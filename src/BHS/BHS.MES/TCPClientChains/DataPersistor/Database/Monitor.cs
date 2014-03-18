using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading;

namespace BHS.MES.TCPClientChains.DataPersistor.Database
{
    public class Monitor: IDisposable
    {
        #region Class Fields and Properties Declaration
        private const int THREAD_INTERVAL = 10;//10 MILLISECOND
        // The name of current class 
        private static readonly string _className =
                    System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Create a logger for use in this class
        private static readonly log4net.ILog _logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        /// <summary>
        /// Property, object of PersistorParameters class.
        /// </summary>
        public BHS.MES.TCPClientChains.DataPersistor.Database.PersistorParameters ClassParameters { get; set; }

        /// <summary>
        /// Property, object of Persistor class.
        /// </summary>
        public BHS.MES.TCPClientChains.DataPersistor.Database.Persistor DBPersistor { get; set; }

        /// <summary>
        /// Property, object of Persistor class.
        /// </summary>
        public BHS.MES.TCPClientChains.Messages.Handlers.MessageHandler MessageHandler { get; set; }

        /// <summary>
        /// ID of class object
        /// </summary>
        public string ObjectID { get; set; }

        private Thread _monitorThread;
        private Thread _2ndMonitorThread;

        //private long _threadCounter;

        private DateTime _lastDBCheckTime;
        private DateTime _lastDBDownloadTime;
        private DateTime _lastSecondaryDBDownloadTime;
        private DateTime _AppLiveUpdateTime;
        private bool _dbEventRaise = false;

        /// <summary>
        /// Event will be raised when database connection can open.
        /// </summary>
        public event EventHandler<EventArgs> OnDBConnected;

        /// <summary>
        /// Event will be raised when database connection can't open.
        /// </summary>
        public event EventHandler<EventArgs> OnDBDisconnected;

        #endregion

        #region Class constructor, dispose, destructor

        public Monitor(PALS.Common.IParameters param, Persistor dbPersistor, Messages.Handlers.MessageHandler messageHandler)
        {
            if ((dbPersistor == null) || (dbPersistor==null))
                throw new Exception("Constractor parameter cannot be null! Creating class object failed! " +
                        "<BHS.MES.TCPClientChains.DataPersistor.Database.Monitor.Constructor()>");

            DBPersistor = dbPersistor;

            MessageHandler = messageHandler;

            // Call Init() method to perform class initialization tasks.
            if (!Init())
                throw new Exception("Instantiate class object failure! " +
                    "<BHS.MES.TCPClientChains.DataPersistor.Database.Monitor.Constructor()>");
        }

        /// <summary>
        /// Class destructer.
        /// </summary>
        ~Monitor()
        {
            Dispose(false);
        }

        /// <summary>
        /// Class method to be called by class wrapper for release resources explicitly.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
        }

        // Dispose(bool disposing) executes in two distinct scenarios. If disposing equals true, 
        // the method has been called directly or indirectly by a user's code. Managed and 
        // unmanaged resources can be disposed.
        // If disposing equals false, the method has been called by the runtime from inside the 
        // finalizer and you should not reference other objects. Only unmanaged resources can be disposed.
        private void Dispose(bool disposing)
        {
            // Release managed & unmanaged resources...
            if (disposing)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object is being destroyed... <" + _className + ".Dispose()>");
            }


            // Terminate message handling thread.
            if (_monitorThread != null)
            {
                _monitorThread.Abort();
                _monitorThread.Join();
                _monitorThread = null;
            }

            if (_2ndMonitorThread != null)
            {
                _2ndMonitorThread.Abort();
                _2ndMonitorThread.Join();
                _2ndMonitorThread = null;
            }

            if (disposing)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object has been destroyed. <" + _className + ".Dispose()>");
            }
        }



        #endregion

        #region Class method

        private bool Init()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            try
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object is initializing... <" + thisMethod + ">");

                ObjectID = string.Empty;

                // Check the database connection before further processing
                if (_logger.IsInfoEnabled)
                {
                    _logger.Info("Database connection checking... <" + thisMethod + ">");
                    _logger.Info("1st (SACDB) Database ConnectionString = (" + DBPersistor.ClassParameters.DBConnectionString + ") <" + thisMethod + ">");
                    _logger.Info("2nd (MISDB) Database ConnectionString = (" + DBPersistor.ClassParameters.SecondaryDBConnectionString + ") <" + thisMethod + ">");
                    _logger.Info("3rd (MESLocal) Database ConnectionString = (" + DBPersistor.ClassParameters.LocalDBConnectionString + ") <" + thisMethod + ">");
                }

                // Perform database initialization tasks:
                // 1. Check database readiness by open DB connection to it. The opened DB connection will be closed immediately after it is opened;
                // 2. Load system parameter settings from database table into global variables.
                DBPersistor._isDBReady = DatabaseInitializing();
                DBPersistor.ClassParameters.SecondaryDBAlive = CheckSecondaryDBAlive();
                if (!DBPersistor._isDBReady)
                {
                    if (_logger.IsWarnEnabled)
                        _logger.Warn("1st (SACDB) Database is not ready for operation!!! <" + thisMethod + ">");
                }

                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object has been initialized. <" + thisMethod + ">");

                // Retrieve SAC public parameter settings from database table [SYSCONFIG]
                //RetrievePublicParametersFromDB();

                // Retrieve Routing Table
                //DBPersistor.GetRoutingTableData();

                //====================================================
                // 2. Load system parameter settings from database table into global variables.
                //DBPersistor.GetAllMESSetting();


                _lastDBDownloadTime = DateTime.Now;
                // Create monitor thread
                _monitorThread = new System.Threading.Thread(new ThreadStart(MonitorThread));
                _monitorThread.Name = _className + ".MonitorThread";
                //_threadCounter = 0;

                // Start message handling thread;
                _monitorThread.Start();
                Thread.Sleep(0);


                _lastSecondaryDBDownloadTime = DateTime.Now;
                _2ndMonitorThread = new System.Threading.Thread(new ThreadStart(SecondaryMonitorThread));
                _2ndMonitorThread.Name = _className + ".SecondaryMonitorThread";
                _2ndMonitorThread.Start();
                Thread.Sleep(0);

                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] MonitorThread has been started. <" + thisMethod + ">");


                return true;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Initializing class setting is failed! <" + thisMethod + ">", ex);

                return false;
            }
        }

        /// <summary>
        /// Perform database initialization tasks:
        /// 1. Check database readiness by open DB connection to it. The opened DB connection will be closed immediately after it is opened;
        /// 2. Load system parameter settings from database table into global variables.
        /// </summary>
        /// <returns></returns>
        private bool DatabaseInitializing()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;

            try
            {
                //====================================================
                // 1. Check database readiness by open DB connection to it. The opened DB connection 
                // will be closed immediately after it is opened ;
                sqlConn = new SqlConnection(DBPersistor.ClassParameters.DBConnectionString);
                sqlConn.Open();

                if (_logger.IsInfoEnabled)
                    _logger.Info("Database connection checking is successed. <" + thisMethod + ">");
                //====================================================

                //====================================================
                // 2. Load system parameter settings from database table into global variables.
                SqlCommand sqlCommand = new SqlCommand(DBPersistor.ClassParameters.stp_RPT_GETDATETIME_FORMAT, sqlConn);
                sqlCommand.CommandType = CommandType.StoredProcedure;
                SqlDataReader sqlReader = sqlCommand.ExecuteReader();
                while (sqlReader.Read())
                {
                    if (!sqlReader.IsDBNull(0)) DBPersistor.ClassParameters.DefaultDateFormat = sqlReader.GetString(0);
                    if (!sqlReader.IsDBNull(1)) DBPersistor.ClassParameters.DefaultTimeFormat = sqlReader.GetString(1);
                }
                DBPersistor.ClassParameters.MainDBAlive = true;
                sqlReader.Close();
                sqlReader.Dispose();
                sqlReader = null;
                sqlCommand.Dispose();
                sqlCommand = null;
                //====================================================

                return true;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Database connection checking is failed! " +
                                    "Please check DB ConnectionString setting, or DB server status. <" + thisMethod + ">", ex);

                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Initializing database is failed! <" + thisMethod + ">", ex);

                return false;
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
        }


        /// <summary>
        /// MonitorThread
        /// </summary>
        private void MonitorThread()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            if (_logger.IsInfoEnabled)
                _logger.Info("DB handling thread has been started. <" + thisMethod + ">");

            try
            {

                while (true)
                {
                    // Check DB Alive status by polling DB Table change status. If any change is detected,
                    // then download data from changed table to local dataset immediately.
                    TimeSpan timeDiffConn, timeDiffDownload, timeDiffAppLiveStatusUpdate;
                    timeDiffConn = DateTime.Now.Subtract(_lastDBCheckTime);
                    timeDiffDownload = DateTime.Now.Subtract(_lastDBDownloadTime);
                    //timeDiffSndDownload = DateTime.Now.Subtract(_lastSecondaryDBDownloadTime);
                    timeDiffAppLiveStatusUpdate = DateTime.Now.Subtract(_AppLiveUpdateTime);
                    if (Math.Abs(timeDiffConn.TotalMilliseconds) >= DBPersistor.ClassParameters.DBAliveCheckThreadInterval)
                    {
                        // 1. Check change status & raise DB live status event upon change.
                        DBConnectionHandling();
                        // 2. Download change data

                        if (DBPersistor.GetSysConfigTableChange())
                        {
                            RetrievePublicParametersFromDB();
                            DBPersistor.GetAllMESSetting();///----Newly added code Ramesh---2013-01-13
                        }

                        if (DBPersistor.ClassParameters.MainDBAlive == true)
                        {
                            //if (DBPersistor.ClassParameters.DisabledDownloadServerToLocalDB == false)
                            //{
                                if (Math.Abs(timeDiffDownload.TotalMilliseconds) >= DBPersistor.ClassParameters.DataChangeMonitorInterval)
                                {
                                    if (MessageHandler.DBPersistor.ClassParameters.DownloadDataToLocal.ToLower()=="true")
                                    {
                                        DBPersistor.DownloadDataFromServer(0, Environment.MachineName, _lastDBDownloadTime);
                                    }
                                    _lastDBDownloadTime = DateTime.Now;
                                }
                            //}
                        }
                        //3. Check historical db connection status.
                        //if (Math.Abs(timeDiffSndDownload.TotalMilliseconds) >= DBPersistor.ClassParameters.DataChangeMonitorInterval)
                        //{

                        //    _lastSecondaryDBDownloadTime = DateTime.Now;
                        //}

                        //4. Update application live status.
                        if (DBPersistor.ClassParameters.MainDBAlive == true)
                        {
                            if (Math.Abs(timeDiffAppLiveStatusUpdate.TotalMilliseconds) >= DBPersistor.ClassParameters.AppLiveUpdateInterval)
                            {
                                DBPersistor.UpdateAppLiveStatus();
                                _AppLiveUpdateTime = DateTime.Now;
                            }
                        }
                        _lastDBCheckTime = DateTime.Now;
                    }

                    Thread.Sleep(THREAD_INTERVAL);
                }
            }
            catch (ThreadAbortException ex)
            {
                ex.ToString();
                Thread.ResetAbort();
                if (_logger.IsInfoEnabled)
                    _logger.Info("DB handling thread has been stopped. <" + thisMethod + ">");
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("DB handling thread failed. <" + thisMethod + ">", ex);

            }
        }

        private void SecondaryMonitorThread()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            if (_logger.IsInfoEnabled)
                _logger.Info("Secondary DB handling thread has been started. <" + thisMethod + ">");

            try
            {

                while (true)
                {
                    TimeSpan timeDiffConn, timeDiffAppLiveStatusUpdate;
                    timeDiffConn = DateTime.Now.Subtract(_lastDBCheckTime);
                    timeDiffAppLiveStatusUpdate = DateTime.Now.Subtract(_AppLiveUpdateTime);
                    if (Math.Abs(timeDiffConn.TotalMilliseconds) >= DBPersistor.ClassParameters.DBAliveCheckThreadInterval)
                    {
                        // 1. Check secondary DB connection.
                        SecondaryDBAliveChecking();

                        ////2. Update application live status.
                        //if (DBPersistor.ClassParameters.SecondaryDBAlive == true)
                        //{
                        //    if (Math.Abs(timeDiffAppLiveStatusUpdate.TotalMilliseconds) >= DBPersistor.ClassParameters.AppLiveUpdateInterval)
                        //    {
                        //        DBPersistor.UpdateAppLiveStatus();
                        //        _AppLiveUpdateTime = DateTime.Now;
                        //    }
                        //}
                        //_lastDBCheckTime = DateTime.Now;
                    }

                    Thread.Sleep(THREAD_INTERVAL);
                }
            }
            catch (ThreadAbortException ex)
            {
                ex.ToString();
                Thread.ResetAbort();
                if (_logger.IsInfoEnabled)
                    _logger.Info("Secondary DB handling thread has been stopped. <" + thisMethod + ">");
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Secondary DB handling thread failed. <" + thisMethod + ">", ex);

            }
        }



        private void DBConnectionHandling()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            try
            {
                if (CheckDBAlive())
                {
                    DBPersistor.GetAllMESSetting();
                    if (_dbEventRaise == false)
                    {
                        if (DBPersistor.ClassParameters.UIConnected == true)
                        {
                            _dbEventRaise = true;
                        }
                        EventHandler<EventArgs> temp = OnDBConnected;
                        DBPersistor.ClassParameters.MainDBAlive = true;
                        //Once main database connection is up, check local data store and upload
                        //data to server and clear local data.
                        if (DBPersistor.ClassParameters.SecondaryDBAlive)
                        {
                            //if (MessageHandler.ClassParameters.DisabledUploadLocalDB == false)
                            //{
                                DBPersistor.UploadLocalToServer();
                            //}
                        }
                        DBPersistor.GetAllMESSetting();

                        if (temp != null)
                            temp(this, new System.EventArgs());
                    }

                    // Check for change table of SYS_CONFIG
                    if (DBPersistor.GetSysConfigTableChange())
                    {
                        RetrievePublicParametersFromDB();
                    }
                }
                else
                {
                    if (_dbEventRaise == true)
                    {
                        _dbEventRaise = false;
                        DBPersistor.ClassParameters.MainDBAlive = false;
                        EventHandler<EventArgs> temp1 = OnDBDisconnected;
                        if (temp1 != null)
                            temp1(this, new System.EventArgs());
                    }
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("DB connection handling is failed. <" + thisMethod + ">", ex);
            }
        }

        private void SecondaryDBAliveChecking()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            try
            {
                if (CheckSecondaryDBAlive())
                {
                    if (DBPersistor.ClassParameters.SecondaryDBAlive == false)
                    {
                        DBPersistor.ClassParameters.SecondaryDBAlive = true;
                        if (DBPersistor.ClassParameters.MainDBAlive)
                            DBPersistor.UploadLocalToServer();
                    }
                }
                else
                {
                    if (DBPersistor.ClassParameters.SecondaryDBAlive == true)
                    {
                        DBPersistor.ClassParameters.SecondaryDBAlive = false;
                    }
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Checking secondary DB connection handling failed. <" + thisMethod + ">", ex);
            }
        }


        /// <summary>
        /// Perform database connection:
        /// 1. Check database readiness by open DB connection to it. The opened DB connection will be closed 
        /// immediately after it is opened;
        /// </summary>
        /// <returns></returns>
        public bool CheckDBAlive()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            bool funcReturnVal = false;

            try
            {
                if (DatabaseInitializing())
                {
                    funcReturnVal = true;
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Initializing database is failed! <" + thisMethod + ">", ex);

                funcReturnVal = false;
            }

            return funcReturnVal;
        }

        /// <summary>
        /// Perform database connection:
        /// 1. Check database readiness by open DB connection to it. The opened DB connection will be closed 
        /// immediately after it is opened;
        /// </summary>
        /// <returns></returns>
        public bool CheckSecondaryDBAlive()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            bool funcReturnVal = false;

            try
            {
                if (CheckSecondaryConnection())
                {
                    funcReturnVal = true;
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Initializing database is failed! <" + thisMethod + ">", ex);

                funcReturnVal = false;
            }

            return funcReturnVal;
        }


        /// <summary>
        /// Perform database initialization tasks:
        /// 1. Check database readiness by open DB connection to it. The opened DB connection will be closed immediately after it is opened;
        /// 2. Load system parameter settings from database table into global variables.
        /// </summary>
        /// <returns></returns>
        private bool CheckSecondaryConnection()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;

            try
            {
                //====================================================
                // 1. Check database readiness by open DB connection to it. The opened DB connection 
                // will be closed immediately after it is opened;
                sqlConn = new SqlConnection(DBPersistor.ClassParameters.SecondaryDBConnectionString);
                sqlConn.Open();

                if (_logger.IsInfoEnabled)
                    _logger.Info("Secondary Database connection checking is successed. <" + thisMethod + ">");
                //====================================================

                //====================================================
                // 2. Call one of the storeprocedure to make sure the database is alive.
                SqlCommand sqlCommand = new SqlCommand(DBPersistor.ClassParameters.stp_RPT_GETDATETIME_FORMAT, sqlConn);
                sqlCommand.CommandType = CommandType.StoredProcedure;
                SqlDataReader sqlReader = sqlCommand.ExecuteReader();
                sqlReader.Close();
                sqlReader.Dispose();
                sqlReader = null;
                sqlCommand.Dispose();
                sqlCommand = null;
                //====================================================

                return true;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Secondary Database connection checking is failed! " +
                                    "Please check DB ConnectionString setting, or DB server status. <" + thisMethod + ">", ex);

                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Initializing secondary database is failed! <" + thisMethod + ">", ex);

                return false;
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
        }

        /// <summary>
        /// Those PLCEngine public parameters whose setting need to be retrieved from SAC database
        /// table [SYSCONFIG], its name must be registered in the parameter list XML file [CFG_SortEngn.XML].
        /// During the service initialization, the pre-registered public parameter name will be readed from
        /// XML file and stored into this HashTable as the element key. The element value will be the 
        /// parameter settings and will be retrieved from DB table and updated into this HashTable by class
        /// DBConnector.
        /// </summary>
        /// <returns></returns>
        public bool RetrievePublicParametersFromDB()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlDataReader reader = null;
            string sDBConnectionString = string.Empty;

            try
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Retrieving SAC public parameter settings from database table [SYSCONFIG]... <" + thisMethod + ">");

                if (DBPersistor.ClassParameters.ParametersHash == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("The Hashtable to store SAC public parameter settings is not instantiated!  <" + thisMethod + ">");

                    return false;
                }

                if (DBPersistor._isDBReady == true)
                {
                    sDBConnectionString = DBPersistor.ClassParameters.DBConnectionString;
                }
                else
                {
                    sDBConnectionString = DBPersistor.ClassParameters.LocalDBConnectionString;
                }

                sqlConn = new SqlConnection(sDBConnectionString);
                sqlCmd = new SqlCommand(DBPersistor.ClassParameters.STPGetSACPublicParams, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlConn.Open();
                reader = sqlCmd.ExecuteReader();

                string key, value;

                while (reader.Read())
                {
                    key = string.Empty;
                    value = string.Empty;

                    if (reader[DBPersistor.ClassParameters.ColumnSysKey] != DBNull.Value)
                    {
                        key = reader[DBPersistor.ClassParameters.ColumnSysKey].ToString();
                    }

                    if (reader[DBPersistor.ClassParameters.ColumnSysValue] != DBNull.Value)
                    {
                        value = reader[DBPersistor.ClassParameters.ColumnSysValue].ToString();
                    }

                    if (key != string.Empty)
                    {
                        if (DBPersistor.ClassParameters.ParametersHash.Contains(key))
                        {
                            // The value that is retrieved from database could be empty string. If so, then
                            // the default value in the XML configuration file will be used.
                            DBPersistor.ClassParameters.ParametersHash[key] = value;

                            //if (DBPersistor.ClassParameters.ParametersHash[key].ToString() == "BCAS_ENABLED")
                            //    DBPersistor.ClassParameters.EnableHBS2BSysKey = Convert.ToBoolean(value);

                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Public Parameter - Registered by Application] Parameter: " + key +
                                    ", Value: " + value + ". <" + thisMethod + ">");
                        }
                        else
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Public Parameter - Unregistered by Application] Parameter: " + key +
                                    ", Value: " + value + ". <" + thisMethod + ">");
                        }
                    }
                }

                if (_logger.IsInfoEnabled)
                    _logger.Info("Retrieving SAC public parameter settings successful. <" + thisMethod + ">");

                return true;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Retrieve Public Parameters From DB failure! <" + thisMethod + ">", ex);

                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Retrieve Public Parameters From DB failure! <" + thisMethod + ">", ex);

                return false;
            }
            finally
            {
                if (reader != null) reader.Close();
                if (sqlConn != null) sqlConn.Close();
            }
        }

        #endregion
    }
}

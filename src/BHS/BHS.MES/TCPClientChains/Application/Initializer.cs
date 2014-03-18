#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       Initializer.cs
// Revision:      1.0 -   14 Jun 2010, By Albert Sun
// =====================================================================================
//
#endregion

using System;
using System.IO;
using System.Xml;
using PALS;
using PALS.Configure;
using PALS.Net;
using log4net;

namespace BHS.MES.TCPClientChains.Application
{
    /// <summary>
    /// Class for centralized application initializing.
    /// </summary>
    public class Initializer : IDisposable
    {
        #region Class Fields and Properties Declaration

        private const string XMLCONFIG_LOG4NET = "log4net";

        private const string OBJECT_ID_INITIALIZER = "1";

        private const string OBJECT_ID_SESSIONMANAGER = "2";
        private const string OBJECT_ID_TCPSERVERCLIENT = "2.1";
        private const string OBJECT_ID_EIP = "2.2";
        private const string OBJECT_ID_CIP = "2.3";
        private const string OBJECT_ID_APPCLIENT = "2.4";
        private const string OBJECT_ID_SOL = "2.5";
        private const string OBJECT_ID_TSYN = "2.6";
        private const string OBJECT_ID_INMID = "2.7";
        private const string OBJECT_ID_ACK = "2.8";
        private const string OBJECT_ID_OUTMID = "2.9";
        private const string OBJECT_ID_SESSIONHANDLER = "2.10";
        private const string OBJECT_ID_SESSIONFORWARDER = "2.11";

        private const string OBJECT_ID_MESSAGEHANDLER = "4";

        //... BHS-PLC Interface Message ...
        private const string OBJECT_ID_IRY = "4.1";
        private const string OBJECT_ID_IEC = "4.2";
        private const string OBJECT_ID_IRM = "4.3";
        //... MES Message ...

        private const string OBJECT_ID_DBPERSISTOR = "5";

        private const string OBJECT_ID_DBMONITOR = "6";

        //private const bool RFC1006_ENABLE = false;

        // The name of current class 
        private static readonly string _className =
                    System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Create a logger for use in this class
        private static readonly log4net.ILog _logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        // Configuration files
        private FileInfo _xmlFileSetting;
        private FileInfo _xmlFileTelegram;

        // -----------------------------------------------------------------------------
        // Used to store the reference of ConfigureAndWatchHandler class object for proper release of file 
        // watchers (done by Dispose() method of Initializer class) when application is closed .
        private ConfigureAndWatchHandler _fileWatchHandler;
        //
        // Code Example: 
        // Instead of watch multiple configuration files in one ConfigureAndWatchHandler class object. Multiple 
        // ConfigureAndWatchHandler objects could be created. And each object is responsible for the watching
        // the changes of different single or multiple configuration files.
        // In this case, the multiple IConfigurationLoader objects need to be created too. Each loader object
        // is paired with one ConfigureAndWatchHandler object for loading settings and watching changes.
        //
        // private ConfigureAndWatchHandler _fileWatchHandler2;
        // private BHS.Engine.TCPClientChains.Configure.XmlSettingLoader2 _xmlLoader2;
        //
        // -----------------------------------------------------------------------------

        // -----------------------------------------------------------------------------
        // Object of class XmlSettingLoader derived from interface IConfigurationLoader for loading setting from XML file.
        private BHS.MES.TCPClientChains.Configure.XmlSettingLoader _xmlLoader;
        public BHS.MES.TCPClientChains.Configure.XmlSettingLoader XmlLoader { get; set; }
        //
        // Code Example: 
        // Object of class IniSettingLoader derived from interface IConfigurationLoader for loading setting from INI file.
        //
        // private BHS.Engine.TCPClientChains.Configure.IniSettingLoader _iniLoader;
        //
        // -----------------------------------------------------------------------------

        // -----------------------------------------------------------------------------
        // Declare Engine Service (TCP Client) - MessageRouter Service (TCP Server) chain classes
        // IREL.Net.Handlers classes object
        private PALS.Common.IChain _forwarder;
        // PALS.Net.Managers.SessionManager object
        private PALS.Net.Managers.SessionManager _manager;
        // PALS.Net.Filters chain classes
        private PALS.Common.IChain _outMID;
        private PALS.Common.IChain _ack;
        private PALS.Common.IChain _inMID;
        private PALS.Common.IChain _sol;
        private PALS.Common.IChain _tsyn;
        private PALS.Common.IChain _appClient;
        private PALS.Common.IChain _cip;
        private PALS.Common.IChain _eip;
        // -----------------------------------------------------------------------------

        //... MES-PLC Message ...
        private Messages.Handlers.IRY _IRY;
        //private Messages.Handlers.IRM _IRM;
        //private Messages.Handlers.IEC _IEC;

        private BHS.MES.TCPClientChains.DataPersistor.Database.Persistor _DBPersistor;
        private BHS.MES.TCPClientChains.DataPersistor.Database.Monitor _Monitor;
        private BHS.MES.TCPClientChains.Messages.Handlers.MessageHandler _msgHandler;

        /// <summary>
        /// Get or set the BHS.Engine.TCPClientChains.Messages.Handlers.Messagehandler class object.
        /// </summary>
        public BHS.MES.TCPClientChains.Messages.Handlers.MessageHandler MsgHandler
        {
            get { return _msgHandler; }
            set { _msgHandler = value; }
        }

        /// <summary>
        /// null
        /// </summary>
        public string ObjectID { get; set; }

        /// <summary>
        /// Event will be raised when message is received.
        /// </summary>
        public event EventHandler<MessageEventArgs> OnReceived;
        /// <summary>
        /// Event will be raised when specific channel connection of Gateway-External device chain is opened.
        /// </summary>
        public event EventHandler<MessageEventArgs> OnConnected;
        /// <summary>
        /// Event will be raised when specific channel connection of Gateway-External device chain is closed.
        /// </summary>
        public event EventHandler<MessageEventArgs> OnDisconnected;

        /// <summary>
        /// Event will be raised when database connection can open.
        /// </summary>
        public event EventHandler<EventArgs> OnDBConnected;

        /// <summary>
        /// Event will be raised when database connection can't open.
        /// </summary>
        public event EventHandler<EventArgs> OnDBDisconnected;

        #endregion

        #region Class Constructor, Dispose, & Destructor

        /// <summary>
        /// Application global initializer for centralized performing of application initializing tasks.
        /// </summary>
        /// <param name="XMLFileSetting"></param>
        /// <param name="XMLFileTelegram"></param>
        public Initializer(string XMLFileSetting, string XMLFileTelegram)
        {
            XmlElement xmlRoot = PALS.Utilities.XMLConfig.GetConfigFileRootElement(XMLFileSetting);
            if (xmlRoot == null)
            {
                throw new Exception("Open application setting XML configuration file failure!");
            }

            XmlElement log4netConfig = (XmlElement)PALS.Utilities.XMLConfig.GetConfigSetElement(ref xmlRoot, XMLCONFIG_LOG4NET);
            if (log4netConfig == null)
            {
                throw new System.Exception("There is no <" + XMLCONFIG_LOG4NET +
                                "> settings in the XML configuration file!");
            }
            else
            {
                _xmlFileSetting = new System.IO.FileInfo(XMLFileSetting);
                _xmlFileTelegram = new System.IO.FileInfo(XMLFileTelegram);

                log4net.Config.XmlConfigurator.Configure(log4netConfig);
                _logger.Info(".");
                _logger.Info(".");
                _logger.Info(".");
                _logger.Info("[..................] <" + _className + ".Initializer()>");
                _logger.Info("[...App Starting...] <" + _className + ".Initializer()>");
                _logger.Info("[..................] <" + _className + ".Initializer()>");
            }
        }

        /// <summary>
        /// Destructer of Initializer class.
        /// </summary>
        ~Initializer()
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
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            // Release managed & unmanaged resources...
            if (disposing)
            {
                _logger.Info(".");
                _logger.Info("Class:[" + _className + "] object is being destroyed... <" + thisMethod + ">");
            }

            // -----------------------------------------------------------------------------
            // Destory TCPClient chain classes, MES2PLC1
            if (_outMID != null)
            {
                PALS.Net.Filters.Application.OutgoingMessageIdentifier outMID =
                            (PALS.Net.Filters.Application.OutgoingMessageIdentifier)_outMID;
                outMID.Dispose();
                _outMID = null;
            }

            if (_ack != null)
            {
                PALS.Net.Filters.Acknowledge.ACK ack =
                            (PALS.Net.Filters.Acknowledge.ACK)_ack;
                ack.Dispose();
                _ack = null;
            }

            if (_inMID != null)
            {
                PALS.Net.Filters.Application.IncomingMessageIdentifier inMID =
                            (PALS.Net.Filters.Application.IncomingMessageIdentifier)_inMID;
                inMID.Dispose();
                _inMID = null;
            }

            if (_sol != null)
            {
                PALS.Net.Filters.SignOfLife.SOL sol =
                            (PALS.Net.Filters.SignOfLife.SOL)_sol;
                sol.Dispose();
                _sol = null;
            }

            if (_appClient != null)
            {
                PALS.Net.Filters.Application.AppClient appCln =
                            (PALS.Net.Filters.Application.AppClient)_appClient;
                appCln.Dispose();
                _appClient = null;
            }

            if (_tsyn != null)
            {
                PALS.Net.Filters.TimeSynchronizing.TimeSync tsyn =
                    (PALS.Net.Filters.TimeSynchronizing.TimeSync)_tsyn;
                tsyn.Dispose();
                _tsyn = null;
            }

            if (_cip != null)
            {
                PALS.Net.Filters.EIPCIP.CIP cip =
                    (PALS.Net.Filters.EIPCIP.CIP)_cip;
                cip.Dispose();
                _cip = null;
            }

            if (_eip != null)
            {
                PALS.Net.Filters.EIPCIP.EIP eip =
                    (PALS.Net.Filters.EIPCIP.EIP)_eip;
                eip.Dispose();
                _eip = null;
            }

            if (_forwarder != null)
            {
                BHS.MES.TCPClientChains.Messages.Handlers.SessionForwarder fwdr =
                            (BHS.MES.TCPClientChains.Messages.Handlers.SessionForwarder)_forwarder;
                fwdr.Dispose();
                _forwarder = null;
            }

            if (_manager != null)
            {
                PALS.Net.Managers.SessionManager mgr =
                            (PALS.Net.Managers.SessionManager)_manager;
                mgr.Dispose();
                _manager = null;

                System.Threading.Thread.Sleep(200);
            }
            // -----------------------------------------------------------------------------

            
            // -----------------------------------------------------------------------------
            // Destory message handlers.
            if (_msgHandler != null)
            {
                _msgHandler.Dispose();
                _msgHandler = null;
            }
            // -----------------------------------------------------------------------------

            // -----------------------------------------------------------------------------
            // Destory Database Persistor.
            if (_Monitor != null)
            {
                _Monitor.Dispose();
                _DBPersistor = null;
            }

            if (_DBPersistor != null)
            {
                _DBPersistor.Dispose();
                _DBPersistor = null;
            }
            // -----------------------------------------------------------------------------


            // -----------------------------------------------------------------------------
            // Destory configuration file watcher.
            if (_fileWatchHandler != null) _fileWatchHandler.Dispose();
            if (XmlLoader != null) XmlLoader.Dispose();
            if (_xmlLoader != null) _xmlLoader.Dispose();
            // -----------------------------------------------------------------------------

            if (disposing)
            {
                _logger.Info("Class:[" + _className + "] object has been destroyed. <" + thisMethod + ">");
            }
        }
        #endregion

        #region Class Method Declaration.
        /// <summary>
        /// Init() method of Initializer class is the place to perform the initialization
        /// tasks for current application. All initialization tasks needed to be done during
        /// the application startup time should be performed here.
        /// </summary>
        /// <returns></returns>
        public bool Init()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            DateTime pref = DateTime.Now;

            try
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Initializing application settings... <" + thisMethod + ">");

                _xmlLoader = new BHS.MES.TCPClientChains.Configure.XmlSettingLoader();
                _xmlLoader.OnReloadSettingCompleted += new EventHandler(Handler_OnReloadSettingCompleted);
                XmlLoader = _xmlLoader;
                //-----------------------------------------------------------------------------
                // Load system parameters from two configuration files (CFG_MDS2CCTVGW.xml, CFG_Telegrams.xml).
                // And also start watcher to detect the change of files.  and reload setting if change is detected.
                //
                _fileWatchHandler = PALS.Configure.AppConfigurator.ConfigureAndWatch(
                                        _xmlLoader, _xmlFileSetting, _xmlFileTelegram);
                //
                // Note: _fileWatchHandler need to be released in the Dispose() method of Initializer class.
                //-----------------------------------------------------------------------------

                #region Code Sample for loading application settings
                //-----------------------------------------------------------------------------
                // Code Example 1:
                // Load system parameters from single configuration file (CFG_MDS2CCTVGW.xml), and also start 
                // watcher to detect the change of files.  and reload setting if change is detected.
                //
                //_configFileHandler = PALS.Configure.AppConfigurator.ConfigureAndWatch(_xmlLoader, _xmlFileSetting);
                //
                // Note: _fileWatchHandler need to be released in the Dispose() method of Initializer class.
                //-----------------------------------------------------------------------------

                //-----------------------------------------------------------------------------
                // Code Example 2:
                // Load system parameters from two configuration files (CFG_MDS2CCTVGW.xml, CFG_Telegrams.xml),  
                // but no file change detection is required.
                //
                //PALS.Configure.AppConfigurator.Configure(_xmlLoader, _xmlFileSetting, _xmlFileTelegram);
                //
                //-----------------------------------------------------------------------------

                //-----------------------------------------------------------------------------
                // Code Example 3:
                // Load system parameters from single configuration file (CFG_MDS2CCTVGW.xml), but no file 
                // change detection is required.
                //
                //PALS.Configure.AppConfigurator.Configure(_xmlLoader, _xmlFileSetting);
                //
                //-----------------------------------------------------------------------------

                //-----------------------------------------------------------------------------
                // Code Example 4:
                // Load system parameters from multiple configuration file (CFG_MDS2CCTVGW.xml, CFG_Telegrams.xml). 
                // Only one file (CFG_MDS2CCTVGW.xml) need to be watched for the changes, but another one
                // does not need.
                //
                //_configFileHandler = PALS.Configure.AppConfigurator.ConfigureAndWatch(_xmlLoader, _xmlFileSetting);
                //PALS.Configure.AppConfigurator.Configure(_xmlLoader2, _xmlFileTelegram);
                //
                // Note: only _fileWatchHandler need to be released in the Dispose() method of Initializer class.
                //-----------------------------------------------------------------------------
                #endregion

                // Build TCPClient Communication Chain
                BuildTCPClientChain();

                // ------------------------------------------------------------------------------------
                // Create database Persistor object
                // ------------------------------------------------------------------------------------
                _DBPersistor = new BHS.MES.TCPClientChains.DataPersistor.Database.Persistor(
                                _xmlLoader.Paramters_DBPersistor);
                _DBPersistor.ObjectID = OBJECT_ID_DBPERSISTOR;
                // ------------------------------------------------------------------------------------

                // ------------------------------------------------------------------------------------
                // Create Application Message Handler class ojects. 
                // Due to message handler classes object have the reference to Database.Persistor class 
                // object, hence CreateMessageHandlers() must be invoked after Database.Persistor class 
                // has been successfully instentiated.
                // ------------------------------------------------------------------------------------
                if (!CreateMessageHandlers())
                    throw new Exception("Instantiate message handlers failure!");
                // ------------------------------------------------------------------------------------

                // ------------------------------------------------------------------------------------
                // Create centralized message handler object. And set its references to individual message handler class objects.
                // ------------------------------------------------------------------------------------
                _msgHandler = new BHS.MES.TCPClientChains.Messages.Handlers.MessageHandler(
                                _xmlLoader.Paramters_MsgHandler,
                                (BHS.MES.TCPClientChains.Messages.Handlers.SessionForwarder)_forwarder);

                _msgHandler.TCPServerClientParames = (PALS.Net.Transports.TCP.TCPServerClientParameters)_manager.ClassParameters;
                
                _msgHandler.ObjectID = OBJECT_ID_MESSAGEHANDLER;
                _msgHandler.DBPersistor = _DBPersistor;
                _msgHandler.IRY = _IRY;
                // Init() method can only be invoked after Persistor and individual message handlers of MessageHandler class
                // are refered to the actual objects.
                _msgHandler.Init();
                //====================================================
                // Add in codes here for refering to other message handler objects required by other projects.
                // ...
                //====================================================

                _Monitor = new BHS.MES.TCPClientChains.DataPersistor.Database.Monitor(_xmlLoader.Paramters_DBPersistor, _DBPersistor, _msgHandler);
                _Monitor.ObjectID = OBJECT_ID_DBMONITOR;

                _msgHandler.OnReceived += new EventHandler<MessageEventArgs>(MsgHandler_OnReceived);
                _msgHandler.OnConnected += new EventHandler<MessageEventArgs>(MsgHandler_OnConnected);
                _msgHandler.OnDisconnected += new EventHandler<MessageEventArgs>(MsgHandler_OnDisconnected);
                _Monitor.OnDBConnected += new EventHandler<EventArgs>(DBHandler_OnDBConnected);
                _Monitor.OnDBDisconnected += new EventHandler<EventArgs>(DBHandler_OnDBDisConnected);
                // ------------------------------------------------------------------------------------
                // MessageHandler object must be created before start session connections as below
                // ------------------------------------------------------------------------------------

                // Open underlying layer connection to open TCP connections
                if (_manager != null)
                {
                    // Open TCP Server Client connection right now...
                    _manager.SessionStart();
                    // Turn on auto re-connect indicator to auto re-open the connection when it is closed.
                    //((PALS.Net.Transports.TCP.TCPClientParameters)_manager.ClassParameters).IsAutoReconnected = true;
                }
                else
                    throw new Exception("SessionManager of TCPClient chain is not created!");

                if (_logger.IsInfoEnabled)
                {
                    _logger.Info("Initializing application setting is successed. <" + thisMethod + ">");
                    _logger.Info("Total loading time: " + Math.Abs(DateTime.Now.Subtract(pref).Milliseconds).ToString() + " ms. <" + thisMethod + ">");
                }

                return true;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Initializing class setting is failed! <" + thisMethod + ">", ex);

                if (_manager != null) _manager.Dispose();
                if (_eip != null) ((PALS.Net.Filters.Frame.Frame)_eip).Dispose();
                if (_cip != null) ((PALS.Net.Filters.Frame.Frame)_cip).Dispose();
                if (_tsyn != null) ((PALS.Net.Filters.Frame.Frame)_tsyn).Dispose();
                if (_appClient != null) ((PALS.Net.Filters.Application.AppClient)_appClient).Dispose();
                if (_sol != null) ((PALS.Net.Filters.SignOfLife.SOL)_sol).Dispose();
                if (_inMID != null) ((PALS.Net.Filters.Application.IncomingMessageIdentifier)_inMID).Dispose();
                if (_ack != null) ((PALS.Net.Filters.Acknowledge.ACK)_ack).Dispose();
                if (_outMID != null) ((PALS.Net.Filters.Application.OutgoingMessageIdentifier)_outMID).Dispose();

                if (_IRY != null) _IRY.Dispose();

                if (_msgHandler != null) _msgHandler.Dispose();
                if (_DBPersistor != null) _DBPersistor.Dispose();
                
                return false;
            }
        }


        /// <summary>
        /// ------------------------------------------------------------------------------------
        /// Build "Handler-Filter-Transport" chain for MES application 
        /// TCPClient chain by following below sequence:
        /// ------------------------------------------------------------------------------------
        /// BHS.Engine.TCPClientChains.Messages.Handlers.SessionForwarder
        /// PALS.Net.handlers.SessionHandler
        /// PALS.Net.Filters.Application.OutgoingMessageIdentifier 
        /// PALS.Net.Filters.Acknowledge.ACK 
        /// PALS.Net.Filters.Application.IncomingMessageIdentifier 
        /// PALS.Net.Filters.SignOfLife.SOL 
        /// PALS.Net.Filters.Application.APPClient 
        /// PALS.Net.FiltersFrame.Frame
        /// PALS.Net.Transports.TCP.TCPClient
        /// ------------------------------------------------------------------------------------
        /// </summary>
        private void BuildTCPClientChain()
        {
            // Instantiate Sessionmanager class to build basice TCPClient-SessioHandler chain
            PALS.Common.IParameters paramTCPSvrCln = _xmlLoader.Paramters_TCPServerClient;
            _manager = new PALS.Net.Managers.SessionManager(
                        PALS.Net.Common.TransportProtocol.TCPServerClient, ref paramTCPSvrCln);
            _manager.ObjectID = OBJECT_ID_SESSIONMANAGER;
            _manager.TransportObjectID = OBJECT_ID_TCPSERVERCLIENT ;
            _manager.HandlerObjectID = OBJECT_ID_SESSIONHANDLER;
            // Opening GW2External device connection shall not be started automatically. 
            // It will be started only after the GW2Internal Engine service connection is opened.
            //((PALS.Net.Transports.TCP.TCPServerClientParameters)_managerGW2External.ClassParameters).IsAutoReconnected = false;

            // Instantiate EIP class
            PALS.Common.IParameters paramEIP = _xmlLoader.Paramters_EIP;
            _eip = new PALS.Net.Filters.EIPCIP.EIP(ref paramEIP);
            ((PALS.Net.Common.AbstractProtocolChain)_eip).ObjectID = OBJECT_ID_EIP;

            // Instantiate CIP class
            PALS.Common.IParameters paramCIP = _xmlLoader.Paramters_CIP;
            _cip = new PALS.Net.Filters.EIPCIP.CIP(ref paramCIP);
            ((PALS.Net.Common.AbstractProtocolChain)_cip).ObjectID = OBJECT_ID_CIP;

            // Instantiate AppClient class
            PALS.Common.IParameters paramApp = _xmlLoader.Paramters_AppClient;
            _appClient = new PALS.Net.Filters.Application.AppClient(ref paramApp);
            ((PALS.Net.Common.AbstractProtocolChain)_appClient).ObjectID = OBJECT_ID_APPCLIENT;

            // Instantiate SOL class
            PALS.Common.IParameters paramSOL = _xmlLoader.Paramters_SOL;
            _sol = new PALS.Net.Filters.SignOfLife.SOL(ref paramSOL);
            ((PALS.Net.Common.AbstractProtocolChain)_sol).ObjectID = OBJECT_ID_SOL;

            // Instantiate TSYN class
            PALS.Common.IParameters paramTSYN = _xmlLoader.Paramters_TSYN;
            _tsyn = new PALS.Net.Filters.TimeSynchronizing.TimeSync(ref paramTSYN);
            ((PALS.Net.Common.AbstractProtocolChain)_tsyn).ObjectID = OBJECT_ID_TSYN;

            // Instantiate Message Identifier (MID) class
            PALS.Common.IParameters paramMID = _xmlLoader.Paramters_MID;
            _inMID = new PALS.Net.Filters.Application.IncomingMessageIdentifier(ref paramMID);
            ((PALS.Net.Common.AbstractProtocolChain)_inMID).ObjectID = OBJECT_ID_INMID;
            _outMID = new PALS.Net.Filters.Application.OutgoingMessageIdentifier(ref paramMID);
            ((PALS.Net.Common.AbstractProtocolChain)_outMID).ObjectID = OBJECT_ID_OUTMID;

            // Instantiate ACK class
            PALS.Common.IParameters paramACK = _xmlLoader.Paramters_ACK;
            _ack = new PALS.Net.Filters.Acknowledge.ACK(ref paramACK);
            ((PALS.Net.Common.AbstractProtocolChain)_ack).ObjectID = OBJECT_ID_ACK;

            // Instantiate GW2ExternalSessionForwarder class
            _forwarder = new BHS.MES.TCPClientChains.Messages.Handlers.SessionForwarder(null);
            ((PALS.Net.Common.AbstractProtocolChain)_forwarder).ObjectID = OBJECT_ID_SESSIONFORWARDER;

            // Build GW2External communication chain
            _manager.AddHandlerToLast(ref _forwarder);
            _manager.AddFilterToLast(ref _outMID);
            _manager.AddFilterToLast(ref _ack);
            _manager.AddFilterToLast(ref _inMID);
            _manager.AddFilterToLast(ref _tsyn);
            _manager.AddFilterToLast(ref _sol);
            _manager.AddFilterToLast(ref _appClient);
            _manager.AddFilterToLast(ref _cip);
            _manager.AddFilterToLast(ref _eip);
        }

        /// <summary>
        /// ------------------------------------------------------------------------------------
        /// Build "Handler-Filter-Transport" chain for CCTV Engine Service application 
        /// TCPClient chain by following below sequence:
        /// ------------------------------------------------------------------------------------
        /// BHS.Engine.TCPClientChains.Messages.Handlers.SessionForwarder
        /// PALS.Net.handlers.SessionHandler
        /// PALS.Net.Filters.Application.OutgoingMessageIdentifier 
        /// PALS.Net.Filters.Acknowledge.ACK 
        /// PALS.Net.Filters.Application.IncomingMessageIdentifier 
        /// PALS.Net.Filters.SignOfLife.SOL 
        /// PALS.Net.Filters.Application.APPClient 
        /// PALS.Net.FiltersFrame.Frame
        /// PALS.Net.Transports.TCP.TCPClient
        /// ------------------------------------------------------------------------------------
        /// </summary>

        //private void BuildTCPClientChainMES2PLC2()
        //{
        //    // Instantiate Sessionmanager class to build basice TCPClient-SessioHandler chain
        //    PALS.Common.IParameters paramTCPCln = _xmlLoader.Paramters_TCPClient_MES2PLC2;
        //    _managerMES2PLC2 = new PALS.Net.Managers.SessionManager(
        //                PALS.Net.Common.TransportProtocol.TCPClient, ref paramTCPCln);
        //    _managerMES2PLC2.ObjectID = OBJECT_ID_MES2PLC2_SESSIONMANAGER;
        //    _managerMES2PLC2.TransportObjectID = OBJECT_ID_MES2PLC2_TCPCLIENT;
        //    _managerMES2PLC2.HandlerObjectID = OBJECT_ID_MES2PLC2_SESSIONHANDLER;
        //    // Do not start socket auto connection process until TCPClient chain is built up.
        //    ((PALS.Net.Transports.TCP.TCPClientParameters)_managerMES2PLC2.ClassParameters).IsAutoReconnected = false;

        //    //// Instantiate RFC1006 class
        //    PALS.Common.IParameters paramRFC1006 = _xmlLoader.Paramters_RFC1006Client_MES2PLC2;
        //    _rfc1006ClientMES2PLC2 = new PALS.Net.Filters.RFC1006.RFC1006Client(ref paramRFC1006);
        //    ((PALS.Net.Common.AbstractProtocolChain)_rfc1006ClientMES2PLC2).ObjectID = OBJECT_ID_MES2PLC2_RFC1006CLIENT;

        //    // Instantiate Frame Class
        //    PALS.Common.IParameters paramFrame = _xmlLoader.Paramters_Frame;
        //    _frameMES2PLC2 = new PALS.Net.Filters.Frame.Frame(ref paramFrame);
        //    ((PALS.Net.Common.AbstractProtocolChain)_frameMES2PLC2).ObjectID = OBJECT_ID_MES2PLC2_FRAME;

        //    // Instantiate AppClient class
        //    PALS.Common.IParameters paramApp = _xmlLoader.Paramters_AppClient_MES2PLC2;
        //    _appClientMES2PLC2 = new PALS.Net.Filters.Application.AppClient(ref paramApp);
        //    ((PALS.Net.Common.AbstractProtocolChain)_appClientMES2PLC2).ObjectID = OBJECT_ID_MES2PLC2_APPCLIENT;

        //    // Instantiate SOL class
        //    PALS.Common.IParameters paramSOL = _xmlLoader.Paramters_SOL;
        //    _solMES2PLC2 = new PALS.Net.Filters.SignOfLife.SOL(ref paramSOL);
        //    ((PALS.Net.Common.AbstractProtocolChain)_solMES2PLC2).ObjectID = OBJECT_ID_MES2PLC2_SOL;

        //    // Instantiate Message Identifier (MID) class
        //    PALS.Common.IParameters paramMID = _xmlLoader.Paramters_MID;
        //    _inMIDMES2PLC2 = new PALS.Net.Filters.Application.IncomingMessageIdentifier(ref paramMID);
        //    ((PALS.Net.Common.AbstractProtocolChain)_inMIDMES2PLC2).ObjectID = OBJECT_ID_MES2PLC2_INMID;
        //    _outMIDMES2PLC2 = new PALS.Net.Filters.Application.OutgoingMessageIdentifier(ref paramMID);
        //    ((PALS.Net.Common.AbstractProtocolChain)_outMIDMES2PLC2).ObjectID = OBJECT_ID_MES2PLC2_OUTMID;

        //    // Instantiate ACK class
        //    PALS.Common.IParameters paramACK = _xmlLoader.Paramters_ACK;
        //    _ackMES2PLC2 = new PALS.Net.Filters.Acknowledge.ACK(ref paramACK);
        //    ((PALS.Net.Common.AbstractProtocolChain)_ackMES2PLC2).ObjectID = OBJECT_ID_MES2PLC2_ACK;

        //    // Instantiate GW2InternalSessionForwarder class
        //    _forwarderMES2PLC2 = new BHS.MES.TCPClientChains.Messages.Handlers.MES2PLC2SessionForwarder(null);
        //    ((PALS.Net.Common.AbstractProtocolChain)_forwarderMES2PLC2).ObjectID = OBJECT_ID_MES2PLC2_SESSIONFORWARDER;

        //    // Build TCPClient communication chain
        //    _managerMES2PLC2.AddHandlerToLast(ref _forwarderMES2PLC2);
        //    _managerMES2PLC2.AddFilterToLast(ref _outMIDMES2PLC2);
        //    _managerMES2PLC2.AddFilterToLast(ref _ackMES2PLC2);
        //    _managerMES2PLC2.AddFilterToLast(ref _inMIDMES2PLC2);
        //    _managerMES2PLC2.AddFilterToLast(ref _solMES2PLC2);
        //    _managerMES2PLC2.AddFilterToLast(ref _appClientMES2PLC2);
        //    _managerMES2PLC2.AddFilterToLast(ref _rfc1006ClientMES2PLC2);
        //    //_managerMES2PLC2.AddFilterToLast(ref _frameMES2PLC2);
        //}

        /// <summary>
        /// Event handler of ReloadSettingCompleted event fired by IConfigurationLoader interface 
        /// implemented class method LoadSettingFromConfigFile() upon the reloading setting from
        /// changed file is successfully completed. 
        /// 
        /// This event handler is to make sure the reloaded settings can be taken effective 
        /// immediately.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Handler_OnReloadSettingCompleted(object sender, EventArgs e)
        {
            // Reassign the reference of new parameter class object to MES2PLC1 chain classes
            ((PALS.Net.Managers.SessionManager)_manager).ClassParameters =
                    _xmlLoader.Paramters_TCPServerClient;
            
            //############################################################################
            // TO-DO-TASK: To change the parameter after PALS framework update.
            //((PALS.Net.Filters.RFC1006.RFC1006Parameters)_rfc1006ClientMES2PLC1).ClassParameters =
            //        (PALS.Net.Filters.Frame.FrameParameters)_xmlLoader.Paramters_RFC1006Client;
            //############################################################################

            ((PALS.Net.Filters.Application.AppClient)_appClient).ClassParameters =
                    (PALS.Net.Filters.Application.AppClientParameters)_xmlLoader.Paramters_AppClient;
            ((PALS.Net.Filters.SignOfLife.SOL)_sol).ClassParameters =
                    (PALS.Net.Filters.SignOfLife.SOLParameters)_xmlLoader.Paramters_SOL;
            ((PALS.Net.Filters.Application.IncomingMessageIdentifier)_inMID).ClassParameters =
                    (PALS.Net.Filters.Application.MessageIdentifierParameters)_xmlLoader.Paramters_MID;
            ((PALS.Net.Filters.Acknowledge.ACK)_ack).ClassParameters =
                    (PALS.Net.Filters.Acknowledge.ACKParameters)_xmlLoader.Paramters_ACK;
            ((PALS.Net.Filters.Application.OutgoingMessageIdentifier)_outMID).ClassParameters =
                    (PALS.Net.Filters.Application.MessageIdentifierParameters)_xmlLoader.Paramters_MID;

            // Reassign the reference of new parameter class object to MES2PLC2 chain classes
            ((PALS.Net.Managers.SessionManager)_manager).ClassParameters =
                    _xmlLoader.Paramters_TCPServerClient;

            //############################################################################
            // TO-DO-TASK: To change the parameter after PALS framework update.
            //((PALS.Net.Filters.RFC1006.RFC1006Parameters)_rfc1006ClientMES2PLC2).ClassParameters =
            //        (PALS.Net.Filters.Frame.FrameParameters)_xmlLoader.Paramters_RFC1006Client;
            //############################################################################

            ((PALS.Net.Filters.Application.AppClient)_appClient).ClassParameters =
                    (PALS.Net.Filters.Application.AppClientParameters)_xmlLoader.Paramters_AppClient;
            ((PALS.Net.Filters.SignOfLife.SOL)_sol).ClassParameters =
                    (PALS.Net.Filters.SignOfLife.SOLParameters)_xmlLoader.Paramters_SOL;
            ((PALS.Net.Filters.Application.IncomingMessageIdentifier)_inMID).ClassParameters =
                    (PALS.Net.Filters.Application.MessageIdentifierParameters)_xmlLoader.Paramters_MID;
            ((PALS.Net.Filters.Acknowledge.ACK)_ack).ClassParameters =
                    (PALS.Net.Filters.Acknowledge.ACKParameters)_xmlLoader.Paramters_ACK;
            ((PALS.Net.Filters.Application.OutgoingMessageIdentifier)_outMID).ClassParameters =
                    (PALS.Net.Filters.Application.MessageIdentifierParameters)_xmlLoader.Paramters_MID;

            // Reassign the reference of new parameter class object to MessageHandler class
            ((BHS.MES.TCPClientChains.Messages.Handlers.MessageHandler)_msgHandler).ClassParameters =
                    (BHS.MES.TCPClientChains.Messages.Handlers.MessageHandlerParameters)_xmlLoader.Paramters_MsgHandler;
            // Reassign the reference of new parameter class object to Persistor class
            ((BHS.MES.TCPClientChains.DataPersistor.Database.Persistor)_DBPersistor).ClassParameters =
                    (BHS.MES.TCPClientChains.DataPersistor.Database.PersistorParameters)_xmlLoader.Paramters_DBPersistor;
        }

        private void MsgHandler_OnReceived(object sender, MessageEventArgs e)
        {
            // Copy to a temporary variable to be thread-safe.
            EventHandler<MessageEventArgs> temp = OnReceived;
            // Event could be null if there are no subscribers, so check it before raise event
            if (temp != null)
                // Raise OnReceived event upon message is received.
                temp(this, e);
        }

        private void MsgHandler_OnConnected(object sender, MessageEventArgs e)
        {
            // Copy to a temporary variable to be thread-safe.
            EventHandler<MessageEventArgs> temp = OnConnected;
            // Event could be null if there are no subscribers, so check it before raise event
            if (temp != null)
                // Raise OnConnected event upon channel connection is opened.
                temp(this, e);
        }

        private void MsgHandler_OnDisconnected(object sender, MessageEventArgs e)
        {
            // Copy to a temporary variable to be thread-safe.
            EventHandler<MessageEventArgs> temp = OnDisconnected;
            // Event could be null if there are no subscribers, so check it before raise event
            if (temp != null)
                // Raise OnDisconnected event upon channel connection is closed.
                temp(this, e);
        }

        private void DBHandler_OnDBConnected(object sender, EventArgs e)
        {
            // Copy to a temporary variable to be thread-safe.
            EventHandler<EventArgs> temp = OnDBConnected;
            // Event could be null if there are no subscribers, so check it before raise event
            if (temp != null)
                // Raise OnDisconnected event upon channel connection is closed.
                temp(this, e);
        }

        private void DBHandler_OnDBDisConnected(object sender, EventArgs e)
        {
            // Copy to a temporary variable to be thread-safe.
            EventHandler<EventArgs> temp = OnDBDisconnected;
            // Event could be null if there are no subscribers, so check it before raise event
            if (temp != null)
                // Raise OnDisconnected event upon channel connection is closed.
                temp(this, e);
        }

        private bool CreateMessageHandlers()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            try
            {
                //IRY message handler
                _IRY = new BHS.MES.TCPClientChains.Messages.Handlers.IRY();
                _IRY.ObjectID = OBJECT_ID_IRY;
                _IRY.DBPersistor = _DBPersistor;
                _IRY.MessageFormat = ((Messages.Handlers.MessageHandlerParameters)
                                _xmlLoader.Paramters_MsgHandler).MessageFormat_IRY;

                return true;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("System Exception! <" + thisMethod + ">", ex);

                return false;
            }
        }
        #endregion
    }
}

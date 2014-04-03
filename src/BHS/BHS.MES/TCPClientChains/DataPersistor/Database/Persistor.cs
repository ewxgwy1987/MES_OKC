#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       Persistor.cs
// Revision:      1.0 -   14 Jun 2010, By Albert Sun
// =====================================================================================
//
#endregion

using System;
using System.Data;
using System.Xml;
using PALS.Security;
using PALS.Utilities;
using PALS.Security.General;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;

namespace BHS.MES.TCPClientChains.DataPersistor.Database
{
    /// <summary>
    /// The single contact with Database
    /// </summary>
    public class Persistor : IDisposable
    {
        #region Class Fields and Properties Declaration
        // The name of current class 
        private static readonly string _className =
                    System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Create a logger for use in this class
        private static readonly log4net.ILog _logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        /// <summary>
        /// ID of class object
        /// </summary>
        public string ObjectID { get; set; }

        /// <summary>
        /// Property, object of PersistorParameters class.
        /// </summary>
        public MES.TCPClientChains.DataPersistor.Database.PersistorParameters ClassParameters { get; set; }

        /// <summary>
        /// Subsystem
        /// </summary>
        public string Subsystem { get; set; }

        ///// <summary>
        ///// Property, object of RoutingTableSyncdHash class.
        ///// </summary>
        //public Hashtable RoutingTableSyncdHash { get; set; }

        // Indicate whether the database has been ready when MES is starting.
        // When MES is starting, DBConnector class will check the database by means of 
        // open one DB connection to it. It connection is able to be opened, it represents
        // that DB is ready. And this indicater (m_IsDBReady) will be change to True as well.
        public bool _isDBReady;

        // This variable will use when persistor is starting to download data from server to prevent
        // concurrency download from initialization and regular download. Once this value is set to true
        // persistor will not download again from server to local.
        private bool _isRunning = false;


        // RoundRobinSyncdHash stores the last sorted destination of given flight. 
        // SortByRoundRobinScheme() method will lookup this hash table to find out the
        // next destination of given flight according to the Round Robin Sortation scheme.
        // The flight historical records will be stored in this hash table for 3 hours. 
        // It will be auto purged after 3 hours.
        // Hashtable Key: FlightIdentifier 
        // combining of "Airline & FlightNo & MasterAirline & MasterFlightNo & SDO" to 
        // identify a unique flight, Data Type: String.
        // Hashtable value: LastSortation Structure Object 
        // The last sorted destination for this flight and time, Data Type: LastSortation.
        //private Hashtable _roundRobinHashTable;

        ///// <summary>
        ///// Property, object of RoundRobinSyncdHash class.
        ///// </summary>
        //public Hashtable RoundRobinSyncdHash { get; set; }

        // Used to store the rounting table. These routing table will be used to 
        // calculate the shortest path.
        // In order to maintain the high application performance, these routing table
        // will be pre-loaded into memory from database table [ROUTING_TABLE] at
        // the application starting time. So there is no database access requirement 
        // for calculating shortest path at later stage.
        // Hashtable Key: Location (Data Type: String).
        // Hashtable value: RoutingItem Object Array (Data Type: RoutingItem()).
        // Once location may have more than one cost settings, because it could belongs
        // to different SubSystem. E.g. Location "CA1" can belongs to SubSystem "CT1" 
        // and "CT2".
        //private Hashtable _routingTableHashTable;

        private const string PUBLIC_PARAM_SCHEME_FUNC_ALLOC = "SCHEME_FUNC_ALLOC";
        private const string PUBLIC_PARAM_DEFAULT_HBS_LEVEL = "DEFAULT_HBS_LEVEL";
        private const string PUBLIC_PARAM_SCHEME_TTS1_ALLOC = "SCHEME_TTS1_ALLOC";
        private const string PUBLIC_PARAM_SCHEME_TTS2_ALLOC = "SCHEME_TTS2_ALLOC";
        private const string PUBLIC_PARAM_EBS_BAG_TO_HBS_ENABLED = "EBS_BAG_TO_HBS_ENABLED";
        private const string PUBLIC_PARAM_AIRPORT_LOCATION_CODE = "AIRPORT_LOCATION_CODE";
        private const string PUBLIC_PARAM_FOUR_DIGITS_SECURITY_SORT_ENABLED = "FOUR_DIGIT_SPECIAL_TAG_ENABLED";
        private const string PUBLIC_PARAM_FOUR_DIGITS_FALLBACK_SORT_ENABLED = "FOUR_DIGIT_FALLBACK_TAG_ENABLED";
        private const string PUBLIC_PARAM_FALLBACK_SORT_ENABLED = "FALLBACK_SORT_ENABLED";
        private const string PUBLIC_PARAM_IN_HOUSE_SORT_ENABLED = "IN_HOUSE_TAG_ENABLED";
        private const string PUBLIC_PARAM_AIRLINE_SORT_ENABLED = "AIRLINE_SORT_ENABLED";
        private const string PUBLIC_PARAM_AIRLINE_RUSH_ALLOC_ENABLED = "AIRLINE_RUSH_ALLOC_ENABLED";
        private const string PUBLIC_PARAM_ERLY_ENABLED = "ERLY_ENABLED";
        private const string PUBLIC_PARAM_GLOBAL_RUSH_ALLOC_ENABLED = "GLOBAL_RUSH_ALLOC_ENABLED";
        private const string PUBLIC_PARAM_ERLY_OPEN_ENABLED = "ERLY_OPEN_ENABLED";
        private const string PUBLIC_PARAM_LATE_ENABLED = "LATE_ENABLED";
        private const string PUBLIC_PARAM_SCHEME_FLIGHT_ALLOC = "SCHEME_FLIGHT_ALLOC";
        private const string PUBLIC_PARAM_SCHEME_AIRLINE_ALLOC = "SCHEME_AIRLINE_ALLOC";
        public string TTS01_SUBSYSTEM = "TTS01";
        private const string ROUNDROBIN_BUFFER_LIFETIME = "lifeTime_RoundRobinBuffer";
        private const string PUBLIC_PARAM_BCAS_ENABLED = "BCAS_ENABLED";

        private Hashtable _routingTableHashTable;
        /// <summary>
        /// Property, object of RoutingTableSyncdHash class.
        /// </summary>
        private Hashtable routingTableSyncdHash { get; set; }

        #region Sortation Control
        /// <summary>
        ///  Property, object of DefaultHBSLevel.
        /// </summary>
        public string DefaultHBSLevel
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_DEFAULT_HBS_LEVEL);
                string setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.DefaultHBSLevel;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_DEFAULT_HBS_LEVEL +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.DefaultHBSLevel +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = temp;
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of SortSchemeTTS1Alloc.
        /// </summary>
        public string SortSchemeTTS1Alloc
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_SCHEME_TTS1_ALLOC);
                string setting = string.Empty;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.SchemeTTS1Alloc;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_SCHEME_TTS1_ALLOC +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.SchemeTTS1Alloc +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = temp;
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of SortSchemeTTS2Alloc.
        /// </summary>
        public string SortSchemeTTS2Alloc
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_SCHEME_TTS2_ALLOC);
                string setting = string.Empty;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.SchemeTTS2Alloc;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_SCHEME_TTS2_ALLOC +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.SchemeTTS2Alloc +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = temp;
                }

                return setting;
            }
        }

        /// <summary>
        /// Property, object of SortSchemeFuncAlloc.
        /// </summary>
        public string SortSchemeFuncAlloc
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_SCHEME_FUNC_ALLOC);
                string setting = string.Empty;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.SchemaFunctionAllocation;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_SCHEME_FUNC_ALLOC +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.SchemaFunctionAllocation +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = temp;
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of EBSBagToHBSEnabled.
        /// </summary>
        public bool EBSBagToHBSEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_EBS_BAG_TO_HBS_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.EBSBagToHBSEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_EBS_BAG_TO_HBS_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.EBSBagToHBSEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        /// BCASEnabled
        /// </summary>
        public bool BCASEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_BCAS_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.BCASEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_BCAS_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.BCASEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }


        /// <summary>
        ///  Property, object of AirportLocationCode.
        /// </summary>
        public string AirportLocationCode
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_AIRPORT_LOCATION_CODE);
                string setting = string.Empty;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.AirportLocationCode;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_AIRPORT_LOCATION_CODE +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.AirportLocationCode +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = temp;
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of FourDigitsSecuritySortEnabled.
        /// </summary>
        public bool FourDigitsSecuritySortEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_FOUR_DIGITS_SECURITY_SORT_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.FourDigitsSecuritySortEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_FOUR_DIGITS_SECURITY_SORT_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.FourDigitsSecuritySortEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of FourDigitsFallbackSortEnabled.
        /// </summary>
        public bool FourDigitsFallbackSortEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_FOUR_DIGITS_FALLBACK_SORT_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.FourDigitsFallbackSortEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_FOUR_DIGITS_FALLBACK_SORT_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.FourDigitsFallbackSortEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of FallbackSortEnabled.
        /// </summary>
        public bool FallbackSortEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_FALLBACK_SORT_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.FallbackSortEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_FALLBACK_SORT_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.FallbackSortEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of InHouseSortEnabled.
        /// </summary>
        public bool InHouseSortEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_IN_HOUSE_SORT_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.InHouseSortEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_IN_HOUSE_SORT_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.InHouseSortEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of AirlineSortEnabled.
        /// </summary>
        public bool AirlineSortEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_AIRLINE_SORT_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.AirlineSortEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_AIRLINE_SORT_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.AirlineSortEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of AirlineRushAllocEnabled.
        /// </summary>
        public bool AirlineRushAllocEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_AIRLINE_RUSH_ALLOC_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.AirlineRushAllocEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_AIRLINE_RUSH_ALLOC_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.AirlineRushAllocEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of EarlyEnabled.
        /// </summary>
        public bool EarlyEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_ERLY_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.EarlyEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_ERLY_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.EarlyEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of GlobalRushAllocEnabled.
        /// </summary>
        public bool GlobalRushAllocEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_GLOBAL_RUSH_ALLOC_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.GlobalRushAllocEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_GLOBAL_RUSH_ALLOC_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.GlobalRushAllocEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of EarlyOpenEnabled.
        /// </summary>
        public bool EarlyOpenEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_ERLY_OPEN_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.EarlyOpenEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_ERLY_OPEN_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.EarlyOpenEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of LateEnabled.
        /// </summary>
        public bool LateEnabled
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_LATE_ENABLED);
                bool setting;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.LateEnabled;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_LATE_ENABLED +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.LateEnabled +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = Convert.ToBoolean(temp);
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of SortSchemeFlightAlloc.
        /// </summary>
        public string SortSchemeFlightAlloc
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_SCHEME_FLIGHT_ALLOC);
                string setting = string.Empty;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.SchemaFlightAllocation;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_SCHEME_FLIGHT_ALLOC +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.SchemaFlightAllocation +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = temp;
                }

                return setting;
            }
        }

        /// <summary>
        ///  Property, object of SortSchemeAirlineAlloc.
        /// </summary>
        public string SortSchemeAirlineAlloc
        {
            get
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                string temp = ClassParameters.GetPublicParameter(PUBLIC_PARAM_SCHEME_AIRLINE_ALLOC);
                string setting = string.Empty;

                // If the parameter value that is retrieved from database is empty, then the value in the 
                // XML configuration file will be used as the default value.
                if (temp.Trim() == string.Empty)
                {
                    setting = ClassParameters.SchemaAirlineAllocation;

                    if (_logger.IsErrorEnabled)
                        _logger.Error("No value was assigned to public parameter (" + PUBLIC_PARAM_SCHEME_AIRLINE_ALLOC +
                                        ") in DB table [SYSCONFIG], The default value (" + ClassParameters.SchemaAirlineAllocation +
                                        ") in the XML configuration file is used. <" + thisMethod + ">");
                }
                else
                {
                    setting = temp;
                }

                return setting;
            }
        }
        #endregion
        #endregion

        #region Class Constructor, Dispose, & Destructor
        /// <summary>
        /// Class constructer.
        /// </summary>
        public Persistor(PALS.Common.IParameters param)
        {
            if (param == null)
                throw new Exception("Constractor parameter can not be null! Creating class object failed! " +
                    "<BHS.MES.DataPersistor.Database.PersistorParameters.Constructor()>");

            ClassParameters = (MES.TCPClientChains.DataPersistor.Database.PersistorParameters)param;

            // Call Init() method to perform class initialization tasks.
            if (!Init())
                throw new Exception("Instantiate class object failure! " +
                    "<BHS.MES.DataPersistor.Database.PersistorParameters.Constructor()>");
        }

        /// <summary>
        /// Class destructer.
        /// </summary>
        ~Persistor()
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
            if (ClassParameters != null)
            {
                ClassParameters.Dispose();
                ClassParameters = null;
            }

            if (routingTableSyncdHash != null)
            {
                routingTableSyncdHash.Clear();
                routingTableSyncdHash = null;
            }

            if (disposing)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object has been destroyed. <" + _className + ".Dispose()>");
            }
        }
        #endregion

        #region Class Method Declaration.

        public bool Init()
        {
            return true;
        }

        /// <summary>
        /// Insert item ready information into database.
        /// </summary>
        /// <param name="TimeStamp">Time stamp which insert data as type of System.DateTime</param>
        /// <param name="GID">Bag global ID as type of System.string.</param>
        /// <param name="Location">Location as type of System.string</param>
        /// <param name="PLCIndex">PLC Index No. as  type of System.string</param>
        public void InsertItemReady(string GID,  string Location, string PLCIndex)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive==true)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_ITEM_READY, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                sqlPara2.Value = GID;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@LOCATION", SqlDbType.VarChar, 10);
                sqlPara3.Value = Location;

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@PLC_INDEX", SqlDbType.VarChar, 10);
                sqlPara4.Value = PLCIndex;

                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
                sqlTrans.Commit();
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting Item Ready information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting Item Ready information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

        /// <summary>
        /// Insert encoded item information into the database.
        /// </summary>
        /// <param name="TimeStamp">Time stamp which insert data as type of System.DateTime</param>
        /// <param name="GIDMSB">Bag global ID MSB as type of System.string.</param>
        /// <param name="GIDLSB">Bag global ID LSB as type of System.string.</param>
        /// <param name="Location">Location as type of System.string</param>
        /// <param name="PLCIndex">PLC index no. as Type of System.String</param>
        /// <param name="DEST">DEST as Type of System.String</param>
        public void InsertItemEncoded(int GIDMSB, int GIDLSB, string Location, string PLCIndex, string Dest, string LicensePlate, string Airline, string FlightNo, string EncodeType)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive==true)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_ITEM_ENCODED, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                sqlPara1.Value = GIDMSB.ToString().Trim() + GIDLSB.ToString().Trim();

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@LOCATION", SqlDbType.VarChar, 10);
                sqlPara2.Value = Location;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@PLC_INDEX", SqlDbType.VarChar, 10);
                sqlPara3.Value = PLCIndex;

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@DEST", SqlDbType.VarChar, 10);
                sqlPara4.Value = Dest;

                SqlParameter sqlPara5 = sqlCmd.Parameters.Add("@LICENSE_PLATE", SqlDbType.VarChar, 10);
                sqlPara5.Value = LicensePlate;

                SqlParameter sqlPara6 = sqlCmd.Parameters.Add("@AIRLINE", SqlDbType.VarChar, 3);
                sqlPara6.Value = Airline;

                SqlParameter sqlPara7 = sqlCmd.Parameters.Add("@FLIGHT_NUMBER", SqlDbType.VarChar, 5);
                sqlPara7.Value = FlightNo;

                SqlParameter sqlPara8 = sqlCmd.Parameters.Add("@ENCODING_TYPE", SqlDbType.VarChar, 2);
                sqlPara8.Value = EncodeType;
                
                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
                sqlTrans.Commit();
            }
            catch (SqlException ex)
            {
                if(sqlTrans!=null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting Item Encode information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting Item Encode information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

        /// <summary>
        /// Insert item remove information into database.
        /// </summary>
        /// <param name="TimeStamp">Time stamp which insert data as type of System.DateTime</param>
        /// <param name="GID">Bag global ID as type of System.string.</param>
        /// <param name="Location">Location as type of System.string</param>
        /// <param name="PLCIndex">PLC Index as  type of System.string</param>
        public void InsertItemRemove(DateTime TimeStamp, string GID, string Location, string PLCIndex)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive==true)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_ITEM_REMOVED, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                sqlPara2.Value = GID;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@LOCATION", SqlDbType.VarChar, 10);
                sqlPara3.Value = Location;

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@PLC_INDEX", SqlDbType.VarChar, 10);
                sqlPara4.Value = PLCIndex;

                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
                sqlTrans.Commit();
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting Item Remove information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting Item Remove information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

        /// <summary>
        /// Insert MES Event information into database.
        /// </summary>
        /// <param name="TimeStamp">Time stamp which insert data as type of System.DateTime</param>
        /// <param name="GID">Bag global ID as type of System.string.</param>
        /// <param name="LicensePlate">IATA Tag no. as type of System.string</param>
        /// <param name="SubSystem">Sub system information as type of System.string</param>
        /// <param name="Location">Location as type of System.string</param>
        /// <param name="MESStation">MES station name as  type of System.string</param>
        /// <param name="Action">Action to log into MES Event log as type of System.string</param>
        /// <param name="ActionDesc">Action decription as type of System.string</param>
        public void InsertMESEvent(DateTime TimeStamp, string GID, string LicensePlate,
            string SubSystem, string Location,
            string MESStation, string Action, string ActionDesc)
        {

            string description = string.Empty;
            description += ActionDesc;
            if (GID != string.Empty)
                description = description + " GID:" + GID;
            if (LicensePlate != string.Empty)
                description = description + " IATA:" + LicensePlate;
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans=null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive==true)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_MES_EVENT, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;
                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SUB_SYSTEM", SqlDbType.NVarChar, 50);
                sqlPara1.Value = "MES";

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@APP_CODE", SqlDbType.VarChar, 30);
                sqlPara2.Value = "";

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@METHOD_NAME", SqlDbType.VarChar);
                sqlPara3.Value = Action;

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@WORKSTATION", SqlDbType.VarChar, 50);
                sqlPara4.Value = MESStation;

                SqlParameter sqlPara5 = sqlCmd.Parameters.Add("@USER_NAME", SqlDbType.VarChar, 50);
                sqlPara5.Value = System.Security.Principal.WindowsIdentity.GetCurrent().Name.Split('\\')[1];

                SqlParameter sqlPara6 = sqlCmd.Parameters.Add("@DESCRIPTION", SqlDbType.VarChar);
                sqlPara6.Value = description;

                SqlParameter sqlPara7 = sqlCmd.Parameters.Add("@TIME_STAMP", SqlDbType.DateTime);
                sqlPara7.Value = TimeStamp;


                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
                sqlTrans.Commit();
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting MES Event information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting MES Event information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

        /// <summary>
        /// Update mds alarms to true when user logs in and update mds alarms to false when user logs out.
        /// </summary>
        /// <param name=""></param>
        public void UpdateMdsAlarmsForLoginLogout(string stationName, string loggingStatus)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;

                    sqlCmd = new SqlCommand(ClassParameters.stp_MES_UPDATE_MDS_ALARMS_FOR_USER_LOGIN_LOGOUT, sqlConn);
                    sqlCmd.CommandType = CommandType.StoredProcedure;

                    SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@MES_STATION", SqlDbType.VarChar, 10);
                    sqlPara1.Value = stationName;

                    SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@LOGGING_STATUS", SqlDbType.VarChar, 10);
                    sqlPara2.Value = loggingStatus;

                    sqlConn.Open();
                    sqlTrans = sqlConn.BeginTransaction();
                    sqlCmd.Transaction = sqlTrans;
                    sqlCmd.ExecuteNonQuery();
                    sqlTrans.Commit();

                    _logger.Info("Updating mds alarms for user login logout success. <" + loggingStatus + "  " + thisMethod + ">");
                }
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating mds alarms for user login logout fail! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating mds alarms for user login logout fail! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

        /// <summary>
        /// Get flight allocation information for GUI display.
        /// </summary>
        /// <param name="Filter">Time interval of filter to flight list.</param>
        /// <returns>
        /// Flight allocation list as type of System.Data.Table. 
        /// Return DataTable to ease of binding into datagridview on GUI side.
        /// </returns>
        public DataTable GetFlightList(int Filter)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsFlightAllocation = new DataSet();
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_FLIGHT_ALLOC, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@Filter", SqlDbType.Int);
                sqlPara1.Value = Filter;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlConn.Open();
                sqlAdapter.Fill(dsFlightAllocation);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Getting flight allocation information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Getting flight allocation information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
            return dsFlightAllocation.Tables[0];
        }

        public DataTable GetMESEvent(string MES_STATION)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsMESEvent = new DataSet();
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_MES_EVENT, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@MES_STATION", SqlDbType.VarChar);
                sqlPara1.Value = MES_STATION;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlConn.Open();
                sqlAdapter.Fill(dsMESEvent);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Getting MES event log failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Getting MES event log failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
            return dsMESEvent.Tables[0];
        }

        /// <summary>
        /// Get the last encoding information from database when application start.
        /// </summary>
        /// <param name="MESStation">MES Station to get last encoded information</param>
        /// <param name="IATATag">IATA Tag ID information as type of System.string</param>
        /// <param name="Reason">Reason information as type of System.string</param>
        public void GetLastEncoding(string MESStation, out string IATATag, out string Reason)
        {
            IATATag = string.Empty;
            Reason = string.Empty;
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive==true)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_LAST_ENCODING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@MESSTATION", SqlDbType.VarChar,16);
                sqlPara1.Value = MESStation;

                sqlConn.Open();
                SqlDataReader sqlReader = sqlCmd.ExecuteReader();
                while (sqlReader.Read())
                {
                    if (!sqlReader.IsDBNull(0)) IATATag = sqlReader.GetString(0);
                    if (!sqlReader.IsDBNull(1)) Reason = sqlReader.GetString(1);
                }

                sqlReader.Close();
                sqlReader.Dispose();
                sqlReader = null;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get last encoding information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get last encoding information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }


        /// <summary>
        /// Get the pessenger information including 
        /// License Plate, Pessenger Name, Travel Class, Air Line, Flight No. and SDO.
        /// </summary>
        /// <param name="LicensePlate">License Plate to search for pessenger information as type of System.string</param>
        /// <returns>Return the list of pessenger info as type of System.Data.DataTable</returns>
        public DataTable GetPassengerInfo(string LicensePlate)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsPessengerInfo = new DataSet();
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive==true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_PESSENGER_INFO, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@LICENSE_PLATE", SqlDbType.VarChar, 10);
                sqlPara1.Value = LicensePlate;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlConn.Open();
                sqlAdapter.Fill(dsPessengerInfo);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get passenger information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get passenger information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }

            if (dsPessengerInfo.Tables.Count == 0)
            {
                return null;
            }
            else
            {
                return dsPessengerInfo.Tables[0];
            }
        }

        /// <summary>
        /// Get the pessenger information including 
        /// License Plate, Pessenger Name, Travel Class, Air Line, Flight No. and SDO.
        /// </summary>
        /// <param name="LicensePlate">License Plate to search for pessenger information as type of System.string</param>
        /// <returns>Return the list of pessenger info as type of System.Data.DataTable</returns>
        public DataTable GetFlightInfo(string strCarrier, string strFlightNo, string strSDO)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsFlightInfo = new DataSet();
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_FLIGHT_INFO, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@CARRIER", SqlDbType.VarChar, 3);
                sqlPara1.Value = strCarrier;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@FLIGHT_NO", SqlDbType.VarChar, 4);
                sqlPara2.Value = strFlightNo;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@SDO", SqlDbType.VarChar, 10);
                sqlPara3.Value = strSDO;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlConn.Open();
                sqlAdapter.Fill(dsFlightInfo);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get flight information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get flight information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }

            if (dsFlightInfo.Tables.Count == 0)
            {
                return null;
            }
            else
            {
                return dsFlightInfo.Tables[0];
            }

        }

        /// <summary>
        /// Get the Airline info from database
        /// </summary>
        /// <param name="strCarrier">The Airline to search</param>
        /// <returns>If the Airline is not exists, it will return error message. Otherwise, the error message is empty</returns>
        public DataTable GetAirlineInfo(string strCarrier, string ticketingcode)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsAirlineInfo = new DataSet();
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_AIRLINE_INFO, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@CARRIER", SqlDbType.VarChar, 3);
                sqlPara1.Value = strCarrier;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@TICKETING_CODE", SqlDbType.VarChar, 4);
                sqlPara2.Value = ticketingcode;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlConn.Open();
                sqlAdapter.Fill(dsAirlineInfo);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get flight information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get flight information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }

            if (dsAirlineInfo.Tables.Count == 0)
            {
                return null;
            }
            else
            {
                return dsAirlineInfo.Tables[0];
            }

        }

        /// <summary>
        /// Get the flight type information.
        /// </summary>
        /// <param name="airline">airline as type of System.string</param>
        /// <param name="flightNumber">flightNumber as type of System.string</param>
        /// <returns>Return the list of flight type as type of System.Data.DataTable</returns>
        public DataTable GetFlightType(string airline, string flightNumber, DateTime sdo)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsFlightType = new DataSet();
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_FLIGHT_TYPE, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@Airline", SqlDbType.VarChar, 4);
                sqlPara1.Value = airline;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@FlightNumber", SqlDbType.VarChar, 4);
                sqlPara2.Value = flightNumber;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@Sdo", SqlDbType.DateTime);
                sqlPara2.Value = sdo;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlConn.Open();
                sqlAdapter.Fill(dsFlightType);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get flight type information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get flight type information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }

            if (dsFlightType.Tables.Count == 0)
            {

                return null;
            }
            else
            {
                return dsFlightType.Tables[0];
            }
        }

        /// <summary>
        /// Get the sort reason from bag info table
        /// </summary>
        /// <param name="sGUID">GID of bag info table.</param>
        /// <param name="sLicensePlate">GID of bag info table.</param>
        /// <returns>Return the list of pessenger info as type of System.Data.DataTable</returns>
        public string GetInfoReason(string sGUID, string sLicensePlate)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsPessengerInfo = new DataSet();
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_BAG_INFO_REASON, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@Bag_GID", SqlDbType.VarChar, 10);
                sqlPara1.Value = sGUID;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@LicensePlate", SqlDbType.VarChar, 10);
                sqlPara2.Value = sLicensePlate;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlConn.Open();
                sqlAdapter.Fill(dsPessengerInfo);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get passenger information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get passenger information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }

            
            if (dsPessengerInfo != null && dsPessengerInfo.Tables.Count > 0 && dsPessengerInfo.Tables[0].Rows.Count > 0)
            return dsPessengerInfo.Tables[0].Rows[0][0].ToString();
            else
            return string.Empty;
            
        }

        /// <summary>
        /// Get all the data inserted locally when MES station disconnected from main database. The 
        /// dataset will include all tables as ITEM_READY, ITEM_REMOVED, ITEM_ENCODED and MES_EVENT.
        /// </summary>
        /// <param name="sqlConn">The opened sql connection to reuse in the function.</param>
        /// <returns>Return tables list as type of System.Data.DataSet</returns>
        private DataSet GetLocalInsertedData(SqlConnection sqlConn)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            DataSet dsLocalInsertedData = new DataSet();
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_LOCAL_INSERTED_DATA, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlAdapter.Fill(dsLocalInsertedData);
                dsLocalInsertedData.Tables[0].TableName = "ItemReady";
                dsLocalInsertedData.Tables[1].TableName = "ItemRemoved";
                dsLocalInsertedData.Tables[2].TableName = "ItemEncoded";
                dsLocalInsertedData.Tables[3].TableName = "MESEvents";
                dsLocalInsertedData.Tables[4].TableName = "InhouseBSM";
                //dsLocalInsertedData.Tables[5].TableName = "ItemInsert";
                //dsLocalInsertedData.Tables[6].TableName = "ItemInsertAck";
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get local inserted information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get local inserted information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return dsLocalInsertedData;
        }

        /// <summary>
        /// Remove all locally inserted data after transferring into main database when main database
        /// is re-connected.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse in the function</param>
        /// <param name="sqlTrans">Opened transaction to reuse in the function</param>
        /// <returns>Return success or fail satatus.</returns>
        private bool RemoveAllLocallyInsertedData(SqlConnection sqlConn, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_REMOVE_LOCAL_INSERTED_DATA, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Removing locally inserted information failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Removing locally inserted information failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert item encoded data from local database to server database when server database is connected and
        /// available.
        /// </summary>
        /// <param name="dtLocalItemEncoded">Local item encoded data to insert into server</param>
        /// <param name="sqlConn">Opened sql connection to reuse</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return success or fail satatus.</returns>
        private bool InsertItemEncodedFromLocal(DataTable dtLocalItemEncoded, SqlConnection sqlConn, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_ITEM_ENCODED_FROM_LOCAL, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@ITEM_ENCODED", SqlDbType.Structured);
                sqlPara1.Value = dtLocalItemEncoded;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local item encoded data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local item encoded data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert item ready data from local database to server database when server database is connected and
        /// available.
        /// </summary>
        /// <param name="dtLocalItemReady">Local item ready data to insert into server</param>
        /// <param name="sqlConn">Opened sql connection to reuse</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return success or fail satatus.</returns>
        private bool InsertItemReadyFromLocal(DataTable dtLocalItemReady, SqlConnection sqlConn, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_ITEM_READY_FROM_LOCAL, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@ITEM_READY", SqlDbType.Structured);
                sqlPara1.Value = dtLocalItemReady;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local item ready data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local item ready data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert item insert data from local database to server database when server database is connected and
        /// available.
        /// </summary>
        /// <param name="dtLocalItemReady">Local item ready data to insert into server</param>
        /// <param name="sqlConn">Opened sql connection to reuse</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return success or fail satatus.</returns>
        private bool InsertItemInsertFromLocal(DataTable dtLocalItemInsert, SqlConnection sqlConn, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_ITEM_INSERT_FROM_LOCAL, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@ITEM_INSERT", SqlDbType.Structured);
                sqlPara1.Value = dtLocalItemInsert;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local item insert data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local item insert data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert item insert data from local database to server database when server database is connected and
        /// available.
        /// </summary>
        /// <param name="dtLocalItemReady">Local item ready data to insert into server</param>
        /// <param name="sqlConn">Opened sql connection to reuse</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return success or fail satatus.</returns>
        private bool InsertItemInsertAckFromLocal(DataTable dtLocalItemInsert, SqlConnection sqlConn, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_ITEM_INSERTACK_FROM_LOCAL, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@ITEM_INSERT_ACK", SqlDbType.Structured);
                sqlPara1.Value = dtLocalItemInsert;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local item insert ack data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local item insert ack data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert item removed data from local database to server database when server database is connected and
        /// available.
        /// </summary>
        /// <param name="dtLocalItemRemoved">Local item removed data to insert into server</param>
        /// <param name="sqlConn">Opened sql connection to reuse</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return success or fail satatus.</returns>
        private bool InsertItemRemovedFromLocal(DataTable dtLocalItemRemoved, SqlConnection sqlConn, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_ITEM_REMOVED_FROM_LOCAL, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@ITEM_REMOVE", SqlDbType.Structured);
                sqlPara1.Value = dtLocalItemRemoved;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local item removed data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local item removed data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert mes event data from local database to server database when server database is connected and
        /// available. Once one process has an error, the function will roll back all and exit for next trip.
        /// </summary>
        /// <param name="dtLocalMESEvent">Local item removed data to insert into server</param>
        /// <param name="sqlConn">Opened sql connection to reuse</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return success or fail satatus.</returns>
        private bool InsertMESEventFromLocal(DataTable dtLocalMESEvent, SqlConnection sqlConn, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_MES_EVENT_FROM_LOCAL, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@MES_EVENT", SqlDbType.Structured);
                sqlPara1.Value = dtLocalMESEvent;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local mes event data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local mes event data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        private bool InsertInhouseBSMFromLocal(DataTable dtLocalInhouseBSM, SqlConnection sqlConn, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_INHOUSE_BSM_FROM_LOCAL, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@ITEM_INHOUSE_BSM", SqlDbType.Structured);
                sqlPara1.Value = dtLocalInhouseBSM;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local mes event data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting local mes event data to server failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Upload local stored MES events data to server when server connection is restored.
        /// This will include, 
        /// 1 - Retrieve all locally inserted data from ITEM_ENCODED, ITEM_READY,
        ///     ITEM_REMOVED AND MES_EVENTS tables
        /// 2 - Insert retrieved data to server database
        /// 3 - Clear local tables after successfully inserted into server
        /// 4 - Data in local tables will clear when all data successfully inserted into server. If not,
        ///     local tables will still remain those data until successfully inserted into server.
        /// </summary>
        public void UploadLocalToServer()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConnLocal = null;
            SqlConnection sqlConnServer = null;
            SqlConnection sqlConn2ndServer = null;
            try
            {
                sqlConnLocal = new SqlConnection();
                sqlConnLocal.ConnectionString = ClassParameters.LocalDBConnectionString;

                sqlConnServer = new SqlConnection();
                sqlConnServer.ConnectionString = ClassParameters.DBConnectionString;

                sqlConn2ndServer = new SqlConnection();
                sqlConn2ndServer.ConnectionString = ClassParameters.SecondaryDBConnectionString;

                SqlTransaction sqlTransLocal = null;
                SqlTransaction sqlTransServer = null;
                SqlTransaction sql2ndaryTransServer = null;

                sqlConnLocal.Open();
                sqlConnServer.Open();
                sqlConn2ndServer.Open();
                DataSet localData = GetLocalInsertedData(sqlConnLocal);

                sql2ndaryTransServer = sqlConn2ndServer.BeginTransaction();
                if (localData.Tables["ItemEncoded"].Rows.Count > 0)
                {
                    if (InsertItemEncodedFromLocal(localData.Tables["ItemEncoded"], sqlConn2ndServer, sql2ndaryTransServer) == false)
                    {
                        sql2ndaryTransServer.Rollback();
                        return;
                    }
                }

                if (localData.Tables["ItemReady"].Rows.Count > 0)
                {
                    if (InsertItemReadyFromLocal(localData.Tables["ItemReady"], sqlConn2ndServer, sql2ndaryTransServer) == false)
                    {
                        sql2ndaryTransServer.Rollback();
                        return;
                    }
                }

                if (localData.Tables["ItemRemoved"].Rows.Count > 0)
                {
                    if (InsertItemRemovedFromLocal(localData.Tables["ItemRemoved"], sqlConn2ndServer, sql2ndaryTransServer) == false)
                    {
                        sql2ndaryTransServer.Rollback();
                        return;
                    }
                }

                if (localData.Tables["MESEvents"].Rows.Count > 0)
                {
                    if (InsertMESEventFromLocal(localData.Tables["MESEvents"], sqlConn2ndServer, sql2ndaryTransServer) == false)
                    {
                        sql2ndaryTransServer.Rollback();
                        return;
                    }
                }

                sqlTransServer = sqlConnServer.BeginTransaction();
                if (localData.Tables["InhouseBSM"].Rows.Count > 0)
                {
                    if (InsertInhouseBSMFromLocal(localData.Tables["InhouseBSM"], sqlConnServer, sqlTransServer) == false)
                    {
                        sql2ndaryTransServer.Rollback();
                        sqlTransServer.Rollback();
                        return;
                    }
                }

                //if (localData.Tables["ItemInsert"].Rows.Count > 0)
                //{
                //    if (InsertItemInsertFromLocal(localData.Tables["ItemInsert"], sqlConn2ndServer, sql2ndaryTransServer) == false)
                //    {
                //        sql2ndaryTransServer.Rollback();
                //        return;
                //    }
                //}

                //if (localData.Tables["ItemInsertAck"].Rows.Count > 0)
                //{
                //    if (InsertItemInsertAckFromLocal(localData.Tables["ItemInsertAck"], sqlConn2ndServer, sql2ndaryTransServer) == false)
                //    {
                //        sql2ndaryTransServer.Rollback();
                //        return;
                //    }
                //}

                sqlTransLocal = sqlConnLocal.BeginTransaction();
                if (RemoveAllLocallyInsertedData(sqlConnLocal, sqlTransLocal) == false)
                {
                    sql2ndaryTransServer.Rollback();
                    sqlTransServer.Rollback();
                    sqlTransLocal.Rollback();
                    return;
                }
                sql2ndaryTransServer.Commit();
                sqlTransServer.Commit();
                sqlTransLocal.Commit();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Uploading local data to server failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Uploading local data to server failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConnLocal != null)
                {
                    sqlConnLocal.Close();
                    sqlConnLocal.Dispose();
                    sqlConnLocal = null;
                }

                if (sqlConnServer != null)
                {
                    sqlConnServer.Close();
                    sqlConnServer.Dispose();
                    sqlConnServer = null;
                }
                if (sqlConn2ndServer != null)
                {
                    sqlConn2ndServer.Close();
                    sqlConn2ndServer.Dispose();
                    sqlConn2ndServer = null;
                }
            }
        }

        /// <summary>
        /// Get required information from server for local temporary store. 
        /// This data will use when MES station was disconnected from database.
        /// </summary>
        /// <param name="sqlConn">SQL connection to server</param>
        /// <param name="status">Status which is 0 - initialization or 1 - get only changes</param>
        /// <param name="stationName">MES Station name as type of System.string</param>
        /// <param name="lastDownloadTime"></param>
        /// <returns>Return all required tables as type of System.Data.DataSet</returns>
        private DataSet GetRequiredInfoFromServer(SqlConnection sqlConn, int status, string stationName, DateTime lastDownloadTime)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            DataSet dsServerData = new DataSet();
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_REQUIRED_INFO_FROM_SERVER, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;
                    
                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@STATION_NAME", SqlDbType.VarChar, 20);
                sqlPara1.Value = stationName;
                ClassParameters.MES_Station_Name = stationName;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@STATUS", SqlDbType.Int);
                sqlPara2.Value = status;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@LAST_DOWNLOAD_TIME", SqlDbType.DateTime);
                sqlPara3.Value = lastDownloadTime;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlAdapter.Fill(dsServerData);
                dsServerData.Tables[0].TableName = "SysConfig";
                dsServerData.Tables[1].TableName = "FunctionAllocGantt";
                dsServerData.Tables[2].TableName = "FunctionAllocList";
                dsServerData.Tables[3].TableName = "FunctionTypes";
                dsServerData.Tables[4].TableName = "SortationReason";
                dsServerData.Tables[5].TableName = "Airlines";
                dsServerData.Tables[6].TableName = "Destinations";
                dsServerData.Tables[7].TableName = "BagInfo";
                dsServerData.Tables[8].TableName = "BagSorting";
                dsServerData.Tables[9].TableName = "ChuteMapping";
                dsServerData.Tables[10].TableName = "FallbackMapping";
                dsServerData.Tables[11].TableName = "FourDigitFallbackMapping";
                dsServerData.Tables[12].TableName = "RoutingTable";
                dsServerData.Tables[13].TableName = "SpecialSecurityTagDestinationMapping";
                dsServerData.Tables[14].TableName = "TTSMESPriority";
                dsServerData.Tables[15].TableName = "FallbackTagInfo";
                dsServerData.Tables[16].TableName = "FlightPlanAlloc";
                dsServerData.Tables[17].TableName = "FlightPlanSorting";
                dsServerData.Tables[18].TableName = "PseudoBSM";
                dsServerData.Tables[19].TableName = "AirlineShortcuts";
                dsServerData.Tables[20].TableName = "HBSPassenger";
                dsServerData.Tables[21].TableName = "HBSFlight";
                dsServerData.Tables[22].TableName = "HBSAirline";
                dsServerData.Tables[23].TableName = "HBSCountry";
                dsServerData.Tables[24].TableName = "HBSPolicy";
                dsServerData.Tables[25].TableName = "HBSSchedule";
                dsServerData.Tables[26].TableName = "HBSTagType";
                dsServerData.Tables[27].TableName = "Airports";
                dsServerData.Tables[28].TableName = "MakeupFlightTypeMap";
                dsServerData.Tables[29].TableName = "SecurityCategories";
                dsServerData.Tables[30].TableName = "SecurityGroupTaskMap";
                dsServerData.Tables[31].TableName = "SecurityGroupTasks";
                dsServerData.Tables[32].TableName = "SecurityGroups";
                dsServerData.Tables[33].TableName = "SecurityTasks";
                dsServerData.Tables[34].TableName = "SecurityUserRights";
                dsServerData.Tables[35].TableName = "SecurityUsers";
                dsServerData.Tables[36].TableName = "HBSLevel";

                if (_logger.IsDebugEnabled)
                    _logger.Debug("[DEBUG] Downloaded tables: SysConfig <" + dsServerData.Tables[0].Rows.Count.ToString() + 
                            ">, FunctionAllocGantt <" + dsServerData.Tables[1].Rows.Count.ToString() +
                            ">, FunctionAllocList <" + dsServerData.Tables[2].Rows.Count.ToString() +
                            ">, FunctionTypes <" + dsServerData.Tables[3].Rows.Count.ToString() +
                            ">, SortationReason <" + dsServerData.Tables[4].Rows.Count.ToString() +
                            ">, Airlines <" + dsServerData.Tables[5].Rows.Count.ToString() +
                            ">, Destinations <" + dsServerData.Tables[6].Rows.Count.ToString() +
                            ">, BagInfo <" + dsServerData.Tables[7].Rows.Count.ToString() +
                            ">, BagSorting <" + dsServerData.Tables[8].Rows.Count.ToString() +
                            ">, ChuteMapping <" + dsServerData.Tables[9].Rows.Count.ToString() +
                            ">, FallbackMapping <" + dsServerData.Tables[10].Rows.Count.ToString() +
                            ">, FourDigitFallbackMapping <" + dsServerData.Tables[11].Rows.Count.ToString() +
                            ">, RoutingTable <" + dsServerData.Tables[12].Rows.Count.ToString() +
                            ">, SpecialSecurityTagDestinationMapping <" + dsServerData.Tables[13].Rows.Count.ToString() +
                            ">, TTSMESPriority <" + dsServerData.Tables[14].Rows.Count.ToString() +
                            ">, FallbackTagInfo <" + dsServerData.Tables[15].Rows.Count.ToString() +
                            ">, FlightPlanAlloc <" + dsServerData.Tables[16].Rows.Count.ToString() +
                            ">, FlightPlanSorting <" + dsServerData.Tables[17].Rows.Count.ToString() +
                            ">, PseudoBSM <" + dsServerData.Tables[18].Rows.Count.ToString() +
                            ">, AirlineShortcuts <" + dsServerData.Tables[19].Rows.Count.ToString() +
                            ">, HBSPassenger <" + dsServerData.Tables[20].Rows.Count.ToString() +
                            ">, HBSFlight <" + dsServerData.Tables[21].Rows.Count.ToString() +
                            ">, HBSAirline <" + dsServerData.Tables[22].Rows.Count.ToString() +
                            ">, HBSCountry <" + dsServerData.Tables[23].Rows.Count.ToString() +
                            ">, HBSPolicy <" + dsServerData.Tables[24].Rows.Count.ToString() +
                            ">, HBSSchedule <" + dsServerData.Tables[25].Rows.Count.ToString() +
                            ">, HBSTagType <" + dsServerData.Tables[26].Rows.Count.ToString() +
                            ">, Airports <" + dsServerData.Tables[27].Rows.Count.ToString() +
                            ">, MakeupFlightTypeMap <" + dsServerData.Tables[28].Rows.Count.ToString() +
                            ">, SecurityCategories <" + dsServerData.Tables[29].Rows.Count.ToString() +
                            ">, SecurityGroupTaskMap <" + dsServerData.Tables[30].Rows.Count.ToString() +
                            ">, SecurityGroupTasks <" + dsServerData.Tables[31].Rows.Count.ToString() +
                            ">, SecurityGroups <" + dsServerData.Tables[32].Rows.Count.ToString() +
                            ">, SecurityTasks <" + dsServerData.Tables[33].Rows.Count.ToString() +
                            ">, SecurityUserRights <" + dsServerData.Tables[34].Rows.Count.ToString() +
                            ">, SecurityUsers <" + dsServerData.Tables[35].Rows.Count.ToString() + ">. <" + thisMethod + ">");

            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get server information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get server information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return dsServerData;
        }

        /// <summary>
        /// Insert air lines data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerAirlines">Air lines information from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalAirlines(SqlConnection sqlConn, DataTable dtServerAirlines, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_AIRLINES, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@AIRLINES", SqlDbType.Structured);
                sqlPara1.Value = dtServerAirlines;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting airlines to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting airlines to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert bag info data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerBagInfo">Bag information from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalBagInfo(SqlConnection sqlConn, DataTable dtServerBagInfo, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_BAG_INFO, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@BAG_INFO", SqlDbType.Structured);
                sqlPara1.Value = dtServerBagInfo;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting bag info to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting bag info to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert bag sorting data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerBagSorting">Bag sorting data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalBagSorting(SqlConnection sqlConn, DataTable dtServerBagSorting, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_BAG_SORTING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@BAG_SORTING", SqlDbType.Structured);
                sqlPara1.Value = dtServerBagSorting;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting bag sorting data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting bag sorting data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert chute mapping data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerChuteMapping">Chute mapping data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalChuteMapping(SqlConnection sqlConn, DataTable dtServerChuteMapping, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_CHUTE_MAPPING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@CHUTE_MAPPING", SqlDbType.Structured);
                sqlPara1.Value = dtServerChuteMapping;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting chute mapping to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting chute mapping to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert fallback mapping data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerFallbackMapping">Fallback mapping data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalFallbackMapping(SqlConnection sqlConn, DataTable dtServerFallbackMapping, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_FALLBACK_MAPPING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@FALLBACK_MAPPING", SqlDbType.Structured);
                sqlPara1.Value = dtServerFallbackMapping;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting fallback mapping data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting fallback mapping data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert fallback tag info data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerFallbackTagInfo">Fallback tag info from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalFallbackTagInfo(SqlConnection sqlConn, DataTable dtServerFallbackTagInfo, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_FALLBACK_TAG_INFO, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@FALLBACK_TAG_INFO", SqlDbType.Structured);
                sqlPara1.Value = dtServerFallbackTagInfo;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting fallback tag info to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting fallback tag info to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert flight plan allocation data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerFlightPlanAlloc">flight plan allocation data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalFlightPlanAlloc(SqlConnection sqlConn, DataTable dtServerFlightPlanAlloc, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_FLIGHT_PLAN_ALLOC, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@FLIGHT_PLAN_ALLOC", SqlDbType.Structured);
                sqlPara1.Value = dtServerFlightPlanAlloc;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting flight plan allocation data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting flight plan allocation data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert flight plan sorting data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerFlightPlanSorting">flight plan sorting data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalFlightPlanSorting(SqlConnection sqlConn, DataTable dtServerFlightPlanSorting, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_FLIGHT_PLAN_SORTING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@FLIGHT_PLAN_SORTING", SqlDbType.Structured);
                sqlPara1.Value = dtServerFlightPlanSorting;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting flight plan sorting data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting flight plan sorting data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert function allocation gantt data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerFunctionAllocGantt">Function allocation gantt data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalFunctionAllocGantt(SqlConnection sqlConn, DataTable dtServerFunctionAllocGantt, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_FUNCTION_ALLOC_GANTT, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@FUNCTION_ALLOC_GANTT", SqlDbType.Structured);
                sqlPara1.Value = dtServerFunctionAllocGantt;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting function allocation gantt data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting function allocation gantt data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert function allocation list data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerFunctionAllocList">Function allocation list data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalFunctionAllocList(SqlConnection sqlConn, DataTable dtServerFunctionAllocList, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_FUNCTION_ALLOC_LIST, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@FUNCTION_ALLOC_LIST", SqlDbType.Structured);
                sqlPara1.Value = dtServerFunctionAllocList;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting function allocation list data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting function allocation list data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert function types into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerFunctionTypes">Function types from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalFunctionTypes(SqlConnection sqlConn, DataTable dtServerFunctionTypes, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_FUNCTION_TYPES, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@FUNCTION_TYPES", SqlDbType.Structured);
                sqlPara1.Value = dtServerFunctionTypes;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting function types to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting function types to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert system configs into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerSysConfig">System configs from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalSysConfig(SqlConnection sqlConn, DataTable dtServerSysConfig, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_SYS_CONFIG, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SYS_CONFIG", SqlDbType.Structured);
                sqlPara1.Value = dtServerSysConfig;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting system config data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting system config data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Download data from server into local database.
        /// </summary>
        /// <param name="status">Status to indicate initialization, 0, or get only changes, 1.</param>
        /// <param name="stationName">MES station name as type of System.string</param>
        /// <param name="lastDownloadTime">Last download time</param>
        public void DownloadDataFromServer(int status, string stationName, DateTime lastDownloadTime)
        {
            if (ClassParameters.MainDBAlive == true)
            {
                string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
                SqlConnection sqlConnLocal = null;
                SqlConnection sqlConnServer = null;

                DateTime dt = DateTime.Now;

                try
                {
                    if (_isRunning == false)
                    {
                        _isRunning = true;
                        sqlConnLocal = new SqlConnection();
                        sqlConnLocal.ConnectionString = ClassParameters.LocalDBConnectionString;

                        sqlConnServer = new SqlConnection();
                        sqlConnServer.ConnectionString = ClassParameters.DBConnectionString;

                        SqlTransaction sqlTransLocal = null;

                        sqlConnLocal.Open();
                        sqlConnServer.Open();
                        DataSet serverData = GetRequiredInfoFromServer(sqlConnServer, status, stationName, lastDownloadTime);

                        sqlTransLocal = sqlConnLocal.BeginTransaction();

                        if (status == 0)
                        {
                            if (ClearLocalData(sqlConnLocal, sqlTransLocal, true) == false)
                            {
                                //sqlTransLocal.Rollback();
                                return;
                            }

                            if (_logger.IsDebugEnabled)
                                _logger.Debug("[DEBUG] MES local DB has been cleared during application startup. <" + thisMethod + ">");

                        }
                        else
                        {
                            if (ClearLocalData(sqlConnLocal, sqlTransLocal, false) == false)
                            {
                                //sqlTransLocal.Rollback();
                                return;
                            }

                            if (_logger.IsDebugEnabled)
                                _logger.Debug("[DEBUG] MES local DB has been cleared by DB monitoring thread. <" + thisMethod + ">");
                        }


                        if (serverData.Tables["Airlines"].Rows.Count > 0)
                        {
                            if (InsertLocalAirlines(sqlConnLocal, serverData.Tables["Airlines"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalAirlines function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["BagInfo"].Rows.Count > 0)
                        {
                            if (InsertLocalBagInfo(sqlConnLocal, serverData.Tables["BagInfo"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalBagInfo function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["BagSorting"].Rows.Count > 0)
                        {
                            if (InsertLocalBagSorting(sqlConnLocal, serverData.Tables["Bagsorting"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalBagSorting function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["ChuteMapping"].Rows.Count > 0)
                        {
                            if (InsertLocalChuteMapping(sqlConnLocal, serverData.Tables["ChuteMapping"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalChuteMapping function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["FallbackMapping"].Rows.Count > 0)
                        {
                            if (InsertLocalFallbackMapping(sqlConnLocal, serverData.Tables["fallbackMapping"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalFallbackMapping function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["FallbackTagInfo"].Rows.Count > 0)
                        {
                            if (InsertLocalFallbackTagInfo(sqlConnLocal, serverData.Tables["FallbackTagInfo"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalFallbackTagInfo function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["FlightPlanAlloc"].Rows.Count > 0)
                        {
                            if (InsertLocalFlightPlanAlloc(sqlConnLocal, serverData.Tables["FlightPlanAlloc"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalFlightPlanAlloc function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["FlightPlanSorting"].Rows.Count > 0)
                        {
                            if (InsertLocalFlightPlanSorting(sqlConnLocal, serverData.Tables["FlightPlanSorting"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalFlightPlanSorting function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["FunctionTypes"].Rows.Count > 0)
                        {
                            if (InsertLocalFunctionTypes(sqlConnLocal, serverData.Tables["FunctionTypes"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalFunctionTypes function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["FunctionAllocGantt"].Rows.Count > 0)
                        {
                            if (InsertLocalFunctionAllocGantt(sqlConnLocal, serverData.Tables["FunctionAllocGantt"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalFunctionAllocGantt function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["FunctionAllocList"].Rows.Count > 0)
                        {
                            if (InsertLocalFunctionAllocList(sqlConnLocal, serverData.Tables["FunctionAllocList"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalFunctionAllocList function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["SysConfig"].Rows.Count > 0)
                        {
                            if (InsertLocalSysConfig(sqlConnLocal, serverData.Tables["SysConfig"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalSysConfig function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["Destinations"].Rows.Count > 0)
                        {
                            if (InsertLocalDestination(sqlConnLocal, serverData.Tables["Destinations"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalDestination function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["FourDigitFallbackMapping"].Rows.Count > 0)
                        {
                            if (InsertLocalFourDigitFallbackMapping(sqlConnLocal, serverData.Tables["FourDigitFallbackMapping"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalFourDigitFallbackMapping function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["PseudoBSM"].Rows.Count > 0)
                        {
                            if (InsertLocalPseudoBSM(sqlConnLocal, serverData.Tables["PseudoBSM"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalPseudoBSM function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["RoutingTable"].Rows.Count > 0)
                        {
                            if (InsertLocalRoutingTable(sqlConnLocal, serverData.Tables["RoutingTable"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalRoutingTable function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["SortationReason"].Rows.Count > 0)
                        {
                            if (InsertLocalSortationReason(sqlConnLocal, serverData.Tables["SortationReason"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalSortationReason function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["SpecialSecurityTagDestinationMapping"].Rows.Count > 0)
                        {
                            if (InsertLocalSpecialSecurityTag(sqlConnLocal, serverData.Tables["SpecialSecurityTagDestinationMapping"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalSpecialSecurityTag function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["TTSMESPriority"].Rows.Count > 0)
                        {
                            if (InsertLocalTTSMESPriority(sqlConnLocal, serverData.Tables["TTSMESPriority"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalTTSMESPriority function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["AirlineShortcuts"].Rows.Count > 0)
                        {
                            if (InsertLocalairlinecodeshortcuts(sqlConnLocal, serverData.Tables["AirlineShortcuts"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalairlinecodeshortcuts function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["HBSPassenger"].Rows.Count > 0)
                        {
                            if (InsertLocalhbspassenger(sqlConnLocal, serverData.Tables["HBSPassenger"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalhbspassenger function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["HBSFlight"].Rows.Count > 0)
                        {
                            if (InsertLocalhbsflight(sqlConnLocal, serverData.Tables["HBSFlight"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalhbsflight function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["HBSAirline"].Rows.Count > 0)
                        {
                            if (InsertLocalhbsairline(sqlConnLocal, serverData.Tables["HBSAirline"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalhbsairline function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["HBSCountry"].Rows.Count > 0)
                        {
                            if (InsertLocalhbscountry(sqlConnLocal, serverData.Tables["HBSCountry"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalhbscountry function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["HBSTagType"].Rows.Count > 0)
                        {
                            if (InsertLocalhbstagtype(sqlConnLocal, serverData.Tables["HBSTagType"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalhbstagtype function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["HBSPolicy"].Rows.Count > 0)
                        {
                            if (InsertLocalhbspolicymanagement(sqlConnLocal, serverData.Tables["HBSPolicy"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalhbspolicymanagement function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["HBSSchedule"].Rows.Count > 0)
                        {
                            if (InsertLocalhbsschedule(sqlConnLocal, serverData.Tables["HBSSchedule"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalhbsschedule function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["Airports"].Rows.Count > 0)
                        {
                            if (InsertLocalairports(sqlConnLocal, serverData.Tables["Airports"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalairports function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["MakeupFlightTypeMap"].Rows.Count > 0)
                        {
                            if (InsertLocalmakeupflighttypemapping(sqlConnLocal, serverData.Tables["MakeupFlightTypeMap"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalmakeupflighttypemapping function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["SecurityCategories"].Rows.Count > 0)
                        {
                            if (InsertLocalsecuritycategories(sqlConnLocal, serverData.Tables["SecurityCategories"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalsecuritycategories function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["SecurityGroups"].Rows.Count > 0)
                        {
                            if (InsertLocalsecuritygroups(sqlConnLocal, serverData.Tables["SecurityGroups"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalsecuritygroups function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["SecurityTasks"].Rows.Count > 0)
                        {
                            if (InsertLocalsecuritytasks(sqlConnLocal, serverData.Tables["SecurityTasks"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalsecuritytasks function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["SecurityGroupTasks"].Rows.Count > 0)
                        {
                            if (InsertLocalsecuritygrouptasks(sqlConnLocal, serverData.Tables["SecurityGroupTasks"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalsecuritygrouptasks function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["SecurityGroupTaskMap"].Rows.Count > 0)
                        {
                            if (InsertLocalsecuritygrouptaskmapping(sqlConnLocal, serverData.Tables["SecurityGroupTaskMap"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalsecuritygrouptaskmapping function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["SecurityUsers"].Rows.Count > 0)
                        {
                            if (InsertLocalsecurityusers(sqlConnLocal, serverData.Tables["SecurityUsers"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalsecurityusers function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["SecurityUserRights"].Rows.Count > 0)
                        {
                            if (InsertLocalsecurityuserrights(sqlConnLocal, serverData.Tables["SecurityUserRights"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalsecurityuserrights function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        if (serverData.Tables["HBSLevel"].Rows.Count > 0)
                        {
                            if (InsertLocalHBSLevel(sqlConnLocal, serverData.Tables["HBSLevel"], sqlTransLocal) == false)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[DEBUG] InsertLocalHBSLevel function failure! <" + thisMethod + ">");

                                sqlTransLocal.Rollback();
                                return;
                            }
                        }

                        sqlTransLocal.Commit();

                        if (serverData.Tables["SysConfig"].Rows.Count > 0)
                        {
                            GetAllMESSetting();
                        }

                        TimeSpan timeDiffConn;
                        timeDiffConn = DateTime.Now.Subtract(dt);

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[DEBUG] Downloading server data to local successful! Time span (" + timeDiffConn.Milliseconds.ToString() + "). <" + thisMethod + ">");

                    }
                }
                catch (SqlException ex)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Downloading server data to local failure! <" + thisMethod + ">", ex);
                }
                catch (Exception ex)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Downloading server data to local failure! <" + thisMethod + ">", ex);
                }
                finally
                {
                    if (sqlConnLocal != null)
                    {
                        sqlConnLocal.Close();
                        sqlConnLocal.Dispose();
                        sqlConnLocal = null;
                    }

                    if (sqlConnServer != null)
                    {
                        sqlConnServer.Close();
                        sqlConnServer.Dispose();
                        sqlConnServer = null;
                    }
                    _isRunning = false;
                }
            }
        }

        /// <summary>
        /// Get Bag GID from the database.
        /// </summary>
        /// <param name="licensePlate">License plate number to retrieve Bag GID</param>
        /// <returns>Return Bag GID number as type of System.String</returns>
        public string GetBagGID(string licensePlate)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            string bagGID = string.Empty;

            try
            {
                sqlConn = new SqlConnection();
                //if (ClassParameters.SecondaryDBAlive==true)
                //{
                //    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;
                //}
                if (ClassParameters.MainDBAlive==true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_BAG_GID, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@LICENSE_PLATE", SqlDbType.VarChar, 10);
                sqlPara1.Value = licensePlate;

                sqlConn.Open();
                SqlDataReader sqlReader = sqlCmd.ExecuteReader();
                while (sqlReader.Read())
                {
                    if (!sqlReader.IsDBNull(0)) bagGID = sqlReader.GetString(0);
                }
                sqlReader.Close();
                sqlReader.Dispose();
                sqlReader = null;
                sqlCmd.Dispose();
                sqlCmd = null;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Database connection checking is failed! " +
                                    "Please check DB ConnectionString setting, or DB server status. <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Initializing database is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return bagGID;
        }

        /// <summary>
        /// Get license plate information from database.
        /// </summary>
        /// <param name="bagGID">Bag GID informatoin to retrieve license plate</param>
        /// <returns>Return license plate number as System.string</returns>
        public string GetLicensePlate(string bagGID)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            string licensePlate = string.Empty;

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_LICENSE_PLATE, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@BAG_GID", SqlDbType.VarChar, 10);
                sqlPara1.Value = bagGID;

                sqlConn.Open();
                SqlDataReader sqlReader = sqlCmd.ExecuteReader();
                while (sqlReader.Read())
                {
                    if (!sqlReader.IsDBNull(0)) licensePlate = sqlReader.GetString(0);
                }
                sqlReader.Close();
                sqlReader.Dispose();
                sqlReader = null;
                sqlCmd.Dispose();
                sqlCmd = null;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Database connection checking is failed! " +
                                    "Please check DB ConnectionString setting, or DB server status. <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Initializing database is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return licensePlate;
        }

        /// <summary>
        /// Generate in-house tag on server side.
        /// </summary>
        /// <param name="firstDigit">First digit as type of System.string</param>
        /// <param name="airline">Airline code as type of System.string</param>
        /// <param name="flightNumber">Flight number as type of System.string</param>
        /// <param name="sdo">SDO as type of System.DateTime</param>
        /// <param name="desc">Description as type of System.string</param>
        /// <param name="mesStation">MES station name as type of System.string</param>
        /// <param name="location">Location of MES Telegram as type of System.string</param>
        /// <param name="subsystem">Subsystem of MES Telegram as type of System.string</param>
        /// <param name="sType">Telegram Type</param>
        /// <returns>Return generated inhouse tag.</returns>
        public string GenerateInhouseTag(string firstDigit, string airline, string flightNumber,
            DateTime sdo, string desc, string mesStation, string subsystem, string location, string sType)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            string licensePlate = string.Empty;
            string numberRange = string.Empty;
            numberRange = ClassParameters.InhouseTagRange;

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive==true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GENERATE_IN_HOUSE_BSM, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@FIRST_DIGIT", SqlDbType.VarChar, 4);
                sqlPara1.Value = firstDigit;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@AIRLINE", SqlDbType.VarChar, 5);
                sqlPara2.Value = airline;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@FLIGHT_NUMBER", SqlDbType.VarChar, 5);
                sqlPara3.Value = flightNumber;

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@SDO", SqlDbType.DateTime);
                sqlPara4.Value = sdo;

                SqlParameter sqlPara5 = sqlCmd.Parameters.Add("@DESCRIPTION", SqlDbType.VarChar, 20);
                sqlPara5.Value = desc;

                SqlParameter sqlPara6 = sqlCmd.Parameters.Add("@MES_STATION", SqlDbType.VarChar, 16);
                sqlPara6.Value = mesStation;

                SqlParameter sqlPara7 = sqlCmd.Parameters.Add("@NUMBER_RANGE", SqlDbType.VarChar, 14);
                sqlPara7.Value = numberRange;

                SqlParameter sqlPara8 = sqlCmd.Parameters.Add("@SUBSYSTEM", SqlDbType.VarChar, 10);
                sqlPara8.Value = subsystem;

                SqlParameter sqlPara9 = sqlCmd.Parameters.Add("@LOCATION", SqlDbType.VarChar, 10);
                sqlPara9.Value = location;

                SqlParameter sqlPara10 = sqlCmd.Parameters.Add("@TYPE", SqlDbType.VarChar, 10);
                sqlPara10.Value = sType;

                sqlConn.Open();
                SqlDataReader sqlReader = sqlCmd.ExecuteReader();
                while (sqlReader.Read())
                {
                    if (!sqlReader.IsDBNull(0)) licensePlate = sqlReader.GetString(0);
                }
                sqlReader.Close();
                sqlReader.Dispose();
                sqlReader = null;
                sqlCmd.Dispose();
                sqlCmd = null;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Generate in-house tag number is failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Generate in-house tag number is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return licensePlate;
        }

        public DataTable GetInhouseTag(string airline, string flightNumber,
            DateTime sdo, string mesStation, int flag)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet inhouseTag = new DataSet();

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive ==true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_INHOUSE_BSM, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@AIRLINE", SqlDbType.VarChar, 5);
                sqlPara2.Value = airline;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@FLIGHT_NUMBER", SqlDbType.VarChar, 5);
                sqlPara3.Value = flightNumber;

                if (sdo == null)
                    sdo = Convert.ToDateTime("01-Jan-1900 00:00");

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@SDO", SqlDbType.DateTime);
                sqlPara4.Value = sdo;

                SqlParameter sqlPara5 = sqlCmd.Parameters.Add("@MES_STATION", SqlDbType.VarChar, 16);
                sqlPara5.Value = mesStation;

                SqlParameter sqlPara6 = sqlCmd.Parameters.Add("@FLAG", SqlDbType.Int);
                sqlPara6.Value = flag;

                sqlConn.Open();

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);
                sqlAdapter.Fill(inhouseTag);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Generate in-house tag number is failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Generate in-house tag number is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return inhouseTag.Tables[0];
        }

        public bool UpdateInhouseBSM(string inHouseBSM, string airLine, string flightNumber, 
            DateTime sdo, string description, string mesStation, string subSystem, string location)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive==true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_UPDATE_ITEM_INHOUSE_BSM, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@INHOUSEBSM", SqlDbType.VarChar, 10);
                sqlPara1.Value = inHouseBSM;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@AIRLINE", SqlDbType.VarChar, 5);
                sqlPara2.Value = airLine;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@FLIGHT_NUMBER", SqlDbType.VarChar, 5);
                sqlPara3.Value = flightNumber;

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@SDO", SqlDbType.DateTime);
                sqlPara4.Value = sdo;

                SqlParameter sqlPara5 = sqlCmd.Parameters.Add("@DESCRIPTION", SqlDbType.VarChar, 20);
                sqlPara5.Value = description;

                SqlParameter sqlPara6 = sqlCmd.Parameters.Add("@MES_STATION", SqlDbType.VarChar, 16);
                sqlPara6.Value = mesStation;

                SqlParameter sqlPara7 = sqlCmd.Parameters.Add("@SUBSYSTEM", SqlDbType.VarChar, 10);
                sqlPara7.Value = subSystem;

                SqlParameter sqlPara8 = sqlCmd.Parameters.Add("@LOCATION", SqlDbType.VarChar, 16);
                sqlPara8.Value = location;

                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                string sNewInhouseTag = (string)sqlCmd.ExecuteScalar();
                InsertMESEvent(DateTime.Now, sNewInhouseTag, sNewInhouseTag, subSystem, location, mesStation, "UPDINHOUSE", "UPD INHOUSE TAG");
                sqlTrans.Commit();
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating MES inhouse BSM information failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating MES inhouse BSM information failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
            return true;
        }

        public DataTable GetIATATagList(string airline, string flightNumber,
            DateTime sdo, string sMESStation, int flag)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet inhouseTag = new DataSet();

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_IATA_TAG_LIST, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@AIRLINE", SqlDbType.VarChar, 5);
                sqlPara2.Value = airline;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@FLIGHT_NUMBER", SqlDbType.VarChar, 5);
                sqlPara3.Value = flightNumber;

                if (sdo == null)
                    sdo = Convert.ToDateTime("01-Jan-1900");

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@SDO", SqlDbType.DateTime);
                sqlPara4.Value = sdo;

                SqlParameter sqlPara5 = sqlCmd.Parameters.Add("@FLAG", SqlDbType.Int);
                sqlPara5.Value = flag;

                SqlParameter sqlPara6 = sqlCmd.Parameters.Add("@MES_STATION", SqlDbType.VarChar, 16);
                sqlPara6.Value = sMESStation;

                sqlConn.Open();

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);
                sqlAdapter.Fill(inhouseTag);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get IATA tag list is failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get IATA tag list is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return inhouseTag.Tables[0];
        }

        /// <summary>
        /// Load data to combobox in pop-up window for Generate Tag module
        /// </summary>
        /// <returns></returns>
        public DataSet GetComboData()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsServerData = new DataSet();
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_COMBO_DATA, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlAdapter.Fill(dsServerData);
                dsServerData.Tables[0].TableName = "Airlines";
                dsServerData.Tables[1].TableName = "FlightNumber";
                dsServerData.Tables[2].TableName = "SDO";
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get server information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get server information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return dsServerData;
        }

        public DataTable GetAirlines()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet airlines = new DataSet();

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_AIRLINES, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlConn.Open();

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);
                sqlAdapter.Fill(airlines);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get airlines list is failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get airlines list is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return airlines.Tables[0];
        }

        public DataTable GetFlights(string sFlightNumber, string sTTSID)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet flights = new DataSet();

            try
            {
                sqlConn = new SqlConnection();

                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                if (_logger.IsInfoEnabled)
                    _logger.Info("Connection String:" + sqlConn.ConnectionString);

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_FLIGHT, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@FLIGHT", SqlDbType.VarChar, 10);
                sqlPara1.Value = sFlightNumber;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@TTSID", SqlDbType.VarChar, 10);
                sqlPara2.Value = sTTSID;

                sqlConn.Open();

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);
                sqlAdapter.Fill(flights);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get airlines list is failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get airlines list is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return flights.Tables[0];
        }

        public DataTable GetDestination(string sDestination, string sTTSID)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet destinations = new DataSet();

            try
            {
                sqlConn = new SqlConnection();

                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_DESTINATION, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@DESTINATION", SqlDbType.VarChar, 20);
                sqlPara1.Value = sDestination;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@TTS", SqlDbType.VarChar, 10);
                sqlPara2.Value = sTTSID;

                sqlConn.Open();

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);
                sqlAdapter.Fill(destinations);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get destination list is failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get destination list is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return destinations.Tables[0];
        }

        public string GetReason(string sReasonID)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            string reason = string.Empty;

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_REASON, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@REASON_ID", SqlDbType.VarChar, 5);
                sqlPara1.Value = sReasonID;

                sqlConn.Open();
                SqlDataReader sqlReader = sqlCmd.ExecuteReader();
                while (sqlReader.Read())
                {
                    if (!sqlReader.IsDBNull(0)) reason = sqlReader.GetString(0);
                }
                sqlReader.Close();
                sqlReader.Dispose();
                sqlReader = null;
                sqlCmd.Dispose();
                sqlCmd = null;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Database connection checking is failed! " +
                                    "Please check DB ConnectionString setting, or DB server status. <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Initializing database is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return reason;
        }


        /// <summary>
        /// GetConv_StatusColor the database.
        /// SubSystm(Current MES workstation)
        /// </summary>
        /// <param name="SubSystm">SubSystm</param>
        public DataTable GetConv_StatusColor(string MES_StationName)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            DataTable dt = new DataTable();
            try
            {

                SqlConnection sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                SqlCommand cmd = new SqlCommand(ClassParameters.stp_MES_GET_CONV_STATUS, sqlConn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SubSystem", MES_StationName);//Modified by Guo Wenyu 2014/04/03 @SubSystm
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get conveyor status is failed! <" + thisMethod + ">", ex); // by guo wenyu
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get conveyor status is failed! <" + thisMethod + ">", ex);// by guo wenyu
            }
            finally
            {
                dt.Dispose();
            }
            return dt;
        }

        /// <summary>
        /// Remove inhouse BSM item information from the database.
        /// </summary>
        /// <param name="sInHouseBSM">In-House BSM ID</param>
        /// <param name="SubSystem">Sub system information as type of System.string</param>
        /// <param name="Location">Location as type of System.string</param>
        public void RemoveInHouseBSM(string sInHouseBSM, string SubSystem, string Location)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_REMOVE_INHOUSE_BSM, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@INHOUSE_BSM", SqlDbType.VarChar, 10);
                sqlPara1.Value = sInHouseBSM;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@SUBSYSTEM", SqlDbType.VarChar, 10);
                sqlPara2.Value = SubSystem;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@LOCATION", SqlDbType.VarChar, 10);
                sqlPara3.Value = Location;

                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
                sqlTrans.Commit();
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting Item Encode information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting Item Encode information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

       
        /// <summary>
        /// UPdate into Bag Infor table for Item Encoded.
        /// </summary>
        /// <param name="sGID"></param>
        /// <param name="sLicensePlate"></param>
        /// <param name="sPLCIndexNo"></param>
        /// <param name="Destination"></param>
        /// <param name="EncodeType"></param>
        /// <param name="SortReason"></param>
        /// <param name="MinHBSLevel"></param>
        /// <param name="sCurrentLocation"></param>
        /// <param name="sSubSystem"></param>
        /// <returns></returns>
        public DataTable UpdateBagInfo(
            string sGID, string sLicensePlate, string sPLCIndexNo, string Destination, string EncodeType, 
            string SortReason, string MinHBSLevel, string sCurrentLocation,  string sSubSystem)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsInventoryList = new DataSet();
            SqlTransaction sqlTrans = null;
            string bagGID = string.Empty;

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_UPDATE_BAG_INFO, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.CommandTimeout = Convert.ToInt32(ClassParameters.CommandTimeOut);

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                sqlPara1.Value = sGID;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@LICENSE_PLATE", SqlDbType.VarChar, 10);
                sqlPara2.Value = sLicensePlate;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@PLC_INDEX_NO", SqlDbType.VarChar, 10);
                sqlPara3.Value = sPLCIndexNo;

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@CUR_LOCATION", SqlDbType.VarChar, 10);
                sqlPara4.Value = sCurrentLocation;

                SqlParameter sqlPara5 = sqlCmd.Parameters.Add("@SUB_SYSTEM", SqlDbType.VarChar, 10);
                sqlPara5.Value = sSubSystem;

                SqlParameter sqlPara6 = sqlCmd.Parameters.Add("@DEST", SqlDbType.VarChar, 10);
                sqlPara6.Value = Destination;

                SqlParameter sqlPara7 = sqlCmd.Parameters.Add("@ENCODED_TYPE", SqlDbType.VarChar, 2);
                sqlPara7.Value = EncodeType;

                SqlParameter sqlPara8 = sqlCmd.Parameters.Add("@REASON", SqlDbType.VarChar, 2);
                sqlPara8.Value = SortReason;

                SqlParameter sqlPara9 = sqlCmd.Parameters.Add("@MIN_HBS_LEVEL", SqlDbType.VarChar, 1);
                sqlPara9.Value = MinHBSLevel;

                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);
                sqlAdapter.Fill(dsInventoryList);
                sqlTrans.Commit();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating bag info is failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating bag info is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            if (dsInventoryList.Tables.Count > 0)
            {
                return dsInventoryList.Tables[0];
            }
            else
            {
                return null;
            }
        }

        /// <summary>
        /// UPdate into Bag Info table for Item Removed.
        /// </summary>
        /// <param name="sGID"></param>
        /// <param name="sLicensePlate"></param>
        /// <param name="sPLCIndexNo"></param>
        /// <param name="Destination"></param>
        /// <param name="EncodeType"></param>
        /// <param name="SortReason"></param>
        /// <param name="MinHBSLevel"></param>
        /// <param name="sCurrentLocation"></param>
        /// <param name="sSubSystem"></param>
        /// <returns></returns>
        public DataTable UpdateBagInfoForItemRemove(
            string sGID, string sLicensePlate, string sPLCIndexNo, string Destination, string EncodeType,
            string SortReason, string MinHBSLevel, string sCurrentLocation, string sSubSystem)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsInventoryList = new DataSet();
            SqlTransaction sqlTrans = null;
            string bagGID = string.Empty;

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_UPDATE_BAG_INFO_FOR_ITEM_REMOVE, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                sqlPara1.Value = sGID;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@LICENSE_PLATE", SqlDbType.VarChar, 10);
                sqlPara2.Value = sLicensePlate;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@PLC_INDEX_NO", SqlDbType.VarChar, 10);
                sqlPara3.Value = sPLCIndexNo;

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@CUR_LOCATION", SqlDbType.VarChar, 10);
                sqlPara4.Value = sCurrentLocation;

                SqlParameter sqlPara5 = sqlCmd.Parameters.Add("@SUB_SYSTEM", SqlDbType.VarChar, 10);
                sqlPara5.Value = sSubSystem;

                SqlParameter sqlPara6 = sqlCmd.Parameters.Add("@DEST", SqlDbType.VarChar, 10);
                sqlPara6.Value = Destination;

                SqlParameter sqlPara7 = sqlCmd.Parameters.Add("@ENCODED_TYPE", SqlDbType.VarChar, 2);
                sqlPara7.Value = EncodeType;

                SqlParameter sqlPara8 = sqlCmd.Parameters.Add("@REASON", SqlDbType.VarChar, 2);
                sqlPara8.Value = SortReason;

                SqlParameter sqlPara9 = sqlCmd.Parameters.Add("@MIN_HBS_LEVEL", SqlDbType.VarChar, 1);
                sqlPara9.Value = MinHBSLevel;

                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);
                sqlAdapter.Fill(dsInventoryList);
                sqlTrans.Commit();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating bag info for item remove is failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating bag info for item remove is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            if (dsInventoryList.Tables.Count > 0)
            {
                return dsInventoryList.Tables[0];
            }
            else
            {
                return null;
            }
        }

        /// <summary>
        /// Insert flight plan sorting data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalDestination(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_DESTINATIONS, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@DESTINATIONS", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting destination data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting destination data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert flight plan sorting data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalFourDigitFallbackMapping(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_FOUR_DIGITS_FALLBACK_MAPPING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@FOUR_DIGITS_FALLBACK_MAPPING", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting four digits fallback mapping data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting four digits fallback mapping data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert flight plan sorting data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalPseudoBSM(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_LOCAL_PSEUDO_BSM, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@PSEUDO_BSM", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting pseudo bsm data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting pseudo bsm data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert flight plan sorting data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalRoutingTable(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_ROUTING_TABLE, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@ROUTING_TABLE", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting routing table data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting routing table data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert flight plan sorting data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalSortationReason(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_SORTATION_REASON, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SORTATION_REASON", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting sortation reason data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting sortation reason data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert flight plan sorting data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalSpecialSecurityTag(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_SPECIAL_SECURITY_TAG_DESTINATION_MAPPING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SPECIAL_SECURITY_TAG_DESTINATION_MAPPING", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting special security tag destination mapping data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting special security tag destination mapping data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert flight plan sorting data into local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalTTSMESPriority(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_TTS_MES_PRIORITY, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@TTS_MES_PRIORITY", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting TTS MES Priority data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting TTS MES Priority data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Remove all locally inserted data before transferring data from main database
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse in the function</param>
        /// <param name="sqlTrans">Opened transaction to reuse in the function</param>
        /// <returns>Return success or fail satatus.</returns>
        private bool ClearLocalData(SqlConnection sqlConn, SqlTransaction sqlTrans, bool bStartup)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_CLEAR_LOCAL_DATA, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@START_UP", SqlDbType.Bit);
                sqlPara2.Value = bStartup;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Clearing local data information fail! <" + thisMethod + ">", ex);
                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Clearing local data information fail! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        public DataTable GetSpecificDestination(string sTTSIDs)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet destinations = new DataSet();

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_SPECIFIC_DEST, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@TTS_ID", SqlDbType.VarChar, 10);
                sqlPara2.Value = sTTSIDs;

                sqlConn.Open();

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);
                sqlAdapter.Fill(destinations);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get destination list is failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get destination list is failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return destinations.Tables[0];
        }

        #region Sortation Control
        /// <summary>
        /// Get Security Tag Level from DB
        /// </summary>
        /// <param name="tagCode"></param>
        /// <returns></returns>
        public string GetSecurityTagLevelFromDB(string tagCode)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            string securityLevel = string.Empty;

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }
                
                sqlCmd = new SqlCommand(ClassParameters.STPGetSecurityTagLevel, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@ID", SqlDbType.VarChar, 2);
                sqlCmd.Parameters["@ID"].Value = tagCode;

                sqlCmd.Parameters.Add("@Level", SqlDbType.VarChar, 1);
                sqlCmd.Parameters["@Level"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@Level"].Value != DBNull.Value)
                {
                    securityLevel = sqlCmd.Parameters["@Level"].Value.ToString();
                }

                return securityLevel;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Security Tag Level From DB failure! <" + thisMethod + ">", ex);

                return securityLevel;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Security Tag Level From DB failure! <" + thisMethod + ">", ex);

                return securityLevel;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Get Minimum Security Level From DB
        /// </summary>
        /// <param name="licensePlate"></param>
        /// <returns></returns>
        public string GetMinimumSecurityLevelFromDB(string licensePlate)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            string securityLevel = string.Empty;

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }
                
                sqlCmd = new SqlCommand(ClassParameters.STPGetMinimumSecurityLevel, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@LicensePlate", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@LicensePlate"].Value = licensePlate;

                sqlCmd.Parameters.Add("@SecurityLevel", SqlDbType.VarChar, 1);
                sqlCmd.Parameters["@SecurityLevel"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@SecurityLevel"].Value != DBNull.Value)
                {
                    securityLevel = sqlCmd.Parameters["@SecurityLevel"].Value.ToString();
                }

                return securityLevel;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Security Tag Level From DB failure! <" + thisMethod + ">", ex);

                return securityLevel;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Security Tag Level From DB failure! <" + thisMethod + ">", ex);

                return securityLevel;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Minimum HBS Security Level Meet Checking
        /// by default isInduction will set to true as no need to clear the EBS bit in BAG_INFO table
        /// </summary>
        /// <param name="gid"></param>
        /// <param name="isMeet"></param>
        /// <param name="minimumSecurityLevel"></param>
        /// <param name="currentSecurityLevel"></param>
        /// <param name="isEBS"></param>
        /// <param name="isIATAInterlineInHouseTag"></param>
        /// <param name="licensePlate"></param>
        /// <param name="isInduction"></param> 
        /// <param name="isBCASEnabled"></param>
        /// <param name="isHBSResultEmpty"></param>
        public void MinimumHBSSecurityLevelMeetChecking(string gid, out bool isMeet, string minimumSecurityLevel, out string currentSecurityLevel,
                out bool isEBS, bool isIATAInterlineInHouseTag, string licensePlate, bool isInduction, out bool isBCASEnabled, out bool isHBSResultEmpty)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            string securityLevel = string.Empty;
            string sDBConnectionString = string.Empty;
            isInduction = true;
            isMeet = false;
            isEBS = false;
            currentSecurityLevel = string.Empty;
            isBCASEnabled = false;
            isHBSResultEmpty = true;

            try
            {
                if (ClassParameters.MainDBAlive == true)
                {
                    sDBConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sDBConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlConn = new SqlConnection(sDBConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPMinimumHBSSecurityLevelMeetChecking, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.CommandTimeout = Convert.ToInt32(ClassParameters.CommandTimeOut);

                sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@GID"].Value = gid;

                sqlCmd.Parameters.Add("@Accept", SqlDbType.VarChar, 1);
                sqlCmd.Parameters["@Accept"].Value = ClassParameters.HBSAcceptedID;

                sqlCmd.Parameters.Add("@IsMeet", SqlDbType.Bit);
                sqlCmd.Parameters["@IsMeet"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@MinSecurityLevel", SqlDbType.VarChar, 1);
                sqlCmd.Parameters["@MinSecurityLevel"].Value = minimumSecurityLevel;

                sqlCmd.Parameters.Add("@CurrentHBSLevel", SqlDbType.VarChar, 2);
                sqlCmd.Parameters["@CurrentHBSLevel"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@IsEBS", SqlDbType.Bit);
                sqlCmd.Parameters["@IsEBS"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@LicensePlate", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@LicensePlate"].Value = licensePlate;

                sqlCmd.Parameters.Add("@NeedCheckLP", SqlDbType.Bit);
                sqlCmd.Parameters["@NeedCheckLP"].Value = isIATAInterlineInHouseTag;

                sqlCmd.Parameters.Add("@IsInduction", SqlDbType.Bit);
                sqlCmd.Parameters["@IsInduction"].Value = isInduction;

                sqlCmd.Parameters.Add("@NeedCheckHBSL1", SqlDbType.Bit);
                sqlCmd.Parameters["@NeedCheckHBSL1"].Value = ClassParameters.IsNeedCheckHBSL1;

                sqlCmd.Parameters.Add("@IsBCASEnabled", SqlDbType.Bit);
                sqlCmd.Parameters["@IsBCASEnabled"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@IsHBSResultEmpty", SqlDbType.Bit);
                sqlCmd.Parameters["@IsHBSResultEmpty"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@IsMeet"].Value != DBNull.Value)
                {
                    isMeet = Convert.ToBoolean(sqlCmd.Parameters["@IsMeet"].Value.ToString().Trim());
                }

                if (sqlCmd.Parameters["@CurrentHBSLevel"].Value != DBNull.Value)
                {
                    currentSecurityLevel = sqlCmd.Parameters["@CurrentHBSLevel"].Value.ToString().Trim();
                }

                if (sqlCmd.Parameters["@IsEBS"].Value != DBNull.Value)
                {
                    isEBS = Convert.ToBoolean(sqlCmd.Parameters["@IsEBS"].Value.ToString().Trim());
                }

                if (sqlCmd.Parameters["@IsBCASEnabled"].Value != DBNull.Value)
                {
                    isBCASEnabled = Convert.ToBoolean(sqlCmd.Parameters["@IsBCASEnabled"].Value.ToString().Trim());
                }

                if (sqlCmd.Parameters["@IsHBSResultEmpty"].Value != DBNull.Value)
                {
                    isHBSResultEmpty = Convert.ToBoolean(sqlCmd.Parameters["@IsHBSResultEmpty"].Value.ToString().Trim());
                }
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Minimum HBS Security Level Meet Checking From DB failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Minimum HBS Security Level Meet Checking From DB failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Customs Security Meet Checking
        /// </summary>
        /// <param name="gid"></param>
        /// <param name="isMeet"></param>
        /// <param name="isIATAInterlineInHouseTag"></param>
        /// <param name="licensePlate"></param>
        /// <param name="isCustomResultEmpty"></param>
        public void CustomsSecurityMeetChecking(string gid, out bool isMeet, bool isIATAInterlineInHouseTag, string licensePlate, out bool isCustomResultEmpty)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            string customsResult = string.Empty;
            string securityLevel = string.Empty;

            isMeet = false;
            isCustomResultEmpty = true;

            try
            {
                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlConn = new SqlConnection(sConnectionString);

                sqlCmd = new SqlCommand(ClassParameters.STPCustomsSecurityMeetChecking, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;


                sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@GID"].Value = gid;

                //sqlCmd.Parameters.Add("@Accept", SqlDbType.VarChar, 1);
                //sqlCmd.Parameters["@Accept"].Value = ClassParameters.CustomsAcceptedID;

                sqlCmd.Parameters.Add("@CustomsResult", SqlDbType.VarChar, 1);
                sqlCmd.Parameters["@CustomsResult"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@LicensePlate", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@LicensePlate"].Value = licensePlate;

                sqlCmd.Parameters.Add("@NeedCheckLP", SqlDbType.Bit);
                sqlCmd.Parameters["@NeedCheckLP"].Value = isIATAInterlineInHouseTag;

                sqlCmd.Parameters.Add("@IsCustomResultEmpty", SqlDbType.Bit);
                sqlCmd.Parameters["@IsCustomResultEmpty"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@CustomsResult"].Value != DBNull.Value)
                {
                    customsResult = sqlCmd.Parameters["@CustomsResult"].Value.ToString().Trim();
                }

                if (sqlCmd.Parameters["@IsCustomResultEmpty"].Value != DBNull.Value)
                {
                    isCustomResultEmpty = Convert.ToBoolean( sqlCmd.Parameters["@IsCustomResultEmpty"].Value.ToString().Trim());
                }

                if (_logger.IsDebugEnabled)
                    _logger.Debug(
                            "[GID:" + gid + ", LP:" + licensePlate + "isIATAInterlineInHouseTag:" + isIATAInterlineInHouseTag.ToString() +
                            "] CustomResult =" + customsResult +
                            "). <" + thisMethod + ">");

                if (ClassParameters.CustomsAcceptedID.Contains(customsResult)) 
                {
                    isMeet = true;
                }
                else
                {
                    isMeet = false;
                }


                if (_logger.IsDebugEnabled)
                    _logger.Debug(
                            "[GID:" + gid + ", LP:" + licensePlate +
                            "] IsCustomMeet =" + isMeet.ToString() +
                            "). <" + thisMethod + ">");

                //if (sqlCmd.Parameters["@IsMeet"].Value != DBNull.Value)
                //{
                //    isMeet = Convert.ToBoolean(sqlCmd.Parameters["@IsMeet"].Value.ToString().Trim());
                //}
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Customs Security Meet Checking From DB failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Customs Security Meet Checking From DB failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Get Destination Of Customs Chute
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="licensePlate"></param>
        /// <param name="reason"></param>
        /// <param name="currentLocation"></param>
        /// <param name="tts"></param>
        /// <returns></returns>
        public LocationID[] GetDestinationOfCustomsChute(string channelName, string gid, string licensePlate, ref string reason, LocationID currentLocation,
                string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] destination = null;

            try
            {
                // Sorted by Customs Reject Bag
                reason = ClassParameters.SortReasonCRB;

                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationCRB,
                        currentLocation, ref destination, ClassParameters.CustomsChuteLocation, tts);

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid + ", License Plate:" + licensePlate +
                            "] which is " + ClassParameters.FuncAllocationCRB +
                            " item. It will redirect to Customs Chute destination: [" +
                            Utilities.LocationIDArrayToString(ref destination) +
                            "] . <" + thisMethod + ">");

                return destination;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of Customs Chute is failure! <" + thisMethod + ">", ex);

                return destination;
            }
        }

        /// <summary>
        /// GetDestination
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="currentLocation"></param>
        /// <param name="validTag"></param>
        /// <param name="hbs1"></param>
        /// <param name="hbs2"></param>
        /// <param name="hbs3"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestination(string channelName, string gid, LocationID currentLocation,
                   Tag validTag, string hbs1, string hbs2, string hbs3, ref string reason, ref LocationID[] destinations,
                   string tts, bool isHLCMode)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] mesLocation = null;

            if (tts == TTS01_SUBSYSTEM)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
            }

            try
            {
                #region Check Bag Tag Type
                if (validTag.Type == TagType.DummyEmptyLP)  // Dummay Empty LP# (0000000000)
                {
                    // Multiple LP validity checking failure, handle bag as the No-Read bag.
                    GetDestinationOfNORD(channelName, gid, currentLocation, ref reason, ref destinations, tts);
                    return;
                }
                else if (validTag.Type == TagType.DummyMultipleLP)  //Dummy Multiple LP# (9999999999)
                {
                    // Both LPs are invalid or both are valid LP;
                    // BMLP: Multiple License Plate Function Allocation
                    GetDestinationOfMTLP(channelName, gid, validTag.LP, currentLocation, ref reason, ref destinations, tts);

                    return;
                }
                else if (validTag.Type == TagType.FallbackTag)
                {
                    // If it is Fallback Tag, then sort it to Fallback tag destination, 
                    GetDestinationOfIATAFallbackTag(channelName, gid, validTag, currentLocation, ref reason, ref destinations, tts);

                    return;
                }
                else if (validTag.Type == TagType.FourDigitsFallbackTag)
                {
                    // If it is Four Digits Fallback Tag, then sort it to Four Digits Fallback tag destination, 
                    GetDestinationOfFourDigitsFallbackTag(channelName, gid, validTag, currentLocation, ref reason, ref destinations, tts);

                    return;
                }
                else if (validTag.Type == TagType.SecurityTag)
                {
                    // If it is Four Digits security Tag, then sort it to Four Digits security tag destination, 
                    GetDestinationOfFourDigitsSecurityTag(channelName, gid, validTag, currentLocation, ref reason, ref destinations, tts);

                    return;
                }
                #endregion

                //// Check for flight cancellation
                //string flighCancellation = string.Empty;
                //GetCancellationOfFlight(validTag.LP, out flighCancellation);

                //if (flighCancellation == ClassParameters.FlightCancellationValue)
                //{
                //    // If no airline code is extracted from LP, then handle it as CCFL bag.
                //    GetDestinationOfCCFL(channelName, gid, validTag.LP, currentLocation, ref reason, ref destinations, tts);

                //    return;
                //}

                // If tag# is not dummy empty tag#, not dummy multiple tag#, and not the fallback tag#,
                // then continue with following IATA tag sortation process.
                string airline, flightNo, masterAirline, masterFlightNo, bsmTravelClass, bsmException, flightHighRisk,
                    flightException, sto;
                int status = -1;
                DateTime sdo = new DateTime();
                AllocationProperty[] allocations;

                airline = string.Empty;
                flightNo = string.Empty;
                masterAirline = string.Empty;
                masterFlightNo = string.Empty;
                bsmTravelClass = string.Empty;
                bsmException = string.Empty;
                flightHighRisk = string.Empty;
                flightException = string.Empty;
                sto = string.Empty;
                allocations = null;

                

                #region Get Allocation
                if (validTag.Type == TagType.IATATag)
                {
                    status = GetAllocationInfoFromIATATag(validTag.LP, ref airline, ref flightNo, ref masterAirline, ref masterFlightNo,
                                    ref sdo, ref sto, ref bsmTravelClass, ref bsmException, ref flightHighRisk, ref flightException,
                                    ref allocations, tts);
                    if (isHLCMode)
                    {

                        if (status == 1)
                        {
                            // check pseudo BSM table
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP +
                                        "] No BSM is found from original BSM, Pseudo BSM will be used if it is found. <" + thisMethod + ">");

                            airline = string.Empty;
                            flightNo = string.Empty;
                            masterAirline = string.Empty;
                            masterFlightNo = string.Empty;
                            bsmTravelClass = string.Empty;
                            bsmException = string.Empty;
                            flightHighRisk = string.Empty;
                            flightException = string.Empty;
                            sto = string.Empty;
                            allocations = null;

                            status = GetAllocationInfoUsingPseudoBSM(validTag.LP, ref airline, ref flightNo, ref masterAirline, ref masterFlightNo,
                                        ref sdo, ref sto, ref bsmTravelClass, ref bsmException, ref flightHighRisk, ref flightException,
                                        ref allocations, tts);
                        }
                    }
                    else
                    {
                        status = 9;

                        // LLC operational mode
                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP +
                                    "] LLC operational mode is enabled, airline sortation will be used. <" + thisMethod + ">");

                    }
                }
                else if (validTag.Type == TagType.InHouseTag)
                {
                    // check pseudo BSM table
                    status = GetAllocationInfoUsingPseudoBSM(validTag.LP, ref airline, ref flightNo, ref masterAirline, ref masterFlightNo,
                                ref sdo, ref sto, ref bsmTravelClass, ref bsmException, ref flightHighRisk, ref flightException,
                                ref allocations, tts);
                }
                #endregion

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid + ", LP:" + validTag.LP +
                            "] Status = " + status.ToString() + ". <" + thisMethod + ">");

                switch (status)
                {
                    case 1:
                        #region No BSM
                        // 1:  No BSM of specific LP# is in the [BAG_SORTING] and [PSEUDO_BSM] table, it is No BSM (NBSM) item;
                        if (AirlineSortEnabled)
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP +
                                        "] No BSM is found, item will be sorted by Airline Allocation. <" + thisMethod + ">");

                            if (validTag.AirlineCode == string.Empty)
                            {
                                // If no airline code is extracted from LP, then handle it as NBSM bag.
                                GetDestinationOfNBSM(channelName, gid, validTag.LP, currentLocation, ref reason, ref destinations, tts);
                            }
                            else
                            {
                                GetDestinationOfAirline(channelName, gid, validTag.AirlineCode, currentLocation, ref reason, ref destinations, tts);

                                if (destinations == null)
                                {
                                    // If Airline has no allocated destination, then handle it as NBSM bag.
                                    if (_logger.IsInfoEnabled)
                                        _logger.Info("[Channel:" + channelName +
                                                "] [GID:" + gid + ", LP:" + validTag.LP +
                                                ", Airline:" + validTag.AirlineCode +
                                                "] Airline has no allocated destination. It will be sorted as NBSM bag. <" + thisMethod + ">");

                                    GetDestinationOfNBSM(channelName, gid, validTag.LP, currentLocation, ref reason, ref destinations, tts);
                                }
                                else
                                {
                                    if (_logger.IsInfoEnabled)
                                        _logger.Info("[Channel:" + channelName +
                                                "] [GID:" + gid + ", LP:" + validTag.LP +
                                                ", Airline:" + validTag.AirlineCode +
                                                "] Airline allocated destination: (" +
                                                Utilities.LocationIDArrayToString(ref destinations) +
                                                "). <" + thisMethod + ">");
                                }
                            }
                        }
                        else
                        {
                            // If Airline Allocation Sortation is disabled, then handle it as NBSM bag.
                            GetDestinationOfNBSM(channelName, gid, validTag.LP, currentLocation, ref reason, ref destinations, tts);
                        }
                        #endregion
                        break;
                    case 2:
                        #region Multiple BSM
                        // 2:  More than one BSMs of specific LP# are in the [BAG_SORTING] table, it is multiple
                        //     BSM (MBSM) item;
                        GetDestinationOfMBSM(channelName, gid, validTag.LP, currentLocation, ref reason, ref destinations, tts);
                        #endregion
                        break;
                    case 3:
                        #region Unknown Flight
                        // 3:  Single BSM of specific LP# is in the [BAG_SORTING] table, but the flight included 
                        //     in the BSM can not be found in the [FLIGHT_PLAN_SORTING] table, it is Unknown flight.
                        //     [AIRLINE],[FLIGHT_NUMBER],[SDO] three fields will be returned caller
                        //     via returned recordset.
                        reason = ClassParameters.SortReasonUNFL;  // Sorted by Unknown flight

                        // Get the destination of Unknown flight function allocation type (UNFL)
                        GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationUNFL,
                                    currentLocation, ref destinations, mesLocation, tts);

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP +
                                    ", Master FLT:" + airline + flightNo + "_" +
                                    sdo.Day.ToString() + "/" + sdo.Month.ToString() + "/" + sdo.Year.ToString() +
                                    "] Unknown Flight (" + ClassParameters.FuncAllocationUNFL +
                                    "). Its destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        #endregion
                        break;
                    case 4:
                        #region Master Flight Unknown
                        // 4:  Flight is Slave filght, but its master flight can not be found in the 
                        //     [FLIGHT_PLAN_SORTING] table, it is treated as Unknown flight.
                        //     [AIRLINE],[FLIGHT_NUMBER],[SDO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
                        //     five fields will be returned caller via returned recordset.
                        reason = ClassParameters.SortReasonUNFL;  // Sorted by Unknown flight

                        // Get the destination of Unknown flight function allocation type (UNFL)
                        GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationUNFL,
                                    currentLocation, ref destinations, mesLocation, tts);

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP +
                                    ", Slave FLT:" + airline + flightNo +
                                    ", Master FLT:" + masterAirline + masterFlightNo + "_" +
                                    sdo.Day.ToString() + "/" + sdo.Month.ToString() + "/" + sdo.Year.ToString() +
                                    "] Unknown Flight (" + ClassParameters.FuncAllocationUNFL +
                                    "). Its destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        #endregion
                        break;
                    case 5:
                        #region No Flight Allocation
                        // 5: (Flight is Master flight and its flight info can be found in the 
                        //     [FLIGHT_PLAN_SORTING] table. But it has no any allocation was created 
                        //     (no allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). It is 
                        //     treated as No Allocation Flight.
                        //     [AIRLINE],[FLIGHT_NUMBER],[SDO],{STO] four fields will be returned caller
                        //     via returned recordset.
                        reason = ClassParameters.SortReasonNOAL;  // Sorted by Flight No Allocation

                        // Get the destination of Flight No Allocation function allocation type (NOAL)
                        GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationNOAL,
                                    currentLocation, ref destinations, mesLocation, tts);

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP +
                                    ", Master FLT:" + airline + flightNo + "_" +
                                    sdo.Day.ToString() + "/" + sdo.Month.ToString() + "/" + sdo.Year.ToString() +
                                    "] Flight has No Allocation (" + ClassParameters.FuncAllocationNOAL +
                                    "). Its destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        #endregion
                        break;
                    case 6:
                        #region Mastar Flight No Allocation
                        // 6: (Flight is Slave flight, its master flight is valid flight (flight 
                        //     info can be found in the [FLIGHT_PLAN_SORTING] table). But it has 
                        //     no any allocation was created (no allocation recoreds in the table 
                        //     [FLIGHT_PLAN_ALLOC]). It is treated as No Allocation Flight.
                        //     [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
                        //     six fields will be returned caller via returned recordset.
                        reason = ClassParameters.SortReasonNOAL;  // Sorted by Flight No Allocation

                        // Get the destination of Flight No Allocation function allocation type (NOAL)
                        GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationNOAL,
                                    currentLocation, ref destinations, mesLocation, tts);

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP +
                                    ", Slave FLT:" + airline + flightNo +
                                    ", Master FLT:" + masterAirline + masterFlightNo + "_" +
                                    sdo.Day.ToString() + "/" + sdo.Month.ToString() + "/" + sdo.Year.ToString() +
                                    "] Flight has No Allocation (" + ClassParameters.FuncAllocationNOAL +
                                    "). Its destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        #endregion
                        break;
                    case 7:
                    case 8:
                        #region Master Flight W Allocation
                        //  7: (Flight is Master flight. Its flight info can be found in the 
                        //     [FLIGHT_PLAN_SORTING] table. And its allocation has been created 
                        //     (has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
                        //     [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[IDO],[ITO],
                        //     [ADO],[ATO],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],[ERLY_OPEN_OFFSET],
                        //     [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
                        //     [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
                        //     21 fields will be returned to caller via returned recordset.
                        //  8: (Flight is Slave flight. its master flight is valid flight 
                        //     (flight info can be found in the [FLIGHT_PLAN_SORTING] table). 
                        //     And its master flight allocation has been created 
                        //     (has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
                        //     [AIRLINE],[FLIGHT_NUMBER],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
                        //     [SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],
                        //     [ERLY_OPEN_OFFSET],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
                        //     [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
                        //     [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
                        //     23 fields will be returned to caller via returned recordset.

                        //As for this project, all the bags are clear in the sortation line, hence it just directly sort as follow the sortation rules
                        //Flight exception with "RISK" will sort as in the departure allocation assigned destination
                        //The Flight Exception and Bag Exception are for the IATA tag which has flight information and BSM.
                        //Step 1: Check wheather it has Flight Exception or not
                        //         Yes - follow Flight Exception destination
                        //         No - mean no destination return, will continue with Bag Exception Check
                        //Step 2: Check wheather it has Bag Exception or not
                        //         Yes - follow Bag Exception destination
                        //         No - mean no destination return, will continue with normal flight destination

                        // If FLT_Exception not equal to nothing mean it has flight exception
                        // Get the flight exception destination
                        if (flightException != string.Empty)
                        {
                            GetDestinationOfFEXC(channelName, gid, currentLocation, ref reason, ref destinations, flightException, tts);

                            if (destinations == null)
                            {
                                // If Flight Exception has no allocated destination, then continue with next step - Bag Exception.
                                // Do Nothing
                            }
                            else
                            {
                                break;
                            }
                        }

                        string bagType = string.Empty;
                        string passengerDestination = string.Empty;
                        string passengerTravelClass = string.Empty;
                        string onwardTransferStatus = string.Empty;
                        List<AllocationProperty> filteredAllocation = new List<AllocationProperty>();

                        if (validTag.Type == TagType.IATATag)
                        {
                            // Get Bag Information - Bag Type, Passenger Destination, Passenger Travel Class, OnwardTransfer status
                            GetBagInformation(validTag.LP, ref bagType, ref passengerDestination, ref passengerTravelClass, ref onwardTransferStatus);

                            // Filter out based on sorting criteria (Bag Type, Passenger Destination, Passenger Travel Class, Onward Transfer Status). 
                            // If the allocation sorting criteria is not same as bag sorting criteria or allocation sorting criteria is not wildcard(*),
                            // it will filter out.
                            for (int i = 0; i < allocations.Length; i++)
                            {
                                if (((allocations[i].BagType == bagType) | (allocations[i].BagType == ClassParameters.Wildcard)) &
                                    ((allocations[i].PassengerDestination == passengerDestination) | (allocations[i].PassengerDestination == ClassParameters.Wildcard)) &
                                    ((allocations[i].TravelClass == passengerTravelClass) | (allocations[i].TravelClass == ClassParameters.Wildcard)) &
                                    ((allocations[i].OnwardTransfer == onwardTransferStatus) | (allocations[i].OnwardTransfer == ClassParameters.Wildcard)))
                                {
                                    filteredAllocation.Add(allocations[i]);
                                }
                            }
                        }
                        else // In-house
                        {
                            // Filter out based on sorting criteria (Bag Type, Passenger Destination, Passenger Travel Class, Onward Transfer Status). 
                            // If the allocation sorting criteria is not wildcard(*), it will filter out.
                            // For in-house tag, the allocation based on all sorting criteria as wildcard(*).
                            for (int i = 0; i < allocations.Length; i++)
                            {
                                if ((allocations[i].BagType == ClassParameters.Wildcard) & (allocations[i].PassengerDestination == ClassParameters.Wildcard) &
                                    (allocations[i].TravelClass == ClassParameters.Wildcard) & (allocations[i].OnwardTransfer == ClassParameters.Wildcard))
                                {
                                    filteredAllocation.Add(allocations[i]);
                                }
                            }
                        }

                        // if filteredAllocation.count is 0, mean No Allocation

                        if ((filteredAllocation.Count == 0) | (filteredAllocation == null))
                        {
                            reason = ClassParameters.SortReasonNOAL;  // Sorted by Flight No Allocation

                            // Get the destination of Flight No Allocation function allocation type (NOAL)
                            GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationNOAL,
                                        currentLocation, ref destinations, mesLocation, tts);

                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP +
                                        ", Slave FLT:" + airline + flightNo +
                                        ", Master FLT:" + masterAirline + masterFlightNo + "_" +
                                        sdo.Day.ToString() + "/" + sdo.Month.ToString() + "/" + sdo.Year.ToString() +
                                        "] No any criteria meet. Common Flight Allocation cannot be found, it will sort as No Allocation (" +
                                        ClassParameters.FuncAllocationNOAL +
                                        "). Its destination: (" +
                                        Utilities.LocationIDArrayToString(ref destinations) +
                                        "). <" + thisMethod + ">");

                            break;
                        }

                        AllocationProperty[] originalAllocatons = allocations;

                        List<AllocationProperty> sortedAllocations = new List<AllocationProperty>();
                        // Get Priority of the allocations
                        List<AllocationProperty> priorityAllocations = new List<AllocationProperty>();
                        int currentPriority = 0;
                        List<AllocationProperty[]> allPriorityAllocations = new List<AllocationProperty[]>();

                        priorityAllocations = GetPriorityOfFlightAllocation(filteredAllocation, ref allocations,
                                ref currentPriority, ref allPriorityAllocations);

                        for (int j = 0; j < allPriorityAllocations.Count; j++)
                        {
                            // Check FilteredAllocation are all in wildcard, if not need to check the highest priority allocation avaiable or not
                            // If avaiable same as previous value
                            // If unavailable, get second priority allocation and it is all common, it will continue
                            int sumUnavailable = 0;
                            bool isCommonFlightAllocation = false;
                            AllocationProperty[] tempAllocation = allPriorityAllocations[j];

                            for (int i = 0; i < tempAllocation.Length; i++)
                            {
                                if ((tempAllocation[i].BagType == ClassParameters.Wildcard) & (tempAllocation[i].PassengerDestination == ClassParameters.Wildcard) &
                                    (tempAllocation[i].TravelClass == ClassParameters.Wildcard) & (tempAllocation[i].OnwardTransfer == ClassParameters.Wildcard))
                                {
                                    // As same priority will have same condition, all wildcard, all allocation will have wildcard
                                    isCommonFlightAllocation = true;
                                    break;
                                }
                                else
                                {
                                    // Check destination allocations availablity 
                                    LocationID temp = new LocationID();
                                    temp.Subsystem = tempAllocation[i].SubSystem;
                                    temp.Location = tempAllocation[i].Resource;

                                    if (ChuteAvailableCheck(temp) == false)
                                    {
                                        if (_logger.IsErrorEnabled)
                                            _logger.Error("[Channel:" + channelName +
                                                        "] [GID:" + gid +
                                                        "] with destination: [" + tempAllocation[i].Resource +
                                                        "] Bag Type: " + tempAllocation[i].BagType +
                                                        ", Flight Destination: " + tempAllocation[i].PassengerDestination +
                                                        ", Passenger Class: " + tempAllocation[i].TravelClass +
                                                        ", Onward Transfer: " + tempAllocation[i].OnwardTransfer +
                                                        " is unvailable.< <" + thisMethod + ">");

                                        sumUnavailable = sumUnavailable + 1;
                                    }

                                    isCommonFlightAllocation = false;
                                }
                            }

                            if ((isCommonFlightAllocation == false) & (sumUnavailable == tempAllocation.Length))
                            {
                                // All Allocation Unavailable, take second priority if it is not common flight allocation

                                if (_logger.IsErrorEnabled)
                                    _logger.Error("[Channel:" + channelName +
                                                "] [GID:" + gid +
                                                "] All same criteria flight allocation unavailable. " +
                                                "Next Common Flight Allocation will be used. < <" + thisMethod + ">");

                            }
                            else
                            {
                                allocations = tempAllocation;
                                break;
                            }
                        }
                        #endregion
                        LocationID[] tempLocationID = null;
                        bool isFunction, isMES;

                        LookupAllocatedDestination(status, channelName, gid, validTag, currentLocation,
                                                      bsmTravelClass, ref allocations, ref reason, ref tempLocationID, out isFunction, out isMES, tts, originalAllocatons);

                        string scheme = SortSchemeFlightAlloc;

                        if ((isFunction == false) & (isMES == false))
                        {
                            scheme = SortSchemeFlightAlloc;
                        }
                        else if ((isFunction == true) & (isMES == false))
                        {
                            scheme = SortSchemeFuncAlloc;
                        }
                        else if ((isMES == true) & (ClassParameters.TTSSorter01 == tts))
                        {
                            scheme = SortSchemeTTS1Alloc;
                        }
                        else if ((isMES == true) & (ClassParameters.TTSSorter02 == tts))
                        {
                            scheme = SortSchemeTTS2Alloc;
                        }


                        if (tempLocationID != null)
                        {
                            if (tempLocationID.Length > 1)
                            {
                                //if (scheme == SortSchemeFlightAlloc)
                                //{
                                //    string flightIdentifier = string.Empty;
                                //    flightIdentifier = airline + flightNo + "_" + masterAirline + masterFlightNo + "_" + sdo.ToString();

                                //    //// Re-order destination according to defined sortation scheme for this flight.
                                //    //destinations = ReOrderDestinationSequence(ref reason, channelName, gid, currentLocation, ref tempLocationID,
                                //    //                            SortSchemeFlightAlloc, flightIdentifier, false, false, tts);
                                //}
                                //else
                                //{
                                    destinations = tempLocationID;
                                //}

                                if (status == 7)
                                {
                                    if (_logger.IsInfoEnabled)
                                        _logger.Info("[Channel:" + channelName +
                                                "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                                ", Master FLT:" + allocations[0].Airline + allocations[0].FlightNumber + "_" +
                                                allocations[0].STD.ToString() +
                                                "] After reorder multiple destinations by Sortation Scheme " +
                                                scheme + " - (" +
                                                Utilities.LocationIDArrayToString(ref destinations) +
                                                "). <" + thisMethod + ">");
                                }
                                else
                                {
                                    if (_logger.IsInfoEnabled)
                                        _logger.Info("[Channel:" + channelName +
                                                "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                                ", Slave FLT:" + allocations[0].Airline + allocations[0].FlightNumber +
                                                ", Master FLT:" + allocations[0].MasterAirline + allocations[0].MasterFlightNumber + "_" +
                                                allocations[0].STD.ToString() +
                                                "] After reorder multiple destinations by Sortation Scheme " +
                                                scheme + " - (" +
                                                Utilities.LocationIDArrayToString(ref destinations) +
                                                "). <" + thisMethod + ">");
                                }
                            }
                            else
                            {
                                //if (scheme == SortSchemeFlightAlloc)
                                //{
                                //    destinations = ReOrderDestinationSequence(ref reason, channelName, gid, currentLocation, ref tempLocationID,
                                //        SortSchemeFlightAlloc, string.Empty, false, false, tts);
                                //}
                                //else
                                //{
                                    destinations = tempLocationID;
                                //}
                            }
                        }
                        else
                        {
                            reason = ClassParameters.SortReasonNOAL;  // Sorted by Flight No Allocation

                            // Get the destination of Flight No Allocation function allocation type (NOAL)
                            GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationNOAL,
                                        currentLocation, ref destinations, mesLocation, tts);

                            if (status == 7)
                            {
                                if (_logger.IsInfoEnabled)
                                    _logger.Info("[Channel:" + channelName +
                                            "][GID:" + gid + ", LP:" + validTag.LP +
                                            ", Master FLT:" + airline + flightNo + "_" +
                                            sdo.Day.ToString() + "/" + sdo.Month.ToString() + "/" + sdo.Year.ToString() +
                                            "] No any Flight Allocation is available, it will sort as No Allocation (" +
                                            ClassParameters.FuncAllocationNOAL +
                                            "). Its destination: (" +
                                            Utilities.LocationIDArrayToString(ref destinations) +
                                            "). <" + thisMethod + ">");
                            }
                            else
                            {
                                if (_logger.IsInfoEnabled)
                                    _logger.Info("[Channel:" + channelName +
                                            "] [GID:" + gid + ", LP:" + validTag.LP +
                                            ", Slave FLT:" + airline + flightNo +
                                            ", Master FLT:" + masterAirline + masterFlightNo + "_" +
                                            sdo.Day.ToString() + "/" + sdo.Month.ToString() + "/" + sdo.Year.ToString() +
                                            "] No any Flight Allocation is available, it will sort as No Allocation (" +
                                            ClassParameters.FuncAllocationNOAL +
                                            "). Its destination: (" +
                                            Utilities.LocationIDArrayToString(ref destinations) +
                                            "). <" + thisMethod + ">");
                            } 
                        }

                        break;
                    case 9:
                        #region LLC Opeational Mode
                        // 1:  LLC operational mode is enabled, it will follow airline sortation;

                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP +
                                        "] LLC operational mode is enabled, item will be sorted by Airline Allocation. <" + thisMethod + ">");

                            if (validTag.AirlineCode == string.Empty)
                            {
                                // If no airline code is extracted from LP, then handle it as NBSM bag.
                                GetDestinationOfNBSM(channelName, gid, validTag.LP, currentLocation, ref reason, ref destinations, tts);
                            }
                            else
                            {
                                GetDestinationOfAirline(channelName, gid, validTag.AirlineCode, currentLocation, ref reason, ref destinations, tts);

                                if (destinations == null)
                                {
                                    // If Airline has no allocated destination, then handle it as NBSM bag.
                                    if (_logger.IsInfoEnabled)
                                        _logger.Info("[Channel:" + channelName +
                                                "] [GID:" + gid + ", LP:" + validTag.LP +
                                                ", Airline:" + validTag.AirlineCode +
                                                "] Airline has no allocated destination. It will be sorted as NBSM bag. <" + thisMethod + ">");

                                    GetDestinationOfNBSM(channelName, gid, validTag.LP, currentLocation, ref reason, ref destinations, tts);
                                }
                                else
                                {
                                    if (_logger.IsInfoEnabled)
                                        _logger.Info("[Channel:" + channelName +
                                                "] [GID:" + gid + ", LP:" + validTag.LP +
                                                ", Airline:" + validTag.AirlineCode +
                                                "] Airline allocated destination: (" +
                                                Utilities.LocationIDArrayToString(ref destinations) +
                                                "). <" + thisMethod + ">");
                                }
                            }

                        #endregion
                        break;
                    case -1:
                        // -1: System Exception Occurs. Get flight allocation destination failure.
                        if (_logger.IsErrorEnabled)
                            _logger.Error("[Channel:" + channelName +
                                    "] System error, no destination is found for LP(" +
                                    validTag.LP + "). <" + thisMethod + ">");

                        break;
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination From Scanned Tag failure! <" + thisMethod + ">", ex);

                destinations = null;
            }
        }

        /// <summary>
        /// Get Sorted Dest Of Function Allocation
        /// </summary>
        /// <param name="reason"></param>
        /// <param name="gid"></param>
        /// <param name="channelName"></param>
        /// <param name="functionType"></param>
        /// <param name="currentLocation"></param>
        /// <param name="destinations"></param>
        /// <param name="alternatives"></param>
        /// <param name="tts"></param>
        public void GetSortedDestOfFunctionAllocation(ref string reason, string gid, string channelName,
                string functionType, LocationID currentLocation, ref LocationID[] destinations, LocationID[] alternatives,
                string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            bool isMES = false;

            // 1. Query destination and its Subsystem of given Function Allocation 
            //    type from table [FUNCTION_ALLOC_GANTT], [FUNCTION_ALLOC_LIST]
            LocationID[] temp = GetDestinationOfFunctionAllocation(functionType, string.Empty, ref isMES, tts);

            // 2. If invalid destination (Nothing is returned) of given function  
            //    allocation type is returned, assign pre-set alternative destination
            //    to it.
            if ((temp == null) | (temp.Length == 0))
            {
                temp = alternatives;
                isMES = true;

                if (_logger.IsWarnEnabled)
                    _logger.Warn("[Channel:" + channelName +
                            "] There is no destination was defined for " +
                            "Function Allocation (" + functionType +
                            ")! The pre-set destination will be assigned to it. <" + thisMethod + ">");
            }

            //// 3. Re-order destination according to function allocation sortation 
            ////    scheme (nearest first algorithm);
            //destinations = ReOrderDestinationSequence(ref reason, channelName, gid,
            //                currentLocation, ref temp, SortSchemeFuncAlloc, functionType, false, isMES, tts);
            destinations = temp;
        }

        /// <summary>
        /// Get allocated destinations of NORD (No Read) function allocation.
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfNORD(string channelName, string gid, LocationID currentLocation, ref string reason,
                ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] mesLocation = null;

            if (tts == TTS01_SUBSYSTEM)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
            }

            try
            {
                // Sorted by No Read.
                reason = ClassParameters.SortReasonNORD;

                // Get the destination of NORD (No Read) function allocation type 
                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationNORD,
                            currentLocation, ref destinations, mesLocation, tts);

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid +
                            "] is " + ClassParameters.FuncAllocationNORD +
                            " item. Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "] . <" + thisMethod + ">");

            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of NORD is failure! <" + thisMethod + ">", ex);

                destinations = mesLocation;
            }
        }

        /// <summary>
        /// Get allocated destinations of MTLP (Multiple LP) function allocation.
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="licensePlate"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfMTLP(string channelName, string gid, string licensePlate,
                LocationID currentLocation, ref string reason, ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] mesLocation = null;

            if (tts == TTS01_SUBSYSTEM)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
            }

            try
            {
                // Sorted by Multiple LP
                reason = ClassParameters.SortReasonMTLP;

                // Get the destination of BMLP (Multiple LP) function allocation type 
                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationMTLP,
                            currentLocation, ref destinations, mesLocation, tts);

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid + ", LP:" + licensePlate +
                            "] is valid (or both invalid) LPs. " +
                            "Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "] . <" + thisMethod + ">");

            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of MTLP is failure! <" + thisMethod + ">", ex);

                //if (tts == "TTS01")
                //{
                //    destinations = ClassParameters.TTS01MESLocation;
                //}
                //else
                //{
                //    destinations = ClassParameters.TTS02MESLocation;
                //}
                destinations = mesLocation;
            }
        }

        /// <summary>
        /// Get allocated destinations of IATA Fallback allocation.
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="bagTag"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfIATAFallbackTag(string channelName, string gid, Tag bagTag, LocationID currentLocation,
                ref string reason, ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlDataReader reader = null;
            List<LocationID> locations = new List<LocationID>();
            LocationID dest;

            try
            {
                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }

                // Sorted by Fallback Tag
                reason = ClassParameters.SortReasonIATAFallback;

                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetIATAFallbackTagDischarged, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@ID", SqlDbType.VarChar, 2);
                sqlCmd.Parameters["@ID"].Value = bagTag.DestinationTagCode;

                sqlCmd.Parameters.Add("@Subsystem", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@Subsystem"].Value = tts;

                sqlConn.Open();
                reader = sqlCmd.ExecuteReader();

                while (reader.Read())
                {
                    dest = new LocationID();

                    if (reader[ClassParameters.ColumnDestination] != DBNull.Value)
                    {
                        dest.Location = reader[ClassParameters.ColumnDestination].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                    {
                        dest.Subsystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                    }

                    locations.Add(dest);
                }

                destinations = locations.ToArray();

                // If no destination is returned from database for specific Fallback Tag destination, 
                // then assign pre-set alternative destination (MES) to it;

                if (destinations == null)
                {
                    if (tts == TTS01_SUBSYSTEM)
                    {
                        destinations = ClassParameters.TTS01MESLocation;
                    }
                    else
                    {
                        destinations = ClassParameters.TTS02MESLocation;
                    }

                    if (_logger.IsWarnEnabled)
                        _logger.Warn("[Channel:" + channelName +
                                "] There is no destination was defined for " +
                                "Fallback Tag Discharge Indicator (" +
                                bagTag.Discharged +
                                ")! It will be sorted to MES. <" + thisMethod + ">");
                }

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid + ", LP:" + bagTag.LP +
                            "] is Fallback Tag. Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "]. <" + thisMethod + ">");

            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of IATA Fallback Tag from database failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of IATA Fallback Tag from database failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (reader != null) reader.Close();
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Get Destination Of Four Digits Fallback Tag
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="bagTag"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfFourDigitsFallbackTag(string channelName, string gid, Tag bagTag, LocationID currentLocation,
                ref string reason, ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlDataReader reader = null;
            List<LocationID> locations = new List<LocationID>();
            LocationID dest;

            try
            {
                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }
                // Sorted by Four Digits Fallback Tag
                reason = ClassParameters.SortReasonFourDigitsFallback;

                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetFourDigitsFallbackTagDischarge, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@ID", SqlDbType.VarChar, 4);
                sqlCmd.Parameters["@ID"].Value = bagTag.DestinationTagCode;

                sqlCmd.Parameters.Add("@Subsystem", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@Subsystem"].Value = tts;

                sqlConn.Open();
                reader = sqlCmd.ExecuteReader();

                while (reader.Read())
                {
                    dest = new LocationID();

                    if (reader[ClassParameters.ColumnDestination] != DBNull.Value)
                    {
                        dest.Location = reader[ClassParameters.ColumnDestination].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                    {
                        dest.Subsystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                    }

                    locations.Add(dest);
                }

                destinations = locations.ToArray();

                // If no destination is returned from database for specific Fallback Tag destination, 
                // then assign pre-set alternative destination (MES) to it;

                if (destinations == null)
                {
                    if (tts == TTS01_SUBSYSTEM)
                    {
                        destinations = ClassParameters.TTS01MESLocation;
                    }
                    else
                    {
                        destinations = ClassParameters.TTS02MESLocation;
                    }

                    if (_logger.IsWarnEnabled)
                        _logger.Warn("[Channel:" + channelName +
                                "] There is no destination was defined for " +
                                "Four Digits Fallback Tag Discharge Indicator (" +
                                bagTag.Discharged +
                                ")! It will be sorted to MES. <" + thisMethod + ">");
                }

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid + ", LP:" + bagTag.LP +
                            "] is Four Digits Fallback Tag. Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "]. <" + thisMethod + ">");

            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of Four Digits Fallback Tag from database failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of Four Digits Fallback Tag from database failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (reader != null) reader.Close();
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Get Destination Of Four Digits Security Tag
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="bagTag"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfFourDigitsSecurityTag(string channelName, string gid, Tag bagTag, LocationID currentLocation,
                ref string reason, ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlDataReader reader = null;
            List<LocationID> locations = new List<LocationID>();
            LocationID dest;

            try
            {
                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }
                // Sorted by Four Digits Security Tag
                reason = ClassParameters.SortReasonFourDigitsSecurity;

                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetFourDigitsSecurityTagDischarge, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@ID", SqlDbType.VarChar, 2);
                sqlCmd.Parameters["@ID"].Value = bagTag.DestinationTagCode;

                sqlCmd.Parameters.Add("@Subsystem", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@Subsystem"].Value = tts;

                sqlConn.Open();
                reader = sqlCmd.ExecuteReader();

                while (reader.Read())
                {
                    dest = new LocationID();

                    if (reader[ClassParameters.ColumnDestination] != DBNull.Value)
                    {
                        dest.Location = reader[ClassParameters.ColumnDestination].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                    {
                        dest.Subsystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                    }

                    locations.Add(dest);
                }

                destinations = locations.ToArray();

                // If no destination is returned from database for specific Fallback Tag destination, 
                // then assign pre-set alternative destination (MES) to it;

                if (destinations == null)
                {
                    if (tts == TTS01_SUBSYSTEM)
                    {
                        destinations = ClassParameters.TTS01MESLocation;
                    }
                    else
                    {
                        destinations = ClassParameters.TTS02MESLocation;
                    }

                    if (_logger.IsWarnEnabled)
                        _logger.Warn("[Channel:" + channelName +
                                "] There is no destination was defined for " +
                                "Four Digits Security Tag Discharge Indicator (" +
                                bagTag.Discharged +
                                ")! It will be sorted to MES. <" + thisMethod + ">");
                }

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid + ", LP:" + bagTag.LP +
                            "] is Four Digits Security Tag. Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "]. <" + thisMethod + ">");

            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of Four Digits Security Tag from database failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of Four Digits Security Tag from database failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (reader != null) reader.Close();
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// 1:  No BSM of specific LP# is in the [BAG_SORTING] table, it is No BSM (NBSM) item;
        /// 2:  More than one BSMs of specific LP# are in the [BAG_SORTING] table, it is multiple 
        ///     BSM (MBSM) item;
        /// 3:  Single BSM of specific LP# is in the [BAG_SORTING] table, but the flight included 
        ///     in the BSM can not be found in the [FLIGHT_PLAN_SORTING] table, it is Unknown flight.
        ///     [AIRLINE],[FLIGHT_NUMBER],[ADO] three fields will be returned caller
        ///     via returned recordset.
        /// 4:  Flight is Slave filght, but its master flight can not be found in the 
        ///     [FLIGHT_PLAN_SORTING] table, it is treated as Unknown flight.
        ///     [AIRLINE],[FLIGHT_NUMBER],[ADO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
        ///     five fields will be returned caller via returned recordset.
        /// 5: (Flight is Master flight and its flight info can be found in the 
        ///     [FLIGHT_PLAN_SORTING] table. But it has no any allocation was created 
        ///     (no allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). It is 
        ///     treated as No Allocation Flight.
        ///     [AIRLINE],[FLIGHT_NUMBER],[ADO],[STO] four fields will be returned caller
        ///     via returned recordset.
        /// 6: (Flight is Slave flight, its master flight is valid flight (flight 
        ///     info can be found in the [FLIGHT_PLAN_SORTING] table). But it has 
        ///     no any allocation was created (no allocation recoreds in the table 
        ///     [FLIGHT_PLAN_ALLOC]). It is treated as No Allocation Flight.
        ///     [AIRLINE],[FLIGHT_NUMBER],[ADO],[STO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
        ///     six fields will be returned caller via returned recordset.
        /// 7: (Flight is Master flight. Its flight info can be found in the [FLIGHT_PLAN_SORTING] table. 
        ///     And its allocation has been created (has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
        ///     Following 24 fields will be returned to caller via returned recordset:
        ///     [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],[ERLY_OPEN_OFFSET],
        ///     [ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],[ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],
        ///     [RUSH_DURATION],[IS_MANUAL_CLOSE],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM],
        ///     [BAG_TYPE],[PASSENGER_DESTINATION],[TRANSFER]
        /// 8: (Flight is Slave flight. its master flight is valid flight (flight info can be found in 
        ///     the [FLIGHT_PLAN_SORTING] table). And its master flight allocation has been created 
        ///     (has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
        ///     Following 26 fields will be returned to caller via returned recordset:
        ///     [AIRLINE],[FLIGHT_NUMBER],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
        ///     [SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],
        ///     [ERLY_OPEN_OFFSET],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
        ///     [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
        ///     [IS_MANUAL_CLOSE],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM],
        ///     [BAG_TYPE],[PASSENGER_DESTINATION],[TRANSFER]
        /// -1: System Exception Occurs. Get flight allocation destination failure.
        /// </summary>
        /// <param name="licensePlate"></param>
        /// <param name="airline"></param>
        /// <param name="flightNo"></param>
        /// <param name="masterAirline"></param>
        /// <param name="masterFlightNo"></param>
        /// <param name="sdo"></param>
        /// <param name="sto"></param>
        /// <param name="bsmTravelClass"></param>
        /// <param name="bsmException"></param>
        /// <param name="flightHighRisk"></param>
        /// <param name="flightException"></param>
        /// <param name="allocations"></param>
        /// <param name="tts"></param>
        /// <returns></returns>
        public int GetAllocationInfoFromIATATag(string licensePlate, ref string airline, ref string flightNo,
                ref string masterAirline, ref string masterFlightNo, ref DateTime sdo, ref string sto,
                ref string bsmTravelClass, ref string bsmException, ref string flightHighRisk, ref string flightException,
                ref AllocationProperty[] allocations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlDataReader reader = null;
            int status;
            List<AllocationProperty> tempAllocation = new List<AllocationProperty>();
            AllocationProperty alloc;
            DateTime date = new DateTime();
            string time = string.Empty;

            try
            {
                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }
                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetFlightAllocationOfLP, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@LicensePlate", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@LicensePlate"].Value = licensePlate;

                sqlCmd.Parameters.Add("@Sorter", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@Sorter"].Value = tts;

                sqlCmd.Parameters.Add("@BSM_TravelClass", SqlDbType.VarChar, 1);
                sqlCmd.Parameters["@BSM_TravelClass"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@BSM_Exception", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@BSM_Exception"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@FLT_HighRisk", SqlDbType.VarChar, 1);
                sqlCmd.Parameters["@FLT_HighRisk"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@FLT_Exception", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@FLT_Exception"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@Status", SqlDbType.Int);
                sqlCmd.Parameters["@Status"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                reader = sqlCmd.ExecuteReader();

                while (reader.Read())
                {
                    if (reader[ClassParameters.ColumnAirline] != DBNull.Value)
                    {
                        airline = reader[ClassParameters.ColumnAirline].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnFlightNo] != DBNull.Value)
                    {
                        flightNo = reader[ClassParameters.ColumnFlightNo].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnSDO] != DBNull.Value)
                    {
                        sdo = Convert.ToDateTime(reader[ClassParameters.ColumnSDO].ToString().Trim());
                    }

                    switch (reader.FieldCount)
                    {
                        case 3:
                            // @Status = 3 (Single BSM of specific LP# is in the [BAG_SORTING] table, but the flight included 
                            //				in the BSM can not be found in the [FLIGHT_PLAN_SORTING] table, it is Unknown flight.
                            //				[AIRLINE],[FLIGHT_NUMBER],[SDO] three fields will be returned caller
                            //				via returned recordset.
                            break;
                        case 4:
                            // @Status = 5 (Flight is Master flight and its flight info can be found in the 
                            //              [FLIGHT_PLAN_SORTING] table. But it has no any allocation was created 
                            //				(no allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). It is 
                            //              treated as No Allocation Flight.
                            //				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO] four fields will be returned caller
                            //				via returned recordset.
                            if (reader[ClassParameters.ColumnSTO] != DBNull.Value)
                            {
                                sto = reader[ClassParameters.ColumnSTO].ToString().Trim();
                            }

                            break;
                        case 5:
                            // @Status = 4 (Flight is Slave filght, but its master flight can not be found in the
                            //				[FLIGHT_PLAN_SORTING] table, it is treated as Unknown flight.
                            //				[AIRLINE],[FLIGHT_NUMBER],[SDO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
                            //				five fields will be returned caller via returned recordset.
                            if (reader[ClassParameters.ColumnMasterAirline] != DBNull.Value)
                            {
                                masterAirline = reader[ClassParameters.ColumnMasterAirline].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnMasterFlightNo] != DBNull.Value)
                            {
                                masterFlightNo = reader[ClassParameters.ColumnMasterFlightNo].ToString().Trim();
                            }

                            break;
                        case 6:
                            // @Status = 6 (Flight is Slave flight, its master flight is valid flight (flight 
                            //				info can be found in the [FLIGHT_PLAN_SORTING] table). But it has 
                            //				no any allocation was created (no allocation recoreds in the table 
                            //				[FLIGHT_PLAN_ALLOC]). It is treated as No Allocation Flight.
                            //				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
                            //				six fields will be returned caller via returned recordset.
                            if (reader[ClassParameters.ColumnSTO] != DBNull.Value)
                            {
                                sto = reader[ClassParameters.ColumnSTO].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnMasterAirline] != DBNull.Value)
                            {
                                masterAirline = reader[ClassParameters.ColumnMasterAirline].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnMasterFlightNo] != DBNull.Value)
                            {
                                masterFlightNo = reader[ClassParameters.ColumnMasterFlightNo].ToString().Trim();
                            }

                            break;

                        case 24:
                            // @Status = 7 (Flight is Master flight. Its flight info can be found in the 
                            //              [FLIGHT_PLAN_SORTING] table. And its allocation has been created 
                            //				(has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
                            //				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[IDO],[ITO],
                            //              [ADO],[ATO],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
                            //              [ERLY_OPEN_OFFSET],[RUSH_DURATION],
                            //              [RUSH_OPEN_OFFSET],[RUSH_CLOSE_RELATED],[ALLOC_RUSH_RELATED],
                            //              [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
                            //              [BAG_TYPE],[PASSENGER_DESTINATION],[TRANSFER]
                            //				24 fields will be returned to caller via returned recordset.
                            alloc = new AllocationProperty(AllocationType.FlightAllocation, ClassParameters.RelatedNameSTD,
                                    ClassParameters.RelatedNameETD);

                            //date = new DateTime ();
                            time = string.Empty;

                            alloc.Airline = airline;
                            alloc.FlightNumber = flightNo;
                            alloc.SDO = sdo;

                            if (reader[ClassParameters.ColumnSTO] != DBNull.Value)
                            {
                                sto = reader[ClassParameters.ColumnSTO].ToString().Trim();
                            }

                            alloc.STO = sto;

                            if (reader[ClassParameters.ColumnEDO] != DBNull.Value)
                            {
                                date = Convert.ToDateTime(reader[ClassParameters.ColumnEDO].ToString().Trim());
                                alloc.NullEDO = false;
                            }
                            else
                            {
                                alloc.NullEDO = true;
                            }

                            if (alloc.NullEDO == true)
                            {
                                alloc.EDO = sdo;
                            }
                            else
                            {
                                alloc.EDO = date;
                            }

                            if (reader[ClassParameters.ColumnETO] != DBNull.Value)
                            {
                                time = reader[ClassParameters.ColumnETO].ToString().Trim();
                                alloc.NullEDO = false;
                            }
                            else
                            {
                                alloc.NullEDO = true;
                            }

                            if (time == string.Empty)
                            {
                                alloc.ETO = sto;
                            }
                            else
                            {
                                alloc.ETO = time;
                            }

                            //date = new DateTime();
                            //time = string.Empty;

                            //if (reader[ClassParameters.ColumnIDO] != DBNull.Value)
                            //{
                            //    date = Convert.ToDateTime(reader[ClassParameters.ColumnIDO].ToString().Trim());
                            //}

                            //if (date == null)
                            //{
                            //    alloc.IDO = sdo;
                            //}
                            //else
                            //{
                            //    alloc.IDO = date;
                            //}

                            //if (reader[ClassParameters.ColumnITO] != DBNull.Value)
                            //{
                            //    time = reader[ClassParameters.ColumnITO].ToString().Trim();
                            //}

                            //if (time == string.Empty)
                            //{
                            //    alloc.ITO = sto;
                            //}
                            //else
                            //{
                            //    alloc.ITO = time;
                            //}

                            date = new DateTime();
                            time = string.Empty;

                            if (reader[ClassParameters.ColumnADO] != DBNull.Value)
                            {
                                date = Convert.ToDateTime(reader[ClassParameters.ColumnADO].ToString().Trim());
                                alloc.NullADO = false;
                            }
                            else
                            {
                                alloc.NullADO = true;
                            }

                            if (alloc.NullADO == false)
                            {
                                alloc.ADO = date;
                            }

                            if (reader[ClassParameters.ColumnATO] != DBNull.Value)
                            {
                                time = reader[ClassParameters.ColumnATO].ToString().Trim();
                                alloc.NullADO = false;
                            }
                            else
                            {
                                alloc.NullADO = true;
                            }

                            if (time == string.Empty)
                            {
                                alloc.ATO = string.Empty;
                            }
                            else
                            {
                                alloc.ATO = time;
                            }


                            if (reader[ClassParameters.ColumnEarlyOpenOffset] != DBNull.Value)
                            {
                                alloc.EarlyOpenOffset = reader[ClassParameters.ColumnEarlyOpenOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocOpenOffset] != DBNull.Value)
                            {
                                alloc.AllocOpenOffset = reader[ClassParameters.ColumnAllocOpenOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocOpenRelated] != DBNull.Value)
                            {
                                alloc.AllocOpenRelated = reader[ClassParameters.ColumnAllocOpenRelated].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocCloseOffset] != DBNull.Value)
                            {
                                alloc.AllocCloseOffset = reader[ClassParameters.ColumnAllocCloseOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocCloseRelated] != DBNull.Value)
                            {
                                alloc.AllocCloseRelated = reader[ClassParameters.ColumnAllocCloseRelated].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnRushDuration] != DBNull.Value)
                            {
                                alloc.RushDuration = reader[ClassParameters.ColumnRushDuration].ToString().Trim();
                            }

                            //if (reader[ClassParameters.ColumnRushOpenOffset] != DBNull.Value)
                            //{
                            //    alloc.RushOpenOffset = reader[ClassParameters.ColumnRushOpenOffset].ToString().Trim();
                            //}

                            //if (reader[ClassParameters.ColumnRushCloseOffset] != DBNull.Value)
                            //{
                            //    alloc.RushCloseOffset = reader[ClassParameters.ColumnRushCloseOffset].ToString().Trim();
                            //}

                            //if (reader[ClassParameters.ColumnAllocRushRelated] != DBNull.Value)
                            //{
                            //    alloc.AllocRushRelated = reader[ClassParameters.ColumnAllocRushRelated].ToString().Trim();
                            //}

                            if (reader[ClassParameters.ColumnIsManualClosed] != DBNull.Value)
                            {
                                alloc.IsManualClosed = Convert.ToBoolean(reader[ClassParameters.ColumnIsManualClosed].ToString().Trim());
                            }

                            if (reader[ClassParameters.ColumnIsClosed] != DBNull.Value)
                            {
                                alloc.IsClosed = Convert.ToBoolean(reader[ClassParameters.ColumnIsClosed].ToString().Trim());
                            }

                            if (reader[ClassParameters.ColumnTravelClass] != DBNull.Value)
                            {
                                alloc.TravelClass = reader[ClassParameters.ColumnTravelClass].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                            {
                                alloc.SubSystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnResource] != DBNull.Value)
                            {
                                alloc.Resource = reader[ClassParameters.ColumnResource].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnBagType] != DBNull.Value)
                            {
                                alloc.BagType = reader[ClassParameters.ColumnBagType].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnPassengerDestination] != DBNull.Value)
                            {
                                alloc.PassengerDestination = reader[ClassParameters.ColumnPassengerDestination].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnTransfer] != DBNull.Value)
                            {
                                alloc.OnwardTransfer = reader[ClassParameters.ColumnTransfer].ToString().Trim();
                            }

                            tempAllocation.Add(alloc);

                            break;
                        case 26:
                            // @Status = 8 (Flight is Slave flight. its master flight is valid flight 
                            //				(flight info can be found in the [FLIGHT_PLAN_SORTING] table). 
                            //              And its master flight allocation has been created 
                            //				(has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
                            //				[AIRLINE],[FLIGHT_NUMBER],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
                            //              [SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],
                            //              [ERLY_OPEN_OFFSET],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
                            //              [RUSH_OPEN_OFFSET],[RUSH_CLOSE_RELATED],[ALLOC_RUSH_RELATED],
                            //              [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM],
                            //              [BAG_TYPE],[PASSENGER_DESTINATION],[TRANSFER]
                            //				26 fields will be returned to caller via returned recordset.
                            if (reader[ClassParameters.ColumnMasterAirline] != DBNull.Value)
                            {
                                masterAirline = reader[ClassParameters.ColumnMasterAirline].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnMasterFlightNo] != DBNull.Value)
                            {
                                masterFlightNo = reader[ClassParameters.ColumnMasterFlightNo].ToString().Trim();
                            }

                            alloc = new AllocationProperty(AllocationType.FlightAllocation, ClassParameters.RelatedNameSTD,
                                    ClassParameters.RelatedNameETD);

                            date = new DateTime();
                            time = string.Empty;

                            alloc.Airline = airline;
                            alloc.FlightNumber = flightNo;
                            alloc.SDO = sdo;
                            alloc.MasterAirline = masterAirline;
                            alloc.MasterFlightNumber = masterFlightNo;

                            if (reader[ClassParameters.ColumnSTO] != DBNull.Value)
                            {
                                sto = reader[ClassParameters.ColumnSTO].ToString().Trim();
                            }

                            alloc.STO = sto;

                            if (reader[ClassParameters.ColumnEDO] != DBNull.Value)
                            {
                                date = Convert.ToDateTime(reader[ClassParameters.ColumnEDO].ToString().Trim());
                                alloc.NullEDO = false;
                            }
                            else
                            {
                                alloc.NullEDO = true;
                            }

                            if (alloc.NullEDO == true)
                            {
                                alloc.EDO = sdo;
                            }
                            else
                            {
                                alloc.EDO = date;
                            }

                            if (reader[ClassParameters.ColumnETO] != DBNull.Value)
                            {
                                time = reader[ClassParameters.ColumnETO].ToString().Trim();
                                alloc.NullEDO = false;
                            }
                            else
                            {
                                alloc.NullEDO = true;
                            }

                            if (time == string.Empty)
                            {
                                alloc.ETO = sto;
                            }
                            else
                            {
                                alloc.ETO = time;
                            }

                            //date = new DateTime();
                            //time = string.Empty;

                            //if (reader[ClassParameters.ColumnIDO] != DBNull.Value)
                            //{
                            //    date = Convert.ToDateTime(reader[ClassParameters.ColumnIDO].ToString().Trim());
                            //}

                            //if (date == null)
                            //{
                            //    alloc.IDO = sdo;
                            //}
                            //else
                            //{
                            //    alloc.IDO = date;
                            //}

                            //if (reader[ClassParameters.ColumnITO] != DBNull.Value)
                            //{
                            //    time = reader[ClassParameters.ColumnITO].ToString().Trim();
                            //}

                            //if (time == string.Empty)
                            //{
                            //    alloc.ITO = sto;
                            //}
                            //else
                            //{
                            //    alloc.ITO = time;
                            //}

                            date = new DateTime();
                            time = string.Empty;

                            if (reader[ClassParameters.ColumnADO] != DBNull.Value)
                            {
                                date = Convert.ToDateTime(reader[ClassParameters.ColumnADO].ToString().Trim());
                                alloc.NullADO = false;
                            }
                            else
                            {
                                alloc.NullADO = true;
                            }

                            if (alloc.NullADO == false)
                            {
                                alloc.ADO = date;
                            }

                            if (reader[ClassParameters.ColumnATO] != DBNull.Value)
                            {
                                time = reader[ClassParameters.ColumnATO].ToString().Trim();
                                alloc.NullADO = false;
                            }
                            else
                            {
                                alloc.NullADO = true;
                            }

                            if (time == string.Empty)
                            {
                                alloc.ATO = string.Empty;
                            }
                            else
                            {
                                alloc.ATO = time;
                            }

                            if (reader[ClassParameters.ColumnEarlyOpenOffset] != DBNull.Value)
                            {
                                alloc.EarlyOpenOffset = reader[ClassParameters.ColumnEarlyOpenOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocOpenOffset] != DBNull.Value)
                            {
                                alloc.AllocOpenOffset = reader[ClassParameters.ColumnAllocOpenOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocOpenRelated] != DBNull.Value)
                            {
                                alloc.AllocOpenRelated = reader[ClassParameters.ColumnAllocOpenRelated].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocCloseOffset] != DBNull.Value)
                            {
                                alloc.AllocCloseOffset = reader[ClassParameters.ColumnAllocCloseOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocCloseRelated] != DBNull.Value)
                            {
                                alloc.AllocCloseRelated = reader[ClassParameters.ColumnAllocCloseRelated].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnRushDuration] != DBNull.Value)
                            {
                                alloc.RushDuration = reader[ClassParameters.ColumnRushDuration].ToString().Trim();
                            }

                            //if (reader[ClassParameters.ColumnRushOpenOffset] != DBNull.Value)
                            //{
                            //    alloc.RushOpenOffset = reader[ClassParameters.ColumnRushOpenOffset].ToString().Trim();
                            //}

                            //if (reader[ClassParameters.ColumnRushCloseOffset] != DBNull.Value)
                            //{
                            //    alloc.RushCloseOffset = reader[ClassParameters.ColumnRushCloseOffset].ToString().Trim();
                            //}

                            //if (reader[ClassParameters.ColumnAllocRushRelated] != DBNull.Value)
                            //{
                            //    alloc.AllocRushRelated = reader[ClassParameters.ColumnAllocRushRelated].ToString().Trim();
                            //}

                            if (reader[ClassParameters.ColumnIsManualClosed] != DBNull.Value)
                            {
                                alloc.IsManualClosed = Convert.ToBoolean(reader[ClassParameters.ColumnIsManualClosed].ToString().Trim());
                            }

                            if (reader[ClassParameters.ColumnIsClosed] != DBNull.Value)
                            {
                                alloc.IsClosed = Convert.ToBoolean(reader[ClassParameters.ColumnIsClosed].ToString().Trim());
                            }

                            if (reader[ClassParameters.ColumnTravelClass] != DBNull.Value)
                            {
                                alloc.TravelClass = reader[ClassParameters.ColumnTravelClass].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                            {
                                alloc.SubSystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnResource] != DBNull.Value)
                            {
                                alloc.Resource = reader[ClassParameters.ColumnResource].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnBagType] != DBNull.Value)
                            {
                                alloc.BagType = reader[ClassParameters.ColumnBagType].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnPassengerDestination] != DBNull.Value)
                            {
                                alloc.PassengerDestination = reader[ClassParameters.ColumnPassengerDestination].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnTransfer] != DBNull.Value)
                            {
                                alloc.OnwardTransfer = reader[ClassParameters.ColumnTransfer].ToString().Trim();
                            }

                            tempAllocation.Add(alloc);

                            break;
                    }
                }

                allocations = tempAllocation.ToArray();
                reader.Close();
                sqlCmd.ExecuteNonQuery();
                // Read OUTPUT parameter values after Reader is closed.
                if (sqlCmd.Parameters["@Status"].Value != DBNull.Value)
                {
                    status = Convert.ToInt32(sqlCmd.Parameters["@Status"].Value.ToString().Trim());
                }
                else
                {
                    status = -1;
                }

                if (sqlCmd.Parameters["@BSM_TravelClass"].Value != DBNull.Value)
                {
                    bsmTravelClass = sqlCmd.Parameters["@BSM_TravelClass"].Value.ToString().Trim();
                }

                if (sqlCmd.Parameters["@BSM_Exception"].Value != DBNull.Value)
                {
                    bsmException = sqlCmd.Parameters["@BSM_Exception"].Value.ToString().Trim();
                }

                if (sqlCmd.Parameters["@FLT_HighRisk"].Value != DBNull.Value)
                {
                    flightHighRisk = sqlCmd.Parameters["@FLT_HighRisk"].Value.ToString().Trim();
                }

                if (sqlCmd.Parameters["@FLT_Exception"].Value != DBNull.Value)
                {
                    flightException = sqlCmd.Parameters["@FLT_Exception"].Value.ToString().Trim();
                }

                reader.Close();
                sqlConn.Close();

                return status;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Allocation Info From IATA Tag failure! <" + thisMethod + ">", ex);

                return -1;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Allocation Info From IATA Tag failure! <" + thisMethod + ">", ex);

                return -1;
            }
            finally
            {
                if (reader != null) reader.Close();
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// 1:  No BSM of specific LP# is in the [PSEUDO_BSM] table, it is No BSM (NBSM) item;
        /// 2:  More than one BSMs of specific LP# are in the [PSEUDO_BSM] table, it is multiple 
        ///     BSM (MBSM) item;
        /// 3:  Single BSM of specific LP# is in the [PSEUDO_BSM] table, but the flight included 
        ///     in the BSM can not be found in the [FLIGHT_PLAN_SORTING] table, it is Unknown flight.
        ///     [AIRLINE],[FLIGHT_NUMBER],[ADO] three fields will be returned caller
        ///     via returned recordset.
        /// 4:  Flight is Slave filght, but its master flight can not be found in the 
        ///     [FLIGHT_PLAN_SORTING] table, it is treated as Unknown flight.
        ///     [AIRLINE],[FLIGHT_NUMBER],[ADO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
        ///     five fields will be returned caller via returned recordset.
        /// 5: (Flight is Master flight and its flight info can be found in the 
        ///     [FLIGHT_PLAN_SORTING] table. But it has no any allocation was created 
        ///     (no allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). It is 
        ///     treated as No Allocation Flight.
        ///     [AIRLINE],[FLIGHT_NUMBER],[ADO],[STO] four fields will be returned caller
        ///     via returned recordset.
        /// 6: (Flight is Slave flight, its master flight is valid flight (flight 
        ///     info can be found in the [FLIGHT_PLAN_SORTING] table). But it has 
        ///     no any allocation was created (no allocation recoreds in the table 
        ///     [FLIGHT_PLAN_ALLOC]). It is treated as No Allocation Flight.
        ///     [AIRLINE],[FLIGHT_NUMBER],[ADO],[STO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
        ///     six fields will be returned caller via returned recordset.
        /// 7: (Flight is Master flight. Its flight info can be found in the [FLIGHT_PLAN_SORTING] table. 
        ///     And its allocation has been created (has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
        ///     Following 21 fields will be returned to caller via returned recordset:
        ///     [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],[ERLY_OPEN_OFFSET],
        ///     [ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],[ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],
        ///     [RUSH_DURATION],[IS_MANUAL_CLOSE],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM],
        ///     [BAG_TYPE],[PASSENGER_DESTINATION],[TRANSFER]
        /// 8: (Flight is Slave flight. its master flight is valid flight (flight info can be found in 
        ///     the [FLIGHT_PLAN_SORTING] table). And its master flight allocation has been created 
        ///     (has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
        ///     Following 23 fields will be returned to caller via returned recordset:
        ///     [AIRLINE],[FLIGHT_NUMBER],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
        ///     [SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],
        ///     [ERLY_OPEN_OFFSET],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
        ///     [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
        ///     [IS_MANUAL_CLOSE],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM],
        ///     [BAG_TYPE],[PASSENGER_DESTINATION],[TRANSFER]
        /// -1: System Exception Occurs. Get flight allocation destination failure.
        /// </summary>
        /// <param name="licensePlate"></param>
        /// <param name="airline"></param>
        /// <param name="flightNo"></param>
        /// <param name="masterAirline"></param>
        /// <param name="masterFlightNo"></param>
        /// <param name="sdo"></param>
        /// <param name="sto"></param>
        /// <param name="bsmTravelClass"></param>
        /// <param name="bsmException"></param>
        /// <param name="flightHighRisk"></param>
        /// <param name="flightException"></param>
        /// <param name="allocations"></param>
        /// <param name="tts"></param>
        /// <returns></returns>
        public int GetAllocationInfoUsingPseudoBSM(string licensePlate, ref string airline, ref string flightNo,
                ref string masterAirline, ref string masterFlightNo, ref DateTime sdo, ref string sto,
                ref string bsmTravelClass, ref string bsmException, ref string flightHighRisk, ref string flightException,
                ref AllocationProperty[] allocations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlDataReader reader = null;
            int status;
            List<AllocationProperty> tempAllocation = new List<AllocationProperty>();
            AllocationProperty alloc;
            DateTime date = new DateTime();
            string time = string.Empty;

            try
            {
                string sConnectionString = string.Empty;
		
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }
                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetFlightAllocOfLPFromPseudoBSM, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@LicensePlate", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@LicensePlate"].Value = licensePlate;

                sqlCmd.Parameters.Add("@Sorter", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@Sorter"].Value = tts;
                sqlCmd.Parameters.Add("@Status", SqlDbType.Int);
                sqlCmd.Parameters["@Status"].Direction = ParameterDirection.Output;


                sqlConn.Open();
                reader = sqlCmd.ExecuteReader();

                while (reader.Read())
                {
                    if (reader[ClassParameters.ColumnAirline] != DBNull.Value)
                    {
                        airline = reader[ClassParameters.ColumnAirline].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnFlightNo] != DBNull.Value)
                    {
                        flightNo = reader[ClassParameters.ColumnFlightNo].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnSDO] != DBNull.Value)
                    {
                        sdo = Convert.ToDateTime(reader[ClassParameters.ColumnSDO].ToString().Trim());
                    }

                    switch (reader.FieldCount)
                    {
                        case 3:
                            // @Status = 3 (Single BSM of specific LP# is in the [BAG_SORTING] table, but the flight included 
                            //				in the BSM can not be found in the [FLIGHT_PLAN_SORTING] table, it is Unknown flight.
                            //				[AIRLINE],[FLIGHT_NUMBER],[SDO] three fields will be returned caller
                            //				via returned recordset.
                            break;
                        case 4:
                            // @Status = 5 (Flight is Master flight and its flight info can be found in the 
                            //              [FLIGHT_PLAN_SORTING] table. But it has no any allocation was created 
                            //				(no allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). It is 
                            //              treated as No Allocation Flight.
                            //				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO] four fields will be returned caller
                            //				via returned recordset.
                            if (reader[ClassParameters.ColumnSTO] != DBNull.Value)
                            {
                                sto = reader[ClassParameters.ColumnSTO].ToString().Trim();
                            }

                            break;
                        case 5:
                            // @Status = 4 (Flight is Slave filght, but its master flight can not be found in the
                            //				[FLIGHT_PLAN_SORTING] table, it is treated as Unknown flight.
                            //				[AIRLINE],[FLIGHT_NUMBER],[SDO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
                            //				five fields will be returned caller via returned recordset.
                            if (reader[ClassParameters.ColumnMasterAirline] != DBNull.Value)
                            {
                                masterAirline = reader[ClassParameters.ColumnMasterAirline].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnMasterFlightNo] != DBNull.Value)
                            {
                                masterFlightNo = reader[ClassParameters.ColumnMasterFlightNo].ToString().Trim();
                            }

                            break;
                        case 6:
                            // @Status = 6 (Flight is Slave flight, its master flight is valid flight (flight 
                            //				info can be found in the [FLIGHT_PLAN_SORTING] table). But it has 
                            //				no any allocation was created (no allocation recoreds in the table 
                            //				[FLIGHT_PLAN_ALLOC]). It is treated as No Allocation Flight.
                            //				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
                            //				six fields will be returned caller via returned recordset.
                            if (reader[ClassParameters.ColumnSTO] != DBNull.Value)
                            {
                                sto = reader[ClassParameters.ColumnSTO].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnMasterAirline] != DBNull.Value)
                            {
                                masterAirline = reader[ClassParameters.ColumnMasterAirline].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnMasterFlightNo] != DBNull.Value)
                            {
                                masterFlightNo = reader[ClassParameters.ColumnMasterFlightNo].ToString().Trim();
                            }

                            break;

                        case 24:
                            // @Status = 7 (Flight is Master flight. Its flight info can be found in the 
                            //              [FLIGHT_PLAN_SORTING] table. And its allocation has been created 
                            //				(has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
                            //				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[IDO],[ITO],
                            //              [ADO],[ATO],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
                            //              [ERLY_OPEN_OFFSET],[RUSH_DURATION],
                            //              [RUSH_OPEN_OFFSET],[RUSH_CLOSE_RELATED],[ALLOC_RUSH_RELATED],
                            //              [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM],
                            //              [BAG_TYPE],[PASSENGER_DESTINATION],[TRANSFER]
                            //				24 fields will be returned to caller via returned recordset.
                            alloc = new AllocationProperty(AllocationType.FlightAllocation, ClassParameters.RelatedNameSTD,
                                    ClassParameters.RelatedNameETD);

                            date = new DateTime();
                            time = string.Empty;

                            alloc.Airline = airline;
                            alloc.FlightNumber = flightNo;
                            alloc.SDO = sdo;

                            if (reader[ClassParameters.ColumnSTO] != DBNull.Value)
                            {
                                sto = reader[ClassParameters.ColumnSTO].ToString().Trim();
                            }

                            alloc.STO = sto;

                            if (reader[ClassParameters.ColumnEDO] != DBNull.Value)
                            {
                                date = Convert.ToDateTime(reader[ClassParameters.ColumnEDO].ToString().Trim());
                                alloc.NullEDO = false;
                            }
                            else
                            {
                                alloc.NullEDO = true;
                            }

                            if (alloc.NullEDO == true)
                            {
                                alloc.EDO = sdo;
                            }
                            else
                            {
                                alloc.EDO = date;
                            }

                            if (reader[ClassParameters.ColumnETO] != DBNull.Value)
                            {
                                time = reader[ClassParameters.ColumnETO].ToString().Trim();
                                alloc.NullEDO = false;
                            }
                            else
                            {
                                alloc.NullEDO = true;
                            }

                            if (time == string.Empty)
                            {
                                alloc.ETO = sto;                                
                            }
                            else
                            {
                                alloc.ETO = time;
                            }

                            //date = new DateTime();
                            //time = string.Empty;

                            //if (reader[ClassParameters.ColumnIDO] != DBNull.Value)
                            //{
                            //    date = Convert.ToDateTime(reader[ClassParameters.ColumnIDO].ToString().Trim());
                            //}

                            //if (date == null)
                            //{
                            //    alloc.IDO = sdo;
                            //}
                            //else
                            //{
                            //    alloc.IDO = date;
                            //}

                            //if (reader[ClassParameters.ColumnITO] != DBNull.Value)
                            //{
                            //    time = reader[ClassParameters.ColumnITO].ToString().Trim();
                            //}

                            //if (time == string.Empty)
                            //{
                            //    alloc.ITO = sto;
                            //}
                            //else
                            //{
                            //    alloc.ITO = time;
                            //}

                            date = new DateTime();
                            time = string.Empty;

                            if (reader[ClassParameters.ColumnADO] != DBNull.Value)
                            {
                                date = Convert.ToDateTime(reader[ClassParameters.ColumnADO].ToString().Trim());
                                alloc.NullADO = false;
                            }
                            else
                            {
                                alloc.NullADO = true;
                            }

                            if (alloc.NullADO == false)
                            {
                                alloc.ADO = date;
                            }

                            if (reader[ClassParameters.ColumnATO] != DBNull.Value)
                            {
                                time = reader[ClassParameters.ColumnATO].ToString().Trim();
                                alloc.NullADO = false;
                            }
                            else
                            {
                                alloc.NullADO = true;
                            }

                            if (time == string.Empty)
                            {
                                alloc.ATO = string.Empty;
                            }
                            else
                            {
                                alloc.ATO = time;
                            }

                            if (reader[ClassParameters.ColumnEarlyOpenOffset] != DBNull.Value)
                            {
                                alloc.EarlyOpenOffset = reader[ClassParameters.ColumnEarlyOpenOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocOpenOffset] != DBNull.Value)
                            {
                                alloc.AllocOpenOffset = reader[ClassParameters.ColumnAllocOpenOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocOpenRelated] != DBNull.Value)
                            {
                                alloc.AllocOpenRelated = reader[ClassParameters.ColumnAllocOpenRelated].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocCloseOffset] != DBNull.Value)
                            {
                                alloc.AllocCloseOffset = reader[ClassParameters.ColumnAllocCloseOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocCloseRelated] != DBNull.Value)
                            {
                                alloc.AllocCloseRelated = reader[ClassParameters.ColumnAllocCloseRelated].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnRushDuration] != DBNull.Value)
                            {
                                alloc.RushDuration = reader[ClassParameters.ColumnRushDuration].ToString().Trim();
                            }

                            //if (reader[ClassParameters.ColumnRushOpenOffset] != DBNull.Value)
                            //{
                            //    alloc.RushOpenOffset = reader[ClassParameters.ColumnRushOpenOffset].ToString().Trim();
                            //}

                            //if (reader[ClassParameters.ColumnRushCloseOffset] != DBNull.Value)
                            //{
                            //    alloc.RushCloseOffset = reader[ClassParameters.ColumnRushCloseOffset].ToString().Trim();
                            //}

                            //if (reader[ClassParameters.ColumnAllocRushRelated] != DBNull.Value)
                            //{
                            //    alloc.AllocRushRelated = reader[ClassParameters.ColumnAllocRushRelated].ToString().Trim();
                            //}

                            if (reader[ClassParameters.ColumnIsManualClosed] != DBNull.Value)
                            {
                                alloc.IsManualClosed = Convert.ToBoolean(reader[ClassParameters.ColumnIsManualClosed].ToString().Trim());
                            }

                            if (reader[ClassParameters.ColumnIsClosed] != DBNull.Value)
                            {
                                alloc.IsClosed = Convert.ToBoolean(reader[ClassParameters.ColumnIsClosed].ToString().Trim());
                            }

                            if (reader[ClassParameters.ColumnTravelClass] != DBNull.Value)
                            {
                                alloc.TravelClass = reader[ClassParameters.ColumnTravelClass].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                            {
                                alloc.SubSystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnResource] != DBNull.Value)
                            {
                                alloc.Resource = reader[ClassParameters.ColumnResource].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnBagType] != DBNull.Value)
                            {
                                alloc.BagType = reader[ClassParameters.ColumnBagType].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnPassengerDestination] != DBNull.Value)
                            {
                                alloc.PassengerDestination = reader[ClassParameters.ColumnPassengerDestination].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnTransfer] != DBNull.Value)
                            {
                                alloc.OnwardTransfer = reader[ClassParameters.ColumnTransfer].ToString().Trim();
                            }

                            tempAllocation.Add(alloc);

                            break;
                        case 26:
                            // @Status = 8 (Flight is Slave flight. its master flight is valid flight 
                            //				(flight info can be found in the [FLIGHT_PLAN_SORTING] table). 
                            //              And its master flight allocation has been created 
                            //				(has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
                            //				[AIRLINE],[FLIGHT_NUMBER],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
                            //              [SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],
                            //              [ERLY_OPEN_OFFSET],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
                            //              [RUSH_OPEN_OFFSET],[RUSH_CLOSE_RELATED],[ALLOC_RUSH_RELATED],
                            //              [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM],
                            //              [BAG_TYPE],[PASSENGER_DESTINATION],[TRANSFER]
                            //				26 fields will be returned to caller via returned recordset.
                            if (reader[ClassParameters.ColumnMasterAirline] != DBNull.Value)
                            {
                                masterAirline = reader[ClassParameters.ColumnMasterAirline].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnMasterFlightNo] != DBNull.Value)
                            {
                                masterFlightNo = reader[ClassParameters.ColumnMasterFlightNo].ToString().Trim();
                            }

                            alloc = new AllocationProperty(AllocationType.FlightAllocation, ClassParameters.RelatedNameSTD,
                                    ClassParameters.RelatedNameETD);

                            date = new DateTime();
                            time = string.Empty;

                            alloc.Airline = airline;
                            alloc.FlightNumber = flightNo;
                            alloc.SDO = sdo;
                            alloc.MasterAirline = masterAirline;
                            alloc.MasterFlightNumber = masterFlightNo;

                            if (reader[ClassParameters.ColumnSTO] != DBNull.Value)
                            {
                                sto = reader[ClassParameters.ColumnSTO].ToString().Trim();
                            }

                            alloc.STO = sto;

                             if (reader[ClassParameters.ColumnEDO] != DBNull.Value)
                            {
                                date = Convert.ToDateTime(reader[ClassParameters.ColumnEDO].ToString().Trim());
                                alloc.NullEDO = false;
                            }
                            else
                            {
                                alloc.NullEDO = true;
                            }

                            if (alloc.NullEDO == true)
                            {
                                alloc.EDO = sdo;
                            }
                            else
                            {
                                alloc.EDO = date;
                            }

                            if (reader[ClassParameters.ColumnETO] != DBNull.Value)
                            {
                                time = reader[ClassParameters.ColumnETO].ToString().Trim();
                                alloc.NullEDO = false;
                            }
                            else
                            {
                                alloc.NullEDO = true;
                            }

                            if (time == string.Empty)
                            {
                                alloc.ETO = sto;                                
                            }
                            else
                            {
                                alloc.ETO = time;
                            }

                            //date = new DateTime();
                            //time = string.Empty;

                            //if (reader[ClassParameters.ColumnIDO] != DBNull.Value)
                            //{
                            //    date = Convert.ToDateTime(reader[ClassParameters.ColumnIDO].ToString().Trim());
                            //}

                            //if (date == null)
                            //{
                            //    alloc.IDO = sdo;
                            //}
                            //else
                            //{
                            //    alloc.IDO = date;
                            //}

                            //if (reader[ClassParameters.ColumnITO] != DBNull.Value)
                            //{
                            //    time = reader[ClassParameters.ColumnITO].ToString().Trim();
                            //}

                            //if (time == string.Empty)
                            //{
                            //    alloc.ITO = sto;
                            //}
                            //else
                            //{
                            //    alloc.ITO = time;
                            //}

                            date = new DateTime();
                            time = string.Empty;

                            if (reader[ClassParameters.ColumnADO] != DBNull.Value)
                            {
                                date = Convert.ToDateTime(reader[ClassParameters.ColumnADO].ToString().Trim());
                                alloc.NullADO = false;
                            }
                            else
                            {
                                alloc.NullADO = true;
                            }

                            if (alloc.NullADO == false)
                            {
                                alloc.ADO = date;
                            }

                            if (reader[ClassParameters.ColumnATO] != DBNull.Value)
                            {
                                time = reader[ClassParameters.ColumnATO].ToString().Trim();
                                alloc.NullADO = false;
                            }
                            else
                            {
                                alloc.NullADO = true;
                            }

                            if (time == string.Empty)
                            {
                                alloc.ATO = string.Empty;
                            }
                            else
                            {
                                alloc.ATO = time;
                            }
                            
                            if (reader[ClassParameters.ColumnEarlyOpenOffset] != DBNull.Value)
                            {
                                alloc.EarlyOpenOffset = reader[ClassParameters.ColumnEarlyOpenOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocOpenOffset] != DBNull.Value)
                            {
                                alloc.AllocOpenOffset = reader[ClassParameters.ColumnAllocOpenOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocOpenRelated] != DBNull.Value)
                            {
                                alloc.AllocOpenRelated = reader[ClassParameters.ColumnAllocOpenRelated].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocCloseOffset] != DBNull.Value)
                            {
                                alloc.AllocCloseOffset = reader[ClassParameters.ColumnAllocCloseOffset].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnAllocCloseRelated] != DBNull.Value)
                            {
                                alloc.AllocCloseRelated = reader[ClassParameters.ColumnAllocCloseRelated].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnRushDuration] != DBNull.Value)
                            {
                                alloc.RushDuration = reader[ClassParameters.ColumnRushDuration].ToString().Trim();
                            }

                            //if (reader[ClassParameters.ColumnRushOpenOffset] != DBNull.Value)
                            //{
                            //    alloc.RushOpenOffset = reader[ClassParameters.ColumnRushOpenOffset].ToString().Trim();
                            //}

                            //if (reader[ClassParameters.ColumnRushCloseOffset] != DBNull.Value)
                            //{
                            //    alloc.RushCloseOffset = reader[ClassParameters.ColumnRushCloseOffset].ToString().Trim();
                            //}

                            //if (reader[ClassParameters.ColumnAllocRushRelated] != DBNull.Value)
                            //{
                            //    alloc.AllocRushRelated = reader[ClassParameters.ColumnAllocRushRelated].ToString().Trim();
                            //}

                            if (reader[ClassParameters.ColumnIsManualClosed] != DBNull.Value)
                            {
                                alloc.IsManualClosed = Convert.ToBoolean(reader[ClassParameters.ColumnIsManualClosed].ToString().Trim());
                            }

                            if (reader[ClassParameters.ColumnIsClosed] != DBNull.Value)
                            {
                                alloc.IsClosed = Convert.ToBoolean(reader[ClassParameters.ColumnIsClosed].ToString().Trim());
                            }

                            if (reader[ClassParameters.ColumnTravelClass] != DBNull.Value)
                            {
                                alloc.TravelClass = reader[ClassParameters.ColumnTravelClass].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                            {
                                alloc.SubSystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnResource] != DBNull.Value)
                            {
                                alloc.Resource = reader[ClassParameters.ColumnResource].ToString().Trim();
                            }
                            
                            if (reader[ClassParameters.ColumnBagType] != DBNull.Value)
                            {
                                alloc.BagType = reader[ClassParameters.ColumnBagType].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnPassengerDestination] != DBNull.Value)
                            {
                                alloc.PassengerDestination = reader[ClassParameters.ColumnPassengerDestination].ToString().Trim();
                            }

                            if (reader[ClassParameters.ColumnTransfer] != DBNull.Value)
                            {
                                alloc.OnwardTransfer = reader[ClassParameters.ColumnTransfer].ToString().Trim();
                            }

                            tempAllocation.Add(alloc);

                            break;
                    }
                }

                allocations = tempAllocation.ToArray();

                reader.Close();
                sqlCmd.ExecuteNonQuery();

                // Read OUTPUT parameter values after Reader is closed.
                if (sqlCmd.Parameters["@Status"].Value != DBNull.Value)
                {
                    status = Convert.ToInt32(sqlCmd.Parameters["@Status"].Value.ToString().Trim());
                }
                else
                {
                    status = -1;
                }

                //if (sqlCmd.Parameters["@BSM_TravelClass"].Value != DBNull.Value)
                //{
                //    bsmTravelClass = sqlCmd.Parameters["@BSM_TravelClass"].Value.ToString().Trim();
                //}

                //if (sqlCmd.Parameters["@BSM_Exception"].Value != DBNull.Value)
                //{
                //    bsmException = sqlCmd.Parameters["@BSM_Exception"].Value.ToString().Trim();
                //}

                //if (sqlCmd.Parameters["@FLT_HighRisk"].Value != DBNull.Value)
                //{
                //    flightHighRisk = sqlCmd.Parameters["@FLT_HighRisk"].Value.ToString().Trim();
                //}

                //if (sqlCmd.Parameters["@FLT_Exception"].Value != DBNull.Value)
                //{
                //    flightException = sqlCmd.Parameters["@FLT_Exception"].Value.ToString().Trim();
                //}

                reader.Close();
                sqlConn.Close();

                return status;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Allocation Info Using Pseudo BSM failure! <" + thisMethod + ">", ex);

                return -1;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Allocation Info Using Pseudo BSM  failure! <" + thisMethod + ">", ex);

                return -1;
            }
            finally
            {
                if (reader != null) reader.Close();
                if (sqlConn != null) sqlConn.Close();
            }
        }


        

        /// <summary>
        ///  Get allocated destinations of No BSM (Unknown LP) function allocation.
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="licensePlate"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfNBSM(string channelName, string gid, string licensePlate, LocationID currentLocation,
                ref string reason, ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] mesLocation = null;

            if (tts == TTS01_SUBSYSTEM)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
            }

            try
            {
                // Sorted by multiple BSM (NBSM)
                reason = ClassParameters.SortReasonNBSM;

                // Get the destination of No BSM function allocation type (NBSM)
                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationNBSM,
                            currentLocation, ref destinations, mesLocation, tts);

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid +
                            "] is " + ClassParameters.FuncAllocationNBSM +
                            " item. Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "] . <" + thisMethod + ">");

            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of NBSM is failure! <" + thisMethod + ">", ex);

                destinations = mesLocation;
            }
        }

        /// <summary>
        /// GetDestinationOfAirline
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="airlineCode"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfAirline(string channelName, string gid, string airlineCode, LocationID currentLocation,
                ref string reason, ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            // Sorted by Airline Allocation
            reason = ClassParameters.SortReasonALAL;

            // 1. Query destination and its Subsystem of given Airline code 
            //    from table [AIRLINES] and [LOCATIONS];
            LocationID[] temp = QueryDestinationOfAirlineCode(airlineCode, tts);

            // 2. Re-order destination according to airline allocation sortation scheme;
            if (temp == null)
            {
                destinations = null;
            }
            else
            {
                //destinations = ReOrderDestinationSequence(ref reason, channelName, gid,
                //                    currentLocation, ref temp, SortSchemeAirlineAlloc, airlineCode, false, false, tts);
                destinations = temp;
            }
        }

        /// <summary>
        /// To get the Airline mapping location(s)
        /// </summary>
        /// <param name="airlineCode"></param>
        /// <param name="tts"></param>
        /// <returns></returns>
        public LocationID[] QueryDestinationOfAirlineCode(string airlineCode, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlDataReader reader = null;
            List<LocationID> locations = new List<LocationID>();
            LocationID dest;

            try
            {
                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }
                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetAirlineAllocation, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@AirlineCode", SqlDbType.VarChar, 4);
                sqlCmd.Parameters["@AirlineCode"].Value = airlineCode;

                sqlCmd.Parameters.Add("@Sorter", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@Sorter"].Value = tts;

                sqlConn.Open();
                reader = sqlCmd.ExecuteReader();

                while (reader.Read())
                {
                    dest = new LocationID();


                    if (reader[ClassParameters.ColumnDestination] != DBNull.Value)
                    {
                        dest.Location = reader[ClassParameters.ColumnDestination].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                    {
                        dest.Subsystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                    }

                    locations.Add(dest);
                }


                return locations.ToArray();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Allocation Info From IATA Tag failure! <" + thisMethod + ">", ex);

                return null;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Allocation Info From IATA Tag failure! <" + thisMethod + ">", ex);

                return null;
            }
            finally
            {
                if (reader != null) reader.Close();
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Get allocated destinations of multiple BSM (MBSM) function allocation.
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="licensePlate"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfMBSM(string channelName, string gid, string licensePlate, LocationID currentLocation, ref string reason,
                ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] mesLocation = null;

            if (tts == TTS01_SUBSYSTEM)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
            }

            try
            {
                // Sorted by multiple BSM (MBSM)
                reason = ClassParameters.SortReasonMBSM;

                // Get the destination of multiple BSM function allocation type (MBSM)
                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationMBSM,
                            currentLocation, ref destinations, mesLocation, tts);

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid + ", LP: " + licensePlate +
                            "] is " + ClassParameters.FuncAllocationMBSM +
                            " item. Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "] . <" + thisMethod + ">");

            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of MBSM is failure! <" + thisMethod + ">", ex);

                destinations = mesLocation;
            }
        }

        /// <summary>
        /// GetDestinationOfOFBK (Off Block to problem Chute)
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfOFBK(string channelName, string gid, LocationID currentLocation,
                ref string reason, ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] mesLocation = null;
            string funcAllocProb = string.Empty;

            if (tts == ClassParameters.TTSSorter01)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
                funcAllocProb = ClassParameters.FuncAllocationPB01;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
                funcAllocProb = ClassParameters.FuncAllocationPB02;
            }

            try
            {
                // Sorted by Off Block. (OFBK)
                reason = ClassParameters.SortReasonOFBK;

                //Get the destination of Off Block. (OFBK) function allocation type 
                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, funcAllocProb,
                            currentLocation, ref destinations, mesLocation, tts);

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid +
                            "] is " + funcAllocProb +
                            " item. Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "] . <" + thisMethod + ">");

            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of OFBK is failure! <" + thisMethod + ">", ex);

                destinations = mesLocation;
            }
        }


        /// <summary>
        /// Get allocated destinations of FEXC (FLIGHT EXCEPTION) function allocation.
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="flightException"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfFEXC(string channelName, string gid, LocationID currentLocation,
                ref string reason, ref LocationID[] destinations, string flightException, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            bool isMES = false;

            try
            {
                // Sorted by FLIGHT EXCEPTION (FEXC).
                reason = ClassParameters.SortReasonFEXC;

                // Get the destination of FEXC (FLIGHT EXCEPTION) function allocation types 
                LocationID[] temp = GetDestinationOfFunctionAllocation(ClassParameters.FuncAllocationFEXC, flightException, ref isMES, tts);

                // Re-order destination according to function allocation sortation scheme, if return nothing mean unavailable
                //bool isException = true;

                if (temp.Length > 0)
                {
                    //destinations = ReOrderDestinationSequence(ref reason, channelName, gid, currentLocation, ref temp, SortSchemeFuncAlloc,
                    //                           ClassParameters.FuncAllocationFEXC, isException, isMES, tts);
                    destinations = temp;

                    if (_logger.IsInfoEnabled)
                        _logger.Info("[Channel:" + channelName +
                                "] [GID:" + gid +
                                "] is " + ClassParameters.FuncAllocationFEXC +
                                " item. Its destination: [" +
                                Utilities.LocationIDArrayToString(ref destinations) +
                                "] . <" + thisMethod + ">");
                }
                else
                {
                    destinations = null;
                }

            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of FEXC is failure! <" + thisMethod + ">", ex);

                if (tts == TTS01_SUBSYSTEM)
                {
                    destinations = ClassParameters.TTS01MESLocation;
                }
                else
                {
                    destinations = ClassParameters.TTS02MESLocation;
                }
            }
        }

        /// <summary>
        /// Get Bag Information - Bag Type, Passenger Destination, Passenger Travel Class, Onward Transfer Status
        /// </summary>
        /// <param name="licensePlate"></param>
        /// <param name="bagType"></param>
        /// <param name="passengerDestination"></param>
        /// <param name="passengerTravelClass"></param>
        /// <param name="onwardTransferStatus"></param>
        private void GetBagInformation(string licensePlate, ref string bagType, ref string passengerDestination,
                ref string passengerTravelClass, ref string onwardTransferStatus)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;

            try
            {
                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }
                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetBagInformation, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@LicensePlate", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@LicensePlate"].Value = licensePlate;

                sqlCmd.Parameters.Add("@Wildcard", SqlDbType.VarChar, 3);
                sqlCmd.Parameters["@Wildcard"].Value = ClassParameters.Wildcard;

                sqlCmd.Parameters.Add("@BagType", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@BagType"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@PasssengerDestination", SqlDbType.VarChar, 5);
                sqlCmd.Parameters["@PasssengerDestination"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@PassengerTravelClass", SqlDbType.VarChar, 1);
                sqlCmd.Parameters["@PassengerTravelClass"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@OnwardTransfer", SqlDbType.VarChar, 3);
                sqlCmd.Parameters["@OnwardTransfer"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@BagType"].Value != DBNull.Value)
                {
                    bagType = sqlCmd.Parameters["@BagType"].Value.ToString();
                }

                if (sqlCmd.Parameters["@PasssengerDestination"].Value != DBNull.Value)
                {
                    passengerDestination = sqlCmd.Parameters["@PasssengerDestination"].Value.ToString();
                }

                if (sqlCmd.Parameters["@PassengerTravelClass"].Value != DBNull.Value)
                {
                    passengerTravelClass = sqlCmd.Parameters["@PassengerTravelClass"].Value.ToString();
                }

                if (sqlCmd.Parameters["@OnwardTransfer"].Value != DBNull.Value)
                {
                    onwardTransferStatus = sqlCmd.Parameters["@OnwardTransfer"].Value.ToString();
                }
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Bag Information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Bag Information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Get Priority Of Flight Allocation(s)
        /// </summary>
        /// <param name="filteredAllocation"></param>
        /// <param name="allocations"></param>
        /// <param name="currentPriority"></param>
        /// <param name="allPriorityAllocations"></param>
        /// <returns></returns>
        private List<AllocationProperty> GetPriorityOfFlightAllocation(List<AllocationProperty> filteredAllocation,
                ref AllocationProperty[] allocations, ref int currentPriority, ref List<AllocationProperty[]> allPriorityAllocations)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            int priority = 0;
            int loopCount = 0;

            List<AllocationProperty> multipleAlloc = new List<AllocationProperty>();

            try
            {
                AllocationProperty[] temp = filteredAllocation.ToArray();

                // 1111 (not wildcard, not wildcard, not wildcard, not wildcard)
                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType != ClassParameters.Wildcard) & (temp[i].PassengerDestination != ClassParameters.Wildcard) &
                        (temp[i].TravelClass != ClassParameters.Wildcard) & (temp[i].OnwardTransfer != ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 1110 (not wildcard, not wildcard, not wildcard, wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType != ClassParameters.Wildcard) & (temp[i].PassengerDestination != ClassParameters.Wildcard) &
                        (temp[i].TravelClass != ClassParameters.Wildcard) & (temp[i].OnwardTransfer == ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 1101 (not wildcard, not wildcard, wildcard, not wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType != ClassParameters.Wildcard) & (temp[i].PassengerDestination != ClassParameters.Wildcard) &
                        (temp[i].TravelClass == ClassParameters.Wildcard) & (temp[i].OnwardTransfer != ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                //1100 (not wildcard, not wildcard, wildcard, wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType != ClassParameters.Wildcard) & (temp[i].PassengerDestination != ClassParameters.Wildcard) &
                        (temp[i].TravelClass == ClassParameters.Wildcard) & (temp[i].OnwardTransfer == ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 1011 (not wildcard, wildcard, not wildcard, not wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType != ClassParameters.Wildcard) & (temp[i].PassengerDestination == ClassParameters.Wildcard) &
                        (temp[i].TravelClass != ClassParameters.Wildcard) & (temp[i].OnwardTransfer != ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 1010 (not wildcard, wildcard, not wildcard, wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType != ClassParameters.Wildcard) & (temp[i].PassengerDestination == ClassParameters.Wildcard) &
                        (temp[i].TravelClass != ClassParameters.Wildcard) & (temp[i].OnwardTransfer == ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 1001 (not wildcard, wildcard, wildcard, not wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType != ClassParameters.Wildcard) & (temp[i].PassengerDestination == ClassParameters.Wildcard) &
                        (temp[i].TravelClass == ClassParameters.Wildcard) & (temp[i].OnwardTransfer != ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 1000 (not wildcard, wildcard, wildcard, wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType != ClassParameters.Wildcard) & (temp[i].PassengerDestination == ClassParameters.Wildcard) &
                        (temp[i].TravelClass == ClassParameters.Wildcard) & (temp[i].OnwardTransfer == ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 0111 (wildcard, not wildcard, not wildcard, not wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType == ClassParameters.Wildcard) & (temp[i].PassengerDestination != ClassParameters.Wildcard) &
                        (temp[i].TravelClass != ClassParameters.Wildcard) & (temp[i].OnwardTransfer != ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 0110 (wildcard, not wildcard, not wildcard, wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType == ClassParameters.Wildcard) & (temp[i].PassengerDestination != ClassParameters.Wildcard) &
                        (temp[i].TravelClass != ClassParameters.Wildcard) & (temp[i].OnwardTransfer == ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 0101 (wildcard, not wildcard, wildcard, not wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType == ClassParameters.Wildcard) & (temp[i].PassengerDestination != ClassParameters.Wildcard) &
                        (temp[i].TravelClass == ClassParameters.Wildcard) & (temp[i].OnwardTransfer != ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 0100 (wildcard, not wildcard, wildcard, wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType == ClassParameters.Wildcard) & (temp[i].PassengerDestination != ClassParameters.Wildcard) &
                        (temp[i].TravelClass == ClassParameters.Wildcard) & (temp[i].OnwardTransfer == ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 0011 (wildcard, wildcard, not wildcard, not wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType == ClassParameters.Wildcard) & (temp[i].PassengerDestination == ClassParameters.Wildcard) &
                        (temp[i].TravelClass != ClassParameters.Wildcard) & (temp[i].OnwardTransfer != ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 0010 (wildcard, wildcard, not wildcard, wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType == ClassParameters.Wildcard) & (temp[i].PassengerDestination == ClassParameters.Wildcard) &
                        (temp[i].TravelClass != ClassParameters.Wildcard) & (temp[i].OnwardTransfer == ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 0001 (wildcard, wildcard, wildcard, not wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType == ClassParameters.Wildcard) & (temp[i].PassengerDestination == ClassParameters.Wildcard) &
                        (temp[i].TravelClass == ClassParameters.Wildcard) & (temp[i].OnwardTransfer != ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // 0000 (wildcard, wildcard, wildcard, wildcard)
                loopCount = 0;
                temp = filteredAllocation.ToArray();

                for (int i = 0; i < temp.Length; i++)
                {
                    if ((temp[i].BagType == ClassParameters.Wildcard) & (temp[i].PassengerDestination == ClassParameters.Wildcard) &
                        (temp[i].TravelClass == ClassParameters.Wildcard) & (temp[i].OnwardTransfer == ClassParameters.Wildcard))
                    {
                        if (loopCount == 0)
                        {
                            priority++;
                        }

                        temp[i].Priority = priority;
                        multipleAlloc.Add(temp[i]);
                        filteredAllocation.Remove(temp[i]);
                        loopCount++;
                    }
                }

                // Get the highest priority allocation
                // As the highest priority at the beginning of the List, so check whether have same priority for following position.
                // If have add into new list, so all the highest priority allocation can be found.
                List<AllocationProperty> samePriorityAllocations = new List<AllocationProperty>();

                int k = 0;

                samePriorityAllocations.Add(multipleAlloc[k]);

                for (int j = k + 1; j < multipleAlloc.Count; j++)
                {
                    if (multipleAlloc[j - 1].Priority == multipleAlloc[j].Priority)
                    {
                        samePriorityAllocations.Add(multipleAlloc[j]);
                    }
                    else
                    {
                        allPriorityAllocations.Add(samePriorityAllocations.ToArray());

                        samePriorityAllocations = new List<AllocationProperty>();
                        samePriorityAllocations.Add(multipleAlloc[j]);
                        //currentPriority = multipleAlloc[k-1].Priority;
                        //break;
                    }
                }

                if ((samePriorityAllocations.Count > 0) & (samePriorityAllocations != null))
                {
                    allPriorityAllocations.Add(samePriorityAllocations.ToArray());
                }

                allocations = allPriorityAllocations[0];

                return multipleAlloc;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Priority Of Flight Allocation failure! <" + thisMethod + ">", ex);

                return null;
            }
        }

        /// <summary>
        /// Lookup Allocated Destination
        /// </summary>
        /// <param name="status"></param>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="validTag"></param>
        /// <param name="currentLocation"></param>
        /// <param name="bsmTravelClass"></param>
        /// <param name="allocations"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="isFunction"></param>
        /// <param name="isMES"></param>    
        /// <param name="tts"></param>  
        /// <param name="originalAllocations"></param>
        private void LookupAllocatedDestination(int status, string channelName, string gid, Tag validTag, LocationID currentLocation,
                string bsmTravelClass, ref AllocationProperty[] allocations, ref string reason, ref LocationID[] destinations, out bool isFunction,
                out bool isMES, string tts, AllocationProperty[] originalAllocations)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            isMES = false;
            isFunction = false;

            List<LocationID> listTooEarly = new List<LocationID>();
            List<LocationID> listEarly = new List<LocationID>();
            List<LocationID> listOpen = new List<LocationID>();
            List<LocationID> listRush = new List<LocationID>();
            List<LocationID> listTooLate = new List<LocationID>();

            LocationID[] tooEarly = null;
            LocationID[] early = null;
            LocationID[] open = null;
            LocationID[] rush = null;
            LocationID[] tooLate = null;
            LocationID[] offBlock = null;
           
            LocationID tempLocationID;

            if (allocations == null)
            {
                destinations = null;
                return;
            }

            int lengthAllocation = allocations.Length;
            if (lengthAllocation == 0)
            {
                destinations = null;
                return;
            }

            LocationID[] mesLocation = null;

            if (tts == TTS01_SUBSYSTEM)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
            }

            try
            {
                for (int i = 0; i < lengthAllocation; i++)
                {
                    BagStates allocationStates;

                    // Compare with time NOW to check allocation states.
                    allocationStates = allocations[i].BagStateChecking(DateTime.Now);


                    //  List out allocations of common class (*)                  
                    switch (allocationStates)
                    {
                        case BagStates.TooEarly:
                            tempLocationID = new LocationID();
                            tempLocationID.Location = allocations[i].Resource;
                            tempLocationID.Subsystem = allocations[i].SubSystem;
                            listTooEarly.Add(tempLocationID);
                            isFunction = true;

                            break;
                        case BagStates.Early:
                            tempLocationID = new LocationID();
                            tempLocationID.Location = allocations[i].Resource;
                            tempLocationID.Subsystem = allocations[i].SubSystem;
                            listEarly.Add(tempLocationID);
                            isFunction = true;

                            break;
                        case BagStates.Open:
                            tempLocationID = new LocationID();
                            tempLocationID.Location = allocations[i].Resource;
                            tempLocationID.Subsystem = allocations[i].SubSystem;
                            listOpen.Add(tempLocationID);
                            isFunction = false;

                            break;
                        case BagStates.Rush:
                            tempLocationID = new LocationID();
                            tempLocationID.Location = allocations[i].Resource;
                            tempLocationID.Subsystem = allocations[i].SubSystem;
                            listRush.Add(tempLocationID);
                            isFunction = true;

                            break;
                        case BagStates.TooLate:
                            tempLocationID = new LocationID();
                            tempLocationID.Location = allocations[i].Resource;
                            tempLocationID.Subsystem = allocations[i].SubSystem;
                            listTooLate.Add(tempLocationID);
                            isFunction = true;

                            break;
                        case BagStates.OffBlock:
                            GetDestinationOfOFBK(channelName, gid, currentLocation, ref reason, ref offBlock, tts);
                            isFunction = true;

                            break;
                    }
                }

                tooEarly = listTooEarly.ToArray();
                early = listEarly.ToArray();
                open = listOpen.ToArray();
                rush = listRush.ToArray();
                tooLate = listTooLate.ToArray();


                if (offBlock != null)
                {
                    destinations = offBlock;

                    if (_logger.IsInfoEnabled)
                        _logger.Info("[Channel:" + channelName +
                                "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                "] Allocation is after Off Block, it will sort to its Problem Destination: (" +
                                Utilities.LocationIDArrayToString(ref destinations) +
                                "). <" + thisMethod + ">");

                    return;
                }



                // Check for flight cancellation
                string flightCancellation = string.Empty;
                bool flightDeleted = false;
                GetCancellationOfFlight(validTag.LP, out flightCancellation, out flightDeleted);

                if (flightCancellation == ClassParameters.FlightCancellationValue)
                {
                    //// Sorted by Cancallation Flight (CCFL)
                    //reason = ClassParameters.SortReasonCCFL;
                    if (rush.Length != 0 & rush != null)
                    {
                        destinations = rush;
                        reason = ClassParameters.SortReasonCCFL;

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is RUSH and it is Cancelled Flight, it will sort to its Flight Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");

                        return;
                    }

                    if (tooLate.Length != 0 & tooLate != null)
                    {
                        destinations = tooLate;
                        reason = ClassParameters.SortReasonCCFL;

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is TOO LATE and it is Cancelled Flight, it will sort to its Flight Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");

                        return;
                    }

                    if (_logger.IsInfoEnabled)
                        _logger.Info("[Channel:" + channelName +
                                "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                "] It is Cancellation Flight. Sorted as usual. <" + thisMethod + ">");

                    //if (open.Length != 0 & open != null)
                    //{
                    //    destinations = open;
                    //}
                    //else if (rush.Length != 0 & rush != null)
                    //{
                    //    destinations = rush;
                    //}
                    //else if (early.Length != 0 & early != null)
                    //{
                    //    destinations = early;
                    //}
                    //else if (tooEarly.Length != 0 & tooEarly != null)
                    //{
                    //    destinations = tooEarly;
                    //}
                    //else
                    //{
                    //    destinations = tooLate;
                    //}

                    //return;
                }

                if (flightDeleted)
                {
                    //// Sorted by Deleted Flight (DELF)
                    //reason = ClassParameters.SortReasonDELF;


                    if (rush.Length != 0 & rush != null)
                    {
                        destinations = rush;
                        reason = ClassParameters.SortReasonDELF;

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is RUSH and it is Deleted Flight, it will sort to its Flight Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");

                        return;
                    }

                    if (tooLate.Length != 0 & tooLate != null)
                    {
                        destinations = tooLate;
                        reason = ClassParameters.SortReasonDELF;

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is TOO LATE and it is Deleted Flight, it will sort to its Flight Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");

                        return;
                    }

                    if (_logger.IsInfoEnabled)
                        _logger.Info("[Channel:" + channelName +
                                "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                "] It is Deleted Flight. Sorted as usual. <" + thisMethod + ">");

                    //if (open.Length != 0 & open != null)
                    //{
                    //    destinations = open;
                    //}
                    //else if (rush.Length != 0 & rush != null)
                    //{
                    //    destinations = rush;
                    //}
                    //else if (early.Length != 0 & early != null)
                    //{
                    //    destinations = early;
                    //}
                    //else if (tooEarly.Length != 0 & tooEarly != null)
                    //{
                    //    destinations = tooEarly;
                    //}
                    //else
                    //{
                    //    destinations = tooLate;
                    //}


                    //return;
                }


                if (open.Length != 0 & open != null) // Has allocation is in OPEN state
                {
                    // Sorted by Flight Allocation
                    reason = ClassParameters.SortReasonALLO;
                    destinations = open;

                    if (_logger.IsInfoEnabled)
                    {
                        if (status == 7)
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Master FLT:" + allocations[0].Airline + allocations[0].FlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer + 
                                    "] Allocation is OPEN. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                        else
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Slave FLT:" + allocations[0].Airline + allocations[0].FlightNumber +
                                    ", Master FLT:" + allocations[0].MasterAirline + allocations[0].MasterFlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer + 
                                    "] Allocation is OPEN. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                    }
                }
                else if (rush.Length != 0 & rush != null) // Don't have allocation is in OPEN state, then check RUSH state
                {
                    if (AirlineRushAllocEnabled)
                    {              
                        // Get Airline Rush Allocation                      
                        // Query destination and its Subsystem from Airline Rush Allocation
                        LocationID[] temp = GetDestinationOfAirlineRush(validTag.AirlineCode, false, tts);

                        // If invalid destination (Nothing is returned) of given function  
                        // allocation type is returned, use global rush
                        if ((temp == null) | (temp.Length == 0))
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer + 
                                        "] Airline RUSH sortation is enabled but no allocation can be found. Check for Global Rush Sortation.<" + thisMethod + ">");

                            if (GlobalRushAllocEnabled)
                            {
                                if (_logger.IsInfoEnabled)
                                    _logger.Info("[Channel:" + channelName +
                                            "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                            ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                            ", Onward Transfer Status:" + allocations[0].OnwardTransfer + 
                                            "] Global RUSH sortation is enabled. Sorted as per RUSH function allocation. <" + thisMethod + ">");

                                // Sorted by Rush Bag Functional allocation
                                reason = ClassParameters.SortReasonRUSH;
                                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationRUSH,
                                                    currentLocation, ref destinations, mesLocation, out isMES, tts);
                            }
                            else
                            {
                                if (_logger.IsInfoEnabled)
                                    _logger.Info("[Channel:" + channelName +
                                            "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                            ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                            ", Onward Transfer Status:" + allocations[0].OnwardTransfer + 
                                            "] Global RUSH sortation is disabled. Sorted as per flight allocation. <" + thisMethod + ">");

                                // Sorted by Flight Allocation
                                reason = ClassParameters.SortReasonALLO;
                                destinations = rush;
                            }
                        }
                        else
                        {
                            // Re-order destination according to function allocation sortation 
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer + 
                                        "] Airline RUSH sortation is enabled. Sorted as per RUSH function allocation. <" + thisMethod + ">");

                            // Sorted by Rush Bag Functional allocation
                            reason = ClassParameters.SortReasonRUSH;    
                            //destinations = ReOrderDestinationSequence(ref reason, channelName, gid,
                            //                currentLocation, ref temp, SortSchemeFuncAlloc, ClassParameters.FuncAllocationRUSH, false, false, tts);
                            destinations = temp;
                        }


                    }
                    else  // If Global Rush sortation is disabled, then sort bag as normal flight allocaction.
                    {
                        if (GlobalRushAllocEnabled)
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer + 
                                        "] Global RUSH sortation is enabled. Sorted as per RUSH function allocation. <" + thisMethod + ">");

                            // Sorted by Rush Bag Functional allocation
                            reason = ClassParameters.SortReasonRUSH;
                            GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationRUSH,
                                                currentLocation, ref destinations, mesLocation, out isMES, tts);
                        }
                        else
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer + 
                                        "] Airline and Global RUSH sortation is disbaled. Sorted as per flight allocation. <" + thisMethod + ">");

                            // Sorted by Flight Allocation
                            reason = ClassParameters.SortReasonALLO;
                            destinations = rush;
                        }
                    }

                    if (_logger.IsInfoEnabled)
                    {
                        if (status == 7)
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Master FLT:" + allocations[0].Airline + allocations[0].FlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer + 
                                    "] Allocation is RUSH. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                        else
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Slave FLT:" + allocations[0].Airline + allocations[0].FlightNumber +
                                    ", Master FLT:" + allocations[0].MasterAirline + allocations[0].MasterFlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer + 
                                    "] Allocation is RUSH. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                    }
                }
                else if (tooEarly.Length != 0 & tooEarly != null)// Don't have allocation of common travel class is in EARLY state, then check TOO-EARLY state
                {
                    if (EarlyOpenEnabled)
                    {
                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] TOO EARLY sortation is enabled. Sorted as per TOO EARLY function allocation. <" + thisMethod + ">");

                        // Sorted by Too Early Bag Functional allocation
                        reason = ClassParameters.SortReasonTERL;
                        GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationTERL,
                                            currentLocation, ref destinations, mesLocation, out isMES, tts);
                    }
                    else  // If Too Early sortation is disabled, then sort bag as normal flight allocaction.
                    {
                        if (EarlyEnabled)
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                        "] TOO EARLY sortation is disbaled. Sorted as per EARLY function allocation. <" + thisMethod + ">");

                            // Sorted by Early Bag Functional allocation
                            reason = ClassParameters.SortReasonERLY;
                            GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationERLY,
                                                currentLocation, ref destinations, mesLocation, out isMES, tts);
                        }
                        else  // If Early sortation is disabled, then sort bag as normal flight allocaction.
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                        "] TOO EARLY sortation is disbaled and EARLY sortation is disbaled. Sorted as per flight allocation. <" + thisMethod + ">");

                            // Sorted by Flight Allocation
                            reason = ClassParameters.SortReasonALLO;
                            destinations = tooEarly;
                        }
                    }

                    if (_logger.IsInfoEnabled)
                    {
                        if (status == 7)
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Master FLT:" + allocations[0].Airline + allocations[0].FlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is TOO EARLY. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                        else
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Slave FLT:" + allocations[0].Airline + allocations[0].FlightNumber +
                                    ", Master FLT:" + allocations[0].MasterAirline + allocations[0].MasterFlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is TOO EARLY. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                    }
                }
                else  // If all allocations have been closed, then sort this bag to Too-Late function allocation.
                {
                    bool isTooLate = false;
                    destinations = null;

                    LookupLateAllocatedDestination(status, channelName, gid, validTag, currentLocation,
                        bsmTravelClass, ref originalAllocations, ref reason, ref destinations, out isFunction,
                        out isMES, tts, out isTooLate);

                    if ((destinations == null))
                    {
                        isTooLate = true;

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] It is too late bag, it will set isTooLate = " + isTooLate.ToString() + ". <" + thisMethod + ">");
                    }

                    if (isTooLate)
                    {
                        if (LateEnabled)
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                        "] TOO LATE sortation is enabled. Sorted as per TOO LATE function allocation. <" + thisMethod + ">");

                            // Sorted by Too Late Bag Functional allocation
                            reason = ClassParameters.SortReasonLATE;
                            GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationLATE,
                                                currentLocation, ref destinations, mesLocation, out isMES, tts);
                        }
                        else  // If Too Late sortation is disabled, then sort bag as normal flight allocaction.
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                        "] TOO LATE sortation is disbaled. Sorted as per flight allocation. <" + thisMethod + ">");

                            // Sorted by Flight Allocation
                            reason = ClassParameters.SortReasonALLO;
                            destinations = tooLate;
                        }

                        if (_logger.IsInfoEnabled)
                        {
                            if (status == 7)
                            {
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Master FLT:" + allocations[0].Airline + allocations[0].FlightNumber + "_" +
                                        allocations[0].STD.ToString() +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                        "] Allocation is closed. TOO LATE Destination: (" +
                                        Utilities.LocationIDArrayToString(ref destinations) +
                                        "). <" + thisMethod + ">");
                            }
                            else
                            {
                                _logger.Info("[Channel:" + channelName +
                                        "] [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Slave FLT:" + allocations[0].Airline + allocations[0].FlightNumber +
                                        ", Master FLT:" + allocations[0].MasterAirline + allocations[0].MasterFlightNumber + "_" +
                                        allocations[0].STD.ToString() +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                        "] Allocation is closed. TOO LATE Destination: (" +
                                        Utilities.LocationIDArrayToString(ref destinations) +
                                        "). <" + thisMethod + ">");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Lookup Allocated Destination For LP is failure! <" + thisMethod + ">", ex);
            }
        }

        /// <summary>
        /// Get Destination Of Airline Rush 
        /// isMesUsed - true (when is 2 digits IATA Ailine code use), false (when is 3 digits numeric from Tag)
        /// </summary>
        /// <param name="airlineCode"></param>
        /// <param name="isMesUsed"></param>
        /// <param name="tts"></param>
        /// <returns></returns>
        public LocationID[] GetDestinationOfAirlineRush(string airlineCode, bool isMesUsed, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlDataReader reader = null;

            List<LocationID> destinations = new List<LocationID>();
            LocationID temp = new LocationID();

            try
            {
                string sConnectionString = string.Empty;

                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetAirlineRush, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@AirlineCode", SqlDbType.VarChar, 4);
                sqlCmd.Parameters["@AirlineCode"].Value = airlineCode;

                sqlCmd.Parameters.Add("@Sorter", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@Sorter"].Value = tts;

                sqlCmd.Parameters.Add("@IsUseInMES", SqlDbType.Bit);
                sqlCmd.Parameters["@IsUseInMES"].Value = isMesUsed;

                sqlConn.Open();
                reader = sqlCmd.ExecuteReader();

                while (reader.Read())
                {
                    temp.Subsystem = string.Empty;
                    temp.Location = string.Empty;

                    if (reader[ClassParameters.ColumnDestination] != DBNull.Value)
                    {
                        temp.Location = reader[ClassParameters.ColumnDestination].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                    {
                        temp.Subsystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                    }

                    destinations.Add(temp);
                }

                return destinations.ToArray();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Bag Information failure! <" + thisMethod + ">", ex);

                return null;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Bag Information failure! <" + thisMethod + ">", ex);

                return null;
            }
            finally
            {
                if (reader != null) reader.Close();
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Lookup Late Allocated Destination
        /// </summary>
        /// <param name="status"></param>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="validTag"></param>
        /// <param name="currentLocation"></param>
        /// <param name="bsmTravelClass"></param>
        /// <param name="allocations"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="isFunction"></param>
        /// <param name="isMES"></param>    
        /// <param name="tts"></param>  
        /// <param name="isTooLate"></param>  
        private void LookupLateAllocatedDestination(int status, string channelName, string gid, Tag validTag, LocationID currentLocation,
                string bsmTravelClass, ref AllocationProperty[] allocations, ref string reason, ref LocationID[] destinations, out bool isFunction,
                out bool isMES, string tts, out bool isTooLate)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            isMES = false;
            isFunction = false;
            isTooLate = false;

            List<LocationID> listTooEarly = new List<LocationID>();
            List<LocationID> listEarly = new List<LocationID>();
            List<LocationID> listOpen = new List<LocationID>();
            List<LocationID> listRush = new List<LocationID>();
            List<LocationID> listTooLate = new List<LocationID>();

            LocationID[] tooEarly;
            LocationID[] early;
            LocationID[] open;
            LocationID[] rush;
            LocationID[] tooLate;

            LocationID tempLocationID;

            if (allocations == null)
            {
                destinations = null;
                isTooLate = true;
                return;
            }

            int lengthAllocation = allocations.Length;
            if (lengthAllocation == 0)
            {
                destinations = null;
                isTooLate = true;
                return;
            }

            LocationID[] mesLocation = null;

            if (tts == TTS01_SUBSYSTEM)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
            }

            try
            {
                for (int i = 0; i < lengthAllocation; i++)
                {
                    BagStates allocationStates;

                    // Compare with time NOW to check allocation states.
                    allocationStates = allocations[i].BagStateChecking(DateTime.Now);

                    //  List out allocations of common class (*)                  
                    switch (allocationStates)
                    {
                        case BagStates.TooEarly:
                            tempLocationID = new LocationID();
                            tempLocationID.Location = allocations[i].Resource;
                            tempLocationID.Subsystem = allocations[i].SubSystem;

                            if (ChuteAvailableCheck(tempLocationID) == true)
                            {
                                listTooEarly.Add(tempLocationID);
                            }

                            isFunction = true;

                            break;
                        case BagStates.Early:
                            tempLocationID = new LocationID();
                            tempLocationID.Location = allocations[i].Resource;
                            tempLocationID.Subsystem = allocations[i].SubSystem;

                            if (ChuteAvailableCheck(tempLocationID) == true)
                            {
                                listEarly.Add(tempLocationID);
                            }

                            isFunction = true;

                            break;
                        case BagStates.Open:
                            tempLocationID = new LocationID();
                            tempLocationID.Location = allocations[i].Resource;
                            tempLocationID.Subsystem = allocations[i].SubSystem;
                            if (ChuteAvailableCheck(tempLocationID) == true)
                            {
                                listOpen.Add(tempLocationID);
                            }
                            isFunction = false;

                            break;
                        case BagStates.Rush:
                            tempLocationID = new LocationID();
                            tempLocationID.Location = allocations[i].Resource;
                            tempLocationID.Subsystem = allocations[i].SubSystem;
                            if (ChuteAvailableCheck(tempLocationID) == true)
                            {
                                listRush.Add(tempLocationID);
                            }
                            isFunction = true;

                            break;
                        case BagStates.TooLate:
                            tempLocationID = new LocationID();
                            tempLocationID.Location = allocations[i].Resource;
                            tempLocationID.Subsystem = allocations[i].SubSystem;
                            if (ChuteAvailableCheck(tempLocationID) == true)
                            {
                                listTooLate.Add(tempLocationID);
                            }
                            isFunction = true;

                            break;
                    }
                }

                tooEarly = listTooEarly.ToArray();
                early = listEarly.ToArray();
                open = listOpen.ToArray();
                rush = listRush.ToArray();
                tooLate = listTooLate.ToArray();

                List<AllocationProperty> priorityAllocations = new List<AllocationProperty>();
                List<AllocationProperty> orginalAllocations = new List<AllocationProperty>();
                int currentPriority = 0;
                List<AllocationProperty[]> allPriorityAllocations = new List<AllocationProperty[]>();

                foreach (AllocationProperty temp in allocations)
                {
                    orginalAllocations.Add(temp);
                }

                priorityAllocations = GetPriorityOfFlightAllocation(orginalAllocations, ref allocations,
                        ref currentPriority, ref allPriorityAllocations);

                // Rush State
                if (rush.Length != 0 & rush != null)
                {
                    int rushCount = 0;
                    int priority = -1;
                    AllocationProperty tempAllocations = null;
                    List<LocationID> tempDestinations = new List<LocationID>();
                    LocationID tempDestination = new LocationID();

                    for (int i = 0; i < rush.Length; i++)
                    {
                        for (int j = 0; j < priorityAllocations.Count; j++)
                        {
                            if ((rush[i].Subsystem == priorityAllocations[j].SubSystem) & (rush[i].Location == priorityAllocations[j].Resource))
                            {
                                if (rushCount == 0)
                                {
                                    tempDestination.Subsystem = priorityAllocations[j].SubSystem;
                                    tempDestination.Location = priorityAllocations[j].Resource;
                                    tempDestinations.Add(tempDestination);
                                    priority = priorityAllocations[j].Priority;
                                    tempAllocations = priorityAllocations[j];
                                    rushCount = rushCount + 1;
                                }
                                else if ((rushCount == 1) | (rushCount == 2))
                                {
                                    if (priority == priorityAllocations[j].Priority)
                                    {
                                        if ((tempAllocations.BagType == priorityAllocations[j].BagType) &
                                            (tempAllocations.PassengerDestination == priorityAllocations[j].PassengerDestination) &
                                            (tempAllocations.TravelClass == priorityAllocations[j].TravelClass) &
                                            (tempAllocations.OnwardTransfer == priorityAllocations[j].OnwardTransfer))
                                        {
                                            tempDestination.Subsystem = priorityAllocations[j].SubSystem;
                                            tempDestination.Location = priorityAllocations[j].Resource;
                                            tempDestinations.Add(tempDestination);
                                            priority = priorityAllocations[j].Priority;
                                            rushCount = rushCount + 1;
                                        }
                                        else
                                        {
                                            destinations = tempDestinations.ToArray();
                                            break;
                                        }
                                    }
                                    else
                                    {
                                        destinations = tempDestinations.ToArray();
                                        break;
                                    }
                                }
                                else
                                {
                                    destinations = tempDestinations.ToArray();
                                    break;
                                }
                            }
                        }

                        if (destinations != null)
                        {
                            break;
                        }

                        if ((destinations == null) & (i == rush.Length - 1))
                        {
                            destinations = tempDestinations.ToArray();
                        }
                    }
                }


                if (destinations != null)
                {
                    if (AirlineRushAllocEnabled)
                    {
                        // Get Airline Rush Allocation                      
                        // Query destination and its Subsystem from Airline Rush Allocation
                        LocationID[] temp = GetDestinationOfAirlineRush(validTag.AirlineCode, false, tts);

                        // If invalid destination (Nothing is returned) of given function  
                        // allocation type is returned, use global rush
                        if ((temp == null) | (temp.Length == 0))
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] This flight allocation is Late but it has other criteria in RUSH State." +
                                        " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                        "] Airline RUSH sortation is enabled but no allocation can be found. Check for Global Rush Sortation.<" + thisMethod + ">");

                            if (GlobalRushAllocEnabled)
                            {
                                if (_logger.IsInfoEnabled)
                                    _logger.Info("[Channel:" + channelName +
                                            "] This flight allocation is Late but it has other criteria in RUSH State." +
                                            " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                            ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                            ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                            "] Global RUSH sortation is enabled. Sorted as per RUSH function allocation. <" + thisMethod + ">");

                                // Sorted by Rush Bag Functional allocation
                                reason = ClassParameters.SortReasonRUSH;
                                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationRUSH,
                                                    currentLocation, ref destinations, mesLocation, out isMES, tts);
                            }
                            else
                            {
                                if (_logger.IsInfoEnabled)
                                    _logger.Info("[Channel:" + channelName +
                                            "] This flight allocation is Late but it has other criteria in RUSH State." +
                                            " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                            ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                            ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                            "] Global RUSH sortation is disabled. Sorted as per flight allocation. <" + thisMethod + ">");

                                // Sorted by Flight Allocation
                                reason = ClassParameters.SortReasonALLO;
                            }
                        }
                        else
                        {
                            // Re-order destination according to function allocation sortation 
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] This flight allocation is Late but it has other criteria in RUSH State." +
                                        " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                        "] Airline RUSH sortation is enabled. Sorted as per RUSH function allocation. <" + thisMethod + ">");

                            // Sorted by Rush Bag Functional allocation
                            reason = ClassParameters.SortReasonRUSH;
                            //destinations = ReOrderDestinationSequence(ref reason, channelName, gid,
                            //                currentLocation, ref temp, SortSchemeFuncAlloc, ClassParameters.FuncAllocationRUSH, false, false, tts);
                            destinations = temp;
                        }


                    }
                    else  // If Global Rush sortation is disabled, then sort bag as normal flight allocaction.
                    {
                        if (GlobalRushAllocEnabled)
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] This flight allocation is Late but it has other criteria in RUSH State." +
                                        " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                        "] Global RUSH sortation is enabled. Sorted as per RUSH function allocation. <" + thisMethod + ">");

                            // Sorted by Rush Bag Functional allocation
                            reason = ClassParameters.SortReasonRUSH;
                            GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationRUSH,
                                                currentLocation, ref destinations, mesLocation, out isMES, tts);
                        }
                        else
                        {
                            if (_logger.IsInfoEnabled)
                                _logger.Info("[Channel:" + channelName +
                                        "] This flight allocation is Late but it has other criteria in RUSH State." +
                                        " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                        ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                        ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                        "] Airline and Global RUSH sortation is disbaled. Sorted as per flight allocation. <" + thisMethod + ">");

                            // Sorted by Flight Allocation
                            reason = ClassParameters.SortReasonALLO;
                        }
                    }

                    if (_logger.IsInfoEnabled)
                    {
                        if (status == 7)
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in RUSH State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Master FLT:" + allocations[0].Airline + allocations[0].FlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is RUSH. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                        else
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in RUSH State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Slave FLT:" + allocations[0].Airline + allocations[0].FlightNumber +
                                    ", Master FLT:" + allocations[0].MasterAirline + allocations[0].MasterFlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is RUSH. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                    }
                    return;
                }

                // Open State
                if (open.Length != 0 & open != null)
                {
                    int openCount = 0;
                    int priority = -1;
                    AllocationProperty tempAllocations = null;
                    List<LocationID> tempDestinations = new List<LocationID>();
                    LocationID tempDestination = new LocationID();

                    for (int i = 0; i < open.Length; i++)
                    {
                        for (int j = 0; j < priorityAllocations.Count; j++)
                        {
                            if ((open[i].Subsystem == priorityAllocations[j].SubSystem) & (open[i].Location == priorityAllocations[j].Resource))
                            {
                                if (openCount == 0)
                                {
                                    tempDestination.Subsystem = priorityAllocations[j].SubSystem;
                                    tempDestination.Location = priorityAllocations[j].Resource;
                                    tempDestinations.Add(tempDestination);
                                    priority = priorityAllocations[j].Priority;
                                    tempAllocations = priorityAllocations[j];
                                    openCount = openCount + 1;
                                }
                                else if ((openCount == 1) | (openCount == 2))
                                {
                                    if (priority == priorityAllocations[j].Priority)
                                    {
                                        if ((tempAllocations.BagType == priorityAllocations[j].BagType) &
                                            (tempAllocations.PassengerDestination == priorityAllocations[j].PassengerDestination) &
                                            (tempAllocations.TravelClass == priorityAllocations[j].TravelClass) &
                                            (tempAllocations.OnwardTransfer == priorityAllocations[j].OnwardTransfer))
                                        {
                                            tempDestination.Subsystem = priorityAllocations[j].SubSystem;
                                            tempDestination.Location = priorityAllocations[j].Resource;
                                            tempDestinations.Add(tempDestination);
                                            priority = priorityAllocations[j].Priority;
                                            openCount = openCount + 1;
                                        }
                                        else
                                        {
                                            destinations = tempDestinations.ToArray();
                                            break;
                                        }
                                    }
                                    else
                                    {
                                        destinations = tempDestinations.ToArray();
                                        break;
                                    }
                                }
                                else
                                {
                                    destinations = tempDestinations.ToArray();
                                    break;
                                }
                            }
                        }

                        if (destinations != null)
                        {
                            break;
                        }

                        if ((destinations == null) & (i == open.Length - 1))
                        {
                            destinations = tempDestinations.ToArray();
                        }
                    }
                }



                if (destinations != null)
                {
                    // Sorted by Flight Allocation
                    reason = ClassParameters.SortReasonALLO;

                    if (_logger.IsInfoEnabled)
                    {
                        if (status == 7)
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in OPEN State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Master FLT:" + allocations[0].Airline + allocations[0].FlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is OPEN. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                        else
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in OPEN State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Slave FLT:" + allocations[0].Airline + allocations[0].FlightNumber +
                                    ", Master FLT:" + allocations[0].MasterAirline + allocations[0].MasterFlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is OPEN. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                    }
                    return;
                }


                // Early State
                if (early.Length != 0 & early != null)
                {
                    int earlyCount = 0;
                    int priority = -1;
                    AllocationProperty tempAllocations = null;
                    List<LocationID> tempDestinations = new List<LocationID>();
                    LocationID tempDestination = new LocationID();

                    for (int i = 0; i < early.Length; i++)
                    {
                        for (int j = 0; j < priorityAllocations.Count; j++)
                        {
                            if ((early[i].Subsystem == priorityAllocations[j].SubSystem) & (early[i].Location == priorityAllocations[j].Resource))
                            {
                                if (earlyCount == 0)
                                {
                                    tempDestination.Subsystem = priorityAllocations[j].SubSystem;
                                    tempDestination.Location = priorityAllocations[j].Resource;
                                    tempDestinations.Add(tempDestination);
                                    priority = priorityAllocations[j].Priority;
                                    tempAllocations = priorityAllocations[j];
                                    earlyCount = earlyCount + 1;
                                }
                                else if ((earlyCount == 1) | (earlyCount == 2))
                                {
                                    if (priority == priorityAllocations[j].Priority)
                                    {
                                        if ((tempAllocations.BagType == priorityAllocations[j].BagType) &
                                            (tempAllocations.PassengerDestination == priorityAllocations[j].PassengerDestination) &
                                            (tempAllocations.TravelClass == priorityAllocations[j].TravelClass) &
                                            (tempAllocations.OnwardTransfer == priorityAllocations[j].OnwardTransfer))
                                        {
                                            tempDestination.Subsystem = priorityAllocations[j].SubSystem;
                                            tempDestination.Location = priorityAllocations[j].Resource;
                                            tempDestinations.Add(tempDestination);
                                            priority = priorityAllocations[j].Priority;
                                            earlyCount = earlyCount + 1;
                                        }
                                        else
                                        {
                                            destinations = tempDestinations.ToArray();
                                            break;
                                        }
                                    }
                                    else
                                    {
                                        destinations = tempDestinations.ToArray();
                                        break;
                                    }
                                }
                                else
                                {
                                    destinations = tempDestinations.ToArray();
                                    break;
                                }
                            }
                        }

                        if (destinations != null)
                        {
                            break;
                        }

                        if ((destinations == null) & (i == early.Length - 1))
                        {
                            destinations = tempDestinations.ToArray();
                        }
                    }
                }


                if (destinations != null)
                {
                    if (EarlyEnabled)
                    {
                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in Early State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] EARLY sortation is enabled. Sorted as per EARLY function allocation. <" + thisMethod + ">");

                        // Sorted by Early Bag Functional allocation
                        reason = ClassParameters.SortReasonERLY;
                        GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationERLY,
                                            currentLocation, ref destinations, mesLocation, out isMES, tts);
                    }
                    else  // If Early sortation is disabled, then sort bag as normal flight allocaction.
                    {
                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in Early State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] EARLY sortation is disbaled. Sorted as per flight allocation. <" + thisMethod + ">");

                        // Sorted by Flight Allocation
                        reason = ClassParameters.SortReasonALLO;
                    }

                    if (_logger.IsInfoEnabled)
                    {
                        if (status == 7)
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in Early State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Master FLT:" + allocations[0].Airline + allocations[0].FlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is EARLY. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                        else
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in Early State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Slave FLT:" + allocations[0].Airline + allocations[0].FlightNumber +
                                    ", Master FLT:" + allocations[0].MasterAirline + allocations[0].MasterFlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is EARLY. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                    }
                    return;
                }

                // Too Early State
                if (tooEarly.Length != 0 & tooEarly != null)
                {
                    int tooEarlyCount = 0;
                    int priority = -1;
                    AllocationProperty tempAllocations = null;
                    List<LocationID> tempDestinations = new List<LocationID>();
                    LocationID tempDestination = new LocationID();

                    for (int i = 0; i < tooEarly.Length; i++)
                    {
                        for (int j = 0; j < priorityAllocations.Count; j++)
                        {
                            if ((tooEarly[i].Subsystem == priorityAllocations[j].SubSystem) & (tooEarly[i].Location == priorityAllocations[j].Resource))
                            {
                                if (tooEarlyCount == 0)
                                {
                                    tempDestination.Subsystem = priorityAllocations[j].SubSystem;
                                    tempDestination.Location = priorityAllocations[j].Resource;
                                    tempDestinations.Add(tempDestination);
                                    priority = priorityAllocations[j].Priority;
                                    tempAllocations = priorityAllocations[j];
                                    tooEarlyCount = tooEarlyCount + 1;
                                }
                                else if ((tooEarlyCount == 1) | (tooEarlyCount == 2))
                                {
                                    if (priority == priorityAllocations[j].Priority)
                                    {
                                        if ((tempAllocations.BagType == priorityAllocations[j].BagType) &
                                            (tempAllocations.PassengerDestination == priorityAllocations[j].PassengerDestination) &
                                            (tempAllocations.TravelClass == priorityAllocations[j].TravelClass) &
                                            (tempAllocations.OnwardTransfer == priorityAllocations[j].OnwardTransfer))
                                        {
                                            tempDestination.Subsystem = priorityAllocations[j].SubSystem;
                                            tempDestination.Location = priorityAllocations[j].Resource;
                                            tempDestinations.Add(tempDestination);
                                            priority = priorityAllocations[j].Priority;
                                            tooEarlyCount = tooEarlyCount + 1;
                                        }
                                        else
                                        {
                                            destinations = tempDestinations.ToArray();
                                            break;
                                        }
                                    }
                                    else
                                    {
                                        destinations = tempDestinations.ToArray();
                                        break;
                                    }
                                }
                                else
                                {
                                    destinations = tempDestinations.ToArray();
                                    break;
                                }
                            }
                        }

                        if (destinations != null)
                        {
                            break;
                        }

                        if ((destinations == null) & (i == tooEarly.Length - 1))
                        {
                            destinations = tempDestinations.ToArray();
                        }
                    }
                }


                if (destinations != null)
                {
                    if (EarlyOpenEnabled)
                    {
                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in TOO Early State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] TOO EARLY sortation is enabled. Sorted as per TOO EARLY function allocation. <" + thisMethod + ">");

                        // Sorted by Too Early Bag Functional allocation
                        reason = ClassParameters.SortReasonTERL;
                        GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationTERL,
                                            currentLocation, ref destinations, mesLocation, out isMES, tts);
                    }
                    else  // If Too Early sortation is disabled, then sort bag as normal flight allocaction.
                    {
                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in TOO Early State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] TOO EARLY sortation is disbaled. Sorted as per flight allocation. <" + thisMethod + ">");

                        // Sorted by Flight Allocation
                        reason = ClassParameters.SortReasonALLO;
                    }

                    if (_logger.IsInfoEnabled)
                    {
                        if (status == 7)
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in TOO Early State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Master FLT:" + allocations[0].Airline + allocations[0].FlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is TOO EARLY. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                        else
                        {
                            _logger.Info("[Channel:" + channelName +
                                    "] This flight allocation is Late but it has other criteria in TOO Early State." +
                                    " [GID:" + gid + ", LP:" + validTag.LP + ", Class:" + bsmTravelClass +
                                    ", Slave FLT:" + allocations[0].Airline + allocations[0].FlightNumber +
                                    ", Master FLT:" + allocations[0].MasterAirline + allocations[0].MasterFlightNumber + "_" +
                                    allocations[0].STD.ToString() +
                                    ", Bag Type:" + allocations[0].BagType + ", Flight Destination:" + allocations[0].PassengerDestination +
                                    ", Onward Transfer Status:" + allocations[0].OnwardTransfer +
                                    "] Allocation is TOO EARLY. Destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                        }
                    }
                    return;
                }

                if (tooLate.Length != 0 & tooLate != null)     // If all allocations have been closed, then sort this bag to Too-Late function allocation.
                {
                    isTooLate = true;
                    return;
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Lookup Allocated Destination For LP is failure! <" + thisMethod + ">", ex);
            }
        }

        /// <summary>
        /// Get Sorted Dest Of Function Allocation
        /// </summary>
        /// <param name="reason"></param>
        /// <param name="gid"></param>
        /// <param name="channelName"></param>
        /// <param name="functionType"></param>
        /// <param name="currentLocation"></param>
        /// <param name="destinations"></param>
        /// <param name="alternatives"></param>
        /// <param name="isMES"></param>
        /// <param name="tts"></param>
        public void GetSortedDestOfFunctionAllocation(ref string reason, string gid, string channelName,
            string functionType, LocationID currentLocation, ref LocationID[] destinations, LocationID[] alternatives, out bool isMES,
            string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            isMES = false;

            // 1. Query destination and its Subsystem of given Function Allocation 
            //    type from table [FUNCTION_ALLOC_GANTT], [FUNCTION_ALLOC_LIST]
            LocationID[] temp = GetDestinationOfFunctionAllocation(functionType, string.Empty, ref isMES, tts);

            // 2. If invalid destination (Nothing is returned) of given function  
            //    allocation type is returned, assign pre-set alternative destination
            //    to it.
            if ((temp == null) | (temp.Length == 0))
            {
                temp = alternatives;
                isMES = true;

                if (_logger.IsWarnEnabled)
                    _logger.Warn("[DEBUG] There is no destination was defined for " +
                            "Function Allocation (" + functionType +
                            ")! The pre-set destination will be assigned to it. <" + thisMethod + ">");
            }

            // 3. Re-order destination according to function allocation sortation 
            //    scheme (nearest first algorithm);
            //destinations = ReOrderDestinationSequence(ref reason, channelName, gid,
            //                currentLocation, ref temp, SortSchemeFuncAlloc, functionType, false, isMES, tts);
            destinations = temp;
        }

        /// <summary>
        /// Get allocated destinations of PROB (Problem Bag) function allocation.
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfPROB(string channelName, string gid, LocationID currentLocation,
                ref string reason, ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] mesLocation = null;
            string funcAllocProb = string.Empty;

            if (tts == TTS01_SUBSYSTEM)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
                funcAllocProb = ClassParameters.FuncAllocationPB01;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
                funcAllocProb = ClassParameters.FuncAllocationPB02;
            }


            try
            {
                // Sorted by Problem Bag. (PROB)
                reason = ClassParameters.SortReasonPROB;

                //Get the destination of PROB (Problem Bag) function allocation type 
                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, funcAllocProb,
                            currentLocation, ref destinations, mesLocation, tts);

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid +
                            "] is " + funcAllocProb +
                            " item. Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "] . <" + thisMethod + ">");

            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of PROB is failure! <" + thisMethod + ">", ex);

                destinations = mesLocation;
            }
        }

        /// <summary>
        /// Get Customs Required
        /// </summary>
        /// <param name="tagType"></param>
        /// <param name="tagID"></param>
        /// <param name="defaultCustomsResult"></param>
        /// <returns></returns>
        public bool GetCustomsRequired(int tagType, string tagID, bool defaultCustomsResult)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            bool isRequired = false;

            try
            {
                string sConnectionString = string.Empty;

                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetCustomsRequired, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@IATAInterline", SqlDbType.Int);
                sqlCmd.Parameters["@IATAInterline"].Value = Convert.ToInt32(TagType.IATATag);

                sqlCmd.Parameters.Add("@IATAFallback", SqlDbType.Int);
                sqlCmd.Parameters["@IATAFallback"].Value = Convert.ToInt32(TagType.FallbackTag);

                sqlCmd.Parameters.Add("@SpecialTag", SqlDbType.Int);
                sqlCmd.Parameters["@SpecialTag"].Value = Convert.ToInt32(TagType.SecurityTag);

                sqlCmd.Parameters.Add("@FourDigitsFallaback", SqlDbType.Int);
                sqlCmd.Parameters["@FourDigitsFallaback"].Value = Convert.ToInt32(TagType.FourDigitsFallbackTag);

                sqlCmd.Parameters.Add("@InHouse", SqlDbType.Int);
                sqlCmd.Parameters["@InHouse"].Value = Convert.ToInt32(TagType.InHouseTag);

                sqlCmd.Parameters.Add("@TagType", SqlDbType.Int);
                sqlCmd.Parameters["@TagType"].Value = tagType;

                sqlCmd.Parameters.Add("@TagID", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@TagID"].Value = tagID;

                sqlCmd.Parameters.Add("@DefaultCustomsRequirement", SqlDbType.Bit);
                sqlCmd.Parameters["@DefaultCustomsRequirement"].Value = defaultCustomsResult;

                sqlCmd.Parameters.Add("@IsCustomRequired", SqlDbType.Bit);
                sqlCmd.Parameters["@IsCustomRequired"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@IsCustomRequired"].Value != DBNull.Value)
                {
                    isRequired = Convert.ToBoolean(sqlCmd.Parameters["@IsCustomRequired"].Value.ToString().Trim());
                }

                return isRequired;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Customs Required From DB failure! <" + thisMethod + ">", ex);

                return isRequired;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Customs Required From DB failure! <" + thisMethod + ">", ex);

                return isRequired;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// To get the function allocaiton destionation from database
        /// By default exception = string.Empty if it is not in uses
        /// </summary>
        /// <param name="functionType"></param>
        /// <param name="exception"></param>
        /// <param name="isMES"></param>
        /// <param name="tts"></param>
        /// <returns></returns>
        public LocationID[] GetDestinationOfFunctionAllocation(string functionType, string exception, ref bool isMES, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlDataReader reader = null;
            List<LocationID> locations = new List<LocationID>();
            isMES = false;

            try
            {
                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }
                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetFunctionAllocation, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@Type", SqlDbType.VarChar, 4);
                sqlCmd.Parameters["@Type"].Value = functionType;

                sqlCmd.Parameters.Add("@Exception", SqlDbType.VarChar, 10);

                sqlCmd.Parameters.Add("@NeedException", SqlDbType.Bit);

                if (exception == string.Empty)
                {
                    sqlCmd.Parameters["@Exception"].Value = DBNull.Value;
                    sqlCmd.Parameters["@NeedException"].Value = false;

                }
                else
                {
                    sqlCmd.Parameters["@Exception"].Value = exception;
                    sqlCmd.Parameters["@NeedException"].Value = true;
                }

                sqlCmd.Parameters.Add("@Sorter", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@Sorter"].Value = tts;


                sqlCmd.Parameters.Add("@Result", SqlDbType.Int);
                sqlCmd.Parameters["@Result"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@IsMES", SqlDbType.Bit);
                sqlCmd.Parameters["@IsMES"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                reader = sqlCmd.ExecuteReader();

                LocationID destination;

                while (reader.Read())
                {
                    destination = new LocationID();

                    if (reader[ClassParameters.ColumnResource] != DBNull.Value)
                    {
                        destination.Location = reader[ClassParameters.ColumnResource].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                    {
                        destination.Subsystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                    }

                    if (destination.Location != string.Empty)
                    {
                        locations.Add(destination);
                    }
                }

                reader.Close();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@IsMES"].Value != DBNull.Value)
                {
                    isMES = Convert.ToBoolean(sqlCmd.Parameters["@IsMES"].Value.ToString());
                }

                return locations.ToArray();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Retrieve Routing Table From DB failure! <" + thisMethod + ">", ex);

                return null;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Retrieve Routing Table From DB failure! <" + thisMethod + ">", ex);

                return null;
            }
            finally
            {
                if (reader != null) reader.Close();
                if (sqlConn != null) sqlConn.Close();
            }
        }

        ///// <summary>
        ///// Rearrange the sortdestination order, by default flightIdentifier = string.Empty
        ///// and isException = false if it is not in use
        ///// </summary>
        ///// <param name="reason"></param>
        ///// <param name="channelName"></param>
        ///// <param name="gid"></param>
        ///// <param name="currentLocation"></param>
        ///// <param name="destinations"></param>
        ///// <param name="schemeType"></param>
        ///// <param name="flightIdentifier"></param>
        ///// <param name="isException"></param>
        ///// <param name="isMES"></param>
        ///// <param name="tts"></param>
        ///// <returns></returns>
        //public LocationID[] ReOrderDestinationSequence(ref string reason, string channelName, string gid,
        //        LocationID currentLocation, ref LocationID[] destinations, string schemeType, string flightIdentifier,
        //        bool isException, bool isMES, string tts)
        //{
        //    string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
        //    LocationID[] final; // sortedDestination;
        //    List<LocationID> availableDestination = new List<LocationID>();
        //    int sumUnavailable;

        //    try
        //    {
        //        if (destinations == null)
        //        {
        //            return null;
        //        }

        //        // Reorder the destination in shortest Path
        //        //sortedDestination = SortByShortestPathScheme(currentLocation, ref destinations);
        //        //destinations = sortedDestination;

        //        // Check availabale of destination
        //        sumUnavailable = 0;
        //        for (int i = 0; i < destinations.Length; i++)
        //        {
        //            if (ChuteAvailableCheck(destinations[i]) == false)
        //            {
        //                if (_logger.IsErrorEnabled)
        //                    _logger.Error("[Channel:" + channelName +
        //                                "] [GID:" + gid +
        //                                "] with destination: [" + destinations[i].Location +
        //                                "] is unvailable.< <" + thisMethod + ">");

        //                sumUnavailable = sumUnavailable + 1;
        //            }
        //            else
        //            {
        //                availableDestination.Add(destinations[i]);
        //            }
        //        }

        //        // if unavailable go to DUMP (total unavailable = total length)
        //        if ((sumUnavailable == destinations.Length) & (isException == false))
        //        {
        //            GetDestinationOfDUMP(channelName, gid, currentLocation, ref reason, ref destinations, ref isMES, tts);

        //            for (int i = 0; i < destinations.Length; i++)
        //            {
        //                if (ChuteAvailableCheck(destinations[i]) == false)
        //                {
        //                    //if (tts == TTS01_SUBSYSTEM)
        //                    //{
        //                    //    destinations = ClassParameters.TTS01OverflowStartLocation;
        //                    //}
        //                    //else
        //                    //{
        //                    //    destinations = ClassParameters.TTS02OverflowStartLocation;
        //                    //}---------------------------------------Commented by Ramesh---2013-01-05
                            

        //                    if (_logger.IsErrorEnabled)
        //                        _logger.Error("[Channel:" + channelName +
        //                                    "] [GID:" + gid +
        //                                    "] with dump destination: [" + destinations[i] +
        //                                    "] is unvailable, it will no destination return.< <" + thisMethod + ">");

                            
        //                    return null;
        //                }
        //            }

        //            return destinations;
        //        }
        //        else if ((sumUnavailable == destinations.Length) & (isException == true))
        //        {
        //            if (_logger.IsErrorEnabled)
        //                _logger.Error("[Channel:" + channelName +
        //                            "] [GID:" + gid +
        //                            "] is " + flightIdentifier +
        //                            " item. Its exception destination: [" +
        //                            Utilities.LocationIDArrayToString(ref destinations) +
        //                            " ] unvailable/unallocated." + thisMethod + ">");

        //            return null;
        //        }
        //        else
        //        {
        //            destinations = availableDestination.ToArray();

        //            // If only single destination was given, then it is unnecessary to 
        //            // sort its sequence, just return it.
        //            if (destinations.Length == 1)
        //            {
        //                return destinations;
        //            }

        //            // If there is no current location or subsystem of current location was
        //            // specified, there is no way to re-order the destination. In this case, 
        //            // just return the original destination.
        //            if ((currentLocation.Location.Trim() == string.Empty) | (currentLocation.Subsystem.Trim() == string.Empty))
        //            {
        //                return destinations;
        //            }

        //            //// If the MES is the destination then need use SortSchemeTTS1Alloc or SortSchemeTTS2Alloc
        //            //if (isMES)
        //            //{
        //            //    if (tts == ClassParameters.TTSSorter01)
        //            //    {
        //            //        schemeType = SortSchemeTTS1Alloc;
        //            //    }
        //            //    else
        //            //    {
        //            //        schemeType = SortSchemeTTS2Alloc;
        //            //    }
        //            //}

        //            //// SortSchemeRR - swapping [Final = SortByRoundRobinScheme(flightIdentifier, ref destination)]
        //            //// SortSchemaWFByPriority
        //            //// SortSchemeWFbyShortestPath - remain the same as shortest path [Final = SortByShortestPathScheme(currentLocation, ref destinations)]
        //            //if (schemeType == ClassParameters.SchemaTypeShortestPath)
        //            //{
        //            //    final = SortByShortestPathScheme(currentLocation, ref destinations);
        //            //}
        //            //else if (schemeType == ClassParameters.SchemaTypeRoundRobin)
        //            //{
        //            //    final = SortByRoundRobinScheme(flightIdentifier, ref destinations);
        //            //}
        //            //else if ((schemeType == ClassParameters.SchemaTypeWaterfallPriority) & (isMES == true))
        //            //{
        //            //    final = SortByMESPriority(ref destinations, tts);
        //            //}
        //            //else if (schemeType == ClassParameters.SchemaTypeWaterfallShortestPath)
        //            //{
        //            //    final = SortByShortestPathScheme(currentLocation, ref destinations);
        //            //}
        //            //else
        //            //{
        //                final = destinations;
        //            //}

        //            return final;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        if (_logger.IsErrorEnabled)
        //            _logger.Error("Re-Order Destination Sequence is failure! <" + thisMethod + ">", ex);

        //        return null;
        //    }
        //}


        /// <summary>
        /// Use to check whether the Chute is available or not for the selected destination
        /// </summary>
        /// <param name="destination"></param>
        /// <param name="TTSId"></param>
        /// <returns></returns>
        public bool ChuteAvailableCheckForDestination(string destination, string TTSId, string sorter)
        {
            bool isAvailable = false;
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            if (destination.Contains("MUC") == true)
            {
                isAvailable = true;
                return isAvailable;
            }

            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
                        
            try
            {
                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }
                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPChuteAvailableCheckForDestination, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@Destination", SqlDbType.VarChar, 20);
                sqlCmd.Parameters["@Destination"].Value = destination;

                sqlCmd.Parameters.Add("@TTSID", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@TTSID"].Value = TTSId;

                sqlCmd.Parameters.Add("@Sorter", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@Sorter"].Value = sorter;
                               
                sqlCmd.Parameters.Add("@IsAvailable", SqlDbType.Bit);
                sqlCmd.Parameters["@IsAvailable"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@IsAvailable"].Value != DBNull.Value)
                {
                    isAvailable = Convert.ToBoolean(sqlCmd.Parameters["@IsAvailable"].Value.ToString());
                }

                return isAvailable;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Chute Available Check For Destination From DB failure! <" + thisMethod + ">", ex);

                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Chute Available Check For Destination From DB failure! <" + thisMethod + ">", ex);

                return false;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }


        /// <summary>
        /// Use to check whether the Chute is available or not
        /// </summary>
        /// <param name="destinations"></param>
        /// <returns></returns>
        public bool ChuteAvailableCheck(LocationID destinations)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            bool isAvailable = false;

            try
            {
                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }
                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPChuteAvailableCheck, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@SubSystem", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@SubSystem"].Value = destinations.Subsystem;

                sqlCmd.Parameters.Add("@Destination", SqlDbType.VarChar, 20);
                sqlCmd.Parameters["@Destination"].Value = destinations.Location;

                sqlCmd.Parameters.Add("@IsAvailable", SqlDbType.Bit);
                sqlCmd.Parameters["@IsAvailable"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@IsAvailable"].Value != DBNull.Value)
                {
                    isAvailable = Convert.ToBoolean(sqlCmd.Parameters["@IsAvailable"].Value.ToString());
                }

                return isAvailable;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Chute Available Check From DB failure! <" + thisMethod + ">", ex);

                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Chute Available Check From DB failure! <" + thisMethod + ">", ex);

                return false;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Get the Dump destination, if cannot get then will assigned to default destination MES
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destination"></param>
        /// <param name="isMES"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfDUMP(string channelName, string gid, LocationID currentLocation, ref string reason,
            ref LocationID[] destination, ref bool isMES, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            isMES = false;
            string funcAllocDump = string.Empty;

            try
            {
                // Sorted by Destination Unavailable
                reason = ClassParameters.SortReasonDTUA;

                if (tts == ClassParameters.TTSSorter01)
                {
                    funcAllocDump = ClassParameters.FuncAllocationDP01;
                }
                else
                {
                    funcAllocDump = ClassParameters.FuncAllocationDP02;
                }

                if (destination != null)
                {
                    foreach (LocationID temp in destination)
                    {
                        if (ClassParameters.EDSCDSChute.Contains(temp.Location) == false)
                        {
                            // Get the destination of DUMP (DUMP) function allocation type 
                            // 1. Query destination and its Subsystem of given Function Allocation 
                            //    type from table [FUNCTION_ALLOC_GANTT], [FUNCTION_ALLOC_LIST];
                            destination = GetDestinationOfFunctionAllocation(funcAllocDump, string.Empty, ref isMES, tts);
                            break;
                        }
                    }
                }
                else
                {
                    // Get the destination of DUMP (DUMP) function allocation type 
                    // 1. Query destination and its Subsystem of given Function Allocation 
                    //    type from table [FUNCTION_ALLOC_GANTT], [FUNCTION_ALLOC_LIST];
                    destination = GetDestinationOfFunctionAllocation(funcAllocDump, string.Empty, ref isMES, tts);
                }

                // 2. If invalid destination (Nothing is returned) of given function  
                //    allocation type is returned, assign pre-set alternative destination
                //    to it;
                if (destination == null)
                {
                    if (tts == TTS01_SUBSYSTEM)
                    {
                        destination = ClassParameters.TTS01MESLocation;
                    }
                    else
                    {
                        destination = ClassParameters.TTS02MESLocation;
                    }
                    isMES = true;

                    if (_logger.IsWarnEnabled)
                        _logger.Warn("[Channel:" + channelName +
                                "] There is no destination was defined for " +
                                "Function Allocation (" + funcAllocDump +
                                ")! The pre-set destination will be assigned to it. <" + thisMethod + ">");

                }

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid +
                            "] which is " + funcAllocDump +
                            " item. It will redirect to dump destination: [" +
                            Utilities.LocationIDArrayToString(ref destination) +
                            "] . <" + thisMethod + ">");
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of DUMP is failure! <" + thisMethod + ">", ex);

            }
        }


        /// <summary>
        /// Get Destination Of EDS
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="licensePlate"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfEDS(string channelName, string gid, string licensePlate, LocationID currentLocation,
                ref string reason, ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] mesLocation = null;

            if (tts == ClassParameters.TTSSorter01)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
            }

            try
            {
                // Sorted by Minumum Security Level (MSSL)
                //reason = ClassParameters.SortReasonMSSL;

                // Get the destination of EDS
                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationEDS,
                            currentLocation, ref destinations, mesLocation, tts);

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid + ", LP:" + licensePlate +
                            "] is " + ClassParameters.FuncAllocationEDS +
                            " item. Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "] . <" + thisMethod + ">");

            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of EDS is failure! <" + thisMethod + ">", ex);

                destinations = mesLocation;
            }
        }

        /// <summary>
        /// Selection Sort Numbers
        /// </summary>
        /// <param name="locations"></param>
        /// <param name="isFromSmallToLarge"></param>
        private void SelectionSortNumbers(ref LocationCost[] locations, bool isFromSmallToLarge)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            try
            {
                int min;
                LocationCost tempLocationCost;

                for (int i = 0; i < locations.Length; i++)
                {
                    min = i;
                    for (int j = i + 1; j < locations.Length; j++)
                    {
                        if (isFromSmallToLarge)
                        {
                            if (locations[j].Cost < locations[min].Cost)
                            {
                                min = j;
                            }
                        }
                        else
                        {
                            if (locations[j].Cost > locations[min].Cost)
                            {
                                min = j;
                            }
                        }
                    }

                    tempLocationCost = locations[min];
                    locations[min] = locations[i];
                    locations[i] = tempLocationCost;
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Selection Sort Numbers is failure! <" + thisMethod + ">", ex);

            }
        }

        #endregion

        /// <summary>
        /// Get bag reoccurance count From DB.
        /// </summary>
        /// <param name="licensePlate"></param>
        /// <returns></returns>
        public int GetBagReOccuranceCount(string gid, string licensePlate, string sEquipmentID)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            int ReOccuranceCount = 0;

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;

                    sqlCmd = new SqlCommand(ClassParameters.stp_MES_CHECK_BAG_REOCCURENCE, sqlConn);
                    sqlCmd.CommandType = CommandType.StoredProcedure;

                    sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                    sqlCmd.Parameters["@GID"].Value = gid;

                    sqlCmd.Parameters.Add("@LICENSE_PLATE", SqlDbType.VarChar, 10);
                    sqlCmd.Parameters["@LICENSE_PLATE"].Value = licensePlate;

                    sqlCmd.Parameters.Add("@EQUIPMENT_ID", SqlDbType.VarChar, 20);
                    sqlCmd.Parameters["@EQUIPMENT_ID"].Value = sEquipmentID;

                    sqlConn.Open();
                    ReOccuranceCount = (int)sqlCmd.ExecuteScalar();
                }

                return ReOccuranceCount;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get bag re-occurance count failure! <" + thisMethod + ">", ex);

                return ReOccuranceCount;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get bag re-occurance count failure! <" + thisMethod + ">", ex);

                return ReOccuranceCount;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Update mds alarms to true when problem bag arrives.
        /// </summary>
        /// <param name=""></param>
        public void UpdateMdsAlarmsForProblemBag(string stationName)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;

                    sqlCmd = new SqlCommand(ClassParameters.stp_MES_UPDATE_MDS_ALARMS_FOR_PROBLEM_BAG, sqlConn);
                    sqlCmd.CommandType = CommandType.StoredProcedure;

                    sqlCmd.Parameters.Add("@MES_STATION", SqlDbType.VarChar, 10);
                    sqlCmd.Parameters["@MES_STATION"].Value = stationName;

                    sqlConn.Open();
                    sqlTrans = sqlConn.BeginTransaction();
                    sqlCmd.Transaction = sqlTrans;
                    sqlCmd.ExecuteNonQuery();
                    sqlTrans.Commit();

                    _logger.Info("Updating mds alarms for problem bag success. <" + thisMethod + ">");
                }
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating mds alarms for problem bag fail! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating mds alarms for problem bag fail! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

        /// <summary>
        /// Reset all mds alarms to false.
        /// </summary>
        /// <param name=""></param>
        public void ResetMdsAlarms(string stationName)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;

                    sqlCmd = new SqlCommand("stp_MES_RESET_MDS_ALARMS", sqlConn);
                    sqlCmd.CommandType = CommandType.StoredProcedure;

                    sqlCmd.Parameters.Add("@MES_STATION", SqlDbType.VarChar, 10);
                    sqlCmd.Parameters["@MES_STATION"].Value = stationName;

                    sqlConn.Open();
                    sqlTrans = sqlConn.BeginTransaction();
                    sqlCmd.Transaction = sqlTrans;
                    sqlCmd.ExecuteNonQuery();
                    sqlTrans.Commit();

                    _logger.Info("Resetting mds alarms success. <" + thisMethod + ">");
                }
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Resetting mds alarms fail! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Resetting mds alarms fail! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
                
            }
        }


        /// <summary>
        /// Get Cancellation Of Flight
        /// </summary>
        /// <param name="licensePlate"></param>
        /// <param name="flightCancellation"></param>
        /// <param name="flightDeleted"></param>
        private void GetCancellationOfFlight(string licensePlate, out string flightCancellation, out bool flightDeleted)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            flightCancellation = string.Empty;
            flightDeleted = false;

            try
            {

                string sConnectionString = string.Empty;
                if (ClassParameters.MainDBAlive == true)
                {
                    sConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlConn = new SqlConnection(sConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetCancellationOfFlight, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@LicensePlate", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@LicensePlate"].Value = licensePlate;

                sqlCmd.Parameters.Add("@FlightCancellation", SqlDbType.VarChar, 1);
                sqlCmd.Parameters["@FlightCancellation"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@FlightDeleted", SqlDbType.Bit);
                sqlCmd.Parameters["@FlightDeleted"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@FlightCancellation"].Value != DBNull.Value)
                {
                    flightCancellation = sqlCmd.Parameters["@FlightCancellation"].Value.ToString().Trim();
                }

                if (sqlCmd.Parameters["@FlightDeleted"].Value != DBNull.Value)
                {
                    flightDeleted = Convert.ToBoolean(sqlCmd.Parameters["@FlightDeleted"].Value.ToString().Trim());
                }
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Cancellation of Flight failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Cancellation of Flight failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Get Destination of CCFL
        /// </summary>
        /// <param name="channelName"></param>
        /// <param name="gid"></param>
        /// <param name="licensePlate"></param>
        /// <param name="currentLocation"></param>
        /// <param name="reason"></param>
        /// <param name="destinations"></param>
        /// <param name="tts"></param>
        public void GetDestinationOfCCFL(string channelName, string gid, string licensePlate, LocationID currentLocation,
                ref string reason, ref LocationID[] destinations, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] mesLocation = null;

            if (tts == TTS01_SUBSYSTEM)
            {
                mesLocation = ClassParameters.TTS01MESLocation;
            }
            else
            {
                mesLocation = ClassParameters.TTS02MESLocation;
            }

            try
            {
                // Sorted by Cancallation Flight (CCFL)
                reason = ClassParameters.SortReasonCCFL;

                // Get the destination of Cancallation Flight allocation type(CCFL)
                GetSortedDestOfFunctionAllocation(ref reason, gid, channelName, ClassParameters.FuncAllocationCCFL,
                            currentLocation, ref destinations, mesLocation, tts);

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                            "] [GID:" + gid +
                            "] is " + ClassParameters.FuncAllocationCCFL +
                            " item. Its destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "] . <" + thisMethod + ">");

            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Destination Of CCFL is failure! <" + thisMethod + ">", ex);

                destinations = mesLocation;
            }
        }

        /// <summary>
        /// Generate Fallback Tag ID.
        /// </summary>
        /// <param name="sAirline"></param>
        /// <param name="sDestination"></param>
        /// <returns></returns>
        public string GenerateFallbackTag(string sAirline, string sDestination)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            string FallbackTag = string.Empty;

            try
            {
                sqlConn = new SqlConnection(ClassParameters.DBConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GENERATE_FALLBACKTAG, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@AIRLINE", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@AIRLINE"].Value = sAirline;

                sqlCmd.Parameters.Add("@DESTINATION", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@DESTINATION"].Value = sDestination;

                sqlConn.Open();
                FallbackTag = (string)sqlCmd.ExecuteScalar();

                return FallbackTag;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Generate Fallback Tag DB failure! <" + thisMethod + ">", ex);

                return FallbackTag;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Generate Fallback Tag DB failure! <" + thisMethod + ">", ex);

                return FallbackTag;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Insert pseudo bsm which generated.
        /// </summary>
        /// <param name="sLicensePlate">License Plate as type of System.string</param>
        /// <param name="sAirline">Airline for pseudo bsm as type of System.string</param>
        /// <param name="sFlightNumber">Flight number for pseudo bsm as type of System.string</param>
        /// <param name="sSDO">SDO for pseudo bsm as type of System.string</param>
        /// <param name="sDescription">Description for pseudo bsm as type of System.string</param>
        /// <param name="sMESStation">MES station name as type of System.string</param>
        /// <param name="sType">Type as System.string</param>
        public void InsertPseudoBSM(string sLicensePlate,
            string sAirline, string sFlightNumber, string sSDO, string sDescription,
            string sMESStation, string sType)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_PSEUDO_BSM, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@LICENSE_PLATE", SqlDbType.VarChar, 10);
                sqlPara1.Value = sLicensePlate;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@AIRLINE", SqlDbType.VarChar, 10);
                sqlPara2.Value = sAirline;

                SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@FLIGHT_NUMBER", SqlDbType.VarChar, 10);
                sqlPara3.Value = sFlightNumber;

                SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@SDO", SqlDbType.DateTime);
                sqlPara4.Value = Convert.ToDateTime(sSDO);

                SqlParameter sqlPara5 = sqlCmd.Parameters.Add("@DESCRIPTION", SqlDbType.VarChar, 20);
                sqlPara5.Value = sDescription;

                SqlParameter sqlPara6 = sqlCmd.Parameters.Add("@MES_STATION", SqlDbType.VarChar, 20);
                sqlPara6.Value = sMESStation;

                SqlParameter sqlPara7 = sqlCmd.Parameters.Add("@TYPE", SqlDbType.VarChar, 10);
                sqlPara7.Value = sType;

                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
                sqlTrans.Commit();
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting pseudo BSM information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting pseudo BSM information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

        public void UpdateAppLiveStatus()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                //if (ClassParameters.SecondaryDBAlive == true)
                //{
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                //}
                //else
                //{
                //    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                //}

                sqlCmd = new SqlCommand(ClassParameters.stp_UPDATE_CHANGED_CONNECTION_MONITORING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@Status", SqlDbType.VarChar, 10);
                sqlPara1.Value = ClassParameters.ApplicationLiveStatus;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@AppCode", SqlDbType.VarChar, 10);
                sqlPara2.Value = ClassParameters.AppLiveStatusUpdateKey;

                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
                sqlTrans.Commit();

                _logger.Info("Updating application live status success. <" + thisMethod + ">");
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating application live status fail! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating application live status fail! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

        public DataTable GetHBSCustomResult(string sLicensePlate, string bagGID)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet results = new DataSet();

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_HBS_RESULTS, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@LICENSE_PLATE", SqlDbType.VarChar, 10);
                sqlPara2.Value = sLicensePlate;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                sqlPara1.Value = bagGID;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlConn.Open();
                sqlAdapter.Fill(results);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get HBS and Custom result failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get HBS and Custom result failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return results.Tables[0];
        }

        public DataTable GetHBSCustomResultForButtonEnter(string sLicensePlate, string bagGID)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet results = new DataSet();

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_HBS_RESULTS_FOR_BUTTON_ENTER, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@LICENSE_PLATE", SqlDbType.VarChar, 10);
                sqlPara2.Value = sLicensePlate;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                sqlPara1.Value = bagGID;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlConn.Open();
                sqlAdapter.Fill(results);
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get HBS and Custom result failed! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get HBS and Custom result failed! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
            return results.Tables[0];
        }

        /// <summary>
        /// Get airline ticketing code.
        /// </summary>
        /// <param name="licensePlate"></param>
        /// <returns></returns>
        public string GetAirlineTicketingCode(string sAirlineCode)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            string sTicketingCode="";

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                //sqlConn = new SqlConnection(ClassParameters.DBConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_AIRLINE_CODE, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@AIRLINE", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@AIRLINE"].Value = sAirlineCode;

                sqlConn.Open();
                sTicketingCode = (string)sqlCmd.ExecuteScalar();

                return sTicketingCode;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get bag re-occurance count failure! <" + thisMethod + ">", ex);

                return sTicketingCode;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get bag re-occurance count failure! <" + thisMethod + ">", ex);

                return sTicketingCode;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Insert airline code shortcuts to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalairlinecodeshortcuts(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_AIRLINE_CODE_SHORTCUTS, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@AIRLINE_CODE_SHORTCUTS", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting airline code shortcuts data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert hbs passenger to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalhbspassenger(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_HBS_PASSENGER, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@HBS_PASSENGER", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting hbs passenger data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert hbs flight to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalhbsflight(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_HBS_FLIGHT, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@HBS_FLIGHT", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting hbs flight data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert hbs airline to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalhbsairline(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_HBS_AIRLINE, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@HBS_AIRLINE", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting hbs airline data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert hbs country to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalhbscountry(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_HBS_COUNTRY, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@HBS_COUNTRY", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting hbs country data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert hbs policy management to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalhbspolicymanagement(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_HBS_POLICY_MANAGEMENT, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@HBS_POLICY_MANAGEMENT", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting hbs policy management data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert hbs schedule to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalhbsschedule(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_HBS_SCHEDULE, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@HBS_SCHEDULE", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting hbs schedule data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert hbs tag type to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalhbstagtype(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_HBS_TAG_TYPE, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@HBS_TAG_TYPE", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting hbs tag type data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert airports to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalairports(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_AIRPORTS, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@AIRPORTS", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting airports data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        public void UpdateLogOnOffStatus()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_UPDATE_CHANGED_CONNECTION_MONITORING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@Status", SqlDbType.VarChar, 10);
                sqlPara1.Value = ClassParameters.AppLogOnOffUpdateKey;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@AppCode", SqlDbType.VarChar, 10);
                sqlPara2.Value = ClassParameters.AppLiveStatusUpdateKey;

                sqlConn.Open();
                sqlTrans = sqlConn.BeginTransaction();
                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
                sqlTrans.Commit();

                _logger.Info("Updating application live status success. <" + thisMethod + ">");
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating application live status fail! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Updating application live status fail! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

        public bool CheckUserInDomain(string sLoginUser)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            bool bReturnValue = false;
            try
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Start checking user in domain.");
                bool domainStatus = false;
                string errorMsg = string.Empty;
                LDAPManager ldapString = new LDAPManager();
                Util.categoryCode = ClassParameters.SecurityCategoryCode;
                ldapString.ContainerNames = new string[] { ClassParameters.SecurityContainerName };
                ldapString.DomainExtendsion = ClassParameters.SecurityDomainExtension;
                ldapString.DomainName = ClassParameters.SecurityDomainName;
                ldapString.OrganizationUnits = new string[] { ClassParameters.SecurityOrgName };
                ldapString.RedundantIPAddresses = ClassParameters.SecurityIPAddress.Split('/');
                string result = ldapString.GetLDAPString(out domainStatus);
                ClassParameters.IsDomainAvailable = domainStatus;
                if (_logger.IsInfoEnabled)
                    _logger.Info("Checking domain status:" + domainStatus.ToString() + " - " + result);
                if (domainStatus)
                {
                    SecurityManager securityManager = new SecurityManager(AD_DB_Actions.ADAction, result);
                    bReturnValue = securityManager.GetStatusByUser(sLoginUser, out errorMsg);
                    if (errorMsg != string.Empty)
                    {
                        if (_logger.IsErrorEnabled)
                            _logger.Error("Checking user in domain fail! <" + thisMethod + ">" + errorMsg);
                    }
                }
                if (_logger.IsInfoEnabled)
                    _logger.Info("Finished checking domain status:" + domainStatus.ToString() + " - " + result);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Checking user in domain fail! <" + thisMethod + ">", ex);
            }
            return bReturnValue;
        }

        /// <summary>
        /// Get bag with No BSM reoccurance count From DB.
        /// </summary>
        /// <param name="licensePlate"></param>
        /// <returns></returns>
        public int GetBagNoBSMReOccuranceCount(string sGID, string sLicensePlate, string sStatus, int iTotalLimit, string sStationName)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            int ReOccuranceCount = 0;

            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;

                    sqlCmd = new SqlCommand(ClassParameters.stp_MES_CHECK_NO_BSM, sqlConn);
                    sqlCmd.CommandType = CommandType.StoredProcedure;

                    SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@GID", SqlDbType.VarChar, 10);
                    sqlPara1.Value = sGID;

                    SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@LICENSE_PLATE", SqlDbType.VarChar, 10);
                    sqlPara2.Value = sLicensePlate;

                    SqlParameter sqlPara3 = sqlCmd.Parameters.Add("@STATUS", SqlDbType.VarChar, 2);
                    sqlPara3.Value = sStatus;

                    SqlParameter sqlPara4 = sqlCmd.Parameters.Add("@TOTAL_LIMIT", SqlDbType.Int);
                    sqlPara4.Value = iTotalLimit;

                    SqlParameter sqlPara5 = sqlCmd.Parameters.Add("@MES_STATION", SqlDbType.VarChar, 10);
                    sqlPara5.Value = sStationName;

                    sqlConn.Open();
                    ReOccuranceCount = (int)sqlCmd.ExecuteScalar();
                }
                return ReOccuranceCount;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get bag with no BSM re-occurance count failure! <" + thisMethod + ">", ex);

                return ReOccuranceCount;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get bag with no BSM re-occurance count failure! <" + thisMethod + ">", ex);

                return ReOccuranceCount;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Alert encoded duration to MDS.
        /// </summary>
        /// <param name="sAlarmType">Alarm type to update</param>
        /// <param name="sEquipmentID">Equipment ID to update</param>
        public void AlertEncodingDuration(string sAlarmType, string sEquipmentID)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            SqlTransaction sqlTrans = null;
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive == true)
                {

                    sqlConn = new SqlConnection(ClassParameters.SecondaryDBConnectionString);
                    sqlCmd = new SqlCommand(ClassParameters.stp_MES_ALERT_ENCODING_DURATION, sqlConn);
                    sqlCmd.CommandType = CommandType.StoredProcedure;

                    SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@ALARM_TYPE", SqlDbType.VarChar, 20);
                    sqlPara1.Value = sAlarmType;

                    SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@EQUIPMENT_ID", SqlDbType.VarChar, 10);
                    sqlPara2.Value = sEquipmentID;

                    sqlConn.Open();
                    sqlTrans = sqlConn.BeginTransaction();
                    sqlCmd.Transaction = sqlTrans;
                    sqlCmd.ExecuteNonQuery();
                    sqlTrans.Commit();
                }
            }
            catch (SqlException ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Alert encoding duration information failure! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (sqlTrans != null)
                    sqlTrans.Rollback();

                if (_logger.IsErrorEnabled)
                    _logger.Error("Alert encoding duration information failure! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlTrans != null)
                {
                    sqlTrans.Dispose();
                    sqlTrans = null;
                }

                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }

                if (sqlConn != null)
                {
                    sqlConn.Close();
                    sqlConn.Dispose();
                    sqlConn = null;
                }
            }
        }

        /// <summary>
        /// Insert makeup flight type mapping to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalmakeupflighttypemapping(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_MAKEUP_FLIGHT_TYPE_MAPPING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@MAKEUP_FLIGHT_TYPE_MAPPING", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting makeup flight type mapping data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert security categories to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalsecuritycategories(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_SECURITY_CATEGORIES, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SECURITY_CATEGORIES", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting security categories data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert security group task mapping to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalsecuritygrouptaskmapping(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_SECURITY_GROUP_TASK_MAPPING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SECURITY_GROUP_TASK_MAPPING", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting security group task mapping data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert security group tasks to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalsecuritygrouptasks(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_SECURITY_GROUP_TASKS, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SECURITY_GROUP_TASKS", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting security group tasks data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert security groups to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalsecuritygroups(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_SECURITY_GROUPS, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SECURITY_GROUPS", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting security groups data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert security tasks to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalsecuritytasks(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_SECURITY_TASKS, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SECURITY_TASKS", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting security tasks data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert security user rights to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalsecurityuserrights(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_SECURITY_USER_RIGHTS, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SECURITY_USER_RIGHTS", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting security user rights data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert HBS Level to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalHBSLevel(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_HBS_LEVEL, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@HBS_LEVEL", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting HBS level data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        /// <summary>
        /// Insert security users to local database.
        /// </summary>
        /// <param name="sqlConn">Opened sql connection to reuse.</param>
        /// <param name="dtServerTable">Data from server.</param>
        /// <param name="sqlTrans">Opened transaction to reuse</param>
        /// <returns>Return true if the process is success and return false if the process is fail</returns>
        private bool InsertLocalsecurityusers(SqlConnection sqlConn, DataTable dtServerTable, SqlTransaction sqlTrans)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            try
            {
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_INSERT_SECURITY_USERS, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@SECURITY_USERS", SqlDbType.Structured);
                sqlPara1.Value = dtServerTable;

                sqlCmd.Transaction = sqlTrans;
                sqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Inserting security users data to local database failure! <" + thisMethod + ">", ex);
                return false;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
            return true;
        }

        public void GetAllMESSetting()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsAllSetting = new DataSet();
            try
            {
                sqlConn = new SqlConnection();
                if (ClassParameters.MainDBAlive)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_ALL_SETTING, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlAdapter.Fill(dsAllSetting);

                if (dsAllSetting.Tables.Count > 0)
                {
                    for (int i = 0; i < dsAllSetting.Tables[0].Rows.Count; i++)
                    {
                        if (dsAllSetting.Tables[0].Rows[i][0].ToString() == ClassParameters.MES_Config.ReOccurenceSysKey)
                        {
                            ClassParameters.BagReoccurance = Convert.ToInt32(dsAllSetting.Tables[0].Rows[i][1].ToString());
                        }
                        else if (dsAllSetting.Tables[0].Rows[i][0].ToString() == ClassParameters.MES_Config.MsgDurationSysKey)
                        {
                            ClassParameters.DisplayMessageDuration = Convert.ToInt32(dsAllSetting.Tables[0].Rows[i][1].ToString()) * 1000;
                        }
                        else if (dsAllSetting.Tables[0].Rows[i][0].ToString() == ClassParameters.MES_Config.NoBSMReoccurenceSysKey)
                        {
                            ClassParameters.NoBSMReoccurance = Convert.ToInt32(dsAllSetting.Tables[0].Rows[i][1].ToString());
                        }
                        else if (dsAllSetting.Tables[0].Rows[i][0].ToString() == ClassParameters.MES_Config.EncodeDurationSysKey)
                        {
                            ClassParameters.EncodeDuration = Convert.ToInt32(dsAllSetting.Tables[0].Rows[i][1].ToString()) * 1000;
                        }
                        else if (dsAllSetting.Tables[0].Rows[i][0].ToString() == ClassParameters.MES_Config.EnableHBS2BSysKey)
                        {
                            ClassParameters.EnableHBS2BSysKey = Convert.ToBoolean(dsAllSetting.Tables[0].Rows[i][1]);
                        }
                        else if (dsAllSetting.Tables[0].Rows[i][0].ToString() == ClassParameters.MES_Config.EnableAirRushAlloc)
                        {
                            ClassParameters.EnableAirRushAlloc = Convert.ToBoolean(dsAllSetting.Tables[0].Rows[i][1]);
                        }
                        else if (dsAllSetting.Tables[0].Rows[i][0].ToString() == ClassParameters.MES_Config.EnableRushFuncAlloc)
                        {
                            ClassParameters.EnableRushFuncAlloc = Convert.ToBoolean(dsAllSetting.Tables[0].Rows[i][1]);
                        }

                    }
                }

                if (_logger.IsInfoEnabled)
                    _logger.Info("Getting MES setting from server successful! <" + thisMethod + ">");
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Getting MES setting from server fail! <" + thisMethod + ">", ex);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Getting MES setting from server fail! <" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
        }

        public DataTable GetChuteByDestination(string strDestination, string tts)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            DataSet dsDestination = new DataSet();
            try
            {
                sqlConn = new SqlConnection();

                if (ClassParameters.MainDBAlive)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_CHUTE_BY_DESTINATION, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sqlPara1 = sqlCmd.Parameters.Add("@DESTINATION", SqlDbType.VarChar, 20);
                sqlPara1.Value = strDestination;

                SqlParameter sqlPara2 = sqlCmd.Parameters.Add("@TTS", SqlDbType.VarChar, 10);
                sqlPara2.Value = tts;

                SqlDataAdapter sqlAdapter = new SqlDataAdapter(sqlCmd);

                sqlAdapter.Fill(dsDestination);
                if (dsDestination != null)
                {
                    if (dsDestination.Tables.Count > 0)
                    {
                        return dsDestination.Tables[0];
                    }
                }
                return null;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get multiple destination fail! <" + thisMethod + ">", ex);
                return null;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get multiple destination fail! <" + thisMethod + ">", ex);
                return null;
            }
            finally
            {
                if (sqlCmd != null)
                {
                    sqlCmd.Dispose();
                    sqlCmd = null;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="currentLocation"></param>
        /// <param name="destinations"></param>
        /// <returns></returns>
        public LocationID[] SortByShortestPathScheme(LocationID currentLocation, ref LocationID[] destinations)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationCost sourceCost;

            try
            {
                if (currentLocation.Subsystem.Trim() == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("There is no SubSystem was specified for shortest path calculation! <" + thisMethod + ">");

                    return destinations;
                }

                if (currentLocation.Location.Trim() == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("There is no Source Location was specified for shortest path calculation! <" + thisMethod + ">");

                    return destinations;
                }
                else
                {
                    // Get the Cost of the Source Location
                    sourceCost.Location = currentLocation;
                    sourceCost.Cost = GetLocationCost(currentLocation.Subsystem, currentLocation.Location);
                }

                if (destinations == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("There is no Destination(s) was specified for shortest path calculation! <" + thisMethod + ">");

                    return destinations;
                }

                int len = destinations.Length;
                if (len < 1)
                {
                    // No destination was specified, return nothing.
                    if (_logger.IsErrorEnabled)
                        _logger.Error("There is no Destination(s) was specified for shortest path calculation! <" + thisMethod + ">");

                    return destinations;
                }
                else if (len == 1)
                {
                    // Only one destination was specified, just return it as the shortest path.
                    return destinations;
                }
                else
                {
                    // More than one destination were specified, then calculate the 
                    // shortest path by using locatioin cost.
                    List<LocationCost> negativeCostDifferent = new List<LocationCost>();
                    List<LocationCost> positiveCostDifferent = new List<LocationCost>();
                    bool hasNegative = false;
                    bool hasPositive = false;

                    for (int i = 0; i < len; i++)
                    {
                        // Get the Cost different between current location and every
                        // location in destination list.
                        int destCost, differentCost;

                        destCost = GetLocationCost(destinations[i].Subsystem, destinations[i].Location);
                        differentCost = destCost - sourceCost.Cost;

                        if (differentCost >= 0)
                        {
                            hasPositive = true;

                            LocationCost temp = new LocationCost();
                            temp.Location = destinations[i];
                            temp.Cost = differentCost;

                            positiveCostDifferent.Add(temp);
                        }
                        else if (differentCost < 0)
                        {
                            hasNegative = true;

                            LocationCost temp = new LocationCost();
                            temp.Location = destinations[i];
                            temp.Cost = differentCost;

                            negativeCostDifferent.Add(temp);
                        }
                    }

                    // If all values of (Destination Cost - CurrentLocation Cost) are positive 
                    // value, then the sorted sequence will be from small value to large value. 
                    // If all values of (Destination Cost - CurrentLocation Cost) are negative 
                    // value, then the sorted sequence will be from large value to small value. 
                    // If value of (Destination Cost - CurrentLocation Cost) is conststed of 
                    // positive and nagetive value, then the sorted sequence will be positive
                    // values first (follow the sequence from small to large value), and then
                    // negative values (follow the sequence from large to small).
                    LocationID[] sortedDests = new LocationID[len];

                    int lastPosition = 0;
                    // Sort the members (from small to large cost value) in LocationCost 
                    // object array by using SelectionSort Algorithms.
                    if (hasPositive)
                    {
                        LocationCost[] tempCostDifferent = positiveCostDifferent.ToArray();

                        SelectionSortNumbers(ref tempCostDifferent, true);

                        for (int i = 0; i < tempCostDifferent.Length; i++)
                        {
                            sortedDests[i] = tempCostDifferent[i].Location;
                            lastPosition = i;
                        }
                    }

                    // Sort the members (from small to large cost value) in LocationCost 
                    // object array by using SelectionSort Algorithms.
                    if (hasNegative)
                    {
                        LocationCost[] tempCostDifferent = negativeCostDifferent.ToArray();

                        SelectionSortNumbers(ref tempCostDifferent, true);

                        for (int i = 0; i < tempCostDifferent.Length; i++)
                        {
                            sortedDests[i + lastPosition + 1] = tempCostDifferent[i].Location;
                        }
                    }
                    return sortedDests;
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Sort By Shortest Path Scheme failure! <" + thisMethod + ">", ex);

                return destinations;
            }
        }


        /// <summary>
        /// Tp get the location cost
        /// </summary>
        /// <param name="baseSubsystem"></param>
        /// <param name="location"></param>
        /// <returns></returns>
        private int GetLocationCost(string baseSubsystem, string location)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            int cost = 0;

             //If due to some reason (e.g. DB was not ready), Routing Table was not retrieved 
             //from DB at the startup time, then retry it before shortest path calculation.
            if (_isDBReady == false)
            {
                throw new Exception("Database is still not ready, shortest path " +
                        "calculation cannot continue.");
            }
            else
            {
                if (routingTableSyncdHash.Count == 0)
                {
                    GetRoutingTableFromDB();
                }
            }


            if (routingTableSyncdHash.Contains(location))
            {
                LocationCost[] items;
                // The values for the RoutingTableSyncdHash is in the List<LocationCost>, so need to change to array.
                items = ((List<LocationCost>)routingTableSyncdHash[location]).ToArray();

                int len = items.Length;

                if (len < 1)
                {
                    // There is not cost was defined for this location
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get path cost of location:" + location + " is failure! <" + thisMethod + ">");

                    throw new Exception("Location:" + location + " is invalid.");
                }
                else if (len == 1)
                {
                    // There is only one cost was defined for this location
                    cost = items[0].Cost;
                }
                else if (len > 1)
                {
                    // There is more than one cost was defined for this location
                    bool hasCost = false;

                    for (int i = 0; i < len; i++)
                    {
                        // Return cost of the one which has the same subsystem.
                        if (items[i].Location.Subsystem == baseSubsystem)
                        {
                            cost = items[i].Cost;
                            hasCost = true;
                            break;
                        }
                    }

                    if (hasCost == false)
                    {
                        // There is no any matched subsystem.
                        if (_logger.IsErrorEnabled)
                            _logger.Error("The SubSystem (" + baseSubsystem + ") of Location (" +
                                    location + ") was not in the database routing table! <" + thisMethod + ">");

                        throw new Exception("Location:" + location + " is invalid.");
                    }

                }
                else
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Location:" + location +
                        " was not defined in the database routing table! <" + thisMethod + ">");

                    throw new Exception("Location:" + location + " is invalid.");
                }
            }

            return cost;
        }


        /// <summary>
        /// GetRoutingTableData
        /// </summary>
        /// <returns></returns>
        public bool GetRoutingTableData()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;

            try
            {

                //====================================================
                // 1. Load system parameter settings from database table into global variables.
                // Retrieve Routing Table from DB for future shortest path calculation.
                _routingTableHashTable = new Hashtable();
                routingTableSyncdHash = Hashtable.Synchronized(_routingTableHashTable);

                if (GetRoutingTableFromDB() == false)
                {
                    return false;
                }
                //====================================================

                return true;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Routing Table Data is failed! <" + thisMethod + ">", ex);

                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Routing Table Data is failed! <" + thisMethod + ">", ex);

                return false;
            }
            finally
            {
                if (sqlConn != null)
                    sqlConn.Close();
            }
        }

        /// <summary>
        /// Retrieve all location cost from database table into memory at the application 
        /// starting time. So that there is no database query is required when calculating
        /// shortest path.
        /// 
        /// The Subsystem, LocationID, and LocationCost of one location will be assigned
        /// to one LocationCost object. Due to the same location ID may have more than 
        /// one cost, the LocationCost object array will be used to represent one
        /// location and assign to Hashtable object (m_RoutingTableSyncdHash) of routing 
        /// table in memory.
        /// 
        /// Hashtable (m_RoutingTableSyncdHash) Key: Location ID
        /// Hashtable (m_RoutingTableSyncdHash) value: LocationCost object array List
        /// </summary>
        /// <param name="sqlConn"></param>
        /// <returns></returns>
        public bool GetRoutingTableFromDB()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlCommand sqlCmd = null;
            SqlDataReader reader = null;

            try
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Retrieving Routing Table from Database... <" + thisMethod + ">");

                SqlConnection sqlConn = new SqlConnection(ClassParameters.DBConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.STPGetRoutingTable, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlConn.Open();
                reader = sqlCmd.ExecuteReader();

                string subsystem, location;
                int cost;

                while (reader.Read())
                {
                    subsystem = string.Empty;
                    location = string.Empty;
                    cost = 0;

                    if (reader[ClassParameters.ColumnSubsystem] != DBNull.Value)
                    {
                        subsystem = reader[ClassParameters.ColumnSubsystem].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnLocation] != DBNull.Value)
                    {
                        location = reader[ClassParameters.ColumnLocation].ToString().Trim();
                    }

                    if (reader[ClassParameters.ColumnCost] != DBNull.Value)
                    {
                        cost = Convert.ToInt32(reader[ClassParameters.ColumnCost].ToString().Trim());
                    }


                    if (subsystem != string.Empty & location != string.Empty)
                    {
                        LocationCost item = new LocationCost();
                        item.Location.Subsystem = subsystem;
                        item.Location.Location = location;
                        item.Cost = cost;

                        List<LocationCost> items = new List<LocationCost>();

                        if (routingTableSyncdHash.Contains(location))
                        {
                            items = (List<LocationCost>)routingTableSyncdHash[location];

                            items.Add(item);
                            routingTableSyncdHash[location] = items;
                        }
                        else
                        {
                            items.Add(item);
                            routingTableSyncdHash[location] = items;
                        }

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Routing_Table] SubSystem: " + subsystem +
                                    ", Location: " + location +
                                    ", Cost: " + cost + ". <" + thisMethod + ">");
                    }
                }

                if (_logger.IsInfoEnabled)
                    _logger.Info("Retrieving Routing Table successful. <" + thisMethod + ">");

                return true;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Retrieve Routing Table From DB failure! <" + thisMethod + ">", ex);

                return false;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Retrieve Routing Table From DB failure! <" + thisMethod + ">", ex);

                return false;
            }
            finally
            {
                if (reader != null) reader.Close();
            }
        }

        
        /// <summary>
        /// GetSysConfigTableChange
        /// </summary>
        /// <returns></returns>
        public bool GetSysConfigTableChange()
        {
 
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;
            bool isChange = false;
            string sDBConnectionString = string.Empty;

            try
            {
                sqlConn = new SqlConnection();

                if (ClassParameters.MainDBAlive)
                {
                    sqlConn.ConnectionString = ClassParameters.DBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlConn = new SqlConnection(sqlConn.ConnectionString);
                sqlCmd = new SqlCommand(ClassParameters.stp_MES_GET_SYS_CONFIG_TABLE_CHANGE, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.Add("@Subsystem", SqlDbType.VarChar, 20);
                sqlCmd.Parameters["@Subsystem"].Value = Subsystem;


                sqlCmd.Parameters.Add("@IsChange", SqlDbType.Bit);
                sqlCmd.Parameters["@IsChange"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                if (sqlCmd.Parameters["@IsChange"].Value != DBNull.Value)
                {
                    isChange = Convert.ToBoolean(sqlCmd.Parameters["@IsChange"].Value.ToString().Trim());
                }

                return isChange;
            }
            catch (SqlException ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Sys Config Table Change From DB failure! <" + thisMethod + ">", ex);

                return isChange;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Sys Config Table Change From DB failure! <" + thisMethod + ">", ex);

                return isChange;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// To get Item Encoded values
        /// </summary>
        /// <param name="EncodedType">Manual encoding type as type of System.String</param>
        /// <param name="LicensePlate">License plate as type of System.String</param>
        /// <param name="Carrier">Carrier code as type of System.String</param>
        /// <param name="Flight">Flight No as type of System.String</param>
        /// <param name="SDO">Flight Departure Date & Time as type of System.String</param>
        /// <param name="AllocationProperty">Allocation property as type of Systm.String</param>
        /// <param name="Location">Location as type of System.String</param>
        /// <param name="Destination">Sort destination as type of System.String</param>
        /// <param name="Reason">Sort reason as type of System.String</param>
        public void GetIRDValuesMES(string EncodedType, string LicensePlate, string Carrier, string Flight, string SDO, string Location, string sortDestination,
            out string Destination, out string Reason, out string DestDescr, out string ReasonDescr)
        {
            Destination = string.Empty;
            Reason = string.Empty;
            DestDescr = string.Empty;
            ReasonDescr = string.Empty;

            string strAlloc_prop = string.Empty;
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;

            try
            {

                // -- To retrieve bag's Allocation Property
                AllocationProperty(LicensePlate, Carrier, Flight, SDO, out strAlloc_prop);

                sqlConn = new SqlConnection();
                if (ClassParameters.SecondaryDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.STPGetIRDValues, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.AddWithValue("@ENCODED_TYPE", EncodedType);
                sqlCmd.Parameters.AddWithValue("@LICENSE_PLATE", LicensePlate);
                sqlCmd.Parameters.AddWithValue("@AIRLINE", Carrier);
                sqlCmd.Parameters.AddWithValue("@FLIGHT_NUMBER", Flight);
                sqlCmd.Parameters.AddWithValue("@SDO", SDO);
                sqlCmd.Parameters.AddWithValue("@ALLOCATION_PROP", strAlloc_prop);
                sqlCmd.Parameters.AddWithValue("@SORTDESTINATION", sortDestination);

                int intCount = 1;
                sqlConn.Open();
                SqlDataReader sqlReader = sqlCmd.ExecuteReader();
                while (sqlReader.Read())
                {
                    Reason = sqlReader["REASON"].ToString();
                    ReasonDescr = sqlReader["R_DESCRIPTION"].ToString();

                    if (intCount == 1)
                    {
                        CheckMUAvailability(sqlReader["DESTINATION"].ToString(), sqlReader["DESTINATION_DESCR"].ToString(), Location, Reason, ReasonDescr, out Destination, out DestDescr, out Reason, out ReasonDescr);
                    }
                    else
                    {
                        CheckMUAvailability(sqlReader["DESTINATION"].ToString(), sqlReader["DESTINATION_DESCR"].ToString(), Location, Reason, ReasonDescr, out Destination, out DestDescr, out Reason, out ReasonDescr);
                    }
                    intCount += 1;
                }

            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Collecting of IEC values FAILURE !<" + thisMethod + ">", ex);

                return;
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
        }

        /// <summary>
        /// Check MU availability
        /// </summary>
        /// <param name="strDestination">Sortation destination as type of System.String</param>
        /// <param name="strDestDescr">Sortation destination description as type of System.String</param>
        /// <param name="strLocation">Current MES location as type of System.String</param>
        /// <param name="strReason">Sortation reason as type of System.String</param>
        /// <param name="strReasonDescr">Sortation reason description as type of System.String</param>
        /// <param name="Destination">Return Destination as type of System.String</param>
        /// <param name="Reason">Return Sortation Reason as type of System.String</param>
        /// <returns></returns>
        private void CheckMUAvailability(string strDestination, string strDestDescr ,string strLocation, string strReason, string strReasonDescr, out string Destination, out string DestDescr, out string Reason, out string ReasonDescr)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;

            Destination = string.Empty;
            Reason = string.Empty;
            DestDescr = string.Empty;
            ReasonDescr = string.Empty;

            try
            {

                sqlConn = new SqlConnection();

                if (ClassParameters.SecondaryDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.STPCheckMUAvailability, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;

                sqlCmd.Parameters.AddWithValue("@DESTINATION", strDestination);
                sqlCmd.Parameters.AddWithValue("@DEST_DESCR", strDestDescr);
                sqlCmd.Parameters.AddWithValue("@LOCATION", strLocation);
                sqlCmd.Parameters.AddWithValue("@ORGREASON", strReason);
                sqlCmd.Parameters.AddWithValue("@ORGREASON_DESCR", strReasonDescr);

                sqlCmd.Parameters.Add("@RETVAL", SqlDbType.VarChar, 4);
                sqlCmd.Parameters["@RETVAL"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@REASON", SqlDbType.VarChar, 4);
                sqlCmd.Parameters["@REASON"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@RETVAL_DESCR", SqlDbType.VarChar, 10);
                sqlCmd.Parameters["@RETVAL_DESCR"].Direction = ParameterDirection.Output;

                sqlCmd.Parameters.Add("@REASON_DESCR", SqlDbType.VarChar, 100);
                sqlCmd.Parameters["@REASON_DESCR"].Direction = ParameterDirection.Output;

                sqlConn.Open();
                sqlCmd.ExecuteNonQuery();

                Destination = sqlCmd.Parameters["@RETVAL"].Value.ToString();
                DestDescr = sqlCmd.Parameters["@RETVAL_DESCR"].Value.ToString();
                Reason = sqlCmd.Parameters["@REASON"].Value.ToString();
                ReasonDescr = sqlCmd.Parameters["@REASON_DESCR"].Value.ToString();
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Checking on MU Availability procedures is FAILURE !<" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }

        }

        /// <summary>
        /// To retrieve Bag' s Allocation Property
        /// </summary>
        /// <param name="strLicensePlate">License Plate as System.String</param>
        /// <param name="strCarrier">Carrier as System.String</param>
        /// <param name="strFlightNo">Flight No as System.String</param>
        /// <param name="strSDO">SDO as System.String</param>
        /// <param name="strAllocProp">Allocation Property as System.String</param>
        private void AllocationProperty(string strLicensePlate, string strCarrier, string strFlightNo, string strSDO, out string strAllocProp)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            SqlConnection sqlConn = null;
            SqlCommand sqlCmd = null;

            System.TimeSpan timeSpan_allocOpenOffset, timeSpan_allocCloseOffset, timeSpan_allocEarlyOpenOffset, timeSpan_allocRushDuration;
            string alloc_open_offset, alloc_open_related, alloc_close_offset, alloc_close_related, alloc_early_open_offset, alloc_rush_duration;
            string sdo, edo, ido, sto, eto, ito;
            DateTime std, etd, itd, s_do, e_do, i_do;

            alloc_open_offset = string.Empty;
            alloc_open_related = string.Empty;
            alloc_close_offset = string.Empty;
            alloc_close_related = string.Empty;
            alloc_early_open_offset = string.Empty;
            alloc_rush_duration = string.Empty;
            sdo = string.Empty;
            edo = string.Empty;
            ido = string.Empty;
            sto = string.Empty;
            eto = string.Empty;
            ito = string.Empty;
            strAllocProp = string.Empty; 

            string Allocation_Property = "UNKNOWN";
            try
            {
                alloc_open_related = "STD";

                sqlConn = new SqlConnection();
                
                if (ClassParameters.SecondaryDBAlive == true)
                {
                    sqlConn.ConnectionString = ClassParameters.SecondaryDBConnectionString;
                }
                else
                {
                    sqlConn.ConnectionString = ClassParameters.LocalDBConnectionString;
                }

                sqlCmd = new SqlCommand(ClassParameters.STPSACGetAllocProp, sqlConn);
                sqlCmd.CommandType = CommandType.StoredProcedure;
                sqlCmd.Parameters.AddWithValue("@LICENSE_PLATE", strLicensePlate);
                sqlCmd.Parameters.AddWithValue("@CARRIER", strCarrier);
                sqlCmd.Parameters.AddWithValue("@FLIGHT_NO", strFlightNo);
                sqlCmd.Parameters.AddWithValue("@S_DO", strSDO);

                sqlConn.Open();
                SqlDataReader sqlReader = sqlCmd.ExecuteReader();
                while (sqlReader.Read())
                {
                    alloc_open_offset = sqlReader["ALLOC_OPEN_OFFSET"].ToString();
                    alloc_open_related = sqlReader["ALLOC_OPEN_RELATED"].ToString();
                    alloc_close_offset = sqlReader["ALLOC_CLOSE_OFFSET"].ToString();
                    alloc_close_related = sqlReader["ALLOC_CLOSE_RELATED"].ToString();
                    alloc_early_open_offset = sqlReader["ALLOC_EARLY_OPEN_OFFSET"].ToString();
                    alloc_rush_duration = sqlReader["ALLOC_RUSH_DURATION"].ToString();

                    sdo = sqlReader["SDO"].ToString();
                    edo = sqlReader["EDO"].ToString();
                    ido = sqlReader["IDO"].ToString();

                    sto = sqlReader["STO"].ToString();
                    eto = sqlReader["ETO"].ToString();
                    ito = sqlReader["ITO"].ToString();

                    s_do = Convert.ToDateTime(sdo == string.Empty ? null : sdo);
                    e_do = Convert.ToDateTime(edo == string.Empty ? null : edo);
                    i_do = Convert.ToDateTime(ido == string.Empty ? null : ido);

                    // Need to imporve on getting the correct Date Time based on current Regional & Language setting
                    std = sdo == string.Empty ? Convert.ToDateTime(null) : Convert.ToDateTime(s_do.Year.ToString() + "-" + s_do.Month.ToString() + "-" + s_do.Day.ToString() + " " + sto.Substring(0, 2) + ":" + sto.Substring(2, 2));
                    etd = edo == string.Empty ? Convert.ToDateTime(null) : Convert.ToDateTime(e_do.Year.ToString() + "-" + e_do.Month.ToString() + "-" + e_do.Day.ToString() + " " + eto.Substring(0, 2) + ":" + eto.Substring(2, 2));
                    itd = ido == string.Empty ? Convert.ToDateTime(null) : Convert.ToDateTime(i_do.Year.ToString() + "-" + i_do.Month.ToString() + "-" + i_do.Day.ToString() + " " + ito.Substring(0, 2) + ":" + ito.Substring(2, 2));

                    timeSpan_allocOpenOffset = Utilities.timeSpan(alloc_open_offset);
                    timeSpan_allocCloseOffset = Utilities.timeSpan(alloc_close_offset);
                    timeSpan_allocEarlyOpenOffset = Utilities.timeSpan(alloc_early_open_offset);
                    timeSpan_allocRushDuration = Utilities.timeSpan(alloc_rush_duration);

                    DateTime alloc_open = std;
                    switch (alloc_open_related)
                    {
                        case "STD":
                            alloc_open = std.Add(timeSpan_allocOpenOffset);
                            break;
                        case "ETD":
                            alloc_open = etd.Add(timeSpan_allocOpenOffset);
                            break;
                        case "ITD":
                            alloc_open = itd.Add(timeSpan_allocOpenOffset);
                            break;
                    }

                    DateTime alloc_close = std;
                    switch (alloc_close_related)
                    {
                        case "STD":
                            alloc_close = std.Add(timeSpan_allocCloseOffset);
                            break;
                        case "ETD":
                            alloc_close = etd.Add(timeSpan_allocCloseOffset);
                            break;
                        case "ITD":
                            alloc_close = itd.Add(timeSpan_allocCloseOffset);
                            break;
                    }

                    DateTime alloc_early_open = alloc_open.Add(timeSpan_allocEarlyOpenOffset);
                    DateTime alloc_rush = alloc_close.Add(timeSpan_allocRushDuration);

                    if (DateTime.Now < alloc_early_open)
                    {
                        // Too early allocation 
                        Allocation_Property = "2EARLY";
                    }
                    else if (alloc_early_open < DateTime.Now && DateTime.Now < alloc_open)
                    {
                        // Early allocation
                        Allocation_Property = "EARLY";
                    }
                    else if (alloc_open < DateTime.Now && DateTime.Now < alloc_close)
                    {
                        // Open allocation
                        Allocation_Property = "OPEN";
                    }
                    else if (alloc_close < DateTime.Now && DateTime.Now < alloc_rush)
                    {
                        // Rush allocation 
                        Allocation_Property = "RUSH";
                    }
                    else if (alloc_rush < DateTime.Now)
                    {
                        // Too late allocation
                        Allocation_Property = "2LATE";
                    }
                }

                if (_logger.IsInfoEnabled)
                    _logger.Info("Allocation property for License Plate " + strLicensePlate + " is " + Allocation_Property + " <" + thisMethod + ">");
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Checking of Allocation property failure !<" + thisMethod + ">", ex);
            }
            finally
            {
                if (sqlConn != null) sqlConn.Close();
            }
            
        }



        #endregion
    }
}
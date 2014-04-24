#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       PersistorParameters.cs
// Revision:      1.0 -   14 Jun 2010, By Albert Sun
// =====================================================================================
//
#endregion

using System;
using System.Xml;
using System.Data;
using PALS.Security;
using PALS.Utilities;
using System.Collections;
using PALS.Security.General;
using System.Collections.Generic;

namespace BHS.MES.TCPClientChains.DataPersistor.Database
{
    /// <summary>
    /// Parameter class used to store parameters of MessageHandler class.
    /// </summary>
    public class PersistorParameters : PALS.Common.IParameters, IDisposable
    {
        #region Class Fields Declaration
        #region Local Fields
        private const string DB_CONNECTION_STRING = "connectionString";
        private const string DB_SECONDARY_CONNECTION_STRING = "secondaryConnectionString";
        private const string LOCALDB_CONNECTION_STRING = "localConnectionString";
        private const string HBS_ACCEPTED_ID = "hbsAcceptedID";
        private const string DEFAULT_HBS_LEVEL = "defaultHBSLevel";
        private const string CUSTOMS_ACCEPTED_ID = "customsAcceptedID";
        private const string WILDCARD = "wildcard";
        private const string APP_LIVE_STATUS_UPDATE_KEY = "appLiveStatusUpdateKey";
        private const string APP_LIVE_STATUS = "appLiveStatusUp";
        private const string APP_LIVE_STATUS_UPDATE_INTERVAL = "appLiveStatusUpdateInterval";
        private const string APP_LOG_ON_OFF_STATUS_UPDATE_KEY = "appLogOnOffStatusUpdateKey";
        private const string MES_EMERGENCY_TASK_LIST = "emergencyUserTaskAssignment";
        private const string EQUIPMENT_ID = "equipmentID";
        private const string NO_BSM_REOCCURANCE_ALARM_TYPE = "alarmTypeNoBSMReoccurance";
        private const string ENCODE_DURATION_ALARM_TYPE = "alarmTypeEncodeDuration";
        private const string SECURITY_CATEGORY_CODE = "securityCategoryCode";
        private const string SECURITY_CONTAINER_NAME = "securityContainerName";
        private const string SECURITY_DOMAIN_EXTENSION = "securityDomainExtension";
        private const string SECURITY_DOMAIN_NAME = "securityDomainName";
        private const string SECURITY_IP_ADDRESSES = "securityIPAddresses";
        private const string SECURITY_RELATED_CONFIG = "securityRelatedConfigs";
        private const string SECURITY_ORGANIZATION_NAME = "securityOrganizationName";
        #region Sort Reason
        private const string DB_SORTATION_REASON_CRB = "sortReason_CRB";
        private const string DB_SORTATION_REASON_DTUA = "sortReason_DTUA";
        private const string DB_SORTATION_REASON_EBSHBS = "sortReason_EBSHBS";
        private const string DB_SORTATION_REASON_NORD = "sortReason_NORD";
        private const string DB_SORTATION_REASON_MTLP = "sortReason_MTLP";
        private const string DB_SORTATION_REASON_FOUR_DIGITS_FALLBACK = "sortReason_FOURDIGITSFALLBACK";
        private const string DB_SORTATION_REASON_FOUR_DIGITS_SECURITY = "sortReason_FOURDIGITSSECURITY";
        private const string DB_SORTATION_REASON_NBSM = "sortReason_NBSM";
        private const string DB_SORTATION_REASON_MBSM = "sortReason_MBSM";
        private const string DB_SORTATION_REASON_UNFL = "sortReason_UNFL";
        private const string DB_SORTATION_REASON_NOAL = "sortReason_NOAL";
        private const string DB_SORTATION_REASON_MSSL = "sortReason_MSSL";
        private const string DB_SORTATION_REASON_IATA_FALLBACK = "sortReason_IATAFALLBACK";
        private const string DB_SORTATION_REASON_ALAL = "sortReason_ALAL";
        private const string DB_SORTATION_REASON_PROB = "sortReason_PROB";
        private const string DB_SORTATION_REASON_ALLO = "sortReason_ALLO";
        private const string DB_SORTATION_REASON_RUSH = "sortReason_RUSH";
        private const string DB_SORTATION_REASON_LATE = "sortReason_LATE";
        private const string DB_SORTATION_REASON_ERLY = "sortReason_ERLY";
        private const string DB_SORTATION_REASON_TERL = "sortReason_TERL";
        private const string DB_SORTATION_REASON_CCFL = "sortReason_CCFL";
        private const string DB_SORTATION_REASON_FEXC = "sortReason_FEXC";
        private const string DB_SORTATION_REASON_STRY = "sortReason_STRY";
        private const string DB_SORTATION_REASON_MRDD = "sortReason_MRDD";
        private const string DB_SORTATION_REASON_DELF = "sortReason_DELF";
        private const string DB_SORTATION_REASON_OFBK = "sortReason_OFBK";
        #endregion
        #region Function Allocation
        private const string DB_FUNC_ALLOCATION_CRB = "funcAllocation_CRB";
        private const string DB_FUNC_ALLOCATION_NORD = "funcAllocation_NORD";
        private const string DB_FUNC_ALLOCATION_MTLP = "funcAllocation_MTLP";
        private const string DB_FUNC_ALLOCATION_NBSM = "funcAllocation_NBSM";
        private const string DB_FUNC_ALLOCATION_NOAL = "funcAllocation_NOAL";
        private const string DB_FUNC_ALLOCATION_MBSM = "funcAllocation_MBSM";
        private const string DB_FUNC_ALLOCATION_UNFL = "funcAllocation_UNFL";
        private const string DB_FUNC_ALLOCATION_FEXC = "funcAllocation_FEXC";
        private const string DB_FUNC_ALLOCATION_RUSH = "funcAllocation_RUSH";
        private const string DB_FUNC_ALLOCATION_TERL = "funcAllocation_TERL";
        private const string DB_FUNC_ALLOCATION_ERLY = "funcAllocation_ERLY";
        private const string DB_FUNC_ALLOCATION_LATE = "funcAllocation_LATE";
        private const string DB_FUNC_ALLOCATION_CCFL = "funcAllocation_CCFL";
        private const string DB_FUNC_ALLOCATION_EDS = "funcAllocation_EDS";
        private const string DB_FUNC_ALLOCATION_PB01 = "funcAllocation_PB01";
        private const string DB_FUNC_ALLOCATION_PB02 = "funcAllocation_PB02";
        private const string DB_FUNC_ALLOCATION_DP01 = "funcAllocation_DP01";
        private const string DB_FUNC_ALLOCATION_DP02 = "funcAllocation_DP02";
        #endregion
        private const string CUSTOMS_CHUTE_LOCATION = "location_CustomsChute";
        private const string CUSTOMS_CHUTE_SUB_LOCATION = "location";

        private const string DB_COLUMN_SYSKEY = "column_SYSKEY";
        private const string DB_COLUMN_SYSVALUE = "column_SYSVALUE";
        private const string DB_COLUMN_RESOURCE = "column_Resource";
        private const string DB_COLUMN_SUBSYSTEM = "column_SubSystem";
        private const string DB_COLUMN_VALUE = "column_VALUE";
        private const string DB_COLUMN_LOCATION = "column_Location";
        private const string DB_COLUMN_COST = "column_Cost";
        private const string DB_COLUMN_DESTINATION = "column_Destination";
        private const string DB_COLUMN_AIRLINE = "column_Airline";
        private const string DB_COLUMN_FLIGHT_NUMBER = "column_FlightNumber";
        private const string DB_COLUMN_SDO = "column_SDO";
        private const string DB_COLUMN_STO = "column_STO";
        private const string DB_COLUMN_MASTER_AIRLINE = "column_MasterAirline";
        private const string DB_COLUMN_MASTER_FLIGHT_NUMBER = "column_MasterFlightNumber";
        private const string DB_COLUMN_EDO = "column_EDO";
        private const string DB_COLUMN_ETO = "column_ETO";
        private const string DB_COLUMN_IDO = "column_IDO";
        private const string DB_COLUMN_ITO = "column_ITO";
        private const string DB_COLUMN_ADO = "column_ADO";
        private const string DB_COLUMN_ATO = "column_ATO";
        private const string DB_COLUMN_EARLY_OPEN_OFFSET = "column_EARLY_OPEN_OFFSET";
        private const string DB_COLUMN_ALLOC_OPEN_OFFSET = "column_ALLOC_OPEN_OFFSET";
        private const string DB_COLUMN_ALLOC_OPEN_RELATED = "column_ALLOC_OPEN_RELATED";
        private const string DB_COLUMN_ALLOC_CLOSE_OFFSET = "column_ALLOC_CLOSE_OFFSET";
        private const string DB_COLUMN_ALLOC_CLOSE_RELATED = "column_ALLOC_CLOSE_RELATED";
        private const string DB_COLUMN_RUSH_DURATION = "column_RUSH_DURATION";
        private const string DB_COLUMN_TRAVEL_CLASS = "column_TRAVEL_CLASS";
        private const string DB_COLUMN_IS_MANUAL_CLOSED = "column_IS_MANUAL_CLOSED";
        private const string DB_COLUMN_IS_CLOSED = "column_IS_CLOSED";
        private const string DB_COLUMN_BAG_TYPE = "column_BAG_TYPE";
        private const string DB_COLUMN_PASSENGER_DESTINATION = "column_PASSENGER_DESTINATION";
        private const string DB_COLUMN_TRANSFER = "column_TRANSFER";

        private const string MES_LOCATION = "location_MES";
        private const string MES_CURRENT_LOCATION = "currentMESLocation";
        private const string MES_SUB_LOCATION = "location";
        private const string MES_DEFAULT_TTS = "ttsMES";

        private const string FOUR_DIGITS_SECURITY_SORT_ENABLED = "fourDigitsSecuritySortEnabled";
        private const string FOUR_DIGITS_FALLBACK_SORT_ENABLED = "fourDigitsFallbackSortEnabled";
        private const string EBS_BAG_TO_HBS_ENABLED = "ebsBagToHBSEnabled";
        private const string FALLBACK_SORT_ENABLED = "fallbackSortEnabled";
        private const string IN_HOUSE_SORT_ENABLED = "inHouseSortEnabled";
        private const string AIRLINE_SORT_ENABLED = "airlineSortEnabled";
        private const string AIRLINE_RUSH_ALLOC_ENABLED = "airlineRushAllocEnabled";
        private const string SORT_EARLY_ENABLED = "earlyEnabled";
        private const string SORT_EARLY_OPEN_ENABLED = "earlyOpenEnabled";
        private const string SORT_LATE_ENABLED = "lateEnabled";
        private const string GLOBAL_RUSH_ALLOC_ENABLED = "globalRushAllocEnabled";
        private const string BCAS_ENABLED = "bcasEnabled";

        private const string EDS_CHUTE_LOCATION = "location_EDSChute";
        private const string EDS_CHUTE_SUB_LOCATION = "location";

        private const string RECIRCULATION_STARTED_POINT = "recirculationStartedPoint";
        private const string RECIRCULATION_STARTED_POINT_LOCATION = "location";

        private const string TTS01 = "tts01";
        private const string TTS02 = "tts02";

        private const string TTS01_SUBSYSTEM = "TTS01";

        private const string SCHEME_TTS1_ALLOC = "scheme_TTS1_Alloc";
        private const string SCHEME_TTS2_ALLOC = "scheme_TTS2_Alloc";

        private const string SCHEME_TYPE_ROUND_ROBIN = "schemeType_RoundRobin";
        private const string SCHEME_TYPE_WATERFALL_SHORTEST_PATH = "schemeType_WaterfallShortestPath";
        private const string SCHEME_TYPE_WATERFALL_PRIORITY = "schemeType_WaterfallPriority";
        private const string SCHEME_FUNCTION_ALLOCATION = "scheme_FunctionAllocation";
        private const string SCHEME_FLIGHT_ALLOCATION = "scheme_FlightAllocation";
        private const string SCHEME_AIRLINE_ALLOCATION = "scheme_AirlineAllocation";

        private const string FOUR_DIGITS_SECURITY_IDENTIFICATION = "four_Digits_Security_Identification";
        private const string FOUR_DIGITS_FALLBACK_IDENTIFICATION = "four_Digits_Fallback_Identification";
        private const string FALLBACK_AIRPORT_LOCTION_CODE = "airportLocationCode";
        private const string EMPTY_LICENSE_PLATE = "emptyLicensePlate";
        private const string DUMMY_MULTIPLE_LICENSE_PLATE = "dummyMultipleLicensePlate";
        private const string DEFAULT_CURRENT_HBS_LEVEL = "defaultCurrentHBSLevel";

        private const string RECIRCULATION_OVER_DUMP = "recirculationOverDump";

        private const string IATA_INTERLINE_IDENTIFIER = "iataInterlineIdentifier";
        private const string IATA_FALLBACK_IDENTIFIER = "iataFallbackIdentifier";
        private const string IN_HOUSE_IDENTIFIER = "inHouseIdentifier";
        private const string IN_HOUSE_AIRLINE_CODE = "inHouseAirlineCode";



        private const string HBS_LOCATION = "location_HBSLevel";
        private const string HBS_LEVEL_LOCATION = "location";

        private const string HBS_LEVEL1_ID = "hbsLevel1ID";
        private const string HBS_LEVEL2_ID = "hbsLevel2ID";
        private const string HBS_LEVEL3_ID = "hbsLevel3ID";
        private const string HBS_LEVEL4_ID = "hbsLevel4ID";
        private const string HBS_LEVEL5_ID = "hbsLevel5ID";

        private string DB_ALIVE_CHECK_THREAD_INTERVAL = "dbAliveCheckThreadInterval";
        private string DATA_CHANGES_MONITOR_INTERVAL = "dataChangesMonitorInterval";
        private string IN_HOUSE_TAG_RANGE = "inHouseTagRange";
        private string DEFAULT_DATE_FORMAT = "defaultDateFormat";
        private string DEFAULT_TIME_FORMAT = "defaultTimeFormat";
        private string DEFAULT_DATE_TIME_FORMAT = "defaultDateTimeFormat";
        private string COMMAND_TIME_OUT = "commandTimeOut";
        private string INHOUSE_TAG_CONSTANT = "inhouseTagConstant";
        private string IATA_TAG_CONSTANT = "iataTagConstant";

        private const string SORT_RELATED_NAME_STD = "relatedName_STD";
        private const string SORT_RELATED_NAME_ETD = "relatedName_ETD";
        private const string SORT_RELATED_NAME_ITD = "relatedName_ITD";
        private const string SORT_RELATED_NAME_ATD = "relatedName_ATD";

        //private const string ROUNDROBIN_BUFFER_LIFETIME = "lifeTime_RoundRobinBuffer";

        private Hashtable _parametersHashtable;


        //Fields Declaration for store procedure MES conv status (added by PST)
        private const string DB_STP_MES_GET_CONV_STATUS = "stp_MES_Get_Conv_Status";
        private const string DB_STP_MES_GET_LOCATIONS_STATUS_TYPE = "stp_MES_GET_LOCATION_STATUS_TYPE";

        /// <summary>
        /// The SchemaTypeShortestPath.
        /// </summary>
        public string SchemaTypeShortestPath { get; set; }

        private string stp_RPT_GETDATETIMEFORMAT = "stp_RptGetDatetimeFormat";
        private string stp_MES_INSERTITEMENCODED = "stp_MESInsertItemEncoded";
        private string stp_MES_INSERTITEMREADY = "stp_MESInsertItemReady";
        private string stp_MES_INSERTITEMINSERT = "stp_MESInsertItemInsert";
        private string stp_MES_INSERTITEMINSERTACK = "stp_MESInsertItemInsertAck";
        private string stp_MES_INSERTITEMREMOVED = "stp_MESInsertItemRemoved";
        private string stp_MES_INSERTMESEVENT = "stp_MESInsertMESEvent";
        private string stp_MES_GETFLIGHTALLOC = "stp_MESGetFlightAllocation";
        private string stp_MES_GETLASTENCODING = "stp_MESGetLastEncoding";
        private string stp_MES_GETPESSENGERINFO = "stp_MESGETPessengerInfo";
        private string stp_MES_GETFLIGHTINFO = "stp_MESGETFlightInfo";
        private string stp_MES_GETFLIGHTTYPE = "stp_MESGETFlightType";
        private string stp_MES_GETAIRLINEINFO = "stp_MESGETAirlineInfo"; //Guo Wenyu 2014/03/23
        private string stp_MES_GETLOCALINSERTEDDATA = "stp_MESGetLocalInsertedData";
        private string stp_MES_REMOVELOCALINSERTEDDATA = "stp_MESRemoveLocalInsertedData";
        private string stp_MES_INSERTITEMENCODEDFROMLOCAL = "stp_MESInsertItemEncodedFromLocal";
        private string stp_MES_INSERTITEMREADYFROMLOCAL = "stp_MESInsertItemReadyFromLocal";
        private string stp_MES_INSERTITEMINSERTFROMLOCAL = "stp_MESInsertItemInsertFromLocal";
        private string stp_MES_INSERTITEMINSERTACKFROMLOCAL = "stp_MESInsertItemInsertAckFromLocal";
        private string stp_MES_INSERTITEMREMOVEDFROMLOCAL = "stp_MESInsertItemRemovedFromLocal";
        private string stp_MES_INSERTMESEVENTFROMLOCAL = "stp_MESInsertMESEventFromLocal";
        private string stp_MES_GETREQUIREDINFOFROMSERVER = "stp_MESGetRequireDataToLocal";
        private string stp_MES_INSERTCHUTEMAPPING = "stp_MESInsertChuteMapping";
        private string stp_MES_INSERTAIRLINES = "stp_MESInsertAirlines";
        private string stp_MES_INSERTBAGINFO = "stp_MESInsertBagInfo";
        private string stp_MES_INSERTBAGSORTING = "stp_MESInsertBagSorting";
        private string stp_MES_INSERTFALLBACKMAPPING = "stp_MESInsertFallbackMapping";
        private string stp_MES_INSERT4DIGITSFALLBACKTAGINFO = "stp_MESInsert4DigitsFallBackMapping";
        private string stp_MES_INSERTFLIGHTPLANALLOC = "stp_MESInsertFlightPlanAlloc";
        private string stp_MES_INSERTFUNCTIONALLOCGANTT = "stp_MESInsertFunctionAllocGantt";
        private string stp_MES_INSERTFUNCTIONALLOCLIST = "stp_MESInsertFunctionAllocList";
        private string stp_MES_INSERTFUNCTIONTYPES = "stp_MESInsertFunctionTypes";
        private string stp_MES_INSERTSYSCONFIG = "stp_MESInsertSysConfig";
        private string stp_MES_GETLICENSEPLATE = "stp_MESGetLicensePlate";
        private string stp_MES_GETBAGGID = "stp_MESGetBagGid";
        private string stp_MES_GENERATEINHOUSEBSM = "stp_MESGenerateInhouseBSM";
        private string stp_MES_GETINHOUSEBSM = "stp_MESGetInhouseBSM";
        private string stp_MES_UPDATEITEMINHOUSEBSM = "stp_MESUpdateItemInhouseBSM";
        private string stp_MES_GETIATATAGLIST = "stp_MESGetIATATagList";
        private string stp_MESGETCOMBODATA = "stp_MESGetComboData";
        private string stp_MES_GETPROBLEMLOCATION = "stp_MESGetProblemLocation";
        private string stp_MES_GETRUSHLOCATION = "stp_MESGetRushLocation";
        private string stp_MES_INSERTINHOUSEBSMFROMLOCAL = "stp_MESInsertInhouseBSMFromLocal";
        private string stp_MES_INSERTFLIGHTPLANSORTING = "stp_MESInsertFlightPlanSorting";
        private string stp_MES_GETAIRLINES = "stp_MESGetAirLines";
        private string stp_MES_GETFLIGHT = "stp_MESGetFlight";
        private string stp_MES_GETDESTINATION = "stp_MESGetDestination";
        private string stp_MES_GETREASON = "stp_MESGetReason";
        private string stp_MES_REMOVEINHOUSEBSM = "stp_MESRemoveInhouseBSM";
        private string stp_MES_UPDATEBAGINFO = "stp_MESUpdateBagInfo";
        private string stp_MES_UPDATEBAGINFOFORITEMREMOVE = "stp_MESUpdateBagInfoForItemRemove";
        private string stp_MES_GETHBSRESULTS = "stp_MESGetHBSResults";
        private string stp_MES_GETHBSRESULTSFORBUTTONENTER = "stp_MESGetHBSResultsForButtonEnter";
        private string stp_MES_GETAIRLINECODE = "stp_MESGetAirlineCode";

        private string stp_MES_INSERTDESTINATIONS = "stp_MESInsertDestinations";
        private string stp_MES_INSERTDESTINATIONCHUTEMAPPING = "stp_MESInsertDestinationChuteMapping";
        private string stp_MES_INSERTDESTINATIONPATHMAPPING = "stp_MESInsertDestinationPathMapping";
        private string stp_MES_INSERTSORTATIONREASON = "stp_MESInsertSortationReason";
        private string stp_MES_CLEARLOCALDATA = "stp_MES_ClearLocalData";
        private string stp_MES_GETSPECIFICDEST = "stp_MESGetSpecificDestination";
        private string stp_MES_GETALLSETTING = "stp_MESGetAllSetting";
        private string stp_MES_CHECKBAGREOCCURENCE = "stp_MESCheckBagReoccurence";
        private string stp_MES_GENERATEFALLBACKTAG = "stp_MESGenerateFallbackTag";
        private string stp_UPDATECHANGEDCONNECTIONMONITORING = "stp_UPDATECHANGEDCONNECTIONMONITORING";
        private string stp_MESUPDATEMDSALARMSFORPROBLEMBAG = "stp_MESUPDATEMDSALARMSFORPROBLEMBAG";
        private string stp_MESUPDATEMDSALARMSFORUSERLOGINLOGOUT = "stp_MESUPDATEALARMSFORUSERLOGINLOGOUT";
        private string stp_MES_INSERTMAKEUPFLIGHTTYPEMAPPING = "stp_MESinsertmakeupflighttypemapping";

        private string stp_MES_INSERTAIRPORTS = "stp_MESinsertairports";
        
        private string stp_MES_CHECKNOBSM = "stp_MESCheckNoBSM";
        private string stp_MES_ALERTENCODINGDURATION = "stp_MESAlertEncodingDuration";

        private string stp_MES_INSERTSECURITYGROUPTASKMAPPING = "stp_MESInsertSecurityGroupTaskMapping";
        private string stp_MES_INSERTSECURITYGROUPTASKS = "stp_MESInsertSecurityGroupTasks";
        private string stp_MES_INSERTSECURITYGROUPS = "stp_MESInsertSecurityGroups";
        private string stp_MES_INSERTSECURITYTASKS = "stp_MESInsertSecurityTasks";
        private string stp_MES_INSERTSECURITYUSERRIGHTS = "stp_MESInsertSecurityUserRights";
        private string stp_MES_INSERTSECURITYUSERS = "stp_MESInsertSecurityUsers";
        private string stp_MES_INSERTSECURITYCATEGORIES = "stp_MESInsertSecurityCategories";
        private string stp_MES_INSERTLOCATIONS = "stp_MESInsertLocations";
        private string stp_MES_GETCHUTEBYDESTINATION = "stp_MESGetChuteByDestination";
        private string stp_MES_GETBAGINFOREASON = "stp_MES_GET_BAG_INFO_REASON";
        private string stp_MES_GETSYSCONFIGTABLECHANGE = "stp_MESGetSysConfigTableChange";
        private string stp_MES_CHUTEAVAILABLECHECKBYDESTINATION = "stp_MES_ChuteAvailableCheckForDestination";
        private const string DOWNLOAD_DATA_TO_LOCAL = "downloadDataToLocal";
       
        private string stp_MES_GETMESEVENT = "stp_MES_GET_MES_EVENT";
        private const string DB_STP_SAC_MINIMUM_HBS_SECURITY_LEVEL_MEET_CHECKING = "stp_SAC_MinimumHBSSecurityLevelMeetChecking";
        private const string DB_STP_SAC_CUSTOMS_SECURITY_MEET_CHECKING = "stp_SAC_CustomsSecurityMeetChecking";
        private const string DB_STP_GET_FUNC_ALLOCATION = "stp_SAC_GetFuncAllocation";
        private const string DB_STP_CHUTE_AVAILABLE_CHECK = "stp_SAC_ChuteAvailableCheck";
        private const string DB_STP_MES_CHUTE_AVAILABLE_CHECK_FOR_DESTINATION = "stp_MES_ChuteAvailableCheckForDestination";
        private const string DB_STP_SAC_GET_SAC_TTS_MES_PRIORITY = "stp_SAC_GetSACTTSMESPriority";
        private const string DB_STP_GET_SAC_PUBLIC_PARAMS = "stp_SAC_GetSACPublicParams";
        private const string DB_STP_GET_ROUTING_TABLE = "stp_SAC_GetRoutingTable";
        private const string DB_STP_GET_IATA_FALLBACK_DISCHARGE = "stp_SAC_GetFallbackTagDischarge";
        private const string DB_STP_SAC_GET_FOUR_DIGITS_FALLBACK_TAG_DISCHARGE = "stp_SAC_GetFourDigitsFallbackTagDischarge";
        private const string DB_STP_SAC_GET_FOUR_DIGITS_SECURITY_TAG_DISCHARGE = "stp_SAC_GetFourDigitsSecurityTagDischarge";
        private const string DB_STP_GET_FLIGHT_ALLOCATION_OF_LP = "stp_SAC_GetFlightAllocationOfLP";
        private const string DB_STP_SAC_GET_FLIGHT_ALLOC_OF_LP_FROM_PSEUDO_BSM = "stp_SAC_GetFlightAllocOfLPFromPseudoBSM";
        private const string DB_STP_GET_AIRLINE_ALLOCATION = "stp_SAC_GetAirlineAllocation";
        private const string DB_STP_SAC_GET_BAG_INFORMATION = "stp_SAC_GetBagInformation";
        private const string DB_STP_SAC_GET_AIRLINE_RUSH = "stp_SAC_GetAirlineRushAllocation";
        private const string DB_STP_SAC_GET_SECURITY_TAG_LEVEL = "stp_SAC_GetSecurityTagLevel";
        private const string DB_STP_SAC_GET_MINIMUM_SECURITY_LEVEL = "stp_SAC_GetMinimumSecurityLevel";
        private const string DB_STP_SAC_GETCANCELLATIONOFFLIGHT = "stp_SAC_GetCancellationOfFlight";
        private const string DB_STP_SAC_GETCUSTOMSREQUIRED = "stp_SAC_GetCustomsRequired";

        private const string DB_STP_SAC_GETIRDVALUES = "stp_SAC_GETIRDVALUESMES";
        private const string DB_STP_SAC_CHECKMUAVAILABILITY = "stp_SAC_CHECKMUAVAILABILITY";
        private const string DB_STP_SAC_GETALLOCPROP = "stp_SAC_GETALLOCPROP";

        private const string FLIGHT_CANCELLATION_VALUE = "flightCancellationValue";

        private const string IS_NEED_CHECK_HBSL1 = "isNeedCheckHBSL1";

        // The name of current class 
        private static readonly string _className =
                    System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Create a logger for use in this class
        private static readonly log4net.ILog _logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        #endregion

        #region Global Fields
        private const string PUBLIC_PARAMETERS = "publicParameters";
        private const string PUBLIC_SUB_PARAMETERS = "param";
        /// <summary>
        /// Database ConnectionString.
        /// </summary>
        public string DBConnectionString { get; set; }
        /// <summary>
        /// Secondary Database ConnectionString.
        /// </summary>
        public string SecondaryDBConnectionString { get; set; }
        /// <summary>
        /// Local database connection string.
        /// </summary>
        public string LocalDBConnectionString { get; set; }
        /// <summary>
        /// Database connection checking thread interval.
        /// </summary>
        public int DBAliveCheckThreadInterval { get; set; }

        /// <summary>
        /// Data changes checking thread interval.
        /// </summary>
        public int DataChangeMonitorInterval { get; set; }

        /// <summary>
        /// Default date format for system
        /// </summary>
        public string DefaultDateFormat { get; set; }

        /// <summary>
        /// Default time format for system.
        /// </summary>
        public string DefaultTimeFormat { get; set; }

        /// <summary>
        /// Default date and time format for system.
        /// </summary>
        public string DefaultDateTimeFormat { get; set; }

        /// <summary>
        /// Command time out for transactions.
        /// </summary>
        public string CommandTimeOut { get; set; }

        /// <summary>
        /// The serial number range for inhouse tag generation.
        /// </summary>
        public string InhouseTagRange { get; set; }

        /// <summary>
        /// Disabled Upload Local DB
        /// </summary>
        public bool DisabledUploadLocalDB { get; set; }

        /// <summary>
        /// Disabled Download Server To Local DB
        /// </summary>
        public bool DisabledDownloadServerToLocalDB { get; set; }

        /// <summary>
        /// Update from GUI to indicate connected information is displayed on screen.
        /// </summary>
        public bool UIConnected { get; set; }
        public bool MainDBAlive { get; set; }
        public bool SecondaryDBAlive { get; set; }
        public string MESDefaultTTS { get; set; }
        public string MESCurrentLocation { get; set; }
        public int BagReoccurance { get; set; }
        public int DisplayMessageDuration { get; set; }
        public int NoBSMReoccurance { get; set; }
        public bool EnableHBS2BSysKey { get; set; }
        public bool EnableAirRushAlloc { get; set; }
        public bool EnableRushFuncAlloc { get; set; }
        public int EncodeDuration { get; set; }
        public string InHouseTagConstant { get; set; }
        public string IATATagConstant { get; set; }
        public string ApplicationLiveStatus { get; set; }
        public string EquipmentID { get; set; }
        public string NoBSMReoccuranceAlarmType { get; set; }
        public string EncodeDurationAlarmType { get; set; }
        public string SecurityCategoryCode { get; set; }
        public string SecurityContainerName { get; set; }
        public string SecurityDomainExtension { get; set; }
        public string SecurityDomainName { get; set; }
        public string SecurityOrgName { get; set; }
        public string SecurityIPAddress { get; set; }
        public bool IsDomainAvailable { get; set; }

        /// <summary>
        /// Application live status update key.
        /// </summary>
        public string AppLiveStatusUpdateKey { get; set; }

        /// <summary>
        /// Application log on or off status update key.
        /// </summary>
        public string AppLogOnOffUpdateKey { get; set; }

        /// <summary>
        /// Application live status update interval.
        /// </summary>
        public int AppLiveUpdateInterval { get; set; }

        /// <summary>
        /// The Wildcard.
        /// </summary>
        public string Wildcard { get; set; }

        /// <summary>
        /// The HBSAcceptedID.
        /// </summary>
        public string HBSAcceptedID { get; set; }

        /// <summary>
        /// The Public ParametersHash
        /// </summary>
        public Hashtable ParametersHash { get; set; }

        /// <summary>
        /// The DefaultHBSLevel.
        /// </summary>
        public string DefaultHBSLevel { get; set; }

        /// <summary>
        /// The CustomsAcceptedID.
        /// </summary>
        public List<string> CustomsAcceptedID { get; set; }

        /// <summary>
        /// The SortReasonSTRY.
        /// </summary>
        public string SortReasonSTRY { get; set; }

        /// <summary>
        /// The SortReasonCRB.
        /// </summary>
        public string SortReasonCRB { get; set; }

        /// <summary>
        /// The SortReasonDTUA.
        /// </summary>
        public string SortReasonDTUA { get; set; }

        /// <summary>
        /// The SortReasonEBSHBS.
        /// </summary>
        public string SortReasonEBSHBS { get; set; }

        /// <summary>
        /// The SortReasonTERL.
        /// </summary>
        public string SortReasonTERL { get; set; }

        /// <summary>
        /// The SortReason CCFL.
        /// </summary>
        public string SortReasonCCFL { get; set; }

        /// <summary>
        /// The SortReasonMRDD.
        /// </summary>
        public string SortReasonMRDD { get; set; }

        /// <summary>
        /// The SortReasonDELF.
        /// </summary>
        public string SortReasonDELF { get; set; }

        /// <summary>
        /// The SortReasonOFBK.
        /// </summary>
        public string SortReasonOFBK { get; set; }       


        /// <summary>
        /// The FUNC_ALLOCATION_MTLP.
        /// </summary>
        public string FuncAllocationMTLP { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_CRB.
        /// </summary>
        public string FuncAllocationCRB { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_MBSM.
        /// </summary>
        public string FuncAllocationMBSM { get; set; }

        /// <summary>
        /// The FuncAllocationEDS.
        /// </summary>
        public string FuncAllocationEDS { get; set; }   

        /// <summary>
        /// The FuncAllocationCCFL.
        /// </summary>
        public string FuncAllocationCCFL { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_PB01.
        /// </summary>
        public string FuncAllocationPB01 { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_PB02.
        /// </summary>
        public string FuncAllocationPB02 { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_DP01.
        /// </summary>
        public string FuncAllocationDP01 { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_DP02.
        /// </summary>
        public string FuncAllocationDP02 { get; set; }

        /// <summary>
        /// The CustomsChuteLocation.
        /// </summary>
        public LocationID[] CustomsChuteLocation { get; set; }

        /// <summary>
        /// The Column RESOURCE.
        /// </summary>
        public string ColumnResource { get; set; }

        /// <summary>
        /// The Column SUBSYSTEM.
        /// </summary>
        public string ColumnSubsystem { get; set; }

        /// <summary>
        /// The Column VALUE 
        /// </summary>
        public string ColumnValue { get; set; }

        /// <summary>
        /// The Column SYSKEY.
        /// </summary>
        public string ColumnSysKey { get; set; }

        /// <summary>
        /// The Column SYSVALUE.
        /// </summary>
        public string ColumnSysValue { get; set; }


        /// <summary>
        /// The TTSSorter01.
        /// </summary>
        public string TTSSorter01 { get; set; }

        /// <summary>
        /// The TTSSorter02.
        /// </summary>
        public string TTSSorter02 { get; set; }

        /// <summary>
        /// The TTS01 MESLocation.
        /// </summary>
        public LocationID[] TTS01MESLocation { get; set; }

        /// <summary>
        /// The TTS02 MESLocation.
        /// </summary>
        public LocationID[] TTS02MESLocation { get; set; }

        /// <summary>
        /// The TTS01 RecirculationStartedPoint.
        /// </summary>
        public LocationID[] TTS01OverflowStartLocation { get; set; }


        /// <summary>
        /// The TTS02 RecirculationStartedPoint.
        /// </summary>
        public LocationID[] TTS02OverflowStartLocation { get; set; }

        /// <summary>
        /// The SchemeTTS2Alloc.
        /// </summary>
        public string SchemeTTS2Alloc { get; set; }

        /// <summary>
        /// The SchemeTTS1Alloc.
        /// </summary>
        public string SchemeTTS1Alloc { get; set; }

        /// <summary>
        /// The SchemaFlightAllocation.
        /// </summary>
        public string SchemaFlightAllocation { get; set; }

        /// <summary>
        /// The SchemaTypeRoundRobin.
        /// </summary>
        public string SchemaTypeRoundRobin { get; set; }

        /// <summary>
        /// The SchemaTypeWaterfallPriority.
        /// </summary>
        public string SchemaTypeWaterfallPriority { get; set; }

        /// <summary>
        /// The SchemaTypeWaterfallShortestPath.
        /// </summary>
        public string SchemaTypeWaterfallShortestPath { get; set; }

        /// <summary>
        /// The SchemaFunctionAllocation.
        /// </summary>
        public string SchemaFunctionAllocation { get; set; }

        /// <summary>
        /// The SchemaAirlineAllocation.
        /// </summary>
        public string SchemaAirlineAllocation { get; set; }

        /// <summary>
        /// The EBSBagToHBSEnabled.
        /// </summary>
        public bool EBSBagToHBSEnabled { get; set; }

        /// <summary>
        /// The EDSChuteLocation.
        /// </summary>
        public LocationID[] EDSChuteLocation { get; set; }

        /// <summary>
        /// The EDSCDSChute.
        /// </summary>
        public List<string> EDSCDSChute { get; set; }

        /// <summary>
        /// The SortReasonMSSL.
        /// </summary>
        public string SortReasonMSSL { get; set; }

        /// <summary>
        /// The AirportLocationCode.
        /// </summary>
        public string AirportLocationCode { get; set; }

        /// <summary>
        /// Empty License Plate - 10 digits of 0 (Hex30)
        /// </summary>
        public string EmptyLicensePlate { get; set; }

        /// <summary>
        /// The FourDigitsSecuritySortEnabled.
        /// </summary>
        public bool FourDigitsSecuritySortEnabled { get; set; }

        /// <summary>
        /// The FourDigitsFallbackSortEnabled.
        /// </summary>
        public bool FourDigitsFallbackSortEnabled { get; set; }

        /// <summary>
        /// The FallbackSortEnabled.
        /// </summary>
        public bool FallbackSortEnabled { get; set; }

        /// <summary>
        /// The InHouseSortEnabled.
        /// </summary>
        public bool InHouseSortEnabled { get; set; }

        /// <summary>
        /// The AirlineRushAllocEnabled.
        /// </summary>
        public bool AirlineRushAllocEnabled { get; set; }


        /// <summary>
        /// The BCASEnabled.
        /// </summary>
        public bool BCASEnabled { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GETROUTINGTABLE].
        /// </summary>
        public string STPGetRoutingTable { get; set; }

        /// <summary>
        /// The Column LOCATION.
        /// </summary>
        public string ColumnLocation { get; set; }

        /// <summary>
        /// The Column COST.
        /// </summary>
        public string ColumnCost { get; set; }

        /// <summary>
        /// The SortReasonNORD.
        /// </summary>
        public string SortReasonNORD { get; set; }

        /// <summary>
        /// The SortReasonNBSM.
        /// </summary>
        public string SortReasonNBSM { get; set; }

        /// <summary>
        /// The SortReasonMBSM.
        /// </summary>
        public string SortReasonMBSM { get; set; }

        /// <summary>
        /// The SortReasonMTLP.
        /// </summary>
        public string SortReasonMTLP { get; set; }

        /// <summary>
        /// The SortReasonUNFL.
        /// </summary>
        public string SortReasonUNFL { get; set; }

        /// <summary>
        /// The SortReasonNOAL.
        /// </summary>
        public string SortReasonNOAL { get; set; }

        /// <summary>
        /// The SortReasonALAL.
        /// </summary>
        public string SortReasonALAL { get; set; }

        /// <summary>
        /// The SortReasonFEXC.
        /// </summary>
        public string SortReasonFEXC { get; set; }

        /// <summary>
        /// The SortReasonIATAFallback.
        /// </summary>
        public string SortReasonIATAFallback { get; set; }

        /// <summary>
        /// The SortReasonFourDigitsFallback.
        /// </summary>
        public string SortReasonFourDigitsFallback { get; set; }

        /// <summary>
        /// The SortReasonFourDigitsSecurity.
        /// </summary>
        public string SortReasonFourDigitsSecurity { get; set; }

        /// <summary>
        /// The SortReasonPROB.
        /// </summary>
        public string SortReasonPROB { get; set; }

        /// <summary>
        /// The SortReasonALLO.
        /// </summary>
        public string SortReasonALLO { get; set; }

        /// <summary>
        /// The SortReasonRUSH.
        /// </summary>
        public string SortReasonRUSH { get; set; }

        /// <summary>
        /// The SortReasonLATE.
        /// </summary>
        public string SortReasonLATE { get; set; }

        /// <summary>
        /// The SortReasonERLY.
        /// </summary>
        public string SortReasonERLY { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_NORD.
        /// </summary>
        public string FuncAllocationNORD { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_NBSM.
        /// </summary>
        public string FuncAllocationNBSM { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_NOAL.
        /// </summary>
        public string FuncAllocationNOAL { get; set; }


        /// <summary>
        /// The FUNC_ALLOCATION_UNFL.
        /// </summary>
        public string FuncAllocationUNFL { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_FEXC.
        /// </summary>
        public string FuncAllocationFEXC { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_RUSH.
        /// </summary>
        public string FuncAllocationRUSH { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_TERL.
        /// </summary>
        public string FuncAllocationTERL { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_ERLY.
        /// </summary>
        public string FuncAllocationERLY { get; set; }

        /// <summary>
        /// The FUNC_ALLOCATION_LATE.
        /// </summary>
        public string FuncAllocationLATE { get; set; }

        /// <summary>
        /// The Column Destination 
        /// </summary>
        public string ColumnDestination { get; set; }

        /// <summary>
        /// The Column Airline.
        /// </summary>
        public string ColumnAirline { get; set; }

        /// <summary>
        /// The Column FlightNo.
        /// </summary>
        public string ColumnFlightNo { get; set; }

        /// <summary>
        /// The Column SDO.
        /// </summary>
        public string ColumnSDO { get; set; }

        /// <summary>
        /// The Column STO.
        /// </summary>
        public string ColumnSTO { get; set; }

        /// <summary>
        /// The Column Master Airline.
        /// </summary>
        public string ColumnMasterAirline { get; set; }

        /// <summary>
        /// The Column Master FlightNo.
        /// </summary>
        public string ColumnMasterFlightNo { get; set; }

        /// <summary>
        /// The RelatedNameSTD.
        /// </summary>
        public string RelatedNameSTD { get; set; }

        /// <summary>
        /// The RelatedNameETD.
        /// </summary>
        public string RelatedNameETD { get; set; }

        /// <summary>
        /// The RelatedNameITD.
        /// </summary>
        public string RelatedNameITD { get; set; }

        /// <summary>
        /// The RelatedNameATD.
        /// </summary>
        public string RelatedNameATD { get; set; }

        /// <summary>
        /// The Column EDO.
        /// </summary>
        public string ColumnEDO { get; set; }

        /// <summary>
        /// The Column ETO.
        /// </summary>
        public string ColumnETO { get; set; }

        /// <summary>
        /// The Column IDO.
        /// </summary>
        public string ColumnIDO { get; set; }

        /// <summary>
        /// The Column ITO.
        /// </summary>
        public string ColumnITO { get; set; }

        /// <summary>
        /// The Column ADO.
        /// </summary>
        public string ColumnADO { get; set; }

        /// <summary>
        /// The Column ATO.
        /// </summary>
        public string ColumnATO { get; set; }

        /// <summary>
        /// The Column Early Open Offset.
        /// </summary>
        public string ColumnEarlyOpenOffset { get; set; }

        /// <summary>
        /// The Column Alloc Open Offset.
        /// </summary>
        public string ColumnAllocOpenOffset { get; set; }

        /// <summary>
        /// The Column Alloc Open Related.
        /// </summary>
        public string ColumnAllocOpenRelated { get; set; }

        /// <summary>
        /// The Column Alloc Close Offset.
        /// </summary>
        public string ColumnAllocCloseOffset { get; set; }

        /// <summary>
        /// The Column Alloc Close Related.
        /// </summary>
        public string ColumnAllocCloseRelated { get; set; }

        /// <summary>
        /// The Column Rush Duration
        /// </summary>
        public string ColumnRushDuration { get; set; }

        /// <summary>
        /// The Column Travel Class
        /// </summary>
        public string ColumnTravelClass { get; set; }

        /// <summary>
        /// The Column Is Manual Closed
        /// </summary>
        public string ColumnIsManualClosed { get; set; }

        /// <summary>
        /// The Column Is Closed
        /// </summary>
        public string ColumnIsClosed { get; set; }

        /// <summary>
        /// The Column Bag Type 
        /// </summary>
        public string ColumnBagType { get; set; }

        /// <summary>
        /// The Column Passenger Destination
        /// </summary>
        public string ColumnPassengerDestination { get; set; }

        /// <summary>
        /// The Column Transfer 
        /// </summary>
        public string ColumnTransfer { get; set; }

        /// <summary>
        /// The AirlineSortEnabled.
        /// </summary>
        public bool AirlineSortEnabled { get; set; }

        /// <summary>
        /// The EarlyEnabled.
        /// </summary>
        public bool EarlyEnabled { get; set; }

        /// <summary>
        /// The GlobalRushAllocEnabled.
        /// </summary>
        public bool GlobalRushAllocEnabled { get; set; }

        /// <summary>
        /// The EarlyOpenEnabled.
        /// </summary>
        public bool EarlyOpenEnabled { get; set; }

        /// <summary>
        /// The LateEnabled.
        /// </summary>
        public bool LateEnabled { get; set; }

        /// <summary>
        /// The Recirculation Over Dump.
        /// </summary>
        public bool RecirculationOverDump { get; set; }

        /// <summary>
        /// The IATAInterlineIdentifier.
        /// </summary>
        public string IATAInterlineIdentifier { get; set; }

        /// <summary>
        /// The IATAFallbackIdentifier.
        /// </summary>
        public string IATAFallbackIdentifier { get; set; }

        /// <summary>
        /// The InHouseIdentifier. - 9
        /// </summary>
        public string InHouseIdentifier { get; set; }

        /// <summary>
        /// The InHouseAirlineCode. - 333
        /// </summary>
        public string InHouseAirlineCode { get; set; }


        /// <summary>
        /// The FourDigitsSecurityIdentification.
        /// </summary>
        public string FourDigitsSecurityIdentification { get; set; }

        /// <summary>
        /// The FourDigitsFallbackIdentification.
        /// </summary>
        public string FourDigitsFallbackIdentification { get; set; }

        /// <summary>
        /// Dummy Multiple License Plate - 10 digits of 9 (Hex39)
        /// </summary>
        public string DummyMultipleLicensePlate { get; set; }

        /// <summary>
        /// The FlightCancellationValue.
        /// </summary>
        public string FlightCancellationValue { get; set; }

        /// <summary>
        /// The DefaultCurrentHBSLevel.
        /// </summary>
        public string DefaultCurrentHBSLevel { get; set; }

        /// <summary>
        /// The HBSLevel1ID.
        /// </summary>
        public string HBSLevel1ID { get; set; }

        /// <summary>
        /// The HBSLevel2ID.
        /// </summary>
        public string HBSLevel2ID { get; set; }

        /// <summary>
        /// The HBSLevel3ID.
        /// </summary>
        public string HBSLevel3ID { get; set; }

        /// <summary>
        /// The HBSLevel4ID.
        /// </summary>
        public string HBSLevel4ID { get; set; }

        /// <summary>
        /// The HBSLevel5ID.
        /// </summary>
        public string HBSLevel5ID { get; set; }

        /// <summary>
        /// The HBSLevel1Location.
        /// </summary>
        public string HBSLevel1Location { get; set; }

        /// <summary>
        /// The HBSLevel2Location.
        /// </summary>
        public string HBSLevel2Location { get; set; }

        /// <summary>
        /// The HBSLevel3Location.
        /// </summary>
        public string HBSLevel3Location { get; set; }

        /// <summary>
        /// The HBSLevel4Location.
        /// </summary>
        public string HBSLevel4Location { get; set; }

        /// <summary>
        /// The HBSLevel5Location.
        /// </summary>
        public string HBSLevel5Location { get; set; }


        ///// <summary>
        ///// The LifeTimeRoundRobinBuffer.
        ///// </summary>
        //public int LifeTimeRRBuffer { get; set; }


        public FunctionList MES_FunctionList { get; set; }

        public MESConfig MES_Config;

        public string MES_Station_Name { get; set; }
        #region Storeprocedures
        /// <summary>
        /// Date time format default storeprocedure
        /// </summary>
        public string stp_RPT_GETDATETIME_FORMAT { get; set; }
        /// <summary>
        /// Insert Item Encoded data into database.
        /// </summary>
        public string stp_MES_INSERT_ITEM_ENCODED { get; set; }
        /// <summary>
        /// Insert received item information into database.
        /// </summary>
        public string stp_MES_INSERT_ITEM_READY { get; set; }
        /// <summary>
        /// Insert inserted item information into database.
        /// </summary>
        public string stp_MES_INSERT_ITEM_INSERTACK { get; set; }
        /// <summary>
        /// Insert inserted item information into database.
        /// </summary>
        public string stp_MES_INSERT_ITEM_INSERT { get; set; }
        /// <summary>
        /// Insert removed item information into database.
        /// </summary>
        public string stp_MES_INSERT_ITEM_REMOVED { get; set; }
        /// <summary>
        /// Insert MES station events into database.
        /// </summary>
        public string stp_MES_INSERT_MES_EVENT { get; set; }
        /// <summary>
        /// Get flight allocation information storeprocedure.
        /// </summary>
        public string stp_MES_GET_FLIGHT_ALLOC { get; set; }
        /// <summary>
        /// Get last encoding tag and reason
        /// </summary>
        public string stp_MES_GET_LAST_ENCODING{get;set;}
        /// <summary>
        /// Get pessenger information
        /// </summary>
        public string stp_MES_GET_PESSENGER_INFO { get; set; }
        /// <summary>
        /// Get pessenger information
        /// </summary>
        public string stp_MES_GET_FLIGHT_INFO { get; set; }
        /// Get flight type information
        /// </summary>
        public string stp_MES_GET_FLIGHT_TYPE { get; set; }
        /// <summary>
        /// Get Airline information
        /// </summary>
        public string stp_MES_GET_AIRLINE_INFO { get; set; }
        /// <summary>
        /// Get locally inserted data while MES statation is disconnected from main database.
        /// </summary>
        public string stp_MES_GET_LOCAL_INSERTED_DATA { get; set; }
        /// <summary>
        /// Remove locally inserted data after transfer those data to MES station while MES station re-connecte
        /// back to main database.
        /// </summary>
        public string stp_MES_REMOVE_LOCAL_INSERTED_DATA { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GETCUSTOMSREQUIRED].
        /// </summary>
        public string STPGetCustomsRequired { get; set; }

        public string stp_MES_INSERT_ITEM_ENCODED_FROM_LOCAL { get; set; }
        public string stp_MES_INSERT_ITEM_READY_FROM_LOCAL { get; set; }
        public string stp_MES_INSERT_ITEM_INSERT_FROM_LOCAL { get; set; }
        public string stp_MES_INSERT_ITEM_INSERTACK_FROM_LOCAL { get; set; }
        public string stp_MES_INSERT_ITEM_REMOVED_FROM_LOCAL { get; set; }
        public string stp_MES_INSERT_MES_EVENT_FROM_LOCAL { get; set; }
        public string stp_MES_GET_CHUTE_BY_DESTINATION { get; set; }
        public string stp_MES_GET_REQUIRED_INFO_FROM_SERVER { get; set; }
        public string stp_MES_INSERT_CHUTE_MAPPING { get; set; }
        public string stp_MES_INSERT_AIRLINES { get; set; }
        public string stp_MES_INSERT_BAG_INFO { get; set; }
        public string stp_MES_INSERT_BAG_SORTING { get; set; }
        public string stp_MES_INSERT_FALLBACK_MAPPING { get; set; }
        public string stp_MES_INSERT_4DIGITS_FALLBACK_MAPPING { get; set; }
        public string stp_MES_INSERT_FLIGHT_PLAN_ALLOC { get; set; }
        public string stp_MES_INSERT_FUNCTION_ALLOC_GANTT { get; set; }
        public string stp_MES_INSERT_FUNCTION_ALLOC_LIST { get; set; }
        public string stp_MES_INSERT_FUNCTION_TYPES { get; set; }
        public string stp_MES_INSERT_SYS_CONFIG { get; set; }
        public string stp_MES_GET_BAG_GID { get; set; }
        public string stp_MES_GET_LICENSE_PLATE { get; set; }
        public string stp_MES_GENERATE_IN_HOUSE_BSM { get; set; }
        public string stp_MES_GET_INHOUSE_BSM { get; set; }
        public string stp_MES_UPDATE_ITEM_INHOUSE_BSM { get; set; }
        public string stp_MES_GET_IATA_TAG_LIST { get; set; }
        public string stp_MES_GET_COMBO_DATA { get; set; }
        public string stp_MES_GET_PROBLEM_LOCATION { get; set; }
        public string stp_MES_GET_RUSH_LOCATION { get; set; }
        public string stp_MES_INSERT_INHOUSE_BSM_FROM_LOCAL { get; set; }
        public string stp_MES_INSERT_FLIGHT_PLAN_SORTING { get; set; }
        public string stp_MES_GET_AIRLINES { get; set; }
        public string stp_MES_GET_FLIGHT { get; set; }
        public string stp_MES_GET_DESTINATION { get; set; }
        public string stp_MES_GET_REASON { get; set; }
        public string stp_MES_REMOVE_INHOUSE_BSM { get; set; }
        public string stp_MES_UPDATE_BAG_INFO { get; set; }
        public string stp_MES_UPDATE_BAG_INFO_FOR_ITEM_REMOVE { get; set; }

        public string stp_MES_INSERT_DESTINATIONS { get; set; }
        public string stp_MES_INSERT_DESTINATION_CHUTE_MAPPING { get; set; }
        public string stp_MES_INSERT_DESTINATION_PATH_MAPPING { get; set; }
        public string stp_MES_INSERT_SORTATION_REASON { get; set; }
        public string stp_MES_CLEAR_LOCAL_DATA { get; set; }
        public string stp_MES_GET_SPECIFIC_DEST { get; set; }
        public string stp_MES_GET_ALL_SETTING { get; set; }
        public string stp_MES_CHECK_BAG_REOCCURENCE { get; set; }
        public string stp_MES_GENERATE_FALLBACKTAG { get; set; }
        public string stp_UPDATE_CHANGED_CONNECTION_MONITORING { get; set; }
        public string stp_MES_UPDATE_MDS_ALARMS_FOR_PROBLEM_BAG { get; set;}
        public string stp_MES_UPDATE_MDS_ALARMS_FOR_USER_LOGIN_LOGOUT { get; set; }
        public string stp_MES_GET_HBS_RESULTS { get; set; }
        public string stp_MES_GET_HBS_RESULTS_FOR_BUTTON_ENTER { get; set; }
        public string stp_MES_GET_AIRLINE_CODE { get; set; }

        public string stp_MES_INSERT_AIRLINE_CODE_SHORTCUTS { get; set; }
        public string stp_MES_INSERT_AIRPORTS { get; set; }
        public string stp_MES_INSERT_HBS_AIRLINE { get; set; }
        public string stp_MES_INSERT_HBS_COUNTRY { get; set; }
        public string stp_MES_INSERT_HBS_FLIGHT { get; set; }
        public string stp_MES_INSERT_HBS_PASSENGER { get; set; }
        public string stp_MES_INSERT_HBS_POLICY_MANAGEMENT { get; set; }
        public string stp_MES_INSERT_HBS_SCHEDULE { get; set; }
        public string stp_MES_INSERT_HBS_TAG_TYPE { get; set; }
        public string stp_MES_INSERT_HBS_LEVEL { get; set; }
        public string stp_MES_CHECK_NO_BSM { get; set; }
        public string stp_MES_ALERT_ENCODING_DURATION { get; set; }
        public string stp_MES_INSERT_MAKEUP_FLIGHT_TYPE_MAPPING { get; set; }

        public string stp_MES_INSERT_SECURITY_GROUP_TASK_MAPPING { get; set; }
        public string stp_MES_INSERT_SECURITY_GROUP_TASKS { get; set; }
        public string stp_MES_INSERT_SECURITY_GROUPS { get; set; }
        public string stp_MES_INSERT_SECURITY_TASKS { get; set; }
        public string stp_MES_INSERT_SECURITY_USER_RIGHTS { get; set; }
        public string stp_MES_INSERT_SECURITY_USERS { get; set; }
        public string stp_MES_INSERT_SECURITY_CATEGORIES { get; set; }
        public string stp_MES_INSERT_LOCATIONS { get; set; }
        public string stp_MES_GET_BAG_INFO_REASON { get; set; }
        public string stp_MES_GET_MES_EVENT { get; set; }
        public string stp_MES_GET_SYS_CONFIG_TABLE_CHANGE { get; set; }
        public string DownloadDataToLocal { get; set; }


        public string stp_MES_GET_CONV_STATUS { get; set; }

        //used to get conveyor status legend - Guo Wenyu 2014/04/24
        public string stp_MES_GET_LOCATION_STATUS_TYPE { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_MinimumHBSSecurityLevelMeetChecking].
        /// </summary>
        public string STPMinimumHBSSecurityLevelMeetChecking { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_CustomsSecurityMeetChecking].
        /// </summary>
        public string STPCustomsSecurityMeetChecking { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GETFUNCALLOCATION].
        /// </summary>
        public string STPGetFunctionAllocation { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_CHUTEAVAILABLECHECK].
        /// </summary>
        public string STPChuteAvailableCheck { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_MES_CHUTEAVAILABLECHECKFORDESTINATION].
        /// </summary>
        public string STPChuteAvailableCheckForDestination { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [STPGetSACTTSMESPriority].
        /// </summary>
        public string STPGetSACTTSMESPriority { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GetFallbackTagDischarge].
        /// </summary>
        public string STPGetIATAFallbackTagDischarged { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GetFourDigitsFallbackTagDischarge].
        /// </summary>
        public string STPGetFourDigitsFallbackTagDischarge { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GetFourDigitsSecurityTagDischarge].
        /// </summary>
        public string STPGetFourDigitsSecurityTagDischarge { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GetFlightAllocationOfLP].
        /// </summary>
        public string STPGetFlightAllocationOfLP { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GetFlightAllocOfLPFromPseudoBSM].
        /// </summary>
        public string STPGetFlightAllocOfLPFromPseudoBSM { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GetAirlineAllocation].
        /// </summary>
        public string STPGetAirlineAllocation { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GetBagInformation].
        /// </summary>
        public string STPGetBagInformation { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GetAirlineRush].
        /// </summary>
        public string STPGetAirlineRush { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GetSecurityTagLevel].
        /// </summary>
        public string STPGetSecurityTagLevel { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GetMinimumSecurityLevel].
        /// </summary>
        public string STPGetMinimumSecurityLevel { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GETSACPUBLICPARAMETERS].
        /// </summary>
        public string STPGetSACPublicParams { get; set; }

        /// <summary>
        /// The name of DB StoredProcedure [stp_SAC_GETCANCELLATIONOFFLIGHT].
        /// </summary>
        public string STPGetCancellationOfFlight { get; set; }

        /// <summary>
        /// The name of DB Stored Procedure [stp_SAC_GETIRDVALUES@MES]
        /// </summary>
        public string STPGetIRDValues { get; set; }

        /// <summary>
        /// The name of DB Stored Proceudre [stp_SAC_CHECKMUAVAILABILITY]
        /// </summary>
        public string STPCheckMUAvailability { get; set; }

        /// <summary>
        /// The name of DB Stored Proceudre [stp_SAC_GETALLOCPROP]
        /// </summary>
        public string STPSACGetAllocProp { get; set; }

        /// <summary>
        /// IsNeedCheckHBSL1 - False
        /// </summary>
        public bool IsNeedCheckHBSL1 { get; set; }
        #endregion
        #endregion
        #endregion

        #region Class Constructor & Destructor
        /// <summary>
        /// Class constructer.
        /// </summary>
        public PersistorParameters(XmlNode configSet, XmlNode telegramSet)
        {
            if (configSet == null)
                throw new Exception("Constractor parameter can not be null! Creating class object fail! " +
                        "<BHS.MES.DataPersistor.Database.PersistorParametersConstructor()>");

            if (Init(ref configSet, ref telegramSet) == false)
                throw new Exception("Instantiate class object failure! " +
                    "<BHS.MES.DataPersistor.Database.PersistorParameters.Constructor()>");
        }

        /// <summary>
        /// Class destructer.
        /// </summary>
        ~PersistorParameters()
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
            return;
        }

        #endregion

        #region Class Methods

        /// <summary>
        /// Class Initialization.
        /// </summary>
        /// <param name="configSet"></param>
        /// <param name="telegramSet"></param>
        /// <returns></returns>
        public bool Init(ref XmlNode configSet, ref XmlNode telegramSet)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            try
            {
                MES_FunctionList = new FunctionList(false, false, false, false, false, false, false,false);
                
                DBConnectionString = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_CONNECTION_STRING, string.Empty)).Trim();
                if (DBConnectionString == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Database ConnectionString setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SecondaryDBConnectionString = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_SECONDARY_CONNECTION_STRING, string.Empty)).Trim();
                if (SecondaryDBConnectionString == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Secondary Database ConnectionString setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                LocalDBConnectionString = (XMLConfig.GetSettingFromInnerText(
                            configSet, LOCALDB_CONNECTION_STRING, string.Empty)).Trim();
                if (LocalDBConnectionString == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Local Database ConnectionString setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                DBAliveCheckThreadInterval = Convert.ToInt32((XMLConfig.GetSettingFromInnerText(configSet,
                        DB_ALIVE_CHECK_THREAD_INTERVAL, "0")).Trim());
                if (DBAliveCheckThreadInterval == 0)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Database ConnectionChecking Thread Interval setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                DataChangeMonitorInterval = Convert.ToInt32((XMLConfig.GetSettingFromInnerText(configSet,
                        DATA_CHANGES_MONITOR_INTERVAL, "0")));
                if (DataChangeMonitorInterval == 0)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Data Changes Checking Thread Interval setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                _parametersHashtable = new Hashtable();
                ParametersHash = Hashtable.Synchronized(_parametersHashtable);
                ParametersHash.Clear();

                XmlNode parameterConfigSet;
                parameterConfigSet = XMLConfig.GetConfigSetElement(ref configSet, PUBLIC_PARAMETERS);
                if (parameterConfigSet == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + PUBLIC_PARAMETERS + "> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }
                else
                {
                    int size;
                    string tempPublicParameters = string.Empty;

                    size = parameterConfigSet.ChildNodes.Count;

                    for (int i = 0; i < size; i++)
                    {
                        if (parameterConfigSet.ChildNodes[i].Name == PUBLIC_SUB_PARAMETERS)
                        {
                            tempPublicParameters = parameterConfigSet.ChildNodes[i].InnerText.Trim();

                            if (tempPublicParameters == string.Empty)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("One of the <" + PUBLIC_SUB_PARAMETERS + "> setting value is empty! <" + thisMethod + ">.");

                                return false;
                            }

                            if (ParametersHash.Contains(tempPublicParameters))
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("The duplicate parameter name is detected in <" + PUBLIC_SUB_PARAMETERS + "> setting! <" + thisMethod + ">.");

                                return false;
                            }
                            else
                            {
                                ParametersHash.Add(tempPublicParameters, "");
                            }
                        }
                    }
                }

                XmlNode GUIConfigSet;
                GUIConfigSet = XMLConfig.GetConfigSetElement(ref configSet, "BHS.MES.GUI");
                //----// added by PST
                stp_MES_GET_CONV_STATUS = (XMLConfig.GetSettingFromInnerText(configSet,
                                        DB_STP_MES_GET_CONV_STATUS, string.Empty)).Trim();
                if (stp_MES_GET_CONV_STATUS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("stp_MES_GET_CONV_STATUS format storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                // The stp used to get all conveyor status type shown as legend in MES conveyor layout
                stp_MES_GET_LOCATION_STATUS_TYPE = (XMLConfig.GetSettingFromInnerText(configSet,
                                        DB_STP_MES_GET_LOCATIONS_STATUS_TYPE, string.Empty)).Trim();
                if (stp_MES_GET_LOCATION_STATUS_TYPE == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("stp_MES_GET_LOCATION_STATUS_TYPE stored procedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }



                stp_RPT_GETDATETIME_FORMAT = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_RPT_GETDATETIMEFORMAT, string.Empty)).Trim();
                if (stp_RPT_GETDATETIME_FORMAT == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Datetime format storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_ITEM_ENCODED = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTITEMENCODED, string.Empty)).Trim();
                if (stp_MES_INSERT_ITEM_ENCODED == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert item encoded storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_ITEM_READY = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTITEMREADY, string.Empty)).Trim();
                if (stp_MES_INSERT_ITEM_READY == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert item ready storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_ITEM_INSERT = (XMLConfig.GetSettingFromInnerText(configSet,
                        stp_MES_INSERTITEMINSERT, string.Empty)).Trim();
                if (stp_MES_INSERT_ITEM_INSERT == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert item insert storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_ITEM_INSERTACK = (XMLConfig.GetSettingFromInnerText(configSet,
                        stp_MES_INSERTITEMINSERTACK, string.Empty)).Trim();
                if (stp_MES_INSERT_ITEM_INSERTACK == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert item insert acknowledge storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_ITEM_REMOVED = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTITEMREMOVED, string.Empty)).Trim();
                if (stp_MES_INSERT_ITEM_REMOVED == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert item remove storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_MES_EVENT = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTMESEVENT, string.Empty)).Trim();
                if (stp_MES_INSERT_MES_EVENT == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert MES event storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_FLIGHT_ALLOC = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETFLIGHTALLOC, string.Empty)).Trim();
                if (stp_MES_GET_FLIGHT_ALLOC == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert MES event storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_LAST_ENCODING = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETLASTENCODING, string.Empty)).Trim();
                if (stp_MES_GET_LAST_ENCODING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert MES event storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_PESSENGER_INFO = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETPESSENGERINFO, string.Empty)).Trim();
                if (stp_MES_GET_PESSENGER_INFO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get passenger info storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_FLIGHT_INFO = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETFLIGHTINFO, string.Empty)).Trim();
                if (stp_MES_GET_FLIGHT_INFO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get flight info store procedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_FLIGHT_TYPE = (XMLConfig.GetSettingFromInnerText(configSet,
                                         stp_MES_GETFLIGHTTYPE, string.Empty)).Trim();
                if (stp_MES_GET_FLIGHT_TYPE == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get flight type info storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                //Added by Guo Wenyu 2014/03/23
                stp_MES_GET_AIRLINE_INFO = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETAIRLINEINFO, string.Empty)).Trim();
                if (stp_MES_GET_AIRLINE_INFO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get flight info store procedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_LOCAL_INSERTED_DATA = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETLOCALINSERTEDDATA, string.Empty)).Trim();
                if (stp_MES_GET_LOCAL_INSERTED_DATA== string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get local inserted data storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_REMOVE_LOCAL_INSERTED_DATA = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_REMOVELOCALINSERTEDDATA, string.Empty)).Trim();
                if (stp_MES_REMOVE_LOCAL_INSERTED_DATA == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Remove local inserted data storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_ITEM_ENCODED_FROM_LOCAL = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTITEMENCODEDFROMLOCAL, string.Empty)).Trim();
                if (stp_MES_INSERT_ITEM_ENCODED_FROM_LOCAL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert item encoded data from local storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_ITEM_READY_FROM_LOCAL = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTITEMREADYFROMLOCAL, string.Empty)).Trim();
                if (stp_MES_INSERT_ITEM_READY_FROM_LOCAL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert item ready data from local storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_ITEM_INSERTACK_FROM_LOCAL = (XMLConfig.GetSettingFromInnerText(configSet,
                        stp_MES_INSERTITEMINSERTACKFROMLOCAL, string.Empty)).Trim();
                if (stp_MES_INSERT_ITEM_INSERTACK_FROM_LOCAL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert item insert ack data from local storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_ITEM_INSERT_FROM_LOCAL = (XMLConfig.GetSettingFromInnerText(configSet,
                        stp_MES_INSERTITEMINSERTFROMLOCAL, string.Empty)).Trim();
                if (stp_MES_INSERT_ITEM_INSERT_FROM_LOCAL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert item insert data from local storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_ITEM_REMOVED_FROM_LOCAL = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTITEMREMOVEDFROMLOCAL, string.Empty)).Trim();
                if (stp_MES_INSERT_ITEM_REMOVED_FROM_LOCAL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert item remove data from local storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_BAG_INFO_REASON = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETBAGINFOREASON, string.Empty)).Trim();
                if (stp_MES_GET_BAG_INFO_REASON == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get bag info reason storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }


                stp_MES_GET_SYS_CONFIG_TABLE_CHANGE = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETSYSCONFIGTABLECHANGE, string.Empty)).Trim();
                if (stp_MES_GET_SYS_CONFIG_TABLE_CHANGE == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error(stp_MES_GETSYSCONFIGTABLECHANGE + " storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }



                stp_MES_GET_MES_EVENT = (XMLConfig.GetSettingFromInnerText(configSet,
                        stp_MES_GETMESEVENT, string.Empty)).Trim();
                if (stp_MES_GET_MES_EVENT == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get mes event storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_MES_EVENT_FROM_LOCAL = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTMESEVENTFROMLOCAL, string.Empty)).Trim();
                if (stp_MES_INSERT_MES_EVENT_FROM_LOCAL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert mes event data from local storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_REQUIRED_INFO_FROM_SERVER = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETREQUIREDINFOFROMSERVER, string.Empty)).Trim();
                if (stp_MES_GET_REQUIRED_INFO_FROM_SERVER == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get required data from server storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_AIRLINES = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTAIRLINES, string.Empty)).Trim();
                if (stp_MES_INSERT_AIRLINES == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert airline data to local database storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_BAG_INFO = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTBAGINFO, string.Empty)).Trim();
                if (stp_MES_INSERT_BAG_INFO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert bag info data to local database  storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_BAG_SORTING = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTBAGSORTING, string.Empty)).Trim();
                if (stp_MES_INSERT_BAG_SORTING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert bag sorting data to local database  storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_CHUTE_MAPPING = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTCHUTEMAPPING, string.Empty)).Trim();
                if (stp_MES_INSERT_CHUTE_MAPPING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert chute mapping data to local database  storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_FALLBACK_MAPPING = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTFALLBACKMAPPING, string.Empty)).Trim();
                if (stp_MES_INSERT_FALLBACK_MAPPING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert fallback mapping data to local database  storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_4DIGITS_FALLBACK_MAPPING = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERT4DIGITSFALLBACKTAGINFO, string.Empty)).Trim();
                if (stp_MES_INSERT_4DIGITS_FALLBACK_MAPPING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert 4 digits fallback mapping data to local database storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_FLIGHT_PLAN_ALLOC = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTFLIGHTPLANALLOC, string.Empty)).Trim();
                if (stp_MES_INSERT_FLIGHT_PLAN_ALLOC == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert flight plan alloc data to local database storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_FUNCTION_ALLOC_GANTT = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTFUNCTIONALLOCGANTT, string.Empty)).Trim();
                if (stp_MES_INSERT_FUNCTION_ALLOC_GANTT == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert function alloc gantt data to local database  storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_FUNCTION_ALLOC_LIST = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTFUNCTIONALLOCLIST, string.Empty)).Trim();
                if (stp_MES_INSERT_FUNCTION_ALLOC_LIST == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert function alloc list data to local database  storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_FUNCTION_TYPES = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTFUNCTIONTYPES, string.Empty)).Trim();
                if (stp_MES_INSERT_FUNCTION_TYPES == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert function types data to local database  storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_SYS_CONFIG = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTSYSCONFIG, string.Empty)).Trim();
                if (stp_MES_INSERT_SYS_CONFIG == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert sys config data to local database storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_BAG_GID = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETBAGGID, string.Empty)).Trim();
                if (stp_MES_GET_BAG_GID == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert sys config data to local database storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_LICENSE_PLATE = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETLICENSEPLATE, string.Empty)).Trim();
                if (stp_MES_GET_LICENSE_PLATE == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert sys config data to local database storeprocedure setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                InhouseTagRange = (XMLConfig.GetSettingFromInnerText(configSet,
                                        IN_HOUSE_TAG_RANGE, string.Empty)).Trim();
                if (InhouseTagRange == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Inhouse tag range config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GENERATE_IN_HOUSE_BSM = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GENERATEINHOUSEBSM, string.Empty)).Trim();
                if (stp_MES_GENERATE_IN_HOUSE_BSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Generate inhouse tag storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_INHOUSE_BSM = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETINHOUSEBSM, string.Empty)).Trim();
                if (stp_MES_GET_INHOUSE_BSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get inhouse bsm storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_UPDATE_ITEM_INHOUSE_BSM = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_UPDATEITEMINHOUSEBSM, string.Empty)).Trim();
                if (stp_MES_UPDATE_ITEM_INHOUSE_BSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Update inhouse bsm storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_IATA_TAG_LIST = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETIATATAGLIST, string.Empty)).Trim();
                if (stp_MES_GET_IATA_TAG_LIST == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get IATA Tag list storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_COMBO_DATA = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MESGETCOMBODATA, string.Empty)).Trim();
                if (stp_MES_GET_COMBO_DATA == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get combo data storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_PROBLEM_LOCATION = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETPROBLEMLOCATION, string.Empty)).Trim();
                if (stp_MES_GET_PROBLEM_LOCATION == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get problem bag location storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_RUSH_LOCATION = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETRUSHLOCATION, string.Empty)).Trim();
                if (stp_MES_GET_RUSH_LOCATION == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get rush location storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_INHOUSE_BSM_FROM_LOCAL = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTINHOUSEBSMFROMLOCAL, string.Empty)).Trim();
                if (stp_MES_INSERT_INHOUSE_BSM_FROM_LOCAL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert inhouse BSM storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_FLIGHT_PLAN_SORTING = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTFLIGHTPLANSORTING, string.Empty)).Trim();
                if (stp_MES_INSERT_FLIGHT_PLAN_SORTING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert flight plan sorting storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_REASON = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETREASON, string.Empty)).Trim();
                if (stp_MES_GET_REASON == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get reason storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_REMOVE_INHOUSE_BSM = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_REMOVEINHOUSEBSM, string.Empty)).Trim();
                if (stp_MES_REMOVE_INHOUSE_BSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Remove in-house bsm storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }


                stp_MES_GET_CHUTE_BY_DESTINATION = (XMLConfig.GetSettingFromInnerText(configSet,stp_MES_GETCHUTEBYDESTINATION
                        , string.Empty)).Trim();
                if (stp_MES_GET_CHUTE_BY_DESTINATION == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get chute by destination storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                DefaultDateFormat = (XMLConfig.GetSettingFromInnerText(configSet,
                                        DEFAULT_DATE_FORMAT, string.Empty)).Trim();
                if (DefaultDateFormat == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Default date format config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                DefaultTimeFormat = (XMLConfig.GetSettingFromInnerText(configSet,
                                        DEFAULT_TIME_FORMAT, string.Empty)).Trim();
                if (DefaultTimeFormat == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Default time format config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                DefaultDateTimeFormat = (XMLConfig.GetSettingFromInnerText(configSet,
                                        DEFAULT_DATE_TIME_FORMAT, string.Empty)).Trim();
                if (DefaultDateTimeFormat == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Default date and time format config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                CommandTimeOut = (XMLConfig.GetSettingFromInnerText(configSet,
                                        COMMAND_TIME_OUT, string.Empty)).Trim();
                if (CommandTimeOut == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Command Time Out config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                DownloadDataToLocal = (XMLConfig.GetSettingFromInnerText(
                           configSet, DOWNLOAD_DATA_TO_LOCAL, string.Empty)).Trim();
                if (DownloadDataToLocal == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DOWNLOAD_DATA_TO_LOCAL + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_AIRLINES = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETAIRLINES, string.Empty)).Trim();
                if (stp_MES_GET_AIRLINES == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get airlines storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_FLIGHT = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETFLIGHT, string.Empty)).Trim();
                if (stp_MES_GET_FLIGHT == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get flights storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_DESTINATION = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETDESTINATION, string.Empty)).Trim();
                if (stp_MES_GET_DESTINATION == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get destination storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_UPDATE_BAG_INFO = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_UPDATEBAGINFO, string.Empty)).Trim();
                if (stp_MES_UPDATE_BAG_INFO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Update bag info storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_UPDATE_BAG_INFO_FOR_ITEM_REMOVE = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_UPDATEBAGINFOFORITEMREMOVE, string.Empty)).Trim();
                if (stp_MES_UPDATE_BAG_INFO_FOR_ITEM_REMOVE == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Update bag info for item remove storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_DESTINATIONS = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTDESTINATIONS, string.Empty)).Trim();
                if (stp_MES_INSERT_DESTINATIONS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert destination storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_DESTINATION_CHUTE_MAPPING = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTDESTINATIONCHUTEMAPPING, string.Empty)).Trim();
                if (stp_MES_INSERT_DESTINATION_CHUTE_MAPPING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert destination destination chute mapping storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_DESTINATION_PATH_MAPPING = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTDESTINATIONPATHMAPPING, string.Empty)).Trim();
                if (stp_MES_INSERT_DESTINATION_PATH_MAPPING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert destination destination path mapping storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_SORTATION_REASON = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_INSERTSORTATIONREASON, string.Empty)).Trim();
                if (stp_MES_INSERT_SORTATION_REASON == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Insert sortating reason storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_CLEAR_LOCAL_DATA = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_CLEARLOCALDATA, string.Empty)).Trim();
                if (stp_MES_CLEAR_LOCAL_DATA == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Clear MES local data storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_SPECIFIC_DEST = (XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MES_GETSPECIFICDEST, string.Empty)).Trim();
                if (stp_MES_GET_SPECIFIC_DEST == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Get MES Specific destination storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                STPMinimumHBSSecurityLevelMeetChecking = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_MINIMUM_HBS_SECURITY_LEVEL_MEET_CHECKING, string.Empty)).Trim();
                if (STPMinimumHBSSecurityLevelMeetChecking == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_MINIMUM_HBS_SECURITY_LEVEL_MEET_CHECKING + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                HBSAcceptedID = (XMLConfig.GetSettingFromInnerText(
                           configSet, HBS_ACCEPTED_ID, string.Empty)).Trim();
                if (HBSAcceptedID == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + HBS_ACCEPTED_ID + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                DefaultHBSLevel = XMLConfig.GetSettingFromInnerText(configSet, DEFAULT_HBS_LEVEL, string.Empty).Trim();
                if (DefaultHBSLevel == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DEFAULT_HBS_LEVEL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPCustomsSecurityMeetChecking = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_CUSTOMS_SECURITY_MEET_CHECKING, string.Empty)).Trim();
                if (STPCustomsSecurityMeetChecking == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_CUSTOMS_SECURITY_MEET_CHECKING + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                CustomsAcceptedID = new List<string>();
                string tempCustomsAcceptedID = XMLConfig.GetSettingFromInnerText(configSet, CUSTOMS_ACCEPTED_ID, string.Empty).Trim();
                if (tempCustomsAcceptedID == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + CUSTOMS_ACCEPTED_ID + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }
                else
                {
                    string[] tempArray = tempCustomsAcceptedID.Split(',');

                    foreach (string singleResult in tempArray)
                    {
                        CustomsAcceptedID.Add(singleResult);
                    }
                }

                SortReasonCRB = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_CRB, string.Empty)).Trim();
                if (SortReasonCRB == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_CRB + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationCRB = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_CRB, string.Empty)).Trim();
                if (FuncAllocationCRB == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_CRB + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                EDSCDSChute = new List<string>();

                List<LocationID> tempCustomsChuteLocation = new List<LocationID>();

                XmlNode customsChuteLocationConfigSet;
                customsChuteLocationConfigSet = XMLConfig.GetConfigSetElement(ref configSet, CUSTOMS_CHUTE_LOCATION);
                if (customsChuteLocationConfigSet == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + CUSTOMS_CHUTE_LOCATION + "> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }
                else
                {
                    int size;
                    string tempLocation = string.Empty;
                    LocationID location;

                    size = customsChuteLocationConfigSet.ChildNodes.Count;

                    for (int i = 0; i < size; i++)
                    {
                        location = new LocationID();

                        if (customsChuteLocationConfigSet.ChildNodes[i].Name == CUSTOMS_CHUTE_SUB_LOCATION)
                        {
                            tempLocation = XMLConfig.GetSettingFromAttribute(customsChuteLocationConfigSet.ChildNodes[i], "subsystem", string.Empty).Trim();

                            if (tempLocation == string.Empty)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("<subsystem-" + tempLocation + "> setting value is empty! <" + thisMethod + ">.");

                                return false;
                            }
                            else
                            {
                                location.Subsystem = tempLocation;
                            }

                            if (customsChuteLocationConfigSet.ChildNodes[i].InnerText.Trim() == string.Empty)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("<" + tempLocation + "> setting value is empty! <" + thisMethod + ">.");

                                return false;
                            }
                            else
                            {
                                location.Location = customsChuteLocationConfigSet.ChildNodes[i].InnerText.Trim();
                                EDSCDSChute.Add(location.Location);
                            }

                            tempCustomsChuteLocation.Add(location);
                        }
                    }

                    CustomsChuteLocation = tempCustomsChuteLocation.ToArray();
                }

                STPGetFunctionAllocation = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_GET_FUNC_ALLOCATION, string.Empty)).Trim();
                if (STPGetFunctionAllocation == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_GET_FUNC_ALLOCATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnResource = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_RESOURCE, string.Empty)).Trim();
                if (ColumnResource == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_RESOURCE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnSubsystem = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_SUBSYSTEM, string.Empty)).Trim();
                if (ColumnSubsystem == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_SUBSYSTEM + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPChuteAvailableCheck = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_CHUTE_AVAILABLE_CHECK, string.Empty)).Trim();
                if (STPChuteAvailableCheck == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_CHUTE_AVAILABLE_CHECK + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPChuteAvailableCheckForDestination = (XMLConfig.GetSettingFromInnerText(
                            configSet, stp_MES_CHUTEAVAILABLECHECKBYDESTINATION, string.Empty)).Trim();
                if(STPChuteAvailableCheckForDestination==string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_CHUTEAVAILABLECHECKBYDESTINATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonDTUA = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_DTUA, string.Empty)).Trim();
                if (SortReasonDTUA == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_DTUA + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }


                TTSSorter01 = XMLConfig.GetSettingFromInnerText(configSet, TTS01, string.Empty).Trim();
                if (TTSSorter01 == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + TTS01 + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                TTSSorter02 = XMLConfig.GetSettingFromInnerText(configSet, TTS02, string.Empty).Trim();
                if (TTSSorter02 == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + TTS02 + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SchemeTTS2Alloc = (XMLConfig.GetSettingFromInnerText(
                           configSet, SCHEME_TTS2_ALLOC, string.Empty)).Trim();
                if (SchemeTTS2Alloc == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SCHEME_TTS2_ALLOC + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SchemaTypeRoundRobin = (XMLConfig.GetSettingFromInnerText(
                           configSet, SCHEME_TYPE_ROUND_ROBIN, string.Empty)).Trim();
                if (SchemaTypeRoundRobin == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SCHEME_TYPE_ROUND_ROBIN + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SchemeTTS1Alloc = (XMLConfig.GetSettingFromInnerText(
                           configSet, SCHEME_TTS1_ALLOC, string.Empty)).Trim();
                if (SchemeTTS1Alloc == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SCHEME_TTS1_ALLOC + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SchemaTypeWaterfallPriority = (XMLConfig.GetSettingFromInnerText(
                           configSet, SCHEME_TYPE_WATERFALL_PRIORITY, string.Empty)).Trim();
                if (SchemaTypeWaterfallPriority == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SCHEME_TYPE_WATERFALL_PRIORITY + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SchemaTypeWaterfallShortestPath = (XMLConfig.GetSettingFromInnerText(
                           configSet, SCHEME_TYPE_WATERFALL_SHORTEST_PATH, string.Empty)).Trim();
                if (SchemaTypeWaterfallShortestPath == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SCHEME_TYPE_WATERFALL_SHORTEST_PATH + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SchemaFlightAllocation = (XMLConfig.GetSettingFromInnerText(
                           configSet, SCHEME_FLIGHT_ALLOCATION, string.Empty)).Trim();
                if (SchemaFlightAllocation == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SCHEME_FLIGHT_ALLOCATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetSACTTSMESPriority = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_GET_SAC_TTS_MES_PRIORITY, string.Empty)).Trim();
                if (STPGetSACTTSMESPriority == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GET_SAC_TTS_MES_PRIORITY + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnValue = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_VALUE, string.Empty)).Trim();
                if (ColumnValue == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_VALUE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SchemaFunctionAllocation = (XMLConfig.GetSettingFromInnerText(
                           configSet, SCHEME_FUNCTION_ALLOCATION, string.Empty)).Trim();
                if (SchemaFunctionAllocation == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SCHEME_FUNCTION_ALLOCATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                List<LocationID> tempTTS01MESLocation = new List<LocationID>();
                List<LocationID> tempTTS02MESLocation = new List<LocationID>();

                XmlNode mesLocationConfigSet;
                mesLocationConfigSet = XMLConfig.GetConfigSetElement(ref configSet, MES_LOCATION);
                if (mesLocationConfigSet == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + MES_LOCATION + "> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }
                else
                {
                    int size;
                    string tempLocation = string.Empty;
                    LocationID location;

                    size = mesLocationConfigSet.ChildNodes.Count;

                    for (int i = 0; i < size; i++)
                    {
                        location = new LocationID();

                        if (mesLocationConfigSet.ChildNodes[i].Name == MES_SUB_LOCATION)
                        {
                            tempLocation = XMLConfig.GetSettingFromAttribute(mesLocationConfigSet.ChildNodes[i], "subsystem", string.Empty).Trim();

                            if (tempLocation == string.Empty)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("<subsystem-" + tempLocation + "> setting value is empty! <" + thisMethod + ">.");

                                return false;
                            }
                            else
                            {
                                location.Subsystem = tempLocation;
                            }

                            if (mesLocationConfigSet.ChildNodes[i].InnerText.Trim() == string.Empty)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("<" + tempLocation + "> setting value is empty! <" + thisMethod + ">.");

                                return false;
                            }
                            else
                            {
                                location.Location = mesLocationConfigSet.ChildNodes[i].InnerText.Trim();
                            }

                            if (tempLocation == TTS01_SUBSYSTEM)
                            {
                                tempTTS01MESLocation.Add(location);
                            }
                            else
                            {
                                tempTTS02MESLocation.Add(location);
                            }
                        }
                    }

                    TTS01MESLocation = tempTTS01MESLocation.ToArray();
                    TTS02MESLocation = tempTTS02MESLocation.ToArray();
                }

                EBSBagToHBSEnabled = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(
                            configSet, EBS_BAG_TO_HBS_ENABLED, "True").ToUpper());
                FourDigitsSecuritySortEnabled = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(
                            configSet, FOUR_DIGITS_SECURITY_SORT_ENABLED, "True").ToUpper());
                FourDigitsFallbackSortEnabled = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(
                            configSet, FOUR_DIGITS_FALLBACK_SORT_ENABLED, "True").ToUpper());
                InHouseSortEnabled = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(
                            configSet, IN_HOUSE_SORT_ENABLED, "True").ToUpper());


                BCASEnabled = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(
                            configSet, BCAS_ENABLED, "True").ToUpper());

                SortReasonEBSHBS = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_EBSHBS, string.Empty)).Trim();
                if (SortReasonEBSHBS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_EBSHBS + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                List<LocationID> tempEDSChuteLocation = new List<LocationID>();

                XmlNode edsChuteLocationConfigSet;
                edsChuteLocationConfigSet = XMLConfig.GetConfigSetElement(ref configSet, EDS_CHUTE_LOCATION);
                if (edsChuteLocationConfigSet == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + EDS_CHUTE_LOCATION + "> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }
                else
                {
                    int size;
                    string tempLocation = string.Empty;
                    LocationID location;

                    size = edsChuteLocationConfigSet.ChildNodes.Count;

                    for (int i = 0; i < size; i++)
                    {
                        location = new LocationID();

                        if (edsChuteLocationConfigSet.ChildNodes[i].Name == EDS_CHUTE_SUB_LOCATION)
                        {
                            tempLocation = XMLConfig.GetSettingFromAttribute(edsChuteLocationConfigSet.ChildNodes[i], "subsystem", string.Empty).Trim();

                            if (tempLocation == string.Empty)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("<subsystem-" + tempLocation + "> setting value is empty! <" + thisMethod + ">.");

                                return false;
                            }
                            else
                            {
                                location.Subsystem = tempLocation;
                            }

                            if (edsChuteLocationConfigSet.ChildNodes[i].InnerText.Trim() == string.Empty)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("<" + tempLocation + "> setting value is empty! <" + thisMethod + ">.");

                                return false;
                            }
                            else
                            {
                                location.Location = edsChuteLocationConfigSet.ChildNodes[i].InnerText.Trim();
                                EDSCDSChute.Add(location.Location);
                            }

                            tempEDSChuteLocation.Add(location);
                        }
                    }

                    EDSChuteLocation = tempEDSChuteLocation.ToArray();
                }

                SortReasonMSSL = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_MSSL, string.Empty)).Trim();
                if (SortReasonMSSL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_MSSL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                AirportLocationCode = (XMLConfig.GetSettingFromInnerText(
                           configSet, FALLBACK_AIRPORT_LOCTION_CODE, string.Empty)).Trim();
                if (AirportLocationCode == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + FALLBACK_AIRPORT_LOCTION_CODE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                string tempValue = string.Empty;
                string[] tempValues = null;

                tempValue = (XMLConfig.GetSettingFromInnerText(
                           configSet, EMPTY_LICENSE_PLATE, string.Empty)).Trim();

                tempValues = tempValue.Split(',');

                foreach (string data in tempValues)
                {
                    EmptyLicensePlate = EmptyLicensePlate + Convert.ToChar(Convert.ToInt32(data.Trim()));
                }

                if (EmptyLicensePlate == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + EMPTY_LICENSE_PLATE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FallbackSortEnabled = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(
                            configSet, FALLBACK_SORT_ENABLED, "True").ToUpper());
                AirlineSortEnabled = Convert.ToBoolean((XMLConfig.GetSettingFromInnerText(
                           configSet, AIRLINE_SORT_ENABLED, "True")).ToUpper().Trim());
                AirlineRushAllocEnabled = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(
                            configSet, AIRLINE_RUSH_ALLOC_ENABLED, "True").ToUpper());
                EarlyEnabled = Convert.ToBoolean((XMLConfig.GetSettingFromInnerText(
                           configSet, SORT_EARLY_ENABLED, "True")).ToUpper().Trim());
                GlobalRushAllocEnabled = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(
                            configSet, GLOBAL_RUSH_ALLOC_ENABLED, "True").ToUpper());
                EarlyOpenEnabled = Convert.ToBoolean((XMLConfig.GetSettingFromInnerText(
                           configSet, SORT_EARLY_OPEN_ENABLED, "True")).ToUpper().Trim());
                LateEnabled = Convert.ToBoolean((XMLConfig.GetSettingFromInnerText(
                           configSet, SORT_LATE_ENABLED, "True")).ToUpper().Trim());

                //AirportLocationCode = (XMLConfig.GetSettingFromInnerText(
                //           configSet, FALLBACK_AIRPORT_LOCTION_CODE, string.Empty)).Trim();
                //if (AirportLocationCode == string.Empty)
                //{
                //    if (_logger.IsErrorEnabled)
                //        _logger.Error("<" + FALLBACK_AIRPORT_LOCTION_CODE + "> setting can not be empty! <" + thisMethod + ">");

                //    return false;
                //}

                STPGetRoutingTable = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_GET_ROUTING_TABLE, string.Empty)).Trim();
                if (STPGetRoutingTable == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_GET_ROUTING_TABLE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnLocation = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_LOCATION, string.Empty)).Trim();
                if (ColumnLocation == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_LOCATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnCost = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_COST, string.Empty)).Trim();
                if (ColumnCost == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_COST + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonNORD = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_NORD, string.Empty)).Trim();
                if (SortReasonNORD == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_NORD + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonNBSM = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_NBSM, string.Empty)).Trim();
                if (SortReasonNBSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_NBSM + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonMBSM = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_MBSM, string.Empty)).Trim();
                if (SortReasonMBSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_MBSM + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonUNFL = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_UNFL, string.Empty)).Trim();
                if (SortReasonUNFL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_UNFL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonNOAL = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_NOAL, string.Empty)).Trim();
                if (SortReasonNOAL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_NOAL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonALAL = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_ALAL, string.Empty)).Trim();
                if (SortReasonALAL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_ALAL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonIATAFallback = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_IATA_FALLBACK, string.Empty)).Trim();
                if (SortReasonIATAFallback == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_IATA_FALLBACK + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonFourDigitsFallback = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_FOUR_DIGITS_FALLBACK, string.Empty)).Trim();
                if (SortReasonFourDigitsFallback == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_FOUR_DIGITS_FALLBACK + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }


                SortReasonFourDigitsSecurity = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_FOUR_DIGITS_SECURITY, string.Empty)).Trim();
                if (SortReasonFourDigitsFallback == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_FOUR_DIGITS_SECURITY + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonPROB = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_PROB, string.Empty)).Trim();
                if (SortReasonPROB == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_PROB + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonALLO = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_ALLO, string.Empty)).Trim();
                if (SortReasonALLO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_ALLO + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                DownloadDataToLocal = (XMLConfig.GetSettingFromInnerText(
                           configSet, DOWNLOAD_DATA_TO_LOCAL, string.Empty)).Trim();
                if (DownloadDataToLocal == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DOWNLOAD_DATA_TO_LOCAL + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonRUSH = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_RUSH, string.Empty)).Trim();
                if (SortReasonRUSH == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_RUSH + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonLATE = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_LATE, string.Empty)).Trim();
                if (SortReasonLATE == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_LATE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonERLY = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_ERLY, string.Empty)).Trim();
                if (SortReasonERLY == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_ERLY + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonTERL = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_TERL, string.Empty)).Trim();
                if (SortReasonTERL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_TERL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationEDS = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_FUNC_ALLOCATION_EDS, string.Empty)).Trim();
                if (FuncAllocationEDS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_EDS + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                } 

                SortReasonCCFL = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_CCFL, string.Empty)).Trim();
                if (SortReasonCCFL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_CCFL + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationNORD = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_NORD, string.Empty)).Trim();
                if (FuncAllocationNORD == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_NORD + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationMTLP = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_MTLP, string.Empty)).Trim();
                if (FuncAllocationMTLP == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_MTLP + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationNBSM = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_NBSM, string.Empty)).Trim();
                if (FuncAllocationNBSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_NBSM + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationNOAL = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_FUNC_ALLOCATION_NOAL, string.Empty)).Trim();
                if (FuncAllocationNOAL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_NOAL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }


                FuncAllocationMBSM = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_MBSM, string.Empty)).Trim();
                if (FuncAllocationMBSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_MBSM + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationUNFL = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_UNFL, string.Empty)).Trim();
                if (FuncAllocationUNFL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_UNFL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationFEXC = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_FEXC, string.Empty)).Trim();
                if (FuncAllocationFEXC == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_FEXC + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationRUSH = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_RUSH, string.Empty)).Trim();
                if (FuncAllocationRUSH == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_RUSH + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationTERL = (XMLConfig.GetSettingFromInnerText(
                             configSet, DB_FUNC_ALLOCATION_TERL, string.Empty)).Trim();
                if (FuncAllocationTERL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_TERL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationERLY = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_FUNC_ALLOCATION_ERLY, string.Empty)).Trim();
                if (FuncAllocationERLY == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_ERLY + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationLATE = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_LATE, string.Empty)).Trim();
                if (FuncAllocationLATE == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_LATE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationCCFL = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_CCFL, string.Empty)).Trim();
                if (FuncAllocationCCFL == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_CCFL + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationPB01 = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_PB01, string.Empty)).Trim();
                if (FuncAllocationPB01 == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_PB01 + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationPB02 = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_PB02, string.Empty)).Trim();
                if (FuncAllocationPB02 == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_PB02 + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationDP01 = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_DP01, string.Empty)).Trim();
                if (FuncAllocationDP01 == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_DP01 + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                FuncAllocationDP02 = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_FUNC_ALLOCATION_DP02, string.Empty)).Trim();
                if (FuncAllocationDP02 == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_FUNC_ALLOCATION_DP02 + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetIATAFallbackTagDischarged = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_GET_IATA_FALLBACK_DISCHARGE, string.Empty)).Trim();
                if (STPGetIATAFallbackTagDischarged == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_GET_IATA_FALLBACK_DISCHARGE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetFourDigitsFallbackTagDischarge = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_GET_FOUR_DIGITS_FALLBACK_TAG_DISCHARGE, string.Empty)).Trim();
                if (STPGetFourDigitsFallbackTagDischarge == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GET_FOUR_DIGITS_FALLBACK_TAG_DISCHARGE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetFourDigitsSecurityTagDischarge = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_GET_FOUR_DIGITS_SECURITY_TAG_DISCHARGE, string.Empty)).Trim();
                if (STPGetFourDigitsSecurityTagDischarge == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GET_FOUR_DIGITS_SECURITY_TAG_DISCHARGE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnDestination = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_DESTINATION, string.Empty)).Trim();
                if (ColumnDestination == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_DESTINATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetFlightAllocationOfLP = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_GET_FLIGHT_ALLOCATION_OF_LP, string.Empty)).Trim();
                if (STPGetFlightAllocationOfLP == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_GET_FLIGHT_ALLOCATION_OF_LP + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnAirline = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_AIRLINE, string.Empty)).Trim();
                if (ColumnAirline == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_AIRLINE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnFlightNo = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_FLIGHT_NUMBER, string.Empty)).Trim();
                if (ColumnFlightNo == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_FLIGHT_NUMBER + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnSDO = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_SDO, string.Empty)).Trim();
                if (ColumnSDO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_SDO + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnSTO = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_STO, string.Empty)).Trim();
                if (ColumnSTO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_STO + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnMasterAirline = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_MASTER_AIRLINE, string.Empty)).Trim();
                if (ColumnMasterAirline == string.Empty)
                {
                   if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_MASTER_AIRLINE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnMasterFlightNo = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_MASTER_FLIGHT_NUMBER, string.Empty)).Trim();
                if (ColumnMasterFlightNo == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_MASTER_FLIGHT_NUMBER + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                RelatedNameSTD = (XMLConfig.GetSettingFromInnerText(
                           configSet, SORT_RELATED_NAME_STD, string.Empty)).Trim();
                if (RelatedNameSTD == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SORT_RELATED_NAME_STD + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                RelatedNameETD = (XMLConfig.GetSettingFromInnerText(
                           configSet, SORT_RELATED_NAME_ETD, string.Empty)).Trim();
                if (RelatedNameETD == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SORT_RELATED_NAME_ETD + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                RelatedNameITD = (XMLConfig.GetSettingFromInnerText(
                           configSet, SORT_RELATED_NAME_ITD, string.Empty)).Trim();
                if (RelatedNameITD == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SORT_RELATED_NAME_ITD + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                RelatedNameATD = (XMLConfig.GetSettingFromInnerText(
                           configSet, SORT_RELATED_NAME_ATD, string.Empty)).Trim();
                if (RelatedNameATD == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SORT_RELATED_NAME_ATD + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnEDO = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_EDO, string.Empty)).Trim();
                if (ColumnEDO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_EDO + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnETO = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_ETO, string.Empty)).Trim();
                if (ColumnETO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_ETO + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnIDO = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_IDO, string.Empty)).Trim();
                if (ColumnIDO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_IDO + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnITO = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_ITO, string.Empty)).Trim();
                if (ColumnITO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_ITO + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }


                ColumnADO = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_ADO, string.Empty)).Trim();
                if (ColumnADO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_ADO + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnATO = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_ATO, string.Empty)).Trim();
                if (ColumnATO == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_ATO + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnEarlyOpenOffset = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_EARLY_OPEN_OFFSET, string.Empty)).Trim();
                if (ColumnEarlyOpenOffset == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_EARLY_OPEN_OFFSET + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnAllocOpenOffset = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_ALLOC_OPEN_OFFSET, string.Empty)).Trim();
                if (ColumnAllocOpenOffset == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_ALLOC_OPEN_OFFSET + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnAllocOpenRelated = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_ALLOC_OPEN_RELATED, string.Empty)).Trim();
                if (ColumnAllocOpenRelated == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_ALLOC_OPEN_RELATED + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnAllocCloseOffset = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_ALLOC_CLOSE_OFFSET, string.Empty)).Trim();
                if (ColumnAllocCloseOffset == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_ALLOC_CLOSE_OFFSET + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnAllocCloseRelated = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_ALLOC_CLOSE_RELATED, string.Empty)).Trim();
                if (ColumnAllocCloseRelated == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_ALLOC_CLOSE_RELATED + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnRushDuration = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_RUSH_DURATION, string.Empty)).Trim();
                if (ColumnRushDuration == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_RUSH_DURATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnTravelClass = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_TRAVEL_CLASS, string.Empty)).Trim();
                if (ColumnTravelClass == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_TRAVEL_CLASS + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnIsManualClosed = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_IS_MANUAL_CLOSED, string.Empty)).Trim();
                if (ColumnIsManualClosed == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_IS_MANUAL_CLOSED + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnIsClosed = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_IS_CLOSED, string.Empty)).Trim();
                if (ColumnIsClosed == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_IS_CLOSED + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnBagType = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_BAG_TYPE, string.Empty)).Trim();
                if (ColumnBagType == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_BAG_TYPE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnPassengerDestination = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_PASSENGER_DESTINATION, string.Empty)).Trim();
                if (ColumnPassengerDestination == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_PASSENGER_DESTINATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnTransfer = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_TRANSFER, string.Empty)).Trim();
                if (ColumnTransfer == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_TRANSFER + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetFlightAllocOfLPFromPseudoBSM = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_GET_FLIGHT_ALLOC_OF_LP_FROM_PSEUDO_BSM, string.Empty)).Trim();
                if (STPGetFlightAllocOfLPFromPseudoBSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GET_FLIGHT_ALLOC_OF_LP_FROM_PSEUDO_BSM + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetAirlineAllocation = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_GET_AIRLINE_ALLOCATION, string.Empty)).Trim();
                if (STPGetAirlineAllocation == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_GET_AIRLINE_ALLOCATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetBagInformation = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_GET_BAG_INFORMATION, string.Empty)).Trim();
                if (STPGetBagInformation == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GET_BAG_INFORMATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                Wildcard = XMLConfig.GetSettingFromInnerText(configSet, WILDCARD, string.Empty).Trim();
                if (Wildcard == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + WILDCARD + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetAirlineRush = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_GET_AIRLINE_RUSH, string.Empty)).Trim();
                if (STPGetAirlineRush == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GET_AIRLINE_RUSH + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                SchemaAirlineAllocation = (XMLConfig.GetSettingFromInnerText(
                            configSet, SCHEME_AIRLINE_ALLOCATION, string.Empty)).Trim();
                if (SchemaAirlineAllocation == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SCHEME_AIRLINE_ALLOCATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FourDigitsSecurityIdentification = XMLConfig.GetSettingFromInnerText(configSet, FOUR_DIGITS_SECURITY_IDENTIFICATION, string.Empty).Trim();
                if (FourDigitsSecurityIdentification == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + FOUR_DIGITS_SECURITY_IDENTIFICATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                FourDigitsFallbackIdentification = XMLConfig.GetSettingFromInnerText(configSet, FOUR_DIGITS_FALLBACK_IDENTIFICATION, string.Empty).Trim();
                if (FourDigitsFallbackIdentification == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + FOUR_DIGITS_FALLBACK_IDENTIFICATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                RecirculationOverDump = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(configSet, RECIRCULATION_OVER_DUMP, "FALSE").ToUpper().Trim());



                IATAInterlineIdentifier = XMLConfig.GetSettingFromInnerText(configSet, IATA_INTERLINE_IDENTIFIER, string.Empty).Trim();
                if (IATAInterlineIdentifier == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + IATA_INTERLINE_IDENTIFIER + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                IATAFallbackIdentifier = XMLConfig.GetSettingFromInnerText(configSet, IATA_FALLBACK_IDENTIFIER, string.Empty).Trim();
                if (IATAFallbackIdentifier == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + IATA_FALLBACK_IDENTIFIER + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                InHouseIdentifier = XMLConfig.GetSettingFromInnerText(configSet, IN_HOUSE_IDENTIFIER, string.Empty).Trim();
                if (InHouseIdentifier == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + IN_HOUSE_IDENTIFIER + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                InHouseAirlineCode = XMLConfig.GetSettingFromInnerText(configSet, IN_HOUSE_AIRLINE_CODE, string.Empty).Trim();
                if (InHouseAirlineCode == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + IN_HOUSE_AIRLINE_CODE + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }






                tempValue = string.Empty;
                tempValues = null;

                tempValue = (XMLConfig.GetSettingFromInnerText(
                       configSet, DUMMY_MULTIPLE_LICENSE_PLATE, string.Empty)).Trim();
                tempValues = tempValue.Split(',');

                foreach (string data in tempValues)
                {
                    DummyMultipleLicensePlate = DummyMultipleLicensePlate + Convert.ToChar(Convert.ToInt32(data.Trim()));
                }

                if (DummyMultipleLicensePlate == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DUMMY_MULTIPLE_LICENSE_PLATE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetSecurityTagLevel = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_GET_SECURITY_TAG_LEVEL, string.Empty)).Trim();
                if (STPGetSecurityTagLevel == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GET_SECURITY_TAG_LEVEL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetMinimumSecurityLevel = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_GET_MINIMUM_SECURITY_LEVEL, string.Empty)).Trim();
                if (STPGetMinimumSecurityLevel == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GET_MINIMUM_SECURITY_LEVEL + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnSysKey = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_SYSKEY, string.Empty)).Trim();
                if (ColumnSysKey == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_SYSKEY + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                ColumnSysValue = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_COLUMN_SYSVALUE, string.Empty)).Trim();
                if (ColumnSysValue == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_COLUMN_SYSVALUE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetSACPublicParams = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_GET_SAC_PUBLIC_PARAMS, string.Empty)).Trim();
                if (STPGetSACPublicParams == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_GET_SAC_PUBLIC_PARAMS + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                MESDefaultTTS = (XMLConfig.GetSettingFromInnerText(
                            configSet, MES_DEFAULT_TTS, string.Empty)).Trim();
                if (MESDefaultTTS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + MES_DEFAULT_TTS + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                MESCurrentLocation = (XMLConfig.GetSettingFromInnerText(
                            configSet, MES_CURRENT_LOCATION, string.Empty)).Trim();
                if (MESCurrentLocation == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + MES_CURRENT_LOCATION + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_ALL_SETTING = (XMLConfig.GetSettingFromInnerText(
                            configSet, stp_MES_GETALLSETTING, string.Empty)).Trim();
                if (stp_MES_GET_ALL_SETTING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_GET_ALL_SETTING + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_CHECK_BAG_REOCCURENCE = (XMLConfig.GetSettingFromInnerText(
                            configSet, stp_MES_CHECKBAGREOCCURENCE, string.Empty)).Trim();
                if (stp_MES_CHECK_BAG_REOCCURENCE == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_CHECK_BAG_REOCCURENCE + "> setting can not be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetCancellationOfFlight = (XMLConfig.GetSettingFromInnerText(
                            configSet, DB_STP_SAC_GETCANCELLATIONOFFLIGHT, string.Empty)).Trim();
                if (STPGetCancellationOfFlight == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GETCANCELLATIONOFFLIGHT + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetIRDValues = (XMLConfig.GetSettingFromInnerText(
                    configSet, DB_STP_SAC_GETIRDVALUES, string.Empty)).Trim();
                if (STPGetIRDValues == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GETIRDVALUES + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                STPCheckMUAvailability = (XMLConfig.GetSettingFromInnerText(
                    configSet, DB_STP_SAC_CHECKMUAVAILABILITY, string.Empty)).Trim();
                if (STPCheckMUAvailability == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_CHECKMUAVAILABILITY + "> setting cannot be empty! <" + thisMethod + ">");
                     
                    return false;
                }

                STPSACGetAllocProp = (XMLConfig.GetSettingFromInnerText(
                    configSet, DB_STP_SAC_GETALLOCPROP, string.Empty)).Trim();
                if (STPSACGetAllocProp == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GETALLOCPROP + "> setting cannot be empty! <" + thisMethod + ">");
                }

                FlightCancellationValue = XMLConfig.GetSettingFromInnerText(configSet, FLIGHT_CANCELLATION_VALUE, string.Empty).Trim();
                if (FlightCancellationValue == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + FLIGHT_CANCELLATION_VALUE + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                InHouseTagConstant = XMLConfig.GetSettingFromInnerText(configSet, INHOUSE_TAG_CONSTANT, string.Empty).Trim();
                if (InHouseTagConstant == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + INHOUSE_TAG_CONSTANT + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                IATATagConstant = XMLConfig.GetSettingFromInnerText(configSet, IATA_TAG_CONSTANT, string.Empty).Trim();
                if (IATATagConstant == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + IATA_TAG_CONSTANT + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GENERATE_FALLBACKTAG = XMLConfig.GetSettingFromInnerText(configSet, stp_MES_GENERATEFALLBACKTAG, string.Empty).Trim();
                if (stp_MES_GENERATE_FALLBACKTAG == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_GENERATEFALLBACKTAG + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_HBS_RESULTS = XMLConfig.GetSettingFromInnerText(configSet, stp_MES_GETHBSRESULTS, string.Empty).Trim();
                if (stp_MES_GET_HBS_RESULTS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_GETHBSRESULTS + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_GET_HBS_RESULTS_FOR_BUTTON_ENTER = XMLConfig.GetSettingFromInnerText(configSet, stp_MES_GETHBSRESULTSFORBUTTONENTER, string.Empty).Trim();
                if (stp_MES_GET_HBS_RESULTS_FOR_BUTTON_ENTER == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_GETHBSRESULTSFORBUTTONENTER + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_UPDATE_CHANGED_CONNECTION_MONITORING = XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_UPDATECHANGEDCONNECTIONMONITORING, string.Empty);
                if (stp_UPDATE_CHANGED_CONNECTION_MONITORING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Update application live connection status storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_UPDATE_MDS_ALARMS_FOR_PROBLEM_BAG = XMLConfig.GetSettingFromInnerText(configSet,
                                        stp_MESUPDATEMDSALARMSFORPROBLEMBAG, string.Empty);
                if (stp_MES_UPDATE_MDS_ALARMS_FOR_PROBLEM_BAG == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Update mds alarms for problem bag storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_UPDATE_MDS_ALARMS_FOR_USER_LOGIN_LOGOUT = XMLConfig.GetSettingFromInnerText(configSet,
                                       stp_MESUPDATEMDSALARMSFORUSERLOGINLOGOUT, string.Empty);
                if (stp_MES_UPDATE_MDS_ALARMS_FOR_USER_LOGIN_LOGOUT == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Update mds alarms for user login logout storeprocedure config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                ApplicationLiveStatus = XMLConfig.GetSettingFromInnerText(configSet,
                                        APP_LIVE_STATUS, string.Empty);
                if (ApplicationLiveStatus == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Application live status config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                AppLiveStatusUpdateKey = XMLConfig.GetSettingFromInnerText(configSet,
                                        APP_LIVE_STATUS_UPDATE_KEY, string.Empty);
                if (AppLiveStatusUpdateKey == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Application live status config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                AppLogOnOffUpdateKey = XMLConfig.GetSettingFromInnerText(configSet,
                                        APP_LOG_ON_OFF_STATUS_UPDATE_KEY, string.Empty);
                if (AppLogOnOffUpdateKey == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Application log on or off status update key config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                AppLiveUpdateInterval = Convert.ToInt32(XMLConfig.GetSettingFromInnerText(configSet,
                                        APP_LIVE_STATUS_UPDATE_INTERVAL, "0"));
                if (AppLiveUpdateInterval == 0)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Application live status update interval config data setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }


                DefaultCurrentHBSLevel = XMLConfig.GetSettingFromInnerText(configSet, DEFAULT_CURRENT_HBS_LEVEL, string.Empty).Trim();
                if (DefaultCurrentHBSLevel == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DEFAULT_CURRENT_HBS_LEVEL + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                HBSLevel1ID = (XMLConfig.GetSettingFromInnerText(
                           configSet, HBS_LEVEL1_ID, string.Empty)).Trim();
                if (HBSLevel1ID == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + HBS_LEVEL1_ID + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                HBSLevel2ID = (XMLConfig.GetSettingFromInnerText(
                           configSet, HBS_LEVEL2_ID, string.Empty)).Trim();
                if (HBSLevel2ID == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + HBS_LEVEL2_ID + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                HBSLevel3ID = (XMLConfig.GetSettingFromInnerText(
                           configSet, HBS_LEVEL3_ID, string.Empty)).Trim();
                if (HBSLevel3ID == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + HBS_LEVEL3_ID + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                HBSLevel4ID = (XMLConfig.GetSettingFromInnerText(
                           configSet, HBS_LEVEL4_ID, string.Empty)).Trim();
                if (HBSLevel4ID == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + HBS_LEVEL4_ID + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                HBSLevel5ID = (XMLConfig.GetSettingFromInnerText(
                           configSet, HBS_LEVEL5_ID, string.Empty)).Trim();
                if (HBSLevel5ID == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + HBS_LEVEL5_ID + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                XmlNode hbsLevelLocationConfigSet;
                hbsLevelLocationConfigSet = XMLConfig.GetConfigSetElement(ref configSet, HBS_LOCATION);
                if (hbsLevelLocationConfigSet == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + HBS_LOCATION + "> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }
                else
                {
                    int size;
                    string tempLocation = string.Empty;

                    size = hbsLevelLocationConfigSet.ChildNodes.Count;

                    for (int i = 0; i < size; i++)
                    {
                        if (hbsLevelLocationConfigSet.ChildNodes[i].Name == HBS_LEVEL_LOCATION)
                        {
                            tempLocation = XMLConfig.GetSettingFromAttribute(hbsLevelLocationConfigSet.ChildNodes[i], "level", string.Empty).Trim();

                            if (tempLocation == string.Empty)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("<level-" + tempLocation + "> setting value is empty! <" + thisMethod + ">.");

                                return false;
                            }
                            else
                            {
                                if (hbsLevelLocationConfigSet.ChildNodes[i].InnerText.Trim() == string.Empty)
                                {
                                    if (_logger.IsErrorEnabled)
                                        _logger.Error("<" + tempLocation + "> setting value is empty! <" + thisMethod + ">.");

                                    return false;
                                }
                                else
                                {
                                    if (tempLocation == HBSLevel1ID)
                                    {
                                        HBSLevel1Location = hbsLevelLocationConfigSet.ChildNodes[i].InnerText.Trim();
                                    }
                                    else if (tempLocation == HBSLevel2ID)
                                    {
                                        HBSLevel2Location = hbsLevelLocationConfigSet.ChildNodes[i].InnerText.Trim();
                                    }
                                    else if (tempLocation == HBSLevel3ID)
                                    {
                                        HBSLevel3Location = hbsLevelLocationConfigSet.ChildNodes[i].InnerText.Trim();
                                    }
                                    else if (tempLocation == HBSLevel4ID)
                                    {
                                        HBSLevel4Location = hbsLevelLocationConfigSet.ChildNodes[i].InnerText.Trim();
                                    }
                                    else if (tempLocation == HBSLevel5ID)
                                    {
                                        HBSLevel5Location = hbsLevelLocationConfigSet.ChildNodes[i].InnerText.Trim();
                                    }
                                }
                            }
                        }
                    }
                }


                // Number of minutes that last sortation record can be kept in the internal RoundRobin buffer.
                // Minimum 30 minutes, Maximum 300 minutes
                //LifeTimeRRBuffer = Convert.ToInt32(XMLConfig.GetSettingFromInnerText(
                //           configSet, ROUNDROBIN_BUFFER_LIFETIME, "300"));

                //if (LifeTimeRRBuffer < 30)
                //{
                //    LifeTimeRRBuffer = 30;
                //}
                //else if (LifeTimeRRBuffer > 300)
                //{
                //    LifeTimeRRBuffer = 300;
                //}

                stp_MES_GET_AIRLINE_CODE = (XMLConfig.GetSettingFromInnerText(
                          configSet, stp_MES_GETAIRLINECODE, string.Empty)).Trim();
                if (stp_MES_GET_AIRLINE_CODE == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_GET_AIRLINE_CODE + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonFEXC = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_FEXC, string.Empty)).Trim();
                if (SortReasonFEXC == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_FEXC + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonSTRY = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_STRY, string.Empty)).Trim();
                if (SortReasonFEXC == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_STRY + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonMRDD = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_MRDD, string.Empty)).Trim();
                if (SortReasonMRDD == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_MRDD + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonDELF = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_DELF, string.Empty)).Trim();
                if (SortReasonDELF == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_DELF + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SortReasonOFBK = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_SORTATION_REASON_OFBK, string.Empty)).Trim();
                if (SortReasonOFBK == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_SORTATION_REASON_OFBK + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SecurityCategoryCode = (XMLConfig.GetSettingFromInnerText(
                           configSet, SECURITY_CATEGORY_CODE, string.Empty)).Trim();
                if (SecurityCategoryCode == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SECURITY_CATEGORY_CODE + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SecurityContainerName = (XMLConfig.GetSettingFromInnerText(
                           configSet, SECURITY_CONTAINER_NAME, string.Empty)).Trim();
                if (SecurityContainerName == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SECURITY_CONTAINER_NAME + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SecurityDomainExtension = (XMLConfig.GetSettingFromInnerText(
                           configSet, SECURITY_DOMAIN_EXTENSION, string.Empty)).Trim();
                if (SecurityDomainExtension == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SECURITY_DOMAIN_EXTENSION + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SecurityDomainName = (XMLConfig.GetSettingFromInnerText(
                           configSet, SECURITY_DOMAIN_NAME, string.Empty)).Trim();
                if (SecurityDomainName == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SECURITY_DOMAIN_NAME + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SecurityOrgName = (XMLConfig.GetSettingFromInnerText(
                           configSet, SECURITY_ORGANIZATION_NAME, string.Empty)).Trim();
                if (SecurityOrgName == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SECURITY_ORGANIZATION_NAME + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                SecurityIPAddress = (XMLConfig.GetSettingFromInnerText(
                           configSet, SECURITY_IP_ADDRESSES, string.Empty)).Trim();
                if (SecurityIPAddress == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SECURITY_IP_ADDRESSES + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_CHECK_NO_BSM = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_CHECKNOBSM, string.Empty)).Trim();
                if (stp_MES_CHECK_NO_BSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_CHECKNOBSM + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_ALERT_ENCODING_DURATION = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_ALERTENCODINGDURATION, string.Empty)).Trim();
                if (stp_MES_ALERT_ENCODING_DURATION == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_ALERTENCODINGDURATION + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                NoBSMReoccuranceAlarmType = (XMLConfig.GetSettingFromInnerText(
                           configSet, NO_BSM_REOCCURANCE_ALARM_TYPE, string.Empty)).Trim();
                if (NoBSMReoccuranceAlarmType == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + NO_BSM_REOCCURANCE_ALARM_TYPE + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                EncodeDurationAlarmType = (XMLConfig.GetSettingFromInnerText(
                           configSet, ENCODE_DURATION_ALARM_TYPE, string.Empty)).Trim();
                if (EncodeDurationAlarmType == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + ENCODE_DURATION_ALARM_TYPE + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                EquipmentID = (XMLConfig.GetSettingFromInnerText(
                           configSet, EQUIPMENT_ID, string.Empty)).Trim();
                if (EquipmentID == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + EQUIPMENT_ID + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                NoBSMReoccuranceAlarmType = (XMLConfig.GetSettingFromInnerText(
                           configSet, NO_BSM_REOCCURANCE_ALARM_TYPE, string.Empty)).Trim();
                if (NoBSMReoccuranceAlarmType == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + NO_BSM_REOCCURANCE_ALARM_TYPE + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                EncodeDurationAlarmType = (XMLConfig.GetSettingFromInnerText(
                           configSet, ENCODE_DURATION_ALARM_TYPE, string.Empty)).Trim();
                if (EncodeDurationAlarmType == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + ENCODE_DURATION_ALARM_TYPE + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_AIRPORTS = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_INSERTAIRPORTS, string.Empty)).Trim();
                if (stp_MES_INSERT_AIRPORTS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_INSERTAIRPORTS + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                STPGetCustomsRequired = (XMLConfig.GetSettingFromInnerText(
                           configSet, DB_STP_SAC_GETCUSTOMSREQUIRED, string.Empty)).Trim();
                if (STPGetCustomsRequired == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + DB_STP_SAC_GETCUSTOMSREQUIRED + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_SECURITY_GROUP_TASK_MAPPING = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_INSERTSECURITYGROUPTASKMAPPING, string.Empty)).Trim();
                if (stp_MES_INSERT_SECURITY_GROUP_TASK_MAPPING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_INSERTSECURITYGROUPTASKMAPPING + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_SECURITY_GROUP_TASKS = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_INSERTSECURITYGROUPTASKS, string.Empty)).Trim();
                if (stp_MES_INSERT_SECURITY_GROUP_TASKS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_INSERTSECURITYGROUPTASKS + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_SECURITY_GROUPS = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_INSERTSECURITYGROUPS, string.Empty)).Trim();
                if (stp_MES_INSERT_SECURITY_GROUPS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_INSERTSECURITYGROUPS + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_SECURITY_TASKS = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_INSERTSECURITYTASKS, string.Empty)).Trim();
                if (stp_MES_INSERT_SECURITY_TASKS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_INSERTSECURITYTASKS + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_SECURITY_USER_RIGHTS = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_INSERTSECURITYUSERRIGHTS, string.Empty)).Trim();
                if (stp_MES_INSERT_SECURITY_USER_RIGHTS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_INSERTSECURITYUSERRIGHTS + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_SECURITY_USERS = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_INSERTSECURITYUSERS, string.Empty)).Trim();
                if (stp_MES_INSERT_SECURITY_USERS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_INSERTSECURITYUSERS + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_SECURITY_CATEGORIES= (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_INSERTSECURITYCATEGORIES, string.Empty)).Trim();
                if (stp_MES_INSERT_SECURITY_CATEGORIES == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_INSERTSECURITYCATEGORIES + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_LOCATIONS = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_INSERTLOCATIONS, string.Empty)).Trim();
                if (stp_MES_INSERT_LOCATIONS == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_INSERT_LOCATIONS + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                stp_MES_INSERT_MAKEUP_FLIGHT_TYPE_MAPPING = (XMLConfig.GetSettingFromInnerText(
                           configSet, stp_MES_INSERTMAKEUPFLIGHTTYPEMAPPING, string.Empty)).Trim();
                if (stp_MES_INSERT_MAKEUP_FLIGHT_TYPE_MAPPING == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + stp_MES_INSERT_MAKEUP_FLIGHT_TYPE_MAPPING + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                string temp = XMLConfig.GetSettingFromInnerText(configSet, IS_NEED_CHECK_HBSL1, "False").Trim();
                if (temp == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + IS_NEED_CHECK_HBSL1 + "> setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }
                else
                {
                    IsNeedCheckHBSL1 = Convert.ToBoolean(temp);
                }

                List<LocationID> tempTTS01OverflowLocation = new List<LocationID>();
                List<LocationID> tempTTS02OverflowLocation = new List<LocationID>();

                XmlNode overflowLocationConfigSet;
                overflowLocationConfigSet = XMLConfig.GetConfigSetElement(ref configSet, RECIRCULATION_STARTED_POINT);
                if (overflowLocationConfigSet == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + RECIRCULATION_STARTED_POINT + "> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }
                else
                {
                    int size;
                    string tempLocation = string.Empty;
                    LocationID location;

                    size = overflowLocationConfigSet.ChildNodes.Count;

                    for (int i = 0; i < size; i++)
                    {
                        location = new LocationID();

                        if (overflowLocationConfigSet.ChildNodes[i].Name == RECIRCULATION_STARTED_POINT_LOCATION)
                        {
                            tempLocation = XMLConfig.GetSettingFromAttribute(overflowLocationConfigSet.ChildNodes[i], "subsystem", string.Empty).Trim();

                            if (tempLocation == string.Empty)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("<subsystem-" + tempLocation + "> setting value is empty! <" + thisMethod + ">.");

                                return false;
                            }
                            else
                            {
                                location.Subsystem = tempLocation;
                            }

                            if (overflowLocationConfigSet.ChildNodes[i].InnerText.Trim() == string.Empty)
                            {
                                if (_logger.IsErrorEnabled)
                                    _logger.Error("<" + tempLocation + "> setting value is empty! <" + thisMethod + ">.");

                                return false;
                            }
                            else
                            {
                                location.Location = overflowLocationConfigSet.ChildNodes[i].InnerText.Trim();
                            }

                            if (tempLocation == TTS01_SUBSYSTEM)
                            {
                                tempTTS01OverflowLocation.Add(location);
                            }
                            else
                            {
                                tempTTS02OverflowLocation.Add(location);
                            }
                        }
                    }

                    TTS01OverflowStartLocation = tempTTS01OverflowLocation.ToArray();
                    TTS02OverflowStartLocation = tempTTS02OverflowLocation.ToArray();
                }

                XmlNode securityRelatedConfigSet = XMLConfig.GetConfigSetElement(ref configSet, SECURITY_RELATED_CONFIG);
                string sKey = string.Empty;
                if (securityRelatedConfigSet == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + SECURITY_RELATED_CONFIG + "> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }
                else
                {
                    for (int i = 0; i < securityRelatedConfigSet.ChildNodes.Count; i++)
                    {
                        sKey = XMLConfig.GetSettingFromAttribute(securityRelatedConfigSet.ChildNodes[i], "configName", string.Empty).Trim();
                        switch (sKey)
                        {
                            case "TaskCodeFieldName":
                                MES_Config.TaskCodeFieldName = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EnableFieldName":
                                MES_Config.EnableFieldName = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EnableDataValue":
                                MES_Config.EnableDataValue = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EncodeByTagTaskCode":
                                MES_Config.EncodeByTagTaskCode = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EncodeByFlightTaskCode":
                                MES_Config.EncodeByFlightTaskCode = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EncodeByDestinationTaskCode":
                                MES_Config.EncodeByDestinationTaskCode = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EncodeByProblemTaskCode":
                                MES_Config.EncodeByProblemTaskCode = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EncodeByRushTaskCode":
                                MES_Config.EncodeByRushTaskCode = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "OperationModeTaskCode":
                                MES_Config.OperationModeTaskCode = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "GenerateTagTaskCode":
                                MES_Config.GenerateTagTaskCode = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "InsertBagTaskCode":
                                MES_Config.InsertBagTaskCode = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "MsgDurationSysKey":
                                MES_Config.MsgDurationSysKey = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "ReOccurenceSysKey":
                                MES_Config.ReOccurenceSysKey = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "NoBSMReoccurence":
                                MES_Config.NoBSMReoccurenceSysKey = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EncodeDurationSysKey":
                                MES_Config.EncodeDurationSysKey = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EnableHBS2BSysKey":
                                MES_Config.EnableHBS2BSysKey = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EnableAirRushAlloc":
                                MES_Config.EnableAirRushAlloc = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                            case "EnableRushFuncAlloc":
                                MES_Config.EnableRushFuncAlloc = securityRelatedConfigSet.ChildNodes[i].InnerText.Trim();
                                break;
                        }
                    }
                }

                UIConnected = false;
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
        /// Get Public Parameter
        /// </summary>
        /// <param name="paramName"></param>
        /// <returns></returns>
        public string GetPublicParameter(string paramName)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            string value = string.Empty;

            try
            {
                if (paramName == string.Empty)
                {
                    return string.Empty;
                }
                else
                {
                    value = ParametersHash[paramName].ToString();
                }

                return value;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get public Parameters is failure! <" + thisMethod + ">", ex);

                return string.Empty;
            }

        }

        /// <summary>
        /// Set available function list for current login user defined in DA Security.
        /// If the user is emergency user, get the setting from config file.
        /// </summary>
        public void SetAvailableFunctionList(bool bADUser, bool bEmergencyUser, string sLoginUser)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            try
            {
                string sKey;
                if (bADUser == true)
                {
                    string sErrorMsg;
                    string sSecurityDBConnStr;
                    if (this.MainDBAlive == true)
                    {
                        sSecurityDBConnStr = this.DBConnectionString;
                    }
                    else
                    {
                        sSecurityDBConnStr = this.LocalDBConnectionString;
                    }
                    Util.categoryCode = this.SecurityCategoryCode;
                    if (_logger.IsInfoEnabled)
                        _logger.Info("Finished Util.categoryCode...");
                    Util.securityCategoryCodes = this.SecurityCategoryCode;
                    if (_logger.IsInfoEnabled)
                        _logger.Info("Finished Util.securityCategoryCodes...");
                    SecurityManager securityManager = new SecurityManager(AD_DB_Actions.DBAction, sSecurityDBConnStr);
                    if (_logger.IsInfoEnabled)
                        _logger.Info("Finished loading task list for domain user...");
                    DataTable dtTaskList = securityManager.GetTaskListByUser(sLoginUser, out sErrorMsg);
                    if (_logger.IsInfoEnabled)
                        _logger.Info("Total Task List: " + dtTaskList.Rows.Count.ToString() + 
                            " Login User: " + sLoginUser + " Error Message: " + sErrorMsg);
                    for (int i = 0; i < dtTaskList.Rows.Count; i++)
                    {
                        if (_logger.IsInfoEnabled)
                            _logger.Info("Security Task Code ID: " + dtTaskList.Rows[i][MES_Config.TaskCodeFieldName].ToString() +
                                " Active Flag: " + dtTaskList.Rows[i][MES_Config.EnableFieldName].ToString());
                        if (dtTaskList.Rows[i][MES_Config.TaskCodeFieldName].ToString() == MES_Config.EncodeByTagTaskCode)
                        {
                            if (dtTaskList.Rows[i][MES_Config.EnableFieldName].ToString() == MES_Config.EnableDataValue)
                                MES_FunctionList.EncodeByTag = true;
                        }
                        else if (dtTaskList.Rows[i][MES_Config.TaskCodeFieldName].ToString() == MES_Config.EncodeByFlightTaskCode)
                        {
                            if (dtTaskList.Rows[i][MES_Config.EnableFieldName].ToString() == MES_Config.EnableDataValue)
                                MES_FunctionList.EncodeByFlight = true;
                        }
                        else if (dtTaskList.Rows[i][MES_Config.TaskCodeFieldName].ToString() == MES_Config.EncodeByDestinationTaskCode)
                        {
                            if (dtTaskList.Rows[i][MES_Config.EnableFieldName].ToString() == MES_Config.EnableDataValue)
                                MES_FunctionList.EncodeByDestination = true;
                        }
                        else if (dtTaskList.Rows[i][MES_Config.TaskCodeFieldName].ToString() == MES_Config.EncodeByProblemTaskCode)
                        {
                            if (dtTaskList.Rows[i][MES_Config.EnableFieldName].ToString() == MES_Config.EnableDataValue)
                                MES_FunctionList.EncodeByProblem = true;
                        }
                        else if (dtTaskList.Rows[i][MES_Config.TaskCodeFieldName].ToString() == MES_Config.EncodeByRushTaskCode)
                        {
                            if (dtTaskList.Rows[i][MES_Config.EnableFieldName].ToString() == MES_Config.EnableDataValue)
                                MES_FunctionList.EncodeByRush = true;
                        }
                        else if (dtTaskList.Rows[i][MES_Config.TaskCodeFieldName].ToString() == MES_Config.OperationModeTaskCode)
                        {
                            if (dtTaskList.Rows[i][MES_Config.EnableFieldName].ToString() == MES_Config.EnableDataValue)
                                MES_FunctionList.OperationMode = true;
                        }
                        else if (dtTaskList.Rows[i][MES_Config.TaskCodeFieldName].ToString() == MES_Config.GenerateTagTaskCode)
                        {
                            if (dtTaskList.Rows[i][MES_Config.EnableFieldName].ToString() == MES_Config.EnableDataValue)
                                MES_FunctionList.GenerateTag = true;
                        }
                        else if (dtTaskList.Rows[i][MES_Config.TaskCodeFieldName].ToString() == MES_Config.InsertBagTaskCode)
                        {
                            if (dtTaskList.Rows[i][MES_Config.EnableFieldName].ToString() == MES_Config.EnableDataValue)
                                MES_FunctionList.InsertBag = true;
                        }
                    }
                    if (_logger.IsInfoEnabled)
                        _logger.Info("Finished loading task list for domain user...");
                }
                else
                {
                    if (bEmergencyUser == true)
                    {
                        if (_logger.IsInfoEnabled)
                            _logger.Info("Start getting task list for emergency user...");
                        string xmlSettingFile = PALS.Utilities.Functions.GetXMLFileFullName("PALS_BASE", @"MES\CFG_MES.xml", 5);
                        if (xmlSettingFile == null)
                        {
                            // Read XML configuration file from \CFG sub folder.
                            xmlSettingFile = PALS.Utilities.Functions.GetXMLFileFullName("PALS_BASE", @"cfg\CFG_MES.xml", 5);

                            if (xmlSettingFile == null)
                                throw new Exception("XML configuration file (CFG_MES.xml) could not be found!");
                        }

                        XmlElement xmlRoot = PALS.Utilities.XMLConfig.GetConfigFileRootElement(xmlSettingFile);
                        if (xmlRoot == null)
                        {
                            throw new Exception("Open application setting XML configuration file failure!");
                        }

                        XmlNode node = XMLConfig.GetConfigSetElement(ref xmlRoot, "configSet", "name", "BHS.MES.TCPClientChains.DataPersistor.Database.Persistor");
                        if (node == null)
                        {
                            throw new Exception("Reading settings from ConfigSet <configSet name=\"" +
                                                       "emergencyUserTaskAssignment" + "\"> is failed!");
                        }

                        XmlNode xmlTaskList = XMLConfig.GetConfigSetElement(ref node, MES_EMERGENCY_TASK_LIST);
                        if (xmlTaskList == null)
                        {
                            if (_logger.IsErrorEnabled)
                                _logger.Error("<" + MES_EMERGENCY_TASK_LIST + "> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");
                        }
                        else
                        {
                            string sTaskName = string.Empty;
                            int iLength = xmlTaskList.ChildNodes.Count;
                            for (int i = 0; i < iLength; i++)
                            {
                                sKey = XMLConfig.GetSettingFromAttribute(xmlTaskList.ChildNodes[i], "taskID", string.Empty).Trim();
                                if (_logger.IsInfoEnabled)
                                    _logger.Info(sKey + " = " + xmlTaskList.ChildNodes[i].InnerText);
                                if (sKey == MES_Config.EncodeByTagTaskCode)
                                {
                                    if (xmlTaskList.ChildNodes[i].InnerText.Trim() == "1")
                                        MES_FunctionList.EncodeByTag = true;
                                }
                                else if(sKey == MES_Config.EncodeByFlightTaskCode)
                                {
                                    if (xmlTaskList.ChildNodes[i].InnerText.Trim() == "1")
                                        MES_FunctionList.EncodeByFlight = true;
                                }
                                else if(sKey == MES_Config.EncodeByDestinationTaskCode)
                                {
                                    if (xmlTaskList.ChildNodes[i].InnerText.Trim() == "1")
                                        MES_FunctionList.EncodeByDestination = true;
                                }
                                else if(sKey == MES_Config.EncodeByProblemTaskCode)
                                {
                                    if (xmlTaskList.ChildNodes[i].InnerText.Trim() == "1")
                                        MES_FunctionList.EncodeByProblem = true;
                                }
                                else if(sKey==MES_Config.EncodeByRushTaskCode)
                                {
                                    if (xmlTaskList.ChildNodes[i].InnerText.Trim() == "1")
                                        MES_FunctionList.EncodeByRush = true;
                                }
                                else if(sKey == MES_Config.OperationModeTaskCode)
                                {
                                    if (xmlTaskList.ChildNodes[i].InnerText.Trim() == "1")
                                        MES_FunctionList.OperationMode = true;
                                }
                                else if(sKey==MES_Config.GenerateTagTaskCode)
                                {
                                    if (xmlTaskList.ChildNodes[i].InnerText.Trim() == "1")
                                        MES_FunctionList.GenerateTag = true;
                                }
                                else if (sKey == MES_Config.InsertBagTaskCode)
                                {
                                    if (xmlTaskList.ChildNodes[i].InnerText.Trim() == "1")
                                        MES_FunctionList.InsertBag = true;
                                }
                            }
                        }
                        if (_logger.IsInfoEnabled)
                            _logger.Info("Finished loading task list for emergency user.");
                    }
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Set available function list failure! <" + thisMethod + ">", ex);
            }
        }
        #endregion
    }
}
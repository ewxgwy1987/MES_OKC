#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       Common.cs
// Revision:      1.0 -   15 Jun 2010, By Albert Sun.
// =====================================================================================
//
#endregion

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PALS.Utilities;

namespace BHS.MES
{
    /// <summary>
    /// 
    /// </summary>
    public struct LocationID
    {
        string _subSystem;
        string _location;

        /// <summary>
        /// Subsystem
        /// </summary>
        public string Subsystem
        {
            get { return _subSystem; }
            set { _subSystem = value; }
        }

        /// <summary>
        /// Location
        /// </summary>
        public string Location
        {
            get { return _location; }
            set { _location = value; }
        }
    }

    /// <summary>
    /// LocationCost
    /// </summary>
    public struct LocationCost
    {
        /// <summary>
        /// Location
        /// </summary>
        public LocationID Location;

        /// <summary>
        /// Cost
        /// </summary>
        public int Cost;
    }

    /// <summary>
    /// LastSortation
    /// </summary>
    public struct LastSortation
    {
        /// <summary>
        /// The last destination that particular flight bag was sorted to.
        /// </summary>
        public LocationID Destination;

        /// <summary>
        /// The time of last sortation.
        /// </summary>
        public DateTime Time;
    }

    /// <summary>
    /// Tag - LP, Valid, Type, Airline Code, Airport Code, Fallback Discharged, FourDigitsFallbackDischarged, 
    ///       Securtity Level, SecurityDischarged, code
    /// </summary>
    public struct Tag
    {
        /// <summary>
        /// Valid
        /// </summary>
        public string LP;

        /// <summary>
        /// Valid
        /// </summary>
        public bool Valid;

        /// <summary>
        /// Type
        /// </summary>
        public TagType Type;

        /// <summary>
        /// AirlineCode
        /// </summary>
        public string AirlineCode;

        /// <summary>
        /// AirportLocationCode
        /// </summary>
        public string AirportLocationCode;

        /// <summary>
        /// Sort Destination Discharged
        /// </summary>
        public string Discharged;

        /// <summary>
        /// SecurityLevel
        /// </summary>
        public string SecurityLevel;

        /// <summary>
        /// DestinationTagCode - for use in the 4 digits fallback tag destination code (4 digits), 
        /// security tag destination code (last 2 digits) , fallback tag destination code (last 2 digits)
        /// </summary>
        public string DestinationTagCode;

        /// <summary>
        /// SecurityLevelTagCode - security tag level code (First 2 digits)
        /// </summary>
        public string SecurityLevelTagCode;

        ///// <summary>
        ///// Priority
        ///// </summary>
        //public int Priority;
    }

    public struct MESConfig
    {
        public string TaskCodeFieldName;
        public string EnableFieldName;
        public string EnableDataValue;
        public string EncodeByTagTaskCode;
        public string EncodeByFlightTaskCode;
        public string EncodeByDestinationTaskCode;
        public string EncodeByProblemTaskCode;
        public string EncodeByRushTaskCode;
        public string OperationModeTaskCode;
        public string GenerateTagTaskCode;
        public string ReOccurenceSysKey;
        public string MsgDurationSysKey;
        public string EncodeDurationSysKey;
        public string NoBSMReoccurenceSysKey;
        public string EnableHBS2BSysKey;
        public string InsertBagTaskCode;
        public string EnableAirRushAlloc;
        public string EnableRushFuncAlloc;
    }

    public class FunctionList
    {
        bool bEncodeByTag;
        bool bEncodeByFlight;
        bool bEncodeByDestination;
        bool bEncodeByProblem;
        bool bEncodeByRush;
        bool bOperationMode;
        /*bool bOperationModeSlow;
        bool bOperationModeMedium;
        bool bOperationModeFast;*/
        bool bGenerateTag;
        /*bool bFlightList;
        bool bUpdateInHouseTag;
        bool bDeleteInHouseTag;*/
        bool bInsertBag;

        public FunctionList(bool EncodeByTag, bool EncodeByFlight, bool EncodeByDestination, 
            bool EncodeByProblem, bool EncodeByRush, bool OperationMode, bool GenerateTag, bool InsertBag)
        {
            bEncodeByTag = EncodeByTag;
            bEncodeByFlight = EncodeByFlight;
            bEncodeByDestination = EncodeByDestination;
            bEncodeByProblem = EncodeByProblem;
            bEncodeByRush = EncodeByRush;
            bOperationMode = OperationMode;
            /*bOperationModeSlow = OperationModeSlow;
            bOperationModeMedium = OperationModeMedium;
            bOperationModeFast = OperationModeFast;*/
            bGenerateTag = GenerateTag;
            /*bFlightList = FlightList;
            bUpdateInHouseTag = UpdateInHouseTag;
            bDeleteInHouseTag = DeleteInHouseTag;*/
            bInsertBag = InsertBag;
        }

        public bool EncodeByTag
        {
            get { return bEncodeByTag; }
            set { bEncodeByTag = value; }
        }

        public bool EncodeByFlight
        {
            get { return bEncodeByFlight; }
            set { bEncodeByFlight = value; }
        }

        public bool EncodeByDestination
        {
            get { return bEncodeByDestination; }
            set { bEncodeByDestination = value; }
        }

        public bool EncodeByProblem
        {
            get { return bEncodeByProblem; }
            set { bEncodeByProblem = value; }
        }

        public bool EncodeByRush
        {
            get { return bEncodeByRush; }
            set { bEncodeByRush = value; }
        }

        public bool OperationMode
        {
            get { return bOperationMode; }
            set { bOperationMode = value; }
        }

        /*public bool OperationModeSlow
        {
            get { return bOperationModeSlow; }
            set { bOperationModeSlow = value; }
        }

        public bool OperationModeMedium
        {
            get { return bOperationModeMedium; }
            set { bOperationModeMedium = value; }
        }

        public bool OperationModeFast
        {
            get { return bOperationModeFast; }
            set { bOperationModeFast = value; }
        }*/

        public bool GenerateTag
        {
            get { return bGenerateTag; }
            set { bGenerateTag = value; }
        }

        /*public bool FlightList
        {
            get { return bFlightList; }
            set { bFlightList = value; }
        }

        public bool UpdateInHouseTag
        {
            get { return bUpdateInHouseTag; }
            set { bUpdateInHouseTag = value; }
        }

        public bool DeleteInHouseTag
        {
            get { return bDeleteInHouseTag; }
            set { bDeleteInHouseTag = value; }
        }*/

        public bool InsertBag
        {
            get { return bInsertBag; }
            set { bInsertBag = value; }
        }
    }

    /// <summary>
    /// TagType - IATA Interline, IATA Fallback, 4 Digits Security, 4 Digits Fallback, In-House
    /// </summary>
    public enum TagType
    {
        /// <summary>
        /// IATATag = 0
        /// </summary>
        IATATag = 0,

        /// <summary>
        /// FallbackTag = 1
        /// </summary>
        FallbackTag = 1,

        /// <summary>
        /// FourDigitsFallbackTag = 2
        /// </summary>
        FourDigitsFallbackTag = 2,

        /// <summary>
        /// SecurityTag = 3
        /// </summary>
        SecurityTag = 3,

        /// <summary>
        /// InHouseTag = 4
        /// </summary>
        InHouseTag = 4,

        /// <summary>
        /// DummyEmptyLP = 5
        /// </summary>
        DummyEmptyLP = 5,

        /// <summary>
        /// DummyMultipleLP = 6
        /// </summary>
        DummyMultipleLP = 6,

        /// <summary>
        /// Others = 7
        /// </summary>
        OthersTag = 7
    }

    /// <summary>
    /// BagStates - Unknow, TooEarly, Early, Open, Rush, Too Late
    /// </summary>
    public enum BagStates
    {
        /// <summary>
        /// Unknow = 0
        /// </summary>
        Unknow = 0,

        /// <summary>
        /// TooEarly = 1
        /// </summary>
        TooEarly = 1,

        /// <summary>
        /// Early = 2
        /// </summary>
        Early = 2,

        /// <summary>
        /// Open = 3
        /// </summary>
        Open = 3,

        /// <summary>
        /// Rush = 4
        /// </summary>
        Rush = 4,

        /// <summary>
        /// TooLate = 5
        /// </summary>
        TooLate = 5,

        /// <summary>
        /// OffBlock = 6
        /// </summary>
        OffBlock = 6
    }

    /// <summary>
    /// RelatedNames - STD, ETD, ITD, ATD
    /// </summary>
    public struct RelatedNames
    {
        /// <summary>
        /// STD
        /// </summary>
        public string STD;

        /// <summary>
        /// ETD
        /// </summary>
        public string ETD;

        /// <summary>
        /// ITD
        /// </summary>
        public string ITD;

        /// <summary>
        /// ATD
        /// </summary>
        public string ATD;
    }

    /// <summary>
    /// All destination
    /// </summary>
    public struct AllDestination
    {
        /// <summary>
        /// Destination Name
        /// </summary>
        public string DestID;

        /// <summary>
        /// Destination Button color
        /// </summary>
        public string DestColor;

        /// <summary>
        /// Destination Actuve
        /// </summary>
        public string IsActive;
    }


    /// <summary>
    /// Utilies - LocationIDArrayToString, BagTagDecoding, ConvertStringToDate
    /// </summary>
    public class Utilities
    {
        private const string EMPTY_AIRPORT_LOCATION = "0000";
        //private const string IDENTIFIER_FALLBACK_TAG = "1";
        //private const string IDENTIFIER_IATA_TAG = "0";

        private static readonly string _className =
                    System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Create a logger for use in this class
        private static readonly log4net.ILog _logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);


        /// <summary>
        /// Convert LocationID structure object array to "Location1/Subsystem1, Location2/Subsystem2, ..."
        /// format string for display purpose.
        /// </summary>
        /// <param name="locations"></param>
        /// <returns></returns>
        public static string LocationIDArrayToString(ref LocationID[] locations)
        {
            string temp, dest;

            if (locations == null)
            {
                return null;
            }

            dest = string.Empty;

            for (int i = 0; i < locations.Length; i++)
            {
                temp = locations[i].Location + "/" + locations[i].Subsystem;

                if (dest == string.Empty)
                {
                    dest = temp;
                }
                else
                {
                    dest = dest + ", " + temp;
                }
            }

            return dest;
        }

        /// <summary>
        /// Decode a 10-digit IATA code or or 4 digits tag into a Tag structure object:
        /// public struct Tag
        /// {
        ///     public string LP;
        ///     public bool Valid;
        ///     public TagType Type;
        ///     public string AirlineCode;
        ///     public string AirportLocationCode;
        ///     public string FallbackDischarged;
        ///     public string FourDigitsFallbackDischarged;
        ///     public string SecurityLevel;
        ///     public string SecurityDischarged;
        /// }
        /// 
        /// Tag.Type will indicate this bag tag is Fallback Tag, Normal IATA License Plate Tag, 4 Digits Fallback Tag or Security Tag.
        /// Tag.Valid will indicate whether the Fallback tag is valid or invalid (the airport location
        /// code in the 10-digit code is not identical to the specific airport location code (given by 
        /// the function argument: AirportLocationCode).
        /// 4 Digits Fallback Tag and Security Tag are having length of 4.
        /// If it is IATA tag, 4 Digits Fallback Tag or Security Tag then the Tag.Valid field value will alwasy be True.  
        /// </summary>
        /// <param name="licensePlate"></param>
        /// <param name="dbPersistor"></param>
        /// <returns></returns>
        public static Tag BagTagDecoding(string licensePlate, TCPClientChains.DataPersistor.Database.Persistor dbPersistor)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            Tag bagTag = new Tag();

            bagTag.LP = licensePlate;
            bagTag.AirportLocationCode = dbPersistor.AirportLocationCode;
            bagTag.Valid = true;

            try
            {
                if (licensePlate.Length == 4)
                {
                    // Get the tag type (First 1 digits of LP#)
                    string type = licensePlate.Substring(0, 1);

                    // Set Airline Code as "000" as it is not in used
                    bagTag.AirportLocationCode = EMPTY_AIRPORT_LOCATION;

                    //int hasRecord = dbPersistor.ValidationOfFourDigitsTag(type);

                    if (dbPersistor.ClassParameters.FourDigitsSecurityIdentification == type)
                    {
                        // Security Tag
                        bagTag.Type = TagType.SecurityTag;

                        bagTag.SecurityLevelTagCode = licensePlate.Substring(0, 2);

                        // Get the Destination code (3-4 digits of LP#)
                        bagTag.DestinationTagCode = licensePlate.Substring(2, 2);
                    }
                    else if (dbPersistor.ClassParameters.FourDigitsFallbackIdentification == type)
                    {
                        // 4 Digits Fallback Tag
                        bagTag.Type = TagType.FourDigitsFallbackTag;

                        // Get the Destination code (1-4 digits of LP#)
                        bagTag.DestinationTagCode = licensePlate.Substring(0, 4);
                    }
                    else
                    {
                        // 4 Digits Fallback Tag
                        bagTag.Type = TagType.FourDigitsFallbackTag;
                        bagTag.Valid = false;
                    }
                }
                else if (licensePlate.Length == 10)
                {
                    // Get tag type (1 digit of LP#)
                    string type = licensePlate.Substring(0, 1);

                    // Get the Airline code (2-4 digits of LP#)
                    bagTag.AirlineCode = licensePlate.Substring(1, 3);

                    if (licensePlate == dbPersistor.ClassParameters.EmptyLicensePlate)
                    {
                        bagTag.Type = TagType.DummyEmptyLP;
                    }
                    else if (licensePlate == dbPersistor.ClassParameters.DummyMultipleLicensePlate)
                    {
                        bagTag.Type = TagType.DummyMultipleLP;
                    }
                    else if (type.CompareTo(dbPersistor.ClassParameters.IATAFallbackIdentifier) == 0)
                    {
                        bagTag.Type = TagType.FallbackTag;

                        // Get the Airport location code (5-8 digits of LP#)
                        bagTag.AirportLocationCode = licensePlate.Substring(4, 4);

                        // Get the Destination code (9-10 digits of LP#)
                        bagTag.DestinationTagCode = licensePlate.Substring(8, 2);

                        if (bagTag.AirportLocationCode.CompareTo(dbPersistor.AirportLocationCode) != 0)
                        {
                            bagTag.Valid = false;
                        }
                        else
                        {
                            bagTag.Valid = true;
                        }
                    }
                    else if (type.CompareTo(dbPersistor.ClassParameters.IATAInterlineIdentifier) == 0)
                    {
                        bagTag.Type = TagType.IATATag;
                    }
                    else if ((type.CompareTo(dbPersistor.ClassParameters.InHouseIdentifier) == 0) & (bagTag.AirlineCode == dbPersistor.ClassParameters.InHouseAirlineCode))
                    {
                        bagTag.Type = TagType.InHouseTag;
                    }
                    else
                    {
                        bagTag.Type = TagType.IATATag;
                    }
                }
                else
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Bag Tag Decoding failed as LP length not equal to 4 or 10. <" + thisMethod + ">");

                    bagTag.LP = licensePlate;
                    bagTag.Type = TagType.DummyEmptyLP;
                    bagTag.AirportLocationCode = EMPTY_AIRPORT_LOCATION;
                    bagTag.Valid = false;
                }

                return bagTag;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Bag Tag Decoding failed. <" + thisMethod + ">", ex);

                bagTag.LP = licensePlate;
                bagTag.Type = TagType.DummyEmptyLP;
                bagTag.AirportLocationCode = EMPTY_AIRPORT_LOCATION;
                bagTag.Valid = false;

                return bagTag;
            }
        }

        /// <summary>
        /// Convert Hex Values into Byte Array
        /// </summary>
        /// <param name="hexVal"></param>
        /// <param name="fieldLen"></param>
        /// <param name="reverse"></param>
        /// <returns></returns>
        public static byte[] ToByteArray(String hexVal, int fieldLen, bool reverse)
        {
            hexVal = hexVal.PadLeft(fieldLen * 2, '0');

            int NumberChars = hexVal.Length;
            byte[] bytes = new byte[NumberChars / 2];
            for (int i = 0; i < NumberChars; i += 2)
            {
                bytes[i / 2] = Convert.ToByte(hexVal.Substring(i, 2), 16);
            }
            return bytes;
        }

        /// <summary>
        /// Convert Hex into Decimal 
        /// </summary>
        /// <param name="fieldActualValue"></param>
        /// <param name="strIntType"></param>
        /// <returns></returns>
        public static string ConvertVal2Decimal(byte[] fieldActualValue, string strIntType)
        {
            string strRetVal = string.Empty;
            string strOrgVal = string.Empty;

            strOrgVal = Functions.ConvertByteArrayToString(fieldActualValue, -1, HexToStrMode.ToPaddedHexString).Trim().Replace(" ", string.Empty);

            if (strIntType == "16")
            {
                Int16 intVal = Int16.Parse(strOrgVal, System.Globalization.NumberStyles.HexNumber);
                strRetVal = intVal.ToString();
            }
            else if (strIntType == "32")
            {
                Int32 intVal = Int32.Parse(strOrgVal, System.Globalization.NumberStyles.HexNumber);
                strRetVal = intVal.ToString();
            }
            else if (strIntType == "64")
            {
                Int64 intVal = Int64.Parse(strOrgVal, System.Globalization.NumberStyles.HexNumber);
                strRetVal = intVal.ToString();
            }

            return strRetVal;
        }

        /// <summary>
        /// Allocation property : Early, Too Early, Open, Late, Too Late
        /// </summary>
        /// <param name="strLicensePlate"></param>
        /// <param name="DBPersistorConnStr"></param>
        /// <param name="DBPersistor_STP"></param>
        /// <returns></returns>
        //public static string AllocationProperty(string strLicensePlate, string strCarrier, string strFlightNo, string strSDO, string DBPersistorConnStr, string DBPersistor_STP)
        //{
        //    string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
        //    SqlConnection sqlConn = null;
        //    SqlCommand sqlCmd = null;

        //    System.TimeSpan timeSpan_allocOpenOffset, timeSpan_allocCloseOffset, timeSpan_allocEarlyOpenOffset, timeSpan_allocRushDuration;
        //    string alloc_open_offset, alloc_open_related, alloc_close_offset, alloc_close_related, alloc_early_open_offset, alloc_rush_duration;
        //    string sdo, edo, ido, sto, eto, ito;
        //    DateTime std, etd, itd, s_do, e_do, i_do;

        //    alloc_open_offset = string.Empty;
        //    alloc_open_related = string.Empty;
        //    alloc_close_offset = string.Empty;
        //    alloc_close_related = string.Empty;
        //    alloc_early_open_offset = string.Empty;
        //    alloc_rush_duration = string.Empty;
        //    sdo = string.Empty;
        //    edo = string.Empty;
        //    ido = string.Empty;
        //    sto = string.Empty;
        //    eto = string.Empty;
        //    ito = string.Empty;

        //    string Allocation_Property = "UNKNOWN";
        //    try
        //    {
        //        alloc_open_related = "STD";

        //        sqlConn = new SqlConnection(DBPersistorConnStr);
        //        sqlCmd = new SqlCommand(DBPersistor_STP, sqlConn);
        //        sqlCmd.CommandType = CommandType.StoredProcedure;
        //        sqlCmd.Parameters.AddWithValue("@LICENSE_PLATE", strLicensePlate);
        //        sqlCmd.Parameters.AddWithValue("@CARRIER", strCarrier);
        //        sqlCmd.Parameters.AddWithValue("@FLIGHT_NO", strFlightNo);
        //        sqlCmd.Parameters.AddWithValue("@S_DO", strSDO);

        //        sqlConn.Open();
        //        SqlDataReader sqlReader = sqlCmd.ExecuteReader();
        //        while (sqlReader.Read())
        //        {
        //            alloc_open_offset = sqlReader["ALLOC_OPEN_OFFSET"].ToString();
        //            alloc_open_related = sqlReader["ALLOC_OPEN_RELATED"].ToString();
        //            alloc_close_offset = sqlReader["ALLOC_CLOSE_OFFSET"].ToString();
        //            alloc_close_related = sqlReader["ALLOC_CLOSE_RELATED"].ToString();
        //            alloc_early_open_offset = sqlReader["ALLOC_EARLY_OPEN_OFFSET"].ToString();
        //            alloc_rush_duration = sqlReader["ALLOC_RUSH_DURATION"].ToString();

        //            sdo = sqlReader["SDO"].ToString();
        //            edo = sqlReader["EDO"].ToString();
        //            ido = sqlReader["IDO"].ToString();

        //            sto = sqlReader["STO"].ToString();
        //            eto = sqlReader["ETO"].ToString();
        //            ito = sqlReader["ITO"].ToString();

        //            s_do = Convert.ToDateTime(sdo == string.Empty ? null : sdo);
        //            e_do = Convert.ToDateTime(edo == string.Empty ? null : edo);
        //            i_do = Convert.ToDateTime(ido == string.Empty ? null : ido);

        //            // Need to imporve on getting the correct Date Time based on current Regional & Language setting
        //            std = sdo == string.Empty ? Convert.ToDateTime(null) : Convert.ToDateTime(s_do.Year.ToString() + "-" + s_do.Month.ToString() + "-" + s_do.Day.ToString() + " " + sto.Substring(0, 2) + ":" + sto.Substring(2, 2));
        //            etd = edo == string.Empty ? Convert.ToDateTime(null) : Convert.ToDateTime(e_do.Year.ToString() + "-" + e_do.Month.ToString() + "-" + e_do.Day.ToString() + " " + eto.Substring(0, 2) + ":" + eto.Substring(2, 2));
        //            itd = ido == string.Empty ? Convert.ToDateTime(null) : Convert.ToDateTime(i_do.Year.ToString() + "-" + i_do.Month.ToString() + "-" + i_do.Day.ToString() + " " + ito.Substring(0, 2) + ":" + ito.Substring(2, 2));

        //            timeSpan_allocOpenOffset = timeSpan(alloc_open_offset);
        //            timeSpan_allocCloseOffset = timeSpan(alloc_close_offset);
        //            timeSpan_allocEarlyOpenOffset = timeSpan(alloc_early_open_offset);
        //            timeSpan_allocRushDuration = timeSpan(alloc_rush_duration);

        //            DateTime alloc_open = std;
        //            switch (alloc_open_related)
        //            {
        //                case "STD":
        //                    alloc_open = std.Add(timeSpan_allocOpenOffset);
        //                    break;
        //                case "ETD":
        //                    alloc_open = etd.Add(timeSpan_allocOpenOffset);
        //                    break;
        //                case "ITD":
        //                    alloc_open = itd.Add(timeSpan_allocOpenOffset);
        //                    break;
        //            }

        //            DateTime alloc_close = std;
        //            switch (alloc_close_related)
        //            {
        //                case "STD":
        //                    alloc_close = std.Add(timeSpan_allocCloseOffset);
        //                    break;
        //                case "ETD":
        //                    alloc_close = etd.Add(timeSpan_allocCloseOffset);
        //                    break;
        //                case "ITD":
        //                    alloc_close = itd.Add(timeSpan_allocCloseOffset);
        //                    break;
        //            }

        //            DateTime alloc_early_open = alloc_open.Add(timeSpan_allocEarlyOpenOffset);
        //            DateTime alloc_rush = alloc_close.Add(timeSpan_allocRushDuration);

        //            if (DateTime.Now < alloc_early_open)
        //            {
        //                // Too early allocation 
        //                Allocation_Property = "2EARLY";
        //            }
        //            else if (alloc_early_open < DateTime.Now && DateTime.Now < alloc_open)
        //            {
        //                // Early allocation
        //                Allocation_Property = "EARLY";
        //            }
        //            else if (alloc_open < DateTime.Now && DateTime.Now < alloc_close)
        //            {
        //                // Open allocation
        //                Allocation_Property = "OPEN";
        //            }
        //            else if (alloc_close < DateTime.Now && DateTime.Now < alloc_rush)
        //            {
        //                // Rush allocation 
        //                Allocation_Property = "RUSH";
        //            }
        //            else if (alloc_rush < DateTime.Now)
        //            {
        //                // Too late allocation
        //                Allocation_Property = "2LATE";
        //            }
        //        }

        //        if (_logger.IsInfoEnabled)
        //            _logger.Info("Allocation property for License Plate " + strLicensePlate + " is " + Allocation_Property + " <" + thisMethod + ">");
        //    }
        //    catch (Exception ex)
        //    {
        //        if (_logger.IsErrorEnabled)
        //            _logger.Error("Checking of Allocation property failure !<" + thisMethod + ">", ex);
        //    }
        //    finally
        //    {
        //        if (sqlConn != null) sqlConn.Close();
        //    }

        //    return Allocation_Property;

        //}

        /// <summary>
        /// Convert string into Time Span
        /// </summary>
        /// <param name="offset"></param>
        /// <returns></returns>
        public static TimeSpan timeSpan(string offset)
        {
            TimeSpan timeSpan;

            if (offset == string.Empty || offset.ToUpper() == "NULL")
            {
                timeSpan = new System.TimeSpan(0, 0, 0);
            }
            else
            {
                if (offset.Contains("-"))
                {
                    timeSpan = new System.TimeSpan(-int.Parse(offset.Substring(1, 2).ToString()), -int.Parse(offset.Substring(3, 2).ToString()), 0);
                }
                else
                {
                    timeSpan = new System.TimeSpan(int.Parse(offset.Substring(0, 2).ToString()), int.Parse(offset.Substring(2, 2).ToString()), 0);
                }
            }

            return timeSpan;
        }

    }
}

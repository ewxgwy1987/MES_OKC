#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       GUIInitializer.cs
// Revision:      1.0 -   17 Jun 2010, By Albert Sun.
// =====================================================================================
//
#endregion

#region System Header Declaration
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using System.Data.SqlClient;
using PALS;
using BHS.MES;
using DYMO;
using System.Diagnostics;
#endregion

namespace BHS.MES.GUI
{
    public class GUIInitializer:IDisposable
    {
        #region Clss Fields Declaration
        private string _className =
            System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();

        public BHS.MES.TCPClientChains.Application.Initializer AppInit
        {
            get{return _appInit;}
            set{_appInit = value;}
        }

        public BHS.MES.GUI.GUIParameters ClassParameters { get; set; }

        public int GUI_Input_Length { get; set; }
        public int GUI_FlightNo_Length { get; set; }
        public int GUI_AirLine_Length { get; set; }
        public int GUI_Destination_Length { get; set; }
        public int GUI_RushAirLine_Length { get; set; }
        public int GUI_DestTag_Length { get; set; }
        public int GUI_FlightTag_Length { get; set; }
        public int GUI_RushTag_Length { get; set; }
        public string GUI_Last_Encode_Tag { get; set; }
        public string GUI_Last_Encode_Tag_Reason { get; set; }

        private static readonly log4net.ILog _logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private BHS.MES.TCPClientChains.Application.Initializer _appInit;
        #endregion

        #region Class Constructor, Dispose, & Destructor
        /// <summary>
        /// Class constructer.
        /// </summary>
        public GUIInitializer()
        {

        }

        //public GUIInitializer(PALS.Common.IParameters param)
        //{
        //    if (param == null)
        //        throw new Exception("Constractor parameter can not be null! Creating class " + _className +
        //            " object failed! <BHS.MES.GUIInitializer.Constructor()>");

        //    ClassParameters = (BHS.MES.GUI.GUIParameters)param;
        //}

        /// <summary>
        /// Class destructer.
        /// </summary>
        ~GUIInitializer()
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

            if (_appInit != null)
            {
                BHS.MES.TCPClientChains.Application.Initializer ApplicationInit =
                    (BHS.MES.TCPClientChains.Application.Initializer)_appInit;
                ApplicationInit.Dispose();
                _appInit = null;
            }

            if (disposing)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object has been destroyed. <" + _className + ".Dispose()>");
                _logger.Info("[..................] <" + thisMethod + ">");
                _logger.Info("[...App Stopped....] <" + thisMethod + ">");
                _logger.Info("[..................] <" + thisMethod + ">");
            }
        }
        #endregion

        #region Class Method Declaration
        public bool Init()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            bool returnValue = false;
            if (_appInit != null)
                returnValue = false;

            try
            {
                string xmlSettingFile = PALS.Utilities.Functions.GetXMLFileFullName("PALS_BASE", @"MES\CFG_MES.xml", 5);            
                if (xmlSettingFile == null)
                {
                    // Read XML configuration file from \CFG sub folder.
                    xmlSettingFile = PALS.Utilities.Functions.GetXMLFileFullName("PALS_BASE", @"cfg\CFG_MES.xml", 5);
                    //xmlSettingFile = @"D:\_PanFeng_\My Documents\Visual Studio 2010\Projects\PGL\Projects\CSIA_MES\cfg\CFG_MES.xml";
                    if (xmlSettingFile == null)
                        throw new Exception("XML configuration file (CFG_MESGW.xml) could not be found!");
                }

                string xmlTelegramFile = PALS.Utilities.Functions.GetXMLFileFullName("PALS_BASE", @"MES\CFG_Telegrams.xml", 5);
                if (xmlTelegramFile == null)
                {
                    // Read XML configuration file from \CFG sub folder.
                    xmlTelegramFile = PALS.Utilities.Functions.GetXMLFileFullName("PALS_BASE", @"cfg\CFG_Telegrams.xml", 5);
                    //xmlTelegramFile = @"D:\_PanFeng_\My Documents\Visual Studio 2010\Projects\PGL\Projects\CSIA_MES\cfg\CFG_Telegrams.xml";
                    if (xmlTelegramFile == null)
                        throw new Exception("XML configuration file (CFG_Telegrams.xml) could not be found!");
                }

                _appInit = new BHS.MES.TCPClientChains.Application.Initializer(xmlSettingFile, xmlTelegramFile);
                if (_appInit.Init())
                {
                    ClassParameters = (BHS.MES.GUI.GUIParameters)_appInit.XmlLoader.Paramters_GUI;
                    GUI_Input_Length= Convert.ToInt32(((BHS.MES.GUI.GUIParameters)(_appInit.XmlLoader.Paramters_GUI)).InputTextLength);
                    GUI_FlightNo_Length = Convert.ToInt32(((BHS.MES.GUI.GUIParameters)(_appInit.XmlLoader.Paramters_GUI)).FlightNoLength);
                    //GUI_AirLine_Length = Convert.ToInt32(((BHS.MES.GUI.GUIParameters)(_appInit.XmlLoader.Paramters_GUI)).AirLineLength);
                    GUI_Destination_Length = Convert.ToInt32(((BHS.MES.GUI.GUIParameters)(_appInit.XmlLoader.Paramters_GUI)).DestinationLength);
                    //GUI_RushAirLine_Length = Convert.ToInt32(((BHS.MES.GUI.GUIParameters)(_appInit.XmlLoader.Paramters_GUI)).RushAirLineLength);
                    //GUI_DestTag_Length = Convert.ToInt32(((BHS.MES.GUI.GUIParameters)(_appInit.XmlLoader.Paramters_GUI)).DestTagLength);
                    //GUI_FlightTag_Length = Convert.ToInt32(((BHS.MES.GUI.GUIParameters)(_appInit.XmlLoader.Paramters_GUI)).FlightTagLength);
                    //GUI_RushTag_Length = Convert.ToInt32(((BHS.MES.GUI.GUIParameters)(_appInit.XmlLoader.Paramters_GUI)).RushTagLength);
                    GUI_Last_Encode_Tag = string.Empty;
                    GUI_Last_Encode_Tag_Reason = string.Empty;

                    returnValue=true;
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Initializing class setting is failed! <" + thisMethod + ">", ex);

                returnValue = true;
            }

            return returnValue;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="UserName">Login User Name as type of System.String</param>
        /// <param name="StationName">Station Name as type of System.String</param>
        /// <param name="Login">Login as type of System.Boolean</param>
        /// <param name="Subsystem">Subsystem as type of System.String</param>
        /// <param name="Location">Location as type of System.String</param>
        public void UserLoginLogOut(string UserName, string StationName, bool Login, string Subsystem, string Location)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            try
            {
                if (Login == true)
                {
                    AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, "", "", Subsystem, Location, StationName, "LOGIN", "User Login");
                    AppInit.MsgHandler.DBPersistor.UpdateMdsAlarmsForLoginLogout(StationName, "login");
                }
                else
                {
                    AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, "", "", Subsystem, Location, StationName, "LOGOUT", "User Logout");
                    AppInit.MsgHandler.DBPersistor.UpdateMdsAlarmsForLoginLogout(StationName, "logout");
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Logging user login to db failed! <" + thisMethod + ">", ex);
            }
        }

        public void LastEncoding(string MESStation)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            string lastEncodeTag, lastEncodeReason;
            try
            {
                AppInit.MsgHandler.DBPersistor.GetLastEncoding(MESStation,out lastEncodeTag, out lastEncodeReason);
                GUI_Last_Encode_Tag = lastEncodeTag;
                GUI_Last_Encode_Tag_Reason = lastEncodeReason;
            }
            catch (Exception ex)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Logging item ready to db failed! <" + thisMethod + ">", ex);
            }
        }

        //public DataTable GetPassengerInfo(string licensePlate)
        //{
        //    DataTable passengerInfo = null;
        //    if (licensePlate.Length == 10)
        //    {
        //        passengerInfo = AppInit.MsgHandler.DBPersistor.GetPassengerInfo(licensePlate, AppInit.MsgHandler.TTS);
        //    }
        //    return passengerInfo;
        //}

        public string GetLicensePlate(string bagGID)
        {
            string licensePlate = string.Empty;
            licensePlate = AppInit.MsgHandler.DBPersistor.GetLicensePlate(bagGID);
            return licensePlate;
        }

        public string GetBagGID(string licensePlate)
        {
            string bagGID = string.Empty;
            bagGID = AppInit.MsgHandler.DBPersistor.GetBagGID(licensePlate);
            return bagGID;
        }

        public bool EncodeProblem(string bagGID, string iataTag, string airlineCode, string destination, string sortReason, string plcIndex, 
            string minHBSLevel, string curHBSLevel, string curHBSResult, string customResult, string sortedReason, string flightNumber)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            if (bagGID == string.Empty && iataTag == string.Empty)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by problem destination failed! Blank bag gid and iata tag. <" + thisMethod + ">");
                return false;
            }

            if (airlineCode == string.Empty)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by problem destination failed! Airline code blank. <" + thisMethod + ">");
                return false;
            }

            if (destination == string.Empty)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by problem destination failed! Destination code blank. <" + thisMethod + ">");
                return false;
            }

            
            //AppInit.MsgHandler.SendIEC(bagGID, iataTag, destination, ClassParameters.EncodeByProblemBag, sortReason, plcIndex,
            //    minHBSLevel,curHBSLevel,curHBSResult, customResult, sortedReason, flightNumber);
            return true;
        }

        public bool EncodeRush(string bagGID, string iataTag, string airlineCode, string destination, string sortReason, string plcIndex,
            string minHBSLevel, string curHBSLevel, string curHBSResult, string customResult, string sortedReason, string flightNumber)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            if (bagGID == string.Empty && iataTag == string.Empty)
            {
                if(_logger.IsInfoEnabled)
                    _logger.Info("Encoded by rush destination failed! Blank bag gid and iata tag. <" + thisMethod + ">");
                return false;
            }

            if (airlineCode == string.Empty)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by rush destination failed! Airline code blank. <" + thisMethod + ">");
                return false;
            }

            if (destination == string.Empty)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by rush destination failed! Destination code blank. <" + thisMethod + ">");
                return false;
            }

            //AppInit.MsgHandler.SendIEC(bagGID, iataTag, destination, ClassParameters.EncodeByProblemBag, sortReason, plcIndex,
            //    minHBSLevel, curHBSLevel, curHBSResult, customResult, sortedReason, flightNumber);
            return true;
        }

        public bool EncodeByTag(string bagGID, string iataTag, string destination, string sortReason, string plcIndex,
            string minHBSLevel, string curHBSLevel, string curHBSResult, string customResult, string sortedReason, string flightNumber)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            if (bagGID == string.Empty || bagGID == "")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by tag failed! Blank bag gid. <" + thisMethod + ">");
                return false;
            }

            if (iataTag == string.Empty || iataTag == "")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by tag failed! Blank iata tag. <" + thisMethod + ">");
                return false;
            }

            if (destination == string.Empty || destination == "")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by tag failed! Destination code blank. <" + thisMethod + ">");
                return false;
            }

            //AppInit.MsgHandler.SendIEC(bagGID, iataTag, destination, ClassParameters.EncodeByProblemBag, sortReason, plcIndex,
            //    minHBSLevel, curHBSLevel, curHBSResult, customResult, sortedReason, flightNumber);
            return true;
        }

        public bool EncodeByFlight(string bagGID, string iataTag, string airlineCode, string flightNumber, string destination,
            string sortReason, string plcIndex, string minHBSLevel, string curHBSLevel, string curHBSResult, string customResult, 
            string sortedReason)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            if (bagGID == string.Empty || bagGID == "")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by flight failed! Blank bag gid. <" + thisMethod + ">");
                return false;
            }

            if (iataTag == string.Empty || iataTag == "")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by flight failed! Blank iata tag. <" + thisMethod + ">");
                return false;
            }

            if (airlineCode == string.Empty || airlineCode == "")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by flight failed! Blank airline code. <" + thisMethod + ">");
                return false;
            }

            if (flightNumber == string.Empty || flightNumber == "")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by flight failed! Blank flight number. <" + thisMethod + ">");
                return false;
            }

            if (destination == string.Empty || destination =="")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by flight failed! Destination code blank. <" + thisMethod + ">");
                return false;
            }

            //AppInit.MsgHandler.SendIEC(bagGID, iataTag, destination, ClassParameters.EncodeByProblemBag, sortReason, plcIndex,
            //    minHBSLevel, curHBSLevel, curHBSResult, customResult, sortedReason, flightNumber);
            return true;
        }

        public bool EncodeByDestination(string bagGID, string iataTag, string destination, string sortReason, string plcIndex,
            string minHBSLevel, string curHBSLevel, string curHBSResult, string customResult, string sortedReason, string flightNumber)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            if (bagGID == string.Empty || iataTag == "")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by destination failed! Blank bag gid. <" + thisMethod + ">");
                return false;
            }

            if (iataTag == string.Empty || iataTag == "")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by destination failed! Blank bag gid and iata tag. <" + thisMethod + ">");
                return false;
            }

            if (destination == string.Empty || destination =="")
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Encoded by destination failed! Blank destination. <" + thisMethod + ">");
                return false;
            }

            //AppInit.MsgHandler.SendIEC(bagGID, iataTag, destination, ClassParameters.EncodeByProblemBag, sortReason, plcIndex,
            //    minHBSLevel, curHBSLevel, curHBSResult, customResult, sortedReason, flightNumber);
            return true;
        }

        public bool CheckTagFormat(string sTag)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            bool returnValue = false;
            Regex allowChar4Digit = new Regex("[09]...");
            Regex allowChar10Digit = new Regex("[0-9].........");
            if (sTag.Length == 4)
            {
                if (allowChar4Digit.IsMatch(sTag) == false)
                {
                    returnValue = false;
                    return returnValue;
                }
            }

            if (sTag.Length == 10)
            {
                if (allowChar10Digit.IsMatch(sTag) == false)
                {
                    returnValue = false;
                    return returnValue;
                }
            }

            if (sTag.Length != 4 && sTag.Length != 10)
            {
                returnValue = false;
                return returnValue;
            }

            returnValue = true;
            return returnValue;
        }

       
        public void PrintLabel(string sTag, string sShortTagMsg, string sTagType, int iCopied)
        {

            DYMO.Label.Framework.ILabel label;
            label = DYMO.Label.Framework.Framework.Open(ClassParameters.LabelFilePath);

            label.SetObjectText("BARCODE_0", sTag);
            label.SetObjectText("BARCODE_1", sTag);
            label.SetObjectText("BARCODE_2", sTag);
            label.SetObjectText("BARCODE_3", sTag);
            label.SetObjectText("TAG_MSG", sShortTagMsg);
            label.SetObjectText("TAG_MSG_1", sShortTagMsg);
            label.SetObjectText("TAG_TYPE", sTagType);
            label.SetObjectText("TAG_TYPE_1", sTagType);
            //label.Print(ClassParameters.LabelName);

            //if (myDymoAddIn.Open(ClassParameters.LabelFilePath))
            //{
            //    myDymoLabel.SetField("BARCODE_0", sTag);
            //    myDymoLabel.SetField("BARCODE_1", sTag);
            //    myDymoLabel.SetField("BARCODE_2", sTag);
            //    myDymoLabel.SetField("BARCODE_3", sTag);
            //    myDymoLabel.SetField("TAG_MSG", sShortTagMsg);
            //    myDymoLabel.SetField("TAG_MSG_1", sShortTagMsg);
            //    myDymoLabel.SetField("TAG_TYPE", sTagType);
            //    myDymoLabel.SetField("TAG_TYPE_1", sTagType);
                if (ClassParameters.LabelPreview == "Y")
                {
                    if (System.IO.File.Exists(ClassParameters.LabelFilePath))
                    {
                        System.IO.File.Delete(ClassParameters.LabelFilePath);
                    }
                    label.SaveToFile(ClassParameters.LabelFilePath);
                    try
                    {
                        Process p = new Process();
                        p.StartInfo.FileName = ClassParameters.LabelFilePath;
                        p.Start();
                    }
                    catch (Exception ex)
                    {
                        if (_logger.IsErrorEnabled)
                            _logger.Error("Unable to open label layout file. <" + _className + ".PrintLabel()>", ex);
                    }
                }
                else
                {
                    label.Print(ClassParameters.LabelName);
                }
            //}
        }

        public void ReloadParameters(PALS.Common.IParameters param)
        {
            if (param == null)
                throw new Exception("Constractor parameter can not be null! Creating class " + _className +
                    " object failed! <BHS.MES.GUIInitializer.Constructor()>");

            ClassParameters = (BHS.MES.GUI.GUIParameters)param;
        }
        #endregion
    }
}

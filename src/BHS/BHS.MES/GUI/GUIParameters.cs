#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       GUIParameters.cs
// Revision:      1.0 -   15 Jun 2010, By Albert Sun.
// =====================================================================================
//
#endregion
using System;
using System.Xml;
using PALS.Utilities;

namespace BHS.MES.GUI
{
    public class GUIParameters:PALS.Common.IParameters, IDisposable
    {
        #region Class Fields Declaration
        private const string txtInputLength = "txtInputLength";
        private const string txtFlightNoLength = "txtFlightNoLength";
        private const string txtAirLineLength = "txtAirLineLength";
        private const string txtDestinationLength = "txtDestinationLength";
        private const string txtRushAirLineLength = "txtRushAirLineLength";
        private const string txtDestTagLength = "txtDestTagLength";
        private const string txtFlightTagLength = "txtFlightTagLength";
        private const string txtRushTagLength = "txtRushTagLength";
        private const string encodeByTag = "encodingTagMode";
        private const string encodeByFlight = "encodingFlightMode";
        private const string encodeByRush = "encodingRushMode";
        private const string encodeByDestination = "encodingDestinationMode";
        private const string encodeByProblemBag = "encodingProblemTag";
        private const string firstDigitForInhouseBSM = "firstDigitsForInhouseBSM";
        private const string destinationPrefix = "destinationPrefix";
        private const string flightListFilter = "filterRange";
        private const string airlineShortCutDisableConstant = "airlineShortCutDisableConstant";
        private const string startupOperationMode = "startUpOperationMode";
        private const string emergencyUserName = "emergencyUserName";
        private const string okBarcode = "okBarcode";
        private const string helpFilePath = "helpFilePath";
        private const string eventLogAppPath = "eventLogAppPath";
        private const string labelFilePath = "labelFile";
        private const string labelName = "labelName";
        private const string labelPreviewStatus = "labelPreview";

        private const string allDestination = "allDestination";

        //Fields Declaration for store procedure MES conv status timer
        private const string Animation_TimerDuration = "AnimationTimerDuration";
        private const string RefreshConv_TimerDuration = "RefreshConvTimerDuration";
        private const string MEStation_Name = "MEStationName";
       

        private static readonly string _className=
            System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        private static readonly log4net.ILog _logger =
            log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        #endregion

        #region Class Constructor & Destructor
        public string InputTextLength { get; set; }
        public string FlightNoLength { get; set; }
        public string AirLineLength { get; set; }
        public string DestinationLength { get; set; }
        public string RushAirLineLength { get; set; }
        public string DestTagLength { get; set; }
        public string FlightTagLength { get; set; }
        public string RushTagLength { get; set; }
        public string EncodeByTag { get; set; }
        public string EncodeByFlight { get; set; }
        public string EncodeByRush { get; set; }
        public string EncodeByDestination { get; set; }
        public string EncodeByProblemBag { get; set; }
        public string FirstDigitForInhouseBSM { get; set; }
        public string DestinationPrefix { get; set; }
        public string LoginUser { get; set; }
        public string FilterRange { get; set; }
        public string AirlineShortcutDisableConstant { get; set; }
        public string StartupOperationMode { get; set; }
        public string EmergencyUserName { get; set; }
        public string OKBarCode { get; set; }
        public string HelpFilePath { get; set; }
        public string EventLogAppPath { get; set; }
        public string LabelFilePath { get; set; }
        public string LabelName { get; set; }
        public string LabelPreview { get; set; }

        public AllDestination[] allDest;

        //new varibale for ME Conv Color status -by PST
        public int AnimationTimerDuration { get; set; }
        public int RefreshConvTimerDuration { get; set; }
        public string MEStationName { get; set; }
        #endregion

        #region Class Constructor & Destructor
        public GUIParameters(XmlNode configSet, XmlNode telegramSet)
        { 
            if(configSet==null)
                throw new Exception("Constractor parameter can not be null! Creating class object fail! " +
                        "<BHS.MES.GUI.GUIParametersConstructor()>");

            if(!Init(ref configSet,ref telegramSet))
                throw new Exception("Instantiate class object failure! " +
                        "<BHS.MES.GUI.GUIParametersConstructor()>");
        }

        ~GUIParameters()
        {
            Dispose(false);
        }

        public void Dispose()
        {
            Dispose(true);
        }

        private void Dispose(bool disposing)
        {
            return;
        }
        #endregion

        #region Class Methods
        public bool Init(ref XmlNode configSet, ref XmlNode telegramSet)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            try
            {
                // Modified by Guo Wenyu 2014/04/03
                string AnimationTimerDuration_str = XMLConfig.GetSettingFromInnerText(
                          configSet, Animation_TimerDuration, string.Empty);
                //if (Animation_TimerDuration == string.Empty)
                if (AnimationTimerDuration_str == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Animation Timer Duration setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }
                else
                    AnimationTimerDuration = Convert.ToInt32(AnimationTimerDuration_str);

                string RefreshConvTimerDuration_str = XMLConfig.GetSettingFromInnerText(
                           configSet, RefreshConv_TimerDuration, string.Empty);
                //if (RefreshConv_TimerDuration == string.Empty)
                if (RefreshConvTimerDuration_str == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("RefreshConv_Timer Duratione setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }
                else
                    RefreshConvTimerDuration = Convert.ToInt32(RefreshConvTimerDuration_str);


                MEStationName = (XMLConfig.GetSettingFromInnerText(
                         configSet, MEStation_Name, string.Empty)).Trim();
                //if (MEStation_Name == string.Empty)
                if (MEStationName == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Display message duration setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }
                

                InputTextLength = (XMLConfig.GetSettingFromInnerText(
                            configSet, txtInputLength, string.Empty)).Trim();
                if (InputTextLength == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Display message duration setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                FlightNoLength = (XMLConfig.GetSettingFromInnerText(
                                            configSet, txtFlightNoLength, string.Empty)).Trim();
                if (FlightNoLength == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Display message duration setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                //AirLineLength = (XMLConfig.GetSettingFromInnerText(
                //                            configSet, txtAirLineLength, string.Empty)).Trim();
                //if (AirLineLength == string.Empty)
                //{
                //    if (_logger.IsErrorEnabled)
                //        _logger.Error("Display message duration setting cannot be empty! <" + thisMethod + ">");

                //    return false;
                //}

                DestinationLength = (XMLConfig.GetSettingFromInnerText(
                                            configSet, txtDestinationLength, string.Empty)).Trim();
                if (DestinationLength == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Display message duration setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                //RushAirLineLength = (XMLConfig.GetSettingFromInnerText(
                //                            configSet, txtRushAirLineLength, string.Empty)).Trim();
                //if (RushAirLineLength == string.Empty)
                //{
                //    if (_logger.IsErrorEnabled)
                //        _logger.Error("Display message duration setting cannot be empty! <" + thisMethod + ">");

                //    return false;
                //}

                //DestTagLength = (XMLConfig.GetSettingFromInnerText(
                //                            configSet, txtDestTagLength, string.Empty)).Trim();
                //if (DestTagLength == string.Empty)
                //{
                //    if (_logger.IsErrorEnabled)
                //        _logger.Error("Display message duration setting cannot be empty! <" + thisMethod + ">");

                //    return false;
                //}

                //FlightTagLength = (XMLConfig.GetSettingFromInnerText(
                //                            configSet, txtFlightTagLength, string.Empty)).Trim();
                //if (FlightTagLength == string.Empty)
                //{
                //    if (_logger.IsErrorEnabled)
                //        _logger.Error("Display message duration setting cannot be empty! <" + thisMethod + ">");

                //    return false;
                //}

                //RushTagLength = (XMLConfig.GetSettingFromInnerText(
                //                            configSet, txtRushTagLength, string.Empty)).Trim();
                //if (RushTagLength == string.Empty)
                //{
                //    if (_logger.IsErrorEnabled)
                //        _logger.Error("Display message duration setting cannot be empty! <" + thisMethod + ">");

                //    return false;
                //}

                EncodeByDestination = (XMLConfig.GetSettingFromInnerText(
                                            configSet, encodeByDestination, string.Empty)).Trim();
                if (EncodeByDestination == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Encoding by destination setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                EncodeByFlight = (XMLConfig.GetSettingFromInnerText(
                                            configSet, encodeByFlight, string.Empty)).Trim();
                if (EncodeByFlight == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Encoding by flight setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                EncodeByProblemBag = (XMLConfig.GetSettingFromInnerText(
                                            configSet, encodeByProblemBag, string.Empty)).Trim();
                if (EncodeByProblemBag == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Encoding problem bag setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                EncodeByRush = (XMLConfig.GetSettingFromInnerText(
                                            configSet, encodeByRush, string.Empty)).Trim();
                if (EncodeByRush == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Encoding by rush destination setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                EncodeByTag = (XMLConfig.GetSettingFromInnerText(
                                            configSet, encodeByTag, string.Empty)).Trim();
                if (EncodeByTag == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Encoding by tag setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                FirstDigitForInhouseBSM = (XMLConfig.GetSettingFromInnerText(
                                            configSet, firstDigitForInhouseBSM, string.Empty)).Trim();
                if (FirstDigitForInhouseBSM == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("First digi for in-house BSM setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                DestinationPrefix = (XMLConfig.GetSettingFromInnerText(
                                            configSet, destinationPrefix, string.Empty)).Trim();
                if (DestinationPrefix == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Destination prefix setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                FilterRange = (XMLConfig.GetSettingFromInnerText(
                                            configSet, flightListFilter, string.Empty)).Trim();
                if (FilterRange == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Flight list filter setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                AirlineShortcutDisableConstant = (XMLConfig.GetSettingFromInnerText(
                                            configSet, airlineShortCutDisableConstant, string.Empty)).Trim();
                if (AirlineShortcutDisableConstant == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Airline shortcut disable constant setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                StartupOperationMode = (XMLConfig.GetSettingFromInnerText(
                                            configSet, startupOperationMode, string.Empty)).Trim();
                if (StartupOperationMode == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Startup operation mode setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                EmergencyUserName = (XMLConfig.GetSettingFromInnerText(
                                            configSet, emergencyUserName, string.Empty)).Trim();
                if (EmergencyUserName == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Emergency user name setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                OKBarCode = (XMLConfig.GetSettingFromInnerText(
                                            configSet, okBarcode, string.Empty)).Trim();
                if (OKBarCode == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("OK barcode setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                HelpFilePath = (XMLConfig.GetSettingFromInnerText(
                                            configSet, helpFilePath, string.Empty)).Trim();
                if (HelpFilePath == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Help file path setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                EventLogAppPath = (XMLConfig.GetSettingFromInnerText(
                            configSet, eventLogAppPath, string.Empty)).Trim();
                if (EventLogAppPath == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("EventLogApp file path setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                LabelFilePath = (XMLConfig.GetSettingFromInnerText(
                                            configSet, labelFilePath, string.Empty)).Trim();
                if (LabelFilePath == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Label file path setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                LabelName = (XMLConfig.GetSettingFromInnerText(
                                            configSet, labelName, string.Empty)).Trim();
                if (LabelName == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Label name setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                LabelPreview = (XMLConfig.GetSettingFromInnerText(
                                            configSet, labelPreviewStatus, string.Empty)).Trim();
                if (LabelPreview == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Label preview setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }

                XmlNode allDestinationConfigSet = XMLConfig.GetConfigSetElement(ref configSet, allDestination);
                string sKey = string.Empty;
                if (allDestinationConfigSet == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<" + allDestination + "> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }
                else
                {
                    allDest = null;
                    allDest = new AllDestination[allDestinationConfigSet.ChildNodes.Count];                    
                    for (int i = 0; i < allDestinationConfigSet.ChildNodes.Count; i++)
                    {
                        allDest[i].DestID= XMLConfig.GetSettingFromAttribute(allDestinationConfigSet.ChildNodes[i], "destID", string.Empty).Trim();
                        allDest[i].DestColor = XMLConfig.GetSettingFromAttribute(allDestinationConfigSet.ChildNodes[i], "color", string.Empty).Trim();
                        allDest[i].IsActive = allDestinationConfigSet.ChildNodes[i].InnerText.Trim();                       
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Initializing class setting is failed! <" + thisMethod + ">", ex);

                return false;
            }
        }
        #endregion
    }
}

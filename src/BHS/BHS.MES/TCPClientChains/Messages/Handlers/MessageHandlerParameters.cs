#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       MessageHandlerParameters.cs
// Revision:      1.0 -   10 Jun 2010, By Albert Sun
// =====================================================================================
//
#endregion

using System;
using System.Xml;
using PALS.Utilities;
using System.Collections.Generic;

namespace BHS.MES.TCPClientChains.Messages.Handlers
{
    public struct msgType
    {
        public string plc, cms;

        public msgType(string _plc, string _cms)
        {
            plc = _plc;
            cms = _cms;
        }
    }
    
    public class MessageHandlerParameters: PALS.Common.IParameters, IDisposable
    {
        #region Class Fields Declaration
        private const string APP_TELEGRAMSET = "Application_Telegrams";
        //... Common Message ...
        private const string MESSAGE_ALIAS_HEADER = "Header"; //Message Header
        private const string MESSAGE_ALIAS_INTM = "INTM"; //Code: 0103, Intermediate message
        private const string MESSAGE_ALIAS_CSNF = "CSNF"; //Code: 0108, Connection Status Notification Message
        //... MES-PLC message ...
        private const string MESSAGE_ALIAS_IRY = "IRY"; //Code: 0201, Item Ready Message
        private const string MESSAGE_ALIAS_IEC = "IEC"; //Code: 0202, Item Encoded Message
        private const string MESSAGE_ALIAS_IRM = "IRM"; //Code: 0203, Item Removed Message

        private const string DEFAULT_CUSTOMS_RESULT = "defaultCustomsResult";
        //private const string DISABLED_UPLOAD_LOCALDB= "disabledUploadLocalDB";
        //private const string DISABLED_DOWNLOAD_SERVER_TOLOCALDB="disabledDownloadServerToLocalDB";
        private const string ACTIVATION = "Activation";
        private const string SWAP_CONNECTION_TIMEOUT = "swapConnectionTimeout";

        // The name of current class 
        private static readonly string _className =
                    System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Create a logger for use in this class
        private static readonly log4net.ILog _logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public Dictionary<string, msgType> _msgTypeMapping;

        public msgType cmsType;

        /// <summary>
        /// Bag Event Message (local) sender name.
        /// </summary>
        public string Sender1 { get; set; }

        /// <summary>
        /// Bag Event Message (local) sender name.
        /// </summary>
        public string Sender2 { get; set; }

        /// <summary>
        /// Bag Event Message (remote) sender name.
        /// </summary>
        public string Receiver1 { get; set; }

        /// <summary>
        /// Bag Event Message (remote) sender name.
        /// </summary>
        public string Receiver2 { get; set; }

        /// <summary>
        /// Sub-system ID.
        /// </summary>
        public string SubSystem { get; set; }

        /// <summary>
        /// Location ID.
        /// </summary>
        public string Location { get; set; }

        /// <summary>
        /// Activation ID.
        /// </summary>
        public string Activation { get; set; }

        /// <summary>
        /// The Default Customs Result
        /// </summary>
        public bool DefaultCustomsResult { get; set; }

        /// <summary>
        /// The Default Upload To Local DB
        /// </summary>
        public bool DisabledUploadLocalDB { get; set; }

        /// <summary>
        /// The Default Download Server To Local DB
        /// </summary>
        public bool DisabledDownloadServerToLocalDB { get; set; }

        /// <summary>
        /// Data changes checking thread interval.
        /// </summary>
        public int SwapConnectionTimeout { get; set; }

        /// <summary>
        /// Message header format.
        /// </summary>
        public PALS.Telegrams.TelegramFormat MessageFormat_Header { get; set; }

        /// <summary>
        /// Bag Event Message type.
        /// </summary>
        public string MessageType_INTM { get; set; }
        /// <summary>
        /// Bag Event Message format.
        /// </summary>
        public PALS.Telegrams.TelegramFormat MessageFormat_INTM { get; set; }

        public string MessageType_IRY { get; set; }

        public PALS.Telegrams.TelegramFormat MessageFormat_IRY { get; set; }

        public string MessageType_IEC { get; set; }

        public PALS.Telegrams.TelegramFormat MessageFormat_IEC { get; set; }

        public string MessageType_IRM { get; set; }

        public PALS.Telegrams.TelegramFormat MessageFormat_IRM { get; set; }
        #endregion

        #region Class Constructor & Destructor
        /// <summary>
        /// Class constructer.
        /// </summary>
        public MessageHandlerParameters(XmlNode configSet, XmlNode telegramSet)
        {
            if (telegramSet == null)
                throw new Exception("Constractor parameter can not be null! Creating class " + _className +
                    " object fail! <BHS.MES.TCPClientChains.Messages.Handlers.MessageHandlerParameters.Constructor()>");

            if (configSet == null)
                throw new Exception("Constractor parameter can not be null! Creating class " + _className +
                    " object fail! <BHS.MES.TCPClientChains.Messages.Handlers.MessageHandlerParameters.Constructor()>");

            if (Init(ref configSet, ref telegramSet) == false)
                throw new Exception("Instantiate class object failure! " +
                    "<BHS.MES.TCPClientChains.Messages.Handlers.MessageHandlerParameters.Constructor()>");
        }

        /// <summary>
        /// Class destructer.
        /// </summary>
        ~MessageHandlerParameters()
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

            // Add codes here to release resource
            if (_msgTypeMapping != null)
            {
                _msgTypeMapping.Clear();
                _msgTypeMapping = null;
            }

            MessageFormat_Header = null;
        }
        #endregion

        #region Class Properties
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

            _msgTypeMapping = new Dictionary<string, msgType>();

            MessageType_INTM = string.Empty;

            MessageType_IRY = string.Empty;
            MessageType_IEC = string.Empty;
            MessageType_IRM = string.Empty;

            MessageFormat_Header = null;
            MessageFormat_INTM = null;

            MessageFormat_IRY = null;
            MessageFormat_IEC = null;
            MessageFormat_IRM = null;
            try
            {
                //<configSet name="BHS.MES.TCPClientChains.Messages.Handlers.MessageHandler">
                //  <!-- INTM message (local) sender, max 8 characters-->
                //  <sender>MES</sender>
                //  <!-- INTM message (remote) receiver, max 8 characters-->
                //  <receiver>PLC</receiver>
                //<!-- Map Alias with PLC Telegram ID and INTM type-->
                //<msgTypeMapping>
                
                //</msgTypeMapping>
                //</configSet>
                string plc, cms, alias;
                int childSize, childIndex;
                int subChildSize, subChildIndex;

                childSize = configSet.ChildNodes.Count;

                for (childIndex = 1; childIndex <= childSize - 1; childIndex++)
                {
                    if (configSet.ChildNodes[childIndex].Name == "msgTypeMapping")
                    {
                        subChildSize = configSet.ChildNodes[childIndex].ChildNodes.Count;

                        for (subChildIndex = 0; subChildIndex <= subChildSize - 1; subChildIndex++)
                        {
                            alias = XMLConfig.GetSettingFromAttribute(configSet.ChildNodes[childIndex].ChildNodes[subChildIndex], "alias", string.Empty);
                            plc = XMLConfig.GetSettingFromAttribute(configSet.ChildNodes[childIndex].ChildNodes[subChildIndex], "PLC", string.Empty);
                            cms = XMLConfig.GetSettingFromAttribute(configSet.ChildNodes[childIndex].ChildNodes[subChildIndex], "CMS", string.Empty);
                            msgType msg = new msgType(plc, cms);
                            _msgTypeMapping.Add(alias, msg);
                        }
                    }
                }

                Sender1 = XMLConfig.GetSettingFromInnerText(configSet, "sender", string.Empty);
                if (Sender1 == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<sender> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }

                Receiver1 = XMLConfig.GetSettingFromInnerText(configSet, "receiver", string.Empty);
                if (Receiver1 == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<receiver> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }

                SubSystem = XMLConfig.GetSettingFromInnerText(configSet, "subSystem", string.Empty);
                if (SubSystem == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<subsystem> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }

                Location = XMLConfig.GetSettingFromInnerText(configSet, "location", string.Empty);
                if (Location == string.Empty)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("<location> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                    return false;
                }

                DefaultCustomsResult = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(configSet, DEFAULT_CUSTOMS_RESULT, "True"));

                ////Activation = XMLConfig.GetSettingFromInnerText(configSet, "Activation", string.Empty);
                ////if (Activation == string.Empty)
                ////{
                ////    if (_logger.IsErrorEnabled)
                ////        _logger.Error("<Activation> setting is missing in XML config file or its value is empty! <" + thisMethod + ">.");

                ////    return false;
                ////}

                //DisabledUploadLocalDB = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(configSet, DISABLED_UPLOAD_LOCALDB, "True"));

                //DisabledDownloadServerToLocalDB = Convert.ToBoolean(XMLConfig.GetSettingFromInnerText(configSet, DISABLED_DOWNLOAD_SERVER_TOLOCALDB, "True"));

                SwapConnectionTimeout = Convert.ToInt32((XMLConfig.GetSettingFromInnerText(configSet,
                        SWAP_CONNECTION_TIMEOUT, "0")));
                if (SwapConnectionTimeout == 0)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("Swap connection timeout setting cannot be empty! <" + thisMethod + ">");

                    return false;
                }


                //<telegramSet name="Application_Telegrams">
                //  <header alias="Header" name="App_Header" sequence="False" acknowledge="False">
                //    <field name="Type" offset="0" length="4" default=""/>
                //    <field name="Length" offset="4" length="4" default=""/>
                //    <field name="Sequence" offset="8" length="4" default=""/>
                //  </header>
                //  ...
                //  <telegram alias="INTM" name="Intermediate_Message" sequence="True" acknowledge="True">
                //    <field name="Type" offset="0" length="4" default="48,49,48,51"/>
                //    <field name="Length" offset="4" length="4" default="?"/>
                //    <field name="Sequence" offset="8" length="4" default="?"/>
                //    <field name="Sender" offset="12" length="8" default="?"/>
                //    <field name="Receiver" offset="20" length="8" default="?"/>
                //    <field name="OriginMsgType" offset="28" length="4" default="?"/>
                //    <field name="OriginMsg" offset="32" length="?" default="?"/>
                //  </telegram>
                //  ...
                //</telegramSet>
                XmlNode teleSet = PALS.Utilities.XMLConfig.GetConfigSetElement(ref telegramSet,
                            "telegramSet", "name", APP_TELEGRAMSET);
                if (teleSet == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("No <telegramSet> XmlNode whose [name] attribute is " +
                            "\"Application_Telegrams\" in the telegram format XML file! <" + thisMethod + ">.");

                    return false;
                }
                else
                {
                    if (GetMessageFormatSettings(telegramSet, teleSet) == false)
                        return false;
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

        private bool GetMessageFormatSettings(XmlNode telegramSet, XmlNode teleSet)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            XmlNode node;

            //Load INTM format
            node = null;
            node = XMLConfig.GetConfigSetElement(ref teleSet, "telegram", "alias", MESSAGE_ALIAS_INTM);
            if (node == null)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("The format of " + MESSAGE_ALIAS_INTM +
                        " message is missing in the config set <" + telegramSet.Name + ">! <" + thisMethod + ">.");

                return false;
            }
            MessageFormat_INTM = new PALS.Telegrams.TelegramFormat(ref node);
            MessageType_INTM = Functions.ConvertByteArrayToString(
                    MessageFormat_INTM.Field("Type").DefaultValue, -1, HexToStrMode.ToAscString);

            //Load IRY format
            node = null;
            node = XMLConfig.GetConfigSetElement(ref teleSet, "telegram", "alias", MESSAGE_ALIAS_IRY);
            if (node == null)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("The format of " + MESSAGE_ALIAS_IRY +
                        " message is missing in the config set <" + telegramSet.Name + ">! <" + thisMethod + ">.");

                return false;
            }
            MessageFormat_IRY = new PALS.Telegrams.TelegramFormat(ref node);
            MessageType_IRY = Functions.ConvertByteArrayToString(
                    MessageFormat_IRY.Field("Type").DefaultValue, -1, HexToStrMode.ToAscString);

            //Load IEC format
            node = null;
            node = XMLConfig.GetConfigSetElement(ref teleSet, "telegram", "alias", MESSAGE_ALIAS_IEC);
            if (node == null)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("The format of " + MESSAGE_ALIAS_IEC +
                        " message is missing in the config set <" + telegramSet.Name + ">! <" + thisMethod + ">.");

                return false;
            }
            MessageFormat_IEC = new PALS.Telegrams.TelegramFormat(ref node);
            MessageType_IEC = Functions.ConvertByteArrayToString(
                    MessageFormat_IEC.Field("Type").DefaultValue, -1, HexToStrMode.ToAscString);

            //Load IRM format
            node = null;
            node = XMLConfig.GetConfigSetElement(ref teleSet, "telegram", "alias", MESSAGE_ALIAS_IRM);
            if (node == null)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("The format of " + MESSAGE_ALIAS_IRM +
                        " message is missing in the config set <" + telegramSet.Name + ">! <" + thisMethod + ">.");

                return false;
            }
            MessageFormat_IRM = new PALS.Telegrams.TelegramFormat(ref node);
            MessageType_IRM = Functions.ConvertByteArrayToString(
                    MessageFormat_IRM.Field("Type").DefaultValue, -1, HexToStrMode.ToAscString);


            return true;
        }
        #endregion
    }
}

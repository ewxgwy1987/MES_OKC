#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       IRY.cs
// Revision:      1.0 -   15 Jun 2010, By Albert Sun.
// =====================================================================================
//
#endregion

using System;
using System.Data;
using System.Data.SqlClient;
using PALS.Utilities;
using PALS.Telegrams;

namespace BHS.MES.TCPClientChains.Messages.Handlers
{
    public class IRY: AbstractMessageHandler,IDisposable
    {
        #region Class Fields and Properties Declaration
        // The name of current class
        private static readonly string _className =
                        System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Create a logger for use in this class
        private static readonly log4net.ILog _logger =
                        log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        /// <summary>
        /// Type field value.
        /// </summary>
        public string TelegramType { get; set; }

        /// <summary>
        /// Length field value.
        /// </summary>
        public string Length { get; set; }

        /// <summary>
        /// Sequence field value.
        /// </summary>
        public string Sequence { get; set; }

        /// <summary>
        /// GID
        /// </summary>
        public string GID { get; set; }

        /// <summary>
        /// Location field value.
        /// </summary>
        public string Location { get; set; }

        /// <summary>
        /// PLC Index number field value.
        /// </summary>
        public string Index { get; set; }

        #endregion

        #region Class Constructor, Dispose, & Destructor
        /// <summary>
        /// Class constructer.
        /// </summary>
        public IRY()
        {
            if(!Init())
                throw new Exception("Creating class " + _className + " object failed! <Constructor()>");
        }

        ~IRY()
        {
            Dispose(false);
        }

        public void Dispose()
        {
            Dispose(true);
        }

        private void Dispose(bool disposing)
        { 
            if(disposing)
                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object has been destroyed. <" + _className + ".Dispose()>");
        }
        #endregion

        #region Class Method Declaration
        /// <summary>
        /// Initialization method.
        /// </summary>
        /// <returns></returns>
        protected bool Init()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            if(_logger.IsInfoEnabled)
                _logger.Info("Class:[" + _className + "] object is initializing... <" + thisMethod + ">");

            // ========================================================
            // Add initialization task code here.
            // ========================================================

            if (_logger.IsInfoEnabled)
                _logger.Info("Class:[" + _className + "] object has been initialized. <" + thisMethod + ">");

            return true;
        }

        protected override void MessageHandling(IncomingMessageInfo msgInfo)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            string channelName, type, length, sequence, gid, location, plcIndex;
            Telegram message;
            DateTime Pref = DateTime.Now;

            if (msgInfo == null)
                return;

            channelName = msgInfo.ChannelName;
            message = msgInfo.Message;

            if (message == null)
                return;

            try
            {
                type = string.Empty;
                length = string.Empty;
                sequence = string.Empty;
                gid = string.Empty;
                location = string.Empty;
                plcIndex = string.Empty;
                
                // 1.Decode message
                MessageDecoding(message, out type, out length, out sequence, out gid, out location, out plcIndex);

                // 2.Add to class parameter fields to make the information available.
                TelegramType = type;
                Length = length;
                Sequence = sequence;
                GID = gid;
                Location = location;
                Index = plcIndex;

                // 3.Log message data into log file.
                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + channelName +
                        "] <- [MSG(" + message.Format.AliasName +
                        "): Type=" + Functions.InvisibleCharacterFormating(ref type) +
                        ", Length=" + Functions.InvisibleCharacterFormating(ref length) +
                        ", Sequence=" + Functions.InvisibleCharacterFormating(ref sequence) +
                        ", GID=" + Functions.InvisibleCharacterFormating(ref gid) +
                        ", Location=" + Functions.InvisibleCharacterFormating(ref location) +
                        ", PLC Index=" + Functions.InvisibleCharacterFormating(ref plcIndex) +
                        "]. (Perf:" + DateTime.Now.Subtract(Pref).TotalMilliseconds.ToString() +
                        "ms). <" + thisMethod + ">");
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Message handling is failed! <" + thisMethod + ">", ex);
            }
        }

        public void MessageDecoding(Telegram message,out string type, out string length, out string sequence,
            out string gid, out string location, out string plcIndex)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
             // <telegram alias="IRY" name="Item_Ready_Message" sequence="True" acknowledge="False">
             //   <field name="Type" offset="0" length="4" default="48,50,48,49"/>
             //   <field name="Length" offset="4" length="4" default="48,48,54,55"/>
             //   <field name="Sequence" offset="8" length="4" default="?"/>
             //   <field name="GID_MSB" offset="12" length="1" default="?"/>
             //   <field name="GID_LSB" offset="13" length="4" default="?"/>
             //   <field name="Location" offset="17" length="2" default="?"/>
             //   <field name="PLC_IDX" offset="19" length="2" default="?"/>
             //</telegram>

            type = Functions.ConvertByteArrayToString(
               message.GetFieldActualValue("Type"), -1, HexToStrMode.ToAscString).Trim();
            length = Functions.ConvertByteArrayToString(
               message.GetFieldActualValue("Length"), -1, HexToStrMode.ToAscString).Trim();

            sequence = Utilities.ConvertVal2Decimal(message.GetFieldActualValue("Sequence"), "32");
            gid = Utilities.ConvertVal2Decimal(message.GetFieldActualValue("GID_MSB"), "16").Trim() + 
                      Utilities.ConvertVal2Decimal(message.GetFieldActualValue("GID_LSB"), "32");
            location = Utilities.ConvertVal2Decimal(message.GetFieldActualValue("Location"), "32");
            plcIndex = Utilities.ConvertVal2Decimal(message.GetFieldActualValue("PLC_IDX"), "16");

            return;
        }

        #endregion

    }
}

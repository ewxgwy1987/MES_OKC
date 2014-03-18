#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       IEC.cs
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
    public class IEC
    {
        #region Class Fields and Properties Declaration
        // The name of current class
        private static readonly string _className =
                        System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Create a logger for use in this class
        private static readonly log4net.ILog _logger =
                        log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        /// <summary>
        /// GID_MSB
        /// </summary>
        public int GID_MSB { get; set; }

        /// <summary>
        /// GID_LSB
        /// </summary>
        public int GID_LSB { get; set; }

        /// <summary>
        /// Location field value.
        /// </summary>
        public string Location { get; set; }

        /// <summary>
        /// PLC Index
        /// </summary>
        public int PLCIndex { get; set; }

        /// <summary>
        /// Bag Destination (Chute) number field value.
        /// </summary>
        public string Destination { get; set; }

        /// <summary>
        /// IEC message format.
        /// </summary>
        private TelegramFormat _messageFormat;
        #endregion

        #region Class Constructor, Dispose, & Destructor
        /// <summary>
        /// Class constructer.
        /// </summary>
        public IEC(TelegramFormat MessageFormat)
        {
            if (MessageFormat == null)
                throw new Exception("Message format can not be null! Creating IEC class object failure! " + 
                    "<" + _className + ".Constructor()>");

            _messageFormat = MessageFormat;
            GID_MSB = 0;
            GID_LSB = 0;
            Location = string.Empty;
            PLCIndex = 0;
            Destination = string.Empty;
        }

        ~IEC()
        {
            Dispose(false);
        }

        public void Dispose()
        {
            Dispose(true);
        }

        private void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object has been destroyed. <" + _className + ".Dispose()>");
            }
        }
        #endregion

        #region Class Method Declaration

        public Telegram ConstructIECMessage()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            Telegram msg = null;

            if (GID_MSB == 0)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("GID MSB is empty, no IEC message is constructed! <" +
                            thisMethod + ">");
                return null;
            }

            if (GID_LSB == 0)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("GID LSB is empty, no IEC message is constructed! <" +
                            thisMethod + ">");
                return null;
            }

            if (Location == string.Empty)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Location is empty, no IEC message is constructed! <" +
                            thisMethod + ">");
                return null;
            }

            if (PLCIndex == 0)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("PLC Index number is empty, no IEC message is constructed! <" +
                            thisMethod + ">");
                return null;
            }

            if (Destination == string.Empty)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Sort Destination is empty, no IEC message is constructed! <" +
                            thisMethod + ">");
                return null;
            }

            try
            {
                // <telegram alias="IEC" name="Item_Encoded_Message" sequence="True" acknowledge="False">
                //   <field name="Type" offset="0" length="4" default="48,50,48,50"/>
                //   <field name="Length" offset="4" length="4" default="48,48,55,53"/>
                //   <field name="Sequence" offset="8" length="4" default="?"/>
                //   <field name="GID_MSB" offset="12" length="1" default="?"/>
                //   <field name="GID_LSB" offset="13" length="4" default="?"/>
                //   <field name="Location" offset="17" length="2" default="?"/>
                //   <field name="PLC_IDX" offset="19" length="2" default="?"/>
                //   <field name="DEST" offset="21" length="2" default="?"/>
                //</telegram>

                byte[] data = null;
                msg = new Telegram(ref data);
                msg.Format = _messageFormat;

                bool temp;
                byte[] type, len, seq, gid_msb, gid_lsb, location, plcIndex, destination;

                # region Telegram : Type
                //Generate type value.
                type = msg.GetFieldDefaultValue("Type");
                temp = msg.SetFieldActualValue("Type", ref type, PALS.Telegrams.Common.PaddingRule.Right);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("IEC message \"Type\" field value assignment is failed! <" +
                            thisMethod + ">");
                    return null;
                }
                # endregion

                # region Telegram : Length
                //Generate length value.
                len = msg.GetFieldDefaultValue("Length");
                temp = msg.SetFieldActualValue("Length", ref len, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("IEC message \"Length\" field value assignment is failed! <" +
                            thisMethod + ">");
                    return null;
                }
                # endregion

                # region Telegram : Sequence No
                // The new sequence number will be calculated and assigned to the
                // "Sequence" field of outgoing application messages, if this message associated
                // TelegramFormat object is indicated that it is the new sequence number
                // required message. The sequence number is globally contained by the static class:
                // PALS.Utilities.SequenceNo. You can get the application global wide unique
                // new sequence number by calling SequenceNo.NewSequenceNo Shared property directly, 
                // without instantial the SequenceNo.
                int fieldLen = _messageFormat.Field("Sequence").Length;
                seq = new byte[fieldLen];
                if (msg.Format.NeedNewSequence == true)
                {
                    long newSeq = SequenceNo.NewSequenceNo1;

                    string HexValue = newSeq.ToString("X");

                    seq = Utilities.ToByteArray(HexValue, fieldLen, false);
                }
                temp = msg.SetFieldActualValue("Sequence", ref seq, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("IEC message \"Sequence\" field value assignment is failed! <" +
                                thisMethod + ">");
                    return null;
                }
                #endregion

                # region Telegram : GID_MSB
                int intGID_MSB_FIELDLEN = _messageFormat.Field("GID_MSB").Length;

                gid_msb = Utilities.ToByteArray(GID_MSB.ToString("X"), intGID_MSB_FIELDLEN, false);
                temp = msg.SetFieldActualValue("GID_MSB", ref gid_msb, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                    {
                        _logger.Error("IEC Message \"GID_MSB\" field value assignment is failed! <" + thisMethod + ">");
                        return null;
                    }
                }
                # endregion

                # region Telegram : GID_LSB
                int intGID_LSB_FIELDLEN = _messageFormat.Field("GID_LSB").Length;
                gid_lsb = Utilities.ToByteArray(GID_LSB.ToString("X"), intGID_LSB_FIELDLEN, false);
                temp = msg.SetFieldActualValue("GID_LSB", ref gid_lsb, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                    {
                        _logger.Error("IEC Message \"GID_LSB\" field value assignment is failed! <" + thisMethod + ">");
                        return null;
                    }
                }
                # endregion

                # region Telegram : Location
                //Generate location id value.
                fieldLen = _messageFormat.Field("Location").Length;
                location = Utilities.ToByteArray(Location, fieldLen, false);
                temp = msg.SetFieldActualValue("Location", ref location, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("IEC message \"Location\" field value assignment is failed! <" +
                                thisMethod + ">");
                    return null;
                }
                # endregion

                #region Telegram : PLC Index
                fieldLen = _messageFormat.Field("PLC_IDX").Length;
                plcIndex = new byte[fieldLen];
                string strHexPlcIndex = PLCIndex.ToString("X");

                plcIndex = Utilities.ToByteArray(strHexPlcIndex, fieldLen, false);
                temp = msg.SetFieldActualValue("PLC_IDX", ref plcIndex, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                    {
                        _logger.Error("IEC Message \"PLC_IDX\" field value assignment is failed! <" + thisMethod + ">");
                        return null;
                    }
                }
                #endregion

                # region Telegram : Destination
                int intDest1 = int.Parse(Destination);
                string strDest1 = intDest1.ToString("X");
                fieldLen = _messageFormat.Field("DEST").Length;
                destination = new byte[fieldLen];

                destination = Utilities.ToByteArray(strDest1, fieldLen, false);
                temp = msg.SetFieldActualValue("DEST", ref destination, PALS.Telegrams.Common.PaddingRule.Right);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("IEC Message \"DEST\" field value assignment is failed!<" + thisMethod + ">");
                    return null;
                }
                # endregion

                return msg;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Constructing IEC message failed! <" +
                            thisMethod + ">", ex);
                return null;
            }
        }

        #endregion
    }
}

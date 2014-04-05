#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       MessageHandler.cs
// Revision:      1.0 -   10 Jun 2010, By Albert Sun
// =====================================================================================
//
#endregion

using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using PALS.Telegrams;
using PALS.Utilities;
using System.Linq;
using System.Text;

namespace BHS.MES.TCPClientChains.Messages.Handlers
{
    /// <summary>
    /// Application layer message handler of Engine Service application. The incoming application 
    /// message from TCPClient communication chains will be forwarded to this class by the  
    /// OnReceived() event fired by most top class, SessionForwarder, in the chains. 
    /// </summary>
    /// <remarks>
    /// <para>
    /// There is a class level internal buffer will be created when class is instantiated for storing
    /// incoming messages. All incoming messages will be stored in this internal buffer. One seperate
    /// thread is running in background to retrieve the incoming messages one by one from this buffer,
    /// and handle it according to the business rules.
    /// </para>
    /// <para>There is no outgoing message queue was implemented in this layer class. It because all 
    /// acknowledge required outgoing messages will be buffered by bottom ACK class. Such message won't 
    /// be lost in case of the sending process failure or it is not acknowledged. But for those acknowledge 
    /// unrequired message, they are not buffered in any layer. Such message will be sent and forget. 
    /// Hence, if the connection is broken at the time of Send() method is invoked, this acknowledge 
    /// unrequired message will be lost. All critical messages should be defined as the acknowledge 
    /// required message in the interface protocol design.
    /// </para>
    /// <para>
    /// Upon channel conenction is opened, closed, or message is received, MessageHandler class will
    /// raise following events to wrapper class: 
    /// OnConnected(object sender, MessageEventArgs e), 
    /// OnDisconnected(object sender, MessageEventArgs e),
    /// and OnReceived(object sender, MessageEventArgs e) 
    /// 
    /// In the event MessageEventArgs type parameter e, the ChainName, ChannelName, OpenedChannelCount, 
    /// and Message will be forwarded to wrapper class.
    /// ChainName           - The name of communication Chain in which the event is fired. One Chain could have
    ///                       multiple channel connections.
    /// ChannelName         - The name of communication Channel where the connection is opened/closed, or 
    ///                       message is received from. One Chain could have multiple channel connections.
    /// OpenedChannelCount  - The number of current opened channel connections.
    /// Message             - The received message.
    /// </para>
    /// </remarks>
    public class MessageHandler
    {
        #region Class Fields and Properties Declaration

        private const string SOURCE_MES2PLC1 = "MES2PLC";
        private const int THREAD_INTERVAL = 10;//10 MILLISECOND
        private const string CSNF_COMM_STATUS_OPENED = "01";
        private const string CSNF_COMM_STATUS_CLOSED = "00";
        //private const int RR_BUFFER_PURGING_INTERVAL = 60000; //60000 millisecond

        // The name of current class 
        private static readonly string _className =
                    System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Create a logger for use in this class
        private static readonly log4net.ILog _logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private Object _thisLock = new Object();

        private Queue _incomingQueue;
        private Queue _syncdIncomingQueue;
        private Thread _handlingThread;
        public bool isHLCMode = false;

        //private DateTime _lastRRBufPurgedTime;

        /// <summary>
        /// To decided connected channel as primary and use this channel to send message.
        /// </summary>
        private string _primaryChannel = string.Empty;

        /// <summary>
        /// Reference of the most top SessionForwarder class to PLC1 in the TCPClient chain.
        /// </summary>
        private SessionForwarder _forwarder;

        /// <summary>
        /// Property, used to the reference of TCPClient class object in a communication channel.
        /// </summary>
        public PALS.Net.Transports.TCP.TCPServerClientParameters TCPServerClientParames { get; set; }

        // Upon ConnectionOpened() method is invoked by bottom chain class,
        // the ChannelName will be stored into this ArrayList.
        // Once the bottom protocol layer connection is closed, its ChannelName
        // will be removed from this ArrayList accordingly.
        private ArrayList _channelList, _syncdChannelList;

        /// <summary>
        /// Event will be raised when message is received.
        /// </summary>
        public event EventHandler<MessageEventArgs> OnReceived;
        /// <summary>
        /// Event will be raised when specific channel connection of MES-PLC device chain is opened.
        /// </summary>
        public event EventHandler<MessageEventArgs> OnConnected;
        /// <summary>
        /// Event will be raised when specific channel connection of MES-PLC device chain is closed.
        /// </summary>
        public event EventHandler<MessageEventArgs> OnDisconnected;
        
        /// <summary>
        /// ID of class object
        /// </summary>
        public string ObjectID { get; set; }
        /// <summary>
        /// Property, object of MessageHandlerParameters class.
        /// </summary>
        public Messages.Handlers.MessageHandlerParameters ClassParameters { get; set; }

        public Messages.Handlers.IRY IRY { get; set; }

        public Messages.Handlers.IEC IEC { get; set; }

        public Messages.Handlers.IRM IRM { get; set; }

        public string ChannelName { get; set; }

        public string MESStationName { get; set; }

        /// <summary>
        /// TTS Name.
        /// </summary>
        public string TTS { get; set; }

        /// <summary>
        /// Reference to persistor class
        /// </summary>
        public DataPersistor.Database.Persistor DBPersistor { get; set; }

        private string _wrdCnt = string.Empty;
        
        public bool _isPLCConnected = false;

        #endregion

        #region Class Constructor, Dispose & Destructor
        /// <summary>
        /// Class constructer.
        /// </summary>
        public MessageHandler(PALS.Common.IParameters param, SessionForwarder forwarder)
        {
            if (param == null)
                throw new Exception("Constractor parameter can not be null! Creating class " + _className +
                    " object failed! <BHS.MES.TCPClientChains.Messages.Handlers.MessageHandler.Constructor()>");

            if (forwarder == null)
                throw new Exception("Constractor parameter can not be null! Creating class " + _className +
                    " object failed! <BHS.MES.TCPClientChains.Messages.Handlers.MessageHandler.Constructor()>");

            ClassParameters = (Messages.Handlers.MessageHandlerParameters)param;
            _forwarder = forwarder;
        }

        /// <summary>
        /// Class destructer.
        /// </summary>
        ~MessageHandler()
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
            if (_handlingThread != null)
            {
                _handlingThread.Abort();
                _handlingThread.Join();
                _handlingThread = null;
            }

            // Release incoming message buffer
            if (_syncdIncomingQueue != null)
            {
                _syncdIncomingQueue.Clear();
                _syncdIncomingQueue = null;
            }

            if (_syncdChannelList != null)
            {
                _syncdChannelList.Clear();
                _syncdChannelList= null;
            }

            if (disposing)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object has been destroyed. <" + _className + ".Dispose()>");
            }
        }
        #endregion

        #region Class Method Declaration
        /// <summary>
        /// Perform MessageHandler class initialization tasks.
        /// <para>Before this method is invoked, those fields of individual message handler 
        /// need to be assigned with value class caller (Initializer class object).</para>
        /// </summary>
        public void Init()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            if (_logger.IsInfoEnabled)
                _logger.Info("Class:[" + _className + "] object is initializing... <" + thisMethod + ">");

            DBPersistor.Subsystem = ClassParameters.SubSystem;

            // Subscribe event handler to classe session forwarders.
            _forwarder.OnReceived += new EventHandler<MessageEventArgs>(_forwarder_OnReceived);
            _forwarder.OnConnected += new EventHandler<MessageEventArgs>(_forwarder_OnConnected);
            _forwarder.OnDisconnected += new EventHandler<MessageEventArgs>(_forwarder_OnDisconnected);

            TTS = DBPersistor.ClassParameters.MESDefaultTTS;

            // Create incoming message buffer
            _incomingQueue = new Queue();
            _syncdIncomingQueue = Queue.Synchronized(_incomingQueue);
            _syncdIncomingQueue.Clear();

            //Create ArrayList object for store opened channel connection name list
            _channelList = new ArrayList();
            _syncdChannelList = ArrayList.Synchronized(_channelList);
            _syncdChannelList.Clear();    

            // Create message handling thread
            _handlingThread = new System.Threading.Thread(new ThreadStart(MessageHandlingThread));
            _handlingThread.Name = _className + ".MessageHandlingThread";

            // Start message handling thread;
            _handlingThread.Start();
            Thread.Sleep(0);

            if (_logger.IsInfoEnabled)
                _logger.Info("Class:[" + _className + "] object has been initialized. <" + thisMethod + ">");
        }

        private void _forwarder_OnConnected(object sender, MessageEventArgs e)
        {
            //TCPServerClientParames.IsAutoReconnected = false;
            
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            lock (_syncdChannelList.SyncRoot)
            {
                if (_syncdChannelList.Contains(e.ChannelName) == false)
                    _syncdChannelList.Add(e.ChannelName);
                 
                if (string.Compare(_primaryChannel, string.Empty) == 0)
                {
                    _primaryChannel = e.ChannelName;
                }
            }

            _isPLCConnected = true;

            if (_logger.IsInfoEnabled)
                _logger.Info("[Channel:" + e.ChannelName +
                        "] PLC connection has been successfully opened! <" + thisMethod + ">");

            // Copy to a temporary variable to be thread-safe.
            EventHandler<MessageEventArgs> temp = OnConnected;
            // Event could be null if there are no subscribers, so check it before raise event
            if (temp != null)
            {
                e.ChainName = SOURCE_MES2PLC1;
                // Raise OnConnected event upon channel connection is opened.
                temp(this, e);
            }
        }

        private void _forwarder_OnDisconnected(object sender, MessageEventArgs e)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            if (_syncdChannelList.Contains(e.ChannelName) == true)
            {
                lock (_syncdChannelList.SyncRoot)
                {
                    _syncdChannelList.Remove(e.ChannelName);
                }

                if (_logger.IsErrorEnabled)
                    _logger.Error("[Channel:" + e.ChannelName +
                            "] PLC connection has been closed! <" + thisMethod + ">");

                _isPLCConnected = false;

                // Copy to a temporary variable to be thread-safe.
                EventHandler<MessageEventArgs> temp = OnDisconnected;

                // Event could be null if there are no subscribers, so check it before raise event
                if (temp != null)
                {
                    e.ChainName = SOURCE_MES2PLC1;
                    // Raise OnDisconnected event upon channel connection is closed.
                    temp(this, e);
                }
            }

        }

        private void _forwarder_OnReceived(object sender, MessageEventArgs e)
        {
            PALS.Telegrams.Common.MessageAndSource msgSource = new PALS.Telegrams.Common.MessageAndSource();

            msgSource.Source = SOURCE_MES2PLC1;
            msgSource.Message = e.Message;

            lock (_incomingQueue.SyncRoot)
            {
                _incomingQueue.Enqueue(msgSource);
            }

            // Copy to a temporary variable to be thread-safe.
            EventHandler<MessageEventArgs> temp = OnReceived;
            // Event could be null if there are no subscribers, so check it before raise event
            if (temp != null)
            {
                e.ChainName = SOURCE_MES2PLC1;
                // Raise OnReceived event upon message is received.
                temp(this, e);
            }
        }

        private void OnMessageSendRequest(Telegram message)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            byte[] originType;
            //Telegram msgINTM1, msgINTM2;

            // Encapsulate outgoing message before send out.
            if (message.Format == null)
                message.Format = ClassParameters.MessageFormat_Header;

            originType = message.GetFieldActualValue("Type");
            string type = Functions.ConvertByteArrayToString(originType, -1, HexToStrMode.ToAscPaddedHexString);

           // Forward encapsulated message to PLC and the message forwarder will check the channel name
            // before sending out message. If the channel name is not equal to the opened channel list in
            // the forwarder, the message will discarded.
            Send2PLC(message);
            
        }

        /// <summary>
        /// Close the specified connection of TCPClient communication chain.
        /// If value null is passed to this method, then all connections of this chain will be closed.
        /// <para>
        /// Disconnect command will be passed to most top class SessionForwarder object
        /// in the chain, and then passed down to every chain classes to close each layer connections.
        /// </para>
        /// </summary>
        /// <param name="channelName">name of channel</param>
        //public void Disconnect(string channelName)
        //{
        //    _forwarderMES2PLC1.Disconnect(channelName);
        //    _forwarderMES2PLC2.Disconnect(channelName);
        //}

        /// <summary>
        /// Sending message to MessageRouter via TCPClient chain classes.
        /// <para>
        /// The message will be sent to all current opened connections of TCPClient chain.
        /// </para>
        /// </summary>
        /// <param name="data"></param>
        public void Send2PLC(byte[] data)
        {
            if ((data == null) || (data.Length == 0))
                return;
            else
            {
                Telegram message = new Telegram(ref data);
                _forwarder.Send(message);
            }
        }

        /// <summary>
        /// Sending message to MessageRouter via TCPClient chain classes.
        /// <para>
        /// The message will be sent to all current opened connections of TCPClient chain.
        /// </para>
        /// </summary>
        /// <param name="message"></param>
        public void Send2PLC(Telegram message)
        {
            if (message == null)
                return;
            else
            {
                _forwarder.Send(message);
            }
        }

        /// <summary>
        /// Message handling thread.
        /// This thread will be permanently running in background after application is started.
        /// </summary>
        private void MessageHandlingThread()
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            if (_logger.IsInfoEnabled)
                _logger.Info("Message handling thread has been started. <" + thisMethod + ">");

            try
            {
                int count;
                PALS.Telegrams.Common.MessageAndSource msgSource;

                while (true)
                {
                    // 1. Handling incoming messages in the incoming queue...
                    count = 0;
                    count = _incomingQueue.Count;

                    for (int i = 0; i < count; i++)
                    {
                        msgSource = null;
                        lock (_incomingQueue.SyncRoot)
                        {
                            msgSource = (PALS.Telegrams.Common.MessageAndSource)_incomingQueue.Dequeue();
                        }

                        // Incoming message handling.
                        IncomingMessageHandling(msgSource);
                    }
                    
                    Thread.Sleep(THREAD_INTERVAL);
                }
            }
            catch (ThreadAbortException ex)
            {
                ex.ToString();
                Thread.ResetAbort();
                if (_logger.IsInfoEnabled)
                    _logger.Info("Message handling thread has been stopped. <" + thisMethod + ">");
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Message handling thread failed. <" + thisMethod + ">", ex);

            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="msgSource"></param>
        private void IncomingMessageHandling(PALS.Telegrams.Common.MessageAndSource msgSource)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            string channelName;
            PALS.Telegrams.Telegram message;

            try
            {
                if (msgSource == null)
                {
                    return;
                }
                else
                {
                    channelName = msgSource.Source;
                    message = msgSource.Message;
                }

                if (message.Format == null)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("[Channel:" + channelName +
                                "] Telegram format is not defined for this incoming message! Message is discarded! [Msg(APP):" +
                                message.ToString(PALS.Utilities.HexToStrMode.ToAscPaddedHexString) + "]. <"
                                + thisMethod + ">");
                }
                else
                {
                    byte[] originType = message.GetFieldActualValue("Type");
                    string type = PALS.Utilities.Functions.ConvertByteArrayToString(
                            originType, -1, PALS.Utilities.HexToStrMode.ToAscString);

                    if (string.Compare(type, ClassParameters.MessageType_IRY) == 0)
                    {
                        message.Format = ClassParameters.MessageFormat_IRY;
                        IncomingIRYMessageHandling(channelName, message);
                    }
                    else
                    {
                        // Undesired message will be discarded.
                        if (_logger.IsErrorEnabled)
                            _logger.Error("[Channel:" + channelName +
                                    "] Undesired message is received! it will be discarded... [Msg(APP):" +
                                    message.ToString(PALS.Utilities.HexToStrMode.ToAscPaddedHexString) + "]. <"
                                    + thisMethod + ">");
                    }
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Incoming message handling is failed. <" + thisMethod + ">", ex);

            }
        }

         /// <summary>
        /// All application data were encapsulated into INTM message. This handling process will decode
        /// it into original application data first, and then following by business logic handling.
        /// </summary>
        /// <param name="channelName">ChannelName.</param>
        /// <param name="message">INTM message.</param>
        private void IncomingIRYMessageHandling(string channelName, PALS.Telegrams.Telegram message)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            DateTime pref = DateTime.Now;
            try
            {
                IncomingMessageInfo InMsgInfo = new IncomingMessageInfo(channelName, message);
                
                //1. Receive IRY message from PLC
                IRY.MessageReceived(InMsgInfo);

                //2. Log received data to database.
                DBPersistor.InsertItemReady(IRY.GID, IRY.Location, IRY.Index);

                //3. Log detail information to log file.
                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + _primaryChannel + "] -> [Msg(IRY):" +
                        " GID =" + IRY.GID.Trim() +
                        " Location=" + IRY.Location +
                        " PLC Index=" + IRY.Index +
                        " Time Spend =" + DateTime.Now.Subtract(pref).TotalMilliseconds.ToString() + "ms" +
                        "]. <" + thisMethod + ">");
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Getting IRY failure! <" + thisMethod + ">", ex);
            }
        }
        
        /// <summary>
        /// Constructing BagEvent message by encapsulating ItemTracking message received from
        /// external device (e.g. PLC).
        /// </summary>
        /// <param name="sender">Outgoing message sender. It shall be the code of current Engine application.</param>
        /// <param name="receiver">Outgoing message final receiver. it shall be the code of associated Gateway application.</param>
        /// <param name="originType">The type of original message that need to be encapsulated into INTM message.</param>
        /// <param name="originMsg">original message.</param>
        /// <param name="formatINTM">INTM message format object.</param>
        /// <returns></returns>
        //private Telegram ConstructINTMMessage(string sender, string receiver, 
        //                byte[] originType, Telegram originMsg, TelegramFormat formatINTM)
        private Telegram ConstructINTMMessage(string sender, string receiver,
                byte[] originType, Telegram originMsg, TelegramFormat formatINTM)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            Telegram msgINTM = null;

            #region Checking Incoming Parameters
            if (sender == string.Empty)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("sender name is empty, no INTM message is constructed! <" +
                            thisMethod + ">");
                return null;
            }

            if (receiver == string.Empty)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("receiver name is empty, no INTM message is constructed! <" +
                            thisMethod + ">");
                return null;
            }

            if (originType == null)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Original message type is null, no INTM message is constructed! <" +
                            thisMethod + ">");
                return null;
            }

            if (originMsg == null)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Original message is null, no INTM message is constructed! <" +
                            thisMethod + ">");
                return null;
            }

            if (formatINTM == null)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("INTM message format object is null, no INTM message is constructed! <" +
                            thisMethod + ">");
                return null;
            }
            #endregion

            try
            {
                //  <telegram alias="INTM" name="Intermediate_Message" sequence="True" acknowledge="True">
                //    <field name="Type" offset="0" length="4" default="48,49,48,51"/>
                //    <field name="Length" offset="4" length="4" default="?"/>
                //    <field name="Sequence" offset="8" length="4" default="?"/>
                //    <field name="Sender" offset="12" length="8" default="?"/>
                //    <field name="Receiver" offset="20" length="8" default="?"/>
                //    <field name="OriginMsgType" offset="28" length="4" default="?"/>
                //    <field name="OriginMsg" offset="32" length="?" default="?"/>
                //  </telegram>

                byte[] data = null;
                msgINTM = new Telegram(ref data);
                msgINTM.Format = formatINTM;

                int fieldLen = 0;
                int msgLen = 0;
                bool temp;
                byte[] type, seq, sndr, rcvr, origin, len;
                #region Generate Type
                fieldLen = msgINTM.Format.Field("Type").Length;
                msgLen = msgLen + fieldLen;
                type = msgINTM.GetFieldDefaultValue("Type");
                temp = msgINTM.SetFieldActualValue("Type", ref type, PALS.Telegrams.Common.PaddingRule.Right);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("INTM message \"Type\" field value assignment is failed! <" +
                                thisMethod + ">");
                    return null;
                }
                #endregion

                #region Generate Sequence
                fieldLen = msgINTM.Format.Field("Sequence").Length;
                msgLen = msgLen + fieldLen;
                // The new sequence number will be calculated and assigned to the
                // "Sequence" field of outgoing application messages, if this message associated
                // TelegramFormat object is indicated that it is the new sequence number
                // required message. The sequence number is globally contained by the static class:
                // PALS.Utilities.SequenceNo. You can get the application global wide unique
                // new sequence number by calling SequenceNo.NewSequenceNo Shared property directly, 
                // without instantial the SequenceNo.
                seq = new byte[fieldLen];
                if (formatINTM.NeedNewSequence == true)
                {
                    long newSeq = SequenceNo.NewSequenceNo1;
                    seq = Functions.ConvertStringToFixLengthByteArray(
                            newSeq.ToString(), fieldLen, '0', Functions.PaddingRule.Left);
                }
                temp = msgINTM.SetFieldActualValue("Sequence", ref seq, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("INTM message \"Sequence\" field value assignment is failed! <" +
                                thisMethod + ">");
                    return null;
                }
                #endregion

                #region Generate Sender
                fieldLen = msgINTM.Format.Field("Sender").Length;
                msgLen = msgLen + fieldLen;
                sndr = Functions.ConvertStringToFixLengthByteArray(sender,
                            msgINTM.Format.Field("Sender").Length, ' ', Functions.PaddingRule.Right);
                temp = msgINTM.SetFieldActualValue("Sender", ref sndr, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("INTM message \"sndr\" field value assignment is failed! <" +
                                thisMethod + ">");
                    return null;
                }
                #endregion

                #region Generate Receiver
                fieldLen = msgINTM.Format.Field("Receiver").Length;
                msgLen = msgLen + fieldLen;
                rcvr = Functions.ConvertStringToFixLengthByteArray(receiver,
                            msgINTM.Format.Field("Receiver").Length, ' ', Functions.PaddingRule.Right);
                temp = msgINTM.SetFieldActualValue("Receiver", ref rcvr, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("INTM message \"Receiver\" field value assignment is failed! <" +
                                thisMethod + ">");
                    return null;
                }
                #endregion

                #region Generate Original Message Type
                fieldLen = msgINTM.Format.Field("OriginMsgType").Length;
                msgLen = msgLen + fieldLen;
                //orgTyp = Functions.ConvertStringToFixLengthByteArray(originType, msgINTM.Format.Field("OriginMsgType").Length, ' ', Functions.PaddingRule.Right);
                temp = msgINTM.SetFieldActualValue("OriginMsgType", ref originType, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("INTM message \"OriginMsgType\" field value assignment is failed! <" +
                                thisMethod + ">");
                    return null;
                }
                #endregion

                #region Generate Original Message
                fieldLen = originMsg.RawData.Length;
                msgLen = msgLen + fieldLen;
                msgINTM.Format.Field("OriginMsg").Length = fieldLen;
                origin = originMsg.RawData;
                temp = msgINTM.SetFieldActualValue("OriginMsg", ref origin, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("INTM message \"OriginMsg\" field value assignment is failed! <" +
                                thisMethod + ">");
                    return null;
                }
                #endregion

                #region Generate Length
                fieldLen = msgINTM.Format.Field("Length").Length;
                msgLen = msgLen + fieldLen;
                len = new byte[fieldLen];
                len = Functions.ConvertStringToFixLengthByteArray(msgLen.ToString(),
                            fieldLen, '0', Functions.PaddingRule.Left);
                temp = msgINTM.SetFieldActualValue("Length", ref len, PALS.Telegrams.Common.PaddingRule.Left);
                if (temp == false)
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("INTM message \"Length\" field value assignment is failed! <" +
                                thisMethod + ">");
                    return null;
                }
                #endregion
                return msgINTM;
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Constructing INTM message is failed! <" + thisMethod + ">", ex);

                return null;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="intGIDMSB"></param>
        /// <param name="intGIDLSB"></param>
        /// <param name="strEncodedType"></param>
        /// <param name="strIATATag"></param>
        /// <param name="strCarrier"></param>
        /// <param name="strFlight"></param>
        /// <param name="strSDO"></param>
        /// <param name="strLocation"></param>
        /// <param name="intPLCIndex"></param>
        public void SendIEC(int intGIDMSB, int intGIDLSB, string strDestination ,string strLocation, int intPLCIndex, string strLicensePlate, string strAirline, string strFlightNo, string strEncodeType)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            DateTime pref = DateTime.Now;
            
            try
            {
                string strReason = string.Empty;

                Messages.Handlers.IEC hdlrIEC = new IEC(ClassParameters.MessageFormat_IEC);

                hdlrIEC.GID_MSB = intGIDMSB;
                hdlrIEC.GID_LSB = intGIDLSB;
                hdlrIEC.Location = strLocation;
                hdlrIEC.PLCIndex = intPLCIndex;
                hdlrIEC.Destination = strDestination;
                
                Telegram msgIEC = hdlrIEC.ConstructIECMessage();
                if (msgIEC != null)
                {
                    //1. Send to PLC
                    OnMessageSendRequest(msgIEC);

                    //2. Log send data to database
                    DBPersistor.InsertItemEncoded(intGIDMSB, intGIDLSB, strLocation, intPLCIndex.ToString().Trim(), strDestination, strLicensePlate, strAirline, strFlightNo, strEncodeType);

                    //3. Log details information to log file.
                    if (_logger.IsInfoEnabled)
                        _logger.Info("[Channel:" + _primaryChannel + "] -> [MSG(IEC):" +
                            " GID=" + hdlrIEC.GID_MSB.ToString().Trim() + hdlrIEC.GID_LSB.ToString().Trim() +
                            ",Location=" + hdlrIEC.Location +
                            ",PLC Index=" + hdlrIEC.PLCIndex +
                            ",Destination=" + hdlrIEC.Destination +
                            ",Time Spend =" + DateTime.Now.Subtract(pref).TotalMilliseconds.ToString() + "ms" +
                            "]. <" + thisMethod + ">");
                }
                else
                {
                    if (_logger.IsErrorEnabled)
                        _logger.Error("[Channel:" + _primaryChannel + "] Constructing IEC message failure!]. <" + thisMethod + ">");
                }
            }
            catch (Exception ex)
            { 
                if (_logger.IsErrorEnabled)
                    _logger.Error("Sending IEC failure! <" + thisMethod + ">", ex);
            }
        }

        // Send IRM Message - Modified by Guo Wenyu 2014/04/05
        public void SendIRM(int intGIDMSB, int intGIDLSB, string strLocation, int intPLCIndex, string LICENSE_PLATE)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            DateTime pref = DateTime.Now;

            try
            {
                Messages.Handlers.IRM hdlrIRM = new IRM(ClassParameters.MessageFormat_IRM);

                hdlrIRM.GID_MSB = intGIDMSB;
                hdlrIRM.GID_LSB = intGIDLSB;
                hdlrIRM.Location = strLocation;
                hdlrIRM.PLCIndex = intPLCIndex;

                Telegram msgIRM = hdlrIRM.ConstructIRMMessage();
                if (msgIRM != null)
                {
                    //1. Send to PLC
                    OnMessageSendRequest(msgIRM);

                    //2. Log send data to database.
                    DBPersistor.InsertItemRemove(DateTime.Now, intGIDMSB.ToString().Trim() + intGIDLSB.ToString().Trim(), strLocation, intPLCIndex.ToString(), LICENSE_PLATE);

                    //3. Log detail information to log file.
                    if (_logger.IsInfoEnabled)
                        _logger.Info("[Channel:" + _primaryChannel + "] -> [MSG(IRM):" +
                            " GID=" + intGIDMSB.ToString().Trim() + intGIDLSB.ToString().Trim()  +
                            ",Location=" + strLocation +
                            ",PLC Index=" + intPLCIndex.ToString() +
                            " Time Spend =" + DateTime.Now.Subtract(pref).TotalMilliseconds.ToString() + "ms" +
                            "]. <" + thisMethod + ">");
                }
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Sending IRM failure! <" + thisMethod + ">", ex);
            }
        }

        #region Sortation Control
        public LocationID[] GetDestination(string sGID, string sLicensePlate, out string sReason)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            LocationID currentLocation = new LocationID();
            LocationID[] destinations = null;
            DateTime Perf = DateTime.Now;
            string lincesePlate = string.Empty;
            string minimumSecurityLevel = string.Empty, currentSecurityLevel = string.Empty;
            string reason = string.Empty;
            bool isCustomsRequired, isHBSMinimumLevelMeet, isEBS, isCustomsSecurityMeet;
            bool isIATAInterlineInHouseTag = false;
            bool isBCASEnabled = false;

            isCustomsRequired = false;
            currentLocation.Location = ClassParameters.Location;
            currentLocation.Subsystem = ClassParameters.SubSystem;


            Tag validTag = LicensePlateValidityChecking(sGID, ChannelName, sLicensePlate, ref isCustomsRequired);

            // 5. Get the highest Minimum Security Level
            if (validTag.Type == TagType.SecurityTag)
            {
                // Get Security Level from Four Digits Security Tag
                minimumSecurityLevel = DBPersistor.GetSecurityTagLevelFromDB(validTag.SecurityLevelTagCode);

                if (DBPersistor.DefaultHBSLevel.CompareTo(minimumSecurityLevel) > 0)
                {
                    minimumSecurityLevel = DBPersistor.DefaultHBSLevel;
                }
            }
            else if ((validTag.Type == TagType.IATATag) | (validTag.Type == TagType.InHouseTag))
            {
                // Get the Passenger Final Destination Country
                // Get the Passenger Final Destination Airport Code
                // Get the Airline of departure flight
                // Get the Departure Flight No
                // Get the Passenger Name
                // Get the Security Screening Instruction Code of BSM .X element
                // If all above disabled, the default values will applied.

                minimumSecurityLevel = DBPersistor.GetMinimumSecurityLevelFromDB(validTag.LP);

                if (minimumSecurityLevel == string.Empty)
                {
                    minimumSecurityLevel = DBPersistor.DefaultHBSLevel;
                }

                isIATAInterlineInHouseTag = true;

                //if (validTag.Type == TagType.IATATag)
                int tagType = Convert.ToInt32(validTag.Type);
                //{
                isCustomsRequired = DBPersistor.GetCustomsRequired(tagType, validTag.LP, ClassParameters.DefaultCustomsResult);
                //}
                //else
                //{
                //    isCustomsRequired = DBPersistor.GetCustomsRequired(validTag.Type, validTag.LP, ClassParameters.DefaultCustomsResult);
                //}
            }
            else
            {
                // Get Default Security Level
                minimumSecurityLevel = DBPersistor.DefaultHBSLevel;
            }

            bool isHBSResultEmpty = true;
            bool isCustomResultEmpty = true;

            DBPersistor.MinimumHBSSecurityLevelMeetChecking(sGID, out isHBSMinimumLevelMeet, minimumSecurityLevel, out currentSecurityLevel,
                    out isEBS, isIATAInterlineInHouseTag, validTag.LP, true, out isBCASEnabled, out isHBSResultEmpty);

            if (minimumSecurityLevel == string.Empty)
            {
                minimumSecurityLevel = DBPersistor.DefaultHBSLevel;
            }

            if (currentSecurityLevel == string.Empty)
            {
                currentSecurityLevel = DBPersistor.ClassParameters.DefaultCurrentHBSLevel;
            }

            if (_logger.IsInfoEnabled)
                _logger.Info("[Channel:" + ChannelName +
                        "] [GID:" + sGID + ", License Plate:" + validTag.LP +
                        "]. The Minimum Security Level = " + minimumSecurityLevel +
                        ", Current Security Level = " + currentSecurityLevel +
                        ", Is HBS Minimum Level Meet = " + isHBSMinimumLevelMeet +
                        ", Is BCAS Enabled = " + isBCASEnabled +
                        "] . <" + thisMethod + ">");

            bool isHLCMode = true;
            // ... check for Operation Mode
            //if (OperationalMode == "2")
            //{
            //    isHLCMode = false;
            //}
            //else
            //{
            //    isHLCMode = true;
            //}

            if ((!isHLCMode) & (isHBSResultEmpty) & ((validTag.Type == TagType.IATATag) | (validTag.Type == TagType.InHouseTag)))
            {
                isHBSMinimumLevelMeet = true;

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + ChannelName +
                            "] [GID:" + sGID + ", License Plate:" + validTag.LP +
                            "]. It is LLC MODE, Tag Type=" + validTag.Type +
                            ", no HBS result can be found, all IATA Interline/In House bags will treat as HBS Result cleared bag, so " +
                            " Is HBS Minimum Level Meet = " + isHBSMinimumLevelMeet +
                            "] . <" + thisMethod + ">");
            }
            //else if ((validTag.Type != TagType.IATATag) & (validTag.Type != TagType.InHouseTag))
            //{
            //    isHBSMinimumLevelMeet = true;

            //    if (_logger.IsInfoEnabled)
            //        _logger.Info("[Channel:" + ChannelName +
            //                "] [GID:" + sGID + ", License Plate:" + validTag.LP +
            //                "]. It is " + validTag.Type + 
            //                ", HBS Result will be cleared, so " + 
            //                " Is HBS Minimum Level Meet = " + isHBSMinimumLevelMeet +
            //                "] . <" + thisMethod + ">");
            //}

            if (isHBSMinimumLevelMeet)
            {
                if (isCustomsRequired)
                {
                    // 5. Customs Clear Checking
                    DBPersistor.CustomsSecurityMeetChecking(sGID, out isCustomsSecurityMeet,
                            isIATAInterlineInHouseTag, validTag.LP, out isCustomResultEmpty);

                    if ((!isHLCMode) & (isCustomResultEmpty) & ((validTag.Type == TagType.IATATag) | (validTag.Type == TagType.InHouseTag)))
                    {
                        isCustomsSecurityMeet = true;

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + ChannelName +
                                    "] [GID:" + sGID + ", License Plate:" + validTag.LP +
                                    "]. It is LLC MODE, Tag Type=" + validTag.Type +
                                    ", no Customs result can be found, all IATA Interline/In House bags will treat as Customs Result cleared bag" + 
                                    ", all the bags will treat as Customs Result cleared bag, so " +
                                    "isCustomsSecurityMeet=" + isCustomsSecurityMeet +
                                    "] . <" + thisMethod + ">");
                    }
                    else if ((validTag.Type != TagType.IATATag) & (validTag.Type != TagType.InHouseTag))
                    {
                        isCustomsSecurityMeet = true;

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + ChannelName +
                                    "] [GID:" + sGID + ", License Plate:" + validTag.LP +
                                    "]. It is " + validTag.Type +
                                    ", Customs Result will be cleared, so " +
                                    "isCustomsSecurityMeet=" + isCustomsSecurityMeet +
                                    "] . <" + thisMethod + ">");
                    }


                    if (isCustomsSecurityMeet == false)
                    {
                        // Get Customs Destination
                        destinations = DBPersistor.GetDestinationOfCustomsChute(ChannelName, sGID, validTag.LP, ref reason,
                            currentLocation, TTS);

                        if (_logger.IsInfoEnabled)
                            _logger.Info("[Channel:" + ChannelName +
                                    "] [GID:" + sGID + ", LP:" + validTag.LP +
                                    "] It is HBS Security Clear but the Customs Unclear Bag " +
                                    ". Its destination: (" +
                                    Utilities.LocationIDArrayToString(ref destinations) +
                                    "). <" + thisMethod + ">");
                    }
                }
                else
                {
                    if (_logger.IsInfoEnabled)
                        _logger.Info("[Channel:" + ChannelName +
                                "] [GID:" + sGID + ", LP:" + validTag.LP +
                                "] It is HBS Security Clear and the Customs Screening is not required" +
                                "). <" + thisMethod + ">");
                }

                if (destinations == null)
                {
                    DBPersistor.GetDestination(ChannelName, sGID, currentLocation, validTag, string.Empty, string.Empty,
                        string.Empty, ref reason, ref destinations, TTS, isHLCMode);
                }
            }
            else
            {
                // It is Minimum Screening Security Level Unclear, it will send to EDS Chute
                //destinations = new LocationID[1];
                reason = DBPersistor.ClassParameters.SortReasonMSSL;

                // Get EDS Chute destination
                DBPersistor.GetDestinationOfEDS(ChannelName, sGID, validTag.LP, currentLocation, ref reason, ref destinations, TTS);

                //for (int i = 0; i < DBPersistor.ClassParameters.EDSChuteLocation.Length; i++)
                //{
                //    if (TTS == DBPersistor.ClassParameters.EDSChuteLocation[i].Subsystem)
                //    {
                //        destinations[0].Subsystem = DBPersistor.ClassParameters.EDSChuteLocation[i].Subsystem;
                //        destinations[0].Location = DBPersistor.ClassParameters.EDSChuteLocation[i].Location;
                //    }
                //}

                if (_logger.IsInfoEnabled)
                    _logger.Info("[Channel:" + ChannelName +
                            "] [GID:" + sGID + ", LP:" + validTag.LP +
                            "]. It will redirect based on Minimum HBS Security Level destination: [" +
                            Utilities.LocationIDArrayToString(ref destinations) +
                            "] . <" + thisMethod + ">");
            }


            sReason = reason;
            return destinations;
        }

        /// <summary>
        /// Tag Validation and get the Tag type
        /// </summary>
        /// <param name="gid"></param>
        /// <param name="channelName"></param>
        /// <param name="licensePlate"></param>
        /// <returns></returns>
        public Tag LicensePlateValidityChecking(string gid, string channelName, string licensePlate, ref bool isCustomsRequired)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            Tag validTag = new Tag();

            try
            {
                validTag = Utilities.BagTagDecoding(licensePlate, DBPersistor);

                if (validTag.Valid == false)
                {
                    if (validTag.Type == TagType.FourDigitsFallbackTag)
                    {
                        if (_logger.IsWarnEnabled)
                            _logger.Warn("DEBUG] [GID:" + gid +
                                        ", LP:" + licensePlate +
                                        "] Invalid 4 Digits Fallback Tag detected. Bag will be sorted as No-Read bag. <" + thisMethod + ">");

                        validTag.Type = TagType.DummyEmptyLP;
                        validTag.LP = DBPersistor.ClassParameters.EmptyLicensePlate;  // Invalid 4 Digits Fallback Tag
                    }
                    //else 
                    if (validTag.Type == TagType.FallbackTag)
                    {
                        if (_logger.IsWarnEnabled)
                            _logger.Warn("DEBUG] [GID:" + gid +
                                        ", LP:" + licensePlate +
                                        "] Invalid Fallback Tag detected - location code (" +
                                        validTag.AirportLocationCode + ") does not match to current airport (" +
                                        DBPersistor.AirportLocationCode + "). Bag will be sorted as No-Read bag. <" + thisMethod + ">");

                        validTag.Type = TagType.DummyEmptyLP;
                        validTag.LP = DBPersistor.ClassParameters.EmptyLicensePlate;  // Invalid Fallback Tag
                    }
                }
                else
                {
                    if (validTag.Type == TagType.SecurityTag)
                    {
                        // If bag is Four Digits Security tag, then check whether the Four Digits Security tag sortation is enabled in the 
                        // current sortation setting. If it was enabled, then return Four Digits Security tag# for further sortation.
                        // Otherwise, return the dummy empty LP# for sortation as No Read.
                        if (DBPersistor.FourDigitsSecuritySortEnabled == false)
                        {
                            if (_logger.IsErrorEnabled)
                                _logger.Error("DEBUG] [GID:" + gid +
                                            ", LP:" + licensePlate +
                                            "] Four Digits Security tag is detected but Four Digits Security tag sortation is disabled, " +
                                            "bag will be sorted as No-Read. <" + thisMethod + ">");

                            validTag.Type = TagType.DummyEmptyLP;
                            validTag.LP = DBPersistor.ClassParameters.EmptyLicensePlate;  // Invalid Four Digits Security tag
                        }
                        else
                        {
                            // ... Check Customs Required
                            isCustomsRequired = DBPersistor.GetCustomsRequired(Convert.ToInt32(validTag.Type), validTag.DestinationTagCode, ClassParameters.DefaultCustomsResult);
                        }
                    }
                    else if (validTag.Type == TagType.FourDigitsFallbackTag)
                    {
                        // If bag is Four Digits Fallback tag, then check whether the Four Digits Fallback tag sortation is enabled in the 
                        // current sortation setting. If it was enabled, then return Four Digits Fallback tag# for further sortation.
                        // Otherwise, return the dummy empty LP# for sortation as No Read.
                        if (DBPersistor.FourDigitsFallbackSortEnabled == false)
                        {
                            if (_logger.IsErrorEnabled)
                                _logger.Error("DEBUG] [GID:" + gid +
                                            ", LP:" + licensePlate +
                                            "] Four Digits Fallback tag is detected but Four Digits Fallback tag sortation is disabled, " +
                                            "bag will be sorted as No-Read. <" + thisMethod + ">");

                            validTag.Type = TagType.DummyEmptyLP;
                            validTag.LP = DBPersistor.ClassParameters.EmptyLicensePlate;  // Invalid Four Digits Fallback tag
                        }
                        else
                        {
                            // ... Check Customs Required
                            isCustomsRequired = DBPersistor.GetCustomsRequired(Convert.ToInt32(validTag.Type), validTag.DestinationTagCode, ClassParameters.DefaultCustomsResult);
                        }
                    }
                    else if (validTag.Type == TagType.FallbackTag)
                    {
                        // If bag is Fallback tag, then check whether the fallback tag sortation is enabled in the 
                        // current sortation setting. If it was enabled, then return fallback tag# for further sortation.
                        // Otherwise, return the dummy empty LP# for sortation as No Read.
                        if (DBPersistor.FallbackSortEnabled == false)
                        {
                            if (_logger.IsErrorEnabled)
                                _logger.Error("DEBUG] [GID:" + gid +
                                            ", LP:" + licensePlate +
                                            "] Fallback tag is detected but fallback tag sortation is disabled, " +
                                            "bag will be sorted as No-Read. <" + thisMethod + ">");

                            validTag.Type = TagType.DummyEmptyLP;
                            validTag.LP = DBPersistor.ClassParameters.EmptyLicensePlate;  // Invalid fallback tag
                        }
                        else
                        {
                            // ... Check Customs Required
                            isCustomsRequired = DBPersistor.GetCustomsRequired(Convert.ToInt32(validTag.Type), validTag.DestinationTagCode, ClassParameters.DefaultCustomsResult);
                        }
                    }
                    else if (validTag.Type == TagType.InHouseTag)
                    {
                        // If bag is In-House tag, then check whether the In-House tag sortation is enabled in the 
                        // current sortation setting. If it was enabled, then return In-House tag# for further sortation.
                        // Otherwise, return the dummy empty LP# for sortation as No Read.
                        if (DBPersistor.InHouseSortEnabled == false)
                        {
                            if (_logger.IsErrorEnabled)
                                _logger.Error("DEBUG] [GID:" + gid +
                                            ", LP:" + licensePlate +
                                            "] In-House tag is detected but In-House tag sortation is disabled, " +
                                            "bag will be sorted as No-Read. <" + thisMethod + ">");

                            validTag.Type = TagType.DummyEmptyLP;
                            validTag.LP = DBPersistor.ClassParameters.EmptyLicensePlate;
                        }
                        else
                        {
                            // ... Check Customs Required
                            isCustomsRequired = DBPersistor.GetCustomsRequired(Convert.ToInt32(validTag.Type), licensePlate, ClassParameters.DefaultCustomsResult);
                        }
                    }
                    else if (validTag.Type == TagType.IATATag)
                    {
                        // ... Check Customs Required
                        isCustomsRequired = DBPersistor.GetCustomsRequired(Convert.ToInt32(validTag.Type), licensePlate, ClassParameters.DefaultCustomsResult);
                    }
                }

                return validTag;
            }
            catch (Exception ex)
            {
                validTag.Type = TagType.DummyEmptyLP;
                validTag.LP = DBPersistor.ClassParameters.EmptyLicensePlate;

                if (_logger.IsErrorEnabled)
                    _logger.Error("Get Allocation Info From IATA Tag failure! <" + thisMethod + ">", ex);

                return validTag;
            }
        }

        public LocationID[] GetProblemDestination(string sGID, out string sReason)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            LocationID[] destination = null;
            string reason = string.Empty;
            try
            {
                LocationID curLocation = new LocationID();
                curLocation.Subsystem = ClassParameters.SubSystem;
                curLocation.Location = ClassParameters.Location;
                DBPersistor.GetDestinationOfPROB(ChannelName, sGID, curLocation, ref reason, ref destination, TTS);
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get problem discharge destination failure! <" + thisMethod + ">", ex);
            }
            sReason = reason;
            return destination;
        }

        public LocationID[] GetRushDestination(string sAirlineCode, string sGID, ref string reason, ref int type)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            bool isMES = false;
            LocationID[] temp = null;
            LocationID curLocation = new LocationID();
            curLocation.Location = ClassParameters.Location;
            curLocation.Subsystem = ClassParameters.SubSystem;
            LocationID[] mesLocation = null;

            if (TTS == DBPersistor.TTS01_SUBSYSTEM)
            {
                mesLocation = DBPersistor.ClassParameters.TTS01MESLocation;
            }
            else
            {
                mesLocation = DBPersistor.ClassParameters.TTS02MESLocation;
            }
            try
            {
                reason = DBPersistor.ClassParameters.SortReasonRUSH;
                // Get Airline Rush Allocation                      
                // Query destination and its Subsystem from Airline Rush Allocation

                if (DBPersistor.ClassParameters.EnableAirRushAlloc && DBPersistor.ClassParameters.EnableRushFuncAlloc)
                {
                    //Airline Rush Allocation
                    type = 1;

                    temp = DBPersistor.GetDestinationOfAirlineRush(sAirlineCode, false, TTS);
                }
                else if (DBPersistor.ClassParameters.EnableAirRushAlloc)
                {
                    //Airline Rush Allocation
                    type = 1;
                    
                    temp = DBPersistor.GetDestinationOfAirlineRush(sAirlineCode, false, TTS);                    
                }
                else if (DBPersistor.ClassParameters.EnableRushFuncAlloc)
                {
                    //Global Rush Allocation

                    type = 2;

                    DBPersistor.GetSortedDestOfFunctionAllocation(ref reason, sGID, ChannelName,
                        DBPersistor.ClassParameters.FuncAllocationRUSH, curLocation, ref temp,
                        mesLocation, out isMES, TTS);                    
                }
                    

                bool isSameMESLoc = false;

                foreach(LocationID loc in temp)
                {
                    foreach(LocationID locMES in mesLocation)
                    {
                        if (loc.Location == locMES.Location)
                        {
                            isSameMESLoc = true;
                            break;
                        }
                    }

                    if (isSameMESLoc)
                    {
                        break;
                    }
                }

                // If invalid destination (Nothing is returned) of given function  
                // allocation type is returned, use global rush
                if ((temp == null) | (temp.Length == 0) | isSameMESLoc)
                {
                    if (DBPersistor.ClassParameters.EnableAirRushAlloc)
                    {
                        if (DBPersistor.ClassParameters.EnableRushFuncAlloc)
                        {
                            //Global Rush Function Allocation 
                            type = 2;
                            // Sorted by Rush Bag Functional allocation
                            //sReason = DBPersistor.ClassParameters.SortReasonRUSH;

                            DBPersistor.GetSortedDestOfFunctionAllocation(ref reason, sGID, ChannelName,
                                DBPersistor.ClassParameters.FuncAllocationRUSH, curLocation, ref temp,
                                mesLocation, out isMES, TTS);
                        }                        
                    }
                }
                
            }
            catch (Exception ex)
            {
                if (_logger.IsErrorEnabled)
                    _logger.Error("Get problem discharge destination failure! <" + thisMethod + ">", ex);
            }
            return temp;
        }
        #endregion

        ///// <summary>
        ///// Purge historical records that older than 3 hours in the RoundRobin buffer
        ///// </summary>
        //private void RoundRobinBufferPruging()
        //{
        //    string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

        //    try
        //    {
        //        if (DBPersistor == null)
        //        {
        //            return;
        //        }

        //        DBPersistor.RoundRobinBufferPurging();
        //    }
        //    catch (Exception ex)
        //    {
        //        if (_logger.IsErrorEnabled)
        //            _logger.Error("RoundRobin buffer pruging failure! <" + thisMethod + ">", ex);

        //    }
        //}

        #endregion
    }
}

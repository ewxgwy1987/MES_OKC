#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       AbstractMessageHandler.cs
// Revision:      1.0 -   15 Jun 2010, By Albert Sun
// =====================================================================================
//
#endregion

using PALS.Telegrams;

namespace BHS.MES.TCPClientChains.Messages.Handlers
{
    /// <summary>
    /// Abstract class for message handler.
    /// </summary>
    abstract public class AbstractMessageHandler
    {
        /// <summary>
        /// The reference of Persistor class object
        /// </summary>
        public TCPClientChains.DataPersistor.Database.Persistor DBPersistor { get; set; }

        /// <summary>
        /// ID of class object
        /// </summary>
        public string ObjectID { get; set; }

        /// <summary>
        /// Telegram format of message associated to current message handler.
        /// </summary>
        public TelegramFormat MessageFormat { get; set; }

        /// <summary>
        /// Common class method, to be available in all message handler classes.
        /// </summary>
        /// <param name="msgInfo"></param>
        public void MessageReceived(IncomingMessageInfo msgInfo)
        {
            MessageHandling(msgInfo);
        }

        /// <summary>
        /// Abstract method and need to be overrided by all message handler classes.
        /// </summary>
        /// <param name="msgInfo"></param>
        abstract protected void MessageHandling(IncomingMessageInfo msgInfo);
    }
}

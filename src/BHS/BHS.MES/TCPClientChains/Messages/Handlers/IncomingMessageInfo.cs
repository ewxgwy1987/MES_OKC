#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       IncomingMessageInfo.cs
// Revision:      1.0 -   14 Jun 2010, By Albert Sun
// =====================================================================================
//
#endregion

using System;
using PALS.Telegrams;

namespace BHS.MES.TCPClientChains.Messages.Handlers
{
    public class IncomingMessageInfo
    {
        /// <summary>
        /// The name of communication Channel where the connection is opened/closed, or 
        /// message is received from. One Chain could have multiple channel connections.
        /// </summary>
        public string ChannelName { get; set; }

        /// <summary>
        /// Reference to the incoming message.
        /// </summary>
        public Telegram Message { get; set; }

        /// <summary>
        /// class constructor.
        /// </summary>
        /// <param name="sender">Incoming message sender name</param>
        /// <param name="receiver">Incoming message receiver name</param>
        /// <param name="channelName">Incoming message channel name</param>
        /// <param name="message">Incoming message</param>
        public IncomingMessageInfo(string channelName, Telegram message)
        {
            ChannelName = channelName;
            Message = message;
        }
    }
}

#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       AllocationProperty.cs
// Revision:      1.0 -   15 Jun 2010, By Albert Sun.
// =====================================================================================
//
#endregion

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BHS.MES.TCPClientChains
{
    /// <summary>
    /// 
    /// </summary>
    public enum AllocationType
    {
        /// <summary>
        /// 
        /// </summary>
        FlightAllocation = 0,

        /// <summary>
        /// 
        /// </summary>
        FunctionAllocation = 1
    }

    /// <summary>
    /// Class to store the properties of single Flight Allocation or Function Allocation
    /// </summary>
    public class AllocationProperty
    {
        #region Class fields and Properties Declaration

        private RelatedNames _relatedName;

        /// <summary>
        /// 
        /// </summary>
        public AllocationType Type { get; set; }

        /// <summary>
        /// Airline
        /// </summary>
        public string Airline { get; set; }

        /// <summary>
        /// Flight Number
        /// </summary>
        public string FlightNumber { get; set; }

        /// <summary>
        /// Master Airline
        /// </summary>
        public string MasterAirline { get; set; }

        /// <summary>
        /// Master Flight Number
        /// </summary>
        public string MasterFlightNumber { get; set; }

        /// <summary>
        /// SDO
        /// </summary>
        public DateTime SDO { get; set; }

        /// <summary>
        /// STO
        /// </summary>
        public string STO { get; set; }

        /// <summary>
        /// EDO
        /// </summary>
        public DateTime EDO { get; set; }

        /// <summary>
        /// ETO
        /// </summary>
        public string ETO { get; set; }

        ///// <summary>
        ///// IDO
        ///// </summary>
        //public DateTime IDO { get; set; }

        ///// <summary>
        ///// ITO
        ///// </summary>
        //public string ITO { get; set; }

        /// <summary>
        /// ADO
        /// </summary>
        public DateTime ADO { get; set; }

        /// <summary>
        /// ATO
        /// </summary>
        public string ATO { get; set; }

        /// <summary>
        /// Early Open Offset
        /// </summary>
        public string EarlyOpenOffset { get; set; }

        /// <summary>
        /// Allocation Open Related
        /// </summary>
        public string AllocOpenRelated { get; set; }

        /// <summary>
        /// Allocation Open Offset
        /// </summary>
        public string AllocOpenOffset { get; set; }

        /// <summary>
        /// Allocation Close Related
        /// </summary>
        public string AllocCloseRelated { get; set; }

        /// <summary>
        /// Allocation Close Offset
        /// </summary>
        public string AllocCloseOffset { get; set; }

        /// <summary>
        /// Rush Duration
        /// </summary>
        public string RushDuration { get; set; }

        /// <summary>
        /// Travel Class
        /// </summary>
        public string TravelClass { get; set; }

        /// <summary>
        /// Is Manual Close
        /// </summary>
        public bool IsManualClosed { get; set; }

        /// <summary>
        /// Is Closed
        /// </summary>
        public bool IsClosed { get; set; }

        /// <summary>
        /// Resource
        /// </summary>
        public string Resource { get; set; }

        /// <summary>
        /// SubSystem
        /// </summary>
        public string SubSystem { get; set; }

        /// <summary>
        /// Bag Type - Bag Exception
        /// </summary>
        public string BagType { get; set; }

        /// <summary>
        /// Passenger Destination
        /// </summary>
        public string PassengerDestination { get; set; }

        /// <summary>
        /// Onward Transfer
        /// </summary>
        public string OnwardTransfer { get; set; }

        /// <summary>
        /// Allocation Priority
        /// </summary>
        public int Priority { get; set; }

        /// <summary>
        /// Function Type
        /// </summary>
        public string FunctionType { get; set; }

        /// <summary>
        /// STD
        /// </summary>
        public DateTime STD { get; set; }

        /// <summary>
        /// ETD
        /// </summary>
        public DateTime ETD { get; set; }

        ///// <summary>
        ///// ITD
        ///// </summary>
        //public DateTime ITD { get; set; }

        /// <summary>
        /// ATD
        /// </summary>
        public DateTime ATD { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public bool NullEDO { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public bool NullADO { get; set; }

        /// <summary>
        /// Allocation Open Time
        /// </summary>
        public DateTime AllocOpenTime { get; set; }

        ///// <summary>
        ///// Allocation Close Time
        ///// </summary>
        //public DateTime AllocCloseTime { get; set; }

        /// <summary>
        /// Early Open Time
        /// </summary>
        public DateTime EarlyOpenTime { get; set; }

        /// <summary>
        /// Rush Open Time
        /// </summary>
        public DateTime RushOpenTime { get; set; }


        /// <summary>
        /// Rush Close Time
        /// </summary>
        public DateTime RushCloseTime { get; set; }

        /// <summary>
        /// Close Related Time (STD, ETD, ITD, ATD)
        /// </summary>
        public DateTime CloseRelatedTime { get; set; }
        #endregion



        #region Class Constructor, Dispose, & Destructor

        /// <summary>
        /// Allocation Property
        /// </summary>
        /// <param name="type"></param>
        /// <param name="stdRelated"></param>
        /// <param name="etdRelated"></param>
        public AllocationProperty(AllocationType type, string stdRelated, string etdRelated)
        {
            Type = type;
            Airline = string.Empty;
            FlightNumber = string.Empty;
            MasterAirline = string.Empty;
            MasterFlightNumber = string.Empty;
            STO = string.Empty;
            ETO = string.Empty;
            //ITO = string.Empty;
            ATO = string.Empty;
            EarlyOpenOffset = string.Empty;
            AllocOpenRelated = string.Empty;
            AllocOpenOffset = string.Empty;
            AllocCloseRelated = string.Empty;
            AllocCloseOffset = string.Empty;
            RushDuration = string.Empty;
            TravelClass = string.Empty;
            IsManualClosed = false;
            IsClosed = false;
            Resource = string.Empty;
            SubSystem = string.Empty;
            BagType = string.Empty;
            PassengerDestination = string.Empty;
            OnwardTransfer = string.Empty;

            NullEDO = true;
            NullADO = true;

            _relatedName.STD = stdRelated;
            _relatedName.ETD = etdRelated;
            //_relatedName.ITD = itdRelated;
            //_relatedName.ATD = atdRelated;
        }

        #endregion



        #region Class Method Declaration.

        /// <summary>
        /// TimeCalculation
        /// </summary>
        /// <param name="currentTime"></param>
        public void TimeCalculation(DateTime currentTime)
        {
            //if (EDO == null)
            //{
            //    EDO = SDO;
            //}

            //if (ETO == String.Empty)
            //{
            //    ETO = STO;
            //}

            //if (IDO == null)
            //{
            //    IDO = SDO;
            //}

            //if (ITO == String.Empty)
            //{
            //    ITO = STO;
            //}

            //if (ADO == null)
            //{
            //    ADO = SDO;
            //}

            //if (ATO == String.Empty)
            //{
            //    ATO = STO;
            //}

            STD = Convert.ToDateTime(Convert.ToDateTime(SDO).ToString("dd/MMM/yyyy") + " " + STO.Substring(0, 2) + ":" + STO.Substring(2, 2) + ":00");

            if (NullEDO == false)
            {
                ETD = Convert.ToDateTime(Convert.ToDateTime(EDO).ToString("dd/MMM/yyyy") + " " + ETO.Substring(0, 2) + ":" + ETO.Substring(2, 2) + ":00");
            }

            //if (NullIDO == false)
            //{
            //    ITD = Convert.ToDateTime(Convert.ToDateTime(IDO).ToString("dd/MMM/yyyy") + " " + ITO.Substring(0, 2) + ":" + ITO.Substring(2, 2) + ":00");
            //}

            if (NullADO == false)
            {
                ATD = Convert.ToDateTime(Convert.ToDateTime(ADO).ToString("dd/MMM/yyyy") + " " + ATO.Substring(0, 2) + ":" + ATO.Substring(2, 2) + ":00");
            }

            int allocOpenOffsetHour, allocOpenOffsetMinutes, allocCloseOffsetHour, allocCloseOffsetMinutes,
                   earlyOpenOffsetHour, earlyOpenOffsetMinutes, rushDurationHour, rushDurationMinutes;


            // If length is 5, it represents the offset is negative value, e.g. "-0200". 
            // If length is 4, it is positive value, e.g. "0200".
            // AllocOpenOffset
            if (AllocOpenOffset.Length == 4)
            {
                allocOpenOffsetHour = Convert.ToInt32(AllocOpenOffset.Substring(0, 2));
                allocOpenOffsetMinutes = Convert.ToInt32(AllocOpenOffset.Substring(2, 2));
            }
            else if (AllocOpenOffset.Length == 5)
            {
                allocOpenOffsetHour = -1 * Convert.ToInt32(AllocOpenOffset.Substring(1, 2));
                allocOpenOffsetMinutes = -1 * Convert.ToInt32(AllocOpenOffset.Substring(3, 2));
            }
            else
            {
                throw new Exception("Wrong format Allocation Open Offset value (" + AllocOpenOffset +
                                    ")! It length must be either 4 or 5 digits (e.g. \"0200\" or \"-0200\").");
            }

            // AllocCloseOffset
            if (AllocCloseOffset.Length == 4)
            {
                allocCloseOffsetHour = Convert.ToInt32(AllocCloseOffset.Substring(0, 2));
                allocCloseOffsetMinutes = Convert.ToInt32(AllocCloseOffset.Substring(2, 2));
            }
            else if (AllocCloseOffset.Length == 5)
            {
                allocCloseOffsetHour = -1 * Convert.ToInt32(AllocCloseOffset.Substring(1, 2));
                allocCloseOffsetMinutes = -1 * Convert.ToInt32(AllocCloseOffset.Substring(3, 2));
            }
            else
            {
                throw new Exception("Wrong format Allocation Close Offset value (" + AllocCloseOffset +
                                    ")! It length must be either 4 or 5 digits (e.g. \"0200\" or \"-0200\").");
            }

            // EarlyOpenOffset
            if (EarlyOpenOffset.Length == 4)
            {
                earlyOpenOffsetHour = Convert.ToInt32(EarlyOpenOffset.Substring(0, 2));
                earlyOpenOffsetMinutes = Convert.ToInt32(EarlyOpenOffset.Substring(2, 2));
            }
            else if (EarlyOpenOffset.Length == 5)
            {
                earlyOpenOffsetHour = -1 * Convert.ToInt32(EarlyOpenOffset.Substring(1, 2));
                earlyOpenOffsetMinutes = -1 * Convert.ToInt32(EarlyOpenOffset.Substring(3, 2));
            }
            else
            {
                throw new Exception("Wrong format Early Open Offset value (" + EarlyOpenOffset +
                                    ")! It length must be either 4 or 5 digits (e.g. \"0200\" or \"-0200\").");
            }

            //// RushOpenOffset
            //if (RushOpenOffset.Length == 4)
            //{
            //    rushOpenOffsetTimeHour = Convert.ToInt32(RushOpenOffset.Substring(0, 2));
            //    rushOpenOffsetTimeMinutes = Convert.ToInt32(RushOpenOffset.Substring(2, 2));
            //}
            //else if (RushOpenOffset.Length == 5)
            //{
            //    rushOpenOffsetTimeHour = -1 * Convert.ToInt32(RushOpenOffset.Substring(1, 2));
            //    rushOpenOffsetTimeMinutes = -1 * Convert.ToInt32(RushOpenOffset.Substring(3, 2));
            //}
            //else
            //{
            //    throw new Exception("Wrong format Rush Open Offset value (" + RushOpenOffset +
            //                        ")! It length must be either 4 or 5 digits (e.g. \"0200\" or \"-0200\").");
            //}

            //// RushCloseOffset
            //if (RushCloseOffset.Length == 4)
            //{
            //    rushCloseOffsetTimeHour = Convert.ToInt32(RushCloseOffset.Substring(0, 2));
            //    rushCloseOffsetTimeMinutes = Convert.ToInt32(RushCloseOffset.Substring(2, 2));
            //}
            //else if (RushCloseOffset.Length == 5)
            //{
            //    rushCloseOffsetTimeHour = -1 * Convert.ToInt32(RushCloseOffset.Substring(1, 2));
            //    rushCloseOffsetTimeMinutes = -1 * Convert.ToInt32(RushCloseOffset.Substring(3, 2));
            //}
            //else
            //{
            //    throw new Exception("Wrong format Rush Close Offset value (" + RushCloseOffset +
            //                        ")! It length must be either 4 or 5 digits (e.g. \"0200\" or \"-0200\").");
            //}

            if (RushDuration.Length == 4)
            {
                rushDurationHour = Convert.ToInt32(RushDuration.Substring(0, 2));
                rushDurationMinutes = Convert.ToInt32(RushDuration.Substring(2, 2));
            }
            else
            {
                throw new Exception("Wrong format Rush Duration value (" + RushDuration +
                                    ")! It length must be either 4 digits (e.g. \"0200\").");
            }

            long rushDuration = (rushDurationHour * 60) + rushDurationMinutes;
            

            DateTime tempDate;

            if (AllocOpenRelated == _relatedName.STD)
            {
                tempDate = STD.AddHours(allocOpenOffsetHour);
            }
            else if ((AllocOpenRelated == _relatedName.ETD) & (NullEDO == false))
            {
                tempDate = ETD.AddHours(allocOpenOffsetHour);
            }
            //else if ((AllocOpenRelated == _relatedName.ITD) & (NullIDO == false))
            //{
            //    tempDate = ITD.AddHours(allocOpenOffsetHour);
            //}
            //else if ((AllocOpenRelated == _relatedName.ATD) & (NullADO == false))
            //{
            //    tempDate = ATD.AddHours(allocOpenOffsetHour);
            //}
            else
            {
                tempDate = STD.AddHours(allocOpenOffsetHour);
            }

            AllocOpenTime = tempDate.AddMinutes(allocOpenOffsetMinutes);


            if (AllocCloseRelated == _relatedName.STD)
            {
                tempDate = STD.AddHours(allocCloseOffsetHour);
                CloseRelatedTime = STD;
            }
            else if ((AllocCloseRelated == _relatedName.ETD)  & (NullEDO == false))
            {
                tempDate = ETD.AddHours(allocCloseOffsetHour);
                CloseRelatedTime = ETD;
            }
            //else if (AllocCloseRelated == _relatedName.ITD)
            //{
            //    tempDate = ITD.AddHours(allocCloseOffsetHour);
            //    CloseRelatedTime = ITD;
            //}
            //else if (AllocCloseRelated == _relatedName.ATD)
            //{
            //    tempDate = ATD.AddHours(allocCloseOffsetHour);
            //    CloseRelatedTime = ATD;
            //}
            else
            {
                tempDate = STD.AddHours(allocCloseOffsetHour);
                CloseRelatedTime = STD;
            }

            RushCloseTime = tempDate.AddMinutes(allocCloseOffsetMinutes);

            if (NullADO == false)
            {
                RushCloseTime = ATD;
            }

 
            ////§ If Rush Close Time > Current Time
            ////    □ If (Rush Close Time - current time) >=  Rush Duration (Default positive value = 30 mins)
            ////        ® Rush Open Time = Rush Close Time - Rush Duration
            ////    □ Else if ((Rush Close Time - current time) <  Rush Duration)
            ////        ® Rush Open Time = Current Time, new Rush Duration = Rush Close Time - Rush Open Time
            ////§ Else if (Rush Close Time <= Current Time)
            ////    □ Rush Open Time = Rush Close Time, Rush Duration = 0
            //if (RushCloseTime > currentTime)
            //{
            //    TimeSpan timeDiff = RushCloseTime - currentTime;

            //    if (Math.Abs(timeDiff.TotalMinutes) >= rushDuration)
            //    {
            //        RushOpenTime = RushCloseTime.AddMinutes((-1 * rushDuration));
            //    }
            //    else
            //    {
            //        RushOpenTime = currentTime;
            //    }
            //}
            //else
            //{
            //    RushOpenTime = RushCloseTime;
            //}

            RushOpenTime = RushCloseTime.AddMinutes((-1 * rushDuration));

            ////tempDate = RushRelatedTime.AddHours(rushOpenOffsetTimeHour);
            //RushOpenTime = tempDate.AddMinutes(rushOpenOffsetTimeMinutes);



            tempDate = AllocOpenTime.AddHours(earlyOpenOffsetHour);
            EarlyOpenTime = tempDate.AddMinutes(earlyOpenOffsetMinutes);
        }


        /// <summary>
        /// BagStateChecking
        /// </summary>
        /// <param name="currentTime"></param>
        /// <returns></returns>
        public BagStates BagStateChecking(DateTime currentTime)
        {
            TimeCalculation(currentTime);

            if ((currentTime >= ATD) & (NullADO == false))
            {
                return BagStates.OffBlock;
            }           
            else if (currentTime < EarlyOpenTime)
            {
                return BagStates.TooEarly;
            }
            else if ((currentTime >= EarlyOpenTime) && (currentTime < AllocOpenTime))
            {
                return BagStates.Early;
            }
            else if ((currentTime >= AllocOpenTime) && (currentTime < RushOpenTime))
            {
                return BagStates.Open;
            }
            else if ((currentTime >= RushOpenTime) && (currentTime < RushCloseTime))
            {
                return BagStates.Rush;
            }
            else
            {
                return BagStates.TooLate;
            }

        }

        #endregion
    }
}

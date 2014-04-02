#region System Header Declaration
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Security.Principal;
using System.Timers;
using System.Diagnostics;
using PALS;
using BHS.MES;

// Added by Guo Wenyu 2014/03/23
using System.Text.RegularExpressions;
using System.Collections;
using MESLayoutDesign;

#endregion

namespace PGL.MESGUI
{
    public partial class CIAS_MESGUI : Form
    {
        #region Local Variable Declaration
        // The name of current class
        private readonly string _className = System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();

        //MES Colror Conv Status
        private Hashtable HshList = new Hashtable();
        private static DataTable dt;


        // Global variable for shift button press. Default value is false.
        private bool _shiftPressed = false;
        
        // Business layer initializer class.
        BHS.MES.GUI.GUIInitializer init;
        // Create a logger for use in this class
        private static readonly log4net.ILog logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        // The time which start display message on screen.
        private DateTime displayMessageCheck;
        // Local variable for repeatetive task.
        private bool _repeat = false;
        // Bag destination which return from sortation engine.
        private string _destination = string.Empty;
        // Bag GID which received from PLC
        private string _bagGID = string.Empty;
        // License Plate number which received from PLC or From BSM.
        private string _licensePlate = string.Empty;
        // Encoding mode which store for checking.
        private string _encodeMode = string.Empty;
        // PLC index number which received from PLC.
        private string _plcIndex = string.Empty;
        // Location which received from PLC
        private string _location = string.Empty;
        
        private bool _isFirstBag = true;
        private string _lastInput = string.Empty;
        private string _lastEncodeMode = string.Empty;
        private bool _isProblemEncoded = false;

        private bool startup;

        private bool fromScreenKeyboard;
        private int selectionStartPosition;
        private bool fromTelegramIncoming;
        private bool lastBagRemoved;

        // connection between MES and PLC
        private bool isConnected = false;
        private bool bOKBarcodeInclude = false;
        private bool multipleBSM = false;
        private bool isAlarm = false;
        private string alarmMessage = string.Empty;
        private string _sortedReason = string.Empty;
        private string _flightNumber = string.Empty;
        private bool isBtnEnter = false;
        private bool _isAlarm = false;

        private bool bOSK_Open = false;
        private bool bShiftToAirline = false;
        
        private bool isHBSFail = true;
        private Int32 count = 0;
        private Int32 alarmCount = 0;

        private int rushCount,airlinePage=0;

        #endregion

        #region Windows Designer Generated Code
        
        /// <summary>
        /// Default from constructor
        /// </summary>
        public CIAS_MESGUI()
        {
            InitializeComponent();
            this.Width = 1024;
            this.Height = 768;
        }

        /// <summary>
        /// Form load event handler. 
        /// On form load, 
        /// 1. Initialize the database connection
        /// 2. Initialize network communication components
        /// 3. Register all require events
        /// 4. Set GUI limitation
        /// 5. Prepare airline function buttons
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void CIAS_MESGUI_Load(object sender, EventArgs e)
        {
            try
            {
                init = new BHS.MES.GUI.GUIInitializer();
                if (init.Init())
                {
                    startup = true;
                    logger.Info("[DEBUG] Initialize finished and GUI start preparing.");

                    init.AppInit.OnConnected += new EventHandler<BHS.MES.MessageEventArgs>(Initializer_OnConnected);
                    init.AppInit.OnDisconnected += new EventHandler<BHS.MES.MessageEventArgs>(Initializer_OnDisconnected);
                    init.AppInit.OnReceived += new EventHandler<BHS.MES.MessageEventArgs>(Initializer_OnDataReceived);
                    init.AppInit.OnDBConnected += new EventHandler<EventArgs>(Initializer_OnDBConnected);
                    init.AppInit.OnDBDisconnected += new EventHandler<EventArgs>(Initializer_OnDBDisConnected);

                    init.ClassParameters.LoginUser = WindowsIdentity.GetCurrent().Name.Split('\\')[1];
                    init.AppInit.MsgHandler.MESStationName = Environment.MachineName;

                    //if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.DownloadDataToLocal.ToLower() == "true")
                    //{
                    //    init.AppInit.MsgHandler.DBPersistor.DownloadDataFromServer(0, init.AppInit.MsgHandler.MESStationName, DateTime.Now);
                    //}

                    init.UserLoginLogOut(init.ClassParameters.LoginUser, init.AppInit.MsgHandler.MESStationName, 
                    true, init.AppInit.MsgHandler.ClassParameters.SubSystem, init.AppInit.MsgHandler.ClassParameters.Location);

                    init.LastEncoding(init.AppInit.MsgHandler.MESStationName);

                    PrepareAirlineFunctionButtons(airlinePage);

                    PrepareDestinationFunctionButtons();

                    _shiftPressed = true;

                    //txtTagInput.Enabled = false;
                    //txtFlightInput.Enabled = false;
                    //txtAirlineInput.Enabled = false; 
                    //txtDestInput.Enabled = false;
                    //txtProbBagDest.Enabled = false;

                    if (logger.IsInfoEnabled)
                        logger.Info("[DEBUG] GUI preparation finished and start security check...");

                    this.Text = this.Text + " - " + init.AppInit.MsgHandler.MESStationName;
                    lblAppTitle.Text = this.Text;

                    //==========================================================================================
                    // Replace if (1) by below commented line after debuging
                    // if (init.AppInit.MsgHandler.DBPersistor.CheckUserInDomain(init.ClassParameters.LoginUser))
                    // if (true)
                    //==========================================================================================
                    if (init.AppInit.MsgHandler.DBPersistor.CheckUserInDomain(init.ClassParameters.LoginUser))
                    {
                        if (logger.IsInfoEnabled)
                            logger.Info("[DEBUG] User " + init.ClassParameters.LoginUser + " in domain. " +
                                "Preparing available function list for " + init.ClassParameters.LoginUser + ".");
                        init.AppInit.MsgHandler.DBPersistor.ClassParameters.SetAvailableFunctionList(true, false,
                            init.ClassParameters.LoginUser);
                    }
                    else
                    {
                        if (init.ClassParameters.EmergencyUserName == init.ClassParameters.LoginUser)
                        {
                            if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.IsDomainAvailable == false)
                            {
                                if (logger.IsInfoEnabled)
                                    logger.Info("[DEBUG] Login as Emergency User.");
                                init.AppInit.MsgHandler.DBPersistor.ClassParameters.SetAvailableFunctionList(false, true,
                                    init.ClassParameters.LoginUser);
                            }
                            else
                            {
                                logger.Info("[DEBUG] Domain is available, but login as Emergency User. All functions will disable.");
                            }
                        }
                    }

                    tmrSortReason.Interval = 3000;

                    SetSecurity();

                    if (logger.IsInfoEnabled)
                        logger.Info("End security setting...");

                    lblMessage.Text = "(" + Properties.Resources.sMessageItemReady + ")";
                    lblMessage.ForeColor = Color.Teal;
                    //EncodeModeChanged("Tag");
                    SetDefaultEncodeMode();

                    btnEmpty.Enabled = false;
                    btnDispatch.Enabled = false;
                    btnRemove.Enabled = false;

                    //MES Color Conv Status BY PST
                    initiHshList();
                    GET_CurrentMEStation();
                    this.tabControlEncodeMode.TabPages.Remove(tabPageFlight);
                    this.tabKeyboard.TabPages.Remove(tabPageDestination);
                  
                    ColorAnimationTimer.Interval = init.ClassParameters.AnimationTimerDuration;
                    ColorAnimationTimer.Enabled = true;
                    RefreshConvColor_Timer.Interval = init.ClassParameters.RefreshConvTimerDuration;
                    RefreshConvColor_Timer.Enabled = true;
                    tabKeyboard.SelectedIndex = 1;
                }
                else
                {
                    lblMessage.Text = "(" + Properties.Resources.sErrorLoadFail + ")";
                    lblMessage.ForeColor = Color.Red;
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Object has been destroyed. <" + _className + ".MIAL_MESGUI_Load()>", ex);
                lblMessage.Text = "(" + Properties.Resources.sErrorLoadFail + ")";
                lblMessage.ForeColor = Color.Red;
            }
            SetFocusToActiveTextbox();
           
        }

        /// <summary>
        /// Form close event handler. This will run when the form is closing. 
        /// Stop all threads running in memory and components initialized while system start.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void CIAS_MESGUI_FormClosing(object sender, FormClosingEventArgs e)
        {
            init.Dispose();
        }

        /// <summary>
        /// Change encoding modes, Tag Mode, Flight Mode and Destination Mode.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //private void EncodeModeChanged(string sMode)
        //{
        //    try
        //    {
        //        lblMessage.Text = string.Empty;
        //        txtTagInput.Text = string.Empty;
        //        txtFlightInput.Text = string.Empty;
        //        txtDestInput.Text = string.Empty;
        //        btnRepeat.Enabled = false;

        //        //if (!btnRepeat.Enabled)
        //        //    isRepeat = false;

        //        switch (sMode)
        //        {
        //            case "Tag":
        //                if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByTag == true)
        //                {
        //                    SetTagEncodingMode();
        //                    _encodeMode = "Tag";

        //                    if (startup == false)
        //                    {
        //                        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, "", "", init.AppInit.MsgHandler.ClassParameters.SubSystem,
        //                            init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, "", "Chng to Encode by Tag");
        //                    }
        //                    else
        //                    {
        //                        startup = false;
        //                    }
        //                }
        //                break;
        //            case "Flight":
        //                if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByFlight == true)
        //                {
        //                    SetFlightEncodingMode();
        //                    _encodeMode = "Flight";

        //                    if (startup == false)
        //                    {
        //                        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, "", "", init.AppInit.MsgHandler.ClassParameters.SubSystem,
        //                            init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, "", "Chng to Encode by Flight");
        //                    }
        //                    else
        //                    {
        //                        startup = false;
        //                    }
        //                }
        //                break;
        //            case "Sort Dest.":
        //                if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByDestination == true)
        //                {
        //                    SetDestinationEncodeMode();
        //                    _encodeMode = "Sort Dest.";

        //                    if (startup == false)
        //                    {
        //                        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, "", "", init.AppInit.MsgHandler.ClassParameters.SubSystem,
        //                            init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, "", "Chng to Encode by Dest");
        //                    }
        //                    else
        //                    {
        //                        startup = false;
        //                    }
        //                }
        //                break;
        //            case "Rush Dest.":
        //                if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByRush == true)
        //                {
        //                    //SetRushEncodeMode();
        //                    _encodeMode = "Rush Dest.";
        //                    if (startup == false)
        //                    {
        //                        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, "", "", init.AppInit.MsgHandler.ClassParameters.SubSystem,
        //                            init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, "", "Chng to Encode by Rush");
        //                    }
        //                    else
        //                    {
        //                        startup = false;
        //                    }
        //                }
        //                break;
        //            default:
        //                SetTagEncodingMode();
        //                _encodeMode = "Tag";

        //                if (startup == false)
        //                {
        //                    init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, "", "", init.AppInit.MsgHandler.ClassParameters.SubSystem,
        //                            init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, "", "Chng to Encode by Tag");
        //                }
        //                else
        //                {
        //                    startup = false;
        //                }
        //                break;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        if (logger.IsErrorEnabled)
        //            logger.Error("Changing encode mode fail. <" + _className + ".EncodeModeChanged()>", ex);
        //    }
        //    displayMessageCheck = DateTime.Now;
        //    //tmrMessageHandler.Enabled = true;
        //    SetFocusToActiveTextbox();
        //}

        /// <summary>
        /// Exit the application
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnLogout_Click(object sender, EventArgs e)
        {
            try
            {
                if (MessageBox.Show("Are you sure you want to log off?", "Log off windows!", MessageBoxButtons.YesNo, MessageBoxIcon.Information) == DialogResult.Yes)
                {

                    if (logger.IsInfoEnabled)
                        logger.Info("PC user log off." + " <" + _className + ".btnLogout_Click()>");
                    tmrSysTime.Enabled = false;
                    init.UserLoginLogOut(init.ClassParameters.LoginUser, init.AppInit.MsgHandler.MESStationName, false, init.AppInit.MsgHandler.ClassParameters.SubSystem, init.AppInit.MsgHandler.ClassParameters.Location);
                    init.AppInit.MsgHandler.DBPersistor.UpdateLogOnOffStatus();
                    if (Properties.Resources.sWorkingMode != "DEV")
                    {
                        Program.ExitWindowsEx(0, 0);
                        System.Environment.Exit(0);
                    }
                    Application.Exit();
                    Process.GetCurrentProcess().Kill(); 
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Logging to MES log fail. <" + _className + ".btnLogout_Click()>", ex);
                lblMessage.Text = "(" + Properties.Resources.sErrorLoadFail + ")";
                lblMessage.ForeColor = Color.Red;
            }
        }

        // In Flight Sortation,the function RegSpaceSplit used to split Airline and Flight separated by space
        // Added by Guo Wenyu 2014/03/23
        private string[] RegSpaceSplit(string str)
        {
            string[] substr;
            string regdel = "\\s+";

            substr = Regex.Split(str, regdel);

            return substr;
        }

        private void btnEnter_Click(object sender, EventArgs e)
        {
            string strDestination = string.Empty, strReason = string.Empty;
            string strDestDescr = string.Empty, strReasonDescr = string.Empty;

            switch (lblEncodingMode.Text)
            {
                case "Tag #":
                    if (string.Compare(txtTagInput.Text, string.Empty) == 0)
                        return;

                    _destination = string.Empty;
                   // if (GetPassengerInfo())
                    //{
                        init.AppInit.MsgHandler.DBPersistor.GetIRDValuesMES("1", txtTagInput.Text, string.Empty, string.Empty, string.Empty, _location, string.Empty, out strDestination, out strReason, out strDestDescr, out strReasonDescr);

                        _destination = strDestination;
                        lblDestination.Text = strDestDescr;
                        lblSortReason1.Text = strReasonDescr;
                        if (lblDestination.Text.ToUpper () != "MES")//If Des is not equal MES auto will Dispatch
                        {
                            btnDispatch_Click(sender, e);
                        }
                      //  btnDispatch.Enabled = lblDestination.Text == "MES" ? false : true;
                  //  }

                    //string airline = GetPassengerAirline();
                    //if (airline!=string.Empty)
                    //{
                    //    this.txtAirlineInput.Text = airline;
                    //    //this.tabControlEncodeMode.SelectedIndex = 2;
                    //    //this.btnEnter_Click(this.button38, e);
                    //}

                    break;
                case "Flight #":
                    if (string.Compare(txtFlightInput.Text, string.Empty) == 0)
                        return;

                    string strCarrier = string.Empty;
                    string strFlightNo = string.Empty;
                    _destination = string.Empty;

                    #region split the string in txtFlightInput.Text into Airline and Flight - Guo Wenyu 2014/03/20
                    // commented by Guo Wenyu 2014/03/20
                    //if (txtFlightInput.Text.Trim().Substring(3, 1) != string.Empty)
                    //{
                    //    strCarrier = txtFlightInput.Text.Trim().Substring(0, 3);
                    //    strFlightNo = txtFlightInput.Text.Trim().Substring(3, txtFlightInput.Text.Trim().Length-3);
                    //}
                    //else
                    //{
                    //    strCarrier = txtFlightInput.Text.Trim().Substring(0,3);
                    //    strFlightNo = txtFlightInput.Text.Trim().Substring(4,txtFlightInput.Text.Trim().Length-4);
                    //}

                    string[] substr = RegSpaceSplit(txtFlightInput.Text.Trim());
                    if (substr.Length > 0)
                    {
                        if (substr.Length == 1)
                            strCarrier = substr[0];
                        else
                        {
                            strCarrier = substr[0];
                            strFlightNo = substr[1];
                        }
                    }

                    #endregion

                    string strSDO = DateTime.Now.Year.ToString() + "-" + DateTime.Now.Month.ToString().PadLeft(2, '0') + "-" + DateTime.Now.Day.ToString().PadLeft(2, '0');

                    if (GetFlightInfo(strCarrier, strFlightNo, strSDO))
                    {
                        init.AppInit.MsgHandler.DBPersistor.GetIRDValuesMES("2", string.Empty, strCarrier, strFlightNo, strSDO, _location, string.Empty, out strDestination, out strReason, out strDestDescr, out strReasonDescr);

                        _destination = strDestination;
                        blSortDest.Text = strDestDescr;
                        lblSortReason2.Text = strReasonDescr;
                    }
                    
                    break;
                case "Airline":
                    if (string.Compare(txtAirlineInput.Text, string.Empty) == 0)
                        return;

                    if (IsExistAirlineInfo(txtAirlineInput.Text.Trim()))
                    {
                        init.AppInit.MsgHandler.DBPersistor.GetIRDValuesMES("6", string.Empty, txtAirlineInput.Text, string.Empty, string.Empty, _location, string.Empty, out strDestination, out  strReason, out strDestDescr, out strReasonDescr);

                        _destination = strDestination;
                        lblSortDest.Text = strDestDescr;
                        lblSortReason3.Text = strReasonDescr;
                    }
                    
                    break;
                case "Destination":
                    if (string.Compare(txtDestInput.Text, string.Empty) == 0)
                        return;

                    init.AppInit.MsgHandler.DBPersistor.GetIRDValuesMES("3", string.Empty, string.Empty, string.Empty, string.Empty, _location, txtDestInput.Text, out strDestination, out  strReason, out strDestDescr, out strReasonDescr);

                    _destination = strDestination;
                    lblSortReason4.Text = strReasonDescr;

                    //added by PST auto dispatch function encode by Destination
                    btnDispatch_Click(sender, e);

                    break;
                case "Problem Bag":
                    break;

            }

            //btnDispatch.Enabled = lblDestination.Text == "MES" ? false : true;
           
        }

        /// <summary>
        /// Enable or disable shift key.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //private void btnEnter_Click(object sender, EventArgs e)
        //{
        //    if (string.Compare(txtTagInput.Text.Trim(), string.Empty) == 0 && string.Compare(txtFlightInput.Text.Trim(), string.Empty) == 0 && string.Compare(txtDestInput.Text.Trim(), string.Empty) == 0)
        //        return;

        //    fromScreenKeyboard = true;

        //    string dest = string.Empty;
        //    int type = 0;

        //    btnRepeat.Enabled = false;
        //    lblMessage.Text = string.Empty;

        //    if (!isHBSFail)
        //    {
        //        txtFlightInput.Enabled = true;
        //        txtDestInput.Enabled = true;
        //    }


        //    if (txtTagInput.Enabled == true && txtFlightInput.Enabled == true && txtDestInput.Enabled == true && isConnected)
        //    {              

        //        bOKBarcodeInclude = CheckOKBarcode();                
            

        //        btnConvStat.Enabled = false;
        //        //btnDispatch.Enabled = false;
                
        //        lblGID.Text = _bagGID;                

        //        switch (lblEncodingMode.Text)
        //        {
        //            case "Tag":
        //                _lastInput = string.Empty;
        //                _lastEncodeMode = "Tag";

        //                ClearAfterEnter();

        //                if (init.CheckTagFormat(txtTagInput.Text) == false)
        //                {
        //                    lblMessage.Text = "(" + Properties.Resources.sErrorInvalidFormat + ")";
        //                    lblMessage.ForeColor = Color.Red;
        //                    displayMessageCheck = DateTime.Now;
        //                    tmrMessageHandler.Enabled = true;
        //                }
        //                else
        //                {
        //                    if (logger.IsDebugEnabled)
        //                        logger.Debug("[DEBUG] Enter button is activated for Encode by Tag (" +
        //                                txtTagInput.Text + "). <" + _className + ".btnEnter_Click()>");

                          
        //                    isBtnEnter = true;

        //                    GetPassengerInfo(false, false);

        //                    GetTagReason();
        //                    _isProblemEncoded = false;

        //                    if (lblBagTagNumber.Text.Trim() == "")
        //                    {
        //                        lblBagTagNumber.Text = txtTagInput.Text;
        //                    }

        //                    if ((lblDestination.Text.Contains("EDS") || lblDestination.Text.Contains("CDS")))
        //                    {

        //                        txtFlightInput.Enabled = false;
        //                        isHBSFail = false;
        //                    }
        //                    else
        //                    {
        //                        txtFlightInput.Enabled = true;
        //                        txtDestInput.Enabled = true;
        //                        isHBSFail = true;                             
        //                    }

        //                    txtTagInput.Text = string.Empty;

        //                }
        //                break;
        //            case "Flight":

        //                lblFlight.Text = "";
        //                lblFlightDest.Text = "";
        //                lblTravelClass.Text = "";
        //                lblPassengerName.Text = "";
        //                lblDestination.Text = "";

        //                  _lastEncodeMode = "Flight";

        //                if (logger.IsDebugEnabled)
        //                    logger.Debug("[DEBUG] Enter button is activated for Encode by Flight (" +
        //                            txtFlightInput.Text + "). <" + _className + ".btnEnter_Click()>");
                    

        //                DataTable dtFlightList = init.AppInit.MsgHandler.DBPersistor.GetFlights(txtFlightInput.Text.Trim(),
        //                    init.AppInit.MsgHandler.TTS);

        //                if (dtFlightList.Rows.Count > 0)
        //                {
        //                    for (int i = 0; i < dtFlightList.Rows.Count; i++)
        //                    {
        //                        string flight = dtFlightList.Rows[i][0].ToString();
        //                        string destination = dtFlightList.Rows[i][4].ToString();
        //                        string std = dtFlightList.Rows[i][1].ToString();

        //                        for (int j = 0; j < dtFlightList.Rows.Count; j++)
        //                        {
        //                            if (i != j)
        //                            {
        //                                //if (std == dtFlightList.Rows[j][1].ToString())
        //                                //{
        //                                if ((flight == dtFlightList.Rows[j][0].ToString()) && (std == dtFlightList.Rows[j][1].ToString()) && (destination == dtFlightList.Rows[j][4].ToString()))
        //                                    {
        //                                        if ((bool.Parse(dtFlightList.Rows[j][6].ToString())) && (bool.Parse(dtFlightList.Rows[i][6].ToString())))
        //                                        {
        //                                            dtFlightList.Rows.Remove(dtFlightList.Rows[j]);
        //                                            j = j - 1;
        //                                        }
        //                                        else if ((!bool.Parse(dtFlightList.Rows[j][6].ToString())) && (bool.Parse(dtFlightList.Rows[i][6].ToString())))
        //                                        {
        //                                            dtFlightList.Rows.Remove(dtFlightList.Rows[j]);
        //                                            j = j - 1;
        //                                        }
        //                                        else if ((bool.Parse(dtFlightList.Rows[j][6].ToString())) && (!bool.Parse(dtFlightList.Rows[i][6].ToString())))
        //                                        {
        //                                            dtFlightList.Rows.Remove(dtFlightList.Rows[i]);
        //                                            i = i - 1;
        //                                        }
        //                                        else if ((!bool.Parse(dtFlightList.Rows[j][6].ToString())) && (!bool.Parse(dtFlightList.Rows[i][6].ToString())))
        //                                        {
        //                                            dtFlightList.Rows.Remove(dtFlightList.Rows[j]);
        //                                            j = j - 1;
        //                                        }
        //                                    }
        //                                //}
        //                            }
        //                        }
        //                    }
        //                }
                        

        //                if (dtFlightList != null)
        //                {
        //                    if (dtFlightList.Rows.Count > 1)
        //                    {
        //                        Selection frmFlightSelection = new Selection(dtFlightList, lblEncodingMode.Text, _licensePlate, _bagGID, init.AppInit.MsgHandler.isHLCMode);
        //                        if (frmFlightSelection.ShowDialog() == DialogResult.OK)
        //                        {

        //                            if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(frmFlightSelection.sDestination, frmFlightSelection.sDestinationID, init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
        //                            {
        //                                //lblFlight.Text = dtFlightList.Rows[frmFlightSelection.nCurrentRow][0].ToString() + ", " + dtFlightList.Rows[frmFlightSelection.nCurrentRow][1].ToString();
        //                                lblFlight.Text = frmFlightSelection.sFlight;
        //                                _flightNumber = frmFlightSelection.sFlight;
        //                                lblDestination.Text = frmFlightSelection.sDestination;
        //                                lblDestination.Tag = frmFlightSelection.sDestinationID;
        //                                lblFlightDest.Tag = frmFlightSelection.sSubSystem;

        //                                //txtFlightInput.Text = "";
        //                                _lastInput = dtFlightList.Rows[frmFlightSelection.nCurrentRow][0].ToString();

        //                                string sReason = string.Empty;
        //                                sReason = init.AppInit.MsgHandler.DBPersistor.ClassParameters.SortReasonALLO;
        //                                lblReason.Text = init.AppInit.MsgHandler.DBPersistor.GetReason(sReason);
        //                                lblReason.Tag = sReason;
        //                                _isProblemEncoded = false;
        //                            }
        //                            else
        //                            {
        //                                if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
        //                                {
        //                                    //lblFlight.Text = dtFlightList.Rows[frmFlightSelection.nCurrentRow][0].ToString() + ", " + dtFlightList.Rows[frmFlightSelection.nCurrentRow][1].ToString();
        //                                    lblFlight.Text = frmFlightSelection.sFlight;
        //                                    _flightNumber = frmFlightSelection.sFlight;
        //                                    lblDestination.Text = frmFlightSelection.sDestination;
        //                                    lblDestination.Tag = frmFlightSelection.sDestinationID;
        //                                    lblFlightDest.Tag = frmFlightSelection.sSubSystem;

        //                                    //txtFlightInput.Text = "";
        //                                    _lastInput = dtFlightList.Rows[frmFlightSelection.nCurrentRow][0].ToString();

        //                                    string sReason = string.Empty;
        //                                    sReason = init.AppInit.MsgHandler.DBPersistor.ClassParameters.SortReasonALLO;
        //                                    lblReason.Text = init.AppInit.MsgHandler.DBPersistor.GetReason(sReason);
        //                                    lblReason.Tag = sReason;
        //                                    _isProblemEncoded = false;
        //                                }
        //                            }
                                  
        //                        }
        //                        frmFlightSelection.Dispose();
        //                        frmFlightSelection = null;

        //                    }
        //                    else if (dtFlightList.Rows.Count == 1)
        //                    {
        //                        if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(dtFlightList.Rows[0][4].ToString(), dtFlightList.Rows[0][3].ToString(), init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
        //                        {
        //                            lblFlight.Text = dtFlightList.Rows[0][0].ToString() + ", " + dtFlightList.Rows[0][1].ToString();
        //                            _flightNumber = dtFlightList.Rows[0][0].ToString() + ", " + dtFlightList.Rows[0][1].ToString();
        //                            lblDestination.Text = dtFlightList.Rows[0][4].ToString();
        //                            lblDestination.Tag = dtFlightList.Rows[0][3].ToString();
        //                            lblFlightDest.Tag = dtFlightList.Rows[0][5].ToString();

        //                            lblFlightDest.Text = dtFlightList.Rows[0][2].ToString();
        //                            //txtFlightInput.Text = "";
        //                            _lastInput = dtFlightList.Rows[0][0].ToString();

        //                            string sReason = string.Empty;
        //                            sReason = init.AppInit.MsgHandler.DBPersistor.ClassParameters.SortReasonALLO;
        //                            lblReason.Text = init.AppInit.MsgHandler.DBPersistor.GetReason(sReason);
        //                            lblReason.Tag = sReason;
        //                            _isProblemEncoded = false;

        //                        }
        //                        else
        //                        {
        //                            if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
        //                            {
        //                                lblFlight.Text = dtFlightList.Rows[0][0].ToString() + ", " + dtFlightList.Rows[0][1].ToString();
        //                                _flightNumber = dtFlightList.Rows[0][0].ToString() + ", " + dtFlightList.Rows[0][1].ToString(); 
        //                                lblDestination.Text = dtFlightList.Rows[0][4].ToString();
        //                                lblDestination.Tag = dtFlightList.Rows[0][3].ToString();
        //                                lblFlightDest.Tag = dtFlightList.Rows[0][5].ToString();

        //                                lblFlightDest.Text = dtFlightList.Rows[0][2].ToString();
        //                                //txtFlightInput.Text = "";
        //                                _lastInput = dtFlightList.Rows[0][0].ToString();

        //                                string sReason = string.Empty;
        //                                sReason = init.AppInit.MsgHandler.DBPersistor.ClassParameters.SortReasonALLO;
        //                                lblReason.Text = init.AppInit.MsgHandler.DBPersistor.GetReason(sReason);
        //                                lblReason.Tag = sReason;
        //                                _isProblemEncoded = false;
        //                            }
        //                        }
                                                              
        //                    }
        //                    else
        //                    {
        //                       // _lastInput = string.Empty;
        //                        lblMessage.Text = "(" + Properties.Resources.sErrorInvalidFlight + ")";
        //                        lblMessage.ForeColor = Color.Red;
        //                        displayMessageCheck = DateTime.Now;
        //                        tmrMessageHandler.Enabled = true;
        //                    }
        //                }

        //                //if (lblDestination.Text == "EDS07" || lblDestination.Text == "EDS08")
        //                //{
        //                //    txtFlightInput.Enabled = false;
        //                //    txtDestInput.Enabled = false;
        //                //    isHBSFail = false;
        //                //}

        //                txtFlightInput.Text = string.Empty;

        //                break;
        //            case "Sort Dest.":
        //                _lastEncodeMode = "Sort Dest.";

        //                if (logger.IsDebugEnabled)
        //                    logger.Debug("[DEBUG] Enter button is activated for Encode by Destination (" +
        //                            txtDestInput.Text + "). <" + _className + ".btnEnter_Click()>");

        //                lblFlight.Text = "";
        //                lblFlightDest.Text = "";
        //                lblTravelClass.Text = "";
        //                lblPassengerName.Text = "";
        //                lblDestination.Text = "";


        //                DataTable dtDest = init.AppInit.MsgHandler.DBPersistor.GetDestination(txtDestInput.Text.Trim(),
        //                     init.AppInit.MsgHandler.TTS);

        //                if (dtDest != null)
        //                {
        //                    if (dtDest.Rows.Count > 1)
        //                    {
        //                        DestinationSelection frmDestinationSelection = new DestinationSelection(dtDest, lblEncodingMode.Text);
        //                        if (frmDestinationSelection.ShowDialog() == DialogResult.OK)
        //                        {
        //                            DataTable dtChutes = init.AppInit.MsgHandler.DBPersistor.GetChuteByDestination(frmDestinationSelection.sDestination, init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS);
        //                            if (dtChutes != null)
        //                            {
        //                                if (dtChutes.Rows.Count > 0)
        //                                {
        //                                    if (dtChutes.Rows.Count == 1)
        //                                    {
        //                                        if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(frmDestinationSelection.sDestination, dtChutes.Rows[0][1].ToString(), init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
        //                                        {
        //                                            lblDestination.Text = frmDestinationSelection.sDestination;
        //                                            lblDestination.Tag = dtChutes.Rows[0][1]; //column1 is CHUTE, column2 is TTS_ID
        //                                            lblFlightDest.Tag = init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS;
        //                                            lblReason.Tag = null;
        //                                            _lastInput = frmDestinationSelection.sDestination;
        //                                            _isProblemEncoded = false;
        //                                        }
        //                                        else
        //                                        {
        //                                            if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
        //                                            {
        //                                                lblDestination.Text = frmDestinationSelection.sDestination;
        //                                                lblDestination.Tag = dtChutes.Rows[0][1]; //column1 is CHUTE, column2 is TTS_ID
        //                                                lblFlightDest.Tag = init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS;
        //                                                lblReason.Tag = null;
        //                                                _lastInput = frmDestinationSelection.sDestination;
        //                                                _isProblemEncoded = false;
        //                                            }
        //                                        }

        //                                    }
        //                                    else
        //                                    {
        //                                            LocationID currentLocation = new LocationID();
        //                                            if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS == init.AppInit.MsgHandler.DBPersistor.TTS01_SUBSYSTEM)
        //                                            {
        //                                                currentLocation = init.AppInit.MsgHandler.DBPersistor.ClassParameters.TTS01MESLocation[0];
        //                                            }
        //                                            else
        //                                            {
        //                                                currentLocation = init.AppInit.MsgHandler.DBPersistor.ClassParameters.TTS02MESLocation[0];
        //                                            }


        //                                            LocationID[] locations = new LocationID[dtChutes.Rows.Count];
        //                                            for (int i = 0; i < dtChutes.Rows.Count; i++)
        //                                            {
        //                                                locations[i].Subsystem = init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS;
        //                                                locations[i].Location = dtChutes.Rows[i][1].ToString();
        //                                            }
        //                                            init.AppInit.MsgHandler.DBPersistor.SortByShortestPathScheme(currentLocation, ref locations);

        //                                            if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(frmDestinationSelection.sDestination, locations[0].Location, init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
        //                                            {
        //                                                lblDestination.Text = frmDestinationSelection.sDestination;
        //                                                lblDestination.Tag = locations[0].Location;
        //                                                lblFlightDest.Tag = init.AppInit.MsgHandler.TTS;
        //                                                lblReason.Tag = null;
        //                                                _lastInput = frmDestinationSelection.sDestination;
        //                                                _isProblemEncoded = false;
        //                                            }
        //                                            else
        //                                            {
        //                                                if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
        //                                                {
        //                                                    lblDestination.Text = frmDestinationSelection.sDestination;
        //                                                    lblDestination.Tag = locations[0].Location;
        //                                                    lblFlightDest.Tag = init.AppInit.MsgHandler.TTS;
        //                                                    lblReason.Tag = null;
        //                                                    _lastInput = frmDestinationSelection.sDestination;
        //                                                    _isProblemEncoded = false;
        //                                                }

        //                                            }                                                                                           
        //                                    }
        //                                }
        //                            }
        //                        }
        //                        frmDestinationSelection.Dispose();
        //                        frmDestinationSelection = null;
        //                    }
        //                    else if (dtDest.Rows.Count == 1)
        //                    {
        //                        DataTable dtChutes = init.AppInit.MsgHandler.DBPersistor.GetChuteByDestination(dtDest.Rows[0][0].ToString(), init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS);
        //                        if (dtChutes != null)
        //                        {
        //                            if (dtChutes.Rows.Count > 0)
        //                            {
        //                                if (dtChutes.Rows.Count == 1)
        //                                {
        //                                    if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(dtDest.Rows[0][0].ToString(), dtChutes.Rows[0][1].ToString(), init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
        //                                    {
        //                                        lblDestination.Text = dtDest.Rows[0][0].ToString();
        //                                        lblDestination.Tag = dtChutes.Rows[0][1]; //column1 is CHUTE, column2 is TTS_ID
        //                                        lblFlightDest.Tag = init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS;
        //                                        lblReason.Tag = null;
        //                                        _lastInput = dtDest.Rows[0][0].ToString();
        //                                        _isProblemEncoded = false;
        //                                    }
        //                                    else
        //                                    {
        //                                        if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
        //                                        {
        //                                            lblDestination.Text = dtDest.Rows[0][0].ToString();
        //                                            lblDestination.Tag = dtChutes.Rows[0][1]; //column1 is CHUTE, column2 is TTS_ID
        //                                            lblFlightDest.Tag = init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS;
        //                                            lblReason.Tag = null;
        //                                            _lastInput = dtDest.Rows[0][0].ToString();
        //                                            _isProblemEncoded = false;
        //                                        }
        //                                    }
                                          
        //                                }
        //                                else
        //                                {
                                            
        //                                        LocationID currentLocation = new LocationID();
        //                                        currentLocation.Location = init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESCurrentLocation;
        //                                        currentLocation.Subsystem = init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS;

        //                                        LocationID[] locations = new LocationID[dtChutes.Rows.Count];
        //                                        for (int i = 0; i < dtChutes.Rows.Count; i++)
        //                                        {
        //                                            locations[i].Subsystem = init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS;
        //                                            locations[i].Location = dtChutes.Rows[i][1].ToString();
        //                                        }
        //                                        init.AppInit.MsgHandler.DBPersistor.SortByShortestPathScheme(currentLocation, ref locations);

        //                                        if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(dtDest.Rows[0][0].ToString(), locations[0].Location, init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
        //                                        {
        //                                            lblDestination.Text = dtDest.Rows[0][0].ToString();
        //                                            lblDestination.Tag = locations[0].Location;
        //                                            lblFlightDest.Tag = init.AppInit.MsgHandler.TTS;
        //                                            lblReason.Tag = null;
        //                                            _lastInput = dtDest.Rows[0][0].ToString();
        //                                            _isProblemEncoded = false;
        //                                        }
        //                                        else
        //                                        {
        //                                            if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
        //                                            {

        //                                            lblDestination.Text = dtDest.Rows[0][0].ToString();
        //                                            lblDestination.Tag = locations[0].Location;
        //                                            lblFlightDest.Tag = init.AppInit.MsgHandler.TTS;
        //                                            lblReason.Tag = null;
        //                                            _lastInput = dtDest.Rows[0][0].ToString();
        //                                            _isProblemEncoded = false;
        //                                            }
        //                                        }
                                                     
        //                                }
        //                            }
        //                        }
        //                    }
        //                    else
        //                    {
        //                        //_lastInput = string.Empty;
        //                        lblMessage.Text = "(" + Properties.Resources.sErrorItemNotfound + ")";
        //                        lblMessage.ForeColor = Color.Red;
        //                        displayMessageCheck = DateTime.Now;
        //                        tmrMessageHandler.Enabled = true;
        //                    }
        //                    lblReason.Text = "Sorted By Sort Destination";
        //                }
        //                else
        //                {
        //                    //_lastInput = string.Empty;

        //                    lblMessage.Text = "(" + Properties.Resources.sErrorItemNotfound + ")";
        //                    lblMessage.ForeColor = Color.Red;
        //                    displayMessageCheck = DateTime.Now;
        //                    tmrMessageHandler.Enabled = true;
        //                }

        //                if ((lblDestination.Text.Contains("EDS") || lblDestination.Text.Contains("CDS")))
        //                {

        //                    txtFlightInput.Enabled = false;
        //                    isHBSFail = false;
        //                }

        //                txtDestInput.Text = string.Empty;

        //                break;
        //            case "Rush Dest.":
        //                _lastEncodeMode = "Rush Dest.";

        //                if (logger.IsDebugEnabled)
        //                    logger.Debug("[DEBUG] Enter button is activated for Encode by Rush (" +
        //                            txtFlightInput.Text + "). <" + _className + ".btnEnter_Click()>");

        //                lblFlight.Text = "";
        //                lblFlightDest.Text = "";
        //                lblTravelClass.Text = "";
        //                lblPassengerName.Text = "";
        //                lblDestination.Text = "";

        //                txtFlightInput.Tag = null;

        //                if (GetDestinationNReason(ref type, ref dest) == true)
        //                {
        //                    _lastInput = txtFlightInput.Text;
        //                    _isProblemEncoded = false;

        //                    string sReason = string.Empty;
        //                    sReason = init.AppInit.MsgHandler.DBPersistor.ClassParameters.SortReasonRUSH;
        //                    lblReason.Text = init.AppInit.MsgHandler.DBPersistor.GetReason(sReason);
        //                }
        //                else
        //                {
        //                    lblMessage.Text = "(" + Properties.Resources.sErrorUnknownDest + ")";
        //                    displayMessageCheck = DateTime.Now;
        //                    tmrMessageHandler.Enabled = true;
        //                }
        //                break;
        //            case "Problem":
        //                break;
        //        }

        //        init.AppInit.MsgHandler.DBPersistor.AlertEncodingDuration(
        //            init.AppInit.MsgHandler.DBPersistor.ClassParameters.EncodeDurationAlarmType,
        //            init.AppInit.MsgHandler.DBPersistor.ClassParameters.EquipmentID);

        //    }
        //    SetFocusToActiveTextbox();
        //}

        private void ClearAfterEnter()
        {
            lblFlight.Text = "";
            lblFlightDest.Text = "";
            lblTravelClass.Text = "";
            lblPassengerName.Text = "";
            lblDestination.Text = "";
        }

        /// <summary>
        /// Clear any text in the text box which is available based on the encoding mode.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnSpace_Click(object sender, EventArgs e)
        {
            fromScreenKeyboard = true;

            lblMessage.Text = "";
            switch (lblEncodingMode.Text)
            {
                case "Tag #":
                    break;
                case "Flight #":
                    if (txtFlightInput.Text.Length < txtFlightInput.MaxLength)
                    {
                        //txtFlightInput.Text += " ";
                        selectionStartPosition = txtFlightInput.SelectionStart;
                        txtFlightInput.Text = txtFlightInput.Text.Substring(0, txtFlightInput.SelectionStart) + " " + txtFlightInput.Text.Substring(txtFlightInput.SelectionStart, txtFlightInput.Text.Length - txtFlightInput.SelectionStart);
                        txtFlightInput.SelectionStart = selectionStartPosition + 1;

                    }
                    break;
                case "Airline":
                    if (txtAirlineInput.Text.Length < txtAirlineInput.MaxLength)
                    {
                        selectionStartPosition = txtAirlineInput.SelectionStart;
                        txtAirlineInput.Text = txtAirlineInput.Text.Substring(0, txtAirlineInput.SelectionStart) + " " + txtAirlineInput.Text.Substring(txtAirlineInput.SelectionStart, txtAirlineInput.Text.Length - txtAirlineInput.SelectionStart);
                        txtAirlineInput.SelectionStart = selectionStartPosition + 1;

                    }
                    break;
                case "Destination":
                    if (txtDestInput.Text.Length < txtDestInput.MaxLength)
                    {
                        //txtFlightInput.Text += " ";
                        selectionStartPosition = txtDestInput.SelectionStart;
                        txtDestInput.Text = txtDestInput.Text.Substring(0, txtDestInput.SelectionStart) + " " + txtDestInput.Text.Substring(txtDestInput.SelectionStart, txtDestInput.Text.Length - txtDestInput.SelectionStart);
                        txtDestInput.SelectionStart = selectionStartPosition + 1;
                    }
                    break;
                case "Problem":
                    break;
            }

            SetFocusToActiveTextbox();
        }

        /// <summary>
        /// Remove character from the right side of available text box based on the encoding mode.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnBackSpace_Click(object sender, EventArgs e)
        {
            fromScreenKeyboard = true;

            lblMessage.Text = "";
            switch (lblEncodingMode.Text)
            {
                case "Tag #":
                    if (txtTagInput.SelectionStart > 0)
                    {
                        selectionStartPosition = txtTagInput.SelectionStart;
                        txtTagInput.Text = txtTagInput.Text.Substring(0, txtTagInput.SelectionStart - 1) + txtTagInput.Text.Substring(txtTagInput.SelectionStart, txtTagInput.Text.Length - txtTagInput.SelectionStart);
                        txtTagInput.SelectionStart = selectionStartPosition - 1;
                    }
                    break;
                case "Flight #":
                    if (txtFlightInput.SelectionStart > 0)
                    {
                        selectionStartPosition = txtFlightInput.SelectionStart;
                        txtFlightInput.Text = txtFlightInput.Text.Substring(0, txtFlightInput.SelectionStart - 1) + txtFlightInput.Text.Substring(txtFlightInput.SelectionStart, txtFlightInput.Text.Length - txtFlightInput.SelectionStart);
                        txtFlightInput.SelectionStart = selectionStartPosition - 1;
                    }
                    break;
                case "Airline":
                    if (txtAirlineInput.SelectionStart > 0)
                    {
                        selectionStartPosition = txtAirlineInput.SelectionStart;
                        txtAirlineInput.Text = txtAirlineInput.Text.Substring(0, txtAirlineInput.SelectionStart - 1) + txtAirlineInput.Text.Substring(txtAirlineInput.SelectionStart, txtAirlineInput.Text.Length - txtAirlineInput.SelectionStart);
                        txtAirlineInput.SelectionStart = selectionStartPosition - 1;
                    }
                    break;
                case "Destination":
                    if (txtDestInput.SelectionStart > 0)
                    {
                        selectionStartPosition = txtDestInput.SelectionStart;
                        txtDestInput.Text = txtDestInput.Text.Substring(0, txtDestInput.SelectionStart - 1) + txtDestInput.Text.Substring(txtDestInput.SelectionStart, txtDestInput.Text.Length - txtDestInput.SelectionStart);
                        txtDestInput.SelectionStart = selectionStartPosition - 1;
                    }
                    break;
                case "Problem":
                    break;
            }


            SetFocusToActiveTextbox();
        }

        /// <summary>
        /// Remove bag from the system.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnRemove_Click(object sender, EventArgs e)
        {
            //if (!txtTagInput.Enabled)
            //    return;
            if (isConnected)
            {
                try
                {
                    if (logger.IsDebugEnabled)
                        logger.Debug("[DEBUG] Remove button is clicked. <" + _className + ".btnRemove_Click()>");

                    ItemRemove();

                    lblMessage.Text = "(" + Properties.Resources.sMessageSuccessRemove + ")";
                    lblMessage.ForeColor = Color.Teal;

                    ClearAll();
                    btnRemove.Enabled = false;
                    btnDispatch.Enabled = false;

                    _encodeMode = "Remove Bag";
                }
                catch (Exception ex)
                {
                    if (logger.IsErrorEnabled)
                        logger.Error("Removing item failed. <" + _className + ".btnRemove_Click()>", ex);
                }
            }
            else
            {
                MessageBox.Show("Cannot Remove a bag when PLC is disconnected or No bag arrives to Encoding area.", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        /// <summary>
        /// Refresh screen to show current system time.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tmrSysTime_Tick(object sender, EventArgs e)
        {
            try
            {
                 
                lblSysTime.Text = DateTime.Now.ToString(init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateTimeFormat);

            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Updating system time failed. <" + _className + ".tmrSysTime_Tick()>", ex);
                lblMessage.Text = "(" + Properties.Resources.sErrorLoadFail + ")";
                lblMessage.ForeColor = Color.Red;
            }
        }

        /// <summary>
        /// To handle display message. After displaying message, this timer will clear
        /// based on the reset time duration from config file.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tmrMessageHandler_Tick(object sender, EventArgs e)
        {
            try
            {
                TimeSpan tsDisplayTime = DateTime.Now.Subtract(displayMessageCheck);
                if (Math.Abs(tsDisplayTime.TotalMilliseconds) >= init.AppInit.MsgHandler.DBPersistor.ClassParameters.DisplayMessageDuration)
                {
                    tmrMessageHandler.Enabled = false;
                    lblMessage.Text = "";
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Clearing displayed message fail. <" + _className + ".tmrMessageHandler_Tick()>", ex);
            }
        }

        /// <summary>
        /// To continue the process with same informationi on the form.
        /// This button only allow to press on Flight, Destination and Rush.
        /// After changing encoding mode to flight, this will reset.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnRepeat_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";

            try
            {
                switch (lblEncodingMode.Text)
                {
                    case "Tag":
                        txtTagInput.Text = _lastInput;
                        break;
                    case "Flight":
                        if (_lastInput == string.Empty)
                        {
                            MessageBox.Show("This is first encoding, please encode by flight, Sort Dest.,Rush Dest.,Problem to use Repeat button", "Warning");
                            return;
                        }

                        if (_lastEncodeMode == "Flight")
                            txtFlightInput.Text = _lastInput;
                        else
                            MessageBox.Show("Last Encoding Mode is " + _lastEncodeMode + " Please Choose " + _lastEncodeMode, "Warning");
                        break;
                    case "Sort Dest.":
                        if (_lastInput == string.Empty)
                        {
                            MessageBox.Show("This is first encoding, please encode by flight, Sort Dest.,Rush Dest.,Problem to use Repeat button", "Warning");
                            return;
                        }

                        if (_lastEncodeMode == "Sort Dest.")
                            txtDestInput.Text = _lastInput;
                        else
                            MessageBox.Show("Last Encoding Mode is " + _lastEncodeMode + " Please Choose " + _lastEncodeMode, "Warning");
                        break;
                    case "Rush Dest.":
                        if (_lastInput == string.Empty)
                        {
                            MessageBox.Show("This is first encoding, please encode by flight, Sort Dest.,Rush Dest.,Problem to use Repeat button", "Warning");
                            return;
                        }

                        if (_lastEncodeMode == "Rush Dest.")
                            txtFlightInput.Text = _lastInput;
                        else
                            MessageBox.Show("Last Encoding Mode is " + _lastEncodeMode + " Please Choose " + _lastEncodeMode, "Warning");
                        break;
                    case "Problem":
                        if (_lastInput == string.Empty)
                        {
                            MessageBox.Show("This is first encoding, please encode by flight, Sort Dest.,Rush Dest.,Problem to use Repeat button", "Warning");
                            return;
                        }

                        if (_lastEncodeMode == "Problem")
                            txtFlightInput.Text = _lastInput;
                        else
                            MessageBox.Show("Last Encoding Mode is " + _lastEncodeMode + " Please Choose " + _lastEncodeMode, "Warning");
                        break;
                }

                btnEnter_Click(null, null);
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Logging mes event fail. <" + _className + ".btnRepeat_Click()>", ex);
            }
        }

        /// <summary>
        /// Dispatch item from MES station.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnDispatch_Click(object sender, EventArgs e)
        {
            if (isConnected)
            {
                try
                {
                    if (_destination == string.Empty)
                    {
                        lblMessage.BeginInvoke(new Action(() => lblMessage.Text = "(please select an encode type)"));
                        return;
                    }

                    if (logger.IsDebugEnabled)
                        logger.Debug("[DEBUG] Dispatch button is clicked. <" + _className + ".btnDispatch_Click()>");

                    ItemDispatch();

                    lblMessage.BeginInvoke(new Action(() => lblMessage.Text = "(" + Properties.Resources.sMessageEncodeSuccess + ")"));
                    lblMessage.Text = "(" + Properties.Resources.sMessageEncodeSuccess + ")";
                    lblMessage.ForeColor = Color.Teal;

                    ClearAll();

                    btnRemove.Enabled = false;
                    btnDispatch.Enabled = false;

                    _encodeMode = lblEncodingMode.Text.Trim();
                }
                catch (Exception ex)
                {
                    if (logger.IsErrorEnabled)
                        logger.Error("Dispatching item failed. <" + _className + ".tmrSysTime_Tick()>", ex);
                }
            }
            else
            {
                btnDispatch.Enabled = false;
                btnRemove.Enabled = false;
                MessageBox.Show("Cannot Dispatch a bag when PLC is disconnected", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }


        /// <summary>
        /// To display allocated flight list.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnFlightList_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";
            FlightList FormFlightList = new FlightList(init);
            FormFlightList.StartPosition = FormStartPosition.CenterParent;
            FormFlightList.ShowDialog();
            FormFlightList.Dispose();
            FormFlightList = null;
            SetFocusToActiveTextbox();
        }

        /// <summary>
        /// Set focus always to input box.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //private void btnKeyboard_Click(object sender, EventArgs e)
        //{
        //    SetFocusToActiveTextbox();
        //}

        /// <summary>
        /// Clear all information.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnClear_Click(object sender, EventArgs e)
        {
            fromScreenKeyboard = true;

            switch (lblEncodingMode.Text)
            {
                case "Tag #":
                    txtTagInput.Text = string.Empty;

                    lblFlight.Text = string.Empty;
                    lblFlightDest.Text = string.Empty;
                    lblTravelClass.Text = string.Empty;
                    lblPassengerName.Text = string.Empty;
                    lblDestination.Text = string.Empty;

                    break;
                case "Flight #":
                    txtFlightInput.Text = string.Empty;

                    lblSTD.Text = string.Empty;
                    lblETD.Text = string.Empty;
                    lblFlightDestination.Text = string.Empty;
                    lblFlightStats.Text = string.Empty;
                    blSortDest.Text = string.Empty;
                    lblSortReason2.Text = string.Empty;

                    break;
                case "Airline":
                    txtAirlineInput.Text = string.Empty;
                    lblSortDest.Text = string.Empty;
                    lblSortReason3.Text = string.Empty;

                    break;
                case "Destination":
                    txtDestInput.Text = string.Empty;
                    lblSortReason4.Text = string.Empty;

                    break;
                case "Problem Bag":
                    txtProbBagDest.Text = string.Empty;

                    break;
            }
            
            SetFocusToActiveTextbox();
        }

        /// <summary>
        /// Go to symbol tab page
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnSymbol_Click(object sender, EventArgs e)
        {
            tabKeyboard.SelectedIndex = 3;
        }

        /// <summary>
        /// Set focus always to input box.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tabControl2_Click(object sender, EventArgs e)
        {
            fromScreenKeyboard = true;

            SetFocusToActiveTextbox();
        }

        /// <summary>
        /// Open help file.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnHelp_Click(object sender, EventArgs e)
        {
            try
            {
                
                foreach (Process proc in Process.GetProcessesByName("hh.exe"))
                {
                    proc.Kill();
                }

                //Process.GetCurrentProcess().Kill();
                Process.Start(init.ClassParameters.HelpFilePath);

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, Properties.Resources.sAppMessageBoxWarning, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                if (logger.IsErrorEnabled)
                    logger.Error("Error on changing windows. <" + _className + ".btnF1_Click()>", ex);
            }
        }

        private void picLogo1_Click(object sender, EventArgs e)
        {
            ABOUT frmAbout = new ABOUT();
            frmAbout.ShowDialog();
            frmAbout.Dispose();
            frmAbout = null;
        }

        private void timerSortReason_Tick(object sender, EventArgs e)
        {
            //if (lblReason.Text == string.Empty)
            //{
            //    lblReason.Text = init.AppInit.MsgHandler.DBPersistor.GetReason(init.AppInit.MsgHandler.DBPersistor.GetInfoReason(_bagGID, _licensePlate));
            //}
            //else
            //    tmrSysTime.Enabled = false;
        }

        //private void txtFlightInput_Enter(object sender, EventArgs e)
        //{
        //    if (!fromScreenKeyboard && !fromTelegramIncoming)
        //    {
        //        if (!bShiftToAirline)
        //        {
        //            EncodeModeChanged("Flight");
        //            lblMessage.Text = "(" + Properties.Resources.sMessageEncodeByFlight + ")";
        //            lblMessage.ForeColor = Color.Teal;

        //            //if (isAlarm)
        //            //{
        //            //    lblMessage.Text = alarmMessage;
        //            //    lblMessage.ForeColor = Color.Red;
        //            //    //isAlarm = false;
        //            //}
        //        }
        //        else
        //        {
        //            EncodeModeChanged("Rush Dest.");
        //            lblMessage.Text = "(" + Properties.Resources.sMessageEncodeByRushDestination + ")";

        //        }
        //    }
        //    fromScreenKeyboard = false;
        //    fromTelegramIncoming = false;
        //}

        //private void txtDestInput_Enter(object sender, EventArgs e)
        //{
        //    if (!fromScreenKeyboard && !fromTelegramIncoming)
        //    {
        //        EncodeModeChanged("Sort Dest.");
        //        lblMessage.Text = "(" + Properties.Resources.sMessageEncodeBySortDestination + ")";
        //        lblMessage.ForeColor = Color.Teal;

        //        //if (isAlarm)
        //        //{
        //        //    lblMessage.Text = alarmMessage;
        //        //    lblMessage.ForeColor = Color.Red;
        //        //    //isAlarm = false;
        //        //}
        //    }
        //    fromScreenKeyboard = false;
        //    fromTelegramIncoming = false;
        //}

        //private void txtFlightInput_KeyDown(object sender, KeyEventArgs e)
        //{
        //    if (e.KeyCode == Keys.Enter)
        //    {
        //        btnEnter_Click(sender, e);
        //    }
        //}

        //private void txtDestInput_KeyDown(object sender, KeyEventArgs e)
        //{
        //    if (e.KeyCode == Keys.Enter)
        //    {
        //        btnEnter_Click(sender, e);
        //    }
        //}

        //private void txtTagInput_Enter(object sender, EventArgs e)
        //{
        //    if (!fromScreenKeyboard)
        //    {
        //        EncodeModeChanged("Tag");
        //        lblMessage.Text = "(" + Properties.Resources.sMessageEncodeByTag + ")";

        //        //if (isAlarm)
        //        //{
        //        //    lblMessage.Text = alarmMessage;
        //        //    lblMessage.ForeColor = Color.Red;
        //        //    //isAlarm = false;
        //        //}
        //    }
        //    fromScreenKeyboard = false;
        //}

        //private void txtTagInput_KeyPress(object sender, KeyPressEventArgs e)
        //{
        //    if (lblEncodingMode.Text.ToUpper() == "TAG")
        //    {
        //        if (e.KeyChar != '\r' && e.KeyChar != '\b' && e.KeyChar != 'o' && e.KeyChar != 'O' && e.KeyChar != 'k' && e.KeyChar != 'K')
        //        {
        //            if (!Regex.IsMatch(e.KeyChar.ToString(), "\\d+"))
        //            {
        //                e.Handled = true;
        //            }
        //        }
        //    }
        //}

        //private void txtTagInput_KeyDown(object sender, KeyEventArgs e)
        //{
        //    if (e.KeyCode == Keys.Enter)
        //    {
        //        btnEnter_Click(sender, e);
        //    }
        //}

        //private void btnHistoryLog_Click(object sender, EventArgs e)
        //{
        //    try
        //    {
        //        Process p = new Process();
        //        p.StartInfo.FileName = init.ClassParameters.EventLogAppPath;
        //        p.Start();
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show(ex.Message, Properties.Resources.sAppMessageBoxWarning, MessageBoxButtons.OK, MessageBoxIcon.Warning);
        //        if (logger.IsErrorEnabled)
        //            logger.Error("Error on opening event log application. <" + _className + ".btnHistoryLog_Click()>", ex);
        //    }
        //}

        //private void txtTagInput_Leave(object sender, EventArgs e)
        //{
        //    fromScreenKeyboard = false;
        //    fromTelegramIncoming = false;
        //}

        //private void txtFlightInput_Leave(object sender, EventArgs e)
        //{
        //    fromScreenKeyboard = false;
        //    fromTelegramIncoming = false;
        //}

        //private void txtDestInput_Leave(object sender, EventArgs e)
        //{
        //    fromScreenKeyboard = false;
        //    fromTelegramIncoming = false;
        //}

        //private void keyboardcontrol1_UserKeyPressed(object sender, KeyboardClassLibrary.KeyboardEventArgs e)
        //{
        //    SendKeys.Send(e.KeyboardKeyPressed);
        //}

        #endregion

        #region Custom Functions and Methods

        /// <summary>
        /// This function will check every key press and based on the function key allocation, it'll call
        /// respective button click.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FunctionKeyAssignment(object sender, KeyEventArgs e)
        {
            switch (e.KeyCode)
            {
                case Keys.F1:
                    btnHelp_Click(sender, e);
                    break;
                case Keys.F2:
                    //btnRepeat_Click(sender, e);
                    btnRemove_Click(sender, e);
                    break;
                case Keys.F3:
                    //btnRemove_Click(sender, e);
                    btnDispatch_Click(sender, e);
                    break;
                case Keys.F4:
                   // btnDispatch_Click(sender, e);
                    break;
                case Keys.F5:
                    break;    
                case Keys.F6:
                    break;
                case Keys.F7:
                    break;
                case Keys.F8:
                    break;
                case Keys.F9:
                    break;
                case Keys.F10:
                    if (btnFlightList.Enabled)
                        btnFlightList_Click(sender, e);
                    break;
                case Keys.F11:
                    //if (btnConvStat.Enabled)
                        //this.btnConvStat_Click(sender, e);
                    break;
                case Keys.F12:
                    this.btnLogout_Click(sender, e);
                    break;
                default:
                    SetFocusToActiveTextbox();
                    break;
            }
        }

        /// <summary>
        /// Common event handler for buttons 0-9 and A-Z.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ButtonText_Click(object sender, EventArgs e)
        {
            fromScreenKeyboard = true;

            if (txtFlightInput.Enabled == true || txtAirlineInput.Enabled == true  ||  txtTagInput.Enabled == true)
            {
                AddText(((Button)sender).Text);
            }
            SetFocusToActiveTextbox();
        }

        /// <summary>
        /// Common event handler for input symbol
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ButtonSymbol_Click(object sender, EventArgs e)
        {
            fromScreenKeyboard = true;

            if (txtFlightInput.Enabled == true || txtAirlineInput.Enabled == true || txtDestInput.Enabled == true)
            {
                AddText(((Button)sender).Text);
            }
            SetFocusToActiveTextbox();
        }

        /// <summary>
        /// Add the text to respective text box based on the local field current active text box.
        /// If the text length in the text box is greater than restricted length,
        /// this function will ignore the input text.
        /// </summary>
        /// <param name="CharString">Require character to add into text box as System.String.</param>
        private void AddText(string CharString)
        {
            // Modified by Guo Wenyu 2014/03/23
            // Add MaxLength for each textbox
            switch (tabControlEncodeMode.SelectedTab.Text)
            {
                case "Tag #":
                    if (txtTagInput.Text.Length < txtTagInput.MaxLength)
                    {
                        if (!CheckNumeric(CharString))
                        {
                            selectionStartPosition = txtTagInput.SelectionStart;
                            txtTagInput.Text = txtTagInput.Text.Substring(0, txtTagInput.SelectionStart) + CharString + txtTagInput.Text.Substring(txtTagInput.SelectionStart, txtTagInput.Text.Length - txtTagInput.SelectionStart);
                            txtTagInput.SelectionStart = selectionStartPosition + 1;
                        }
                    }
                    break;
                case "Flight #":
                    if (txtFlightInput.Text.Length < txtFlightInput.MaxLength)
                    {
                        selectionStartPosition = txtFlightInput.SelectionStart;
                        txtFlightInput.Text = txtFlightInput.Text.Substring(0, txtFlightInput.SelectionStart) + CharString + txtFlightInput.Text.Substring(txtFlightInput.SelectionStart, txtFlightInput.Text.Length - txtFlightInput.SelectionStart);
                        txtFlightInput.SelectionStart = selectionStartPosition + 1;
                    }
                    break;
                case "Airline":
                    if (txtAirlineInput.Text.Length < txtAirlineInput.MaxLength)
                    {
                        selectionStartPosition = txtAirlineInput.SelectionStart;
                        txtAirlineInput.Text = txtAirlineInput.Text.Substring(0, txtAirlineInput.SelectionStart) + CharString + txtAirlineInput.Text.Substring(txtAirlineInput.SelectionStart, txtAirlineInput.Text.Length - txtAirlineInput.SelectionStart);
                        txtAirlineInput.SelectionStart = selectionStartPosition + 1;
                    }
                    break;
                case "Destination":
                    if (txtDestInput.Text.Length < txtDestInput.MaxLength)
                    {
                        selectionStartPosition = txtDestInput.SelectionStart;
                        txtDestInput.Text = txtDestInput.Text.Substring(0, txtDestInput.SelectionStart) + CharString + txtDestInput.Text.Substring(txtDestInput.SelectionStart, txtDestInput.Text.Length - txtDestInput.SelectionStart);
                        txtDestInput.SelectionStart = selectionStartPosition + 1;
                    }
                    break;
            }
        }

        /// <summary>
        /// Set focus back to the active text box based on the local field
        /// current focus text box.
        /// </summary>
        /// <param name="ClearTextBoxes">Indicator to check user press
        /// Clear button or not. If user is pressing clear button, 
        /// program will set back to the first text box of the encoding mode.</param>
        private void SetFocusToActiveTextbox()
        {
            switch (lblEncodingMode.Text)
            {
                case "Tag #":
                    txtTagInput.BeginInvoke(new Action(() => txtTagInput.Focus()));
                    break;
                case "Flight #":
                    txtFlightInput.BeginInvoke(new Action(() => txtFlightInput.Focus()));
                    break;
                case "Airline":
                    txtAirlineInput.BeginInvoke(new Action(() => txtAirlineInput.Focus()));
                    break;
                case "Destination":
                    txtDestInput.BeginInvoke(new Action(() => txtDestInput.Focus()));
                    break;
            }
        }

        /// <summary>
        /// Event triggerred when connected to PLC.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Initializer_OnConnected(object sender, MessageEventArgs e)
        {
            DisplayStatus(lblPLCStatus, e);
        }

        /// <summary>
        /// Event triggerred when disconnected from PLC.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Initializer_OnDisconnected(object sender, MessageEventArgs e)
        {
            DisplayStatus(lblPLCStatus, e);
        }

        /// <summary>
        /// Envent triggerred when data received from PLC1 or PLC2.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Initializer_OnDataReceived(object sender, MessageEventArgs e)
        {
            ProcessIncomingMessage(lblMessage, txtTagInput, e);
        }

        /// <summary>
        /// Definition for event triggerred when data received from PLC1 or PLC2.
        /// 1. If there's previous encoding information, move those information to status bar message
        /// 2. Clear screen
        /// 3. Decode message
        /// 4. Get passenger detail information
        /// 5. Set focus back to input box
        /// </summary>
        /// <param name="lblMessage"></param>
        /// <param name="txtTag"></param>
        /// <param name="e"></param>
        public delegate void ProcessIncomingMessageDelegate(Label lblMessage, TextBox txtTag, MessageEventArgs e);
        private void ProcessIncomingMessage(Label lblMessage, TextBox txtTag, MessageEventArgs e)
        {
            if (lblMessage.InvokeRequired)
            {
                ProcessIncomingMessageDelegate deleg = new ProcessIncomingMessageDelegate(ProcessIncomingMessage);
                this.Invoke(deleg, new object[] { lblMessage, txtTag, e });
            }
            else
            {
                string teleType = e.Message.ToString().Substring(0, 4);

                if (teleType == "0018")
                {
                    fromTelegramIncoming = true;

                    string type, length, sequence ;
                    try
                    {
                        
                        #region set last bag information to status area
                        lblLastBagInfo.Text = string.Empty;

                        string temp = "Last Bag: ";
                        if (_encodeMode == "Tag #")
                        {
                            temp = temp + " Encoded by Tag #,  GID =" + _bagGID + ", License Plate=" + _licensePlate ;
                        }
                        else if (_encodeMode == "Flight #")
                        {
                            temp = temp + " Encoded by Flight #, GID :" + _bagGID;
                        }
                        else if (_encodeMode == "Airline")
                        {
                            temp = temp + " Encoded by Airline, GID :" + _bagGID;
                        }
                        else if (_encodeMode == "Destination")
                        {
                            temp = temp + " Encoded by Destination, GID :" + _bagGID;
                        }
                        else if (_encodeMode == "Problem Bag")
                        {
                            temp = temp + " Encoded by Problem Bag, GID :" + _bagGID;
                        }
                        else if (_encodeMode == "Remove Bag")
                        {
                            temp = temp + " Encoded by Remove Bag, GID : " + _bagGID;
                        }

                        if (_isFirstBag == true)
                        {
                            lblLastBagInfo.Text = string.Empty;
                            _isFirstBag = false;
                        }
                        else 
                        {
                            lblLastBagInfo.Text = temp;
                        }
                        #endregion 

                        _bagGID = string.Empty;
                        _licensePlate = string.Empty;
                        _encodeMode = string.Empty;

                        #region clear textbox value
                        ClearAll();
                        #endregion

                        #region Message Decoding

                        init.AppInit.MsgHandler.IRY.MessageDecoding(e.Message, out type, out length, out sequence,
                            out _bagGID, out _location , out _plcIndex);

                        SetDefaultEncodeMode();

                        lblMessage.Text = "(" + Properties.Resources.sMessageItemReady + ")";
                        lblMessage.ForeColor = Color.Teal;
                        lblGID.Text = _bagGID;

                        #endregion

                        //if (_licensePlate == string.Empty || _licensePlate == "0000000000" || _licensePlate == "9999999999")
                        //{
                        //    _licensePlate = init.AppInit.MsgHandler.DBPersistor.GetLicensePlate(_bagGID);
                        //}

                        //if (_licensePlate != string.Empty && _licensePlate != "0000000000" && _licensePlate!="9999999999")
                        //    lblBagTagNumber.Text = _licensePlate;

                        //#region display bag reoccurance count
                        //if (_licensePlate != string.Empty)
                        //{
                        //    if (init.AppInit.MsgHandler.DBPersistor.GetBagReOccuranceCount(_bagGID, _licensePlate,
                        //       init.AppInit.MsgHandler.MESStationName) >=
                        //        init.AppInit.MsgHandler.DBPersistor.ClassParameters.BagReoccurance)
                        //    {
                        //        //lblMessage.Text = "(" + Properties.Resources.sMessageBagReoccurance +
                        //        //    init.AppInit.MsgHandler.DBPersistor.ClassParameters.BagReoccurance.ToString() + " times.)";
                        //        alarmMessage =  Properties.Resources.sMessageBagReoccurance +
                        //                init.AppInit.MsgHandler.DBPersistor.ClassParameters.BagReoccurance.ToString() + " times ";
                        //        isAlarm = true;
                        //        _isAlarm = true;
                        //        alarmCount = 0;

                        //        if (logger.IsDebugEnabled)
                        //            logger.Debug("[DEBUG] Bag Reoccurance count is exceeded. <" + _className + " MES Station Name = " + init.AppInit.MsgHandler.MESStationName +".ProcessIncomingMessage()>");
                              
                        //    }
                        //}
                        //#endregion

                        //#region check bag get BSM or not
                        //if (init.AppInit.MsgHandler.DBPersistor.GetBagNoBSMReOccuranceCount(_bagGID, _licensePlate,
                        //    init.AppInit.MsgHandler.DBPersistor.ClassParameters.SortReasonNBSM,
                        //    init.AppInit.MsgHandler.DBPersistor.ClassParameters.NoBSMReoccurance,
                        //    init.AppInit.MsgHandler.MESStationName) == 1)
                        //{
                        //    lblMessage.Text = "(Consecutive " +
                        //        init.AppInit.MsgHandler.DBPersistor.ClassParameters.NoBSMReoccurance.ToString() +
                        //        " bags without BSM are detected.)";
                        //    _isAlarm = true;
                        //    alarmCount = 0;
                        //}
                        //#endregion

                        //lblReason.Text = init.AppInit.MsgHandler.DBPersistor.GetReason(
                        //    init.AppInit.MsgHandler.DBPersistor.GetInfoReason(_bagGID, _licensePlate));

                        //_sortedReason = init.AppInit.MsgHandler.DBPersistor.GetInfoReason(_bagGID, _licensePlate);

                        //if (lblReason.Text == string.Empty)
                        //    tmrSortReason.Enabled = true; 

                        #region prepare to encode

                        //txtTagInput.Enabled = true;
                        //txtFlightInput.Enabled = true;
                        //txtDestInput.Enabled = true;
                        //btnRepeat.Enabled = false;
                        //btnRemove.Enabled = true;

                        btnRemove.Enabled = true;
                        btnDispatch.Enabled = true;

                        #endregion

                        isBtnEnter = false;

                        //GetPassengerInfo(true, true);

                        //_isProblemEncoded = false;

                        SetFocusToActiveTextbox();
                        
                    }
                    catch (Exception ex)
                    {
                        if (logger.IsErrorEnabled)
                            logger.Error("Fail to decode telegram. <" + _className + ".ProcessIncomingMessage>", ex);
                    }
                }
                                
            }
        }

        //private void AutoEncodeByTag()
        //{
        //    if (string.Compare(txtTagInput.Text.Trim(), string.Empty) == 0 && string.Compare(txtFlightInput.Text.Trim(), string.Empty) == 0 && string.Compare(txtDestInput.Text.Trim(), string.Empty) == 0)
        //        return;

        //    fromScreenKeyboard = true;

        //    string dest = string.Empty;

        //    btnRepeat.Enabled = false;

        //    //if (!btnRepeat.Enabled)
        //    //    isRepeat = false;

        //    lblMessage.Text = "";

        //    //_lastInput = string.Empty;
        //    //_lastEncodeMode = "Tag";

        //    //ClearInfoWhenShiftEncodeMode();

        //    if (init.CheckTagFormat(txtTagInput.Text) == false)
        //    {
        //        lblMessage.Text = "(" + Properties.Resources.sErrorInvalidFormat + ")";
        //        lblMessage.ForeColor = Color.Red;
        //        displayMessageCheck = DateTime.Now;
        //        tmrMessageHandler.Enabled = true;
        //    }
        //    else
        //    {
        //        if (logger.IsDebugEnabled)
        //            logger.Debug("[DEBUG] Enter button is activated for Encode by Tag (" +
        //                    txtTagInput.Text + "). <" + _className + ".btnEnter_Click()>");

        //        bool isMultiBSM = GetPassengerInfo(false, true);
        //        multipleBSM = isMultiBSM;

        //        if (!isMultiBSM)
        //            GetTagReason();

        //        if (lblBagTagNumber.Text.Trim() == "")
        //        {
        //            lblBagTagNumber.Text = txtTagInput.Text;
        //        }

        //    }

        //    init.AppInit.MsgHandler.DBPersistor.AlertEncodingDuration(
        //    init.AppInit.MsgHandler.DBPersistor.ClassParameters.EncodeDurationAlarmType,
        //    init.AppInit.MsgHandler.DBPersistor.ClassParameters.EquipmentID);

        //}

        /// <summary>
        /// Update PLC connection status on screen (Online / Offline).
        /// </summary>
        /// <param name="lblStatus"></param>
        /// <param name="e"></param>
        public delegate void DisplayStatusDelegate(Label lblStatus, MessageEventArgs e);
        private void DisplayStatus(Label lblStatus, MessageEventArgs e)
        {
            if (lblStatus.InvokeRequired)
            {
                DisplayStatusDelegate deleg = new DisplayStatusDelegate(DisplayStatus);
                this.Invoke(deleg, new object[] { lblStatus, e });
            }
            else
            {
                if (init.AppInit.MsgHandler._isPLCConnected)
                {
                    if (lblStatus.Text == "Offline")
                    {
                        lblStatus.BackColor = Color.Lime;
                        lblStatus.Text = "Online";

                        isConnected = true;
                    }
                }
                else
                {
                    if (lblStatus.Text == "Online")
                    {
                        lblStatus.BackColor = Color.Red;
                        lblStatus.Text = "Offline";

                        isConnected = false;
                    }
                }
            }
        }

        /// <summary>
        /// Envent triggerred when connected to DB.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Initializer_OnDBConnected(object sender, EventArgs e)
        {
            DisplayDBConnectStatus(lblSACStatus, e);
        }

        public delegate void DisplayDBConnectStatusDelegate(Label lblStatus, EventArgs e);
        private void DisplayDBConnectStatus(Label lblStatus, EventArgs e)
        {
            if (lblStatus.InvokeRequired)
            {
                DisplayDBConnectStatusDelegate deleg = new DisplayDBConnectStatusDelegate(DisplayDBConnectStatus);
                this.Invoke(deleg, new object[] { lblStatus, e });
            }
            else
            {
                lblStatus.BackColor = Color.Lime;
                lblStatus.Text = "Online";
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.UIConnected = true;
            }
        }

        /// <summary>
        /// Envent triggerred when disconnected from DB.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Initializer_OnDBDisConnected(object sender, EventArgs e)
        {
            DisplayDBDisConnectStatus(lblSACStatus, e);
        }

        public delegate void DisplayDBDisConnectStatusDelegate(Label lblStatus, EventArgs e);
        private void DisplayDBDisConnectStatus(Label lblStatus, EventArgs e)
        {
            if (lblStatus.InvokeRequired)
            {
                DisplayDBDisConnectStatusDelegate deleg = new DisplayDBDisConnectStatusDelegate(DisplayDBDisConnectStatus);
                this.Invoke(deleg, new object[] { lblStatus, e });
            }
            else
            {
                lblStatus.BackColor = Color.Red;
                lblStatus.Text = "Offline";
            }
        }

        /// <summary>
        /// Checking input chracter is numeric or not.
        /// </summary>
        /// <param name="InputCharacter">Input character with the type of System.String</param>
        /// <returns>Return boolean value false if input character is numeric. If not, return true 
        /// to ignore the input character. This function will taking care of backspace and space as well.
        /// It will allow user to press backspace and space on the key board.
        /// </returns>
        private bool CheckNumeric(string InputCharacter)
        {
            Regex AllowChar = new Regex(@"\D");
            if ((InputCharacter != "\b") && (InputCharacter != " "))
            {
                if (AllowChar.IsMatch(InputCharacter))
                    return true;
                else
                    return false;
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// Clear all information store in memory and on screen.
        /// </summary>
        private void ClearAll()
        {
            _destination = string.Empty;
            _plcIndex = string.Empty;

            txtTagInput.Text = string.Empty;
            lblFlight.Text = string.Empty;
            lblFlightDest.Text = string.Empty;
            lblTravelClass.Text = string.Empty;
            lblPassengerName.Text = string.Empty;
            lblDestination.Text = string.Empty;
            lblSortReason1.Text = string.Empty;
            lblGID.Text = string.Empty;

            txtFlightInput.Text = string.Empty;
            lblSTD.Text = string.Empty;
            lblETD.Text = string.Empty;
            lblFlightDestination.Text = string.Empty;
            lblFlightStats.Text = string.Empty;
            lblSortDest.Text = string.Empty;
            lblSortReason2.Text = string.Empty;

            txtAirlineInput.Text = string.Empty;
            lblSortDest.Text = string.Empty;
            lblSortReason3.Text = string.Empty;

            txtDestInput.Text = string.Empty;
            lblSortReason4.Text = string.Empty;

            txtProbBagDest.Text = string.Empty;
        }

        //private void ClearInfoWhenShiftEncodeMode()
        //{
        //    _destination = string.Empty;
        //    lblReason.Text = "";
        //    lblFlight.Text = "";
        //    lblFlightDest.Text = "";
        //    lblTravelClass.Text = "";
        //    lblPassengerName.Text = "";
        //    lblDestination.Text = "";
        //}

        /// <summary>
        /// Common event handler for all airline function buttons.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void AirlineFunction_Click(object sender, EventArgs e)
        {
            fromScreenKeyboard = true;

            lblMessage.Text = "";
            //if ((txtAirlineInput.Enabled == true || txtFlightInput.Enabled == true) && isConnected)
            if (txtAirlineInput.Enabled == true || txtFlightInput.Enabled == true)
            {
                switch (lblEncodingMode.Text)
                {
                    case "Tag #":
                        break;
                    case "Flight #":
                        txtFlightInput.Text = ((Button)sender).Text;
                        if (((Button)sender).Tag != null)
                        {
                            txtFlightInput.Tag = ((Button)sender).Tag.ToString();
                        }
                        txtFlightInput.SelectionStart = txtFlightInput.Text.Length;
                        break;
                    case "Airline":
                        txtAirlineInput.Text = ((Button)sender).Text;
                        if (((Button)sender).Tag != null)
                        {
                            txtAirlineInput.Tag = ((Button)sender).Tag.ToString();
                        }
                        txtAirlineInput.SelectionStart = txtAirlineInput.Text.Length;
                        btnEnter_Click(sender, e);
                        break;
                    case "Destination":
                        break;
                    case "Problem Bag":
                        break;
                }

                SetFocusToActiveTextbox();
            }
        }

        /// <summary>
        /// Common event handler for all destination function buttons.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DestinationFunction_Click(object sender, EventArgs e)
        {
            fromScreenKeyboard = true;

            lblMessage.Text = "";
            if (txtDestInput.Enabled == true && isConnected)
            {
                switch (lblEncodingMode.Text)
                {
                    case "Tag #":
                        break;
                    case "Flight #":
                        break;
                    case "Airline":
                        break;
                    case "Destination":
                         txtDestInput.Text = ((Button)sender).Text;
                        if (((Button)sender).Tag != null)
                        {
                            txtDestInput.Tag = ((Button)sender).Tag.ToString();
                        }
                        txtDestInput.SelectionStart = txtDestInput.Text.Length;

                        btnEnter_Click(sender, e);
                        break;
                    case "Problem Bag":
                        break;
                }

                SetFocusToActiveTextbox();
            }
        }

        /// <summary>
        /// Load airlines from airline tables and set all the 2 characters airline code to 
        /// airline function buttons on the form.
        /// </summary>
        private void PrepareAirlineFunctionButtons(int page)
        {
            int i = 0, count = 1;
            try
            {
                DataTable dtAirlines = init.AppInit.MsgHandler.DBPersistor.GetAirlines();

                if (Convert.ToInt32(dtAirlines.Rows.Count / 34) < page)
                {
                    page = 0;
                    airlinePage = 0;
                }

                if (dtAirlines.Rows.Count > 0)
                {
                        for (i = (34 * page + 1); i <= (34 * (page + 1)); i++)
                        {
                            tabPageAirline.Controls["btnAirline" + (count).ToString()].Text = string.Empty;
                            tabPageAirline.Controls["btnAirline" + (count).ToString()].Tag = string.Empty;
                            tabPageAirline.Controls["btnAirline" + (count).ToString()].Enabled = true;

                            if (dtAirlines.Rows.Count >= i)
                            {
                                tabPageAirline.Controls["btnAirline" + (count).ToString()].Text = dtAirlines.Rows[i-1][0].ToString();
                                tabPageAirline.Controls["btnAirline" + (count).ToString()].Tag = dtAirlines.Rows[i-1][1].ToString();
                            }
                            else
                            {
                                tabPageAirline.Controls["btnAirline" + (count).ToString()].Text = init.ClassParameters.AirlineShortcutDisableConstant;
                                tabPageAirline.Controls["btnAirline" + (count).ToString()].Enabled = false;
                            }

                            count += 1;                             
                       }            
                                   
                }
                else
                {
                    if (dtAirlines.Rows.Count <= 0)
                    {
                        for (int j = 0; j < 34; j++)
                        {
                            tabPageAirline.Controls["btnAirline" + (j + 1).ToString()].Text = init.ClassParameters.AirlineShortcutDisableConstant;
                            tabPageAirline.Controls["btnAirline" + (j + 1).ToString()].Enabled = false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Fail to prepare airline functions. <" + _className + ".PrepareAirlineFunctionButtons()>", ex);
            }
        }

        /// <summary>
        /// Load destinations and set all the characters destination code to 
        /// destination function buttons on the form.
        /// </summary>
        private void PrepareDestinationFunctionButtons()
        {
            int i = 0;
            try
            {
                //DataTable dtDest = init.AppInit.MsgHandler.DBPersistor.GetDestination(txtDestInput.Text.Trim(),
                //            init.AppInit.MsgHandler.TTS);

                //if (dtDest.Rows.Count > 0)
                //{
                //    for (i = 0; i < dtDest.Rows.Count; i++)
                //    {
                //        tabPageDestination.Controls["btnDest" + (i + 1).ToString()].Text = dtDest.Rows[i][0].ToString();
                //        tabPageDestination.Controls["btnDest" + (i + 1).ToString()].Enabled = true;
                //    }
                //    for (int j = i; j < 25; j++)
                //    {
                //        tabPageDestination.Controls["btnDest" + (j + 1).ToString()].Text = init.ClassParameters.AirlineShortcutDisableConstant;
                //        tabPageDestination.Controls["btnDest" + (j + 1).ToString()].Enabled = false;
                //    }
                //}
                //else
                //{
                //    if (dtDest.Rows.Count <= 0)
                //    {
                //        for (int j = 0; j < 25; j++)
                //        {
                //            tabPageDestination.Controls["btnDest" + (j + 1).ToString()].Text = init.ClassParameters.AirlineShortcutDisableConstant;
                //            tabPageDestination.Controls["btnDest" + (j + 1).ToString()].Enabled = false;
                //        }
                //    }
                //}

                AllDestination[] destinations = init.ClassParameters.allDest;

                if (destinations.Length > 0)
                {
                    for (i = 0; i < destinations.Length; i++)
                    {
                        tabPageDestination.Controls["btnDest" + (i + 1).ToString()].Text = destinations[i].DestID;
                        if (destinations[i].DestColor != "Normal")
                            tabPageDestination.Controls["btnDest" + (i + 1).ToString()].BackColor = Color.FromName(destinations[i].DestColor);
                        if (destinations[i].IsActive == "1")
                            tabPageDestination.Controls["btnDest" + (i + 1).ToString()].Enabled = true;
                        else if (destinations[i].IsActive == "0")
                            tabPageDestination.Controls["btnDest" + (i + 1).ToString()].Enabled = false;                        
                    }
                }
                
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Fail to prepare detination functions. <" + _className + ".PrepareDestinationFunctionButtons()>", ex);
            }
        }
        
        /// <summary>
        /// Get passenger information detail from database and display on the screen.
        /// </summary>
        private bool  GetPassengerInfo()
        {
            try
            {
                lblMessage.Text = string.Empty;
                lblFlight.Text = string.Empty;
                lblFlightDest.Text = string.Empty;
                lblTravelClass.Text = string.Empty;
                lblPassengerName.Text = string.Empty;
                lblDestination.Text = string.Empty;
                lblSortReason1.Text = string.Empty;

                DataTable dtPassengerInfo = init.AppInit.MsgHandler.DBPersistor.GetPassengerInfo(txtTagInput.Text);

                // Moved by Guo Wenyu 2014/03/23
                if (logger.IsInfoEnabled)
                {
                    if (dtPassengerInfo != null)
                        logger.Debug("[INFO] Getting passenger info... [licensePlate = " + txtTagInput.Text + ", GID = " +
                                _bagGID + ", Returned PassengerInfo Records = " +
                                dtPassengerInfo.Rows.Count.ToString() + "]. <" + _className + ".GetPassengerInfo()>");
                    else
                        logger.Debug("[INFO] Getting passenger info... [licensePlate = " + _licensePlate + ", GID = " +
                                _bagGID + ", Returned PassengerInfo Records = 0]. <" +
                                _className + ".GetPassengerInfo()>");
                }

                if (dtPassengerInfo.Rows[0][5].ToString() == string.Empty)
                {
                    lblFlight.Text = dtPassengerInfo.Rows[0][2].ToString() + dtPassengerInfo.Rows[0][3].ToString();
                    lblTravelClass.Text = dtPassengerInfo.Rows[0][1].ToString();
                    lblPassengerName.Text = dtPassengerInfo.Rows[0][0].ToString();
                    lblFlightDest.Text = dtPassengerInfo.Rows[0][4].ToString();

                    return true;
                }
                else
                {
                    // MessageBox.Show(dtPassengerInfo.Rows[0][5].ToString().Trim().Trim() , "Warning", MessageBoxButtons.OK);

                     return false;
                }

                # region 07/03/2014 - Not applicable for CLT & OKC MES
                //else if (dtPassengerInfo.Rows.Count > 1)
                    //{
                        //if (!bAuto)
                        //{
                        //    if (bTelegramReceived == false)
                        //    {
                        //        Selection frmPassengerSelection = new Selection(dtPassengerInfo, lblEncodingMode.Text, _licensePlate, _bagGID, init.AppInit.MsgHandler.isHLCMode);
                        //        if (frmPassengerSelection.ShowDialog() == DialogResult.OK)
                        //        {
                        //            if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(frmPassengerSelection.sDestination, frmPassengerSelection.sDestinationID, init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
                        //            {

                        //                lblFlight.Text = frmPassengerSelection.sFlightNumber;
                        //                lblTravelClass.Text = frmPassengerSelection.sTravelClass;
                        //                lblPassengerName.Text = frmPassengerSelection.sPassengerName;
                        //                lblFlightDest.Text = frmPassengerSelection.sFlightDestination;
                        //                lblDestination.Text = frmPassengerSelection.sDestination;
                        //                lblDestination.Tag = frmPassengerSelection.sDestinationID;
                        //            }
                        //            else
                        //            {
                        //                if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
                        //                {

                        //                    lblFlight.Text = frmPassengerSelection.sFlightNumber;
                        //                    lblTravelClass.Text = frmPassengerSelection.sTravelClass;
                        //                    lblPassengerName.Text = frmPassengerSelection.sPassengerName;
                        //                    lblFlightDest.Text = frmPassengerSelection.sFlightDestination;
                        //                    lblDestination.Text = frmPassengerSelection.sDestination;
                        //                    lblDestination.Tag = frmPassengerSelection.sDestinationID;
                        //                }
                        //            }
                        //        }
                        //        frmPassengerSelection.Dispose();
                        //        frmPassengerSelection = null;
                        //    }
                        //    else
                        //    {
                        //        DateTime dtTemp;
                        //        if (DateTime.TryParse(dtPassengerInfo.Rows[0][4].ToString(), out dtTemp))
                        //        {
                        //            lblFlight.Text = dtPassengerInfo.Rows[0][2].ToString() + dtPassengerInfo.Rows[0][3].ToString() + ", " +
                        //            dtTemp.ToString(init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateTimeFormat); 
                        //        }
                        //        else
                        //        {
                        //            lblFlight.Text = dtPassengerInfo.Rows[0][2].ToString() + dtPassengerInfo.Rows[0][3].ToString();
                        //        }
                        //        lblTravelClass.Text = dtPassengerInfo.Rows[0][7].ToString();
                        //        lblPassengerName.Text = dtPassengerInfo.Rows[0][10].ToString();
                        //        lblFlightDest.Text = dtPassengerInfo.Rows[0][6].ToString();
                        //        lblDestination.Tag = dtPassengerInfo.Rows[0][8].ToString();
                        //    }
                        //}
                        //else
                        //{
                            //lblMessage.Text = "(" + Properties.Resources.sMessageMultiBSMforMES + ")";
                            //lblMessage.ForeColor = Color.Teal;
                            //return true;
                        //}
                    //}
                    //else
                    //{
                    //    lblMessage.Text = "(" + Properties.Resources.sErrorItemNotfound + ")";
                    //    lblMessage.ForeColor = Color.Red;
                    //    displayMessageCheck = DateTime.Now;
                    //    tmrMessageHandler.Enabled = true;
                //}
                #endregion

            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Fail to retrieve passenger info. <" + _className + ".GetPassengerInfo()>", ex);
                return false;
            }
        }

       

        /// <summary>
        /// Get Flight information detail from database and display on the screen
        /// </summary>
        /// <returns></returns>
        private bool GetFlightInfo(string strCarrier, string strFlightNo, string strSDO)
        {
            lblSTD.Text = string.Empty;
            lblETD.Text = string.Empty;
            lblFlightDestination.Text = string.Empty;
            lblFlightStats.Text = string.Empty;
            blSortDest.Text = string.Empty;
            lblSortReason2.Text = string.Empty;

            DataTable dtFlightInfo = init.AppInit.MsgHandler.DBPersistor.GetFlightInfo(strCarrier, strFlightNo, strSDO);

            // the codes move by Guo Wenyu 2014/03/23
            // the original code cannot be reached
            if (logger.IsInfoEnabled)
                if (dtFlightInfo != null)
                    logger.Debug("[INFO] Getting flight info... [Flight # = " + txtFlightInput.Text + ", GID = " +
                            _bagGID + ", Returned FlightInfo Records = " +
                            dtFlightInfo.Rows.Count.ToString() + "]. <" + _className + ".dtFlightInfo()>");
                else
                    logger.Debug("[INFO] Getting flight info... [Flight # = " + txtFlightInput.Text + ", GID = " +
                            _bagGID + ", Returned Flight Info Records = 0]. <" +
                            _className + ".dtFlightInfo()>");

            if (dtFlightInfo.Rows[0][4].ToString() == string.Empty)
            {
                lblSTD.Text = dtFlightInfo.Rows[0][0].ToString();
                lblETD.Text = dtFlightInfo.Rows[0][1].ToString();
                lblFlightDestination.Text = dtFlightInfo.Rows[0][2].ToString();
                lblFlightStats.Text = dtFlightInfo.Rows[0][3].ToString();

                return true;
            }
            else
            {
                MessageBox.Show(dtFlightInfo.Rows[0][4].ToString().Trim().Trim(), "Warning", MessageBoxButtons.OK);

                return false;
            }

            
        }

        /// <summary>
        /// Get Airline information detail from database and display on the screen
        /// </summary>
        /// <param name="strCarrier"></param>
        /// <returns></returns>
        private bool IsExistAirlineInfo(string strCarrier)
        {
            lblSortDest.Text = string.Empty;
            lblSortReason3.Text = string.Empty;

            DataTable dtAirlineInfo = init.AppInit.MsgHandler.DBPersistor.GetAirlineInfo(strCarrier, "");

            if (logger.IsInfoEnabled)
                if (dtAirlineInfo != null)
                    logger.Debug("[INFO] Getting Airline info... [Airline # = " + txtAirlineInput.Text + ", GID = " +
                            _bagGID + ", Returned Airline Info Records = " +
                            dtAirlineInfo.Rows.Count.ToString() + "]. <" + _className + ".dtFlightInfo()>");
                else
                    logger.Debug("[INFO] Getting Airline info... [Airline # = " + txtAirlineInput.Text + ", GID = " +
                            _bagGID + ", Returned Airline Info Records = 0]. <" +
                            _className + ".dtFlightInfo()>");

            if (dtAirlineInfo.Rows[0][0].ToString() == string.Empty)
            {
                return true;
            }
            else
            {
                MessageBox.Show(dtAirlineInfo.Rows[0][0].ToString().Trim().Trim(), "Warning", MessageBoxButtons.OK);
                return false;
            }
        }

        /// <summary>
        /// Get the Airline information according to the ticketing code in license plate
        /// </summary>
        /// <param name="strCarrier"></param>
        /// <returns></returns>
        private string GetPassengerAirline()
        {
            string ticketing_code = txtTagInput.Text.Trim().Substring(1, 3);

            DataTable dtAirlineInfo = init.AppInit.MsgHandler.DBPersistor.GetAirlineInfo("", ticketing_code);

            if (logger.IsInfoEnabled)
                if (dtAirlineInfo != null)
                    logger.Debug("[INFO] Getting Airline by Tag info... [Tag # = " + txtTagInput.Text + ", Ticketing Code = " + ticketing_code 
                        + " GID = " + _bagGID + ", Returned Airline Info Records = " +
                            dtAirlineInfo.Rows.Count.ToString() + "]. <" + _className + ".dtFlightInfo()>");
                else
                    logger.Debug("[INFO] Getting Airline by Tag info... [Tag # = " + txtTagInput.Text + ", Ticketing Code = " + ticketing_code 
                        + ", GID = " + _bagGID + ", Returned Airline Info Records = 0]. <" +
                            _className + ".dtFlightInfo()>");

            if (dtAirlineInfo.Rows[0][0].ToString() == string.Empty)
            {
                string airline = dtAirlineInfo.Rows[0][1].ToString();
                //MessageBox.Show("This bag can be sorted by Ticketing Code", "Warning", MessageBoxButtons.OK);
                return airline;
            }
            //else
            //{
            //    MessageBox.Show(dtAirlineInfo.Rows[0][0].ToString().Trim().Trim(), "Warning", MessageBoxButtons.OK);
            //    return false;
            //}

            return string.Empty;
        }

        /// <summary>
        /// Get bag destination and reason from sortation control.
        /// </summary>
        //private bool GetDestinationNReason(ref int rushType, ref string dest)
        //{
        //    try
        //    {
        //        string sReason = string.Empty;

        //        if (lblEncodingMode.Text == "Rush Dest.")
        //        {
        //            string temp = string.Empty;
        //            txtFlightInput.Tag = init.AppInit.MsgHandler.DBPersistor.GetAirlineTicketingCode(txtFlightInput.Text);


        //            if (txtFlightInput.Tag == null)
        //            {
        //                temp = string.Empty;
        //            }
        //            else
        //            {
        //                temp = txtFlightInput.Tag.ToString();
        //            }


        //            LocationID[] probDest = init.AppInit.MsgHandler.GetRushDestination(temp, _bagGID, ref sReason, ref rushType);
                                       

        //            if (CheckDestination(probDest) == false)
        //            {
        //                if (probDest.Length > 1)
        //                {
        //                    Selection frmRushDestSelection = new Selection(probDest);
        //                    if (frmRushDestSelection.ShowDialog() == DialogResult.OK)
        //                    {
        //                        DataTable dtRushDestination = GetDestinationList(frmRushDestSelection.sRushDestination);
        //                        if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(dtRushDestination.Rows[0][2].ToString(), dtRushDestination.Rows[0][1].ToString(), init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
        //                        {
        //                            lblDestination.Text = dtRushDestination.Rows[0][2].ToString();
        //                            lblDestination.Tag = dtRushDestination.Rows[0][1].ToString();
        //                            lblFlightDest.Tag = dtRushDestination.Rows[0][3].ToString();
        //                        }
        //                        else
        //                        {
        //                            if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
        //                            {
        //                                lblDestination.Text = dtRushDestination.Rows[0][2].ToString();
        //                                lblDestination.Tag = dtRushDestination.Rows[0][1].ToString();
        //                                lblFlightDest.Tag = dtRushDestination.Rows[0][3].ToString();
        //                            }
        //                        }

        //                    }
        //                    frmRushDestSelection.Dispose();
        //                    frmRushDestSelection = null;
        //                }
        //                else if (probDest.Length == 1)
        //                {
        //                    DataTable dtRushDestination = GetDestinationList(probDest);
        //                    if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(dtRushDestination.Rows[0][2].ToString(), dtRushDestination.Rows[0][1].ToString(), init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
        //                    {
        //                        lblDestination.Text = dtRushDestination.Rows[0][2].ToString();
        //                        lblDestination.Tag = dtRushDestination.Rows[0][1].ToString();
        //                        lblFlightDest.Tag = dtRushDestination.Rows[0][3].ToString();
        //                    }
        //                    else
        //                    {
        //                        if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
        //                        {
        //                            lblDestination.Text = dtRushDestination.Rows[0][2].ToString();
        //                            lblDestination.Tag = dtRushDestination.Rows[0][1].ToString();
        //                            lblFlightDest.Tag = dtRushDestination.Rows[0][3].ToString();
        //                        }
        //                    }
                           
        //                }

        //                lblReason.Text = init.AppInit.MsgHandler.DBPersistor.GetReason(sReason);
        //                lblReason.Tag = sReason;
        //                dest = lblDestination.Text;

        //                if (rushType == 1)
        //                {
        //                    //Airline Rush Allocation
        //                    if (logger.IsDebugEnabled)
        //                        logger.Debug("[DEBUG] Encode bag to Rush destination (" + lblDestination.Text +
        //                            ") allocation to airline (" + txtDestInput.Text + "). <" + _className + ".GetDestinationNReason()>");
        //                }
        //                else if (rushType == 2)
        //                {
        //                    //Global Rush Function Allocation
        //                    if (logger.IsDebugEnabled)
        //                        logger.Debug("[DEBUG] Encode bag to global Rush function allocation (" + lblDestination.Text +
        //                            ") as No Rush destination assigned to Airline (" + txtDestInput.Text + "). <" + _className + ".GetDestinationNReason()>");
        //                }

        //                return true;
        //            }
        //            else
        //            {
        //                //Airline Rush Allocation
        //                if (logger.IsDebugEnabled)
        //                    logger.Debug("[DEBUG] No any Rush destination is available. <" + _className + ".GetDestinationNReason()>");

        //                return false;
        //            }
        //        }
        //        else
        //        {
        //            //Sortation
        //            BHS.MES.LocationID[] destination = init.AppInit.MsgHandler.GetDestination(_bagGID, _licensePlate, out sReason);
        //            if (CheckDestination(destination) == false)
        //            {
        //                if (destination.Length > 1)
        //                {
        //                    Selection frmDestinationSelection = new Selection(GetDestinationList(destination), "Sort Dest.", _licensePlate, _bagGID, init.AppInit.MsgHandler.isHLCMode);
        //                    if (frmDestinationSelection.ShowDialog() == DialogResult.OK)
        //                    {
        //                        if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(frmDestinationSelection.sDestination, frmDestinationSelection.sDestinationID, init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
        //                        {
        //                            lblDestination.Text = frmDestinationSelection.sDestination;
        //                            lblDestination.Tag = frmDestinationSelection.sDestinationID;
        //                            lblFlightDest.Tag = frmDestinationSelection.sSubSystem;
        //                        }
        //                        else
        //                        {
        //                            if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
        //                            {
        //                                lblDestination.Text = frmDestinationSelection.sDestination;
        //                                lblDestination.Tag = frmDestinationSelection.sDestinationID;
        //                                lblFlightDest.Tag = frmDestinationSelection.sSubSystem;
        //                            }
        //                        }
                            
        //                    }
        //                    frmDestinationSelection.Dispose();
        //                    frmDestinationSelection = null;
        //                }
        //                else if (destination.Length == 1)
        //                {
        //                    DataTable dtDestination = GetDestinationList(destination);
        //                    if (dtDestination.Rows.Count > 0)
        //                    {
        //                        if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(dtDestination.Rows[0][1].ToString(), dtDestination.Rows[0][0].ToString(), init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
        //                        {
        //                            lblDestination.Text = dtDestination.Rows[0][1].ToString();
        //                            lblDestination.Tag = dtDestination.Rows[0][0].ToString();
        //                            lblFlightDest.Tag = dtDestination.Rows[0][2].ToString();
        //                        }
        //                        else
        //                        {
        //                            if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
        //                            {
        //                                lblDestination.Text = dtDestination.Rows[0][1].ToString();
        //                                lblDestination.Tag = dtDestination.Rows[0][0].ToString();
        //                                lblFlightDest.Tag = dtDestination.Rows[0][2].ToString();
        //                            }
        //                        }
                              
        //                    }
        //                }
        //                lblReason.Text = init.AppInit.MsgHandler.DBPersistor.GetReason(sReason);
        //                lblReason.Tag = sReason;
        //            }
        //            else
        //            {
        //                lblReason.Text = init.AppInit.MsgHandler.DBPersistor.GetReason(sReason);
        //                lblReason.Tag = sReason;
        //            }
        //            lblReason.Text = sReason;
        //            dest = lblDestination.Text;

        //            return true;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        if (logger.IsErrorEnabled)
        //            logger.Error("Fail to retrieve destination and reason. <" + _className + ".GetDestinationNReason>", ex);

        //        return false;
        //    }
        //}

        /// <summary>
        /// Get problem sort destination from sortation engine
        /// </summary>
        private bool GetProblemDestination()
        {
            string sReason = string.Empty;
            bool isEmpty = false;
            LocationID[] probDest = init.AppInit.MsgHandler.GetProblemDestination(_bagGID, out sReason);

            if (probDest != null)
            {
                if (probDest.Length > 1)
                {
                    Selection frmProblemDestSelection = new Selection(GetDestinationList(probDest), "Sort Dest.", _licensePlate, _bagGID, init.AppInit.MsgHandler.isHLCMode);
                    if (frmProblemDestSelection.ShowDialog() == DialogResult.OK)
                    {
                        if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(frmProblemDestSelection.sDestination, frmProblemDestSelection.sDestinationID, init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
                        {
                            lblDestination.Text = frmProblemDestSelection.sDestination;
                            lblDestination.Tag = frmProblemDestSelection.sDestinationID;
                            lblFlightDest.Tag = frmProblemDestSelection.sSubSystem;
                        }
                        else
                        {
                            if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
                            {
                                lblDestination.Text = frmProblemDestSelection.sDestination;
                                lblDestination.Tag = frmProblemDestSelection.sDestinationID;
                                lblFlightDest.Tag = frmProblemDestSelection.sSubSystem;
                            }
                        }
                    }
                    frmProblemDestSelection.Dispose();
                    frmProblemDestSelection = null;
                }
                else if (probDest.Length == 1)
                {
                    DataTable dtDestination = GetDestinationList(probDest);
                    if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(dtDestination.Rows[0][2].ToString(), dtDestination.Rows[0][1].ToString(), init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
                    {
                        lblDestination.Text = dtDestination.Rows[0][2].ToString();
                        lblDestination.Tag = dtDestination.Rows[0][1].ToString();
                        lblFlightDest.Tag = dtDestination.Rows[0][3].ToString();
                    }
                    else
                    {
                        if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
                        {
                            lblDestination.Text = dtDestination.Rows[0][2].ToString();
                            lblDestination.Tag = dtDestination.Rows[0][1].ToString();
                            lblFlightDest.Tag = dtDestination.Rows[0][3].ToString();
                        }
                    }
                }
                isEmpty = true;
            }
            else
            {
                lblMessage.Text = "(" + Properties.Resources.sErrorUnknownDest + ")";
                lblMessage.ForeColor = Color.Red;
                displayMessageCheck = DateTime.Now;
                tmrMessageHandler.Enabled = true;
                isEmpty = false;
            }

            return isEmpty;
        }
 
        /// <summary>
        /// Dispatch the bag from system
        /// </summary>
        private void ItemDispatch()
        {
            //string sEncodeType = string.Empty;
            //string sReason = string.Empty;
            //string curHBSLevel = string.Empty;
            //string curHBSResult = string.Empty;

            //if (_isProblemEncoded)
            //    _encodeMode = "Problem";

            //switch (_encodeMode)
            //{
            //    case "Tag":
            //        sEncodeType = init.ClassParameters.EncodeByTag;
            //        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, _bagGID, _licensePlate, init.AppInit.MsgHandler.ClassParameters.SubSystem,
            //            init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, sEncodeType, "Encode by Tag");
            //        break;
            //    case "Flight":
            //        sEncodeType = init.ClassParameters.EncodeByFlight;
            //        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, _bagGID, _licensePlate, init.AppInit.MsgHandler.ClassParameters.SubSystem,
            //            init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, sEncodeType, "Encode by Flight");
            //        break;
            //    case "Sort Dest.":
            //        sEncodeType = init.ClassParameters.EncodeByDestination;
            //        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, _bagGID, _licensePlate, init.AppInit.MsgHandler.ClassParameters.SubSystem,
            //            init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, sEncodeType, "Encode by Destination");
            //        break;
            //    case "Rush Dest.":
            //        sEncodeType = init.ClassParameters.EncodeByRush;
            //        lblReason.Tag = init.AppInit.MsgHandler.DBPersistor.ClassParameters.SortReasonRUSH;
            //        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, _bagGID, _licensePlate, init.AppInit.MsgHandler.ClassParameters.SubSystem,
            //            init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, sEncodeType, "Encode by Rush");
            //        break;
            //    case "Problem":
            //        sEncodeType = init.ClassParameters.EncodeByProblemBag;
            //        lblReason.Tag = init.AppInit.MsgHandler.DBPersistor.ClassParameters.SortReasonPROB;
            //        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, _bagGID, _licensePlate, init.AppInit.MsgHandler.ClassParameters.SubSystem,
            //            init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, sEncodeType, "Encode by Problem");
            //        break;
            //}

            //if (lblReason.Tag != null)
            //{
            //    sReason = lblReason.Tag.ToString();
            //}

            //_licensePlate = lblBagTagNumber.Text;

            //if (_licensePlate == "" || _licensePlate == string.Empty)
            //{
            //    _licensePlate = "0000000000";
            //}

            if (logger.IsDebugEnabled)
                logger.Debug("[DEBUG] Sending IEC message to PLC... <" + _className + ".ItemDispatch()>");

            //if (!lblDestination.Text.Contains("EDS"))
            //{
            //    if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.EnableHBS2BSysKey)
            //    {
            //        if ((curHBSLevel == "0") || (curHBSLevel == null))
            //            curHBSLevel = "5";

            //        if ((curHBSResult == string.Empty) || (curHBSResult == null))
            //            curHBSResult = "A";
            //    }
            //    else
            //    {
            //        if ((curHBSLevel == null))
            //            curHBSLevel = "0";

            //        if ((curHBSResult == string.Empty) || (curHBSResult == null))
            //            curHBSResult = "A";
            //    }
            //}

            string strTagNo = string.Empty, strFlightNo = string.Empty, strCarrier = string.Empty, strEncodeType = string.Empty;
            
            // Modified by Guo Wenyu 2014/03/23
            // Assign strTagNo with txtTagInput.Text for each sortation mode, 
            // so that bags can be traced by license plate as long as Operators scan the tags
            switch (lblEncodingMode.Text)
            {
                case "Tag #":
                    strTagNo = txtTagInput.Text;
                    strEncodeType = "1";
                    break;
                case "Flight #":
                    //Added by Guo Wenyu 2014/03/23
                    strTagNo = txtTagInput.Text;

                    #region split the string in txtFlightInput.Text into Airline and Flight - Guo Wenyu 2014/03/20
                    //Commented by Guo Wenyu 2014/03/20
                    //if (txtFlightInput.Text.Trim().Substring(3, 1) != string.Empty)
                    //{
                    //    strCarrier = txtFlightInput.Text.Trim().Substring(0, 3);
                    //    strFlightNo = txtFlightInput.Text.Trim().Substring(3, txtFlightInput.Text.Trim().Length - 3);
                    //}
                    //else
                    //{
                    //    strCarrier = txtFlightInput.Text.Trim().Substring(0, 3);
                    //    strFlightNo = txtFlightInput.Text.Trim().Substring(4, txtFlightInput.Text.Trim().Length - 4);
                    //}

                    string[] substr = RegSpaceSplit(txtFlightInput.Text.Trim());
                    if (substr.Length > 0)
                    {
                        if (substr.Length == 1)
                            strCarrier = substr[0];
                        else
                        {
                            strCarrier = substr[0];
                            strFlightNo = substr[1];
                        }
                    }

                    #endregion
                    strEncodeType = "2";
                    break;
                case "Airline":
                    //Added by Guo Wenyu 2014/03/23
                    strTagNo = txtTagInput.Text;

                    strCarrier = txtAirlineInput.Text;
                    strEncodeType = "6";
                    break;
                case "Destination":
                    //Added by Guo Wenyu 2014/03/23
                    strTagNo = txtTagInput.Text;

                    strEncodeType = "3";
                    break;
                case "Problem Bag":
                    //Added by Guo Wenyu 2014/03/23
                    strTagNo = txtTagInput.Text;

                    strEncodeType = "4";
                    break;
            }

            init.AppInit.MsgHandler.SendIEC(int.Parse(_bagGID.Substring(0, 2)), int.Parse(_bagGID.Substring(2, 8)), _destination, _location, int.Parse(_plcIndex), strTagNo, strCarrier, strFlightNo, strEncodeType);

            //_sortedReason = string.Empty;
            //_flightNumber = string.Empty;

            //if (logger.IsDebugEnabled)
            //    logger.Debug("[DEBUG] Updating [BAG_INFO] Table... <" + _className + ".ItemDispatch()>");

            //UpdateBagInfo(_bagGID, _licensePlate, lblDestination.Tag.ToString(), sEncodeType, sReason, _plcIndex, string.Empty);
        }

        /// <summary>
        /// Remove the bag from system
        /// </summary>
        private void ItemRemove()
        {
            if (_bagGID == string.Empty)
            {
                if (logger.IsInfoEnabled)
                    logger.Info("Remove bag failed! Blank bag gid. <" + _className + ".ItemRemove()>");
                lblMessage.Text = "(" + Properties.Resources.sMessageRemoveFail + ")";
                lblMessage.ForeColor = Color.Red;
                return;
            }

            //if (_licensePlate == string.Empty)
            //{
            //    if (logger.IsInfoEnabled)
            //        logger.Info("Encoded by destination failed! Blank iata tag. <" + _className + ".ItemRemove()>");
            //    lblMessage.Text = "(" + Properties.Resources.sMessageRemoveFail + ")";
            //    lblMessage.ForeColor = Color.Red;
            //    return;
            //}

            //init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, _bagGID, _licensePlate, init.AppInit.MsgHandler.ClassParameters.SubSystem,
            //                init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, string.Empty, "Remove Bag");

            if (logger.IsDebugEnabled)
                logger.Debug("[DEBUG] Sending IRM message to PLC... <" + _className + ".ItemRemove()>");

            init.AppInit.MsgHandler.SendIRM(int.Parse(_bagGID.Substring(0, 2)), int.Parse(_bagGID.Substring(2, 8)),_location, int.Parse(_plcIndex));

            //if (logger.IsDebugEnabled)
            //    logger.Debug("[DEBUG] Updating [BAG_INFO] Table... <" + _className + ".ItemRemove()>");

            //UpdateBagInfoForItemRemove(_bagGID, _licensePlate, string.Empty, string.Empty, string.Empty, _plcIndex, string.Empty);
        }

        /// <summary>
        /// Update bag information.
        /// </summary>
        /// <param name="BagGID"></param>
        /// <param name="IATATag"></param>
        /// <param name="Destination"></param>
        /// <param name="EncodeType"></param>
        /// <param name="SortReason"></param>
        /// <param name="PLCIndex"></param>
        /// <param name="MinHBSLevel"></param>
        private void UpdateBagInfo(string BagGID, string IATATag, string Destination, string EncodeType, string SortReason, string PLCIndex,
            string MinHBSLevel)
        {
            DataTable dtBagInfo = init.AppInit.MsgHandler.DBPersistor.UpdateBagInfo(_bagGID, _licensePlate, _plcIndex,
                Destination, EncodeType, SortReason, MinHBSLevel, init.AppInit.MsgHandler.ClassParameters.Location,
                init.AppInit.MsgHandler.ClassParameters.SubSystem);
            if (dtBagInfo != null)
            {
                if (dtBagInfo.Rows.Count > 0)
                {
                    _bagGID = dtBagInfo.Rows[0][0].ToString();
                    _licensePlate = dtBagInfo.Rows[0][1].ToString();
                }
            }
        }

        /// <summary>
        /// Update bag information for item remove.
        /// </summary>
        /// <param name="BagGID"></param>
        /// <param name="IATATag"></param>
        /// <param name="Destination"></param>
        /// <param name="EncodeType"></param>
        /// <param name="SortReason"></param>
        /// <param name="PLCIndex"></param>
        /// <param name="MinHBSLevel"></param>
        private void UpdateBagInfoForItemRemove(string BagGID, string IATATag, string Destination, string EncodeType, string SortReason, string PLCIndex,
            string MinHBSLevel)
        {
            DataTable dtBagInfo = init.AppInit.MsgHandler.DBPersistor.UpdateBagInfoForItemRemove(_bagGID, _licensePlate, _plcIndex,
                Destination, EncodeType, SortReason, MinHBSLevel, init.AppInit.MsgHandler.ClassParameters.Location,
                init.AppInit.MsgHandler.ClassParameters.SubSystem);
        }

        /// <summary>
        /// Change the character buttons' caption character case.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ChangeCharacterCase(object sender, EventArgs e)
        {
            fromScreenKeyboard = true;

            if (_shiftPressed == true)
            {
                _shiftPressed = false;
                for (int i = 65; i < 91; i++)
                {
                    tabPageAlphabet.Controls["btn" + Convert.ToChar((Char)i).ToString()].Text = tabPageAlphabet.Controls["btn" + Convert.ToChar((Char)i).ToString()].Text.ToLower().ToString();
                }
            }
            else
            {
                _shiftPressed = true;
                for (int i = 65; i < 91; i++)
                {
                    tabPageAlphabet.Controls["btn" + Convert.ToChar((Char)i).ToString()].Text = tabPageAlphabet.Controls["btn" + Convert.ToChar((Char)i).ToString()].Text.ToUpper().ToString();
                }
            }
            SetFocusToActiveTextbox();
        }

        /// <summary>
        /// Get the list of destination for user to select.
        /// </summary>
        /// <param name="destination"></param>
        /// <returns></returns>
        private DataTable GetTagDestinationList(BHS.MES.LocationID[] destination)
        {
            DataTable dtDestination = null;
            DataTable dsDB = null;
            try
            {
                dsDB = new DataTable();

                LocationID[] temp = new LocationID[destination.Length];

                dsDB.Columns.Add("Chute", typeof(string));
                
                dsDB.Columns.Add("Destination", typeof(string));
                dsDB.Columns.Add("t2", typeof(string));
                dsDB.Columns.Add("TTSID", typeof(string));
                dsDB.Columns.Add("Is_Available", typeof(string));

                string sTTSIDs = string.Empty;

                for (int i = 0; i < destination.Length; i++)
                {
                    sTTSIDs = destination[i].Location;
                    dtDestination = init.AppInit.MsgHandler.DBPersistor.GetSpecificDestination(sTTSIDs);

                    if (dtDestination.Rows.Count == 0)
                    {
                        return null;
                    }
                    else
                    {
                        dsDB.Rows.Add(dtDestination.Rows[0][0].ToString(), dtDestination.Rows[0][2].ToString(), "",sTTSIDs,dtDestination.Rows[0][4].ToString());
                    }
          
                }
           
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Fail to retrieve destination info. <" + _className + ".GetDestinationList(BHS.MES.LocationID[])>", ex);
            }
            return dsDB;
        }


        /// <summary>
        /// Remove bag from MES
        /// </summary>
        /// <param name="destination"></param>
        /// <returns></returns>
        private LocationID[] GetSortDestinationList(BHS.MES.LocationID[] destination)
        {
            DataTable dtDestination = null;
            LocationID[] temp = null;
            try
            {
                temp = new LocationID[destination.Length];
                
                string sTTSIDs = string.Empty;

                for (int i = 0; i < destination.Length; i++)
                {
                    sTTSIDs = destination[i].Location;
                    dtDestination = init.AppInit.MsgHandler.DBPersistor.GetSpecificDestination(sTTSIDs);

                    temp[i].Location = dtDestination.Rows[0][1].ToString();
                }

            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Fail to retrieve destination info. <" + _className + ".GetDestinationList(BHS.MES.LocationID[])>", ex);
            }
            return temp;
        }

        /// <summary>
        /// Check the MES destination with destination provided from parameter.
        /// If all destinations provided in parameter same as MES destinations, the function will
        /// return true. If one destination provided in prameter different from MES stations, the function
        /// will return false.
        /// </summary>
        /// <param name="destination">Destination list to check against with MES stations</param>
        /// <returns>If all destinations provided in parameter same as MES destinations, the function will
        /// return true. If one destination provided in prameter different from MES stations, the function
        /// will return false.</returns>
        private bool CheckDestination(BHS.MES.LocationID[] destination)
        {
            bool bReturnVal = false;
            for (int i = 0; i < destination.Length; i++)
            {
                for (int j = 0; j < init.AppInit.MsgHandler.DBPersistor.ClassParameters.TTS01MESLocation.Length; j++)
                {
                    if (destination[i].Location == init.AppInit.MsgHandler.DBPersistor.ClassParameters.TTS01MESLocation[j].Location)
                    {
                        bReturnVal = true;
                        break;
                    }
                    else
                    {
                        bReturnVal = false;
                    }
                }
                if (i == 0 && bReturnVal == false)
                    break;
            }
            return bReturnVal;
        }

        /// <summary>
        /// Set screen to Tag encoding mode.
        /// </summary>
        private void SetTagEncodingMode()
        {
            lblEncodingMode.Text = "Tag #";
            btnRemove.Enabled = false;

            if (!bOSK_Open)
                tabKeyboard.SelectedIndex = 1;
        }

        /// <summary>
        /// Set screen to Flight encoding mode.
        /// </summary>
        private void SetFlightEncodingMode()
        {
            lblEncodingMode.Text = "Flight #";
            btnRemove.Enabled = true;

            //if (btnRepeat.Enabled)
            //    isRepeat = true;

            if (!bOSK_Open)
                tabKeyboard.SelectedIndex = 2;
        }

        /// <summary>
        /// Set screen to destination encode mode.
        /// </summary>
        private void SetDestinationEncodeMode()
        {
            lblEncodingMode.Text = "Destination";
            btnRemove.Enabled = true;

            //if (btnRepeat.Enabled)
            //    isRepeat = true;

            if (!bOSK_Open)
            {
                tabKeyboard.SelectedIndex = 4;
            }
        }

        /// <summary>
        /// Set screen to rush encode mode
        /// </summary>
        //private void SetRushEncodeMode()
        //{
        //    //if ((init.AppInit.MsgHandler.DBPersistor.ClassParameters.EnableRushFuncAlloc) && (init.AppInit.MsgHandler.DBPersistor.ClassParameters.EnableAirRushAlloc))
        //    //{
        //    //     lblInputByFlightCaption.Text = "Airline:";
        //    //}
        //    //else if  (init.AppInit.MsgHandler.DBPersistor.ClassParameters.EnableAirRushAlloc)
        //    //{
        //    //     lblInputByFlightCaption.Text = "Airline:";
        //    //}
        //    //else if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.EnableRushFuncAlloc)
        //    //{
        //    //    lblInputByFlightCaption.Text = "Flight #:";
        //    //}

        //    lblInputByFlightCaption.Text = "Airline:";
        //    lblEncodingMode.Text = "Rush Dest.";
        //    btnRepeat.Enabled = true;

        //    //if (btnRepeat.Enabled)
        //    //    isRepeat = true;

        //    if (!bOSK_Open)
        //        tabKeyboard.SelectedIndex = 2;
            
        //}

        /// <summary>
        /// Set default encoding mode on screen based on config file setting.
        /// </summary>
        private void SetDefaultEncodeMode()
        {
            switch (init.ClassParameters.StartupOperationMode.ToUpper())
            {
                case "TAG":
                    if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByTag == true)
                    {
                        SetTagEncodingMode();
                    }
                    else if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByFlight == true)
                    {
                        SetFlightEncodingMode();
                    }
                    else if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByDestination == true)
                    {
                        SetDestinationEncodeMode();
                    }
                    break;
                case "FLIGHT":
                    if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByFlight == true)
                    {
                        SetFlightEncodingMode();
                    }
                    else if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByDestination == true)
                    {
                        SetDestinationEncodeMode();
                    }
                    else if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByTag == true)
                    {
                        SetTagEncodingMode();
                    }
                    break;
                case "DESTINATION":
                    if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByDestination == true)
                    {
                        SetDestinationEncodeMode();
                    }
                    else if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByTag == true)
                    {
                        SetTagEncodingMode();
                    }
                    else if (init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByFlight == true)
                    {
                        SetFlightEncodingMode();
                    }
                    break;
                default:
                    SetTagEncodingMode();
                    break;
            }
        }

        
        /// <summary>
        /// Get the list of destination for user to select.
        /// </summary>
        /// <param name="destination"></param>
        /// <returns></returns>
        private DataTable GetDestinationList(BHS.MES.LocationID[] destination)
        {
            DataTable dtDestination = null;
            try
            {
                string sTTSIDs = string.Empty;
                for (int i = 0; i < destination.Length; i++)
                {
                    sTTSIDs += destination[i].Location + ",";
                }
                sTTSIDs = sTTSIDs.Substring(0, sTTSIDs.Length - 1);
                dtDestination = init.AppInit.MsgHandler.DBPersistor.GetSpecificDestination(sTTSIDs);
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Fail to retrieve destination info. <" + _className + ".GetDestinationList(BHS.MES.LocationID[])>", ex);
            }
            return dtDestination;
        }

        /// <summary>
        /// Get reason for sorted bag
        /// </summary>
        private void GetTagReason()
        {
            try
            {
                string sReason = string.Empty;
                BHS.MES.LocationID[] destination = init.AppInit.MsgHandler.GetDestination(_bagGID, _licensePlate, out sReason);

                DataTable dtDestination = GetTagDestinationList(destination);

                if (dtDestination.Rows.Count > 0)
                {
                    for (int i = 0; i < dtDestination.Rows.Count; i++)
                    {
                        string dest = dtDestination.Rows[i][1].ToString();

                        for (int j = 0; j < dtDestination.Rows.Count; j++)
                        {
                            if (i != j)
                            {
                                if (dest == dtDestination.Rows[j][1].ToString())
                                {
                                    if ((bool.Parse(dtDestination.Rows[j][4].ToString())) && (bool.Parse(dtDestination.Rows[i][4].ToString())))
                                    {
                                        dtDestination.Rows.Remove(dtDestination.Rows[j]);
                                        j = j - 1;
                                    }
                                    else if ((!bool.Parse(dtDestination.Rows[j][4].ToString())) && (bool.Parse(dtDestination.Rows[i][4].ToString())))
                                    {
                                        dtDestination.Rows.Remove(dtDestination.Rows[j]);
                                        j = j - 1;
                                    }
                                    else if ((bool.Parse(dtDestination.Rows[j][4].ToString())) && (!bool.Parse(dtDestination.Rows[i][4].ToString())))
                                    {
                                        dtDestination.Rows.Remove(dtDestination.Rows[i]);
                                        i = i - 1;
                                    }
                                    else if ((!bool.Parse(dtDestination.Rows[j][4].ToString())) && (!bool.Parse(dtDestination.Rows[i][4].ToString())))
                                    {
                                        dtDestination.Rows.Remove(dtDestination.Rows[j]);
                                        j = j - 1;
                                    }
                                }
                            }
                        }
                    }
                }

                if (multipleBSM)
                {

                    if ((dtDestination.Rows.Count > 1) &&  ((dtDestination.Rows[0][1].ToString() != "MES01") && (dtDestination.Rows[0][1].ToString() != "MES02") && (dtDestination.Rows[0][1].ToString() != "MES03") && (dtDestination.Rows[0][1].ToString() != "MES04")
                            || (dtDestination.Rows[1][1].ToString() != "MES01") && (dtDestination.Rows[1][1].ToString() != "MES02") && (dtDestination.Rows[1][1].ToString() != "MES03") && (dtDestination.Rows[1][1].ToString() != "MES04")))
                    {
                        DataView dataView = dtDestination.DefaultView;
                        dataView.RowFilter = "Destination ='" + lblDestination.Text.Trim() + "'";
                        dtDestination = null;
                        dtDestination = dataView.ToTable();
                    }

                    
                }

                LocationID[] mes1Location = init.AppInit.MsgHandler.DBPersistor.ClassParameters.TTS01MESLocation;
                LocationID[] mes2Location = init.AppInit.MsgHandler.DBPersistor.ClassParameters.TTS02MESLocation;
                bool isDestMES = false;

                if (dtDestination == null)
                {
                    lblDestination.Text = string.Empty;
                    lblDestination.Tag = 0;
                }
                else if (dtDestination.Rows.Count == 0)
                {
                    lblDestination.Text = string.Empty;
                    lblDestination.Tag = 0;
                }
                else
                {
                    if (mes1Location.Length > 0)
                    {
                        for (int i = 0; i < mes1Location.Length; i++)
                        {
                            if (dtDestination.Rows[0][0].ToString() == mes1Location[i].Location)
                            {
                                isDestMES = true;
                                break;
                            }
                        }
                    }

                    if (mes2Location.Length > 0)
                    {
                        for (int i = 0; i < mes2Location.Length; i++)
                        {
                            if (dtDestination.Rows[0][0].ToString() == mes2Location[i].Location)
                            {
                                isDestMES = true;
                                break;
                            }
                        }
                    }
                }

                if (isDestMES == true)
                {
                    lblDestination.Text = string.Empty;
                    lblDestination.Tag = 0;
                }
                else
                {

                    if (dtDestination == null)
                    {
                        lblDestination.Text = string.Empty;
                        lblDestination.Tag = 0;
                    }
                    else if (dtDestination.Rows.Count > 1)
                    {
                        if ((dtDestination.Rows[0][1].ToString() != "MES01") && (dtDestination.Rows[0][1].ToString() != "MES02") && (dtDestination.Rows[0][1].ToString() != "MES03") && (dtDestination.Rows[0][1].ToString() != "MES04")
                            || (dtDestination.Rows[1][1].ToString() != "MES01") && (dtDestination.Rows[1][1].ToString() != "MES02") && (dtDestination.Rows[1][1].ToString() != "MES03") && (dtDestination.Rows[1][1].ToString() != "MES04"))
                        {
                            Selection frmDestinationSelection = new Selection(dtDestination, "Sort Dest.", _licensePlate, _bagGID,init.AppInit.MsgHandler.isHLCMode);
                            if (frmDestinationSelection.ShowDialog(this) == DialogResult.OK)
                            {

                                if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(frmDestinationSelection.sDestination, frmDestinationSelection.sDestinationID, init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
                                {
                                    lblDestination.Text = frmDestinationSelection.sDestination;
                                    lblDestination.Tag = frmDestinationSelection.sDestinationID;
                                }
                                else
                                {
                                    if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
                                    {
                                        lblDestination.Text = frmDestinationSelection.sDestination;
                                        lblDestination.Tag = frmDestinationSelection.sDestinationID;
                                    }
                                }

                            }
                            else
                            {
                                lblDestination.Text = string.Empty;
                                lblDestination.Tag = 0;
                            }

                            frmDestinationSelection.Dispose();
                            frmDestinationSelection = null;
                        }

                    }
                    else if (dtDestination.Rows.Count == 1)
                    {
                        if ((dtDestination.Rows[0][1].ToString() != "MES01") && (dtDestination.Rows[0][1].ToString() != "MES02") && (dtDestination.Rows[0][1].ToString() != "MES03") && (dtDestination.Rows[0][1].ToString() != "MES04"))
                        {
                            if (init.AppInit.MsgHandler.DBPersistor.ChuteAvailableCheckForDestination(dtDestination.Rows[0][1].ToString(), dtDestination.Rows[0][3].ToString(), init.AppInit.MsgHandler.DBPersistor.ClassParameters.MESDefaultTTS))
                            {
                                lblDestination.Tag = dtDestination.Rows[0][3].ToString();
                                lblDestination.Text = dtDestination.Rows[0][1].ToString();
                            }
                            else
                            {
                                if (DialogResult.OK == MessageBox.Show("The destination is Unavailable. Are you sure to continue ?", "Warning", MessageBoxButtons.OKCancel))
                                {
                                    lblDestination.Tag = dtDestination.Rows[0][3].ToString();
                                    lblDestination.Text = dtDestination.Rows[0][1].ToString();
                                }
                            }
                        }
                    }

                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Fail to retrieve reason. <" + _className + ".GetReason>", ex);
            }
        }

        private void SetSecurity()
        {
            if (Properties.Resources.sWorkingMode == "DEV")
            {
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByTag = true;
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByFlight = true;
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByDestination = true;
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByProblem = true;
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.EncodeByRush = true;
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.OperationMode = true;
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.GenerateTag = true;
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.MES_FunctionList.InsertBag = true;

            }

        }
        
        // ** Function is not being utilized at btnEnter_Click **
        private bool CheckOKBarcode()
        {
            bool returnValue = false;
            int iLength = init.ClassParameters.OKBarCode.Length;

            if ((lblEncodingMode.Text == "Tag") || (lblEncodingMode.Text == "Problem"))
            {
                if (txtTagInput.Text.Length >= iLength)
                {
                    if (init.ClassParameters.OKBarCode == txtTagInput.Text.Substring(txtTagInput.Text.Length - iLength, iLength))
                    {
                        returnValue = true;
                        txtTagInput.Text = txtTagInput.Text.Substring(0, txtTagInput.Text.Length - iLength).Trim();
                        //SetFocusToActiveTextbox();
                    }
                }            
            }
            else if ((lblEncodingMode.Text == "Flight") || (lblEncodingMode.Text == "Rush Dest."))
            {
                if (txtFlightInput.Text.Length >= iLength)
                {
                    if (init.ClassParameters.OKBarCode == txtFlightInput.Text.Substring(txtFlightInput.Text.Length - iLength, iLength))
                    {
                        returnValue = true;
                        txtFlightInput.Text = txtFlightInput.Text.Substring(0, txtFlightInput.Text.Length - iLength).Trim();
                        //SetFocusToActiveTextbox();
                    }
                }            
         
            }
            else if (lblEncodingMode.Text == "Sort Dest.")
            {
                if (txtDestInput.Text.Length >= iLength)
                {
                    if (init.ClassParameters.OKBarCode == txtDestInput.Text.Substring(txtDestInput.Text.Length - iLength, iLength))
                    {
                        returnValue = true;
                        txtDestInput.Text = txtDestInput.Text.Substring(0, txtDestInput.Text.Length - iLength).Trim();
                        //SetFocusToActiveTextbox();
                    }
                }                         
            }  
             
            return returnValue;
        }

        /// <summary>
        /// Navigate to next page of Airline list
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnNextAirline_Click(object sender, EventArgs e)
        {

            if (airlinePage == 0)
            {
                airlinePage = 1;
                PrepareAirlineFunctionButtons(airlinePage);
            }
            else if (airlinePage == 1)
            {
                airlinePage = 2;
                PrepareAirlineFunctionButtons(airlinePage);
            }
            else
            {
                airlinePage = 0;
                PrepareAirlineFunctionButtons(airlinePage);
            }

        }

        private void tabControlEncodeMode_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch (tabControlEncodeMode.SelectedTab.Text.ToString().ToLower())
            {
                case "tag #":
                    lblEncodingMode.Text = "Tag #";
                    txtTagInput.Enabled = true;
                    tabKeyboard.SelectedIndex = 1;
                    txtFlightInput.Enabled = false;
                    txtAirlineInput.Enabled = false;
                    txtDestInput.Enabled = false;
                    //BY PST
                    if(lblDestination.Text  != "MES" | lblDestination.Text  !=string.Empty )
                    btnDispatch.Enabled =  false ;
                    else
                        btnDispatch.Enabled = true;
                    break;
                case "flight #":
                    lblEncodingMode.Text = "Flight #";
                    txtFlightInput.Enabled = true;

                    txtTagInput.Enabled = false;
                    txtAirlineInput.Enabled = false;
                    txtDestInput.Enabled = false;

                    break;
                case "airline":
                    lblEncodingMode.Text = "Airline";
                    tabKeyboard.SelectedIndex = 0;
                    if (txtTagInput.Text != string.Empty)
                    {
                        string airline = GetPassengerAirline();
                        if (airline != string.Empty)
                        {
                            this.txtAirlineInput.Text = airline;
                            this.btnEnter_Click(sender, e);
                            btnDispatch.Enabled = true;
                        }
                        else
                        {
                            lblSortDest.Text = string.Empty;
                            lblSortReason3.Text = string.Empty;
                            txtAirlineInput.Text = string.Empty;
                        }
                    }

                    txtAirlineInput.Enabled = true;
                    txtTagInput.Enabled = false;
                    txtFlightInput.Enabled = false;
                    txtDestInput.Enabled = false;

                    break;
                case "destination" :
                    lblEncodingMode.Text = "Destination";
                    txtDestInput.Enabled = true;

                    txtTagInput.Enabled = false;
                    txtFlightInput.Enabled = false;
                    txtAirlineInput.Enabled = false;
                    
                    break;
                case "problem bag":
                    lblEncodingMode.Text = "Problem Bag";

                    string strDestination = string.Empty, strReason = string.Empty;
                    string strDestDescr = string.Empty, strReasonDescr = string.Empty;

                    init.AppInit.MsgHandler.DBPersistor.GetIRDValuesMES("4", string.Empty, string.Empty, string.Empty, string.Empty, _location, string.Empty, out strDestination, out strReason, out strDestDescr, out strReasonDescr);

                    _destination = strDestination;
                    txtProbBagDest.Text = strDestDescr;

                    if (lblPLCStatus.Text.ToUpper ()!="OFFLINE")
                        btnDispatch.Enabled = lblDestination.Text.ToUpper () == "MES" ? false : true;

                    break;
            }

            SetFocusToActiveTextbox();
        }


        //Conv Status Color Methods & Events

        #region methods
        private void initiHshList()
        {
            string MEStation_Name = init.ClassParameters.MEStationName;
            dt = init.AppInit.MsgHandler.DBPersistor.GetConv_StatusColor(MEStation_Name);
            for (int i = 0; i < dt.Rows.Count; i++)
            {

                if (dt.Rows[i]["Color_Blinking"].ToString() == "True")
                {
                    HshList.Add(dt.Rows[i]["Conv_Name"].ToString(), "false");
                }
            }
        }
        private void GET_CurrentMEStation()
        {
            if ("ME1" == init.ClassParameters.MEStationName.ToUpper())
            {
                MES01 _idlDiaGram = new MES01(dt, HshList);
                _idlDiaGram.HshList = HshList;
                this.diagramView1.Content = _idlDiaGram;

            }
            else if ("ME2" == init.ClassParameters.MEStationName.ToUpper())
            {
                MES02 _idlDiaGram = new MES02(dt, HshList);
                _idlDiaGram.HshList = HshList;
                this.diagramView1.Content = _idlDiaGram;

            }
            else if ("ME3" == init.ClassParameters.MEStationName.ToUpper())
            {
                MES03 _idlDiaGram = new MES03(dt, HshList);
                _idlDiaGram.HshList = HshList;
                this.diagramView1.Content = _idlDiaGram;

            }
        }


        #endregion
        private void RefreshConvColor_Timer_Tick(object sender, EventArgs e)
        {
            if ("ME1" == init.ClassParameters.MEStationName.ToUpper())
            {
                HshList.Clear();
                initiHshList();
                MES01 _idlDiaGram = new MES01(dt, HshList);
            }
            else if ("ME2" == init.ClassParameters.MEStationName.ToUpper())
            {
                HshList.Clear();
                initiHshList();
                MES02 _idlDiaGram = new MES02(dt, HshList);
            }
            else if ("ME3" == init.ClassParameters.MEStationName.ToUpper())
            {
                HshList.Clear();
                initiHshList();
                MES02 _idlDiaGram = new MES02(dt, HshList);
            }
        }

        private void ColorAnimationTimer_Tick(object sender, EventArgs e)
        {
            GET_CurrentMEStation();
        }

        private void txtTagInput_KeyDown(object sender, KeyEventArgs e)
        {
            //BY PST
            if (e.KeyCode == Keys.Enter)
            {
                if (logger.IsInfoEnabled)
                    logger.Info("Enter Event Fire.." + " <" + _className + " >" );
                btnEnter_Click(sender, e);
            }
        }

   
        #endregion


       


    }

}
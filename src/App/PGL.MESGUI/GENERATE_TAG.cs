#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       GENERATE_TAG.cs
// Revision:      1.0 -   29 Jun 2010, By Albert Sun.
// =====================================================================================
//
#endregion

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
#endregion

namespace PGL.MESGUI
{
    public partial class GENERATE_TAG : Form
    {
        #region Local Variable Declaration
        private readonly string _className = System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        private bool shiftPressed = true;
        private string currentFocusTxtBox = string.Empty;
        private BHS.MES.GUI.GUIInitializer init = null;
        private static readonly log4net.ILog logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private string airline = " ";
        private string flightNumber = " ";
        private DateTime sdo = Convert.ToDateTime("01-Jan-1900");
        private bool filtered = false;
        string defaultDateFormat = string.Empty;
        string defaultTimeFormat = string.Empty;
        int _flag = 0;
        #endregion

        #region Windows Designer Generated Code
        public GENERATE_TAG(BHS.MES.GUI.GUIInitializer initMain)
        {
            InitializeComponent();
            init = initMain;
            _flag = 0;
        }

        private void tabGenerateTag_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch(tabGenerateTag.SelectedTab.Text.Trim())
            {
                case "IATA Interline":
                    txtIATATag.Focus();
                    txtIATATag_Click(sender, e);
                    EnableDisableButtons();
                    break;
                case "IATA Fallback":
                    txtAireLineCode.Focus();
                    txtAireLineCode_Click(sender, e);
                    EnableDisableButtons();
                    break;
                case "In-House":
                    cmbInhouseFirstDigit.Focus();
                    cmbInhouseFirstDigit_Click(sender, e);
                    EnableDisableButtons();
                    break;
                case "Pseudo BSM":
                    rbtnIATABSM.Checked=true;
                    txtEditAirline_Click(sender, e);
                    _flag = 0;
                    rbtnIATABSM_CheckedChanged(sender, e);
                    EnableDisableButtons();
                    break;
            }
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void GENERATE_TAG_Load(object sender, EventArgs e)
        {
            this.Width = 1024;
            this.Height = 768;

            defaultDateFormat = init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat;
            defaultTimeFormat = init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultTimeFormat;

            tabGenerateTag.SelectTab(0);
            this.tabGenerateTag.TabPages.Remove(this.tabPage4);

            rbtnPrintIATATag.Select();
            txtIATATag_Click(sender, e);
            EnableDisableButtons();
            //GetFirstDigits();
            cmbInhouseFirstDigit.Text = "                       9333";
            cmbInhouseFirstDigit.Enabled = false;

            PrepareAirlineFunctionButtons();

            SetFocusToActiveTextbox(false);
        }

        private void btnBackSpace_Click(object sender, EventArgs e)
        {
            switch (currentFocusTxtBox)
            {
                case "txtIATATag":
                    if (txtIATATag.Text.Length > 0)
                    {
                        txtIATATag.Text = txtIATATag.Text.Substring(0, txtIATATag.Text.Length - 1);
                    }
                    break;
                case "txtQty":
                    if (txtQty.Text.Length>0)
                    {
                        txtQty.Text = txtQty.Text.Substring(0, txtQty.Text.Length - 1);
                    }
                    break;
                case "txtDestCode":
                    if (txtDestCode.Text.Length > 0)
                    {
                        txtDestCode.Text = txtDestCode.Text.Substring(0,txtDestCode.Text.Length-1);
                    }
                    break;
                case "txtAireLineCode":
                    if (txtAireLineCode.Text.Length > 0)
                    {
                        txtAireLineCode.Text = txtAireLineCode.Text.Substring(0, txtAireLineCode.Text.Length - 1);
                    }
                    break;
                case "txtFallbackShortMsg":
                    if (txtFallbackShortMsg.Text.Length > 0)
                    {
                        txtFallbackShortMsg.Text=txtFallbackShortMsg.Text.Substring(0, txtFallbackShortMsg.Text.Length-1);
                    }
                    break;
                case "txtIHFlightNo":
                    if (txtIHFlightNo.Text.Length > 0)
                    {
                        txtIHFlightNo.Text = txtIHFlightNo.Text.Substring(0, txtIHFlightNo.Text.Length - 1);
                    }
                    break;
                case "txtIHAirlineCode":
                    if (txtIHAirlineCode.Text.Length > 0)
                    {
                        txtIHAirlineCode.Text = txtIHAirlineCode.Text.Substring(0, txtIHAirlineCode.Text.Length - 1);
                    }
                    break;
                case "txtIHShortMsg":
                    if (txtIHShortMsg.Text.Length > 0)
                    {
                        txtIHShortMsg.Text = txtIHShortMsg.Text.Substring(0, txtIHShortMsg.Text.Length - 1);
                    }
                    break;
                case "txtIHSDO":
                    if (txtIHSDO.Text.Length > 0)
                    {
                        txtIHSDO.Text = txtIHSDO.Text.Substring(0, txtIHSDO.Text.Length - 1);
                    }
                    break;
                case "txtEditFlightNumber":
                    if (txtEditFlightNumber.Text.Length > 0)
                    {
                        txtEditFlightNumber.Text = txtEditFlightNumber.Text.Substring(0, txtEditFlightNumber.Text.Length - 1);
                    }
                    break;
                case "txtEditAirline":
                    if (txtEditAirline.Text.Length > 0)
                    {
                        txtEditAirline.Text = txtEditAirline.Text.Substring(0, txtEditAirline.Text.Length - 1);
                    }
                    break;
                case "txtEditSDO":
                    if (txtEditSDO.Text.Length > 0)
                    {
                        txtEditSDO.Text = txtEditSDO.Text.Substring(0, txtEditSDO.Text.Length - 1);
                    }
                    break;
                case "txtIATAShortMsg":
                    if (txtIATAShortMsg.Text.Length > 0)
                    {
                        txtIATAShortMsg.Text = txtIATAShortMsg.Text.Substring(0, txtIATAShortMsg.Text.Length - 1);
                    }
                    break;
                case "txtIATAAirline":
                    if (txtIATAAirline.Text.Length > 0)
                    {
                        txtIATAAirline.Text = txtIATAAirline.Text.Substring(0, txtIATAAirline.Text.Length - 1);
                    }
                    break;
                case "txtIATAGenerateTagMsg":
                    if (txtIATAGenerateTagMsg.Text.Length > 0)
                    {
                        txtIATAGenerateTagMsg.Text = txtIATAGenerateTagMsg.Text.Substring(0, txtIATAGenerateTagMsg.Text.Length - 1);
                    }
                    break;
                case "txtIATASDO":
                    if (txtIATASDO.Text.Length > 0)
                    {
                        txtIATASDO.Text = txtIATASDO.Text.Substring(0, txtIATASDO.Text.Length - 1);
                    }
                    break;
                case "txtIATAFlightNo":
                    if (txtIATAFlightNo.Text.Length > 0)
                    {
                        txtIATAFlightNo.Text = txtIATAFlightNo.Text.Substring(0, txtIATAFlightNo.Text.Length - 1);
                    }
                    break;
                case "txtEditDescription":
                    if (txtEditDescription.Text.Length > 0)
                    {
                        txtEditDescription.Text = txtEditDescription.Text.Substring(0, txtEditDescription.Text.Length - 1);
                    }
                    break;
            }
        }

        private void txtIATATag_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtIATATag.Name;
        }

        private void rbtnPrintIATATag_Click(object sender, EventArgs e)
        {
            pnlPrintGenerate.Visible = false;
            pnlPrintTag.Visible = true;
        }

        private void rbtnGenerateIATATag_CheckedChanged(object sender, EventArgs e)
        {
            pnlPrintTag.Visible = false;
            pnlPrintGenerate.Visible = true;
        }

        private void txtIATAAirline_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtIATAAirline.Name;
        }

        private void txtIATAFlightNo_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtIATAFlightNo.Name;
        }

        private void txtIATASDO_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtIATASDO.Name;
        }

        private void txtIATAGenerateTagMsg_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtIATAGenerateTagMsg.Name;
        }

        private void txtIATAShortMsg_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtIATAShortMsg.Name;
        }

        private void txtAireLineCode_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtAireLineCode.Name;
        }

        private void txtDestCode_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtDestCode.Name;
        }

        private void txtQty_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtQty.Name;
        }

        private void txtFallbackShortMsg_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtFallbackShortMsg.Name;
        }

        private void cmbInhouseFirstDigit_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = cmbInhouseFirstDigit.Name;
        }

        private void txtIHAirlineCode_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtIHAirlineCode.Name;
        }

        private void txtIHFlightNo_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtIHFlightNo.Name;
        }

        private void txtIHSDO_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtIHSDO.Name;
        }

        private void txtIHShortMsg_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtIHShortMsg.Name;
        }

        private void txtEditAirline_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtEditAirline.Name;
        }

        private void txtEditFlightNumber_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtEditFlightNumber.Name;
        }

        private void txtEditSDO_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtEditSDO.Name;
        }

        private void txtEditDescription_Click(object sender, EventArgs e)
        {
            currentFocusTxtBox = txtEditDescription.Name;
        }

        private void btnPrint_Click(object sender, EventArgs e)
        {
            try
            {
                switch (tabGenerateTag.SelectedTab.Text.Trim())
                {
                    case "IATA Interline":
                        if (rbtnPrintIATATag.Checked)
                        {
                            //Preview frmPreview = new Preview(txtIATATag.Text, txtIATAShortMsg.Text, "IATA");
                            //frmPreview.ShowDialog();
                            //frmPreview.Dispose();
                            //frmPreview = null;

                            init.PrintLabel(txtIATATag.Text, txtIATAShortMsg.Text, "IATA", 1);
                            init.AppInit.MsgHandler.DBPersistor.InsertPseudoBSM(txtIATATag.Text, string.Empty, string.Empty,
                                "01-Jan-1900", txtIATAShortMsg.Text,
                                init.AppInit.MsgHandler.MESStationName, "IATA");
                            init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, string.Empty, txtIATATag.Text,
                                init.AppInit.MsgHandler.ClassParameters.SubSystem,
                                init.AppInit.MsgHandler.ClassParameters.Location,
                                init.AppInit.MsgHandler.MESStationName, "PRNIATA", "Printed IATA tag.");
                            MessageBox.Show(Properties.Resources.sMessageSuccessIATAPrint, Properties.Resources.sAppMessageBoxTitleInfo, MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                        else if (rbtnGenerateIATATag.Checked)
                        {
                            //Preview frmPreview = new Preview(txtIATATag.Text, txtIATAGenerateTagMsg.Text, "IATA");
                            //frmPreview.ShowDialog();
                            //frmPreview.Dispose();
                            //frmPreview = null;

                            init.PrintLabel(txtIATATag.Text, txtIATAGenerateTagMsg.Text, "IATA", 1);
                            init.AppInit.MsgHandler.DBPersistor.InsertPseudoBSM(txtIATATag.Text, txtIATAAirline.Text, 
                                txtIATAFlightNo.Text, txtIATASDO.Text, txtIATAGenerateTagMsg.Text,
                                init.AppInit.MsgHandler.MESStationName, "IATA");
                            init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, string.Empty, txtIATATag.Text,
                                init.AppInit.MsgHandler.ClassParameters.SubSystem,
                                init.AppInit.MsgHandler.ClassParameters.Location,
                                init.AppInit.MsgHandler.MESStationName, "PRNIATA", "Printed IATA tag.");
                            MessageBox.Show(Properties.Resources.sMessageSuccessIATAPrint, Properties.Resources.sAppMessageBoxTitleInfo, MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                        break;
                    case "IATA Fallback":
                        if (txtAireLineCode.Text.Trim() == "")
                        {
                            MessageBox.Show(Properties.Resources.sErrorInvalidAirlineCode,
                                Properties.Resources.sAppMessageBoxWarning,
                                MessageBoxButtons.OK, MessageBoxIcon.Information);
                            break;
                        }
                        if (txtDestCode.Text.Trim() == "")
                        {
                            MessageBox.Show(Properties.Resources.sErrorInvalidDestination,
                               Properties.Resources.sAppMessageBoxWarning,
                               MessageBoxButtons.OK, MessageBoxIcon.Information);
                            break;
                        }
                        if (txtQty.Text.Trim() == "")
                        {
                            MessageBox.Show(Properties.Resources.sErrorInvalidQuantity,
                              Properties.Resources.sAppMessageBoxWarning,
                              MessageBoxButtons.OK, MessageBoxIcon.Information);
                            break;
                        }
                        string sFallbackTag = init.AppInit.MsgHandler.DBPersistor.GenerateFallbackTag(txtAireLineCode.Text,
                            txtDestCode.Text);

                        //Preview frmFallbackPreview = new Preview(sFallbackTag, txtFallbackShortMsg.Text, "Fallback");
                        //frmFallbackPreview.ShowDialog();
                        //frmFallbackPreview.Dispose();
                        //frmFallbackPreview = null;

                        init.PrintLabel(sFallbackTag, txtFallbackShortMsg.Text, "Fallback", Convert.ToInt32(txtQty.Text));
                        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, string.Empty, sFallbackTag,
                            init.AppInit.MsgHandler.ClassParameters.SubSystem,
                            init.AppInit.MsgHandler.ClassParameters.Location,
                            init.AppInit.MsgHandler.MESStationName, "PRNFALLBAK", "Printed " + txtQty.Text.Trim() + " fallback tags.");
                        MessageBox.Show(Properties.Resources.sMessageSuccessFallbakPrint, Properties.Resources.sAppMessageBoxTitleInfo);
                        break;
                    case "In-House":
                        if (cmbInhouseFirstDigit.Text.Trim() == "")
                        {
                            MessageBox.Show(Properties.Resources.sErrorInvalidFirstDigit,
                                Properties.Resources.sAppMessageBoxWarning);
                            break;
                        }

                        if (txtIHAirlineCode.Text.Trim() == "")
                        {
                            MessageBox.Show(Properties.Resources.sErrorInvalidAirlineCode,
                                                       Properties.Resources.sAppMessageBoxWarning, 
                                                        MessageBoxButtons.OK, MessageBoxIcon.Information);
                            break;
                        }

                        if (txtIHFlightNo.Text.Trim() == "")
                        {
                            MessageBox.Show(Properties.Resources.sErrorInvalidFlight,
                                Properties.Resources.sAppMessageBoxWarning, MessageBoxButtons.OK, MessageBoxIcon.Information);
                            break;
                        }

                        if (txtIHSDO.Text.Trim() == "")
                        {
                            MessageBox.Show(Properties.Resources.sErrorInvalidFormat,
                                Properties.Resources.sAppMessageBoxWarning, MessageBoxButtons.OK, MessageBoxIcon.Information);
                            break;
                        }
                        DateTime dtSDO;
                        bool bConvert = DateTime.TryParseExact(txtIHSDO.Text, init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat,
                            null, System.Globalization.DateTimeStyles.None, out dtSDO);
                        string inhouseTag = init.AppInit.MsgHandler.DBPersistor.GenerateInhouseTag(
                            cmbInhouseFirstDigit.Text.Trim(), txtIHAirlineCode.Text, txtIHFlightNo.Text,
                            dtSDO, txtIHShortMsg.Text,
                            init.AppInit.MsgHandler.MESStationName,
                            init.AppInit.MsgHandler.ClassParameters.SubSystem,
                            init.AppInit.MsgHandler.ClassParameters.Location, 
                            init.AppInit.MsgHandler.DBPersistor.ClassParameters.InHouseTagConstant);

                        //Preview frmInhousePreview = new Preview(inhouseTag, txtIHShortMsg.Text, "In-House");
                        //frmInhousePreview.ShowDialog();
                        //frmInhousePreview.Dispose();
                        //frmInhousePreview = null;

                        init.PrintLabel(inhouseTag, txtIHShortMsg.Text, "In-House", 1);
                        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, string.Empty, inhouseTag,
                            init.AppInit.MsgHandler.ClassParameters.SubSystem,
                            init.AppInit.MsgHandler.ClassParameters.Location,
                            init.AppInit.MsgHandler.MESStationName, "PRNINHOUSE", "Printed Inhouse tag.");
                        if (inhouseTag != string.Empty)
                        {
                            MessageBox.Show(Properties.Resources.sMessageSuccessInhousePrint,
                                Properties.Resources.sAppMessageBoxTitleInfo, MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                        else
                        {
                            MessageBox.Show(Properties.Resources.sErrorInhousePrintFail,
                                Properties.Resources.sAppMessageBoxTitleInfo, MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                        break;
                    case "Pseudo BSM":
                        if (rbtnIATABSM.Checked == true)
                        {
                            //Preview frmIATABSMPreview = new Preview(txtEditAirline.Tag.ToString(), txtEditDescription.Text, "IATA");
                            //frmIATABSMPreview.ShowDialog();
                            //frmIATABSMPreview.Dispose();
                            //frmIATABSMPreview = null;

                            init.PrintLabel(txtEditAirline.Tag.ToString(), txtEditDescription.Text, "IATA", 1);
                            init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, string.Empty, txtEditAirline.Tag.ToString(),
                            init.AppInit.MsgHandler.ClassParameters.SubSystem,
                            init.AppInit.MsgHandler.ClassParameters.Location,
                            init.AppInit.MsgHandler.MESStationName, "PRNIATA", "Printed IATA tag.");
                        }
                        else
                        {
                            if (rbtnIHBSM.Checked == true)
                            {
                                //Preview frmIHBSMPreview = new Preview(txtEditAirline.Tag.ToString(), txtEditDescription.Text, "In-House");
                                //frmIHBSMPreview.ShowDialog();
                                //frmIHBSMPreview.Dispose();
                                //frmIHBSMPreview = null;

                                init.PrintLabel(txtEditAirline.Tag.ToString(), txtEditDescription.Text, "In-House", 1);
                                init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, string.Empty, txtEditAirline.Tag.ToString(),
                                init.AppInit.MsgHandler.ClassParameters.SubSystem,
                                init.AppInit.MsgHandler.ClassParameters.Location,
                                init.AppInit.MsgHandler.MESStationName, "PRNINHOUSE", "Printed Inhouse tag.");
                            }
                        }
                        break;
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] printing bsm failed. <" + _className + ".btnPrint_Click()>", ex);
            }
        }

        private void rbtnIHBSM_CheckedChanged(object sender, EventArgs e)
        {
            try
            {
                dgvBSM.Visible = true;
                dgvIATAList.Visible = false;

                txtEditAirline.Text = "";
                txtEditFlightNumber.Text = "";
                txtEditSDO.Text = "";
                txtEditDescription.Text = "";

                GetInhouseBSM();

                dgvBSM_Click(sender, e);
                EnableDisableButtons();
                
                grpEditInhouseTag.Enabled = true;
                lblTotalRecord.Text = "(Total: " + dgvBSM.Rows.Count.ToString() + ")";
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] getting in-house BSM failed. <" + _className + ".rbtnIHBSM_CheckedChanged()>", ex);
            }
        }

        private void dgvBSM_Click(object sender, EventArgs e)
        {
            try
            {
                if (dgvBSM.Rows.Count > 0)
                {
                    int curRow = dgvBSM.CurrentRow.Index;
                    txtEditAirline.Tag = dgvBSM.Rows[curRow].Cells[0].Value.ToString();
                    txtEditAirline.Text = dgvBSM.Rows[curRow].Cells[1].Value.ToString();
                    txtEditFlightNumber.Text = dgvBSM.Rows[curRow].Cells[2].Value.ToString();
                    txtEditSDO.Text = Convert.ToDateTime(dgvBSM.Rows[curRow].Cells[3].Value.ToString()).ToString(
                        init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat);
                    txtEditDescription.Text = dgvBSM.Rows[curRow].Cells[4].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] showing Inhouse bsm failed. <" + _className + ".dgvBSM_Click()>", ex);
            }
        }

        private void dgvIATAList_Click(object sender, EventArgs e)
        {
            try
            {
                if (dgvIATAList.Rows.Count > 0)
                {
                    int curRow = dgvIATAList.CurrentRow.Index;
                    txtEditAirline.Tag = dgvIATAList.Rows[curRow].Cells[0].Value.ToString();
                    txtEditAirline.Text = dgvIATAList.Rows[curRow].Cells[1].Value.ToString();
                    txtEditFlightNumber.Text = dgvIATAList.Rows[curRow].Cells[2].Value.ToString();
                    txtEditSDO.Text = Convert.ToDateTime(dgvIATAList.Rows[curRow].Cells[3].Value.ToString()).ToString(
                        init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat + " " +
                        init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultTimeFormat);
                    txtEditDescription.Text = string.Empty;
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] showing IATA bsm failed. <" + _className + ".dgvIATAList_Click()>", ex);
            }
        }

        private void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                IFormatProvider dateFormat = new System.Globalization.CultureInfo("en-GB", true);

                if (txtEditAirline.Text.Trim() == "")
                {
                    MessageBox.Show(Properties.Resources.sErrorInvalidAirlineCode,
                        Properties.Resources.sAppMessageBoxWarning, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (txtEditFlightNumber.Text.Trim() == "")
                {
                    MessageBox.Show(Properties.Resources.sErrorInvalidFlight,
                        Properties.Resources.sAppMessageBoxWarning, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (txtEditSDO.Text.Trim() == "")
                {
                    MessageBox.Show(Properties.Resources.sErrorInvalidFormat,
                        Properties.Resources.sAppMessageBoxWarning, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (MessageBox.Show(Properties.Resources.sQuestionUpdateIHTag,
                    Properties.Resources.sAppMessageBoxTitleConfirm, MessageBoxButtons.YesNo) == DialogResult.Yes)
                {
                    if (init.AppInit.MsgHandler.DBPersistor.UpdateInhouseBSM(
                        txtEditAirline.Tag.ToString(), txtEditAirline.Text, txtEditFlightNumber.Text,
                        DateTime.ParseExact(txtEditSDO.Text, init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat ,dateFormat), txtEditDescription.Text,
                        init.AppInit.MsgHandler.MESStationName,
                        init.AppInit.MsgHandler.ClassParameters.SubSystem,
                        init.AppInit.MsgHandler.ClassParameters.Location))
                    {
                        init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, "", "", init.AppInit.MsgHandler.ClassParameters.SubSystem,
                                        init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, "", "Updated in-house tag");
                        MessageBox.Show(Properties.Resources.sMessageSuccessInhousePrint,
                            Properties.Resources.sAppMessageBoxTitleInfo, MessageBoxButtons.OK, MessageBoxIcon.Information);
                        rbtnIHBSM_CheckedChanged(sender, e);
                    }
                    else
                    {
                        MessageBox.Show(Properties.Resources.sErrorInhouseUpdateFail,
                            Properties.Resources.sAppMessageBoxTitleInfo, MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] updating In-house bsm failed. <" + _className + ".btnUpdate_Click()>", ex);
            }
        }

        private void btnFilter_Click(object sender, EventArgs e)
        {
            try
            {
                Filter frmFilter = new Filter(init.AppInit.MsgHandler.DBPersistor.GetComboData());

                frmFilter.ShowDialog();
                if (frmFilter.DialogResult != DialogResult.Cancel)
                {
                    airline = frmFilter.Airline;
                    flightNumber = frmFilter.FlightNumber;
                    sdo = frmFilter.SDO;
                    btnFilter.Enabled = false;
                    btnResetFilter.Enabled = true;
                    filtered = true;
                    _flag = frmFilter.Flag;

                    if (_flag != 0)
                    {
                        if (rbtnIATABSM.Checked == true)
                        {
                            rbtnIATABSM_CheckedChanged(sender, e);
                        }
                        else if (rbtnIHBSM.Checked == true)
                        {
                            rbtnIHBSM_CheckedChanged(sender, e);
                        }
                        //init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, "", "", init.AppInit.MsgHandler.ClassParameters.SubSystem,
                        //                        init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, "", "Filtered in-house tag");
                    }
                }
                frmFilter.Dispose();
                frmFilter = null;
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] filtering data failed. <" + _className + ".btnFilter_Click()>", ex);
            }
        }

        private void btnResetFilter_Click(object sender, EventArgs e)
        {
            try
            {
                filtered = false;
                btnFilter.Enabled = true;
                btnResetFilter.Enabled = false;
                airline = "";
                flightNumber = "";
                sdo = Convert.ToDateTime("01-Jan-1900");
                _flag = 0;
                if (rbtnIATABSM.Checked == true)
                {
                    rbtnIATABSM_CheckedChanged(sender, e);
                }
                else if (rbtnIHBSM.Checked == true)
                {
                    rbtnIHBSM_CheckedChanged(sender, e);
                }
                //init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, "", "", init.AppInit.MsgHandler.ClassParameters.SubSystem,
                //                        init.AppInit.MsgHandler.ClassParameters.Location, init.AppInit.MsgHandler.MESStationName, "", "Reset filter in-house tag");
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] resetting filtered data failed. <" + _className + ".btnResetFilter_Click()>", ex);
            }
        }

        private void btnSpace_Click(object sender, EventArgs e)
        {
            AddText(" ");
            SetFocusToActiveTextbox(false);
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                if (MessageBox.Show(Properties.Resources.sQuestionDeleteIHTag,
                Properties.Resources.sAppMessageBoxTitleConfirm, MessageBoxButtons.YesNo) == DialogResult.Yes)
                {
                    string tag, airline, subSystem, flightNo, location, station;
                    tag = txtEditAirline.Tag.ToString();
                    airline = txtEditAirline.Text;
                    flightNo = txtEditFlightNumber.Text;
                    location = init.AppInit.MsgHandler.ClassParameters.Location;
                    subSystem = init.AppInit.MsgHandler.ClassParameters.SubSystem;
                    station = init.AppInit.MsgHandler.MESStationName;

                    init.AppInit.MsgHandler.DBPersistor.RemoveInHouseBSM(txtEditAirline.Tag.ToString(),
                        init.AppInit.MsgHandler.ClassParameters.SubSystem,
                        init.AppInit.MsgHandler.ClassParameters.Location);

                    rbtnIHBSM_CheckedChanged(sender, e);

                    init.AppInit.MsgHandler.DBPersistor.InsertMESEvent(DateTime.Now, string.Empty, tag,
                                subSystem, location, station, "", "Deleted in-house tag");

                    MessageBox.Show(Properties.Resources.sMessageSuccessRemove,
                            Properties.Resources.sAppMessageBoxTitleInfo, MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Getting inhouse bsm list failed. <" + _className + ".btnDelete_Click()>", ex);
            }
        }

        private void tabControl2_Click(object sender, EventArgs e)
        {
            SetFocusToActiveTextbox(false);
        }

        private void txtIATATag_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar != '\r' && e.KeyChar != '\b')
            {
                if (!Regex.IsMatch(e.KeyChar.ToString(), "\\d+"))
                {
                    e.Handled = true;
                }
            }
        }
        #endregion

        #region Custom Functions and Methods
        /// <summary>
        /// Common event handler for buttons 0-9 and A-Z.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ButtonText_Click(object sender, EventArgs e)
        {
            AddText(((Button)sender).Text);
            SetFocusToActiveTextbox(false);
        }

        /// <summary>
        /// Add the text to respective text box based on the local field current active text box.
        /// If the text length in the text boxy is greater than restricted length,
        /// this function will ignore the input text.
        /// </summary>
        /// <param name="CharString">Require character to add into text box as System.String.</param>
        private void AddText(string CharString)
        {
            switch (currentFocusTxtBox)
            {
                case "txtIATATag":
                    if (!CheckNumeric(CharString))
                    {
                        txtIATATag.Text += CharString;
                    }
                    break;
                case "txtQty":
                    if (!CheckNumeric(CharString))
                    {
                        txtQty.Text += CharString;
                    }
                    break;
                case "txtDestCode":
                    txtDestCode.Text += CharString;
                    break;
                case "txtAireLineCode":
                    txtAireLineCode.Text += CharString;
                    break;
                case "txtFallbackShortMsg":
                    txtFallbackShortMsg.Text += CharString;
                    break;
                case "txtIHFlightNo":
                    txtIHFlightNo.Text += CharString;
                    break;
                case "txtIHAirlineCode":
                    txtIHAirlineCode.Text += CharString;
                    break;
                case "txtIHShortMsg":
                    txtIHShortMsg.Text += CharString;
                    break;
                case "txtIHSDO":
                    //if (txtIHSDO.Text.Length < (defaultDateFormat.Length+defaultTimeFormat.Length+1))
                    //{
                    //    if (txtIHSDO.Text.Length == defaultDateFormat.IndexOf('-',1))
                    //    {
                    //        txtIHSDO.Text += "-";
                    //    }
                    //    if (txtIHSDO.Text.Length == defaultDateFormat.IndexOf('-',defaultDateFormat.IndexOf('-', 1) + 1))
                    //    {
                    //        txtIHSDO.Text += "-";
                    //    }
                    //    if (txtIHSDO.Text.Length == defaultDateFormat.Length)
                    //    {
                    //        txtIHSDO.Text += " ";
                    //    }
                    //    if (txtIHSDO.Text.Length == defaultDateFormat.Length+1+defaultTimeFormat.IndexOf(':',1))
                    //    {
                    //        txtIHSDO.Text += ":";
                    //    }
                    //    if (txtIHSDO.Text.Length == defaultDateFormat.Length + 1 + defaultTimeFormat.IndexOf(':', defaultTimeFormat.IndexOf(':', 1)+1))
                    //    {
                    //        txtIHSDO.Text += ":";
                    //    }
                    //    txtIHSDO.Text += CharString;
                    //}
                    txtIHSDO.Text += CharString;
                    break;
                case "txtEditFlightNumber":
                    txtEditFlightNumber.Text += CharString;
                    break;
                case "txtEditAirline":
                    txtEditAirline.Text += CharString;
                    break;
                case "txtEditSDO":
                    //if (txtEditSDO.Text.Length < (defaultDateFormat.Length + defaultTimeFormat.Length + 1))
                    //{
                    //    if (txtEditSDO.Text.Length == defaultDateFormat.IndexOf('-', 1))
                    //    {
                    //        txtEditSDO.Text += "-";
                    //    }
                    //    if (txtEditSDO.Text.Length == defaultDateFormat.IndexOf('-', defaultDateFormat.IndexOf('-', 1) + 1))
                    //    {
                    //        txtEditSDO.Text += "-";
                    //    }
                    //    if (txtEditSDO.Text.Length == defaultDateFormat.Length)
                    //    {
                    //        txtEditSDO.Text += " ";
                    //    }
                    //    if (txtEditSDO.Text.Length == defaultDateFormat.Length + 1 + defaultTimeFormat.IndexOf(':', 1))
                    //    {
                    //        txtEditSDO.Text += ":";
                    //    }
                    //    if (txtEditSDO.Text.Length == defaultDateFormat.Length + 1 + defaultTimeFormat.IndexOf(':', defaultTimeFormat.IndexOf(':', 1) + 1))
                    //    {
                    //        txtEditSDO.Text += ":";
                    //    }
                    //    txtEditSDO.Text += CharString;
                    //}
                    txtEditSDO.Text += CharString;
                    break;
                case "txtIATAShortMsg":
                    txtIATAShortMsg.Text += CharString;
                    break;
                case "txtIATAAirline":
                    txtIATAAirline.Text += CharString;
                    break;
                case "txtIATAGenerateTagMsg":
                    txtIATAGenerateTagMsg.Text += CharString;
                    break;
                case "txtIATASDO":
                    //if (txtIATASDO.Text.Length < (defaultDateFormat.Length + defaultTimeFormat.Length + 1))
                    //{
                    //    if (txtIATASDO.Text.Length == defaultDateFormat.IndexOf('-', 1))
                    //    {
                    //        txtIATASDO.Text += "-";
                    //    }
                    //    if (txtIATASDO.Text.Length == defaultDateFormat.IndexOf('-', defaultDateFormat.IndexOf('-', 1) + 1))
                    //    {
                    //        txtIATASDO.Text += "-";
                    //    }
                    //    if (txtIATASDO.Text.Length == defaultDateFormat.Length)
                    //    {
                    //        txtIATASDO.Text += " ";
                    //    }
                    //    if (txtIATASDO.Text.Length == defaultDateFormat.Length + 1 + defaultTimeFormat.IndexOf(':', 1))
                    //    {
                    //        txtIATASDO.Text += ":";
                    //    }
                    //    if (txtIATASDO.Text.Length == defaultDateFormat.Length + 1 + defaultTimeFormat.IndexOf(':', defaultTimeFormat.IndexOf(':', 1) + 1))
                    //    {
                    //        txtIATASDO.Text += ":";
                    //    }
                    //    txtIATASDO.Text += CharString;
                    //}
                    txtIATASDO.Text += CharString;
                    break;
                case "txtIATAFlightNo":
                    txtIATAFlightNo.Text += CharString;
                    break;
                case "txtEditDescription":
                    txtEditDescription.Text += CharString;
                    break;
                case "cmbInhouseFirstDigit":
                    if (!CheckNumeric(CharString))
                    {
                        if (Convert.ToInt32(CharString) > 1)
                        {
                            if (cmbInhouseFirstDigit.Text.Length < 1)
                            {
                                cmbInhouseFirstDigit.Text += CharString;
                            }
                        }
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
        private void SetFocusToActiveTextbox(bool ClearTextBoxes)
        {
            switch (currentFocusTxtBox)
            {
                case "txtIATATag":
                    txtIATATag.SelectionStart = txtIATATag.Text.Length;
                    txtIATATag.Focus();
                    break;
                case "txtQty":
                    txtQty.SelectionStart = txtQty.Text.Length;
                    txtQty.Focus();
                    break;
                case "txtDestCode":
                    txtDestCode.SelectionStart = txtDestCode.Text.Length;
                    txtDestCode.Focus();
                    break;
                case "txtAireLineCode":
                    txtAireLineCode.SelectionStart = txtAireLineCode.Text.Length;
                    txtAireLineCode.Focus();
                    break;
                case "txtFallbackShortMsg":
                    txtFallbackShortMsg.SelectionStart = txtFallbackShortMsg.Text.Length;
                    txtFallbackShortMsg.Focus();
                    break;
                case "txtIHFlightNo":
                    txtIHFlightNo.SelectionStart = txtIHFlightNo.Text.Length;
                    txtIHFlightNo.Focus();
                    break;
                case "txtIHAirlineCode":
                    txtIHAirlineCode.SelectionStart = txtIHAirlineCode.Text.Length;
                    txtIHAirlineCode.Focus();
                    break;
                case "txtIHShortMsg":
                    txtIHShortMsg.SelectionStart = txtIHShortMsg.Text.Length;
                    txtIHShortMsg.Focus();
                    break;
                case "txtIHSDO":
                    txtIHSDO.SelectionStart = txtIHSDO.Text.Length;
                    txtIHSDO.Focus();
                    break;
                case "txtEditFlightNumber":
                    txtEditFlightNumber.SelectionStart = txtEditFlightNumber.Text.Length;
                    txtEditFlightNumber.Focus();
                    break;
                case "txtEditAirline":
                    txtEditAirline.SelectionStart = txtEditAirline.Text.Length;
                    txtEditAirline.Focus();
                    break;
                case "txtEditSDO":
                    txtEditSDO.SelectionStart = txtEditSDO.Text.Length;
                    txtEditSDO.Focus();
                    break;
                case "txtIATAShortMsg":
                    txtIATAShortMsg.SelectionStart = txtIATAShortMsg.Text.Length;
                    txtIATAShortMsg.Focus();
                    break;
                case "txtIATAAirline":
                    txtIATAAirline.SelectionStart = txtIATAAirline.Text.Length;
                    txtIATAAirline.Focus();
                    break;
                case "txtIATAGenerateTagMsg":
                    txtIATAGenerateTagMsg.SelectionStart = txtIATAGenerateTagMsg.Text.Length;
                    txtIATAGenerateTagMsg.Focus();
                    break;
                case "txtIATASDO":
                    txtIATASDO.SelectionStart = txtIATASDO.Text.Length;
                    txtIATASDO.Focus();
                    break;
                case "txtIATAFlightNo":
                    txtIATAFlightNo.SelectionStart = txtIATAFlightNo.Text.Length;
                    txtIATAFlightNo.Focus();
                    break;
                case "txtEditDescription":
                    txtEditDescription.SelectionStart = txtEditDescription.Text.Length;
                    txtEditDescription.Focus();
                    break;
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

        private void btnClear_Click(object sender, EventArgs e)
        {
            switch (tabGenerateTag.SelectedTab.Text.Trim())
            {
                case "IATA Interline":
                    txtIATATag.Text = "";
                    if (rbtnPrintIATATag.Checked == true)
                    {
                        txtIATAShortMsg.Text = "";
                    }
                    if (rbtnGenerateIATATag.Checked == true)
                    {
                        txtIHAirlineCode.Text = "";
                        txtIATAAirline.Text = "";
                        txtIATAFlightNo.Text = "";
                        txtIATASDO.Text = "";
                        txtIATAGenerateTagMsg.Text = "";
                    }
                    txtIATATag_Click(sender, e);
                    break;
                case "IATA Fallback":
                    txtAireLineCode.Text = "";
                    txtDestCode.Text = "";
                    txtQty.Text = "";
                    txtFallbackShortMsg.Text = "";
                    txtAireLineCode_Click(sender, e);
                    break;
                case "In-House":
                    cmbInhouseFirstDigit.SelectedIndex=-1;
                    txtIHAirlineCode.Text = "";
                    txtIHFlightNo.Text = "";
                    txtIHSDO.Text = "";
                    txtIHShortMsg.Text = "";
                    break;
                case "Pseudo BSM":
                    txtEditAirline.Text = "";
                    txtEditDescription.Text = "";
                    txtEditFlightNumber.Text = "";
                    txtEditSDO.Text = "";
                    txtEditAirline_Click(sender, e);
                    break;
            }
            SetFocusToActiveTextbox(true);
        }

        private void EnableDisableButtons()
        {
            switch (tabGenerateTag.SelectedTab.Text.Trim())
            {
                case "IATA Interline":
                case "IATA Fallback":
                case "In-House":
                    btnFilter.Enabled = false;
                    btnResetFilter.Enabled = false;
                    btnUpdate.Enabled = false;
                    btnDelete.Enabled = false;
                    btnPrint.Enabled = true;
                    break;
                case "Pseudo BSM":
                    if (rbtnIATABSM.Checked == true)
                    {
                        if (dgvIATAList.Rows.Count > 0)
                        {
                            if (filtered == false)
                            {
                                btnFilter.Enabled = true;
                                btnResetFilter.Enabled = false;
                                btnPrint.Enabled = true;
                            }
                            else
                            {
                                btnFilter.Enabled = false;
                                btnResetFilter.Enabled = true;
                                btnPrint.Enabled = true;
                            }
                            btnUpdate.Enabled = false;
                            btnDelete.Enabled = false;
                        }
                        else
                        {
                            btnPrint.Enabled = true;
                            btnUpdate.Enabled = false;
                            btnDelete.Enabled = false;
                        }
                    }
                    else if (rbtnIHBSM.Checked == true)
                    {
                        if (dgvBSM.Rows.Count > 0)
                        {
                            if (filtered == false)
                            {
                                btnFilter.Enabled = true;
                                btnResetFilter.Enabled = false;
                            }
                            else
                            {
                                btnFilter.Enabled = false;
                                btnResetFilter.Enabled = true;
                            }
                            btnUpdate.Enabled = true;
                            btnDelete.Enabled = true;
                            btnPrint.Enabled = true;
                        }
                        else
                        {
                            btnUpdate.Enabled = false;
                            btnDelete.Enabled = false;
                            btnPrint.Enabled = true;
                        }
                    }
                    break;
            }
        }

        private void GetFirstDigits()
        {
            string[] firstDigits = init.ClassParameters.FirstDigitForInhouseBSM.Split(',');
            for (int i = 0; i < firstDigits.Length; i++)
            {
                cmbInhouseFirstDigit.Items.Add(firstDigits[i]);
            }
        }

        private void GetInhouseBSM()
        {
            try
            {
                if (rbtnIHBSM.Checked == true)
                {
                    DataTable inhouseBSMList = init.AppInit.MsgHandler.DBPersistor.GetInhouseTag(airline, flightNumber, sdo,
                        init.AppInit.MsgHandler.MESStationName, _flag);

                    for (int i = 0; i < inhouseBSMList.Columns.Count; i++)
                    {
                        if (dgvBSM.Columns.Count > i)
                        {
                            dgvBSM.Columns[i].DataPropertyName = inhouseBSMList.Columns[i].ColumnName;
                        }
                        if (inhouseBSMList.Columns[i].ColumnName == "SDO")
                        {
                            dgvBSM.Columns[i].DefaultCellStyle.Format = init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat;
                        }
                    }
                    dgvBSM.DataSource = inhouseBSMList;
                    dgvBSM.Refresh();
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Getting inhouse bsm list failed. <" + _className + ".tmrSysTime_Tick()>", ex);
            }
        }

        private void GetIATATagList()
        {
            try
            {
                DataTable iataTagList = init.AppInit.MsgHandler.DBPersistor.GetIATATagList(airline, flightNumber, sdo,
                    init.AppInit.MsgHandler.MESStationName, _flag);
                for (int i = 0; i < iataTagList.Columns.Count; i++)
                {
                    if (dgvIATAList.Columns.Count > i)
                    {
                        dgvIATAList.Columns[i].DataPropertyName = iataTagList.Columns[i].ColumnName;
                    }
                    if (iataTagList.Columns[i].ColumnName == "SDO")
                    {
                        dgvIATAList.Columns[i].DefaultCellStyle.Format = init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat + " " +
                            init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultTimeFormat;
                    }
                }
                dgvIATAList.DataSource = iataTagList;
                dgvIATAList.Refresh();
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Getting IATA Tag list failed. <" + _className + ".tmrSysTime_Tick()>", ex);
            }
        }

        /// <summary>
        /// Load airlines from airline tables and set all the 2 characters airline code to 
        /// airline function buttons on the form.
        /// </summary>
        private void PrepareAirlineFunctionButtons()
        {
            int i = 0;
            try
            {
                DataTable dtAirlines = init.AppInit.MsgHandler.DBPersistor.GetAirlines();
                if (dtAirlines.Rows.Count > 0)
                {
                    for (i = 0; i < dtAirlines.Rows.Count; i++)
                    {
                        tabPageAirline.Controls["btnAirline" + (i + 1).ToString()].Text = dtAirlines.Rows[i][0].ToString();
                        tabPageAirline.Controls["btnAirline" + (i + 1).ToString()].Tag = dtAirlines.Rows[i][1].ToString();
                    }
                    for (int j = i; j < 34; j++)
                    {
                        tabPageAirline.Controls["btnAirline" + (j + 1).ToString()].Text = "+";
                        tabPageAirline.Controls["btnAirline" + (j + 1).ToString()].Enabled = false;
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

        private void ChangeCharacterCase(object sender, EventArgs e)
        {
            if (shiftPressed == true)
            {
                shiftPressed = false;
                for (int i = 65; i < 91; i++)
                {
                    tabPageAlphabet.Controls["btn" + Convert.ToChar((Char)i).ToString()].Text = tabPageAlphabet.Controls["btn" + Convert.ToChar((Char)i).ToString()].Text.ToLower().ToString();
                }
            }
            else
            {
                shiftPressed = true;
                for (int i = 65; i < 91; i++)
                {
                    tabPageAlphabet.Controls["btn" + Convert.ToChar((Char)i).ToString()].Text = tabPageAlphabet.Controls["btn" + Convert.ToChar((Char)i).ToString()].Text.ToUpper().ToString();
                }
            }
            SetFocusToActiveTextbox(false);
        }
        #endregion

        private void txtIHFlightNo_Validated(object sender, EventArgs e)
        {
            Regex oCheckNumeric = new Regex("[^0-9]");
            if (oCheckNumeric.IsMatch(txtIHFlightNo.Text))
            {
                this.errMessage.SetError(txtIHFlightNo, "");
                this.errMessage.SetError(txtIHFlightNo, "Only numeric values allow.");
            }
            else
            {
                this.errMessage.SetError(txtIHFlightNo, "");
            }
        }

        private void txtIHSDO_Validated(object sender, EventArgs e)
        {
            DateTime dtOutput;
            bool isValid = DateTime.TryParseExact(txtIHSDO.Text,
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat,null, System.Globalization.DateTimeStyles.None, out dtOutput);
            if (txtIHSDO.Text.Trim() != "")
            {
                if (isValid == false)
                {
                    this.errMessage.SetError(txtIHSDO, "");
                    this.errMessage.SetError(txtIHSDO, "Invalid date format. The require date format is : " +
                        init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat);
                }
                else
                {
                    this.errMessage.SetError(txtIHSDO, "");
                }
            }
            else
            {
                this.errMessage.SetError(txtIHSDO, "");
            }
        }

        private void txtQty_Validated(object sender, EventArgs e)
        {
            Regex oCheckNumeric = new Regex("[^0-9]");
            if (oCheckNumeric.IsMatch(txtQty.Text))
            {
                this.errMessage.SetError(txtQty, "");
                this.errMessage.SetError(txtQty, "Only numeric values allow.");
            }
            else
            {
                this.errMessage.SetError(txtQty, "");
            }
        }

        private void txtIATATag_Validated(object sender, EventArgs e)
        {
            Regex oCheckNumeric = new Regex("[^0-9]");
            if (oCheckNumeric.IsMatch(txtIATATag.Text))
            {
                this.errMessage.SetError(txtIATATag, "");
                this.errMessage.SetError(txtIATATag, "Only numeric values allow.");
            }
            else
            {
                this.errMessage.SetError(txtIATATag, "");
            }
        }

        private void txtEditSDO_Validated(object sender, EventArgs e)
        {
            DateTime dtOutput;
            bool isValid = DateTime.TryParseExact(txtEditSDO.Text,
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat, null, System.Globalization.DateTimeStyles.None, out dtOutput);
            if (txtEditSDO.Text.Trim() != "")
            {
                if (isValid == false)
                {
                    this.errMessage.SetError(txtEditSDO, "");
                    this.errMessage.SetError(txtEditSDO, "Invalid date format. The require date format is : " +
                        init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat);
                }
                else
                {
                    this.errMessage.SetError(txtEditSDO, "");
                }
            }
            else
            {
                this.errMessage.SetError(txtEditSDO, "");
            }
        }

        private void txtIATAFlightNo_Validated(object sender, EventArgs e)
        {
            Regex oCheckNumeric = new Regex("[^0-9]");
            if (oCheckNumeric.IsMatch(txtIATAFlightNo.Text))
            {
                this.errMessage.SetError(txtIATAFlightNo, "");
                this.errMessage.SetError(txtIATAFlightNo, "Only numeric values allow.");
            }
            else
            {
                this.errMessage.SetError(txtIATAFlightNo, "");
            }
        }

        private void txtIATASDO_Validated(object sender, EventArgs e)
        {
            DateTime dtOutput;
            bool isValid = DateTime.TryParseExact(txtIATASDO.Text,
                init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat, null, System.Globalization.DateTimeStyles.None, out dtOutput);
            if (txtIATASDO.Text.Trim() != "")
            {
                if (isValid == false)
                {
                    this.errMessage.SetError(txtIATASDO, "");
                    this.errMessage.SetError(txtIATASDO, "Invalid date format. The require date format is : " +
                        init.AppInit.MsgHandler.DBPersistor.ClassParameters.DefaultDateFormat);
                }
                else
                {
                    this.errMessage.SetError(txtIATASDO, "");
                }
            }
            else
            {
                this.errMessage.SetError(txtIATASDO, "");
            }
        }

        private void rbtnIATABSM_CheckedChanged(object sender, EventArgs e)
        {
            try
            {
                grpEditInhouseTag.Enabled = false;
                dgvIATAList.Visible = true;
                dgvBSM.Visible = false;

                txtEditAirline.Text = "";
                txtEditFlightNumber.Text = "";
                txtEditSDO.Text = "";
                txtEditDescription.Text = "";

                GetIATATagList();

                dgvIATAList_Click(sender, e);
                EnableDisableButtons();

                lblTotalRecord.Text = "(Total: " + dgvIATAList.Rows.Count.ToString() + ")";
                
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] getting IATA bsm failed. <" + _className + ".rbtnIATABSM_Click()>", ex);
            }
        }

        private void TextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            e.KeyChar = Char.ToUpper(e.KeyChar);
        }
    }
}

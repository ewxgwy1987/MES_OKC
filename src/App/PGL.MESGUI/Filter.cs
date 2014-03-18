#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       Filter.cs
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
using System.Windows.Forms;
#endregion

namespace PGL.MESGUI
{
    public partial class Filter : Form
    {
        #region Local Variable Declaration
        DataSet comboDataList = null;
        public string Airline = " ";
        public string FlightNumber = " ";
        public DateTime SDO = Convert.ToDateTime("01-Jan-1900");

        // Flag: 100 - only search by airline, 110 - search by airline and flight#, 111 - search by airline, flight# and SDO
        //       001 - Only search by SDO, 010 - search by flight#, 011 - search by flight# and SDO, 101 - search by airline and SDO
        public int Flag = 0;

        #endregion
        
        #region Windows Designer Generated Code
        public Filter(DataSet comboData)
        {
            InitializeComponent();
            comboDataList = comboData;
            Flag = 0; 
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void Filter_Load(object sender, EventArgs e)
        {
            LoadData();
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            Flag = 0;

            if (cmbAirline.Text.Trim() != "" && chkAirline.Checked == true)
            {
                Airline = cmbAirline.Text;
                Flag = 100;
            }
            
            if (cmbFlight.Text.Trim() != "" && chkFlight.Checked == true)
            {
                FlightNumber = cmbFlight.Text;
                Flag = Flag + 10;
            }

            // if (Convert.ToDateTime(cmbSDO.Text).ToString("dd-MMM-yyyy") != "01-Jan-1900" && chkSDO.Checked == true)
            if (chkSDO.Checked == true)
            {
                SDO = Convert.ToDateTime(cmbSDO.Text);
                Flag = Flag + 1;
            }

            this.DialogResult = DialogResult.OK;
            this.Close();
        }
        #endregion

        #region Custom Functions and Methods
        private void LoadData()
        {
            if (comboDataList.Tables["Airlines"].Rows.Count > 0)
            {
                cmbAirline.DataSource = comboDataList.Tables["Airlines"];
                cmbAirline.DisplayMember = comboDataList.Tables["Airlines"].Columns[0].ColumnName;
            }

            if (comboDataList.Tables["FlightNumber"].Rows.Count > 0)
            {
                cmbFlight.DataSource = comboDataList.Tables["FlightNumber"];
                cmbFlight.DisplayMember = comboDataList.Tables["FlightNumber"].Columns[0].ColumnName;
            }

            if (comboDataList.Tables["SDO"].Rows.Count > 0)
            {
                cmbSDO.DataSource = comboDataList.Tables["SDO"];
                cmbSDO.DisplayMember = comboDataList.Tables["SDO"].Columns[0].ColumnName;
            }
        }
        #endregion

        private void chkAirline_CheckedChanged(object sender, EventArgs e)
        {
            EnableDisableOkButton();
        }

        private void chkFlight_CheckedChanged(object sender, EventArgs e)
        {
            EnableDisableOkButton();
        }

        private void chkSDO_CheckedChanged(object sender, EventArgs e)
        {
            EnableDisableOkButton();
        }

        private void cmbAirline_SelectedIndexChanged(object sender, EventArgs e)
        {
            EnableDisableOkButton();
        }

        private void EnableDisableOkButton()
        {
            if (((chkAirline.Checked == true) && (cmbAirline.Text.Trim() != "")) ||
                ((chkFlight.Checked == true) && (cmbFlight.Text.Trim() != "")) ||
                (chkSDO.Checked == true))
            {
                btnOK.Enabled = true;
            }
            else
            {
                btnOK.Enabled = false;
            }
        }

        private void cmbFlight_SelectedIndexChanged(object sender, EventArgs e)
        {
            EnableDisableOkButton();
        }

        private void cmbSDO_SelectedIndexChanged(object sender, EventArgs e)
        {
            EnableDisableOkButton();
        }
    }
}

#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       Selection.cs
// Revision:      1.0 -   15 Jun 2010, By Albert Sun.
// =====================================================================================
//
#endregion

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace PGL.MESGUI
{
    public partial class Selection : Form
    {
        public string sFlightNumber=string.Empty;
        public string sDestination=string.Empty;
        public string sDestinationID = string.Empty;
        public string sSubSystem = string.Empty;
        public string sTravelClass = string.Empty;
        public string sPassengerName = string.Empty;
        public string sFlightDestination = string.Empty;
        public BHS.MES.LocationID[] sRushDestination = new BHS.MES.LocationID[1];
        //#################################### add by PF
        public string sMinSecurityLevel = string.Empty;
        public string sFlight = string.Empty;
        public int nCurrentRow;
        public int nCurrentColumn;
        private readonly string _className = System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Business layer initializer class.
        BHS.MES.GUI.GUIInitializer init;
        private static readonly log4net.ILog logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        //####################################

        string sOperationMode=string.Empty;
        private string _licensePlate;
        private string _bagGid ;

        public Selection()
        {
            InitializeComponent();
            //init = new BHS.MES.GUI.GUIInitializer();
        }

        public Selection(DataTable dtInformation, string sMode,string sLicensePlate, string sGID, bool isHLCMode)
        {
            InitializeComponent();
            init = new BHS.MES.GUI.GUIInitializer();

            if (dtInformation.Columns[2].ColumnName == "t2")
                dtInformation.Columns.Remove("t2");
            //dgvSelection.Columns[2].Visible; // 

            dgvSelection.DataSource = dtInformation;

            _bagGid = sGID;
            _licensePlate = sLicensePlate;

            if (!isHLCMode)
            {
                if (dtInformation.Columns.Count==4)
                {
                    btnRefresh.Visible = false;

                    if (dtInformation.Columns[0].ColumnName == "Chute")
                        dgvSelection.Columns[0].Visible = false;

                    if (dtInformation.Columns[3].ColumnName == "Is_Available")
                        dgvSelection.Columns[3].Visible = false;
                }
            }

            if (isHLCMode)
            {
                if (dtInformation.Columns.Count > 3)
                {
                    btnRefresh.Visible = false;

                    if (dtInformation.Columns[3].ColumnName == "SORT_DESTINATION")
                        dgvSelection.Columns[3].Visible = false;

                    if (dtInformation.Columns[5].ColumnName == "SUBSYSTEM")
                        dgvSelection.Columns[5].Visible = false;

                    if (dtInformation.Columns[6].ColumnName == "IS_AVAILABLE")
                        dgvSelection.Columns[6].Visible = false;
                }

                if (dtInformation.Columns.Count == 13)
                {

                    btnRefresh.Visible = true;

                    if (dtInformation.Columns[8].ColumnName == "Destination ID")
                        dgvSelection.Columns[8].Visible = false;

                    if (dtInformation.Columns[9].ColumnName == "Sub System")
                        dgvSelection.Columns[9].Visible = false;

                    if (dtInformation.Columns[12].ColumnName == "Is_Available")
                        dgvSelection.Columns[12].Visible = false;
                }
            }

            if (dtInformation.Columns[2].ColumnName == "TTSID")
                dgvSelection.Columns[2].Visible = false;

            dgvSelection.Refresh();
            sOperationMode = sMode;
            PrepareGridView();
            lblRecordsQuantity.Text = dgvSelection.Rows.Count.ToString();
        }

        public Selection(BHS.MES.LocationID[] destination)
        {
            InitializeComponent();
            dgvSelection.DataSource = destination;
            dgvSelection.Refresh();
            lblRecordsQuantity.Text = dgvSelection.Rows.Count.ToString();
            nCurrentRow = 0;
            nCurrentColumn = 0;
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
            int i = dgvSelection.CurrentRow.Index;
            if (sOperationMode == "Flight")
            {
                DateTime dtTemp;
                if (DateTime.TryParse(dgvSelection.Rows[i].Cells[1].Value.ToString(), out dtTemp))
                {
                    sFlight = dgvSelection.Rows[i].Cells[0].Value.ToString() + ", " + dtTemp.ToString("yyyy-MM-dd HH:mm");
                }
                else
                {
                    sFlight = dgvSelection.Rows[i].Cells[0].Value.ToString();
                }
                sFlightNumber = dgvSelection.Rows[i].Cells[0].Value.ToString();
                sDestinationID = dgvSelection.Rows[i].Cells[3].Value.ToString();
                sDestination = dgvSelection.Rows[i].Cells[4].Value.ToString();
                sSubSystem = dgvSelection.Rows[i].Cells[5].Value.ToString();
                nCurrentRow = i;
            }
            else if (sOperationMode == "Tag")
            {
                sFlightNumber = dgvSelection.Rows[i].Cells[2].Value.ToString() + dgvSelection.Rows[i].Cells[3].Value.ToString() + ", " +
                    dgvSelection.Rows[i].Cells[4].Value.ToString();
                sTravelClass = dgvSelection.Rows[i].Cells[7].Value.ToString();
                sPassengerName = dgvSelection.Rows[i].Cells[10].Value.ToString();
                sDestination = dgvSelection.Rows[i].Cells[5].Value.ToString();
                sFlightDestination = dgvSelection.Rows[i].Cells[6].Value.ToString();
                sDestinationID = dgvSelection.Rows[i].Cells[8].Value.ToString();
                sSubSystem = dgvSelection.Rows[i].Cells[9].Value.ToString();
                sMinSecurityLevel = dgvSelection.Rows[i].Cells[11].Value.ToString();
            }
            else if (sOperationMode == string.Empty)
            {
                for (int j = 0; j < dgvSelection.Rows.Count; j++)
                {
                    if (j == i)
                    {
                        sRushDestination[0].Location = dgvSelection.Rows[j].Cells[0].Value.ToString();
                        sRushDestination[0].Location = dgvSelection.Rows[j].Cells[1].Value.ToString();
                    }
                }
            }
            else if (sOperationMode == "Sort Dest.")
            {
                sDestination = dgvSelection.Rows[i].Cells[1].Value.ToString();
                sDestinationID = dgvSelection.Rows[i].Cells[2].Value.ToString();
                //sSubSystem = dgvSelection.Rows[i].Cells[2].Value.ToString();
            }
        }

        private void btnRefresh_Click(object sender, EventArgs e)
        {
            if (init.Init())
            {
                DataTable dtPassengerInfo = init.AppInit.MsgHandler.DBPersistor.GetPassengerInfo(_licensePlate);

                if (dtPassengerInfo.Rows.Count > 0)
                {
                    for (int i = 0; i < dtPassengerInfo.Rows.Count; i++)
                    {
                        string dest = dtPassengerInfo.Rows[i][5].ToString();

                        for (int j = 0; j < dtPassengerInfo.Rows.Count; j++)
                        {
                            if (i != j)
                            {
                                if (dest == dtPassengerInfo.Rows[j][5].ToString())
                                {
                                    if ((bool.Parse(dtPassengerInfo.Rows[j][12].ToString())) && (bool.Parse(dtPassengerInfo.Rows[i][12].ToString())))
                                    {
                                        dtPassengerInfo.Rows.Remove(dtPassengerInfo.Rows[j]);
                                        j = j - 1;
                                    }
                                    else if ((!bool.Parse(dtPassengerInfo.Rows[j][12].ToString())) && (bool.Parse(dtPassengerInfo.Rows[i][12].ToString())))
                                    {
                                        dtPassengerInfo.Rows.Remove(dtPassengerInfo.Rows[j]);
                                        j = j - 1;
                                    }
                                    else if ((bool.Parse(dtPassengerInfo.Rows[j][12].ToString())) && (!bool.Parse(dtPassengerInfo.Rows[i][12].ToString())))
                                    {
                                        dtPassengerInfo.Rows.Remove(dtPassengerInfo.Rows[i]);
                                        i = i - 1;
                                    }
                                    else if ((!bool.Parse(dtPassengerInfo.Rows[j][12].ToString())) && (!bool.Parse(dtPassengerInfo.Rows[i][12].ToString())))
                                    {
                                        dtPassengerInfo.Rows.Remove(dtPassengerInfo.Rows[j]);
                                        j = j - 1;
                                    }
                                }
                            }
                        }
                    }
                }

                if (dtPassengerInfo != null)
                {
                    if (dtPassengerInfo.Rows.Count > 1)
                    {
                        if (dtPassengerInfo.Columns[2].ColumnName == "t2")
                            dtPassengerInfo.Columns.Remove("t2");
                        //dgvSelection.Columns[2].Visible; // 

                        dgvSelection.DataSource = dtPassengerInfo;

                        if (dtPassengerInfo.Columns.Count > 3)
                        {
                            if (dtPassengerInfo.Columns[3].ColumnName == "SORT_DESTINATION")
                                dgvSelection.Columns[3].Visible = false;

                            if (dtPassengerInfo.Columns[5].ColumnName == "SUBSYSTEM")
                                dgvSelection.Columns[5].Visible = false;

                            if (dtPassengerInfo.Columns[6].ColumnName == "IS_AVAILABLE")
                                dgvSelection.Columns[6].Visible = false;
                        }

                        if (dtPassengerInfo.Columns.Count == 13)
                        {
                            if (dtPassengerInfo.Columns[8].ColumnName == "Destination ID")
                                dgvSelection.Columns[8].Visible = false;

                            if (dtPassengerInfo.Columns[9].ColumnName == "Sub System")
                                dgvSelection.Columns[9].Visible = false;

                            if (dtPassengerInfo.Columns[12].ColumnName == "Is_Available")
                                dgvSelection.Columns[12].Visible = false;
                        }

                        if (dtPassengerInfo.Columns[2].ColumnName == "TTSID")
                            dgvSelection.Columns[2].Visible = false;

                        dgvSelection.Refresh();
                        //PrepareGridView();
                        //lblRecordsQuantity.Text = dgvSelection.Rows.Count.ToString();
                    }

                }
            }
         
        }

        private void PrepareGridView()
        {
            switch (sOperationMode)
            {
                case "Flight":
                    dgvSelection.Columns[0].HeaderText = "Flight #";
                    dgvSelection.Columns[1].HeaderText = "STD";
                    dgvSelection.Columns[1].DefaultCellStyle.Format = "yyyy-MMM-dd HH:mm";
                    dgvSelection.Columns[2].HeaderText = "Destination Airport";
                    dgvSelection.Columns[3].HeaderText = "Chute";
                    //dgvSelection.Columns[3].Visible = false;
                    dgvSelection.Columns[4].HeaderText = "Sort Destination";
                    dgvSelection.Columns[5].Visible = false;
                    break;
                case "Tag":
                    dgvSelection.Columns[4].HeaderText = "STD";
                    dgvSelection.Columns[4].DefaultCellStyle.Format = "yyyy-MMM-dd HH:mm";
                    break;
                case "Sort Dest.":
                    //dgvSelection.Columns[0].Visible = false;
                    dgvSelection.Columns[1].HeaderText = "Destination";
                    //dgvSelection.Columns[2].Visible = false;
                    break;
            }
        }

        private void Selection_Load(object sender, EventArgs e)
        {
            this.StartPosition = FormStartPosition.CenterScreen;

            switch (sOperationMode)
            {
                case "Flight":
                    this.Width = 1020;
                    this.Height = 565;
                    break;
                case "Tag":
                    this.Width = 1020;
                    this.Height = 565;
                    break;
                case "Sort Dest.":
                    this.Width = 1020;
                    this.Height = 565;
                    break;
            }
        }

        private void dgvSelection_RowPostPaint(object sender, DataGridViewRowPostPaintEventArgs e)
        {
            try
            {
                SolidBrush v_SolidBrush = new SolidBrush(dgvSelection.RowHeadersDefaultCellStyle.ForeColor);
                int nLineNo = 0;
                nLineNo = e.RowIndex + 1;
                string strLine = nLineNo.ToString();
                Font font = new Font(e.InheritedRowStyle.Font.Name, e.InheritedRowStyle.Font.Size - 4);

                e.Graphics.DrawString(strLine, font, v_SolidBrush, e.RowBounds.Location.X - 1, e.RowBounds.Location.Y + 3);
                dgvSelection.CurrentCell = dgvSelection[nCurrentColumn, nCurrentRow];
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Datagridview paint failed. <" + _className + ".dgvSelection_RowPostPaint()>", ex);
            }
        }

        private void btnPageUp_Click(object sender, EventArgs e)
        {
            nCurrentRow = 0;
            dgvSelection.CurrentCell = dgvSelection[nCurrentColumn, dgvSelection.Rows.GetFirstRow(DataGridViewElementStates.None)];
        }

        private void btnLineUp_Click(object sender, EventArgs e)
        {
            if (nCurrentRow != 0)
            {
                nCurrentRow -= 1;
                dgvSelection.CurrentCell = dgvSelection[nCurrentColumn, nCurrentRow];
            }
        }

        private void btnLineDown_Click(object sender, EventArgs e)
        {
            if (nCurrentRow < dgvSelection.Rows.Count - 1)
            {
                nCurrentRow += 1;
                dgvSelection.CurrentCell = dgvSelection[nCurrentColumn, nCurrentRow];
            }
        }

        private void btnPageDown_Click(object sender, EventArgs e)
        {
            nCurrentRow = dgvSelection.Rows.Count - 1;
            dgvSelection.CurrentCell = dgvSelection[nCurrentColumn, dgvSelection.Rows.GetLastRow(DataGridViewElementStates.None)];
        }

        private void btnLineHome_Click(object sender, EventArgs e)
        {
            nCurrentColumn = 0;
            dgvSelection.CurrentCell = dgvSelection[nCurrentColumn, nCurrentRow];
        }

        private void btnLineLeft_Click(object sender, EventArgs e)
        {
            if (nCurrentColumn != 0)
            {
                nCurrentColumn -= 1;
                dgvSelection.CurrentCell = dgvSelection[nCurrentColumn, nCurrentRow];
            }
        }

        private void btnLineRight_Click(object sender, EventArgs e)
        {
            if (nCurrentColumn < dgvSelection.Columns.Count - 1)
            {
                nCurrentColumn += 1;
                dgvSelection.CurrentCell = dgvSelection[nCurrentColumn, nCurrentRow];
            }
        }

        private void btnLineEnd_Click(object sender, EventArgs e)
        {
            nCurrentColumn = dgvSelection.Columns.Count - 2;
            dgvSelection.CurrentCell = dgvSelection[nCurrentColumn, nCurrentRow];
            btnLineRight_Click(null, null);
        }

        private void dgvSelection_RowEnter(object sender, DataGridViewCellEventArgs e)
        {
            //if(dgvSelection.Rows.Count>0)
            //dgvSelection.CurrentCell = dgvSelection[0,  e.RowIndex];
            nCurrentRow = e.RowIndex;
            //dgvSelection.SelectedRows[e.RowIndex].Cells[0] // to get the first cell value, use the same way for all the cells
        }

    }
}

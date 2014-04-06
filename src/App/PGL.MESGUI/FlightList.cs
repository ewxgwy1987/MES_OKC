#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       FlightList.cs
// Revision:      1.0 -   20 Jun 2010, By Albert Sun.
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
using PALS;
using BHS.MES;
#endregion

namespace PGL.MESGUI
{
    public partial class FlightList : Form
    {
        #region Local Variable Declaration
        private readonly string _className = System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        private static readonly log4net.ILog logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private BHS.MES.GUI.GUIInitializer init = null;

        private DataTable dtFlightList;
        private int nCurrentRow;

        #endregion

        #region Windows Designer Generated Code
        public FlightList()
        {
            InitializeComponent();
        }

        public FlightList(BHS.MES.GUI.GUIInitializer initMain)
        {
            InitializeComponent();

            init = initMain;
            PrepareCombo();
            rbtnAll_Click(null, null);
        }

        private void FlightList_Load(object sender, EventArgs e)
        {
            this.Height = 768;
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void rbtnFilter_Click(object sender, EventArgs e)
        {
            cboHr.Enabled = true;

            cboHr.SelectedIndex = (cboHr.Items.Count + 1) / 2;
            LoadData(Convert.ToInt32(cboHr.Text));

            // Commented by Guo Wenyu 2014/04/06
            //if (cboHr.Items.Count == 49)
            //    cboHr.SelectedIndex = 24;
            //else
            //    LoadData(Convert.ToInt32(cboHr.Text));
        }

        private void rbtnAll_Click(object sender, EventArgs e)
        {
            cboHr.Enabled = false;
            LoadData(0);
        }

        private void cboHr_SelectedValueChanged(object sender, EventArgs e)
        {
            LoadData(Convert.ToInt32(cboHr.Text));
        }

        private void btnLineUp_Click(object sender, EventArgs e)
        {
            if (nCurrentRow != 0)
            {
                nCurrentRow -= 1;
                dgvFlightList.CurrentCell = dgvFlightList[0, nCurrentRow];
            }
        }

        private void btnLineDown_Click(object sender, EventArgs e)
        {
            if (nCurrentRow < dgvFlightList.Rows.Count - 1)
            {
                nCurrentRow += 1;
                dgvFlightList.CurrentCell = dgvFlightList[0, nCurrentRow];
            }
        }

        private void btnPageUp_Click(object sender, EventArgs e)
        {
            nCurrentRow = 0;
            dgvFlightList.CurrentCell = dgvFlightList[0, dgvFlightList.Rows.GetFirstRow(DataGridViewElementStates.None)];
        }

        private void btnPageDown_Click(object sender, EventArgs e)
        {
            nCurrentRow = dgvFlightList.Rows.Count - 1;
            dgvFlightList.CurrentCell = dgvFlightList[0, dgvFlightList.Rows.GetLastRow(DataGridViewElementStates.None)];
        }

        private void dgvFlightList_RowPostPaint(object sender, DataGridViewRowPostPaintEventArgs e)
        {
            try
            {
                SolidBrush v_SolidBrush = new SolidBrush(dgvFlightList.RowHeadersDefaultCellStyle.ForeColor);
                int nLineNo = 0;
                nLineNo = e.RowIndex + 1;
                string strLine = nLineNo.ToString();
                Font font = new Font(e.InheritedRowStyle.Font.Name, e.InheritedRowStyle.Font.Size - 4);

                e.Graphics.DrawString(strLine, font, v_SolidBrush, e.RowBounds.Location.X - 1, e.RowBounds.Location.Y + 3);

            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Datagridview paint failed. <" + _className + ".dgvFlightList_RowPostPaint()>", ex);
            }
        }
        #endregion

        #region Custom Functions and Methods
        private void LoadData(int Filter)
        {
            try
            {
                dtFlightList = init.AppInit.MsgHandler.DBPersistor.GetFlightList(Filter);
                dgvFlightList.DataSource = dtFlightList;
                dgvFlightList.Refresh();
                if (dtFlightList.Rows.Count != 0)
                    nCurrentRow = dgvFlightList.CurrentRow.Index;
                lblRecordsQuantity.Text = dgvFlightList.Rows.Count.ToString();
                
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Loading flight list failed. <" + _className + ".LoadData()>", ex);
            }
        }


        private void PrepareCombo()
        {
            try
            {
                string[] sFilterRange = init.ClassParameters.FilterRange.Split(',');

                cboHr.Items.Clear();
                for (int i = Convert.ToInt32(sFilterRange[0]); i <= Convert.ToInt32(sFilterRange[1]); i++)
                {
                    cboHr.Items.Add(i.ToString());
                }
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Preparing combobox failed. <" + _className + ".PrepareCombo()>", ex);
            }
        }


        #endregion
    }
}

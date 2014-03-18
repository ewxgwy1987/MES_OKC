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
    public partial class DestinationSelection : Form
    {
        public string sFlightNumber = string.Empty;
        public string sDestination = string.Empty;
        public string sDestinationID = string.Empty;
        public string sSubSystem = string.Empty;
        public string sTravelClass = string.Empty;
        public string sPassengerName = string.Empty;
        public string sFlightDestination = string.Empty;
        public string sFlight = string.Empty;
        public int nCurrentRow;
        private readonly string _className = System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        private static readonly log4net.ILog logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public DestinationSelection()
        {
            InitializeComponent();
        }

        public DestinationSelection(DataTable dtInformation, string sMode)
        {
            InitializeComponent();
            dgvSelection.DataSource = dtInformation;
            dgvSelection.Refresh();
            PrepareGridView();
            lblRecordsQuantity.Text = dgvSelection.Rows.Count.ToString();
        }

        private void DestinationSelection_Load(object sender, EventArgs e)
        {
            this.StartPosition = FormStartPosition.CenterScreen;
        }

        private void btnPageUp_Click(object sender, EventArgs e)
        {
            nCurrentRow = 0;
            dgvSelection.CurrentCell = dgvSelection[0, dgvSelection.Rows.GetFirstRow(DataGridViewElementStates.None)];
        }

        private void btnLineUp_Click(object sender, EventArgs e)
        {
            if (nCurrentRow != 0)
            {
                nCurrentRow -= 1;
                dgvSelection.CurrentCell = dgvSelection[0, nCurrentRow];
            }
        }

        private void btnLineDown_Click(object sender, EventArgs e)
        {
            if (nCurrentRow < dgvSelection.Rows.Count - 1)
            {
                nCurrentRow += 1;
                dgvSelection.CurrentCell = dgvSelection[0, nCurrentRow];
            }
        }

        private void btnPageDown_Click(object sender, EventArgs e)
        {
            nCurrentRow = dgvSelection.Rows.Count - 1;
            dgvSelection.CurrentCell = dgvSelection[0, dgvSelection.Rows.GetLastRow(DataGridViewElementStates.None)];
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
            int i = dgvSelection.CurrentRow.Index;

            sDestination = dgvSelection.Rows[i].Cells[0].Value.ToString();
        }

        private void PrepareGridView()
        {
            dgvSelection.Columns[0].HeaderText = "Destination";
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

            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Datagridview paint failed. <" + _className + ".dgvSelection_RowPostPaint()>", ex);
            }
        }
    }
}

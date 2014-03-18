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
    public partial class MESEvent : Form
    {
        #region Local Variable Declaration
        private readonly string _className = System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        private static readonly log4net.ILog logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private BHS.MES.GUI.GUIInitializer init = null;
        #endregion

        public MESEvent(BHS.MES.GUI.GUIInitializer initMain)
        {
            InitializeComponent();
            init = initMain;

        }

        private void MESEvent_Load(object sender, EventArgs e)
        {
            LoadData();
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void LoadData()
        {
            try
            {
                DataTable dtMESEvent = init.AppInit.MsgHandler.DBPersistor.GetMESEvent(init.AppInit.MsgHandler.MESStationName);
                dgvMESEvent.DataSource = dtMESEvent;
                dgvMESEvent.Refresh();
            }
            catch (Exception ex)
            {
                if (logger.IsErrorEnabled)
                    logger.Error("Class:[" + _className + "] Getting MES Event list failed. <" + _className + ".LoadData()>", ex);
            }
        }
    }
}

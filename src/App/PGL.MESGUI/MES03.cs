using System;
using ILOG.Diagrammer;
using ILOG.Diagrammer.Graphic;
using System.Windows.Forms;
using System.Data;
using System.Collections;

namespace MESLayoutDesign
{
    public partial class MES03 : idlMESLayoutBase 
    {
        public MES03(DataTable dt, Hashtable HshList)
        {
            InitializeComponent();	// required by the designer
            this.HshList = HshList;
            this.BindEquipments(this, dt);
        }
    }
}


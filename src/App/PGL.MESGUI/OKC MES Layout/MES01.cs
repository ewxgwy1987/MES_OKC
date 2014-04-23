using System;
using ILOG.Diagrammer;
using ILOG.Diagrammer.Graphic;
using System.Data;
using System.Collections;

namespace MESLayoutDesign
{
    public partial class MES01 : idlMESLayoutBase
    {
        public MES01(DataTable dt, Hashtable HshList)
        {
            InitializeComponent();	// required by the designer
            this.HshList = HshList;
            this.BindEquipments(this, dt);
        }
    }
}

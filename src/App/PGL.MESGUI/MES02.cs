using System;
using ILOG.Diagrammer;
using ILOG.Diagrammer.Graphic;
using System.Data;
using System.Collections;

namespace MESLayoutDesign
{
    public partial class MES02 : idlMESLayoutBase 
    {

        public MES02(DataTable dt, Hashtable HshList)
        {
            InitializeComponent();	// required by the designer
            this.HshList = HshList;
            this.BindEquipments(this, dt);
        }

    }
}

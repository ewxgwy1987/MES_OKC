using System;
using ILOG.Diagrammer;
using ILOG.Diagrammer.Graphic;
using System.Windows.Forms;
using System.Collections;
using System.Drawing;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
//Authour :PST
//Show color
namespace MESLayoutDesign
{
    public partial class MES01 : idlMESLayoutBase 
    {
      
        public MES01(DataTable dt,Hashtable HshList)
        {
            InitializeComponent();	// required by the designer     
            this.HshList = HshList;
            this.BindEquipments(this, dt);
        }

       

    }
}


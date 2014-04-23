using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using BHS.MES.GUI;
using System.Collections;
using ILOG.Diagrammer.Graphic;
using MESLayoutDesign;
namespace PGL.MESGUI
{
    public partial class MESConv_StatusScreen : Form
    {
        #region variable
       static GUIInitializer _init;
      // private Group _content;
       private Hashtable HshList = new Hashtable();
       private static DataTable dt;
       #endregion

        #region Event
       public MESConv_StatusScreen(GUIInitializer intit)
       {
           InitializeComponent();
           _init = intit;
       }

       private void MESConv_StatusScreen_Load(object sender, EventArgs e)
       {
           initiHshList();
           GET_CurrentMEStation();
           ColorAnimationTimer.Interval = _init.ClassParameters.AnimationTimerDuration;
           ColorAnimationTimer.Enabled = true;
           RefreshConvColor_Timer.Interval = _init.ClassParameters.RefreshConvTimerDuration;
           RefreshConvColor_Timer.Enabled = true;
           
       }

       private void MESConv_StatusScreen_FormClosed(object sender, FormClosedEventArgs e)
       {
           RefreshConvColor_Timer.Stop();
           ColorAnimationTimer.Stop();
           dt.Dispose();
           HshList.Clear();
       }
       #endregion
        
        #region methods
       private void initiHshList()
       {
           string MEStation_Name = _init.ClassParameters.MEStationName;
           dt = _init.AppInit.MsgHandler.DBPersistor.GetConv_StatusColor(MEStation_Name);
           for (int i = 0; i < dt.Rows.Count; i++)
           {

               if (dt.Rows[i]["Color_Blinking"].ToString() == "True")
               {
                   HshList.Add(dt.Rows[i]["Conv_Name"].ToString(), "false");
               }
           }
       }
       private void GET_CurrentMEStation()
       {
           if ("ME1" == _init.ClassParameters.MEStationName.ToUpper())
           {
               MES01 _idlDiaGram = new MES01(dt, HshList);
               _idlDiaGram.HshList = HshList;
               this.diagramView1.Content = _idlDiaGram;
               this.Height = 350;
           }
           // For OKC project, only one MES - Commented by Guo Wenyu 2014/04/22
           //else if ("ME2" == _init.ClassParameters.MEStationName.ToUpper())
           //{
           //    MES02 _idlDiaGram = new MES02(dt, HshList);
           //    _idlDiaGram.HshList = HshList;
           //    this.diagramView1.Content = _idlDiaGram;
           //    this.Height = 350;
           //}
           //else if ("ME3" == _init.ClassParameters.MEStationName.ToUpper())
           //{
           //    MES03 _idlDiaGram = new MES03(dt, HshList);
           //    _idlDiaGram.HshList = HshList;
           //    this.diagramView1.Content = _idlDiaGram;
           //    this.Width = 600;
           //    this.Height =450;
           //} 
       }


       #endregion

        #region timmer Event
       private void ColorAnimationTimer_Tick(object sender, EventArgs e)
       {
           GET_CurrentMEStation();
       }

       private void RefreshConvColor_Timer_Tick(object sender, EventArgs e)
       {
         
               if ("ME1" == _init.ClassParameters.MEStationName.ToUpper())
               {
                   HshList.Clear();
                   initiHshList();
                   MES01 _idlDiaGram = new MES01(dt, HshList);
               }
               // For OKC project, only one MES - Commented by Guo Wenyu 2014/04/22
               //else if ("ME2" == _init.ClassParameters.MEStationName.ToUpper())
               //{
               //    HshList.Clear();
               //    initiHshList();
               //    MES02 _idlDiaGram = new MES02(dt, HshList);
               //}
               //else if ("ME3" == _init.ClassParameters.MEStationName.ToUpper())
               //{
               //    HshList.Clear();
               //    initiHshList(); 
               //    MES02 _idlDiaGram = new MES02(dt, HshList);
               //}
              
       }
       #endregion
    
    }
}

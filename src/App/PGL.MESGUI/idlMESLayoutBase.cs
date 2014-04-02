using System;
using ILOG.Diagrammer;
using ILOG.Diagrammer.Graphic;
using System.Collections;
using System.Drawing;
using System.Data;

namespace MESLayoutDesign
{
    public partial class idlMESLayoutBase : Group
    {
        #region variable 
        const string _LIB_NAMESPACE = "ilog.diagrammer.graphic.";
        private static Hashtable _HshList ;
       
        #endregion

        #region Property 

        public Hashtable HshList
        {
            get
            {
                return _HshList;
            }
            set
            {
                _HshList = value;
            }
        }
        #endregion

        #region  Constructors

        public idlMESLayoutBase()
        {
            InitializeComponent();	// required by the designer
        }
        #endregion

        #region methods & function

        protected void BindEquipments(Group GrpZone, DataTable dt)
        {
            foreach (GraphicObject oGraphicObject in GrpZone.Objects)
            {
                string ObjectType = "";
                ObjectType = oGraphicObject.GetType().ToString().ToLower();

                switch (ObjectType)
                {
                    case _LIB_NAMESPACE + "rect":
                        ILOG.Diagrammer.Graphic.Rect oA = oGraphicObject as Rect;
                        oA.Name = oA.Name.Replace("_", "-");
                        if (oA.Name != "rect1" && dt != null)
                        {
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (dt.Rows[i]["Color_Blinking"].ToString() == "True")
                                {
                                    if (dt.Rows[i]["Conv_Name"].ToString() == oA.Name && HshList.ContainsKey(oA.Name) && HshList[oA.Name].ToString() == "false")
                                    {
                                        Color C = HexToColor(dt.Rows[i]["Color_Code"].ToString());
                                        oA.Fill = new SolidFill(C);
                                        HshList[oA.Name] = "true";
                                        oA.ToolTip = dt.Rows[i]["Desc"].ToString();
                                    }
                                    else if (dt.Rows[i]["Conv_Name"].ToString() == oA.Name && HshList.ContainsKey(oA.Name) && HshList[oA.Name].ToString() == "true")
                                    {
                                        HshList[oA.Name] = "false";
                                        oA.Fill = new SolidFill(System.Drawing.Color.WhiteSmoke);
                                        oA.ToolTip = dt.Rows[i]["Conv_Name"].ToString();
                                        oA.ToolTip = dt.Rows[i]["Desc"].ToString();
                                    }
                                }
                                else if (dt.Rows[i]["Color_Blinking"].ToString() == "False" && dt.Rows[i]["Conv_Name"].ToString() == oA.Name && !HshList.ContainsKey(oA.Name))
                                {

                                    Color C = HexToColor(dt.Rows[i]["Color_Code"].ToString());
                                    oA.Fill = new SolidFill(C);
                                    oA.ToolTip = dt.Rows[i]["Desc"].ToString();

                                }
                            }
                        }
                        break;
                    case _LIB_NAMESPACE + "path":
                        ILOG.Diagrammer.Graphic.Path Curve = oGraphicObject as Path;
                        Curve.Name = Curve.Name.Replace("_", "-");
                        if (dt != null)
                        {
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (dt.Rows[i]["Color_Blinking"].ToString() == "True")
                                {
                                    if (dt.Rows[i]["Conv_Name"].ToString() == Curve.Name && HshList.ContainsKey(Curve.Name) && HshList[Curve.Name].ToString() == "false")
                                    {
                                        Color C = HexToColor(dt.Rows[i]["Color_Code"].ToString());
                                        Curve.Fill = new SolidFill(C);
                                        Curve.ToolTip =dt.Rows[i]["Desc"].ToString();
                                        HshList[Curve.Name] = "true";
                                    }
                                    else if (dt.Rows[i]["Conv_Name"].ToString() == Curve.Name && HshList.ContainsKey(Curve.Name) && HshList[Curve.Name].ToString() == "true")
                                    {
                                        HshList[Curve.Name] = "false";
                                        Curve.Fill = new SolidFill(System.Drawing.Color.WhiteSmoke);
                                        Curve.ToolTip = dt.Rows[i]["Desc"].ToString();
                                    }
                                }
                                else if (dt.Rows[i]["Color_Blinking"].ToString() == "False" && dt.Rows[i]["Conv_Name"].ToString() == Curve.Name && !HshList.ContainsKey(Curve.Name))
                                {

                                    Color C = HexToColor(dt.Rows[i]["Color_Code"].ToString());
                                    Curve.Fill = new SolidFill(C);
                                    Curve.ToolTip = dt.Rows[i]["Desc"].ToString();
                                }
                            }
                        }
                        break;
                    case _LIB_NAMESPACE + "polyline":
                        ILOG.Diagrammer.Graphic.Polyline Curve60 = oGraphicObject as Polyline ;
                        Curve60.Name = Curve60.Name.Replace("_", "-");
                        if (dt != null)
                        {
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (dt.Rows[i]["Color_Blinking"].ToString() == "True")
                                {
                                    if (dt.Rows[i]["Conv_Name"].ToString() == Curve60.Name && HshList.ContainsKey(Curve60.Name) && HshList[Curve60.Name].ToString() == "false")
                                    {
                                        Color C = HexToColor(dt.Rows[i]["Color_Code"].ToString()); 
                                        Curve60.Fill = new SolidFill(C);
                                        HshList[Curve60.Name] = "true";
                                        Curve60.ToolTip = dt.Rows[i]["Desc"].ToString();
                                    }
                                    else if (dt.Rows[i]["Conv_Name"].ToString() == Curve60.Name && HshList.ContainsKey(Curve60.Name) && HshList[Curve60.Name].ToString() == "true")
                                    {
                                        HshList[Curve60.Name] = "false";
                                        Curve60.Fill = new SolidFill(System.Drawing.Color.WhiteSmoke);
                                        Curve60.ToolTip = dt.Rows[i]["Desc"].ToString();
                                    }
                                }
                                else if (dt.Rows[i]["Color_Blinking"].ToString() == "False" && dt.Rows[i]["Conv_Name"].ToString() == Curve60.Name && !HshList.ContainsKey(Curve60.Name))
                                {

                                    Color C = HexToColor(dt.Rows[i]["Color_Code"].ToString());
                                    Curve60.Fill = new SolidFill(C);
                                    Curve60.ToolTip = dt.Rows[i]["Desc"].ToString();

                                }
                            }
                        }
                        break;
                } //end Switch statement
            } //end For Each loop

        }

        protected int Hex(string hex)
        {
            return (HexStrToBase10Int(hex));
        }

        protected int HexStrToBase10Int(string hex)
        {
            int base10value = 0;

            try
            {
                return (Convert.ToInt32(hex, 16));
            }
            catch
            { }

            return base10value;
        }

        protected Color HexToColor(string hex)
        {
            hex = hex.Replace("#", "");
            if (hex.Length != 6) return (Color.Black);

            string r = hex.Substring(0, 2);
            string g = hex.Substring(2, 2);
            string b = hex.Substring(4, 2);

            return (Color.FromArgb(Hex(r), Hex(g), Hex(b)));
        }
        #endregion
    }
}

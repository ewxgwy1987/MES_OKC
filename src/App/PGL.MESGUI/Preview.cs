#region Release Information
//
// =====================================================================================
// Copyright 2010, Albert Sun, All Rights Reserved.
// =====================================================================================
// FileName       Preview.cs
// Revision:      1.0 -   15 Oct 2010, By Albert Sun.
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
using Microsoft.Reporting.WinForms;

namespace PGL.MESGUI
{
    public partial class Preview : Form
    {
        public Preview()
        {
            InitializeComponent();
        }

        public Preview(string sLicensePlate, string sShortMsg, string sType)
        {
            InitializeComponent();
            ReportParameter LiceensePlate = new ReportParameter("LicensePlate", "*" + sLicensePlate + "*");
            ReportParameter ShortMessage = new ReportParameter("ShortMessage", sShortMsg);
            ReportParameter Type = new ReportParameter("Type", sType);
            ReportParameter LiceensePlateText = new ReportParameter("LicensePlateForText", sLicensePlate);
            this.reportViewer1.LocalReport.SetParameters(new ReportParameter[] { LiceensePlate, ShortMessage, Type, LiceensePlateText });
            this.reportViewer1.RefreshReport();
        }

        private void Preview_Load(object sender, EventArgs e)
        {

            this.reportViewer1.RefreshReport();
        }
    }
}

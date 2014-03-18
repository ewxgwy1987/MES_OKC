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
    public partial class ABOUT : Form
    {
        public ABOUT()
        {
            InitializeComponent();
        }

        private void ABOUT_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void ABOUT_MouseDown(object sender, MouseEventArgs e)
        {
            this.Close();
        }

        private void ABOUT_Load(object sender, EventArgs e)
        {
            lblVersion.Text = "Release " + System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.Major.ToString() + "." +
                System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.Minor.ToString() +
                ", " + Properties.Resources.sReleaseDate;
        }
    }
}

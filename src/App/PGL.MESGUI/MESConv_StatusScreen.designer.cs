namespace PGL.MESGUI
{
    partial class MESConv_StatusScreen
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.diagramView1 = new ILOG.Diagrammer.Windows.Forms.DiagramView();
            this.ColorAnimationTimer = new System.Windows.Forms.Timer(this.components);
            this.RefreshConvColor_Timer = new System.Windows.Forms.Timer(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.diagramView1)).BeginInit();
            this.SuspendLayout();
            // 
            // diagramView1
            // 
            this.diagramView1.AutoSizeContent = true;
            this.diagramView1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.diagramView1.Location = new System.Drawing.Point(0, 0);
            this.diagramView1.Name = "diagramView1";
            this.diagramView1.Size = new System.Drawing.Size(591, 388);
            this.diagramView1.TabIndex = 0;
            // 
            // ColorAnimationTimer
            // 
            this.ColorAnimationTimer.Tick += new System.EventHandler(this.ColorAnimationTimer_Tick);
            // 
            // RefreshConvColor_Timer
            // 
            this.RefreshConvColor_Timer.Tick += new System.EventHandler(this.RefreshConvColor_Timer_Tick);
            // 
            // MESConv_StatusScreen
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(591, 388);
            this.Controls.Add(this.diagramView1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "MESConv_StatusScreen";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Conv_Status";
            this.TopMost = true;
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.MESConv_StatusScreen_FormClosed);
            this.Load += new System.EventHandler(this.MESConv_StatusScreen_Load);
            ((System.ComponentModel.ISupportInitialize)(this.diagramView1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private ILOG.Diagrammer.Windows.Forms.DiagramView diagramView1;
        private System.Windows.Forms.Timer ColorAnimationTimer;
        private System.Windows.Forms.Timer RefreshConvColor_Timer;
    }
}
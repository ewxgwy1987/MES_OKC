namespace PGL.MESGUI
{
    partial class Filter
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
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.chkAirline = new System.Windows.Forms.CheckBox();
            this.chkFlight = new System.Windows.Forms.CheckBox();
            this.chkSDO = new System.Windows.Forms.CheckBox();
            this.cmbAirline = new System.Windows.Forms.ComboBox();
            this.cmbFlight = new System.Windows.Forms.ComboBox();
            this.cmbSDO = new System.Windows.Forms.ComboBox();
            this.SuspendLayout();
            // 
            // btnOK
            // 
            this.btnOK.Enabled = false;
            this.btnOK.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnOK.Location = new System.Drawing.Point(66, 153);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(127, 48);
            this.btnOK.TabIndex = 212;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCancel.Location = new System.Drawing.Point(199, 153);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(127, 48);
            this.btnCancel.TabIndex = 213;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // chkAirline
            // 
            this.chkAirline.AutoSize = true;
            this.chkAirline.Font = new System.Drawing.Font("Microsoft Sans Serif", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.chkAirline.Location = new System.Drawing.Point(19, 13);
            this.chkAirline.Name = "chkAirline";
            this.chkAirline.Size = new System.Drawing.Size(100, 33);
            this.chkAirline.TabIndex = 214;
            this.chkAirline.Text = "Airline";
            this.chkAirline.UseVisualStyleBackColor = true;
            this.chkAirline.CheckedChanged += new System.EventHandler(this.chkAirline_CheckedChanged);
            // 
            // chkFlight
            // 
            this.chkFlight.AutoSize = true;
            this.chkFlight.Font = new System.Drawing.Font("Microsoft Sans Serif", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.chkFlight.Location = new System.Drawing.Point(19, 54);
            this.chkFlight.Name = "chkFlight";
            this.chkFlight.Size = new System.Drawing.Size(92, 33);
            this.chkFlight.TabIndex = 215;
            this.chkFlight.Text = "Flight";
            this.chkFlight.UseVisualStyleBackColor = true;
            this.chkFlight.CheckedChanged += new System.EventHandler(this.chkFlight_CheckedChanged);
            // 
            // chkSDO
            // 
            this.chkSDO.AutoSize = true;
            this.chkSDO.Font = new System.Drawing.Font("Microsoft Sans Serif", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.chkSDO.Location = new System.Drawing.Point(19, 95);
            this.chkSDO.Name = "chkSDO";
            this.chkSDO.Size = new System.Drawing.Size(84, 33);
            this.chkSDO.TabIndex = 216;
            this.chkSDO.Text = "SDO";
            this.chkSDO.UseVisualStyleBackColor = true;
            this.chkSDO.CheckedChanged += new System.EventHandler(this.chkSDO_CheckedChanged);
            // 
            // cmbAirline
            // 
            this.cmbAirline.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbAirline.Font = new System.Drawing.Font("Microsoft Sans Serif", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cmbAirline.FormattingEnabled = true;
            this.cmbAirline.Location = new System.Drawing.Point(145, 11);
            this.cmbAirline.Name = "cmbAirline";
            this.cmbAirline.Size = new System.Drawing.Size(234, 37);
            this.cmbAirline.TabIndex = 217;
            this.cmbAirline.SelectedIndexChanged += new System.EventHandler(this.cmbAirline_SelectedIndexChanged);
            // 
            // cmbFlight
            // 
            this.cmbFlight.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbFlight.Font = new System.Drawing.Font("Microsoft Sans Serif", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cmbFlight.FormattingEnabled = true;
            this.cmbFlight.Location = new System.Drawing.Point(145, 54);
            this.cmbFlight.Name = "cmbFlight";
            this.cmbFlight.Size = new System.Drawing.Size(234, 37);
            this.cmbFlight.TabIndex = 218;
            this.cmbFlight.SelectedIndexChanged += new System.EventHandler(this.cmbFlight_SelectedIndexChanged);
            // 
            // cmbSDO
            // 
            this.cmbSDO.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbSDO.Font = new System.Drawing.Font("Microsoft Sans Serif", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cmbSDO.FormatString = "dd-MMM-yyyy";
            this.cmbSDO.FormattingEnabled = true;
            this.cmbSDO.Location = new System.Drawing.Point(145, 97);
            this.cmbSDO.Name = "cmbSDO";
            this.cmbSDO.Size = new System.Drawing.Size(234, 37);
            this.cmbSDO.TabIndex = 219;
            this.cmbSDO.SelectedIndexChanged += new System.EventHandler(this.cmbSDO_SelectedIndexChanged);
            // 
            // Filter
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(398, 225);
            this.ControlBox = false;
            this.Controls.Add(this.cmbSDO);
            this.Controls.Add(this.cmbFlight);
            this.Controls.Add(this.cmbAirline);
            this.Controls.Add(this.chkSDO);
            this.Controls.Add(this.chkFlight);
            this.Controls.Add(this.chkAirline);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Filter";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Filter";
            this.Load += new System.EventHandler(this.Filter_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.CheckBox chkAirline;
        private System.Windows.Forms.CheckBox chkFlight;
        private System.Windows.Forms.CheckBox chkSDO;
        private System.Windows.Forms.ComboBox cmbAirline;
        private System.Windows.Forms.ComboBox cmbFlight;
        private System.Windows.Forms.ComboBox cmbSDO;
    }
}
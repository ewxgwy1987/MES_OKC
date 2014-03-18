namespace PGL.MESGUI
{
    partial class MESEvent
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.dgvMESEvent = new System.Windows.Forms.DataGridView();
            this.btnClose = new System.Windows.Forms.Button();
            this.TIME_STAMP = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.GID = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.LICENSE_PLATE = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.SUBSYSTEM = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.LOCATION = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ACTION = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ACTION_DESC = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.MES_STATION = new System.Windows.Forms.DataGridViewTextBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.dgvMESEvent)).BeginInit();
            this.SuspendLayout();
            // 
            // dgvMESEvent
            // 
            this.dgvMESEvent.AllowUserToAddRows = false;
            this.dgvMESEvent.AllowUserToDeleteRows = false;
            this.dgvMESEvent.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvMESEvent.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.DisplayedCells;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Microsoft Sans Serif", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvMESEvent.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvMESEvent.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvMESEvent.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.TIME_STAMP,
            this.GID,
            this.LICENSE_PLATE,
            this.SUBSYSTEM,
            this.LOCATION,
            this.ACTION,
            this.ACTION_DESC,
            this.MES_STATION});
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvMESEvent.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvMESEvent.Location = new System.Drawing.Point(9, 26);
            this.dgvMESEvent.MultiSelect = false;
            this.dgvMESEvent.Name = "dgvMESEvent";
            this.dgvMESEvent.ReadOnly = true;
            this.dgvMESEvent.RowHeadersVisible = false;
            this.dgvMESEvent.RowHeadersWidth = 25;
            this.dgvMESEvent.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvMESEvent.Size = new System.Drawing.Size(845, 528);
            this.dgvMESEvent.TabIndex = 1;
            // 
            // btnClose
            // 
            this.btnClose.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnClose.Location = new System.Drawing.Point(698, 569);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new System.Drawing.Size(156, 48);
            this.btnClose.TabIndex = 72;
            this.btnClose.Text = "Close";
            this.btnClose.UseVisualStyleBackColor = true;
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            // 
            // TIME_STAMP
            // 
            this.TIME_STAMP.DataPropertyName = "TIME_STAMP";
            this.TIME_STAMP.HeaderText = "Time";
            this.TIME_STAMP.Name = "TIME_STAMP";
            this.TIME_STAMP.ReadOnly = true;
            // 
            // GID
            // 
            this.GID.DataPropertyName = "GID";
            this.GID.HeaderText = "GID";
            this.GID.Name = "GID";
            this.GID.ReadOnly = true;
            // 
            // LICENSE_PLATE
            // 
            this.LICENSE_PLATE.DataPropertyName = "LICENSE_PLATE";
            this.LICENSE_PLATE.HeaderText = "License Plate";
            this.LICENSE_PLATE.Name = "LICENSE_PLATE";
            this.LICENSE_PLATE.ReadOnly = true;
            // 
            // SUBSYSTEM
            // 
            this.SUBSYSTEM.DataPropertyName = "SUBSYSTEM";
            this.SUBSYSTEM.HeaderText = "Subsystem";
            this.SUBSYSTEM.Name = "SUBSYSTEM";
            this.SUBSYSTEM.ReadOnly = true;
            // 
            // LOCATION
            // 
            this.LOCATION.DataPropertyName = "LOCATION";
            this.LOCATION.HeaderText = "Location";
            this.LOCATION.Name = "LOCATION";
            this.LOCATION.ReadOnly = true;
            // 
            // ACTION
            // 
            this.ACTION.DataPropertyName = "ACTION";
            this.ACTION.HeaderText = "Action";
            this.ACTION.Name = "ACTION";
            this.ACTION.ReadOnly = true;
            // 
            // ACTION_DESC
            // 
            this.ACTION_DESC.DataPropertyName = "ACTION_DESC";
            this.ACTION_DESC.HeaderText = "Action Desc";
            this.ACTION_DESC.Name = "ACTION_DESC";
            this.ACTION_DESC.ReadOnly = true;
            // 
            // MES_STATION
            // 
            this.MES_STATION.DataPropertyName = "MES_STATION";
            this.MES_STATION.HeaderText = "MES Station";
            this.MES_STATION.Name = "MES_STATION";
            this.MES_STATION.ReadOnly = true;
            // 
            // MESEvent
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(862, 629);
            this.Controls.Add(this.btnClose);
            this.Controls.Add(this.dgvMESEvent);
            this.Name = "MESEvent";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "MES Event Log";
            this.Load += new System.EventHandler(this.MESEvent_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dgvMESEvent)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView dgvMESEvent;
        private System.Windows.Forms.Button btnClose;
        private System.Windows.Forms.DataGridViewTextBoxColumn TIME_STAMP;
        private System.Windows.Forms.DataGridViewTextBoxColumn GID;
        private System.Windows.Forms.DataGridViewTextBoxColumn LICENSE_PLATE;
        private System.Windows.Forms.DataGridViewTextBoxColumn SUBSYSTEM;
        private System.Windows.Forms.DataGridViewTextBoxColumn LOCATION;
        private System.Windows.Forms.DataGridViewTextBoxColumn ACTION;
        private System.Windows.Forms.DataGridViewTextBoxColumn ACTION_DESC;
        private System.Windows.Forms.DataGridViewTextBoxColumn MES_STATION;

    }
}
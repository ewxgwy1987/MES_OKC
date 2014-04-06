namespace PGL.MESGUI
{
    partial class FlightList
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.btnPageDown = new System.Windows.Forms.Button();
            this.btnPageUp = new System.Windows.Forms.Button();
            this.btnLineDown = new System.Windows.Forms.Button();
            this.btnLineUp = new System.Windows.Forms.Button();
            this.dgvFlightList = new System.Windows.Forms.DataGridView();
            this.Column2 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Column3 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ETD = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Column4 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Column5 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.FLIGHT_STATUS = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.lblRecordsQuantity = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.btnClose = new System.Windows.Forms.Button();
            this.cboHr = new System.Windows.Forms.ComboBox();
            this.rbtnFilter = new System.Windows.Forms.RadioButton();
            this.rbtnAll = new System.Windows.Forms.RadioButton();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvFlightList)).BeginInit();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.btnPageDown);
            this.groupBox1.Controls.Add(this.btnPageUp);
            this.groupBox1.Controls.Add(this.btnLineDown);
            this.groupBox1.Controls.Add(this.btnLineUp);
            this.groupBox1.Controls.Add(this.dgvFlightList);
            this.groupBox1.Font = new System.Drawing.Font("Microsoft Sans Serif", 16F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox1.Location = new System.Drawing.Point(-3, -1);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(1010, 663);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            // 
            // btnPageDown
            // 
            this.btnPageDown.BackgroundImage = global::PGL.MESGUI.Properties.Resources.downdown;
            this.btnPageDown.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnPageDown.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnPageDown.Location = new System.Drawing.Point(956, 535);
            this.btnPageDown.Name = "btnPageDown";
            this.btnPageDown.Size = new System.Drawing.Size(43, 43);
            this.btnPageDown.TabIndex = 4;
            this.btnPageDown.UseVisualStyleBackColor = true;
            this.btnPageDown.Click += new System.EventHandler(this.btnPageDown_Click);
            // 
            // btnPageUp
            // 
            this.btnPageUp.BackgroundImage = global::PGL.MESGUI.Properties.Resources.upup;
            this.btnPageUp.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnPageUp.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnPageUp.Location = new System.Drawing.Point(956, 81);
            this.btnPageUp.Name = "btnPageUp";
            this.btnPageUp.Size = new System.Drawing.Size(43, 43);
            this.btnPageUp.TabIndex = 3;
            this.btnPageUp.UseVisualStyleBackColor = true;
            this.btnPageUp.Click += new System.EventHandler(this.btnPageUp_Click);
            // 
            // btnLineDown
            // 
            this.btnLineDown.BackgroundImage = global::PGL.MESGUI.Properties.Resources.down;
            this.btnLineDown.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLineDown.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnLineDown.Location = new System.Drawing.Point(956, 486);
            this.btnLineDown.Name = "btnLineDown";
            this.btnLineDown.Size = new System.Drawing.Size(43, 43);
            this.btnLineDown.TabIndex = 2;
            this.btnLineDown.UseVisualStyleBackColor = true;
            this.btnLineDown.Click += new System.EventHandler(this.btnLineDown_Click);
            // 
            // btnLineUp
            // 
            this.btnLineUp.BackgroundImage = global::PGL.MESGUI.Properties.Resources.up;
            this.btnLineUp.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLineUp.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnLineUp.Location = new System.Drawing.Point(956, 130);
            this.btnLineUp.Name = "btnLineUp";
            this.btnLineUp.Size = new System.Drawing.Size(43, 43);
            this.btnLineUp.TabIndex = 1;
            this.btnLineUp.UseVisualStyleBackColor = true;
            this.btnLineUp.Click += new System.EventHandler(this.btnLineUp_Click);
            // 
            // dgvFlightList
            // 
            this.dgvFlightList.AllowUserToAddRows = false;
            this.dgvFlightList.AllowUserToDeleteRows = false;
            this.dgvFlightList.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.DisplayedCells;
            this.dgvFlightList.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.DisplayedCells;
            this.dgvFlightList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvFlightList.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Column2,
            this.Column3,
            this.ETD,
            this.Column4,
            this.Column5,
            this.FLIGHT_STATUS});
            this.dgvFlightList.Location = new System.Drawing.Point(15, 18);
            this.dgvFlightList.MultiSelect = false;
            this.dgvFlightList.Name = "dgvFlightList";
            this.dgvFlightList.ReadOnly = true;
            this.dgvFlightList.RowHeadersWidth = 50;
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.dgvFlightList.RowsDefaultCellStyle = dataGridViewCellStyle4;
            this.dgvFlightList.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvFlightList.Size = new System.Drawing.Size(930, 638);
            this.dgvFlightList.TabIndex = 0;
            this.dgvFlightList.RowPostPaint += new System.Windows.Forms.DataGridViewRowPostPaintEventHandler(this.dgvFlightList_RowPostPaint);
            // 
            // Column2
            // 
            this.Column2.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.DisplayedCells;
            this.Column2.DataPropertyName = "Flight";
            this.Column2.HeaderText = "Flight";
            this.Column2.Name = "Column2";
            this.Column2.ReadOnly = true;
            this.Column2.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.Column2.Width = 90;
            // 
            // Column3
            // 
            this.Column3.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.DisplayedCells;
            this.Column3.DataPropertyName = "STD";
            dataGridViewCellStyle1.Format = "dd-MM-yyyy HH:mm";
            this.Column3.DefaultCellStyle = dataGridViewCellStyle1;
            this.Column3.HeaderText = "STD";
            this.Column3.Name = "Column3";
            this.Column3.ReadOnly = true;
            this.Column3.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.Column3.Width = 80;
            // 
            // ETD
            // 
            this.ETD.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.DisplayedCells;
            this.ETD.DataPropertyName = "ETD";
            dataGridViewCellStyle2.Format = "dd-MM-yyyy HH:mm";
            dataGridViewCellStyle2.NullValue = null;
            this.ETD.DefaultCellStyle = dataGridViewCellStyle2;
            this.ETD.HeaderText = "ETD";
            this.ETD.Name = "ETD";
            this.ETD.ReadOnly = true;
            this.ETD.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.ETD.Width = 80;
            // 
            // Column4
            // 
            this.Column4.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.DisplayedCells;
            this.Column4.DataPropertyName = "FLIGHT_DESTINATION";
            this.Column4.HeaderText = "Flight Dest";
            this.Column4.Name = "Column4";
            this.Column4.ReadOnly = true;
            this.Column4.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.Column4.Width = 141;
            // 
            // Column5
            // 
            this.Column5.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.DisplayedCells;
            this.Column5.DataPropertyName = "SORT_DESTINATION";
            dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.Column5.DefaultCellStyle = dataGridViewCellStyle3;
            this.Column5.HeaderText = "Sort Dest";
            this.Column5.Name = "Column5";
            this.Column5.ReadOnly = true;
            this.Column5.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.Column5.Width = 128;
            // 
            // FLIGHT_STATUS
            // 
            this.FLIGHT_STATUS.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.DisplayedCells;
            this.FLIGHT_STATUS.DataPropertyName = "FLIGHT_STATUS";
            this.FLIGHT_STATUS.HeaderText = "Flight Status";
            this.FLIGHT_STATUS.Name = "FLIGHT_STATUS";
            this.FLIGHT_STATUS.ReadOnly = true;
            this.FLIGHT_STATUS.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.FLIGHT_STATUS.Width = 158;
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.lblRecordsQuantity);
            this.groupBox2.Controls.Add(this.label2);
            this.groupBox2.Controls.Add(this.label1);
            this.groupBox2.Controls.Add(this.btnClose);
            this.groupBox2.Controls.Add(this.cboHr);
            this.groupBox2.Controls.Add(this.rbtnFilter);
            this.groupBox2.Controls.Add(this.rbtnAll);
            this.groupBox2.Font = new System.Drawing.Font("Microsoft Sans Serif", 16F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox2.Location = new System.Drawing.Point(60, 661);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(846, 75);
            this.groupBox2.TabIndex = 1;
            this.groupBox2.TabStop = false;
            // 
            // lblRecordsQuantity
            // 
            this.lblRecordsQuantity.AutoSize = true;
            this.lblRecordsQuantity.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblRecordsQuantity.Location = new System.Drawing.Point(196, 30);
            this.lblRecordsQuantity.Name = "lblRecordsQuantity";
            this.lblRecordsQuantity.Size = new System.Drawing.Size(20, 24);
            this.lblRecordsQuantity.TabIndex = 74;
            this.lblRecordsQuantity.Text = "0";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(5, 30);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(185, 24);
            this.label2.TabIndex = 73;
            this.label2.Text = "Number of Records: ";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(260, 28);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(66, 26);
            this.label1.TabIndex = 72;
            this.label1.Text = "Filter:";
            // 
            // btnClose
            // 
            this.btnClose.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnClose.Location = new System.Drawing.Point(681, 20);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new System.Drawing.Size(156, 48);
            this.btnClose.TabIndex = 71;
            this.btnClose.Text = "Close";
            this.btnClose.UseVisualStyleBackColor = true;
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            // 
            // cboHr
            // 
            this.cboHr.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboHr.Enabled = false;
            this.cboHr.FormattingEnabled = true;
            this.cboHr.Items.AddRange(new object[] {
            "-9",
            "-8",
            "-7",
            "-6",
            "-5",
            "-4",
            "-3",
            "-2",
            "-1",
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9"});
            this.cboHr.Location = new System.Drawing.Point(529, 26);
            this.cboHr.Name = "cboHr";
            this.cboHr.Size = new System.Drawing.Size(71, 33);
            this.cboHr.TabIndex = 2;
            this.cboHr.SelectedValueChanged += new System.EventHandler(this.cboHr_SelectedValueChanged);
            // 
            // rbtnFilter
            // 
            this.rbtnFilter.AutoSize = true;
            this.rbtnFilter.Location = new System.Drawing.Point(427, 27);
            this.rbtnFilter.Name = "rbtnFilter";
            this.rbtnFilter.Size = new System.Drawing.Size(77, 30);
            this.rbtnFilter.TabIndex = 1;
            this.rbtnFilter.Text = "Hour";
            this.rbtnFilter.UseVisualStyleBackColor = true;
            this.rbtnFilter.Click += new System.EventHandler(this.rbtnFilter_Click);
            // 
            // rbtnAll
            // 
            this.rbtnAll.AutoSize = true;
            this.rbtnAll.Checked = true;
            this.rbtnAll.Location = new System.Drawing.Point(341, 27);
            this.rbtnAll.Name = "rbtnAll";
            this.rbtnAll.Size = new System.Drawing.Size(55, 30);
            this.rbtnAll.TabIndex = 0;
            this.rbtnAll.TabStop = true;
            this.rbtnAll.Text = "All";
            this.rbtnAll.UseVisualStyleBackColor = true;
            this.rbtnAll.Click += new System.EventHandler(this.rbtnAll_Click);
            // 
            // FlightList
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1018, 740);
            this.ControlBox = false;
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FlightList";
            this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Show;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Flight List";
            this.Load += new System.EventHandler(this.FlightList_Load);
            this.groupBox1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvFlightList)).EndInit();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Button btnClose;
        private System.Windows.Forms.DataGridView dgvFlightList;
        private System.Windows.Forms.ComboBox cboHr;
        private System.Windows.Forms.RadioButton rbtnFilter;
        private System.Windows.Forms.RadioButton rbtnAll;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnPageDown;
        private System.Windows.Forms.Button btnPageUp;
        private System.Windows.Forms.Button btnLineDown;
        private System.Windows.Forms.Button btnLineUp;
        private System.Windows.Forms.Label lblRecordsQuantity;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.DataGridViewTextBoxColumn Column2;
        private System.Windows.Forms.DataGridViewTextBoxColumn Column3;
        private System.Windows.Forms.DataGridViewTextBoxColumn ETD;
        private System.Windows.Forms.DataGridViewTextBoxColumn Column4;
        private System.Windows.Forms.DataGridViewTextBoxColumn Column5;
        private System.Windows.Forms.DataGridViewTextBoxColumn FLIGHT_STATUS;
    }
}
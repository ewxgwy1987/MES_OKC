namespace PGL.MESGUI
{
    partial class DestinationSelection
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
            this.lblRecordsQuantity = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.btnPageDown = new System.Windows.Forms.Button();
            this.btnPageUp = new System.Windows.Forms.Button();
            this.btnLineDown = new System.Windows.Forms.Button();
            this.btnLineUp = new System.Windows.Forms.Button();
            this.dgvSelection = new System.Windows.Forms.DataGridView();
            this.Column1 = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvSelection)).BeginInit();
            this.SuspendLayout();
            // 
            // lblRecordsQuantity
            // 
            this.lblRecordsQuantity.AutoSize = true;
            this.lblRecordsQuantity.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblRecordsQuantity.Location = new System.Drawing.Point(193, 250);
            this.lblRecordsQuantity.Name = "lblRecordsQuantity";
            this.lblRecordsQuantity.Size = new System.Drawing.Size(20, 24);
            this.lblRecordsQuantity.TabIndex = 10;
            this.lblRecordsQuantity.Text = "0";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(2, 250);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(185, 24);
            this.label2.TabIndex = 9;
            this.label2.Text = "Number of Records: ";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.btnPageDown);
            this.groupBox1.Controls.Add(this.btnPageUp);
            this.groupBox1.Controls.Add(this.btnLineDown);
            this.groupBox1.Controls.Add(this.btnLineUp);
            this.groupBox1.Controls.Add(this.dgvSelection);
            this.groupBox1.Font = new System.Drawing.Font("Microsoft Sans Serif", 16F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox1.Location = new System.Drawing.Point(0, 25);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(417, 224);
            this.groupBox1.TabIndex = 5;
            this.groupBox1.TabStop = false;
            // 
            // btnPageDown
            // 
            this.btnPageDown.BackgroundImage = global::PGL.MESGUI.Properties.Resources.downdown;
            this.btnPageDown.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnPageDown.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnPageDown.Location = new System.Drawing.Point(368, 169);
            this.btnPageDown.Name = "btnPageDown";
            this.btnPageDown.Size = new System.Drawing.Size(43, 43);
            this.btnPageDown.TabIndex = 8;
            this.btnPageDown.UseVisualStyleBackColor = true;
            this.btnPageDown.Click += new System.EventHandler(this.btnPageDown_Click);
            // 
            // btnPageUp
            // 
            this.btnPageUp.BackgroundImage = global::PGL.MESGUI.Properties.Resources.upup;
            this.btnPageUp.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnPageUp.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnPageUp.Location = new System.Drawing.Point(368, 22);
            this.btnPageUp.Name = "btnPageUp";
            this.btnPageUp.Size = new System.Drawing.Size(43, 43);
            this.btnPageUp.TabIndex = 7;
            this.btnPageUp.UseVisualStyleBackColor = true;
            this.btnPageUp.Click += new System.EventHandler(this.btnPageUp_Click);
            // 
            // btnLineDown
            // 
            this.btnLineDown.BackgroundImage = global::PGL.MESGUI.Properties.Resources.down;
            this.btnLineDown.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLineDown.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnLineDown.Location = new System.Drawing.Point(368, 120);
            this.btnLineDown.Name = "btnLineDown";
            this.btnLineDown.Size = new System.Drawing.Size(43, 43);
            this.btnLineDown.TabIndex = 6;
            this.btnLineDown.UseVisualStyleBackColor = true;
            this.btnLineDown.Click += new System.EventHandler(this.btnLineDown_Click);
            // 
            // btnLineUp
            // 
            this.btnLineUp.BackgroundImage = global::PGL.MESGUI.Properties.Resources.up;
            this.btnLineUp.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLineUp.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnLineUp.Location = new System.Drawing.Point(368, 71);
            this.btnLineUp.Name = "btnLineUp";
            this.btnLineUp.Size = new System.Drawing.Size(43, 43);
            this.btnLineUp.TabIndex = 5;
            this.btnLineUp.UseVisualStyleBackColor = true;
            this.btnLineUp.Click += new System.EventHandler(this.btnLineUp_Click);
            // 
            // dgvSelection
            // 
            this.dgvSelection.AllowUserToAddRows = false;
            this.dgvSelection.AllowUserToDeleteRows = false;
            this.dgvSelection.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.DisplayedCells;
            this.dgvSelection.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.DisplayedCells;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Microsoft Sans Serif", 16F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvSelection.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvSelection.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvSelection.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Column1});
            this.dgvSelection.Location = new System.Drawing.Point(6, 22);
            this.dgvSelection.MultiSelect = false;
            this.dgvSelection.Name = "dgvSelection";
            this.dgvSelection.ReadOnly = true;
            this.dgvSelection.RowHeadersWidth = 20;
            this.dgvSelection.ScrollBars = System.Windows.Forms.ScrollBars.Horizontal;
            this.dgvSelection.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvSelection.Size = new System.Drawing.Size(356, 190);
            this.dgvSelection.TabIndex = 0;
            this.dgvSelection.RowPostPaint += new System.Windows.Forms.DataGridViewRowPostPaintEventHandler(this.dgvSelection_RowPostPaint);
            // 
            // Column1
            // 
            this.Column1.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.Column1.DataPropertyName = "DESTINATION";
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleCenter;
            this.Column1.DefaultCellStyle = dataGridViewCellStyle2;
            this.Column1.HeaderText = "Destination";
            this.Column1.Name = "Column1";
            this.Column1.ReadOnly = true;
            // 
            // btnOK
            // 
            this.btnOK.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnOK.Location = new System.Drawing.Point(48, 277);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(156, 48);
            this.btnOK.TabIndex = 6;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCancel.Location = new System.Drawing.Point(210, 277);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(156, 48);
            this.btnCancel.TabIndex = 8;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // label1
            // 
            this.label1.Dock = System.Windows.Forms.DockStyle.Top;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(0, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(417, 32);
            this.label1.TabIndex = 7;
            this.label1.Text = "Choose a matching record and press OK button.";
            // 
            // DestinationSelection
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(417, 333);
            this.ControlBox = false;
            this.Controls.Add(this.lblRecordsQuantity);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.label1);
            this.Name = "DestinationSelection";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Destination Selection";
            this.Load += new System.EventHandler(this.DestinationSelection_Load);
            this.groupBox1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvSelection)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblRecordsQuantity;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button btnPageDown;
        private System.Windows.Forms.Button btnPageUp;
        private System.Windows.Forms.Button btnLineDown;
        private System.Windows.Forms.Button btnLineUp;
        private System.Windows.Forms.DataGridView dgvSelection;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.DataGridViewTextBoxColumn Column1;
    }
}
namespace PGL.MESGUI
{
    partial class Selection
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
            this.label1 = new System.Windows.Forms.Label();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnOK = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.btnLineEnd = new System.Windows.Forms.Button();
            this.btnLineHome = new System.Windows.Forms.Button();
            this.btnLineRight = new System.Windows.Forms.Button();
            this.btnLineLeft = new System.Windows.Forms.Button();
            this.btnPageDown = new System.Windows.Forms.Button();
            this.btnPageUp = new System.Windows.Forms.Button();
            this.btnLineDown = new System.Windows.Forms.Button();
            this.btnLineUp = new System.Windows.Forms.Button();
            this.dgvSelection = new System.Windows.Forms.DataGridView();
            this.label2 = new System.Windows.Forms.Label();
            this.lblRecordsQuantity = new System.Windows.Forms.Label();
            this.imageList1 = new System.Windows.Forms.ImageList(this.components);
            this.btnRefresh = new System.Windows.Forms.Button();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvSelection)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(0, 5);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(1014, 27);
            this.label1.TabIndex = 1;
            this.label1.Text = "Multiple BSM/Flight Allocation. Choose a matching record and press OK button.";
            this.label1.TextAlign = System.Drawing.ContentAlignment.BottomLeft;
            // 
            // btnCancel
            // 
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCancel.Location = new System.Drawing.Point(804, 483);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(156, 48);
            this.btnCancel.TabIndex = 2;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // btnOK
            // 
            this.btnOK.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnOK.Location = new System.Drawing.Point(642, 483);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(156, 48);
            this.btnOK.TabIndex = 1;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.btnLineEnd);
            this.groupBox1.Controls.Add(this.btnLineHome);
            this.groupBox1.Controls.Add(this.btnLineRight);
            this.groupBox1.Controls.Add(this.btnLineLeft);
            this.groupBox1.Controls.Add(this.btnPageDown);
            this.groupBox1.Controls.Add(this.btnPageUp);
            this.groupBox1.Controls.Add(this.btnLineDown);
            this.groupBox1.Controls.Add(this.btnLineUp);
            this.groupBox1.Controls.Add(this.dgvSelection);
            this.groupBox1.Font = new System.Drawing.Font("Microsoft Sans Serif", 16F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox1.Location = new System.Drawing.Point(0, 30);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(1014, 447);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            // 
            // btnLineEnd
            // 
            this.btnLineEnd.BackgroundImage = global::PGL.MESGUI.Properties.Resources.rightright;
            this.btnLineEnd.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLineEnd.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnLineEnd.Location = new System.Drawing.Point(965, 397);
            this.btnLineEnd.Name = "btnLineEnd";
            this.btnLineEnd.Size = new System.Drawing.Size(43, 43);
            this.btnLineEnd.TabIndex = 12;
            this.btnLineEnd.UseVisualStyleBackColor = true;
            this.btnLineEnd.Click += new System.EventHandler(this.btnLineEnd_Click);
            // 
            // btnLineHome
            // 
            this.btnLineHome.BackgroundImage = global::PGL.MESGUI.Properties.Resources.leftleft;
            this.btnLineHome.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLineHome.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnLineHome.Location = new System.Drawing.Point(965, 250);
            this.btnLineHome.Name = "btnLineHome";
            this.btnLineHome.Size = new System.Drawing.Size(43, 43);
            this.btnLineHome.TabIndex = 11;
            this.btnLineHome.UseVisualStyleBackColor = true;
            this.btnLineHome.Click += new System.EventHandler(this.btnLineHome_Click);
            // 
            // btnLineRight
            // 
            this.btnLineRight.BackgroundImage = global::PGL.MESGUI.Properties.Resources.right;
            this.btnLineRight.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLineRight.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnLineRight.Location = new System.Drawing.Point(965, 348);
            this.btnLineRight.Name = "btnLineRight";
            this.btnLineRight.Size = new System.Drawing.Size(43, 43);
            this.btnLineRight.TabIndex = 10;
            this.btnLineRight.UseVisualStyleBackColor = true;
            this.btnLineRight.Click += new System.EventHandler(this.btnLineRight_Click);
            // 
            // btnLineLeft
            // 
            this.btnLineLeft.BackgroundImage = global::PGL.MESGUI.Properties.Resources.left;
            this.btnLineLeft.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLineLeft.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnLineLeft.Location = new System.Drawing.Point(965, 299);
            this.btnLineLeft.Name = "btnLineLeft";
            this.btnLineLeft.Size = new System.Drawing.Size(43, 43);
            this.btnLineLeft.TabIndex = 9;
            this.btnLineLeft.UseVisualStyleBackColor = true;
            this.btnLineLeft.Click += new System.EventHandler(this.btnLineLeft_Click);
            // 
            // btnPageDown
            // 
            this.btnPageDown.BackgroundImage = global::PGL.MESGUI.Properties.Resources.downdown;
            this.btnPageDown.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnPageDown.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnPageDown.Location = new System.Drawing.Point(965, 165);
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
            this.btnPageUp.Location = new System.Drawing.Point(965, 18);
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
            this.btnLineDown.Location = new System.Drawing.Point(965, 116);
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
            this.btnLineUp.Location = new System.Drawing.Point(965, 67);
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
            this.dgvSelection.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvSelection.Location = new System.Drawing.Point(6, 18);
            this.dgvSelection.MultiSelect = false;
            this.dgvSelection.Name = "dgvSelection";
            this.dgvSelection.ReadOnly = true;
            this.dgvSelection.RowHeadersWidth = 20;
            this.dgvSelection.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvSelection.Size = new System.Drawing.Size(953, 423);
            this.dgvSelection.TabIndex = 0;
            this.dgvSelection.RowEnter += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvSelection_RowEnter);
            this.dgvSelection.RowPostPaint += new System.Windows.Forms.DataGridViewRowPostPaintEventHandler(this.dgvSelection_RowPostPaint);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(2, 493);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(137, 24);
            this.label2.TabIndex = 3;
            this.label2.Text = "Total Records: ";
            // 
            // lblRecordsQuantity
            // 
            this.lblRecordsQuantity.AutoSize = true;
            this.lblRecordsQuantity.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblRecordsQuantity.Location = new System.Drawing.Point(145, 493);
            this.lblRecordsQuantity.Name = "lblRecordsQuantity";
            this.lblRecordsQuantity.Size = new System.Drawing.Size(20, 24);
            this.lblRecordsQuantity.TabIndex = 4;
            this.lblRecordsQuantity.Text = "0";
            // 
            // imageList1
            // 
            this.imageList1.ColorDepth = System.Windows.Forms.ColorDepth.Depth8Bit;
            this.imageList1.ImageSize = new System.Drawing.Size(16, 16);
            this.imageList1.TransparentColor = System.Drawing.Color.Transparent;
            // 
            // btnRefresh
            // 
            this.btnRefresh.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnRefresh.Location = new System.Drawing.Point(479, 483);
            this.btnRefresh.Name = "btnRefresh";
            this.btnRefresh.Size = new System.Drawing.Size(156, 48);
            this.btnRefresh.TabIndex = 5;
            this.btnRefresh.Text = "Refresh";
            this.btnRefresh.UseVisualStyleBackColor = true;
            this.btnRefresh.Click += new System.EventHandler(this.btnRefresh_Click);
            // 
            // Selection
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(1014, 537);
            this.Controls.Add(this.btnRefresh);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.lblRecordsQuantity);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.btnCancel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Selection";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Selection";
            this.Load += new System.EventHandler(this.Selection_Load);
            this.groupBox1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvSelection)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.DataGridView dgvSelection;
        private System.Windows.Forms.Button btnPageDown;
        private System.Windows.Forms.Button btnPageUp;
        private System.Windows.Forms.Button btnLineDown;
        private System.Windows.Forms.Button btnLineUp;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label lblRecordsQuantity;
        private System.Windows.Forms.ImageList imageList1;
        private System.Windows.Forms.Button btnLineEnd;
        private System.Windows.Forms.Button btnLineHome;
        private System.Windows.Forms.Button btnLineRight;
        private System.Windows.Forms.Button btnLineLeft;
        private System.Windows.Forms.Button btnRefresh;
    }
}
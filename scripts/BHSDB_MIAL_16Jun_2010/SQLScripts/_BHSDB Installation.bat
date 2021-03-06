@ECHO OFF

ECHO #############################################################################
ECHO # Batch File: _BHSDB Installation.bat                                       #
ECHO # Release#: 2.0                                                             #
ECHO # Release Date: 20 Aug 2009                                                 #
ECHO # Author: Xu Jian                                                           #
ECHO # Description:                                                              #
ECHO # This batch will perform follow tasks-                                     #
ECHO # 1.1 Create PALS BHS Solution Database: BHSDB                              #
ECHO # 1.2 Create BHSDB Database LOGIN, ROLE and USER                            #
ECHO # 2.1 Create SAC Tables, Views, Triggers and Keys                           #
ECHO # 2.2 Create SAC application Stored Procedures                              #
ECHO # 2.3 Insert SAC Initial Data in to SAC tables                              #
ECHO # 2.4 Update SAC tables                                                     #
ECHO # 3.1 Create MDS Tables, Views, Triggers and Keys                           #
ECHO # 3.2 Create MDS application Stored Procedures                              #
ECHO # 3.3 Insert MDS Initial Data in to MDS tables                              #
ECHO # 4.1 Create Reporting Tables, Views, Triggers and Keys                     #
ECHO # 4.2 Create Reporting Stored Procedures                                    #
ECHO # 4.3 Insert Reporting Initial Data                                         #
ECHO # 5.1 Create MDS-CCTV interface Tables, Views, Triggers and Keys            #
ECHO # 5.2 Create MDS-CCTV interface Stored Procedures                           #
ECHO # 5.3 Insert MDS-CCTV interface Initial Data                                #
ECHO # 5.4 Create MDS-CCTV interface DB job for auto resetting CCTV faults       #
ECHO # 9.0 Create BHSDB Database housekeeping Stored Procedure                   #
ECHO #                                                                           #
ECHO # Following 16 SQL script files is required by the batch file-              #
ECHO # 1.1.SYS_CreateDB.sql                                                      #
ECHO # 1.2.SYS_CreateSecurity.sql                                                #
ECHO # 2.1.SAC_CreateTable.sql                                                   #
ECHO # 2.2.SAC_CreateSTP.sql                                                     #
ECHO # 2.3.SAC_InsertINIData.sql                                                 #
ECHO # 3.1.MDS_CreateTable.sql                                                   #
ECHO # 3.2.MDS_CreateSTP.sql                                                     #
ECHO # 3.3.MDS_InsertINIDate.sql                                                 #
ECHO # 4.1.RPT_CreateTable.sql                                                   #
ECHO # 4.2.RPT_CreateSTP.sql                                                     #
ECHO # 4.3.RPT_InsertINIData.sql                                                 #
ECHO # 5.1.CCTV_CreateTable.sql                                                  #
ECHO # 5.2.CCTV_CreateSTP.sql                                                    #
ECHO # 5.3.CCTV_InsertINIData.sql                                                #
ECHO # 5.4.CCTV_CreateAutoResetJob.sql                                           #
ECHO # 9.0.SYS_CreateHousekeepSTP.sql (must be the last step among all scripts)  #
ECHO #                                                                           #
ECHO # The BHS Solution Database will be created on the S: drive folder:         #
ECHO # - S:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\               #
ECHO #############################################################################
PAUSE

ECHO Creating "C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\"... 
MKDIR "C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA"

COPY ReportLogo.gif C:\

REM Follow DBSVR is the SQL DB server name (or full DB instance name if it is created).
SET DBSVR=N04045-ITXXXXSG

echo Step 1.1 Create PALS BHS Solution Database: BHSDB 
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\1.1.SYS_CreateDB.sql" -o .\_Step1.1.log

echo Step 1.2 Create BHSDB Database LOGIN, ROLE and USER 
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\1.2.SYS_CreateSecurity.sql" -o .\_Step1.2.log

echo Step 2.1 Create SAC Tables, Views, Triggers and Keys
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\2.1.SAC_CreateTable.sql" -o .\_Step2.1.log

echo Step 2.2 Create SAC application Stored Procedures
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\2.2.SAC_CreateSTP.sql" -o .\_Step2.2.log

echo Step 2.3 Insert SAC Initial Data in to SAC tables
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\2.3.SAC_InsertINIData.sql" -o .\_Step2.3.log

echo Step 2.4 Update SAC tables
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\2.4.2.4.SAC_UpdateMESTables.sql" -o .\_Step2.4.log

echo Step 3.1 Create MDS Tables, Views, Triggers and Keys
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\3.1.MDS_CreateTable.sql" -o .\_Step3.1.log

echo Step 3.2 Create MDS application Stored Procedures
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\3.2.MDS_CreateSTP.sql" -o .\_Step3.2.log

echo Step 3.3 Insert MDS Initial Data in to MDS tables
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\3.3.MDS_InsertINIDate.sql" -o .\_Step3.3.log

echo Step 4.1 Create Reporting Tables, Views, Triggers and Keys
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\4.1.RPT_CreateTable.sql" -o .\_Step4.1.log

echo Step 4.2 Create Reporting Stored Procedures
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\4.2.RPT_CreateSTP.sql" -o .\_Step4.2.log

echo Step 4.3 Insert Reporting Initial Data
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\4.3.RPT_InsertINIData.sql" -o .\_Step4.3.log

echo Step 5.1 Create MDS-CCTV interface Tables, Views, Triggers and Keys
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\5.1.CCTV_CreateTable.sql" -o .\_Step5.1.log

echo Step 5.2 Create MDS-CCTV interface Stored Procedures
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\5.2.CCTV_CreateSTP.sql" -o .\_Step5.2.log

echo Step 5.3 Insert MDS-CCTV interface Initial Data
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\5.3.CCTV_InsertINIData.sql" -o .\_Step5.3.log

echo Step 5.4 Create MDS-CCTV interface DB job for auto resetting CCTV faults
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\5.4.CCTV_CreateScheduleJob.sql" -o .\_Step5.4.log

echo Step 9.0 Create BHSDB Database housekeeping Stored Procedure
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\9.0.SYS_CreateHousekeepSTP.sql" -o .\_Step9.0.log

:Exit
PAUSE



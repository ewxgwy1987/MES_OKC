@ECHO OFF

ECHO #############################################################################
ECHO # Batch File: _BHS_LOCALMES Installation.bat                                #
ECHO # Release#: 1.0                                                             #
ECHO # Release Date: 09 Dec 2010                                                 #
ECHO # Author: Albert                                                            #
ECHO # Description:                                                              #
ECHO # This batch will perform follow tasks-                                     #
ECHO # 1.1 Create PALS BHS Solution Database: BHS_LOCALMES                       #
ECHO # 2.1 Create MES Tables, Views, Triggers and Keys                           #
ECHO # 2.2 Create MES application Stored Procedures                              #
ECHO #                                                                           #
ECHO # Following 3 SQL script files is required by the batch file-               #
ECHO # 1.1.SYS_CreateDB.sql                                                      #
ECHO # 2.1.CreateTables.sql                                                      #
ECHO # 2.2.CreateStoreprocedures.sql                                             #
ECHO #                                                                           #
ECHO # The BHS Solution Database will be created on the S: drive folder:         #
ECHO # - S:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\               #
ECHO #############################################################################
PAUSE

ECHO Creating "S:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\"... 
REM MKDIR "S:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA"

COPY ReportLogo.gif C:\

REM Follow DBSVR is the SQL DB server name (or full DB instance name if it is created).
SET DBSVR=CSI-ALBERT

echo Step 1.1 Create PALS BHS Solution Database: BHS_LOCALMES 
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\1.1.SYS_CreateDB.sql" -o .\_Step1.1.log

echo Step 2.1 Create Tables, Views, Triggers and Keys
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\2.1.CreateTables.sql" -o .\_Step2.1.log

echo Step 2.2 Create application Stored Procedures
SQLCMD -S %DBSVR% -U sa -P DBAdm1n@BHS.irel -i ".\2.2.CreateStoreprocedures.sql" -o .\_Step2.2.log

:Exit
PAUSE



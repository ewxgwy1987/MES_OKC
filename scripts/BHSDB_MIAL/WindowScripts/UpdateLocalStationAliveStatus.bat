@ECHO OFF
REM #############################################################################
REM # Batch File: STATUS.bat    	                                        #
REM # Release#: 1.0                                                             #
REM # Release Date: 18 FEB 2009                                                 #
REM # Author: HS CHIA                                                           #
REM # Description:                                                              #
REM # 	This batch will perform the BHS connection checking task    		#
REM #	by updating the DB table [APP_LIVE_MONITORING] with 			#
REM #   StoredProcedure [stp_SYS_SERVERSTATUS].			                #
REM #	                                                                        #
REM #   There are a integer parameters need to be passed to StoredProcedure:    #
REM #   @sERVER -	THIS IS THE SERVER NAME, AVOID THE SERVER HAVE "-"	#
REM #			LIKE SAC-COM1 WHICH "-" IS NOT ALLOWED   		#
REM #############################################################################

SQLCMD -S BHSDB -U sacdbuser -P sac@interr0l1er -v SERVER="%COMPUTERNAME%" -Q "USE BHSDB;EXEC [dbo].[stp_SAC_UPDATELOCALSTATIONALIVESTATUS] $(SERVER);" 


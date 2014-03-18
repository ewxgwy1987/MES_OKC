-- ##########################################################################
-- Release#:    R1.0
-- Release On:  20 Aug 2009
-- Filename:    5.4.CCTV_CreateScheduleJob.sql
-- Description: SQL Scripts of creating SQL Server Agent schedule jobs.
--
--    Schedule jobs to be created by this script:
--    01. [PALS_CCTV_FaultAutoReset] - Scheduler job to be performed by SQL
--        Server Agent service. This job will be started in 1 minutes interval
--        to check the [TIME_STAMP] field value or CCTV alarms in [CCTV_STATUS]
--        table, and remove those alarms, which CCTV server is not able to produce 
--        the alarm normalized message, after 5 minutes. This process is called
--        auto reset CCTV alarms.
--
--
-- Histories:
--    R1.0 - Released on ?.
-- Remarks:
-- ##########################################################################




PRINT 'INFO: STEP 5.4 - Create MDS-CCTV interface related scheduler jobs.'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO

USE [msdb]
GO

--/****** Object:  Job [PALS_CCTV_FaultAutoReset]    Script Date: 08/20/2009 17:38:34 ******/
--IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'PALS_CCTV_FaultAutoReset')
--BEGIN
--	PRINT 'INFO: Deleting existing SQL Server Agent job [PALS_CCTV_FaultAutoReset]...'
--	EXEC msdb.dbo.sp_delete_job @job_name=N'PALS_CCTV_FaultAutoReset', @delete_unused_schedule=1
--END
--GO

--PRINT 'INFO: Creating SQL Server Agent job [PALS_CCTV_FaultAutoReset]...'

--/****** Object:  Job [PALS_CCTV_FaultAutoReset]    Script Date: 08/20/2009 17:38:34 ******/
--BEGIN TRANSACTION
--DECLARE @ReturnCode INT
--SELECT @ReturnCode = 0
--/****** Object:  JobCategory [Database Maintenance]    Script Date: 08/20/2009 17:38:34 ******/
--IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
--BEGIN
--EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

--END

--DECLARE @jobId BINARY(16)
--EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'PALS_CCTV_FaultAutoReset', 
--		@enabled=1, 
--		@notify_level_eventlog=0, 
--		@notify_level_email=0, 
--		@notify_level_netsend=0, 
--		@notify_level_page=0, 
--		@delete_level=0, 
--		@description=N'Job will be started in every one minute interval to remove CCTV alarms, on which CCTV server is unable to produce the normalized message for MDS, after they were activated for 5 minutes.', 
--		@category_name=N'Database Maintenance', 
--		@owner_login_name=N'sacdbuser', @job_id = @jobId OUTPUT
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--/****** Object:  Step [FaultAutoReset]    Script Date: 08/20/2009 17:38:34 ******/
--EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FaultAutoReset', 
--		@step_id=1, 
--		@cmdexec_success_code=0, 
--		@on_success_action=1, 
--		@on_success_step_id=0, 
--		@on_fail_action=2, 
--		@on_fail_step_id=0, 
--		@retry_attempts=0, 
--		@retry_interval=0, 
--		@os_run_priority=0, @subsystem=N'TSQL', 
--		@command=N'DECLARE @ResetTimeout int

---- CCTV Fault Auto Reset Timeout, default is 5 minutes
--SET @ResetTimeout = 5 
--EXECUTE [BHSDB].[dbo].[stp_CCTV_AUTORESETCCTVFAULTS] @ResetTimeout

--', 
--		@database_name=N'BHSDB', 
--		@flags=0
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'FaultAutoReset', 
--		@enabled=1, 
--		@freq_type=4, 
--		@freq_interval=1, 
--		@freq_subday_type=4, 
--		@freq_subday_interval=1, 
--		@freq_relative_interval=0, 
--		@freq_recurrence_factor=0, 
--		@active_start_date=20090820, 
--		@active_end_date=99991231, 
--		@active_start_time=0, 
--		@active_end_time=235959, 
--		@schedule_uid=N'f2c4a430-0912-497a-b518-0df9c660dd84'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
--COMMIT TRANSACTION
--GOTO EndSave
--QuitWithRollback:
--    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
--EndSave:

--GO





PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: End of STEP 5.4'
GO

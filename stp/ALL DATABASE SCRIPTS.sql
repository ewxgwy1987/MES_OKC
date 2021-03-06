USE [BHSDB_CLT_LOCAL]
GO
/****** Object:  User [mdsdbuser]    Script Date: 05-Apr-14 3:49:06 PM ******/
CREATE USER [mdsdbuser] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [reportuser]    Script Date: 05-Apr-14 3:49:06 PM ******/
CREATE USER [reportuser] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [sacdbuser]    Script Date: 05-Apr-14 3:49:06 PM ******/
CREATE USER [sacdbuser] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [BHS]    Script Date: 05-Apr-14 3:49:06 PM ******/
CREATE ROLE [BHS]
GO
ALTER ROLE [BHS] ADD MEMBER [mdsdbuser]
GO
ALTER ROLE [BHS] ADD MEMBER [reportuser]
GO
ALTER ROLE [BHS] ADD MEMBER [sacdbuser]
GO
/****** Object:  UserDefinedTableType [dbo].[ALLOCCOMINFO_TABLETYPE]    Script Date: 05-Apr-14 3:49:06 PM ******/
CREATE TYPE [dbo].[ALLOCCOMINFO_TABLETYPE] AS TABLE(
	[AIRLINE] [varchar](3) NULL,
	[FLIGHT_NUMBER] [varchar](5) NULL,
	[SDO] [datetime] NULL,
	[COMBINEINFO] [varchar](200) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[ALLOCINFO_TABLETYPE]    Script Date: 05-Apr-14 3:49:06 PM ******/
CREATE TYPE [dbo].[ALLOCINFO_TABLETYPE] AS TABLE(
	[AIRLINE] [varchar](3) NULL,
	[FLIGHT_NUMBER] [varchar](5) NULL,
	[SDO] [datetime] NULL,
	[ALLOCINFO] [varchar](10) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[ITEM_ENCODED_TABLETYPE]    Script Date: 05-Apr-14 3:49:06 PM ******/
CREATE TYPE [dbo].[ITEM_ENCODED_TABLETYPE] AS TABLE(
	[TIME_STAMP] [datetime] NULL,
	[GID] [varchar](10) NULL,
	[LICENSE_PLATE] [varchar](10) NULL,
	[SUBSYSTEM] [varchar](10) NULL,
	[LOCATION] [varchar](20) NULL,
	[ENCODED_TYPE] [varchar](2) NULL,
	[SORT_REASON] [varchar](2) NULL,
	[INDEX_NO] [varchar](10) NULL,
	[EDS] [bit] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[ITEM_READY_TABLETYPE]    Script Date: 05-Apr-14 3:49:06 PM ******/
CREATE TYPE [dbo].[ITEM_READY_TABLETYPE] AS TABLE(
	[TIME_STAMP] [datetime] NULL,
	[GID] [varchar](10) NULL,
	[LICENSE_PLATE] [varchar](10) NULL,
	[SUBSYSTEM] [varchar](10) NULL,
	[LOCATION] [varchar](20) NULL,
	[SORTATION_REASON] [varchar](2) NULL,
	[INDEX_NO] [varchar](10) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[ITEM_REMOVED_TABLETYPE]    Script Date: 05-Apr-14 3:49:06 PM ******/
CREATE TYPE [dbo].[ITEM_REMOVED_TABLETYPE] AS TABLE(
	[TIME_STAMP] [datetime] NULL,
	[GID] [varchar](10) NULL,
	[LICENSE_PLATE] [varchar](10) NULL,
	[SUBSYSTEM] [varchar](10) NULL,
	[LOCATION] [varchar](20) NULL,
	[INDEX_NO] [varchar](10) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[MES_EVENT_TABLETYPE]    Script Date: 05-Apr-14 3:49:06 PM ******/
CREATE TYPE [dbo].[MES_EVENT_TABLETYPE] AS TABLE(
	[TIME_STAMP] [datetime] NULL,
	[GID] [varchar](10) NULL,
	[LICENSE_PLATE] [varchar](10) NULL,
	[SUBSYSTEM] [varchar](10) NULL,
	[LOCATION] [varchar](10) NULL,
	[ACTION] [varchar](10) NULL,
	[ACTION_DESC] [varchar](25) NULL,
	[MES_STATION] [varchar](16) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[TAGREAD_TABLETYPE]    Script Date: 05-Apr-14 3:49:07 PM ******/
CREATE TYPE [dbo].[TAGREAD_TABLETYPE] AS TABLE(
	[GID] [varchar](10) NULL,
	[LICENSE_PLATE1] [varchar](10) NULL,
	[LICENSE_PLATE2] [varchar](10) NULL,
	[LOCATION] [varchar](20) NULL,
	[TIME_STAMP] [datetime] NULL
)
GO
/****** Object:  StoredProcedure [dbo].[stp_BCDS_GET_BAG_COUNT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Pan Feng
-- Create date: 2011-10-24
-- Description:	Main sp for get baggage count on L1/2, L3, L4, Clear Line and lost bag count, stray bag count  select * from BCDS_BAG_COUNT  update BCDS_BAG_COUNT set BAG_COUNT=1
-- stp_BCDS_GET_BAG_COUNT 'GetBagCount','',0,'','',''
-- =============================================
CREATE PROCEDURE [dbo].[stp_BCDS_GET_BAG_COUNT]
	--@OperationType varchar(50),
	--@Location varchar(20),
	--@BagType varchar(2),
	--@ProceededDest varchar(20),
	--@ProceededType varchar(2),
	--@GID varchar(10)
	@OperationType varchar(50),
	@Original_Location varchar(20),
	@Destination_Location varchar(20),
	@Screen_Level varchar(20),
	@GID varchar(10),
	@BagType varchar(2)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @OperationType = 'GetBagCount'
	BEGIN
		Select * from BCDS_BAG_COUNT where BAG_LOCATION != 'L5'
	END
	ELSE IF @OperationType = 'ItemScreen'
	BEGIN
		If (@Screen_Level in ('1','2'))
		Begin
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT + 1 where BAG_LOCATION = 'L1/2'
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT + 1 where BAG_LOCATION = 'System'
		End
		ELSE IF (@Screen_Level = '3')
		BEGIN
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT + 1 where BAG_LOCATION = 'L5'
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'L3' and BAG_COUNT >0
		END
	END
	ELSE IF @OperationType = 'ItemProceeded'
	BEGIN
		If ((@Original_Location like 'CI%' and  @Destination_Location like 'RT%') or (@Original_Location like 'TX%' and  @Destination_Location = 'RTT'))
		BEGIN
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'L1/2' and BAG_COUNT >0
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'System' and BAG_COUNT >0
		END
		ELSE IF ((@Original_Location like 'CI%' and  @Destination_Location like 'CL%') or (@Original_Location like 'TX%' and  @Destination_Location like 'CL%') )
		BEGIN
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'L1/2' and BAG_COUNT >0
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT + 1 where BAG_LOCATION = 'L3'
		END
		ELSE IF (@Original_Location like 'DL%' and @Destination_Location like 'RT%')
		BEGIN
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'L5' and BAG_COUNT >0
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'System' and BAG_COUNT >0
		END
		ELSE IF ((@Original_Location = 'DL1M07' and @Destination_Location = 'DL1M17') or @Destination_Location = 'DL1M16')
		BEGIN
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'L4' and BAG_COUNT >0
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'System' and BAG_COUNT >0
		END
		ELSE IF (@Original_Location = 'DL1M05' and @Destination_Location = 'DL1M15')
		BEGIN
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT + 1 where BAG_LOCATION = 'L4'
			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'L5' and BAG_COUNT >0
		END
	END
	--ELSE IF @OperationType = 'GIDUsed'
	--BEGIN
	--	IF @Original_Location = 'BR1-5'
	--	BEGIN
	--		update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT + 1 where BAG_LOCATION = 'L4'
	--		update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'L5'
	--	END
	--END


	--Declare @Origin_Conveyor_Level varchar(10)
	--Select @Origin_Conveyor_Level from LOCATIONS where LOCATION = @Location
	
	--Declare @Dest_Conveyor_Level varchar(10)
	--Select @Dest_Conveyor_Level from LOCATIONS where LOCATION = @ProceededDest
	
	--IF @OperationType = 'GetBagCount'
	--BEGIN
	--	Select * from BCDS_BAG_COUNT where BAG_LOCATION != 'L5'
	--END
	--ELSE IF @OperationType = 'GIDUsed'
	--BEGIN
	--	If (@Origin_Conveyor_Level in ('L1/2','L3','L5','L4'))
	--	Begin
	--		update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT + 1 where BAG_LOCATION = @Origin_Conveyor_Level
	--		update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT + 1 where BAG_COUNT = 'System'
	--	End
	--END
	--ELSE IF @OperationType = 'ItemLost'
	--BEGIN
	--	If (@Origin_Conveyor_Level in ('L1/2','L3','L5','L4'))
	--	Begin
	--		update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = @Origin_Conveyor_Level and BAG_COUNT > 0
	--		update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'System' and BAG_COUNT > 0
	--	End
	--END
	--ELSE IF @OperationType = 'ItemProceeded'
	--BEGIN
	--	If (@Origin_Conveyor_Level in ('L1/2','L3','L5','L4'))
	--	Begin
	--		If (@Dest_Conveyor_Level not in ('L1/2','L3','L5','L4'))
	--		Begin
	--			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = @Origin_Conveyor_Level and BAG_COUNT > 0
	--			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = 'System' and BAG_COUNT > 0
	--		End
	--		Else
	--		Begin
	--			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT - 1 where BAG_LOCATION = @Origin_Conveyor_Level and BAG_COUNT > 0
	--			update BCDS_BAG_COUNT set BAG_COUNT = BAG_COUNT + 1 where BAG_LOCATION = @Dest_Conveyor_Level
	--		End
			
	--	End	
	--END

END


GO
/****** Object:  StoredProcedure [dbo].[stp_BCDS_RESET_BAG_COUNT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Pan Feng
-- Create date: 2011-10-24
-- Description:	For BCDS recreate temp table
-- =============================================
create PROCEDURE [dbo].[stp_BCDS_RESET_BAG_COUNT]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	     
    UPDATE BCDS_BAG_COUNT SET BAG_COUNT = 0 

END


GO
/****** Object:  StoredProcedure [dbo].[stp_BCDS_RESET_BAG_COUNT_AUTO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Pan Feng
-- Create date: 2011-10-31
-- Description:	auto reset bag counter
-- =============================================
create PROCEDURE [dbo].[stp_BCDS_RESET_BAG_COUNT_AUTO]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
	DECLARE @reset bit
	SET @reset = 0
	
	DECLARE @reset2 bit
	SET @reset2 = 0
	
	DECLARE @reset3 bit
	SET @reset3 = 0
	
	DECLARE @reset4 bit
	SET @reset4 = 0
	
	DECLARE @interval int
	SELECT @interval = ISNULL(SYS_VALUE,10) FROM SYS_CONFIG WHERE SYS_KEY = 'BCDS_AUTO_RESET_TIMEOUT'
	
	IF not exists(SELECT * FROM GID_USED WHERE DATEDIFF(MINUTE,TIME_STAMP,GETDATE())<= @interval)
	BEGIN SET @reset = 1 END
	ELSE
	BEGIN SET @reset = 0 END
	
	--select @reset
	
	IF not exists(SELECT * FROM ITEM_PROCEEDED WHERE DATEDIFF(MINUTE,TIME_STAMP,GETDATE())<= @interval)
	BEGIN SET @reset2 = 1 END
		ELSE
	BEGIN SET @reset2 = 0 END
	
	--select @reset
	
	IF not exists(SELECT * FROM ITEM_LOST WHERE DATEDIFF(MINUTE,TIME_STAMP,GETDATE())<= @interval)
	BEGIN SET @reset3 = 1 END
		ELSE
	BEGIN SET @reset3 = 0 END
	
		--select @reset
	
	IF not exists(SELECT * FROM ITEM_SCREENED WHERE DATEDIFF(MINUTE,TIME_STAMP,GETDATE())<= @interval)
	BEGIN SET @reset4 = 1 END
		ELSE
	BEGIN SET @reset4 = 0 END
	
		--select @reset
	
	IF (@reset = 1 AND @reset2 = 1 AND @reset3 = 1 AND @reset4 = 1)
	BEGIN
	EXEC stp_BCDS_RESET_BAG_COUNT
	END
	
END



GO
/****** Object:  StoredProcedure [dbo].[stp_CHECKAPPLIVESTATUS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_CHECKAPPLIVESTATUS] 
	@AppCode [varchar](30),
	@Status [varchar](10) OUT, 
	@TimeStamp [DATETIME] OUT	
AS		
BEGIN
	SELECT @TimeStamp = [TIME_STAMP], @Status = [LIVE_STATUS_TYPE] FROM [BHSDB_T1].[dbo].[APP_LIVE_MONITORING]
		  WHERE APP_CODE = @AppCode 
END


GO
/****** Object:  StoredProcedure [dbo].[stp_DANGER_CLEANTABLE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_DANGER_CLEANTABLE]
AS
BEGIN
	BEGIN TRY

		BEGIN TRANSACTION CLEAN_TABLE;

		TRUNCATE TABLE ITME_1500P;
		TRUNCATE TABLE ITME_ENCODING_REQUEST;
		TRUNCATE TABLE ITME_LOST;
		TRUNCATE TABLE ITME_MEASURED;
		TRUNCATE TABLE ITME_PROCEEDED;
		TRUNCATE TABLE ITME_REDIRECT;
		TRUNCATE TABLE ITME_SCANNED;
		TRUNCATE TABLE ITME_SCREENED;
		TRUNCATE TABLE ITME_SORTATION_EVENT;
		TRUNCATE TABLE ITME_TRACKING;
		TRUNCATE TABLE GID_USED;

		COMMIT TRANSACTION CLEAN_TABLE;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[stp_IB_FLIGHT_ERROR_DATA]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_IB_FLIGHT_ERROR_DATA]   
  
  @DESC nvarchar (200),  
  @ERROR_INDICATOR char(1),      
  @RAW_DATA varchar(5000)   
  AS        
 Declare @DATA_ID bigint   
     INSERT INTO FLIGHT_PLANS       
   (TIME_STAMP,RAW_DATA,ERROR_INDICATOR )      
   VALUES(GETDATE(),@RAW_DATA,@ERROR_INDICATOR )    
      
   SET @DATA_ID =(Select Top 1 ID from FLIGHT_PLANS order by TIME_STAMP desc)  
     
    INSERT INTO FLIGHT_PLAN_ERROR       
   (DATA_ID,TIME_STAMP,DESCRIPTION )      
   VALUES(@DATA_ID,GETDATE(),@DESC)   

GO
/****** Object:  StoredProcedure [dbo].[stp_IB_FLIGHT_RAW_DATA]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  <Author,,PST>    
-- Create date: <Create Date,2012,>    
-- Description: <Description,,>    
-- =============================================  stp_IB_FlightInfoIntoDataBase 'LH','123','2012-12-24 00:00:00.000'    
Create PROCEDURE [dbo].[stp_IB_FLIGHT_RAW_DATA]    
 -- Add the parameters for the stored procedure here   
  @ERROR_INDICATOR char(1),  
  @RAW_DATA varchar(5000)  
    
 AS  
   
 BEGIN  
  --- Loginto  FLIGHT_PLANS  
 INSERT INTO FLIGHT_PLANS   
   (TIME_STAMP,RAW_DATA,ERROR_INDICATOR )  
   VALUES(GETDATE(),@RAW_DATA,@ERROR_INDICATOR )      
 END   

GO
/****** Object:  StoredProcedure [dbo].[stp_IB_FlightInfoIntoDataBase]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        

-- Author:  <Author,,PST>        

-- Create date: <Create Date,2012,>        

-- Description: <Description,,>        

-- =============================================  stp_IB_FlightInfoIntoDataBase 'Create','LH','123','2012-12-24 00:00:00.000',        

CREATE PROCEDURE [dbo].[stp_IB_FlightInfoIntoDataBase]        

 -- Add the parameters for the stored procedure here       

  @FLIGHTSTATUS varchar(10),      

  @MASTERFLIGHTNUMBER varchar(5),      

  @MASTERAIRLINE varchar(3),      

  @MASTERSDO varchar(8),      

  @AIRLINE varchar(3),         

  @FLIGHT_NUMBER varchar(5),         

  @SDO datetime,       

  @STO varchar(4),       

  @EDO datetime,        

  @ETO varchar(4),      

  @CHECKIN_AREA varchar(10) ,    

  @ERROR_INDICATOR char(1),      

  @RAW_DATA varchar(5000)  ,  

  @GATE varchar(5)   ,

  @FINAL_DEST varchar(3)

AS        

BEGIN        

  DECLARE @FLIGHTCREATE varchar(10)

  DECLARE @FLIGHTCANCEL varchar(10)      

  DECLARE @FLIGHTDELETE varchar(10)      

  DECLARE @CREATEDBY varchar(15)      

  DECLARE @PREV_ALLOC_RESOURCE_CODE varchar(10)      

  DECLARE @ALLOC_RESOURCE_CODE varchar(10)   

  DECLARE @PREVCHECK_Countercode varchar(10)     

  SET @FLIGHTCREATE ='CREATE'

  SET @FLIGHTCANCEL='CANCEL'      

  SET @FLIGHTDELETE ='DELETE'      

  SET @CREATEDBY='FIDS'      

        

  IF (@CHECKIN_AREA IS NOT NULL AND @CHECKIN_AREA <> '')      

  BEGIN      

 SET @ALLOC_RESOURCE_CODE =

   (select ALLOC_RESOURCE_CODE

   from dbo.CHECKIN_GROUP_RESOURCE_MAPPING

   where CHECKIN_GROUP_CODE =(

      SELECT CHECKIN_GROUP_CODE from

        dbo.CHECKIN_GROUP_MAPPING where CHECKIN_LINE_CODE ='CI'+@CHECKIN_AREA ))

        
  set @PREVCHECK_Countercode=(SELECT CHECKIN_AREA FROM FLIGHT_PLAN_SORTING     

         Where AIRLINE=@AIRLINE and FLIGHT_NUMBER =@FLIGHT_NUMBER       

         and SDO =@SDO )   

        

  SET @PREV_ALLOC_RESOURCE_CODE =      

  (select ALLOC_RESOURCE_CODE 

   from dbo.CHECKIN_GROUP_RESOURCE_MAPPING

   where CHECKIN_GROUP_CODE =(

      SELECT CHECKIN_GROUP_CODE from

        dbo.CHECKIN_GROUP_MAPPING where CHECKIN_LINE_CODE ='CI' + @PREVCHECK_Countercode))    

       

 END       

        

  IF EXISTS(SELECT FLIGHT_NUMBER from FLIGHT_PLAN_SORTING Where AIRLINE=@AIRLINE and FLIGHT_NUMBER =@FLIGHT_NUMBER       

 and SDO =@SDO )        

  BEGIN      

    --LogInto FLIGHT_CANCEL tbl      

    IF @FLIGHTSTATUS=@FLIGHTCANCEL      

       BEGIN      

       INSERT INTO FLIGHT_CANCEL (TIME_STAMP,AIRLINE,FLIGHT_NUMBER ,SDO,STO,EDO,ETO,CREATED_BY )      

       VALUES(GETDATE(),@AIRLINE,@FLIGHT_NUMBER,@SDO,@STO,@EDO,@ETO,@CREATEDBY )      

       END      

     --LogInto FLIGHT_DELETE tbl      

       ELSE IF @FLIGHTSTATUS =@FLIGHTDELETE       

      BEGIN      

        INSERT INTO FLIGHT_DELETE (TIME_STAMP,AIRLINE,FLIGHT_NUMBER ,SDO,STO,EDO,ETO,CREATED_BY )      

        VALUES(GETDATE(),@AIRLINE,@FLIGHT_NUMBER,@SDO,@STO,@EDO,@ETO,@CREATEDBY )      

       END      

       --LogInto FLIGHT_RESOURCE_CHANGE      

       ELSE IF @PREV_ALLOC_RESOURCE_CODE <> @ALLOC_RESOURCE_CODE       

       BEGIN      

       INSERT INTO FLIGHT_RESOURCE_CHANGE (TIME_STAMP,AIRLINE,FLIGHT_NUMBER,SDO,STO,EDO,ETO,
	   CURRENT_RESOURCE,NEW_RESOURCE,CREATED_BY )      

       VALUES(GETDATE(),@AIRLINE,@FLIGHT_NUMBER,@SDO,@STO,@EDO,@ETO,
	   @PREV_ALLOC_RESOURCE_CODE,@ALLOC_RESOURCE_CODE,@CREATEDBY )      

       Update FLIGHT_PLAN_SORTING SET CHECKIN_AREA =@CHECKIN_AREA,PIER =@ALLOC_RESOURCE_CODE
       Where AIRLINE=@AIRLINE and FLIGHT_NUMBER =@FLIGHT_NUMBER       
       and SDO =@SDO       

       END      

	   ELSE 
	     BEGIN
		  Update FLIGHT_PLAN_SORTING SET STO =@STO , ETO =@STO 
          Where AIRLINE=@AIRLINE and FLIGHT_NUMBER =@FLIGHT_NUMBER       
          and SDO =@SDO  and 
		  (select STO From FLIGHT_PLAN_SORTING Where AIRLINE=@AIRLINE and FLIGHT_NUMBER =@FLIGHT_NUMBER       
          and SDO =@SDO) !=@STO 
	   END
         

   END       

  ELSE IF @FLIGHTSTATUS=@FLIGHTCREATE      

  BEGIN      

  --- Loginto NEW Flight into FLIGHT_PLAN_SORTING      

 INSERT INTO FLIGHT_PLAN_SORTING       

   (TIME_STAMP,AIRLINE,FLIGHT_NUMBER,      

    SDO,STO,EDO,ETO,MASTER_AIRLINE,MASTER_FLIGHT_NUMBER,MASTER_SDO,
	CREATED_BY, CHECKIN_AREA,GATE,WEEKDAY,TERMINAL,PIER,FINAL_DEST )      

 VALUES(GETDATE(),@AIRLINE,@FLIGHT_NUMBER,@SDO,@STO,@EDO,      

 @ETO,@MASTERAIRLINE,@MASTERFLIGHTNUMBER,@MASTERSDO,@CREATEDBY,@CHECKIN_AREA,
 @GATE,(Select DATEPART(Weekday,GETDATE ())),'1',@ALLOC_RESOURCE_CODE ,@FINAL_DEST            
 )
               

  END      

       IF NOT EXISTS(Select CODE_IATA FROM AIRLINES WHERE CODE_IATA =@AIRLINE )
		 BEGIN
		 INSERT INTO AIRLINES
		 (CODE_IATA,NAME ,TICKETING_CODE,DESTINATION,DESTINATION1,RUSH,HANDLER,SORT_FLAG )
		 VALUES(@AIRLINE,'','0',NULL,NULL,NUll,NUll,'FALSE')
	   END
        
     INSERT INTO FLIGHT_PLANS       

   (TIME_STAMP,RAW_DATA,ERROR_INDICATOR )      

   VALUES(GETDATE(),@RAW_DATA,@ERROR_INDICATOR )       

END 

GO
/****** Object:  StoredProcedure [dbo].[stp_IB_UpdateMasterFlight]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  <Author,,PST>        
-- Create date: <Create Date,2012,>        
-- Description: <Description,,>        
-- =============================================  stp_IB_CreateFlight 'LH','123','2012-12-24 00:00:00.000'        
CREATE PROCEDURE [dbo].[stp_IB_UpdateMasterFlight]        
 -- Add the parameters for the stored procedure here        
  @MASTER_AIRLINE varchar(3),         
  @MASTER_FLIGHT_NUMBER varchar(5),         
  @AIRLINE varchar(30),        
  @FLIGHT_NUMBER varchar(20),       
  @MasterFlightSDO DateTIme     
AS        
BEGIN        

  
Update FLIGHT_PLAN_SORTING 
			SET MASTER_AIRLINE  =@MASTER_AIRLINE, 
			MASTER_FLIGHT_NUMBER  =@MASTER_FLIGHT_NUMBER   
			--MASTER_SDO =@MasterFlightSDO
		    WHERE AIRLINE IN(SELECT ColumnA AS AirLine  
		FROM dbo.udf_List2Table(@AIRLINE,',')) 
		AND FLIGHT_NUMBER in (SELECT ColumnA AS FlightNum  
		FROM dbo.udf_List2Table(@FLIGHT_NUMBER,','))  
		AND SDO in (@MasterFlightSDO)
  
END 

GO
/****** Object:  StoredProcedure [dbo].[stp_MDS_TOPEQUIPMENT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MDS_TOPEQUIPMENT] 
	@RANK [int],
	@DTFrom [datetime],
	@DTTo [datetime]   
AS
BEGIN
		SELECT TOP (@RANK) COUNT(*) AS OCCURRENCE, ALM_ALMEXTFLD2
		FROM MDS_ALARMS
		WHERE  (ALM_ALMSTATUS = 'CFN') AND (ALM_UNCERTAIN = 0) 
			   AND (ALM_ALMAREA2 <> 'AA_UNAV') AND (ALM_ALMAREA2 <> 'AA_ESTP') AND (ALM_ALMAREA2 <> 'AA_ISOF')
			   AND (ALM_STARTTIME BETWEEN @DTFrom AND @DTTo)
		GROUP BY ALM_ALMEXTFLD2
		ORDER BY OCCURRENCE DESC
END



GO
/****** Object:  StoredProcedure [dbo].[stp_MDS_TOPFAULT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MDS_TOPFAULT] 
	@RANK [int],
	@DTFrom [datetime],
    @DTTo [datetime]   
AS
BEGIN
        SELECT TOP (@RANK) COUNT(*) AS OCCURRENCE, FAULT_DESCRIPTION
        FROM MDS_ALARMS, REPORT_FAULT
        WHERE  (ALM_ALMSTATUS = 'CFN') AND (ALM_UNCERTAIN = 0) AND (ALM_ALMAREA2 <> 'AA_UNAV') AND 
			   (ALM_ALMAREA2 <> 'AA_ESTP') AND (ALM_ALMAREA2 <> 'AA_ISOF') AND
			   (ALM_STARTTIME BETWEEN @DTFrom AND @DTTo) AND 
               (MDS_ALARMS.ALM_ALMAREA2=REPORT_FAULT.FAULT_NAME) AND
               (REPORT_FAULT.FAULT_TYPE='ALARM') AND (REPORT_FAULT.FAULT_USED='TRUE')
        GROUP BY FAULT_DESCRIPTION
        ORDER BY OCCURRENCE DESC
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_CHECK_BAG_REOCCURENCE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Albert Sun
-- Create date: 15-Oct-2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_MES_CHECK_BAG_REOCCURENCE]
	@GID VARCHAR(10),
	@LICENSE_PLATE VARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @ITEM_COUNT INT
	DECLARE @BAG_REOCCURENCE_LIMIT INT
	
	SELECT @BAG_REOCCURENCE_LIMIT = CAST(SYS_VALUE AS INT) FROM SYS_CONFIG WHERE SYS_KEY = 'MES_BAG_REOCCURENCE'
	SELECT @ITEM_COUNT = COUNT(*) FROM ITEM_READY WHERE LICENSE_PLATE = @LICENSE_PLATE

	IF @ITEM_COUNT > @BAG_REOCCURENCE_LIMIT
	BEGIN
		UPDATE MDS_BHS_ALARMS SET ALARM_STATUS = 1 WHERE ALARM_TYPE = 'MESREOCCUR'
	END
	
	SELECT @ITEM_COUNT
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_DISABLECHANGEMONITORINGTABLEROWS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_DISABLECHANGEMONITORINGTABLEROWS]
@SAC_OWS as varchar(20),
@ID varchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	 DELETE FROM CHANGE_MONITORING_TABLE_ROWS WHERE SAC_OWS = @SAC_OWS AND ID = convert(int, @ID) 
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GET_AIRLINE_CODE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Albert Sun
-- Create date: 25-Nov-2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_MES_GET_AIRLINE_CODE] 
	@TicketCode AS VARCHAR(4)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT CODE_IATA
	FROM AIRLINES
	WHERE TICKETING_CODE = @TicketCode or '0'+ TICKETING_CODE = @TicketCode
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GET_AIRLINES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		SC Leong
-- Create date: 27-01-2014
-- Description:	Get Airlines to be displayed on buttons
-- =============================================
create PROCEDURE [dbo].[stp_MES_GET_AIRLINES]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT A.CODE_IATA, A.TICKETING_CODE 
	FROM AIRLINES A 
	ORDER BY A.CODE_IATA
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GET_ALL_SETTING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Albert Sun
-- Create date: 14-Oct-2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_MES_GET_ALL_SETTING]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT SYS_KEY, SYS_VALUE FROM SYS_CONFIG WHERE GROUP_NAME = 'MES_Sett' AND SYS_KEY LIKE 'MES_%'    
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GET_CODESHARE_FLIGHTNUMBER]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_MES_GET_CODESHARE_FLIGHTNUMBER] 
	@FLIGHT varchar(10),
	@SDO datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MASTER_AIRLINE + ' '+MASTER_FLIGHT_NUMBER FROM FLIGHT_PLAN_SORTING WHERE AIRLINE + ' '+ FLIGHT_NUMBER = @FLIGHT 
	and DAY(sdo) = DAY(@SDO) and MONTH(SDO) = MONTH(@SDO) and YEAR(SDO) = YEAR(@SDO) and MASTER_AIRLINE is not null and MASTER_AIRLINE != ''
	and MASTER_FLIGHT_NUMBER is not null and MASTER_FLIGHT_NUMBER != ''
END






GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GET_CONV_STATUS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================

-- Author:		<Author,,PST>

-- Create date: <Create Date,19 March 2014,>

-- Description:	<Description, get conv status to show on MES GUI screen,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_MES_GET_CONV_STATUS] 

	-- Add the parameters for the stored procedure here

	@SubSystem nvarchar(7)

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;


	select L.[LOCATION] 'Conv_Name',LSY.[BLINKING] 'Color_Blinking' ,LSY.[DESCRIPTION] 'Desc',LSY.[COLOR_CODE]  'Color_Code'

		   from LOCATIONS as L inner join LOCATION_STATUS_TYPES as LSY 

		   on L.STATUS_TYPE =LSY.TYPE  where L.SUBSYSTEM  =@SubSystem 



END

GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GET_FLIGHT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Albert Sun
-- Create date: 14-Sep-2010
-- Description:	<Description,,>
-- ============================================= stp_MES_GET_FLIGHT 'D'
CREATE PROCEDURE [dbo].[stp_MES_GET_FLIGHT]
	@FLIGHT VARCHAR(10)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT A.FLIGHT, A.STD,'' AS VIA,A.CLASS, A.[TRANSFER],  A.FLIGHT_DESTINATION,A.ALLOCATION_STATE, A.SORT_DESTINATION AS DEP_ALLOC_IDENT, A.SORT_DESTINATION AS DISCHARGE_NAME FROM
	(
		SELECT A.FLIGHT,A.STD, A.FLIGHT_DESTINATION, A.SORT_DESTINATION, A.SORT_DESTINATION_DESC, A.SUBSYSTEM,  A.IS_MANUAL_CLOSE, A.IS_CLOSED, A.TRAVEL_CLASS AS CLASS, A.[TRANSFER], A.ALLOCATION_STATE FROM
		(SELECT RIGHT('   ' + A.[AIRLINE], 3) + RIGHT('    ' + A.[FLIGHT_NUMBER], 4) + COALESCE(' ' + S.[FLIGHT_NUMBER_SUFFIX],'') AS FLIGHT, 
			CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
				DATEADD(HH,
					CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) AS INT) 
					WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) AS INT) END,
					A.SDO+dbo.RPT_GETFORMATTEDSTO(A.STO)) 
			WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN 
				DATEADD(MI,
					CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) AS INT) 
					WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) AS INT) END,
					A.SDO+dbo.RPT_GETFORMATTEDSTO(A.STO)) 
			END
			AS STD,
			COALESCE(S.DEST1 + ', ', '') + 
			COALESCE(S.DEST2 + ', ', '') + COALESCE(S.DEST3 + ', ', '') + COALESCE(S.DEST4 + ', ', '') + COALESCE(S.DEST5 + ', ', '') + 
			COALESCE(S.FINAL_DEST, '') AS [FLIGHT_DESTINATION], 
			ISNULL(C.DESTINATION, '') AS [SORT_DESTINATION],
			ISNULL(C.DESCRIPTION, '') AS [SORT_DESTINATION_DESC],
			ISNULL(C.SUBSYSTEM, '') AS [SUBSYSTEM],
			A.IS_MANUAL_CLOSE, A.IS_CLOSED, A.TRAVEL_CLASS, A.[TRANSFER], dbo.MES_GETFLIGHTSTATUS(A.AIRLINE,A.FLIGHT_NUMBER,A.SDO, A.STO) AS ALLOCATION_STATE
		FROM FLIGHT_PLAN_SORTING S JOIN FLIGHT_PLAN_ALLOC A ON 
			S.AIRLINE = A.AIRLINE AND S.FLIGHT_NUMBER = A.FLIGHT_NUMBER AND S.SDO = A.SDO
		LEFT JOIN DESTINATIONS C ON A.[RESOURCE] = C.DESTINATION
		) A
		WHERE REPLACE(A.FLIGHT, ' ', '') LIKE '%' + REPLACE(@FLIGHT, ' ', '') + '%' 
	) A
	WHERE /*(A.STD > GETDATE())*/ A.STD BETWEEN DATEADD(DD,-1, GETDATE()) AND DATEADD(DD, 1, GETDATE()) OR (A.IS_MANUAL_CLOSE = 1 AND A.IS_CLOSED=0)
	ORDER BY A.STD, A.FLIGHT
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GETAIRLINEINFO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		GUO WENYU
-- Create date: 23-03-2014
-- Description:	Get Flight Info to be displayed on MES : Encode by Flight
-- =============================================
create PROCEDURE [dbo].[stp_MES_GETAIRLINEINFO]
	-- Add the parameters for the stored procedure here
	@CARRIER VARCHAR(3),
	@TICKETING_CODE VARCHAR(4)
AS
DECLARE 
    @ERROR VARCHAR(100)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @ERROR = ''

	IF NOT EXISTS(SELECT * FROM AIRLINES WHERE (CODE_IATA = @CARRIER OR TICKETING_CODE=@TICKETING_CODE))
	BEGIN
	    SET @ERROR = 'No Airline Information received for Airline # ' + @CARRIER

	    SELECT @ERROR AS ERROR,'' AS AIRLINE,'' AS TICKETING_CODE
		   
		RETURN 0   
	END
    ELSE
    BEGIN
		SELECT '' AS ERROR,CODE_IATA AS AIRLINE,TICKETING_CODE FROM AIRLINES 
		WHERE (CODE_IATA = @CARRIER OR TICKETING_CODE=@TICKETING_CODE)
	END
    	 
END

GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GETCHANGEMONITORINGTABLEROWS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_GETCHANGEMONITORINGTABLEROWS]
@SAC_OWS as varchar(20)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DELETE FROM CHANGE_MONITORING_TABLE_ROWS WHERE SAC_OWS=@SAC_OWS AND IS_CHANGED=0

SELECT * FROM CHANGE_MONITORING_TABLE_ROWS 	Where SAC_OWS=@SAC_OWS and IS_CHANGED=1
	
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GETFLIGHTINFO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		SC Leong
-- Create date: 27-01-2014
-- Description:	Get Flight Info to be displayed on MES : Encode by Flight
-- =============================================
create PROCEDURE [dbo].[stp_MES_GETFLIGHTINFO]
	-- Add the parameters for the stored procedure here
	@CARRIER VARCHAR(3),
	@FLIGHT_NO VARCHAR(4),
	@SDO VARCHAR(10)
AS
DECLARE 
    @ERROR VARCHAR(100),
	@COLUMN VARCHAR(3)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT @COLUMN = SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY = 'ALLOC_OPEN_RELATED'

	SET @ERROR = ''

	IF NOT EXISTS(SELECT * FROM FLIGHT_PLAN_SORTING WHERE AIRLINE = @CARRIER AND FLIGHT_NUMBER = @FLIGHT_NO AND SDO = @SDO)
	   BEGIN
	       SET @ERROR = 'No Flight Information received for Flight # ' + @CARRIER + ' ' + @FLIGHT_NO 

	       SELECT '' AS STD, '' AS ETD, '' AS FLIGHT_DEST, '' AS FLIGHT_STATUS, @ERROR AS ERROR
		   
		   RETURN 0   
	   END
	ELSE IF NOT EXISTS(SELECT * FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE = @CARRIER AND FLIGHT_NUMBER = @FLIGHT_NO AND SDO = @SDO) 
	   BEGIN
	      SET @ERROR = 'No Flight Allocation for Flight # ' + @CARRIER + ' ' + @FLIGHT_NO 
		  
		  SELECT '' AS STD, '' AS ETD, '' AS FLIGHT_DEST, '' AS FLIGHT_STATUS, @ERROR AS ERROR
		   
		  RETURN 0  
	   END    
    ELSE
       BEGIN
	       
		   SELECT A.SDO AS STD, A.EDO AS ETD, A.FINAL_DEST, (SELECT dbo.MES_GETFLIGHTSTATUS(@CARRIER, @FLIGHT_NO, @SDO, A.STO)) AS FLIGHT_STATUS, '' AS ERROR
		   FROM FLIGHT_PLAN_SORTING A
		   WHERE A.AIRLINE = @CARRIER AND A.FLIGHT_NUMBER = @FLIGHT_NO AND SDO = @SDO
	   END
    	 
END

GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GETFLIGHTLIST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Albert Sun
-- Create date: 24-Jun-2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_MES_GETFLIGHTLIST]
	@Filter int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF @Filter > 0 
	BEGIN
		SELECT A.FLIGHT,A.STD, A.FLIGHT_DESTINATION, A.SORT_DESTINATION FROM
		(SELECT DISTINCT A.[AIRLINE] + '' + A.[FLIGHT_NUMBER] AS FLIGHT, 
			CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
				DATEADD(HH,
					CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) AS INT) 
					WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) AS INT) END,
					A.SDO+dbo.RPT_GETFORMATTEDSTO(A.STO)) 
			WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN 
				DATEADD(MI,
					CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) AS INT) 
					WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) AS INT) END,
					A.SDO+dbo.RPT_GETFORMATTEDSTO(A.STO)) 
			END
			 AS STD,
			COALESCE(S.DEST1 + '', '', '') + 
			COALESCE(S.DEST2 + '', '', '') + COALESCE(S.DEST3 + '', '', '') + COALESCE(S.DEST4 + '', '', '') + COALESCE(S.DEST5 + '', '', '') + 
			COALESCE(S.FINAL_DEST, '') AS [FLIGHT_DESTINATION], 
			dbo.MES_GETALLOCATEDDESTINATION(A.AIRLINE, A.FLIGHT_NUMBER, A.SDO, A.STO) AS [SORT_DESTINATION]
		FROM FLIGHT_PLAN_SORTING S JOIN FLIGHT_PLAN_ALLOC A ON 
			S.AIRLINE = A.AIRLINE AND S.FLIGHT_NUMBER = A.FLIGHT_NUMBER AND S.SDO = A.SDO	
		) A
		WHERE A.STD BETWEEN DATEADD(HH,0, GETDATE()) AND DATEADD(HH, @Filter, GETDATE())
		ORDER BY A.STD, A.FLIGHT
	END
	ELSE
	BEGIN
		SELECT DISTINCT FLIGHT, STD, FLIGHT_DESTINATION, SORT_DESTINATION FROM
		(
		SELECT A.FLIGHT,A.STD, A.FLIGHT_DESTINATION, A.SORT_DESTINATION FROM
		(SELECT DISTINCT A.[AIRLINE] + '' + A.[FLIGHT_NUMBER] AS FLIGHT, 
			CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
				DATEADD(HH,
					CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) AS INT) 
					WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) AS INT) END,
					A.SDO+dbo.RPT_GETFORMATTEDSTO(A.STO)) 
			WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN 
				DATEADD(MI,
					CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) AS INT) 
					WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) AS INT) END,
					A.SDO+dbo.RPT_GETFORMATTEDSTO(A.STO)) 
			END
			AS STD,
			COALESCE(S.DEST1 + '', '', '') + 
			COALESCE(S.DEST2 + '', '', '') + COALESCE(S.DEST3 + '', '', '') + COALESCE(S.DEST4 + '', '', '') + COALESCE(S.DEST5 + '', '', '') + 
			COALESCE(S.FINAL_DEST, '') AS [FLIGHT_DESTINATION], 
			dbo.MES_GETALLOCATEDDESTINATION(A.AIRLINE, A.FLIGHT_NUMBER, A.SDO, A.STO) AS [SORT_DESTINATION]
		FROM FLIGHT_PLAN_SORTING S JOIN FLIGHT_PLAN_ALLOC A ON 
			S.AIRLINE = A.AIRLINE AND S.FLIGHT_NUMBER = A.FLIGHT_NUMBER AND S.SDO = A.SDO	
		) A
		WHERE A.STD >= GETDATE()
		UNION ALL
		SELECT A.FLIGHT,A.STD, A.FLIGHT_DESTINATION, A.SORT_DESTINATION FROM
		(SELECT DISTINCT A.[AIRLINE] + '' + A.[FLIGHT_NUMBER] AS FLIGHT, 
			CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
				DATEADD(HH,
					CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) AS INT) 
					WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) AS INT) END,
					A.SDO+dbo.RPT_GETFORMATTEDSTO(A.STO)) 
			WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN 
				DATEADD(MI,
					CASE WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) <> 00 THEN 
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 1, 2) AS INT) 
					WHEN SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) <> 00 THEN
						CAST(SUBSTRING(ALLOC_CLOSE_OFFSET, 3, 2) AS INT) END,
					A.SDO+dbo.RPT_GETFORMATTEDSTO(A.STO)) 
			END
			AS STD,
			COALESCE(S.DEST1 + '', '', '') + 
			COALESCE(S.DEST2 + '', '', '') + COALESCE(S.DEST3 + '', '', '') + COALESCE(S.DEST4 + '', '', '') + COALESCE(S.DEST5 + '', '', '') + 
			COALESCE(S.FINAL_DEST, '') AS [FLIGHT_DESTINATION], 
			dbo.MES_GETALLOCATEDDESTINATION(A.AIRLINE, A.FLIGHT_NUMBER, A.SDO, A.STO) AS [SORT_DESTINATION]
		FROM FLIGHT_PLAN_SORTING S JOIN FLIGHT_PLAN_ALLOC A ON 
			S.AIRLINE = A.AIRLINE AND S.FLIGHT_NUMBER = A.FLIGHT_NUMBER AND S.SDO = A.SDO	
		WHERE A.IS_MANUAL_CLOSE = 1 AND A.IS_CLOSED = 0
		) A
		) B
		ORDER BY B.STD, B.FLIGHT
	END
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GETIATATAGINFO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_GETIATATAGINFO]
	@IATATAG VARCHAR(10)
	
AS
BEGIN
   	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (LEN(@IATATAG) = 10)
	   BEGIN
	       SELECT *
		   FROM BAG_SORTING A, FLIGHT_PLAN_SORTING B
		   WHERE A.AIRLINE = B.AIRLINE AND A.FLIGHT_NUMBER = B.FLIGHT_NUMBER AND A.SDO = B.SDO 
	   END
    
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GETPASSENGERINFO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		SC Leong
-- Create date: 27-01-2014
-- Description:	Get Passenger & Flight Info to be displayed on MES : Encode by License Plate
-- =============================================
create PROCEDURE [dbo].[stp_MES_GETPASSENGERINFO]
	-- Add the parameters for the stored procedure here
	@LICENSE_PLATE VARCHAR(10)
AS
DECLARE 
    @ERROR VARCHAR(100),
	@COLUMN VARCHAR(3)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT @COLUMN = SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY = 'ALLOC_OPEN_RELATED'

	SET @ERROR = ''

	IF NOT EXISTS(SELECT * FROM BAG_SORTING WHERE LICENSE_PLATE = @LICENSE_PLATE)
	   BEGIN
	       SET @ERROR = @LICENSE_PLATE + ' => No BSM received' 

	       SELECT '' AS PASSENGER_NAME, '' AS TRAVEL_CLASS, '' AS AIRLINE, '' AS FLIGHT_NUMBER, '' AS FINAL_DEST, @ERROR AS ERROR
		   
		   RETURN 0   
	   END
	ELSE IF (SELECT COUNT(LICENSE_PLATE) FROM BAG_SORTING WHERE LICENSE_PLATE = @LICENSE_PLATE) > 1
	   BEGIN
	      SET @ERROR = @LICENSE_PLATE + ' => Multiple BSM received'
		  
		  SELECT '' AS PASSENGER_NAME, '' AS TRAVEL_CLASS, '' AS AIRLINE, '' AS FLIGHT_NUMBER, '' AS FINAL_DEST, @ERROR AS ERROR
		   
		  RETURN 0  
	   END    
	ELSE IF NOT EXISTS(SELECT M.LICENSE_PLATE	                   
	                   FROM BAG_SORTING M,FLIGHT_PLAN_SORTING A
					   WHERE M.LICENSE_PLATE = @LICENSE_PLATE AND M.AIRLINE = A.AIRLINE AND M.FLIGHT_NUMBER = A.FLIGHT_NUMBER AND 
					         (CASE WHEN @COLUMN = 'STD' THEN A.SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN A.EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN A.ADO ELSE A.ITO END END END) = M.SDO) 
	   BEGIN
	       SET @ERROR = @LICENSE_PLATE + ' => Unknown Flight'

	       SELECT '' AS PASSENGER_NAME, '' AS TRAVEL_CLASS, '' AS AIRLINE, '' AS FLIGHT_NUMBER, '' AS FINAL_DEST, @ERROR AS ERROR 

		   RETURN 0
	   END    
    ELSE IF NOT EXISTS(SELECT M.LICENSE_PLATE	                   
	                   FROM BAG_SORTING M,FLIGHT_PLAN_ALLOC A
					   WHERE M.LICENSE_PLATE = @LICENSE_PLATE AND M.AIRLINE = A.AIRLINE AND M.FLIGHT_NUMBER = A.FLIGHT_NUMBER AND 
					         (CASE WHEN @COLUMN = 'STD' THEN A.SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN A.EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN A.ADO ELSE A.ITO END END END) = M.SDO) 
	   BEGIN
	       SET @ERROR = @LICENSE_PLATE + ' => No allocation'

	       SELECT '' AS PASSENGER_NAME, '' AS TRAVEL_CLASS, '' AS AIRLINE, '' AS FLIGHT_NUMBER, '' AS FINAL_DEST, @ERROR AS ERROR 

		   RETURN 0
	   END  
    ELSE
       BEGIN
		   SELECT COALESCE(SURNAME, '') + COALESCE(' ' + GIVEN_NAME, '') + COALESCE(' ' + OTHERS_NAME, '') AS PASSENGER_NAME, TRAVEL_CLASS , A.AIRLINE, A.FLIGHT_NUMBER, B.FINAL_DEST, 
		          '' AS ERROR  
		   FROM BAG_SORTING A INNER JOIN FLIGHT_PLAN_SORTING B ON (A.AIRLINE = B.AIRLINE AND A.FLIGHT_NUMBER = B.FLIGHT_NUMBER AND A.SDO = B.SDO)
		   WHERE A.LICENSE_PLATE = @LICENSE_PLATE
	   END
    	 
END

GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GETSUBSYSTEM]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_GETSUBSYSTEM]
	@DESTINATION VARCHAR(10)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT SUBSYSTEM FROM DESTINATIONS WHERE DESTINATION=@DESTINATION

END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GETSYSCONFIGTABLECHANGE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[stp_MES_GETSYSCONFIGTABLECHANGE]
	@Subsystem varchar(20),
	@IsChange bit OUTPUT
AS
BEGIN
	SELECT  @IsChange=IS_CHANGED FROM CHANGE_MONITORING WHERE SAC_OWS = @Subsystem AND STATE_CODE ='TB_SYS_CONFIG';
					
	UPDATE CHANGE_MONITORING SET IS_CHANGED = 0 WHERE SAC_OWS = @Subsystem AND STATE_CODE ='TB_SYS_CONFIG';
END

GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_ITEM_ENCODED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_ITEM_ENCODED]
       @GID varchar(10),
       @LOCATION varchar(10),
	   @LICENSE_PLATE varchar(10),
	   @AIRLINE varchar(3),
	   @FLIGHT_NUMBER varchar(5),
	   @ENCODING_TYPE varchar(2), 
	   @PLC_INDEX varchar(10),
	   @DEST varchar(10)

AS
BEGIN
    
    -- Step 1 : Insert Item Encoded bag event into event table [ITEM_ENCODED] 
	INSERT INTO [ITEM_ENCODED]([TIME_STAMP],[GID],[LOCATION],[LICENSE_PLATE],[AIRLINE],[FLIGHT_NUMBER],[ENCODING_TYPE],[PLC_INDEX],[DEST])
	VALUES(GETDATE(), @GID, @LOCATION,@LICENSE_PLATE, @AIRLINE, @FLIGHT_NUMBER, @ENCODING_TYPE, @PLC_INDEX, @DEST) 
			
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_ITEM_READY]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_ITEM_READY]
       @GID varchar(10),
       @SUBSYSTEM varchar(10),
       @LOCATION varchar(20),
       @SCREENING_LEVEL varchar(1),
       @SCREENING_STATUS varchar(1),
       @MODE varchar(1),
       @BAG_NUMBER varchar(5)
AS
BEGIN
	SET NOCOUNT ON;
	-- Step 1: Check Bag_Info has record or not
	EXEC stp_SAC_INSERT_BAG @GID, @Location
	
	
	DECLARE @Subsystem1 varchar(10)
	DECLARE @Location1  varchar(10)
	DECLARE @Subsystem2 varchar(10)
	DECLARE @Location2  varchar(10)
	DECLARE @Subsystem3 varchar(10)
	DECLARE @Location3  varchar(10)
	DECLARE @Subsystem4 varchar(10)
	DECLARE @Location4  varchar(10)
	DECLARE @Subsystem5 varchar(10)
	DECLARE @Location5  varchar(10)
	
	SELECT @Location1 = DESTINATION1, @Subsystem1 = SUBSYSTEM1,
		   @Location2 = DESTINATION2, @Subsystem2 = SUBSYSTEM2,
		   @Location3 = DESTINATION3, @Subsystem3 = SUBSYSTEM3,
		   @Location4 = DESTINATION4, @Subsystem4 = SUBSYSTEM4 
		   FROM BAG_INFO WHERE GID = @GID
		   
	IF (@Location1 IS NULL AND @Subsystem1 IS NULL)
	BEGIN
		UPDATE BAG_INFO SET SUBSYSTEM1 = @SubSystem, DESTINATION1 = @Location, LAST_LOCATION = @Location, TIME_STAMP = GETDATE()
		WHERE GID = @GID
	END
	ELSE IF (@Location2 IS NULL AND @Subsystem2 IS NULL) 
	BEGIN
		UPDATE BAG_INFO SET SUBSYSTEM2 = @SubSystem, DESTINATION2 = @Location, LAST_LOCATION = @Location, TIME_STAMP = GETDATE()
		WHERE GID = @GID
	END
	ELSE IF (@Location3 IS NULL AND @Subsystem3 IS NULL) 
	BEGIN
		UPDATE BAG_INFO SET SUBSYSTEM3 = @SubSystem, DESTINATION3 = @Location, LAST_LOCATION = @Location, TIME_STAMP = GETDATE()
		WHERE GID = @GID
	END
	ELSE IF (@Location4 IS NULL AND @Subsystem4 IS NULL)
	BEGIN
		UPDATE BAG_INFO SET SUBSYSTEM4 = @SubSystem, DESTINATION4 = @Location, LAST_LOCATION = @Location, TIME_STAMP = GETDATE()
		WHERE GID = @GID
	END
	ELSE
	BEGIN
		UPDATE BAG_INFO SET SUBSYSTEM5 = @SubSystem, DESTINATION5 = @Location, LAST_LOCATION = @Location, TIME_STAMP = GETDATE()
		WHERE GID = @GID
	END
	
	IF (@Screening_Level = '1')
	BEGIN
		UPDATE BAG_INFO SET HBS1_RESULT = @Screening_Status, CURRENT_LEVEL = @Screening_Level, CURRENT_STATUS = @Screening_Status
		WHERE GID = @GID
	END
	ELSE IF (@Screening_Level = '2')
	BEGIN
		UPDATE BAG_INFO SET HBS2_RESULT = @Screening_Status, CURRENT_LEVEL = @Screening_Level, CURRENT_STATUS = @Screening_Status
		WHERE GID = @GID
	END
	ELSE IF (@Screening_Level = '3')
	BEGIN
		UPDATE BAG_INFO SET HBS3_RESULT = @Screening_Status, CURRENT_LEVEL = @Screening_Level, CURRENT_STATUS = @Screening_Status
		WHERE GID = @GID
	END
	ELSE IF (@Screening_Level = '4')
	BEGIN
		UPDATE BAG_INFO SET HBS4_RESULT = @Screening_Status, CURRENT_LEVEL = @Screening_Level, CURRENT_STATUS = @Screening_Status
		WHERE GID = @GID
	END


	INSERT INTO [ITEM_READY]([TIME_STAMP],[GID],[SUBSYSTEM],[LOCATION],[SCREENING_LEVEL],[SCREENING_STATUS],[MODE],[BAG_NUMBER])
	VALUES (GETDATE(), @GID, @SUBSYSTEM, @LOCATION, @SCREENING_LEVEL, @SCREENING_STATUS, @MODE, @BAG_NUMBER)
	
	
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_ITEM_REMOVED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_ITEM_REMOVED]
	@GID varchar(10), 
	@LICENSE_PLATE varchar(10), 
	@SUBSYSTEM varchar(10), 
	@LOCATION varchar(20)
AS
BEGIN
	 INSERT INTO ITEM_REMOVED(TIME_STAMP,GID, LICENSE_PLATE, SUBSYSTEM, LOCATION)
	 VALUES(GETDATE(),@GID, @LICENSE_PLATE, @SUBSYSTEM, @LOCATION)
	 
	DECLARE @Subsystem1 varchar(10)
	DECLARE @Location1  varchar(10)
	DECLARE @Subsystem2 varchar(10)
	DECLARE @Location2  varchar(10)
	DECLARE @Subsystem3 varchar(10)
	DECLARE @Location3  varchar(10)
	DECLARE @Subsystem4 varchar(10)
	DECLARE @Location4  varchar(10)
	DECLARE @Subsystem5 varchar(10)
	DECLARE @Location5  varchar(10)
	
	SELECT @Location1 = DESTINATION1, @Subsystem1 = SUBSYSTEM1,
		   @Location2 = DESTINATION2, @Subsystem2 = SUBSYSTEM2,
		   @Location3 = DESTINATION3, @Subsystem3 = SUBSYSTEM3,
		   @Location4 = DESTINATION4, @Subsystem4 = SUBSYSTEM4 
		   FROM BAG_INFO WHERE GID = @GID

	UPDATE BAG_INFO SET LICENSE_PLATE = @LICENSE_PLATE WHERE GID = @GID
		   
	IF (@Location1 IS NULL AND @Subsystem1 IS NULL)
	BEGIN
		UPDATE BAG_INFO SET SUBSYSTEM1 = @SUBSYSTEM, DESTINATION1 = @LOCATION, LAST_LOCATION = @LOCATION, TIME_STAMP = GETDATE(), REMOVED = 1
		WHERE GID = @GID
	END
	ELSE IF (@Location2 IS NULL AND @Subsystem2 IS NULL) 
	BEGIN
		UPDATE BAG_INFO SET SUBSYSTEM2 = @SUBSYSTEM, DESTINATION2 = @LOCATION, LAST_LOCATION = @LOCATION, TIME_STAMP = GETDATE(), REMOVED = 1
		WHERE GID = @GID
	END
	ELSE IF (@Location3 IS NULL AND @Subsystem3 IS NULL)
	BEGIN
		UPDATE BAG_INFO SET SUBSYSTEM3 = @SUBSYSTEM, DESTINATION3 = @LOCATION, LAST_LOCATION = @LOCATION, TIME_STAMP = GETDATE(), REMOVED = 1
		WHERE GID = @GID
	END
	ELSE IF (@Location4 IS NULL AND @Subsystem4 IS NULL)
	BEGIN
		UPDATE BAG_INFO SET SUBSYSTEM4 = @SUBSYSTEM, DESTINATION4 = @LOCATION, LAST_LOCATION = @LOCATION, TIME_STAMP = GETDATE(), REMOVED = 1
		WHERE GID = @GID
	END
	ELSE
	BEGIN
		UPDATE BAG_INFO SET SUBSYSTEM5 = @SUBSYSTEM, DESTINATION5 = @LOCATION, LAST_LOCATION = @LOCATION, TIME_STAMP = GETDATE(), REMOVED = 1
		WHERE GID = @GID
	END
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_MES_EVENT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_MES_EVENT] 
	@TIME_STAMP datetime, 
	@GID varchar(10), 
	@LICENSE_PLATE varchar(10), 
	@SUBSYSTEM varchar(10), 
	@LOCATION varchar(10), 
	@ACTION varchar(10), 
	@ACTION_DESC varchar(25), 
	@MES_STATION varchar(16)
AS
BEGIN
	INSERT INTO MES_EVENT([TIME_STAMP], [GID], [LICENSE_PLATE], [SUBSYSTEM], 
		[LOCATION], [ACTION], [ACTION_DESC], [MES_STATION])
	VALUES(@TIME_STAMP, @GID, @LICENSE_PLATE, @SUBSYSTEM, @LOCATION, 
		@ACTION, @ACTION_DESC, @MES_STATION)
END


GO
/****** Object:  StoredProcedure [dbo].[stp_MES_UPDATE_BAG_INFO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Albert Sun
-- Create date: 16-Sep-2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_MES_UPDATE_BAG_INFO]
	@GID VARCHAR(10),
	@INDEX_NO VARCHAR(10),
	@LICENSE_PLATE VARCHAR(10),
	@LAST_LOCATION VARCHAR(10),
	@CUR_LOCATION VARCHAR(10),
	@SUB_SYSTEM VARCHAR(10),
	@REMOVED BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @lGID VARCHAR(10)
	DECLARE @lINDEX_NO VARCHAR(10)
	DECLARE @lLICENSE_PLATE VARCHAR(10)
	DECLARE @REASON_ID VARCHAR(2)
	DECLARE @REASON_DESC VARCHAR(50)

	SELECT @lGID = GID , @lLICENSE_PLATE = LICENSE_PLATE, @REASON_ID = SORT_REASON FROM BAG_INFO
	WHERE GID = @GID 

	IF ISNULL(@lGID, '-') = '-'
	BEGIN
		SELECT @lGID = @GID , @lINDEX_NO = @INDEX_NO, @lLICENSE_PLATE = @LICENSE_PLATE
		
		INSERT INTO BAG_INFO(TIME_STAMP, GID, LICENSE_PLATE, LAST_LOCATION, SUBSYSTEM1, DESTINATION1, DISCHARGED, REMOVED, CREATED_BY)
		VALUES(GETDATE(), @GID, @LICENSE_PLATE, @LAST_LOCATION,@SUB_SYSTEM,@CUR_LOCATION,0,@REMOVED,'BHS')
		
	END
	ELSE
	BEGIN
		UPDATE BAG_INFO SET LAST_LOCATION = @LAST_LOCATION, SUBSYSTEM1 = @SUB_SYSTEM, 
		     DESTINATION1 = @CUR_LOCATION, CREATED_BY = 'BHS', TIME_STAMP = GETDATE()
		WHERE GID = @GID
	END

	--SELECT @REASON_DESC = [DESCRIPTION] FROM SORTATION_REASON WHERE REASON = @REASON_ID

	SELECT @lGID, @lLICENSE_PLATE, @INDEX_NO, @REASON_ID, @REASON_DESC
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_AllocInfoCombine]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_AllocInfoCombine]
		  @ALLOCINFO_TABLE AS ALLOCINFO_TABLETYPE readonly
		  --@COMMBINFO_TABLE AS ALLOCCOMINFO_TABLETYPE OUTPUT readonly 
AS
BEGIN
	PRINT 'HELLO';
	
	CREATE TABLE #AI_COMBINEINFO_TEMP
	( 
		AIRLINE varchar(3),
		FLIGHT_NUMBER varchar(5),
		SDO datetime,
		COMBINEINFO VARCHAR(200)
	);
	
	INSERT INTO #AI_COMBINEINFO_TEMP
	SELECT DISTINCT AIRLINE, FLIGHT_NUMBER, SDO, '' AS COMBINEINFO
	FROM @ALLOCINFO_TABLE;
	
	DECLARE @AIRLINE VARCHAR(3);
	DECLARE @FLIGHTNUM VARCHAR(5);
	DECLARE @SDO DATETIME;
	DECLARE @INFO_TABLE TABLE(ALLOCINFO VARCHAR(MAX)); --table variable for tempary allocation data
	
	DECLARE GROUP_CUROR CURSOR FOR SELECT AIRLINE,FLIGHT_NUMBER,SDO  FROM #AI_COMBINEINFO_TEMP;
	OPEN GROUP_CUROR;
	
	FETCH NEXT FROM GROUP_CUROR INTO @AIRLINE,@FLIGHTNUM,@SDO;
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DECLARE @INDIVIDUAL_INFO VARCHAR(10);
		DECLARE @COMMBINE_INFO VARCHAR(MAX)='';
		
		INSERT INTO @INFO_TABLE(ALLOCINFO) 
		SELECT DISTINCT ALI.ALLOCINFO 
		FROM @ALLOCINFO_TABLE ALI 
		WHERE (ALI.AIRLINE=@AIRLINE AND ALI.FLIGHT_NUMBER=@FLIGHTNUM AND ALI.SDO=@SDO) ORDER BY ALI.ALLOCINFO
		
		DECLARE INFO_CURSOR CURSOR FOR SELECT ALLOCINFO FROM @INFO_TABLE;
		OPEN INFO_CURSOR
		
		FETCH NEXT FROM INFO_CURSOR INTO @INDIVIDUAL_INFO;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF (@INDIVIDUAL_INFO='' OR @INDIVIDUAL_INFO IS NULL)
			BEGIN
				Set @COMMBINE_INFO = @COMMBINE_INFO
			END
			ELSE
			BEGIN
				Set @COMMBINE_INFO = @COMMBINE_INFO + @INDIVIDUAL_INFO + ',';
				FETCH NEXT FROM INFO_CURSOR INTO @INDIVIDUAL_INFO;
			END
		END
		
		Set @COMMBINE_INFO = SUBSTRING(@COMMBINE_INFO,1,LEN(@COMMBINE_INFO)- 1);  --Remove the last 1 comma
		
		CLOSE INFO_CURSOR;
		DEALLOCATE INFO_CURSOR;
		DELETE @INFO_TABLE; --Empty the table variable
							
		UPDATE #AI_COMBINEINFO_TEMP SET COMBINEINFO=@COMMBINE_INFO 
		WHERE AIRLINE=@AIRLINE AND FLIGHT_NUMBER=@FLIGHTNUM AND SDO=@SDO

		FETCH NEXT FROM GROUP_CUROR INTO @AIRLINE,@FLIGHTNUM,@SDO;
	END
	
	CLOSE GROUP_CUROR;
	DEALLOCATE GROUP_CUROR;
	

	SELECT * FROM #AI_COMBINEINFO_TEMP
END
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_AVERAGEBAGINSYSTEMTIME]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [stp_RPT_AVERAGEBAGINSYSTEMTIME] '2012-12-12 00:00:00.000', '2012-12-12 11:00:00:000', 120

CREATE PROCEDURE [dbo].[stp_RPT_AVERAGEBAGINSYSTEMTIME] 
	@DTFrom datetime,
	@DTTo datetime,
    @IntervalMin int
AS
BEGIN     
		DECLARE @Counter int
		SET @Counter = 1
		DECLARE @TimeStart DATETIME
		DECLARE @TimeEnd DATETIME
	    DECLARE @interval int
		DECLARE @start_point datetime
		DECLARE @end_point datetime

		IF @IntervalMin < 5
		BEGIN
			SET @interval = 5
		END
		ELSE
		BEGIN
			SET @interval =  @IntervalMin
		END 
		
        SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
		SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

		IF datediff(d, @start_point, @end_point) > 365 
		BEGIN
			SET @end_point =  DATEADD(d,365,@start_point)
		END

		DECLARE @TotalCount INT
		SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))

		DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int,origin_max varchar(10), origin_min varchar(10), origin_avg varchar(10), transfer_max varchar(10), transfer_min varchar(10), transfer_avg varchar(10))  

		DECLARE @origin_max_int int, @origin_min_int int, @origin_avg_int int, @transfer_max_int int, @transfer_min_int int, @transfer_avg_int int 

		WHILE (@Counter <= @TotalCount)
		BEGIN
			SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
			SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
			select @origin_max_int = max(interval), @origin_min_int = case when min(interval)<0 then 0 else min(interval)end from(select MAX(A.TIME_STAMP) as time_from, MAX(B.TIME_STAMP) as time_to, A.GID, DATEDIFF(SECOND,MAX(A.TIME_STAMP),MAX(B.TIME_STAMP)) as interval
			from ITEM_SCREENED A left join ITEM_PROCEEDED B on A.GID = B.GID where (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and A.LOCATION not like '%TX%' group by A.GID) A
			set @origin_avg_int = (@origin_max_int + @origin_min_int) / 2
			
			select @transfer_max_int = max(interval), @transfer_min_int = case when min(interval)<0 then 0 else min(interval)end from(select MAX(A.TIME_STAMP) as time_from, MAX(B.TIME_STAMP) as time_to, A.GID, DATEDIFF(SECOND,MAX(A.TIME_STAMP),MAX(B.TIME_STAMP)) as interval
			from ITEM_SCREENED A left join ITEM_PROCEEDED B on A.GID = B.GID where (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and A.LOCATION like '%TX%' group by A.GID) A
			set @transfer_avg_int = (@transfer_max_int + @transfer_min_int) / 2
			
			INSERT INTO @temptable (start_time,end_time,Interval,origin_max, origin_min, origin_avg, transfer_max, transfer_min, transfer_avg) values 
			(@TimeStart,@TimeEnd,(@Counter *@interval),
			ISNULL('00:'+ RIGHT('0'+CONVERT(varchar(2),@origin_max_int/60,2),2)+ ':' +RIGHT('0'+CONVERT(varchar(2),@origin_max_int%60,2),2),'00:00:00'),
			ISNULL('00:'+ RIGHT('0'+CONVERT(varchar(2),@origin_min_int/60,2),2)+ ':' +RIGHT('0'+CONVERT(varchar(2),@origin_min_int%60,2),2),'00:00:00'),
			ISNULL('00:'+ RIGHT('0'+CONVERT(varchar(2),@origin_avg_int/60,2),2)+ ':' +RIGHT('0'+CONVERT(varchar(2),@origin_avg_int%60,2),2),'00:00:00'),
			ISNULL('00:'+ RIGHT('0'+CONVERT(varchar(2),@transfer_max_int/60,2),2)+ ':' +RIGHT('0'+CONVERT(varchar(2),@transfer_max_int%60,2),2),'00:00:00'),
			ISNULL('00:'+ RIGHT('0'+CONVERT(varchar(2),@transfer_min_int/60,2),2)+ ':' +RIGHT('0'+CONVERT(varchar(2),@transfer_min_int%60,2),2),'00:00:00'),
			ISNULL('00:'+ RIGHT('0'+CONVERT(varchar(2),@transfer_avg_int/60,2),2)+ ':' +RIGHT('0'+CONVERT(varchar(2),@transfer_avg_int%60,2),2),'00:00:00'))
			SET @Counter  = (@Counter + 1)
		End

		SELECT * FROM @temptable
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_ATR_HEAD_STATISTIC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_ATR_HEAD_STATISTIC]
		  @DTFROM datetime , 
		  @DTTO datetime, 
		  @ATRUNIT varchar(20)
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;

	SELECT ISC.*,LOC.LOCATION AS ATRUNIT INTO #ATR_ATRDETAIL_TEMP
	FROM ITEM_SCANNED ISC, LOCATIONS LOC WITH(NOLOCK)
	WHERE ISC.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		AND ISC.LOCATION=LOC.LOCATION_ID AND LOC.LOCATION=@ATRUNIT;

	SELECT	aat.ATRUNIT, 
			COUNT(aat.ID) AS TOTAL_READ,
			SUM(aat.HEAD01) AS READ_HEAD01, CAST(SUM(aat.HEAD01) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ01,
			SUM(aat.HEAD02) AS READ_HEAD02, CAST(SUM(aat.HEAD02) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ02,
			SUM(aat.HEAD03) AS READ_HEAD03, CAST(SUM(aat.HEAD03) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ03 ,
			SUM(aat.HEAD04) AS READ_HEAD04, CAST(SUM(aat.HEAD04) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ04,
			SUM(aat.HEAD05) AS READ_HEAD05, CAST(SUM(aat.HEAD05) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ05,
			SUM(aat.HEAD06) AS READ_HEAD06, CAST(SUM(aat.HEAD06) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ06,
			SUM(aat.HEAD07) AS READ_HEAD07, CAST(SUM(aat.HEAD07) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ07,
			SUM(aat.HEAD08) AS READ_HEAD08, CAST(SUM(aat.HEAD08) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ08,
			SUM(aat.HEAD09) AS READ_HEAD09, CAST(SUM(aat.HEAD09) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ09,
			SUM(aat.HEAD10) AS READ_HEAD10, CAST(SUM(aat.HEAD10) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ10,
			SUM(aat.HEAD11) AS READ_HEAD11, CAST(SUM(aat.HEAD11) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ11,
			SUM(aat.HEAD12) AS READ_HEAD12, CAST(SUM(aat.HEAD12) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ12,
			SUM(aat.HEAD13) AS READ_HEAD13, CAST(SUM(aat.HEAD13) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ13,
			SUM(aat.HEAD14) AS READ_HEAD14, CAST(SUM(aat.HEAD14) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ14,
			SUM(aat.HEAD15) AS READ_HEAD15, CAST(SUM(aat.HEAD15) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ15,
			SUM(aat.HEAD16) AS READ_HEAD16, CAST(SUM(aat.HEAD16) AS FLOAT)/CAST(COUNT(aat.ID) AS FLOAT) AS RATE_READ16
	FROM #ATR_ATRDETAIL_TEMP aat
	GROUP BY aat.ATRUNIT;


END

--DECLARE @DTFROM datetime='2013-12-29'; 
--DECLARE @DTTO datetime='2013-12-31';
--DECLARE @ATRUNIT varchar(20)='SS1-2';
--EXEC stp_RPT12_ATR_HEAD_STATISTIC_GWYTEST @DTFROM,@DTTO,@ATRUNIT;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_ATR_OVERALL_STATISTIC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_ATR_OVERALL_STATISTIC]
		  @DTFROM datetime , 
		  @DTTO datetime, 
		  @ATRUNITS varchar(MAX)
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;

	--1. Prepare ITEM_SCANNED detail data
	SELECT	ISC.*,LOC.LOCATION AS ATRUNIT, 0 AS LATE_MARK 
	INTO	#ATR_ATRDETAIL_TEMP
	FROM	ITEM_SCANNED ISC, 
			LOCATIONS LOC WITH(NOLOCK)
	WHERE ISC.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		AND ISC.LOCATION=LOC.LOCATION_ID 
		AND LOC.LOCATION IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@ATRUNITS));

	CREATE TABLE #ATR_STATISTIC_TEMP
	(
		ATRUNIT VARCHAR(20),
		COUNT_BAGSSEEN INT,
		COUNT_BAGSREAD INT,
		COUNT_NOREAD INT,
		COUNT_VALIDTAGS INT,
		COUNT_CONFLICT_TAGS INT,
		COUNT_NOBSM INT,
		COUNT_LATEBAGS INT,
		READ_RATE FLOAT
	);

	INSERT INTO #ATR_STATISTIC_TEMP 
	SELECT DISTINCT AAT.ATRUNIT, 0, 0, 0, 0, 0, 0, 0, 0
	FROM #ATR_ATRDETAIL_TEMP AAT

	--1. BAGS SEEN
	UPDATE AST
	SET AST.COUNT_BAGSSEEN=AAT.CNT_BAGSEEN
	FROM (
			SELECT AAT.ATRUNIT, COUNT(AAT.GID) AS CNT_BAGSEEN
			FROM #ATR_ATRDETAIL_TEMP AAT
			GROUP BY AAT.ATRUNIT
		 ) AS AAT, #ATR_STATISTIC_TEMP AST
	WHERE AAT.ATRUNIT=AST.ATRUNIT;

	--2. BAGS READ
	UPDATE AST
	SET AST.COUNT_BAGSREAD=AAT.CNT_BAGREAD
	FROM (
			SELECT AAT.ATRUNIT, COUNT(GID) AS CNT_BAGREAD
			FROM #ATR_ATRDETAIL_TEMP AAT
			WHERE (AAT.STATUS_TYPE='1'	--Read ok. Single Tag
				OR AAT.STATUS_TYPE='3'	--Read ok. Multiple tags with different Tag Type
				OR AAT.STATUS_TYPE='7'	--Read ok. Multiple tags with same Tag Type
				OR AAT.STATUS_TYPE='8')	--Read ok. Multiple tags with more than 3 tag
			GROUP BY AAT.ATRUNIT
		 ) AS AAT, #ATR_STATISTIC_TEMP AST
	WHERE AAT.ATRUNIT=AST.ATRUNIT;

	--3. NO READS
	UPDATE #ATR_STATISTIC_TEMP
	SET COUNT_NOREAD=COUNT_BAGSSEEN-COUNT_BAGSREAD;

	--4. VALID TAGS
	SELECT AAT.ATRUNIT,
		CASE AAT.STATUS_TYPE
			WHEN '1' THEN 1 --Read ok. Single Tag
			WHEN '3' THEN 2 --Read ok. Multiple tags with different Tag Type
			ELSE 0
		END AS NUM_VALIDTAGS
	INTO #ATR_NUM_VALIDTAGS
	FROM #ATR_ATRDETAIL_TEMP AAT;

	UPDATE AST
	SET AST.COUNT_VALIDTAGS=AAT.CNT_VALIDTAGS
	FROM (
			SELECT ANV.ATRUNIT,SUM(ANV.NUM_VALIDTAGS) AS CNT_VALIDTAGS
			FROM #ATR_NUM_VALIDTAGS ANV
			GROUP BY ANV.ATRUNIT
		  )AS AAT, #ATR_STATISTIC_TEMP AST
	WHERE AAT.ATRUNIT=AST.ATRUNIT;

	--5. CONFLICT TAGS
	UPDATE AST
	SET AST.COUNT_CONFLICT_TAGS=AAT.CNT_CONFLICTTAGS
	FROM (
			SELECT AAT.ATRUNIT,COUNT(GID)*2 AS CNT_CONFLICTTAGS
			FROM #ATR_ATRDETAIL_TEMP AAT
			WHERE AAT.STATUS_TYPE='7'
			GROUP BY AAT.ATRUNIT
		 ) AS AAT, #ATR_STATISTIC_TEMP AST
	WHERE AAT.ATRUNIT=AST.ATRUNIT;

	--6. NO MATCHING BSM
	SELECT DISTINCT LICENSE_PLATE,AIRLINE,FLIGHT_NUMBER,SDO INTO #ATR_BAG_SORTING_TEMP
	FROM 
	(
		SELECT LICENSE_PLATE,AIRLINE,FLIGHT_NUMBER,SDO
		FROM BAG_SORTING WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
			
		UNION ALL
		SELECT LICENSE_PLATE,AIRLINE,FLIGHT_NUMBER,SDO
		FROM BAG_SORTING_HIS WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
	) AS BAG_SORTING_ALL ;

	UPDATE AST
	SET AST.COUNT_NOBSM=AAT.CNT_NOBSM
	FROM (
			SELECT AAT1.ATRUNIT,COUNT(GID) AS CNT_NOBSM
			FROM #ATR_ATRDETAIL_TEMP AAT1
			WHERE NOT EXISTS (SELECT * FROM #ATR_BAG_SORTING_TEMP ABSG WHERE AAT1.LICENSE_PLATE1=ABSG.LICENSE_PLATE)
				AND NOT EXISTS (SELECT * FROM #ATR_BAG_SORTING_TEMP ABSG WHERE AAT1.LICENSE_PLATE2=ABSG.LICENSE_PLATE)
			GROUP BY AAT1.ATRUNIT
		 ) AS AAT, #ATR_STATISTIC_TEMP AST
	WHERE AAT.ATRUNIT=AST.ATRUNIT;

	--7. READ RATE
	UPDATE AST
	SET AST.READ_RATE=CAST(AST.COUNT_BAGSREAD AS FLOAT)/CAST(AST.COUNT_BAGSSEEN AS FLOAT)*100
	FROM #ATR_STATISTIC_TEMP AST

	--UPDATE AST
	--SET AST.READ_RATE=ARR.READRATE
	--FROM (
	--		SELECT AST.ATRUNIT,CAST(COUNT(ANV.NUM_VALIDTAGS) AS FLOAT)/CAST(AST.COUNT_BAGSSEEN AS FLOAT) AS READRATE
	--		FROM #ATR_STATISTIC_TEMP AST, #ATR_NUM_VALIDTAGS ANV
	--		WHERE AST.ATRUNIT=ANV.ATRUNIT
	--	 ) AS ARR,#ATR_STATISTIC_TEMP AST
	--WHERE ARR.ATRUNIT=AST.ATRUNIT;

	

	--8 Mark the bag which is late(ISC timestamp is after close time)
	UPDATE AAT
	SET AAT.LATE_MARK=1
	FROM #ATR_ATRDETAIL_TEMP AAT, #ATR_BAG_SORTING_TEMP BS, FLIGHT_PLAN_ALLOC FPA WITH(NOLOCK)
	WHERE (AAT.LICENSE_PLATE1=BS.LICENSE_PLATE OR AAT.LICENSE_PLATE2=BS.LICENSE_PLATE)
		AND BS.AIRLINE=FPA.AIRLINE AND BS.FLIGHT_NUMBER=FPA.FLIGHT_NUMBER AND BS.SDO=FPA.SDO
		AND AAT.TIME_STAMP >=
				(	CASE FPA.ALLOC_CLOSE_RELATED
						WHEN 'ETD' 
							--THEN CONVERT(DATETIME,CONVERT(VARCHAR,FPA.EDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(dbo.SAC_OFFSETOPERATOR(FPA.ETO,FPA.ALLOC_CLOSE_OFFSET)),103)
							THEN DBO.RPT_TIME_CAL(FPA.EDO,FPA.ETO,FPA.ALLOC_CLOSE_OFFSET)
						ELSE 
							--CONVERT(DATETIME,CONVERT(VARCHAR,FPA.SDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(dbo.SAC_OFFSETOPERATOR(FPA.STO,FPA.ALLOC_CLOSE_OFFSET)),103)
							DBO.RPT_TIME_CAL(FPA.SDO,FPA.STO,FPA.ALLOC_CLOSE_OFFSET)
					END
				)--CLOASE TIME
		AND EXISTS(	
					SELECT AAT.ATRUNIT FROM MIS_SubsystemCatalog MSC 
					WHERE AAT.ATRUNIT=MSC.DETECT_LOCATION 
						AND MSC.SUBSYSTEM_TYPE='ATR' 
						AND MSC.SUBSYSTEM LIKE 'ML%'
				  )

	--9 Count the number of late bags 
	UPDATE AST
	SET AST.COUNT_LATEBAGS=ALB.CNT_LATEBAGS
	FROM (
			SELECT AAT.ATRUNIT,COUNT(GID) AS CNT_LATEBAGS
			FROM #ATR_ATRDETAIL_TEMP AAT
			WHERE AAT.LATE_MARK=1
			GROUP BY AAT.ATRUNIT
		 ) AS ALB, #ATR_STATISTIC_TEMP AST
	WHERE ALB.ATRUNIT=AST.ATRUNIT;


	select * from #ATR_STATISTIC_TEMP;
END

--DECLARE @DTFROM datetime='2014/1/3 17:43:03'; 
--DECLARE @DTTO datetime='2014/1/3 18:30:04';
--DECLARE @ATRUNIT varchar(MAX)='ML1-2';
--EXEC stp_RPT12_ATR_OVERALL_STATISTIC_GWYTEST @DTFROM,@DTTO,@ATRUNIT;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_BagData]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[stp_RPT_CLT_BagData]
		  @DTFROM datetime,
		  @DTTO datetime
AS
BEGIN
--Problem1: 1500P time stamp is not the removed time
--Problem2: What is the location name of CBRA in IPR proceed location
--Problem3: Cannot get the oog identified time

	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;
	DECLARE @MINUTERANGE INT=60;

	--Create temp table for final result
	CREATE TABLE #BD_BAGDATA_TEMP 
	(
		GID bigint,		
		BMAM_BAG_TYPE varchar(15),
		EDS_SN varchar(50),
		ENTER_TIMESTAMP datetime,

		LEVEL1_SCREEN_STATUS varchar(1),
		LEVEL1_SCREENED_TIME datetime,
		LEVEL2_SCREEN_STATUS varchar(1),
		LEVEL2_SCREENED_TIME datetime,

		EDS_CLEARTIME DATETIME,
		EDS_CLEARLOCATION VARCHAR(20),

		CBRA_DELIVERED_TIME datetime,
		CBRA_REMOVED_TIME datetime,
		CBRA_ETDSTATION# varchar(50)
	);

	---------------#REGION 1 FOR IN-SPEC(NORMAL) BAGGAGES
	--1. Query baggage measure info into final table
	--DECLARE @NEW_SCREEN_DATE datetime=CONVERT(datetime,CONVERT(varchar,@SCREEN_DATE,103),103);

	-------------------------------------Commented by Guo Wenyu 2014/1/4-------------------------------------
	--Because some bags are lost during moving, so the GID from GID_USED should be used as the index in the report
	--INSERT INTO #BD_BAGDATA_TEMP
	--SELECT DISTINCT im.GID,
	--	   'In-Spec' AS BMAM_BAG_TYPE,
	--	   NULL AS EDS_SN, 
	--	   NULL AS ENTER_TIMESTAMP, 
	--	   NULL AS LEVEL1_SCREEN_STATUS, 
	--	   NULL AS LEVEL1_SCREENED_TIME, 
	--	   NULL AS LEVEL2_SCREEN_STATUS, 
	--	   NULL AS LEVEL2_SCREENED_TIME, 
	--	   NULL AS CBRA_DELIVERED_TIME, 
	--	   NULL AS CBRA_REMOVED_TIME,
	--	   NULL AS CBRA_ETDSTATION#
	--FROM ITEM_MEASURED im WITH(NOLOCK)
	--WHERE im.TIME_STAMP BETWEEN @DTFROM AND @DTTO
	--	AND IM.TYPE='2'; --'in-Spec'NORMAL BAG
	-------------------------------------New Code added by Guo Wenyu 2014/1/4-------------------------------------
	INSERT INTO #BD_BAGDATA_TEMP
	SELECT DISTINCT GID.GID, 
		   CASE 
			   WHEN IM.TYPE='2' THEN 'In-Spec'
			   WHEN IM.TYPE='1' THEN 'OOG'
			   WHEN IM.TYPE IS NULL THEN ''
			   ELSE ''
		   END as BMAM_BAG_TYPE,
		   NULL AS EDS_SN, 
		   NULL AS ENTER_TIMESTAMP, 
		   NULL AS LEVEL1_SCREEN_STATUS, 
		   NULL AS LEVEL1_SCREENED_TIME, 
		   NULL AS LEVEL2_SCREEN_STATUS, 
		   NULL AS LEVEL2_SCREENED_TIME, 
		   NULL AS EDS_CLEARTIME,
		   NULL AS EDS_CLEARLOCATION,
		   NULL AS CBRA_DELIVERED_TIME, 
		   NULL AS CBRA_REMOVED_TIME,
		   NULL AS CBRA_ETDSTATION#
	FROM LOCATIONS LOC,GID_USED GID WITH(NOLOCK)
	LEFT JOIN ITEM_MEASURED IM WITH(NOLOCK) 
		ON GID.GID=IM.GID
		AND IM.TIME_STAMP BETWEEN @DTFROM AND @DTTO
	WHERE GID.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		AND GID.LOCATION=LOC.LOCATION_ID
		AND (LOC.LOCATION LIKE 'SS%' OR LOC.LOCATION LIKE 'ED%' OR LOC.LOCATION LIKE 'OOG%' OR LOC.LOCATION LIKE 'SB%')
		AND (LOC.LOCATION <> 'OOG1-5' AND LOC.LOCATION <> 'OOG2-4');
	-------------------------------------END by Guo Wenyu 2014/1/4 END-------------------------------------

	--select * from #BD_BAGDATA_TEMP where gid='3223000423';

	CREATE NONCLUSTERED INDEX #BD_BAGDATA_TEMP_GID ON #BD_BAGDATA_TEMP(GID);

	--2. Update the time(ENTER_TIMESTAMP) when the bags entering into the EDS machine
	UPDATE BBT
	SET BBT.ENTER_TIMESTAMP=ITI.TIME_STAMP
	FROM #BD_BAGDATA_TEMP BBT, ITEM_TRACKING ITI, LOCATIONS LOC  WITH(NOLOCK)
	WHERE BBT.GID=ITI.GID
		AND ITI.LOCATION=LOC.LOCATION_ID
		AND  EXISTS(
					SELECT ELD.POST_XM_LOCATION 
					FROM GET_RPT_EDS_LINE_DEVICE() ELD
					WHERE ELD.SUBSYSTEM=LOC.SUBSYSTEM AND ELD.PRE_XM_LOCATION=LOC.LOCATION 
				  )
		AND ITI.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)

	--3. Query screen info into a tempary table #EI_ITEM_SCREENED_TEMP
	SELECT icr.GID, icr.SCREEN_LEVEL, ICR.LOCATION, icr.TIME_STAMP, icr.RESULT_TYPE INTO #EI_ITEM_SCREENED_TEMP
	FROM ITEM_SCREENED icr, LOCATIONS loc, #BD_BAGDATA_TEMP BBT WITH(NOLOCK)
	WHERE BBT.GID=icr.GID
		AND (icr.SCREEN_LEVEL='1' OR icr.SCREEN_LEVEL='2' OR icr.SCREEN_LEVEL='3')
		AND icr.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
		AND icr.LOCATION=loc.LOCATION_ID;
		--AND BBT.BMAM_BAG_TYPE='in-Spec';


	--4. Update LEVE1 screen info(LEVEL1_SCREEN_STATUS,LEVEL1_SCREENED_TIME) into final table
	UPDATE BBT
	SET BBT.LEVEL1_SCREEN_STATUS=
				CASE 
					WHEN	ICR.RESULT_TYPE='21'
						 OR ICR.RESULT_TYPE='22'
						 OR ICR.RESULT_TYPE='23'
						 OR ICR.RESULT_TYPE='24'
						 OR ICR.RESULT_TYPE='25'
						 THEN 'A'
					ELSE 'R'
				END	, 
		BBT.LEVEL1_SCREENED_TIME=ITI.TIME_STAMP,
		BBT.EDS_SN=ESLM.EDS_SN,
		BBT.LEVEL2_SCREEN_STATUS=
				CASE 
					WHEN ICR.RESULT_TYPE='12' OR ICR.RESULT_TYPE='22' THEN 'A'
					ELSE 'R'
				END, 
		BBT.LEVEL2_SCREENED_TIME=ICR.TIME_STAMP
	FROM #EI_ITEM_SCREENED_TEMP ICR,LOCATIONS ICRLOC,MIS_EDS_SN2LOCATION_MAP ESLM,#BD_BAGDATA_TEMP BBT
	LEFT JOIN ITEM_TRACKING ITI WITH(NOLOCK)
		ON BBT.GID=ITI.GID 
		AND ITI.TIME_STAMP BETWEEN  DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
		AND EXISTS(
					SELECT ELD.POST_XM_LOCATION 
					FROM GET_RPT_EDS_LINE_DEVICE() ELD, LOCATIONS LOC
					WHERE ELD.SUBSYSTEM=LOC.SUBSYSTEM AND ELD.POST_XM_LOCATION=LOC.LOCATION 
						AND ITI.LOCATION=LOC.LOCATION_ID
				  )
	WHERE BBT.GID=icr.GID
		AND ICR.LOCATION=ICRLOC.LOCATION_ID
		AND ICRLOC.LOCATION=ESLM.LOCATION
		--AND icr.SCREEN_LEVEL='1';
		
		
	--5. Update EDS Clear Time AND EDS CLEAR LOCATION
	SELECT GID,PRDLOC,TIME_STAMP AS TIME_STAMP
	INTO #BD_RECENT_IPR_TEMP
	FROM (
			SELECT IPR.GID, ELD.CLEAR_LOCATION AS PRDLOC,IPR.TIME_STAMP
			FROM ITEM_PROCEEDED IPR,GET_RPT_EDS_LINE_DEVICE() ELD, LOCATIONS PRELOC WITH(NOLOCK)
			WHERE IPR.PROCEED_LOCATION=PRELOC.LOCATION_ID
				AND ELD.SUBSYSTEM=PRELOC.SUBSYSTEM
				AND ELD.CLEAR_LOCATION=PRELOC.LOCATION
				AND IPR.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
			UNION ALL
			SELECT IPR.GID, PRELOC.LOCATION AS PRDLOC, IPR.TIME_STAMP
			FROM ITEM_PROCEEDED IPR, LOCATIONS PRELOC WITH(NOLOCK)
			WHERE IPR.PROCEED_LOCATION=PRELOC.LOCATION_ID
				AND PRELOC.LOCATION IN ('OOG1-15B','OOG2-17B','ED9-33B')
				AND IPR.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
		) AS ALLIPR;

	UPDATE BBT
	SET BBT.EDS_CLEARTIME=IPR.TIME_STAMP,
		BBT.EDS_CLEARLOCATION = IPR.PRDLOC
	FROM #BD_BAGDATA_TEMP BBT
	LEFT JOIN #BD_RECENT_IPR_TEMP IPR
		ON BBT.GID=IPR.GID AND IPR.TIME_STAMP=(SELECT MAX(TIME_STAMP) FROM #BD_RECENT_IPR_TEMP IPR2 WHERE IPR2.GID=IPR.GID);
	
	--5. Update LEVE1 screen info(LEVEL2_SCREEN_STATUS,LEVEL2_SCREENED_TIME) into final table
	--UPDATE BBT
	--SET BBT.LEVEL2_SCREEN_STATUS=
	--			CASE 
	--				WHEN ICR.RESULT_TYPE='12' OR ICR.RESULT_TYPE='22' THEN 'A'
	--				ELSE 'R'
	--			END, 
	--	BBT.LEVEL2_SCREENED_TIME=ICR.TIME_STAMP
	--FROM #EI_ITEM_SCREENED_TEMP ICR, #BD_BAGDATA_TEMP BBT
	--WHERE BBT.GID=icr.GID 
	--	AND ICR.SCREEN_LEVEL='2';
	--------------------END #REGION 1 END----------------------

	---------------#REGION 2 FOR OOG BAGGAGES------------------
	
	--9. Insert OOG bags GID into final table from the oog lines
	INSERT INTO #BD_BAGDATA_TEMP
	SELECT
		   GID,
		   'OOG' AS BMAM_BAG_TYPE,
		   NULL AS EDS_SN, 
		   NULL AS ENTER_TIMESTAMP, 
		   NULL AS LEVEL1_SCREEN_STATUS, 
		   NULL AS LEVEL1_SCREENED_TIME, 
		   NULL AS LEVEL2_SCREEN_STATUS, 
		   NULL AS LEVEL2_SCREENED_TIME, 
		   NULL AS EDS_CLEARTIME,
		   NULL AS EDS_CLEARLOCATION,
		   NULL AS CBRA_DELIVERED_TIME, 
		   NULL AS CBRA_REMOVED_TIME,
		   NULL AS CBRA_ETDSTATION#
	FROM GID_USED GID, LOCATIONS LOC WITH(NOLOCK)
	WHERE GID.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		AND GID.LOCATION=LOC.LOCATION_ID
		AND (LOC.LOCATION = 'OOG1-5' OR LOC.LOCATION = 'OOG2-4');

	----11. Update OOG identified time
	----An oog bag cannot get the identified time from BMAM, because the GID is changed after oog line
	UPDATE BBT
	SET BBT.ENTER_TIMESTAMP=IM.TIME_STAMP
	FROM #BD_BAGDATA_TEMP BBT, ITEM_MEASURED IM, LOCATIONS LOC WITH(NOLOCK)
	WHERE BBT.GID=IM.GID
		AND BBT.BMAM_BAG_TYPE='OOG'
		AND IM.LOCATION=LOC.LOCATION_ID
		AND LOC.LOCATION IN ('SS1-2','SS2-2','SS3-2','SS4-2')
		AND IM.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)

	--------------------END #REGION 2 END----------------------

	--7. Update CBRA Delivered time(CBRA_DELIVERED_TIME) into final table
	UPDATE BBT
	SET BBT.CBRA_DELIVERED_TIME=ipr.TIME_STAMP
	FROM ITEM_PROCEEDED ipr, LOCATIONS loc, #BD_BAGDATA_TEMP BBT WITH(NOLOCK)
	WHERE ipr.GID=BBT.GID AND BBT.GID IS NOT NULL
		AND ipr.PROCEED_LOCATION=loc.LOCATION_ID 
		AND loc.SUBSYSTEM LIKE 'SB%'--Maybe another name
		--AND LOC.LOCATION IN ('','','','','')
		AND ipr.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)



	--8. Update CBRA Removed time and new GID(CBRA_REMOVED_TIME) into final table
	--some problem here
	--PROBLEM: Telegram 1500P is not sent when bags are removed, but before bags are moved to inspection tables.
	UPDATE BBT
	SET BBT.CBRA_REMOVED_TIME=i1500.TIME_STAMP,
		BBT.CBRA_ETDSTATION#='ETD STATION: ' + I1500.ETD_STATION
	FROM #BD_BAGDATA_TEMP BBT, ITEM_1500P i1500 WITH(NOLOCK)
	LEFT JOIN LOCATIONS LOC ON  i1500.LOCATION=LOC.LOCATION_ID
	--LEFT JOIN  MIS_CBRA_ETD#2LOCATION_MAP CELM ON LOC.LOCATION=CELM.LOCATION
	WHERE i1500.GID=BBT.GID
		AND i1500.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
	

	SELECT * FROM #BD_BAGDATA_TEMP
	ORDER BY ENTER_TIMESTAMP;
END

--declare @DTFROM datetime='2013-12-27';
--declare @DTTO datetime='2013-12-28';
--exec stp_RPT20_BagData_GWYTEST @DTFROM,@DTTO;

--SELECT * FROM ITEM_1500P WHERE GID='3110000515';
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_BAGNOTFOUND]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_BAGNOTFOUND]
		  @DTFROM datetime, 
		  @DTTO datetime
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;

	--1.Query the bags data from BSM into temp table #BNF_BAG_SORTING_TEMP
	SELECT DISTINCT LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE INTO #BNF_BAG_SORTING_TEMP
	FROM 
	(
		SELECT LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE
		FROM BAG_SORTING WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
		UNION ALL
		SELECT LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE
		FROM BAG_SORTING_HIS WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO) 
	) AS BAG_SORTING_ALL ;

	CREATE NONCLUSTERED INDEX #BNF_BAG_SORTING_TEMP_IDXLP ON #BNF_BAG_SORTING_TEMP(LICENSE_PLATE);

	--2.Query the bags INFO from BAG_INFO into temp table #BNF_BAG_INFO_TEMP
	SELECT DISTINCT GID,LOCATION AS LOCATION_SEEN,TIME_STAMP,LICENSE_PLATE1,LICENSE_PLATE2 INTO #BNF_BAG_INFO_TEMP
	FROM 
	(
		SELECT GID,LOC.LOCATION,TIME_STAMP,BI.LICENSE_PLATE1,BI.LICENSE_PLATE2
		FROM BAG_INFO BI, LOCATIONS LOC WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
			AND BI.LAST_LOCATION=LOC.LOCATION_ID
		UNION ALL
		SELECT GID,LOC.LOCATION,TIME_STAMP,BI.LICENSE_PLATE1,BI.LICENSE_PLATE2
		FROM BAG_INFO BI, LOCATIONS LOC  WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO) 
			AND BI.LAST_LOCATION=LOC.LOCATION_ID
	) AS BAG_INFO_ALL

	CREATE NONCLUSTERED INDEX ##BNF_BAG_INFO_TEMP_GIDXLP ON #BNF_BAG_INFO_TEMP(GID);
	--3. Query bag data in ITEM_REDIRECT with No flight or No allocation
	SELECT MAX(TIME_STAMP) AS TIME_STAMP, GID
	INTO #BNF_ITEM_REDIRECT_TEMP
	FROM ITEM_REDIRECT IRD WITH(NOLOCK)
	WHERE IRD.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		AND (IRD.REASON='11' OR IRD.REASON='13') --No flight or No allocation
		--AND IRD.DESTINATION_1<>'4500'
	GROUP BY GID;

	CREATE NONCLUSTERED INDEX #BNF_ITEM_REDIRECT_TEMP_IDXGID ON #BNF_ITEM_REDIRECT_TEMP(GID);

	--4.Query Bag BSM Data and Item Scanned Data for each not found baggage
	SELECT	BSG.AIRLINE AS CARRIER_ID, 
			BSG.LICENSE_PLATE AS TAG_NUMBER,
			BI.TIME_STAMP AS TIME_SEEN,
			BI.LOCATION_SEEN,
			(ISNULL(GIVEN_NAME,'')+' '+ISNULL(SURNAME,'')+' '+ISNULL(OTHERS_NAME,'')) AS PAX_NAME,
			(BSG.AIRLINE+BSG.FLIGHT_NUMBER) AS FLTNUM			
	FROM	#BNF_ITEM_REDIRECT_TEMP IRD
	--LEFT JOIN ITEM_SCANNED ISC WITH(NOLOCK) 
	--	ON	IRD.GID=ISC.GID 
	--	AND ISC.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
	LEFT JOIN #BNF_BAG_INFO_TEMP BI
		ON	IRD.GID=BI.GID 
	--INNER JOIN LOCATIONS LOC WITH(NOLOCK) ON ISC.LOCATION=LOC.LOCATION_ID
	LEFT JOIN #BNF_BAG_SORTING_TEMP BSG ON (BSG.LICENSE_PLATE=BI.LICENSE_PLATE1 OR BSG.LICENSE_PLATE=BI.LICENSE_PLATE2)

		--AND IRD.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
		--AND (IRD.REASON='11' OR IRD.REASON='13'); --No flight or No allocation

END

--DECLARE @DTFrom [datetime]='2013-12-19';
--DECLARE @DTTo [datetime]='2014-12-21';
--exec stp_RPT18_BAGNOTFOUND_GWYTEST @DTFrom,@DTTo;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_BAGTAG]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_BAGTAG]
		  @SDO datetime 
AS
BEGIN
	-- NOTE: Tag report is based on IATA tag scanned by ATR or MES
	-- The license plates which are not scanned by ATR or MES will not be shown in this report
	DECLARE @DATERANGE INT=1;
	DECLARE @HOURRANGE INT = 4;

	SET @SDO = CONVERT(DATETIME,CONVERT(VARCHAR,@SDO,103),103);--ONLY DATE PART

	--Create temp table for final result
	CREATE TABLE #BT_BAG_TAG_TEMP 
	(
		GID BIGINT,
		LICENSE_PLATE VARCHAR(10),
		PAX_NAME VARCHAR(200),
		FLIGHT_NUMBER VARCHAR(5),
		AIRLINE VARCHAR(3),
		SDO DATETIME,
		STD DATETIME,
		TAG_READ_TIME DATETIME,
		TAG_READ_LOCATION VARCHAR(20),
		BAG_TYPE VARCHAR(15),
		ALLOC_MU VARCHAR(10),
		SORTED_MU VARCHAR(10),
		LATE_FLTNUM VARCHAR(8)
	);

	--1. Query the ATR read info into temp table #BT_ITEM_TAGREAD_TEMP
	SELECT ISC.GID, ISC.LICENSE_PLATE1, ISC.LICENSE_PLATE2, ISC.LOCATION, ISC.TIME_STAMP 
	INTO #BT_ITEM_TAGREAD_TEMP
	FROM ITEM_SCANNED ISC WITH(NOLOCK)
	WHERE ISC.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@SDO) AND DATEADD(DAY,@DATERANGE,@SDO)
		AND (ISC.STATUS_TYPE='1' OR ISC.STATUS_TYPE='3' OR ISC.STATUS_TYPE='7')

	--2. Query the MES read info into temp table #BT_ITEM_TAGREAD_TEMP 
	INSERT INTO #BT_ITEM_TAGREAD_TEMP
	SELECT IER.GID,IER.LICENSE_PLATE AS LICENSE_PLATE1,'0000000000' AS LICENSE_PLATE2,IER.LOCATION,IER.TIME_STAMP 
	FROM ITEM_ENCODING_REQUEST IER WITH(NOLOCK)
	WHERE IER.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@SDO) AND DATEADD(DAY,@DATERANGE,@SDO)
	
	--3. In Oklahoma project, there are 1 ATR and 1 MES which a bag may goes through. 
	--So stored procedure must find the lastest location where item_scanned telegram is sent ordered by time_stamp
	DECLARE @TAGREAD_TABLE AS TAGREAD_TABLETYPE; --For the parameter of stp_RPT_GET_LATEST_TAGREAD

	INSERT INTO @TAGREAD_TABLE
	SELECT * FROM #BT_ITEM_TAGREAD_TEMP;
	
	CREATE TABLE #BT_TAGREAD_TEMP
	( 
		GID VARCHAR(10),
		LICENSE_PLATE VARCHAR(10),
		LOCATION VARCHAR(20), 
		TIME_STAMP DATETIME
	);

	INSERT INTO #BT_TAGREAD_TEMP
	EXEC dbo.stp_RPT_GET_LATEST_TAGREAD @TAGREAD_TABLE;

	CREATE NONCLUSTERED INDEX #BT_TAGREAD_TEMP_IDXLP ON #BT_TAGREAD_TEMP(LICENSE_PLATE);

	--4. Query the bags data from BSM into temp table #BT_BAG_SORTING_TEMP
	SELECT DISTINCT LICENSE_PLATE,SDO,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE,SOURCE INTO #BT_BAG_SORTING_TEMP
	FROM 
	(
		SELECT LICENSE_PLATE,SDO,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE,SOURCE
		FROM BAG_SORTING WITH(NOLOCK)
		WHERE SDO BETWEEN DATEADD(DAY,-@DATERANGE,@SDO) AND DATEADD(DAY,2*@DATERANGE,@SDO)
		UNION ALL
		SELECT LICENSE_PLATE,SDO,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE,SOURCE
		FROM BAG_SORTING_HIS WITH(NOLOCK)
		WHERE SDO BETWEEN DATEADD(DAY,-@DATERANGE,@SDO) AND DATEADD(DAY,2*@DATERANGE,@SDO)

	) AS BAG_SORTING_ALL ;

	CREATE NONCLUSTERED INDEX #BT_BAG_SORTING_TEMP_IDXLP ON #BT_BAG_SORTING_TEMP(LICENSE_PLATE);

	--4. Insert bags TAG data WITH BSM ON @SDO into final table
	INSERT INTO #BT_BAG_TAG_TEMP
	SELECT BTR.GID,BTR.LICENSE_PLATE,
		(ISNULL(BST.GIVEN_NAME,'')+' '+ISNULL(BST.SURNAME,'')+' '+ISNULL(BST.OTHERS_NAME,'')) AS PAX_NAME,
		BST.FLIGHT_NUMBER, BST.AIRLINE, BST.SDO, NULL AS STD,
		BTR.TIME_STAMP AS TAG_READ_TIME,LOC.LOCATION AS TAG_READ_LOCATION,
		CASE BST.SOURCE
		   WHEN 'L' THEN 'outbound'
		   WHEN 'T' THEN 'transfer'
		   WHEN 'A' THEN 'inbound'
		   ELSE ''
		END AS BAG_TYPE,
		'' AS ALLOC_MU,'' AS SORTED_MU, NULL AS LATE_FLTNUM
	FROM #BT_TAGREAD_TEMP BTR,#BT_BAG_SORTING_TEMP BST, LOCATIONS LOC
	WHERE BST.SDO=@SDO
	AND BTR.LICENSE_PLATE=BST.LICENSE_PLATE
	AND BTR.LOCATION=LOC.LOCATION_ID

	--5. Insert bags TAG data WITHOUT BSM into final table
	INSERT INTO #BT_BAG_TAG_TEMP
	SELECT BTR.GID,BTR.LICENSE_PLATE,
		'' AS PAX_NAME,'' AS FLIGHT_NUMBER, '' AS AIRLINE, NULL AS SDO, NULL AS STD,
		BTR.TIME_STAMP AS TAG_READ_TIME,LOC.LOCATION AS TAG_READ_LOCATION,
		'' AS BAG_TYPE, '' AS ALLOC_MU,'' AS SORTED_MU, NULL AS LATE_FLTNUM
	FROM #BT_TAGREAD_TEMP BTR, LOCATIONS LOC
	WHERE NOT EXISTS (SELECT BST.LICENSE_PLATE FROM #BT_BAG_SORTING_TEMP BST WHERE BTR.LICENSE_PLATE=BST.LICENSE_PLATE)
	AND BTR.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@SDO) AND DATEADD(DAY,@DATERANGE,@SDO)
	AND BTR.LOCATION=LOC.LOCATION_ID

	CREATE INDEX #BT_BAG_TAG_TEMP_IDXGID ON #BT_BAG_TAG_TEMP(GID);

	--6. Update Flight Allocation Make-up carousel(ALLOC_MU) into final table
	UPDATE BTT
	SET BTT.ALLOC_MU=FPA.RESOURCE
	FROM FLIGHT_PLAN_ALLOC FPA, #BT_BAG_TAG_TEMP BTT WITH(NOLOCK)
	WHERE FPA.AIRLINE=BTT.AIRLINE AND FPA.FLIGHT_NUMBER=BTT.FLIGHT_NUMBER
		AND FPA.SDO=@SDO;

	--7. Update STD into final table
	UPDATE BTT
	SET BTT.STD=CONVERT(DATETIME,CONVERT(VARCHAR,BTT.SDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(FPS.STO),103)
	FROM FLIGHT_PLAN_SORTING FPS, #BT_BAG_TAG_TEMP BTT WITH(NOLOCK)
	WHERE BTT.SDO IS NOT NULL
		AND FPS.AIRLINE=BTT.AIRLINE AND FPS.FLIGHT_NUMBER=BTT.FLIGHT_NUMBER AND FPS.SDO=@SDO;
		

	--8. Update sorted MU(SORTED_MU) into final table
	UPDATE BTT
	SET BTT.SORTED_MU=LOC.LOCATION
	FROM ITEM_PROCEEDED IPR, LOCATIONS LOC,#BT_BAG_TAG_TEMP BTT WITH(NOLOCK)
	WHERE IPR.GID=BTT.GID AND BTT.GID IS NOT NULL
		AND IPR.PROCEED_LOCATION = LOC.LOCATION_ID
		AND LOC.SUBSYSTEM LIKE 'MU%'
		AND IPR.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@SDO) AND DATEADD(DAY,@DATERANGE,@SDO);

		
	--Update Secondary Flight if bag misses the first flight(LATE_FLTNUM) into final table
	----
	----
	----
	
	SELECT	*
	FROM	#BT_BAG_TAG_TEMP
	WHERE GID IS NOT NULL
	ORDER BY LICENSE_PLATE;

END;


--DECLARE @SDO datetime='2014-1-14';
--DECLARE @AIRLINE varchar(max)='DL';
--DECLARE @FLIGHTNUM varchar(max)='0006';
--EXEC stp_RPT_CLT_BAGTAG @SDO;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_BAGTRACE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_CLT_BAGTRACE]
		  @DTFROM DATETIME,
		  @DTTO DATETIME,
		  @GID VARCHAR(10),
		  @LICENSE_PLATE VARCHAR (10),
		  @LOGIC VARCHAR(10)
AS
BEGIN
	PRINT 'BAG TRACE REPORT BEGIN';

	SET NOCOUNT ON;

	DECLARE @MINUTERANGE INT=0;
	DECLARE @SECONDRANGE INT=10;

	--Create a temp table used to store all the gid belonging to the searched bag
	CREATE TABLE #BT_BAG_GIDLIST_TEMP
	(
		--TIME_STAMP DATETIME,
		GID VARCHAR(10)
	);

	--Create a temp table used to store all the event
	CREATE TABLE #BT_BAG_TRACE_TEMP
	(
		TIME_STAMP DATETIME,
		BAG_GID VARCHAR(10),
		BAG_EVENT VARCHAR(2000)
	);

	--QUERY ALL 
	
	DECLARE @STD_LICENSE_PLATE VARCHAR(10)=NULL;

	--1. If the license plate is Fall Back tag, then find the corresponding IATA tag
	IF @LICENSE_PLATE IS NOT NULL AND @LICENSE_PLATE<>'' AND @LICENSE_PLATE LIKE '1%'
	BEGIN 
		SET @STD_LICENSE_PLATE =
		(  SELECT DISTINCT TOP 1
				CASE
					WHEN ISC.LICENSE_PLATE1 LIKE '0%' AND ISC.LICENSE_PLATE1<>'0000000000' AND ISC.LICENSE_PLATE1<>'999999999' AND LEN(LICENSE_PLATE1)=10
						THEN ISC.LICENSE_PLATE1
					WHEN ISC.LICENSE_PLATE2 LIKE '0%' AND ISC.LICENSE_PLATE2<>'0000000000' AND ISC.LICENSE_PLATE2<>'999999999' AND LEN(LICENSE_PLATE1)=10
						THEN ISC.LICENSE_PLATE2
					WHEN LEN(ISC.LICENSE_PLATE1)=10 AND ISC.LICENSE_PLATE1 LIKE '1%'
						THEN ISC.LICENSE_PLATE1 --NULL
					WHEN LEN(ISC.LICENSE_PLATE2)=10 AND ISC.LICENSE_PLATE2 LIKE '1%'
						THEN ISC.LICENSE_PLATE2 --NULL
					ELSE ISC.LICENSE_PLATE1
				END AS LICENSE_PLATE
			FROM ITEM_SCANNED ISC WITH(NOLOCK)
			WHERE (ISC.LICENSE_PLATE1=@LICENSE_PLATE OR ISC.LICENSE_PLATE2=@LICENSE_PLATE)
				AND ISC.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		)

		
	END
	ELSE IF @LICENSE_PLATE LIKE '0%' AND @LICENSE_PLATE<>'0000000000'
	BEGIN
		SET @STD_LICENSE_PLATE = @LICENSE_PLATE;
	END
	

	IF @STD_LICENSE_PLATE IS NULL AND (@GID IS NULL OR @GID='')
	BEGIN
		SELECT * FROM #BT_BAG_TRACE_TEMP;
		RETURN;
	END

	--SELECT * FROM GID_USED;
	--SELECT * FROM ITEM_SCANNED;
	--SELECT * FROM ITEM_SCAN_STATUS_TYPES;
	--SELECT * FROM ITEM_MEASURED im;
	--SELECT * FROM ITEM_MEASURED_TYPES imt;
	--SELECT * FROM ITEM_TRACKING it;
	--SELECT * FROM ITEM_SCREENED ;
	--SELECT * FROM ITEM_SCREEN_RESULT_TYPES isrt;
	--SELECT * FROM ITEM_PROCEEDED;
	--SELECT * FROM ITEM_PROCEED_TYPES;
	--SELECT * FROM ITEM_1500P ip;
	--SELECT * FROM ITEM_1500P_BAGSTATS ipb;
	--SELECT * FROM ITEM_REDIRECT ir;
	--SELECT * FROM SORTATION_REASON sr;
	--SELECT * FROM ITEM_ENCODING_REQUEST;
	--SELECT * FROM ITEM_ENCODING_REQUEST_TYPES;
	--SELECT * FROM ITEM_SORTATION_EVENT ise;
	--SELECT * FROM ITEM_SORTATION_EVENT_TYPES iset;
	--SELECT * FROM ITEM_LOST il;
	
	--3. Find all the GID belonging to STD_LICENSE_PLATE, and insert them into #BT_BAG_GIDLIST_TEMP
	IF @STD_LICENSE_PLATE IS NOT NULL
	BEGIN
		INSERT INTO #BT_BAG_GIDLIST_TEMP(GID)
		SELECT DISTINCT GID FROM
		(
			SELECT DISTINCT TIME_STAMP, GID
			FROM ITEM_SCANNED ISC WITH(NOLOCK)
			WHERE (ISC.LICENSE_PLATE1=@STD_LICENSE_PLATE OR ISC.LICENSE_PLATE2=@STD_LICENSE_PLATE)
				AND ISC.TIME_STAMP BETWEEN @DTFROM AND @DTTO

			UNION ALL
			SELECT DISTINCT TIME_STAMP,GID
			FROM ITEM_1500P P1500 WITH(NOLOCK)
			WHERE P1500.LICENSE_PLATE=@STD_LICENSE_PLATE
				AND P1500.TIME_STAMP BETWEEN @DTFROM AND @DTTO

			UNION ALL
			SELECT DISTINCT TIME_STAMP,GID
			FROM ITEM_ENCODED IEC WITH(NOLOCK)
			WHERE IEC.LICENSE_PLATE=@STD_LICENSE_PLATE
				AND IEC.TIME_STAMP BETWEEN @DTFROM AND @DTTO

		) AS GIDLIST
	END

	--SELECT * FROM #BT_BAG_GIDLIST_TEMP;
	--4. If the @LOGIC is 'AND', then search bag trace info by @GID AND @STD_LICENSE_PLATE
	--   If the @LOGIC is 'OR', then search bag trace info by @GID or @STD_LICENSE_PLATE
	IF NOT EXISTS(SELECT * FROM #BT_BAG_GIDLIST_TEMP WHERE GID=@GID)
	BEGIN
		INSERT INTO #BT_BAG_GIDLIST_TEMP
		VALUES (@GID);
	END

	IF @LOGIC='AND' AND (@GID IS NOT NULL AND @GID<>'')
	BEGIN
		DELETE FROM #BT_BAG_GIDLIST_TEMP
		WHERE GID<>@GID
	END
	--ELSE IF @LOGIC='OR' AND (@GID IS NOT NULL AND @GID<>'')
	--BEGIN
	--	IF NOT EXISTS(SELECT * FROM #BT_BAG_GIDLIST_TEMP WHERE GID=@GID)
	--	BEGIN
	--		INSERT INTO #BT_BAG_GIDLIST_TEMP
	--		VALUES (@GID);
	--	END
	--END

	--SELECT * FROM #BT_BAG_GIDLIST_TEMP;
	--Find all corresponding GID for the searched license plate

	INSERT INTO #BT_BAG_TRACE_TEMP(TIME_STAMP,BAG_GID,BAG_EVENT)
		--SELECT * FROM GID_USED;
		SELECT	GUD.TIME_STAMP,
				GUD.GID,
				/*'Bag[GID:'+ GUD.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'GID generated at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+GUD.LOCATION+']') + ' as ' + 
				CASE GUD.BAG_TYPE
					WHEN '01' THEN 'Normal Bag.'
					WHEN '02' THEN 'Stray Bag.' 
						+	CASE --FAIL SAFE: STAY BAG IN DIVERTER TO CLEAR LINE
								WHEN EXISTS(SELECT MALM.ALM_STARTTIME
											FROM GET_RPT_EDS_LINE_DEVICE() EDSL,MDS_ALARMS MALM WITH(NOLOCK)
											WHERE MALM.ALM_ALMAREA2 ='AA_FSAL'
												AND LOC.LOCATION IS NOT NULL
												AND EDSL.CLEAR_LOCATION=LOC.LOCATION
												AND MALM.ALM_ALMEXTFLD2=
													SUBSTRING(LOC.LOCATION,1,CHARINDEX('B',LOC.LOCATION)-1)
												AND MALM.ALM_STARTTIME BETWEEN DATEADD(SECOND,-@SECONDRANGE,GUD.TIME_STAMP) AND DATEADD(SECOND,@SECONDRANGE,GUD.TIME_STAMP)
											)
								THEN '[Fail Safe]'
							ELSE ''
						END
				END AS BAG_EVENT
 		FROM	#BT_BAG_GIDLIST_TEMP BBG, GID_USED GUD WITH (NOLOCK)
		LEFT JOIN  LOCATIONS LOC ON GUD.LOCATION=LOC.LOCATION_ID
		WHERE	GUD.GID=BBG.GID
				AND GUD.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_MEASURED im;
		--SELECT * FROM ITEM_MEASURED_TYPES imt;
		UNION ALL
		SELECT	BMAM.TIME_STAMP,
				BMAM.GID,
				/*'Bag[GID:'+ BMAM.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Measured at '
				+ COALESCE(LOC.LOCATION,'Invalid location['+BMAM.LOCATION+']') + ' ' 
				+ '[' + IMT.DESCRIPTION + ']. ' + CHAR(10) + CHAR(13) +
				+ 'Length: ' + CAST(FORMAT(BMAM.LENGTH,'00') AS VARCHAR) + 'mm, ' 
				+ 'Width: ' + CAST(FORMAT(BMAM.WIDTH,'00') AS VARCHAR) + 'mm, ' 
				+ 'Height: ' + CAST(FORMAT(BMAM.HEIGHT,'00') AS VARCHAR) + 'mm'
				+ '.' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_MEASURED_TYPES IMT, ITEM_MEASURED BMAM WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON BMAM.LOCATION=LOC.LOCATION_ID
		WHERE	BMAM.TYPE=IMT.TYPE
				AND BMAM.GID=BBG.GID
				AND BMAM.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
		
		--SELECT * FROM ITEM_SCANNED;
		--SELECT * FROM ITEM_SCAN_STATUS_TYPES;
		UNION ALL
		SELECT	ISC.TIME_STAMP,
				ISC.GID,
				/*'Bag[GID:'+ ISC.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Scanned at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+ISC.LOCATION+']') + ' ' 
				+ '[' + ISCT.DESCRIPTION + ']. '
				+ CASE 
						WHEN ISC.LICENSE_PLATE1 IS NOT NULL AND RTRIM(LTRIM(ISC.LICENSE_PLATE1))<>''
							THEN 'License Plate1:' + ISC.LICENSE_PLATE1 + '   ' 
						ELSE ''
				  END
				+ CASE 
						WHEN ISC.LICENSE_PLATE1 IS NOT NULL AND RTRIM(LTRIM(ISC.LICENSE_PLATE2))<>''
							THEN 'License Plate2:' + ISC.LICENSE_PLATE2 + '   ' 
						ELSE ''
				  END
				+ '.' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_SCAN_STATUS_TYPES ISCT, ITEM_SCANNED ISC WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON ISC.LOCATION=LOC.LOCATION_ID
		WHERE	ISC.STATUS_TYPE=ISCT.TYPE
				AND ISC.GID=BBG.GID
				AND ISC.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_TRACKING it;
		UNION ALL
		SELECT	ITI.TIME_STAMP,
				ITI.GID,
				/*'Bag[GID:'+ ITI.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Bag Reached at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+ITI.LOCATION+']') + '.' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_TRACKING ITI WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON ITI.LOCATION=LOC.LOCATION_ID
		WHERE	ITI.GID=BBG.GID
				AND ITI.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_SCREENED ;
		--SELECT * FROM ITEM_SCREEN_RESULT_TYPES isrt;
		UNION ALL
		SELECT	ICR.TIME_STAMP,
				ICR.GID,
				/*'Bag[GID:'+ ICR.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Screened at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+ICR.LOCATION+']') +  ' ' 
				/*+ 'with Screen Level [' + ICR.SCREEN_LEVEL+ ']. '*/
				+ 'Screen Result ['+ ICRT.DESCRIPTION + '].' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_SCREEN_RESULT_TYPES ICRT, ITEM_SCREENED ICR WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON ICR.LOCATION=LOC.LOCATION_ID
		WHERE	ICR.RESULT_TYPE=ICRT.TYPE
				AND ICR.GID=BBG.GID
				AND ICR.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_PROCEEDED;
		--SELECT * FROM ITEM_PROCEED_TYPES;
		UNION ALL
		SELECT	IPR.TIME_STAMP,
				IPR.GID,
				/*'Bag[GID:'+ IPR.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Proceed from ' 
				+ COALESCE(AT_LOC.LOCATION,'Invalid location['+IPR.LOCATION+']')+ ' to ' 
				+ COALESCE(PRD_LOC.LOCATION,'Invalid location['+IPR.PROCEED_LOCATION+']') + ' '
				+ '[' + IPRT.DESCRIPTION + '].' AS BAG_EVENT
		FROM	 #BT_BAG_GIDLIST_TEMP BBG, ITEM_PROCEED_TYPES IPRT, ITEM_PROCEEDED IPR WITH(NOLOCK)
		LEFT JOIN LOCATIONS AT_LOC ON IPR.LOCATION=AT_LOC.LOCATION_ID
		LEFT JOIN LOCATIONS PRD_LOC ON IPR.PROCEED_LOCATION=PRD_LOC.LOCATION_ID
		WHERE	IPR.PROCEED_TYPE=IPRT.TYPE
				AND IPR.GID=BBG.GID
				AND IPR.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_1500P ip;
		--SELECT * FROM ITEM_1500P_BAGSTATS ipb;
		UNION ALL
		SELECT	IP.TIME_STAMP,
				IP.GID,
				/*'Bag[GID:'+ IP.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Reached CBRA Area at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+IP.LOCATION+']') + ' '
				+ '[' +COALESCE(IPT.DESCRIPTION,'Invalid TYPE:'+IP.BAG_STATUS) + ']. ' 
				+ 'CBRA XRAY_ID:' + IP.XRAY_ID + ' BIT Station:' + IP.BIT_STATION + ' ETD Station:' + IP.ETD_STATION + '.' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG,  ITEM_1500P IP WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON IP.LOCATION=LOC.LOCATION_ID
		LEFT JOIN ITEM_1500P_BAGSTATS IPT ON IP.BAG_STATUS=IPT.TYPE
		WHERE	IP.GID=BBG.GID
				AND IP.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_REDIRECT ir;
		--SELECT * FROM SORTATION_REASON sr;
		UNION ALL
		SELECT	IRD.TIME_STAMP,
				IRD.GID,
				/*'Bag[GID:'+ IRD.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Redirected to ' 
				+ CASE WHEN DES1_LOC.LOCATION IS NOT NULL THEN ' Destination1: '+ DES1_LOC.LOCATION + ' '
					   WHEN IRD.DESTINATION_1='4500' THEN  ' Destination1: MES ' ELSE '' END
				+ CASE WHEN DES2_LOC.LOCATION IS NOT NULL THEN ' Destination2: '+ DES2_LOC.LOCATION + '. '
					   WHEN IRD.DESTINATION_2='4500' THEN  ' Destination2: MES. ' ELSE '. ' END
				--+ COALESCE(' Destination1: '+DES1_LOC.LOCATION,IRD.DESTINATION_1)  + ' '
				--+ COALESCE(', Destination2: '+DES2_LOC.LOCATION,IRD.DESTINATION_1) + '. '
				+ 'Reason: [' + IRDR.DESCRIPTION + '].' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, SORTATION_REASON IRDR, ITEM_REDIRECT IRD WITH(NOLOCK)
		LEFT JOIN LOCATIONS DES1_LOC ON IRD.DESTINATION_1=DES1_LOC.LOCATION_ID
		LEFT JOIN LOCATIONS DES2_LOC ON IRD.DESTINATION_2=DES2_LOC.LOCATION_ID
		WHERE	IRD.REASON=IRDR.REASON
				AND IRD.GID=BBG.GID
				AND IRD.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_ENCODING_REQUEST;
		--SELECT * FROM ITEM_ENCODING_REQUEST_TYPES;
		--UNION ALL
		--SELECT	MER.TIME_STAMP,
		--		MER.GID,
		--		/*'Bag[GID:'+ MER.GID + ']'+ CHAR(10) + CHAR(13) +*/
		--		'Encoded at ' 
		--		+ COALESCE(LOC.LOCATION,'Invalid location ['+MER.LOCATION+']') + ' '
		--		+ '[' + ISNULL(MERT.DESCRIPTION,'') + ']. ' 
		--		+ CASE MER.ENCODING_TYPE
		--			WHEN '1' THEN ISNULL('LICENSE PLATE[' + MER.LICENSE_PLATE + '] , ','') 
		--			WHEN '2' THEN ISNULL('AIRLINE[' + UPPER(MER.AIRLINE) + '] , ' ,'')+ISNULL('FLIGHT NUMBER[' + MER.FLIGHT_NUMBER + '] , ' ,'')
		--			WHEN '3' THEN ''
		--			WHEN '4' THEN ''
		--			WHEN '5' THEN ''
		--			WHEN '6' THEN ISNULL('AIRLINE[' + UPPER(MER.AIRLINE) + '] , ' ,'')
		--			ELSE ''
		--		  END
		--		--ISNULL('SDO[' + MER.SDO + '] , ','')
		--		+ ISNULL('DESTINATION[' + DETLOC.LOCATION + ']. ','')
		--		 AS BAG_EVENT
		--FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_ENCODING_REQUEST_TYPES MERT, ITEM_ENCODING_REQUEST MER WITH(NOLOCK)
		--LEFT JOIN LOCATIONS LOC ON MER.LOCATION=LOC.LOCATION_ID
		--LEFT JOIN LOCATIONS DETLOC ON MER.DESTINATION=DETLOC.LOCATION_ID
		--WHERE	MER.ENCODING_TYPE=MERT.TYPE
		--		AND MER.GID=BBG.GID
		--		AND MER.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
		--		AND MER.TIME_STAMP=( SELECT MAX(TIME_STAMP) FROM ITEM_ENCODING_REQUEST MER2 WITH(NOLOCK) WHERE MER.GID=MER2.GID )
		
		--SELECT * FROM ITEM_READY;
		UNION ALL
		SELECT	IRY.TIME_STAMP,
				IRY.GID,
				/*'Bag[GID:'+ IPR.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Bag Ready for encoding at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+IRY.LOCATION+']') AS BAG_EVENT
		FROM	 #BT_BAG_GIDLIST_TEMP BBG, ITEM_READY IRY WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON IRY.LOCATION=LOC.LOCATION_ID
		WHERE	IRY.GID=BBG.GID
				AND IRY.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_REMOVED;
		UNION ALL
		SELECT	IRM.TIME_STAMP,
				IRM.GID,
				/*'Bag[GID:'+ ITI.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Bag Removed at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+IRM.LOCATION+']') + '.' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_REMOVED IRM WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON IRM.LOCATION=LOC.LOCATION_ID
		WHERE	IRM.GID=BBG.GID
				AND IRM.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_ENCODED;
		--SELECT * FROM ITEM_ENCODING_REQUEST_TYPES;
		UNION ALL
		SELECT	IEC.TIME_STAMP,
				IEC.GID,
				/*'Bag[GID:'+ MER.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Encoded at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location ['+IEC.LOCATION+']') + ' '
				+ '[' + ISNULL(IERT.DESCRIPTION,'') + ']. ' 
				+ CASE IEC.ENCODING_TYPE
					WHEN '1' THEN ISNULL('LICENSE PLATE[' + IEC.LICENSE_PLATE + '] , ','') 
					WHEN '2' THEN ISNULL('AIRLINE[' + UPPER(IEC.AIRLINE) + '] , ' ,'')+ISNULL('FLIGHT NUMBER[' + IEC.FLIGHT_NUMBER + '] , ' ,'')
					WHEN '3' THEN ''
					WHEN '4' THEN ''
					WHEN '5' THEN ''
					WHEN '6' THEN ISNULL('AIRLINE[' + UPPER(IEC.AIRLINE) + '] , ' ,'')
					ELSE ''
				  END
				--ISNULL('SDO[' + MER.SDO + '] , ','')
				+ ISNULL('DESTINATION[' + DETLOC.LOCATION + ']. ','')
				 AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_ENCODING_REQUEST_TYPES IERT, ITEM_ENCODED IEC WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON IEC.LOCATION=LOC.LOCATION_ID
		LEFT JOIN LOCATIONS DETLOC ON IEC.DEST=DETLOC.LOCATION_ID
		WHERE	IEC.ENCODING_TYPE=IERT.TYPE
				AND IEC.GID=BBG.GID
				AND IEC.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
				AND IEC.TIME_STAMP=( SELECT MAX(TIME_STAMP) FROM ITEM_ENCODED IEC2 WITH(NOLOCK) WHERE IEC.GID=IEC2.GID )

		--SELECT * FROM ITEM_SORTATION_EVENT ise;
		--SELECT * FROM ITEM_SORTATION_EVENT_TYPES iset;
		UNION ALL
		SELECT	ISE.TIME_STAMP,
				ISE.GID,
				/*'Bag[GID:'+ ISE.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Sortation event at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location ['+ISE.LOCATION+']') + ' '
				+ '[' + ISET.DESCRIPTION + '], ' 
				+ 'and new destination is ' + COALESCE(SORT_LOC.LOCATION,'['+ISE.SORT_DESTINATION+']') + '.' AS BAG_EVENT 
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_SORTATION_EVENT_TYPES ISET, ITEM_SORTATION_EVENT ISE WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON ISE.LOCATION=LOC.LOCATION_ID
		LEFT JOIN LOCATIONS SORT_LOC ON ISE.SORT_DESTINATION=SORT_LOC.LOCATION_ID
		WHERE	ISE.SORT_EVENT_TYPE=ISET.TYPE
				AND ISE.GID=BBG.GID
				AND ISE.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_LOST il;
		UNION ALL
		SELECT	ITL.TIME_STAMP,
				ITL.GID,
				/*'Bag[GID:'+ ITL.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Lost tracking at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location ['+ITL.LOCATION+']') + '.' 
				--FAIL SAFE: BAG LOST IN DIVERTER TO ALARM LINE
				+ CASE 
					 WHEN EXISTS(SELECT MALM.ALM_STARTTIME
								 FROM	GET_RPT_EDS_LINE_DEVICE() EDSL,MDS_ALARMS MALM WITH(NOLOCK)
								 WHERE  MALM.ALM_ALMAREA2 ='AA_FSAL'
									AND LOC.LOCATION IS NOT NULL
									AND EDSL.REJECT_LOCATION=LOC.LOCATION
									AND MALM.ALM_ALMEXTFLD2=
										SUBSTRING(LOC.LOCATION,1,CHARINDEX('C',LOC.LOCATION)-1)
									AND MALM.ALM_STARTTIME BETWEEN DATEADD(SECOND,-@SECONDRANGE,ITL.TIME_STAMP) AND DATEADD(SECOND,@SECONDRANGE,ITL.TIME_STAMP)
								)
						 THEN '[Fail Safe]'
					 ELSE ''
				 END 
				 AS BAG_EVENT 
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_LOST ITL WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON ITL.LOCATION=LOC.LOCATION_ID
		WHERE	ITL.GID=BBG.GID
				AND ITL.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		SELECT * FROM #BT_BAG_TRACE_TEMP bbtt
		ORDER BY bbtt.TIME_STAMP;
END

--DECLARE @GID VARCHAR(10)='';--3211000413
--DECLARE @LICENSE_PLATE VARCHAR(10)='1131578207';--0612100122
--DECLARE @DTFROM DATETIME='2014/1/1 19:35:40';
--DECLARE @DTTO DATETIME='2014/1/2 19:35:40';
--DECLARE @LOGIC VARCHAR(10)='OR';
--EXEC stp_RPT27_BAGTRACE_GWYTEST @DTFROM,@DTTO,@GID,@LICENSE_PLATE,@LOGIC;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_BDDFault]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_CLT_BDDFault]
		  @DTFrom datetime, 
		  @DTTo datetime
AS
BEGIN
--What is AA_BDAL
	SELECT	MALM.ALM_ALMEXTFLD2 AS BMA_ID, 
			ALM_STARTTIME, 
			ALM_ENDTIME,
			DATEDIFF(SECOND,ALM_STARTTIME,ALM_ENDTIME) AS FAULT_DUARTION,
			ALM_MSGDESC AS ALM_DESCRIPTION
	FROM	MIS_SS_LINE_DEVICE AS SLD,
			MDS_ALARMS AS MALM WITH(NOLOCK)
	WHERE	MALM.ALM_ALMAREA1=SLD.SUBSYSTEM
			AND MALM.ALM_ALMEXTFLD2 LIKE '%' + DBO.RPT_FORMAT_LOCATION(SLD.BMA_LOCATION) + '%'
			AND ALM_UNCERTAIN = 0
			AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo 
			AND MALM.ALM_MSGTYPE='ALARM'
	ORDER BY ALM_STARTTIME

	--SELECT     ALM_ALMAREA1, ALM_STARTTIME, ALM_ENDTIME, ALM_MSGDESC
	--FROM         MDS_ALARMS
	--WHERE    (ALM_UNCERTAIN = 0) AND  (ALM_STARTTIME BETWEEN @DTFrom AND @DTTo) AND (ALM_ALMAREA2 = 'AA_BDAL')
	--ORDER BY ALM_STARTTIME

END

--DECLARE @DTFrom datetime='2014-1-7';
--DECLARE @DTTo datetime='2014-1-10';
--EXEC stp_RPT24_BDDFault @DTFrom,@DTTo
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_BDDSTATISTICS_OOG]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_CLT_BDDSTATISTICS_OOG]
		  @DTFROM datetime , 
		  @DTTO datetime
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @SECONDRANGE INT=300;

	--SELECT GID.GID AS BAGS_GID, BMAM.TIME_STAMP, BMAM.GID, BMAM.TYPE,
	--	CASE
	--		WHEN BMAM.LOCATION IS NOT NULL THEN BMAM.LOCATION
	--		ELSE (	SELECT TOP 1 LOC.LOCATION_ID
	--				FROM MIS_SS_LINE_DEVICE,LOCATIONS LOC 
	--				WHERE GID_LOCATION=GIDLOC.LOCATION 
	--					AND BMA_LOCATION=LOC.LOCATION
	--			 )
	--	END AS LOCATION
	--INTO #BDD_ITEM_MEASURED_TEMP
	--FROM LOCATIONS GIDLOC, GID_USED GID WITH(NOLOCK)
	--LEFT JOIN ITEM_MEASURED BMAM 
	--	ON GID.GID=BMAM.GID
	--	AND BMAM.TIME_STAMP BETWEEN DATEADD(SECOND,-@SECONDRANGE,@DTFROM) AND DATEADD(SECOND,@SECONDRANGE,@DTTO)
	-- WHERE GID.TIME_STAMP BETWEEN @DTFrom AND @DTTo
	--	AND GID.LOCATION=GIDLOC.LOCATION_ID
	--	AND GIDLOC.LOCATION LIKE 'SS%'
	--	--AND EXISTS(SELECT GID_LOCATION FROM MIS_SS_LINE_DEVICE WHERE GIDLOC.LOCATION=GID_LOCATION)

	----DELETE THE BAG GID WHICH IS LOST
	--DELETE 
	--FROM #BDD_ITEM_MEASURED_TEMP
	--WHERE BAGS_GID IN (	SELECT GID 
	--					FROM ITEM_LOST ITI, LOCATIONS LOC WITH(NOLOCK)
	--					WHERE ITI.TIME_STAMP BETWEEN DATEADD(SECOND,-@SECONDRANGE,@DTFROM) AND DATEADD(SECOND,@SECONDRANGE,@DTTO)
	--						AND ITI.LOCATION=LOC.LOCATION_ID
	--						AND LOC.LOCATION IN (SELECT BMA_LOCATION FROM MIS_SS_LINE_DEVICE)
	--					)

	--1. The quantity of bags is based on the GID generate before BMA
	SELECT	GID.GID,SLD.BMA_LOCATION AS LOCATION
	INTO	#BDD_BAGGID_TEMP
	FROM	GID_USED GID,LOCATIONS GIDLOC,MIS_SS_LINE_DEVICE SLD,LOCATIONS BMALOC WITH(NOLOCK)
	WHERE	GID.TIME_STAMP BETWEEN @DTFrom AND @DTTo
		AND GID.LOCATION=GIDLOC.LOCATION_ID AND SLD.SUBSYSTEM=GIDLOC.SUBSYSTEM
		AND SLD.BMA_LOCATION=BMALOC.LOCATION
		AND GID.LOCATION<=BMALOC.LOCATION_ID -- GID generate before the BMA

	--2. DELETE THE BAG GID WHICH IS LOST before the BMA
	DELETE 
	FROM #BDD_BAGGID_TEMP
	WHERE GID IN (	SELECT GID 
					FROM MIS_SS_LINE_DEVICE SLD,LOCATIONS BMALOC,ITEM_LOST ITL, LOCATIONS ITLLOC WITH(NOLOCK)
					WHERE ITL.TIME_STAMP BETWEEN DATEADD(SECOND,-@SECONDRANGE,@DTFROM) AND DATEADD(SECOND,@SECONDRANGE,@DTTO)
						AND ITL.LOCATION=ITLLOC.LOCATION_ID AND SLD.SUBSYSTEM=ITLLOC.SUBSYSTEM
						AND SLD.BMA_LOCATION=BMALOC.LOCATION
						AND ITL.LOCATION<=BMALOC.LOCATION_ID -- GID generate before the BMA
				)

	--3. The bags which is measured by BMA
	SELECT BMAM.GID, BMAM.TIME_STAMP,LOC.LOCATION, BMAM.TYPE
	INTO #BDD_ITEM_MEASURED_TEMP
	FROM ITEM_MEASURED BMAM, LOCATIONS LOC
	WHERE BMAM.LOCATION=LOC.LOCATION_ID
	AND BMAM.TIME_STAMP BETWEEN DATEADD(SECOND,-@SECONDRANGE,@DTFROM) AND DATEADD(SECOND,@SECONDRANGE,@DTTO)

	--4. The count of bags which passed through BMA with GID
	SELECT	BAGGID.LOCATION, 
			COUNT(BAGGID.GID) AS 'TOTAL',
			0 AS 'DIM_TOTAL',
			0 AS 'OUT',
			0 AS 'NORMAL',
			0 AS 'NOT_DIM'
	INTO #BDD_DIMSTATISTICS_TEMP
	FROM	#BDD_BAGGID_TEMP BAGGID
	GROUP BY BAGGID.LOCATION

	--SELECT * FROM #BDD_DIMSTATISTICS_TEMP;

	--5. The count of Bags DIMENSIONED
	UPDATE BDD
	SET BDD.DIM_TOTAL=BMA_DIM.DIM
	FROM(
			SELECT BMAM.LOCATION,COUNT(BMAM.GID) AS DIM
			FROM #BDD_ITEM_MEASURED_TEMP BMAM
			GROUP BY BMAM.LOCATION
		) BMA_DIM, #BDD_DIMSTATISTICS_TEMP BDD
	WHERE BDD.LOCATION=BMA_DIM.LOCATION

	
	--SELECT * FROM #BDD_DIMSTATISTICS_TEMP;

	--6. The count of bags which are OOG
	UPDATE BDD
	SET BDD.OUT=BMA_OOG.OOG
	FROM(
			SELECT BMAM.LOCATION,COUNT(BMAM.GID) AS OOG
			FROM #BDD_ITEM_MEASURED_TEMP BMAM
			WHERE BMAM.TYPE='1'--OOG
			GROUP BY BMAM.LOCATION
		) BMA_OOG, #BDD_DIMSTATISTICS_TEMP BDD
	WHERE BDD.LOCATION=BMA_OOG.LOCATION

	--7. The count of bags which are NORMAL
	UPDATE BDD
	SET BDD.NORMAL=BMA_NOR.NORMAL
	FROM(
			SELECT BMAM.LOCATION,COUNT(BMAM.GID) AS NORMAL
			FROM #BDD_ITEM_MEASURED_TEMP BMAM
			WHERE BMAM.TYPE='2'--NORMAL
			GROUP BY BMAM.LOCATION
		) BMA_NOR, #BDD_DIMSTATISTICS_TEMP BDD
	WHERE BDD.LOCATION=BMA_NOR.LOCATION

	--8. Update the count of bags which are not dimensioned
	UPDATE BDT
	SET BDT.NOT_DIM=TOTAL-DIM_TOTAL
	FROM #BDD_DIMSTATISTICS_TEMP BDT;

	SELECT * FROM #BDD_DIMSTATISTICS_TEMP;
END

--DECLARE @DTFrom datetime='2013-12-18';
--DECLARE @DTTo datetime='2013-12-27';
--EXEC stp_RPT24_BDDSTATISTICS_OOG_GWYTEST @DTFROM,@DTTO;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_BSM]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_BSM]
		  @DTFROM DATETIME , 
		  @DTTO DATETIME,
		  @AIRLINE varchar(max) , 
		  @FLIGHTNUM varchar(max)
AS
BEGIN
	-- NOTE: BSM report is based on all license plates from BSM
	-- The tags which do not have matched BSM data will not shown in this report
	DECLARE @DATERANGE INT=1;

	--Create temp table for final result
	CREATE TABLE #BSM_BAG_BSM_TEMP 
	(
		GID BIGINT,
		LICENSE_PLATE VARCHAR(10),
		PAX_NAME VARCHAR(200),
		FLIGHT_NUMBER VARCHAR(5),
		AIRLINE VARCHAR(3),
		TAG_READ_TIME DATETIME,
		TAG_READ_LOCATION VARCHAR(20),
		BAG_TYPE VARCHAR(15),
		BSM_RECD_TIME DATETIME,
		TAG_PRINT_TIME DATETIME,
		BAG_LATE_STATUS VARCHAR(8)
	);

	--1. Query the bags data from BSM
	SELECT DISTINCT LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE,SOURCE,BSM_RECD_TIME,TAG_PRINT_TIME INTO #BSM_BAG_SORTING_TEMP
	FROM 
	(
		SELECT LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE,SOURCE,TIME_STAMP AS BSM_RECD_TIME,CHECK_IN_TIME_STAMP AS TAG_PRINT_TIME
		FROM BAG_SORTING WITH(NOLOCK)
		WHERE SDO BETWEEN DATEADD(DAY,-@DATERANGE, @DTFrom) AND DATEADD(DAY,@DATERANGE, @DTTo)	
			AND AIRLINE IN (SELECT * FROM RPT_GETPARAMETERS(@AIRLINE)) 
			AND FLIGHT_NUMBER IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@FLIGHTNUM))
			
		UNION ALL
		SELECT LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE,SOURCE,TIME_STAMP AS BSM_RECD_TIME,CHECK_IN_TIME_STAMP AS TAG_PRINT_TIME
		FROM BAG_SORTING_HIS WITH(NOLOCK)
		WHERE SDO BETWEEN DATEADD(DAY,-@DATERANGE, @DTFrom) AND DATEADD(DAY,@DATERANGE, @DTTo) 
			AND AIRLINE IN (SELECT * FROM RPT_GETPARAMETERS(@AIRLINE)) 
			AND FLIGHT_NUMBER IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@FLIGHTNUM))
	) AS BAG_SORTING_ALL ;


	--2. Insert bags data into final table
	INSERT INTO #BSM_BAG_BSM_TEMP
	SELECT NULL AS GID, LICENSE_PLATE, (ISNULL(GIVEN_NAME,'')+' '+ISNULL(SURNAME,'')+' '+ISNULL(OTHERS_NAME,'')) AS PAX_NAME,
		   FLIGHT_NUMBER,AIRLINE, NULL AS TAG_READ_TIME, '' AS TAG_READ_LOCATION,
		   CASE SOURCE
			   WHEN 'L' THEN 'outbound'
			   WHEN 'T' THEN 'transfer'
			   WHEN 'A' THEN 'inbound'
			   ELSE 'N/A'
		   END AS BAG_TYPE,
		   BSM_RECD_TIME,TAG_PRINT_TIME,'' AS BAG_LATE_STATUS
	FROM #BSM_BAG_SORTING_TEMP

	CREATE INDEX #BSM_BAG_BSM_TEMP_IDXLP ON #BSM_BAG_BSM_TEMP(LICENSE_PLATE);


	--3. Query the ATR read info into temp table #BT_ITEM_TAGREAD_TEMP
	SELECT ISC.GID, ISC.LICENSE_PLATE1, ISC.LICENSE_PLATE2, ISC.LOCATION, ISC.TIME_STAMP INTO #BT_ITEM_TAGREAD_TEMP
	FROM ITEM_SCANNED ISC, #BSM_BAG_BSM_TEMP BBT WITH(NOLOCK)
	WHERE (ISC.LICENSE_PLATE1=BBT.LICENSE_PLATE OR ISC.LICENSE_PLATE2=BBT.LICENSE_PLATE)
		AND ISC.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFrom) AND DATEADD(DAY,@DATERANGE,@DTTo)
		AND (ISC.STATUS_TYPE='1' OR ISC.STATUS_TYPE='3' OR ISC.STATUS_TYPE='7')

	--4. Query the MES read info into temp table #BT_ITEM_TAGREAD_TEMP 
	INSERT INTO #BT_ITEM_TAGREAD_TEMP
	SELECT IER.GID,IER.LICENSE_PLATE AS LICENSE_PLATE1,'0000000000' AS LICENSE_PLATE2,IER.LOCATION,IER.TIME_STAMP 
	FROM ITEM_ENCODING_REQUEST IER,#BSM_BAG_BSM_TEMP BBT WITH(NOLOCK)
	WHERE IER.LICENSE_PLATE=BBT.LICENSE_PLATE
		AND IER.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFrom) AND DATEADD(DAY,@DATERANGE,@DTTo)

	--In Charlotte project, there are 2 ATRs and MES a bag may goes through. 
	--So stored procedure must find the lastest location where item_scanned telegram is sent ordered by time_stamp

	DECLARE @TAGREAD_TABLE AS TAGREAD_TABLETYPE; --For the parameter of stp_RPT_GET_LATEST_TAGREAD

	INSERT INTO @TAGREAD_TABLE
	SELECT * FROM #BT_ITEM_TAGREAD_TEMP;

	CREATE TABLE #BT_TAGREAD_TEMP
	( 
		GID VARCHAR(10),
		LICENSE_PLATE VARCHAR(10), 
		LOCATION VARCHAR(20), 
		TIME_STAMP DATETIME
	);

	INSERT INTO #BT_TAGREAD_TEMP
	EXEC dbo.stp_RPT_GET_LATEST_TAGREAD @TAGREAD_TABLE;

	CREATE INDEX #BT_TAGREAD_TEMP_IDXLP ON #BT_TAGREAD_TEMP(LICENSE_PLATE);
	--CREATE INDEX #BT_TAGREAD_TEMP_IDXGID ON #BT_TAGREAD_TEMP(LICENSE_PLATE2);

	--select * from #BT_TAGREAD_TEMP;

	--5. Update ATR OR MES read info(GID,TAG_READ_TIME,TAG_READ_LOCATION) into final table
	UPDATE BBT
	SET BBT.GID=BTT.GID,BBT.TAG_READ_TIME=BTT.TIME_STAMP,BBT.TAG_READ_LOCATION=LOC.LOCATION
	FROM #BT_TAGREAD_TEMP BTT, #BSM_BAG_BSM_TEMP BBT, LOCATIONS LOC
	WHERE BTT.LICENSE_PLATE=BBT.LICENSE_PLATE
		AND BTT.LOCATION=LOC.LOCATION_ID 

	CREATE INDEX #BSM_BAG_BSM_TEMP_IDXGID ON #BSM_BAG_BSM_TEMP(GID);

	
	--6. Update BAG late status(BAG_LATE_STATUS) into final table
	UPDATE BBT
	SET BBT.BAG_LATE_STATUS='YES'
	FROM ITEM_REDIRECT IRD, #BSM_BAG_BSM_TEMP BBT WITH(NOLOCK)
	WHERE IRD.GID=BBT.GID AND BBT.GID IS NOT NULL
		AND IRD.REASON='5'--TOO LATE
		AND IRD.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFrom) AND DATEADD(DAY,@DATERANGE,@DTTo);

	UPDATE BBT
	SET BBT.BAG_LATE_STATUS='NO'
	FROM #BSM_BAG_BSM_TEMP BBT
	WHERE BBT.BAG_LATE_STATUS != 'YES';
	

	SELECT * FROM #BSM_BAG_BSM_TEMP;
	
END;

--DECLARE @DTFROM datetime='2014-01-01';
--DECLARE @DTTO datetime='2014-01-02';
--DECLARE @AIRLINE varchar(max)='DL,UA,EK';
--DECLARE @FLIGHTNUM varchar(max)='1234,8888,5555,1113';
--EXEC stp_RPT19_BSM_GWYTEST @DTFROM,@DTTO,@AIRLINE,@FLIGHTNUM;

GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_CBRASTATISTICS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_CBRASTATISTICS]
		  @DTFROM datetime , 
		  @DTTO datetime 
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;

	CREATE TABLE #CBRA_STATISTICS_TEMP
	(
		CBRA_ID varchar(20),
		INSPECTION_TABLE_ID varchar(20),
		BAGS_RECEIVED INT,
		BAGS_CLEARED INT,
		PERCENTAGE float
	);

	--1.Query CBRA info(1500P) into temp table
	SELECT P1500.LOCATION,P1500.BIT_STATION,P1500.LICENSE_PLATE,P1500.BAG_STATUS
	INTO #CBRA_ITEM_1500P_TEMP
	FROM ITEM_1500P AS P1500 WITH(NOLOCK)
	WHERE P1500.TIME_STAMP BETWEEN @DTFROM AND @DTTO;

	--1. Insert CBRA info and BAGS_RECEIVED into final table
	INSERT INTO #CBRA_STATISTICS_TEMP
	SELECT	CBRA_LOC.SUBSYSTEM AS CBRA_ID, 
			'BIT'+ P1500.BIT_STATION AS INSPECTION_TABLE_ID,
			COUNT(P1500.LICENSE_PLATE) AS BAGS_RECEIVED,
			0 AS BAGS_CLEARED,
			0 AS PERCENTAGE
	FROM	#CBRA_ITEM_1500P_TEMP AS P1500 WITH(NOLOCK)
	LEFT JOIN LOCATIONS CBRA_LOC ON P1500.LOCATION=CBRA_LOC.LOCATION_ID
	GROUP BY CBRA_LOC.SUBSYSTEM,
			'BIT'+ P1500.BIT_STATION;
	 -- MAY BE PROBELMS

	-------------------------------------Commented by Guo Wenyu 2014/01/07-------------------------------------
	-------------Because the number of BAGS_CLEARED is counted from MDS_COUNT
	----2.UPDATE the BAGS_CLEARED
	--UPDATE CST
	--SET  CST.BAGS_CLEARED=CLEARED_1500P.BAGS_CLEARED
	--FROM (
	--		SELECT	P1500.LOCATION AS CBRA_LOCATIONID,
	--				P1500.BIT_STATION AS TABLE_LOCATIONID,
	--				COUNT(P1500.LICENSE_PLATE) AS BAGS_CLEARED
	--		FROM	#CBRA_ITEM_1500P_TEMP P1500
	--		WHERE	P1500.BAG_STATUS='1'
	--		GROUP BY P1500.LOCATION,P1500.BIT_STATION
	--	 ) AS CLEARED_1500P, #CBRA_STATISTICS_TEMP AS CST
	--WHERE CLEARED_1500P.CBRA_LOCATIONID=CST.CBRA_LOCATIONID AND CLEARED_1500P.TABLE_LOCATIONID=CST.TABLE_LOCATIONID;

	-------------------------------------New Code added by Guo Wenyu 2014/01/07-------------------------------------
	--2.INSERT the BAGS_CLEARED only for group CBRA
	INSERT INTO #CBRA_STATISTICS_TEMP
	SELECT	MCCD.CBRA_ID,
			'CBRA' AS INSPECTION_TABLE_ID,
			0 AS BAGS_RECEIVED,
			SUM(MBC.DIFFERENT) AS BAGS_CLEARED,
			0 AS PERCENTAGE
	FROM	MDS_COUNT MBC, MDS_COUNTERS MBCR, MIS_CBRA_CLEARLINE_DEVICE MCCD
	WHERE	MBC.COUNTER_ID=MBCR.COUNTER_ID
		AND MBCR.SUBSYSTEM=MCCD.CLEARLINE_ID
		AND MBCR.TYPE='CV'
		AND MBC.TIME_STAMP BETWEEN @DTFROM AND @DTTO
	GROUP BY MCCD.CBRA_ID;

	-------------------------------------END by Guo Wenyu 2014/01/07 END-------------------------------------

	----3. UPDATE the PERCENTAGE
	--UPDATE CST 
	--SET CST.PERCENTAGE=CAST(CST.BAGS_CLEARED AS float)/CAST(CST.BAGS_RECEIVED AS float)*100
	--FROM #CBRA_STATISTICS_TEMP AS CST;

	SELECT * FROM #CBRA_STATISTICS_TEMP;
END

--DECLARE @DTFrom [datetime]='2014-1-7';
--DECLARE @DTTo [datetime]='2014-1-8';

--EXEC stp_RPT25_CBRASTATISTICS_GWYTEST @DTFrom,@DTTo
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_CRITICALTRACKINGPEC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_CLT_CRITICALTRACKINGPEC]
	@DTFrom DATETIME,
	@DTTo DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @HOURRANGE INT=1;
	DECLARE @msgEnter varchar(50)
	DECLARE @msgExit varchar (50)

	set @msgEnter = 'Entering EDS at'
	set @msgExit = 'Exited from EDS at'

	SELECT DISTINCT ITI.GID,
		CASE
			WHEN ISC.LICENSE_PLATE1 LIKE '0%' AND ISC.LICENSE_PLATE1<>'0000000000' AND ISC.LICENSE_PLATE1<>'999999999' AND LEN(LICENSE_PLATE1)=10
				THEN ISC.LICENSE_PLATE1
			WHEN ISC.LICENSE_PLATE2 LIKE '0%' AND ISC.LICENSE_PLATE2<>'0000000000' AND ISC.LICENSE_PLATE2<>'999999999' AND LEN(LICENSE_PLATE1)=10
				THEN ISC.LICENSE_PLATE2
			WHEN LEN(ISC.LICENSE_PLATE1)=10 AND ISC.LICENSE_PLATE1 LIKE '1%'
				THEN ISC.LICENSE_PLATE1 --NULL
			WHEN LEN(ISC.LICENSE_PLATE2)=10 AND ISC.LICENSE_PLATE2 LIKE '1%'
				THEN ISC.LICENSE_PLATE2 --NULL
			ELSE ITI.GID
		END AS LICENSE_PLATE
	INTO #CTP_GID2LPMAP_TEMP
	FROM (	SELECT GID FROM ITEM_TRACKING ITI,LOCATIONS LOC WITH(NOLOCK) 
			WHERE TIME_STAMP BETWEEN  @DTFrom AND @DTTo
				AND ITI.LOCATION=LOC.LOCATION_ID
				AND EXISTS(
								SELECT ELD.PRE_XM_LOCATION FROM GET_RPT_EDS_LINE_DEVICE() ELD
								WHERE ELD.PRE_XM_LOCATION=LOC.LOCATION
								UNION
								SELECT POST_XM_LOCATION FROM GET_RPT_EDS_LINE_DEVICE() ELD
								WHERE ELD.POST_XM_LOCATION=LOC.LOCATION
						  )
			UNION
			SELECT GID FROM ITEM_PROCEEDED IPR,LOCATIONS LOC WITH(NOLOCK) 
			WHERE TIME_STAMP BETWEEN  @DTFrom AND @DTTo
				AND IPR.LOCATION=LOC.LOCATION_ID
				AND EXISTS(
								SELECT DIVERT_LOCATION FROM GET_RPT_EDS_LINE_DEVICE() 
								WHERE SUBSYSTEM=LOC.SUBSYSTEM AND DIVERT_LOCATION=LOC.LOCATION
						  )
		 ) AS ITI
	LEFT JOIN ITEM_SCANNED ISC WITH(NOLOCK) 
		ON ITI.GID=ISC.GID
		AND ISC.TIME_STAMP BETWEEN  DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo);

	UPDATE #CTP_GID2LPMAP_TEMP
	SET LICENSE_PLATE=GID
	WHERE LICENSE_PLATE IS NULL;

	CREATE NONCLUSTERED INDEX #CTP_GID2LPMAP_TEMP_IDXGID ON #CTP_GID2LPMAP_TEMP(GID);
	CREATE NONCLUSTERED INDEX #CTP_GID2LPMAP_TEMP_IDXLP ON #CTP_GID2LPMAP_TEMP(LICENSE_PLATE);
	
	/**Upstream of Xray**/
	SELECT	G2L.LICENSE_PLATE, 
			LOC.SUBSYSTEM AS SUBSYSTEM,
			--(SELECT XRAY_ID FROM GET_RPT_EDS_LINE_DEVICE() WHERE SUBSYSTEM = LOC.SUBSYSTEM) AS XRAY_ID,
			@msgEnter +' '+ LOC.LOCATION AS ACT, 
			ITI.TIME_STAMP, 
			'Entered' AS XRAY_STAT
	FROM ITEM_TRACKING AS ITI, LOCATIONS LOC, #CTP_GID2LPMAP_TEMP G2L WITH(NOLOCK)
	WHERE ITI.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
		AND ITI.LOCATION=LOC.LOCATION_ID
		AND ITI.GID=G2L.GID
		AND EXISTS(
					SELECT PRE_XM_LOCATION FROM GET_RPT_EDS_LINE_DEVICE() 
					WHERE SUBSYSTEM=LOC.SUBSYSTEM AND PRE_XM_LOCATION=LOC.LOCATION
				  )
		--AND (LOC.LOCATION IN('SS1-06','SS2-06','SS3-06','SS4-06'))
	

	/**Downstream of Xray**/
	UNION ALL
	SELECT	G2L.LICENSE_PLATE, 
			LOC.SUBSYSTEM AS SUBSYSTEM,
			--(SELECT XRAY_ID FROM GET_RPT_EDS_LINE_DEVICE() WHERE SUBSYSTEM = LOC.SUBSYSTEM) AS XRAY_ID,
			@msgExit + ' '+ LOC.LOCATION AS ACT, 
			ITI.TIME_STAMP, 
			(	SELECT TOP 1 
					CASE 
						WHEN (ITI.TIME_STAMP < ICR.TIME_STAMP)OR (ICR_TYPE.DESCRIPTION) IS NULL 
							THEN '-'
						ELSE 
							(/*'Screen Level ' + ICR.SCREEN_LEVEL + CHAR(10) + CHAR(13) +*/ ICR_TYPE.DESCRIPTION) 
					END 
				FROM ITEM_SCREENED AS ICR WITH(NOLOCK)
				INNER JOIN ITEM_SCREEN_RESULT_TYPES AS ICR_TYPE ON ICR.RESULT_TYPE = ICR_TYPE.TYPE
				WHERE ICR.TIME_STAMP BETWEEN @DTFrom AND @DTTo
					AND ITI.GID = ICR.GID
				ORDER BY ICR.TIME_STAMP DESC
			) AS XRAY_STAT
		FROM ITEM_TRACKING AS ITI , LOCATIONS LOC, #CTP_GID2LPMAP_TEMP G2L WITH(NOLOCK)
		WHERE ITI.TIME_STAMP BETWEEN @DTFrom AND @DTTo
			AND ITI.LOCATION=LOC.LOCATION_ID
			AND ITI.GID=G2L.GID
			AND EXISTS(
						SELECT POST_XM_LOCATION FROM GET_RPT_EDS_LINE_DEVICE() 
						WHERE SUBSYSTEM=LOC.SUBSYSTEM AND POST_XM_LOCATION=LOC.LOCATION
					  )
			--AND LOC.LOCATION IN ('SS1-EXT','SS2-EXT','SS3-EXT','SS4-EXT')
	
	
	/**After Divert Point**/
	UNION ALL
	SELECT	G2L.LICENSE_PLATE AS LICENSE_PLATE, 
			LOC.SUBSYSTEM AS SUBSYSTEM,
			--(SELECT XRAY_ID FROM GET_RPT_EDS_LINE_DEVICE() WHERE SUBSYSTEM = LOC.SUBSYSTEM) AS XRAY_ID,
			'At Divert Point: '+ LOC.LOCATION + CHAR(10) + CHAR(13) +'Diverted to ' + PRD_LOC.LOCATION  AS ACT, 
			IPR.TIME_STAMP, 
			(	SELECT TOP 1 
					CASE 
						WHEN (IPR.TIME_STAMP < ICR.TIME_STAMP) OR (ICR_TYPE.DESCRIPTION) IS NULL 
							THEN '-' 
						ELSE 
							(/*'Screen Level ' + ICR.SCREEN_LEVEL + CHAR(10) + CHAR(13) +*/ ICR_TYPE.DESCRIPTION)
					END
				FROM ITEM_SCREENED AS ICR 
				INNER JOIN ITEM_SCREEN_RESULT_TYPES AS ICR_TYPE ON ICR.RESULT_TYPE = ICR_TYPE.TYPE
				WHERE (ICR.TIME_STAMP BETWEEN @DTFrom AND @DTTo) AND (ICR.GID = IPR.GID)
				ORDER BY ICR.TIME_STAMP
			) AS XRAY_STAT
	FROM ITEM_PROCEEDED AS IPR , LOCATIONS LOC, LOCATIONS PRD_LOC, #CTP_GID2LPMAP_TEMP G2L WITH(NOLOCK)
	WHERE IPR.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
		AND IPR.LOCATION=LOC.LOCATION_ID
		AND IPR.GID=G2L.GID
		AND IPR.PROCEED_LOCATION=PRD_LOC.LOCATION_ID
		AND EXISTS(
						SELECT DIVERT_LOCATION 
						FROM GET_RPT_EDS_LINE_DEVICE() ELD
						WHERE ((ELD.SUBSYSTEM=LOC.SUBSYSTEM AND ELD.DIVERT_LOCATION=LOC.LOCATION)
							OR LOC.LOCATION IN ('OOG1-15A','OOG2-17A','ED9-33A'))
				  )
		--AND (PRD_LOC.LOCATION IN ('CL1-02','AL1-02','CL2-02','AL2-02','CL3-02','AL3-02','CL4-02','AL4-02','CL6-01','AL1-11')) 
	
	
	--/**Before divert point**/
	--UNION ALL	
	--SELECT	G2L.LICENSE_PLATE AS LICENSE_PLATE, 
	--		(SELECT XRAY_ID FROM GET_RPT_EDS_LINE_DEVICE() WHERE SUBSYSTEM = LOC.SUBSYSTEM) AS XRAY_ID,
	--		'Prior to Divert Point at' + ' '+ ITI.LOCATION AS ACT, ITI.TIME_STAMP,
	--		(	SELECT TOP 1 
	--				CASE 
	--					WHEN (ITI.TIME_STAMP < ICR.TIME_STAMP)OR (ICR_TYPE.DESCRIPTION) IS NULL 
	--						THEN '-'	 
	--					ELSE 
	--						('Screen Level ' + ICR.SCREEN_LEVEL + ':' + ICR_TYPE.DESCRIPTION) 
	--				END 
	--			 FROM ITEM_SCREENED AS ICR WITH(NOLOCK)
	--			 INNER JOIN ITEM_SCREEN_RESULT_TYPES AS ICR_TYPE ON ICR.RESULT_TYPE = ICR_TYPE.TYPE
	--			 WHERE (ICR.TIME_STAMP BETWEEN @DTFrom AND @DTTo)AND(ITI.GID = ICR.GID)
	--			 ORDER BY ICR.TIME_STAMP
	--		) AS XRAY_STAT
	--FROM ITEM_TRACKING AS ITI , LOCATIONS LOC, #CTP_GID2LPMAP_TEMP G2L WITH(NOLOCK)
	--WHERE ITI.TIME_STAMP BETWEEN @DTFrom AND @DTTo
	--	AND ITI.LOCATION=LOC.LOCATION_ID
	--	AND ITI.GID=G2L.GID
	--	AND LOC.LOCATION IN ('SS1-12','SS2-12','SS3-12','SS4-12','AL1-08A')
	
	
	/**Lost Track**/
	UNION ALL	
	SELECT	G2L.LICENSE_PLATE AS LICENSE_PLATE, 
			LOC.SUBSYSTEM AS SUBSYSTEM,
			--(SELECT XRAY_ID FROM GET_RPT_EDS_LINE_DEVICE() WHERE SUBSYSTEM = LOC.SUBSYSTEM) AS XRAY_ID,
			'Lost tracking at '+ LOC.LOCATION as ACT,
			ILT.TIME_STAMP, '-' AS STAT		
	FROM ITEM_LOST AS ILT, LOCATIONS LOC, #CTP_GID2LPMAP_TEMP G2L WITH(NOLOCK)
	WHERE ILT.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
		AND ILT.LOCATION=LOC.LOCATION_ID
		AND ILT.GID=G2L.GID
		AND (LOC.LOCATION LIKE 'ED%' OR LOC.LOCATION LIKE 'OOG%')
	ORDER BY TIME_STAMP,LICENSE_PLATE,SUBSYSTEM;
		
END

--DECLARE @DTFrom [datetime]='2014-1-11';
--DECLARE @DTTo [datetime]='2014-1-12';
--EXEC stp_RPT22_CRITICALTRACKINGPEC_GWYTEST @DTFrom,@DTTo;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_DAYEND_ATRSTATS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_RPT_CLT_DAYEND_ATRSTATS]
		  @DTFrom DATETIME,
		  @DTTo DATETIME,
		  @ATRUNITS varchar(MAX)
AS
BEGIN
	CREATE TABLE #DAYEND_ATRSTATUS_TEMP
	(
		ATRUNIT VARCHAR(20),
		COUNT_BAGSSEEN INT,
		COUNT_BAGSREAD INT,
		COUNT_NOREAD INT,
		COUNT_VALIDTAGS INT,
		COUNT_CONFLICT_TAGS INT,
		COUNT_NOBSM INT,
		COUNT_LATEBAGS INT,
		READ_RATE FLOAT
	);

	INSERT INTO #DAYEND_ATRSTATUS_TEMP
	EXEC stp_RPT_CLT_ATR_OVERALL_STATISTIC @DTFrom,@DTTo,@ATRUNITS

	SELECT ATRUNIT, COUNT_BAGSSEEN, COUNT_BAGSREAD, COUNT_LATEBAGS, READ_RATE
	FROM #DAYEND_ATRSTATUS_TEMP;

	DROP TABLE #DAYEND_ATRSTATUS_TEMP;
END

--declare @DTFrom datetime='2013-12-18';
--declare @DTTo datetime='2013-12-27';
--DECLARE @ATRUNITS varchar(MAX)='SS1-2,SS2-2,SS2-2,SS3-2,ML1-2,ML2-2,ML3-2,ML4-2';
--EXEC stp_RPT14_DAYEND_ATRSTATS @DTFrom,@DTTo,@ATRUNITS;

--3 BDD STATS
--PROBLEM1: BAGS READ=BAGCNT_NORMAL?

GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_DAYEND_BDDSTATS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_RPT_CLT_DAYEND_BDDSTATS]
		  @DTFrom DATETIME,
		  @DTTo DATETIME
AS
BEGIN
	CREATE TABLE #DAYEND_BDDSTATUS_TEMP
	(
		BDD_ARRAY VARCHAR(20),
		BAGCNT_SEEN INT,
		BAGCNT_DIM INT,
		BAGCNT_OOG INT,
		BAGCNT_NORMAL INT,
		BAGCNT_NOTDIM INT
	)
	INSERT INTO #DAYEND_BDDSTATUS_TEMP
	EXEC stp_RPT_CLT_BDDSTATISTICS_OOG @DTFrom,@DTTo

	SELECT BDD_ARRAY,BAGCNT_NORMAL AS BAGS_READ, BAGCNT_DIM AS BAGS_DIM
	FROM #DAYEND_BDDSTATUS_TEMP;

	DROP TABLE #DAYEND_BDDSTATUS_TEMP;
END

--declare @DTFrom datetime='2013-12-18';
--declare @DTTo datetime='2013-12-27';
--EXEC stp_RPT14_DAYEND_BDDSTATS @DTFrom,@DTTo

--4 MES STATS

GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_DAYEND_EDSSTATS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_RPT_CLT_DAYEND_EDSSTATS]
		  @DTFrom DATETIME,
		  @DTTo DATETIME
AS
BEGIN
	CREATE TABLE #EDS_STATUS_TEMP
	(
		SUBSYSTEM_TYPE VARCHAR(30),
		SUBSYSTEM VARCHAR(20),
		BAGS INT,
		BAGS_CLEARED INT,
		BAGS_ALARMED INT,
		CLEARED_RATE FLOAT
	)

	INSERT INTO #EDS_STATUS_TEMP
	EXEC stp_RPT_CLT_LOADBALANCING_EDS @DTFrom,@DTTo;

	SELECT SUBSYSTEM AS EDS_MACHINE, BAGS, BAGS_CLEARED, BAGS_ALARMED, CLEARED_RATE
	FROM #EDS_STATUS_TEMP
	WHERE SUBSYSTEM_TYPE='EDS MACHINES';

	DROP TABLE #EDS_STATUS_TEMP;
END

--declare @DTFrom datetime='2013-12-15';
--declare @DTTo datetime='2013-12-27';
--EXEC stp_RPT14_DAYEND_EDSSTATS @DTFrom,@DTTo;

--6 OUTPUTS


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_DAYEND_INPUT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_RPT_CLT_DAYEND_INPUT]
		  @DTFrom DATETIME,
		  @DTTo DATETIME
AS
BEGIN
	--SELECT	LOC.LOCATION AS 'LOCATION', 
	--		COUNT(GID.GID) AS 'COUNT' 
	--FROM GID_USED GID, LOCATIONS LOC WITH(NOLOCK)
	--WHERE	GID.BAG_TYPE='01'--normal bag
	--		AND GID.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
	--		AND GID.LOCATION=LOC.LOCATION_ID
	--		AND EXISTS(SELECT GID_LOCATION FROM MIS_SS_LINE_DEVICE SLD WHERE LOC.LOCATION=SLD.GID_LOCATION)
	--GROUP BY LOC.LOCATION

	SELECT MBCR.SUBSYSTEM AS 'LOCATION',SUM(MBC.DIFFERENT) AS 'COUNT'
	FROM MDS_COUNT MBC, MDS_COUNTERS MBCR WITH(NOLOCK)
	WHERE MBC.COUNTER_ID=MBCR.COUNTER_ID
	AND MBC.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
	AND (MBCR.SUBSYSTEM LIKE '%TC%' OR MBCR.SUBSYSTEM LIKE '%IC%' OR MBCR.SUBSYSTEM LIKE '%CS%' OR MBCR.SUBSYSTEM LIKE 'OS%')
	AND MBCR.TYPE='CV'
	GROUP BY MBCR.SUBSYSTEM;
END
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_DAYEND_MESSTATS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_RPT_CLT_DAYEND_MESSTATS]
		  @DTFrom DATETIME,
		  @DTTo DATETIME
AS
BEGIN
	SELECT LOC.LOCATION AS MES_STATION, COUNT(DISTINCT IRY.GID) AS BAGS
	FROM ITEM_READY IRY, LOCATIONS LOC WITH(NOLOCK)
	WHERE IRY.TIME_STAMP BETWEEN @DTFrom AND @DTTo
		AND IRY.LOCATION=LOC.LOCATION_ID
	GROUP BY LOC.SUBSYSTEM, LOC.LOCATION;
END

--declare @DTFrom datetime='2013-12-18';
--declare @DTTo datetime='2013-12-27';
--EXEC stp_RPT14_DAYEND_MESSTATS @DTFrom,@DTTo;

--5 EDS STATS


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_DAYEND_OUTPUT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[stp_RPT_CLT_DAYEND_OUTPUT]
		  @DTFrom DATETIME,
		  @DTTo DATETIME
AS
BEGIN
	SELECT LOC.LOCATION AS OUTPUT_LOCATION, COUNT(IPR.GID) AS BAGS
	FROM ITEM_PROCEEDED IPR, LOCATIONS LOC
	WHERE IPR.PROCEED_LOCATION=LOC.LOCATION_ID
		AND LOC.LOCATION LIKE 'MU%'
		AND IPR.TIME_STAMP BETWEEN @DTFrom AND @DTTo
	GROUP BY LOC.LOCATION;
END
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_EDSID]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_EDSID]
		  --@SCREEN_DATE datetime
		  @DTFROM DATETIME,
		  @DTTO DATETIME
AS
BEGIN
--Problem1: 1500P time stamp is not the removed time
--Problem2: What is the location name of CBRA in IPR proceed location

	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;
	DECLARE @MINUTERANGE INT=60;

	--Create temp table for final result
	CREATE TABLE #EI_EDSID_TEMP 
	(
		GID bigint,
		LICENSE_PLATE varchar(10),
		GIDUSE_TIMESTAMP datetime,
		SCREEN_LOCATION varchar(20),
		SCREENED_TIME datetime,
		CLEARED_TIME datetime,
		CLEARED_LOCATION VARCHAR(20),
		CBRA_GID bigint,
		CBRA_DELIVERED_TIME datetime,
		CBRA_REMOVED_TIME datetime,
		BMAM_BAG_TYPE varchar(15)
	);

	---------------#REGION 1 FOR IN-SPEC(NORMAL) BAGGAGES
	--1. Query baggage measure info into final table
	--DECLARE @NEW_SCREEN_DATE datetime=CONVERT(datetime,CONVERT(varchar,@SCREEN_DATE,103),103);

	-------------------------------------Commented by Guo Wenyu 2014/1/4-------------------------------------
	--Because some bags are lost during moving, so the GID from GID_USED should be used as the index in the report

	--INSERT INTO #EI_EDSID_TEMP
	--SELECT DISTINCT im.GID, NULL AS LICENSE_PLATE, NULL AS GIDUSE_TIMESTAMP, NULL AS SCREEN_LOCATION, NULL AS SCREENED_TIME, 
	--	   NULL AS CLEARED_TIME, NULL AS CBRA_GID, NULL AS CBRA_DELIVERED_TIME, NULL AS CBRA_REMOVED_TIME,
	--	   'In-Spec' AS BMAM_BAG_TYPE
	--	   --CASE im.TYPE
	--		  -- WHEN '01' THEN 'in-Spec'
	--		  -- WHEN '00' THEN 'OOG'
	--		  -- ELSE 'wrong'
	--	   --END as BMAM_BAG_TYPE
	--FROM ITEM_MEASURED im WITH(NOLOCK)
	--WHERE im.TIME_STAMP BETWEEN @NEW_SCREEN_DATE AND DATEADD(DAY,@DATERANGE,@NEW_SCREEN_DATE)
	--	AND IM.TYPE='2'; --'in-Spec'NORMAL BAG
	
	-------------------------------------New Code added by Guo Wenyu 2014/1/4-------------------------------------
	INSERT INTO #EI_EDSID_TEMP
	SELECT DISTINCT GID.GID, NULL AS LICENSE_PLATE, GID.TIME_STAMP AS GIDUSE_TIMESTAMP, NULL AS SCREEN_LOCATION, NULL AS SCREENED_TIME, 
		   NULL AS CLEARED_TIME,NULL AS CLEARED_LOCATION, NULL AS CBRA_GID, NULL AS CBRA_DELIVERED_TIME, NULL AS CBRA_REMOVED_TIME,
		   CASE 
			   WHEN IM.TYPE='2' THEN 'In-Spec'
			   WHEN IM.TYPE='1' THEN 'OOG'
			   WHEN IM.TYPE IS NULL THEN ''
			   ELSE ''
		   END as BMAM_BAG_TYPE
	FROM LOCATIONS LOC,GID_USED GID WITH(NOLOCK)
	LEFT JOIN ITEM_MEASURED IM WITH(NOLOCK) 
		ON GID.GID=IM.GID
		AND IM.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO) --DATEADD(DAY,@DATERANGE,@NEW_SCREEN_DATE)
	WHERE GID.TIME_STAMP BETWEEN @DTFROM AND @DTTO --DATEADD(DAY,@DATERANGE,@NEW_SCREEN_DATE)
		AND GID.LOCATION=LOC.LOCATION_ID
		AND (LOC.LOCATION LIKE 'SS%' OR LOC.LOCATION LIKE 'ED%' OR LOC.LOCATION LIKE 'OOG%' OR LOC.LOCATION LIKE 'SB%')
		AND (LOC.LOCATION <> 'OOG1-5' AND LOC.LOCATION <> 'OOG2-4');
	-------------------------------------END by Guo Wenyu 2014/1/4 END-------------------------------------


	--select * from #EI_EDSID_TEMP where gid='3211000311';

	CREATE NONCLUSTERED INDEX #EI_EDSID_TEMP_GID ON #EI_EDSID_TEMP(GID);

	--2. Update GID time stamp(GIDUSE_TIMESTAMP) into final table
	--Commented by Guo Wenyu 2014/1/4
	--Same reason with 1
	--UPDATE eet
	--SET eet.GIDUSE_TIMESTAMP=gu.TIME_STAMP
	--FROM GID_USED gu, #EI_EDSID_TEMP eet WITH(NOLOCK)
	--WHERE eet.GID=gu.GID
	--	AND gu.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@SCREEN_DATE) AND DATEADD(DAY,@DATERANGE,@SCREEN_DATE);


	--3. Update license plate(LICENSE_PLATE) into final table
	UPDATE eet
	SET eet.LICENSE_PLATE=
		CASE
			--IATA TAG
			WHEN ISC.LICENSE_PLATE1 LIKE '0%' AND ISC.LICENSE_PLATE1<>'0000000000' AND ISC.LICENSE_PLATE1<>'999999999' AND LEN(LICENSE_PLATE1)=10
				THEN ISC.LICENSE_PLATE1
			WHEN ISC.LICENSE_PLATE2 LIKE '0%' AND ISC.LICENSE_PLATE2<>'0000000000' AND ISC.LICENSE_PLATE2<>'999999999' AND LEN(LICENSE_PLATE1)=10
				THEN ISC.LICENSE_PLATE2
			--Fallback Tag
			WHEN LEN(ISC.LICENSE_PLATE1)=10 AND ISC.LICENSE_PLATE1 LIKE '1%'
				THEN ISC.LICENSE_PLATE1 --NULL
			WHEN LEN(ISC.LICENSE_PLATE2)=10 AND ISC.LICENSE_PLATE2 LIKE '1%'
				THEN ISC.LICENSE_PLATE2 --NULL
			--4 DIGIT TAG
			WHEN LEN(ISC.LICENSE_PLATE1)=4
				THEN ISC.LICENSE_PLATE1
			WHEN LEN(ISC.LICENSE_PLATE2)=4
				THEN ISC.LICENSE_PLATE2
			ELSE ISC.LICENSE_PLATE1
		END
	FROM ITEM_SCANNED isc, #EI_EDSID_TEMP eet WITH(NOLOCK)
	WHERE isc.GID=eet.GID
		AND isc.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO);

	CREATE NONCLUSTERED INDEX #EI_EDSID_TEMP_LP ON #EI_EDSID_TEMP(LICENSE_PLATE);

	--4. Query screen info into a tempary table #EI_ITEM_SCREENED_TEMP
	SELECT icr.GID, icr.SCREEN_LEVEL, loc.LOCATION, icr.TIME_STAMP, icr.RESULT_TYPE INTO #EI_ITEM_SCREENED_TEMP
	FROM ITEM_SCREENED icr, LOCATIONS loc, #EI_EDSID_TEMP eet WITH(NOLOCK)
	WHERE eet.GID=icr.GID
		AND (icr.SCREEN_LEVEL='1' OR icr.SCREEN_LEVEL='2' OR icr.SCREEN_LEVEL='3')
		AND icr.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
		AND icr.LOCATION=loc.LOCATION_ID;
		--AND eet.BMAM_BAG_TYPE='In-Spec';

	--SELECT * FROM #EI_ITEM_SCREENED_TEMP;

	--5. Update screen info(SCREEN_LOCATION,SCREENED_TIME) into final table when bag type is 'in-spec'
	--SCREEN BY: ITEM_SCREENED.LOCATION
	--TIME SCREENED: ITEM_SCREENED.TIME_STAMP
	--TIME CLEARED: ITEM_PROCEEDED.TIME_STAMP to clear line
	UPDATE eet
	SET		eet.SCREEN_LOCATION=ICR.LOCATION, 
			eet.SCREENED_TIME=ICR.TIME_STAMP, 
			EET.CLEARED_TIME=IPR.TIME_STAMP, 
			EET.CLEARED_LOCATION=(	SELECT TOP 1 PRELOC.LOCATION
									FROM LOCATIONS PRELOC
									WHERE IPR.PROCEED_LOCATION=PRELOC.LOCATION_ID)
	FROM	#EI_EDSID_TEMP EET
	--AFTER FAT, IT SHOULD BE MODIFIED AS BELOW:
	LEFT JOIN #EI_ITEM_SCREENED_TEMP ICR ON EET.GID=ICR.GID 
	----SCREENED_TIME is assigned to item_tracking time_stamp before EDS
	--LEFT JOIN ITEM_TRACKING ITI WITH(NOLOCK)
	--	ON EET.GID=ITI.GID 
	--	AND ITI.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@SCREEN_DATE) AND DATEADD(DAY,@DATERANGE,@SCREEN_DATE)
	--	AND EXISTS(
	--				SELECT ELD.POST_XM_LOCATION 
	--				FROM GET_RPT_EDS_LINE_DEVICE() ELD, LOCATIONS LOC
	--				WHERE ELD.SUBSYSTEM=LOC.SUBSYSTEM AND ELD.PRE_XM_LOCATION=LOC.LOCATION 
	--					AND ITI.LOCATION=LOC.LOCATION_ID
	--			  )

	--SCREENED_TIME is assigned to ITEM_PROCEEDED time_stamp to clear line
	LEFT JOIN ITEM_PROCEEDED IPR WITH(NOLOCK)
		ON EET.GID=IPR.GID 
		AND IPR.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
		AND EXISTS(
					SELECT ELD.EDS_LOCATION 
					FROM GET_RPT_EDS_LINE_DEVICE() ELD, LOCATIONS LOC
					WHERE ELD.SUBSYSTEM=LOC.SUBSYSTEM 
						AND ELD.CLEAR_LOCATION=LOC.LOCATION
						--AND (ELD.CLEAR_LOCATION=LOC.LOCATION OR ELD.REJECT_LOCATION=LOC.LOCATION)
						AND IPR.PROCEED_LOCATION=LOC.LOCATION_ID
					UNION ALL
					SELECT PRELOC.LOCATION
					FROM LOCATIONS PRELOC
					WHERE IPR.PROCEED_LOCATION=PRELOC.LOCATION_ID
						AND PRELOC.LOCATION IN ('OOG1-15B','OOG2-17B','ED9-33B')
				  )
	--WHERE EET.GID=ICR.GID 
		--AND icr.SCREEN_LEVEL='1'
		--AND (icr.RESULT_TYPE='12' OR icr.RESULT_TYPE='22')--CLEARED

	
	
	----6. Update screen cleared time(CLEARED_TIME) into final table
	--UPDATE eet
	--SET eet.CLEARED_TIME=icr.TIME_STAMP
	--FROM #EI_ITEM_SCREENED_TEMP icr, #EI_EDSID_TEMP eet
	--WHERE eet.GID=icr.GID 
	--	AND icr.SCREEN_LEVEL='2'
	--	AND (icr.RESULT_TYPE='12' OR icr.RESULT_TYPE='22');--CLEARED

	--------------------END #REGION 1 END----------------------

	---------------#REGION 2 FOR OOG BAGGAGES------------------
	
	--7. Insert OOG bags GID into final table from the oog lines
	INSERT INTO #EI_EDSID_TEMP
	SELECT
	    GID.GID,
	    NULL AS LICENSE_PLATE,
	    GID.TIME_STAMP AS GIDUSE_TIMESTAMP,
	    NULL AS SCREEN_LOCATION,
	    NULL AS SCREENED_TIME,
	    NULL AS CLEARED_TIME,
		NULL AS CLEARED_LOCATION,
	    GID.GID AS CBRA_GID,
	    NULL AS CBRA_DELIVERED_TIME,
	    NULL AS CBRA_REMOVED_TIME,
	    'OOG' AS BMAM_BAG_TYPE
	FROM GID_USED GID, LOCATIONS LOC WITH(NOLOCK)
	WHERE GID.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		AND GID.LOCATION=LOC.LOCATION_ID
		AND (LOC.LOCATION = 'OOG1-5' OR LOC.LOCATION = 'OOG2-4');

	--------------------END #REGION 2 END----------------------

	--8. Update CBRA Delivered time(CBRA_DELIVERED_TIME) into final table
	UPDATE eet
	SET eet.CBRA_DELIVERED_TIME=ipr.TIME_STAMP
	FROM ITEM_PROCEEDED ipr, LOCATIONS loc, #EI_EDSID_TEMP eet WITH(NOLOCK)
	WHERE ipr.GID=eet.GID AND eet.GID IS NOT NULL
		AND ipr.PROCEED_LOCATION=loc.LOCATION_ID AND loc.SUBSYSTEM LIKE 'SB%'--Maybe another name
		AND ipr.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)



	--9. Update CBRA Removed time and new GID(CBRA_REMOVED_TIME) into final table
	--some problem here
	--PROBLEM: Telegram 1500P is not sent when bags are removed, but before bags are moved to inspection tables.
	UPDATE eet
	SET eet.CBRA_GID=i1500.GID, eet.CBRA_REMOVED_TIME=i1500.TIME_STAMP
	FROM ITEM_1500P i1500, #EI_EDSID_TEMP eet WITH(NOLOCK)
	WHERE i1500.GID=eet.GID
		AND i1500.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

	select * from #EI_EDSID_TEMP
	ORDER BY GIDUSE_TIMESTAMP;
END

		  
--DECLARE @DTFROM datetime='2014-1-4';
--DECLARE @DTTO DATETIME DATETIME=''
--exec stp_RPT_EDSID_GWYTEST @screendate;

GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_EDSMalfunction]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[stp_RPT_CLT_EDSMalfunction]
		  @DTFrom datetime, 
		  @DTTo datetime
AS
BEGIN
	SELECT	ALM_ALMAREA1 AS ALM_SUBSYSTEM, 
			MALM.ALM_ALMEXTFLD2 AS EDS_ID, --ALM_ALMEXTFLD2,ELD.EDS_LOCATION
			ALM_STARTTIME, 
			ALM_ENDTIME,
			ALM_MSGDESC AS ALM_DESCRIPTION
	FROM	DBO.GET_RPT_EDS_LINE_DEVICE() AS ELD,
			MDS_ALARMS AS MALM WITH(NOLOCK)
	WHERE	MALM.ALM_ALMAREA1=ELD.SUBSYSTEM
			AND MALM.ALM_ALMEXTFLD2=('XR-'+ ELD.SUBSYSTEM)
			AND ALM_UNCERTAIN = 0
			AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo 
			AND MALM.ALM_MSGTYPE='ALARM'
			AND MALM.ALM_ALMAREA2<>'AA_RDRV'
	ORDER BY ALM_STARTTIME


END

--DECLARE @DTFrom datetime='2014-1-7';
--DECLARE @DTTo datetime='2014-1-10';
--EXEC stp_RPT21_EDSMalfunction @DTFrom,@DTTo
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_EDSOperation]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_CLT_EDSOperation]
		  @DTFrom datetime, 
		  @DTTo datetime
AS
BEGIN

	--From Phoenix
	--EDS Fault Start Time and End Time
	--SELECT ALM_ALMAREA1 AS XRAY_ID, ALM_STARTTIME AS FAULTSTART, ALM_ENDTIME AS FAULTEND
	--FROM MDS_ALARMS
	--WHERE ALM_ALMAREA2 = 'AA_NRRV' AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo
	--ORDER BY ALM_STARTTIME

	--EDS Startup time and Shutdown Time
	--SELECT ALM_ALMAREA1 AS XRAY_ID, ALM_STARTTIME AS STARTUP, ALM_ENDTIME AS SHUTDWN
	--FROM MDS_ALARMS 
	--WHERE ALM_ALMAREA2 = 'AA_XBPM' AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo
	--ORDER BY ALM_STARTTIME

	--EDS Operation Time
	--SELECT ALM_ALMAREA1 AS XRAY_ID,SUM(DATEDIFF(S,ALM_STARTTIME,ALM_ENDTIME)) AS TOTAL
	--FROM MDS_ALARMS
	--WHERE ALM_ALMAREA2 = 'AA_RDRV' AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo AND ALM_ENDTIME BETWEEN @DTFrom AND @DTTo
	--GROUP BY ALM_ALMAREA1

	CREATE TABLE #EDS_OPER_TEMP
	(
		EDS_ID VARCHAR(20),
		SUBSYSTEM VARCHAR(20),
		EDS_LOCATION VARCHAR(20),
		OPER_STARTTIME DATETIME,
		OPER_ENDTIME DATETIME,
		MANUAL_ENDTIME DATETIME,
		OPER_DURATION INT,
		BAGS_ALARM INT,
		BAGS_CLEAR INT
	);
	
	DECLARE @DAYRANGE INT=1;
	DECLARE @NOW DATETIME=GETDATE();

	--1. EDS Operation time
	INSERT INTO #EDS_OPER_TEMP
	SELECT	MALM.ALM_ALMEXTFLD2 AS EDS_ID,  --ELD.XRAY_ID AS EDS_ID, --ALM_ALMEXTFLD2
			MALM.ALM_ALMAREA1 AS SUBSYSTEM,
			ELD.EDS_LOCATION AS EDS_LOCATION,
			ALM_STARTTIME AS OPER_STARTTIME, 
			ALM_ENDTIME AS OPER_ENDTIME,
			CASE 
				WHEN ALM_ENDTIME IS NOT NULL THEN ALM_ENDTIME
				WHEN ALM_ENDTIME IS NULL AND @NOW<DATEADD(DAY,@DAYRANGE,CONVERT(DATETIME,CONVERT(VARCHAR,ALM_STARTTIME,103),103)) THEN @NOW
				ELSE NULL --HDATEADD(DAY,@DAYRANGE,CONVERT(DATETIME,CONVERT(VARCHAR,ALM_STARTTIME,103),103))
			END AS MANUAL_ENDTIME,
			0 AS OPER_DURATION,
			0 AS BAGS_ALARM,
			0 AS BAGS_CLEAR	
	FROM	DBO.GET_RPT_EDS_LINE_DEVICE() AS ELD,
			MDS_ALARMS AS MALM WITH(NOLOCK)
	WHERE	MALM.ALM_ALMAREA1=ELD.SUBSYSTEM
			--AND MALM.ALM_ALMEXTFLD2=DBO.RPT_FORMAT_LOCATION(ELD.EDS_LOCATION)
			AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo 
			AND MALM.ALM_MSGTYPE='ALARM'
			AND MALM.ALM_ALMAREA2='AA_RDRV'  --READY TO RECEIVE: OPERATION
	ORDER BY ALM_STARTTIME;

	UPDATE #EDS_OPER_TEMP
	SET OPER_DURATION=DATEDIFF(SECOND,OPER_STARTTIME,MANUAL_ENDTIME) 
	WHERE MANUAL_ENDTIME IS NOT NULL
	

	--2. the count of bag cleared during EDS operation time
	SELECT	EOT.SUBSYSTEM,EOT.EDS_LOCATION,EOT.OPER_STARTTIME,COUNT(ICR.GID) AS BAGS_CLEAR
	INTO	#EDS_EDSCLEAR_TEMP
	FROM	#EDS_OPER_TEMP EOT, 
			ITEM_SCREENED ICR,
			LOCATIONS LOC WITH(NOLOCK)
	WHERE	EOT.SUBSYSTEM=LOC.SUBSYSTEM AND EOT.EDS_LOCATION=DBO.RPT_FORMAT_LOCATION(LOC.LOCATION)
		AND LOC.LOCATION_ID=ICR.LOCATION
		AND ICR.TIME_STAMP BETWEEN EOT.OPER_STARTTIME AND EOT.MANUAL_ENDTIME
		AND EOT.MANUAL_ENDTIME IS NOT NULL
		--AND (ICR.SCREEN_LEVEL='1' OR ICR.SCREEN_LEVEL='2' OR ICR.SCREEN_LEVEL='3')
		AND ICR.RESULT_TYPE LIKE '2%' --MACHINE CLEAR
	GROUP BY EOT.SUBSYSTEM,EOT.EDS_LOCATION,EOT.OPER_STARTTIME;

	--3. the count of bag alarmed during EDS operation time
	SELECT	EOT.SUBSYSTEM,EOT.EDS_LOCATION,EOT.OPER_STARTTIME,COUNT(ICR.GID) AS BAGS_ALARM
	INTO	#EDS_EDSALARM_TEMP
	FROM	#EDS_OPER_TEMP EOT, 
			ITEM_SCREENED ICR,
			LOCATIONS LOC WITH(NOLOCK)
	WHERE	EOT.SUBSYSTEM=LOC.SUBSYSTEM AND EOT.EDS_LOCATION=DBO.RPT_FORMAT_LOCATION(LOC.LOCATION)
		AND LOC.LOCATION_ID=ICR.LOCATION
		AND ICR.TIME_STAMP BETWEEN EOT.OPER_STARTTIME AND EOT.MANUAL_ENDTIME
		AND EOT.MANUAL_ENDTIME IS NOT NULL
		--AND (ICR.SCREEN_LEVEL='1' OR ICR.SCREEN_LEVEL='2'OR ICR.SCREEN_LEVEL='3')
		AND ICR.RESULT_TYPE LIKE '1%' --MACHINE ALARM
	GROUP BY EOT.SUBSYSTEM,EOT.EDS_LOCATION,EOT.OPER_STARTTIME;

	--4. update the counts of cleared bags and alarmed bags+
	UPDATE	EOT
	SET		EOT.BAGS_CLEAR=CLR.BAGS_CLEAR, EOT.BAGS_ALARM=ALM.BAGS_ALARM
	FROM	#EDS_OPER_TEMP EOT, #EDS_EDSCLEAR_TEMP CLR, #EDS_EDSALARM_TEMP ALM
	WHERE	EOT.SUBSYSTEM=CLR.SUBSYSTEM AND EOT.EDS_LOCATION=CLR.EDS_LOCATION
		AND EOT.OPER_STARTTIME=CLR.OPER_STARTTIME
		AND	EOT.SUBSYSTEM=ALM.SUBSYSTEM AND EOT.EDS_LOCATION=ALM.EDS_LOCATION
		AND EOT.OPER_STARTTIME=ALM.OPER_STARTTIME;

	SELECT EOT.EDS_ID, EOT.OPER_STARTTIME, EOT.OPER_ENDTIME, EOT.OPER_DURATION, EOT.BAGS_ALARM, EOT.BAGS_CLEAR
	FROM #EDS_OPER_TEMP EOT;
END

--DECLARE	@DTFrom datetime='2014/1/10 18:45:06';
--DECLARE @DTTo datetime='2014/1/11 18:45:06';
--EXEC stp_RPT21_EDSOperation @DTFrom,@DTTo

GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_EquipCorrection]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_EquipCorrection]
		  @DTFrom datetime, 
		  @DTTo datetime,
		  @Subsystem varchar(max),
		  @EquipmentID varchar(max),
		  @FaultType varchar(max)
AS
BEGIN
	SELECT	ALM_ALMAREA1 AS ALM_SUBSYSTEM, 
			ALM_ALMEXTFLD2 AS ALM_EQUIPID, 
			ALM_STARTTIME AS ALM_TIMESET,
			ALM_ENDTIME AS ALM_TIMECLEAR, 
			ALM_MSGDESC AS ALM_DESCRIPTION,
			CASE
				WHEN ALM_ENDTIME IS NOT NULL THEN DATEDIFF(SECOND,ALM_STARTTIME,ALM_ENDTIME)
				ELSE 0
			END  AS ALM_DURATION,
			LOC.INTERNAL_LOC AS HIDDEN_LOC
	FROM	MDS_ALARMS, LOCATIONS LOC WITH(NOLOCK)
	WHERE	ALM_UNCERTAIN = 0
			AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo 
			AND ALM_ALMAREA1 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@Subsystem)) 
			AND ALM_ALMEXTFLD2 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@EquipmentID)) 
			AND ALM_ALMAREA2 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@FaultType))
			AND ALM_ALMAREA1=LOC.SUBSYSTEM AND ALM_ALMEXTFLD2=LOC.LOCATION
	ORDER BY LOC.SUBSYSTEM,LOC.INTERNAL_LOC,ALM_STARTTIME
END

--DECLARE @DTFrom datetime='2014/1/11 18:56:26' 
--DECLARE @DTTo datetime='2014/1/12 19:26:32'
--DECLARE @Subsystem varchar(max)='RI1'
--DECLARE @EquipmentID varchar(max)='RI1-04SD'
--DECLARE @FaultType varchar(max)='AA_SDAL'
--EXEC stp_RPT0502_EquipCorrection @DTFrom,@DTTo,@Subsystem,@EquipmentID,@FaultType;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_EquipFaultSummary]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_EquipFaultSummary]
		  @DTFrom datetime, 
		  @DTTo datetime,
		  @FaultType varchar(max)
AS
BEGIN

	SELECT	ALM_ALMAREA2,
			DATEDIFF(SECOND,ALM_STARTTIME,ALM_ENDTIME) AS ALM_DURATION
	INTO #EFS_ALARM_DETAIL_TEMP
	FROM	MDS_ALARMS WITH(NOLOCK)
	WHERE	ALM_UNCERTAIN = 0
			AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo 
			AND ALM_ALMAREA2 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@FaultType));

	SELECT	EAD.ALM_ALMAREA2,
			ISNULL(RF.FAULT_DESCRIPTION, EAD.ALM_ALMAREA2) AS EQUIP_FAULTTYPE, 
			COUNT(EAD.ALM_ALMAREA2) AS OCCURRENCES, 
			SUM(EAD.ALM_DURATION) AS FAULT_DURATION
	FROM #EFS_ALARM_DETAIL_TEMP EAD
	LEFT JOIN REPORT_FAULT RF ON EAD.ALM_ALMAREA2=RF.FAULT_NAME
	GROUP BY EAD.ALM_ALMAREA2,RF.FAULT_DESCRIPTION;

	DROP TABLE #EFS_ALARM_DETAIL_TEMP;

END

--DECLARE @DTFrom datetime='2009-12-01';
--DECLARE @DTTo datetime='2009-12-31';
--DECLARE @FaultType varchar(max)='AA_ENUS,AA_BJAM,AA_ESTP,AA_ENUS,AA_ISOF,AA_CNFT';
--EXEC stp_RPT08_EquipFaultSummary @DTFrom,@DTTo,@FaultType;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_EquipOperation_Diverter]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_EquipOperation_Diverter]
		@DTFrom [datetime],
		@DTTo [datetime],
		@SubSystem varchar(MAX)
AS
BEGIN

	SELECT	MBCR.SUBSYSTEM, 
			MBCR.LOCATION AS DIVERTER_ID, 
			CASE
				WHEN MBCR.DESCRIPTION LIKE '%EXTENDED%' THEN 'EXTENDED' --extended
				WHEN MBCR.DESCRIPTION LIKE '%HOME%' THEN 'HOME' --retract
				ELSE 'WRONG TYPE'
			END AS MOVE_TYPE,
			SUM(DIFFERENT) AS MOVE_CNT

	INTO	#EOD_DIVERTER_TEMP

	FROM	MDS_COUNT MBC, 
			MDS_COUNTERS MBCR WITH(NOLOCK)

	WHERE	MBC.COUNTER_ID=MBCR.COUNTER_ID
			AND (MBCR.COUNTER_ID LIKE '%EXT%' OR MBCR.COUNTER_ID LIKE '%RTC%') --May be other name
			AND (MBCR.DESCRIPTION LIKE '%EXTENDED%' OR MBCR.DESCRIPTION LIKE '%HOME%') --May be other name
			AND MBCR.SUBSYSTEM IN (SELECT * FROM RPT_GETPARAMETERS(@SubSystem))
			AND MBC.TIME_STAMP BETWEEN @DTFrom AND @DTTo 

	GROUP BY	MBCR.SUBSYSTEM,
				MBCR.LOCATION,
				CASE
					WHEN MBCR.DESCRIPTION LIKE '%EXTENDED%' THEN 'EXTENDED' --extended
					WHEN MBCR.DESCRIPTION LIKE '%HOME%' THEN 'HOME' --retract
					ELSE 'WRONG TYPE'
				END;


	SELECT	EXT_DIVR.SUBSYSTEM,
			EXT_DIVR.DIVERTER_ID,
			EXT_DIVR.MOVE_CNT AS EXTENDED_CNT,
			HME_DIVR.MOVE_CNT AS HOME_CNT
	FROM	#EOD_DIVERTER_TEMP EXT_DIVR,
			#EOD_DIVERTER_TEMP HME_DIVR
	WHERE	EXT_DIVR.SUBSYSTEM=HME_DIVR.SUBSYSTEM
		AND EXT_DIVR.DIVERTER_ID=HME_DIVR.DIVERTER_ID
		AND EXT_DIVR.MOVE_TYPE='HOME'
		AND HME_DIVR.MOVE_TYPE='EXTENDED';

	
END

--DECLARE @DTFrom datetime='2013-11-01';
--DECLARE @DTTo datetime='2013-12-25';
--DECLARE @Subsystem varchar(max)='ED1,ED2,ED3,ED4,SS1,SS2';
--EXEC stp_RPT06_EquipOperation_Diverter @DTFrom,@DTTo,@Subsystem;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_EquipOperation_JAMPHOTOCELL]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[stp_RPT_CLT_EquipOperation_JAMPHOTOCELL]
		@DTFrom [datetime],
		@DTTo [datetime],
		@SubSystem varchar(MAX)
AS
BEGIN


	--SELECT	MBCR.SUBSYSTEM, 
	--		MBCR.LOCATION AS PhotoCellID, 
	--		SUM(DIFFERENT) AS TOTAL_BAGS
	--FROM	MDS_BAG_COUNT MBC, 
	--		MDS_BAG_COUNTERS MBCR,
	--		LOCATIONS LOC WITH(NOLOCK)
	--WHERE	MBC.COUNTER_ID=MBCR.COUNTER_ID
	--		AND MBCR.SUBSYSTEM=LOC.SUBSYSTEM AND MBCR.LOCATION=LOC.LOCATION
	--		AND LOC.TRACKED<>1 --NOT TRACKING PHOTOCELL
	--		AND MBCR.SUBSYSTEM IN (SELECT * FROM RPT_GETPARAMETERS(@SubSystem))
	--		AND MBC.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
	--GROUP BY MBCR.SUBSYSTEM,MBCR.LOCATION


	SELECT	ALM_ALMAREA1 AS SUBSYSTEM 
			,ALM_ALMEXTFLD2 AS PhotoCellID 
			,COUNT(ALM_ALMEXTFLD2) AS JAM_BAGS
	FROM	MDS_ALARMS MALM
			,LOCATIONS LOC WITH(NOLOCK)
	WHERE	ALM_STARTTIME BETWEEN @DTFrom AND @DTTo 
			AND ALM_UNCERTAIN = 0 
			AND ALM_ALMAREA1 IN (SELECT * FROM  RPT_GETPARAMETERS(@SubSystem)) 
			AND ALM_ALMAREA2 = 'AA_BJAM'
			AND MALM.ALM_ALMAREA1=LOC.SUBSYSTEM AND MALM.ALM_ALMEXTFLD2=DBO.RPT_FORMAT_LOCATION(LOC.LOCATION)
			AND LOC.TRACKED<>1 --NOT TRACKING PHOTOCELL
			--AND EXISTS (SELECT LOCATION FROM LOCATIONS WHERE TRACKED = 1 AND ALM_ALMEXTFLD2=LOCATIONS.LOCATION) 
	GROUP BY ALM_ALMAREA1, ALM_ALMEXTFLD2

END

--DECLARE @DTFrom datetime='2013-11-01';
--DECLARE @DTTo datetime='2013-12-25';
--DECLARE @Subsystem varchar(max)='ED1,ED2,ED3,ED4,SS1,SS2';
--EXEC stp_RPT06_EquipOperation_JAMPHOTOCELL @DTFrom,@DTTo,@Subsystem;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_IndvFlightSummary]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_IndvFlightSummary]
		  @DTFROM datetime , 
		  @DTTO datetime,
		  @AIRLINE varchar(max) , 
		  @FLIGHTNUM varchar(max)
		  --@DETAIL_MARK int
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;

	--Create temp table for final result

	
	CREATE TABLE #IFS_FLIGHTSUMMARY_TEMP 
	(
		FLIGHT_NUMBER VARCHAR(5),
		AIRLINE VARCHAR(3),
		CLOSEOUT_TIME DATETIME,
		NUMBER_ALLBAGS INT,
		NUMBER_BAGSORTED INT,
		NUMBER_BAGS_ONTIME INT,
		NUMBER_BAGS_INSYSTEM INT,
		NUMBER_BAGS_LATE INT
	);

	--CREATE TABLE FOR BAGGAGES DETAIL
	CREATE TABLE #IFS_BAGSDETAIL_TEMP
	(
		AIRLINE varchar(3),
		FLIGHT_NUMBER varchar(5),
		SDO datetime,
		SOURCE varchar(1),
		BSM_TIME_STAMP datetime,
		CLOSEOUT_TIME datetime,
		LICENSE_PLATE varchar(10),
		PAX_NAME VARCHAR(200),
		LASTEST_GID varchar(10),
		TAG_READ_TIME DATETIME,
		SORTED_MARK int, -- Indicate whether this bag is sorted
		SORTED_TIMESTAMP datetime,-- Indicate when this bag is sorted
		SORTED_ONTIME_MARK int, -- Indicate whether this bag is sorted on time
		BAG_LATE_MARK int -- Indicate whether this bag is sorted late BY IRD
	);

	--1. Query flight info that its STO is between @DTFROM and @DTTO
	SELECT  FPS.AIRLINE,FPS.FLIGHT_NUMBER,FPS.SDO,FPS.STO,FPS.EDO,FPS.ETO,FPA.ALLOC_CLOSE_OFFSET,FPA.ALLOC_CLOSE_RELATED 
	INTO #IFS_FLIGHT_PLAN_ALLOC_TEMP
	FROM FLIGHT_PLAN_SORTING FPS WITH(NOLOCK)
	LEFT JOIN FLIGHT_PLAN_ALLOC fpa WITH(NOLOCK)
	ON	FPS.AIRLINE=FPA.AIRLINE AND FPS.FLIGHT_NUMBER=FPA.FLIGHT_NUMBER AND FPS.SDO=FPA.SDO
		AND CONVERT(datetime,CONVERT(VARCHAR,fpa.SDO,103)+' '+DBO.RPT_GETFORMATTEDSTO(fpa.STO),103) BETWEEN @DTFROM AND @DTTO
		AND fpa.TIME_STAMP=(SELECT MAX(TIME_STAMP) 
							FROM FLIGHT_PLAN_ALLOC FPA2 WITH(NOLOCK)
							WHERE FPA2.AIRLINE=fpa.AIRLINE 
								AND FPA2.FLIGHT_NUMBER=fpa.FLIGHT_NUMBER 
								AND FPA2.SDO=fpa.SDO
						   )
	WHERE CONVERT(datetime,CONVERT(VARCHAR,FPS.SDO,103)+' '+DBO.RPT_GETFORMATTEDSTO(FPS.STO),103) BETWEEN @DTFROM AND @DTTO
		AND FPS.AIRLINE IN (SELECT * FROM RPT_GETPARAMETERS(@AIRLINE)) 
		AND FPS.FLIGHT_NUMBER IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@FLIGHTNUM));

	--2. Insert into all bags detail from bag_sorting to #IFS_BAGSDETAIL_TEMP
	INSERT INTO #IFS_BAGSDETAIL_TEMP
	SELECT DISTINCT BSA.AIRLINE, BSA.FLIGHT_NUMBER, BSA.SDO, SOURCE, BSA.TIME_STAMP AS BSM_TIME_STAMP, 
		CASE FPA.ALLOC_CLOSE_RELATED
			WHEN 'ETD' 
				--THEN CONVERT(DATETIME,CONVERT(VARCHAR,FPA.EDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(dbo.SAC_OFFSETOPERATOR(FPA.ETO,FPA.ALLOC_CLOSE_OFFSET)),103)
				THEN DBO.RPT_TIME_CAL(FPA.EDO,FPA.ETO,FPA.ALLOC_CLOSE_OFFSET)
			WHEN 'STD' 
				--THEN CONVERT(DATETIME,CONVERT(VARCHAR,FPA.SDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(dbo.SAC_OFFSETOPERATOR(FPA.STO,FPA.ALLOC_CLOSE_OFFSET)),103)
				THEN DBO.RPT_TIME_CAL(FPA.SDO,FPA.STO,FPA.ALLOC_CLOSE_OFFSET)
		END AS CLOSEOUT_TIME, 
		LICENSE_PLATE, (ISNULL(GIVEN_NAME,'')+' '+ISNULL(SURNAME,'')+' '+ISNULL(OTHERS_NAME,'')) AS PAX_NAME,
		'' AS LASTEST_GID, NULL AS TAG_READ_TIME, 0 AS SORTED_MARK, NULL AS SORTED_TIMESTAMP, 0 AS SORTED_ONTIME_MARK, 0 AS BAG_LATE_MARK
	FROM 
	(
		SELECT AIRLINE, FLIGHT_NUMBER, SDO, SOURCE, TIME_STAMP, LICENSE_PLATE, GIVEN_NAME, SURNAME, OTHERS_NAME
		FROM BAG_SORTING WITH(NOLOCK)
		WHERE SDO BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)	
		UNION ALL
		SELECT AIRLINE, FLIGHT_NUMBER, SDO, SOURCE, TIME_STAMP, LICENSE_PLATE, GIVEN_NAME, SURNAME, OTHERS_NAME
		FROM BAG_SORTING_HIS WITH(NOLOCK)
		WHERE SDO BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)	

	) AS BSA, #IFS_FLIGHT_PLAN_ALLOC_TEMP FPA
	WHERE BSA.AIRLINE=FPA.AIRLINE AND BSA.FLIGHT_NUMBER=FPA.FLIGHT_NUMBER AND BSA.SDO=FPA.SDO ;

	CREATE INDEX #IFS_BAGSDETAIL_TEMP_IDXLP ON #IFS_BAGSDETAIL_TEMP(LICENSE_PLATE);


	--3. Query the ATR read info into temp table #BT_ITEM_TAGREAD_TEMP
	SELECT ISC.GID, ISC.LICENSE_PLATE1, ISC.LICENSE_PLATE2, ISC.LOCATION, ISC.TIME_STAMP INTO #IFS_ITEM_TAGREAD_TEMP
	FROM ITEM_SCANNED ISC, #IFS_BAGSDETAIL_TEMP FBD WITH(NOLOCK)
	WHERE (ISC.LICENSE_PLATE1=FBD.LICENSE_PLATE OR ISC.LICENSE_PLATE2=FBD.LICENSE_PLATE)
		AND ISC.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
		AND (ISC.STATUS_TYPE='1' OR ISC.STATUS_TYPE='3' OR ISC.STATUS_TYPE='7');
	--ORDER BY ISC.TIME_STAMP DESC; 

	--4. Query the MES read info into temp table #BT_ITEM_TAGREAD_TEMP 
	INSERT INTO #IFS_ITEM_TAGREAD_TEMP
	SELECT IEC.GID,IEC.LICENSE_PLATE AS LICENSE_PLATE1,'0000000000' AS LICENSE_PLATE2,IEC.LOCATION,IEC.TIME_STAMP 
	FROM ITEM_ENCODED IEC,#IFS_BAGSDETAIL_TEMP FBD WITH(NOLOCK)
	WHERE IEC.LICENSE_PLATE=FBD.LICENSE_PLATE
		AND IEC.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)

	--In Charlotte project, there are 2 ATRs and MES a bag may goes through. 
	--So stored procedure must find the lastest location where item_scanned telegram is sent ordered by time_stamp
	--SELECT GID, LICENSE_PLATE1, LICENSE_PLATE2, LOCATION, MAX(TIME_STAMP) AS TIME_STAMP INTO #IFS_TAGREAD_TEMP
	--FROM #IFS_ITEM_TAGREAD_TEMP
	--GROUP BY GID, LICENSE_PLATE1, LICENSE_PLATE2, LOCATION;

	DECLARE @TAGREAD_TABLE AS TAGREAD_TABLETYPE; --For the parameter of stp_RPT_GET_LATEST_TAGREAD

	INSERT INTO @TAGREAD_TABLE
	SELECT * FROM #IFS_ITEM_TAGREAD_TEMP;

	CREATE TABLE #IFS_TAGREAD_TEMP
	( 
		GID VARCHAR(10),
		LICENSE_PLATE VARCHAR(10), 
		--LICENSE_PLATE2 VARCHAR(10), 
		LOCATION VARCHAR(20), 
		TIME_STAMP DATETIME
	);

	INSERT INTO #IFS_TAGREAD_TEMP
	EXEC dbo.stp_RPT_GET_LATEST_TAGREAD @TAGREAD_TABLE;

	CREATE INDEX #IFS_TAGREAD_TEMP_IDXLP1 ON #IFS_TAGREAD_TEMP(LICENSE_PLATE);
	--CREATE INDEX #IFS_TAGREAD_TEMP_IDXLP2 ON #IFS_TAGREAD_TEMP(LICENSE_PLATE2);

	--5. Update ATR OR MES read info(Latest GID and TAG_READ_TIME) into #IFS_BAGSDETAIL_TEMP
	UPDATE FBT
	SET FBT.LASTEST_GID=FTT.GID, FBT.TAG_READ_TIME=ftt.TIME_STAMP
	FROM #IFS_TAGREAD_TEMP FTT, #IFS_BAGSDETAIL_TEMP FBT
	WHERE FTT.LICENSE_PLATE=FBT.LICENSE_PLATE

	--6. Update sorted info (SORTED_MARK, SORTED_TIMESTAMP, SORTED_ONTIME_MARK) into #IFS_BAGSDETAIL_TEMP
	--BAG ONTIME OR LATE IS DECIDED BY ITEM_SCANNED(MAINLINE) TIME_STAMP
	UPDATE FBT
	SET FBT.SORTED_MARK=1, 
		FBT.SORTED_TIMESTAMP=IPR.TIME_STAMP,
		FBT.SORTED_ONTIME_MARK=
		CASE
			WHEN FBT.TAG_READ_TIME<FBT.CLOSEOUT_TIME THEN 1 
			ELSE 0
		END,
		FBT.BAG_LATE_MARK=
		CASE
			WHEN FBT.TAG_READ_TIME>=FBT.CLOSEOUT_TIME THEN 1
			ELSE 0
		END
	FROM ITEM_PROCEEDED IPR, LOCATIONS LOC,#IFS_BAGSDETAIL_TEMP FBT WITH(NOLOCK)
	WHERE IPR.GID=FBT.LASTEST_GID AND FBT.LASTEST_GID IS NOT NULL
		AND IPR.PROCEED_LOCATION = LOC.LOCATION_ID
		AND LOC.SUBSYSTEM LIKE 'MU%'
		AND IPR.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO);

	--7. Update bag late mark(BAG_LATE_MARK) into #IFS_BAGSDETAIL_TEMP
	--UPDATE FBT
	--SET FBT.BAG_LATE_MARK=1
	--FROM ITEM_REDIRECT IRD, #IFS_BAGSDETAIL_TEMP FBT WITH(NOLOCK)
	--WHERE IRD.GID=FBT.LASTEST_GID AND FBT.LASTEST_GID IS NOT NULL
	--	AND IRD.REASON='5'--TOO LATE
	--	AND IRD.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFrom) AND DATEADD(DAY,@DATERANGE,@DTTo);

	--8. Finally, get the statistic result or detail result
	INSERT	INTO #IFS_FLIGHTSUMMARY_TEMP
	SELECT	DISTINCT FLIGHT_NUMBER,AIRLINE,
			NULL AS CLOSEOUT_TIME, 
			0 AS NUMBER_ALLBAGS, 
			0 AS NUMBER_BAGSORTED,
			0 AS NUMBER_BAGS_ONTIME,
			0 AS NUMBER_BAGS_INSYSTEM,
			0 AS NUMBER_BAGS_LATE
	FROM FLIGHT_PLAN_SORTING FPS WITH(NOLOCK)
	WHERE CONVERT(datetime,CONVERT(VARCHAR,FPS.SDO,103)+' '+DBO.RPT_GETFORMATTEDSTO(FPS.STO),103) BETWEEN @DTFROM AND @DTTO
		AND AIRLINE IN (SELECT * FROM RPT_GETPARAMETERS(@AIRLINE)) 
		AND FLIGHT_NUMBER IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@FLIGHTNUM));

	UPDATE	FLTSUM
	SET		FLTSUM.CLOSEOUT_TIME=FLTSTC.CLOSEOUT_TIME,
			FLTSUM.NUMBER_ALLBAGS=FLTSTC.NUMBER_ALLBAGS,
			FLTSUM.NUMBER_BAGSORTED=FLTSTC.NUMBER_BAGSORTED,
			FLTSUM.NUMBER_BAGS_ONTIME=FLTSTC.NUMBER_BAGS_ONTIME,
			FLTSUM.NUMBER_BAGS_INSYSTEM=FLTSTC.NUMBER_BAGS_INSYSTEM,
			FLTSUM.NUMBER_BAGS_LATE=FLTSTC.NUMBER_BAGS_LATE
	FROM	(SELECT FLIGHT_NUMBER, AIRLINE, CLOSEOUT_TIME,
				COUNT(LICENSE_PLATE) AS NUMBER_ALLBAGS,
				SUM(SORTED_MARK) AS NUMBER_BAGSORTED,
				SUM(SORTED_ONTIME_MARK) AS NUMBER_BAGS_ONTIME,
				0 AS NUMBER_BAGS_INSYSTEM, 
				SUM(BAG_LATE_MARK) AS NUMBER_BAGS_LATE
			FROM #IFS_BAGSDETAIL_TEMP FBT
			GROUP BY FBT.FLIGHT_NUMBER,FBT.AIRLINE,FBT.CLOSEOUT_TIME
			) AS FLTSTC,#IFS_FLIGHTSUMMARY_TEMP FLTSUM
	WHERE	FLTSUM.AIRLINE=FLTSTC.AIRLINE AND FLTSUM.FLIGHT_NUMBER=FLTSTC.FLIGHT_NUMBER;

	UPDATE #IFS_FLIGHTSUMMARY_TEMP
	SET NUMBER_BAGS_INSYSTEM=NUMBER_ALLBAGS-NUMBER_BAGSORTED;



	--Insert each bag data of the individual flight into ##MIS_IFS_INDIVIDUAL_FLIGHT_DETAIL
	IF EXISTS (SELECT NAME FROM sys.sysobjects WHERE NAME LIKE 'MIS_IFS_INDIVIDUAL_FLIGHT_DETAIL%')
	BEGIN
			DROP TABLE MIS_IFS_INDIVIDUAL_FLIGHT_DETAIL;
	END

	--delete from ##MIS_IFS_INDIVIDUAL_FLIGHT_DETAIL;

	--SELECT * FROM #IFS_BAGSDETAIL_TEMP;

	CREATE TABLE MIS_IFS_INDIVIDUAL_FLIGHT_DETAIL
	(
		LICENSE_PLATE VARCHAR(10),
		PAX_NAME VARCHAR(200),
		BSM_TIME_STAMP DATETIME,
		TAG_READ_TIME DATETIME,
		SORTED_TIMESTAMP DATETIME
	)

	INSERT INTO MIS_IFS_INDIVIDUAL_FLIGHT_DETAIL
	SELECT IBT.LICENSE_PLATE,ibt.PAX_NAME,ibt.BSM_TIME_STAMP,ibt.TAG_READ_TIME,ibt.SORTED_TIMESTAMP
	FROM #IFS_BAGSDETAIL_TEMP ibt
	ORDER BY ibt.CLOSEOUT_TIME;
	

	SELECT * FROM #IFS_FLIGHTSUMMARY_TEMP;
END

--DECLARE @DTFROM DATETIME='2014-1-1';
--DECLARE @DTTO DATETIME='2014-1-3';
--DECLARE @AIRLINE varchar(max)='SQ';
--DECLARE @FLIGHTNUM varchar(max)='1114';
--EXEC stp_RPT17_IndvFlightSummary_GWYTEST @DTFROM,@DTTO,@AIRLINE,@FLIGHTNUM;

--SELECT * FROM MIS_IFS_INDIVIDUAL_FLIGHT_DETAIL;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_LOADBALANCING_EDS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create PROCEDURE [dbo].[stp_RPT_CLT_LOADBALANCING_EDS]
		  @DTFROM DATETIME,
		  @DTTO DATETIME
AS
BEGIN
--PROBLEM1: only machine(lvl1) result or levle1&2 result

	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;

	--1. Insert item_screened data into a temp table
	SELECT LOCATION,GID,SCREEN_LEVEL,TIME_STAMP,RESULT_TYPE
	INTO #EDS_ITEM_SCREENED_TEMP
	FROM ITEM_SCREENED WITH(NOLOCK)
	WHERE TIME_STAMP BETWEEN @DTFrom AND @DTTo;

	--2. create a temp table for machine result
	CREATE TABLE #EDS_STATUS_TEMP
	(
		SUBSYSTEM_TYPE VARCHAR(30),
		SUBSYSTEM VARCHAR(20),
		LOCATION VARCHAR(20),
		BAGS INT,
		BAGS_CLEARED INT,
		BAGS_ALARMED INT,
		CLEARED_RATE FLOAT
	)

	--Insert EDS machines screened result into #EDS_STATUS_TEMP
	--3. total number of bags
	INSERT INTO #EDS_STATUS_TEMP
	SELECT 'EDS MACHINES' AS SUBSYSTEM_TYPE,LOC.SUBSYSTEM, LOC.LOCATION, COUNT(ICR.GID) AS BAGS, 0 AS BAGS_CLEARED, 0 AS BAGS_ALARMED, 0 AS CLEARED_RATE
	FROM #EDS_ITEM_SCREENED_TEMP ICR, LOCATIONS LOC
	WHERE ICR.LOCATION=LOC.LOCATION_ID
		--AND ICR.SCREEN_LEVEL='3'
	GROUP BY LOC.SUBSYSTEM, LOC.LOCATION;


	--4. cleared bag
	UPDATE EST
	SET EST.BAGS_CLEARED=CLR.CLEARED_CNT
	FROM
	(
		SELECT LOC.LOCATION,COUNT(ICR.GID) AS CLEARED_CNT
		FROM #EDS_ITEM_SCREENED_TEMP ICR, LOCATIONS LOC
		WHERE LOC.LOCATION_ID=ICR.LOCATION
			--AND ICR.SCREEN_LEVEL='3'
			AND (ICR.RESULT_TYPE='12' OR ICR.RESULT_TYPE='22')--CLEARED
		GROUP BY LOC.LOCATION
	) AS CLR, #EDS_STATUS_TEMP EST
	WHERE EST.LOCATION=CLR.LOCATION;

	--5. alarmed bag
	UPDATE EST
	SET EST.BAGS_ALARMED=ALM.ALARMED_CNT
	FROM
	(
		SELECT LOC.LOCATION,COUNT(ICR.GID) AS ALARMED_CNT
		FROM #EDS_ITEM_SCREENED_TEMP ICR, LOCATIONS LOC
		WHERE LOC.LOCATION_ID=ICR.LOCATION
			--AND ICR.SCREEN_LEVEL='3'
			AND (ICR.RESULT_TYPE<>'12' AND ICR.RESULT_TYPE<>'22')--ALARMED
		GROUP BY LOC.LOCATION
	) AS ALM, #EDS_STATUS_TEMP EST
	WHERE EST.LOCATION=ALM.LOCATION;


	--6. cleared rate
	UPDATE EST
	SET EST.CLEARED_RATE=CAST(BAGS_CLEARED AS FLOAT)/CAST(BAGS AS FLOAT)*100
	FROM #EDS_STATUS_TEMP EST;

	--7. count the bags by different matrix (east and west)
	--And finally select all the result.
	SELECT 'EDS MATRIX' AS SUBSYSTEM_TYPE,
		CASE 
			WHEN SUBSYSTEM IN ('ED1','ED2','ED3','ED4') THEN 'WEST MATRIX'
			WHEN SUBSYSTEM IN ('ED7','ED8','ED9','ED10','ED11') THEN 'EAST MATRIX'
			ELSE 'UNKNOW MATRIX'
		END AS SUBSYSTEM_M,
		SUM(BAGS) AS BAGS,
		SUM(BAGS_CLEARED) AS BAGS_CLEARED,
		SUM(BAGS_ALARMED) AS BAGS_ALARMED,
		CAST(SUM(BAGS_CLEARED) AS FLOAT)/CAST(SUM(BAGS) AS FLOAT)*100 AS CLEARED_RATE
	FROM #EDS_STATUS_TEMP EST
	GROUP BY 
		CASE 
			WHEN SUBSYSTEM IN ('ED1','ED2','ED3','ED4') THEN 'WEST MATRIX'
			WHEN SUBSYSTEM IN ('ED7','ED8','ED9','ED10','ED11') THEN 'EAST MATRIX'
			ELSE 'UNKNOW MATRIX'
		END

	UNION ALL
	SELECT SUBSYSTEM_TYPE, SUBSYSTEM, BAGS, BAGS_CLEARED,BAGS_ALARMED, CLEARED_RATE
	FROM #EDS_STATUS_TEMP

	

END

--DECLARE @DTFrom [datetime]='2013-12-30';
--DECLARE @DTTo [datetime]='2014-01-01';
--EXEC stp_RPT10_LOADBALANCING_EDS @DTFrom,@DTTo;

--SELECT * FROM ITEM_SCREEN_RESULT_TYPES;

--DECLARE @DTFrom [datetime]='2013-12-10';
--DECLARE @DTTo [datetime]='2013-12-27';
--SELECT * FROM ITEM_SCREENED ICR 
--WHERE ICR.TIME_STAMP BETWEEN @DTFrom AND @DTTo
--	AND (ICR.RESULT_TYPE<>'12' AND ICR.RESULT_TYPE<>'22');
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_LOADBALANCING_NORMAL]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_CLT_LOADBALANCING_NORMAL]
		  @DTFROM DATETIME,
		  @DTTO DATETIME,
		  @INTERVAL INT,--MINUTES
		  @SUBSYSTEM VARCHAR(MAX)
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;

	DECLARE @INTERVAL_END DATETIME=GETDATE();
	DECLARE @INTERVAL_START DATETIME=DATEADD(MINUTE,-@INTERVAL,@INTERVAL_END);

	--Create temp table for final result
	CREATE TABLE #LB_NORMAL_SUBSYSTEM_TEMP
	(
		SUBSYSTEM_TYPE VARCHAR(30),
		SUBSYSTEM VARCHAR(20),
		TOTAL_BAGS INT,
		CRT_INTERVAL_LOAD INT
	);

	--1. count the bags for EDS line
	INSERT INTO #LB_NORMAL_SUBSYSTEM_TEMP
	SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM, COUNT(DISTINCT ITI.GID) AS TOTAL_BAGS, NULL AS CRT_INTERVAL_LOAD
	FROM	MIS_SubsystemCatalog SC
	INNER JOIN LOCATIONS LOC ON SC.DETECT_LOCATION=LOC.LOCATION
	LEFT JOIN ITEM_TRACKING ITI WITH(NOLOCK)
		ON LOC.LOCATION_ID=ITI.LOCATION 
		AND ITI.TIME_STAMP BETWEEN @DTFROM AND @DTTO 
	WHERE  (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
		AND SC.SUBSYSTEM_TYPE='EDS'
		AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@SUBSYSTEM))
		--AND SC.MDS_DATA=0
	GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM

	--2. count the current interval load for EDS
	UPDATE LNST
	SET LNST.CRT_INTERVAL_LOAD=CRT_LOAD.CRT_INTERVAL_LOAD
	FROM
	(
		SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM, COUNT(DISTINCT ITI.GID) AS CRT_INTERVAL_LOAD
		FROM	MIS_SubsystemCatalog SC
		INNER JOIN LOCATIONS LOC ON SC.DETECT_LOCATION=LOC.LOCATION
		LEFT JOIN ITEM_TRACKING ITI WITH(NOLOCK)
			ON LOC.LOCATION_ID=ITI.LOCATION 
			AND ITI.TIME_STAMP BETWEEN @INTERVAL_START AND @INTERVAL_END
		WHERE  (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
			AND SC.SUBSYSTEM_TYPE='EDS'
			AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@SUBSYSTEM))
			--AND SC.MDS_DATA=0
		GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM
	) AS CRT_LOAD,#LB_NORMAL_SUBSYSTEM_TEMP LNST
	WHERE CRT_LOAD.SUBSYSTEM_TYPE=LNST.SUBSYSTEM_TYPE AND CRT_LOAD.SUBSYSTEM=LNST.SUBSYSTEM
		AND LNST.CRT_INTERVAL_LOAD IS NULL;

	--3. count the total bags for normal subsystems by item_proceed
	INSERT INTO #LB_NORMAL_SUBSYSTEM_TEMP
	SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM, COUNT(DISTINCT IPR.GID) AS TOTAL_BAGS, NULL AS CRT_INTERVAL_LOAD
	FROM	MIS_SubsystemCatalog SC,
			ITEM_PROCEEDED IPR, 
			LOCATIONS LOC 
			WITH(NOLOCK)
	WHERE SC.DETECT_LOCATION=LOC.LOCATION
		AND LOC.LOCATION_ID=IPR.PROCEED_LOCATION
		AND (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
		AND IPR.TIME_STAMP BETWEEN @DTFROM AND @DTTO 
		AND NOT EXISTS(SELECT * FROM #LB_NORMAL_SUBSYSTEM_TEMP LNST WHERE LNST.SUBSYSTEM=SC.SUBSYSTEM)
		AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@SUBSYSTEM))
		--AND SC.MDS_DATA=0
	GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM

	--4. count the current interval load for normal subsystems by item_proceed
	UPDATE LNST
	SET LNST.CRT_INTERVAL_LOAD=CRT_LOAD.CRT_INTERVAL_LOAD
	FROM 
	(
		SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM,COUNT(DISTINCT IPR.GID) AS CRT_INTERVAL_LOAD
		FROM MIS_SubsystemCatalog SC, ITEM_PROCEEDED IPR, LOCATIONS LOC WITH(NOLOCK)
		WHERE SC.DETECT_LOCATION=LOC.LOCATION
			AND LOC.LOCATION_ID=IPR.PROCEED_LOCATION
			AND (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
			AND IPR.TIME_STAMP BETWEEN @INTERVAL_START AND @INTERVAL_END
			--AND SC.MDS_DATA=0
		GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM
	) AS CRT_LOAD,#LB_NORMAL_SUBSYSTEM_TEMP LNST
	WHERE CRT_LOAD.SUBSYSTEM_TYPE=LNST.SUBSYSTEM_TYPE AND CRT_LOAD.SUBSYSTEM=LNST.SUBSYSTEM
		AND LNST.CRT_INTERVAL_LOAD IS NULL;
		

	--5. count the total bags for normal subsystems by MDS_COUNT
	INSERT INTO #LB_NORMAL_SUBSYSTEM_TEMP
	SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM, SUM(MBC.DIFFERENT) AS TOTAL_BAGS, NULL AS CRT_INTERVAL_LOAD
	FROM MIS_SubsystemCatalog SC, MDS_COUNT MBC, MDS_COUNTERS MBCR WITH(NOLOCK)
	WHERE MBCR.LOCATION=DBO.RPT_FORMAT_LOCATION(SC.DETECT_LOCATION)
		AND MBCR.COUNTER_ID=MBC.COUNTER_ID
		AND MBCR.TYPE='CV'
		AND (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
		AND MBC.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		AND NOT EXISTS(SELECT * FROM #LB_NORMAL_SUBSYSTEM_TEMP LNST WHERE LNST.SUBSYSTEM=SC.SUBSYSTEM)
		AND MBCR.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@SUBSYSTEM))
		--AND SC.MDS_DATA=1 
	GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM

	--6. count the current interval load for normal subsystems by MDS_COUNT
	--current interval is from nowtime-interval to nowtime ?????
	UPDATE LNST
	SET LNST.CRT_INTERVAL_LOAD=CRT_LOAD.CRT_INTERVAL_LOAD
	FROM 
	(
		SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM,SUM(MBC.DIFFERENT) AS CRT_INTERVAL_LOAD
		FROM MIS_SubsystemCatalog SC, MDS_COUNT MBC, MDS_COUNTERS MBCR
		WHERE MBCR.LOCATION=DBO.RPT_FORMAT_LOCATION(SC.DETECT_LOCATION)
			AND MBCR.COUNTER_ID=MBC.COUNTER_ID
			AND MBCR.TYPE='CV'
			AND (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
			AND MBC.TIME_STAMP BETWEEN @INTERVAL_START AND @INTERVAL_END
			--AND SC.MDS_DATA=1 
		GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM
	) AS CRT_LOAD,#LB_NORMAL_SUBSYSTEM_TEMP LNST
	WHERE CRT_LOAD.SUBSYSTEM_TYPE=LNST.SUBSYSTEM_TYPE AND CRT_LOAD.SUBSYSTEM=LNST.SUBSYSTEM
		AND LNST.CRT_INTERVAL_LOAD IS NULL; -- add by guo wenyu 2014/03/04
	
	SELECT * FROM #LB_NORMAL_SUBSYSTEM_TEMP
	ORDER BY SUBSYSTEM_TYPE,SUBSYSTEM;
		 
END

--DECLARE @DTFrom [datetime]='2014-1-1';
--DECLARE @DTTo [datetime]='2014-1-3';
--DECLARE @INTERVAL INT =60;
--DECLARE @SUBSYSTEM VARCHAR(MAX)='ED1,ED2,ED3,ED4,ML01,ML02,ML03,ML04,MU,ME1,ME2,ME3';
--EXEC stp_RPT10_LOADBALANCING_NORMAL @DTFROM,@DTTO,@INTERVAL,@SUBSYSTEM;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_MESUTILIZATION_DISPATCH]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_MESUTILIZATION_DISPATCH]
		  @DTFROM datetime, 
		  @DTTO datetime
AS
BEGIN
	--Modified by Guo Wenyu on 2014/01/02
	--Redesign the report, and do not follow the specification
	--Just show the exact encoded type for telegram-Manual Encoding Request

	DECLARE @HOURRANGE INT=1;

	--Create temp table for final result
	CREATE TABLE #MU_MESUTILIZATION_TEMP
	(
		ME_STATION VARCHAR(10),
		CNT_LICENSE_PLATE INT,
		CNT_FLIGHT_NUMBER INT,
		CNT_DESTINATION INT,
		CNT_PROBLEM_BAG INT,
		CNT_ITEM_REMOVED INT,
		CNT_AIRLINE INT,
	);

	--Create temp table for all the required MES data from ITEM_ENCODING_REQUEST 
	--And mark the encoding type
	CREATE TABLE #MU_MESMARKLIST_TEMP
	(
		GID VARCHAR(10),
		TIME_STAMP DATETIME,
		LOCATION VARCHAR(10),
		ENCODING_TYPE VARCHAR(2),
		MARK_LICENSE_PLATE INT,
		MARK_FLIGHT_NUMBER INT,
		MARK_DESTINATION INT,
		MARK_PROBLEM_BAG INT,
		MARK_ITEM_REMOVED INT,
		MARK_AIRLINE INT,
	);

	--1. Query ITEM_ENCODED detail data into #MES_ITEM_ENCODED_TEMP
	SELECT --MAX(IEC.TIME_STAMP) AS TIME_STAMP,
				IEC.TIME_STAMP,
				IEC.GID,IEC.LOCATION,IEC.ENCODING_TYPE 
	INTO	#MES_ITEM_ENCODED_TEMP
	FROM	ITEM_ENCODED IEC WITH(NOLOCK)
	WHERE IEC.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		--AND IEC.TIME_STAMP=(SELECT MAX(TIME_STAMP) FROM ITEM_ENCODED IEC2 WITH(NOLOCK) WHERE IEC.GID=IEC2.GID)
		--AND IEC.PLC_IDX<>'1001'
	--GROUP BY IEC.GID,IEC.LOCATION,IEC.ENCODING_TYPE;
	--2. Query ITEM_REMOVED detail data into #MES_ITEM_REMOVED_TEMP
	SELECT IRM.GID,IRM.TIME_STAMP,IRM.LOCATION
	INTO #MES_ITEM_REMOVED_TEMP 
	FROM ITEM_REMOVED IRM WITH(NOLOCK)
	WHERE IRM.TIME_STAMP BETWEEN @DTFROM AND @DTTO

	--select * from #MU_ITEM_ENCODING_REQUEST_TEMP;

	--3. Initialize MES encoding mark of #MU_MESMARKLIST_TEMP
	--There is only 3 MES in CLT
	INSERT INTO #MU_MESMARKLIST_TEMP
	SELECT IEC.GID, IEC.TIME_STAMP, LOC.SUBSYSTEM AS LOCATION, IEC.ENCODING_TYPE,
		   0 AS MARK_LICENSE_PLATE, 0 AS MARK_FLIGHT_NUMBER, 0 AS MARK_DESTINATION, 
		   0 AS MARK_PROBLEM_BAG, 0 AS MARK_ITEM_REMOVED, 0 AS MARK_AIRLINE
	FROM #MES_ITEM_ENCODED_TEMP IEC, LOCATIONS LOC
	WHERE IEC.LOCATION=LOC.LOCATION_ID AND LOC.SUBSYSTEM LIKE 'ME%'
	UNION
	SELECT IRM.GID, IRM.TIME_STAMP, LOC.SUBSYSTEM AS LOCATION, '5' AS ENCODING_TYPE,
		   0 AS MARK_LICENSE_PLATE, 0 AS MARK_FLIGHT_NUMBER, 0 AS MARK_DESTINATION, 
		   0 AS MARK_PROBLEM_BAG, 1 AS MARK_ITEM_REMOVED, 0 AS MARK_AIRLINE
	FROM   #MES_ITEM_REMOVED_TEMP IRM, LOCATIONS LOC
	WHERE  IRM.LOCATION=LOC.LOCATION_ID AND LOC.SUBSYSTEM LIKE 'ME%'

	--Commented by Guo Wenyu 2014/01/02
	--3	Query ITEM_REDIRECT with Reason: Unknown License Plate into temp table
	--SELECT IRD.GID INTO #MU_ITEM_REDIRECT_TEMP
	--FROM ITEM_REDIRECT IRD, LOCATIONS LOC
	--WHERE IRD.REASON='12'
	--	AND IRD.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
	--	AND (IRD.DESTINATION_1=LOC.LOCATION_ID OR IRD.DESTINATION_2=LOC.LOCATION_ID)
	--	AND LOC.SUBSYSTEM LIKE 'ME%';
	
	--CREATE INDEX #MU_ITEM_REDIRECT_TEMP_IDXGID ON #MU_ITEM_REDIRECT_TEMP(GID);
	--Commented END

	--3. Update each mark of #MU_MESMARKLIST_TEMP according to ENCODING_TYPE

	--Encoded Type. There are following possible values:
	--¡°1¡± ¨C Encoded by License Plate Number.
	--¡°2¡± ¨C Encoded by Flight Number.
	--¡°3¡± ¨C Encoded by Destination.
	--¡°4¡± ¨C Encoded by Problem Bag.
	--¡°5¡± ¨C Encoded by Item Removed.
	--¡°6¡± ¨C Encoded by Airline.

	UPDATE MMT
	SET 
		MARK_LICENSE_PLATE	= CASE MMT.ENCODING_TYPE WHEN '1' THEN 1 ELSE 0 END, 
		MARK_FLIGHT_NUMBER	= CASE MMT.ENCODING_TYPE WHEN '2' THEN 1 ELSE 0 END, 
		MARK_DESTINATION	= CASE MMT.ENCODING_TYPE WHEN '3' THEN 1 ELSE 0 END, 
		MARK_PROBLEM_BAG	= CASE MMT.ENCODING_TYPE WHEN '4' THEN 1 ELSE 0 END, 
		MARK_ITEM_REMOVED	= CASE MMT.ENCODING_TYPE WHEN '5' THEN 1 ELSE 0 END, 
		MARK_AIRLINE		= CASE MMT.ENCODING_TYPE WHEN '6' THEN 1 ELSE 0 END
	FROM #MU_MESMARKLIST_TEMP MMT

	--UPDATE MMT
	--SET MARK_BSM=MARK_SCANNING-MARK_LATEBSMS
	--FROM #MU_MESMARKLIST_TEMP MMT;

	INSERT INTO #MU_MESUTILIZATION_TEMP
	SELECT MMT.LOCATION AS ME_STATION,
		   SUM(MARK_LICENSE_PLATE) AS CNT_LICENSE_PLATE,
		   SUM(MARK_FLIGHT_NUMBER) AS CNT_FLIGHT_NUMBER,
		   SUM(MARK_DESTINATION) AS CNT_DESTINATION,
		   SUM(MARK_PROBLEM_BAG) AS CNT_PROBLEM_BAG,
		   SUM(MARK_ITEM_REMOVED) AS CNT_ITEM_REMOVED,
		   SUM(MARK_AIRLINE) AS CNT_AIRLINE
	FROM #MU_MESMARKLIST_TEMP MMT
	GROUP BY MMT.LOCATION;

	SELECT * FROM #MU_MESUTILIZATION_TEMP;
END


--declare @DTFROM datetime='2014-01-02';
--declare @DTTO datetime='2014-01-03';
--exec stp_RPT09_MESUTILIZATION_GWYTEST @DTFROM,@DTTO;

GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_MESUTILIZATION_REASON]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_MESUTILIZATION_REASON]
		  @DTFROM datetime, 
		  @DTTO datetime
AS
BEGIN
	DECLARE @MINUTERANGE INT=10;

	--0	Sorted by Unknown --USE
	--1	Sorted by Flight Allocation
	--2	Sorted by Fallback Sortation
	--3	Sorted by Early Bag Functional Allocation
	--4	Sorted by Rush Bag Functional Allocation
	--5	Sorted by Too Late Bag Functional Allocation
	--6	Sorted by No Read Bag Functional Allocation --USE
	--7	Sorted by Standby Passenger Bag Functional Allocation
	--8	Sorted by First Class Bag Functional Allocation
	--9	Sorted by Business Class Bag Functional Allocation
	--10	Sorted by Multiple Tag Bag Functional Allocation --USE
	--11	Sorted by Unknown Flight Bag Functional Allocation --USE
	--12	Sorted by Unknown License Plate Bag Functional Allocation --USE
	--13	Sorted by No Allocation Bag Functional Allocation --USE
	--14	Sorted by Problem Bag Functional Allocation --USE
	--15	Sorted by Dump Discharge Functional Allocation 
	--16	Sorted by Carrier Allocation
	--17	Sorted by 4 Digits Tag Allocation
	--18	Sorted by Too Early Bag Functional Allocation
	--19	Sorted by Multiple BSM Functional Allocation --USE
	--20	Sorted by Invalid Fallback Tag

	--Create temp table for final result
	CREATE TABLE #MUR_MESUTILIZATION_REASON_TEMP
	(
		ME_STATION VARCHAR(10),
		CNT_UNKNOWN INT,
		CNT_NOREAD INT,
		CNT_MULTI_TAG INT,
		CNT_UNKNOWN_FLIGHT INT,
		CNT_UNKNOWN_LICENSE_PLATE INT,
		CNT_NOALLOCATION INT,
		CNT_PROBLEM_BAG INT,
		CNT_MULTI_BSM INT,
		CNT_OTHER INT
	);

	--Create temp table for all the required MES data from ITEM_ENCODING_REQUEST 
	--And mark the encoding type
	CREATE TABLE #MUR_MESMARKLIST_REASON_TEMP
	(
		GID VARCHAR(10),
		TIME_STAMP DATETIME,
		MES_SUBSYSTEM VARCHAR(10),
		REASON VARCHAR(2),
		MARK_UNKNOWN INT,--0
		MARK_NOREAD INT,--6
		MARK_MULTI_TAG INT,--10
		MARK_UNKNOWN_FLIGHT INT,--11
		MARK_UNKNOWN_LICENSE_PLATE INT,--12
		MARK_NOALLOCATION INT,--13
		MARK_PROBLEM_BAG INT,--14
		MARK_MULTI_BSM INT,--19
		MARK_OTHER INT	--OTHER
	);

	INSERT INTO #MUR_MESMARKLIST_REASON_TEMP
	SELECT	IPR.GID,IRD.TIME_STAMP,PRDLOC.SUBSYSTEM,IRD.REASON,
			0 AS MARK_UNKNOWN, 0 AS MARK_NOREAD, 0 AS MARK_MULTI_TAG,
			0 AS MARK_UNKNOWN_FLIGHT, 0 AS MARK_UNKNOWN_LICENSE_PLATE, 0 AS MARK_NOALLOCATION,
			0 AS MARK_PROBLEM_BAG, 0 AS MARK_MULTI_BSM, 0 AS MARK_OTHER
	FROM	LOCATIONS PRDLOC, LOCATIONS LOC,ITEM_PROCEEDED IPR
	LEFT JOIN ITEM_REDIRECT IRD 
			ON IPR.GID=IRD.GID 
			AND IRD.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
	WHERE	IPR.TIME_STAMP BETWEEN @DTFROM AND @DTTO
			AND IPR.LOCATION=LOC.LOCATION_ID
			--AND EXISTS(SELECT IPR_TOMES_SUBSYSTEM FROM MIS_MAINLINE_DEVICE MMD WHERE MMD.IPR_TOMES_SUBSYSTEM =PRDLOC.SUBSYSTEM)
			AND IPR.PROCEED_LOCATION=PRDLOC.LOCATION_ID
			AND PRDLOC.SUBSYSTEM LIKE 'ME%';

	UPDATE MMR
	SET 
		MARK_UNKNOWN				= CASE MMR.REASON WHEN '0' THEN 1 ELSE 0 END, 
		MARK_NOREAD					= CASE MMR.REASON WHEN '6' THEN 1 ELSE 0 END, 
		MARK_MULTI_TAG				= CASE MMR.REASON WHEN '10' THEN 1 ELSE 0 END, 
		MARK_UNKNOWN_FLIGHT			= CASE MMR.REASON WHEN '11' THEN 1 ELSE 0 END, 
		MARK_UNKNOWN_LICENSE_PLATE	= CASE MMR.REASON WHEN '12' THEN 1 ELSE 0 END, 
		MARK_NOALLOCATION			= CASE MMR.REASON WHEN '13' THEN 1 ELSE 0 END,
		MARK_PROBLEM_BAG			= CASE MMR.REASON WHEN '14' THEN 1 ELSE 0 END,
		MARK_MULTI_BSM				= CASE MMR.REASON WHEN '19' THEN 1 ELSE 0 END,
		MARK_OTHER					= CASE WHEN MMR.REASON NOT IN ('0','6','10','11','12','13','14','19','20') OR MMR.REASON IS NULL THEN 1 ELSE 0 END
	FROM #MUR_MESMARKLIST_REASON_TEMP MMR

	--SELECT * FROM #MUR_MESMARKLIST_REASON_TEMP;

	INSERT INTO #MUR_MESUTILIZATION_REASON_TEMP
	SELECT MMR.MES_SUBSYSTEM AS ME_STATION,
		   SUM(MARK_UNKNOWN) AS CNT_UNKNOWN,
		   SUM(MARK_NOREAD) AS CNT_NOREAD,
		   SUM(MARK_MULTI_TAG) AS CNT_MULTI_TAG,
		   SUM(MARK_UNKNOWN_FLIGHT) AS CNT_UNKNOWN_FLIGHT,
		   SUM(MARK_UNKNOWN_LICENSE_PLATE) AS CNT_UNKNOWN_LICENSE_PLATE,
		   SUM(MARK_NOALLOCATION) AS CNT_NOALLOCATION,
		   SUM(MARK_PROBLEM_BAG) AS CNT_PROBLEM_BAG,
		   SUM(MARK_MULTI_BSM) AS CNT_MULTI_BSM,
		   SUM(MARK_OTHER) AS CNT_OTHER
	FROM #MUR_MESMARKLIST_REASON_TEMP MMR
	GROUP BY MMR.MES_SUBSYSTEM;

	SELECT * FROM #MUR_MESUTILIZATION_REASON_TEMP;
END

--declare @DTFROM datetime='2014-01-02';
--declare @DTTO datetime='2014-01-03';
--exec stp_RPT09_MESUTILIZATION_REASON @DTFROM,@DTTO;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_RUNOUT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_CLT_RUNOUT]
		  @DTFrom datetime, 
		  @DTTo datetime,
		  @Subsystem varchar(max)
AS
BEGIN
--Run out is the bags which are proceeded to Dump carousel, 
--but not included in item redirect and manual encoded request(destination) telegram

	DECLARE @HOURRANGE INT=1;
	

	CREATE TABLE #RO_RUNOUT_LIST
	(
		GID VARCHAR(10),
		LICENSE_PLATE VARCHAR(20),
		SUBSYSTEM VARCHAR(20),
		LOCATION VARCHAR(20),
		TIME_STAMP DATETIME,
		REASON VARCHAR(200)
	)
	--0. Find the Dump carousel
	DECLARE @DUMPLOC VARCHAR(20) = (SELECT TOP 1 FAL.RESOURCE FROM FUNCTION_ALLOC_LIST FAL WHERE FAL.FUNCTION_TYPE='DUMP');

	--1. Find all the bags which is proceeded to dump carousel
	SELECT	IPR.TIME_STAMP,IPR.GID, PRDLOC.LOCATION
	INTO	#RO_DUMPBAG_TEMP
	FROM	ITEM_PROCEEDED IPR, 
			LOCATIONS PRDLOC
	WHERE	IPR.PROCEED_LOCATION=PRDLOC.LOCATION_ID
		--AND IPR.PROCEED_TYPE<>'7' --7	Proceeded to run-out pier
		AND PRDLOC.LOCATION LIKE (@DUMPLOC+'%')
		AND IPR.TIME_STAMP BETWEEN @DTFrom AND @DTTo;

	--2. Insert the bag GID into temp table except the bags of ITEM_REDIRECT and ITEM_ENCODING_REQUEST(Destination)
	INSERT INTO #RO_RUNOUT_LIST
	SELECT DISTINCT GID, '' AS LICENSE_PLATE,'' AS SUBSYSTEM,'' AS LOCATION,NULL AS TIME_STAMP,'' AS REASON
	FROM #RO_DUMPBAG_TEMP RDT
	WHERE NOT EXISTS(SELECT IRD.GID 
					 FROM	ITEM_REDIRECT IRD,LOCATIONS LOC WITH (NOLOCK)
					 WHERE	IRD.GID=RDT.GID
						AND IRD.DESTINATION_1=LOC.LOCATION_ID AND LOC.LOCATION=@DUMPLOC
						AND IRD.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
					)
	  AND NOT EXISTS(SELECT IEC.GID 
					 FROM	ITEM_ENCODED IEC,LOCATIONS LOC WITH (NOLOCK)
					 WHERE	IEC.GID=RDT.GID
						AND IEC.ENCODING_TYPE='3'--Encoded by Destination
						AND IEC.DEST=LOC.LOCATION_ID AND LOC.LOCATION=@DUMPLOC
						AND IEC.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
					)

	--3. Query the ATR read info into temp table #BT_ITEM_TAGREAD_TEMP
	SELECT ISC.GID, ISC.LICENSE_PLATE1, ISC.LICENSE_PLATE2, ISC.LOCATION, ISC.TIME_STAMP 
	INTO #RO_ITEM_TAGREAD_TEMP
	FROM ITEM_SCANNED ISC, #RO_RUNOUT_LIST RNOT WITH(NOLOCK)
	WHERE ISC.GID=RNOT.GID
		AND ISC.TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO)
		AND (ISC.STATUS_TYPE='1' OR ISC.STATUS_TYPE='3' OR ISC.STATUS_TYPE='7');
	--ORDER BY ISC.TIME_STAMP DESC; 

	--4. Query the MES read info into temp table #BT_ITEM_TAGREAD_TEMP 
	INSERT INTO #RO_ITEM_TAGREAD_TEMP
	SELECT IEC.GID,IEC.LICENSE_PLATE AS LICENSE_PLATE1,'0000000000' AS LICENSE_PLATE2,IEC.LOCATION,IEC.TIME_STAMP 
	FROM ITEM_ENCODED IEC,#RO_RUNOUT_LIST RNOT WITH(NOLOCK)
	WHERE IEC.GID=RNOT.GID
		AND IEC.LICENSE_PLATE IS NOT NULL AND LEN(IEC.LICENSE_PLATE)<>0
		AND IEC.TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO)

	--5. The latest sortation event timestamp for each gid
	SELECT ISE.GID,ISE.LOCATION,ISE.SORT_DESTINATION,ISE.SORT_EVENT_TYPE,ISE.TIME_STAMP
	INTO #RO_ITEM_SORTATION_EVENT_TEMP
	FROM ITEM_SORTATION_EVENT ISE
	WHERE ISE.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
		AND EXISTS(SELECT GID FROM #RO_RUNOUT_LIST RRL WHERE ISE.GID=RRL.GID)

	SELECT ISE.GID,ISE.TIME_STAMP,LOC.SUBSYSTEM,LOC.LOCATION,ISET.DESCRIPTION
	INTO #RO_ISE_LATEST_TEMP
	FROM #RO_ITEM_SORTATION_EVENT_TEMP ISE, #RO_RUNOUT_LIST RRL, ITEM_SORTATION_EVENT_TYPES ISET, LOCATIONS LOC
	WHERE RRL.GID=ISE.GID
		AND ISE.SORT_EVENT_TYPE=ISET.TYPE
		AND ISE.LOCATION=LOC.LOCATION_ID
		AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@Subsystem))
		AND ISE.TIME_STAMP=(SELECT MAX(ISE2.TIME_STAMP) FROM #RO_ITEM_SORTATION_EVENT_TEMP ISE2 WHERE ISE2.GID=ISE.GID);

	--6. Update the sortation infomation according to #RO_ISE_LATEST_TEMP
	UPDATE	RRL
	SET		RRL.SUBSYSTEM=ISEL.SUBSYSTEM,
			RRL.TIME_STAMP=ISEL.TIME_STAMP,
			RRL.LICENSE_PLATE=
			CASE
				--IATA TAG
				WHEN TGR.LICENSE_PLATE1 LIKE '0%' AND TGR.LICENSE_PLATE1<>'0000000000' AND TGR.LICENSE_PLATE1<>'999999999' AND LEN(TGR.LICENSE_PLATE1)=10
					THEN TGR.LICENSE_PLATE1
				WHEN TGR.LICENSE_PLATE2 LIKE '0%' AND TGR.LICENSE_PLATE2<>'0000000000' AND TGR.LICENSE_PLATE2<>'999999999' AND LEN(TGR.LICENSE_PLATE1)=10
					THEN TGR.LICENSE_PLATE2
				--FALLBACK TAG
				WHEN LEN(TGR.LICENSE_PLATE1)=10 AND TGR.LICENSE_PLATE1 LIKE '1%'
					THEN TGR.LICENSE_PLATE1 --NULL
				WHEN LEN(TGR.LICENSE_PLATE2)=10 AND TGR.LICENSE_PLATE2 LIKE '1%'
					THEN TGR.LICENSE_PLATE2 --NULL
				--4 DIGIT TAG
				WHEN LEN(TGR.LICENSE_PLATE1)=4
					THEN TGR.LICENSE_PLATE1
				WHEN LEN(TGR.LICENSE_PLATE2)=4
					THEN TGR.LICENSE_PLATE2
				ELSE TGR.LICENSE_PLATE1
			END, 
			RRL.LOCATION=ISEL.LOCATION,
			RRL.REASON=ISEL.DESCRIPTION
	FROM #RO_RUNOUT_LIST RRL, #RO_ISE_LATEST_TEMP ISEL
	LEFT JOIN #RO_ITEM_TAGREAD_TEMP TGR WITH(NOLOCK)
		ON ISEL.GID=TGR.GID
	WHERE RRL.GID=ISEL.GID
		

	--7. ITEM_LOST TO DUMP
	UPDATE	RRL
	SET		RRL.SUBSYSTEM=LOC.SUBSYSTEM,
			RRL.TIME_STAMP=GID.TIME_STAMP,
			RRL.LICENSE_PLATE='GID: ' + GID.GID,
			RRL.LOCATION=LOC.LOCATION,
			RRL.REASON='Stray Bag'--'Lost Tracking'
	FROM #RO_RUNOUT_LIST RRL, GID_USED GID WITH(NOLOCK)
	INNER JOIN LOCATIONS LOC ON GID.LOCATION=LOC.LOCATION_ID
	WHERE RRL.GID=GID.GID
		AND GID.BAG_TYPE='02'--STRAY BAG
		AND RRL.TIME_STAMP IS NULL
		AND GID.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
		AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@Subsystem))

	SELECT GID,SUBSYSTEM,TIME_STAMP,LICENSE_PLATE,LOCATION AS EUIPMENT_ID,REASON
	FROM #RO_RUNOUT_LIST
	--WHERE TIME_STAMP<>''
	ORDER BY SUBSYSTEM,TIME_STAMP;

END

--DECLARE @DTFrom datetime='2014-03-01';
--DECLARE @DTTo datetime='2014-03-25';
--DECLARE @Subsystem varchar(max)='ML1';
--EXEC stp_RPT_OKC_RUNOUT @DTFrom,@DTTo,@Subsystem;

GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_ScreeningStatus]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_CLT_ScreeningStatus]
	@DTFrom [datetime],
	@DTTo [datetime]
AS
BEGIN
	SET NOCOUNT ON;

	--11	Machine Alarm / operator alarm			ALARM
	--12	Machine Alarm / operator clear			CLEAR
	--13	Machine Alarm / operator unknown		ALARM
	--14	Machine Alarm / operator pending		NO DECISION
	--15	Machine Alarm / operator timed out		NO DECISION
	--21	Machine clear / operator alarm			ALARM
	--22	Machine clear / operator clear			CLEAR
	--23	Machine clear / operator unknown		ALARM
	--24	Machine clear / operator pending		NO DECISION
	--25	Machine clear / Operator timed out		NO DECISION
	--33	Error / Unknown							UNKNOWN
	--X	Error / Unknown								UNKNOWN
	print '[stp_RPT22_ScreeningStatus_GWYTEST]';


	--1. Insert item_screened data into a temp table

	SELECT LOCATION,GID,SCREEN_LEVEL,TIME_STAMP,RESULT_TYPE
	INTO #EDS_ITEM_SCREENED_TEMP
	FROM ITEM_SCREENED WITH(NOLOCK)
	WHERE TIME_STAMP BETWEEN @DTFrom AND @DTTo;

	--2 select eds machine(level1) result detail into a temp table
	--SELECT ICR.GID, ICR.TIME_STAMP, 
	--	CASE 
	--		WHEN ICR.RESULT_TYPE LIKE '2%' THEN 'Cleared'
	--		WHEN ICR.RESULT_TYPE LIKE '1%' THEN 'Alarmed'
	--		ELSE 'Unknown'
	--	END AS RESULT
	--INTO #EDS_RESULT_TEMP
	--FROM #EDS_ITEM_SCREENED_TEMP ICR, LOCATIONS LOC
	--WHERE ICR.SCREEN_LEVEL='1'
	--	AND ICR.LOCATION=LOC.LOCATION_ID

	--SELECT * FROM #EDS_RESULT_TEMP;

	--3 update eds result for #EDS_RESULT_TEMP by level 2 screened result
	SELECT ICR.GID, ICR.TIME_STAMP, 
		CASE
			WHEN ICR.RESULT_TYPE='12' OR ICR.RESULT_TYPE='22' THEN 'Cleared'
			WHEN ICR.RESULT_TYPE='11' OR ICR.RESULT_TYPE='21' OR ICR.RESULT_TYPE='13' OR ICR.RESULT_TYPE='23' THEN 'Alarmed'
			WHEN ICR.RESULT_TYPE='14' OR ICR.RESULT_TYPE='24' OR ICR.RESULT_TYPE='15' OR ICR.RESULT_TYPE='25' THEN 'No Decision'
			ELSE 'Unknown'
		END AS RESULT
	INTO #EDS_RESULT_TEMP
	FROM #EDS_ITEM_SCREENED_TEMP ICR
	--WHERE ERT.GID=ICR.GID
		--AND ICR.SCREEN_LEVEL='2'

	--4 calculate the statistics result
	SELECT COUNT(GID) AS Number_Bags, ERT.RESULT
	FROM #EDS_RESULT_TEMP ERT
	GROUP BY ERT.RESULT

END

--DECLARE @DTFrom [datetime]='2014-1-11';
--DECLARE @DTTo [datetime]='2014-1-12';
--EXEC stp_RPT22_ScreeningStatus_GWYTEST @DTFrom,@DTTo;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_SortAreaAssignment]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_SortAreaAssignment]
		  @DTFrom datetime , 
		  @DTTo datetime
AS
BEGIN
	PRINT 'SortAreaAssignment STORED PROCEDURE BEGIN';

	SELECT frc.CURRENT_RESOURCE as Physical_MakeUp, frc.NEW_RESOURCE as AssignedTo
	FROM FLIGHT_RESOURCE_CHANGE frc
	WHERE TIME_STAMP BETWEEN @DTFrom AND @DTTo
END
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_SortCorrelation]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[stp_RPT_CLT_SortCorrelation]
		  @SDO datetime , 
		  @AIRLINE varchar(max)
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;

	SET @SDO=CONVERT(DATETIME,CONVERT(VARCHAR,@SDO,103),103);

	--Create temp table for final result
	CREATE TABLE #SC_SortCorrelation_TEMP 
	(
		SDO datetime,
		AIRLINE varchar(3),
		FLIGHT_NUMBER varchar(5),
		DESTINATION varchar(3),
		CLOSEOUT_TIME datetime,
		DEPARTURE_TIME datetime,
		SORTED_MU varchar(100),
		DEFAULT_MU varchar(10),
		FLIGHT_DAYS varchar(15),
		PRIMARY_MU varchar(100),
		FIRST_MU varchar(10),
		BUSINESS_MU varchar(10),
		HOT_MU varchar(10),
		LATE_MU varchar(10),
		STANDBY_MU varchar(10),
	);

	--1. Query flight info into final table
	INSERT INTO #SC_SortCorrelation_TEMP
	SELECT DISTINCT fpa.SDO, fpa.AIRLINE, fpa.FLIGHT_NUMBER, fpa.FLIGHT_DESTINATION, 
		MAX(CASE FPA.ALLOC_CLOSE_RELATED
			WHEN 'ETD' 
				--THEN CONVERT(DATETIME,CONVERT(VARCHAR,FPA.EDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(dbo.SAC_OFFSETOPERATOR(FPA.ETO,FPA.ALLOC_CLOSE_OFFSET)),103)
				THEN DBO.RPT_TIME_CAL(FPA.EDO,FPA.ETO,FPA.ALLOC_CLOSE_OFFSET)
			ELSE 
				--CONVERT(DATETIME,CONVERT(VARCHAR,FPA.SDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(dbo.SAC_OFFSETOPERATOR(FPA.STO,FPA.ALLOC_CLOSE_OFFSET)),103)
				DBO.RPT_TIME_CAL(FPA.SDO,FPA.STO,FPA.ALLOC_CLOSE_OFFSET)
		END) AS CLOSEOUT_TIME,
		CASE 
			WHEN FPA.EDO IS NULL 
				THEN CONVERT(DATETIME,CONVERT(VARCHAR,FPA.SDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(FPA.STO),103)
			ELSE 
				CONVERT(DATETIME,CONVERT(VARCHAR,FPA.EDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(FPA.ETO),103)
		END AS DEPARTURE_TIME,
		'' AS SORTED_MU,
		'' AS DEFAULT_MU,
		'' AS FLIGHT_WEEKDAYS,
		'' AS PRIMARY_MU, '' AS FIRST_MU, '' AS BUSINESS_MU, '' AS HOT_MU, '' AS LATE_MU, '' AS STANDBY_MU
	FROM FLIGHT_PLAN_ALLOC fpa WITH(NOLOCK)
	WHERE fpa.SDO=@SDO AND fpa.AIRLINE IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@AIRLINE)) 
	GROUP BY  fpa.SDO, fpa.AIRLINE, fpa.FLIGHT_NUMBER, fpa.FLIGHT_DESTINATION,
		CASE 
			WHEN FPA.EDO IS NULL THEN CONVERT(DATETIME,CONVERT(VARCHAR,FPA.SDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(FPA.STO),103)
			ELSE CONVERT(DATETIME,CONVERT(VARCHAR,FPA.EDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(FPA.ETO),103)
		END 

	
	--2. Update first, business, hot, late and standby MU into final table
	UPDATE SST
	SET SST.DEFAULT_MU=AIR.DESTINATION
	FROM AIRLINES AIR,#SC_SortCorrelation_TEMP SST
	WHERE AIR.CODE_IATA=SST.AIRLINE;--DEFAULT_MU

	UPDATE #SC_SortCorrelation_TEMP
	SET #SC_SortCorrelation_TEMP.FIRST_MU=FAL.RESOURCE
	FROM FUNCTION_ALLOC_LIST FAL
	WHERE FAL.FUNCTION_TYPE='FCPB';--FIRST
	
	UPDATE #SC_SortCorrelation_TEMP
	SET #SC_SortCorrelation_TEMP.BUSINESS_MU=FAL.RESOURCE
	FROM FUNCTION_ALLOC_LIST FAL
	WHERE FAL.FUNCTION_TYPE='BCPB';--BUSINESS
	
	UPDATE #SC_SortCorrelation_TEMP
	SET #SC_SortCorrelation_TEMP.HOT_MU=FAL.RESOURCE
	FROM FUNCTION_ALLOC_LIST FAL
	WHERE FAL.FUNCTION_TYPE='RUSH';--RUSH OR HOT
	
	UPDATE #SC_SortCorrelation_TEMP
	SET #SC_SortCorrelation_TEMP.LATE_MU=FAL.RESOURCE
	FROM FUNCTION_ALLOC_LIST FAL
	WHERE FAL.FUNCTION_TYPE='LATE';--LATE
	
	UPDATE #SC_SortCorrelation_TEMP
	SET #SC_SortCorrelation_TEMP.STANDBY_MU=FAL.RESOURCE
	FROM FUNCTION_ALLOC_LIST FAL
	WHERE FAL.FUNCTION_TYPE='SBPB';--STANDBY
	
	
	--CREATE TYPE ALLOCINFO_TABLETYPE AS TABLE 
	--( 
	--	AIRLINE varchar(3),
	--	FLIGHT_NUMBER varchar(5),
	--	SDO datetime,
	--	ALLOCINFO VARCHAR(10)
	--);

	--CREATE TYPE ALLOCCOMINFO_TABLETYPE AS TABLE
	--( 
	--	AIRLINE varchar(3),
	--	FLIGHT_NUMBER varchar(5),
	--	SDO datetime,
	--	COMBINEINFO VARCHAR(200)
	--);

	--3. Update primary MU and sorted MU into final table
	DECLARE @SC_ALLOCINFO_TABLE AS ALLOCINFO_TABLETYPE; --For the parameter of stp_RPT_AllocInfoCombine
	DECLARE @SC_COMBINEINFO_TABLE AS ALLOCCOMINFO_TABLETYPE;--For the result of stp_RPT_AllocInfoCombine
	
	INSERT INTO @SC_ALLOCINFO_TABLE
	SELECT DISTINCT SC.AIRLINE,SC.FLIGHT_NUMBER,SC.SDO,FPA.RESOURCE
	FROM #SC_SortCorrelation_TEMP SC, FLIGHT_PLAN_ALLOC fpa WITH(NOLOCK)
	WHERE SC.AIRLINE=FPA.AIRLINE AND SC.FLIGHT_NUMBER=FPA.FLIGHT_NUMBER AND SC.SDO=FPA.SDO

	INSERT INTO @SC_COMBINEINFO_TABLE
	EXEC DBO.stp_RPT_AllocInfoCombine @SC_ALLOCINFO_TABLE

	UPDATE SC
	SET SC.SORTED_MU=COMB.COMBINEINFO, SC.PRIMARY_MU=COMB.COMBINEINFO
	FROM #SC_SortCorrelation_TEMP SC, @SC_COMBINEINFO_TABLE COMB
	WHERE SC.AIRLINE=COMB.AIRLINE AND SC.FLIGHT_NUMBER=COMB.FLIGHT_NUMBER AND SC.SDO=COMB.SDO;

	--4. Update weekday (FLIGHT_WEEKDAYS) into final table
	DELETE @SC_ALLOCINFO_TABLE;
	DELETE @SC_COMBINEINFO_TABLE;

	INSERT INTO @SC_ALLOCINFO_TABLE
	SELECT DISTINCT SC.AIRLINE,SC.FLIGHT_NUMBER,SC.SDO AS SDO,fpa.WEEKDAY
	FROM #SC_SortCorrelation_TEMP SC, FLIGHT_PLAN_ALLOC fpa WITH(NOLOCK)
	WHERE SC.AIRLINE=FPA.AIRLINE AND SC.FLIGHT_NUMBER=FPA.FLIGHT_NUMBER
		--AND FPA.SDO BETWEEN DATEADD(DAY,-@DATERANGE,@SDO) AND DATEADD(DAY,@DATERANGE,@SDO);
		AND FPA.SDO BETWEEN @SDO AND DATEADD(DAY,@DATERANGE,@SDO);

	--SELECT * FROM @SC_ALLOCINFO_TABLE;

	INSERT INTO @SC_COMBINEINFO_TABLE
	EXEC DBO.stp_RPT_AllocInfoCombine @SC_ALLOCINFO_TABLE

	--SELECT * FROM @SC_COMBINEINFO_TABLE;

	UPDATE SC
	SET SC.FLIGHT_DAYS=COMB.COMBINEINFO
	FROM #SC_SortCorrelation_TEMP SC, @SC_COMBINEINFO_TABLE COMB
	WHERE SC.AIRLINE=COMB.AIRLINE AND SC.FLIGHT_NUMBER=COMB.FLIGHT_NUMBER-- AND SC.SDO=COMB.SDO;

	SELECT DISTINCT * FROM #SC_SortCorrelation_TEMP SC;
END


--DECLARE @AIRLINE VARCHAR(MAX)='AA, AC, B6, BA, BR, DL, UA, US';
--DECLARE @SDO DATETIME='2014/1/7';
--EXEC stp_RPT04_SortCorrelation_GWYTEST @SDO,@AIRLINE;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_STANDBY_BAGGAGE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_CLT_STANDBY_BAGGAGE]
		  @DTFROM DATETIME,
		  @DTTO DATETIME
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;
	DECLARE @HOURRANGE INT=1;

	--Create temp table for final result
	CREATE TABLE #SBB_STANDBY_BAGGAGE_TEMP 
	(
		TIME_STAMP DATETIME,
		GID BIGINT,
		LICENSE_PLATE VARCHAR(10),
		PAX_NAME VARCHAR(200),
		FLIGHT_NUMBER VARCHAR(5),
		AIRLINE VARCHAR(3),
		SDO DATETIME,
		TAG_READ_TIME DATETIME,
		TAG_READ_LOCATION VARCHAR(20),
		ALLOC_MU VARCHAR(10),
		SORTED_MU VARCHAR(10),
	);

	--INSERT INTO #SBB_STANDBY_BAGGAGE_TEMP EXEC DBO.stp_RPT_BAGTAG_GWYTEST

	--1. Query the bags data from BSM
	SELECT DISTINCT TIME_STAMP, LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE, SDO INTO #SBB_BAG_SORTING_TEMP
	FROM 
	(
		SELECT TIME_STAMP, LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE, SDO
		FROM BAG_SORTING WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE, @DTFrom) AND DATEADD(HOUR,@HOURRANGE, @DTTo)	
			--AND AIRLINE IN (SELECT * FROM RPT_GETPARAMETERS(@AIRLINE)) 
			--AND FLIGHT_NUMBER IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@FLIGHTNUM))
			AND RECONCILIATION_PASSENGER_STATUS='S'
			
		UNION ALL
		SELECT TIME_STAMP, LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE, SDO
		FROM BAG_SORTING_HIS WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE, @DTFrom) AND DATEADD(HOUR,@HOURRANGE, @DTTo) 
			--AND AIRLINE IN (SELECT * FROM RPT_GETPARAMETERS(@AIRLINE)) 
			--AND FLIGHT_NUMBER IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@FLIGHTNUM))
			AND RECONCILIATION_PASSENGER_STATUS='S'
	) AS BAG_SORTING_ALL ;

	--2. Insert bags data into final table
	INSERT INTO #SBB_STANDBY_BAGGAGE_TEMP
	SELECT TIME_STAMP, NULL AS GID, LICENSE_PLATE, (ISNULL(GIVEN_NAME,'')+' '+ISNULL(SURNAME,'')+' '+ISNULL(OTHERS_NAME,''))  AS PAX_NAME,
		   FLIGHT_NUMBER, AIRLINE, SDO, NULL AS TAG_READ_TIME,'' AS TAG_READ_LOCATION,'' AS ALLOC_MU,'' AS SORTED_MU
	FROM #SBB_BAG_SORTING_TEMP

	CREATE INDEX #SBB_STANDBY_BAGGAGE_TEMP_IDXLP ON #SBB_STANDBY_BAGGAGE_TEMP(LICENSE_PLATE);


	--3. Query the ATR read info into temp table #BT_ITEM_TAGREAD_TEMP
	SELECT ISC.GID, ISC.LICENSE_PLATE1, ISC.LICENSE_PLATE2, ISC.LOCATION, ISC.TIME_STAMP INTO #BT_ITEM_TAGREAD_TEMP
	FROM ITEM_SCANNED ISC, #SBB_STANDBY_BAGGAGE_TEMP SBB WITH(NOLOCK)
	WHERE (ISC.LICENSE_PLATE1=SBB.LICENSE_PLATE OR ISC.LICENSE_PLATE2=SBB.LICENSE_PLATE)
		AND ISC.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
		AND (ISC.STATUS_TYPE='1' OR ISC.STATUS_TYPE='3' OR ISC.STATUS_TYPE='7')
	--ORDER BY ISC.TIME_STAMP DESC; 

	--4. Query the MES read info into temp table #BT_ITEM_TAGREAD_TEMP 
	INSERT INTO #BT_ITEM_TAGREAD_TEMP
	SELECT IER.GID,IER.LICENSE_PLATE AS LICENSE_PLATE1,'0000000000' AS LICENSE_PLATE2,IER.LOCATION,IER.TIME_STAMP 
	FROM ITEM_ENCODING_REQUEST IER,#SBB_STANDBY_BAGGAGE_TEMP SBB WITH(NOLOCK)
	WHERE IER.LICENSE_PLATE=SBB.LICENSE_PLATE
		AND IER.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)

	--In Charlotte project, there are 2 ATRs and MES a bag may goes through. 
	--So stored procedure must find the lastest location where item_scanned telegram is sent ordered by time_stamp

	--SELECT GID, LICENSE_PLATE1, LICENSE_PLATE2, LOCATION, TIME_STAMP INTO #BT_TAGREAD_TEMP
	--FROM #BT_ITEM_TAGREAD_TEMP
	--ORDER BY TIME_STAMP DESC;

	DECLARE @TAGREAD_TABLE AS TAGREAD_TABLETYPE; --For the parameter of stp_RPT_GET_LATEST_TAGREAD

	INSERT INTO @TAGREAD_TABLE
	SELECT * FROM #BT_ITEM_TAGREAD_TEMP;

	CREATE TABLE #BT_TAGREAD_TEMP
	( 
		GID VARCHAR(10),
		LICENSE_PLATE VARCHAR(10), 
		LOCATION VARCHAR(20), 
		TIME_STAMP DATETIME
	);

	INSERT INTO #BT_TAGREAD_TEMP
	EXEC dbo.stp_RPT_GET_LATEST_TAGREAD @TAGREAD_TABLE;


	CREATE INDEX #BT_TAGREAD_TEMP_IDXLP ON #BT_TAGREAD_TEMP(LICENSE_PLATE);
	--CREATE INDEX #BT_TAGREAD_TEMP_IDXGID ON #BT_TAGREAD_TEMP(LICENSE_PLATE2);

	--5. Update ATR OR MES read info(GID,TAG_READ_TIME,TAG_READ_LOCATION) into final table
	UPDATE SBB
	SET SBB.GID=ITT.GID,SBB.TAG_READ_TIME=ITT.TIME_STAMP,SBB.TAG_READ_LOCATION=LOC.LOCATION
	FROM #BT_TAGREAD_TEMP ITT, #SBB_STANDBY_BAGGAGE_TEMP SBB, LOCATIONS LOC
	WHERE ITT.LICENSE_PLATE=SBB.LICENSE_PLATE
		AND ITT.LOCATION=LOC.LOCATION_ID

	CREATE INDEX #SBB_STANDBY_BAGGAGE_TEMP_IDXGID ON #SBB_STANDBY_BAGGAGE_TEMP(GID);

	--6. Update Flight Allocation Make-up carousel(ALLOC_MU) into final table
	UPDATE SBB
	SET SBB.ALLOC_MU=FPA.RESOURCE
	FROM FLIGHT_PLAN_ALLOC FPA, #SBB_STANDBY_BAGGAGE_TEMP SBB WITH(NOLOCK)
	WHERE FPA.AIRLINE=SBB.AIRLINE AND FPA.FLIGHT_NUMBER=SBB.FLIGHT_NUMBER
		AND FPA.SDO=SBB.SDO;

	--7. Update sorted MU(SORTED_MU) into final table
	UPDATE SBB
	SET SBB.SORTED_MU=LOC.LOCATION
	FROM ITEM_PROCEEDED IPR, LOCATIONS LOC,#SBB_STANDBY_BAGGAGE_TEMP SBB WITH(NOLOCK)
	WHERE IPR.GID=SBB.GID AND SBB.GID IS NOT NULL
		AND IPR.PROCEED_LOCATION = LOC.LOCATION_ID
		AND LOC.SUBSYSTEM LIKE 'MU%'
		AND IPR.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO);


	SELECT * FROM #SBB_STANDBY_BAGGAGE_TEMP;

END


--DECLARE @DTFROM datetime='2014-1-1';
--DECLARE @DTTO datetime='2014-1-3';
--EXEC stp_RPT_STANDBY_BAGGAGE_GWYTEST @DTFROM,@DTTO;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_TIMEINSYSTEM]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[stp_RPT_CLT_TIMEINSYSTEM]
		  @DTFROM DATETIME,
		  @DTTO DATETIME,
		  @Interval INT
AS
BEGIN
--PROBLEM1: EDS LEVEL1 & LEVEL2 AVERAGE GO-THROUGHT TIME

	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @HOURRANGE INT=1;
	DECLARE @DATERANGE INT=1;

	--1. Query the bags data from BSM
	SELECT DISTINCT LICENSE_PLATE,BSM_RECD_TIME,TAG_PRINT_TIME INTO #TIS_BAG_SORTING_TEMP
	FROM 
	(
		SELECT LICENSE_PLATE,TIME_STAMP AS BSM_RECD_TIME,CHECK_IN_TIME_STAMP AS TAG_PRINT_TIME
		FROM BAG_SORTING WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE, @DTFrom) AND DATEADD(DAY,@DATERANGE, @DTTo)	
				
		UNION ALL
		SELECT LICENSE_PLATE,TIME_STAMP AS BSM_RECD_TIME,CHECK_IN_TIME_STAMP AS TAG_PRINT_TIME
		FROM BAG_SORTING_HIS WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE, @DTFrom) AND DATEADD(DAY,@DATERANGE, @DTTo) 
	) AS BAG_SORTING_ALL ;
	
	--CREATE TABLE FOR FINAL STATISTIC
	CREATE TABLE #TIS_TIMEINSYSTEM_TEMP
	(
		START_TIME DATETIME,
		END_TIME DATETIME,
		MAX_TIME INT,--SECONDS
		MIN_TIME INT,--SECONDS
		AVG_TIME INT,--SECONDS

		EDSLVL1_AVGTIME INT,
		EDSLVL2_AVGTIME INT
	);

	--Create table for all bags time detail
	--Start Time when bags entering into system BY GID at the entrance ATR
	--End Time when bags are sorted to MU BY GID at the mainline ATR
	CREATE TABLE #TIS_BAGS_TIMEDETAIL
	(
		LICENSE_PLATE varchar(10),
		FIRST_ATR_GID varchar(10),
		STARTTIME datetime,
		SECOND_ATR_GID varchar(10),
		ENDTIME datetime,
		TRAVEL_DURATION INT,

		ENTER_ITI_TIME DATETIME,
		ICR_LVL1_TIME DATETIME,
		ICR_LVL2_TIME DATETIME,
		LVL1_DURATION INT,
		LVL2_DURATION INT
	);

	--1. Insert bag info(license plate) and entering time BY GID at the entrance ATR
	INSERT INTO #TIS_BAGS_TIMEDETAIL
	SELECT 
		CASE
			WHEN ISC.LICENSE_PLATE1 LIKE '0%' AND ISC.LICENSE_PLATE1<>'0000000000' AND ISC.LICENSE_PLATE1<>'999999999' AND LEN(LICENSE_PLATE1)=10
				THEN ISC.LICENSE_PLATE1
			WHEN ISC.LICENSE_PLATE2 LIKE '0%' AND ISC.LICENSE_PLATE2<>'0000000000' AND ISC.LICENSE_PLATE2<>'999999999' AND LEN(LICENSE_PLATE1)=10
				THEN ISC.LICENSE_PLATE2
		END AS LICENSE_PLATE, 
		ISC.GID AS FIRST_ATR_GID,
		NULL AS STARTTIME,
		NULL AS SECOND_ATR_GID,
		NULL AS ENDTIME,
		NULL AS TRAVEL_DURATION,
		NULL AS ENTER_ITI_TIME, NULL AS ICR_LVL1_TIME, NULL AS ICR_LVL2_TIME, NULL AS LVL1_DURATION, NULL AS LVL2_DURATION
	FROM ITEM_SCANNED ISC, 
		 --GID_USED GUD, 
		 --LOCATIONS GID_LOC,
		 LOCATIONS ISC_LOC WITH(NOLOCK)
	WHERE ISC.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		--AND ISC.GID=GUD.GID
		--AND GUD.TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO)
		AND (ISC.LICENSE_PLATE1 LIKE '0%' OR ISC.LICENSE_PLATE2 LIKE '0%')
		AND (	 (ISC.LICENSE_PLATE1 <>'0000000000' AND ISC.LICENSE_PLATE1<>'999999999' AND LEN(LICENSE_PLATE1)=10) 
			  OR (ISC.LICENSE_PLATE2 <>'0000000000' AND ISC.LICENSE_PLATE2<>'999999999' AND LEN(LICENSE_PLATE1)=10)
			)
		--AND GUD.LOCATION=GID_LOC.LOCATION_ID
		--AND GID_LOC.LOCATION IN ('','','','','','')--
		AND ISC.LOCATION=ISC_LOC.LOCATION_ID
		AND EXISTS( SELECT * FROM MIS_SS_LINE_DEVICE MSLD WHERE MSLD.ATR_LOCATION=ISC_LOC.LOCATION)
		--AND ISC_LOC.LOCATION IN ('SS1-2','SS2-2','SS3-2','SS4-2');---THE ATR AT THE CHECKIN LOCATION

	

	--2 Update the start time by BSM Tag print time or BSM time stamp
	UPDATE TBT
	SET TBT.STARTTIME=
		(	CASE 
				WHEN BS.TAG_PRINT_TIME IS NOT NULL THEN TAG_PRINT_TIME
				ELSE BS.BSM_RECD_TIME
			END 
		)
	FROM #TIS_BAGS_TIMEDETAIL TBT, #TIS_BAG_SORTING_TEMP BS
	WHERE TBT.LICENSE_PLATE=BS.LICENSE_PLATE;

	--SELECT * FROM #TIS_BAGS_TIMEDETAIL;

	--3. Query the data of the bags which are proceeded to make-up carousel
	SELECT IPR.GID, MAX(IPR.TIME_STAMP) AS TIME_STAMP
	INTO #TIS_ITEM_PROCEEDED_TEMP
	FROM ITEM_PROCEEDED IPR,LOCATIONS PRD_LOC WITH(NOLOCK)
	WHERE IPR.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
		AND IPR.PROCEED_LOCATION=PRD_LOC.LOCATION_ID
		AND PRD_LOC.LOCATION IN ('MU1','MU2','MU3','MU4','MU5','MU6')
	GROUP BY IPR.GID;

	--4. Update the end time BY GID at the mainline ATR with same license plate
	UPDATE TBT
	SET TBT.SECOND_ATR_GID=ISC.GID, TBT.ENDTIME=IPR.TIME_STAMP
	FROM #TIS_BAGS_TIMEDETAIL TBT, 
		 ITEM_SCANNED ISC, 
		 LOCATIONS ISC_LOC,
		 #TIS_ITEM_PROCEEDED_TEMP IPR WITH(NOLOCK)
	WHERE (TBT.LICENSE_PLATE=ISC.LICENSE_PLATE1 OR TBT.LICENSE_PLATE=ISC.LICENSE_PLATE2)
		AND ISC.LOCATION=ISC_LOC.LOCATION_ID
		AND ISC.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
		AND ISC.LOCATION IN ('ML1-2','ML2-2','ML3-2','ML4-2')
		AND ISC.GID=IPR.GID
		--AND IPR.PROCEED_LOCATION=PRD_LOC.LOCATION_ID
		--AND PRD_LOC.LOCATION IN ('MU1','MU2','MU3','MU4','MU5','MU6')
		--AND IPR.TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO);	
	
	--SELECT * FROM #TIS_BAGS_TIMEDETAIL;	

	--5. Calculate the duration(SECONDS) between start time and end time
	UPDATE TBT
	SET TBT.TRAVEL_DURATION = DATEDIFF(SECOND,TBT.STARTTIME,TBT.ENDTIME)
	FROM #TIS_BAGS_TIMEDETAIL TBT
	WHERE TBT.ENDTIME IS NOT NULL AND TBT.STARTTIME IS NOT NULL;


	--6. Update ITI timestamp before EDS, ICR timestamp of level1 and leve2 into #TIS_BAGS_TIMEDETAIL
	UPDATE TBT
	SET TBT.ENTER_ITI_TIME=PRE_ITI.TIME_STAMP,TBT.ICR_LVL1_TIME=POST_ITI.TIME_STAMP,TBT.ICR_LVL2_TIME=ICR.TIME_STAMP
	FROM #TIS_BAGS_TIMEDETAIL TBT
	INNER JOIN (	SELECT GID,MAX(TIME_STAMP) AS TIME_STAMP FROM ITEM_SCREENED WITH(NOLOCK) 
					WHERE (SCREEN_LEVEL='1' OR SCREEN_LEVEL='2' OR SCREEN_LEVEL='3')
						AND TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
					GROUP BY GID
				) AS ICR
		ON TBT.FIRST_ATR_GID=ICR.GID
			
	INNER JOIN ITEM_TRACKING PRE_ITI WITH(NOLOCK) 
		ON TBT.FIRST_ATR_GID=PRE_ITI.GID 
		AND PRE_ITI.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
		AND  EXISTS(
						SELECT ELD.PRE_XM_LOCATION 
						FROM GET_RPT_EDS_LINE_DEVICE() ELD, LOCATIONS LOC
						WHERE ELD.SUBSYSTEM=LOC.SUBSYSTEM AND ELD.PRE_XM_LOCATION=LOC.LOCATION AND PRE_ITI.LOCATION=LOC.LOCATION_ID
					)
	INNER JOIN ITEM_TRACKING POST_ITI WITH(NOLOCK) 
		ON TBT.FIRST_ATR_GID=POST_ITI.GID 
		AND POST_ITI.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
		AND  EXISTS(
						SELECT ELD.POST_XM_LOCATION 
						FROM GET_RPT_EDS_LINE_DEVICE() ELD, LOCATIONS LOC
						WHERE ELD.SUBSYSTEM=LOC.SUBSYSTEM AND ELD.POST_XM_LOCATION=LOC.LOCATION AND POST_ITI.LOCATION=LOC.LOCATION_ID
					)
	--INNER JOIN (	SELECT GID,MAX(TIME_STAMP) AS TIME_STAMP FROM ITEM_SCREENED WITH(NOLOCK) 
	--				WHERE SCREEN_LEVEL='2'
	--					AND TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO)
	--				GROUP BY GID
	--			) AS ICRLVL2 
	--	ON TBT.FIRST_ATR_GID=ICRLVL2.GID
	WHERE TBT.FIRST_ATR_GID=ICR.GID 
		AND TBT.FIRST_ATR_GID=POST_ITI.GID
		AND TBT.FIRST_ATR_GID=PRE_ITI.GID;
		
	
	--7. Calculate duration for level 1 and level 2
	UPDATE TBT
	SET TBT.LVL1_DURATION=
			CASE 
				WHEN ENTER_ITI_TIME IS NOT NULL AND ICR_LVL1_TIME IS NOT NULL
					THEN DATEDIFF(SECOND,ENTER_ITI_TIME,ICR_LVL1_TIME)
				ELSE NULL
			END,
		TBT.LVL2_DURATION=
			CASE
				WHEN ICR_LVL1_TIME IS NOT NULL AND ICR_LVL2_TIME IS NOT NULL
					THEN DATEDIFF(SECOND,ICR_LVL1_TIME,ICR_LVL2_TIME)
				ELSE NULL
			END
	FROM #TIS_BAGS_TIMEDETAIL TBT;
	
	--SELECT * FROM #TIS_BAGS_TIMEDETAIL;
	--8. Calculate the max,min and avg travel time for each interval
	DECLARE @STARTTIME_IDX DATETIME = @DTFROM;
	DECLARE @ENDTIME_IDX DATETIME = DATEADD(MINUTE,@INTERVAL,@STARTTIME_IDX);
	
	WHILE(@STARTTIME_IDX < @DTTO)
	BEGIN
		IF (@ENDTIME_IDX > @DTTO)
		BEGIN
			SET @ENDTIME_IDX=@DTTO;
		END
		
		INSERT INTO #TIS_TIMEINSYSTEM_TEMP
		SELECT @STARTTIME_IDX AS START_TIME,
			   @ENDTIME_IDX AS END_TIME,
			   MAX(TBT.TRAVEL_DURATION) AS MAX_TIME,
			   MIN(TBT.TRAVEL_DURATION) AS MIN_TIME,
			   AVG(TBT.TRAVEL_DURATION) AS AVG_TIME,
			   0 AS EDSLVL1_AVGTIME,
			   0 AS EDSLVL2_AVGTIME
		FROM #TIS_BAGS_TIMEDETAIL TBT
		WHERE TBT.STARTTIME BETWEEN @STARTTIME_IDX AND @ENDTIME_IDX
			AND TBT.TRAVEL_DURATION IS NOT NULL AND TBT.TRAVEL_DURATION > 0;

		UPDATE TIS
		SET EDSLVL1_AVGTIME=
		(	SELECT AVG(TBT.LVL1_DURATION)
			FROM #TIS_BAGS_TIMEDETAIL TBT
			WHERE TBT.ENTER_ITI_TIME BETWEEN @STARTTIME_IDX AND @ENDTIME_IDX
				AND TBT.LVL1_DURATION IS NOT NULL AND TBT.LVL1_DURATION>0
		) 
		FROM #TIS_TIMEINSYSTEM_TEMP TIS
		WHERE TIS.START_TIME=@STARTTIME_IDX AND TIS.END_TIME=@ENDTIME_IDX

		UPDATE TIS
		SET EDSLVL2_AVGTIME=
		(	SELECT AVG(TBT.LVL2_DURATION)
			FROM #TIS_BAGS_TIMEDETAIL TBT
			WHERE TBT.ENTER_ITI_TIME BETWEEN @STARTTIME_IDX AND @ENDTIME_IDX
				AND TBT.LVL2_DURATION IS NOT NULL AND TBT.LVL2_DURATION>0
		) 
		FROM #TIS_TIMEINSYSTEM_TEMP TIS
		WHERE TIS.START_TIME=@STARTTIME_IDX AND TIS.END_TIME=@ENDTIME_IDX

			
		SET @STARTTIME_IDX = DATEADD(MINUTE,@INTERVAL,@STARTTIME_IDX);
		SET @ENDTIME_IDX = DATEADD(MINUTE,@INTERVAL,@STARTTIME_IDX);
	END

	SELECT * FROM #TIS_TIMEINSYSTEM_TEMP;
	
END

--DECLARE @DTFrom [datetime]='2013-12-30 15:10:00.000';
--DECLARE @DTTo [datetime]='2013-12-30 15:20:00.000';
--DECLARE @Interval INT=1;
--exec stp_RPT26_TIMEINSYSTEM_GWYTEST @DTFrom,@DTTo,@Interval
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_CLT_TRACKEDPHOTOCELL]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_CLT_TRACKEDPHOTOCELL]
		@DTFrom [datetime],
		@DTTo [datetime],
		@SubSystem varchar(MAX)
AS
BEGIN
	SELECT SUBSYSTEM, PhotoCellID,INTERNAL_LOC, TOTAL, TYPE 
	INTO #PTK_PECTRACKING_TEMP
	FROM
	(
		--BAGS SEEN
		SELECT MBCR.SUBSYSTEM, MBCR.LOCATION AS PhotoCellID, LOC.INTERNAL_LOC, SUM(DIFFERENT) AS TOTAL, 'TOTAL_BAG' AS TYPE
		FROM MDS_COUNT MBC, MDS_COUNTERS MBCR, LOCATIONS LOC WITH(NOLOCK)
		WHERE MBC.COUNTER_ID=MBCR.COUNTER_ID
			AND MBCR.TYPE='CV'
			AND MBCR.LOCATION=LOC.LOCATION AND MBCR.SUBSYSTEM=LOC.SUBSYSTEM AND LOC.TRACKED=1 
			--AND EXISTS (SELECT LOCATION FROM LOCATIONS WHERE TRACKED = 1 AND MBCR.LOCATION=LOCATIONS.LOCATION)
			AND MBCR.SUBSYSTEM IN (SELECT * FROM RPT_GETPARAMETERS(@SubSystem))
			AND TIME_STAMP BETWEEN @DTFrom AND @DTTo 
		GROUP BY MBCR.SUBSYSTEM,MBCR.LOCATION,LOC.INTERNAL_LOC

		-- MISS BAG JAM
		UNION
		SELECT ALM_ALMAREA1 AS SUBSYSTEM, ALM_ALMEXTFLD2 AS PhotoCellID,LOC.INTERNAL_LOC,COUNT(ALM_ALMEXTFLD2) AS TOTAL, 'MSBJ' AS TYPE
		FROM MDS_ALARMS MALR, LOCATIONS LOC WITH(NOLOCK)
		WHERE (ALM_STARTTIME BETWEEN @DTFrom AND @DTTo) AND (ALM_UNCERTAIN = 0) 
			AND ALM_ALMAREA1 IN (SELECT * FROM  RPT_GETPARAMETERS(@SubSystem)) 
			AND ALM_ALMAREA2 = 'AA_MSBJ'
			AND MALR.ALM_ALMEXTFLD2=LOC.LOCATION AND LOC.TRACKED=1 
			--AND EXISTS (SELECT LOCATION FROM LOCATIONS WHERE TRACKED = 1 AND ALM_ALMEXTFLD2=LOCATIONS.LOCATION) 
		GROUP BY ALM_ALMAREA1, ALM_ALMEXTFLD2,LOC.INTERNAL_LOC

		-- HARD BAG JAM
		UNION
		SELECT ALM_ALMAREA1 AS SUBSYSTEM, ALM_ALMEXTFLD2 AS PhotoCellID,LOC.INTERNAL_LOC, COUNT(ALM_ALMEXTFLD2) AS TOTAL, 'BJAM' AS TYPE
		FROM MDS_ALARMS MALR, LOCATIONS LOC WITH(NOLOCK)
		WHERE (ALM_STARTTIME BETWEEN @DTFrom AND @DTTo) AND (ALM_UNCERTAIN = 0) 
			AND ALM_ALMAREA1 IN (SELECT * FROM  RPT_GETPARAMETERS(@SubSystem)) 
			AND ALM_ALMAREA2 = 'AA_BJAM'
			AND MALR.ALM_ALMEXTFLD2=LOC.LOCATION AND LOC.TRACKED=1 
			--AND EXISTS (SELECT LOCATION FROM LOCATIONS WHERE TRACKED = 1 AND ALM_ALMEXTFLD2=LOCATIONS.LOCATION) 	
		GROUP BY ALM_ALMAREA1, ALM_ALMEXTFLD2 ,LOC.INTERNAL_LOC

		-- MISSING BAGS
		UNION	
		SELECT LOC.SUBSYSTEM, LOC.LOCATION AS PhotoCellID,LOC.INTERNAL_LOC, COUNT(ITL.GID) AS TOTAL, 'MISS' AS TYPE
		FROM ITEM_LOST ITL, LOCATIONS LOC WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN @DTFrom AND @DTTo 
			AND ITL.LOCATION=LOC.LOCATION_ID
			AND LOC.SUBSYSTEM IN (SELECT * FROM  RPT_GETPARAMETERS(@SubSystem))
			--AND ITL.LOCATION IN (SELECT LOCATION_ID FROM LOCATIONS WHERE TRACKED = 1)
		GROUP BY LOC.SUBSYSTEM, LOC.LOCATION,LOC.INTERNAL_LOC
		

		-- UNKNOWN BAGS
		UNION
		SELECT LOC.SUBSYSTEM, LOC.LOCATION AS PhotoCellID,LOC.INTERNAL_LOC, COUNT(GID.GID) AS TOTAL, 'BHS UNKNOWN' AS TYPE
		FROM GID_USED GID, LOCATIONS LOC WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN @DTFrom AND @DTTo 
			AND GID.LOCATION=LOC.LOCATION_ID
			AND SUBSYSTEM IN (SELECT * FROM  RPT_GETPARAMETERS(@SubSystem)) 
			AND GID.BAG_TYPE = '02' 
			--AND GID.LOCATION IN (SELECT LOCATION_ID FROM LOCATIONS WHERE TRACKED = 1)
		GROUP BY LOC.SUBSYSTEM, LOC.LOCATION,LOC.INTERNAL_LOC
		
	) 
	AS TEMP_TBL
	
	CREATE TABLE #PTK_PECTRACKING_FINAL
	(
		SUBSYSTEM VARCHAR(20),
		PhotoCellID VARCHAR(20),
		INTERNAL_LOC VARCHAR(20),
		TOTAL_BAG INT,
		MISS INT,
		UNKNOWN INT,
		BJAM INT,
		MSBJ INT,
		--PEC_INDEX VARCHAR(10)
	);
	
	-- USE INTERNAL_LOC as a hidden columen to sort the result
	--INSERT INTO #PTK_PECTRACKING_FINAL
	--SELECT DISTINCT SUBSYSTEM, PhotoCellID, 0 AS TOTAL_BAG, 0 AS MISS, 0 AS UNKNOWN, 0 AS BJAM, 0 AS MSBJ,
	--	CASE 
	--		WHEN LEN(SUBSTRING(PhotoCellID,CHARINDEX('-',PhotoCellID)+1,LEN(PhotoCellID))) > 1
	--			THEN SUBSTRING(PhotoCellID,CHARINDEX('-',PhotoCellID)+1,LEN(PhotoCellID))
	--		ELSE
	--			'0' + SUBSTRING(PhotoCellID,CHARINDEX('-',PhotoCellID)+1,LEN(PhotoCellID))
	--	END AS PEC_INDEX
	--FROM #PTK_PECTRACKING_TEMP

	INSERT INTO #PTK_PECTRACKING_FINAL
	SELECT DISTINCT SUBSYSTEM, PhotoCellID,INTERNAL_LOC,0 AS TOTAL_BAG, 0 AS MISS, 0 AS UNKNOWN, 0 AS BJAM, 0 AS MSBJ
	FROM #PTK_PECTRACKING_TEMP
			
	UPDATE PPF
	SET PPF.TOTAL_BAG=PPT.TOTAL
	FROM #PTK_PECTRACKING_TEMP PPT,#PTK_PECTRACKING_FINAL PPF
	WHERE PPF.SUBSYSTEM=PPT.SUBSYSTEM 
		AND PPF.PhotoCellID=PPT.PhotoCellID
		AND PPT.TYPE='TOTAL_BAG';
		
	UPDATE PPF
	SET PPF.MISS=PPT.TOTAL
	FROM #PTK_PECTRACKING_TEMP PPT,#PTK_PECTRACKING_FINAL PPF
	WHERE PPF.SUBSYSTEM=PPT.SUBSYSTEM 
		AND PPF.PhotoCellID=PPT.PhotoCellID
		AND PPT.TYPE='MISS';
		
	UPDATE PPF
	SET PPF.UNKNOWN=PPT.TOTAL
	FROM #PTK_PECTRACKING_TEMP PPT,#PTK_PECTRACKING_FINAL PPF
	WHERE PPF.SUBSYSTEM=PPT.SUBSYSTEM 
		AND PPF.PhotoCellID=PPT.PhotoCellID
		AND PPT.TYPE='BHS UNKNOWN';
		
	UPDATE PPF
	SET PPF.BJAM=PPT.TOTAL
	FROM #PTK_PECTRACKING_TEMP PPT,#PTK_PECTRACKING_FINAL PPF
	WHERE PPF.SUBSYSTEM=PPT.SUBSYSTEM 
		AND PPF.PhotoCellID=PPT.PhotoCellID
		AND PPT.TYPE='BJAM';
	
	UPDATE PPF
	SET PPF.MSBJ=PPT.TOTAL
	FROM #PTK_PECTRACKING_TEMP PPT,#PTK_PECTRACKING_FINAL PPF
	WHERE PPF.SUBSYSTEM=PPT.SUBSYSTEM 
		AND PPF.PhotoCellID=PPT.PhotoCellID
		AND PPT.TYPE='MSBJ';
	
	SELECT * FROM #PTK_PECTRACKING_FINAL
	ORDER BY SUBSYSTEM,INTERNAL_LOC;
END


--DECLARE @DTFrom datetime='2013-11-01';
--DECLARE @DTTo datetime='2013-12-25';
--DECLARE @Subsystem varchar(max)='ED1,ED2,ED3,ED4,SS1,SS2';
--EXEC stp_RPT23_TRACKEDPHOTOCELL @DTFrom,@DTTo,@Subsystem;
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_COMPUTERPLCSTATUS_COMPUTER]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_COMPUTERPLCSTATUS_COMPUTER] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET NOCOUNT ON;
	DECLARE @temptable TABLE (APP_CODE nvarchar(30), LIVE_STATUS_TYPE varchar(10))  
	INSERT INTO @temptable select APP_CODE,'UP' from APP_LIVE_MONITORING

	

	Select * from @temptable
	--Sample 
	--select 'FIDS-Master' as APP_CODE, 'up' as LIVE_STATUS_TYPE
	--union
	--select 'FIDS-Backup','up'
	--union
	--select 'HyperV-Master','up'
	--union
	--select 'HyperV-Backup','up'
	--union
	--select 'BHSDB-Master','up'
	--union
	--select 'BHSDB-Backup','up'
	--union
	--select 'SACCOM-Master','up'
	--union
	--select 'SACCOM-Backup','up'
	--union
	--select 'MDS-Master','up'
	--union
	--select 'MDS-Backup','up'
	--union
	--select 'SAC Workstation 01','up'
	--union
	--select 'SAC Workstation 02','up'
	--union
	--select 'MDS Workstation 01','up'
	--union
	--select 'MDS Workstation 02','up'
	--union
	--select 'MES 01','down'
	--union
	--select 'MES 02','down'
	--union
	--select 'MES 03','down'
	--union
	--select 'MES 04','down'

	--select APP_CODE, LIVE_STATUS_TYPE from APP_LIVE_MONITORING
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_COMPUTERPLCSTATUS_PLC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_COMPUTERPLCSTATUS_PLC] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Sample
	select 'CL1' as APP_CODE, 'down' as LIVE_STATUS_TYPE
	union
	select 'CL2','down'
	union
	select 'CT01/02','down'
	union
	select 'CT03/04','down'
	union
	select 'CT05/06','down'
	union
	select 'CT07/08','down'
	union
	select 'CT09/10','down'
	union
	select 'CT11/12','down'
	union
	select 'CT13/14','down'
	union
	select 'DL1','down'
	union
	select 'EDS1/3','down'
	union
	select 'EDS2/4','down'
	union
	select 'MP','down'
	union
	select 'TX1','down'
	union
	select 'TX2','down'

	--select APP_CODE, LIVE_STATUS_TYPE from APP_LIVE_MONITORING
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_EQUIPMENT_MALFUNCTION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_EQUIPMENT_MALFUNCTION]
	@DTFrom datetime,
	@DTTo datetime,
	@AlarmType varchar(100),
	@SubSystem varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Declare @CriticalFactor table(CriticalLevel varchar(10))
	--IF @Level = 1
	--BEGIN
	--	insert @CriticalFactor (CriticalLevel) values ('HIHI')
	--END
	--ELSE IF @Level = 2
	--BEGIN
	--	insert @CriticalFactor (CriticalLevel) values ('HIHI')
	--	insert @CriticalFactor (CriticalLevel) values ('HIGH')
	--END
	--ELSE IF @Level = 3
	--BEGIN
	--	insert @CriticalFactor (CriticalLevel) values ('HIHI')
	--	insert @CriticalFactor (CriticalLevel) values ('HIGH')
	--	insert @CriticalFactor (CriticalLevel) values ('MEDIUM')
	--END
	--ELSE IF @Level = 4
	--BEGIN
	--	insert @CriticalFactor (CriticalLevel) values ('HIHI')
	--	insert @CriticalFactor (CriticalLevel) values ('HIGH')
	--	insert @CriticalFactor (CriticalLevel) values ('MEDIUM')
	--	insert @CriticalFactor (CriticalLevel) values ('LOW')
	--END
	--ELSE 
	--BEGIN
	--	insert @CriticalFactor (CriticalLevel) values ('HIHI')
	--	insert @CriticalFactor (CriticalLevel) values ('HIGH')
	--	insert @CriticalFactor (CriticalLevel) values ('MEDIUM')
	--	insert @CriticalFactor (CriticalLevel) values ('LOW')
	--	insert @CriticalFactor (CriticalLevel) values ('LOLO')
	--END
	
	--Select ALM_ALMEXTFLD2 as Unit_Name, ALM_ALMEXTFLD2+' '+ALM_MSGDESC as ALM_Description, ALM_STARTTIME as Time_Start,
	--ALM_ENDTIME as Time_End, 
	--RIGHT('0'+CONVERT(varchar(2),DATEDIFF(second,ALM_STARTTIME,ALM_ENDTIME)/60),2) + 
	--RIGHT('0'+CONVERT(varchar(2),DATEDIFF(second,ALM_STARTTIME,ALM_ENDTIME)%60),2) as Duration from MDS_ALARMS
	--where ALM_STARTTIME between @DTFrom and @DTTo and ALM_ALMPRIORITY in (select CriticalLevel from @CriticalFactor)

	--Sample 
	select 'Cl01_03' as Unit_Name, 'WS/Cl1-3 Check-in Row 1 Counter 3 Emergency Stop' as ALM_Description,
	'2012-12-30 10:00:01' as Time_Start, '2012-12-30 10:01:01' as Time_End, '00:60' as Duration
	union
	select 'Cl01_06' as Unit_Name, 'WS/Cl1-6 Check-in Row 1 Counter 6 Emergency Stop' as ALM_Description,
	'2012-12-30 10:00:01' as Time_Start, '2012-12-30 10:01:01' as Time_End, '00:60' as Duration
	union
	select 'Cl01_AA' as Unit_Name, 'PE/CT1-AA Over-length Detected' as ALM_Description,
	'2012-12-30 10:00:01' as Time_Start, '2012-12-30 10:01:01' as Time_End, '00:60' as Duration
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_FIDS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_FIDS]
	@DTFrom datetime,
	@DTTo datetime,
	@Flight varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TIME_STAMP, FLIGHT, [DESCRIPTION] FROM FIDS_HISTORY WHERE TIME_STAMP BETWEEN @DTFrom AND @DTTo and (FLIGHT = @Flight or @Flight = 'ALL')
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_FLIGHTCLOSEOUT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_FLIGHTCLOSEOUT]
	@DTFrom datetime,
	@DTTo datetime,
	@FlightList varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select A.FLIGHT_NUMBER, A.SDO, A.encodedTime, B.LOCATION, B.LICENSE_PLATE from
	(select FLIGHT_NUMBER, SDO, max(TIME_STAMP) as encodedTime from ITEM_ENCODED
	where TIME_STAMP between @DTFrom and @DTTo and 
	FLIGHT_NUMBER is not null and FLIGHT_NUMBER !='' 
	and (FLIGHT_NUMBER = @FlightList or @FlightList = 'ALL')
	group by FLIGHT_NUMBER, SDO) A
	left join 
	ITEM_ENCODED B on A.FLIGHT_NUMBER = B.FLIGHT_NUMBER  and A.SDO = B.SDO and A.encodedTime = B.TIME_STAMP
	
	
	
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_GET_LATEST_TAGREAD]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT_GET_LATEST_TAGREAD]
	@TAGREAD_TABLE AS TAGREAD_TABLETYPE readonly
AS
BEGIN
	
	SELECT * INTO #TAGTMP FROM @TAGREAD_TABLE;

	CREATE NONCLUSTERED INDEX #TAGTMP_IDXTIME ON #TAGTMP(TIME_STAMP);

	--In Charlotte project, there are 2 ATRs and MES a bag may goes through. 
	--So stored procedure must find the lastest location where item_scanned telegram is sent ordered by time_stamp

	-- Cannot use following method, because this will lost tags. 
	-- The tags, no matter in LICENSE_PLATE1 or LICENSE_PLATE1, no matter it is IATA, Fallback or 4-digit, all should be included in result
	--SELECT 
	--	CASE
	--		--IATA TAG
	--		WHEN TGR.LICENSE_PLATE1 LIKE '0%' AND TGR.LICENSE_PLATE1<>'0000000000' AND TGR.LICENSE_PLATE1<>'999999999' AND LEN(TGR.LICENSE_PLATE1)=10
	--			THEN TGR.LICENSE_PLATE1
	--		WHEN TGR.LICENSE_PLATE2 LIKE '0%' AND TGR.LICENSE_PLATE2<>'0000000000' AND TGR.LICENSE_PLATE2<>'999999999' AND LEN(TGR.LICENSE_PLATE1)=10
	--			THEN TGR.LICENSE_PLATE2
	--		--FALLBACK TAG
	--		WHEN LEN(TGR.LICENSE_PLATE1)=10 AND TGR.LICENSE_PLATE1 LIKE '1%'
	--			THEN TGR.LICENSE_PLATE1 --NULL
	--		WHEN LEN(TGR.LICENSE_PLATE2)=10 AND TGR.LICENSE_PLATE2 LIKE '1%'
	--			THEN TGR.LICENSE_PLATE2 --NULL
	--		--4 DIGIT TAG
	--		WHEN LEN(TGR.LICENSE_PLATE1)=4
	--			THEN TGR.LICENSE_PLATE1
	--		WHEN LEN(TGR.LICENSE_PLATE2)=4
	--			THEN TGR.LICENSE_PLATE2
	--		ELSE TGR.LICENSE_PLATE1
	--	END AS LICENSE_PLATE,MAX(TIME_STAMP) AS TIME_STAMP
	--INTO #BT_TAGREAD_LATESTTIME
	--FROM #TAGTMP TGR
	--GROUP BY 
	--	CASE
	--		WHEN TGR.LICENSE_PLATE1 LIKE '0%' AND TGR.LICENSE_PLATE1<>'0000000000' AND TGR.LICENSE_PLATE1<>'999999999' AND LEN(TGR.LICENSE_PLATE1)=10
	--			THEN TGR.LICENSE_PLATE1
	--		WHEN TGR.LICENSE_PLATE2 LIKE '0%' AND TGR.LICENSE_PLATE2<>'0000000000' AND TGR.LICENSE_PLATE2<>'999999999' AND LEN(TGR.LICENSE_PLATE1)=10
	--			THEN TGR.LICENSE_PLATE2
	--		WHEN LEN(TGR.LICENSE_PLATE1)=10 AND TGR.LICENSE_PLATE1 LIKE '1%'
	--			THEN TGR.LICENSE_PLATE1 --NULL
	--		WHEN LEN(TGR.LICENSE_PLATE2)=10 AND TGR.LICENSE_PLATE2 LIKE '1%'
	--			THEN TGR.LICENSE_PLATE2 --NULL
	--		WHEN LEN(TGR.LICENSE_PLATE1)=4
	--			THEN TGR.LICENSE_PLATE1
	--		WHEN LEN(TGR.LICENSE_PLATE2)=4
	--			THEN TGR.LICENSE_PLATE2
	--		ELSE TGR.LICENSE_PLATE1
	--	END

	SELECT LICENSE_PLATE,MAX(TIME_STAMP) AS TIME_STAMP
	INTO #BT_TAGREAD_LATESTTIME
	FROM(
			SELECT TGR.LICENSE_PLATE1 AS LICENSE_PLATE,TIME_STAMP
			FROM #TAGTMP TGR
			--WHERE TGR.LICENSE_PLATE1<>'0000000000' 
			--AND TGR.LICENSE_PLATE1<>'999999999' 
			--AND LICENSE_PLATE1 LIKE '0%' 
			--AND LEN(TGR.LICENSE_PLATE1)=10
			UNION
			SELECT TGR.LICENSE_PLATE2 AS LICENSE_PLATE,TIME_STAMP
			FROM #TAGTMP TGR
			--WHERE  TGR.LICENSE_PLATE2<>'0000000000' 
			--AND TGR.LICENSE_PLATE2<>'999999999' 
			--AND LICENSE_PLATE2 LIKE '0%' 
			--AND LEN(TGR.LICENSE_PLATE2)=10
		 ) ALLTAG
	GROUP BY LICENSE_PLATE

	SELECT GID,TRLT.LICENSE_PLATE, LOCATION, TRLT.TIME_STAMP
	FROM #TAGTMP TGR,#BT_TAGREAD_LATESTTIME TRLT
	WHERE TGR.LICENSE_PLATE1=TRLT.LICENSE_PLATE
		AND TGR.TIME_STAMP=TRLT.TIME_STAMP
	UNION
	SELECT GID,TRLT.LICENSE_PLATE, LOCATION, TRLT.TIME_STAMP
	FROM #TAGTMP TGR,#BT_TAGREAD_LATESTTIME TRLT
	WHERE TGR.LICENSE_PLATE2=TRLT.LICENSE_PLATE
		AND TGR.TIME_STAMP=TRLT.TIME_STAMP
END
GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_GETDATETIMEFORMAT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_RPT_GETDATETIMEFORMAT] 
AS
BEGIN
	DECLARE @DFormat VARCHAR(15); --Date format
	DECLARE @TFormat VARCHAR(15); --Time format
	
	SELECT  @DFormat = [SYS_VALUE] FROM [SYS_CONFIG] WHERE [SYS_KEY] = 'DEFAULT_DATE_FORMAT';
	SELECT  @TFormat = [SYS_VALUE] FROM [SYS_CONFIG] WHERE [SYS_KEY] = 'DEFAULT_TIME_FORMAT';
	
	SELECT @DFormat AS [DATEFORMAT], @TFormat AS [TIMEFORMAT];
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_GIDREPORT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<KP TAN>
-- Create date: <2012-12-05>
-- Description:	<INDIVIDUALBAGREPORT>
-- ============================================= stp_RPT_GIDREPORT '2010-12-01 00:00:00.000','2013-12-01 00:00:00.000','6000158530','999999999'
CREATE PROCEDURE [dbo].[stp_RPT_GIDREPORT] 
	@DTFrom datetime,
	@DTTo datetime,
	@GIDMin varchar (10),
	@GIDMax varchar (10)
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	select   W.GID, W.TIME_STAMP, W.[DESCRIPTION] from(
    SELECT A.GID  As GID,A.TIME_STAMP,'Normal item is found on ME Station '+ SUBSTRING(LOCATION,4,2) + '. Bag number = '+ BAG_NUMBER + '.'
	AS [DESCRIPTION] FROM ITEM_READY A  
	WHERE (A.TIME_STAMP between @DTFrom and @DTTo) and (A.GID between @GIDMin and @GIDMax ) 
	
    UNION
    SELECT A.GID , A.TIME_STAMP,'Item screened in '+ ISNULL(B.DESCRIPTION,'unknown')+'. Screening approve status = '+ A.RESULT_TYPE +'.'
	AS [DESCRIPTION] FROM ITEM_SCREENED A left join SUBSYSTEM_LIST B on (B.ID=A.LOCATION) 
	WHERE (A.TIME_STAMP between @DTFrom and @DTTo) and (A.GID between @GIDMin and @GIDMax) 
	
    UNION
    SELECT A.GID, A.TIME_STAMP, 'Item is proceeded from ' + ISNULL(C.DESCRIPTION,'unknown')+ ' to ' + ISNULL(B.DESCRIPTION,'unknown') 
	AS [DESCRIPTION] FROM ITEM_PROCEEDED A left join SUBSYSTEM_LIST B on (B.ID=A.DESTINATION) left join CONTROLPOINT_LIST C on (A.CONTROL_POINT=C.ID) 
	  
	WHERE  (A.TIME_STAMP between @DTFrom and @DTTo) and (A.GID  between @GIDMin and @GIDMax) 
	
    UNION
    SELECT A.GID , A.TIME_STAMP,'Item '+ B.TYPE_DESC +'. Item is sent to '+ A.DESTINATION + '.'
	AS [DESCRIPTION] FROM ITEM_ENCODED A left join ITEM_ENCODE_TYPE B on (A.ENCODED_TYPE=B.ENCODE_TYPE) 
	WHERE  (A.TIME_STAMP between @DTFrom and @DTTo) and (A.GID  between @GIDMin and @GIDMax) 
	
	UNION
	SELECT A.GID , A.TIME_STAMP, 'Item is found on '+ CASE WHEN A.LOCATION = '' THEN 'Conveyor' ELSE ISNULL(A.LOCATION,'unknown') END
	AS [DESCRIPTION] FROM GID_USED A 
	WHERE  (A.TIME_STAMP between @DTFrom and @DTTo) and (A.GID  between @GIDMin and @GIDMax) 
	
	UNION
	SELECT A.GID , A.TIME_STAMP, 'Item is lost at '+ ISNULL(A.LOCATION ,'unknown')
	AS [DESCRIPTION] FROM ITEM_LOST A  
	WHERE  (A.TIME_STAMP between @DTFrom and @DTTo) 
	and (A.GID between @GIDMin and @GIDMax) 
	 
	UNION
	SELECT A.GID, A.TIME_STAMP, 'Item is removed at '+ A.LOCATION + '.'
	AS [DESCRIPTION] FROM ITEM_REMOVED A 
	WHERE  (A.TIME_STAMP between @DTFrom and @DTTo) and (A.GID  between @GIDMin and @GIDMax) 
	) W
	order by TIME_STAMP
       
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_HBSLevel1And2Utilisation]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================   stp_RPT_HBSLevel1And2Utilisation '2013-05-02 00:00:00.000','2013-05-03 00:00:00.000','01,02,03,04,TX1,TX2'
CREATE PROCEDURE [dbo].[stp_RPT_HBSLevel1And2Utilisation] 
@DTFrom datetime,
@DTTo datetime,
@HBSLineList varchar (100)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

---- Sample
--	select '01' as HBS, 124 as [CLEAR], 1543 as RT, 0 as VSCCL, 1667 as TOTAL
--	union
--	select '02', 104, 1255, 0, 1359
--	union
--	select '03', 139, 1374, 0, 1513
--	union
--	select '09', 84, 870, 0, 954
--	union
--	select '14', 40, 456, 0, 496




-- 1-2 overall
	SELECT isnull(A.HBS,'0') as HBS, ISNULL(B.[CLEAR],'0') as [CLEAR], 
	ISNULL(C.RT,'0')as RT, isnull (D.VSCCL,'0') as VSCCL, ISNULL(B.[CLEAR],'0') + ISNULL(C.RT,'0') + isnull (D.VSCCL,'0') as TOTAL FROM  

	(Select * from (select '01' as HBS
	union
	select '02' as HBS
	union
	select '03' as HBS
	union
	select '04' as HBS
	union
	select '05' as HBS
	union
	select '06' as HBS
	union
	select '07' as HBS
	union
	select '08' as HBS
	union
	select '09' as HBS
	union
	select '10' as HBS
	union
	select '11' as HBS
	union
	select '12' as HBS
	union
	select '13' as HBS
	union
	select '14' as HBS
	union
    select 'TX1' as HBS
	union
	select 'TX2' as HBS) as G
	Where G.HBS in (SELECT ColumnA FROM dbo.udf_List2Table(@HBSLineList,','))
	)A 

	left join 

	(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS , COUNT(A.RESULT_TYPE) AS [CLEAR] from ITEM_SCREENED A 
	where RESULT_TYPE != 'C' and SCREEN_LEVEL = '2' and [STATUS] = 'N'  and ((A.TIME_STAMP between @DTFrom and @DTTo) 
	and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
	group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) B
	on A.HBS = B.HBS
	left join 

	(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS RT from ITEM_SCREENED A 
	where ((RESULT_TYPE = 'C' and SCREEN_LEVEL = '1') or (RESULT_TYPE = 'C' and SCREEN_LEVEL = '2')) and [STATUS] = 'N' and ((A.TIME_STAMP between @DTFrom and @DTTo) 
	and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
	group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) C
	on A.HBS = C.HBS
	left join

	(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS VSCCL from ITEM_SCREENED A
	where [STATUS] = 'T' and ((A.TIME_STAMP between @DTFrom and @DTTo) 
	and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
	group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) D
	on A.HBS = D.HBS
	--left join 

	--(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS TOTAL from ITEM_SCREENED A
	--where ((RESULT_TYPE != 'C' and SCREEN_LEVEL = '2' and [STATUS] = 'N') or (RESULT_TYPE = 'C' and SCREEN_LEVEL = '1' and [STATUS] = 'N')or([STATUS] = 'T')) or ((A.TIME_STAMP between @DTFrom and @DTTo) 
	--and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
	--	FROM dbo.udf_List2Table(@HBSLineList,',')) ))
	--group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) E
	--on A.HBS = E.HBS

	--where convert(int,A.HBS,2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)


--SELECT isnull(A.HBS,'0') as HBS, ISNULL(B.[CLEAR],'0') as [CLEAR], ISNULL(C.RT,'0')as RT, isnull (D.VSCCL,'0') as VSCCL, isnull(E.TOTAL,'0')as TOTAL FROM  

--(select '01' as HBS
--union
--select '02' as HBS
--union
--select '03' as HBS
--union
--select '04' as HBS
--union
--select '05' as HBS
--union
--select '06' as HBS
--union
--select '07' as HBS
--union
--select '08' as HBS
--union
--select '09' as HBS
--union
--select '10' as HBS
--union
--select '11' as HBS
--union
--select '12' as HBS
--union
--select '13' as HBS
--union
--select '14' as HBS
--)A 

--left join 

--(select '0'+SUBSTRING(B.LOCATION,5,1) AS HBS , COUNT(A.RESULT_TYPE) AS [CLEAR] from ITEM_SCREENED A left join GID_USED B on A.GID = B.GID
--where B.LOCATION like 'CT1-%' and RESULT_TYPE != 'C' and SCREEN_LEVEL = '2' and [STATUS] = 'N'  and ((A.TIME_STAMP between @DTFrom and @DTTo) and ('0'+SUBSTRING(B.LOCATION,5,1) between ('0'+@HBSLineMin) and ('0'+@HBSLineMax)))
--group by '0'+SUBSTRING(B.LOCATION,5,1)) B
--on A.HBS = B.HBS
--left join 

--(select '0'+SUBSTRING(B.LOCATION,5,1) AS HBS, COUNT(A.RESULT_TYPE) AS RT from ITEM_SCREENED A left join GID_USED B on A.GID = B.GID
--where B.LOCATION like 'CT1-%' and RESULT_TYPE = 'C' and SCREEN_LEVEL = '1' and [STATUS] = 'N' and ((A.TIME_STAMP between @DTFrom and @DTTo) and ('0'+ SUBSTRING(B.LOCATION,5,1) between ('0'+@HBSLineMin) and ('0'+@HBSLineMax)))
--group by '0'+SUBSTRING(B.LOCATION,5,1)) C
--on A.HBS = C.HBS
--left join

--(select '0'+SUBSTRING(B.LOCATION,5,1) AS HBS, COUNT(A.RESULT_TYPE) AS VSCCL from ITEM_SCREENED A left join GID_USED B on A.GID = B.GID
--where B.LOCATION like 'CT1-%' and [STATUS] = 'T' and ((A.TIME_STAMP between @DTFrom and @DTTo) and ('0'+SUBSTRING(B.LOCATION,5,1) between ('0'+@HBSLineMin) and ('0'+@HBSLineMax)))
--group by '0'+SUBSTRING(B.LOCATION,5,1)) D
--on A.HBS = D.HBS
--left join 

--(select '0'+SUBSTRING(B.LOCATION,5,1) AS HBS, COUNT(A.RESULT_TYPE) AS TOTAL from ITEM_SCREENED A left join GID_USED B on A.GID = B.GID
--where B.LOCATION like 'CT1-%' and ((RESULT_TYPE != 'C' and SCREEN_LEVEL = '2' and [STATUS] = 'N') and (RESULT_TYPE = 'C' and SCREEN_LEVEL = '1' and [STATUS] = 'N')or([STATUS] = 'T')) and ((A.TIME_STAMP between @DTFrom and @DTTo) and ('0'+ SUBSTRING(B.LOCATION,5,1) between ('0'+@HBSLineMin) and ('0'+@HBSLineMax)))
--group by '0'+SUBSTRING(B.LOCATION,5,1)) E
--on A.HBS = E.HBS

--where A.HBS between RIGHT('0'+ @HBSLineMin,2) and RIGHT('0'+ @HBSLineMax,2)

END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_HBSLevel1Utilisation]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ============================================= stp_RPT_HBSLevel1Utilisation '2013-04-23 00:00:00.000','2013-04-23 05:00:00.000','1','14'
CREATE PROCEDURE [dbo].[stp_RPT_HBSLevel1Utilisation] 
	@DTFrom datetime,
	@DTTo datetime,
	@HBSLineList varchar (100)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Insert statements for procedure here
	SELECT isnull(W.HBS,'0')as HBS, isnull(A.CL,'0') as CL,
	isnull(B.REJECT,'0') as REJECT,
	isnull(C.NOSCANNED,'0')as NOSCANNED, 
	isnull(D.TOTAL,'0') as TOTAL 
	FROM  
		(
		select HBS from
		(select '01' as HBS 
		union
		select '02' as HBS
		union
		select '03' as HBS
		union
		select '04' as HBS
		union
		select '05' as HBS
		union
		select '06' as HBS
		union
		select '07' as HBS
		union
		select '08' as HBS
		union
		select '09' as HBS
		union
		select '10' as HBS
		union
		select '11' as HBS
		union
		select '12' as HBS
		union
		select '13' as HBS
		union
		select '14' as HBS
		union
		select 'TX1' as HBS
		union
		select 'TX2' as HBS)W1
		where HBS in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) 
		) W left join
		
		
		(select 
		SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS , COUNT(RESULT_TYPE) AS CL 
		from ITEM_SCREENED A
		where 
		(A.RESULT_TYPE = 'C' and SCREEN_LEVEL ='1') and 
		((A.TIME_STAMP between @DTFrom and @DTTo) and 
		(REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) A
		on W.HBS = A.HBS
	left join 
		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(RESULT_TYPE) AS REJECT from ITEM_SCREENED A 
		where A.RESULT_TYPE != 'C' and SCREEN_LEVEL ='1'  and ((A.TIME_STAMP between @DTFrom and @DTTo) 
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) B
	on W.HBS = B.HBS
	left join
		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(RESULT_TYPE) AS NOSCANNED from ITEM_SCREENED A 
		where A.RESULT_TYPE = 'N' and SCREEN_LEVEL ='1' and ((A.TIME_STAMP between @DTFrom and @DTTo) 
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,','))))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) C
	on W.HBS = C.HBS
	left join 
		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(RESULT_TYPE) AS TOTAL from ITEM_SCREENED A 
		where A.RESULT_TYPE in ('C','R','N') and SCREEN_LEVEL ='1'and ((A.TIME_STAMP between @DTFrom and @DTTo) 
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) D
	on W.HBS = D.HBS

	order by W.HBS

 --   -- Insert statements for procedure here
	--SELECT isnull(A.HBS,'0')as HBS, isnull(A.CL,'0') as CL,isnull(B.REJECT,'0') as REJECT,isnull(C.NOSCANNED,'0')as NOSCANNED, isnull(D.TOTAL,'0') as TOTAL 
	--FROM  
	--	(select SUBSTRING(SUBSYSTEM,5,2) AS HBS , COUNT(RESULT_TYPE) AS CL 
	--	from ITEM_SCREENED A
	--	where 
	--	(A.RESULT_TYPE = 'C' and SCREEN_LEVEL ='1') and 
	--	((A.TIME_STAMP between @DTFrom and @DTTo) and 
	--	(convert(int,(SUBSTRING(SUBSYSTEM,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
	--	group by SUBSTRING(SUBSYSTEM,5,2)) A
	--left join 
	--	(select SUBSTRING(SUBSYSTEM,5,2) AS HBS, COUNT(RESULT_TYPE) AS REJECT from ITEM_SCREENED A 
	--	where A.RESULT_TYPE != 'C' and SCREEN_LEVEL ='1'  and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(SUBSYSTEM,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
	--	group by SUBSTRING(SUBSYSTEM,5,2)) B
	--on A.HBS = B.HBS
	--left join
	--	(select SUBSTRING(SUBSYSTEM,5,2) AS HBS, COUNT(RESULT_TYPE) AS NOSCANNED from ITEM_SCREENED A 
	--	where A.RESULT_TYPE = 'N' and SCREEN_LEVEL ='1' and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(SUBSYSTEM,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
	--	group by SUBSTRING(SUBSYSTEM,5,2)) C
	--on A.HBS = C.HBS
	--left join 
	--	(select SUBSTRING(SUBSYSTEM,5,2) AS HBS, COUNT(RESULT_TYPE) AS TOTAL from ITEM_SCREENED A 
	--	where A.RESULT_TYPE in ('C','R','N') and SCREEN_LEVEL ='1'and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(SUBSYSTEM,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
	--	group by SUBSTRING(SUBSYSTEM,5,2)) D
	--on A.HBS = D.HBS

	--order by RIGHT('0'+ A.HBS,2)


	
	----Sample
	--select '01' as HBS, 1200 as CL, 478 as REJECT, 20 as NOSCANNED, 1678 as TOTAL
	--union
	--select '02', 856, 505, 15, 1361
	--union
	--select '03', 909, 607, 8, 1516
	--union
	--select '04', 786, 461, 19, 1247
	--union
	--select '14', 313, 183, 1, 496
	
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_HBSLevel1Utilisation_Test]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ============================================= stp_RPT_HBSLevel1Utilisation_Test '2013-04-23 00:00:00.000','2013-04-23 05:00:00.000','01,02,TX1'
CREATE PROCEDURE [dbo].[stp_RPT_HBSLevel1Utilisation_Test] 
	@DTFrom datetime,
	@DTTo datetime,
	@HBSLineList varchar (100)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT isnull(A.HBS,'0')as HBS, isnull(A.CL,'0') as CL,
	isnull(B.REJECT,'0') as REJECT,
	isnull(C.NOSCANNED,'0')as NOSCANNED, 
	isnull(D.TOTAL,'0') as TOTAL 
	FROM  
		(select 
		
		SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS , COUNT(RESULT_TYPE) AS CL 
		from ITEM_SCREENED A
		where 
		(A.RESULT_TYPE = 'C' and SCREEN_LEVEL ='1') and 
		((A.TIME_STAMP between @DTFrom and @DTTo) and 
		(REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) A
	left join 
		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(RESULT_TYPE) AS REJECT from ITEM_SCREENED A 
		where A.RESULT_TYPE != 'C' and SCREEN_LEVEL ='1'  and ((A.TIME_STAMP between @DTFrom and @DTTo) 
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) B
	on A.HBS = B.HBS
	left join
		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(RESULT_TYPE) AS NOSCANNED from ITEM_SCREENED A 
		where A.RESULT_TYPE = 'N' and SCREEN_LEVEL ='1' and ((A.TIME_STAMP between @DTFrom and @DTTo) 
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,','))))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) C
	on A.HBS = C.HBS
	left join 
		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(RESULT_TYPE) AS TOTAL from ITEM_SCREENED A 
		where A.RESULT_TYPE in ('C','R','N') and SCREEN_LEVEL ='1'and ((A.TIME_STAMP between @DTFrom and @DTTo) 
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) D
	on A.HBS = D.HBS

	order by RIGHT('0'+ A.HBS,2)
 --   -- Insert statements for procedure here
	--SELECT isnull(A.HBS,'0')as HBS, isnull(A.CL,'0') as CL,isnull(B.REJECT,'0') as REJECT,isnull(C.NOSCANNED,'0')as NOSCANNED, isnull(D.TOTAL,'0') as TOTAL 
	--FROM  
	--	(select SUBSTRING(SUBSYSTEM,5,2) AS HBS , COUNT(RESULT_TYPE) AS CL 
	--	from ITEM_SCREENED A
	--	where 
	--	(A.RESULT_TYPE = 'C' and SCREEN_LEVEL ='1') and 
	--	((A.TIME_STAMP between @DTFrom and @DTTo) and 
	--	(convert(int,(SUBSTRING(SUBSYSTEM,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
	--	group by SUBSTRING(SUBSYSTEM,5,2)) A
	--left join 
	--	(select SUBSTRING(SUBSYSTEM,5,2) AS HBS, COUNT(RESULT_TYPE) AS REJECT from ITEM_SCREENED A 
	--	where A.RESULT_TYPE != 'C' and SCREEN_LEVEL ='1'  and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(SUBSYSTEM,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
	--	group by SUBSTRING(SUBSYSTEM,5,2)) B
	--on A.HBS = B.HBS
	--left join
	--	(select SUBSTRING(SUBSYSTEM,5,2) AS HBS, COUNT(RESULT_TYPE) AS NOSCANNED from ITEM_SCREENED A 
	--	where A.RESULT_TYPE = 'N' and SCREEN_LEVEL ='1' and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(SUBSYSTEM,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
	--	group by SUBSTRING(SUBSYSTEM,5,2)) C
	--on A.HBS = C.HBS
	--left join 
	--	(select SUBSTRING(SUBSYSTEM,5,2) AS HBS, COUNT(RESULT_TYPE) AS TOTAL from ITEM_SCREENED A 
	--	where A.RESULT_TYPE in ('C','R','N') and SCREEN_LEVEL ='1'and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(SUBSYSTEM,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
	--	group by SUBSTRING(SUBSYSTEM,5,2)) D
	--on A.HBS = D.HBS

	--order by RIGHT('0'+ A.HBS,2)


	
	----Sample
	--select '01' as HBS, 1200 as CL, 478 as REJECT, 20 as NOSCANNED, 1678 as TOTAL
	--union
	--select '02', 856, 505, 15, 1361
	--union
	--select '03', 909, 607, 8, 1516
	--union
	--select '04', 786, 461, 19, 1247
	--union
	--select '14', 313, 183, 1, 496
	
END



GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_HBSLevel2Utilisation]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<KP Tan>
-- Create date: <2012-12-06>
-- Description:	<stp_RPT_HBSLevel2Utilisation>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_HBSLevel2Utilisation] --stp_RPT_HBSLevel2Utilisation '2010-11-21 11:57:04.323','2013-11-21 11:57:04.323','1','8'
	@DTFrom datetime,
	@DTTo datetime,
	@HBSLineList varchar (100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT isnull(W.HBS,'0') as HBS, isnull(A.Cleared,'0') as Cleared, isnull(B.Rejected,'0') as Rejected, isnull(C.DecisionPoint,'0')as DecisionPoint, isnull(D.OperatorTimeOut,'0') as OperatorTimeOut, isnull(E.NotScanned,'0') as NotScanned, isnull(F.Total,'0') as Total FROM 
	(Select * from	 (
		select '01' as HBS
		union
		select '02' as HBS
		union
		select '03' as HBS
		union
		select '04' as HBS
		union
		select '05' as HBS
		union
		select '06' as HBS
		union
		select '07' as HBS
		union
		select '08' as HBS
		union
		select '09' as HBS
		union
		select '10' as HBS
		union
		select '11' as HBS
		union
		select '12' as HBS
		union
		select '13' as HBS
		union
		select '14' as HBS
		union
		select 'TX1' as HBS
		union
		select 'TX2' as HBS) as G
		where G.HBS in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,','))
		) W left join
		 
		 
		 (select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS , COUNT(A.RESULT_TYPE) AS Cleared from ITEM_SCREENED A 
		where (RESULT_TYPE = 'C' and SCREEN_LEVEL ='2') and ((A.TIME_STAMP between @DTFrom and @DTTo) and
		 (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) A
		on W.HBS = A.HBS
		left join 

		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS Rejected from ITEM_SCREENED A 
		where RESULT_TYPE = 'R' and SCREEN_LEVEL ='2' and ((A.TIME_STAMP between @DTFrom and @DTTo) 
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) B
		on W.HBS = B.HBS
		left join

		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS DecisionPoint from ITEM_SCREENED A 
		where RESULT_TYPE = 'D' and SCREEN_LEVEL ='2' and ((A.TIME_STAMP between @DTFrom and @DTTo) 
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) C
		on W.HBS = C.HBS
		left join 

		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS OperatorTimeOut from ITEM_SCREENED A 
		where RESULT_TYPE = 'O' and SCREEN_LEVEL ='2' and ((A.TIME_STAMP between @DTFrom and @DTTo) 
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) D
		on W.HBS = D.HBS
		left join 

		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS NotScanned from ITEM_SCREENED A
		where RESULT_TYPE = 'N' and SCREEN_LEVEL ='2' and ((A.TIME_STAMP between @DTFrom and @DTTo)  
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3))  E
		on W.HBS = E.HBS
		left join

		(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS Total from ITEM_SCREENED A 
		where RESULT_TYPE in ('C','R','D','O','N') and SCREEN_LEVEL ='2'and ((A.TIME_STAMP between @DTFrom and @DTTo)
		and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
		group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) F
		on W.HBS = F.HBS

		order by W.HBS


		--SELECT isnull(A.HBS,'0') as HBS, isnull(A.Cleared,'0') as Cleared, isnull(B.Rejected,'0') as Rejected, isnull(C.DecisionPoint,'0')as DecisionPoint, isnull(D.OperatorTimeOut,'0') as OperatorTimeOut, isnull(E.NotScanned,'0') as NotScanned, isnull(F.Total,'0') as Total FROM 
		-- (select SUBSTRING(SUBSYSTEM,3,2) AS HBS , COUNT(A.RESULT_TYPE) AS Cleared from ITEM_SCREENED A 
		--where (RESULT_TYPE = 'C' and SCREEN_LEVEL ='2') and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(SUBSYSTEM,3,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
		--group by SUBSTRING(SUBSYSTEM,3,2)) A
		--left join 

		--(select SUBSTRING(A.SUBSYSTEM ,3,2) AS HBS, COUNT(A.RESULT_TYPE) AS Rejected from ITEM_SCREENED A 
		--where RESULT_TYPE = 'R' and SCREEN_LEVEL ='2' and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(SUBSYSTEM,3,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
		--group by SUBSTRING(SUBSYSTEM,3,2)) B
		--on A.HBS = B.HBS
		--left join

		--(select SUBSTRING(A.SUBSYSTEM ,5,2) AS HBS, COUNT(A.RESULT_TYPE) AS DecisionPoint from ITEM_SCREENED A 
		--where RESULT_TYPE = 'D' and SCREEN_LEVEL ='2' and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(A.SUBSYSTEM,3,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
		--group by SUBSTRING(A.SUBSYSTEM,5,2)) C
		--on A.HBS = C.HBS
		--left join 

		--(select SUBSTRING(A.SUBSYSTEM,5,2) AS HBS, COUNT(A.RESULT_TYPE) AS OperatorTimeOut from ITEM_SCREENED A 
		--where RESULT_TYPE = 'O' and SCREEN_LEVEL ='2' and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(A.SUBSYSTEM,3,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
		--group by SUBSTRING(A.SUBSYSTEM ,5,2)) D
		--on A.HBS = D.HBS
		--left join 

		--(select SUBSTRING(A.SUBSYSTEM,3,2) AS HBS, COUNT(A.RESULT_TYPE) AS NotScanned from ITEM_SCREENED A
		--where RESULT_TYPE = 'N' and SCREEN_LEVEL ='2' and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(A.SUBSYSTEM,3,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
		--group by SUBSTRING(A.SUBSYSTEM,3,2)) E
		--on A.HBS = E.HBS
		--left join

		--(select SUBSTRING(A.SUBSYSTEM,5,2) AS HBS, COUNT(A.RESULT_TYPE) AS Total from ITEM_SCREENED A 
		--where RESULT_TYPE in ('C','R','D','O','N') and SCREEN_LEVEL ='2'and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(A.SUBSYSTEM,3,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
		--group by SUBSTRING(A.SUBSYSTEM,5,2)) F
		--on A.HBS = F.HBS

		--order by RIGHT('0'+ A.HBS,2)



END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_HBSLevel3Utilisation]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<KP Tan>
-- Create date: <2012-12-06>
-- Description:	<stp_RPT_HBSLevel3Utilisation>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_HBSLevel3Utilisation] 
	@DTFrom datetime,
	@DTTo datetime,
	@HBSLineList varchar (100)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT isnull (W.HBS,'0') as HBS ,isnull (A.Cleared,'0') as Cleared , isnull (B.Rejected,'0') as Rejected , isnull(C.TestMode,'0') as TestMode, ISNULL(D.ScanningFault,'0') as ScanningFault , isnull(E.Rescan,'0') as Rescan ,isnull (F.Total,'0') as Total FROM  
	(
		Select * from (select '01' as HBS
		union
		select '02' as HBS
		union
		select '04' as HBS) G
		where G.HBS in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,','))
		) W
	left join
	(
	select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS , 
	COUNT(A.RESULT_TYPE) AS Cleared from ITEM_SCREENED A 
	where  (RESULT_TYPE = 'C' and SCREEN_LEVEL ='3') and ((A.TIME_STAMP between @DTFrom and @DTTo) 
	and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
	group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) A
	on W.HBS = A.HBS
	left join 

	(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS Rejected from ITEM_SCREENED A 
	where  RESULT_TYPE = 'R' and SCREEN_LEVEL ='3' and ((A.TIME_STAMP between @DTFrom and @DTTo)
	and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
	group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) B
	on W.HBS = B.HBS
	left join

	(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS TestMode from ITEM_SCREENED A 
	where  [STATUS] = 'T' and SCREEN_LEVEL ='3' and ((A.TIME_STAMP between @DTFrom and @DTTo) 
	and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
	group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) C
	on W.HBS = C.HBS
	left join 

	(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS ScanningFault from ITEM_SCREENED A 
	where RESULT_TYPE = 'F' and SCREEN_LEVEL ='3' and ((A.TIME_STAMP between @DTFrom and @DTTo) 
	and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
	group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) D
	on W.HBS = D.HBS
	left join 

	 (SELECT E.HBS,COUNT(E.Rescan) as Rescan  FROM (SELECT SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, A.GID AS Rescan FROM 
	 ITEM_SCREENED A where A.SCREEN_LEVEL ='3' 
	 and  ((A.TIME_STAMP between @DTFrom and @DTTo) and 
	 (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
	GROUP BY SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),GID having Count(GID)!=1) E
	Group BY E.HBS ) E
	on W.HBS = E.HBS
	left join

	(select SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3) AS HBS, COUNT(A.RESULT_TYPE) AS Total from ITEM_SCREENED A 
	where RESULT_TYPE in ('C','R') and SCREEN_LEVEL ='3'and ((A.TIME_STAMP between @DTFrom and @DTTo) 
	and (REPLACE(SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3),' ','') in (SELECT ColumnA 
		FROM dbo.udf_List2Table(@HBSLineList,',')) ))
	group by SUBSTRING(LEFT(SUBSYSTEM+' ',7),5,3)) F
	on W.HBS = F.HBS
	
	order by W.HBS	


--Sample
	--select '01' as HBS, 1014 as Cleared, 2 as Rejected, 0 as TestMode, 1 as ScanningFault, 1 as Rescan, 1016 as Total
	--union
	--select '02', 261, 1, 0, 1, 0, 262
	--union
	--select '04', 65, 0, 0, 0, 0, 65

--SELECT isnull (A.HBS,'0') as HBS ,isnull (A.Cleared,'0') as Cleared , isnull (B.Rejected,'0') as Rejected , isnull(C.TestMode,'0') as TestMode, ISNULL(D.ScanningFault,'0') as ScanningFault , isnull(E.Rescan,'0') as Rescan ,isnull (F.Total,'0') as Total FROM  (select SUBSTRING(B.LOCATION,5,2) AS HBS , COUNT(A.RESULT_TYPE) AS Cleared from ITEM_SCREENED A left join GID_USED B on A.GID = B.GID
--where B.LOCATION like 'CT1-%' and (RESULT_TYPE = 'C' and SCREEN_LEVEL ='3') and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(B.LOCATION,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
--group by SUBSTRING(B.LOCATION,5,2)) A
--left join 

--(select SUBSTRING(B.LOCATION,5,2) AS HBS, COUNT(A.RESULT_TYPE) AS Rejected from ITEM_SCREENED A left join GID_USED B on A.GID = B.GID
--where B.LOCATION like 'CT1-%' and RESULT_TYPE = 'R' and SCREEN_LEVEL ='3' and ((A.TIME_STAMP between @DTFrom and @DTTo)and (convert(int,(SUBSTRING(B.LOCATION,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
--group by SUBSTRING(B.LOCATION,5,2)) B
--on A.HBS = B.HBS
--left join

--(select SUBSTRING(B.LOCATION,5,2) AS HBS, COUNT(A.RESULT_TYPE) AS TestMode from ITEM_SCREENED A left join GID_USED B on A.GID = B.GID
--where B.LOCATION like 'CT1-%' and [STATUS] = 'T' and SCREEN_LEVEL ='3' and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(B.LOCATION,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
--group by SUBSTRING(B.LOCATION,5,2)) C
--on A.HBS = C.HBS
--left join 

--(select SUBSTRING(B.LOCATION,5,2) AS HBS, COUNT(A.RESULT_TYPE) AS ScanningFault from ITEM_SCREENED A left join GID_USED B on A.GID = B.GID
--where B.LOCATION like 'CT1-%' and RESULT_TYPE = 'F' and SCREEN_LEVEL ='3' and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(B.LOCATION,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
--group by SUBSTRING(B.LOCATION,5,2)) D
--on A.HBS = D.HBS
--left join 

--(SELECT SUBSTRING(B.LOCATION,5,2) AS HBS, COUNT(A.GID) AS Rescan FROM 
--(select GID  from ITEM_SCREENED where SCREEN_LEVEL ='3' group by GID having COUNT(GID)!='1') A
--left join GID_USED B on A.GID = B.GID and  ((B.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(B.LOCATION,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
--where B.LOCATION like 'CT1-%' 
--GROUP BY SUBSTRING(B.LOCATION,5,2)) E
--on A.HBS = E.HBS
--left join

--(select SUBSTRING(B.LOCATION,5,2) AS HBS, COUNT(A.RESULT_TYPE) AS Total from ITEM_SCREENED A left join GID_USED B on A.GID = B.GID
--where B.LOCATION like 'CT1-%' and RESULT_TYPE in ('C','R') and SCREEN_LEVEL ='3'and ((A.TIME_STAMP between @DTFrom and @DTTo) and (convert(int,(SUBSTRING(B.LOCATION,5,2)),2) between convert(int,@HBSLineMin,2) and convert(int,@HBSLineMax,2)))
--group by SUBSTRING(B.LOCATION,5,2)) F
--on A.HBS = F.HBS
	
--order by RIGHT('0'+ A.HBS,2)	
	
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_HBSLevel4Utilisation]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<KP Tan>
-- Create date: <2012-12-10>
-- Description:	<stp_RPT_HBSLevel4Utilisation>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_HBSLevel4Utilisation] 
	@DTFrom datetime,
	@DTTo datetime
/** 
@DTFrom datetime,
	@DTTo datetime,
	@HBSLineMin varchar (2),
	@HBSLineMax varchar (2)

-- from ITEM_Proceeded
**/

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select 1 as BR, (select count(*) from ITEM_PROCEEDED where TIME_STAMP between @DTFrom and @DTTo
	 and CONTROL_POINT = 'DL1M07' and DESTINATION = 'DL1M17' ) as [CLEAR],
	 (select count(*) from ITEM_PROCEEDED where TIME_STAMP between @DTFrom and @DTTo
	 and DESTINATION = 'DL1M16' ) as REJECTED,
	 (select count(*) from ITEM_PROCEEDED where TIME_STAMP between @DTFrom and @DTTo
	 and DESTINATION in ('DL1M16','DL1M17')) as TOTAL

--select 1 AS BR, 15 AS [CLEAR], 5 AS REJECTED, 20 As TOTAL

END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_HLCEQUIPEMNTSTATUS_COMPUTER]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_HLCEQUIPEMNTSTATUS_COMPUTER] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @temptable TABLE (APP_CODE nvarchar(30), LIVE_STATUS_TYPE varchar(10))  
	INSERT INTO @temptable select APP_CODE,'UP' from APP_LIVE_MONITORING

	

	Select * from @temptable
	
	--Sample 
	--select 'FIDS-Master' as APP_CODE, 'up' as LIVE_STATUS_TYPE, '1.00' as SW_Version, 'Server' as SW_Type
	--union
	--select 'FIDS-Backup','up','1.00','Server'
	--union
	--select 'HyperV-Master','up','1.00','Server'
	--union
	--select 'HyperV-Backup','up','1.00','Server'
	--union
	--select 'BHSDB-Master','up','1.00','Server'
	--union
	--select 'BHSDB-Backup','up','1.00','Server'
	--union
	--select 'SACCOM-Master','up','1.00','Server'
	--union
	--select 'SACCOM-Backup','up','1.00','Server'
	--union
	--select 'MDS-Master','up','1.00','Server'
	--union
	--select 'MDS-Backup','up','1.00','Server'
	--union
	--select 'SAC Workstation 01','up','1.00','Workstation'
	--union
	--select 'SAC Workstation 02','up','1.00','Workstation'
	--union
	--select 'MDS Workstation 01','up','1.00','Workstation'
	--union
	--select 'MDS Workstation 02','up','1.00','Workstation'
	--union
	--select 'MES 01','down','1.00','Workstation'
	--union
	--select 'MES 02','down','1.00','Workstation'
	--union
	--select 'MES 03','down','1.00','Workstation'
	--union
	--select 'MES 04','down','1.00','Workstation'

	--select APP_CODE, LIVE_STATUS_TYPE from APP_LIVE_MONITORING
	
	
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_HLCEQUIPEMNTSTATUS_PLC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_HLCEQUIPEMNTSTATUS_PLC] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Sample
	select 'CL1' as APP_CODE, 'down' as LIVE_STATUS_TYPE, '10.00' as SW_Version, '20556.00' as SW_Type
	union
	select 'CL2','down', '10.00', '20556.00'
	union
	select 'CT01/02','down', '10.00', '20556.00'
	union
	select 'CT03/04','down', '10.00', '20556.00'
	union
	select 'CT05/06','down', '10.00', '20556.00'
	union
	select 'CT07/08','down', '10.00', '20556.00'
	union
	select 'CT09/10','down', '10.00', '20556.00'
	union
	select 'CT11/12','down', '10.00', '20556.00'
	union
	select 'CT13/14','down', '10.00', '20556.00'
	union
	select 'DL1','down', '10.00', '20556.00'
	union
	select 'EDS1/3','down', '10.00', '20556.00'
	union
	select 'EDS2/4','down', '10.00', '20556.00'
	union
	select 'MP','down', '10.00', '20556.00'
	union
	select 'TX1','down', '10.00', '20556.00'
	union
	select 'TX2','down', '10.00', '20556.00'
	--select APP_CODE, LIVE_STATUS_TYPE from APP_LIVE_MONITORING
	
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_INDIVIDUALBAGREPORT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<KP TAN>
-- Create date: <2012-12-05>
-- Description:	<INDIVIDUALBAGREPORT>
-- ============================================= stp_RPT_INDIVIDUALBAGREPORT '2013-04-22 00:00:00.000','2013-04-24 00:00:00.000','000000000','999999999',''
CREATE PROCEDURE [dbo].[stp_RPT_INDIVIDUALBAGREPORT] 
	@DTFrom datetime,
	@DTTo datetime,
	@IATAMin varchar (10),
	@IATAMax varchar (10),
	@Flight varchar(200)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select W.IATA, W.TIME_STAMP, W.DESCRIPTION from (
    SELECT B.LICENSE_PLATE As IATA,A.TIME_STAMP,'Normal item is found on '+ LOCATION+ '. GID = '+ A.GID + '.'
	AS [DESCRIPTION] FROM ITEM_READY A left join BAG_INFO B on (A.GID=B.GID) 
	WHERE (A.TIME_STAMP between @DTFrom and @DTTo) and (B.LICENSE_PLATE between @IATAMin and @IATAMax) /*and A.GID in (select GID from ITEM_ENCODED where FLIGHT_NUMBER in (@Flight))*/
    UNION
    SELECT C.LICENSE_PLATE, A.TIME_STAMP,'Item screened in '+ ISNULL(B.DESCRIPTION,'unknown')+'. Screening approve status = '+ D.SHORT_DESCRIPTION  +'.'
	AS [DESCRIPTION] FROM ITEM_SCREENED A left join SUBSYSTEM_LIST B on (B.ID=A.LOCATION) left join BAG_INFO C on (A.GID=C.GID)
	left join ITEM_SCREEN_RESULT_TYPES D on A.RESULT_TYPE =D.TYPE 
	WHERE (A.TIME_STAMP between @DTFrom and @DTTo) and (C.LICENSE_PLATE between @IATAMin and @IATAMax) 
	/*and A.GID in (select GID from ITEM_ENCODED where FLIGHT_NUMBER in (@Flight))*/

    UNION
    SELECT D.LICENSE_PLATE, A.TIME_STAMP, 'Item is proceeded from ' + ISNULL(C.DESCRIPTION,'unknown')+ CASE WHEN A.DESTINATION like ('RT%') THEN' and discharge  to ' ELSE ' to ' END + ISNULL(B.DESCRIPTION  ,'unknown') 
	AS [DESCRIPTION] FROM ITEM_PROCEEDED A  left join CONTROLPOINT_LIST C on (A.CONTROL_POINT=C.ID) 
	left join SUBSYSTEM_LIST B on B.ID=A.DESTINATION
	left join BAG_INFO D on (a.GID=d.GID)  
	WHERE destination != '' 
	--and left(destination,4) not in ('DL1M','DL2M') 
	and (A.TIME_STAMP between @DTFrom and @DTTo) and (D.LICENSE_PLATE between @IATAMin and @IATAMax) /*and A.GID in (select GID from ITEM_ENCODED where FLIGHT_NUMBER in (@Flight))*/
    UNION
    SELECT C.LICENSE_PLATE, A.TIME_STAMP,'Item '+ B.TYPE_DESC +'. Item is sent to '+ A.DESTINATION + '.'
	AS [DESCRIPTION] FROM ITEM_ENCODED A left join ITEM_ENCODE_TYPE B on (A.ENCODED_TYPE=B.ENCODE_TYPE) left join BAG_INFO C on (A.GID=C.GID) 
	WHERE  (A.TIME_STAMP between @DTFrom and @DTTo) and (C.LICENSE_PLATE between @IATAMin and @IATAMax) /*and A.GID in (select GID from ITEM_ENCODED where FLIGHT_NUMBER in (@Flight))*/
	UNION
	--SELECT B.LICENSE_PLATE, A.TIME_STAMP, 'Item is found on '+ case when A.LOCATION='' then 'conveyor' else ISNULL(A.LOCATION ,'unknown') end
	--AS [DESCRIPTION] FROM GID_USED A left join BAG_INFO B on A.GID = B.GID 
	--WHERE  (A.TIME_STAMP between @DTFrom and @DTTo) and (B.LICENSE_PLATE between @IATAMin and @IATAMax) /*and A.GID in (select GID from ITEM_ENCODED where FLIGHT_NUMBER in (@Flight))*/
	--UNION
	SELECT B.LICENSE_PLATE, A.TIME_STAMP, 'Item is lost at '+ ISNULL(A.LOCATION ,'unknown')
	AS [DESCRIPTION] FROM ITEM_LOST A left join BAG_INFO B on A.GID = B.GID 
	WHERE  (A.TIME_STAMP between @DTFrom and @DTTo) and (B.LICENSE_PLATE between @IATAMin and @IATAMax) /*and A.GID in (select GID from ITEM_ENCODED where FLIGHT_NUMBER in (@Flight))*/
	UNION
	SELECT B.LICENSE_PLATE, A.TIME_STAMP, 'Item is removed at '+ A.LOCATION + '.'
	AS [DESCRIPTION] FROM ITEM_REMOVED A left join BAG_INFO B on A.GID = B.GID 
	WHERE  (A.TIME_STAMP between @DTFrom and @DTTo) and (B.LICENSE_PLATE between @IATAMin and @IATAMax) /*and A.GID in (select GID from ITEM_ENCODED where FLIGHT_NUMBER in (@Flight))*/
	) W
	order by TIME_STAMP 
       
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_Level1Utilization]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_RPT_Level1Utilization] 
	@DTFrom [datetime],
	@DTTo [datetime],
    @IntervalMin [int],
    @System varchar(10)  
AS
BEGIN     
		DECLARE @Counter int
		SET @Counter = 1
		DECLARE @TimeStart DATETIME
		DECLARE @TimeEnd DATETIME
	    DECLARE @interval int
		DECLARE @start_point datetime
		DECLARE @end_point datetime

		IF @IntervalMin < 5
		BEGIN
			SET @interval = 5
		END
		ELSE
		BEGIN
			SET @interval =  @IntervalMin
		END 
		
        SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
		SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

		IF datediff(d, @start_point, @end_point) > 365 
		BEGIN
			SET @end_point =  DATEADD(d,365,@start_point)
		END

		DECLARE @TotalCount INT
		SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))

		DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int, SubSystem nvarchar(10), tot_num INT)  

		DECLARE @sum INT

		WHILE (@Counter <= @TotalCount)
		BEGIN
			SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
			SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
			SET @sum = (SELECT count(*)	FROM GID_USED A left join LOCATIONS B on A.LOCATION = B.LOCATION WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND B.SUBSYSTEM = @System )
			INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@System, @sum)

			SET @Counter  = (@Counter + 1)
		End

		SELECT * FROM @temptable
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_LOADBALANCING_COLLECTION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_LOADBALANCING_COLLECTION]
	@DTFrom datetime,
	@DTTo datetime,
	@CollectionLine varchar(10),
	@IntervalMin int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	----Sample
	--select '01' as collectionLine, 578 as bags
	--union
	--select '02',400	

	--SELECT substring(LOCATION,3,2) as checkinLine, COUNT(*) as bags FROM GID_USED WHERE TIME_STAMP between @DTFrom and @DTTo and LOCATION like 'Cl%'
	--and (LOCATION = 'Cl'+ LEFT('00'+@Checkin,2) or @Checkin = 'ALL' )
	--group by LOCATION


	DECLARE @Counter int
	SET @Counter = 1
	DECLARE @TimeStart DATETIME
	DECLARE @TimeEnd DATETIME
	DECLARE @interval int
	DECLARE @start_point datetime
	DECLARE @end_point datetime
	Declare @LoopCount INT
	SET @LoopCount=1

	IF @IntervalMin < 5
	BEGIN
		SET @interval = 5
	END
	ELSE
	BEGIN
		SET @interval =  @IntervalMin
	END 
		
    SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
	SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

	IF datediff(d, @start_point, @end_point) > 365 
	BEGIN
		SET @end_point =  DATEADD(d,365,@start_point)
	END

	DECLARE @TotalCount INT
	SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))

	DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int, SubSystem nvarchar(10), tot_num INT)  

	DECLARE @sum INT

	WHILE (@Counter <= @TotalCount)
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		
		IF 'CL01' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CollectionLine ,',')) )
		BEGIN
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION = 'CL01')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CL01', @sum)
		END
	    IF 'CL02' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CollectionLine ,',')) )
		BEGIN
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION = 'CL02')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CL02', @sum)
		END
		--ELSE IF @CollectionLine = 'ALL'
		--BEGIN
		
		--SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION in ('CL01'))
		--	   INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CL01', @sum)

		--SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION in ('CL02'))
		--	   INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CL02', @sum)
		
		--END
		
		SET @Counter  = (@Counter + 1)
	End

	SELECT * FROM @temptable as t order by t.SubSystem ,t.Interval 

END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_LOADBALANCING_DELIEVEY]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_LOADBALANCING_DELIEVEY]
	@DTFrom datetime,
	@DTTo datetime,
	@DelieveyLine varchar(10),
	@IntervalMin int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	----Sample
	--select '01' as delieveyLine, 957 as bags
	--union
	--select '02',2001	

	--SELECT substring(LOCATION,3,2) as checkinLine, COUNT(*) as bags FROM GID_USED WHERE TIME_STAMP between @DTFrom and @DTTo and LOCATION like 'Cl%'
	--and (LOCATION = 'Cl'+ LEFT('00'+@Checkin,2) or @Checkin = 'ALL' )
	--group by LOCATION

	DECLARE @Counter int
	SET @Counter = 1
	DECLARE @TimeStart DATETIME
	DECLARE @TimeEnd DATETIME
	DECLARE @interval int
	DECLARE @start_point datetime
	DECLARE @end_point datetime

	IF @IntervalMin < 5
	BEGIN
		SET @interval = 5
	END
	ELSE
	BEGIN
		SET @interval =  @IntervalMin
	END 
		
    SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
	SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

	IF datediff(d, @start_point, @end_point) > 365 
	BEGIN
		SET @end_point =  DATEADD(d,365,@start_point)
	END

	DECLARE @TotalCount INT
	SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))

	DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int, SubSystem nvarchar(10), tot_num INT)  

	DECLARE @sum INT

WHILE (@Counter <= @TotalCount)
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		IF 'DL01' in ((SELECT ColumnA FROM dbo.udf_List2Table(@DelieveyLine ,',')) )
		--@DelieveyLine ='1'
		BEGIN
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION = 'DL01')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'DL01', @sum)
		END
	    IF 'DL02' in ((SELECT ColumnA FROM dbo.udf_List2Table(@DelieveyLine ,',')) )
			--@DelieveyLine ='2'
			BEGIN
			SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION = 'DL02')
			INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'DL02', @sum)
			END
     
		SET @Counter  = (@Counter + 1)
	End

	SELECT * FROM @temptable as t order by t.SubSystem ,t.Interval 

END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_LOADBALANCING_INPUT_CHECKIN]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_LOADBALANCING_INPUT_CHECKIN]
	@DTFrom datetime,
	@DTTo datetime,
	@Checkin varchar(100),
	@IntervalMin int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	----Sample
	--select '01' as checinLine, 1512 as bags
	--union
	--select '02',714
	--union
	--select '03',393
	--union
	--select '04',753
	--union
	--select '05',429
	--union
	--select '06',612
	--union
	--select '07',1207
	--union
	--select '08',1294
	--union
	--select '09',996
	--union
	--select '10',361
	--union
	--select '11',466
	--union
	--select '12',769
	--union
	--select '13',1542
	--union
	--select '14',750

	--SELECT substring(LOCATION,3,2) as checkinLine, COUNT(*) as bags FROM GID_USED WHERE TIME_STAMP between @DTFrom and @DTTo and LOCATION like 'Cl%'
	--and (LOCATION = 'Cl'+ LEFT('00'+@Checkin,2) or @Checkin = 'ALL' )
	--group by LOCATION

	DECLARE @Counter int
	SET @Counter = 1
	DECLARE @TimeStart DATETIME
	DECLARE @TimeEnd DATETIME
	DECLARE @interval int
	DECLARE @start_point datetime
	DECLARE @end_point datetime
	Declare @LoopCount INT
	SET @LoopCount=1
	IF @IntervalMin < 5
	BEGIN
		SET @interval = 5
	END
	ELSE
	BEGIN
		SET @interval =  @IntervalMin
	END 
		
    SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
	SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

	IF datediff(d, @start_point, @end_point) > 365 
	BEGIN
		SET @end_point =  DATEADD(d,365,@start_point)
	END

	DECLARE @TotalCount INT
	SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))

	DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int, SubSystem nvarchar(10), tot_num INT)  

	DECLARE @sum INT, @Sub varchar(10)
	WHILE (@Counter <= @TotalCount)
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		--IF (@Checkin != 'ALL')
		--BEGIN
	    --  IF LEN(@Checkin)!=2
		--BEGIN
		--SET @SUB='CI0'+ @Checkin
		--SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND CONTROL_POINT like ('CI0'+ @Checkin + '%'))
		--END
		--ELSE
		--BEGIN
		--SET @SUB='CI'+ @Checkin
		--SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND CONTROL_POINT like ('CI'+ @Checkin + '%'))
		--END
		
		--INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@SUB, @sum)
		--END
		 
		BEGIN
		
		If '01' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
		BEGIN
		SET @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		         and [SUBSYSTEM] in ('CI01'))
		   INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI0'+ Convert(varchar,'1',20), @sum)
	    END
	
	   
	    If '02' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
	     BEGIN
	    SET @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		         and [SUBSYSTEM] in ('CI02'))
				 INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI0'+ Convert(varchar,'2',20), @sum)
        END

       
         If '03' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
          BEGIN
		SET @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		         and [SUBSYSTEM] in ('CI03'))
			 INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI0'+ Convert(varchar,'3',20), @sum)
        END

        If '04' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
        BEGIN
		SEt @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		         and [SUBSYSTEM] in ('CI04'))
				 INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI0'+ Convert(varchar,'4',20), @sum)
        END

        If '05' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
        BEGIN
		SEt @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		and [SUBSYSTEM] in ('CI05'))
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI0'+ Convert(varchar,'5',20), @sum)
        END
 
       If '06' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
       BEGIN
		SET @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		         and [SUBSYSTEM] in ('CI06'))
				 INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI0'+ Convert(varchar,'6',20), @sum)
       END

        If '07' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
        BEGIN
		SET @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		and [SUBSYSTEM] in ('CI07'))
	    INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI0'+ Convert(varchar,'7',20), @sum)
        END

        If '08' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
        BEGIN
		SET @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		and [SUBSYSTEM] in ('CI08'))
	    INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI0'+ Convert(varchar,'8',20), @sum)
        END

        If '09' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
        BEGIN
		SEt @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		and [SUBSYSTEM] in ('CI09'))
	    INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI0'+ Convert(varchar,'9',20), @sum)
        END
    
        If '10' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
        BEGIN
        SET @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		and [SUBSYSTEM] in ('CI10'))
	    INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI'+ Convert(varchar,'10',20), @sum)
        END

        If '11' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
        BEGIN
		SET @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		and [SUBSYSTEM] in ('CI11'))
	    INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI'+ Convert(varchar,'11',20), @sum)
        END
       
        If '12' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
        BEGIN
		SEt @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		and [SUBSYSTEM] in ('CI12'))
	    INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI'+ Convert(varchar,'12',20), @sum)
        END
 
        If '13' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
        BEGIN
		SEt @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		and [SUBSYSTEM] in ('CI13'))
	    INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI'+ Convert(varchar,'13',20), @sum)
        END
        
        If '14' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Checkin ,',')) )
        BEGIN
		SEt @sum=( SELECT count(*) FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and [STATUS]  = 'N'
		and [SUBSYSTEM] in ('CI14'))
	    INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'CI'+ Convert(varchar,'14',20), @sum)
        END
		
		
		END
	


		SET @Counter  = (@Counter + 1)
	End

	SELECT * FROM @temptable t order by t.SubSystem,t.Interval    

END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_LOADBALANCING_INPUT_TRANSFER]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_LOADBALANCING_INPUT_TRANSFER]
	@DTFrom datetime,
	@DTTo datetime,
	@Transfer varchar(10),
	@IntervalMin int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	----Sample
	--select '01' as transferLine, 127 as bags
	--union
	--select '02',43
	--SELECT substring(LOCATION,3,2) as checkinLine, COUNT(*) as bags FROM GID_USED WHERE TIME_STAMP between @DTFrom and @DTTo and LOCATION like 'Cl%'
	--and (LOCATION = 'Cl'+ LEFT('00'+@Checkin,2) or @Checkin = 'ALL' )
	--group by LOCATION

	DECLARE @Counter int
	SET @Counter = 1
	DECLARE @TimeStart DATETIME
	DECLARE @TimeEnd DATETIME
	DECLARE @interval int
	DECLARE @start_point datetime
	DECLARE @end_point datetime

	IF @IntervalMin < 5
	BEGIN
		SET @interval = 5
	END
	ELSE
	BEGIN
		SET @interval =  @IntervalMin
	END 
		
    SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
	SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

	IF datediff(d, @start_point, @end_point) > 365 
	BEGIN
		SET @end_point =  DATEADD(d,365,@start_point)
	END

	DECLARE @TotalCount INT
	SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))

	DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int, SubSystem nvarchar(10), tot_num INT)  

	DECLARE @sum INT

	WHILE (@Counter <= @TotalCount)
	BEGIN
		
		IF 'TX01' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Transfer ,',')) )
		BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND SUBSYSTEM  = 'TX01')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'TX01', @sum)
		
		END
		
		IF 'TX02' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Transfer ,',')) )
		BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND SUBSYSTEM  = 'TX02')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'TX02', @sum)
		
		END
		
		--ELSE IF(@Transfer ='ALL')
		--BEGIN
		--SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		--SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		----SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND SUBSYSTEM  in('TX01','TX02'))
		----INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'TX01', @sum)
		--SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND SUBSYSTEM  in('TX01'))
		--INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'TX01', @sum)
		
		--SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND SUBSYSTEM  in('TX02'))
		--INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'TX02', @sum)
		--END
		
		SET @Counter  = (@Counter + 1)
	End

	SELECT * FROM @temptable as t order by t.SubSystem,t.Interval 

END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_LOADBALANCING_MES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_LOADBALANCING_MES]
	@DTFrom datetime,
	@DTTo datetime,
	@MES varchar(100),
	@IntervalMin int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	----Sample
	--select 'MES01' as mes, 428 as bags
	--union
	--select 'MES02',753
	--union
	--select 'MES03',101
	--union
	--select 'MES04',159	

	--SELECT substring(LOCATION,3,2) as checkinLine, COUNT(*) as bags FROM GID_USED WHERE TIME_STAMP between @DTFrom and @DTTo and LOCATION like 'Cl%'
	--and (LOCATION = 'Cl'+ LEFT('00'+@Checkin,2) or @Checkin = 'ALL' )
	--group by LOCATION

	DECLARE @Counter int
	SET @Counter = 1
	DECLARE @TimeStart DATETIME
	DECLARE @TimeEnd DATETIME
	DECLARE @interval int
	DECLARE @start_point datetime
	DECLARE @end_point datetime
	Declare @LoopCount INT
	SET @LoopCount=1
	IF @IntervalMin < 5
	BEGIN
		SET @interval = 5
	END
	ELSE
	BEGIN
		SET @interval =  @IntervalMin
	END 
		
    SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
	SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

	IF datediff(d, @start_point, @end_point) > 365 
	BEGIN
		SET @end_point =  DATEADD(d,365,@start_point)
	END

	DECLARE @TotalCount INT
	SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))

	DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int, SubSystem nvarchar(10), tot_num INT)  

	DECLARE @sum INT

	WHILE (@Counter <= @TotalCount)
	BEGIN
	IF 'MES01' in ((SELECT ColumnA FROM dbo.udf_List2Table(@MES ,',')) )
	BEGIN

		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point) 
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_READY   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND [LOCATION] = 'MES01')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'MES01', @sum)
   END
   IF 'MES02' in ((SELECT ColumnA FROM dbo.udf_List2Table(@MES ,',')) )
	BEGIN

		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_READY   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND [LOCATION] = 'MES02')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'MES02', @sum)
   END
  IF 'MES03' in ((SELECT ColumnA FROM dbo.udf_List2Table(@MES ,',')) )
	BEGIN

		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_READY   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND [LOCATION] = 'MES03')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'MES03', @sum)
   END
  IF 'MES04' in ((SELECT ColumnA FROM dbo.udf_List2Table(@MES ,',')) )
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_READY   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND [LOCATION] = 'MES04')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'MES04', @sum)
   END
 -- ELSE IF @MES ='ALL'
	--BEGIN
	--	  SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
	--	   SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
	--	   SET @sum = (SELECT count(*)	FROM ITEM_READY   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND [LOCATION]  = 'MES01')
	--	   INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'MES01', @sum)
   
 --          SET @sum = (SELECT count(*)	FROM ITEM_READY    WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND [LOCATION] = 'MES02')
	--	   INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'MES02', @sum)
   
	--	   SET @sum = (SELECT count(*)	FROM ITEM_READY   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND [LOCATION] = 'MES03')
	--	   INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'MES03', @sum)

	--	   SET @sum = (SELECT count(*)	FROM ITEM_READY   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND [LOCATION] = 'MES04')
	--	   INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'MES04', @sum)

	--END

		SET @Counter  = (@Counter + 1)
	End

	SELECT * FROM @temptable as t order by t.SubSystem,t.Interval

END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_LOADBALANCING_RACETRACK]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_LOADBALANCING_RACETRACK]
	@DTFrom datetime,
	@DTTo datetime,
	@Racetrack varchar(100),
	@IntervalMin int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	----Sample
	--select 'RT01' as racetrack, 2210 as bags
	--union
	--select 'RT02', 1156
	--union
	--select 'RT03', 1049
	--union
	--select 'RT04', 2492
	--union
	--select 'RT05', 1355
	--union
	--select 'RT06', 1237
	--union
	--select 'RT07', 2285
	--union
	--select 'RTT',162

	--SELECT DESTINATION as racetrack, COUNT(*) as bags FROM ITEM_PROCEEDED WHERE TIME_STAMP between @DTFrom and @DTTo and DESTINATION in ('...')
	--group by DESTINATION

	DECLARE @Counter int
	SET @Counter = 1
	DECLARE @TimeStart DATETIME
	DECLARE @TimeEnd DATETIME
	DECLARE @interval int
	DECLARE @start_point datetime
	DECLARE @end_point datetime
	Declare @LoopCount INT
	SET @LoopCount=1
	IF @IntervalMin < 5
	BEGIN
		SET @interval = 5
	END
	ELSE
	BEGIN
		SET @interval =  @IntervalMin
	END 
		
    SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
	SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

	IF datediff(d, @start_point, @end_point) > 365 
	BEGIN
		SET @end_point =  DATEADD(d,365,@start_point)
	END

	DECLARE @TotalCount INT
	SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))

	DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int, SubSystem nvarchar(10), tot_num INT)  

	DECLARE @sum INT

	WHILE (@Counter <= @TotalCount)
	BEGIN
	IF 'RT01' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Racetrack ,',')) )
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		--SET @sum = (SELECT count(*)	FROM GID_USED  WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND LOCATION = 'RT01')
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION  = 'RT01')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'RT01', @sum)
	END
	IF 'RT02' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Racetrack ,',')) )
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION='RT02')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'RT02', @sum)
	END
	IF 'RT03' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Racetrack ,',')) )
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION = 'RT03')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'RT03', @sum)
	END
	IF 'RT04' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Racetrack ,',')) )
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION= 'RT04')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'RT04', @sum)
	END
	
	IF 'RT05' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Racetrack ,',')) )
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION= 'RT05')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'RT05', @sum)
	END
	
	IF 'RT06' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Racetrack ,',')) )
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION= 'RT06')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'RT06', @sum)
	END
	
	 IF 'RTT' in ((SELECT ColumnA FROM dbo.udf_List2Table(@Racetrack ,',')) )
	BEGIN
		SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
		SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED   WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION= 'RTT')
		INSERT INTO @temptable (start_time,end_time,Interval,SubSystem,tot_num ) values (@TimeStart,@TimeEnd,(@Counter *@interval),'RTT', @sum)
	END

		SET @Counter  = (@Counter + 1)
	End

	SELECT * FROM @temptable as t order by t.SubSystem ,t.Interval 

END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_MESUTILISATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================stp_RPT_MESUTILISATION '2010-11-21 11:53:49.920','2012-11-21 11:53:49.920' 
CREATE PROCEDURE [dbo].[stp_RPT_MESUTILISATION]
	@DTFrom datetime,
	@DTTo datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Sample
	--select '01' as mes, 984 as flight, 0 as racetrack, 0 as tbs, 0 as pb, 1 as removed, 19 as lastTub, 1003 as Total
	--union
	--select '02', 258,0,0,0,1,2,260
	--union
	--select '03',0,0,0,0,0,0,0
	--union
	--select '04',65,0,0,0,2,1,67

	SELECT W.mes , ISNULL(A.flight,0) as flight, ISNULL(B.racetrack,0) as racetrack, 
	ISNULL(C.tbs,0) as tbs, ISNULL(D.pb,0) as pb, 
	ISNULL(E.lastTub,0) as lastTub,ISNULL(F.removed,0) as removed,
	ISNULL(A.flight,0) + ISNULL(B.racetrack,0) + ISNULL(C.tbs,0) + ISNULL(D.pb,0)
	+ ISNULL(E.lastTub,0) + ISNULL(F.removed,0)
	as Total  FROM
	(
	select 'MES01' as mes
	union
	select 'MES02' as mes
	union
	select 'MES03' as mes
	union
	select 'MES04' as mes
	) W
	left join (
	SELECT LOCATION as mes, COUNT(*) as flight FROM ITEM_ENCODED 
	WHERE TIME_STAMP between @DTFrom and @DTTo and ENCODED_TYPE = '02' and LICENSE_PLATE != '9999999999'
	group by LOCATION) A
	on W.mes = A.mes
	left join 
	(SELECT LOCATION as mes, COUNT(*) as racetrack FROM ITEM_ENCODED 
	WHERE TIME_STAMP between @DTFrom and @DTTo and ENCODED_TYPE = '03' and DESTINATION not in ('TBS','PBL') and LICENSE_PLATE != '9999999999'
	group by LOCATION) B on W.mes = B.mes
	left join
	(SELECT LOCATION as mes, COUNT(*) as tbs FROM ITEM_ENCODED 
	WHERE TIME_STAMP between @DTFrom and @DTTo and DESTINATION = 'TBS' and LICENSE_PLATE != '9999999999'
	group by LOCATION) C on W.mes = C.mes
	left join
	(SELECT LOCATION as mes, COUNT(*) as pb FROM ITEM_ENCODED 
	WHERE TIME_STAMP between @DTFrom and @DTTo and DESTINATION = 'PBL' and LICENSE_PLATE != '9999999999'
	group by LOCATION) D on W.mes = D.mes
	left join
	(SELECT LOCATION as mes, COUNT(*) as lastTub FROM ITEM_ENCODED 
	WHERE TIME_STAMP between @DTFrom and @DTTo and LICENSE_PLATE = '9999999999'
	group by LOCATION) E on W.mes = E.mes
	left join
	(SELECT LOCATION as mes, COUNT(*) as removed FROM ITEM_REMOVED 
	WHERE TIME_STAMP between @DTFrom and @DTTo
	group by LOCATION) F on W.mes = D.mes
	
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_NUMBEROFBAGPROCESSED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [stp_RPT_NUMBEROFBAGPROCESSED] '2012-12-12 00:00:00.000', '2012-12-12 11:00:00:000', 120,''

CREATE PROCEDURE [dbo].[stp_RPT_NUMBEROFBAGPROCESSED] 
	@DTFrom datetime,
	@DTTo datetime,
    @IntervalMin int
AS
BEGIN     
		DECLARE @Counter int
		SET @Counter = 1
		DECLARE @TimeStart DATETIME
		DECLARE @TimeEnd DATETIME
	    DECLARE @interval int
		DECLARE @start_point datetime
		DECLARE @end_point datetime

		IF @IntervalMin < 5
		BEGIN
			SET @interval = 5
		END
		ELSE
		BEGIN
			SET @interval =  @IntervalMin
		END 
		
        SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
		SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

		IF datediff(d, @start_point, @end_point) > 365 
		BEGIN
			SET @end_point =  DATEADD(d,365,@start_point)
		END

		DECLARE @TotalCount INT
		SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))

		DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int,subsystem varchar(10), bag_number int)

		DECLARE @subsystem varchar(10), @bag_number int

		WHILE (@Counter <= @TotalCount)
		BEGIN
			SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
			SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
			select @subsystem = 'CL1', @bag_number = COUNT(*) from
			ITEM_PROCEEDED where (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and DESTINATION = 'CL01'
			INSERT INTO @temptable (start_time,end_time,Interval,subsystem, bag_number) values 
			(@TimeStart,@TimeEnd,(@Counter *@interval),@subsystem, @bag_number)
			
			select @subsystem = 'CL2', @bag_number = COUNT(*) from
			ITEM_PROCEEDED where (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and DESTINATION = 'CL02'
						INSERT INTO @temptable (start_time,end_time,Interval,subsystem, bag_number) values 
			(@TimeStart,@TimeEnd,(@Counter *@interval),@subsystem, @bag_number)
			
			select @subsystem = 'MES01', @bag_number = COUNT(*) from
			ITEM_READY where (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and LOCATION = 'MES01'
			INSERT INTO @temptable (start_time,end_time,Interval,subsystem, bag_number) values 
			(@TimeStart,@TimeEnd,(@Counter *@interval),@subsystem, @bag_number)
			
			select @subsystem = 'MES02', @bag_number = COUNT(*) from
			ITEM_READY where (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and LOCATION = 'MES02'
			INSERT INTO @temptable (start_time,end_time,Interval,subsystem, bag_number) values 
			(@TimeStart,@TimeEnd,(@Counter *@interval),@subsystem, @bag_number)
			
			
			select @subsystem = 'MES03', @bag_number = COUNT(*) from
			ITEM_READY where (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and LOCATION = 'MES03'
			INSERT INTO @temptable (start_time,end_time,Interval,subsystem, bag_number) values 
			(@TimeStart,@TimeEnd,(@Counter *@interval),@subsystem, @bag_number)

			select @subsystem = 'MES04', @bag_number = COUNT(*) from
			ITEM_READY where (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and LOCATION = 'MES04'
			INSERT INTO @temptable (start_time,end_time,Interval,subsystem, bag_number) values 
			(@TimeStart,@TimeEnd,(@Counter *@interval),@subsystem, @bag_number)
			
			select @subsystem = 'TX01', @bag_number = COUNT(*) from
			ITEM_PROCEEDED where (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and CONTROL_POINT like 'TX01%'
			INSERT INTO @temptable (start_time,end_time,Interval,subsystem, bag_number) values 
			(@TimeStart,@TimeEnd,(@Counter *@interval),@subsystem, @bag_number)
			
			select @subsystem = 'TX02', @bag_number = COUNT(*) from
			ITEM_PROCEEDED where (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) and CONTROL_POINT like 'TX02%'
			INSERT INTO @temptable (start_time,end_time,Interval,subsystem, bag_number) values 
			(@TimeStart,@TimeEnd,(@Counter *@interval),@subsystem, @bag_number)
						
			SET @Counter  = (@Counter + 1)
		End

		SELECT subsystem, MAX(bag_number) as max_number, MIN(bag_number) as min_number,(MAX(bag_number) + MIN(bag_number))/2 as med_number
		FROM @temptable
		GROUP BY subsystem
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_OKC_FlightSummary]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_RPT_OKC_FlightSummary]
		  @DTFROM datetime , 
		  @DTTO datetime
		  --@AIRLINE varchar(max) , 
		  --@FLIGHTNUM varchar(max)
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;

	--Create temp table for final result
	CREATE TABLE #FS_FLIGHTSUMMARY_TEMP 
	(
		FLIGHT_NUMBER VARCHAR(5),
		AIRLINE VARCHAR(3),
		BAG_TYPE VARCHAR(1),
		NUMBER_ALLBAGS INT,
		NUMBER_BAGS_ONTIME INT,
		NUMBER_BAGS_LATE INT
	);

	CREATE TABLE #FS_BAGSDETAIL_TEMP
	(
		AIRLINE varchar(3),
		FLIGHT_NUMBER varchar(5),
		SDO datetime,
		SOURCE varchar(1),
		BSM_TIME_STAMP datetime,
		CLOSEOUT_TIME datetime,
		LICENSE_PLATE varchar(10),
		LASTEST_GID varchar(10),
		SORTED_MARK int, -- Indicate whether this bag is sorted
		SORTED_TIMESTAMP datetime,-- Indicate when this bag is sorted
		SORTED_ONTIME_MARK int, -- Indicate whether this bag is sorted on time
		BAG_LATE_MARK int -- Indicate whether this bag is sorted late BY IRD
	);

	--1. Query flight info that its STO is between @DTFROM and @DTTO
	SELECT FPS.AIRLINE,FPS.FLIGHT_NUMBER,FPS.SDO,FPS.STO,FPS.EDO,FPS.ETO,FPA.ALLOC_CLOSE_OFFSET,FPA.ALLOC_CLOSE_RELATED
	INTO #FS_FLIGHT_PLAN_ALLOC_TEMP
	FROM FLIGHT_PLAN_SORTING FPS WITH(NOLOCK)
	LEFT JOIN FLIGHT_PLAN_ALLOC FPA WITH(NOLOCK)
	ON	FPS.AIRLINE=FPA.AIRLINE AND FPS.FLIGHT_NUMBER=FPA.FLIGHT_NUMBER AND FPS.SDO=FPA.SDO
		AND CONVERT(datetime,CONVERT(VARCHAR,fpa.SDO,103)+' '+DBO.RPT_GETFORMATTEDSTO(fpa.STO),103) BETWEEN @DTFROM AND @DTTO
		AND FPA.TIME_STAMP=(SELECT MAX(TIME_STAMP) 
							FROM FLIGHT_PLAN_ALLOC FPA2 WITH(NOLOCK)
							WHERE FPA2.AIRLINE=FPA.AIRLINE 
								AND FPA2.FLIGHT_NUMBER=FPA.FLIGHT_NUMBER 
								AND FPA2.SDO=FPA.SDO
						   )
	WHERE CONVERT(datetime,CONVERT(VARCHAR,FPS.SDO,103)+' '+DBO.RPT_GETFORMATTEDSTO(FPS.STO),103) BETWEEN @DTFROM AND @DTTO;
	
	--SELECT * FROM #FS_FLIGHT_PLAN_ALLOC_TEMP;

	--2. Insert into all bags detail from bag_sorting to #FS_BAGSDETAIL_TEMP
	INSERT INTO #FS_BAGSDETAIL_TEMP
	SELECT DISTINCT BSA.AIRLINE, BSA.FLIGHT_NUMBER, BSA.SDO, SOURCE, BSA.TIME_STAMP AS BSM_TIME_STAMP, 
		CASE FPA.ALLOC_CLOSE_RELATED
			WHEN 'ETD' 
				--THEN CONVERT(DATETIME,CONVERT(VARCHAR,FPA.EDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(dbo.SAC_OFFSETOPERATOR(FPA.ETO,FPA.ALLOC_CLOSE_OFFSET)),103)
				THEN DBO.RPT_TIME_CAL(FPA.EDO,FPA.ETO,FPA.ALLOC_CLOSE_OFFSET)
			WHEN 'STD' 
				--THEN CONVERT(DATETIME,CONVERT(VARCHAR,FPA.SDO,103) + ' ' + DBO.RPT_GETFORMATTEDSTO(dbo.SAC_OFFSETOPERATOR(FPA.STO,FPA.ALLOC_CLOSE_OFFSET)),103)
				THEN DBO.RPT_TIME_CAL(FPA.SDO,FPA.STO,FPA.ALLOC_CLOSE_OFFSET)
		END AS CLOSEOUT_TIME, 
		LICENSE_PLATE, '' AS LASTEST_GID, 0 AS SORTED_MARK, NULL AS SORTED_TIMESTAMP, 0 AS SORTED_ONTIME_MARK, 0 AS BAG_LATE_MARK
	FROM 
	(
		SELECT AIRLINE, FLIGHT_NUMBER, SDO, SOURCE, TIME_STAMP, LICENSE_PLATE
		FROM BAG_SORTING WITH(NOLOCK)
		WHERE SDO BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)			
		UNION ALL
		SELECT AIRLINE, FLIGHT_NUMBER, SDO, SOURCE, TIME_STAMP, LICENSE_PLATE
		FROM BAG_SORTING_HIS WITH(NOLOCK)
		WHERE SDO BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)	

	) AS BSA, #FS_FLIGHT_PLAN_ALLOC_TEMP FPA
	WHERE BSA.AIRLINE=FPA.AIRLINE AND BSA.FLIGHT_NUMBER=FPA.FLIGHT_NUMBER AND BSA.SDO=FPA.SDO;

	CREATE INDEX #FS_BAGSDETAIL_TEMP_IDXLP ON #FS_BAGSDETAIL_TEMP(LICENSE_PLATE);

	--SELECT * FROM #FS_BAGSDETAIL_TEMP;

	--3. Query the ATR read info into temp table #BT_ITEM_TAGREAD_TEMP
	SELECT ISC.GID, ISC.LICENSE_PLATE1, ISC.LICENSE_PLATE2, ISC.LOCATION, ISC.TIME_STAMP INTO #FS_ITEM_TAGREAD_TEMP
	FROM ITEM_SCANNED ISC, #FS_BAGSDETAIL_TEMP FBD WITH(NOLOCK)
	WHERE (ISC.LICENSE_PLATE1=FBD.LICENSE_PLATE OR ISC.LICENSE_PLATE2=FBD.LICENSE_PLATE)
		AND ISC.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
		AND (ISC.STATUS_TYPE='1' OR ISC.STATUS_TYPE='3' OR ISC.STATUS_TYPE='7');
	--ORDER BY ISC.TIME_STAMP DESC; 

	--4. Query the MES read info into temp table #BT_ITEM_TAGREAD_TEMP 
	INSERT INTO #FS_ITEM_TAGREAD_TEMP
	SELECT IEC.GID,IEC.LICENSE_PLATE AS LICENSE_PLATE1,'0000000000' AS LICENSE_PLATE2,IEC.LOCATION,IEC.TIME_STAMP 
	FROM ITEM_ENCODED IEC,#FS_BAGSDETAIL_TEMP FBD WITH(NOLOCK)
	WHERE IEC.LICENSE_PLATE=FBD.LICENSE_PLATE
		AND IEC.LICENSE_PLATE IS NOT NULL AND LEN(IEC.LICENSE_PLATE)<>0
		AND IEC.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)

	--In Charlotte project, there are 2 ATRs and MES a bag may goes through. 
	--So stored procedure must find the lastest location where item_scanned telegram is sent ordered by time_stamp
	--SELECT GID, LICENSE_PLATE1, LICENSE_PLATE2, LOCATION, MAX(TIME_STAMP) AS TIME_STAMP INTO #FS_TAGREAD_TEMP
	--FROM #FS_ITEM_TAGREAD_TEMP
	--GROUP BY GID, LICENSE_PLATE1, LICENSE_PLATE2, LOCATION;

	DECLARE @TAGREAD_TABLE AS TAGREAD_TABLETYPE; --For the parameter of stp_RPT_GET_LATEST_TAGREAD

	INSERT INTO @TAGREAD_TABLE
	SELECT * FROM #FS_ITEM_TAGREAD_TEMP;

	CREATE TABLE #FS_TAGREAD_TEMP
	( 
		GID VARCHAR(10),
		LICENSE_PLATE VARCHAR(10), 
		--LICENSE_PLATE2 VARCHAR(10), 
		LOCATION VARCHAR(20), 
		TIME_STAMP DATETIME
	);

	INSERT INTO #FS_TAGREAD_TEMP
	EXEC dbo.stp_RPT_GET_LATEST_TAGREAD @TAGREAD_TABLE;

	CREATE INDEX #FS_TAGREAD_TEMP_IDXLP1 ON #FS_TAGREAD_TEMP(LICENSE_PLATE);
	--CREATE INDEX #FS_TAGREAD_TEMP_IDXLP2 ON #FS_TAGREAD_TEMP(LICENSE_PLATE2);

	------------------ Commented by Guo Wenyu 2014/01/02 -------------------------

	--Because the bag on-time or late definition is confirmed.
	--Their definition is from comparison between item_scanned.time_stamp and close-time
	--Not between item_proceeded.time_stamp and close-time (original my codes)

	----5. Update ATR OR MES read info(Latest GID) into #FS_BAGSDETAIL_TEMP
	--UPDATE FBT
	--SET FBT.LASTEST_GID=FTT.GID
	--FROM #FS_TAGREAD_TEMP FTT, #FS_BAGSDETAIL_TEMP FBT
	--WHERE FTT.LICENSE_PLATE1=FBT.LICENSE_PLATE OR FTT.LICENSE_PLATE2=FBT.LICENSE_PLATE

	----6. Update sorted info (SORTED_MARK, SORTED_TIMESTAMP, SORTED_ONTIME_MARK) into #FS_BAGSDETAIL_TEMP
	--UPDATE FBT
	--SET FBT.SORTED_MARK=1, FBT.SORTED_TIMESTAMP=IPR.TIME_STAMP,
	--	FBT.SORTED_ONTIME_MARK=
	--	CASE
	--		WHEN IPR.TIME_STAMP<=FBT.CLOSEOUT_TIME THEN 1
	--		ELSE 0
	--	END
	--FROM ITEM_PROCEEDED IPR, LOCATIONS LOC,#FS_BAGSDETAIL_TEMP FBT WITH(NOLOCK)
	--WHERE IPR.GID=FBT.LASTEST_GID AND FBT.LASTEST_GID IS NOT NULL
	--	AND IPR.PROCEED_LOCATION = LOC.LOCATION_ID
	--	AND LOC.SUBSYSTEM LIKE 'MU%'
	--	AND IPR.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO);

	----7. Update bag late mark(BAG_LATE_MARK) into #FS_BAGSDETAIL_TEMP
	--UPDATE FBT
	--SET FBT.BAG_LATE_MARK=1
	--FROM ITEM_REDIRECT IRD, #FS_BAGSDETAIL_TEMP FBT WITH(NOLOCK)
	--WHERE IRD.GID=FBT.LASTEST_GID AND FBT.LASTEST_GID IS NOT NULL
	--	AND IRD.REASON='5'--TOO LATE
	--	AND IRD.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFrom) AND DATEADD(DAY,@DATERANGE,@DTTo);

	------------------END Commented by Guo Wenyu 2014/01/02 END-------------------------

	--New definition of bag on-time and late
	--6. Update ATR OR MES read info(Latest GID) into #FS_BAGSDETAIL_TEMP
	UPDATE	FBT
	SET		FBT.LASTEST_GID=TGR.GID,
			FBT.SORTED_MARK=1,
			FBT.SORTED_TIMESTAMP=TGR.TIME_STAMP,
			FBT.SORTED_ONTIME_MARK=
			CASE
				WHEN TGR.TIME_STAMP<FBT.CLOSEOUT_TIME THEN 1
				ELSE 0
			END,
			FBT.BAG_LATE_MARK=
			CASE
				WHEN TGR.TIME_STAMP>=FBT.CLOSEOUT_TIME THEN 1
				ELSE 0
			END
	FROM #FS_TAGREAD_TEMP TGR, #FS_BAGSDETAIL_TEMP FBT
	WHERE TGR.LICENSE_PLATE=FBT.LICENSE_PLATE

	

	--8. Finally, get the statistic result
	--Flight Summary cannot base on FLIGHT_PLAN_SORTING, because same flight may have different bag type
	--INSERT INTO #FS_FLIGHTSUMMARY_TEMP
	--SELECT DISTINCT FLIGHT_NUMBER,AIRLINE,NULL AS BAG_TYPE, 0 AS NUMBER_ALLBAGS, 0 AS NUMBER_BAGS_ONTIME,0 AS NUMBER_BAGS_LATE
	--FROM FLIGHT_PLAN_SORTING FPS WITH(NOLOCK)
	--WHERE CONVERT(datetime,CONVERT(VARCHAR,FPS.SDO,103)+' '+DBO.RPT_GETFORMATTEDSTO(FPS.STO),103) BETWEEN @DTFROM AND @DTTO;
	--UPDATE	FLTSUM
	--SET		FLTSUM.BAG_TYPE=FLTSTC.BAG_TYPE,
	--		FLTSUM.NUMBER_ALLBAGS=FLTSTC.NUMBER_ALLBAGS,
	--		FLTSUM.NUMBER_BAGS_ONTIME=FLTSTC.NUMBER_BAGS_ONTIME,
	--		FLTSUM.NUMBER_BAGS_LATE=FLTSTC.NUMBER_BAGS_LATE
	--FROM	(SELECT	FLIGHT_NUMBER, AIRLINE,
	--			CASE SOURCE
	--				WHEN 'L' THEN 'O'
	--				WHEN 'T' THEN 'X'
	--				WHEN 'A' THEN 'T'
	--				ELSE ''
	--			END AS BAG_TYPE,count(LICENSE_PLATE) AS NUMBER_ALLBAGS,SUM(SORTED_ONTIME_MARK) AS NUMBER_BAGS_ONTIME, SUM(BAG_LATE_MARK) AS NUMBER_BAGS_LATE
	--		FROM #FS_BAGSDETAIL_TEMP FBT
	--		GROUP BY FBT.FLIGHT_NUMBER,FBT.AIRLINE,FBT.SOURCE
	--		) AS FLTSTC
	--		,#FS_FLIGHTSUMMARY_TEMP FLTSUM
	--WHERE	FLTSUM.AIRLINE=FLTSTC.AIRLINE AND FLTSUM.FLIGHT_NUMBER=FLTSTC.FLIGHT_NUMBER;

	INSERT INTO #FS_FLIGHTSUMMARY_TEMP
	SELECT	FLIGHT_NUMBER, AIRLINE,
			CASE SOURCE
				WHEN 'L' THEN 'O'
				WHEN 'T' THEN 'X'
				WHEN 'A' THEN 'T'
				ELSE ''
			END AS BAG_TYPE,count(LICENSE_PLATE) AS NUMBER_ALLBAGS,SUM(SORTED_ONTIME_MARK) AS NUMBER_BAGS_ONTIME, SUM(BAG_LATE_MARK) AS NUMBER_BAGS_LATE
	FROM #FS_BAGSDETAIL_TEMP FBT
	GROUP BY FBT.FLIGHT_NUMBER,FBT.AIRLINE,FBT.SOURCE

	SELECT * FROM #FS_FLIGHTSUMMARY_TEMP;
END

--DECLARE @DTFROM DATETIME='2014-1-1';
--DECLARE @DTTO DATETIME='2014-1-3';
--EXEC stp_RPT16_FlightSummary_GWYTEST @DTFROM,@DTTO;

GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_PEAKLEVEL1UTILIZATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--stp_RPT_PEAKLEVEL1UTILIZATION '2013-04-23 00:00:00.000', '2013-04-23 4:00:00:000', 1, 16, 20

CREATE PROCEDURE [dbo].[stp_RPT_PEAKLEVEL1UTILIZATION] 
	@DTFrom datetime,
	@DTTo datetime,
   -- @CheckinRowMin int,
    @CheckinRowList nvarchar(50),
   -- @CheckinRowMax int,
    @IntervalMin int 
AS
BEGIN     
		DECLARE @Counter int
		SET @Counter = 1
		--DECLARE @Counter_CheckinLine int
		--SET @Counter = @CheckinRowMin
		DECLARE @TimeStart DATETIME
		DECLARE @TimeEnd DATETIME
	    DECLARE @interval int
		DECLARE @start_point datetime
		DECLARE @end_point datetime

		--IF @CheckinRowMax > 16
		--BEGIN
		--	SET @CheckinRowMax = 16
		--END

		IF @IntervalMin < 5
		BEGIN
			SET @interval = 5
		END
		ELSE
		BEGIN
			SET @interval =  @IntervalMin
		END 
		
        SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
		SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

		IF datediff(d, @start_point, @end_point) > 365 
		BEGIN
			SET @end_point =  DATEADD(d,365,@start_point)
		END

		DECLARE @TotalCount INT
		SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))
		
		DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int,tot_num INT, subsystem varchar(10))  

		DECLARE @sum INT
		
		WHILE (@Counter <= @TotalCount)
		
		BEGIN
			SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
			SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
		
		
			   IF '01' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) ='01')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT'+ RIGHT('0'+CONVERT(varchar(2), @CheckInRowList,2),2))
				END
				
				IF '02' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) = '02')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT02')
				END
				
				IF '03' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) ='03')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT03')
				END
				
				IF '04' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) ='04')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT04')
				END
				
				IF '05' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) ='05')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT05')
				END
				
				IF '06' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) = '06')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT06')
				END
				
				IF '07' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) ='07')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT07')
				END
				
				IF '08' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) ='08')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT08')
				END
				
				IF '09' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) = '09')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT09')
				END
				
				IF '10' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) = '10')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT10')
				END
				
				IF '11' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) = '11')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT11')
				END
				
	            IF '12' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) = '12')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT12')
				END
							
				IF '13' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) ='13')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT13')
				END
				
				IF '14' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' 
				AND substring(SUBSYSTEM,5,2) ='14')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'CT14')
				END
				
				IF 'TX01' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' AND substring(SUBSYSTEM,5,3) = 'TX1')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'TX01')
				END
				IF 'TX02' in ((SELECT ColumnA FROM dbo.udf_List2Table(@CheckInRowList ,',')) )
				BEGIN
				SET @sum = (SELECT count(*)	FROM ITEM_SCREENED A WHERE (A.TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND A.SCREEN_LEVEL = '1' AND substring(SUBSYSTEM,5,3) = 'TX2')
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, subsystem ) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, 'TX02')
				END
		
		
			--SET @Counter_CheckinLine = @CheckinRowMin
			 SET @Counter  = (@Counter + 1)
		End
   
		

		SELECT * FROM @temptable order by subsystem, start_time
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_RACETRACKSTATUS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- stp_RPT_RACETRACKSTATUS '2013-04-25 01:50:00.647','2013-04-25 02:50:00.647', '1', '7','60'

CREATE PROCEDURE [dbo].[stp_RPT_RACETRACKSTATUS] 
	@DTFrom datetime,
	@DTTo datetime,
    @RacetrackMin varchar(5),
    @RacetrackMax varchar(5), 
    @IntervalMin int
AS
BEGIN     
		DECLARE @Counter int
		SET @Counter = 1
		IF @RacetrackMin = 'RTT'
		BEGIN
			SET @RacetrackMin = '8'
		END
		IF @RacetrackMax = 'RTT'
		BEGIN
			SET @RacetrackMin = '8'
		END
		DECLARE @Counter_Racetrack int
		SET @Counter = CONVERT(int,@RacetrackMin,1)
		DECLARE @TimeStart DATETIME
		DECLARE @TimeEnd DATETIME
	    DECLARE @interval int
		DECLARE @start_point datetime
		DECLARE @end_point datetime

		IF @IntervalMin < 5
		BEGIN
			SET @interval = 5
		END
		ELSE
		BEGIN
			SET @interval =  @IntervalMin
		END 
		
        SET @start_point = convert(datetime,RIGHT(STR(DATEPART(dd,@DTFrom)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTFrom)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTFrom)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTFrom))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTFrom)),2) +':00.000' , 103)  
		SET @end_point =  convert(datetime,RIGHT(STR(DATEPART(dd,@DTTo)),2) +'/' + RIGHT(STR(DATEPART(mm,@DTTo)),2) + '/' + RIGHT(STR(DATEPART(yyyy,@DTTo)),4)+ ' '+RIGHT('00'+LTRIM(STR(DATEPART(hh,@DTTo))),2)+':'+ RIGHT(STR(DATEPART(MI,@DTTo)),2) +':00.000' , 103)

		IF datediff(d, @start_point, @end_point) > 365 
		BEGIN
			SET @end_point =  DATEADD(d,365,@start_point)
		END

		DECLARE @TotalCount INT
		SET @TotalCount = CONVERT (INT ,(DATEDIFF(mi, @start_point, @end_point)/@interval))

		DECLARE @temptable TABLE (start_time datetime,end_time datetime,Interval int,tot_num INT, racetrack varchar(10))  

		DECLARE @sum INT
		DECLARE @racetarck varchar(5)

		WHILE (@Counter <= @TotalCount)
		BEGIN
			SET @TimeEnd = DATEADD(mi,@Counter * @interval, @start_point)
			SET @TimeStart = DATEADD(mi,-1*@interval,@TimeEnd)
			WHILE (@Counter_Racetrack <= CONVERT(int,@RacetrackMax,1))
			BEGIN
				IF (@Counter_Racetrack = 1)
				BEGIN
					SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION in ('RT01'))
					SET @racetarck = 'RT01'
				END
				IF (@Counter_Racetrack = 2)
				BEGIN
					SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION in ('RT02'))
					SET @racetarck = 'RT02'
				END	
				IF (@Counter_Racetrack = 3)
				BEGIN
					SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION in ('RT03'))
					SET @racetarck = 'RT03'
				END
				IF (@Counter_Racetrack = 4)
				BEGIN
					SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION in ('RT04'))
					SET @racetarck = 'RT04'
				END
				IF (@Counter_Racetrack = 5)
				BEGIN
					SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION in ('RT05'))
					SET @racetarck = 'RT05'
				END
				IF (@Counter_Racetrack = 6)
				BEGIN
					SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION in ('RT06'))
					SET @racetarck = 'RT06'
				END
				IF (@Counter_Racetrack = 7)
				BEGIN
					SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION in ('RT07'))
					SET @racetarck = 'RT07'
				END
				IF (@Counter_Racetrack = 8)
				BEGIN
					SET @sum = (SELECT count(*)	FROM ITEM_PROCEEDED WHERE (TIME_STAMP BETWEEN @TimeStart AND  @TimeEnd ) AND DESTINATION in ('RTT'))
					SET @racetarck = 'RTT'
				END		
				INSERT INTO @temptable (start_time,end_time,Interval,tot_num, racetrack) values (@TimeStart,@TimeEnd,(@Counter *@interval),@sum, @racetarck)
				SET @Counter_Racetrack = (@Counter_Racetrack + 1)
			END
			SET @Counter_Racetrack = CONVERT(int,@RacetrackMin,1)
			SET @Counter  = (@Counter + 1)
		End

		--INSERT INTO @temptable (start_time,end_time,Interval,tot_num, racetrack) values ('2013-01-07 11:20:00','2013-01-07 11:40:00',1,13, 'RT02')
		--INSERT INTO @temptable (start_time,end_time,Interval,tot_num, racetrack) values ('2013-01-07 11:40:00','2013-01-07 12:00:00',1,25, 'RT02')
		--INSERT INTO @temptable (start_time,end_time,Interval,tot_num, racetrack) values ('2013-01-07 11:20:00','2013-01-07 11:40:00',1,23, 'RTT')
		--INSERT INTO @temptable (start_time,end_time,Interval,tot_num, racetrack) values ('2013-01-07 11:40:00','2013-01-07 12:00:00',1,35, 'RTT')

		SELECT * FROM @temptable order by racetrack
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT_UNEXPECTEDBAG]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[stp_RPT_UNEXPECTEDBAG] 
	@DTFrom datetime,
	@DTTo datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Sample 
	--select 'BR1-1A' as LOCATION, 0 as lost, 1 as stray
	--union
	--select 'BR1-3', 1, 0
	--union
	--select 'CT10A-1',1,2

	select A.LOCATION, B.lost, c.stray from
	(select distinct LOCATION from ITEM_LOST) A
	left join
	(select LOCATION, COUNT(*) as lost from ITEM_LOST where TIME_STAMP between @DTFrom and @DTTo
	group by LOCATION) B on A.LOCATION = B.LOCATION
	left join
	(select LOCATION, COUNT(*) as stray from GID_USED where BAG_TYPE != 'N' and TIME_STAMP between @DTFrom and @DTTo
	group by LOCATION) C on A.LOCATION = C.LOCATION
	where B.lost !=0 and C.stray !=0
	
END


GO
/****** Object:  StoredProcedure [dbo].[stp_RPT0501_EquipMalfunction]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_RPT0501_EquipMalfunction]
		  @DTFrom datetime, 
		  @DTTo datetime,
		  @Subsystem varchar(max),
		  @EquipmentID varchar(max),
		  @FaultType varchar(max)
AS
BEGIN
	SELECT	ALM_ALMAREA1 AS ALM_SUBSYSTEM, 
			ALM_ALMEXTFLD2 AS ALM_EQUIPID, 
			ALM_STARTTIME AS ALM_TIMESET, 
			ALM_MSGDESC AS ALM_DESCRIPTION
	FROM	MDS_ALARMS WITH(NOLOCK)
	WHERE	ALM_UNCERTAIN = 0
			AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo 
			AND ALM_ALMAREA1 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@Subsystem)) 
			AND ALM_ALMEXTFLD2 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@EquipmentID)) 
			AND ALM_ALMAREA2 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@FaultType))
	ORDER BY ALM_STARTTIME

END

--DECLARE @DTFrom datetime='2009-11-01';
--DECLARE @DTTo datetime='2009-12-31';
--DECLARE @Subsystem varchar(max)='AL1,CS1,CL3';
--DECLARE @EquipmentID varchar(max)='AL1-01,AL1-07,AL1-08,CS1-01,CS1-02,CS1-04,CL3-01,CL3-11,CL3-12';
--DECLARE @FaultType varchar(max)='AA_ENUS,AA_BJAM,AA_ESTP,AA_ENUS,AA_ISOF,AA_CNFT';
--EXEC stp_RPT0501_EquipMalfunction @DTFrom,@DTTo,@Subsystem,@EquipmentID,@FaultType
--EXEC stp_RPT0502_EquipCorrection @DTFrom,@DTTo,@Subsystem,@EquipmentID,@FaultType
GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_AIRPORTCODEFUNCALLOCINFORMATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_AIRPORTCODEFUNCALLOCINFORMATION] 
	@AirportCode [varchar](4), 
	@DumpDest [varchar](10),
	@NoAllocDest [varchar](10), 
	@NoCarrierDest [varchar](10),
	@NoReadDest [varchar](10)
AS
BEGIN
	-- Step 1: Insert [AIRPORT_CODE_FUNCTION_ALLOC_INFO] bag event into event table [AIRPORT_CODE_FUNCTION_ALLOC_INFO].
	INSERT INTO [LOG_AIRPORT_CODE_FUNCTION_ALLOC_INFO]
			   ([TIME_STAMP], [AIRPORT_CODE], [DUMP_DEST], [NO_ALLOC_DEST], [NO_CARRIER_DEST], [NO_READ_DEST])
		 VALUES
			   (GETDATE(), @AirportCode, @DumpDest, @NoAllocDest, @NoCarrierDest, @NoReadDest);
END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_AUTOINCREASEMANUALCLOSEFLIGHTOFFSET]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_AUTOINCREASEMANUALCLOSEFLIGHTOFFSET]
	@Is_Manual_Close bit
AS
Begin
	Declare @AirLine varchar(3);
	Declare @FLIGHT_NUMBER varchar(5);
	Declare @RESOURCE varchar(10);
	Declare @Now datetime;
	Declare @RushNow datetime	;
	Declare @STODT datetime;
	Declare @STO varchar(4);
	Declare @SDO datetime;
	Declare @CloseOffset varchar(5);
	Declare @DefaultCloseOffset varchar(4);
	Declare @RushOffset varchar(5);
	Declare @ETime varchar(4);
	Declare @ResultCloseOffset varchar(5);
	Declare @MyDay int;
	Declare @MyHour int;
	Declare @MyMinute bigint;
	Declare @DiffOffset varchar(4);
	Declare @Close_Do datetime;
	Declare @Close_Related varchar(4);
	Declare @Close_To varchar(4);
	
	Set @STO = '';
	Set @CloseOffset = '';
	Set @Close_Related = 'STD';
	Set @Now = DATEADD(ss, -DATEPART(ss,GETDATE()),GETDATE()); --get now without seconds

	SELECT @DefaultCloseOffset = SUBSTRING(SYS_VALUE,2,4) FROM SYS_CONFIG WHERE (SYS_KEY='ALLOC_CLOSE_OFFSET');

	Declare CHKAuto CURSOR FOR
	SELECT SDO,STO,ALLOC_CLOSE_OFFSET,RUSH_DURATION,AIRLINE,FLIGHT_NUMBER,[RESOURCE] FROM dbo.FLIGHT_PLAN_ALLOC
	WHERE ((IS_MANUAL_CLOSE=@Is_Manual_Close) AND (IS_CLOSED=0));
	OPEN CHKAuto;	

	FETCH CHKAuto INTO @SDO,@STO,@CloseOffset,@RushOffset,@AirLine,@FLIGHT_NUMBER,@RESOURCE;
	WHILE @@FETCH_STATUS = 0
		Begin
			
			--//Close Related	
				Set @Close_Do=@SDO
				SELECT @Close_Related=ALLOC_CLOSE_RELATED FROM FLIGHT_PLAN_ALLOC 
					WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FLIGHT_NUMBER) AND (SDO = @SDO) AND (RESOURCE=@RESOURCE));
				--STD
				IF(RTRIM(LTRIM(@Close_Related))='STD')
					Begin
						SELECT @Close_Do=SDO,@Close_To=STO
						FROM FLIGHT_PLAN_ALLOC WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FLIGHT_NUMBER) AND (SDO = @SDO) AND (RESOURCE=@RESOURCE));
					End
				--ETD
				ELSE IF(RTRIM(LTRIM(@Close_Related))='ETD')
					Begin
						SELECT @Close_Do=EDO,@Close_To=ETO
						FROM FLIGHT_PLAN_ALLOC WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FLIGHT_NUMBER) AND (SDO=@SDO) AND (RESOURCE=@RESOURCE));
					End
				--ITD
				ELSE IF(RTRIM(LTRIM(@Close_Related))='ITD')
					Begin
						SELECT @Close_Do=IDO,@Close_To=ITO
						FROM FLIGHT_PLAN_ALLOC WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FLIGHT_NUMBER) AND (SDO=@SDO) AND (RESOURCE=@RESOURCE));
					End
				--ATD
				ELSE IF(RTRIM(LTRIM(@Close_Related))='ATD')
					Begin
						SELECT @Close_Do=ADO,@Close_To=ATO
						FROM FLIGHT_PLAN_ALLOC WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FLIGHT_NUMBER) AND (SDO=@SDO) AND (RESOURCE=@RESOURCE));
					End
			--//Close Related	
			Set @ETime = [dbo].[SAC_OFFSETOPERATOR](@Close_To,@DefaultCloseOffset);				
			Set @STODT = DATEADD(mi,[dbo].[SAC_MINUTECONVERTER](@ETime), CONVERT(datetime, CONVERT(nvarchar(30),@Close_Do, 111)));
			Set @RushNow = @Now;

			IF((@STODT <= DATEADD(mi,[dbo].[SAC_MINUTECONVERTER](@RushOffset)+50, @RushNow)) AND ([dbo].[SAC_MINUTECONVERTER](@CloseOffset)<5760))
			Begin
				Set @MyHour = FLOOR(DATEDIFF(hh,@STODT,DATEADD(mi,[dbo].[SAC_MINUTECONVERTER](@RushOffset)+50, @RushNow)));
				Set @MyMinute = DATEDIFF(mi,@STODT,DATEADD(mi,[dbo].[SAC_MINUTECONVERTER](@RushOffset)+50, @RushNow))-(@MyHour * 60) ;
				
				IF(@MyHour >= 96)
					Begin
						Set @DiffOffset = '9600';
						Set @ResultCloseOffset = @DiffOffset;
						
						UPDATE dbo.FLIGHT_PLAN_ALLOC Set [ALLOC_CLOSE_OFFSET] = @ResultCloseOffset,IS_CLOSED=1
						WHERE ((SDO=@SDO) AND (IS_MANUAL_CLOSE=@Is_Manual_Close) AND (AIRLINE=@AirLine) 
						AND (FLIGHT_NUMBER=@FLIGHT_NUMBER) AND (RESOURCE=@RESOURCE));
					End
				ELSE
					Begin
							--Hour
							IF(@MyHour>0)
								Begin
									IF(LEN(@MyHour)=1)
										Begin
											Set @DiffOffset='0' + CONVERT(varchar(1),@MyHour);
										End	
									ELSE
										Begin
											Set @DiffOffset = CONVERT(varchar(2),@MyHour);
										End
								END
							ELSE
								Begin
									Set @DiffOffset='00';
								End
							--Minute
							IF(@MyMinute>0)
								Begin
									IF(LEN(@MyMinute)=1)
										Begin
											Set @DiffOffset=@DiffOffset +'0'+ CONVERT(varchar(1),@MyMinute);
										End	
									ELSE
										Begin
											Set @DiffOffset=@DiffOffset+ CONVERT(varchar(2),@MyMinute);
										End
								End
							ELSE
								Begin
									Set @DiffOffset=@DiffOffset+'00';
								End
						Set @ResultCloseOffset = @DiffOffset;
						UPDATE dbo.FLIGHT_PLAN_ALLOC SET [ALLOC_CLOSE_OFFSET] = @ResultCloseOffset
						WHERE (([SDO]=@SDO) AND ([IS_MANUAL_CLOSE]=@Is_Manual_Close) AND ([AIRLINE]=@AirLine)
						AND ([FLIGHT_NUMBER]=@FLIGHT_NUMBER) AND ([RESOURCE]=@RESOURCE) AND ([IS_CLOSED]= 0));
					End
			End
			FETCH CHKAuto INTO @SDO,@STO,@CloseOffset,@RushOffset,@AirLine,@FLIGHT_NUMBER,@RESOURCE;
		End
	CLOSE CHKAuto;
	DEALLOCATE CHKAuto;
End


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_BAGGAGEMEASUREMENTARRAY]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_BAGGAGEMEASUREMENTARRAY] 
	@GID [varchar](10), 
	@BMALocation [varchar](10),
	@Length [Decimal] (18,2),
	@Width [Decimal] (18,2),
	@Height [Decimal] (18,2), 
	@BMAType [varchar](2)
AS
BEGIN
	---- Step 1: Insert or Update new GID info into sortation working table [BAG].
	--DECLARE @Count int = 0;
	--DECLARE @CarrierID [varchar](3) = (SELECT ID FROM CARRIER WHERE id = SUBSTRING(@LicensePlate,2,3));
	--DECLARE	@No int
		
	--SET @No = (SELECT Count(*) FROM [BAG] WHERE [IATA]=@LicensePlate)
	--IF @No = 0
	--	BEGIN
	--		INSERT INTO [BAG] 
	--			(TIME_STAMP, IATA, CARRIER_ID, LOCATION, NO_OF_TIME_SEEN)
	--		VALUES 
	--			(GETDATE(), @LicensePlate, @CarrierID, @BMALocation, @Count);
	--	END
	--ELSE
	--	BEGIN
	--		SET @Count = (SELECT (NO_OF_TIME_SEEN + 1) FROM BAG WHERE [IATA]=@LicensePlate);
	--		UPDATE [BAG]
	--		SET [LOCATION]=@BMALocation, NO_OF_TIME_SEEN=@Count, 
	--			[TIME_STAMP]= GETDATE()
	--		WHERE IATA=@LicensePlate;
	--	END
		
	-- Step 2: Insert GID Used bag event into event table [BAG_HISTORICAL].
		--INSERT INTO [BAG_HISTORICAL] 
		--	(TIME_STAMP, IATA, CARRIER_ID, LOCATION, NO_OF_TIME_SEEN)
		--VALUES 
		--	(GETDATE(), @LicensePlate, @CarrierID, @BMALocation, @Count);

	-- Step 3: Insert Item Lost bag event into event table [BAGGAGE_MEASURE_ARRAY_MSG].
	INSERT INTO [ITEM_MEASURED] 
		([TIME_STAMP], [GID], [LOCATION], [LENGTH], [WIDTH], [HEIGHT], [TYPE] )
	VALUES 
		(GETDATE(), @GID, @BMALocation, @Length, @Width, @Height, @BMAType);
END
GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_CARRIERALLOCINFORMATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_CARRIERALLOCINFORMATION] 
	@NoOfCarrier [varchar](2), 
	@CarrierCode1 [varchar](3),
	@SortDevice1 [varchar](10), 
	@CarrierCode2 [varchar](3),
	@SortDevice2 [varchar](10), 
	@CarrierCode3 [varchar](3),
	@SortDevice3 [varchar](10), 
	@CarrierCode4 [varchar](3),
	@SortDevice4 [varchar](10), 
	@CarrierCode5 [varchar](3),
	@SortDevice5 [varchar](10), 
	@CarrierCode6 [varchar](3),
	@SortDevice6 [varchar](10), 
	@CarrierCode7 [varchar](3),
	@SortDevice7 [varchar](10), 
	@CarrierCode8 [varchar](3),
	@SortDevice8 [varchar](10), 
	@CarrierCode9 [varchar](3),
	@SortDevice9 [varchar](10), 
	@CarrierCode10 [varchar](3),
	@SortDevice10 [varchar](10) 
AS
BEGIN
	-- Step 1: Insert [CARRIER_ALLOC_INFO] bag event into event table [CARRIER_ALLOC_INFO].
	INSERT INTO [LOG_CARRIER_ALLOC_INFO]
			   ([TIME_STAMP], [NO_OF_CARRIER], 
			   [CARRIER_CODE_1], [SORT_DEVICE_1], 
			   [CARRIER_CODE_2], [SORT_DEVICE_2],
			   [CARRIER_CODE_3], [SORT_DEVICE_3], 
			   [CARRIER_CODE_4], [SORT_DEVICE_4], 
			   [CARRIER_CODE_5], [SORT_DEVICE_5], 
			   [CARRIER_CODE_6], [SORT_DEVICE_6], 
			   [CARRIER_CODE_7], [SORT_DEVICE_7], 
			   [CARRIER_CODE_8], [SORT_DEVICE_8], 
			   [CARRIER_CODE_9], [SORT_DEVICE_9], 
			   [CARRIER_CODE_10], [SORT_DEVICE_10])
		 VALUES
			   (GETDATE(),@NoOfCarrier, @CarrierCode1, @SortDevice1, 
			   @CarrierCode2, @SortDevice2, 
			   @CarrierCode3, @SortDevice3, 
			   @CarrierCode4, @SortDevice4, 
			   @CarrierCode5, @SortDevice5, 
			   @CarrierCode6, @SortDevice6, 
			   @CarrierCode7, @SortDevice7, 
			   @CarrierCode8, @SortDevice8, 
			   @CarrierCode9, @SortDevice9, 
			   @CarrierCode10, @SortDevice10);
END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_CHANGEDISCHARGEOFMANUALCLOSEALLOC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stp_SAC_CHANGEDISCHARGEOFMANUALCLOSEALLOC]
	@AirLine varchar(3),
	@FlightNo varchar(5),
	@SDO datetime,
	@OStart datetime,
	@OEnd datetime,
	@OResource varchar(10),
	@NResource varchar(10)
AS
BEGIN
	Set NOCOUNT ON;
	Declare @Now datetime
	Declare @STODT datetime
	Declare @OCloseOffset varchar(5)
	Declare @OOpenOffset varchar(5)
	Declare @NCloseOffset varchar(5)
	Declare @NOpenOffset varchar(5)
	Declare @MyDay int
	Declare @MyHour int
	Declare @MyMinute bigint
	Declare @STO varchar(4)
	Declare @IS_Manual bit
	Declare @Close_Related varchar(4)
	Declare @Close_Do datetime
	Declare @ExcOffset varchar(4)
	Declare @ExistRushDuration varchar(5)
	
	--Default
	Set @OCloseOffset=''
	Set @OOpenOffset=''
	Set @NCloseOffset=''
	Set @NOpenOffset=''
	Set @MyDay=0
	Set @MyHour=0
	Set @MyMinute=0
	Set @STO=''
	Set @IS_Manual=0
	Set @ExistRushDuration = '0010'
		
	Set @Now = DATEADD(ss,-DATEPART(ss,GETDATE()),GETDATE()) --get now

	--Close Related	
	SELECT @Close_Related = ALLOC_CLOSE_RELATED FROM FLIGHT_PLAN_ALLOC 
		WHERE ((AIRLINE = @AirLine) AND (FLIGHT_NUMBER = @FlightNo) AND (SDO = @SDO) AND (RESOURCE = @OResource))
	--STD
	IF(RTRIM(LTRIM(@Close_Related))='STD')
		Begin
			SELECT @Close_Do = SDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=STO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FlightNo) AND (SDO=@SDO) AND (RESOURCE=@OResource))
		End
	--ETD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ETD')
		Begin
			SELECT  @Close_Do=EDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ETO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER = @FlightNo) AND (SDO = @SDO) AND (RESOURCE = @OResource))
		End
	--ITD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ITD')
		Begin
			SELECT  @Close_Do=IDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ITO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FlightNo) AND (SDO=@SDO) AND (RESOURCE=@OResource))
		End
	--ATD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ATD')
		Begin
			SELECT @Close_Do=ADO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ATO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FlightNo) AND (SDO=@SDO) AND (RESOURCE=@OResource))
		End
	--Set STO
	Set @STODT=CONVERT(datetime, CONVERT(nvarchar(30),@Close_Do, 111)+' '+ SUBSTRING(@STO,1,2)+':'+SUBSTRING(@STO,3,2)+':00')

		Set @MyMinute=DATEDIFF(mi,@Now,@OEnd)
		Set @MyHour=@MyMinute / 60
		Set @MyMinute=@MyMinute - (@MyHour * 60)

	--Get New Close Offset
	IF(SUBSTRING(@OCloseOffset,1,1)='-')
		Begin
			Set @NCloseOffset= [dbo].[SAC_HOURMINUTEMASTER](@OCloseOffset,@MyDay,@MyHour,@MyMinute,'+')
			--Update Original One
			UPDATE FLIGHT_PLAN_ALLOC SET [ALLOC_CLOSE_OFFSET]=@NCloseOffset,[IS_CLOSED] = 1,[TIME_STAMP] = GETDATE(),RUSH_DURATION='0000'
			WHERE ((AIRLINE = @AirLine) AND (FLIGHT_NUMBER = @FlightNo) AND (SDO = @SDO) AND (RESOURCE = @OResource	))
		End
	ELSE
		Begin
    		--Special Effect 
				IF(LEN(DATEPART(hh,@Now))=1)
					Begin
						Set @NCloseOffset = '0' + CONVERT(varchar(1), DATEPART(hh,@Now))
					End
				ELSE
					Begin
						Set @NCloseOffset = CONVERT(varchar(2), DATEPART(hh,@Now))
					End
				IF(LEN(DATEPART(mi,@Now))=1)
					Begin
						Set @NCloseOffset = @NCloseOffset+ '0' + CONVERT(varchar(1),DATEPART(mi,@Now))
					End
				ELSE
					Begin
						Set @NCloseOffset = @NCloseOffset+  CONVERT(varchar(2),DATEPART(mi,@Now))
					End
			--Special Effect 
			IF(@Now>=@STODT)
				Begin		

					Set @MyMinute=DATEDIFF(mi,@STODT,@Now)
					Set @MyHour=@MyMinute / 60
					Set @MyMinute=@MyMinute - (@MyHour * 60)
					--Hour
					IF(@MyHour>0)
						Begin
							IF(LEN(@MyHour)=1)
								Begin
									Set @NCloseOffset='0'+CONVERT(varchar(1),@MyHour)
								End			
							ELSE
								Begin
									Set @NCloseOffset=CONVERT(varchar(2),@MyHour)
								End		
						End
					ELSE
						Begin
							Set @NCloseOffset='00'
						End
					--Minute
					IF(@MyMinute>0)
						Begin
							IF(LEN(@MyMinute)=1)
								Begin
									Set @NCloseOffset=@NCloseOffset+ '0'+CONVERT(varchar(1),@MyMinute)
								End			
							ELSE
								Begin
									Set @NCloseOffset=@NCloseOffset+CONVERT(varchar(2),@MyMinute)
								End		
						End
					ELSE
						Begin
							Set @NCloseOffset=@NCloseOffset+'00'
						End

					UPDATE FLIGHT_PLAN_ALLOC Set [ALLOC_CLOSE_OFFSET] = @NCloseOffset, [IS_CLOSED] = 1,[TIME_STAMP] = GETDATE(),RUSH_DURATION='0000'
					WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FlightNo) AND (SDO=@SDO) AND (RESOURCE=@OResource))
				End
			ELSE
				Begin
					Set @NCloseOffset ='-'+ [dbo].[SAC_HOURMINUTEDIFF](@STO,@NCloseOffset) --Error have to consider +/- matter(only working - matter)
					UPDATE FLIGHT_PLAN_ALLOC Set [ALLOC_CLOSE_OFFSET] = @NCloseOffset,[IS_CLOSED] = 1,[TIME_STAMP] = GETDATE(),RUSH_DURATION='0000'
					WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FlightNo) AND (SDO=@SDO) AND (RESOURCE = @OResource))
				End
		End
	Set @NOpenOffset= @NCloseOffset
	--Insert new one at new allocation
	INSERT INTO dbo.FLIGHT_PLAN_ALLOC(AIRLINE,FLIGHT_NUMBER,SDO,STO,RESOURCE,WEEKDAY,EDO,ETO,ADO,ATO,IDO,ITO,
									  TRAVEL_CLASS,HIGH_RISK,HBS_LEVEL_REQUIRED,EARLY_OPEN_OFFSET,EARLY_OPEN_ENABLED,
									  ALLOC_OPEN_OFFSET,ALLOC_OPEN_RELATED,ALLOC_CLOSE_OFFSET,ALLOC_CLOSE_RELATED,
									  RUSH_DURATION,SCHEME_TYPE,CREATED_BY,TIME_STAMP,HOUR,IS_MANUAL_CLOSE,IS_CLOSED)
		SELECT AIRLINE,FLIGHT_NUMBER,SDO,STO,@NResource,WEEKDAY,EDO,ETO,ADO,ATO,IDO,ITO,
			   TRAVEL_CLASS,HIGH_RISK,HBS_LEVEL_REQUIRED,EARLY_OPEN_OFFSet,EARLY_OPEN_ENABLED,
			   @NOpenOffset,@Close_Related,@OCloseOffset,ALLOC_CLOSE_RELATED,
			   @ExistRushDuration,SCHEME_TYPE,CREATED_BY,GETDATE(),HOUR,1,0
		FROM dbo.FLIGHT_PLAN_ALLOC WHERE ((AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FlightNo)
			 AND (SDO=@SDO) AND (RESOURCE=@OResource))
	--Delete , if Open_offset=Closeoffset in a same location.
	DELETE FROM FLIGHT_PLAN_ALLOC WHERE ((ALLOC_OPEN_OFFSET = ALLOC_CLOSE_OFFSET) AND 
	(AIRLINE=@AirLine) AND (FLIGHT_NUMBER=@FlightNo) AND (SDO=@SDO) AND (RESOURCE=@OResource))
End




GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_CHANGEDISCHARGEOFOPENALLOC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_CHANGEDISCHARGEOFOPENALLOC]
	@AirLine varchar(3),
	@FlightNo varchar(5),
	@SDO datetime,
	@OStart datetime,
	@OEnd datetime,
	@OResource varchar(10),
	@NResource varchar(10)
AS
BEGIN
	Set NOCOUNT ON;
	Declare @Now datetime
	Declare @STODT datetime
	Declare @OCloseOffset varchar(5)
	Declare @OOpenOffset varchar(5)
	Declare @NCloseOffset varchar(5)
	Declare @NOpenOffset varchar(5)
	Declare @MyDay int
	Declare @MyHour int
	Declare @MyMinute bigint
	Declare @STO varchar(4)
	Declare @IS_Manual bit
	Declare @Close_Related varchar(4)
	Declare @Close_Do datetime
	Declare @ExcOffset varchar(4)
	Declare @ExistRushDuration varchar(5)
	
	--Default
	Set @OCloseOffset=''
	Set @OOpenOffset=''
	Set @NCloseOffset=''
	Set @NOpenOffset=''
	Set @MyDay=0
	Set @MyHour=0
	Set @MyMinute=0
	Set @STO=''
	Set @IS_Manual=0
	Set @ExistRushDuration = '0010'
	
	Set @Now=DATEADD(ss,-DATEPART(ss,GETDATE()),GETDATE()) --get now

	--Close Related	
	SELECT @Close_Related=ALLOC_CLOSE_RELATED FROM FLIGHT_PLAN_ALLOC 
		WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
	--STD
	IF(RTRIM(LTRIM(@Close_Related))='STD')
		Begin
			SELECT @Close_Do=SDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=STO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--ETD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ETD')
		Begin
			SELECT  @Close_Do=EDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ETO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--ITD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ITD')
		Begin
			SELECT  @Close_Do=IDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ITO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--ATD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ATD')
		Begin
			SELECT @Close_Do=ADO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ATO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--Set STO
	Set @STODT=CONVERT(datetime, CONVERT(nvarchar(30),@Close_Do, 111)+' '+ SUBSTRING(@STO,1,2)+':'+SUBSTRING(@STO,3,2)+':00')

		Set @MyMinute=DATEDIFF(mi,@Now,@OEnd)
		Set @MyHour=@MyMinute / 60
		Set @MyMinute=@MyMinute - (@MyHour * 60)
		
	--Get Rush Duration
	SELECT @ExistRushDuration = RUSH_DURATION FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource;

	--Get New Close Offset
	IF(SUBSTRING(@OCloseOffset,1,1)='-')
		Begin
			Set @NCloseOffset= [dbo].[SAC_HOURMINUTEMASTER](@OCloseOffset,@MyDay,@MyHour,@MyMinute,'+')
			--Update Original One
			UPDATE FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSET=@NCloseOffset,TIME_STAMP=GETDATE(),RUSH_DURATION='0000'
			WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource	
		End
	ELSE
		Begin
			Print 'Reached to closed time ++ changed status'
			--To do code here update statement for original one	
			--Special Effect 
				IF(LEN(DATEPART(hh,@Now))=1)
					Begin
						Set @NCloseOffset = '0' + CONVERT(varchar(1), DATEPART(hh,@Now))
					End
				ELSE
					Begin
						Set @NCloseOffset = CONVERT(varchar(2), DATEPART(hh,@Now))
					End
				IF(LEN(DATEPART(mi,@Now))=1)
					Begin
						Set @NCloseOffset =@NCloseOffset+ '0' + CONVERT(varchar(1),DATEPART(mi,@Now))
					End
				ELSE
					Begin
						Set @NCloseOffset =@NCloseOffset+  CONVERT(varchar(2),DATEPART(mi,@Now))
					End
			--Special Effect 
			IF(@Now>=@STODT)
				Begin		

					Set @MyMinute=DATEDIFF(mi,@STODT,@Now)
					Set @MyHour=@MyMinute / 60
					Set @MyMinute=@MyMinute - (@MyHour * 60)
					--Hour
					IF(@MyHour>0)
						Begin
							IF(LEN(@MyHour)=1)
								Begin
									Set @NCloseOffset='0'+CONVERT(varchar(1),@MyHour)
								End			
							ELSE
								Begin
									Set @NCloseOffset=CONVERT(varchar(2),@MyHour)
								End		
						End
					ELSE
						Begin
							Set @NCloseOffset='00'
						End
					--Minute
					IF(@MyMinute>0)
						Begin
							IF(LEN(@MyMinute)=1)
								Begin
									Set @NCloseOffset=@NCloseOffset+ '0'+CONVERT(varchar(1),@MyMinute)
								End			
							ELSE
								Begin
									Set @NCloseOffset=@NCloseOffset+CONVERT(varchar(2),@MyMinute)
								End		
						End
					ELSE
						Begin
							Set @NCloseOffset=@NCloseOffset+'00'
						End

					-- Set @NCloseOffset =''0''+CONVERT(varchar(2),@MyHour)+CONVERT(varchar(2),@MyMinute) --Max -9959
					UPDATE FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSET=@NCloseOffset,TIME_STAMP=GETDATE(),RUSH_DURATION='0000'
					WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource	
					--print @MyHour
				End
			ELSE
				Begin
					Set @NCloseOffset ='-'+ [dbo].[SAC_HOURMINUTEDIFF](@STO,@NCloseOffset) --Error have to consider +/- matter(only working - matter)
					UPDATE FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSET=@NCloseOffset,TIME_STAMP=GETDATE(),RUSH_DURATION='0000'
					WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource	
				End
		End

	Set @NOpenOffset= @NCloseOffset
	
	--Insert new one at new allocation
	INSERT INTO dbo.FLIGHT_PLAN_ALLOC
		(AIRLINE,FLIGHT_NUMBER,SDO,STO,RESOURCE,WEEKDAY,EDO,ETO,ADO,ATO,IDO,ITO,
		TRAVEL_CLASS,HIGH_RISK,HBS_LEVEL_REQUIRED,EARLY_OPEN_OFFSET,EARLY_OPEN_ENABLED,
		ALLOC_OPEN_OFFSET,ALLOC_OPEN_RELATED,ALLOC_CLOSE_OFFSET,ALLOC_CLOSE_RELATED,
		RUSH_DURATION,SCHEME_TYPE,CREATED_BY,TIME_STAMP,HOUR,IS_MANUAL_CLOSE,IS_CLOSED)
		SELECT AIRLINE,FLIGHT_NUMBER,SDO,STO,@NResource,WEEKDAY,EDO,ETO,ADO,ATO,IDO,ITO,
			TRAVEL_CLASS,HIGH_RISK,HBS_LEVEL_REQUIRED,EARLY_OPEN_OFFSet,EARLY_OPEN_ENABLED,
			@NOpenOffset,@Close_Related,@OCloseOffset,ALLOC_CLOSE_RELATED,
			@ExistRushDuration,SCHEME_TYPE,CREATED_BY,GETDATE(),HOUR,@IS_Manual,IS_CLOSED
		FROM dbo.FLIGHT_PLAN_ALLOC
		WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
	--Delete , if Open_offset=Closeoffset in a same location.
	DELETE FROM FLIGHT_PLAN_ALLOC WHERE ALLOC_OPEN_OFFSET=ALLOC_CLOSE_OFFSET AND 
	AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
End


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_CHECKMUAVAILABILITY]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_CHECKMUAVAILABILITY] 
	@DESTINATION CHAR(4),
	@DEST_DESCR VARCHAR(10),
	@LOCATION CHAR(4),
	@ORGREASON VARCHAR(2),
	@ORGREASON_DESCR VARCHAR(100),
	@RETVAL VARCHAR(4) OUTPUT,
	@REASON VARCHAR(2) OUTPUT,
	@RETVAL_DESCR VARCHAR(10) OUTPUT,
	@REASON_DESCR VARCHAR(100) OUTPUT 
AS
DECLARE
    @RESOURCE VARCHAR(10),
    @SUBSYSTEM VARCHAR(10),
    @LOCATION_NAME VARCHAR(20),
    @COUNT INT,
    @COUNT2 INT,
    @RECIRCULATE BIT
BEGIN
    SET @RETVAL = ''
    
    SELECT @RESOURCE = DESTINATION FROM DESTINATIONS WHERE LOCATION_ID = @DESTINATION 
    SELECT @SUBSYSTEM = SUBSYSTEM, @LOCATION_NAME = LOCATION FROM LOCATIONS WHERE LOCATION_ID = @LOCATION 
    
    -- STEP 1 : IF BAG'S CURRENT LOCATION IS AT MANUAL ENCODING STATION. 
    --          MAP IT TO THE NEAREST MAIN LINE IN ORDER TO CHECK AVAILABILITY OF IT'S ASSIGNED DESTINATION
    IF @SUBSYSTEM = 'ME1'
       BEGIN 
          SET @SUBSYSTEM = 'ML1' 
       END
    ELSE IF @SUBSYSTEM = 'ME2'
       BEGIN 
          SET @SUBSYSTEM = 'ML2'
       END 
    ELSE IF @SUBSYSTEM = 'ME3'
       BEGIN 
          SET @SUBSYSTEM = 'ML4' 
       END
        
    -- STEP 2 : CHECK DESTINATION AVAILABILITY EXCEPT MES. THIS IS BECAUSE AS LONG IT IS UNKNOWN / ERROR BAG IT WILL STILL GO TO MES, NO OTHER WAYS IT CAN PROCEED TO.
    IF (@RESOURCE != 'MES')
		BEGIN
		    
		    -- CHECK WHETHER IS BAG NOT ABLE DIVERT TO THE DESTINATION AT DIVERSION POINT.
		    IF EXISTS(SELECT * FROM DESTINATION_CHUTE_MAPPING WHERE LOCATION_ID = @LOCATION)
		       BEGIN
		            SELECT @SUBSYSTEM=SUBSYSTEM,@LOCATION_NAME=LOCATIONS,@RECIRCULATE=RECIRCULATE FROM DESTINATION_CHUTE_MAPPING WHERE LOCATION_ID = @LOCATION
		            
					-- CHECK MU AVAILABILITY 
					SELECT @COUNT = COUNT(*) FROM DESTINATION_CHUTE_MAPPING A INNER JOIN DESTINATIONS B ON (A.DESTINATION = B.DESTINATION)
					WHERE A.DESTINATION = @RESOURCE AND 
						  A.SUBSYSTEM IN (SELECT PATH FROM DESTINATION_PATH_MAPPING WHERE SUBSYSTEM = @SUBSYSTEM) AND 
						 (SELECT COUNT(STATUS) FROM DESTINATION_CHUTE_MAPPING   
						  WHERE DESTINATION = @RESOURCE AND SUBSYSTEM = A.SUBSYSTEM AND [STATUS] = '2') = 0 AND
						  B.IS_AVAILABLE = 1
					
					-- CHECK ABILITY TO RECIRCULATE TO THE SAME DESTINATION THROUGH THE NEXT DIVERSION POINT OR ATR
					IF @RECIRCULATE = 0
					   BEGIN
					       SET @COUNT = 0 
					   END
		       END
		    ELSE 
		       BEGIN
		            -- CHECK MU AVAILABILITY
					SELECT @COUNT = COUNT(*) FROM DESTINATION_CHUTE_MAPPING A INNER JOIN DESTINATIONS B ON (A.DESTINATION = B.DESTINATION)
					WHERE A.DESTINATION = @RESOURCE AND 
						  A.SUBSYSTEM IN (SELECT PATH FROM DESTINATION_PATH_MAPPING WHERE SUBSYSTEM = @SUBSYSTEM) AND 
						 (SELECT COUNT(STATUS) FROM DESTINATION_CHUTE_MAPPING   
						  WHERE DESTINATION = @RESOURCE AND SUBSYSTEM = A.SUBSYSTEM AND [STATUS] = '2') = 0 AND
						  B.IS_AVAILABLE = 1
		       END   
		           
			-- IF DESTINATION IS AVAILABLE, RETURN THE ASSIGNED DESTINATION
			IF (@COUNT > 0)
			   BEGIN
			      SET @REASON = @ORGREASON
				  SET @REASON_DESCR = @ORGREASON_DESCR 
				  SET @RETVAL = @DESTINATION
				  SET @RETVAL_DESCR = @DEST_DESCR  
		          
				  RETURN 0 
			   END 
			ELSE -- ELSE RETURN DUMP DISCHARGE DESTINATION
			   BEGIN 
			      SET @REASON = '15'
			      
				  SELECT @RETVAL = LOCATION_ID, @RETVAL_DESCR = B.DESTINATION, @REASON_DESCR = (SELECT SR.DESCRIPTION FROM SORTATION_REASON SR WHERE SR.REASON = @REASON)  
				  FROM FUNCTION_ALLOC_LIST A INNER JOIN DESTINATIONS B ON (A.[RESOURCE] = B.DESTINATION) 
				  WHERE FUNCTION_TYPE = 'DUMP' AND IS_ENABLED = 1
		          
				  RETURN 0
			   END   
		END
	ELSE 
	    BEGIN
	        SET @REASON = @ORGREASON 
	        SET @REASON_DESCR = @ORGREASON_DESCR
			SET @RETVAL = @DESTINATION
			SET @RETVAL_DESCR = @DEST_DESCR

	        
	        RETURN 0
	    END	   
END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_CHECKTAGDEST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_CHECKTAGDEST]
    @TAG_TYPE CHAR(1), 
	@LICENSE_PLATE1 VARCHAR(10),
	@LICENSE_PLATE2 VARCHAR(10),
	@RETVAL VARCHAR(10) OUTPUT
AS
DECLARE 
    @COUNT INT,
	@COUNT_BSM INT,
	@FALLBACK_AIRPORTLOC1 VARCHAR(4),
	@FALLBACK_AIRPORTLOC2 VARCHAR(4),
	@FALLBACK_CARRIERCODE1 VARCHAR(4),
	@FALLBACK_CARRIERCODE2 VARCHAR(4),
	@FALLBACK_NO1 VARCHAR(2),
	@FALLBACK_NO2 VARCHAR(2),
	@AIRPORT_LOC_CODE VARCHAR(10)
BEGIN
    /** @TAG_TYPE (1,2,3) **/  
	/** 1 - FALLBACK TAG **/
	/** 2 - 4 DIGITS SORTATION TAG **/
	/** 3 - NORMAL IATA TAG **/

    SET @RETVAL = ''
    
	IF @TAG_TYPE = '1'
	   BEGIN
	      SET @FALLBACK_AIRPORTLOC1 = RIGHT(LEFT(@LICENSE_PLATE1,8),4) 
		  SET @FALLBACK_CARRIERCODE1 = RIGHT(LEFT(@LICENSE_PLATE1,4),3)
		  SET @FALLBACK_NO1 = RIGHT(@LICENSE_PLATE1,2)
		  SET @FALLBACK_AIRPORTLOC2 = RIGHT(LEFT(@LICENSE_PLATE2,8),4) 
		  SET @FALLBACK_CARRIERCODE2 = RIGHT(LEFT(@LICENSE_PLATE2,4),3)
		  SET @FALLBACK_NO2 = RIGHT(@LICENSE_PLATE2,2)
          
		  SELECT @AIRPORT_LOC_CODE = SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY = 'AIRPORT_LOCATION_CODE'
		  
		  /** CONDITION TO CHECK VALIDITY OF FALLBACK TAG :
		      1 : MAKE SURE BOTH FALLBACK TAG ARE DEDICATED FOR THE SAME AIRLINE
			  2 : MAKE SURE AIRLINE TICKETING CODE IS EXIST IN DATABASE
			  3 : MAKE SURE EITHER 1 FALLBACK TAG IS VALID BY CHECKING ON THE FALLBACK TAG AIRPORT LOCATION
			  4 : MAKE SURE BOTH FALLBACK NO IS HEADING TO THE SAME DESTINATION (MU) **/
		  IF @FALLBACK_CARRIERCODE1 = @FALLBACK_CARRIERCODE2 AND (@FALLBACK_AIRPORTLOC1 = @AIRPORT_LOC_CODE OR @FALLBACK_AIRPORTLOC2 = @AIRPORT_LOC_CODE)  
		     BEGIN  
			       /** TO CHECK AIRLINE CODE IS VALID **/
			       IF EXISTS(SELECT TICKETING_CODE FROM AIRLINES WHERE TICKETING_CODE = @FALLBACK_CARRIERCODE1)
				      BEGIN 
			              /** RETURN EITHER 1 OF THE FALLBACK TAG FOR SORTATION PURPOSE, IF EITHER 1 IS VALID, RETURN VALID FALLBACK TAG FOR SORTATION **/
			              IF  (@FALLBACK_AIRPORTLOC1 = @AIRPORT_LOC_CODE) 
				              BEGIN
						          SET @LICENSE_PLATE1 = @LICENSE_PLATE1   
					 	  END

                          IF  (@FALLBACK_AIRPORTLOC2 = @AIRPORT_LOC_CODE) 
				              BEGIN
						          SET @LICENSE_PLATE1 = @LICENSE_PLATE2   
					 	      END 
		
	                      /** TO CHECK BOTH FALLBACK NO RETURNING THE SAME DESTINATION. (1 = SAME DESTINATION , > 1 = DIFFERENT DESTINATION) **/
				          SELECT @COUNT = COUNT(DISTINCT DESTINATION) FROM FALLBACK_MAPPING WHERE ID IN (@FALLBACK_NO1,@FALLBACK_NO2)
                      END
				    ELSE 
					  BEGIN
					      SET @COUNT = 0
					  END	   
             END 
		  ELSE 
		     BEGIN
			    SET @COUNT = 0   
			 END	    

	   END 
    ELSE IF @TAG_TYPE = '2' 
	   BEGIN 
          SELECT @COUNT = COUNT(DISTINCT DESTINATION) FROM FOUR_DIGITS_FALLBACK_MAPPING WHERE ID IN (@LICENSE_PLATE1, @LICENSE_PLATE2)      
	   END
	ELSE IF @TAG_TYPE = '3' 
	   BEGIN
	      -- TO CHECK AVAILABILITY OF BSM
	      SELECT @COUNT_BSM = COUNT(*) FROM BAG_SORTING WHERE LICENSE_PLATE IN (@LICENSE_PLATE1, @LICENSE_PLATE2)
	      
		  -- IF COUNT >= 2, THATS MEAN THIS 2 LICENSE PLATE ALREADY HAVE BSM     
		  IF @COUNT_BSM >= 2
		     BEGIN  
			   SELECT @COUNT = COUNT(*) 
		       FROM (SELECT DISTINCT AIRLINE, FLIGHT_NUMBER, SDO
                     FROM BAG_SORTING
                     WHERE LICENSE_PLATE IN (@LICENSE_PLATE1, @LICENSE_PLATE2)) RESULTS
			 END
	      -- COUNT = 1, ONLY 1 LICENSE PLATE WITH BSM. SHOULD SEND THE BAG TO MES FOR MANUAL ENCODE. THIS IS BECAUSE SAC UNABLE TO IDENTIFY WHICH TO BE USED FOR SORTING.  
          ELSE IF @COUNT_BSM = 1
		     BEGIN
			   
			     SET @COUNT = 2
			 END 
          -- COUNT = 0, THATS MEAN BOTH LICENSE PLATE GOT NO BSM. SORT BY CARRIER CODE
	      ELSE IF @COUNT_BSM = 0
		     BEGIN 
			    --IF RIGHT(LEFT(@LICENSE_PLATE1,4),3) = RIGHT(LEFT(@LICENSE_PLATE2,4),3)
				   --BEGIN 
				   --   SET @COUNT = 1
				   --END
       --         ELSE 
				  --BEGIN
				  SET @COUNT = 2 
				  --END
			 END    		 		         
	   END 
    
    IF @COUNT = 1
	  BEGIN 
	     SET @RETVAL = @LICENSE_PLATE1    
	  END
    ELSE IF @COUNT != 1
	  BEGIN   
	     SET @RETVAL = '' 
	  END
	
	SELECT @RETVAL AS RET_VAL   	 	   
END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_COLLECTCHANGEDCRAI]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_COLLECTCHANGEDCRAI] 
AS
BEGIN
	DECLARE @temptable TABLE ([CODE] VARCHAR(3), [SORT_DESTINATION] VARCHAR(10), [SORT_DESTINATION_DESC] VARCHAR(10));
     
    INSERT INTO @temptable 
        SELECT TICKETING_CODE, B.LOCATION_ID ,B.DESTINATION FROM AIRLINES A, DESTINATIONS B
        WHERE A.DESTINATION = B.DESTINATION AND A.IS_CHANGED = 1;
    
    SELECT [CODE],[SORT_DESTINATION],[SORT_DESTINATION_DESC] FROM @temptable
        
    UPDATE AIRLINES SET IS_CHANGED = 0 WHERE IS_CHANGED = 1 AND TICKETING_CODE IN (SELECT CODE FROM @temptable)
    
    UPDATE [CHANGE_MONITORING] SET [IS_CHANGED] = 0 WHERE [STATE_CODE] = 'TB_AIRLINES';
END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_COLLECTCHANGEDFBTI]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_COLLECTCHANGEDFBTI] 
AS
BEGIN
	DECLARE @temptable TABLE ([ID] VARCHAR(2), [DESTINATION] VARCHAR(10), [DESTINATION_DESC] VARCHAR(10));
	
	INSERT INTO @temptable 
		SELECT A.ID, B.LOCATION_ID, A.DESTINATION FROM [FALLBACK_MAPPING] A,[DESTINATIONS] B WHERE A.DESTINATION = B.DESTINATION AND [IS_CHANGED] = 1;
		
	UPDATE [FALLBACK_MAPPING] SET [IS_CHANGED] = 0 WHERE [IS_CHANGED] = 1 AND [ID] IN (SELECT [ID] FROM @temptable);

	UPDATE [CHANGE_MONITORING] SET [IS_CHANGED] = 0 WHERE [STATE_CODE] = 'TB_FALLBACK_MAPPING';
	
	SELECT [ID], [DESTINATION], [DESTINATION_DESC] FROM @temptable ORDER BY ID;
END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_COLLECTCHANGEDFPTI]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_COLLECTCHANGEDFPTI] 
AS
BEGIN
	DECLARE @temptable TABLE ([ID] VARCHAR(4), [DESTINATION] VARCHAR(10), [DESTINATION_DESC] VARCHAR(10));
	
	INSERT INTO @temptable 
		SELECT A.ID, B.LOCATION_ID,A.DESTINATION FROM [FOUR_DIGITS_FALLBACK_MAPPING] A, [DESTINATIONS] B WHERE A.DESTINATION = B.DESTINATION AND [IS_CHANGED] = 1;
		
	UPDATE [FOUR_DIGITS_FALLBACK_MAPPING] SET [IS_CHANGED] = 0 WHERE [IS_CHANGED] = 1 AND [ID] IN (SELECT [ID] FROM @temptable);
	
	UPDATE [CHANGE_MONITORING] SET [IS_CHANGED] = 0 WHERE [STATE_CODE] = 'TB_FOUR_DIGITS_MAPPING';

	SELECT [ID], [DESTINATION], [DESTINATION_DESC] FROM @temptable ORDER BY ID;
END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_COLLECTCHANGEDTABLES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_COLLECTCHANGEDTABLES] 
AS
BEGIN
	DECLARE  @TEMP TABLE (STATE_CODE VARCHAR(30));
	
	INSERT INTO @TEMP 
		SELECT [STATE_CODE] FROM [CHANGE_MONITORING] WHERE SAC_OWS = 'CR-MDSOWS1' AND IS_CHANGED = 1;
	
	UPDATE [CHANGE_MONITORING] SET IS_CHANGED = 0 WHERE SAC_OWS = 'CR-MDSOWS1' AND IS_CHANGED = 1 
		AND STATE_CODE IN (SELECT [STATE_CODE] FROM @TEMP);
		
	SELECT [STATE_CODE] FROM @TEMP;	
END
GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_COLLECTENTIREAFAI]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_COLLECTENTIREAFAI] 
	@AirportDesc [varchar] (30),
	@DumpDischargeDesc [varchar] (4),
	@NoAllocDesc [varchar](4), 
	@NoCarrierDesc [varchar](4),
	@NoReadDesc [varchar](4),
	@Airport [varchar](4) OUTPUT, 
	@DumpDischarge [varchar](10) OUTPUT,
	@NoAlloc [varchar](10) OUTPUT, 
	@NoCarrier [varchar](10) OUTPUT,
	@NoRead [varchar](10) OUTPUT,
	@DumpDischargeDest [varchar](10) OUTPUT,
	@NoAllocDest [varchar](10) OUTPUT,
	@NoCarrierDest [varchar](10) OUTPUT,
	@NoReadDest [varchar](10) OUTPUT
AS
BEGIN
	SELECT @Airport=SYS_VALUE FROM dbo.SYS_CONFIG WHERE SYS_KEY = @AirportDesc;
	UPDATE [SYS_CONFIG] SET [IS_CHANGED] = 0 WHERE SYS_KEY = @AirportDesc AND [IS_CHANGED] = 1;
	UPDATE [CHANGE_MONITORING] SET [IS_CHANGED] = 0 WHERE [STATE_CODE] = 'TB_SYS_CONFIG';

	SELECT @DumpDischarge= B.LOCATION_ID,@DumpDischargeDest = B.DESTINATION FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.RESOURCE = B.DESTINATION AND A.FUNCTION_TYPE = @DumpDischargeDesc;
	SELECT @NoAlloc=B.LOCATION_ID, @NoAllocDest = B.DESTINATION FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.[RESOURCE] = B.DESTINATION AND FUNCTION_TYPE = @NoAllocDesc;
	SELECT @NoCarrier=B.LOCATION_ID, @NoCarrierDest = B.DESTINATION FROM dbo.FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.[RESOURCE] = B.DESTINATION AND FUNCTION_TYPE = @NoCarrierDesc;
	SELECT @NoRead=B.LOCATION_ID, @NoReadDest = B.DESTINATION FROM dbo.FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.[RESOURCE]=B.DESTINATION AND FUNCTION_TYPE = @NoReadDesc;
	
	UPDATE [FUNCTION_ALLOC_LIST] SET [IS_CHANGED] = 0 WHERE FUNCTION_TYPE IN 
			(@DumpDischargeDesc, @NoAllocDesc, @NoCarrierDesc, @NoReadDesc) AND [IS_CHANGED] = 1;
			
	UPDATE [CHANGE_MONITORING] SET [IS_CHANGED] = 0 WHERE [STATE_CODE] = 'TB_FUNCTION_ALLOC_LIST';		
END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_COLLECTENTIRECRAI]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_COLLECTENTIRECRAI] 
AS
BEGIN
	DECLARE @temptable TABLE ([CODE] VARCHAR(3), [SORT_DESTINATION] VARCHAR(10), [SORT_DESTINATION_DESC] VARCHAR(10));
     
    INSERT INTO @temptable 
        SELECT TICKETING_CODE, B.LOCATION_ID, B.DESTINATION FROM AIRLINES A, DESTINATIONS B
        WHERE A.DESTINATION = B.DESTINATION AND A.DESTINATION IS NOT NULL AND RTRIM(LTRIM(A.DESTINATION)) != '';
    
    INSERT INTO @temptable 
        SELECT TICKETING_CODE, B.LOCATION_ID, B.DESTINATION FROM AIRLINES A, DESTINATIONS B
        WHERE (A.DESTINATION IS NULL AND IS_CHANGED=1) OR (RTRIM(LTRIM(A.DESTINATION))='' AND IS_CHANGED=1);
    
    SELECT [CODE],[SORT_DESTINATION],[SORT_DESTINATION_DESC] FROM @temptable
        
    UPDATE AIRLINES SET IS_CHANGED = 0 WHERE IS_CHANGED = 1 AND TICKETING_CODE IN (SELECT CODE FROM @temptable)
    
    UPDATE [CHANGE_MONITORING] SET [IS_CHANGED] = 0 WHERE [STATE_CODE] = 'TB_AIRLINES';
END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_COLLECTENTIREFBTI]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_COLLECTENTIREFBTI] 
AS
BEGIN
	DECLARE @temptable TABLE ([ID] VARCHAR(4), [DESTINATION] VARCHAR(10),[DESTINATION_DESC] VARCHAR(10));
	
	INSERT INTO @temptable 
		SELECT A.ID, B.LOCATION_ID, A.DESTINATION FROM [FALLBACK_MAPPING] A, DESTINATIONS B 
			WHERE A.DESTINATION = B.DESTINATION AND A.DESTINATION IS NOT NULL AND RTRIM(LTRIM(A.DESTINATION))!='' ;
	
	INSERT INTO @temptable 	
		SELECT A.ID, B.LOCATION_ID, A.DESTINATION FROM [FALLBACK_MAPPING] A, DESTINATIONS B 
			WHERE A.DESTINATION = B.DESTINATION AND (A.DESTINATION IS NULL AND IS_CHANGED=1) OR (RTRIM(LTRIM(A.DESTINATION))='' AND IS_CHANGED=1);
			
	SELECT [ID], [DESTINATION], [DESTINATION_DESC] FROM @temptable ORDER BY ID;		
	UPDATE [FALLBACK_MAPPING] SET [IS_CHANGED] = 0 WHERE [ID] IN (SELECT [ID] FROM @temptable);
	UPDATE [CHANGE_MONITORING] SET [IS_CHANGED] = 0 WHERE [STATE_CODE] = 'TB_FALLBACK_MAPPING';	
END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_COLLECTENTIREFPTI]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_COLLECTENTIREFPTI] 
AS
BEGIN
	DECLARE @temptable TABLE ([ID] VARCHAR(4), [DESTINATION] VARCHAR(10), [DESTINATION_DESC] VARCHAR(10));
	
	INSERT INTO @temptable 
		SELECT [ID], B.LOCATION_ID, A.DESTINATION FROM [FOUR_DIGITS_FALLBACK_MAPPING] A, DESTINATIONS B 
			WHERE A.DESTINATION = B.DESTINATION AND A.DESTINATION IS NOT NULL AND RTRIM(LTRIM(A.DESTINATION))!='';
	
	INSERT INTO @temptable 	
		SELECT [ID], B.LOCATION_ID, A.DESTINATION FROM [FOUR_DIGITS_FALLBACK_MAPPING] A, DESTINATIONS B
			WHERE A.DESTINATION = B.DESTINATION AND ((A.DESTINATION is NULL  AND IS_CHANGED=1) OR (RTRIM(LTRIM(A.DESTINATION))='' AND IS_CHANGED=1));
	
	SELECT [ID], [DESTINATION], [DESTINATION_DESC] FROM @temptable ORDER BY ID;		
	UPDATE [FOUR_DIGITS_FALLBACK_MAPPING] SET [IS_CHANGED] = 0;
	UPDATE [CHANGE_MONITORING] SET [IS_CHANGED] = 0 WHERE [STATE_CODE] = 'TB_FOUR_DIGITS_FALLBACK_MAPPING';	

END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_CREATEMAKEUPGLOBALTABLE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_CREATEMAKEUPGLOBALTABLE]
	@TimeFrame float(8)
AS
BEGIN
	SET NOCOUNT ON;
	
	--15 Minutes
	IF(@TimeFrame = 15)
		Begin
				--Clear Temp Table
				IF EXISTS (SELECT NAME FROM tempdb..sysobjects WHERE NAME LIKE '##MakeupCapacity15%')
					BEGIN
						DROP TABLE ##MakeupCapacity15;
					END
				--Create Temp Table		
				CREATE TABLE ##MakeupCapacity15([Time1] float(8),[Time2] float(8),[Time3] float(8),[Time4] float(8),[Time5] float(8),
											  [Time6] float(8),[Time7] float(8),[Time8] float(8),[Time9] float(8),[Time10] float(8),
											  [Time11] float(8),[Time12] float(8),[Time13] float(8),[Time14] float(8),[Time15] float(8),
											  [Time16] float(8),[Time17] float(8),[Time18] float(8),[Time19] float(8),[Time20] float(8),
											  [Time21] float(8),[Time22] float(8),[Time23] float(8),[Time24] float(8),[Time25] float(8),
											  [Time26] float(8),[Time27] float(8),[Time28] float(8),[Time29] float(8),[Time30] float(8),
											  [Time31] float(8),[Time32] float(8),[Time33] float(8),[Time34] float(8),[Time35] float(8),
											  [Time36] float(8),[Time37] float(8),[Time38] float(8),[Time39] float(8),[Time40] float(8),
											  [Time41] float(8),[Time42] float(8),[Time43] float(8),[Time44] float(8),[Time45] float(8),
											  [Time46] float(8),[Time47] float(8),[Time48] float(8),[Time49] float(8),[Time50] float(8),
											  [Time51] float(8),[Time52] float(8),[Time53] float(8),[Time54] float(8),[Time55] float(8),
											  [Time56] float(8),[Time57] float(8),[Time58] float(8),[Time59] float(8),[Time60] float(8),
											  [Time61] float(8),[Time62] float(8),[Time63] float(8),[Time64] float(8),[Time65] float(8),
											  [Time66] float(8),[Time67] float(8),[Time68] float(8),[Time69] float(8),[Time70] float(8),
											  [Time71] float(8),[Time72] float(8),[Time73] float(8),[Time74] float(8),[Time75] float(8),
											  [Time76] float(8),[Time77] float(8),[Time78] float(8),[Time79] float(8),[Time80] float(8),
											  [Time81] float(8),[Time82] float(8),[Time83] float(8),[Time84] float(8),[Time85] float(8),
											  [Time86] float(8),[Time87] float(8),[Time88] float(8),[Time89] float(8),[Time90] float(8),
											  [Time91] float(8),[Time92] float(8),[Time93] float(8),[Time94] float(8),[Time95] float(8),
											  [Time96] float(8));
									
				INSERT INTO ##MakeupCapacity15 VALUES(0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0);
		End
		
	--30 Minutes
	ELSE IF(@TimeFrame = 30)
		Begin
				--Clear Temp Table
				IF EXISTS (SELECT NAME FROM tempdb..sysobjects WHERE NAME LIKE '##MakeupCapacity30%')
					BEGIN
						DROP TABLE ##MakeupCapacity30;
					END
				--Create Temp Table		
				CREATE TABLE ##MakeupCapacity30([Time1] float(8),[Time2] float(8),[Time3] float(8),[Time4] float(8),[Time5] float(8),
											  [Time6] float(8),[Time7] float(8),[Time8] float(8),[Time9] float(8),[Time10] float(8),
											  [Time11] float(8),[Time12] float(8),[Time13] float(8),[Time14] float(8),[Time15] float(8),
											  [Time16] float(8),[Time17] float(8),[Time18] float(8),[Time19] float(8),[Time20] float(8),
											  [Time21] float(8),[Time22] float(8),[Time23] float(8),[Time24] float(8),[Time25] float(8),
											  [Time26] float(8),[Time27] float(8),[Time28] float(8),[Time29] float(8),[Time30] float(8),
											  [Time31] float(8),[Time32] float(8),[Time33] float(8),[Time34] float(8),[Time35] float(8),
											  [Time36] float(8),[Time37] float(8),[Time38] float(8),[Time39] float(8),[Time40] float(8),
											  [Time41] float(8),[Time42] float(8),[Time43] float(8),[Time44] float(8),[Time45] float(8),
											  [Time46] float(8),[Time47] float(8),[Time48] float(8));
									
				INSERT INTO ##MakeupCapacity30 VALUES(0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0);
		End
		
	--60 Minutes
	ELSE IF(@TimeFrame = 60)
		Begin
				--Clear Temp Table
				IF EXISTS (SELECT NAME FROM tempdb..sysobjects WHERE NAME LIKE '##MakeupCapacity60%')
					BEGIN
						DROP TABLE ##MakeupCapacity60;
					END
				--Create Temp Table		
				CREATE TABLE ##MakeupCapacity60([Time1] float(8),[Time2] float(8),[Time3] float(8),[Time4] float(8),[Time5] float(8),
											  [Time6] float(8),[Time7] float(8),[Time8] float(8),[Time9] float(8),[Time10] float(8),
											  [Time11] float(8),[Time12] float(8),[Time13] float(8),[Time14] float(8),[Time15] float(8),
											  [Time16] float(8),[Time17] float(8),[Time18] float(8),[Time19] float(8),[Time20] float(8),
											  [Time21] float(8),[Time22] float(8),[Time23] float(8),[Time24] float(8));
									
				INSERT INTO ##MakeupCapacity60 VALUES(0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0,0,0,0,0,0,0,
													  0,0,0,0);
		End
  
END


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_EXECUTEMAKEUPCAPACITYUTILIZATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_EXECUTEMAKEUPCAPACITYUTILIZATION]
	@Makeup varchar(10),
	@ProductionDate datetime,
	@TimeFrameMinute int 
AS
BEGIN
	Set NOCOUNT ON;
	
	Declare @SdoDate datetime, @STD datetime, @OPENDT datetime, @CLOSEDT datetime,
			@StartTime datetime, @EndTime datetime, 
		    @OpenTime varchar(5), @CloseTime varchar(5),@AllocLength bigint,
		    @BagPerPassenger float(8),@SeatCount bigint,@ClassPercent float(8),@ClassCount int,
		    @BagInvolvement float(8), @BagCountPerMinute float(8), @ClassPerMakeupPercent float(8),
		    @MinProDate datetime,@MaxProDate datetime, @IsFound bit;
		
	Declare @AIRLINE varchar(3),@FLIGHT_NUMBER varchar(5),@SDO datetime,@STO varchar(4),@RESOURCE varchar(10),
			@ALLOC_OPEN_OFFSET varchar(5), @ALLOC_CLOSE_OFFSET varchar(5), @TRAVEL_CLASS varchar(1),
			@IATA_CODE varchar(3);
		
	Set @SdoDate = @ProductionDate;
	Set @MinProDate = CONVERT(datetime,  CONVERT(datetime, CONVERT(nvarchar(30),CONVERT(nvarchar(30),@SdoDate, 111))) + ' 00:00:00');
	Set @MaxProDate = CONVERT(datetime,  CONVERT(datetime, CONVERT(nvarchar(30),CONVERT(nvarchar(30),@SdoDate, 111))) + ' 23:59:00');
	
	--Create Temp Tables	    
	EXEC [dbo].[stp_SAC_CreateMakeupGlobalTable] @TimeFrameMinute;
	
	Set @SeatCount = 0;
										 
	--Create new cursor
	Declare AllocCursor CURSOR FOR SELECT FPA.[AIRLINE],FPA.[FLIGHT_NUMBER],FPA.[SDO],FPA.[STO],FPA.[RESOURCE],FPA.[ALLOC_OPEN_OFFSET],
										  FPA.[ALLOC_CLOSE_OFFSET],FPA.[TRAVEL_CLASS] FROM [FLIGHT_PLAN_ALLOC] FPA
										  INNER JOIN [FLIGHT_PLAN_SORTING] FPS ON (FPA.SDO = FPS.SDO AND FPA.AIRLINE = FPS.AIRLINE AND FPA.FLIGHT_NUMBER = FPS.FLIGHT_NUMBER)
										  WHERE(((FPA.SDO BETWEEN DATEADD(day,-4,@SdoDate) AND DATEADD(day,4,@SdoDate)) AND (FPA.[RESOURCE]= @Makeup))
										  AND (FPS.CANCELLED<>'Y' OR FPS.CANCELLED IS NULL));
    
    --Open Cursor				
	OPEN AllocCursor;
	
    FETCH NEXT FROM AllocCursor INTO @AIRLINE, @FLIGHT_NUMBER,@SDO,@STO,@RESOURCE,@ALLOC_OPEN_OFFSET,@ALLOC_CLOSE_OFFSET,@TRAVEL_CLASS;
    
    WHILE @@FETCH_STATUS = 0
		BEGIN
			--Aircraft Type
			SELECT @IATA_CODE = AIRCRAFT_TYPE FROM FLIGHT_PLAN_SORTING WHERE AIRLINE=@AIRLINE AND FLIGHT_NUMBER=@FLIGHT_NUMBER
				   AND SDO=@SDO;	
				   
			Set @IsFound = 0;
			Set @STD = CONVERT(datetime, CONVERT(nvarchar(30),CONVERT(nvarchar(30),@SDO, 111) + ' ' + 
					   SUBSTRING(@STO,1, 2) + ':' + SUBSTRING(@STO,3, 2) + ':00'));
					   
			Set @OPENDT = DATEADD(minute,[dbo].[SAC_MINUTECONVERTERSIGN](@ALLOC_OPEN_OFFSET),@STD);
			Set @CLOSEDT = DATEADD(minute,[dbo].[SAC_MINUTECONVERTERSIGN](@ALLOC_CLOSE_OFFSET),@STD);
			Set @StartTime = @OPENDT;
			Set @EndTime = @CLOSEDT;
			
			--Scnerio 1
			IF((@SDO < @SdoDate) AND (@CLOSEDT > @MinProDate))
			Begin
				Print 'Scnerio 1'
				IF( @OPENDT < @MinProDate)
    				Set @OPENDT = @MinProDate;
				Set @IsFound = 1;
			End
			
			IF((@SDO < @SdoDate) AND (@CLOSEDT > @MaxProDate))
			Begin
				Print 'Scnerio 1.1'
				Set @CLOSEDT = @MaxProDate;
				Set @IsFound = 1;
			End
			
			--Scnerio 2
			IF((@SDO > @SdoDate) AND (@OPENDT < @MaxProDate))
			Begin
				Print 'Scnerio 2'
				IF(@CLOSEDT > @MaxProDate) 
					Set @CLOSEDT = @MaxProDate;
					
				Set @IsFound = 1;
			End
			
		    IF((@SDO > @SdoDate) AND (@OPENDT < @MinProDate))
			Begin
				Print 'Scnerio 2.1'
				Set @OPENDT = @MinProDate;
				Set @IsFound = 1;
			End
			
			--Scnerio 3
			IF((@SDO = @SdoDate) AND (@CLOSEDT > @MaxProDate))
			Begin
				Print 'Scnerio 3'
				Set @CLOSEDT = @MaxProDate;
				Set @IsFound = 1;
			End
			
			--Scnerio 4
			IF((@SDO = @SdoDate) AND (@OPENDT < @MinProDate))
			Begin
				Print 'Scnerio 4'
				Set @OPENDT = @MinProDate;
				Set @IsFound = 1;
			End
			
			--Filter
			IF(@IsFound = 0 AND @SDO <> @ProductionDate)
				GOTO NextLoop;
			
			--Allocation Length
			SET @AllocLength = DATEDIFF(minute,@StartTime,@EndTime);
			
			IF(@AllocLength <= 0)
				GOTO NextLoop;
				
			--Bag Per Passenger
		    SELECT @BagPerPassenger = SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY = 'NO_BAG_PER_PASSENGER';
		    
		    --Seat Count 
		    SELECT @SeatCount = SEATS FROM AIRCRAFT WHERE CODE_IATA=@IATA_CODE;
		    IF(@SeatCount = 0)
				Set @SeatCount = 300;
		    
		    --Class Percent
		    IF(@TRAVEL_CLASS <> '*')
				SELECT @ClassPercent = INVOLVEMENT FROM TRAVEL_CLASS WHERE CODE=@TRAVEL_CLASS;
			ELSE
				SET @ClassPercent = [dbo].SAC_COMMONCLASS(@AIRLINE,@FLIGHT_NUMBER,@SDO);
				
		    --Class Count
		    SELECT @ClassCount = COUNT(*) FROM FLIGHT_PLAN_ALLOC 
				WHERE AIRLINE=@AIRLINE AND FLIGHT_NUMBER = @FLIGHT_NUMBER 
				AND SDO=@SDO AND  TRAVEL_CLASS = @TRAVEL_CLASS;
		    
		    --Bag Count Involvement
		    IF(@ClassCount > 0)
				SET @ClassPerMakeupPercent = @ClassPercent / @ClassCount;
			ELSE
				SET @ClassPerMakeupPercent = @ClassPercent;
				
		    SET @BagInvolvement = ((@SeatCount * @BagPerPassenger) * @ClassPerMakeupPercent) / 100;
		    
		    --Bag count per minute
		    SET @BagCountPerMinute = @BagInvolvement / @AllocLength;
		    
		    /* Test Output
				Print '-----------------------------------'
				Print @AIRLINE
				Print @FLIGHT_NUMBER
				Print @AllocLength
				Print @StartTime
				Print @EndTime
				Print @SDO
				Print @OPENDT
				Print @CLOSEDT
				Print @TimeFrameMinute
				Print @BagCountPerMinute
				Print '----------------------------------'
		    */
	    
		    --Update Time Columns
		    EXEC [dbo].[stp_SAC_TimeFrameSpiliter] @ProductionDate,@OPENDT,@CLOSEDT,@TimeFrameMinute,@BagCountPerMinute;
			
			NextLoop:
			--Fetching next cursor
		    FETCH NEXT FROM AllocCursor INTO @AIRLINE, @FLIGHT_NUMBER,@SDO,@STO,@RESOURCE,@ALLOC_OPEN_OFFSET,@ALLOC_CLOSE_OFFSET,@TRAVEL_CLASS;
		END
	
	IF(@TimeFrameMinute = 15)
		SELECT * FROM ##MakeupCapacity15;
	ELSE IF(@TimeFrameMinute = 30)
		SELECT * FROM ##MakeupCapacity30;
	ELSE IF(@TimeFrameMinute = 60)
		SELECT * FROM ##MakeupCapacity60;
	
	CLOSE AllocCursor;
	DEALLOCATE AllocCursor;
END

/*
Exec [stp_SAC_ExecuteMakeupCapacityUtilization] 'MUC18','2010-11-09',60
Go
*/ 


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_FALLBACKTAGINFORMATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_FALLBACKTAGINFORMATION] 
	@NoOfTag [varchar](2), 
	@Code1 [varchar](2),
	@Destination1 [varchar](10), 
	@Code2 [varchar](2),
	@Destination2 [varchar](10), 
	@Code3 [varchar](2),
	@Destination3 [varchar](10), 
	@Code4 [varchar](2),
	@Destination4 [varchar](10), 
	@Code5 [varchar](2),
	@Destination5 [varchar](10), 
	@Code6 [varchar](2),
	@Destination6 [varchar](10), 
	@Code7 [varchar](2),
	@Destination7 [varchar](10), 
	@Code8 [varchar](2),
	@Destination8 [varchar](10), 
	@Code9 [varchar](2),
	@Destination9 [varchar](10), 
	@Code10 [varchar](2),
	@Destination10 [varchar](10)
AS
BEGIN
	-- Step 1: Insert [FALLBACK_TAG_INFO] bag event into event table [FALLBACK_TAG_INFO].
	INSERT INTO [LOG_FALLBACK_TAG_INFO]
			   ([TIME_STAMP], [NO_OF_FALLBACK], [FALLBACK_NO_1], [DESTINATION_1], [FALLBACK_NO_2], [DESTINATION_2],
			   [FALLBACK_NO_3], [DESTINATION_3], [FALLBACK_NO_4], [DESTINATION_4], [FALLBACK_NO_5], [DESTINATION_5],
			   [FALLBACK_NO_6], [DESTINATION_6], [FALLBACK_NO_7], [DESTINATION_7], [FALLBACK_NO_8], [DESTINATION_8],
			   [FALLBACK_NO_9], [DESTINATION_9], [FALLBACK_NO_10], [DESTINATION_10])
			 VALUES
			   (GETDATE(),@NoOfTag, @Code1, @Destination1, @Code2, @Destination2,
			   @Code3, @Destination3, @Code4, @Destination4, @Code5, @Destination5,
			   @Code6, @Destination6, @Code7, @Destination7, @Code8, @Destination8,
			   @Code9, @Destination9, @Code10, @Destination10);
END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_FIDSBISTIMESTAMPMonitor]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_FIDSBISTIMESTAMPMonitor]
	@Type varchar(4),
	@totalTimeStamp datetime OUTPUT,
	@correctTimeStamp datetime OUTPUT,
	@errorTimeStamp datetime OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN Try
	
		IF @Type = 'FIDS'
		BEGIN
			SELECT @totalTimeStamp = MAX(TIME_STAMP) FROM [FLIGHT_PLANS];
			SELECT @correctTimeStamp = MAX(TIME_STAMP) FROM [FLIGHT_PLAN_SORTING] --WHERE CREATED_BY='FIDS';
			SELECT @errorTimeStamp = MAX(TIME_STAMP) FROM [FLIGHT_PLAN_ERROR];
		END 
		ELSE IF @Type = 'BIS'
		BEGIN
			SELECT @totalTimeStamp = MAX(TIME_STAMP) FROM [BAGS];
			SELECT @correctTimeStamp = MAX(TIME_STAMP) FROM [BAG_SORTING] --WHERE CREATED_BY='BIS';
			SELECT @errorTimeStamp = MAX(TIME_STAMP) FROM [BAG_ERROR_BSM];
		END 
			
	END Try
	BEGIN Catch
	
		Set @totalTimeStamp = null;
		Set @correctTimeStamp = null;
		Set @errorTimeStamp = null;
		
	END Catch
END


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_FLIGHTMONITORING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_FLIGHTMONITORING]
	@hour int,
	@totalTelegram int OUTPUT,
	@correctTelegram bigint OUTPUT,
	@errorTelegram bigint OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	Declare @timeStamp datetime;
	Declare @resCount int;
	Declare @now datetime;
	
	BEGIN Try
	
		Set @now = GETDATE();
		
		IF @hour = 1
		    Set @timeStamp = DATEADD(hh, -1 , @now);
		ELSE IF @hour = 24
			Set @timeStamp = DATEADD(DD, -1 , @now);
    	ELSE IF @hour = 48
			Set @timeStamp = DATEADD(DD, -2 , @now);
		ELSE IF @hour = 72
			Set @timeStamp = DATEADD(DD, -3 , @now);
		ELSE IF @hour = 96
			Set @timeStamp = DATEADD(DD, -4 , @now);
		ELSE IF @hour = 120
			Set @timeStamp = DATEADD(DD, -5 , @now);
		ELSE IF @hour = 144
			Set @timeStamp = DATEADD(DD, -6 , @now);
		ELSE IF @hour = 168
			Set @timeStamp = DATEADD(DD, -7 , @now);

			
		SELECT @totalTelegram = COUNT(*) FROM [FLIGHT_PLANS] WHERE ((TIME_STAMP >= @timeStamp) AND (TIME_STAMP < @now));
		
		SELECT @correctTelegram = COUNT(*) FROM [FLIGHT_PLANS] WHERE ((TIME_STAMP >= @timeStamp) AND (TIME_STAMP < @now)
		 AND (ERROR_INDICATOR='0'));
		
		SELECT @errorTelegram = COUNT(*) FROM [FLIGHT_PLANS] WHERE ((TIME_STAMP >= @timeStamp) AND (TIME_STAMP < @now)
		 AND (ERROR_INDICATOR='1'));
			
	END Try
	BEGIN Catch
	
		Set @totalTelegram = 0;
		Set @correctTelegram = 0;
		Set @errorTelegram = 0;
		
	END Catch
END


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_FOURPIERTAGINFORMATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_FOURPIERTAGINFORMATION] 
	@NoOfTag [varchar](2), 
	@Code1 [varchar](4),
	@Destination1 [varchar](10), 
	@Code2 [varchar](4),
	@Destination2 [varchar](10), 
	@Code3 [varchar](4),
	@Destination3 [varchar](10), 
	@Code4 [varchar](4),
	@Destination4 [varchar](10), 
	@Code5 [varchar](4),
	@Destination5 [varchar](10), 
	@Code6 [varchar](4),
	@Destination6 [varchar](10), 
	@Code7 [varchar](4),
	@Destination7 [varchar](10), 
	@Code8 [varchar](4),
	@Destination8 [varchar](10), 
	@Code9 [varchar](4),
	@Destination9 [varchar](10), 
	@Code10 [varchar](4),
	@Destination10 [varchar](10)
AS
BEGIN
	-- Step 1: Insert [FOUR_PIER_TAG_INFO] bag event into event table [FOUR_PIER_TAG_INFO].
	INSERT INTO [BHSDB].[dbo].[LOG_FOUR_DIGITS_FALLBACK_TAG]
			   ([TIME_STAMP], [NO_OF_TAG], [TAG_NO_1], [DESTINATION_1], [TAG_NO_2], [DESTINATION_2],
			   [TAG_NO_3], [DESTINATION_3], [TAG_NO_4], [DESTINATION_4], [TAG_NO_5], [DESTINATION_5],
			   [TAG_NO_6], [DESTINATION_6], [TAG_NO_7], [DESTINATION_7], [TAG_NO_8], [DESTINATION_8],
			   [TAG_NO_9], [DESTINATION_9], [TAG_NO_10], [DESTINATION_10])
		 VALUES
			   (GETDATE(),@NoOfTag, @Code1, @Destination1, @Code2, @Destination2,
			   @Code3, @Destination3, @Code4, @Destination4, @Code5, @Destination5,
			   @Code6, @Destination6, @Code7, @Destination7, @Code8, @Destination8,
			   @Code9, @Destination9, @Code10, @Destination10);
END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_GETALLOCPROP]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_GETALLOCPROP](
      @LICENSE_PLATE VARCHAR(10),
      @CARRIER VARCHAR(3),
      @FLIGHT_NO VARCHAR(5),
      @S_DO DATETIME 
)
AS
DECLARE 
     @AIRLINE VARCHAR(3),
     @FLIGHT_NUMBER VARCHAR(5),
     @SDO DATETIME  
BEGIN
        SET @AIRLINE = NULL
        SET @FLIGHT_NUMBER = NULL 
        SET @SDO = NULL 
      
		BEGIN 
			  IF (SELECT COUNT(*) FROM BAG_SORTING WHERE LICENSE_PLATE = @LICENSE_PLATE) = 1
				 BEGIN 
					SELECT @AIRLINE=AIRLINE, @FLIGHT_NUMBER=FLIGHT_NUMBER, @SDO=SDO FROM BAG_SORTING WHERE LICENSE_PLATE = @LICENSE_PLATE   
				 END 
			  ELSE 
			     -- THIS HAPPEND WHEN BAG IS DECODED WITH AIRLINE, FLIGHT NO & SDO AT MES
			     BEGIN
			        SET @AIRLINE = @CARRIER 
			        SET @FLIGHT_NUMBER = @FLIGHT_NO 
			        SET @SDO = @S_DO  
			     END  	 
		         
			  -- TO CHECK BAGGAGE ALLOCATION STATUS (EARLY, RUSH, LATE)
			  SELECT A.ALLOC_CLOSE_OFFSET AS [ALLOC_CLOSE_OFFSET] , 
					 A.ALLOC_CLOSE_RELATED AS [ALLOC_CLOSE_RELATED], 
					 A.ALLOC_OPEN_OFFSET AS [ALLOC_OPEN_OFFSET], 
					 A.ALLOC_OPEN_RELATED AS [ALLOC_OPEN_RELATED],
					 A.EARLY_OPEN_OFFSET AS [ALLOC_EARLY_OPEN_OFFSET],
					 A.RUSH_DURATION AS [ALLOC_RUSH_DURATION], 
					 A.STO AS [STO], A.SDO AS [SDO], A.ETO AS [ETO], A.EDO AS [EDO], A.ITO AS [ITO], A.IDO AS [IDO] 
			  FROM FLIGHT_PLAN_ALLOC A
			  WHERE A.AIRLINE = @AIRLINE AND A.FLIGHT_NUMBER = @FLIGHT_NUMBER AND A.SDO = @SDO
			  ORDER BY SDO
		  END 
      
END 
GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_GETBAGINFO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		SC LEONG
-- Create date: 01-NOV-2013
-- Description: To collect bag info based on GID
-- =============================================
CREATE PROCEDURE [dbo].[stp_SAC_GETBAGINFO] 
       @GID varchar(10),
       @SCANNED_STATUS VARCHAR(2) OUTPUT,
       @LICENSE_PLATE1 VARCHAR(10) OUTPUT,
       @LICENSE_PLATE2 VARCHAR(10) OUTPUT,
       @AIRLINE VARCHAR(3) OUTPUT,
       @FLIGHT_NUMBER VARCHAR(5) OUTPUT,
       @SDO VARCHAR(10) OUTPUT,
       @DESTINATION VARCHAR(20) OUTPUT,
       @ENCODEDTYPE VARCHAR(2) OUTPUT 
AS
DECLARE 
       @TYPE VARCHAR(1)
BEGIN
       SET @LICENSE_PLATE1 = NULL 
       SET @LICENSE_PLATE2 = NULL 
       SET @AIRLINE = NULL 
       SET @FLIGHT_NUMBER = NULL 
       SET @SDO = NULL 
       SET @DESTINATION = NULL 
       SET @ENCODEDTYPE = NULL 
       
       SELECT @TYPE = [TYPE] FROM BAG_INFO WHERE GID = @GID  
                
       -- GET DATA FROM ITEM SCANNED TABLE
       IF (@TYPE = 1)
          BEGIN
              SELECT @SCANNED_STATUS = STATUS_TYPE, @LICENSE_PLATE1 = LICENSE_PLATE1, @LICENSE_PLATE2 = LICENSE_PLATE2   
              FROM ITEM_SCANNED 
              WHERE GID = @GID  
          END
       -- GET DATA FROM ITEM ENCODING REQUEST TABLE
       ELSE IF (@TYPE = 2)
          BEGIN
		       
		      
              SELECT @LICENSE_PLATE1 = A.LICENSE_PLATE ,@AIRLINE = A.AIRLINE , @FLIGHT_NUMBER = A.FLIGHT_NUMBER, 
                     @DESTINATION = A.DEST, @ENCODEDTYPE = A.ENCODING_TYPE
              FROM ITEM_ENCODED A
              WHERE GID = @GID   
          END
            
END


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_GETFLIGHTMOVEENABLELIST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_GETFLIGHTMOVEENABLELIST]
	@ProductionDate datetime,
	@Makeup varchar(10)
AS
BEGIN
	SET NOCOUNT ON;
	Declare @SdoDate datetime, @STD datetime, @OPENDT datetime, @CLOSEDT datetime,
		@OpenTime varchar(5), @CloseTime varchar(5),@MASTER_AIRLINE varchar(3),
		@MASTER_FLIGHT_NUMBER varchar(5),@Flight_State varchar(10),@BSMCount int,
		@License_Plate varchar(10),@ChuteNo varchar(10), @DischrageCount int, @RemainCount int;
		
	Declare @AIRLINE varchar(3),@FLIGHT_NUMBER varchar(5),@SDO datetime,@STO varchar(4),@RESOURCE varchar(10),
			@ALLOC_OPEN_OFFSET varchar(5), @ALLOC_CLOSE_OFFSET varchar(5),  @RUSH_DURATION varchar(5),
			@EARLY_DURATION varchar(5),@IS_MANUAL_CLOSE bit, @IS_CLOSED bit;
		
	Set @SdoDate = @ProductionDate;

	--Create new cursor
	Declare AllocCursor CURSOR FOR SELECT [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[RESOURCE],[ALLOC_OPEN_OFFSET],
		[ALLOC_CLOSE_OFFSET],[RUSH_DURATION],[IS_MANUAL_CLOSE],[IS_CLOSED] FROM [FLIGHT_PLAN_ALLOC] WHERE
		 ((SDO=@SdoDate) OR (IS_MANUAL_CLOSE=1 AND (IS_CLOSED=0))) AND [RESOURCE]= @Makeup;
	
	--Get Early Hour
	SELECT @EARLY_DURATION = SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY ='ERLY_OPEN_OFFSET';	
	
	--Clear Temp Table
	IF EXISTS (SELECT NAME FROM tempdb..sysobjects WHERE NAME LIKE '#MovableFlightList%')
		BEGIN
			DROP TABLE #MovableFlightList;
		END
	--Create Temp Table		
	CREATE TABLE #MovableFlightList (SDO datetime,
									 OpenTime datetime,
									 CloseTime datetime,
									 MakeUp varchar(10),
									 Airline varchar(3),
									 Flight_Number varchar(5),
									 Is_Manual_Close bit,
									 [State] varchar(10));

	--Open Cursor				
	OPEN AllocCursor;
    --Open Cursor
    FETCH NEXT FROM AllocCursor INTO @AIRLINE, @FLIGHT_NUMBER,@SDO,@STO,@RESOURCE,@ALLOC_OPEN_OFFSET,@ALLOC_CLOSE_OFFSET,@RUSH_DURATION,@IS_MANUAL_CLOSE,@IS_CLOSED;
    
    WHILE @@FETCH_STATUS = 0
		BEGIN
			Set @STD = CONVERT(datetime, CONVERT(nvarchar(30),CONVERT(nvarchar(30),@SDO, 111) + ' ' + 
					   SUBSTRING(@STO,1, 2) + ':' + SUBSTRING(@STO,3, 2) + ':00'));
					   
			SET @OPENDT = DATEADD(minute,[dbo].[SAC_MINUTECONVERTERSIGN](@ALLOC_OPEN_OFFSET),@STD);
			SET @CLOSEDT = DATEADD(minute,[dbo].[SAC_MINUTECONVERTERSIGN](@ALLOC_CLOSE_OFFSET),@STD);
		    
			Set @OpenTime = [dbo].[SAC_FORMATTIME](CONVERT(nvarchar(2),DATEPART(HOUR,@OPENDT))) + ':' + 
							[dbo].[SAC_FORMATTIME](CONVERT(nvarchar(2),DATEPART(MINUTE,@OPENDT)));
			Set @CloseTime = [dbo].[SAC_FORMATTIME](CONVERT(nvarchar(2),DATEPART(HOUR,@CLOSEDT)))+ ':' +
							[dbo].[SAC_FORMATTIME](CONVERT(nvarchar(2),DATEPART(MINUTE,@CLOSEDT)));
			
			SELECT @MASTER_AIRLINE = MASTER_AIRLINE, @MASTER_FLIGHT_NUMBER = MASTER_FLIGHT_NUMBER
				   FROM FLIGHT_PLAN_SORTING WHERE ((SDO=@SDO) AND (AIRLINE = @AIRLINE) AND 
				   (FLIGHT_NUMBER = @FLIGHT_NUMBER));
				   
			--Flight State
			Set @Flight_State = [dbo].[SAC_FLIGHTSTATE](@OPENDT,@CLOSEDT, @RUSH_DURATION, @EARLY_DURATION, 0);
			
			--Flight information saving
			IF((@Flight_State = 'TooEarly') OR (@Flight_State = 'Early') OR (@Flight_State='Opening'))
				Begin
					--Save Flight List
					INSERT INTO #MovableFlightList(SDO,OpenTime,CloseTime,MakeUp,Airline,Flight_Number,Is_Manual_Close, [State]) VALUES(@ProductionDate, @OPENDT, @CLOSEDT, @Makeup,@AIRLINE,@FLIGHT_NUMBER,@IS_MANUAL_CLOSE, @Flight_State);
				End
			--Fetching next cursor
			FETCH NEXT FROM AllocCursor INTO @AIRLINE, @FLIGHT_NUMBER,@SDO, @STO,@RESOURCE, @ALLOC_OPEN_OFFSET, @ALLOC_CLOSE_OFFSET, @RUSH_DURATION,@IS_MANUAL_CLOSE,@IS_CLOSED;
		END
	
	SELECT * FROM #MovableFlightList ORDER BY [State], Airline, Flight_Number;
	
	CLOSE AllocCursor;
	DEALLOCATE AllocCursor;
END


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_GETIRDVALUES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_SAC_GETIRDVALUES] (
	@SCANNER_STATUS VARCHAR(2),
	@LICENSE_PLATE VARCHAR(10),
	@ALLOCATION_PROP VARCHAR(10)
	)
AS
DECLARE 
    @AIRLINE VARCHAR(3),
    @FLIGHT_NUMBER VARCHAR(5),
    @SDO DATETIME ,
    @TRAVEL_CLASS VARCHAR(1),
    @RECONCILIATION_PASSENGER_STATUS VARCHAR(1),
    @STATUS CHAR(2),
    @COLUMN VARCHAR(3),
    @REASON VARCHAR(2),
    @DESTINATION VARCHAR(10)
BEGIN
    SET @AIRLINE = NULL
    SET @FLIGHT_NUMBER = NULL
    SET @SDO = NULL
    
    SELECT @COLUMN = SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY = 'ALLOC_OPEN_RELATED'
    
    IF (@SCANNER_STATUS = '2')
        -- STEP 1. SCANNER NO READ
        BEGIN
           IF (EXISTS(SELECT [RESOURCE] FROM FUNCTION_ALLOC_LIST A WHERE A.FUNCTION_TYPE = 'NORD' AND A.IS_ENABLED = 1))
              BEGIN 
                  SET @REASON = '6'
                  
                  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
                  FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
                  WHERE A.FUNCTION_TYPE = 'NORD' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
              END
           ELSE 
              BEGIN
                  SET @REASON = '6'
                  SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON FROM DESTINATIONS WHERE DESTINATION = 'MES'   
              END
           RETURN 0
        END
          
        -- END OF STEP 1
    ELSE IF (@SCANNER_STATUS = '8' OR @SCANNER_STATUS = '7')
        -- STEP 2. SCANNER READ, BUT MULTIPLE TAG WITH THE SAME TYPE 
        BEGIN
            IF (EXISTS(SELECT [RESOURCE] FROM FUNCTION_ALLOC_LIST WHERE FUNCTION_TYPE = 'BMLP' AND IS_ENABLED = 1))
                BEGIN
                    SET @REASON = '10'
                
                    SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
                    FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
                    WHERE A.FUNCTION_TYPE = 'BMLP' AND A.IS_ENABLED = 1 AND A.RESOURCE = B.DESTINATION 
                END
            ELSE 
                BEGIN
                    SET @REASON = '10'
                    SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON FROM DESTINATIONS WHERE DESTINATION = 'MES'  
                END
            RETURN 0
        END
        -- END OF STEP 2
    ELSE IF (@SCANNER_STATUS NOT IN ('1','2','3','7','8'))
        -- STEP 3. OTHER SCANNER STATUS. 4 - INDEX ERROR, 5 - NO ANSWER, 6 - SCANNER FAILUER 
        BEGIN
            SET @REASON = '0'
            SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON FROM DESTINATIONS WHERE DESTINATION = 'MES' 
            RETURN 0
        END 
        -- END OF STEP 3
    ELSE IF (@SCANNER_STATUS = '1' OR @SCANNER_STATUS = '3')
        -- STEP 4. SCANNER READ OK 
        BEGIN
             -- STEP 4.1 IDENTIFY TYPE OF TAG (4 PIER TAG, FALLBACK TAG, IATA TAG)
             IF (LEFT(@LICENSE_PLATE,1)='1') AND LEN(LTRIM(RTRIM(@LICENSE_PLATE))) = 10
                -- FALLBACK TAG 
                BEGIN 
                    IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'FALLBACK_SORT_ENABLED' AND SYS_VALUE='TRUE') AND
                       EXISTS(SELECT * FROM SYS_CONFIG WHERE SYS_KEY = 'AIRPORT_LOCATION_CODE' AND SYS_VALUE = RIGHT(LEFT(@LICENSE_PLATE,8),4))
                       
                       -- HAVE TO CHECK VALIDITY OF AIRPORT CODE AND ABILITY TO SORT BY FALLBACK TAG 
                       BEGIN 
                     		SET @REASON = '2'
		                    
							SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
							FROM FALLBACK_MAPPING A,DESTINATIONS B WHERE A.DESTINATION = B.DESTINATION AND ID = RIGHT(LTRIM(RTRIM(@LICENSE_PLATE)),2) AND B.IS_AVAILABLE = 1
		                    
							RETURN 0
					   END
					ELSE
					   -- IF FALLBACK SORTATION DISABLED && NOT VALID OF AIRPORT CODE, CONSIDER AS UNKNOWN LICENSE PLATE
					   BEGIN
					        IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'UNKNOWN_LICENSE_PLATE' AND SYS_VALUE='TRUE')
										 BEGIN 
											 SET @REASON = '20'
									         
											 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
											 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
											 WHERE A.FUNCTION_TYPE = 'UNLP' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
									         
										 END 
							 ELSE
						   				 BEGIN
											  SET @REASON = '20'
									          
											  SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON FROM DESTINATIONS WHERE DESTINATION = 'MES'
									          
										 END
							RETURN 0 
					   END   		
                END
             ELSE IF (LEFT(@LICENSE_PLATE,1) IN ('0','2','3','4','5','6','7','8','9')) AND LEN(LTRIM(RTRIM(@LICENSE_PLATE))) = 10
                -- IATA TAG 
                BEGIN
                    
                    -- CHECK EXISTENCE OF BAG SORTING DATA :- THAT'S MEAN ABLE TO SORT BY FLIGHT & OTHER SORTING OPTIONS
                    -- OTHERWISE IT WILL SORT BY CARRIER SORTATION IF CARRIER SORTATION IS ENABLED
                    -- NONE OF THE CONDITIONS ARE MET, DEFAULT DESTINATION : MES WILL BE REPLIED.
                    IF (SELECT COUNT(*) FROM BAG_SORTING WHERE LICENSE_PLATE = @LICENSE_PLATE) > 0
                       BEGIN 
                            SET @STATUS = '01'
                            
                            -- GET AIRLINE, FLIGHT NUMBER, SDO FROM BAG_SORTING (BSM) TABLE
							SELECT @AIRLINE = AIRLINE,@FLIGHT_NUMBER = FLIGHT_NUMBER,@SDO = SDO, @TRAVEL_CLASS = TRAVEL_CLASS, 
								   @RECONCILIATION_PASSENGER_STATUS = RECONCILIATION_PASSENGER_STATUS
							FROM BAG_SORTING 
							WHERE LICENSE_PLATE = @LICENSE_PLATE 
                            
					   END 
				    ELSE 
				       BEGIN
				            SET @STATUS = '02'
				            
				            -- SORT BASED ON AIRLINE CODE FROM THE IATA TAG
				            SET @AIRLINE = RIGHT(LEFT(@LICENSE_PLATE,4),3)
				       END
                                                             
                    IF @STATUS = '01'
                       BEGIN
							-- IATA TAG EXCEPTIONS HANDLING
							-- 1. MULTIPLE BSM SORTING
							IF (SELECT COUNT(*) FROM BAG_SORTING WHERE LICENSE_PLATE = @LICENSE_PLATE) > 1
							   BEGIN
								   SET @REASON = '19' 
								    
								   SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
								   FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B
								   WHERE A.FUNCTION_TYPE = 'MBSM' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
		                           
								   RETURN 0
							   END
							-- 2. UNKNOWN FLIGHT BAG SORTING
							ELSE IF NOT EXISTS(SELECT * FROM FLIGHT_PLAN_SORTING   
											   WHERE FLIGHT_NUMBER = @FLIGHT_NUMBER AND AIRLINE = @AIRLINE AND 
											   (CASE WHEN @COLUMN = 'STD' THEN SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN ADO ELSE ITO END END END) = @SDO)
							   BEGIN
								   SET @REASON = '11'
		                           
								   SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
								   FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
								   WHERE A.FUNCTION_TYPE = 'UNFL' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
		                           
								   RETURN 0
							   END
							-- 3. NO ALLOCATION SORTING
							ELSE IF NOT EXISTS(SELECT * FROM FLIGHT_PLAN_ALLOC   
											   WHERE FLIGHT_NUMBER = @FLIGHT_NUMBER AND AIRLINE = @AIRLINE AND 
											   (CASE WHEN @COLUMN = 'STD' THEN SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN ADO ELSE ITO END END END) = @SDO)
							   BEGIN
								   SET @REASON = '13' 
		                            
								   SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
								   FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
								   WHERE A.FUNCTION_TYPE = 'NOAL' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
		                               
								   RETURN 0
							   END
							-- 4. STANDBY PASSENGER SORTING
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'STAND_BY_PASSENGER_ENABLED' AND SYS_VALUE='TRUE') AND 
									@RECONCILIATION_PASSENGER_STATUS = 'S' 
							   BEGIN
									 SET @REASON = '7'
		                                    
									 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
									 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
									 WHERE A.FUNCTION_TYPE = 'SBPB' AND A.IS_ENABLED = 1 AND A.RESOURCE = B.DESTINATION
		                                
									 RETURN 0
							   END
							-- 5. LATE BAG SORTING
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'LATE_ENABLED' AND SYS_VALUE='TRUE') AND 
									@ALLOCATION_PROP = '2LATE'
							   BEGIN                      
								  SET @REASON = '5'
		                              
								  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.FUNCTION_TYPE = 'LATE' AND A.[RESOURCE] = B.DESTINATION
		                          
								  RETURN 0
							   END
							-- 6. HOT BAG SORTING   
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'RUSH_ENABLED' AND SYS_VALUE='TRUE') AND 
									@ALLOCATION_PROP = 'RUSH'
							   BEGIN
								  SET @REASON = '4'
		                          
								  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.FUNCTION_TYPE = 'RUSH' AND A.[RESOURCE] = B.DESTINATION 
		                          
								  RETURN 0 
							   END 
							-- 7. EARLY BAG SORTING    
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'ERLY_ENABLED' AND SYS_VALUE='TRUE') AND 
									@ALLOCATION_PROP = 'EARLY'
							   BEGIN
								  SET @REASON = '3'
		                       
								  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.FUNCTION_TYPE = 'ERLY' AND A.[RESOURCE] = B.DESTINATION
		                          
								  RETURN 0
							   END
							-- 7. TOO EARLY BAG SORTING    
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'ERLY_OPEN_ENABLED' AND SYS_VALUE='TRUE') AND 
									@ALLOCATION_PROP = '2EARLY'
							   BEGIN
								  SET @REASON = '18'
		                          
								  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.FUNCTION_TYPE = 'TERL' AND A.[RESOURCE] = B.DESTINATION
		                          
								  RETURN 0
							   END   
							-- 8. BUSINESS CLASS SORTING   
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'BUSINESS_CLASS_ENABLED' AND SYS_VALUE='TRUE') AND
									@TRAVEL_CLASS != 'F'
							   BEGIN
								   SET @REASON = '9'
		                                   
								   SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
								   FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
								   WHERE A.FUNCTION_TYPE = 'BCPB' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
		                                   
								   RETURN 0
							   END
							-- 9. FIRST CLASS SORTING
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'FIRST_CLASS_ENABLED' AND SYS_VALUE='TRUE') AND 
									@TRAVEL_CLASS = 'F'
							   BEGIN
									 SET @REASON = '8'
		                             
									 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
									 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
									 WHERE A.FUNCTION_TYPE = 'FCPB' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
		                             
									 RETURN 0
							   END 
							--10. FLIGHT SORTING OPTION
							ELSE IF EXISTS(SELECT * FROM BAG_SORTING A INNER JOIN FLIGHT_PLAN_ALLOC B ON (A.AIRLINE = B.AIRLINE AND A.FLIGHT_NUMBER = B.FLIGHT_NUMBER AND 
							               A.SDO =  (CASE WHEN @COLUMN = 'STD' THEN B.SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN B.EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN B.ADO ELSE B.ITO END END END)) WHERE A.LICENSE_PLATE = @LICENSE_PLATE)
							   BEGIN
								  SET @REASON = '1' 
		                           
								  SELECT C.LOCATION_ID AS DESTINATION, @REASON AS REASON 
								  FROM BAG_SORTING A INNER JOIN FLIGHT_PLAN_ALLOC B ON (A.AIRLINE = B.AIRLINE AND A.FLIGHT_NUMBER = B.FLIGHT_NUMBER AND 
								       A.SDO = (CASE WHEN @COLUMN = 'STD' THEN B.SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN B.EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN B.ADO ELSE B.ITO END END END)), DESTINATIONS C
								  WHERE A.LICENSE_PLATE = @LICENSE_PLATE AND B.[RESOURCE] = C.DESTINATION 
								  ORDER BY (CASE WHEN @COLUMN = 'STD' THEN B.SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN B.EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN B.ADO ELSE B.ITO END END END) 
		                          
								  RETURN 0 
							   END
							-- DEFAULT DESTINATION : MES
						    ELSE
						       BEGIN
						           SET @REASON = '0'
						            
						           SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON FROM DESTINATIONS WHERE DESTINATION = 'MES'
						           
						           RETURN 0
						       END
					   END
					ELSE IF @STATUS = '02'
					   BEGIN 
					       
					       --11. CARRIER SORTING OPTION 
                           IF (SELECT SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY = 'AIRLINE_SORT_ENABLED') = 'TRUE' AND 
                               EXISTS(SELECT B.LOCATION_ID FROM AIRLINES A, DESTINATIONS B WHERE A.DESTINATION = B.DESTINATION AND A.TICKETING_CODE = @AIRLINE) 
                               BEGIN
								   -- GET AIRLINE'S DESTINATION
								   SELECT @DESTINATION = B.LOCATION_ID FROM AIRLINES A, DESTINATIONS B WHERE A.DESTINATION = B.DESTINATION AND A.TICKETING_CODE = @AIRLINE 
						           
								   IF (@DESTINATION != '0' AND @DESTINATION != '' AND @DESTINATION != 'NULL')
									 BEGIN
										 SET @REASON = '16'
						                 
										 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON FROM AIRLINES A, DESTINATIONS B 
										 WHERE A.DESTINATION = B.DESTINATION AND A.TICKETING_CODE = @AIRLINE
						                 
										 RETURN 0
									 END
								   ELSE 
									 BEGIN
										 SET @REASON = '13'
						                 
										 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
										 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
										 WHERE A.FUNCTION_TYPE = 'NOAL' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
						                 
										 RETURN 0
									 END
					           END
					        -- SORT BY UNKNOWN LICENSE PLATE FUNCTIONAL ALLOCATION   
						    ELSE 
						        BEGIN 
						              IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'UNKNOWN_LICENSE_PLATE' AND SYS_VALUE='TRUE')
										 BEGIN 
											 SET @REASON = '12'
									         
											 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
											 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
											 WHERE A.FUNCTION_TYPE = 'UNLP' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
									         
											 RETURN 0
										 END 
									  ELSE
						   				 BEGIN
											  SET @REASON = '12'
									          
											  SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON FROM DESTINATIONS WHERE DESTINATION = 'MES'
									          
											  RETURN 0
										 END
						        END     
					   END     		   
                END       
             ELSE IF LEN(LTRIM(RTRIM(@LICENSE_PLATE))) = 4
                -- 4 DIGITS SORTATION TAG 
                BEGIN
                    SET @REASON = '17'
                    
                    SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON
                    FROM FOUR_DIGITS_FALLBACK_MAPPING A, DESTINATIONS B WHERE A.DESTINATION = B.DESTINATION AND ID = LTRIM(RTRIM(@LICENSE_PLATE))
                    
                    RETURN 0
                END 
        END 
        -- END OF STEP 4
    
       
END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_GETIRDVALUES@MES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_SAC_GETIRDVALUES@MES] (
     @ENCODED_TYPE CHAR(2),
     @LICENSE_PLATE VARCHAR(10),
     @AIRLINE VARCHAR(3),
     @FLIGHT_NUMBER VARCHAR(5),
     @SDO VARCHAR(10),
     @ALLOCATION_PROP VARCHAR(10),
	 @SORTDESTINATION VARCHAR(20)
)
AS
DECLARE 
     @CARRIER VARCHAR(3),
     @FLIGHT_NO VARCHAR(5),
     @S_DO DATETIME,
     @TRAVEL_CLASS VARCHAR(1),
     @RECONCILIATION_PASSENGER_STATUS VARCHAR(1),
     @COLUMN VARCHAR(3),
     @REASON VARCHAR(2),
     @DESTINATION VARCHAR(10)
BEGIN 
     SET @CARRIER = NULL 
     SET @FLIGHT_NO = NULL 
     SET @S_DO = NULL
     
     SELECT @COLUMN = SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY = 'ALLOC_OPEN_RELATED'
     
     -- 1. ENCODED BY LICENSE PLATE
     IF (@ENCODED_TYPE = '1')
        BEGIN
            
            -- 4 DIGITS TAG SORTATION 
            IF LEN(LTRIM(RTRIM(@LICENSE_PLATE))) = 4
                BEGIN
                    SET @REASON = '17'
                    
                    SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
                    FROM FOUR_DIGITS_FALLBACK_MAPPING A, DESTINATIONS B WHERE A.DESTINATION = B.DESTINATION AND ID = LTRIM(RTRIM(@LICENSE_PLATE))
                    
                    RETURN 0
                END 
            ELSE IF (LEFT(@LICENSE_PLATE,1)='1') AND LEN(LTRIM(RTRIM(@LICENSE_PLATE))) = 10
                -- FALLBACK TAG 
                BEGIN 
                    IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'FALLBACK_SORT_ENABLED' AND SYS_VALUE='TRUE') AND
                       EXISTS(SELECT * FROM SYS_CONFIG WHERE SYS_KEY = 'AIRPORT_LOCATION_CODE' AND SYS_VALUE = RIGHT(LEFT(@LICENSE_PLATE,8),4))
                       
                       -- HAVE TO CHECK VALIDITY OF AIRPORT CODE. IF INVALID, GO FOR UNKNOWN LICENSE PLATE SORTATION 
                       BEGIN 
                     		SET @REASON = '2'
		                    
							SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
							FROM FALLBACK_MAPPING A,DESTINATIONS B WHERE A.DESTINATION = B.DESTINATION AND ID = RIGHT(LTRIM(RTRIM(@LICENSE_PLATE)),2) AND B.IS_AVAILABLE = 1
		                    
							RETURN 0
					   END
					ELSE
					   -- IF FALLBACK SORTATION DISABLED, CONSIDER AS NO READ
					   BEGIN
					        IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'UNKNOWN_LICENSE_PLATE' AND SYS_VALUE='TRUE')
										 BEGIN 
											 SET @REASON = '20'
									         
											 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
											 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
											 WHERE A.FUNCTION_TYPE = 'UNLP' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
									         
										 END 
							 ELSE
						   				 BEGIN
											  SET @REASON = '20'
									          
											  SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON, DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
											  FROM DESTINATIONS WHERE DESTINATION = 'MES'
									          
										 END
							RETURN 0 
					   END
                END
            ELSE IF LEN(LTRIM(RTRIM(@LICENSE_PLATE))) = 10
                BEGIN 
                    IF EXISTS(SELECT * FROM BAG_SORTING WHERE LICENSE_PLATE = @LICENSE_PLATE)
                       BEGIN 
                    
							-- GET AIRLINE, FLIGHT NUMBER, SDO FROM BAG_SORTING (BSM) TABLE
							SELECT @CARRIER = AIRLINE,@FLIGHT_NO = FLIGHT_NUMBER,@S_DO = SDO, @TRAVEL_CLASS = TRAVEL_CLASS, 
								   @RECONCILIATION_PASSENGER_STATUS = RECONCILIATION_PASSENGER_STATUS
							FROM BAG_SORTING 
							WHERE LICENSE_PLATE = @LICENSE_PLATE
							
				            
							-- 1.1 CHECK FOR MULTIPLE BSM
							IF (SELECT COUNT(*) FROM BAG_SORTING WHERE LICENSE_PLATE = @LICENSE_PLATE) > 1
							   BEGIN
								   SET @REASON = '19' 
								
								   SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
								   FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B
								   WHERE A.FUNCTION_TYPE = 'MBSM' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
				                   
								   RETURN 0
							   END
							-- 1.2 UNKNOWN FLIGHT BAG SORTING
							ELSE IF NOT EXISTS(SELECT * FROM FLIGHT_PLAN_SORTING
											   WHERE FLIGHT_NUMBER = @FLIGHT_NO AND AIRLINE = @CARRIER AND
											   CASE WHEN @COLUMN = 'STD' THEN SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN ADO ELSE ITO END END END = @S_DO)
							   BEGIN
								   SET @REASON = '11'
				                   
								   SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
								   FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
								   WHERE A.FUNCTION_TYPE = 'UNFL' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
				                   
								   RETURN 0
							   END    
							-- 1.3 NO ALLOCATION SORTING
							ELSE IF NOT EXISTS(SELECT * FROM FLIGHT_PLAN_ALLOC   
											   WHERE FLIGHT_NUMBER = @FLIGHT_NO AND AIRLINE = @CARRIER AND 
											   CASE WHEN @COLUMN = 'STD' THEN SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN ADO ELSE ITO END END END = @S_DO)
							   BEGIN
								   SET @REASON = '13' 
				                    
								   SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
								   FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
								   WHERE A.FUNCTION_TYPE = 'NOAL' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
				                       
								   RETURN 0
							   END       
							-- 1.4 STANDBY PASSENGER SORTING
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'STAND_BY_PASSENGER_ENABLED' AND SYS_VALUE='TRUE') AND 
									@RECONCILIATION_PASSENGER_STATUS = 'S' 
							   BEGIN
									 SET @REASON = '7'
				                            
									 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
									 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
									 WHERE A.FUNCTION_TYPE = 'SBPB' AND A.IS_ENABLED = 1 AND A.RESOURCE = B.DESTINATION
				                        
									 RETURN 0
							   END
							-- 1.5 LATE BAG SORTING
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'LATE_ENABLED' AND SYS_VALUE = 'TRUE') AND 
									@ALLOCATION_PROP = '2LATE'
							   BEGIN                      
								  SET @REASON = '5'
				                      
								  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
								  FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B  
								  WHERE A.FUNCTION_TYPE = 'LATE' AND A.[RESOURCE] = B.DESTINATION
				                  
								  RETURN 0
							   END
							-- 1.6 HOT BAG SORTING   
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'RUSH_ENABLED' AND SYS_VALUE = 'TRUE') AND 
									@ALLOCATION_PROP = 'RUSH'
							   BEGIN
								  SET @REASON = '4'
				                  
								  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
								  FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.FUNCTION_TYPE = 'RUSH' AND A.[RESOURCE] = B.DESTINATION 
				                  
								  RETURN 0 
							   END 
							-- 1.7 EARLY BAG SORTING    
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'ERLY_ENABLED' AND SYS_VALUE = 'TRUE') AND 
									@ALLOCATION_PROP = 'EARLY'
							   BEGIN
								  SET @REASON = '3'
				               
								  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION  
								  FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.FUNCTION_TYPE = 'ERLY' AND A.[RESOURCE] = B.DESTINATION
				                  
								  RETURN 0
							   END
							-- 1.8 TOO EARLY BAG SORTING    
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'ERLY_OPEN_ENABLED' AND SYS_VALUE='TRUE') AND 
									@ALLOCATION_PROP = '2EARLY'
							   BEGIN
								  SET @REASON = '18'
				                  
								  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
								  FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.FUNCTION_TYPE = 'TERL' AND A.[RESOURCE] = B.DESTINATION
				                  
								  RETURN 0
							   END
							-- 1.9 BUSINESS CLASS SORTING   
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'BUSINESS_CLASS_ENABLED' AND SYS_VALUE='TRUE') AND
									@TRAVEL_CLASS != 'F'
							   BEGIN
								   SET @REASON = '9'
				                           
								   SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
								   FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
								   WHERE A.FUNCTION_TYPE = 'BCPB' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
				                           
								   RETURN 0
							   END
							-- 1.9.1 FIRST CLASS SORTING
							ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'FIRST_CLASS_ENABLED' AND SYS_VALUE='TRUE') AND 
									@TRAVEL_CLASS = 'F' 
							   BEGIN
									 SET @REASON = '8'
				                     
									 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
									 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
									 WHERE A.FUNCTION_TYPE = 'FCPB' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
				                     
									 RETURN 0
							   END 
							-- 1.9.2 FLIGHT SORTING OPTION
							ELSE IF EXISTS(SELECT * FROM BAG_SORTING A INNER JOIN FLIGHT_PLAN_ALLOC B ON (A.AIRLINE = B.AIRLINE AND A.FLIGHT_NUMBER = B.FLIGHT_NUMBER AND 
										   A.SDO = CASE WHEN @COLUMN = 'STD' THEN B.SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN B.EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN B.ADO ELSE B.ITO END END END) WHERE A.LICENSE_PLATE = @LICENSE_PLATE)
							   BEGIN
								  SET @REASON = '1' 
				                   
								  SELECT C.LOCATION_ID AS DESTINATION, @REASON AS REASON, C.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
								  FROM BAG_SORTING A INNER JOIN FLIGHT_PLAN_ALLOC B ON (A.AIRLINE = B.AIRLINE AND A.FLIGHT_NUMBER = B.FLIGHT_NUMBER AND 
										 A.SDO = (CASE WHEN @COLUMN = 'STD' THEN B.SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN B.EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN B.ADO ELSE B.ITO END END END)), DESTINATIONS C
								  WHERE A.LICENSE_PLATE = @LICENSE_PLATE AND B.[RESOURCE] = C.DESTINATION 
								  ORDER BY B.SDO 
				                  
								  RETURN 0 
							   END
					   END		   
					-- 1.11 UNKNOWN LICENSE PLATE FUNCTIONAL ALLOCATION   
					ELSE 
					   BEGIN
						  IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'UNKNOWN_LICENSE_PLATE' AND SYS_VALUE='TRUE')
						     BEGIN 
						         SET @REASON = '12'
						         
								 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
								 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
								 WHERE A.FUNCTION_TYPE = 'UNLP' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
						         
						         RETURN 0
						     END 
						  ELSE    
						   	 BEGIN 		 
								  SET @REASON = '12'
						            
								  SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON, DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
								  FROM DESTINATIONS WHERE DESTINATION = 'MES'
						           
								  RETURN 0
							 END	  
					   END
				  
			     END	        
        END
     -- 2. ENCODED BY FLIGHT NUMBER
     ELSE IF (@ENCODED_TYPE = '2')
        BEGIN 
            -- 2.1 UNKNOWN FLIGHT BAG SORTATION
            IF NOT EXISTS(SELECT * FROM FLIGHT_PLAN_SORTING   
						  WHERE FLIGHT_NUMBER = @FLIGHT_NUMBER AND AIRLINE = @AIRLINE AND (CASE WHEN @COLUMN = 'STD' THEN SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN ADO ELSE ITO END END END) = @SDO)
			   BEGIN
				   SET @REASON = '11'
                   
				   SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
				   FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
				   WHERE A.FUNCTION_TYPE = 'UNFL' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
                   
				   RETURN 0
			   END
			-- 2.2 NO ALLOCATION SORTATION
			ELSE IF NOT EXISTS(SELECT * FROM FLIGHT_PLAN_ALLOC   
							   WHERE FLIGHT_NUMBER = @FLIGHT_NUMBER AND AIRLINE = @AIRLINE AND (CASE WHEN @COLUMN = 'STD' THEN SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN ADO ELSE ITO END END END) = @SDO)
			   BEGIN
				   SET @REASON = '13' 
	                
				   SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
				   FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
				   WHERE A.FUNCTION_TYPE = 'NOAL' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
	                   
				   RETURN 0
			   END
			-- 2.3 LATE BAG SORTATION
			ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'LATE_ENABLED') AND 
					@ALLOCATION_PROP = '2LATE'
			   BEGIN                      
				  SET @REASON = '5'
                      
				  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
				  FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.FUNCTION_TYPE = 'LATE' AND A.[RESOURCE] = B.DESTINATION
                  
				  RETURN 0
			   END
			-- 2.4 HOT BAG SORTATION   
			ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'RUSH_ENABLED') AND 
					@ALLOCATION_PROP = 'RUSH'
			   BEGIN
				  SET @REASON = '4'
                  
				  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
				  FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.FUNCTION_TYPE = 'RUSH' AND A.[RESOURCE] = B.DESTINATION 
                  
				  RETURN 0 
			   END 
			-- 2.5 EARLY BAG SORTATION    
			ELSE IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME = 'SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'ERLY_ENABLED') AND 
					@ALLOCATION_PROP = 'EARLY'
			   BEGIN
				  SET @REASON = '3'
                  
				  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
				  FROM FUNCTION_ALLOC_LIST A, DESTINATIONS B WHERE A.FUNCTION_TYPE = 'ERLY' AND A.[RESOURCE] = B.DESTINATION
                  
				  RETURN 0
			   END
			-- 2.6 FLIGHT ALLOCATION SORTATION
			ELSE IF EXISTS(SELECT * FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE = @AIRLINE AND FLIGHT_NUMBER = @FLIGHT_NUMBER AND 
			               (CASE WHEN @COLUMN = 'STD' THEN SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN ADO ELSE ITO END END END) = @SDO)
			   BEGIN
				  SET @REASON = '1' 
                  
				  SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
				  FROM FLIGHT_PLAN_ALLOC A, DESTINATIONS B
				  WHERE A.AIRLINE = @AIRLINE AND A.FLIGHT_NUMBER = @FLIGHT_NUMBER AND 
				       (CASE WHEN @COLUMN = 'STD' THEN A.SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN A.EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN A.ADO ELSE A.ITO END END END) = @SDO AND A.[RESOURCE] = B.DESTINATION 
				  ORDER BY (CASE WHEN @COLUMN = 'STD' THEN A.SDO ELSE CASE WHEN @COLUMN = 'ETD' THEN A.EDO ELSE CASE WHEN @COLUMN = 'ATD' THEN A.ADO ELSE A.ITO END END END) 
                  
				  RETURN 0 
			   END
			-- 2.7 DEFAULT DESTINATION : MES   
		    ELSE 
		       BEGIN
		           SET @REASON = '0'
		           
		           SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON, DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
				   FROM DESTINATIONS WHERE DESTINATION = 'MES'
		           
		           RETURN 0
		       END   
        END
     -- 4. ENCODED BY : PROBLEM BAG
     ELSE IF (@ENCODED_TYPE = '4')
        BEGIN 
             IF EXISTS(SELECT * FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B WHERE A.FUNCTION_TYPE = 'PROB' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION)
               BEGIN   
                 SET @REASON = '14'
                 
                 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
			     FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
			     WHERE A.FUNCTION_TYPE = 'PROB' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
			    
			     RETURN 0
			   END
			 ELSE 
			   BEGIN
			     SET @REASON = '14'
			     
			     SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON, DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
				 FROM DESTINATIONS WHERE DESTINATION = 'MES'
			     
			     RETURN 0  
			   END   
         END
     -- 6. ENCODED BY : AIRLINE   
     ELSE IF (@ENCODED_TYPE = '6')  
        BEGIN
               -- GET AIRLINE'S DESTINATION
			   SELECT @DESTINATION = B.LOCATION_ID FROM AIRLINES A, DESTINATIONS B WHERE A.DESTINATION = B.DESTINATION AND A.CODE_IATA = @AIRLINE 
		       
			   -- CARRIER SORTING OPTION 
			   IF (SELECT SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY = 'AIRLINE_SORT_ENABLED') = 'TRUE'
		           
				   IF (@DESTINATION != '0' AND @DESTINATION != '')
					 BEGIN
						 SET @REASON = '16'
		                 
		                 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION  
						 FROM AIRLINES A, DESTINATIONS B WHERE A.DESTINATION = B.DESTINATION AND A.CODE_IATA = @AIRLINE 
		                 
						 RETURN 0
					 END  
				   ELSE 
					 BEGIN
						 SET @REASON = '13'  
		                 
						 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
						 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
						 WHERE A.FUNCTION_TYPE = 'NOAL' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
		                 
						 RETURN 0
					 END
				-- DEFAULT DESTINATION : MES   
				ELSE 
					BEGIN 
					      IF EXISTS(SELECT * FROM SYS_CONFIG WHERE GROUP_NAME='SControl_Sett' AND IS_ENABLED = 1 AND SYS_KEY = 'UNKNOWN_LICENSE_PLATE' AND SYS_VALUE='TRUE')
							 BEGIN 
								 SET @REASON = '12'
						         
								 SELECT B.LOCATION_ID AS DESTINATION, @REASON AS REASON, B.DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION
								 FROM FUNCTION_ALLOC_LIST A,DESTINATIONS B 
								 WHERE A.FUNCTION_TYPE = 'UNLP' AND A.IS_ENABLED = 1 AND A.[RESOURCE] = B.DESTINATION
						         
								 RETURN 0
							 END 
						  ELSE    
		   					 BEGIN 		 
								  SET @REASON = '12'
						            
								  SELECT LOCATION_ID AS DESTINATION, @REASON AS REASON, DESTINATION AS [DESTINATION_DESCR], (SELECT R.DESCRIPTION FROM SORTATION_REASON R WHERE R.REASON = @REASON) AS R_DESCRIPTION 
								  FROM DESTINATIONS WHERE DESTINATION = 'MES'
						           
								  RETURN 0
							 END
					END  
        END
	ELSE IF (@ENCODED_TYPE = '3')
	    BEGIN
		            SELECT D.LOCATION_ID AS DESTINATION, '' AS REASON, D.DESTINATION AS [DESTINATION_DESCR], '' AS R_DESCRIPTION 
					FROM DESTINATIONS D
					WHERE D.DESTINATION = @SORTDESTINATION 
		END 
END     

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_GETSACPUBLICPARAMETERS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_GETSACPUBLICPARAMETERS]
AS 
BEGIN
	SELECT 
		[SYS_KEY], [SYS_VALUE]
	FROM 
		[SYS_CONFIG]
END


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_GIDUSED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_GIDUSED] 
       @GID varchar(10),
       @Location varchar(20),
       @BagType varchar(2)
AS
BEGIN

	-- Step 1: Insert GID Used bag event into event table [GID_USED].
	INSERT INTO [GID_USED]
           ([TIME_STAMP]
           ,[GID]
           ,[LOCATION]
           ,[BAG_TYPE]
           )
     VALUES
           (GETDATE()
           ,@GID
           ,@Location
           ,@BagType)
    
     -- Step 2: Update / Insert Bag_Info table 
     IF EXISTS(SELECT * FROM BAG_INFO WHERE GID=@GID)
        BEGIN 
           UPDATE BAG_INFO SET LAST_LOCATION = @Location, TIME_STAMP = GETDATE() WHERE GID = @GID  
        END
     ELSE 
        BEGIN 
           INSERT INTO BAG_INFO (GID,LAST_LOCATION,TIME_STAMP) VALUES (@GID, @Location, GETDATE()) 
        END          

END


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_HOLDRELEASEFLIGHTALLOCATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_HOLDRELEASEFLIGHTALLOCATION]
	@ProductionDate datetime,
	@Makeup varchar(10),
	@OnHold bit
AS
BEGIN
	SET NOCOUNT ON;
	Declare @SdoDate datetime, @STD datetime, @OPENDT datetime, @CLOSEDT datetime,
		@OpenTime varchar(5), @CloseTime varchar(5),@MASTER_AIRLINE varchar(3),
		@MASTER_FLIGHT_NUMBER varchar(5),@Flight_State varchar(10),@BSMCount int,
		@License_Plate varchar(10),@ChuteNo varchar(10), @DischrageCount int, @RemainCount int;
		
	Declare @AIRLINE varchar(3),@FLIGHT_NUMBER varchar(5),@SDO datetime,@STO varchar(4),@RESOURCE varchar(10),
			@ALLOC_OPEN_OFFSET varchar(5), @ALLOC_CLOSE_OFFSET varchar(5),  @RUSH_DURATION varchar(5),
			@EARLY_DURATION varchar(5),@IS_MANUAL_CLOSE bit, @IS_CLOSED bit;
		
	Set @SdoDate = @ProductionDate;

	--Create new cursor
	Declare AllocCursor CURSOR FOR SELECT [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[RESOURCE],[ALLOC_OPEN_OFFSET],
		[ALLOC_CLOSE_OFFSET],[RUSH_DURATION],[IS_MANUAL_CLOSE],[IS_CLOSED] FROM [FLIGHT_PLAN_ALLOC] WHERE
		 (SDO=@SdoDate) AND (IS_MANUAL_CLOSE = @OnHold) AND ([RESOURCE]= @Makeup);
	
	--Get Early Hour
	SELECT @EARLY_DURATION = SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY ='ERLY_OPEN_OFFSET';	
	
	--Clear Temp Table
	IF EXISTS (SELECT NAME FROM tempdb..sysobjects WHERE NAME LIKE '#HoldReleaseFlightList%')
		BEGIN
			DROP TABLE #HoldReleaseFlightList;
		END
	--Create Temp Table		
	CREATE TABLE #HoldReleaseFlightList (SDO datetime,
										 OpenTime datetime,
										 CloseTime datetime,
										 MakeUp varchar(10),
										 Airline varchar(3),
										 Flight_Number varchar(5),
										 Is_Manual_Close bit,
										 [State] varchar(10));

	--Open Cursor				
	OPEN AllocCursor;
    --Open Cursor
    FETCH NEXT FROM AllocCursor INTO @AIRLINE, @FLIGHT_NUMBER,@SDO,@STO,@RESOURCE,@ALLOC_OPEN_OFFSET,@ALLOC_CLOSE_OFFSET,@RUSH_DURATION,@IS_MANUAL_CLOSE,@IS_CLOSED;
    
    WHILE @@FETCH_STATUS = 0
		BEGIN
			Set @STD = CONVERT(datetime, CONVERT(nvarchar(30),CONVERT(nvarchar(30),@SDO, 111) + ' ' + 
					   SUBSTRING(@STO,1, 2) + ':' + SUBSTRING(@STO,3, 2) + ':00'));
					   
			SET @OPENDT = DATEADD(minute,[dbo].[SAC_MINUTECONVERTERSIGN](@ALLOC_OPEN_OFFSET),@STD);
			SET @CLOSEDT = DATEADD(minute,[dbo].[SAC_MINUTECONVERTERSIGN](@ALLOC_CLOSE_OFFSET),@STD);
		    
			Set @OpenTime = [dbo].[SAC_FORMATTIME](CONVERT(nvarchar(2),DATEPART(HOUR,@OPENDT))) + ':' + 
							[dbo].[SAC_FORMATTIME](CONVERT(nvarchar(2),DATEPART(MINUTE,@OPENDT)));
			Set @CloseTime = [dbo].[SAC_FORMATTIME](CONVERT(nvarchar(2),DATEPART(HOUR,@CLOSEDT)))+ ':' +
							[dbo].[SAC_FORMATTIME](CONVERT(nvarchar(2),DATEPART(MINUTE,@CLOSEDT)));
			
			SELECT @MASTER_AIRLINE = MASTER_AIRLINE, @MASTER_FLIGHT_NUMBER = MASTER_FLIGHT_NUMBER
				   FROM FLIGHT_PLAN_SORTING WHERE ((SDO=@SDO) AND (AIRLINE = @AIRLINE) AND 
				   (FLIGHT_NUMBER = @FLIGHT_NUMBER));
				   
			--Flight State
			Set @Flight_State = [dbo].[SAC_FLIGHTSTATE](@OPENDT,@CLOSEDT, @RUSH_DURATION, @EARLY_DURATION, 0);
			
			--Flight information saving
			IF((@Flight_State = 'TooEarly') OR (@Flight_State = 'Early') OR (@Flight_State='Opening')OR (@Flight_State='Rushing'))
				Begin
					--Save Flight List
					INSERT INTO #HoldReleaseFlightList(SDO,OpenTime,CloseTime,MakeUp,Airline,Flight_Number,Is_Manual_Close, [State]) VALUES(@ProductionDate, @OPENDT, @CLOSEDT, @Makeup,@AIRLINE,@FLIGHT_NUMBER,@IS_MANUAL_CLOSE, @Flight_State);
				End
			--Fetching next cursor
			FETCH NEXT FROM AllocCursor INTO @AIRLINE, @FLIGHT_NUMBER,@SDO, @STO,@RESOURCE, @ALLOC_OPEN_OFFSET, @ALLOC_CLOSE_OFFSET, @RUSH_DURATION,@IS_MANUAL_CLOSE,@IS_CLOSED;
		END
	
	SELECT * FROM #HoldReleaseFlightList ORDER BY [State], Airline, Flight_Number;
	
	CLOSE AllocCursor;
	DEALLOCATE AllocCursor;
END


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_ITEM1500P]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEM1500P] 
           @GID VARCHAR(10),
           @LICENSE_PLATE VARCHAR(10),
           @XRAY_ID VARCHAR(10),
           @BIT_STATION VARCHAR(20),
           @ETD_STATION VARCHAR(20),
           @PLC_TIMESTAMP VARCHAR(20),
           @BAG_STATUS VARCHAR(2),
           @LOCATION VARCHAR(20)
AS
BEGIN
	
	INSERT INTO [ITEM_1500P]
           ([TIME_STAMP]
           ,[GID]
           ,[LICENSE_PLATE]
           ,[XRAY_ID]
           ,[BIT_STATION]
           ,[ETD_STATION]
           ,[PLC_TIMESTAMP]
           ,[BAG_STATUS]
           ,[LOCATION]
           )
     VALUES
           (GETDATE()
           ,@GID
           ,@LICENSE_PLATE
           ,@XRAY_ID
           ,@BIT_STATION
           ,@ETD_STATION
           ,@PLC_TIMESTAMP
           ,@BAG_STATUS
           ,@LOCATION
           )
           
END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMENCODINGREQUEST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMENCODINGREQUEST] 
	@GID [varchar](10), 
	@Location [varchar](20), 
	@LicensePlate [varchar](10),
	@Airline [varchar](3),
	@FlightNumber [varchar](5),
	@SDO [varchar](10),
	@Destination [varchar](20),
	@EncodingType [varchar] (2),
	@PLC_IDX [varchar] (10)
AS
BEGIN
	-- Step 1: Insert Item Encoding Request table [ITEM_ENCODING_REQUEST].
	INSERT INTO [ITEM_ENCODING_REQUEST] ([TIME_STAMP], [GID], 
			[LOCATION], [LICENSE_PLATE],[AIRLINE], [FLIGHT_NUMBER], [SDO], [DESTINATION], [ENCODING_TYPE],[PLC_IDX]) 
	VALUES (GETDATE(), @GID, @Location, @LicensePlate, 
			@Airline, @FlightNumber, @SDO, @Destination, @EncodingType,@PLC_IDX);
   
    -- Step 2: Insert into Bag_Info table 
    IF EXISTS(SELECT * FROM BAG_INFO WHERE GID = @GID)
       BEGIN
           UPDATE BAG_INFO SET LICENSE_PLATE1 = @LicensePlate, LICENSE_PLATE2 = NULL, LAST_LOCATION = @Location, TIME_STAMP = GETDATE(), [TYPE] = '2' 
           WHERE GID = @GID
       END
    ELSE 
       BEGIN 
           INSERT INTO BAG_INFO (GID, LICENSE_PLATE1, LICENSE_PLATE2, LAST_LOCATION, TIME_STAMP, [TYPE]) VALUES (@GID, @LicensePlate, NULL, @Location, GETDATE(), '2') 
       END
END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMLOST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMLOST] 
	@GID [varchar](10), 
	@Location [varchar](10)
AS
BEGIN
	
	-- Step 1: Insert Item Lost bag event into event table [ITEM_LOST].
	INSERT INTO [ITEM_LOST] 
		([TIME_STAMP], [GID], [LOCATION]) 
	VALUES 
		(GETDATE(), @GID, @Location)
		
    -- Step 2 : Insert / Update sortation working table (BAG_INFO) 
    IF EXISTS(SELECT * FROM BAG_INFO WHERE GID = @GID) 
	   BEGIN
	       UPDATE BAG_INFO SET LAST_LOCATION = @Location, TIME_STAMP = GETDATE() WHERE GID = @GID 
	   END
	ELSE 
	   BEGIN
	       INSERT INTO BAG_INFO (GID, LAST_LOCATION, TIME_STAMP) VALUES (@GID, @Location, GETDATE()) 
	   END 
	     	
END


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMPROCEEDED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMPROCEEDED] 
	@GID [varchar](10), 
	@Location [varchar](20), 
	@ProceededDest [varchar](20), 
	@ProceededType [varchar](2)
AS
BEGIN

	-- Step 1: Insert Item Lost bag event into event table [ITEM_PROCEEDED].
	INSERT INTO [ITEM_PROCEEDED] 
		([TIME_STAMP], [GID], [LOCATION], [PROCEED_LOCATION], [PROCEED_TYPE]) 
	VALUES 
		(GETDATE(), @GID, @Location, @ProceededDest, @ProceededType)

		
	-- Step 2 : Insert / Update sortation working table [BAG_INFO]
	IF EXISTS(SELECT * FROM BAG_INFO WHERE GID = @GID)
	   BEGIN
	       UPDATE BAG_INFO SET LAST_LOCATION = @ProceededDest, TIME_STAMP = GETDATE() WHERE GID = @GID 
	   END
	ELSE 
	   BEGIN
	       INSERT INTO BAG_INFO (GID, LAST_LOCATION, TIME_STAMP) VALUES (@GID, @ProceededDest, GETDATE()) 
	   END   	

END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMREDIRECT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMREDIRECT] 
           @GID VARCHAR(10),
           @DESTINATION_1 VARCHAR(10),
           @DESTINATION_2 VARCHAR(10),
           @REASON VARCHAR(2),
           @PLC_INDEX VARCHAR(10)
AS
BEGIN
	
	INSERT INTO [ITEM_REDIRECT]
           ([TIME_STAMP]
           ,[GID]
           ,[DESTINATION_1]
           ,[DESTINATION_2]
           ,[REASON]
           ,[PLC_INDEX]           
           )
     VALUES
           (GETDATE()
           ,@GID
           ,@DESTINATION_1 
           ,@DESTINATION_2 
           ,@REASON
           ,@PLC_INDEX
           )
           
END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMSCANNED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMSCANNED] 
	@GID [varchar](10), 
	@Location [varchar](20), 
	@LicensePlate1 [varchar](10), 
	@LicensePlate2 [varchar](10),
	@Status [varchar](2),
	@plc_idx [int],
	@Head1 [int],
	@Head2 [int],
	@Head3 [int],
	@Head4 [int],
	@Head5 [int],
	@Head6 [int],
	@Head7 [int],
	@Head8 [int],
	@Head9 [int],
	@Head10 [int],
	@Head11 [int],
	@Head12 [int],
	@Head13 [int],
	@Head14 [int],
	@Head15 [int],
	@Head16 [int]
AS
BEGIN
	-- Step 1: Insert Item Screened bag event into event table [ITEM_SCANNED].
	INSERT INTO [ITEM_SCANNED] 
		   ([TIME_STAMP], [GID], [LOCATION], [LICENSE_PLATE1], [LICENSE_PLATE2], [STATUS_TYPE], [PLC_IDX],
			[HEAD01], [HEAD02], [HEAD03], [HEAD04], [HEAD05], [HEAD06], [HEAD07], [HEAD08], [HEAD09], [HEAD10], 
			[HEAD11], [HEAD12], [HEAD13], [HEAD14], [HEAD15], [HEAD16]) 
	VALUES  (GETDATE(), @GID, @Location, @LicensePlate1, @LicensePlate2, @Status, @plc_idx,  
		   @Head1, @Head2, @Head3, @Head4, @Head5, @Head6, @Head7, @Head8, @Head9, @Head10,
		   @Head11, @Head12, @Head13, @Head14, @Head15, @Head16)
     
	-- Step 2 : Insert / Update sortation working table (BAG_INFO)
	IF EXISTS(SELECT * FROM BAG_INFO WHERE GID=@GID)
	   BEGIN
	       UPDATE BAG_INFO SET LICENSE_PLATE1 = @LicensePlate1, LICENSE_PLATE2 = @LicensePlate2, TIME_STAMP = GETDATE(), [TYPE] = '1',
	                           LAST_LOCATION = @Location 
	       WHERE GID = @GID 
	   END
	ELSE 
	   BEGIN 
	       INSERT INTO BAG_INFO (GID, LICENSE_PLATE1, LICENSE_PLATE2, LAST_LOCATION, TIME_STAMP, [TYPE]) VALUES 
	       (@GID, @LicensePlate1, @LicensePlate2, @Location, GETDATE(), '1')  
	   END   
END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMSCREENED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMSCREENED] 
           @GID varchar(10),
           @Location varchar(20),
           @Screen_Level char(1),
           @Result_Type varchar(2),
           @plc_idx varchar(10)
AS
BEGIN
	
	-- Step 1 : Check existence of Screen Result Type from cross reference table
	IF NOT EXISTS(SELECT * FROM ITEM_SCREEN_RESULT_TYPES WHERE [TYPE] = @Result_Type)
	   BEGIN
	      SET @Result_Type = 'X'
       END
          	
	-- Step 2 : Insert Item Screened bag event into event table [ITEM_SCREENED].
	INSERT INTO [ITEM_SCREENED]
           ([TIME_STAMP]
           ,[GID]
           ,[LOCATION]
           ,[SCREEN_LEVEL]
           ,[RESULT_TYPE]
           ,[PLC_IDX]
           )
     VALUES
           (GETDATE()
           ,@GID
           ,@Location
           ,@Screen_Level
           ,@Result_Type
           ,@plc_idx
           )
     
     -- Step 3 : Insert / Update sortation working table
     IF EXISTS(SELECT * FROM BAG_INFO WHERE GID = @GID)
        BEGIN
            IF @Screen_Level = '1'
               UPDATE BAG_INFO SET LAST_LOCATION = @Location, HBS1_RESULT = @Result_Type, TIME_STAMP = GETDATE() WHERE GID = @GID 
            ELSE IF @Screen_Level = '2'
               UPDATE BAG_INFO SET LAST_LOCATION = @Location, HBS2_RESULT = @Result_Type, TIME_STAMP = GETDATE() WHERE GID = @GID  
            ELSE IF @Screen_Level = '3'
               UPDATE BAG_INFO SET LAST_LOCATION = @Location, HBS3_RESULT = @Result_Type, TIME_STAMP = GETDATE() WHERE GID = @GID  
        END
     ELSE 
        BEGIN
            IF @Screen_Level = '1'
               INSERT INTO BAG_INFO (GID,HBS1_RESULT,LAST_LOCATION,TIME_STAMP) VALUES (@GID, @Result_Type, @Location, GETDATE())
            ELSE IF @Screen_Level = '2'
               INSERT INTO BAG_INFO (GID,HBS2_RESULT,LAST_LOCATION,TIME_STAMP) VALUES (@GID, @Result_Type, @Location, GETDATE()) 
            ELSE IF @Screen_Level = '3'
               INSERT INTO BAG_INFO (GID,HBS3_RESULT,LAST_LOCATION,TIME_STAMP) VALUES (@GID, @Result_Type, @Location, GETDATE())   
        END
                     
END



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMSORTATIONEVENT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMSORTATIONEVENT] 
	@GID [varchar](10), 
	@Location [varchar](20), 
	@Destination [varchar](10), 
	@SortationType [varchar](2),
	@PLC_INDEX [varchar] (10)
AS
BEGIN
	
	-- Step 1: Insert Item Sortation Event bag event into event table [ITEM_SORTATION].
	INSERT INTO [ITEM_SORTATION_EVENT] 
		([TIME_STAMP], [GID], [LOCATION], [SORT_DESTINATION], [SORT_EVENT_TYPE], [PLC_INDEX]) 
	VALUES 
		(GETDATE(), @GID, @Location, @Destination, @SortationType, @PLC_INDEX)
	
	-- Step 2: Insert / update sortation working table (BAG_INFO)
	IF EXISTS(SELECT * FROM BAG_INFO WHERE GID = @GID)
	   BEGIN
	        UPDATE BAG_INFO SET LAST_LOCATION = @Location, TIME_STAMP = GETDATE() WHERE GID=@GID    
	   END
	ELSE 
	   BEGIN
	        INSERT INTO BAG_INFO (GID, LAST_LOCATION, TIME_STAMP) VALUES (@GID, @Location, GETDATE())
	   END   
	   
END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMTRACKING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMTRACKING] 
	@GID [varchar](10), 
	@Location [varchar](20), 
	@TimeStamp [varchar](20)
AS
BEGIN
	
	-- Step 1: Insert Item Tracking Information event into event table [ITEM_TRACKING].
	INSERT INTO [ITEM_TRACKING]
		([TIME_STAMP], [GID], [LOCATION], [PLC_TIMESTAMP]) 
	VALUES 
		(GETDATE(), @GID, @Location, @TimeStamp)
		
		
	-- Step 2 : Insert / Update sortation working table 
	IF EXISTS(SELECT * FROM BAG_INFO WHERE GID=@GID)
	   BEGIN
	       UPDATE BAG_INFO SET LAST_LOCATION = @Location, TIME_STAMP = GETDATE() WHERE GID = @GID 
	   END
    ELSE 
	   BEGIN 
	       INSERT INTO BAG_INFO (GID, LAST_LOCATION, TIME_STAMP) VALUES (@GID, @Location, GETDATE())
	   END
      	
END

GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_MANUALCLOSEFLIGHTALLOC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stp_SAC_MANUALCLOSEFLIGHTALLOC]
	@AirLine varchar(3),
	@Flight_Number varchar(5),
	@SDO datetime,
	@Resource varchar(10),
	@EndTime datetime	
AS
Begin
	SET NOCOUNT ON;
	Declare @MyMinute bigint
	Declare @Now datetime
	Declare @RushDuration varchar(4)
	Declare @ResultOffset varchar(5)
	Declare @CloseOffset varchar(5)
	
	Set @Now = DATEADD(ss,-DATEPART(ss,GETDATE()),GETDATE()) --get now without seconds
	--Get Rush Minutes
	SELECT @RushDuration = [RUSH_DURATION], @CloseOffset = [ALLOC_CLOSE_OFFSET] 
		FROM [FLIGHT_PLAN_ALLOC]
		WHERE ((AIRLINE = @AirLine) AND (FLIGHT_NUMBER = @Flight_Number) AND (SDO = @SDO) AND ([RESOURCE]=@Resource))
	--Get different minutes
	Set @MyMinute = DATEDIFF(mi,@Now,@EndTime)
	--Get Now
	Set @ResultOffset = [dbo].[SAC_SUBSTRACTMINUTESTOOFFSET](@CloseOffset,@MyMinute)
	--New formula added for rush duration (Mumbi standard)
	Set @RushDuration = '0000'
	--Update close offset with rush duration
	Set @ResultOffset = [dbo].[SAC_ADDMINUTESTOOFFSET](@ResultOffset,[dbo].[SAC_MINUTECONVERTER](@RushDuration))
	--Update to database
	UPDATE dbo.FLIGHT_PLAN_ALLOC SET [ALLOC_CLOSE_OFFSET] = @ResultOffset, [IS_MANUAL_CLOSE] = 0,[IS_CLOSED] = 0
	WHERE (([AIRLINE]= @AirLine) AND ([FLIGHT_NUMBER] = @Flight_Number)
	AND ([SDO] = @SDO) AND ([RESOURCE]= @Resource)) 
End



GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_SCHEDULETEMPLATE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_SCHEDULETEMPLATE]
	@AIRLINE varchar(3),
	@FLIGHT_NUMBER varchar(5),
	@SDO datetime
AS
BEGIN
	SET NOCOUNT ON;
	Declare @SYS_VALUE varchar(20);
	
	SELECT @SYS_VALUE = SYS_VALUE FROM SYS_CONFIG WHERE SYS_KEY ='TEMPLATE_OPTION';
	
	IF(@SYS_VALUE = 'Schedule')
	Begin
		Declare @RESOURCE varchar(10);
		Declare @COUNT int;

		SELECT @RESOURCE = T.[RESOURCE]
			FROM TEMPLATE_ASSIGNMENTS TA, TEMPLATE_FLIGHT_PLAN_ALLOC T
			WHERE
				@SDO = TA.PRODUCTION_DATE AND
				@AIRLINE = T.AIRLINE AND
				@FLIGHT_NUMBER = T.FLIGHT_NUMBER AND
				T.TEMPLATE_ID = TA.TEMPLATE_ID;
		
		SELECT @COUNT = ISNULL(COUNT(FLIGHT_NUMBER),0) 
			FROM FLIGHT_PLAN_ALLOC
			WHERE AIRLINE = @AIRLINE AND FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDO AND [RESOURCE]= @RESOURCE;
		
		IF(@COUNT = 0)	 	
		Begin
			INSERT INTO FLIGHT_PLAN_ALLOC (
					AIRLINE,FLIGHT_NUMBER,SDO,STO,[RESOURCE],[WEEKDAY],EDO,ETO,
					ADO,ATO,IDO,ITO,TRAVEL_CLASS,HIGH_RISK,HBS_LEVEL_REQUIRED,ALLOC_OPEN_OFFSET,
					ALLOC_OPEN_RELATED,ALLOC_CLOSE_OFFSET,ALLOC_CLOSE_RELATED,RUSH_DURATION,
					SCHEME_TYPE,CREATED_BY,TIME_STAMP,[HOUR]) 
				SELECT FPS.AIRLINE,FPS.FLIGHT_NUMBER,FPS.SDO,FPS.STO,T.[RESOURCE],T.[WEEKDAY],FPS.EDO,FPS.ETO,
					FPS.ADO,FPS.ATO,FPS.IDO,FPS.ITO,'*',FPS.HIGH_RISK,FPS.HBS_LEVEL_REQUIRED,T.ALLOC_OPEN_OFFSET,
					T.ALLOC_OPEN_RELATED,T.ALLOC_CLOSE_OFFSET,T.ALLOC_CLOSE_RELATED,T.RUSH_DURATION,
					T.SCHEME_TYPE,T.CREATED_BY,GETDATE(),T.[HOUR]
				FROM FLIGHT_PLAN_SORTING FPS INNER JOIN TEMPLATE_ASSIGNMENTS TA 
				ON FPS.SDO = TA.PRODUCTION_DATE INNER JOIN TEMPLATE_FLIGHT_PLAN_ALLOC T
				ON FPS.AIRLINE = T.AIRLINE AND FPS.FLIGHT_NUMBER = T.FLIGHT_NUMBER
				AND TA.TEMPLATE_ID = T.TEMPLATE_ID
				WHERE
					FPS.SDO = @SDO AND
					FPS.AIRLINE = @AIRLINE AND
					FPS.FLIGHT_NUMBER = @FLIGHT_NUMBER;
		End
	End
END


GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_TIMEFRAMESPILITER]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_SAC_TIMEFRAMESPILITER] 
	@SDO datetime,
	@StartTime datetime,
	@EndTime datetime,
	@TimeFrame int,
	@BagCountPerMinute float(8)
AS
BEGIN
	SET NOCOUNT ON;
	Declare @TempTime datetime,@UpdateQuery varchar(200),@TableName varchar(20);
	Declare @TimeLength float(8), @AffectedBlocks int, @TimeName varchar(10),@BagCount float(8);
	
	SET @TimeLength = DATEDIFF(minute, @StartTime, @EndTime);
--	SET @AffectedBlocks = CEILING(@TimeLength / @TimeFrame);
	SET @TempTime = @StartTime;
	
	IF(@TimeFrame = 15)
		Set @TableName = '##MakeupCapacity15';
	ELSE IF(@TimeFrame = 30)
		Set @TableName = '##MakeupCapacity30';
	ELSE IF(@TimeFrame = 60)
		Set @TableName = '##MakeupCapacity60';
	
	WHILE(@TimeLength > 0)
	Begin
		SET @TimeName = [dbo].SAC_TimeFrameDecision(@SDO, @TempTime, @TimeFrame);
		SET @TempTime = DATEADD(minute,1,@TempTime);
		SET @BagCount = @BagCountPerMinute;
		SET @UpdateQuery = 'UPDATE '+ @TableName + ' SET '+ @TimeName + '='+ @TimeName +'+'+ CONVERT(VARCHAR(10),@BagCount);
		SET @TimeLength = @TimeLength - 1;
		EXEC(@UpdateQuery); 
		--print @UpdateQuery
	End
END
/*
    Exec stp_SAC_TimeFrameSpiliter '2010-11-01', 'Nov  1 2010  2:30AM','Nov  1 2010  4:10AM', 60, 3
    Go
*/    


GO
/****** Object:  StoredProcedure [dbo].[stp_UpdateAppLiveMonitoring]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_UpdateAppLiveMonitoring]    
 @APP_CODE varchar(30),   
  @LIVE_STATUS_TYPE varchar(5)  
AS    
BEGIN    
   Declare @DESC nvarchar(150)  
   Declare  @TIME_STAMP datetime  
   SET @DESC ='ChangiIB2SonicMQ connection status. UP:Connected, DOWN:Disconnected. Updated by IB in  60 sec interval.'  
   SET @APP_CODE = LTRIM(RTRIM(@APP_CODE));    
   SET @TIME_STAMP =GETDATE ();  
     
 -- Update the live status record on the [APP_LIVE_MONITORING] table for the passed in application.    
 IF @APP_CODE <> '' AND  @APP_CODE IS NOT NULL    
  BEGIN    
  IF EXISTS(SELECT [APP_CODE] FROM [dbo].[APP_LIVE_MONITORING] WHERE [APP_CODE] = @APP_CODE)     
   BEGIN    
   UPDATE [dbo].[APP_LIVE_MONITORING] SET [TIME_STAMP]=@TIME_STAMP, [LIVE_STATUS_TYPE]=@LIVE_STATUS_TYPE     
    WHERE [APP_CODE]=@APP_CODE;        
   END;    
  ELSE    
   BEGIN    
   INSERT [dbo].[APP_LIVE_MONITORING]([APP_CODE],[TIME_STAMP],[LIVE_STATUS_TYPE],[DESCRIPTION]   )  
    VALUES(@APP_CODE, @TIME_STAMP, @LIVE_STATUS_TYPE,@DESC);    
   END;    
  END;     
    
END    
  

GO
/****** Object:  StoredProcedure [dbo].[stp_UPDATECHANGEDCONNECTIONMONITORING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_UPDATECHANGEDCONNECTIONMONITORING] 
	@Status [varchar](10), 
	@AppCode [varchar](30)
AS		
BEGIN
	UPDATE [APP_LIVE_MONITORING]
		  SET [TIME_STAMP] = GETDATE(), [LIVE_STATUS_TYPE] = @Status
	 WHERE APP_CODE = @AppCode 
END	


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_FALLBACKTAGINFORMATION]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON


GO
/****** Object:  UserDefinedFunction [dbo].[GET_RPT_EDS_LINE_DEVICE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GET_RPT_EDS_LINE_DEVICE]--[GET_RPT_POST_XM]
(
)
RETURNS 
@POST_XM_TABLE  TABLE 
(
	-- Add the column definitions for the TABLE variable here
	XRAY_ID  VARCHAR(15),			--EDS ID
	DIVERT_LOCATION VARCHAR(15),	--ITEM_PROCEED LOCATION
	REJECT_LOCATION VARCHAR (15),	--ITEM_PROCEED ALARM
	CLEAR_LOCATION VARCHAR (15),	--ITEM_PROCEED CLEAR
	PRE_XM_LOCATION VARCHAR (15),	--ITEM_TRACKING BEFORE EDS
	EDS_LOCATION VARCHAR(15),
	POST_XM_LOCATION VARCHAR (15),	--ITEM_TRACKING AFTER EDS
	SUBSYSTEM VARCHAR(20)			--EDS LINE SUBSYSTEM NAME
)
AS
BEGIN

	--Need update
	INSERT INTO @POST_XM_TABLE VALUES('EDS01', 'ED1-19A', 'ED1-19C', 'ED1-19B','ED1-12','ED1-13', 'ED1-14','ED1');
	INSERT INTO @POST_XM_TABLE VALUES('EDS02', 'ED2-18A', 'ED2-18C', 'ED2-18B','ED2-11','ED2-12', 'ED2-13','ED2');
	INSERT INTO @POST_XM_TABLE VALUES('EDS03', 'ED3-17A', 'ED3-17C', 'ED3-17B','ED3-10','ED3-11', 'ED3-12','ED3');
	INSERT INTO @POST_XM_TABLE VALUES('EDS04', 'ED4-17A', 'ED4-17C', 'ED4-17B','ED4-10','ED4-11', 'ED4-12','ED4');
	INSERT INTO @POST_XM_TABLE VALUES('EDS07', 'ED7-18A', 'ED7-18C', 'ED7-18B','ED7-10','ED7-11', 'ED7-12','ED7');
	INSERT INTO @POST_XM_TABLE VALUES('EDS08', 'ED8-17A', 'ED8-17C', 'ED8-17B','ED8-10','ED8-11', 'ED8-12','ED8');
	INSERT INTO @POST_XM_TABLE VALUES('EDS09', 'ED9-18A', 'ED9-18C', 'ED9-18B','ED9-10','ED9-11', 'ED9-12','ED9');
	INSERT INTO @POST_XM_TABLE VALUES('EDS10', 'ED10-17A', 'ED10-17C', 'ED10-17B','ED10-10','ED10-11', 'ED10-12','ED10');
	INSERT INTO @POST_XM_TABLE VALUES('EDS11', 'ED11-17A', 'ED11-17C', 'ED11-17B','ED11-10','ED11-11', 'ED11-12','ED11');
	RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[MES_GETALLOCATEDDESTINATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Albert Sun
-- Create date: 30-Sep-2010
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[MES_GETALLOCATEDDESTINATION]
(
	@AIRLINE VARCHAR(5),
	@FLIGHT_NUMBER VARCHAR(10),
	@SDO DATETIME,
	@STO VARCHAR(5)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @DESTINATION AS VARCHAR(MAX)

	SELECT @DESTINATION = COALESCE(@DESTINATION + ', ', '') + [RESOURCE]
	FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE = @AIRLINE AND FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDO
	AND STO = @STO
	
	-- Return the result of the function
	RETURN @DESTINATION

END


GO
/****** Object:  UserDefinedFunction [dbo].[MES_GETFLIGHTSTATUS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Pan Feng
-- Create date: 2012-May-02
-- Description:	Get flight status
-- =============================================
-- MES_GETFLIGHTSTATUS '2K','1231','2012-12-27 00:00:00.000','2000'
CREATE FUNCTION [dbo].[MES_GETFLIGHTSTATUS]
(
	@AIRLINE VARCHAR(5),
	@FLIGHT_NUMBER VARCHAR(5),
	@SDO DATETIME,
	@STO VARCHAR(5)
)
RETURNS VARCHAR(20)
AS
BEGIN

 --   /*
 --   1. The follow is the formula:
	--a. Early Open Time  = Allocation Open Time + Early Open Offset
	--b. Allocation Open Time = Allocation Open Related Time + Allocation Open Offset (default negative)
	--c. Allocation Open Related = ETD/STD
	--d. Rush Related = ETD/STD
	--e. Rush Close Time (Allocation Close Time)
	--	i. If have ATD & auto close, Rush Close Time= ATD;
	--	ii. Else, Rush Close Time =  Rush Related + Rush Close Time Offset (default positive)
	--f. Rush Open Time (Open State Close)  = Rush Related + Rush Open Time Offset (default negative)
	--g. Rush Close Time Offset > Rush Open Time Offset
	
	--Too Early State = Current Time < Early Open Time
	--Early State = Current Time >= Early Open time & Current Time < Allocation Open Time
	--Open State = Current Time >= Allocation Open Time & Current Time < Rush Open Time
	--Rush State = Current Time >= Rush Open Time & Current Time < Rush Close Time
	--Too Late State = Current Time >=Rush Close Time

 --   */
 	/*1. The follow is the formula:
		a. Early Open Time  = Allocation Open Time + Early Open Offset
		b. Allocation Open Time = Allocation Open Related Time + Allocation Open Offset (default negative)
		c. Allocation Open Related = ETD/STD
		d. Rush Related = ETD/STD
		e. Rush Close Time (Allocation Close Time)
			i. If have ATD & auto close, Rush Close Time= ATD;
			ii. Else, Rush Close Time =  Rush Related + Rush Close Time Offset (default positive)
		f. Rush Open Time (Open State Close)  = Rush Related + Rush Open Time Offset (default negative)
		g. Rush Close Time Offset > Rush Open Time Offset
	
	2. Once ATD is received, interface need to check the allocation whether is in manual close or not. 
		a. If manual close, update the ATD but no need to update the Rush Close Offset
		b. If auto close, update the ATD and update the Rush Close Offset as Rush close Time is same as ATD.
		c. Whenever Operator change from manual close to auto close, DA need check the ATD value, 
			i. If have ATD, rush close time = ATD
			ii. If don’t have, rush close time = rush related + rush close offset
	*/

 
	DECLARE @STATUS AS VARCHAR(20)
    DECLARE @EARLY_OPEN_TIME AS DATETIME
    DECLARE @ALLOCATION_OPEN_TIME AS DATETIME
    DECLARE @EARLY_OPEN_OFFSET_HH AS INT
    DECLARE @EARLY_OPEN_OFFSET_MI AS INT
    DECLARE @ALLOCATION_OPEN_RELATED AS DATETIME
    DECLARE @ALLOCATION_OPEN_OFFSET_HH AS INT
    DECLARE @ALLOCATION_OPEN_OFFSET_MI AS INT
    DECLARE @RUSH_RELATED AS DATETIME
    DECLARE @RUSH_OPEN_TIME AS DATETIME
    DECLARE @RUSH_CLOSE_TIME AS DATETIME
    DECLARE @RUSH_OPEN_TIME_OFFSET_HH AS INT
    DECLARE @RUSH_OPEN_TIME_OFFSET_MI AS INT
    DECLARE @RUSH_CLOSE_TIME_OFFSET_HH AS INT
    DECLARE @RUSH_CLOSE_TIME_OFFSET_MI AS INT
    DECLARE @HAS_ATD AS BIT

	SELECT @ALLOCATION_OPEN_RELATED = LEFT(CONVERT(varchar(8),CASE WHEN  ALLOC_OPEN_RELATED ='STD' THEN SDO ELSE EDO END,112),4) + '-' + SUBSTRING(CONVERT(varchar(8),CASE WHEN  ALLOC_OPEN_RELATED ='STD' THEN SDO ELSE EDO END,112),5,2)+ '-' + SUBSTRING(CONVERT(varchar(8),CASE WHEN  ALLOC_OPEN_RELATED ='STD' THEN SDO ELSE EDO END,112),7,2) + ' '+LEFT(CASE WHEN  ALLOC_OPEN_RELATED ='STD' THEN STO ELSE ETO END,2)+ ':'+SUBSTRING(CASE WHEN  ALLOC_OPEN_RELATED ='STD' THEN STO ELSE ETO END,3,2)+':00.000',
	@RUSH_RELATED = LEFT(CONVERT(varchar(8),SDO,112),4) + '-' + SUBSTRING(CONVERT(varchar(8),SDO,112),5,2)+ '-' + SUBSTRING(CONVERT(varchar(8),SDO,112),7,2) + ' '+LEFT(STO,2)+ ':'+SUBSTRING(STO,3,2)+':00.000', 
	@ALLOCATION_OPEN_OFFSET_HH = CAST(SUBSTRING(ALLOC_OPEN_OFFSET, 2, 2) AS INT),
	@ALLOCATION_OPEN_OFFSET_MI = CAST(SUBSTRING(ALLOC_OPEN_OFFSET, 4, 2) AS INT),
	@RUSH_OPEN_TIME_OFFSET_HH = CAST(SUBSTRING('-0030', 2, 2) AS INT),
	@RUSH_OPEN_TIME_OFFSET_MI = CAST(SUBSTRING('-0030', 4, 2) AS INT),
	@EARLY_OPEN_OFFSET_HH = CAST(SUBSTRING(EARLY_OPEN_OFFSET, 2, 2) AS INT),
	@EARLY_OPEN_OFFSET_MI = CAST(SUBSTRING(EARLY_OPEN_OFFSET, 4, 2) AS INT),
	@HAS_ATD = CASE WHEN ATO IS NULL THEN 0 ELSE 1 END
	FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE = @AIRLINE AND FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDO
	AND STO = @STO 

 	SET @ALLOCATION_OPEN_TIME = DATEADD(MI,-@ALLOCATION_OPEN_OFFSET_MI,DATEADD(HH,-@ALLOCATION_OPEN_OFFSET_HH,@ALLOCATION_OPEN_RELATED))
    SET @EARLY_OPEN_TIME = DATEADD(MI,-@EARLY_OPEN_OFFSET_MI,DATEADD(HH,-@EARLY_OPEN_OFFSET_HH,@ALLOCATION_OPEN_TIME))
    SET @RUSH_OPEN_TIME = DATEADD(MI,-@RUSH_OPEN_TIME_OFFSET_MI,DATEADD(HH,-@RUSH_OPEN_TIME_OFFSET_HH,@RUSH_RELATED))
    
	IF @HAS_ATD = 0
	BEGIN
		SET @RUSH_CLOSE_TIME = DATEADD(MI,-@RUSH_CLOSE_TIME_OFFSET_MI,DATEADD(HH,@RUSH_CLOSE_TIME_OFFSET_HH,@RUSH_RELATED))
	END
	ELSE
	BEGIN
		SELECT @RUSH_CLOSE_TIME = LEFT(CONVERT(varchar(8),ADO,112),4) + '-' + SUBSTRING(CONVERT(varchar(8),ADO,112),5,2)+ '-' + SUBSTRING(CONVERT(varchar(8),ADO,112),7,2) + ' '+LEFT(ATO,2)+ ':'+SUBSTRING(ATO,3,2)+':00.000'
		FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE = @AIRLINE AND FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDO AND STO = @STO
	END
	
	--if GETDATE() < @EARLY_OPEN_TIME 
	--BEGIN
	--	SET @STATUS = 'Too Early'
	--END
	if  GETDATE() < @ALLOCATION_OPEN_TIME
	BEGIN
		SET @STATUS = 'Early'
	END
	else if GETDATE() >= @ALLOCATION_OPEN_TIME and GETDATE() < @RUSH_OPEN_TIME
	BEGIN
		SET @STATUS = 'Open'
	END
	else if GETDATE() >= @RUSH_OPEN_TIME and GETDATE() < @RUSH_CLOSE_TIME
	BEGIN
		SET @STATUS = 'Rush'
	END
	else
	BEGIN
		SET @STATUS = 'Too Late'
	END
	
	RETURN @STATUS

END



GO
/****** Object:  UserDefinedFunction [dbo].[MES_GETTABLECHANGES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[MES_GETTABLECHANGES](@StationName VARCHAR(20),@UpdateStatus int)
RETURNS VARCHAR(200)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @StateCodes VARCHAR(200)
	SELECT @StateCodes = coalesce(@StateCodes + ',', '') + STATE_CODE 
		FROM CHANGE_MONITORING WHERE SAC_OWS = @StationName AND IS_CHANGED = @UpdateStatus

	-- Return the result of the function
	RETURN @StateCodes

END


GO
/****** Object:  UserDefinedFunction [dbo].[RPT_CONVERT_MINUTE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[RPT_CONVERT_MINUTE](@TIME VARCHAR(5)) --@TIME='2345'|| '-0020' || '0020'
RETURNS INT
AS
BEGIN
	
	DECLARE @HOUR INT;
	DECLARE @MIN INT;
	DECLARE @TOTAL_MIN INT;

	IF SUBSTRING(@TIME,1,1)='-' AND LEN(@TIME)=5
	BEGIN
		SET @HOUR = CAST(SUBSTRING(@TIME,2,2) AS INT);
		SET @MIN = CAST(SUBSTRING(@TIME,4,2) AS INT);
		SET @TOTAL_MIN = 0 - @HOUR * 60 - @MIN;
	END
	ELSE IF LEN(@TIME)=4 AND SUBSTRING(@TIME,1,1)<>'-'
	BEGIN
		SET @HOUR = CAST(SUBSTRING(@TIME,1,2) AS INT);
		SET @MIN = CAST(SUBSTRING(@TIME,3,2) AS INT);
		SET @TOTAL_MIN = @HOUR * 60 + @MIN;
	END

	RETURN @TOTAL_MIN;
END

--SELECT DBO.RPT_CONVERT_MINUTE('0945');
--SELECT DBO.RPT_CONVERT_MINUTE('0230');
--SELECT DBO.RPT_CONVERT_MINUTE('-0230');
--SELECT DBO.RPT_CONVERT_MINUTE('-0030');
--SELECT DBO.RPT_CONVERT_MINUTE('0030');
GO
/****** Object:  UserDefinedFunction [dbo].[RPT_FORMAT_LOCATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[RPT_FORMAT_LOCATION]
(
	@LOCATION VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN
	--For example: Convert 'SS1-1' to 'SS1-01'
	--For example: Convert 'SS1-1-M1' to 'SS1-01-M1'
	--For example: Convert 'SS1-1A' to 'SS1-01A'
	DECLARE @FORMAT_LOC VARCHAR(50);
	DECLARE @NUM_PART VARCHAR(50);
	DECLARE @BEFORE_PART VARCHAR(50)=SUBSTRING(@LOCATION,1,CHARINDEX('-',@LOCATION));
	DECLARE @TEMP VARCHAR(50)=SUBSTRING(@LOCATION,CHARINDEX('-',@LOCATION)+1,LEN(@LOCATION)-CHARINDEX('-',@LOCATION));
	DECLARE @AFTER_PART VARCHAR(50)='';
	
	IF ISNUMERIC(@TEMP)<>1
	BEGIN
		IF CHARINDEX('-',@TEMP)>0
		BEGIN
			SET @NUM_PART=SUBSTRING(@TEMP,1,CHARINDEX('-',@TEMP)-1);
			SET @AFTER_PART=SUBSTRING(@TEMP,CHARINDEX('-',@TEMP),LEN(@TEMP)-CHARINDEX('-',@TEMP)+1);
		END
		ELSE
		BEGIN
			SET @NUM_PART=@TEMP;
		END
		
		IF ISNUMERIC(@NUM_PART)<>1
		BEGIN
			IF ISNUMERIC(SUBSTRING(@NUM_PART,1,1))=1 AND ISNUMERIC(SUBSTRING(@NUM_PART,2,1))<>1
			BEGIN
				SET @AFTER_PART=SUBSTRING(@NUM_PART,2,LEN(@NUM_PART))+@AFTER_PART;
				SET @NUM_PART=SUBSTRING(@NUM_PART,1,1);
			END	
		END
	END
	ELSE
	BEGIN
		SET @NUM_PART=@TEMP;
	END

	IF LEN(@NUM_PART)=1 AND ISNUMERIC(@NUM_PART)=1
		SET @NUM_PART='0' + @NUM_PART



	SET @FORMAT_LOC=@BEFORE_PART + @NUM_PART + @AFTER_PART;
	
	RETURN @FORMAT_LOC
END
GO
/****** Object:  UserDefinedFunction [dbo].[RPT_GETFORMATTEDSTO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[RPT_GETFORMATTEDSTO]
(
 @PARAMETER VARCHAR(4)
)
RETURNS VARCHAR(5)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	DECLARE @HOUR VARCHAR(2)
	DECLARE @SECOND VARCHAR(2)
	DECLARE @RESULT VARCHAR(5)
	
	SET @HOUR= SUBSTRING(@PARAMETER,1,2)
	
	SET @SECOND= SUBSTRING(@PARAMETER,3,2)
	
	SET @RESULT= @HOUR + ':' + @SECOND
	
	RETURN @RESULT
END


GO
/****** Object:  UserDefinedFunction [dbo].[RPT_GETPARAMETERS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[RPT_GETPARAMETERS]
(
 @parameter varchar(max)
)
RETURNS 
@temp  TABLE 
(
	PAR NVARCHAR(50)
)
AS
BEGIN

/*
	DECLARE @d char(1)
	DECLARE @Start int
	DECLARE @End int
	SET @d = ',';

	WITH CSVCTE (StartPos, EndPos, Value) AS
	( SELECT 1 AS StartPos, CHARINDEX(@d , @Parameter + @d) AS EndPos,
		SUBSTRING(@Parameter,1,CHARINDEX(@d , @Parameter + @d)-1)
				 UNION ALL
	  SELECT EndPos + 1 AS StartPos , 
		CHARINDEX(@d,@Parameter + @d , EndPos + 1) AS EndPos,
		SUBSTRING(@Parameter,EndPos + 1, CHARINDEX(@d,@Parameter + @d , EndPos + 1)-(EndPos + 1))
	FROM CSVCTE WHERE CHARINDEX(@d, @Parameter + @d, EndPos + 1) <> 0)	      
	     
	 INSERT INTO @temp (PAR ) SELECT LTRIM(RTRIM(Value)) FROM CSVCTE
*/

DECLARE @d char(1)=','
set @Parameter= @Parameter +@d 
DECLARE @PLen int= len(@Parameter)
DECLARE @SIndex int=1
DECLARE @EIndex int= 0


	WHILE (@PLen > @EIndex)
	Begin
	SET @EIndex = CHARINDEX(@d , @Parameter)-1
	INSERT INTO @temp (PAR ) VALUES (LTRIM(RTRIM(SUBSTRING(@Parameter,@SIndex ,@EIndex))))
	SET @SIndex = CHARINDEX(@d , @Parameter)+1
	SET @Parameter =  SUBSTRING(@Parameter, @SIndex, @PLen )
	SET @SIndex = 1
	SET @EIndex = 0
	SET @PLen = LEN(@Parameter)
	End
	
	RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[RPT_TIME_CAL]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[RPT_TIME_CAL](@SDO DATETIME, @STO VARCHAR(4), @OFFSET VARCHAR(5)) --@TIME='2345'|| '-0020' || '0020'
RETURNS DATETIME
AS
BEGIN
	
	DECLARE @STDMIN INT = DBO.RPT_CONVERT_MINUTE(@STO);
	DECLARE @OFSMIN INT = DBO.RPT_CONVERT_MINUTE(@OFFSET);
	DECLARE @STD DATETIME = DATEADD(MINUTE,@STDMIN,@SDO);

	RETURN DATEADD(MINUTE,@OFSMIN,@STD);
END

--SELECT [dbo].[RPT_TIME_CAL]('2014-03-23 00:00:00.000','2100','0302');
GO
/****** Object:  UserDefinedFunction [dbo].[SAC_ADDMINUTESTOOFFSET]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SAC_ADDMINUTESTOOFFSET](@Source varchar(5),@ExtMinute int)
RETURNS varchar(5)
AS
Begin
	Declare @MyMinute int
	Declare @Operator varchar(1)
	Declare @MyOffset varchar(5)
	Declare @Hour int
	Declare @Minute int
	
	IF(LEN(@Source)=5) --[-0000]
	Begin
		Set @Operator='-'
		Set @MyMinute=(CONVERT(int,SUBSTRING(@Source,2,2)*60)+CONVERT(int,SUBSTRING(@Source,4,2)))*(-1)
	End
	ELSE --[0000]
	Begin
		Set @Operator='' --'+'
		Set @MyMinute=(CONVERT(int,SUBSTRING(@Source,1,2)*60)+CONVERT(int,SUBSTRING(@Source,3,2)))
	End
	
	Set @MyMinute= @MyMinute+@ExtMinute
	IF(@MyMinute<0)
	Begin
		Set @Operator='-'
	End		
	ELSE
	Begin
		Set @Operator=''
	End		
	
	Set @MyMinute=ABS(@MyMinute)
	Set @Hour=@MyMinute / 60
	Set @Minute=@MyMinute-(@Hour * 60)
	--Hour
	IF(@Hour>0)
		Begin
			IF(LEN(@Hour)=1)
			Begin
				Set @MyOffset= '0'+CONVERT(varchar(1),@Hour)
			End
			else
			Begin
				Set @MyOffset= CONVERT(varchar(2),@Hour)
			End
		End
	ELSE
		Begin
			Set @MyOffset='00'
		End
	--Minute
	IF(@Minute>0)
		Begin
			IF(LEN(@Minute)=1)
				Begin
					Set @MyOffset=@MyOffset + '0'+CONVERT(varchar(1),@Minute)
				End
			ELSE
				Begin
					Set @MyOffset= @MyOffset + CONVERT(varchar(2),@Minute)
				End
		End
	ELSE
		Begin
			Set @MyOffset=@MyOffset+'00'
		End
	Set @MyOffset=@Operator+@MyOffset
	Return @MyOffset
End	


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_COMMONCLASS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SAC_COMMONCLASS]
(
	@Airline varchar(3), @FlightNumber varchar(5), @SDO datetime
)
RETURNS float
AS
BEGIN
	Declare @Common_Class float(8);
	Declare @ClassCount int, @InvolvementPercent float, @TClass varchar(1);
	
	Declare ClassCursor CURSOR FOR SELECT  TRAVEL_CLASS, COUNT(*) AS [Class_Count] FROM FLIGHT_PLAN_ALLOC 
	        WHERE (AIRLINE = @Airline AND FLIGHT_NUMBER = @FlightNumber AND SDO = @SDO AND TRAVEL_CLASS <> '*')
	        GROUP BY TRAVEL_CLASS;
	
	--Default Common Class Percent
	SET @Common_Class = 100;
	       
    --Open Cursor
    Open ClassCursor;
    
    FETCH NEXT FROM ClassCursor INTO @TClass, @ClassCount;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SELECT @InvolvementPercent = INVOLVEMENT FROM TRAVEL_CLASS WHERE CODE = @TClass;
		
		SET @Common_Class = @Common_Class - @InvolvementPercent;
		
		--Fetching next cursor
		FETCH NEXT FROM ClassCursor INTO @TClass, @ClassCount;
	END

	CLOSE ClassCursor;
	DEALLOCATE ClassCursor;

	RETURN @Common_Class;
END


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_FLIGHTSTATE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SAC_FLIGHTSTATE](@OpenTime datetime, @CloseTime datetime, @RushDuration varchar(5),@Early_Duration varchar(5), @LateDisappearInterval int)
RETURNS varchar(10)
AS
Begin
	Declare @FlightState varchar(10), @Rush_Minutes int, @Early_Minutes int,@Now datetime, @ClosePeriod datetime;
	
	Set @Rush_Minutes = [dbo].[SAC_MINUTECONVERTERSIGN](@RushDuration);
	Set @Early_Minutes = [dbo].[SAC_MINUTECONVERTERSIGN](@Early_Duration) * -1;
	Set @Now = DATEADD(ss,-DATEPART(ss,GETDATE()),GETDATE()) --get now without seconds
	Set @ClosePeriod = DATEADD(MINUTE,-(@Rush_Minutes+@LateDisappearInterval),@Now)
	
	IF((@CloseTime >= @ClosePeriod) AND (@CloseTime <= DATEADD(MINUTE,-@Rush_Minutes,@Now)))
		Set @FlightState = 'Late';
	ELSE IF(@CloseTime < @ClosePeriod)
		Set @FlightState = 'TooLate';
	ELSE IF((@CloseTime > DATEADD(MINUTE,-@Rush_Minutes,@Now)) AND (@CloseTime <= @Now))
		Set @FlightState = 'Rushing';
	ELSE IF((@OpenTime <= @Now) AND (@CloseTime > @Now))
		Set @FlightState = 'Opening';
	ELSE IF((@OpenTime > @Now) AND (@OpenTime <= (DATEADD(MINUTE,@Early_Minutes,@Now))))
		Set @FlightState = 'Early';
	ELSE IF(@OpenTime > (DATEADD(MINUTE,@Early_Minutes,@Now)))
		Set @FlightState = 'TooEarly';
	ELSE
		Set @FlightState = 'Unknown';
		
	Return @FlightState
End

/* Formulae
            1. Too Late
               - Bar_End_Time <= (Current_Time - RushDuration)
            2. Rush
               - (Bar_End_Time > (Current_Time - RushDuration)) && (Bar_End_Time <= Current_Time)
            3. Open
               - (Bar_Start_Time <= Current_Time) && (Bar_End_Time > Current_Time)
            4. Early
               - (Bar_Start_Time > Current_Time) && (Bar_Start_Time <= (Current_Time + Early_Hour))
            5. Too-Early
               - Bar_Start_Time > (Current_Time + Early_Hour)
*/


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_FORMATTIME]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SAC_FORMATTIME](@Time nvarchar(2))
RETURNS nvarchar(2)
AS
Begin
	Declare @FormatTime nvarchar(2)
	IF(LEN(@Time)=2)
		Set @FormatTime= @Time
	ELSE
		Set @FormatTime= '0' + @Time
	Return @FormatTime
End


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_HOURMINUTECOMPARATOR]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[SAC_HOURMINUTECOMPARATOR](@Source varchar(5),@Destination varchar(5))
RETURNS varchar(1)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnStatus varchar(1)
	DECLARE @SOperator varchar(1)
	DECLARE @DOperator varchar(1)
	DECLARE @Sminute bigint
	DECLARE @Dminute bigint
	
	--Offset Value
	IF(LEN(@Source)=5) --(-0000)
	Begin
		Set @Sminute=CONVERT(int,SUBSTRING(@Source,4,2)) + (CONVERT(int,SUBSTRING(@Source,2,2)) * 60)
		Set @SOperator='-'
	End	
	ELSE --(0000)
	Begin
		Set @Sminute=CONVERT(int,SUBSTRING(@Source,3,2)) + (CONVERT(int,SUBSTRING(@Source,1,2)) * 60)
		Set @SOperator=''
	End	
	IF(LEN(@Destination)=5) --(-0000)
	Begin
		Set @Dminute=CONVERT(int,SUBSTRING(@Destination,4,2)) + (CONVERT(int,SUBSTRING(@Destination,2,2)) * 60)
		Set @DOperator='-'
	End	
	ELSE --(0000)
	Begin
		Set @Dminute=CONVERT(int,SUBSTRING(@Destination,3,2)) + (CONVERT(int,SUBSTRING(@Destination,1,2)) * 60)
		Set @DOperator=''
	End	
	IF(@Sminute>@Dminute) 
	Begin
		Set @returnStatus =1  --(+)
	End
	ELSE
	Begin
		Set @returnStatus =0  --(-)
	End
	RETURN @returnStatus
END


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_HOURMINUTEDIFF]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SAC_HOURMINUTEDIFF](@Source varchar(5),@Destination varchar(5))
RETURNS varchar(4)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnStatus varchar(4)
	DECLARE @SOperator varchar(1)
	DECLARE @DOperator varchar(1)
	DECLARE @Sminute int
	DECLARE @Dminute int
	DECLARE @Hour int
	DECLARE @Minute int
	
	--Offset Value
	IF(LEN(@Source)=5) --(-0000)
	Begin
		Set @Sminute=CONVERT(int,SUBSTRING(@Source,4,2)) + (CONVERT(int,SUBSTRING(@Source,2,2)) * 60)
		Set @SOperator='-'
	End	
	ELSE --(0000)
	Begin
		Set @Sminute=CONVERT(int,SUBSTRING(@Source,3,2)) + (CONVERT(int,SUBSTRING(@Source,1,2)) * 60)
		Set @SOperator=''
	End	
	IF(LEN(@Destination)=5) --(-0000)
	Begin
		Set @Dminute=CONVERT(int,SUBSTRING(@Destination,4,2)) + (CONVERT(int,SUBSTRING(@Destination,2,2)) * 60)
		Set @DOperator='-'
	End	
	ELSE --(0000)
	Begin
		Set @Dminute = CONVERT(int,SUBSTRING(@Destination,3,2)) + (CONVERT(int,SUBSTRING(@Destination,1,2)) * 60)
		Set @DOperator='' 
	End	
--		if(@Sminute>@Dminute)
--			begin
			Set @Minute=@Sminute - @Dminute 
--			end
--		else
--			begin
--				Set @Minute=@Dminute - @Sminute
--			end
	
	Set @Hour = @Minute / 60
	Set @Minute = @Minute - (@Hour * 60)
	--Hour
	IF(@Hour>0)
	Begin
		IF(LEN(@Hour)=1)
			Begin
				Set @returnStatus= '0' + CONVERT(varchar(1), @Hour)
			End
		ELSE
			Begin
				Set @returnStatus= CONVERT(varchar(2),@Hour)
			End
	End
	ELSE
		Begin
			Set @returnStatus='00'
		End
	--Minute
	IF(@Minute>0)
		Begin
			IF(LEN(@Minute)=1)
				Begin
					Set @returnStatus=@returnStatus + '0'+ CONVERT(varchar(1),@Minute)
				End
			ELSE
				Begin
					Set @returnStatus=@returnStatus + CONVERT(varchar(2),@Minute)
				End
		End	
	ELSE
		Begin
			Set @returnStatus = @returnStatus+'00'
		End
	
	RETURN @returnStatus
END


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_HOURMINUTEMASTER]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SAC_HOURMINUTEMASTER](@Offset varchar(5),@Day int,@Hour int,@Minute int,@Operation varchar(1))
RETURNS varchar(5)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnStatus varchar(5)
	DECLARE @OHour int
	DECLARE @OMinute bigint
	DECLARE @NMinute bigint
	DECLARE @Operator varchar(1)
	SET @NMinute=(@Day * 1440) + (@Hour * 60) + @Minute
	
	--Offset Value
	IF(LEN(@Offset)=5) --(-0000)
	Begin
		Set @OMinute = CONVERT(int,SUBSTRING(@Offset,4,2)) + (CONVERT(int,SUBSTRING(@Offset,2,2)) * 60)
		Set @Operator='-'
	End	
	ELSE --(0000)
	Begin
		Set @OMinute=CONVERT(int,SUBSTRING(@Offset,3,2)) + (CONVERT(int,SUBSTRING(@Offset,1,2)) * 60)
		Set @Operator=''
	End	
	--Operation
	IF(@Operation = '+')
	Begin
		Set @OMinute = @OMinute + @NMinute
		IF(@OMinute>59)
		Begin
			Set @OHour = @OMinute / 60
			Set @OMinute = @OMinute - (@OHour * 60)
		End
		ELSE
		Begin
			Set @OHour=0
		End
	End		
	ELSE
	Begin
		Set @OMinute = @OMinute - @NMinute
		IF(@OMinute>59)
		Begin
			Set @OHour = @OMinute / 60
			Set @OMinute = @OMinute - (@OHour * 60)
		End
		ELSE
		Begin
			Set @OHour=0
		End
	End		
	--Formating (-0000 or 0000)
	--Hour
	if(@OHour>0)
		Begin
			IF(LEN(@OHour)=1)
				Begin
					Set @returnStatus='0' + CONVERT(varchar(1),@OHour)
				End
			ELSE
				Begin
					Set @returnStatus= CONVERT(varchar(2),@OHour)
				End 
	End		
	else
		Begin
			Set @returnStatus='00'
		End
	--Minute
	if(@OMinute>0)
		Begin
			IF(LEN(@OMinute)=1)
				Begin
					Set @returnStatus=@returnStatus + '0' + CONVERT(varchar(1),@OMinute)
				End
			ELSE
				Begin
					Set @returnStatus= @returnStatus + CONVERT(varchar(2),@OMinute)
				End 		
		End
	else
		Begin
			Set @returnStatus=@returnStatus+'00'
		End	
	
	Set @returnStatus = @Operator + @returnStatus
	-- Return the result of the function
	RETURN @returnStatus
END


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_MINUTECONVERTER]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SAC_MINUTECONVERTER](@OffsetValue varchar(5))
RETURNS int
AS
Begin
	Declare @TMinute int
	IF(LEN(@OffsetValue)=5)
	Begin
		Set @TMinute=(CONVERT(int,SUBSTRING(@OffsetValue,2,2))*60)+CONVERT(int,SUBSTRING(@OffsetValue,4,2))
	End
	ELSE
	Begin
		Set @TMinute= (CONVERT(int,SUBSTRING(@OffsetValue,1,2))*60)+CONVERT(int,SUBSTRING(@OffsetValue,3,2))
	End
	Return @TMinute
End


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_MINUTECONVERTERSIGN]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SAC_MINUTECONVERTERSIGN](@OffsetValue varchar(5))
RETURNS int
AS
Begin
	Declare @TMinute int
	IF(LEN(@OffsetValue)=5)
	Begin
		Set @TMinute=(CONVERT(int,SUBSTRING(@OffsetValue,2,2))*60)+CONVERT(int,SUBSTRING(@OffsetValue,4,2))
		Set @TMinute = @TMinute * (-1)
	End
	ELSE
	Begin
		Set @TMinute= (CONVERT(int,SUBSTRING(@OffsetValue,1,2))*60)+CONVERT(int,SUBSTRING(@OffsetValue,3,2))
	End
	Return @TMinute
End


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_OFFSETOPERATOR]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SAC_OFFSETOPERATOR](@Source varchar(4),@Destination varchar(5)) --@Source=''0945'',@Destination=''-0020'' || ''0020''
RETURNS varchar(4)
AS
Begin
	Declare @sHour int
	Declare @sMinute int
	Declare @dHour int
	Declare @dMinute int
	Declare @liveHour int
	Declare @liveMinute int
	Declare @totaldMinute int
	Declare @totalsMinute int
	Declare @totalbMinute int
	Declare @dOperator varchar(1)
	Declare @result varchar(4)
	--Default
	Set @sHour=0
	Set @sMinute=0
	Set @dHour=0
	Set @dMinute=0
	Set @liveHour=0
	Set @liveMinute=0
	Set @totaldMinute=0
	Set @totalsMinute=0
	Set @totalbMinute=0
	Set @dOperator='' --default +
	Set @result=''		

	--Source
	Set @sHour=CONVERT(int,SUBSTRING(@Source,1,2))
	Set @sMinute=CONVERT(int,SUBSTRING(@Source,3,2))
	--Destination
	IF(LEN(@Destination)=4)
	Begin
		Set @dHour=CONVERT(int,SUBSTRING(@Destination,1,2))
		Set @dMinute=CONVERT(int,SUBSTRING(@Destination,3,2))
	--+ Normal
		Set @totaldMinute=(@dHour * 60)+@dMinute
		Set @totalsMinute=(@sHour * 60)+@sMinute
		Set @totalbMinute=@totalsMinute+@totaldMinute
		Set @liveHour=@totalbMinute / 60
		Set @liveMinute=@totalbMinute - (@liveHour * 60)
	End
	Else
	Begin
		Set @dOperator='-'
		Set @dHour = CONVERT(int,SUBSTRING(@Destination,2,2))
		Set @dMinute = CONVERT(int,SUBSTRING(@Destination,4,2))
		Set @totaldMinute=(@dHour * 60)+@dMinute
		Set @totalsMinute=(@sHour * 60)+@sMinute
		Set @totalbMinute=@totalsMinute-@totaldMinute
		Set @liveHour=@totalbMinute / 60
		Set @liveMinute=@totalbMinute - (@liveHour * 60)
	End
	IF(@liveHour>0)
		Begin		
			IF(LEN(@liveHour)= 1)
				Begin
					Set @result='0' + CONVERT(varchar(1),@liveHour)
				End
			ELSE
				Begin
					Set @result= CONVERT(varchar(2),@liveHour)
				End
		End
	ELSE
		Begin
			Set @result='00'
		End
	IF(@liveMinute>0)
		Begin
			IF(LEN(@liveMinute)= 1)
				Begin
					Set @result=@result + '0' + CONVERT(varchar(1),@liveMinute)
				End
			ELSE
				Begin
					Set @result= @result + CONVERT(varchar(2),@liveMinute)
				End
		End
	ELSE
		Begin
			Set @result=@result+'00'
		End
	
	RETURN @result  --(HHMM)-->STO
END


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_RESOURCECOMBINATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SAC_RESOURCECOMBINATION]
(
	@Airline varchar(3),@Flight_Number varchar(5),@Template_Group varchar(15),@Weekday_Name varchar(15)
)
RETURNS varchar(500)
AS
BEGIN
	Declare @RESOURCE_STRING varchar(500),@RESOURCE varchar(15);

	Declare ResourceCursor CURSOR FOR SELECT DISTINCT TFP.RESOURCE FROM TEMPLATE_FLIGHT_PLAN_ALLOC TFP INNER JOIN TEMPLATES T
	   ON TFP.TEMPLATE_ID = T.ID INNER JOIN TEMPLATE_GROUPS TG 
	   ON T.TEMPLATE_GROUP_ID = TG.ID
	   WHERE TFP.AIRLINE=@Airline AND TFP.FLIGHT_NUMBER=@Flight_Number
	   AND TG.ID=@Template_Group  AND T.WEEKDAY_NAME = @Weekday_Name;
	   
	Set @RESOURCE_STRING = ''
	
    --Open Cursor
    Open ResourceCursor;
    FETCH NEXT FROM ResourceCursor INTO @RESOURCE;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Set @RESOURCE_STRING = @RESOURCE_STRING + @RESOURCE + ',';
		
		--Fetching next cursor
		FETCH NEXT FROM ResourceCursor INTO @RESOURCE;
	END
	IF(len(@RESOURCE_STRING) > 0)
	Begin
		Set @RESOURCE_STRING = SUBSTRING(@RESOURCE_STRING,1,LEN(@RESOURCE_STRING)- 1);  --Remove the last 1
	End
	
	CLOSE ResourceCursor;
	DEALLOCATE ResourceCursor;
	
	RETURN @RESOURCE_STRING;
END



GO
/****** Object:  UserDefinedFunction [dbo].[SAC_SUBSTRACTMINUTESTOOFFSET]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SAC_SUBSTRACTMINUTESTOOFFSET](@Source varchar(5),@ExtMinute int)
RETURNS varchar(5)
AS
Begin
	Declare @MyMinute bigint
	Declare @Operator varchar(1)
	Declare @MyOffset varchar(5)
	Declare @Hour int
	Declare @Minute bigint
	
	IF(LEN(@Source)=5) --[-0000]
		Begin
			Set @Operator='-'
			Set @MyMinute=(CONVERT(int,SUBSTRING(@Source,2,2)*60) + CONVERT(int,SUBSTRING(@Source,4,2)))*(-1)
		End
	ELSE --[0000]
		Begin
			Set @Operator='' --'+'
			Set @MyMinute=(CONVERT(int,SUBSTRING(@Source,1,2)*60)+CONVERT(int,SUBSTRING(@Source,3,2)))
		End
	Set @MyMinute= @MyMinute-@ExtMinute
	--Set @MyMinute = (-1) * @MyMinute
	IF(@MyMinute<0)
		Begin
			Set @Operator='-'
		End		
	ELSE
		Begin
			Set @Operator=''
		End		
	Set @MyMinute = ABS(@MyMinute)
	Set @Hour=@MyMinute / 60
	Set @Minute=@MyMinute-(@Hour * 60)
	--Hour
	IF(@Hour>0)
		Begin
			IF(LEN(@Hour)=1)
				Begin
					Set @MyOffset= '0' + CONVERT(varchar(1),@Hour)
				End
			ELSE
				Begin
					Set @MyOffset= CONVERT(varchar(2),@Hour)
				End
		End
	else
		Begin
			Set @MyOffset='00'
		End
	--Minute
	IF(@Minute>0)
		Begin
			IF(LEN(@Minute)=1)
				Begin
					Set @MyOffset = @MyOffset + '0'+ CONVERT(varchar(1),@Minute)
				End
			ELSE
				Begin
					Set @MyOffset = @MyOffset + CONVERT(varchar(2),@Minute)
				End
		End
	ELSE
		Begin
			Set @MyOffset = @MyOffset+'00'
		End
	Set @MyOffset=@Operator+@MyOffset
	Return @MyOffset
End	


GO
/****** Object:  UserDefinedFunction [dbo].[SAC_TIMEFRAMEDECISION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SAC_TIMEFRAMEDECISION]
(
	@SDO datetime,
	@TimeInfo datetime,
	@TimeFrame int
)
RETURNS varchar(10)
AS
BEGIN
	Declare @TimeName varchar(10),@Index int, @Output varchar(10);
	Declare @TempTime1 datetime, @TempTime2 datetime;
	
	Set @TempTime1 = CAST(floor(CAST(@SDO as float)) as datetime);
	Set @TempTime2 =  CAST(floor(CAST(@SDO as float)) as datetime);
	Set @Output = '';
	
	Set @Index = 0;
	
	--15 Minutes
	IF(@TimeFrame = 15)
	Begin
		WHILE(@Index < 96)	
			Begin
				IF(@Index = 0)
					Set @TempTime2 = DATEADD(minute, 15, @TempTime1);
				Else
					Begin
						Set @TempTime1 = DATEADD(minute, 15, @TempTime1);
						Set @TempTime2 = DATEADD(minute, 15, @TempTime2);
					End
				
				IF(@TimeInfo >=  @TempTime1 AND @TimeInfo <  @TempTime2)
					Begin
						Set @Output = 'Time'+ CONVERT(VARCHAR(2),@Index+1);
						BREAK;
					End 	
				
				Set @Index = @Index + 1;
			End
	End
	--30 Minutes
	ELSE IF(@TimeFrame = 30)
	Begin
		WHILE(@Index < 48)	
			Begin
				IF(@Index = 0)
					Set @TempTime2 = DATEADD(minute, 30, @TempTime1);
				Else
					Begin
						Set @TempTime1 = DATEADD(minute, 30, @TempTime1);
						Set @TempTime2 = DATEADD(minute, 30, @TempTime2);
					End
				
				IF(@TimeInfo >=  @TempTime1 AND @TimeInfo <  @TempTime2)
					 Begin
						Set @Output = 'Time'+ CONVERT(VARCHAR(2),@Index+1)
						BREAK;
					End 	
				
				Set @Index = @Index + 1;
			End
	End
	--60 Minutes
	ELSE IF(@TimeFrame = 60)
	Begin
		WHILE(@Index < 24)	
			Begin
				IF(@Index = 0)
					Set @TempTime2 = DATEADD(minute, 60, @TempTime1);
				Else
					Begin
						Set @TempTime1 = DATEADD(minute, 60, @TempTime1);
						Set @TempTime2 = DATEADD(minute, 60, @TempTime2);
					End
				
				IF(@TimeInfo >=  @TempTime1 AND @TimeInfo <  @TempTime2)
					 Begin
						Set @Output = 'Time'+ CONVERT(VARCHAR(2),@Index+1)
						BREAK;
					End 	
				
				Set @Index = @Index + 1;
			End
	End
	
	RETURN @Output;
END


GO
/****** Object:  UserDefinedFunction [dbo].[SPLIT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SPLIT](@String varchar(8000), @Delimiter char(1))       
			returns @temptable TABLE (items varchar(8000))       
as       
	begin       
		declare @idx int;       
		declare @slice varchar(8000);       
		select @idx = 1;       
		if len(@String)<1 or @String is null  return       
		while @idx!= 0       
			begin       
				set @idx = charindex(@Delimiter,@String);       
				if @idx!=0       
					set @slice = left(@String,@idx - 1);      
				else       
					set @slice = @String;       
				if(len(@slice)>0)  
					insert into @temptable(Items) values(@slice);       
				set @String = right(@String,len(@String) - @idx);       
				if len(@String) = 0 break       
			end   
		return       
	end
	
--SELECT count(*) FROM DBO.SPLIT('CHENNAI,BANGALORE,MUMBAI,The king of SQl Server',',');   



GO
/****** Object:  UserDefinedFunction [dbo].[udf_List2Table]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udf_List2Table]
(
@List VARCHAR(MAX),
@Delim CHAR
)
RETURNS
@ParsedList TABLE
(
ColumnA VARCHAR(MAX)
)
AS
BEGIN
DECLARE @item VARCHAR(MAX), @Pos INT
SET @List = LTRIM(RTRIM(@List))+ @Delim
SET @Pos = CHARINDEX(@Delim, @List, 1)
WHILE @Pos > 0
BEGIN
SET @item = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))
IF @item <> ''
BEGIN
INSERT INTO @ParsedList (ColumnA)
VALUES (CAST(@item AS VARCHAR(MAX)))
END
SET @List = RIGHT(@List, LEN(@List) - @Pos)
SET @Pos = CHARINDEX(@Delim, @List, 1)
END
RETURN
END


GO
/****** Object:  Table [dbo].[AIRCRAFT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AIRCRAFT](
	[CODE_IATA] [varchar](3) NOT NULL,
	[CODE_ICAO] [varchar](4) NULL,
	[SEATS] [int] NOT NULL,
	[MODEL] [varchar](50) NOT NULL,
	[DESCRIPTION] [varchar](100) NULL,
 CONSTRAINT [PK_AIRCRAFT] PRIMARY KEY CLUSTERED 
(
	[CODE_IATA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AIRCRAFT_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AIRCRAFT_TYPES](
	[TYPE] [varchar](10) NOT NULL,
	[MAX_PAX] [int] NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_AIRCRAFT_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AIRLINES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AIRLINES](
	[CODE_IATA] [varchar](3) NOT NULL,
	[CODE_ICAO] [varchar](3) NULL,
	[NAME] [nvarchar](50) NOT NULL,
	[TICKETING_CODE] [varchar](4) NOT NULL,
	[DESTINATION] [varchar](10) NULL,
	[DESTINATION1] [varchar](10) NULL,
	[RUSH] [varchar](10) NULL,
	[HANDLER] [varchar](3) NULL,
	[SORT_FLAG] [bit] NOT NULL,
	[IS_CHANGED] [bit] NULL,
	[EARLY] [varchar](10) NULL,
	[FIRST_CLASS] [varchar](10) NULL,
	[BUSINESS_CLASS] [varchar](10) NULL,
 CONSTRAINT [PK_AIRLINES] PRIMARY KEY CLUSTERED 
(
	[CODE_IATA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AIRPORT_CODE_LOCATION_INFORMATION]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AIRPORT_CODE_LOCATION_INFORMATION](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[AIRPORT_CODE] [varchar](4) NOT NULL,
	[CONFLICTS_LP_DEST] [varchar](10) NOT NULL,
	[NO_ALLOC_DESC] [varchar](10) NOT NULL,
	[DUMP_DEST] [varchar](10) NOT NULL,
	[NO_READ_DEST] [varchar](10) NOT NULL,
	[DEFAULT_MINIMUM_SECURITY_LEVEL] [varchar](1) NOT NULL,
 CONSTRAINT [PK_AIRPORT_CODE_LOCATION_INFORMATION] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AIRPORTS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AIRPORTS](
	[CODE_IATA] [varchar](3) NOT NULL,
	[CODE_ICAO] [varchar](4) NULL,
	[NAME] [nvarchar](50) NOT NULL,
	[COUNTRY] [nvarchar](50) NOT NULL,
	[CITY] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_AIRPORTS] PRIMARY KEY CLUSTERED 
(
	[CODE_IATA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ALLOC_RESOURCE_CAPACITY]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ALLOC_RESOURCE_CAPACITY](
	[RESOURCE] [varchar](10) NOT NULL,
	[CAPACITY] [int] NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
 CONSTRAINT [PK_ALLOC_RESOURCE_CAPACITY] PRIMARY KEY CLUSTERED 
(
	[RESOURCE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ALLOC_RESOURCES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ALLOC_RESOURCES](
	[ID] [int] NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
 CONSTRAINT [PK_ALLOC_RESOURCES] PRIMARY KEY CLUSTERED 
(
	[RESOURCE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ALLOCATION_TEMPLATE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ALLOCATION_TEMPLATE](
	[ID] [varchar](5) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[DESCRIPTION] [varchar](100) NULL,
 CONSTRAINT [PK_ALLOCATION_TEMPLATE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[APP_LIVE_MONITORING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[APP_LIVE_MONITORING](
	[APP_CODE] [varchar](30) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[LIVE_STATUS_TYPE] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](150) NULL,
 CONSTRAINT [PK_APP_LIVE_MONITORING] PRIMARY KEY CLUSTERED 
(
	[APP_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[APP_LIVE_STATUS_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[APP_LIVE_STATUS_TYPES](
	[TYPE] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
 CONSTRAINT [PK_APP_LIVE_STATUS_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AUDIT_LOG]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AUDIT_LOG](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[EVENT_TYPE] [varchar](10) NOT NULL,
	[TABLE_NAME] [varchar](40) NOT NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[DESCRIPTION] [nvarchar](350) NULL,
 CONSTRAINT [PK_AUDIT_LOG] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BAG_ERROR_BSM]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BAG_ERROR_BSM](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DATA_ID] [bigint] NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[DESCRIPTION] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_BAG_ERROR_BSM] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BAG_INFO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BAG_INFO](
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE1] [varchar](10) NULL,
	[LICENSE_PLATE2] [varchar](10) NULL,
	[HBS1_RESULT] [varchar](2) NULL,
	[HBS2_RESULT] [varchar](2) NULL,
	[HBS3_RESULT] [varchar](2) NULL,
	[LAST_LOCATION] [varchar](10) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[TYPE] [varchar](1) NULL,
 CONSTRAINT [PK_BAG_INFO] PRIMARY KEY CLUSTERED 
(
	[GID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BAG_SORTING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BAG_SORTING](
	[DATA_ID] [bigint] NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[DICTIONARY_VERSION] [int] NULL,
	[SOURCE] [varchar](1) NULL,
	[AIRPORT_CODE] [varchar](5) NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[AIRLINE] [varchar](3) NULL,
	[FLIGHT_NUMBER] [varchar](5) NULL,
	[SDO] [datetime] NULL,
	[DESTINATION] [varchar](5) NULL,
	[TRAVEL_CLASS] [varchar](1) NULL,
	[INBOUND_AIRLINE] [varchar](3) NULL,
	[INBOUND_FLIGHT_NUMBER] [varchar](5) NULL,
	[INBOUND_SDO] [datetime] NULL,
	[INBOUND_AIRPORT_CODE] [varchar](5) NULL,
	[INBOUND_TRAVEL_CLASS] [varchar](1) NULL,
	[ONWARD_AIRLINE] [varchar](20) NULL,
	[ONWARD_FLIGHT_NUMBER] [varchar](30) NULL,
	[ONWARD_SDO] [varchar](75) NULL,
	[ONWARD_AIRPORT_CODE] [varchar](30) NULL,
	[ONWARD_TRAVEL_CLASS] [varchar](10) NULL,
	[NO_PASSENGER_SAME_SURNAME] [int] NULL,
	[SURNAME] [nvarchar](30) NULL,
	[GIVEN_NAME] [nvarchar](30) NULL,
	[OTHERS_NAME] [nvarchar](100) NULL,
	[BAG_EXCEPTION] [varchar](10) NULL,
	[CHECK_IN_COUNTER] [varchar](10) NULL,
	[CHECK_IN_COUNTER_DESCRIPTION] [varchar](20) NULL,
	[CHECK_IN_TIME_STAMP] [datetime] NULL,
	[CHECK_IN_CARRIAGE_MEDIUM] [varchar](5) NULL,
	[CHECK_IN_TRANSPORT_ID] [varchar](20) NULL,
	[TAG_PRINTER_ID] [varchar](10) NULL,
	[RECONCILIATION_LOAD_AUTHORITY] [varchar](1) NULL,
	[RECONCILIATION_SEAT_NUMBER] [varchar](5) NULL,
	[RECONCILIATION_PASSENGER_STATUS] [varchar](1) NULL,
	[RECONCILIATION_SEQUENCE_NUMBER] [varchar](3) NULL,
	[RECONCILIATION_SECURITY_NUMBER] [varchar](3) NULL,
	[RECONCILIATION_PASSENGER_PROFILES_STATUS] [varchar](1) NULL,
	[RECONCILIATION_TRANSPORT_AUTHORITY] [varchar](1) NULL,
	[RECONCILIATION_BAG_TAG_STATUS] [varchar](1) NULL,
	[HANDLING_TERMINAL] [varchar](10) NULL,
	[HANDLING_BAR] [varchar](10) NULL,
	[HANDLING_GATE] [varchar](10) NULL,
	[WEIGHT_INDICATOR] [varchar](1) NULL,
	[WEIGHT_CHECKED_BAG_NUMBER] [int] NULL,
	[CHECKED_WEIGHT] [int] NULL,
	[UNCHECKED_WEIGHT] [int] NULL,
	[WEIGHT_UNIT] [varchar](2) NULL,
	[WEIGHT_LENGTH] [int] NULL,
	[WEIGHT_WIDTH] [int] NULL,
	[WEIGHT_HEIGHT] [int] NULL,
	[WEIGHT_BAG_TYPE_CODE] [varchar](10) NULL,
	[GROUND_TRANSPORT_EARLIEST_DELIVERY] [datetime] NULL,
	[GROUND_TRANSPORT_LATEST_DELIVERY] [datetime] NULL,
	[GROUND_TRANSPORT_DESCRIPTION] [varchar](200) NULL,
	[FREQUENT_TRAVELLER_ID_NUMBER] [varchar](25) NULL,
	[FREQUENT_TRAVELLER_TIER_ID] [varchar](25) NULL,
	[CORPORATE_NAME] [varchar](20) NULL,
	[AUTOMATED_PNR_ADDRESS] [varchar](20) NULL,
	[MESSAGE_PRINTER_ID] [varchar](10) NULL,
	[INTERNAL_AIRLINE_DATA] [varchar](60) NULL,
	[SECURITY_SCREENING_INSTRUCTION] [varchar](3) NULL,
	[SECURITY_SCREENING_RESULT] [varchar](3) NULL,
	[SECURITY_SCREENING_RESULT_REASON] [varchar](1) NULL,
	[SECURITY_SCREENING_RESULT_METHOD] [varchar](5) NULL,
	[SECURITY_SCREENING_AUTOGRAPH] [varchar](10) NULL,
	[SECURITY_SCREENING_FREE_TEXT] [varchar](40) NULL,
	[HIGH_RISK] [char](1) NULL,
	[HBS_LEVEL_REQUIRED] [char](1) NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
 CONSTRAINT [PK_BAG_SORTING] PRIMARY KEY CLUSTERED 
(
	[TIME_STAMP] ASC,
	[LICENSE_PLATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BAG_SORTING_HIS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BAG_SORTING_HIS](
	[DATA_ID] [bigint] NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[DICTIONARY_VERSION] [int] NULL,
	[SOURCE] [varchar](1) NULL,
	[AIRPORT_CODE] [varchar](5) NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[AIRLINE] [varchar](3) NULL,
	[FLIGHT_NUMBER] [varchar](5) NULL,
	[SDO] [datetime] NULL,
	[DESTINATION] [varchar](5) NULL,
	[TRAVEL_CLASS] [varchar](1) NULL,
	[INBOUND_AIRLINE] [varchar](3) NULL,
	[INBOUND_FLIGHT_NUMBER] [varchar](5) NULL,
	[INBOUND_SDO] [datetime] NULL,
	[INBOUND_AIRPORT_CODE] [varchar](5) NULL,
	[INBOUND_TRAVEL_CLASS] [varchar](1) NULL,
	[ONWARD_AIRLINE] [varchar](20) NULL,
	[ONWARD_FLIGHT_NUMBER] [varchar](30) NULL,
	[ONWARD_SDO] [varchar](75) NULL,
	[ONWARD_AIRPORT_CODE] [varchar](30) NULL,
	[ONWARD_TRAVEL_CLASS] [varchar](10) NULL,
	[NO_PASSENGER_SAME_SURNAME] [int] NULL,
	[SURNAME] [nvarchar](30) NULL,
	[GIVEN_NAME] [nvarchar](30) NULL,
	[OTHERS_NAME] [nvarchar](100) NULL,
	[BAG_EXCEPTION] [varchar](10) NULL,
	[CHECK_IN_COUNTER] [varchar](10) NULL,
	[CHECK_IN_COUNTER_DESCRIPTION] [varchar](20) NULL,
	[CHECK_IN_TIME_STAMP] [datetime] NULL,
	[CHECK_IN_CARRIAGE_MEDIUM] [varchar](5) NULL,
	[CHECK_IN_TRANSPORT_ID] [varchar](20) NULL,
	[TAG_PRINTER_ID] [varchar](10) NULL,
	[RECONCILIATION_LOAD_AUTHORITY] [varchar](1) NULL,
	[RECONCILIATION_SEAT_NUMBER] [varchar](5) NULL,
	[RECONCILIATION_PASSENGER_STATUS] [varchar](1) NULL,
	[RECONCILIATION_SEQUENCE_NUMBER] [varchar](3) NULL,
	[RECONCILIATION_SECURITY_NUMBER] [varchar](3) NULL,
	[RECONCILIATION_PASSENGER_PROFILES_STATUS] [varchar](1) NULL,
	[RECONCILIATION_TRANSPORT_AUTHORITY] [varchar](1) NULL,
	[RECONCILIATION_BAG_TAG_STATUS] [varchar](1) NULL,
	[HANDLING_TERMINAL] [varchar](10) NULL,
	[HANDLING_BAR] [varchar](10) NULL,
	[HANDLING_GATE] [varchar](10) NULL,
	[WEIGHT_INDICATOR] [varchar](1) NULL,
	[WEIGHT_CHECKED_BAG_NUMBER] [int] NULL,
	[CHECKED_WEIGHT] [int] NULL,
	[UNCHECKED_WEIGHT] [int] NULL,
	[WEIGHT_UNIT] [varchar](2) NULL,
	[WEIGHT_LENGTH] [int] NULL,
	[WEIGHT_WIDTH] [int] NULL,
	[WEIGHT_HEIGHT] [int] NULL,
	[WEIGHT_BAG_TYPE_CODE] [varchar](10) NULL,
	[GROUND_TRANSPORT_EARLIEST_DELIVERY] [datetime] NULL,
	[GROUND_TRANSPORT_LATEST_DELIVERY] [datetime] NULL,
	[GROUND_TRANSPORT_DESCRIPTION] [varchar](200) NULL,
	[FREQUENT_TRAVELLER_ID_NUMBER] [varchar](25) NULL,
	[FREQUENT_TRAVELLER_TIER_ID] [varchar](25) NULL,
	[CORPORATE_NAME] [varchar](20) NULL,
	[AUTOMATED_PNR_ADDRESS] [varchar](20) NULL,
	[MESSAGE_PRINTER_ID] [varchar](10) NULL,
	[INTERNAL_AIRLINE_DATA] [varchar](60) NULL,
	[SECURITY_SCREENING_INSTRUCTION] [varchar](3) NULL,
	[SECURITY_SCREENING_RESULT] [varchar](3) NULL,
	[SECURITY_SCREENING_RESULT_REASON] [varchar](1) NULL,
	[SECURITY_SCREENING_RESULT_METHOD] [varchar](5) NULL,
	[SECURITY_SCREENING_AUTOGRAPH] [varchar](10) NULL,
	[SECURITY_SCREENING_FREE_TEXT] [varchar](40) NULL,
	[HIGH_RISK] [char](1) NULL,
	[HBS_LEVEL_REQUIRED] [char](1) NULL,
	[CREATED_BY] [varchar](15) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BAGS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BAGS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[RAW_DATA] [varchar](5000) NOT NULL,
	[ERROR_INDICATOR] [char](1) NULL,
 CONSTRAINT [PK_BAGS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BCDS_BAG_COUNT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BCDS_BAG_COUNT](
	[BAG_LOCATION] [varchar](10) NOT NULL,
	[BAG_COUNT] [int] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CarrierCode]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CarrierCode](
	[Carrier Code] [nvarchar](255) NULL,
	[Carrier Alias Number] [float] NULL,
	[Carrier Code1] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CHANGE_MONITORING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CHANGE_MONITORING](
	[SAC_OWS] [varchar](20) NOT NULL,
	[STATE_CODE] [varchar](30) NOT NULL,
	[IS_CHANGED] [bit] NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
 CONSTRAINT [PK_CHANGE_MONITORING] PRIMARY KEY CLUSTERED 
(
	[SAC_OWS] ASC,
	[STATE_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CHANGE_MONITORING_TABLE_ROWS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CHANGE_MONITORING_TABLE_ROWS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SAC_OWS] [varchar](20) NOT NULL,
	[STATE_CODE] [varchar](30) NOT NULL,
	[IS_CHANGED] [bit] NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
	[AFFECTED_COLUMNS] [nvarchar](1000) NOT NULL,
	[DATA_MANIPULATION_TYPE] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CHECKIN_COUNTER]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CHECKIN_COUNTER](
	[CODE] [varchar](10) NOT NULL,
	[NAME] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](200) NULL,
 CONSTRAINT [PK_CHECKIN_COUNTER] PRIMARY KEY CLUSTERED 
(
	[CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CHECKIN_COUNTER_LINE_MAPPING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CHECKIN_COUNTER_LINE_MAPPING](
	[CHECKIN_COUNTER_CODE] [varchar](10) NOT NULL,
	[CHECKIN_LINE_CODE] [varchar](10) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CHECKIN_GROUP_MAPPING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CHECKIN_GROUP_MAPPING](
	[CHECKIN_GROUP_CODE] [varchar](10) NOT NULL,
	[CHECKIN_LINE_CODE] [varchar](10) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CHECKIN_GROUP_RESOURCE_MAPPING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CHECKIN_GROUP_RESOURCE_MAPPING](
	[CHECKIN_GROUP_CODE] [varchar](10) NOT NULL,
	[ALLOC_RESOURCE_CODE] [varchar](10) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CHECKIN_LINE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CHECKIN_LINE](
	[CODE] [varchar](10) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](200) NULL,
 CONSTRAINT [PK_CHECKIN_COUTNER] PRIMARY KEY CLUSTERED 
(
	[CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CHECKIN_LINE_GROUP]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CHECKIN_LINE_GROUP](
	[CODE] [varchar](10) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](200) NULL,
 CONSTRAINT [PK_CHECKIN_COUNTER_GROUP] PRIMARY KEY CLUSTERED 
(
	[CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConditionEvent]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConditionEvent](
	[EventID] [uniqueidentifier] NOT NULL,
	[SourceName] [nvarchar](200) NULL,
	[SourcePath] [nvarchar](512) NULL,
	[SourceID] [uniqueidentifier] NULL,
	[ServerName] [nvarchar](50) NULL,
	[TicksTimeStamp] [bigint] NULL,
	[EventTimeStamp] [datetime] NULL,
	[EventCategory] [nvarchar](50) NULL,
	[Severity] [int] NULL,
	[Priority] [int] NULL,
	[Message] [nvarchar](512) NULL,
	[ConditionName] [nvarchar](50) NULL,
	[SubConditionName] [nvarchar](50) NULL,
	[AlarmClass] [nvarchar](40) NULL,
	[Active] [bit] NULL,
	[Acked] [bit] NULL,
	[EffDisabled] [bit] NULL,
	[Disabled] [bit] NULL,
	[EffSuppressed] [bit] NULL,
	[Suppressed] [bit] NULL,
	[PersonID] [nvarchar](50) NULL,
	[ChangeMask] [int] NULL,
	[InputValue] [float] NULL,
	[LimitValue] [float] NULL,
	[Quality] [int] NULL,
	[EventAssociationID] [uniqueidentifier] NULL,
	[UserComment] [nvarchar](512) NULL,
	[UserComputerID] [nvarchar](64) NULL,
	[Tag1Value] [nvarchar](128) NULL,
	[Tag2Value] [nvarchar](128) NULL,
	[Tag3Value] [nvarchar](128) NULL,
	[Tag4Value] [nvarchar](128) NULL,
	[Shelved] [bit] NULL,
	[AutoUnshelveTime] [datetime] NULL,
 CONSTRAINT [PK_101_CondEvent] PRIMARY KEY NONCLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CONTROLPOINT_LIST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CONTROLPOINT_LIST](
	[ID] [varchar](10) NOT NULL,
	[DESCRIPTION] [varchar](50) NULL,
	[CONTROLPOINT_LEVEL] [varchar](10) NULL,
 CONSTRAINT [PK_CONTROLPOINT_LIST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[COUNTRY]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[COUNTRY](
	[Code] [varchar](5) NOT NULL,
	[Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DESTINATION_CHUTE_MAPPING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DESTINATION_CHUTE_MAPPING](
	[DESTINATION] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATIONS] [varchar](20) NOT NULL,
	[STATUS] [varchar](2) NOT NULL,
	[RECIRCULATE] [bit] NOT NULL,
	[LOCATION_ID] [varchar](4) NULL,
 CONSTRAINT [PK_DESTINATION_CHUTE_MAPPING] PRIMARY KEY CLUSTERED 
(
	[DESTINATION] ASC,
	[SUBSYSTEM] ASC,
	[LOCATIONS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DESTINATION_GROUPING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DESTINATION_GROUPING](
	[GROUP_NAME] [varchar](10) NOT NULL,
	[DESTINATION] [varchar](10) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DESTINATION_PATH_MAPPING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DESTINATION_PATH_MAPPING](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[PATH] [varchar](50) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DESTINATIONS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DESTINATIONS](
	[DESTINATION] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
	[IS_AVAILABLE] [bit] NOT NULL,
	[LOCATION_ID] [char](4) NULL,
 CONSTRAINT [PK_DESTINATION] PRIMARY KEY CLUSTERED 
(
	[DESTINATION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DESTINATIONS_LIST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DESTINATIONS_LIST](
	[ID] [varchar](10) NOT NULL,
	[DESCRIPTION] [varchar](50) NULL,
	[DESTINATIONS_LEVEL] [varchar](10) NULL,
 CONSTRAINT [PK_DESTINATIONS_LIST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EVENT_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EVENT_TYPES](
	[TYPE] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_EVENT_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EXCEPTION_TYPE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EXCEPTION_TYPE](
	[TYPE] [nvarchar](10) NOT NULL,
	[SOURCE] [nvarchar](10) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EXCEPTIONS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EXCEPTIONS](
	[NAME] [varchar](50) NOT NULL,
	[DESCRIPTION] [varchar](100) NULL,
	[EXCEPTION_TYPE] [varchar](10) NOT NULL,
	[IS_HIDDEN] [bit] NOT NULL,
 CONSTRAINT [PK_EXCEPTIONS] PRIMARY KEY CLUSTERED 
(
	[NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FALLBACK_MAPPING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FALLBACK_MAPPING](
	[ID] [varchar](2) NOT NULL,
	[DESTINATION] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
	[SYS_ACTION] [varchar](50) NULL,
	[IS_CHANGED] [bit] NOT NULL,
 CONSTRAINT [PK_FALLBACK_MAPPING] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FIDS_HISTORY]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FIDS_HISTORY](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[FLIGHT] [varchar](10) NOT NULL,
	[DESCRIPTION] [varchar](1000) NOT NULL,
	[SDO] [datetime] NOT NULL,
	[STO] [varchar](4) NOT NULL,
 CONSTRAINT [PK_FIDS_HISTORY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHT_ALLOC_COMMENT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHT_ALLOC_COMMENT](
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[SDO] [datetime] NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[DESCRIPTION] [varchar](350) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
 CONSTRAINT [PK_FLIGHT_ALLOC_COMMENT] PRIMARY KEY CLUSTERED 
(
	[AIRLINE] ASC,
	[FLIGHT_NUMBER] ASC,
	[SDO] ASC,
	[RESOURCE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHT_CANCEL]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHT_CANCEL](
	[TIME_STAMP] [datetime] NOT NULL,
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[FLIGHT_NUMBER_SUFFIX] [varchar](3) NOT NULL,
	[SDO] [datetime] NOT NULL,
	[STO] [varchar](4) NOT NULL,
	[EDO] [datetime] NULL,
	[ETO] [varchar](4) NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
 CONSTRAINT [PK_FLIGHT_CANCEL_1] PRIMARY KEY CLUSTERED 
(
	[AIRLINE] ASC,
	[FLIGHT_NUMBER] ASC,
	[SDO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHT_DELETE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHT_DELETE](
	[TIME_STAMP] [datetime] NOT NULL,
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[FLIGHT_NUMBER_SUFFIX] [varchar](3) NOT NULL,
	[SDO] [datetime] NOT NULL,
	[STO] [varchar](4) NOT NULL,
	[EDO] [datetime] NULL,
	[ETO] [varchar](4) NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
 CONSTRAINT [PK_FLIGHT_DELETE_1] PRIMARY KEY CLUSTERED 
(
	[AIRLINE] ASC,
	[FLIGHT_NUMBER] ASC,
	[SDO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHT_PLAN_ALLOC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHT_PLAN_ALLOC](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[SDO] [datetime] NOT NULL,
	[STO] [varchar](4) NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[WEEKDAY] [char](1) NOT NULL,
	[EDO] [datetime] NULL,
	[ETO] [varchar](4) NULL,
	[ADO] [datetime] NULL,
	[ATO] [varchar](4) NULL,
	[IDO] [datetime] NULL,
	[ITO] [varchar](4) NULL,
	[TRAVEL_CLASS] [varchar](1) NOT NULL,
	[FLIGHT_DESTINATION] [varchar](3) NOT NULL,
	[BAG_TYPE] [varchar](10) NOT NULL,
	[TRANSFER] [varchar](10) NOT NULL,
	[COMMENT_ID] [bigint] NULL,
	[HIGH_RISK] [char](1) NULL,
	[HBS_LEVEL_REQUIRED] [char](1) NULL,
	[EARLY_OPEN_OFFSET] [varchar](5) NULL,
	[EARLY_OPEN_ENABLED] [bit] NULL,
	[ALLOC_OPEN_OFFSET] [varchar](5) NOT NULL,
	[ALLOC_OPEN_RELATED] [varchar](4) NOT NULL,
	[ALLOC_CLOSE_OFFSET] [varchar](5) NOT NULL,
	[ALLOC_CLOSE_RELATED] [varchar](4) NOT NULL,
	[RUSH_DURATION] [varchar](5) NULL,
	[SCHEME_TYPE] [varchar](2) NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[HOUR] [varchar](2) NULL,
	[IS_MANUAL_CLOSE] [bit] NOT NULL,
	[IS_CLOSED] [bit] NOT NULL,
	[IS_MISS_TEMPLATE_FLIGHT] [bit] NOT NULL,
 CONSTRAINT [PK_FLIGHT_PLAN_ALLOC] PRIMARY KEY CLUSTERED 
(
	[AIRLINE] ASC,
	[FLIGHT_NUMBER] ASC,
	[SDO] ASC,
	[RESOURCE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHT_PLAN_ALLOC_ERROR]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHT_PLAN_ALLOC_ERROR](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[SDO] [datetime] NOT NULL,
	[STO] [varchar](4) NOT NULL,
	[EDO] [datetime] NULL,
	[ETO] [varchar](4) NULL,
	[ALLOC_OPEN_OFFSET] [varchar](5) NOT NULL,
	[ALLOC_CLOSE_OFFSET] [varchar](5) NOT NULL,
	[RUSH_DURATION] [varchar](5) NOT NULL,
	[ALLOC_OPEN_TIME] [datetime] NULL,
	[ALLOC_CLOSE_TIME] [datetime] NULL,
	[RESOURCE] [varchar](10) NULL,
	[DESCRIPTION] [varchar](200) NULL,
	[ERROR_TYPE] [varchar](2) NOT NULL,
 CONSTRAINT [PK_FLIGHT_PLAN_ALLOC_ERROR] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHT_PLAN_ALLOC_ERROR_TYPE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHT_PLAN_ALLOC_ERROR_TYPE](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [varchar](100) NULL,
 CONSTRAINT [PK_FLIGHT_PLAN_ALLOC_ERROR_TYPE] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHT_PLAN_ERROR]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FLIGHT_PLAN_ERROR](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DATA_ID] [bigint] NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[DESCRIPTION] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_FLIGHT_PLAN_ERROR] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FLIGHT_PLAN_SORTING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHT_PLAN_SORTING](
	[TIME_STAMP] [datetime] NOT NULL,
	[DATA_ID] [bigint] NULL,
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[FLIGHT_NUMBER_SUFFIX] [varchar](3) NULL,
	[HANDLER] [varchar](20) NULL,
	[SDO] [datetime] NOT NULL,
	[STO] [varchar](4) NULL,
	[EDO] [datetime] NULL,
	[ETO] [varchar](4) NULL,
	[ADO] [datetime] NULL,
	[ATO] [varchar](4) NULL,
	[IDO] [datetime] NULL,
	[ITO] [varchar](4) NULL,
	[BLOCK_OFF_TIME] [varchar](14) NULL,
	[FINAL_DEST] [varchar](3) NULL,
	[DEST1] [varchar](3) NULL,
	[DEST2] [varchar](3) NULL,
	[DEST3] [varchar](3) NULL,
	[DEST4] [varchar](3) NULL,
	[DEST5] [varchar](3) NULL,
	[CANCELLED] [varchar](1) NULL,
	[AIRCRAFT_TYPE] [varchar](4) NULL,
	[HANDLER_SPECIFIC_DESC] [varchar](12) NULL,
	[AIRCRAFT_VERSION] [varchar](12) NULL,
	[TERMINAL] [varchar](5) NULL,
	[CHECKIN_AREA] [varchar](10) NULL,
	[CHECKIN_STATUS] [varchar](10) NULL,
	[PUBLIC_REMARK_CODE] [varchar](10) NULL,
	[PIER] [varchar](5) NULL,
	[GATE] [varchar](5) NULL,
	[PARKING_STAND] [varchar](5) NULL,
	[NATURE] [varchar](15) NULL,
	[SORTING_DEST1] [varchar](10) NULL,
	[SORTING_DEST2] [varchar](10) NULL,
	[GENERAL_PURPOSE] [varchar](40) NULL,
	[FI_EXCEPTION] [varchar](10) NULL,
	[MASTER_AIRLINE] [varchar](3) NULL,
	[MASTER_FLIGHT_NUMBER] [varchar](5) NULL,
	[MASTER_FLIGHT_NUMBER_SUFFIX] [varchar](3) NULL,
	[MASTER_SDO] [varchar](8) NULL,
	[BOOKED_PAX] [varchar](20) NULL,
	[HBS_LEVEL_REQUIRED] [char](1) NULL,
	[WEEKDAY] [varchar](1) NULL,
	[HOUR] [varchar](10) NULL,
	[HIGH_RISK] [varchar](1) NULL,
	[ALLOC_OPEN_TIME] [datetime] NULL,
	[ALLOC_CLOSE_TIME] [datetime] NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
	[IS_ALLOCATED] [bit] NOT NULL,
	[CUSTOMS_REQUIRED] [bit] NOT NULL,
	[FLIGHT_TYPE] [varchar](1) NULL,
 CONSTRAINT [PK_FLIGHT_PLAN_SORTING] PRIMARY KEY CLUSTERED 
(
	[AIRLINE] ASC,
	[FLIGHT_NUMBER] ASC,
	[SDO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHT_PLANS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHT_PLANS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[RAW_DATA] [varchar](5000) NOT NULL,
	[ERROR_INDICATOR] [char](1) NULL,
 CONSTRAINT [PK_FLIGHT_PLANS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHT_RESOURCE_CHANGE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHT_RESOURCE_CHANGE](
	[TIME_STAMP] [datetime] NOT NULL,
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[FLIGHT_NUMBER_SUFFIX] [varchar](3) NOT NULL,
	[SDO] [datetime] NOT NULL,
	[STO] [varchar](4) NOT NULL,
	[EDO] [datetime] NULL,
	[ETO] [varchar](4) NULL,
	[CURRENT_RESOURCE] [varchar](10) NOT NULL,
	[NEW_RESOURCE] [varchar](10) NOT NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
 CONSTRAINT [PK_FLIGHT_RESOURCE_CHANGE] PRIMARY KEY CLUSTERED 
(
	[AIRLINE] ASC,
	[FLIGHT_NUMBER] ASC,
	[SDO] ASC,
	[CURRENT_RESOURCE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHT_TYPE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHT_TYPE](
	[TYPE] [varchar](1) NOT NULL,
	[DESCRIPTION] [varchar](100) NOT NULL,
 CONSTRAINT [PK_FLIGHT_TYPE] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FLIGHTS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FLIGHTS](
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[AIRLINE] [varchar](3) NOT NULL,
	[AIRCRAFT_TYPE] [varchar](10) NOT NULL,
	[FLIGHT_DESC] [varchar](50) NOT NULL,
	[HIGH_RISK] [char](1) NOT NULL,
	[HBS_LEVEL_REQUIRED] [char](1) NULL,
 CONSTRAINT [PK_FLIGHTS] PRIMARY KEY CLUSTERED 
(
	[AIRLINE] ASC,
	[FLIGHT_NUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FOUR_DIGITS_FALLBACK_MAPPING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FOUR_DIGITS_FALLBACK_MAPPING](
	[ID] [varchar](4) NOT NULL,
	[DESTINATION] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
	[SYS_ACTION] [varchar](50) NULL,
	[IS_CHANGED] [bit] NOT NULL,
 CONSTRAINT [PK_FOUR_DIGITS_FALLBACK_MAPPING] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FTAEInstance]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FTAEInstance](
	[lFTAEInstanceId] [int] NOT NULL,
	[sProduct] [varchar](255) NOT NULL,
	[sCatalogNumber] [varchar](255) NULL,
	[lMajorVersion] [int] NOT NULL,
	[lMinorVersion] [int] NOT NULL,
	[lPatchVersion] [int] NOT NULL,
	[lBuildVersion] [int] NULL,
	[sVersionString] [varchar](20) NULL,
	[sComments] [varchar](255) NULL,
	[lUpdatedById] [int] NULL,
	[tEntered] [datetime] NOT NULL,
	[tModified] [datetime] NULL,
 CONSTRAINT [PK_FTAEInstance] PRIMARY KEY CLUSTERED 
(
	[lFTAEInstanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FUNCTION_ALLOC_GANTT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FUNCTION_ALLOC_GANTT](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[FUNCTION_TYPE] [varchar](4) NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[ALLOC_OPEN_DATETIME] [datetime] NOT NULL,
	[ALLOC_CLOSE_DATETIME] [datetime] NOT NULL,
	[IS_CLOSED] [bit] NOT NULL,
	[EXCEPTION] [varchar](10) NULL,
 CONSTRAINT [PK_FUNCTION_ALLOC_GANTT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FUNCTION_ALLOC_LIST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FUNCTION_ALLOC_LIST](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[FUNCTION_TYPE] [varchar](4) NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[IS_ENABLED] [bit] NOT NULL,
	[SYS_TAB_NAME] [varchar](20) NOT NULL,
	[SYS_ACTION] [varchar](50) NULL,
	[IS_CHANGED] [bit] NOT NULL,
 CONSTRAINT [PK_FUNCTION_ALLOC_LIST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FUNCTION_TYPE_GROUPS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FUNCTION_TYPE_GROUPS](
	[GROUP] [varchar](5) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_FUNCTION_TYPE_GROUPS] PRIMARY KEY CLUSTERED 
(
	[GROUP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FUNCTION_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FUNCTION_TYPES](
	[TYPE] [varchar](4) NOT NULL,
	[GROUP] [varchar](5) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
	[IS_ALLOCATED] [bit] NOT NULL,
	[IS_ENABLED] [bit] NOT NULL,
 CONSTRAINT [PK_FUNCTION_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GID_USED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GID_USED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[BAG_TYPE] [varchar](2) NOT NULL,
 CONSTRAINT [PK_GID_USED] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GROUND_HANDLER]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GROUND_HANDLER](
	[HANDLER] [varchar](3) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[DESTINATION1] [varchar](10) NULL,
	[DESTINATION2] [varchar](10) NULL,
	[DESCRIPTION] [varchar](100) NULL,
 CONSTRAINT [PK_GROUND_HANDLER] PRIMARY KEY CLUSTERED 
(
	[HANDLER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HANDLER]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HANDLER](
	[HANDLER] [varchar](1) NOT NULL,
	[NAME] [varchar](15) NOT NULL,
 CONSTRAINT [PK_HANDLER] PRIMARY KEY CLUSTERED 
(
	[HANDLER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HIGH_RISK_NEEDED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HIGH_RISK_NEEDED](
	[VALUE] [varchar](1) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_HIGH_RISK_NEEDED] PRIMARY KEY CLUSTERED 
(
	[VALUE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HOUR_CONFIG]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HOUR_CONFIG](
	[HOURIND] [varchar](2) NOT NULL,
 CONSTRAINT [PK_HOURID] PRIMARY KEY CLUSTERED 
(
	[HOURIND] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IFS_INDIVIDUAL_FLIGHT_DETAIL]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IFS_INDIVIDUAL_FLIGHT_DETAIL](
	[LICENSE_PLATE] [varchar](10) NULL,
	[PAX_NAME] [varchar](200) NULL,
	[BSM_TIME_STAMP] [datetime] NULL,
	[TAG_READ_TIME] [datetime] NULL,
	[SORTED_TIMESTAMP] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_1500P]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_1500P](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[XRAY_ID] [varchar](10) NOT NULL,
	[BIT_STATION] [varchar](20) NOT NULL,
	[ETD_STATION] [varchar](20) NOT NULL,
	[PLC_TIMESTAMP] [datetime] NOT NULL,
	[BAG_STATUS] [varchar](2) NOT NULL,
 CONSTRAINT [PK_ITEM_1500P] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_1500P_BAGSTATS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_1500P_BAGSTATS](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ITEM_1500P_BAGSTATS] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_ENCODED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_ENCODED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[ENCODING_TYPE] [varchar](2) NOT NULL,
	[PLC_INDEX] [varchar](10) NOT NULL,
	[DEST] [varchar](10) NOT NULL,
 CONSTRAINT [PK_ITEM_ENCODED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_ENCODING_REQUEST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_ENCODING_REQUEST](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NULL,
	[AIRLINE] [varchar](3) NULL,
	[FLIGHT_NUMBER] [varchar](5) NULL,
	[SDO] [varchar](10) NULL,
	[DESTINATION] [varchar](20) NULL,
	[ENCODING_TYPE] [varchar](2) NULL,
	[PLC_IDX] [varchar](10) NULL,
 CONSTRAINT [PK_ITEM_ENCODING_REQUEST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_ENCODING_REQUEST_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_ENCODING_REQUEST_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ITEM_ENCODING_REQUEST_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_LOST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_LOST](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
 CONSTRAINT [PK_ITEM_LOST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_MEASURED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_MEASURED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](10) NOT NULL,
	[LENGTH] [decimal](18, 2) NOT NULL,
	[WIDTH] [decimal](18, 2) NOT NULL,
	[HEIGHT] [decimal](18, 2) NOT NULL,
	[TYPE] [varchar](2) NOT NULL,
 CONSTRAINT [PK_ITEM_MEASURED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_MEASURED_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_MEASURED_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ITEM_SCREENED_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_PROCEED_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_PROCEED_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ITEM_PROCEED_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_PROCEEDED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_PROCEEDED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PROCEED_LOCATION] [varchar](20) NOT NULL,
	[PROCEED_TYPE] [varchar](2) NOT NULL,
 CONSTRAINT [PK_ITEM_PROCEEDED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_READY]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_READY](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](10) NOT NULL,
	[PLC_INDEX] [varchar](10) NOT NULL,
 CONSTRAINT [PK_ITEM_READY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_REDIRECT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_REDIRECT](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[DESTINATION_1] [varchar](10) NOT NULL,
	[DESTINATION_2] [varchar](10) NOT NULL,
	[REASON] [varchar](2) NOT NULL,
	[PLC_INDEX] [varchar](10) NOT NULL,
 CONSTRAINT [PK_ITEM_REDIRECT] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_REMOVED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_REMOVED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](10) NOT NULL,
	[PLC_INDEX] [nchar](10) NULL,
 CONSTRAINT [PK_ITEM_REMOVED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_SCAN_STATUS_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_SCAN_STATUS_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ITEM_SCAN_STATUS_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_SCANNED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_SCANNED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[LICENSE_PLATE1] [varchar](10) NOT NULL,
	[LICENSE_PLATE2] [varchar](10) NOT NULL,
	[STATUS_TYPE] [varchar](2) NOT NULL,
	[PLC_IDX] [int] NOT NULL,
	[HEAD01] [int] NULL,
	[HEAD02] [int] NULL,
	[HEAD03] [int] NULL,
	[HEAD04] [int] NULL,
	[HEAD05] [int] NULL,
	[HEAD06] [int] NULL,
	[HEAD07] [int] NULL,
	[HEAD08] [int] NULL,
	[HEAD09] [int] NULL,
	[HEAD10] [int] NULL,
	[HEAD11] [int] NULL,
	[HEAD12] [int] NULL,
	[HEAD13] [int] NULL,
	[HEAD14] [int] NULL,
	[HEAD15] [int] NULL,
	[HEAD16] [int] NULL,
	[HEAD17] [int] NULL,
	[HEAD18] [int] NULL,
	[HEAD19] [int] NULL,
	[HEAD20] [int] NULL,
 CONSTRAINT [PK_ITEM_SCANNED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_SCREEN_RESULT_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_SCREEN_RESULT_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
	[SHORT_DESCRIPTION] [nvarchar](50) NULL,
 CONSTRAINT [PK_ITEM_SCREEN_RESULT_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_SCREENED]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_SCREENED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[SCREEN_LEVEL] [char](1) NOT NULL,
	[RESULT_TYPE] [varchar](2) NOT NULL,
	[PLC_IDX] [varchar](10) NOT NULL,
 CONSTRAINT [PK_ITEM_SCREEN] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_SORTATION_EVENT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_SORTATION_EVENT](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[SORT_DESTINATION] [varchar](10) NOT NULL,
	[SORT_EVENT_TYPE] [varchar](2) NOT NULL,
	[PLC_INDEX] [varchar](10) NOT NULL,
 CONSTRAINT [PK_ITEM_SORTATION_EVENT] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_SORTATION_EVENT_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_SORTATION_EVENT_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ITEM_SORTATION_EVENT_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ITEM_TRACKING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ITEM_TRACKING](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PLC_TIMESTAMP] [datetime] NOT NULL,
 CONSTRAINT [PK_ITEM_TRACK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LOCATION_STATUS_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LOCATION_STATUS_TYPES](
	[TYPE] [int] NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
	[COLOR_CODE] [nvarchar](6) NULL,
	[BLINKING] [bit] NULL,
 CONSTRAINT [PK_LOCATION_STATUS_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LOCATIONS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOCATIONS](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
	[ASSIGNABLE] [char](1) NULL,
	[TRACKED] [bit] NOT NULL,
	[CONVEYOR_LEVEL] [varchar](10) NULL,
	[LOCATION_ID] [varchar](4) NULL,
	[INTERNAL_LOC] [varchar](20) NULL,
	[STATUS_TYPE] [int] NULL,
 CONSTRAINT [PK_LOCATIONS] PRIMARY KEY CLUSTERED 
(
	[LOCATION] ASC,
	[SUBSYSTEM] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[locations_bak_gwy]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[locations_bak_gwy](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
	[ASSIGNABLE] [char](1) NULL,
	[TRACKED] [bit] NOT NULL,
	[CONVEYOR_LEVEL] [varchar](10) NULL,
	[LOCATION_ID] [varchar](4) NULL,
	[INTERNAL_LOC] [varchar](20) NULL,
	[STATUS_TYPE] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[locations_bak_test]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[locations_bak_test](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
	[ASSIGNABLE] [char](1) NULL,
	[TRACKED] [bit] NOT NULL,
	[CONVEYOR_LEVEL] [varchar](10) NULL,
	[LOCATION_ID] [varchar](4) NULL,
	[INTERNAL_LOC] [varchar](20) NULL,
	[STATUS_TYPE] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LOCATIONS_TEMP1]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOCATIONS_TEMP1](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
	[ASSIGNABLE] [char](1) NULL,
	[STATUS_TYPE] [varchar](2) NULL,
	[TRACKED] [bit] NOT NULL,
	[CONVEYOR_LEVEL] [varchar](10) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LOCATIONS_TEMP2]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOCATIONS_TEMP2](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
	[ASSIGNABLE] [char](1) NULL,
	[STATUS_TYPE] [varchar](2) NULL,
	[TRACKED] [bit] NOT NULL,
	[CONVEYOR_LEVEL] [varchar](10) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LOG_AIRPORT_CODE_FUNCTION_ALLOC_INFO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOG_AIRPORT_CODE_FUNCTION_ALLOC_INFO](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[AIRPORT_CODE] [varchar](4) NOT NULL,
	[DUMP_DEST] [varchar](10) NOT NULL,
	[NO_ALLOC_DEST] [varchar](10) NOT NULL,
	[NO_CARRIER_DEST] [varchar](10) NOT NULL,
	[NO_READ_DEST] [varchar](10) NOT NULL,
 CONSTRAINT [PK_AIRPORT_CODE_FUNCTION_ALLOC_INFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LOG_CARRIER_ALLOC_INFO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOG_CARRIER_ALLOC_INFO](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[NO_OF_CARRIER] [varchar](2) NOT NULL,
	[CARRIER_CODE_1] [varchar](3) NOT NULL,
	[SORT_DEVICE_1] [varchar](10) NOT NULL,
	[CARRIER_CODE_2] [varchar](3) NULL,
	[SORT_DEVICE_2] [varchar](10) NULL,
	[CARRIER_CODE_3] [varchar](3) NULL,
	[SORT_DEVICE_3] [varchar](10) NULL,
	[CARRIER_CODE_4] [varchar](3) NULL,
	[SORT_DEVICE_4] [varchar](10) NULL,
	[CARRIER_CODE_5] [varchar](3) NULL,
	[SORT_DEVICE_5] [varchar](10) NULL,
	[CARRIER_CODE_6] [varchar](3) NULL,
	[SORT_DEVICE_6] [varchar](10) NULL,
	[CARRIER_CODE_7] [varchar](3) NULL,
	[SORT_DEVICE_7] [varchar](10) NULL,
	[CARRIER_CODE_8] [varchar](3) NULL,
	[SORT_DEVICE_8] [varchar](10) NULL,
	[CARRIER_CODE_9] [varchar](3) NULL,
	[SORT_DEVICE_9] [varchar](10) NULL,
	[CARRIER_CODE_10] [varchar](3) NULL,
	[SORT_DEVICE_10] [varchar](10) NULL,
 CONSTRAINT [PK_CARRIER_ALLOC_INFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LOG_FALLBACK_TAG_INFO]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOG_FALLBACK_TAG_INFO](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[NO_OF_FALLBACK] [varchar](2) NOT NULL,
	[FALLBACK_NO_1] [varchar](2) NOT NULL,
	[DESTINATION_1] [varchar](10) NOT NULL,
	[FALLBACK_NO_2] [varchar](2) NULL,
	[DESTINATION_2] [varchar](10) NULL,
	[FALLBACK_NO_3] [varchar](2) NULL,
	[DESTINATION_3] [varchar](10) NULL,
	[FALLBACK_NO_4] [varchar](2) NULL,
	[DESTINATION_4] [varchar](10) NULL,
	[FALLBACK_NO_5] [varchar](2) NULL,
	[DESTINATION_5] [varchar](10) NULL,
	[FALLBACK_NO_6] [varchar](2) NULL,
	[DESTINATION_6] [varchar](10) NULL,
	[FALLBACK_NO_7] [varchar](2) NULL,
	[DESTINATION_7] [varchar](10) NULL,
	[FALLBACK_NO_8] [varchar](2) NULL,
	[DESTINATION_8] [varchar](10) NULL,
	[FALLBACK_NO_9] [varchar](2) NULL,
	[DESTINATION_9] [varchar](10) NULL,
	[FALLBACK_NO_10] [varchar](2) NULL,
	[DESTINATION_10] [varchar](10) NULL,
 CONSTRAINT [PK_FALLBACK_TAG_INFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LOG_FOUR_DIGITS_FALLBACK_TAG]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LOG_FOUR_DIGITS_FALLBACK_TAG](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[NO_OF_TAG] [varchar](2) NOT NULL,
	[TAG_NO_1] [varchar](4) NOT NULL,
	[DESTINATION_1] [varchar](10) NOT NULL,
	[TAG_NO_2] [varchar](4) NULL,
	[DESTINATION_2] [varchar](10) NULL,
	[TAG_NO_3] [varchar](4) NULL,
	[DESTINATION_3] [varchar](10) NULL,
	[TAG_NO_4] [varchar](4) NULL,
	[DESTINATION_4] [varchar](10) NULL,
	[TAG_NO_5] [varchar](4) NULL,
	[DESTINATION_5] [varchar](10) NULL,
	[TAG_NO_6] [varchar](4) NULL,
	[DESTINATION_6] [varchar](10) NULL,
	[TAG_NO_7] [varchar](4) NULL,
	[DESTINATION_7] [varchar](10) NULL,
	[TAG_NO_8] [varchar](4) NULL,
	[DESTINATION_8] [varchar](10) NULL,
	[TAG_NO_9] [varchar](4) NULL,
	[DESTINATION_9] [varchar](10) NULL,
	[TAG_NO_10] [varchar](4) NULL,
	[DESTINATION_10] [varchar](10) NULL,
 CONSTRAINT [PK_FOUR_PIER_TAG_INFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_ALARMS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_ALARMS](
	[ALM_NATIVETIMEIN] [datetime] NULL,
	[ALM_NATIVETIMELAST] [datetime] NULL,
	[ALM_STARTTIME] [datetime] NULL,
	[ALM_ENDTIME] [datetime] NULL,
	[ALM_LOGNODENAME] [varchar](10) NULL,
	[ALM_PHYSLNODE] [varchar](10) NULL,
	[ALM_TAGNAME] [varchar](30) NULL,
	[ALM_TAGDESC] [nvarchar](40) NULL,
	[ALM_VALUE] [varchar](40) NULL,
	[ALM_UNIT] [varchar](13) NULL,
	[ALM_MSGTYPE] [varchar](11) NULL,
	[ALM_MSGDESC] [nvarchar](480) NULL,
	[ALM_MSGID1] [varchar](80) NULL,
	[ALM_MSGID2] [varchar](80) NULL,
	[ALM_ALMSTATUS] [varchar](9) NULL,
	[ALM_ALMPRIORITY] [varchar](10) NULL,
	[ALM_ALMAREA] [varchar](500) NULL,
	[ALM_ALMEXTFLD1] [varchar](80) NULL,
	[ALM_ALMEXTFLD2] [varchar](80) NULL,
	[ALM_OPNAME] [varchar](32) NULL,
	[ALM_OPFULLNAME] [varchar](80) NULL,
	[ALM_OPNODE] [varchar](10) NULL,
	[ALM_PERFNAME] [varchar](32) NULL,
	[ALM_PERFFULLNAME] [varchar](80) NULL,
	[ALM_PERFBYCOMMENT] [varchar](170) NULL,
	[ALM_VERNAME] [varchar](32) NULL,
	[ALM_VERFULLNAME] [varchar](80) NULL,
	[ALM_VERBYCOMMENT] [varchar](170) NULL,
	[ALM_DATEIN] [varchar](12) NULL,
	[ALM_TIMEIN] [varchar](15) NULL,
	[ALM_DATELAST] [varchar](12) NULL,
	[ALM_TIMELAST] [varchar](15) NULL,
	[ALM_ALMAREA1] [varchar](80) NULL,
	[ALM_ALMAREA2] [varchar](80) NULL,
	[ALM_UNCERTAIN] [int] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_AUDIT_LOGS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_AUDIT_LOGS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[MSG_DESC] [nvarchar](480) NULL,
	[MSG_TYPE] [nvarchar](50) NULL,
	[OP_NAME] [nvarchar](32) NULL,
	[OP_FULLNAME] [nvarchar](80) NULL,
	[IFIX_NODE] [varchar](15) NULL,
 CONSTRAINT [PK_MDS_AUDIT_LOGS] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_BHS_ALARMS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_BHS_ALARMS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[EQUIPMENT_ID] [varchar](20) NOT NULL,
	[ALARM_TYPE] [varchar](30) NOT NULL,
	[ALARM_DESCRIPTION] [varchar](100) NOT NULL,
	[ALARM_STATUS] [bit] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_CONDITION_EVENT_LOGS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_CONDITION_EVENT_LOGS](
	[EventID] [uniqueidentifier] NOT NULL,
	[SourceName] [nvarchar](200) NULL,
	[SourcePath] [nvarchar](512) NULL,
	[SourceID] [uniqueidentifier] NULL,
	[ServerName] [nvarchar](50) NULL,
	[TicksTimeStamp] [bigint] NULL,
	[EventTimeStamp] [datetime] NULL,
	[EventCategory] [nvarchar](50) NULL,
	[Severity] [int] NULL,
	[Priority] [int] NULL,
	[Message] [nvarchar](512) NULL,
	[ConditionName] [nvarchar](50) NULL,
	[SubConditionName] [nvarchar](50) NULL,
	[AlarmClass] [nvarchar](40) NULL,
	[Active] [bit] NULL,
	[Acked] [bit] NULL,
	[EffDisabled] [bit] NULL,
	[Disabled] [bit] NULL,
	[EffSuppressed] [bit] NULL,
	[Suppressed] [bit] NULL,
	[PersonID] [nvarchar](50) NULL,
	[ChangeMask] [int] NULL,
	[InputValue] [float] NULL,
	[LimitValue] [float] NULL,
	[Quality] [int] NULL,
	[EventAssociationID] [uniqueidentifier] NULL,
	[UserComment] [nvarchar](512) NULL,
	[UserComputerID] [nvarchar](64) NULL,
	[Tag1Value] [nvarchar](128) NULL,
	[Tag2Value] [nvarchar](128) NULL,
	[Tag3Value] [nvarchar](128) NULL,
	[Tag4Value] [nvarchar](128) NULL,
 CONSTRAINT [PK_101_CondEventLogs] PRIMARY KEY NONCLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_COUNT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_COUNT](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[COUNTER_ID] [varchar](50) NOT NULL,
	[PREVIOUS_COUNT] [int] NOT NULL,
	[CURRENT_COUNT] [int] NOT NULL,
	[DIFFERENT] [int] NOT NULL,
	[IFIX_NODE] [varchar](10) NULL,
 CONSTRAINT [PK_MDS_BAG_COUNT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_COUNT_NUM]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_COUNT_NUM](
	[DateAndTime] [datetime] NULL,
	[Millitm] [smallint] NULL,
	[TagName] [nvarchar](255) NULL,
	[Val] [float] NULL,
	[Status] [nvarchar](1) NULL,
	[Marker] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_COUNT_NUM_LOG]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_COUNT_NUM_LOG](
	[DateAndTime] [datetime] NULL,
	[Millitm] [smallint] NULL,
	[TagName] [nvarchar](255) NULL,
	[Val] [float] NULL,
	[Status] [nvarchar](1) NULL,
	[Marker] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_COUNT_STR]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_COUNT_STR](
	[DateAndTime] [datetime] NULL,
	[Millitm] [smallint] NULL,
	[TagName] [nvarchar](255) NULL,
	[Val] [nvarchar](82) NULL,
	[Status] [nvarchar](1) NULL,
	[Marker] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_COUNTERS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_COUNTERS](
	[COUNTER_ID] [varchar](50) NOT NULL,
	[TYPE] [nchar](10) NULL,
	[TYPE_STATUS] [nchar](10) NULL,
	[LAST_UPDATE] [datetime] NULL,
	[PREVIOUS_COUNT] [int] NULL,
	[SUBSYSTEM] [varchar](20) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[DESCRIPTION] [varchar](50) NULL,
 CONSTRAINT [PK_MDS_BAG_COUNTERS] PRIMARY KEY CLUSTERED 
(
	[COUNTER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_DATA]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_DATA](
	[ALM_NATIVETIMEIN] [datetime] NULL,
	[ALM_NATIVETIMELAST] [datetime] NULL,
	[ALM_LOGNODENAME] [char](10) NULL,
	[ALM_PHYSLNODE] [char](10) NULL,
	[ALM_TAGNAME] [char](30) NULL,
	[ALM_TAGDESC] [char](40) NULL,
	[ALM_VALUE] [char](40) NULL,
	[ALM_UNIT] [char](13) NULL,
	[ALM_MSGTYPE] [char](11) NULL,
	[ALM_MSGDESC] [char](480) NULL,
	[ALM_MSGID] [uniqueidentifier] NULL,
	[ALM_ALMSTATUS] [char](9) NULL,
	[ALM_ALMPRIORITY] [char](10) NULL,
	[ALM_ALMAREA] [char](500) NULL,
	[ALM_ALMEXTFLD1] [char](80) NULL,
	[ALM_ALMEXTFLD2] [char](80) NULL,
	[ALM_OPNAME] [char](32) NULL,
	[ALM_OPFULLNAME] [char](80) NULL,
	[ALM_OPNODE] [char](10) NULL,
	[ALM_PERFNAME] [char](32) NULL,
	[ALM_PERFFULLNAME] [char](80) NULL,
	[ALM_PERFBYCOMMENT] [char](170) NULL,
	[ALM_VERNAME] [char](32) NULL,
	[ALM_VERFULLNAME] [char](80) NULL,
	[ALM_VERBYCOMMENT] [char](170) NULL,
	[ALM_DATEIN] [char](12) NULL,
	[ALM_TIMEIN] [char](15) NULL,
	[ALM_DATELAST] [char](12) NULL,
	[ALM_TIMELAST] [char](15) NULL,
	[ALM_ALMAREA1] [char](80) NULL,
	[ALM_ALMAREA2] [char](80) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_EVENTS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_EVENTS](
	[ALM_NATIVETIMEIN] [datetime] NULL,
	[ALM_NATIVETIMELAST] [datetime] NULL,
	[ALM_LOGNODENAME] [varchar](10) NULL,
	[ALM_PHYSLNODE] [varchar](10) NULL,
	[ALM_TAGNAME] [varchar](30) NULL,
	[ALM_TAGDESC] [nvarchar](40) NULL,
	[ALM_VALUE] [varchar](40) NULL,
	[ALM_UNIT] [varchar](13) NULL,
	[ALM_MSGTYPE] [varchar](11) NULL,
	[ALM_MSGDESC] [nvarchar](480) NULL,
	[ALM_MSGID] [uniqueidentifier] NULL,
	[ALM_ALMSTATUS] [varchar](9) NULL,
	[ALM_ALMPRIORITY] [varchar](10) NULL,
	[ALM_ALMAREA] [varchar](500) NULL,
	[ALM_ALMEXTFLD1] [varchar](80) NULL,
	[ALM_ALMEXTFLD2] [varchar](80) NULL,
	[ALM_OPNAME] [varchar](32) NULL,
	[ALM_OPFULLNAME] [varchar](80) NULL,
	[ALM_OPNODE] [varchar](10) NULL,
	[ALM_PERFNAME] [varchar](32) NULL,
	[ALM_PERFFULLNAME] [varchar](80) NULL,
	[ALM_PERFBYCOMMENT] [varchar](170) NULL,
	[ALM_VERNAME] [varchar](32) NULL,
	[ALM_VERFULLNAME] [varchar](80) NULL,
	[ALM_VERBYCOMMENT] [varchar](170) NULL,
	[ALM_DATEIN] [varchar](12) NULL,
	[ALM_TIMEIN] [varchar](15) NULL,
	[ALM_DATELAST] [varchar](12) NULL,
	[ALM_TIMELAST] [varchar](15) NULL,
	[ALM_ALMAREA1] [varchar](80) NULL,
	[ALM_ALMAREA2] [varchar](80) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_HBS_DATA]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_HBS_DATA](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[XRAYID] [varchar](20) NOT NULL,
	[SCREEN_LEVEL] [char](1) NOT NULL,
	[RESULT_TYPE] [varchar](2) NOT NULL,
	[PREVIOUS_COUNT] [int] NOT NULL,
	[CURRENT_COUNT] [int] NOT NULL,
	[DIFFERENT] [int] NOT NULL,
	[IFIX_NODE] [varchar](10) NULL,
 CONSTRAINT [PK_MDS_HBS_DATA] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_LOCATIONS_GWY]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_LOCATIONS_GWY](
	[SUBSYSTEM] [varchar](80) NULL,
	[LOCATION] [varchar](80) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_LOGS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_LOGS](
	[ALM_NATIVETIMEIN] [datetime] NULL,
	[ALM_NATIVETIMELAST] [datetime] NULL,
	[ALM_LOGNODENAME] [varchar](10) NULL,
	[ALM_PHYSLNODE] [varchar](10) NULL,
	[ALM_TAGNAME] [varchar](30) NULL,
	[ALM_TAGDESC] [nvarchar](40) NULL,
	[ALM_VALUE] [varchar](40) NULL,
	[ALM_UNIT] [varchar](13) NULL,
	[ALM_MSGTYPE] [varchar](11) NULL,
	[ALM_MSGDESC] [nvarchar](480) NULL,
	[ALM_MSGID] [uniqueidentifier] NULL,
	[ALM_ALMSTATUS] [varchar](9) NULL,
	[ALM_ALMPRIORITY] [varchar](10) NULL,
	[ALM_ALMAREA] [varchar](500) NULL,
	[ALM_ALMEXTFLD1] [varchar](80) NULL,
	[ALM_ALMEXTFLD2] [varchar](80) NULL,
	[ALM_OPNAME] [varchar](32) NULL,
	[ALM_OPFULLNAME] [varchar](80) NULL,
	[ALM_OPNODE] [varchar](10) NULL,
	[ALM_PERFNAME] [varchar](32) NULL,
	[ALM_PERFFULLNAME] [varchar](80) NULL,
	[ALM_PERFBYCOMMENT] [varchar](170) NULL,
	[ALM_VERNAME] [varchar](32) NULL,
	[ALM_VERFULLNAME] [varchar](80) NULL,
	[ALM_VERBYCOMMENT] [varchar](170) NULL,
	[ALM_DATEIN] [varchar](12) NULL,
	[ALM_TIMEIN] [varchar](15) NULL,
	[ALM_DATELAST] [varchar](12) NULL,
	[ALM_TIMELAST] [varchar](15) NULL,
	[ALM_ALMAREA1] [varchar](80) NULL,
	[ALM_ALMAREA2] [varchar](80) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_MAINTENANCE_STATUS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_MAINTENANCE_STATUS](
	[TIME_STAMP] [datetime] NOT NULL,
	[SUBSYSTEM] [varchar](20) NOT NULL,
	[EQUIP_ID] [varchar](20) NOT NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[CURRENT_VALUE] [int] NOT NULL,
	[TOTAL_VALUE] [int] NOT NULL,
	[UNIT] [nvarchar](10) NOT NULL,
	[IFIX_NODE] [varchar](15) NULL,
 CONSTRAINT [PK_MDS_MAINTENANCE_STATUS] PRIMARY KEY CLUSTERED 
(
	[SUBSYSTEM] ASC,
	[EQUIP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_STATUS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MDS_STATUS](
	[STATUS_ID] [nvarchar](200) NOT NULL,
	[TYPE] [nchar](10) NULL,
	[TYPE_STATUS] [nchar](10) NULL,
	[LAST_UPDATE] [datetime] NULL,
	[STATUS] [nvarchar](200) NULL,
	[SUBSYSTEM] [varchar](20) NULL,
	[LOCATION] [varchar](20) NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[DESCRIPTION] [varchar](50) NULL,
 CONSTRAINT [PK_MDS_STATUS] PRIMARY KEY CLUSTERED 
(
	[STATUS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MDS_STATUS_LK]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_STATUS_LK](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TYPE] [nchar](10) NULL,
	[TYPE_STATUS] [nchar](10) NULL,
	[DESC_TYPE] [nchar](10) NULL,
	[FIX] [nchar](10) NULL,
	[MIN] [int] NULL,
	[MAX] [int] NULL,
	[DESCRIPTION] [nchar](100) NULL,
 CONSTRAINT [PK_MDS_STATUS_LK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_STATUS_NUM]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_STATUS_NUM](
	[DateAndTime] [datetime] NULL,
	[Millitm] [smallint] NULL,
	[TagName] [nvarchar](255) NULL,
	[Val] [float] NULL,
	[Status] [nvarchar](1) NULL,
	[Marker] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_STATUS_STR]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_STATUS_STR](
	[DateAndTime] [datetime] NULL,
	[Millitm] [smallint] NULL,
	[TagName] [nvarchar](255) NULL,
	[Val] [nvarchar](82) NULL,
	[Status] [nvarchar](1) NULL,
	[Marker] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_TAG_EQUIP_IDX]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_TAG_EQUIP_IDX](
	[TagName] [nvarchar](255) NULL,
	[TagIndex] [smallint] NULL,
	[TagType] [smallint] NULL,
	[TagDataType] [smallint] NULL,
	[EQUIP_ID] [nchar](100) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_TAG_EQUIP_NUM]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_TAG_EQUIP_NUM](
	[DateAndTime] [datetime] NULL,
	[Millitm] [smallint] NULL,
	[TagIndex] [smallint] NULL,
	[Val] [float] NULL,
	[Status] [nvarchar](1) NULL,
	[Marker] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_TAG_EQUIP_STR]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_TAG_EQUIP_STR](
	[DateAndTime] [datetime] NULL,
	[Millitm] [smallint] NULL,
	[TagIndex] [smallint] NULL,
	[Val] [nvarchar](82) NULL,
	[Status] [nvarchar](1) NULL,
	[Marker] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_TAG_MES_IDX]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_TAG_MES_IDX](
	[TagName] [nvarchar](255) NULL,
	[TagIndex] [smallint] NULL,
	[TagType] [smallint] NULL,
	[TagDataType] [smallint] NULL,
	[TagEquipmentID] [nvarchar](20) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_TAG_MES_NUM]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_TAG_MES_NUM](
	[DateAndTime] [datetime] NULL,
	[Millitm] [smallint] NULL,
	[TagIndex] [smallint] NULL,
	[Val] [float] NULL,
	[Status] [nvarchar](1) NULL,
	[Marker] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_TAG_MES_STR]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_TAG_MES_STR](
	[DateAndTime] [datetime] NULL,
	[Millitm] [smallint] NULL,
	[TagIndex] [smallint] NULL,
	[Val] [nvarchar](82) NULL,
	[Status] [nvarchar](1) NULL,
	[Marker] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_TAG_NUM]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_TAG_NUM](
	[DateAndTime] [datetime] NULL,
	[Millitm] [smallint] NULL,
	[TagName] [nvarchar](255) NULL,
	[Val] [float] NULL,
	[Status] [nvarchar](1) NULL,
	[Marker] [nvarchar](1) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MDS_TAG_STATUS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDS_TAG_STATUS](
	[TAG_NAME] [nvarchar](50) NOT NULL,
	[TAG_DESC] [nvarchar](50) NULL,
	[ALMAREA1] [nchar](10) NULL,
	[ALMAREA2] [nchar](10) NULL,
	[ALMEXT1] [nchar](10) NULL,
	[ALMEXT2] [nchar](10) NULL,
	[A_ENAB] [nchar](10) NULL,
	[A_TYPE] [nchar](10) NULL,
	[EQUIP_TYPE] [nchar](10) NULL,
 CONSTRAINT [PK_MDS_TAG_STATUS] PRIMARY KEY CLUSTERED 
(
	[TAG_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MES_EVENT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MES_EVENT](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](10) NULL,
	[ACTION] [varchar](10) NOT NULL,
	[ACTION_DESC] [varchar](25) NULL,
	[MES_STATION] [varchar](16) NULL,
 CONSTRAINT [PK_MES_EVENT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_CBRA_CLEARLINE_DEVICE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_CBRA_CLEARLINE_DEVICE](
	[CBRA_ID] [varchar](20) NULL,
	[CLEARLINE_ID] [varchar](20) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_CBRA_ETD#2LOCATION_MAP]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_CBRA_ETD#2LOCATION_MAP](
	[LOCATION] [varchar](20) NULL,
	[ETD_STATION_NUM] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_DATE_BASIC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_DATE_BASIC](
	[DATE_BASIC_VALUE] [varchar](20) NOT NULL,
	[DATE_BASIC_LABEL] [varchar](20) NULL,
	[IS_DEFAULT] [bit] NULL,
 CONSTRAINT [PK_MIS_DATE_BASIC] PRIMARY KEY CLUSTERED 
(
	[DATE_BASIC_VALUE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_DEVICE_PLC_MAP]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_DEVICE_PLC_MAP](
	[EQUIP_SUBSYSTEM] [varchar](20) NULL,
	[PLC_ID] [varchar](20) NULL,
	[PLC_OTHERNAME] [varchar](20) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_EDS_SN2LOCATION_MAP]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_EDS_SN2LOCATION_MAP](
	[LOCATION] [varchar](20) NULL,
	[EDS_SN] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_EQUIP_LIVE_MONITOR]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_EQUIP_LIVE_MONITOR](
	[SUBSYSTEM] [varchar](20) NULL,
	[CATEGORY] [varchar](50) NULL,
	[EQUIP_ID] [varchar](20) NOT NULL,
	[STATUS_CLASS] [varchar](20) NOT NULL,
	[UPDATE_TIME_STAMP] [datetime] NULL,
	[CURRENT_STATUS] [varchar](20) NULL,
 CONSTRAINT [PK_ELM_STATUS] PRIMARY KEY CLUSTERED 
(
	[EQUIP_ID] ASC,
	[STATUS_CLASS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_EQUIP_STATUS_VALUEMAP]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_EQUIP_STATUS_VALUEMAP](
	[STATUS_CLASS] [varchar](20) NOT NULL,
	[STATUS_VALUE] [float] NOT NULL,
	[STATUS_NAME] [varchar](30) NULL,
 CONSTRAINT [PK_ESV_STATUSCLASS] PRIMARY KEY CLUSTERED 
(
	[STATUS_CLASS] ASC,
	[STATUS_VALUE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_IFS_INDIVIDUAL_FLIGHT_DETAIL]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_IFS_INDIVIDUAL_FLIGHT_DETAIL](
	[LICENSE_PLATE] [varchar](10) NULL,
	[PAX_NAME] [varchar](200) NULL,
	[BSM_TIME_STAMP] [datetime] NULL,
	[TAG_READ_TIME] [datetime] NULL,
	[SORTED_TIMESTAMP] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_MAINLINE_DEVICE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_MAINLINE_DEVICE](
	[SUBSYSTEM] [varchar](20) NULL,
	[GID_LOCATION] [varchar](20) NULL,
	[ATR_LOCATION] [varchar](20) NULL,
	[IPR_TOMES_SUBSYSTEM] [varchar](20) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_SS_LINE_DEVICE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_SS_LINE_DEVICE](
	[SUBSYSTEM] [varchar](20) NULL,
	[GID_LOCATION] [varchar](20) NULL,
	[ATR_LOCATION] [varchar](20) NULL,
	[BMA_LOCATION] [varchar](20) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_STATUS_EDS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_STATUS_EDS](
	[EDS_NAME] [varchar](50) NULL,
	[SW_TYPE] [varchar](50) NULL,
	[SW_REV] [varchar](50) NULL,
	[KEY_POS] [varchar](50) NULL,
	[EDS_STATUS] [varchar](20) NULL,
	[PLC_SCAN_TIME] [int] NULL,
	[ESTOP] [int] NULL,
	[FAULTS] [int] NULL,
	[RTR_HIGH] [int] NULL,
	[RTR_LOW] [int] NULL,
	[JAMS] [int] NULL,
	[BAGS_SCR] [int] NULL,
	[BAGS_CLR] [int] NULL,
	[BAGS_ALM] [int] NULL,
	[BAGS_EDS_UNKNOWN] [int] NULL,
	[BAGS_SEEN] [int] NULL,
	[BAGS_BHS_UNKNOWN] [int] NULL,
	[BAGS_BHS_UNKNOWN_PER] [float] NULL,
	[TIMEOUTS] [int] NULL,
	[AVG_L2_DECISION_TIME] [float] NULL,
	[AVG_BAG_PROC_TIME] [float] NULL,
	[COMM_IF_STATUS] [int] NULL,
	[COMM_PLC_NAME] [varchar](30) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_STATUS_PLC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_STATUS_PLC](
	[PLC_NAME] [varchar](50) NULL,
	[SW_TYPE] [varchar](50) NULL,
	[SW_REV] [varchar](50) NULL,
	[KEY_POS] [varchar](30) NULL,
	[PLC_STATUS] [varchar](30) NULL,
	[LED_CPU] [varchar](3) NULL,
	[LED_FORCE] [varchar](3) NULL,
	[LED_COMM] [varchar](3) NULL,
	[LED_BATT] [varchar](3) NULL,
	[MEM_SIZE] [int] NULL,
	[MEM_USED] [int] NULL,
	[MEM_CMPL] [int] NULL,
	[RUN_CNT] [int] NULL,
	[SCAN_TIME] [int] NULL,
	[CPU_ERR] [int] NULL,
	[NWK_ERR] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MIS_SubsystemCatalog]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_SubsystemCatalog](
	[SUBSYSTEM_TYPE] [varchar](30) NOT NULL,
	[SUBSYSTEM] [varchar](20) NULL,
	[DETECT_LOCATION] [varchar](20) NOT NULL,
	[MDS_DATA] [int] NULL,
 CONSTRAINT [PK_SC] PRIMARY KEY CLUSTERED 
(
	[SUBSYSTEM_TYPE] ASC,
	[DETECT_LOCATION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MONTH_CONFIG]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MONTH_CONFIG](
	[MONTHIND] [varchar](2) NOT NULL,
	[MONTHDESC] [varchar](15) NOT NULL,
	[MONTHABB] [varchar](3) NULL,
 CONSTRAINT [PK_MONTHID] PRIMARY KEY CLUSTERED 
(
	[MONTHIND] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PICTURES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PICTURES](
	[PIC_NAME] [varchar](20) NOT NULL,
	[PIC_TITLE] [varchar](100) NOT NULL,
	[PIC_DESC] [nvarchar](100) NULL,
	[PIC_IMAGE] [varbinary](max) NOT NULL,
 CONSTRAINT [PK_PICTURES] PRIMARY KEY CLUSTERED 
(
	[PIC_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[REPORT_FAULT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[REPORT_FAULT](
	[FAULT_NAME] [varchar](10) NOT NULL,
	[FAULT_DESCRIPTION] [nvarchar](100) NOT NULL,
	[FAULT_TYPE] [varchar](11) NOT NULL,
	[FAULT_USED] [bit] NOT NULL,
	[MDS_USED] [bit] NOT NULL,
	[CCTV_USED] [bit] NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[HELP_ID] [varchar](20) NULL,
 CONSTRAINT [FAULT_PK] PRIMARY KEY CLUSTERED 
(
	[FAULT_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[REPORT_FAULT_TYPES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[REPORT_FAULT_TYPES](
	[FAULT_TYPE] [varchar](11) NOT NULL,
	[DESCRIPTION] [varchar](50) NOT NULL,
 CONSTRAINT [REPORT_FAULT_TYPES_PK] PRIMARY KEY CLUSTERED 
(
	[FAULT_TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ROLES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ROLES](
	[ID] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ROLES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SAC_OWS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SAC_OWS](
	[SAC_OWS] [varchar](20) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NULL,
 CONSTRAINT [PK_SAC_OWS] PRIMARY KEY CLUSTERED 
(
	[SAC_OWS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SCHEME_TYPE]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SCHEME_TYPE](
	[SCHEME_TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_SCHEME_TYPE] PRIMARY KEY CLUSTERED 
(
	[SCHEME_TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SECURITY_CATEGORIES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SECURITY_CATEGORIES](
	[SECU_CAT_CODE] [varchar](15) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[DESCRIPTION] [varchar](200) NULL,
 CONSTRAINT [PK_SECURITY_CATEGORIES] PRIMARY KEY CLUSTERED 
(
	[SECU_CAT_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SECURITY_GROUP_TASK_MAPPING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING](
	[SECU_GROUP_CODE] [varchar](15) NOT NULL,
	[SECU_TASK_CODE] [varchar](15) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SECURITY_GROUP_TASKS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SECURITY_GROUP_TASKS](
	[SECU_GROUP_CODE] [varchar](15) NOT NULL,
	[SECU_TASK_CODE] [varchar](15) NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SECURITY_GROUPS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SECURITY_GROUPS](
	[SECU_GROUP_CODE] [varchar](15) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[SECU_CAT_CODE] [varchar](15) NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[DESCRIPTION] [varchar](200) NULL,
 CONSTRAINT [PK_SECURITY_GROUPS] PRIMARY KEY CLUSTERED 
(
	[SECU_GROUP_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SECURITY_TASKS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SECURITY_TASKS](
	[SECU_TASK_CODE] [varchar](15) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[SECU_CAT_CODE] [varchar](15) NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[DESCRIPTION] [varchar](200) NULL,
 CONSTRAINT [PK_SECURITY_TASKS] PRIMARY KEY CLUSTERED 
(
	[SECU_TASK_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SECURITY_USER_RIGHTS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SECURITY_USER_RIGHTS](
	[USER_NAME] [varchar](20) NOT NULL,
	[SECU_GROUP_CODE] [varchar](15) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SECURITY_USERS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SECURITY_USERS](
	[USER_NAME] [varchar](20) NOT NULL,
	[USER_PASSWORD] [varchar](200) NOT NULL,
	[AD_USER_GROUP] [varchar](200) NULL,
	[COMPANY] [varchar](50) NULL,
	[JOB_TITLE] [varchar](100) NULL,
	[AIRPORT_BADGE] [varchar](100) NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[DESCRIPTION] [varchar](200) NULL,
 CONSTRAINT [PK_SECURITY_USERS] PRIMARY KEY CLUSTERED 
(
	[USER_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SimpleEvent]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SimpleEvent](
	[EventID] [uniqueidentifier] NOT NULL,
	[SourceName] [nvarchar](200) NULL,
	[SourcePath] [nvarchar](512) NULL,
	[SourceID] [uniqueidentifier] NULL,
	[ServerName] [nvarchar](50) NULL,
	[TicksTimeStamp] [bigint] NULL,
	[EventTimeStamp] [datetime] NULL,
	[EventCategory] [nvarchar](50) NULL,
	[Severity] [int] NULL,
	[Priority] [int] NULL,
	[Message] [nvarchar](512) NULL,
 CONSTRAINT [PK_100_SimpleEvent] PRIMARY KEY NONCLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SORTATION_REASON]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SORTATION_REASON](
	[REASON] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_SORTATION_REASON] PRIMARY KEY CLUSTERED 
(
	[REASON] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SUBSYSTEM_GROUPING]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SUBSYSTEM_GROUPING](
	[GROUP_NAME] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SUBSYSTEM_LIST]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SUBSYSTEM_LIST](
	[ID] [varchar](10) NOT NULL,
	[DESCRIPTION] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SUBSYSTEMS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SUBSYSTEMS](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_SUBSYSTEMS] PRIMARY KEY CLUSTERED 
(
	[SUBSYSTEM] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SUBSYSTEMS_BAK_GWY]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SUBSYSTEMS_BAK_GWY](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SYS_CONFIG]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SYS_CONFIG](
	[SYS_KEY] [varchar](40) NOT NULL,
	[SYS_VALUE] [varchar](20) NOT NULL,
	[DEFAULT_VALUE] [varchar](20) NOT NULL,
	[LAST_VALUE] [varchar](20) NOT NULL,
	[DESCRIPTION] [nvarchar](80) NOT NULL,
	[VALUE_TOKEN] [varchar](80) NULL,
	[SYS_ACTION] [varchar](50) NULL,
	[GROUP_NAME] [varchar](20) NULL,
	[ORDER_FLAG] [varchar](1) NULL,
	[IS_ENABLED] [bit] NOT NULL,
	[IS_CHANGED] [bit] NOT NULL,
 CONSTRAINT [PK_SYS_CONFIG] PRIMARY KEY CLUSTERED 
(
	[SYS_KEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TEMPLATE_ASSIGNMENTS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMPLATE_ASSIGNMENTS](
	[PRODUCTION_DATE] [datetime] NOT NULL,
	[TEMPLATE_ID] [bigint] NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
 CONSTRAINT [PK_TEMPLATE_ASSIGNMENT] PRIMARY KEY CLUSTERED 
(
	[PRODUCTION_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TEMPLATE_COMMENT]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TEMPLATE_COMMENT](
	[PRODUCTION_DATE] [datetime] NOT NULL,
	[COMMENT] [varchar](200) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
 CONSTRAINT [PK_TEMPLATE_COMMENT] PRIMARY KEY CLUSTERED 
(
	[PRODUCTION_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TEMPLATE_ID] [bigint] NOT NULL,
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[STO] [varchar](4) NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[WEEKDAY] [varchar](1) NOT NULL,
	[ALLOC_OPEN_OFFSET] [varchar](5) NOT NULL,
	[ALLOC_OPEN_RELATED] [varchar](4) NOT NULL,
	[ALLOC_CLOSE_OFFSET] [varchar](5) NOT NULL,
	[ALLOC_CLOSE_RELATED] [varchar](4) NOT NULL,
	[RUSH_DURATION] [varchar](5) NOT NULL,
	[SCHEME_TYPE] [varchar](2) NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[HOUR] [varchar](2) NULL,
 CONSTRAINT [PK_FLIGHT_PLAN_ALLOC_TEMPLATE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TEMPLATE_GROUPS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TEMPLATE_GROUPS](
	[ID] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[TODELETE] [varchar](1) NOT NULL,
 CONSTRAINT [PK_TEMPLATE_GROUPS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TEMPLATES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TEMPLATES](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TEMPLATE_GROUP_ID] [varchar](15) NOT NULL,
	[WEEKDAY] [int] NOT NULL,
	[WEEKDAY_NAME] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[TODELETE] [varchar](1) NOT NULL,
 CONSTRAINT [PK_TEMPLATES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[test_isc]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[test_isc](
	[license_plate] [varchar](10) NULL,
	[gid] [varchar](10) NULL,
	[time_stamp] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TrackingEvent]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrackingEvent](
	[EventID] [uniqueidentifier] NOT NULL,
	[SourceName] [nvarchar](200) NULL,
	[SourcePath] [nvarchar](512) NULL,
	[SourceID] [uniqueidentifier] NULL,
	[ServerName] [nvarchar](50) NULL,
	[TicksTimeStamp] [bigint] NULL,
	[EventTimeStamp] [datetime] NULL,
	[EventCategory] [nvarchar](50) NULL,
	[Severity] [int] NULL,
	[Priority] [int] NULL,
	[Message] [nvarchar](512) NULL,
	[PersonID] [nvarchar](50) NULL,
	[UserComment] [nvarchar](512) NULL,
	[ComputerID] [nvarchar](64) NULL,
 CONSTRAINT [PK_102_TrackEvent] PRIMARY KEY NONCLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TRAVEL_CLASS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TRAVEL_CLASS](
	[CODE] [varchar](1) NOT NULL,
	[NAME] [varchar](30) NOT NULL,
	[INVOLVEMENT] [int] NOT NULL,
	[IS_HIDDEN] [bit] NOT NULL,
	[DESCRIPTION] [varchar](100) NULL,
 CONSTRAINT [PK_TRAVEL_CLASS] PRIMARY KEY CLUSTERED 
(
	[CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[USERS]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[USERS](
	[ID] [varchar](15) NOT NULL,
	[USER_NAME] [nvarchar](40) NOT NULL,
	[USER_IP_ADDR] [varchar](60) NULL,
	[IP_CHECK] [char](1) NOT NULL,
	[EXPIRY_DATE] [datetime] NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
 CONSTRAINT [PK_USERS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[USERS_ROLES]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[USERS_ROLES](
	[ROLE_ID] [varchar](10) NOT NULL,
	[USER_ID] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
 CONSTRAINT [PK_USERS_ROLES] PRIMARY KEY CLUSTERED 
(
	[ROLE_ID] ASC,
	[USER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WEEKDAY_CONFIG]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WEEKDAY_CONFIG](
	[WEEKDAY] [char](1) NOT NULL,
	[DESCRIPTION] [nvarchar](10) NOT NULL,
	[WEEKDAYABB] [varchar](10) NOT NULL,
	[WEEKDAYUPPER] [varchar](10) NOT NULL,
 CONSTRAINT [PK_WEEKDAY] PRIMARY KEY CLUSTERED 
(
	[WEEKDAY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vwConditionEvent]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwConditionEvent]
			AS
			SELECT *, 2 as EventType
			FROM  ConditionEvent
GO
/****** Object:  View [dbo].[vwSimpleEvent]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwSimpleEvent]
			AS
			SELECT *, 1 as EventType
			FROM  SimpleEvent
GO
/****** Object:  View [dbo].[vwTrackingEvent]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwTrackingEvent]
			AS
			SELECT *, 3 as EventType
			FROM  TrackingEvent
GO
/****** Object:  View [dbo].[vwAllEvents]    Script Date: 05-Apr-14 3:49:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwAllEvents]
      AS
      select ALLE.EventID, ALLE.SourceName, ALLE.SourcePath, ALLE.SourceID, ALLE.ServerName, ALLE.TicksTimeStamp, ALLE.EventTimeStamp, ALLE.EventCategory, ALLE.Severity, ALLE.Priority, ALLE.Message, ALLE.EventType, ALLE.UserComment, ALLE.ComputerID, ALLE.PersonID,
      vwConditionEvent.ConditionName, vwConditionEvent.SubConditionName, vwConditionEvent.AlarmClass, vwConditionEvent.Active, vwConditionEvent.Acked, vwConditionEvent.EffDisabled, vwConditionEvent.Disabled,
      vwConditionEvent.EffSuppressed, vwConditionEvent.Suppressed, vwConditionEvent.ChangeMask, vwConditionEvent.InputValue, vwConditionEvent.LimitValue, vwConditionEvent.Quality,
      vwConditionEvent.EventAssociationID, vwConditionEvent.Tag1Value, vwConditionEvent.Tag2Value, vwConditionEvent.Tag3Value, vwConditionEvent.Tag4Value,
      vwConditionEvent.Shelved
      from
      (select CE.EventID, CE.SourceName, CE.SourcePath, CE.SourceID, CE.ServerName, CE.TicksTimeStamp, CE.EventTimeStamp, CE.EventCategory, CE.Severity, CE.Priority, CE.Message, CE.EventType, CE.UserComment, CE.UserComputerID as ComputerID, CE.PersonID as PersonID
      from vwConditionEvent CE
      UNION ALL
      select SE.EventID, SE.SourceName, SE.SourcePath, SE.SourceID, SE.ServerName, SE.TicksTimeStamp, SE.EventTimeStamp, SE.EventCategory, SE.Severity, SE.Priority, SE.Message, SE.EventType, NULL as UserComment, NULL as ComputerID, NULL as PersonID
      from vwSimpleEvent SE
      UNION ALL
      select TE.EventID, TE.SourceName, TE.SourcePath, TE.SourceID, TE.ServerName, TE.TicksTimeStamp, TE.EventTimeStamp, TE.EventCategory, TE.Severity, TE.Priority, TE.Message, TE.EventType, TE.UserComment, TE.ComputerID as ComputerID, TE.PersonID as PersonID
      from vwTrackingEvent TE) as ALLE left outer join
      vwConditionEvent on ALLE.eventid = vwConditionEvent.eventid left outer join vwTrackingEvent on ALLE.EventID = vwTrackingEvent.EventID
GO
ALTER TABLE [dbo].[AIRLINES] ADD  CONSTRAINT [DF_AIRLINES_SORTFLAG]  DEFAULT ((0)) FOR [SORT_FLAG]
GO
ALTER TABLE [dbo].[AIRLINES] ADD  CONSTRAINT [DF_AIRLINES_IS_CHANGED]  DEFAULT ((1)) FOR [IS_CHANGED]
GO
ALTER TABLE [dbo].[CHANGE_MONITORING] ADD  CONSTRAINT [DF_CHANGE_MONITORING_IS_CHANGED]  DEFAULT ((0)) FOR [IS_CHANGED]
GO
ALTER TABLE [dbo].[DESTINATIONS] ADD  CONSTRAINT [DF_DESTINATIONS_IS_AVAILABLE]  DEFAULT ((1)) FOR [IS_AVAILABLE]
GO
ALTER TABLE [dbo].[EXCEPTIONS] ADD  CONSTRAINT [DF_EXCEPTIONS_IS_HIDDEN]  DEFAULT ((0)) FOR [IS_HIDDEN]
GO
ALTER TABLE [dbo].[FALLBACK_MAPPING] ADD  CONSTRAINT [DF_FALLBACK_MAPPING_IS_CHANGED]  DEFAULT ((1)) FOR [IS_CHANGED]
GO
ALTER TABLE [dbo].[FLIGHT_CANCEL] ADD  CONSTRAINT [DF_FLIGHT_CANCEL_FLIGHT_NUMBER_SUFFIX]  DEFAULT (' ') FOR [FLIGHT_NUMBER_SUFFIX]
GO
ALTER TABLE [dbo].[FLIGHT_DELETE] ADD  CONSTRAINT [DF_FLIGHT_DELETE_FLIGHT_NUMBER_SUFFIX]  DEFAULT (' ') FOR [FLIGHT_NUMBER_SUFFIX]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC] ADD  CONSTRAINT [DF_FLIGHT_PLAN_ALLOC_TRAVEL_CLASS]  DEFAULT ('*') FOR [TRAVEL_CLASS]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC] ADD  CONSTRAINT [DF_FLIGHT_PLAN_ALLOC_FLIGHT_DESTINATION]  DEFAULT ('*') FOR [FLIGHT_DESTINATION]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC] ADD  CONSTRAINT [DF_FLIGHT_PLAN_ALLOC_BAG_TYPE]  DEFAULT ('*') FOR [BAG_TYPE]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC] ADD  CONSTRAINT [DF_FLIGHT_PLAN_ALLOC_TRANSFER]  DEFAULT ('*') FOR [TRANSFER]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC] ADD  CONSTRAINT [DF_FLIGHT_PLAN_ALLOC_IS_MANUAL_CLOSE]  DEFAULT ((0)) FOR [IS_MANUAL_CLOSE]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC] ADD  CONSTRAINT [DF_FLIGHT_PLAN_ALLOC_IS_CLOSED]  DEFAULT ((0)) FOR [IS_CLOSED]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC] ADD  CONSTRAINT [DF_FLIGHT_PLAN_ALLOC_IS_TEMPLATE_FLIGHT]  DEFAULT ((0)) FOR [IS_MISS_TEMPLATE_FLIGHT]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING] ADD  CONSTRAINT [DF_FPA_IS_ALLOCATED]  DEFAULT ((0)) FOR [IS_ALLOCATED]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING] ADD  CONSTRAINT [DF_FPA_CUSTOMS_REQUIRED]  DEFAULT ((1)) FOR [CUSTOMS_REQUIRED]
GO
ALTER TABLE [dbo].[FLIGHT_RESOURCE_CHANGE] ADD  CONSTRAINT [DF_FLIGHT_RESOURCE_CHANGE_FLIGHT_NUMBER_SUFFIX]  DEFAULT (' ') FOR [FLIGHT_NUMBER_SUFFIX]
GO
ALTER TABLE [dbo].[FOUR_DIGITS_FALLBACK_MAPPING] ADD  CONSTRAINT [DF_FOUR_DIGITS_FALLBACK_MAPPING_IS_CHANGED]  DEFAULT ((1)) FOR [IS_CHANGED]
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT] ADD  CONSTRAINT [DF_FUNCTION_ALLOC_GANTT_IS_CLOSED]  DEFAULT ((0)) FOR [IS_CLOSED]
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_LIST] ADD  CONSTRAINT [DF_FUNCTION_ALLOC_LIST_IS_ENABLED]  DEFAULT ((1)) FOR [IS_ENABLED]
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_LIST] ADD  CONSTRAINT [DF_FUNCTION_ALLOC_LIST_IS_CHANGED]  DEFAULT ((1)) FOR [IS_CHANGED]
GO
ALTER TABLE [dbo].[FUNCTION_TYPES] ADD  CONSTRAINT [DF_FUNCTION_TYPES_IS_ENABLED]  DEFAULT ((1)) FOR [IS_ENABLED]
GO
ALTER TABLE [dbo].[LOCATIONS] ADD  CONSTRAINT [DF_LOCATIONS_TRACKED]  DEFAULT ((0)) FOR [TRACKED]
GO
ALTER TABLE [dbo].[MDS_ALARMS] ADD  CONSTRAINT [DF_MDS_ALARMS_ALM_UNCERTAIN]  DEFAULT ((0)) FOR [ALM_UNCERTAIN]
GO
ALTER TABLE [dbo].[MDS_BHS_ALARMS] ADD  DEFAULT ('') FOR [EQUIPMENT_ID]
GO
ALTER TABLE [dbo].[MDS_BHS_ALARMS] ADD  DEFAULT ('') FOR [ALARM_TYPE]
GO
ALTER TABLE [dbo].[MDS_BHS_ALARMS] ADD  DEFAULT ('') FOR [ALARM_DESCRIPTION]
GO
ALTER TABLE [dbo].[MDS_BHS_ALARMS] ADD  DEFAULT ((0)) FOR [ALARM_STATUS]
GO
ALTER TABLE [dbo].[SECURITY_CATEGORIES] ADD  CONSTRAINT [DF_SECURITY_CATEGORIES_IS_ACTIVE]  DEFAULT ((1)) FOR [IS_ACTIVE]
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASKS] ADD  CONSTRAINT [DF_SECURITY_GROUP_TASK_IS_ACTIVE]  DEFAULT ((1)) FOR [IS_ACTIVE]
GO
ALTER TABLE [dbo].[SECURITY_GROUPS] ADD  CONSTRAINT [DF_SECURITY_GROUPS_IS_ACTIVE]  DEFAULT ((1)) FOR [IS_ACTIVE]
GO
ALTER TABLE [dbo].[SECURITY_TASKS] ADD  CONSTRAINT [DF_SECURITY_TASKS_IS_ACTIVE]  DEFAULT ((1)) FOR [IS_ACTIVE]
GO
ALTER TABLE [dbo].[SECURITY_USERS] ADD  CONSTRAINT [DF_SECURITY_USERS_IS_ACTIVE]  DEFAULT ((1)) FOR [IS_ACTIVE]
GO
ALTER TABLE [dbo].[SYS_CONFIG] ADD  CONSTRAINT [DF_SYS_CONFIG_IS_ENABLED]  DEFAULT ((1)) FOR [IS_ENABLED]
GO
ALTER TABLE [dbo].[SYS_CONFIG] ADD  CONSTRAINT [DF_SYS_CONFIG_IS_CHANGED]  DEFAULT ((0)) FOR [IS_CHANGED]
GO
ALTER TABLE [dbo].[TEMPLATE_GROUPS] ADD  CONSTRAINT [DF_TEMPLATE_GROUPS_TODELETE]  DEFAULT ('N') FOR [TODELETE]
GO
ALTER TABLE [dbo].[TEMPLATES] ADD  CONSTRAINT [DF_TEMPLATES_TODELETE]  DEFAULT ('N') FOR [TODELETE]
GO
ALTER TABLE [dbo].[TRAVEL_CLASS] ADD  CONSTRAINT [DF_TRAVEL_CLASS_IS_HIDDEN]  DEFAULT ((0)) FOR [IS_HIDDEN]
GO
ALTER TABLE [dbo].[USERS] ADD  CONSTRAINT [DF__USERS__IP_CHECK__014935CB]  DEFAULT ('N') FOR [IP_CHECK]
GO
ALTER TABLE [dbo].[AIRLINES]  WITH CHECK ADD  CONSTRAINT [FK_AIRLINES_DESTINATION] FOREIGN KEY([DESTINATION])
REFERENCES [dbo].[DESTINATIONS] ([DESTINATION])
GO
ALTER TABLE [dbo].[AIRLINES] CHECK CONSTRAINT [FK_AIRLINES_DESTINATION]
GO
ALTER TABLE [dbo].[APP_LIVE_MONITORING]  WITH CHECK ADD  CONSTRAINT [FK_APP_LIVE_MONITORING_STATUS_TYPE] FOREIGN KEY([LIVE_STATUS_TYPE])
REFERENCES [dbo].[APP_LIVE_STATUS_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[APP_LIVE_MONITORING] CHECK CONSTRAINT [FK_APP_LIVE_MONITORING_STATUS_TYPE]
GO
ALTER TABLE [dbo].[BAG_ERROR_BSM]  WITH CHECK ADD  CONSTRAINT [FK_BAG_ERROR_BSM_BAG] FOREIGN KEY([DATA_ID])
REFERENCES [dbo].[BAGS] ([ID])
GO
ALTER TABLE [dbo].[BAG_ERROR_BSM] CHECK CONSTRAINT [FK_BAG_ERROR_BSM_BAG]
GO
ALTER TABLE [dbo].[BAG_SORTING]  WITH CHECK ADD  CONSTRAINT [FK_BAG_SORTING_BAG] FOREIGN KEY([DATA_ID])
REFERENCES [dbo].[BAGS] ([ID])
GO
ALTER TABLE [dbo].[BAG_SORTING] CHECK CONSTRAINT [FK_BAG_SORTING_BAG]
GO
ALTER TABLE [dbo].[CHANGE_MONITORING]  WITH CHECK ADD  CONSTRAINT [FK_CHANGE_MONITORING_SAC_OWS] FOREIGN KEY([SAC_OWS])
REFERENCES [dbo].[SAC_OWS] ([SAC_OWS])
GO
ALTER TABLE [dbo].[CHANGE_MONITORING] CHECK CONSTRAINT [FK_CHANGE_MONITORING_SAC_OWS]
GO
ALTER TABLE [dbo].[CHECKIN_COUNTER_LINE_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_CHECKIN_COUNTER_LINE_MAPPING_CHECKIN_COUNTER] FOREIGN KEY([CHECKIN_COUNTER_CODE])
REFERENCES [dbo].[CHECKIN_COUNTER] ([CODE])
GO
ALTER TABLE [dbo].[CHECKIN_COUNTER_LINE_MAPPING] CHECK CONSTRAINT [FK_CHECKIN_COUNTER_LINE_MAPPING_CHECKIN_COUNTER]
GO
ALTER TABLE [dbo].[CHECKIN_COUNTER_LINE_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_CHECKIN_COUNTER_LINE_MAPPING_CHECKIN_LINE_CODE] FOREIGN KEY([CHECKIN_LINE_CODE])
REFERENCES [dbo].[CHECKIN_LINE] ([CODE])
GO
ALTER TABLE [dbo].[CHECKIN_COUNTER_LINE_MAPPING] CHECK CONSTRAINT [FK_CHECKIN_COUNTER_LINE_MAPPING_CHECKIN_LINE_CODE]
GO
ALTER TABLE [dbo].[CHECKIN_GROUP_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_CHECKIN_GROUP_MAPPING_CHECKIN_COUNTER_GROUP] FOREIGN KEY([CHECKIN_GROUP_CODE])
REFERENCES [dbo].[CHECKIN_LINE_GROUP] ([CODE])
GO
ALTER TABLE [dbo].[CHECKIN_GROUP_MAPPING] CHECK CONSTRAINT [FK_CHECKIN_GROUP_MAPPING_CHECKIN_COUNTER_GROUP]
GO
ALTER TABLE [dbo].[CHECKIN_GROUP_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_CHECKIN_GROUP_MAPPING_CHECKIN_COUTNER] FOREIGN KEY([CHECKIN_LINE_CODE])
REFERENCES [dbo].[CHECKIN_LINE] ([CODE])
GO
ALTER TABLE [dbo].[CHECKIN_GROUP_MAPPING] CHECK CONSTRAINT [FK_CHECKIN_GROUP_MAPPING_CHECKIN_COUTNER]
GO
ALTER TABLE [dbo].[CHECKIN_GROUP_RESOURCE_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_CHECKIN_GROUP_RESOURCE_MAPPING_CHECKIN_COUNTER_GROUP] FOREIGN KEY([CHECKIN_GROUP_CODE])
REFERENCES [dbo].[CHECKIN_LINE_GROUP] ([CODE])
GO
ALTER TABLE [dbo].[CHECKIN_GROUP_RESOURCE_MAPPING] CHECK CONSTRAINT [FK_CHECKIN_GROUP_RESOURCE_MAPPING_CHECKIN_COUNTER_GROUP]
GO
ALTER TABLE [dbo].[DESTINATION_GROUPING]  WITH CHECK ADD  CONSTRAINT [FK_DESTINATION_GROUPING_DESTINATION] FOREIGN KEY([DESTINATION])
REFERENCES [dbo].[DESTINATIONS] ([DESTINATION])
GO
ALTER TABLE [dbo].[DESTINATION_GROUPING] CHECK CONSTRAINT [FK_DESTINATION_GROUPING_DESTINATION]
GO
ALTER TABLE [dbo].[FALLBACK_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_FALLBACK_MAPPING_DESTINATION] FOREIGN KEY([DESTINATION])
REFERENCES [dbo].[DESTINATIONS] ([DESTINATION])
GO
ALTER TABLE [dbo].[FALLBACK_MAPPING] CHECK CONSTRAINT [FK_FALLBACK_MAPPING_DESTINATION]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHT_PLAN_ALLOC_RESOURCE] FOREIGN KEY([RESOURCE])
REFERENCES [dbo].[ALLOC_RESOURCES] ([RESOURCE])
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC] CHECK CONSTRAINT [FK_FLIGHT_PLAN_ALLOC_RESOURCE]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC_ERROR]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHT_PLAN_ALLOC_ERROR_TYPE] FOREIGN KEY([ERROR_TYPE])
REFERENCES [dbo].[FLIGHT_PLAN_ALLOC_ERROR_TYPE] ([TYPE])
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC_ERROR] CHECK CONSTRAINT [FK_FLIGHT_PLAN_ALLOC_ERROR_TYPE]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ERROR]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHT_PLAN_ERROR_FLIGHT_PLANS] FOREIGN KEY([DATA_ID])
REFERENCES [dbo].[FLIGHT_PLANS] ([ID])
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ERROR] CHECK CONSTRAINT [FK_FLIGHT_PLAN_ERROR_FLIGHT_PLANS]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS] FOREIGN KEY([DATA_ID])
REFERENCES [dbo].[FLIGHT_PLANS] ([ID])
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING] CHECK CONSTRAINT [FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHT_PLAN_SORTING_FLIGHT_TYPE] FOREIGN KEY([FLIGHT_TYPE])
REFERENCES [dbo].[FLIGHT_TYPE] ([TYPE])
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING] CHECK CONSTRAINT [FK_FLIGHT_PLAN_SORTING_FLIGHT_TYPE]
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHT_PLAN_SORTING_HIGH_RISK] FOREIGN KEY([HIGH_RISK])
REFERENCES [dbo].[HIGH_RISK_NEEDED] ([VALUE])
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING] CHECK CONSTRAINT [FK_FLIGHT_PLAN_SORTING_HIGH_RISK]
GO
ALTER TABLE [dbo].[FLIGHTS]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHTS_AIRCRAFT_TYPE] FOREIGN KEY([AIRCRAFT_TYPE])
REFERENCES [dbo].[AIRCRAFT_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[FLIGHTS] CHECK CONSTRAINT [FK_FLIGHTS_AIRCRAFT_TYPE]
GO
ALTER TABLE [dbo].[FLIGHTS]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHTS_AIRLINE_CODE_IATA] FOREIGN KEY([AIRLINE])
REFERENCES [dbo].[AIRLINES] ([CODE_IATA])
GO
ALTER TABLE [dbo].[FLIGHTS] CHECK CONSTRAINT [FK_FLIGHTS_AIRLINE_CODE_IATA]
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT]  WITH CHECK ADD  CONSTRAINT [FK_FUNCTION_ALLOC_GANTT_FUNC_TYPE] FOREIGN KEY([FUNCTION_TYPE])
REFERENCES [dbo].[FUNCTION_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT] CHECK CONSTRAINT [FK_FUNCTION_ALLOC_GANTT_FUNC_TYPE]
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT]  WITH CHECK ADD  CONSTRAINT [FK_FUNCTION_ALLOC_GANTT_RESOURCE] FOREIGN KEY([RESOURCE])
REFERENCES [dbo].[ALLOC_RESOURCES] ([RESOURCE])
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT] CHECK CONSTRAINT [FK_FUNCTION_ALLOC_GANTT_RESOURCE]
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_LIST]  WITH CHECK ADD  CONSTRAINT [FK_FUNCTION_ALLOC_LIST_FUNC_TYPE] FOREIGN KEY([FUNCTION_TYPE])
REFERENCES [dbo].[FUNCTION_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_LIST] CHECK CONSTRAINT [FK_FUNCTION_ALLOC_LIST_FUNC_TYPE]
GO
ALTER TABLE [dbo].[FUNCTION_TYPES]  WITH CHECK ADD  CONSTRAINT [FK_FUNCTION_TYPES_GROUP] FOREIGN KEY([GROUP])
REFERENCES [dbo].[FUNCTION_TYPE_GROUPS] ([GROUP])
GO
ALTER TABLE [dbo].[FUNCTION_TYPES] CHECK CONSTRAINT [FK_FUNCTION_TYPES_GROUP]
GO
ALTER TABLE [dbo].[ITEM_ENCODING_REQUEST]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_ENCODING_REQUEST_TYPE] FOREIGN KEY([ENCODING_TYPE])
REFERENCES [dbo].[ITEM_ENCODING_REQUEST_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_ENCODING_REQUEST] CHECK CONSTRAINT [FK_ITEM_ENCODING_REQUEST_TYPE]
GO
ALTER TABLE [dbo].[ITEM_PROCEEDED]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_PROCEEDED_TYPE] FOREIGN KEY([PROCEED_TYPE])
REFERENCES [dbo].[ITEM_PROCEED_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_PROCEEDED] CHECK CONSTRAINT [FK_ITEM_PROCEEDED_TYPE]
GO
ALTER TABLE [dbo].[ITEM_REDIRECT]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_REDIRECT_SORTATION_REASON] FOREIGN KEY([REASON])
REFERENCES [dbo].[SORTATION_REASON] ([REASON])
GO
ALTER TABLE [dbo].[ITEM_REDIRECT] CHECK CONSTRAINT [FK_ITEM_REDIRECT_SORTATION_REASON]
GO
ALTER TABLE [dbo].[ITEM_SCANNED]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_SCANNED_STATUS_TYPE] FOREIGN KEY([STATUS_TYPE])
REFERENCES [dbo].[ITEM_SCAN_STATUS_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_SCANNED] CHECK CONSTRAINT [FK_ITEM_SCANNED_STATUS_TYPE]
GO
ALTER TABLE [dbo].[ITEM_SCREENED]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_SCREENED_RESULT_TYPE] FOREIGN KEY([RESULT_TYPE])
REFERENCES [dbo].[ITEM_SCREEN_RESULT_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_SCREENED] CHECK CONSTRAINT [FK_ITEM_SCREENED_RESULT_TYPE]
GO
ALTER TABLE [dbo].[ITEM_SORTATION_EVENT]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_SORTATION_EVENT_TYPE] FOREIGN KEY([SORT_EVENT_TYPE])
REFERENCES [dbo].[ITEM_SORTATION_EVENT_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_SORTATION_EVENT] CHECK CONSTRAINT [FK_ITEM_SORTATION_EVENT_TYPE]
GO
ALTER TABLE [dbo].[LOCATIONS]  WITH CHECK ADD  CONSTRAINT [FK_LOCATIONS_LOCATION_STATUS_TYPES] FOREIGN KEY([STATUS_TYPE])
REFERENCES [dbo].[LOCATION_STATUS_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[LOCATIONS] CHECK CONSTRAINT [FK_LOCATIONS_LOCATION_STATUS_TYPES]
GO
ALTER TABLE [dbo].[LOCATIONS]  WITH CHECK ADD  CONSTRAINT [FK_LOCATIONS_SUBSYSTEM] FOREIGN KEY([SUBSYSTEM])
REFERENCES [dbo].[SUBSYSTEMS] ([SUBSYSTEM])
GO
ALTER TABLE [dbo].[LOCATIONS] CHECK CONSTRAINT [FK_LOCATIONS_SUBSYSTEM]
GO
ALTER TABLE [dbo].[MDS_COUNT]  WITH CHECK ADD  CONSTRAINT [FK_MDS_BAG_COUNT_MDS_BAG_COUNTERS] FOREIGN KEY([COUNTER_ID])
REFERENCES [dbo].[MDS_COUNTERS] ([COUNTER_ID])
GO
ALTER TABLE [dbo].[MDS_COUNT] CHECK CONSTRAINT [FK_MDS_BAG_COUNT_MDS_BAG_COUNTERS]
GO
ALTER TABLE [dbo].[MDS_HBS_DATA]  WITH CHECK ADD  CONSTRAINT [FK_MDS_HBS_DATA_MDS_HBS_DATA] FOREIGN KEY([RESULT_TYPE])
REFERENCES [dbo].[ITEM_SCREEN_RESULT_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[MDS_HBS_DATA] CHECK CONSTRAINT [FK_MDS_HBS_DATA_MDS_HBS_DATA]
GO
ALTER TABLE [dbo].[REPORT_FAULT]  WITH CHECK ADD  CONSTRAINT [FK_FAULT_TYPES] FOREIGN KEY([FAULT_TYPE])
REFERENCES [dbo].[REPORT_FAULT_TYPES] ([FAULT_TYPE])
GO
ALTER TABLE [dbo].[REPORT_FAULT] CHECK CONSTRAINT [FK_FAULT_TYPES]
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE] FOREIGN KEY([SECU_GROUP_CODE])
REFERENCES [dbo].[SECURITY_GROUPS] ([SECU_GROUP_CODE])
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING] CHECK CONSTRAINT [FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE]
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE] FOREIGN KEY([SECU_TASK_CODE])
REFERENCES [dbo].[SECURITY_TASKS] ([SECU_TASK_CODE])
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING] CHECK CONSTRAINT [FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE]
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASKS]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_GROUP_TASKS_SECU_GROUP_CODE] FOREIGN KEY([SECU_GROUP_CODE])
REFERENCES [dbo].[SECURITY_GROUPS] ([SECU_GROUP_CODE])
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASKS] CHECK CONSTRAINT [FK_SECURITY_GROUP_TASKS_SECU_GROUP_CODE]
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASKS]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_GROUP_TASKS_SECU_TASK_CODE] FOREIGN KEY([SECU_TASK_CODE])
REFERENCES [dbo].[SECURITY_TASKS] ([SECU_TASK_CODE])
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASKS] CHECK CONSTRAINT [FK_SECURITY_GROUP_TASKS_SECU_TASK_CODE]
GO
ALTER TABLE [dbo].[SECURITY_GROUPS]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_GROUPS_SECU_CAT_CODE] FOREIGN KEY([SECU_CAT_CODE])
REFERENCES [dbo].[SECURITY_CATEGORIES] ([SECU_CAT_CODE])
GO
ALTER TABLE [dbo].[SECURITY_GROUPS] CHECK CONSTRAINT [FK_SECURITY_GROUPS_SECU_CAT_CODE]
GO
ALTER TABLE [dbo].[SECURITY_TASKS]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_TASKS_SECU_CAT_CODE] FOREIGN KEY([SECU_CAT_CODE])
REFERENCES [dbo].[SECURITY_CATEGORIES] ([SECU_CAT_CODE])
GO
ALTER TABLE [dbo].[SECURITY_TASKS] CHECK CONSTRAINT [FK_SECURITY_TASKS_SECU_CAT_CODE]
GO
ALTER TABLE [dbo].[SECURITY_USER_RIGHTS]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE] FOREIGN KEY([SECU_GROUP_CODE])
REFERENCES [dbo].[SECURITY_GROUPS] ([SECU_GROUP_CODE])
GO
ALTER TABLE [dbo].[SECURITY_USER_RIGHTS] CHECK CONSTRAINT [FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE]
GO
ALTER TABLE [dbo].[SECURITY_USER_RIGHTS]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_USER_RIGHTS_USER_NAME] FOREIGN KEY([USER_NAME])
REFERENCES [dbo].[SECURITY_USERS] ([USER_NAME])
GO
ALTER TABLE [dbo].[SECURITY_USER_RIGHTS] CHECK CONSTRAINT [FK_SECURITY_USER_RIGHTS_USER_NAME]
GO
ALTER TABLE [dbo].[TEMPLATE_ASSIGNMENTS]  WITH CHECK ADD  CONSTRAINT [FK_TEMPLATE_ASSIGNMENTS_TEMPLATE_ID] FOREIGN KEY([TEMPLATE_ID])
REFERENCES [dbo].[TEMPLATES] ([ID])
GO
ALTER TABLE [dbo].[TEMPLATE_ASSIGNMENTS] CHECK CONSTRAINT [FK_TEMPLATE_ASSIGNMENTS_TEMPLATE_ID]
GO
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]  WITH CHECK ADD  CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_RESOURCE] FOREIGN KEY([RESOURCE])
REFERENCES [dbo].[ALLOC_RESOURCES] ([RESOURCE])
GO
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC] CHECK CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_RESOURCE]
GO
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]  WITH CHECK ADD  CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_SCHEME_TYPE] FOREIGN KEY([SCHEME_TYPE])
REFERENCES [dbo].[SCHEME_TYPE] ([SCHEME_TYPE])
GO
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC] CHECK CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_SCHEME_TYPE]
GO
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]  WITH CHECK ADD  CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_TEMPLATE_ID] FOREIGN KEY([TEMPLATE_ID])
REFERENCES [dbo].[TEMPLATES] ([ID])
GO
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC] CHECK CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_TEMPLATE_ID]
GO
ALTER TABLE [dbo].[TEMPLATES]  WITH CHECK ADD  CONSTRAINT [FK_TEMPLATES_TEMPLATE_GROUP] FOREIGN KEY([TEMPLATE_GROUP_ID])
REFERENCES [dbo].[TEMPLATE_GROUPS] ([ID])
GO
ALTER TABLE [dbo].[TEMPLATES] CHECK CONSTRAINT [FK_TEMPLATES_TEMPLATE_GROUP]
GO
ALTER TABLE [dbo].[USERS_ROLES]  WITH CHECK ADD  CONSTRAINT [FK_USER_ROLES_ROLEID] FOREIGN KEY([ROLE_ID])
REFERENCES [dbo].[ROLES] ([ID])
GO
ALTER TABLE [dbo].[USERS_ROLES] CHECK CONSTRAINT [FK_USER_ROLES_ROLEID]
GO
ALTER TABLE [dbo].[USERS_ROLES]  WITH CHECK ADD  CONSTRAINT [FK_USER_ROLES_USERID] FOREIGN KEY([USER_ID])
REFERENCES [dbo].[USERS] ([ID])
GO
ALTER TABLE [dbo].[USERS_ROLES] CHECK CONSTRAINT [FK_USER_ROLES_USERID]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'To identify item is inducted from ATR / MES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BAG_INFO', @level2type=N'COLUMN',@level2name=N'TYPE'
GO

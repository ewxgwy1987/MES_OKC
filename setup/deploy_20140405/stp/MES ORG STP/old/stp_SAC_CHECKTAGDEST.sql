USE [BHSDB_CLT]
GO
/****** Object:  StoredProcedure [dbo].[stp_SAC_CHECKTAGDEST]    Script Date: 2014/3/31 17:30:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[stp_SAC_CHECKTAGDEST]
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

		  IF @AIRPORT_LOC_CODE = @FALLBACK_AIRPORTLOC1 AND @AIRPORT_LOC_CODE = @FALLBACK_AIRPORTLOC2 AND @FALLBACK_CARRIERCODE1 = @FALLBACK_CARRIERCODE2
		     BEGIN  
	            SELECT @COUNT = COUNT(DISTINCT DESTINATION) FROM FALLBACK_MAPPING WHERE ID IN (@FALLBACK_NO1, @FALLBACK_NO2)
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
	   	 	   
END

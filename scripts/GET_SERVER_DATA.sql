declare @StationName as varchar(16)
declare @Status as smallint
set @StationName = 'MES1'
set @Status = 1

DECLARE @Statecodes AS VARCHAR(200)
EXEC @StateCodes = dbo.Mes_GETTablechanges @StationName, @Status
-- AIRLINES
IF((@Status = 0) OR (PATINDEX('%AIRLINES%', @Statecodes)>0))
BEGIN
	SELECT [CODE_IATA], [CODE_ICAO], [NAME], [TICKETING_CODE], [DESTINATION], [DESTINATION1]
	FROM AIRLINES
END
ELSE
BEGIN
	SELECT [CODE_IATA], [CODE_ICAO], [NAME], [TICKETING_CODE], [DESTINATION], [DESTINATION1]
	FROM AIRLINES WHERE [CODE_IATA] = ''
END
-- BAG INFO
IF((@Status = 0) OR (PATINDEX('%BAG_INFO%', @Statecodes)>0))
BEGIN
	SELECT [GID], [LICENSE_PLATE1], [LICENSE_PLATE2], [HBS1_RESULT], [HBS2_RESULT], 
	[HBS3_RESULT], [HBS4_RESULT], [HBS5_RESULT], [RECYLE_COUNT], [LAST_LOCATION], 
	[CREATED_BY], [TIME_STAMP]
	FROM BAG_INFO WHERE [TIME_STAMP] BETWEEN DATEADD(HH,-6,GETDATE()) 
	AND DATEADD(HH,24,GETDATE())
END 
ELSE
BEGIN
	SELECT [GID], [LICENSE_PLATE1], [LICENSE_PLATE2], [HBS1_RESULT], [HBS2_RESULT], 
	[HBS3_RESULT], [HBS4_RESULT], [HBS5_RESULT], [RECYLE_COUNT], [LAST_LOCATION], 
	[CREATED_BY], [TIME_STAMP]
	FROM BAG_INFO WHERE [GID] = ''
END
-- BAG SORTING
IF((@Status = 0) OR (PATINDEX('%BAG_SORTING%', @Statecodes)>0))
BEGIN
	SELECT [DATA_ID], [TIME_STAMP], [DICTIONARY_VERSION], [SOURCE], [AIRPORT_CODE], [LICENSE_PLATE], [AIRLINE], [FLIGHT_NUMBER], [SDO], [DESTINATION], [TRAVEL_CLASS], [INBOUND_AIRLINE], [INBOUND_FLIGHT_NUMBER], [INBOUND_SDO], [INBOUND_AIRPORT_CODE], [INBOUND_TRAVEL_CLASS], [ONWARD_AIRLINE], [ONWARD_FLIGHT_NUMBER], [ONWARD_SDO], [ONWARD_AIRPORT_CODE], [ONWARD_TRAVEL_CLASS], [NO_PASSENGER_SAME_SURNAME], [SURNAME], [GIVEN_NAME], [OTHERS_NAME], [BAG_EXCEPTION], [CHECK_IN_COUNTER], [CHECK_IN_COUNTER_DESCRIPTION], [CHECK_IN_TIME_STAMP], [CHECK_IN_CARRIAGE_MEDIUM], [CHECK_IN_TRANSPORT_ID], [TAG_PRINTER_ID], [RECONCILIATION_LOAD_AUTHORITY], [RECONCILIATION_SEAT_NUMBER], [RECONCILIATION_PASSENGER_STATUS], [RECONCILIATION_SEQUENCE_NUMBER], [RECONCILIATION_SECURITY_NUMBER], [RECONCILIATION_PASSENGER_PROFILES_STATUS], [RECONCILIATION_TRANSPORT_AUTHORITY], [RECONCILIATION_BAG_TAG_STATUS], [HANDLING_TERMINAL], [HANDLING_BAR], [HANDLING_GATE], [WEIGHT_INDICATOR], [WEIGHT_CHECKED_BAG_NUMBER], [CHECKED_WEIGHT], [UNCHECKED_WEIGHT], [WEIGHT_UNIT], [WEIGHT_LENGTH], [WEIGHT_WIDTH], [WEIGHT_HEIGHT], [WEIGHT_BAG_TYPE_CODE], [GROUND_TRANSPORT_EARLIEST_DELIVERY], [GROUND_TRANSPORT_LATEST_DELIVERY], [GROUND_TRANSPORT_DESCRIPTION], [FREQUENT_TRAVELLER_ID_NUMBER], [FREQUENT_TRAVELLER_TIER_ID], [CORPORATE_NAME], [AUTOMATED_PNR_ADDRESS], [MESSAGE_PRINTER_ID], [INTERNAL_AIRLINE_DATA], [SECURITY_SCREENING_INSTRUCTION], [SECURITY_SCREENING_RESULT], [SECURITY_SCREENING_RESULT_REASON], [SECURITY_SCREENING_RESULT_METHOD], [SECURITY_SCREENING_AUTOGRAPH], [SECURITY_SCREENING_FREE_TEXT], [HIGH_RISK], [HBS_LEVEL_REQUIRED], [CREATED_BY]
	FROM BAG_SORTING WHERE [TIME_STAMP] BETWEEN DATEADD(HH,-6,GETDATE()) 
	AND DATEADD(HH,24,GETDATE())
END
ELSE
BEGIN
	SELECT [DATA_ID], [TIME_STAMP], [DICTIONARY_VERSION], [SOURCE], [AIRPORT_CODE], [LICENSE_PLATE], [AIRLINE], [FLIGHT_NUMBER], [SDO], [DESTINATION], [TRAVEL_CLASS], [INBOUND_AIRLINE], [INBOUND_FLIGHT_NUMBER], [INBOUND_SDO], [INBOUND_AIRPORT_CODE], [INBOUND_TRAVEL_CLASS], [ONWARD_AIRLINE], [ONWARD_FLIGHT_NUMBER], [ONWARD_SDO], [ONWARD_AIRPORT_CODE], [ONWARD_TRAVEL_CLASS], [NO_PASSENGER_SAME_SURNAME], [SURNAME], [GIVEN_NAME], [OTHERS_NAME], [BAG_EXCEPTION], [CHECK_IN_COUNTER], [CHECK_IN_COUNTER_DESCRIPTION], [CHECK_IN_TIME_STAMP], [CHECK_IN_CARRIAGE_MEDIUM], [CHECK_IN_TRANSPORT_ID], [TAG_PRINTER_ID], [RECONCILIATION_LOAD_AUTHORITY], [RECONCILIATION_SEAT_NUMBER], [RECONCILIATION_PASSENGER_STATUS], [RECONCILIATION_SEQUENCE_NUMBER], [RECONCILIATION_SECURITY_NUMBER], [RECONCILIATION_PASSENGER_PROFILES_STATUS], [RECONCILIATION_TRANSPORT_AUTHORITY], [RECONCILIATION_BAG_TAG_STATUS], [HANDLING_TERMINAL], [HANDLING_BAR], [HANDLING_GATE], [WEIGHT_INDICATOR], [WEIGHT_CHECKED_BAG_NUMBER], [CHECKED_WEIGHT], [UNCHECKED_WEIGHT], [WEIGHT_UNIT], [WEIGHT_LENGTH], [WEIGHT_WIDTH], [WEIGHT_HEIGHT], [WEIGHT_BAG_TYPE_CODE], [GROUND_TRANSPORT_EARLIEST_DELIVERY], [GROUND_TRANSPORT_LATEST_DELIVERY], [GROUND_TRANSPORT_DESCRIPTION], [FREQUENT_TRAVELLER_ID_NUMBER], [FREQUENT_TRAVELLER_TIER_ID], [CORPORATE_NAME], [AUTOMATED_PNR_ADDRESS], [MESSAGE_PRINTER_ID], [INTERNAL_AIRLINE_DATA], [SECURITY_SCREENING_INSTRUCTION], [SECURITY_SCREENING_RESULT], [SECURITY_SCREENING_RESULT_REASON], [SECURITY_SCREENING_RESULT_METHOD], [SECURITY_SCREENING_AUTOGRAPH], [SECURITY_SCREENING_FREE_TEXT], [HIGH_RISK], [HBS_LEVEL_REQUIRED], [CREATED_BY]
	FROM BAG_SORTING WHERE [DATA_ID]=''
END
-- CHUTE MAPPING
IF((@Status = 0) OR (PATINDEX('%CHUTE_MAPPING%', @Statecodes)>0))
BEGIN
	SELECT [CHUTE], [SORTER], [DESTINATION] FROM CHUTE_MAPPING
END
ELSE
BEGIN
	SELECT [CHUTE], [SORTER], [DESTINATION] FROM CHUTE_MAPPING WHERE [CHUTE] = ''
END
-- FALLBACK MAPPING
IF((@Status = 0) OR (PATINDEX('%FALLBACK_MAPPING%', @Statecodes)>0))
BEGIN
	SELECT [ID], [DESTINATION], [DESCRIPTION], [SYS_ACTION] FROM FALLBACK_MAPPING
END
ELSE
BEGIN
	SELECT [ID], [DESTINATION], [DESCRIPTION], [SYS_ACTION] FROM FALLBACK_MAPPING
	WHERE [ID] = ''
END
-- FLIGHT PLAN ALLOC
IF((@Status = 0) OR (PATINDEX('%FLIGHT_PLAN_ALLOC%', @Statecodes)>0))
BEGIN
	SELECT [AIRLINE], [FLIGHT_NUMBER], [SDO], [STO], [RESOURCE], [WEEKDAY], [EDO], [ETO], 
	[ADO], [ATO], [IDO], [ITO], [TRAVEL_CLASS], [HIGH_RISK], [HBS_LEVEL_REQUIRED], 
	[EARLY_OPEN_OFFSET], [EARLY_OPEN_ENABLED], [ALLOC_OPEN_OFFSET], [ALLOC_OPEN_RELATED], 
	[ALLOC_CLOSE_OFFSET], [ALLOC_CLOSE_RELATED], [RUSH_DURATION], [SCHEME_TYPE], 
	[CREATED_BY], [TIME_STAMP], [HOUR], [IS_MANUAL_CLOSE], [IS_CLOSED] 
	FROM FLIGHT_PLAN_ALLOC WHERE [TIME_STAMP] BETWEEN DATEADD(HH,-6,GETDATE()) 
	AND DATEADD(HH,24,GETDATE())
END
ELSE
BEGIN
	SELECT [AIRLINE], [FLIGHT_NUMBER], [SDO], [STO], [RESOURCE], [WEEKDAY], [EDO], [ETO], 
	[ADO], [ATO], [IDO], [ITO], [TRAVEL_CLASS], [HIGH_RISK], [HBS_LEVEL_REQUIRED], 
	[EARLY_OPEN_OFFSET], [EARLY_OPEN_ENABLED], [ALLOC_OPEN_OFFSET], [ALLOC_OPEN_RELATED], 
	[ALLOC_CLOSE_OFFSET], [ALLOC_CLOSE_RELATED], [RUSH_DURATION], [SCHEME_TYPE], 
	[CREATED_BY], [TIME_STAMP], [HOUR], [IS_MANUAL_CLOSE], [IS_CLOSED] 
	FROM FLIGHT_PLAN_ALLOC WHERE [AIRLINE] = ''
END
-- FUNCTION ALLOC GANTT
IF((@Status = 0) OR (PATINDEX('%FUNCTION_ALLOC_GANTT%', @Statecodes)>0))
BEGIN
	SELECT [TIME_STAMP], [FUNCTION_TYPE], [RESOURCE], [ALLOC_OPEN_DATETIME], 
	[ALLOC_CLOSE_DATETIME], [IS_CLOSED], [EXCEPTION]
	FROM FUNCTION_ALLOC_GANTT
END
ELSE
BEGIN
	SELECT [TIME_STAMP], [FUNCTION_TYPE], [RESOURCE], [ALLOC_OPEN_DATETIME], 
	[ALLOC_CLOSE_DATETIME], [IS_CLOSED], [EXCEPTION]
	FROM FUNCTION_ALLOC_GANTT WHERE [TIME_STAMP] = ''
END
-- FUNCTION TYPES
IF((@Status = 0) OR (PATINDEX('%FUNCTION_TYPES%', @Statecodes)>0))
BEGIN
	SELECT [TYPE], [GROUP], [DESCRIPTION], [IS_ALLOCATED], [IS_ENABLED] FROM FUNCTION_TYPES
END
ELSE
BEGIN
	SELECT [TYPE], [GROUP], [DESCRIPTION], [IS_ALLOCATED], [IS_ENABLED] FROM FUNCTION_TYPES
	WHERE [TYPE]=''
END
-- SYS CONFIG
IF((@Status = 0) OR (PATINDEX('%SYS_CONFIG%', @Statecodes)>0))
BEGIN
	SELECT [SYS_KEY], [SYS_VALUE], [DEFAULT_VALUE], [LAST_VALUE], [DESCRIPTION], 
	[VALUE_TOKEN], [SYS_ACTION], [GROUP_NAME], [ORDER_FLAG], [IS_ENABLED] FROM SYS_CONFIG
END
ELSE
BEGIN
	SELECT [SYS_KEY], [SYS_VALUE], [DEFAULT_VALUE], [LAST_VALUE], [DESCRIPTION], 
	[VALUE_TOKEN], [SYS_ACTION], [GROUP_NAME], [ORDER_FLAG], [IS_ENABLED] FROM SYS_CONFIG
	WHERE [SYS_KEY] = ''
END
-- ##########################################################################
-- Release#:    R1.00
-- Release On:  13 May 2009
-- Filename:    2.1.SAC_CreateTable.sql
-- Description: SQL Scripts of creating BHS Solution Database [BHSDB] objects 
--              (table, view, trigger, foreign keys, etc.)
--    Tables to be created by this script:
--    01. [AIRPORTS]
--    02. [AIRLINES] - Used to store the airline information and the default sortation destination of 
--                     No BSM Discharge.
--                     Note: Onle single No BSM Discharge per airline is allowed.
--    03. [AIRCRAFT_TYPES]
--    04. [HANDLER]
--    05. [MONTH_CONFIG]
--    06. [WEEKDAY_CONFIG]
--    07. [HOUR_CONFIG]
--    08. [BSM_FI_ACTIONS] - Used to store the valid ACTION list of BSM message and Flight Information
--                         message received from BHS-BIS and BHS-FIS interfaces. Valid values are
--                         NEW (New BSM or FI), UPD (Update existing BSM or FI), DEL (Delete existing
--                         BSM or FI).
--    09. [BAGS]         - Used to store all valid format raw BSM received from BHS-DCS interface.
--                         Historical data table to be used for reporting purpose.
--                         The records is inserted by BHS-DCS interface gateway service. BHS-DCS
--                         interface gateway service is only allowed to insert the received BSM into
--                         [BAGS] table, no matter action of incoming BSM is NEW, UPD, or DEL. 
--                         [BAGS] table Insert trigger will insert new BSM, update or delete existing 
--                         BSM into or from working table [BAG_SORTING] depend on the ACTION field value 
--                         of INSERTED record. Hence, [BAGS] table has only INSERT trigger, no UPDATE 
--                         and DELETE trigger. 
--                         Historical data table type housekeeping (e.g. 1 ~ 12 months) is needed.
--    10. [BAG_SORTING]  - Working data table to store limited time period (Type 1: 14 ~ 30 days) of BSM data 
--                         for sortation destination decision making, to maintain the sortation query 
--                         performance.
--                         The records is inserted or updated by INSERT or UPDATE Trigger of table [BAGS].
--                         Working data table type 1 housekeeping (Type 1: 14 ~ 30 days) is needed.
--    11. [BAG_ERROR_BSM]- Used to store all invalid format BSM that is received from BHS-DCS interface.
--                         Historical data table to be used for reporting purpose.
--                         The records is inserted or updated by BHS-DCS interface gateway service.
--                         Historical data table type housekeeping (e.g. 1 ~ 12 months) is needed.
--    12. [BAG_INFO]     - Working data table to be used by SortEngine service for sortation destination
--                         making purpose.
--                         The records is inserted and updated by SortEngine service.
--                         Note: 
--                         Working data table type 2 housekeeping (Type 2: 3 days) is needed. This is 
--                         to prevent the repeating of GID# is inserted into this table and result in 
--                         returning of wrong sortation destination of given GID#. 
--    13. [SYS_CONFIG]   - Used to store SAC system public parameters. All these public parameters could
--                         be changed by using "BHS Configuration" GUI of Departure Allocation application.
--    14. [FLIGHTS]      - Static data table used to store the Flight (Note: no the Flight Schedule Plan)
--                         data. The records in this table should not grow after the initial data is inserted.
--    15. [FLIGHT_PLANS] - Used to store all valid format raw Flight schedule plan information that are 
--                         received from BHS-FIS interface.
--                         The records is inserted by BHS-FIS interface gateway service. BHS-FIS
--                         interface gateway service is only allowed to insert the received FI into
--                         [FLIGHT_PLANS] table, no matter action of incoming FI is NEW, UPD, or DEL. 
--                         [FLIGHT_PLANS] table Insert trigger will insert new FI, update or delete existing 
--                         FI into or from working table [FLIGHT_PLAN_SORTING] depend on the ACTION field value 
--                         of INSERTED record. Hence, [FLIGHT_PLANS] table has only INSERT trigger, no UPDATE 
--                         and DELETE trigger. 
--                         Historical data table type housekeeping (e.g. 1 ~ 12 months) is needed.
--    16. [FLIGHT_PLAN_SORTING] - Working data table to store limited time period (Type 1: 14 ~ 30 days) of 
--                         Flight schedule plan data for sortation destination decision making, to 
--                         maintain the sortation query performance.
--                         The records is inserted or updated by INSERT or UPDATE Trigger of table [FLIGHT_PLANS].
--                         Working data table type 1 housekeeping (Type 1: 14 ~ 30 days) is needed.
--    17. [FLIGHT_PLAN_ERROR] - Used to store all invalid format Flight schedule plan data that is received 
--                         from BHS-FIS interface.
--                         Historical data table to be used for reporting purpose.
--                         The records is inserted or updated by BHS-FIS interface gateway service.
--                         Historical data table type housekeeping (e.g. 1 ~ 12 months) is needed.
--    18. [FLIGHT_PLAN_ALLOC] - The possible values for column named CREATED_BY are "TMP", "MAN" and "FIS".
--								TMP - Allocation do by Template
--								MAN - Allocation do by operator in DA
--								FIS - Allocation do by FIS
--    19. [TEMPLATE_FLIGHT_PLAN_ALLOC]
--    20. [TEMPLATE_ASSIGNMENTS]
--    21. [TEMPLATES]
--    22. [TEMPLATE_GROUPS]
--    23. [FUNCTION_TYPE_GROUPS] - Used to store group name of function types. Function types are seperated 
--                         into two (2) groups. The allocation of group 1 function types will has allocation 
--                         opening and close time. The available allocation destinations of this type is 
--                         defined in the table [ALLOC_RESOURCES]. the created allocation of this group
--                         function types could be deleted from the GUI Gantt Chart.
--
--                         The allocation of group 2 function types are permanent setting and can not 
--                         be deleted. The available allocation destinations of this type is 
--                         defined in the table [DESTINATIONS].
--
--                         Group 1 is the functions whose allocation is created in the Gantt
--                         chart by mouse drag the selected function type in the function list and drop
--                         it to one of the allocation resources in the Gantt Chart. The created allocation 
--                         of group 1 function types will be shown on the GUI Gantt Chart.
--
--                         Group 2 is the functions whose allocation is created in the BHS Configuration
--                         dialog box. The created allocation of group 2 function types will not be shown 
--                         on the GUI Gantt Chart.
--    24. [FUNCTION_TYPES] - Used to store function types. 
--    25. [FUNCTION_ALLOC_GANTT] - Used to store function allocations of above group 1 function types. 
--                         They are created and displayed via the GUI Gantt Chart.
--    26. [FUNCTION_ALLOC_LIST] - Used to store function allocations of above group 2 function types. 
--                         They are created and displayed via the BHS Configuration window.
--    27. [SCHEME_TYPE]
--    28. [GID_USED] - Use to store the historical of GID generated for each bag.
--    29. [ITEM_TRACKING] - Use to store the bags tracking information.
--    30. [ITEM_READY] - Use to store the Item Ready from PLC to MES.
--    31. [ITEM_REMOVED] - Use to store the Item Removed from MES to PLC.
--    32. [ITEM_ENCODING_REQUEST]
--    33. [ITEM_ENCODING_REQUEST_TYPES]
--    34. [ITEM_DEST_REQUEST]
--    35. [ITEM_LOST]
--    36. [ITEM_SCREENED]
--    37. [ITEM_SCREEN_RESULT_TYPES]
--    38. [ITEM_SCANNED]
--    39. [ITEM_SCAN_STATUS_TYPES]
--    40. [ITEM_PROCEEDED]
--    41. [ITEM_PROCEED_TYPES]
--    42. [ITEM_REDIRECT]
--    43. [ITEM_SORTATION_EVENT]
--    44. [ITEM_SORTATION_EVENT_TYPES]
--    45. [ALLOC_RESOURCES] - Used to store the valid name list of Allocation Destinations that need to 
--                         be displayed on the Departure Allocation Application GUI Gantt Chart.
--    46. [DESTINATIONS] - Used to store the valid name list of baggage destinations that need to be 
--                         returned from SAC to PLC via Item Redirect Message.
--    47. [DESTINATION_GROUPING]
--    48. [SUBSYSTEMS]
--    49. [SUBSYSTEM_GROUPING]
--    50. [LOCATIONS]
--    51. [LOCATION_STATUS_TYPES]
--    52. [ROUTING_TABLE]
--    53. [SORTATION_REASON]
--    54. [ROLES]
--    55. [USERS]
--    56. [USERS_ROLES]
--    57. [AUDIT_LOG]    - Used to record down the operations (INS, UPD, DEL) made on following tables:
--                         [FUNCTION_ALLOC], [FUNCTION_TYPES], [SYS_CONFIG], [ROLES], [AIRLINES],
--                         [AIRPORTS], [FLIGHTS], [AIRCRAFT_TYPES], [USERS], [USERS_ROLES] 
--    58. [SAC_OWS]      - Used to store computer name of PC on which the Departure Allocation GUI 
--                         application is running. 
--                         Note: 
--                         1. The field [SAC_OWS] value must identical to the actuall computer
--                            name that the Departure Allocation GUI application is running on.
--                         2. The number of records in the table must identical to the number 
--                            of physical computers running Departure Allocation GUI application.
--    59. [CHANGE_MONITORING] - Provide a series of indicaters to inform SAC applications, which are 
--                         running on the inividual physical workstations (e.g. Departure Allication), 
--                         about the Table or field value has been changed. Its field [IS_CHANGED] value
--                         will be set to 1 by insert, update or delete triggers of following tables:
--                         [SYS_CONFIG], [FUNCTION_ALLOC], [FLIGHT_PLAN_ALLOC], [FLIGHT_PLAN_SORTING], 
--                         and the changing of value of field [IS_MANUAL_CLOSE] in the table 
--                         [FLIGHT_PLAN_ALLOC].
--                         Note: 
--                         1. Each computer on which the Departure Allocation GUI application is running
--                            shall have its own set records to indicate the change status of above 
--                            tables and Field. 
--                         2. The field [SAC_OWS] value must identical to the actuall computer
--                            name that the Departure Allocation GUI application is running on.
--    60. [APP_LIVE_MONITORING]
--    61. [APP_LIVE_STATUS_TYPES]
--    62. [FALLBACK_MAPPING]
--    63. [MES_EVENT]
--    64. [EVENT_TYPES]
--    65. [PICTURES]     - Used to store logo image for reporting purpose.
--    66. [HIGH_RISK_NEEDED] - Table used to restrict the valid value range of field [HIGH_RISK] in 
--                         the table [FLIGHT_PLANS] and [FLIGHT_PLAN_SORTING] by setting Foreign Key
--                         link to [HIGH_RISK] field in above 2 tables and [VALUE] field in [HIGH_RISK_NEEDED]
--                         field. There are 2 valid values of [HIGH-RISK] field, Y and N.
--                         Y - Flight is High Risk Flight;
--                         N - Flight is Not High Risk Flight;
--
--    67. [SECURITY_CATEGORIES]
--    68. [SECURITY_TASKS]
--    69. [SECURITY_GROUPS]
--    70. [SECURITY_GROUP_TASK_MAPPING]
--	  71. [SECURITY_USERS]
--    72. [SECURITY_USER_RIGHTS]
--	  73. [EXCEPTION_TYPE] - this table values will direct insert while recieved BSM of Flight Information.  
--		  The column of [TYPE] is exception type, [SOURCE] is from where this type from, either "BSM" or "FLT" (Flight Information)  
--	  74. [TRACKING_ZONE_GROUPING] - Use for grouping specific equipment into respective tracking zone to report the fault occured on this zone.  mainly use for reporting. 
--	  75. [BHS_FIS_OUTGOING_ALLOCATIONS] - Use to store all data which need to send out to FIS.
--										   The possible values for column named ALLOC_TYPE are "FLT" and "FUN".
--										   FLT - Flight Allocation
--										   FUN - Functuion Allocation including List and Grantt.
--	  74. [DEPARTURE_FLIGHT_ALLOC_REPLY] - Use for store the historical data of FARL which send to FIS. 
--	  75. [DEPARTURE_FLIGHT_ALLOC_DELETED] - Use for store the historical data of FADL which send to FIS. 
--	  76. [DEPARTURE_FUNCTION_ALLOC_REPLY] - Use for store the historical data of FURL which send to FIS. 
--	  77. [DEPARTURE_FUNCTION_ALLOC_DELETED] - Use for store the historical data of FUDL which send to FIS. 
--	  78. [ENCAPSULATED_BPM] - Use for store the historical data of EBPM which send to BIS. 
--	  79. [BAGGAGE_MEASURE_ARRAY_TYPE] - Provides the status of baggage measurement array type.
--    80. [BAGGAGE_MEASURE_ARRAY_MSG] - Use for store the baggage measurement array message.
--	  81. [FALLBACK_TAG_INFO] - Use for store the fallback tag information send to PLC
--	  82. [CHUTE_MAPPING] - Use for mapping between destinations make-up carousel and chutes.
--	  83. [ITEM_MINIMUM_SECURITY_LEVEL] - Use for store the Item Minimum Security Level received from PLC.
--	  84. [MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST] - Use for store the Make-up Carousel and Chute Mapping List send to PLC.
--    85. [ITEM_CUSTOMS_SCREENED] - Use for store the Item Screened received from PLC.
--    86. [ITEM_CUSTOMS_RESULT_TYPES] - Provides the result type description of the customs result.
--    87. [ITEM_ENCODED] - Use for store the Item Encoded from MES to PLC.
--
--    Views to be created by this script:
--    01. 
--
--    Foreign Keys to be created by this script:
--    01. [FK_AIRLINES_DESTINATION]
--    02. [FK_AUDIT_LOG_EVENT_TYPE]
--    03. [FK_FLIGHT_PLAN_ALLOC_RESOURCE]
--    04. [FK_FLIGHT_PLAN_SORTING_HIGH_RISK]
--    05. [FK_FLIGHT_PLANS_HIGH_RISK]
--    06. [FK_FLIGHTS_AIRCRAFT_TYPE]
--    07. [FK_FLIGHTS_AIRLINE_CODE_IATA]
--    08. [FK_FUNCTION_TYPES_GROUP]
--    09. [FK_FUNCTION_ALLOC_GANTT_RESOURCE]
--    10. [FK_FUNCTION_ALLOC_LIST_RESOURCE]
--    11. [FK_FUNCTION_ALLOC_GANTT_FUNC_TYPE]
--    12. [FK_FUNCTION_ALLOC_LIST_FUNC_TYPE]
--    13. [FK_ITEM_PROCEEDED_TYPE]
--	  14. 
--    15. [FK_ITEM_REDIRECT_SORTATION_REASON]
--    16. [FK_ITEM_SCANNED_STATUS_TYPE]
--    17. [FK_ITEM_SCREENED_RESULT_TYPE]
--    18. [FK_ITEM_SORTATION_EVENT_TYPE]
--    19. [FK_ALLOC_RESOURCES_SUBSYSTEM]
--    20. [FK_DESTINATIONS_SUBSYSTEM]
--    21. [FK_DESTINATION_GROUPING_LOCATIONS]
--    22. [FK_DESTINATION_GROUPING_NAME]
--    23. [FK_DESTINATION_GROUPING_LOCATION]
--    24. [FK_FALLBACK_MAPPING_DESTINATION]
--    25. [FK_LOCATIONS_STATUS_TYPE]
--    26. [FK_LOCATIONS_SUBSYSTEM]
--    27. [FK_USER_ROLES_ROLEID]
--    28. [FK_USER_ROLES_USERID]
--    29. [FK_APP_LIVE_MONITORING_STATUS_TYPE]
--    30. [FK_TEMPLATES_TEMPLATE_GROUP]
--    31. [FK_TEMPLATE_ASSIGNMENTS_TEMPLATE_ID]
--    32. [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_TEMPLATE_ID]
--    33. [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_RESOURCE]
--    34. [FK_CHANGE_MONITORING_SAC_OWS]
--	  35. [FK_ITEM_ENCODING_REQUEST_TYPE]
--	  36. [FK_SECURITY_TASKS_SECU_CAT_CODE]
--	  37. [FK_SECURITY_GROUPS_SECU_CAT_CODE]
--	  38. [FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE]
--	  39. [FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE]
--	  40. [FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE]
--	  41. [FK_SECURITY_USER_RIGHTS_USER_NAME]
--	  42. [FK_BAG_SORTING_BAG]
--	  43. [FK_BAG_ERROR_BSM_BAG]
--	  44. [FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS]
--	  45. [FLIGHT_PLAN_ERROR_FLIGHT_PLANS]
--	  46. [FK_BAGGAGE_MEASURE_ARRAY_MSG_TYPE] - The column TYPE of table BAGGAGE_MEASURE_ARRAY_MSG point to the Primary Key (TYPE) of table BAGGAGE_MEASURE_ARRAY_TYPE.
--	  47. [FK_ITEM_CUSTOMS_SCREENED_RESULT_TYPE] - The column RESULT_TYPE of table ITEM_CUSTOMS_SCREENED point to the Primary Key (TYPE) of table ITEM_CUSTOMS_RESULT_TYPES.
--
--    Constraints to be created by this script:
--    01. [DF_SECURITY_CATEGORIES_IS_ACTIVE]
--    02. [DF_SECURITY_TASKS_IS_ACTIVE]
--	  03. [DF_SECURITY_GROUPS_IS_ACTIVE]
--	  04. [DF_SECURITY_USERS_IS_ACTIVE]
--
--
--    Triggers to be created by this script:
--    01. [INSERT_BAG_ERROR] - Insert trigger of table [BAG_ERROR_BSM]
--    02. [INSERT_FLIGHT_PLAN_ERROR] - Insert trigger of table [FLIGHT_PLAN_ERROR]
--    03. [INSERT_FLIGHT_PLAN_SORTING] - Insert trigger of table [FLIGHT_PLAN_SORTING]
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_FLIGHT_PLAN_SORTING';
--                        2. Auto creating allocation for inserted flight base on the Template assignment to the date of SDO.
--    04. [UPDATE_FLIGHT_PLAN_SORTING] - Update trigger of table [FLIGHT_PLAN_SORTING] 
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_FLIGHT_PLAN_SORTING';
--                        2. Updating existing allocations in the [FLIGHT_PLAN_ALLOC] table for inserted flight.
--    05. [DELETE_FLIGHT_PLAN_SORTING] - Delete trigger of table [FLIGHT_PLAN_SORTING] 
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_FLIGHT_PLAN_SORTING';
--                        2. Delete existing allocations in the [FLIGHT_PLAN_ALLOC] table for deleted flight.
--    06. [INSERT_FLIGHT_PLAN_ALLOC] - Insert trigger of table [FLIGHT_PLAN_ALLOC]
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_FLIGHT_PLAN_ALLOC';
--                        2. UPDATE [FLIGHT_PLAN_SORTING] SET [IS_ALLOCATED]=1 WHERE [AIRLINE]=@AIRLINE AND 
--                                  [FLIGHT_NUMBER]=@FLIGHT_NUMBER AND [SDO]=@SDO;
--    07. [UPDATE_FLIGHT_PLAN_ALLOC] - Update trigger of table [FLIGHT_PLAN_ALLOC] 
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_FLIGHT_PLAN_ALLOC';
--                        2. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='CO_MANUAL_CLOSE';
--    08. [DELETE_FLIGHT_PLAN_ALLOC] - Delete trigger of table [FLIGHT_PLAN_ALLOC] 
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_FLIGHT_PLAN_ALLOC';
--                        2. Update [IS_ALLOCATED]=0 in the table [FLIGHT_PLAN_SORTING] if all allocations of 
--                           specific flight have been deleted.
--    09. [INSERT_FUNCTION_ALLOC_GANTT] - Insert trigger of table [FUNCTION_ALLOC_GANTT]
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_FUNCTION_ALLOC';
--                        2. UPDATE [FUNCTION_TYPES] SET [IS_ALLOCATED]=1 WHERE FUNCTION_TYPE = @FuncType;
--                        3. Record "INS" event of table [FUNCTION_ALLOC_GANTT] into table [AUDIT_LOG];
--    10. [UPDATE_FUNCTION_ALLOC_GANTT] - Update trigger of table [FUNCTION_ALLOC_GANTT] 
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_FUNCTION_ALLOC';
--						  2. INSERT INTO [BHS_FIS_OUTGOING_ALLOCATIONS] TABLE WHERE ALLOC_OPEN_DATETIME != ALLOC_CLOSE_DATETIME
--                        3. Delete the function allocation from table [FUNCTION_ALLOC_GANTT] whose ALLOC_OPEN_DATETIME 
--                           and ALLOC_CLOSE_DATETIME time different is less than 60 seconds. In other words, the 
--                           function allocation open time and close time will be treated as identical if their time 
--                           different less than 1 minute. and this function allocation will be removed from 
--                           DA application GUI Gantt chart;
--                        4. UPDATE specific function type [IS_ALLOCATED] field value in the table [FUNCTION_TYPES];
--                        5. Record "UPD" event of table [FUNCTION_ALLOC_GANTT] into table [AUDIT_LOG];
--    11. [DELETE_FUNCTION_ALLOC_GANTT] - Delete trigger of table [FUNCTION_ALLOC_GANTT] 
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_FUNCTION_ALLOC';
--                        2. UPDATE specific function type [IS_ALLOCATED] field value in the table [FUNCTION_TYPES];
--                        3. Record "DEL" event of table [FUNCTION_ALLOC_GANTT] into table [AUDIT_LOG];
--    12. [INSERT_FUNCTION_TYPES] - Insert trigger of table [FUNCTION_TYPES]
--                        1. Record "INS" event of [FUNCTION_TYPES] into table [AUDIT_LOG];
--    13. [UPDATE_FUNCTION_TYPES] - Update trigger of table [FUNCTION_TYPES]
--                        1. Record "UPD" event of [FUNCTION_TYPES] into table [AUDIT_LOG];
--    14. [DELETE_FUNCTION_TYPES] - Delete trigger of table [FUNCTION_TYPES]
--                        1. Record "DEL" event of [FUNCTION_TYPES] into table [AUDIT_LOG];
--    15. [INSERT_SYS_CONFIG] - Insert trigger of table [SYS_CONFIG]
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_SYS_CONFIG';
--                        2. Record "INS" event of [SYS_CONFIG] into table [AUDIT_LOG];
--    16. [UPDATE_SYS_CONFIG] - Update trigger of table [SYS_CONFIG]
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_SYS_CONFIG';
--                        2. Record "UPD" event of [SYS_CONFIG] into table [AUDIT_LOG];
--    17. [DELETE_SYS_CONFIG] - Delete trigger of table [SYS_CONFIG]
--                        1. UPDATE [CHANGE_MONITORING] SET [IS_CHANGED]=1 WHERE [STATE_CODE]='TB_SYS_CONFIG';
--                        2. Record "DEL" event of [SYS_CONFIG] into table [AUDIT_LOG];
--    18. [INSERT_ROLES] - Insert trigger of table [ROLES]
--                        1. Record "INS" event of [ROLES] into table [AUDIT_LOG];
--    19. [UPDATE_ROLES] - Update trigger of table [ROLES]
--                        1. Record "UPD" event of [ROLES] into table [AUDIT_LOG];
--    20. [DELETE_ROLES] - Delete trigger of table [ROLES]
--                        1. Record "DEL" event of [ROLES] into table [AUDIT_LOG];
--    21. [INSERT_AIRLINES] - Insert trigger of table [AIRLINES]
--                        1. Record "INS" event of [AIRLINES] into table [AUDIT_LOG];
--    22. [UPDATE_AIRLINES] - Update trigger of table [AIRLINES]
--                        1. Record "UPD" event of [AIRLINES] into table [AUDIT_LOG];
--    23. [DELETE_AIRLINES] - Delete trigger of table [AIRLINES]
--                        1. Record "DEL" event of [AIRLINES] into table [AUDIT_LOG];
--    24. [INSERT_AIRPORTS] - Insert trigger of table [AIRPORTS]
--                        1. Record "INS" event of [AIRPORTS] into table [AUDIT_LOG];
--    25. [UPDATE_AIRPORTS] - Update trigger of table [AIRPORTS]
--                        1. Record "UPD" event of [AIRPORTS] into table [AUDIT_LOG];
--    26. [DELETE_AIRPORTS] - Delete trigger of table [AIRPORTS]
--                        1. Record "DEL" event of [AIRPORTS] into table [AUDIT_LOG];
--    27. [INSERT_FLIGHTS] - Insert trigger of table [FLIGHTS]
--                        1. Record "INS" event of [FLIGHTS] into table [AUDIT_LOG];
--    28. [UPDATE_FLIGHTS] - Update trigger of table [FLIGHTS]
--                        1. Record "UPD" event of [FLIGHTS] into table [AUDIT_LOG];
--    29. [DELETE_FLIGHTS] - Delete trigger of table [FLIGHTS]
--                        1. Record "DEL" event of [FLIGHTS] into table [AUDIT_LOG];
--    30. [INSERT_AIRCRAFT_TYPES] - Insert trigger of table [AIRCRAFT_TYPES]
--                        1. Record "INS" event of [AIRCRAFT_TYPES] into table [AUDIT_LOG];
--    31. [UPDATE_AIRCRAFT_TYPES] - Update trigger of table [AIRCRAFT_TYPES]
--                        1. Record "UPD" event of [AIRCRAFT_TYPES] into table [AUDIT_LOG];
--    32. [DELETE_AIRCRAFT_TYPES] - Delete trigger of table [AIRCRAFT_TYPES]
--                        1. Record "DEL" event of [AIRCRAFT_TYPES] into table [AUDIT_LOG];
--    33. [INSERT_USERS] - Insert trigger of table [USERS]
--                        1. Record "INS" event of [USERS] into table [AUDIT_LOG];
--    34. [UPDATE_USERS] - Update trigger of table [USERS]
--                        1. Record "UPD" event of [USERS] into table [AUDIT_LOG];
--    35. [DELETE_USERS] - Delete trigger of table [USERS]
--                        1. Record "DEL" event of [USERS] into table [AUDIT_LOG];
--    36. [INSERT_USERS_ROLES] - Insert trigger of table [USERS_ROLES]
--                        1. Record "INS" event of [USERS_ROLES] into table [AUDIT_LOG];
--    37. [UPDATE_USERS_ROLES] - Update trigger of table [USERS_ROLES]
--                        1. Record "UPD" event of [USERS_ROLES] into table [AUDIT_LOG];
--    38. [DELETE_USERS_ROLES] - Delete trigger of table [USERS_ROLES]
--                        1. Record "DEL" event of [USERS_ROLES] into table [AUDIT_LOG];
--    39. [INSERT_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS] - Insert trigger of table [FLIGHT_PLAN_ALLOC]
--                        1. Record "NEW" ACTION of [ACTION] into table [BHS_FIS_OUTGOING_ALLOCATIONS];
--    40. [UPDATE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS] - Update trigger of table [FLIGHT_PLAN_ALLOC]
--                        1. Record "UPD" ACTION of [ACTION] into table [BHS_FIS_OUTGOING_ALLOCATIONS];
--    41. [DELETE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS] - Delete trigger of table [FLIGHT_PLAN_ALLOC]
--                        1. Record "DEL" ACTION of [ACTION] into table [BHS_FIS_OUTGOING_ALLOCATIONS];
--    42. [INSERT_FUNCTION_ALLOC_LIST] - Insert trigger of table [FUNCTION_ALLOC_LIST]
--                        1. Record "NEW" ACTION of [ACTION] into table [BHS_FIS_OUTGOING_ALLOCATIONS];
--    43. [UPDATE_FUNCTION_ALLOC_LIST] - Update trigger of table [FUNCTION_ALLOC_LIST]
--                        1. Record "UPD" ACTION of [ACTION] into table [BHS_FIS_OUTGOING_ALLOCATIONS];

--
--
-- Histories:
--				R1.0 - Released on 15 Mar 2010.
-- ##########################################################################


USE [BHSDB]
GO

PRINT 'INFO: STEP2 - Creat BHS Solution Database SAC Tables'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Drop Existing Tables...'
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIRPORTS]') AND type in (N'U'))
	DROP TABLE [dbo].[AIRPORTS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MONTH_CONFIG]') AND type in (N'U'))
	DROP TABLE [dbo].[MONTH_CONFIG]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WEEKDAY_CONFIG]') AND type in (N'U'))
	DROP TABLE [dbo].[WEEKDAY_CONFIG]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HOUR_CONFIG]') AND type in (N'U'))
	DROP TABLE [dbo].[HOUR_CONFIG]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BSM_FI_ACTIONS]') AND type in (N'U'))
	DROP TABLE [dbo].[BSM_FI_ACTIONS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAG_SORTING]') AND type in (N'U'))
	DROP TABLE [dbo].[BAG_SORTING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAG_ERROR_BSM]') AND type in (N'U'))
	DROP TABLE [dbo].[BAG_ERROR_BSM]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAGS]') AND type in (N'U'))
	DROP TABLE [dbo].[BAGS]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAG_INFO]') AND type in (N'U'))
	DROP TABLE [dbo].[BAG_INFO]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_CONFIG]') AND type in (N'U'))
	DROP TABLE [dbo].[SYS_CONFIG]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHTS]') AND type in (N'U'))
	DROP TABLE [dbo].[FLIGHTS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLAN_SORTING]') AND type in (N'U'))
	DROP TABLE [dbo].[FLIGHT_PLAN_SORTING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLAN_ERROR]') AND type in (N'U'))
	DROP TABLE [dbo].[FLIGHT_PLAN_ERROR]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLANS]') AND type in (N'U'))
	DROP TABLE [dbo].[FLIGHT_PLANS]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLAN_ALLOC]') AND type in (N'U'))
	DROP TABLE [dbo].[FLIGHT_PLAN_ALLOC]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]') AND type in (N'U'))
	DROP TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEMPLATE_ASSIGNMENTS]') AND type in (N'U'))
	DROP TABLE [dbo].[TEMPLATE_ASSIGNMENTS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEMPLATES]') AND type in (N'U'))
	DROP TABLE [dbo].[TEMPLATES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEMPLATE_GROUPS]') AND type in (N'U'))
	DROP TABLE [dbo].[TEMPLATE_GROUPS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FUNCTION_ALLOC_GANTT]') AND type in (N'U'))
	DROP TABLE [dbo].[FUNCTION_ALLOC_GANTT]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FUNCTION_ALLOC_LIST]') AND type in (N'U'))
	DROP TABLE [dbo].[FUNCTION_ALLOC_LIST]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FUNCTION_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[FUNCTION_TYPES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FUNCTION_TYPE_GROUPS]') AND type in (N'U'))
	DROP TABLE [dbo].[FUNCTION_TYPE_GROUPS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SCHEME_TYPE]') AND type in (N'U'))
	DROP TABLE [dbo].[SCHEME_TYPE]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GID_USED]') AND type in (N'U'))
	DROP TABLE [dbo].[GID_USED]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_TRACKING]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_TRACKING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_READY]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_READY]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_REMOVED]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_REMOVED]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_ENCODING_REQUEST]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_ENCODING_REQUEST]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_ENCODING_REQUEST_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_ENCODING_REQUEST_TYPES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_DEST_REQUEST]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_DEST_REQUEST]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_LOST]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_LOST]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SCREENED]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_SCREENED]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MDS_HBS_DATA]') AND type in (N'U'))
	DROP TABLE [dbo].[MDS_HBS_DATA]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SCREEN_RESULT_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_SCREEN_RESULT_TYPES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SCANNED]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_SCANNED]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SCAN_STATUS_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_SCAN_STATUS_TYPES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_PROCEEDED]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_PROCEEDED]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_PROCEED_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_PROCEED_TYPES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_REDIRECT]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_REDIRECT]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SORTATION_EVENT]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_SORTATION_EVENT]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SORTATION_EVENT_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_SORTATION_EVENT_TYPES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FALLBACK_MAPPING]') AND type in (N'U'))
	DROP TABLE [dbo].[FALLBACK_MAPPING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ROUTING_TABLE]') AND type in (N'U'))
	DROP TABLE [dbo].[ROUTING_TABLE]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SORTATION_REASON]') AND type in (N'U'))
	DROP TABLE [dbo].[SORTATION_REASON]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USERS_ROLES]') AND type in (N'U'))
	DROP TABLE [dbo].[USERS_ROLES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ROLES]') AND type in (N'U'))
	DROP TABLE [dbo].[ROLES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USERS]') AND type in (N'U'))
	DROP TABLE [dbo].[USERS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AUDIT_LOG]') AND type in (N'U'))
	DROP TABLE [dbo].[AUDIT_LOG]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHANGE_MONITORING]') AND type in (N'U'))
	DROP TABLE [dbo].[CHANGE_MONITORING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAC_OWS]') AND type in (N'U'))
	DROP TABLE [dbo].[SAC_OWS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[APP_LIVE_MONITORING]') AND type in (N'U'))
	DROP TABLE [dbo].[APP_LIVE_MONITORING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[APP_LIVE_STATUS_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[APP_LIVE_STATUS_TYPES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MES_EVENT]') AND type in (N'U'))
	DROP TABLE [dbo].[MES_EVENT]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EVENT_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[EVENT_TYPES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALLOC_RESOURCES]') AND type in (N'U'))
	DROP TABLE [dbo].[ALLOC_RESOURCES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIRLINES]') AND type in (N'U'))
	DROP TABLE [dbo].[AIRLINES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIRCRAFT_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[AIRCRAFT_TYPES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HANDLER]') AND type in (N'U'))
	DROP TABLE [dbo].[HANDLER]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PICTURES]') AND type in (N'U'))
	DROP TABLE [dbo].[PICTURES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DESTINATION_GROUPING]') AND type in (N'U'))
	DROP TABLE [dbo].[DESTINATION_GROUPING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DESTINATIONS]') AND type in (N'U'))
	DROP TABLE [dbo].[DESTINATIONS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LOCATIONS]') AND type in (N'U'))
	DROP TABLE [dbo].[LOCATIONS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LOCATION_STATUS_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[LOCATION_STATUS_TYPES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SUBSYSTEM_GROUPING]') AND type in (N'U'))
	DROP TABLE [dbo].[SUBSYSTEM_GROUPING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SUBSYSTEMS]') AND type in (N'U'))
	DROP TABLE [dbo].[SUBSYSTEMS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HIGH_RISK_NEEDED]') AND type in (N'U'))
	DROP TABLE [dbo].[HIGH_RISK_NEEDED]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_USER_RIGHTS]') AND type in (N'U'))
	DROP TABLE [dbo].[SECURITY_USER_RIGHTS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_USERS]') AND type in (N'U'))
	DROP TABLE [dbo].[SECURITY_USERS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_GROUP_TASK_MAPPING]') AND type in (N'U'))
	DROP TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_GROUPS]') AND type in (N'U'))
	DROP TABLE [dbo].[SECURITY_GROUPS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_TASKS]') AND type in (N'U'))
	DROP TABLE [dbo].[SECURITY_TASKS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_CATEGORIES]') AND type in (N'U'))
	DROP TABLE [dbo].[SECURITY_CATEGORIES]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TRACKING_ZONE_GROUPING]') AND type in (N'U'))
	DROP TABLE [dbo].[TRACKING_ZONE_GROUPING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]') AND type in (N'U'))
	DROP TABLE [dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEPARTURE_FLIGHT_ALLOC_REPLY]') AND type in (N'U'))
	DROP TABLE [dbo].[DEPARTURE_FLIGHT_ALLOC_REPLY]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEPARTURE_FLIGHT_ALLOC_DELETED]') AND type in (N'U'))
	DROP TABLE [dbo].[DEPARTURE_FLIGHT_ALLOC_DELETED]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEPARTURE_FUNCTION_ALLOC_REPLY]') AND type in (N'U'))
	DROP TABLE [dbo].[DEPARTURE_FUNCTION_ALLOC_REPLY]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEPARTURE_FUNCTION_ALLOC_DELETED]') AND type in (N'U'))
	DROP TABLE [dbo].[DEPARTURE_FUNCTION_ALLOC_DELETED]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ENCAPSULATED_BPM]') AND type in (N'U'))
	DROP TABLE [dbo].[ENCAPSULATED_BPM]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAGGAGE_MEASURE_ARRAY_MSG]') AND type in (N'U'))
	DROP TABLE [dbo].[BAGGAGE_MEASURE_ARRAY_MSG]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAGGAGE_MEASURE_ARRAY_TYPE]') AND type in (N'U'))
	DROP TABLE [dbo].[BAGGAGE_MEASURE_ARRAY_TYPE]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FALLBACK_TAG_INFO]') AND type in (N'U'))
	DROP TABLE [dbo].[FALLBACK_TAG_INFO]		
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHUTE_MAPPING]') AND type in (N'U'))
	DROP TABLE [dbo].[CHUTE_MAPPING]		
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_MINIMUM_SECURITY_LEVEL]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_MINIMUM_SECURITY_LEVEL]		
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST]') AND type in (N'U'))
	DROP TABLE [dbo].[MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST]			
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_CUSTOMS_SCREENED]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_CUSTOMS_SCREENED]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_CUSTOMS_RESULT_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_CUSTOMS_RESULT_TYPES]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_ENCODED]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_ENCODED]	



PRINT 'INFO: End of Drop Existing Tables.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Tables...'
GO




-- ****** Object:  Table [dbo].[AIRPORTS]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIRPORTS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [AIRPORTS]...'
	DROP TABLE [dbo].[AIRPORTS]
END
GO
PRINT 'INFO: Creating table [AIRPORTS]...'
CREATE TABLE [dbo].[AIRPORTS](
	[CODE_IATA] [varchar](3) NOT NULL,
	[CODE_ICAO] [varchar](4) NULL,
	[NAME] [nvarchar](50) NOT NULL,
	[COUNTRY] [nvarchar](50) NOT NULL,
	[CITY] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_AIRPORTS] PRIMARY KEY CLUSTERED 
(
	[CODE_IATA] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[AIRLINES]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIRLINES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [AIRLINES]...'
	DROP TABLE [dbo].[AIRLINES]
END
GO
PRINT 'INFO: Creating table [AIRLINES]...'
CREATE TABLE [dbo].[AIRLINES](
	[CODE_IATA] [varchar](3) NOT NULL,
	[CODE_ICAO] [varchar](3) NULL,
	[NAME] [nvarchar](50) NOT NULL,
	[TICKETING_CODE] [varchar](4) NOT NULL,
	[DESTINATION] [varchar](10) NULL,
	[DESTINATION1] [varchar](10) NULL,
 CONSTRAINT [PK_AIRLINES] PRIMARY KEY CLUSTERED 
(
	[CODE_IATA] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[AIRCRAFT_TYPES]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIRCRAFT_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [AIRCRAFT_TYPES]...'
	DROP TABLE [dbo].[AIRCRAFT_TYPES]
END
GO
PRINT 'INFO: Creating table [AIRCRAFT_TYPES]...'
CREATE TABLE [dbo].[AIRCRAFT_TYPES](
	[TYPE] [varchar](10) NOT NULL,
	[MAX_PAX] [int] NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_AIRCRAFT_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[HANDLER]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HANDLER]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [HANDLER]...'
	DROP TABLE [dbo].[HANDLER]
END
GO
PRINT 'INFO: Creating table [HANDLER]...'
CREATE TABLE [dbo].[HANDLER](
	[HANDLER] [varchar](1) NOT NULL,
	[NAME] [varchar](15) NOT NULL,
 CONSTRAINT [PK_HANDLER] PRIMARY KEY CLUSTERED 
(
	[HANDLER] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[MONTH_CONFIG]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MONTH_CONFIG]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [MONTH_CONFIG]...'
	DROP TABLE [dbo].[MONTH_CONFIG]
END
GO
PRINT 'INFO: Creating table [MONTH_CONFIG]...'
CREATE TABLE [dbo].[MONTH_CONFIG](
	[MONTHIND] [varchar](2) NOT NULL,
	[MONTHDESC] [varchar](15) NOT NULL,
	[MONTHABB] [varchar](3) NULL,
 CONSTRAINT [PK_MONTHID] PRIMARY KEY CLUSTERED 
(
	[MONTHIND] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[WEEKDAY_CONFIG]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WEEKDAY_CONFIG]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [WEEKDAY_CONFIG]...'
	DROP TABLE [dbo].[WEEKDAY_CONFIG]
END
GO
PRINT 'INFO: Creating table [WEEKDAY_CONFIG]...'
CREATE TABLE [dbo].[WEEKDAY_CONFIG](
	[WEEKDAY] [char](1) NOT NULL,
	[DESCRIPTION] [nvarchar](10) NOT NULL,
	[WEEKDAYABB] [varchar](10) NOT NULL,
	[WEEKDAYUPPER] [varchar](10) NOT NULL,
 CONSTRAINT [PK_WEEKDAY] PRIMARY KEY CLUSTERED 
(
	[WEEKDAY] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[HOUR_CONFIG]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HOUR_CONFIG]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [HOUR_CONFIG]...'
	DROP TABLE [dbo].[HOUR_CONFIG]
END
GO
PRINT 'INFO: Creating table [HOUR_CONFIG]...'
CREATE TABLE [dbo].[HOUR_CONFIG](
	[HOURIND] [varchar](2) NOT NULL,
 CONSTRAINT [PK_HOURID] PRIMARY KEY CLUSTERED 
(
	[HOURIND] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




-- ****** Object:  Table [dbo].[BSM_FI_ACTIONS]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BSM_FI_ACTIONS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [BSM_FI_ACTIONS]...'
	DROP TABLE [dbo].[BSM_FI_ACTIONS]
END
GO
PRINT 'INFO: Creating table [BSM_FI_ACTIONS]...'
CREATE TABLE [dbo].[BSM_FI_ACTIONS](
	[ACTION] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_BSM_FI_ACTIONS] PRIMARY KEY CLUSTERED 
(
	[ACTION] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




-- ****** Object:  Table [dbo].[BAGS]    Script Date: 10/08/2007 13:18:34 ******
-- 	[ERROR_INDICATOR] - 0 mean correct, 1 mean error
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAGS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [BAGS]...'
	DROP TABLE [dbo].[BAGS]
END
GO
PRINT 'INFO: Creating table [BAGS]...'
CREATE TABLE [dbo].[BAGS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,	
	[RAW_DATA] [varchar](5000) NOT NULL,
	[ERROR_INDICATOR] [char] (1),
 CONSTRAINT [PK_BAGS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[BAG_SORTING]    Script Date: 10/08/2007 13:18:34 ******
-- Valid of Field [SOURCE] - 
--    L = Local Check –In Baggage, 
--    T = Transfer Baggage, 
--    X = Terminating Baggage, 
--    R = Remote check-in baggage. 
--
-- These fields are derived from the .V field of the BSM message (refer to RP1745).
-- Only L and T sourced baggage information will be stored.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAG_SORTING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [BAG_SORTING]...'
	DROP TABLE [dbo].[BAG_SORTING]
END
GO
PRINT 'INFO: Creating table [BAG_SORTING]...'
CREATE TABLE [dbo].[BAG_SORTING](
	[DATA_ID] [bigint] NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[DICTIONARY_VERSION] int NULL,
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
	[NO_PASSENGER_SAME_SURNAME] int NULL,
	[SURNAME] [nvarchar](30) NULL,
	[GIVEN_NAME] [nvarchar](30) NULL,
	[OTHERS_NAME] [nvarchar](100) NULL,	
	[BAG_EXCEPTION] [varchar](10) NULL,
	[CHECK_IN_COUNTER] [varchar](10) NULL,
	[CHECK_IN_COUNTER_DESCRIPTION] [varchar](20) NULL,
	[CHECK_IN_TIME_STAMP] DATETIME NULL,
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
	[WEIGHT_CHECKED_BAG_NUMBER] int NULL,
	[CHECKED_WEIGHT] int NULL,
	[UNCHECKED_WEIGHT] int NULL,
	[WEIGHT_UNIT] [varchar](2) NULL,
	[WEIGHT_LENGTH] int NULL,
	[WEIGHT_WIDTH] int NULL,
	[WEIGHT_HEIGHT] int NULL,
	[WEIGHT_BAG_TYPE_CODE] [varchar](10) NULL,
	[GROUND_TRANSPORT_EARLIEST_DELIVERY] datetime NULL,
	[GROUND_TRANSPORT_LATEST_DELIVERY] datetime NULL,
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




/****** Object:  Table [dbo].[BAG_ERROR_BSM]    Script Date: 05/05/2008 15:22:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAG_ERROR_BSM]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [BAG_ERROR_BSM]...'
	DROP TABLE [dbo].[BAG_ERROR_BSM]
END
GO
PRINT 'INFO: Creating table [BAG_ERROR_BSM]...'
CREATE TABLE [dbo].[BAG_ERROR_BSM](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DATA_ID] [bigint] NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[DESCRIPTION] [nvarchar](200) NOT NULL
 CONSTRAINT [PK_BAG_ERROR_BSM] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[BAG_INFO]    Script Date: 10/08/2007 13:18:34 ******
-- Works as the working table for bag sortation control purpose. 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAG_INFO]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [BAG_INFO]...'
	DROP TABLE [dbo].[BAG_INFO]
END
GO
PRINT 'INFO: Creating table [BAG_INFO]...'
CREATE TABLE [dbo].[BAG_INFO](
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE1] [varchar](10) NULL,
	[LICENSE_PLATE2] [varchar](10) NULL,
	[HBS1_RESULT] [varchar](1) NULL,
	[HBS2_RESULT] [varchar](1) NULL,
	[HBS3_RESULT] [varchar](1) NULL,
	[HBS4_RESULT] [varchar](1) NULL,
	[HBS5_RESULT] [varchar](1) NULL,
	[RECYLE_COUNT] [decimal](2, 0) NULL,
	[LAST_LOCATION] [varchar](10) NOT NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
 CONSTRAINT [PK_BAG_INFO] PRIMARY KEY CLUSTERED 
(
	[GID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[SYS_CONFIG]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_CONFIG]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SYS_CONFIG]...'
	DROP TABLE [dbo].[SYS_CONFIG]
END
GO
PRINT 'INFO: Creating table [SYS_CONFIG]...'
CREATE TABLE [dbo].[SYS_CONFIG](
	[SYS_KEY] [varchar](40) NOT NULL,
	[SYS_VALUE] [varchar](15) NOT NULL,
	[DEFAULT_VALUE] [varchar](15) NOT NULL,
	[LAST_VALUE] [varchar](15) NOT NULL,
	[DESCRIPTION] [nvarchar](80) NOT NULL,
	[VALUE_TOKEN] [varchar](80) NULL,
	[SYS_ACTION] [varchar](50) NULL,
	[GROUP_NAME] [varchar](20) NULL,
	[ORDER_FLAG] [varchar](1) NULL,
	[IS_ENABLED] [bit] NOT NULL CONSTRAINT [DF_SYS_CONFIG_IS_ENABLED]  DEFAULT ((1)),
 CONSTRAINT [PK_SYS_CONFIG] PRIMARY KEY CLUSTERED 
(
	[SYS_KEY] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




-- ****** Object:  Table [dbo].[FLIGHTS]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHTS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FLIGHTS]...'
	DROP TABLE [dbo].[FLIGHTS]
END
GO
PRINT 'INFO: Creating table [FLIGHTS]...'
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




-- ****** Object:  Table [dbo].[FLIGHT_PLANS]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLANS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FLIGHT_PLANS]...'
	DROP TABLE [dbo].[FLIGHT_PLANS]
END
GO
PRINT 'INFO: Creating table [FLIGHT_PLANS]...'
CREATE TABLE [dbo].[FLIGHT_PLANS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,	
	[RAW_DATA] [varchar](5000) NOT NULL,
	[ERROR_INDICATOR] [char] (1),	
 CONSTRAINT [PK_FLIGHT_PLANS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[FLIGHT_PLAN_SORTING]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLAN_SORTING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FLIGHT_PLAN_SORTING]...'
	DROP TABLE [dbo].[FLIGHT_PLAN_SORTING]
END
GO
PRINT 'INFO: Creating table [FLIGHT_PLAN_SORTING]...'
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
	[CREATED_BY] [varchar](15) NOT NULL,
	[IS_ALLOCATED] [bit] NOT NULL CONSTRAINT [DF_FPA_IS_ALLOCATED] DEFAULT ((0)),
CONSTRAINT [PK_FLIGHT_PLAN_SORTING] PRIMARY KEY CLUSTERED 
(
	[AIRLINE] ASC,
	[FLIGHT_NUMBER] ASC,
	[SDO] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[FLIGHT_PLAN_ERROR]    Script Date: 05/05/2008 15:22:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLAN_ERROR]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FLIGHT_PLAN_ERROR]...'
	DROP TABLE [dbo].[FLIGHT_PLAN_ERROR]
END
GO
PRINT 'INFO: Creating table [FLIGHT_PLAN_ERROR]...'
CREATE TABLE [dbo].[FLIGHT_PLAN_ERROR](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DATA_ID] [bigint] NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[DESCRIPTION] [nvarchar](200) NOT NULL
 CONSTRAINT [PK_FLIGHT_PLAN_ERROR] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[FLIGHT_PLAN_ALLOC]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLAN_ALLOC]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FLIGHT_PLAN_ALLOC]...'
	DROP TABLE [dbo].[FLIGHT_PLAN_ALLOC]
END
GO
PRINT 'INFO: Creating table [FLIGHT_PLAN_ALLOC]...'
CREATE TABLE [dbo].[FLIGHT_PLAN_ALLOC](
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[SDO] [datetime] NOT NULL,
	[STO] [varchar](4) NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[WEEKDAY] [char](1) NOT NULL,
	[EDO] [datetime] NULL,
	[ETO] [varchar](4) NULL,
	[ADO] [datetime] NULL,
	[ATO] [varchar](4) NULL,
	[IDO] [datetime] NULL,
	[ITO] [varchar](4) NULL,
	[TRAVEL_CLASS] [varchar](1) NOT NULL CONSTRAINT [DF_FPA_CLASS] DEFAULT (('*')),
	[HIGH_RISK] [char](1) NULL,
	[HBS_LEVEL_REQUIRED] [char](1) NULL,
	[EARLY_OPEN_OFFSET] [varchar](5) NULL,
	[EARLY_OPEN_ENABLED] [bit] NULL,
	[ALLOC_OPEN_OFFSET] [varchar](5) NULL,
	[ALLOC_OPEN_RELATED] [varchar](4) NULL,
	[ALLOC_CLOSE_OFFSET] [varchar](5) NULL,
	[ALLOC_CLOSE_RELATED] [varchar](4) NULL,
	[RUSH_DURATION] [varchar](5) NULL,
	[SCHEME_TYPE] [varchar](2) NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[HOUR] [varchar](2) NULL,
	[IS_MANUAL_CLOSE] [bit] NOT NULL CONSTRAINT [DF_FPA_IS_MANUAL_CLOSE] DEFAULT ((0)),
	[IS_CLOSED] [bit] NOT NULL CONSTRAINT [DF_FPA_IS_CLOSED] DEFAULT ((0)),
 CONSTRAINT [PK_FLIGHT_PLAN_ALLOC] PRIMARY KEY CLUSTERED 
(
	[AIRLINE] ASC,
	[FLIGHT_NUMBER] ASC,
	[SDO] ASC,
	[RESOURCE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [TEMPLATE_FLIGHT_PLAN_ALLOC]...'
	DROP TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]
END
GO
PRINT 'INFO: Creating table [TEMPLATE_FLIGHT_PLAN_ALLOC]...'
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[TEMPLATE_ASSIGNMENTS]    Script Date: 08/12/2008 10:10:18 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEMPLATE_ASSIGNMENTS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [TEMPLATE_ASSIGNMENTS]...'
	DROP TABLE [dbo].[TEMPLATE_ASSIGNMENTS]
END
GO
PRINT 'INFO: Creating table [TEMPLATE_ASSIGNMENTS]...'
CREATE TABLE [dbo].[TEMPLATE_ASSIGNMENTS](
	[PRODUCTION_DATE] [datetime] NOT NULL,
	[TEMPLATE_ID] [bigint] NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	CONSTRAINT [PK_TEMPLATE_ASSIGNMENT] PRIMARY KEY CLUSTERED 
	(
		[PRODUCTION_DATE] ASC
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[TEMPLATES]    Script Date: 08/12/2008 10:10:18 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEMPLATES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [TEMPLATES]...'
	DROP TABLE [dbo].[TEMPLATES]
END
GO
PRINT 'INFO: Creating table [TEMPLATES]...'
CREATE TABLE [dbo].[TEMPLATES](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TEMPLATE_GROUP_ID] [varchar](15) NOT NULL,
	[WEEKDAY] [int] NOT NULL,
	[WEEKDAY_NAME] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[TODELETE] [varchar](1) NOT NULL CONSTRAINT [DF_TEMPLATES_TODELETE] DEFAULT ('N'),
	CONSTRAINT [PK_TEMPLATES] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[TEMPLATE_GROUPS]    Script Date: 08/12/2008 10:10:18 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEMPLATE_GROUPS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [TEMPLATE_GROUPS]...'
	DROP TABLE [dbo].[TEMPLATE_GROUPS]
END
GO
PRINT 'INFO: Creating table [TEMPLATE_GROUPS]...'
CREATE TABLE [dbo].[TEMPLATE_GROUPS](
	[ID] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[TODELETE] [varchar](1) NOT NULL CONSTRAINT [DF_TEMPLATE_GROUPS_TODELETE] DEFAULT ('N'),
	CONSTRAINT [PK_TEMPLATE_GROUPS] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[FUNCTION_TYPE_GROUPS]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FUNCTION_TYPE_GROUPS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FUNCTION_TYPE_GROUPS]...'
	DROP TABLE [dbo].[FUNCTION_TYPE_GROUPS]
END
GO
PRINT 'INFO: Creating table [FUNCTION_TYPE_GROUPS]...'
CREATE TABLE [dbo].[FUNCTION_TYPE_GROUPS](
	[GROUP] [varchar](5) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
CONSTRAINT [PK_FUNCTION_TYPE_GROUPS] PRIMARY KEY CLUSTERED 
(
	[GROUP] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




-- ****** Object:  Table [dbo].[FUNCTION_TYPES]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FUNCTION_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FUNCTION_TYPES]...'
	DROP TABLE [dbo].[FUNCTION_TYPES]
END
GO
PRINT 'INFO: Creating table [FUNCTION_TYPES]...'
CREATE TABLE [dbo].[FUNCTION_TYPES](
	[TYPE] [varchar](4) NOT NULL,
 	[GROUP] [varchar](5) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 	[IS_ALLOCATED] [bit] NOT NULL,
	[IS_ENABLED] [bit] NOT NULL CONSTRAINT [DF_FUNCTION_TYPES_IS_ENABLED]  DEFAULT ((1)),
CONSTRAINT [PK_FUNCTION_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




-- ****** Object:  Table [dbo].[FUNCTION_ALLOC_GANTT]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FUNCTION_ALLOC_GANTT]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FUNCTION_ALLOC_GANTT]...'
	DROP TABLE [dbo].[FUNCTION_ALLOC_GANTT]
END
GO
PRINT 'INFO: Creating table [FUNCTION_ALLOC_GANTT]...'
CREATE TABLE [dbo].[FUNCTION_ALLOC_GANTT](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[FUNCTION_TYPE] [varchar](4) NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[ALLOC_OPEN_DATETIME] [datetime] NOT NULL,
	[ALLOC_CLOSE_DATETIME] [datetime] NOT NULL,
	[IS_CLOSED] [bit] NOT NULL CONSTRAINT [DF_FUNCTION_ALLOC_GANTT_IS_CLOSED]  DEFAULT ((0)),
	[EXCEPTION] [varchar] (10) NULL,
 CONSTRAINT [PK_FUNCTION_ALLOC_GANTT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[FUNCTION_ALLOC_LIST]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FUNCTION_ALLOC_LIST]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FUNCTION_ALLOC_LIST]...'
	DROP TABLE [dbo].[FUNCTION_ALLOC_LIST]
END
GO
PRINT 'INFO: Creating table [FUNCTION_ALLOC_LIST]...'
CREATE TABLE [dbo].[FUNCTION_ALLOC_LIST](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[FUNCTION_TYPE] [varchar](4) NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[IS_ENABLED] [bit] NOT NULL CONSTRAINT [DF_FUNCTION_ALLOC_LIST_IS_ENABLED]  DEFAULT ((1)),
	[SYS_ACTION] [varchar](50) NULL,
 CONSTRAINT [PK_FUNCTION_ALLOC_LIST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




-- ****** Object:  Table [dbo].[SCHEME_TYPE]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SCHEME_TYPE]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SCHEME_TYPE]...'
	DROP TABLE [dbo].[SCHEME_TYPE]
END
GO
PRINT 'INFO: Creating table [SCHEME_TYPE]...'
CREATE TABLE [dbo].[SCHEME_TYPE](
	[SCHEME_TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_SCHEME_TYPE] PRIMARY KEY CLUSTERED 
(
	[SCHEME_TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[GID_USED]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GID_USED]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [GID_USED]...'
	DROP TABLE [dbo].[GID_USED]
END
GO
PRINT 'INFO: Creating table [GID_USED]...'
CREATE TABLE [dbo].[GID_USED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[BAG_TYPE] [varchar](2) NOT NULL,
 CONSTRAINT [PK_GID_USED] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[ITEM_TRACKING]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_TRACKING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_TRACKING]...'
	DROP TABLE [dbo].[ITEM_TRACKING]
END
GO
PRINT 'INFO: Creating table [ITEM_TRACKING]...'
CREATE TABLE [dbo].[ITEM_TRACKING](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PLC_TIMESTAMP] [varchar](20) NOT NULL,
 CONSTRAINT [PK_ITEM_TRACK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_READY]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_READY]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_READY]...'
	DROP TABLE [dbo].[ITEM_READY]
END
GO
PRINT 'INFO: Creating table [ITEM_READY]...'
CREATE TABLE [dbo].[ITEM_READY](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
 CONSTRAINT [PK_ITEM_READY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_REMOVED]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_REMOVED]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_REMOVED]...'
	DROP TABLE [dbo].[ITEM_REMOVED]
END
GO
PRINT 'INFO: Creating table [ITEM_REMOVED]...'
CREATE TABLE [dbo].[ITEM_REMOVED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
 CONSTRAINT [PK_ITEM_REMOVED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[ITEM_ENCODING_REQUEST]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_ENCODING_REQUEST]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_ENCODING_REQUEST]...'
	DROP TABLE [dbo].[ITEM_ENCODING_REQUEST]
END
GO
PRINT 'INFO: Creating table [ITEM_ENCODING_REQUEST]...'
CREATE TABLE [dbo].[ITEM_ENCODING_REQUEST](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NULL,
	[AIRLINE] [varchar](3) NULL,
	[FLIGHT_NUMBER] [varchar](5) NULL,
	[SDO] [varchar](10) NULL,
	[DESTINATION] [varchar](20) NULL,
	[ENCODING_TYPE] [varchar](2) NULL,
CONSTRAINT [PK_ITEM_ENCODING_REQUEST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[ITEM_ENCODING_REQUEST_TYPES]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_ENCODING_REQUEST_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_ENCODING_REQUEST_TYPES]...'
	DROP TABLE [dbo].[ITEM_ENCODING_REQUEST_TYPES]
END
GO
PRINT 'INFO: Creating table [ITEM_ENCODING_REQUEST_TYPES]...'
CREATE TABLE [dbo].[ITEM_ENCODING_REQUEST_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ITEM_ENCODING_REQUEST_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[ITEM_DEST_REQUEST]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_DEST_REQUEST]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_DEST_REQUEST]...'
	DROP TABLE [dbo].[ITEM_DEST_REQUEST]
END
GO
PRINT 'INFO: Creating table [ITEM_DEST_REQUEST]...'
CREATE TABLE [dbo].[ITEM_DEST_REQUEST](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
 CONSTRAINT [PK_ITEM_DEST_REQUEST] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[ITEM_LOST]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_LOST]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_LOST]...'
	DROP TABLE [dbo].[ITEM_LOST]
END
GO
PRINT 'INFO: Creating table [ITEM_LOST]...'
CREATE TABLE [dbo].[ITEM_LOST](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
 CONSTRAINT [PK_ITEM_LOST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_SCREENED]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SCREENED]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_SCREENED]...'
	DROP TABLE [dbo].[ITEM_SCREENED]
END
GO
PRINT 'INFO: Creating table [ITEM_SCREENED]...'
CREATE TABLE [dbo].[ITEM_SCREENED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[XRAY_ID] [varchar](10) NOT NULL,
	[SCREEN_LEVEL] [char](1) NOT NULL,
	[RESULT_TYPE] [varchar](1) NOT NULL,
 CONSTRAINT [PK_ITEM_SCREEN] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_SCREEN_RESULT_TYPES]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SCREEN_RESULT_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_SCREEN_RESULT_TYPES]...'
	DROP TABLE [dbo].[ITEM_SCREEN_RESULT_TYPES]
END
GO
PRINT 'INFO: Creating table [ITEM_SCREEN_RESULT_TYPES]...'
CREATE TABLE [dbo].[ITEM_SCREEN_RESULT_TYPES](
	[TYPE] [varchar](1) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ITEM_SCREEN_RESULT_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_SCANNED]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SCANNED]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_SCANNED]...'
	DROP TABLE [dbo].[ITEM_SCANNED]
END
GO
PRINT 'INFO: Creating table [ITEM_SCANNED]...'
CREATE TABLE [dbo].[ITEM_SCANNED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE1] [varchar](10) NOT NULL,
	[LICENSE_PLATE2] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[SCANNER_ID] [varchar](4) NULL,
	[STATUS_TYPE] [varchar](2) NOT NULL,
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
	[DESTINATION] [varchar](20) NOT NULL,	
 CONSTRAINT [PK_ITEM_SCANNED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_SCAN_STATUS_TYPES]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SCAN_STATUS_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_SCAN_STATUS_TYPES]...'
	DROP TABLE [dbo].[ITEM_SCAN_STATUS_TYPES]
END
GO
PRINT 'INFO: Creating table [ITEM_SCAN_STATUS_TYPES]...'
CREATE TABLE [dbo].[ITEM_SCAN_STATUS_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ITEM_SCAN_STATUS_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_PROCEEDED]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_PROCEEDED]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_PROCEEDED]...'
	DROP TABLE [dbo].[ITEM_PROCEEDED]
END
GO
PRINT 'INFO: Creating table [ITEM_PROCEEDED]...'
CREATE TABLE [dbo].[ITEM_PROCEEDED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PROCEED_LOCATION] [varchar](20) NOT NULL,
	[PROCEED_TYPE] [varchar](2) NOT NULL,
 CONSTRAINT [PK_ITEM_PROCEEDED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_PROCEED_TYPES]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_PROCEED_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_PROCEED_TYPES]...'
	DROP TABLE [dbo].[ITEM_PROCEED_TYPES]
END
GO
PRINT 'INFO: Creating table [ITEM_PROCEED_TYPES]...'
CREATE TABLE [dbo].[ITEM_PROCEED_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ITEM_PROCEED_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_REDIRECT]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_REDIRECT]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_REDIRECT]...'
	DROP TABLE [dbo].[ITEM_REDIRECT]
END
GO
PRINT 'INFO: Creating table [ITEM_REDIRECT]...'
CREATE TABLE [dbo].[ITEM_REDIRECT](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM1] [varchar](10) NOT NULL,
	[LOCATION1] [varchar](20) NOT NULL,
	[SUBSYSTEM2] [varchar](10) NULL,
	[LOCATION2] [varchar](20) NULL,
	[SUBSYSTEM3] [varchar](10) NULL,
	[LOCATION3] [varchar](20) NULL,
	[REASON] [varchar](2) NOT NULL,
 CONSTRAINT [PK_ITEM_REDIRECT] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_SORTATION_EVENT]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SORTATION_EVENT]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_SORTATION_EVENT]...'
	DROP TABLE [dbo].[ITEM_SORTATION_EVENT]
END
GO
PRINT 'INFO: Creating table [ITEM_SORTATION_EVENT]...'
CREATE TABLE [dbo].[ITEM_SORTATION_EVENT](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[SORT_DESTINATION] [varchar](10) NOT NULL,
	[SORT_EVENT_TYPE] [varchar](2) NOT NULL,
 CONSTRAINT [PK_ITEM_SORTATION_EVENT] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[ITEM_SORTATION_EVENT_TYPES]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_SORTATION_EVENT_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_SORTATION_EVENT_TYPES]...'
	DROP TABLE [dbo].[ITEM_SORTATION_EVENT_TYPES]
END
GO
PRINT 'INFO: Creating table [ITEM_SORTATION_EVENT_TYPES]...'
CREATE TABLE [dbo].[ITEM_SORTATION_EVENT_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ITEM_SORTATION_EVENT_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ALLOC_RESOURCES]    Script Date: 12/06/2008 21:00:00 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALLOC_RESOURCES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ALLOC_RESOURCES]...'
	DROP TABLE [dbo].[ALLOC_RESOURCES]
END
GO
PRINT 'INFO: Creating table [ALLOC_RESOURCES]...'
CREATE TABLE [dbo].[ALLOC_RESOURCES] (
	[ID] int NOT NULL,
	[RESOURCE] varchar (10) NOT NULL ,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[DESCRIPTION] nvarchar(100) NULL
	CONSTRAINT [PK_ALLOC_RESOURCES] PRIMARY KEY  CLUSTERED 
	(
		[RESOURCE]
	)  ON [PRIMARY] 
) ON [PRIMARY]
GO


-- ****** Object:  Table [dbo].[DESTINATIONS]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DESTINATIONS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [DESTINATIONS]...'
	DROP TABLE [dbo].[DESTINATIONS]
END
GO
PRINT 'INFO: Creating table [DESTINATIONS]...'
CREATE TABLE [dbo].[DESTINATIONS](
	[DESTINATION] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
	[IS_AVAILABLE] bit NOT NULL CONSTRAINT DF_DESTINATIONS_IS_AVAILABLE DEFAULT 1,
 CONSTRAINT [PK_DESTINATION] PRIMARY KEY CLUSTERED 
(
	[DESTINATION] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[DESTINATION_GROUPING]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DESTINATION_GROUPING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [DESTINATION_GROUPING]...'
	DROP TABLE [dbo].[DESTINATION_GROUPING]
END
GO
PRINT 'INFO: Creating table [DESTINATION_GROUPING]...'
CREATE TABLE [dbo].[DESTINATION_GROUPING](
	[GROUP_NAME] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[SUBSYSTEMS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SUBSYSTEMS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SUBSYSTEMS]...'
	DROP TABLE [dbo].[SUBSYSTEMS]
END
GO
PRINT 'INFO: Creating table [SUBSYSTEMS]...'
CREATE TABLE [dbo].[SUBSYSTEMS](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_SUBSYSTEMS] PRIMARY KEY CLUSTERED 
(
	[SUBSYSTEM] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[SUBSYSTEM_GROUPING]    Script Date: 11/01/2007 11:29:45 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SUBSYSTEM_GROUPING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SUBSYSTEM_GROUPING]...'
	DROP TABLE [dbo].[SUBSYSTEM_GROUPING]
END
GO
PRINT 'INFO: Creating table [SUBSYSTEM_GROUPING]...'
CREATE TABLE [dbo].[SUBSYSTEM_GROUPING](
	[GROUP_NAME] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF




-- ****** Object:  Table [dbo].[LOCATIONS]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LOCATIONS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [LOCATIONS]...'
	DROP TABLE [dbo].[LOCATIONS]
END
GO
PRINT 'INFO: Creating table [LOCATIONS]...'
CREATE TABLE [dbo].[LOCATIONS](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
	[ASSIGNABLE] [char](1) NULL,
	[STATUS_TYPE] [varchar](2) NULL,
	[TRACKED] [bit] NOT NULL CONSTRAINT [DF_LOCATIONS_TRACKED]  DEFAULT ((0)),
 CONSTRAINT [PK_LOCATIONS] PRIMARY KEY CLUSTERED 
(
	[LOCATION] ASC,
	[SUBSYSTEM] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[LOCATION_STATUS_TYPES]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LOCATION_STATUS_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [LOCATION_STATUS_TYPES]...'
	DROP TABLE [dbo].[LOCATION_STATUS_TYPES]
END
GO
PRINT 'INFO: Creating table [LOCATION_STATUS_TYPES]...'
CREATE TABLE [dbo].[LOCATION_STATUS_TYPES](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_LOCATION_STATUS_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[ROUTING_TABLE]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ROUTING_TABLE]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ROUTING_TABLE]...'
	DROP TABLE [dbo].[ROUTING_TABLE]
END
GO
PRINT 'INFO: Creating table [ROUTING_TABLE]...'
CREATE TABLE [dbo].[ROUTING_TABLE](
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
	[COST] [decimal](4, 0) NOT NULL,
 CONSTRAINT [PK_ROUTING_TABLE] PRIMARY KEY CLUSTERED 
(
	[SUBSYSTEM] ASC,
	[LOCATION] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[SORTATION_REASON]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SORTATION_REASON]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SORTATION_REASON]...'
	DROP TABLE [dbo].[SORTATION_REASON]
END
GO
PRINT 'INFO: Creating table [SORTATION_REASON]...'
CREATE TABLE [dbo].[SORTATION_REASON](
	[REASON] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_SORTATION_REASON] PRIMARY KEY CLUSTERED 
(
	[REASON] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO





-- ****** Object:  Table [dbo].[ROLES]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ROLES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ROLES]...'
	DROP TABLE [dbo].[ROLES]
END
GO
PRINT 'INFO: Creating table [ROLES]...'
CREATE TABLE [dbo].[ROLES](
	[ID] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ROLES] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[USERS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USERS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [USERS]...'
	DROP TABLE [dbo].[USERS]
END
GO
PRINT 'INFO: Creating table [USERS]...'
CREATE TABLE [dbo].[USERS](
	[ID] [varchar](15) NOT NULL,
	[USER_NAME] [nvarchar](40) NOT NULL,
	[USER_IP_ADDR] [varchar](60) NULL,
	[IP_CHECK] [char](1) NOT NULL CONSTRAINT [DF__USERS__IP_CHECK__014935CB]  DEFAULT ('N'),
	[EXPIRY_DATE] [datetime] NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
 CONSTRAINT [PK_USERS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




-- ****** Object:  Table [dbo].[USERS_ROLES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USERS_ROLES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [USERS_ROLES]...'
	DROP TABLE [dbo].[USERS_ROLES]
END
GO
PRINT 'INFO: Creating table [USERS_ROLES]...'
CREATE TABLE [dbo].[USERS_ROLES](
	[ROLE_ID] [varchar](10) NOT NULL,
	[USER_ID] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
 CONSTRAINT [PK_USERS_ROLES] PRIMARY KEY CLUSTERED 
(
	[ROLE_ID] ASC,
	[USER_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[AUDIT_LOG]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AUDIT_LOG]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [AUDIT_LOG]...'
	DROP TABLE [dbo].[AUDIT_LOG]
END
GO
PRINT 'INFO: Creating table [AUDIT_LOG]...'
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




-- ****** Object:  Table [dbo].[SAC_OWS]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAC_OWS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SAC_OWS]...'
	DROP TABLE [dbo].[SAC_OWS]
END
GO
PRINT 'INFO: Creating table [SAC_OWS]...'
CREATE TABLE [dbo].[SAC_OWS](
    [SAC_OWS] varchar(20) NOT NULL,
	[DESCRIPTION] nvarchar(50) NULL
 CONSTRAINT [PK_SAC_OWS] PRIMARY KEY CLUSTERED 
(
	[SAC_OWS] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[CHANGE_MONITORING]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHANGE_MONITORING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CHANGE_MONITORING]...'
	DROP TABLE [dbo].[CHANGE_MONITORING]
END
GO
PRINT 'INFO: Creating table [CHANGE_MONITORING]...'
CREATE TABLE [dbo].[CHANGE_MONITORING](
    [SAC_OWS] varchar(20) NOT NULL,
	[STATE_CODE] varchar(30) NOT NULL,
	[IS_CHANGED] bit NOT NULL CONSTRAINT DF_CHANGE_MONITORING_IS_CHANGED DEFAULT 0,
	[DESCRIPTION] nvarchar(100) NULL
CONSTRAINT [PK_CHANGE_MONITORING] PRIMARY KEY CLUSTERED 
(
	[SAC_OWS] ASC,
	[STATE_CODE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
	


-- ****** Object:  Table [dbo].[APP_LIVE_MONITORING]    Script Date: 12/06/2008 21:00:00 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[APP_LIVE_MONITORING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [APP_LIVE_MONITORING]...'
	DROP TABLE [dbo].[APP_LIVE_MONITORING]
END
GO
PRINT 'INFO: Creating table [APP_LIVE_MONITORING]...'
CREATE TABLE [dbo].[APP_LIVE_MONITORING] (
	[APP_CODE] varchar(30) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL ,
	[LIVE_STATUS_TYPE] varchar (5) NOT NULL ,
	[DESCRIPTION] nvarchar(100) NULL
CONSTRAINT [PK_APP_LIVE_MONITORING] PRIMARY KEY  CLUSTERED 
(
	[APP_CODE] ASC
)  ON [PRIMARY] 
) ON [PRIMARY]
GO


-- ****** Object:  Table [dbo].[APP_LIVE_STATUS_TYPES]    Script Date: 06/16/2008 11:41:29 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[APP_LIVE_STATUS_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [APP_LIVE_STATUS_TYPES]...'
	DROP TABLE [dbo].[APP_LIVE_STATUS_TYPES]
END
GO
PRINT 'INFO: Creating table [APP_LIVE_STATUS_TYPES]...'
CREATE TABLE [dbo].[APP_LIVE_STATUS_TYPES](
	[TYPE] [varchar](5) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
CONSTRAINT [PK_APP_LIVE_STATUS_TYPES] PRIMARY KEY  CLUSTERED 
(
	[TYPE] ASC
)  ON [PRIMARY] 
) ON [PRIMARY]
GO



-- ****** Object:  Table [dbo].[FALLBACK_MAPPING]    Script Date: 08/12/2008 10:10:18 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FALLBACK_MAPPING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FALLBACK_MAPPING]...'
	DROP TABLE [dbo].[FALLBACK_MAPPING]
END
GO
PRINT 'INFO: Creating table [FALLBACK_MAPPING]...'
CREATE TABLE [dbo].[FALLBACK_MAPPING](
	[ID] [varchar](2) NOT NULL,
	[DESTINATION] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
	[SYS_ACTION] [varchar](50) NULL,
CONSTRAINT [PK_FALLBACK_MAPPING] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)  ON [PRIMARY] 
) ON [PRIMARY]
GO


-- ****** Object:  Table [dbo].[MES_EVENT]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MES_EVENT]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [MES_EVENT]...'
	DROP TABLE [dbo].[MES_EVENT]
END
GO
PRINT 'INFO: Creating table [MES_EVENT]...'
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[EVENT_TYPES]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EVENT_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [EVENT_TYPES]...'
	DROP TABLE [dbo].[EVENT_TYPES]
END
GO
PRINT 'INFO: Creating table [EVENT_TYPES]...'
CREATE TABLE [dbo].[EVENT_TYPES](
	[TYPE] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_EVENT_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



/****** Object:  Table [dbo].[PICTURES]    Script Date: 11/01/2007 09:21:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PICTURES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [PICTURES]...'
	DROP TABLE [dbo].[PICTURES]
END
GO
PRINT 'INFO: Creating table [PICTURES]...'
CREATE TABLE [dbo].[PICTURES](
	[PIC_NAME] [varchar](20) NOT NULL,
	[PIC_TITLE] [varchar](100) NOT NULL,
	[PIC_DESC] [nvarchar](100) NULL,
	[PIC_IMAGE] [varbinary](max) NOT NULL,
CONSTRAINT [PK_PICTURES] PRIMARY KEY CLUSTERED 
(
	[PIC_NAME] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF


-- ****** Object:  Table [dbo].[HIGH_RISK_NEEDED]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HIGH_RISK_NEEDED]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [HIGH_RISK_NEEDED]...'
	DROP TABLE [dbo].[HIGH_RISK_NEEDED]
END
GO
PRINT 'INFO: Creating table [HIGH_RISK_NEEDED]...'
CREATE TABLE [dbo].[HIGH_RISK_NEEDED](
	[VALUE] [varchar](1) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_HIGH_RISK_NEEDED] PRIMARY KEY CLUSTERED 
(
	[VALUE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[SECURITY_CATEGORIES]    Script Date: 03/23/2009 14:40:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_CATEGORIES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SECURITY_CATEGORIES]...'
	DROP TABLE [dbo].[SECURITY_CATEGORIES]
END
GO
PRINT 'INFO: Creating table [SECURITY_CATEGORIES]...'
CREATE TABLE [dbo].[SECURITY_CATEGORIES](
	[SECU_CAT_CODE] [varchar](15) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[DESCRIPTION] [varchar](200) NULL,
 CONSTRAINT [PK_SECURITY_CATEGORIES] PRIMARY KEY CLUSTERED 
(
	[SECU_CAT_CODE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[SECURITY_TASKS]    Script Date: 03/23/2009 14:40:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_TASKS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SECURITY_TASKS]...'
	DROP TABLE [dbo].[SECURITY_TASKS]
END
GO
PRINT 'INFO: Creating table [SECURITY_TASKS]...'
CREATE TABLE [dbo].[SECURITY_TASKS](
	[SECU_TASK_CODE] [varchar](15) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[SECU_CAT_CODE] [varchar](15) NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[DESCRIPTION] [varchar](200) NULL,
 CONSTRAINT [PK_SECURITY_TASKS] PRIMARY KEY CLUSTERED 
(
	[SECU_TASK_CODE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[SECURITY_GROUPS]    Script Date: 03/23/2009 14:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_GROUPS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SECURITY_GROUPS]...'
	DROP TABLE [dbo].[SECURITY_GROUPS]
END
GO
PRINT 'INFO: Creating table [SECURITY_GROUPS]...'
CREATE TABLE [dbo].[SECURITY_GROUPS](
	[SECU_GROUP_CODE] [varchar](15) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[SECU_CAT_CODE] [varchar](15) NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[DESCRIPTION] [varchar](200) NULL,
 CONSTRAINT [PK_SECURITY_GROUPS] PRIMARY KEY CLUSTERED 
(
	[SECU_GROUP_CODE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[SECURITY_GROUP_TASK_MAPPING]    Script Date: 03/23/2009 14:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_GROUP_TASK_MAPPING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SECURITY_GROUP_TASK_MAPPING]...'
	DROP TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING]
END
GO
PRINT 'INFO: Creating table [SECURITY_GROUP_TASK_MAPPING]...'
CREATE TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING](
	[SECU_GROUP_CODE] [varchar](15) NOT NULL,
	[SECU_TASK_CODE] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[SECURITY_USERS]    Script Date: 03/23/2009 14:41:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_USERS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SECURITY_USERS]...'
	DROP TABLE [dbo].[SECURITY_USERS]
END
GO
PRINT 'INFO: Creating table [SECURITY_USERS]...'
CREATE TABLE [dbo].[SECURITY_USERS](
	[USER_NAME] [varchar](20) NOT NULL,
	[USER_PASSWORD] [varchar](200) NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[DESCRIPTION] [varchar](200) NULL,
 CONSTRAINT [PK_SECURITY_USERS] PRIMARY KEY CLUSTERED 
(
	[USER_NAME] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[SECURITY_USER_RIGHTS]    Script Date: 03/23/2009 14:42:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SECURITY_USER_RIGHTS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [SECURITY_USER_RIGHTS]...'
	DROP TABLE [dbo].[SECURITY_USER_RIGHTS]
END
GO
PRINT 'INFO: Creating table [SECURITY_USER_RIGHTS]...'
CREATE TABLE [dbo].[SECURITY_USER_RIGHTS](
	[USER_NAME] [varchar](20) NOT NULL,
	[SECU_GROUP_CODE] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[EXCEPTION_TYPE]    Script Date: 03/23/2009 14:42:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EXCEPTION_TYPE]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [EXCEPTION_TYPE]...'
	DROP TABLE [dbo].[EXCEPTION_TYPE]
END
GO
PRINT 'INFO: Creating table [EXCEPTION_TYPE]...'
CREATE TABLE [dbo].[EXCEPTION_TYPE](
	[TYPE] [nvarchar](10) NOT NULL,
	[SOURCE] [nvarchar](10) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

-- ****** Object:  Table [dbo].[TRACKING_ZONE_GROUPING]    Script Date: 11/01/2007 11:29:45 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TRACKING_ZONE_GROUPING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [TRACKING_ZONE_GROUPING]...'
	DROP TABLE [dbo].[TRACKING_ZONE_GROUPING]
END
GO
PRINT 'INFO: Creating table [TRACKING_ZONE_GROUPING]...'
CREATE TABLE [dbo].[TRACKING_ZONE_GROUPING](
	[GROUP_NAME] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [BHS_FIS_OUTGOING_ALLOCATIONS]...'
	DROP TABLE [dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
END
GO
PRINT 'INFO: Creating table [BHS_FIS_OUTGOING_ALLOCATIONS]...'
CREATE TABLE [dbo].[BHS_FIS_OUTGOING_ALLOCATIONS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ALLOC_TYPE] [varchar](10) NOT NULL,	
	[ACTION] [varchar](10) NOT NULL,	
	[AIRLINE] [varchar](3) NULL,
	[FLIGHT_NUMBER] [varchar](5) NULL,
	[SDO] [datetime] NULL,
	[RESOURCE] [varchar](10) NULL,
	[STATE] [varchar](10) NULL,
	[OPEN_TIME] [datetime] NULL,
	[CLOSE_TIME] [datetime] NULL,	
	[TRAVEL_CLASS] [varchar](1) NULL,
	[FUNCTION_TYPE] [varchar](4) NULL,	
	[FUNCTION_DATA] [varchar](5) NULL,	
	[FUNCTION_IS_CLOSED] bit NOT NULL CONSTRAINT DF_BHS_FIS_OUTGOING_ALLOCATIONS_IS_CLOSED DEFAULT 0,	
 CONSTRAINT [PK_BHS_FIS_OUTGOING_ALLOCATIONS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[DEPARTURE_FLIGHT_ALLOC_REPLY]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEPARTURE_FLIGHT_ALLOC_REPLY]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [DEPARTURE_FLIGHT_ALLOC_REPLY]...'
	DROP TABLE [dbo].[DEPARTURE_FLIGHT_ALLOC_REPLY]
END
GO
PRINT 'INFO: Creating table [DEPARTURE_FLIGHT_ALLOC_REPLY]...'
CREATE TABLE [dbo].[DEPARTURE_FLIGHT_ALLOC_REPLY](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] datetime NOT NULL,
	[AIRLINE] [varchar](3) NULL,
	[FLIGHT_NUMBER] [varchar](5) NULL,
	[SDO] [varchar](8) NULL,
	[RESOURCE] [varchar](10) NULL,
	[STATE] [varchar](10) NULL,
	[OPEN_TIME] [varchar](14) NULL,
	[CLOSE_TIME] [varchar](14) NULL,	
	[TRAVEL_CLASS] [varchar](1) NULL,	
 CONSTRAINT [PK_DEPARTURE_FLIGHT_ALLOC_REPLY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

-- ****** Object:  Table [dbo].[DEPARTURE_FLIGHT_ALLOC_DELETED]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEPARTURE_FLIGHT_ALLOC_DELETED]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [DEPARTURE_FLIGHT_ALLOC_DELETED]...'
	DROP TABLE [dbo].[DEPARTURE_FLIGHT_ALLOC_DELETED]
END
GO
PRINT 'INFO: Creating table [DEPARTURE_FLIGHT_ALLOC_DELETED]...'
CREATE TABLE [dbo].[DEPARTURE_FLIGHT_ALLOC_DELETED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] datetime NOT NULL,
	[AIRLINE] [varchar](3) NULL,
	[FLIGHT_NUMBER] [varchar](5) NULL,
	[SDO] [varchar](8) NULL,
	[RESOURCE] [varchar](10) NULL,
 CONSTRAINT [PK_DEPARTURE_FLIGHT_ALLOC_DELETED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[DEPARTURE_FUNCTION_ALLOC_REPLY]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEPARTURE_FUNCTION_ALLOC_REPLY]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [DEPARTURE_FUNCTION_ALLOC_REPLY]...'
	DROP TABLE [dbo].[DEPARTURE_FUNCTION_ALLOC_REPLY]
END
GO
PRINT 'INFO: Creating table [DEPARTURE_FUNCTION_ALLOC_REPLY]...'
CREATE TABLE [dbo].[DEPARTURE_FUNCTION_ALLOC_REPLY](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] datetime NOT NULL,
	[FUNCTION_TYPE] [varchar](4) NULL,
	[FUNCTION_DATA] [varchar](5) NULL,
	[RESOURCE] [varchar](10) NULL,
 CONSTRAINT [PK_DEPARTURE_FUNCTION_ALLOC_REPLY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[DEPARTURE_FUNCTION_ALLOC_DELETED]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DEPARTURE_FUNCTION_ALLOC_DELETED]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [DEPARTURE_FUNCTION_ALLOC_DELETED]...'
	DROP TABLE [dbo].[DEPARTURE_FUNCTION_ALLOC_DELETED]
END
GO
PRINT 'INFO: Creating table [DEPARTURE_FUNCTION_ALLOC_DELETED]...'
CREATE TABLE [dbo].[DEPARTURE_FUNCTION_ALLOC_DELETED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] datetime NOT NULL,
	[FUNCTION_TYPE] [varchar](4) NULL,
	[FUNCTION_DATA] [varchar](5) NULL,
	[RESOURCE] [varchar](10) NULL,
 CONSTRAINT [PK_DEPARTURE_FUNCTION_ALLOC_DELETED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[ENCAPSULATED_BPM]    Script Date: 10/08/2007 13:18:34 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ENCAPSULATED_BPM]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ENCAPSULATED_BPM]...'
	DROP TABLE [dbo].[ENCAPSULATED_BPM]
END
GO
PRINT 'INFO: Creating table [ENCAPSULATED_BPM]...'
CREATE TABLE [dbo].[ENCAPSULATED_BPM](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] datetime NOT NULL,
	[BPM] [varchar](5000) NULL,
 CONSTRAINT [PK_ENCAPSULATED_BPM] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[BAGGAGE_MEASURE_ARRAY_TYPE]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAGGAGE_MEASURE_ARRAY_TYPE]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [BAGGAGE_MEASURE_ARRAY_TYPE]...'
	DROP TABLE [dbo].[BAGGAGE_MEASURE_ARRAY_TYPE]
END
GO
PRINT 'INFO: Creating table [BAGGAGE_MEASURE_ARRAY_TYPE]...'
CREATE TABLE [dbo].[BAGGAGE_MEASURE_ARRAY_TYPE](
	[TYPE] [varchar](2) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_TYPE] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[BAGGAGE_MEASURE_ARRAY_MSG]    Script Date: 05/12/2009 16:32:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BAGGAGE_MEASURE_ARRAY_MSG]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [BAGGAGE_MEASURE_ARRAY_MSG]...'
	DROP TABLE [dbo].[BAGGAGE_MEASURE_ARRAY_MSG]
END
GO
PRINT 'INFO: Creating table [BAGGAGE_MEASURE_ARRAY_MSG]...'
CREATE TABLE [dbo].[BAGGAGE_MEASURE_ARRAY_MSG](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[LOCATION] [varchar](10) NOT NULL,	
	[TYPE] [varchar](2) NOT NULL,
 CONSTRAINT [PK_BAGGAGE_MEASURE_ARRAY_MSG] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]	
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[FALLBACK_TAG_INFO]    Script Date: 05/12/2009 16:32:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FALLBACK_TAG_INFO]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [FALLBACK_TAG_INFO]...'
	DROP TABLE [dbo].[FALLBACK_TAG_INFO]
END
GO
PRINT 'INFO: Creating table [FALLBACK_TAG_INFO]...'
CREATE TABLE [dbo].[FALLBACK_TAG_INFO](
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]	
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO



/****** Object:  Table [dbo].[CHUTE_MAPPING]    Script Date: 05/12/2009 16:32:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHUTE_MAPPING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CHUTE_MAPPING]...'
	DROP TABLE [dbo].[CHUTE_MAPPING]
END
GO
PRINT 'INFO: Creating table [CHUTE_MAPPING]...'
CREATE TABLE [dbo].[CHUTE_MAPPING](
	[CHUTE] [varchar](20) NOT NULL,
	[DESTINATION] [varchar](20) NOT NULL,
 CONSTRAINT [PK_CHUTE_MAPPING] PRIMARY KEY CLUSTERED 
(
	[CHUTE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[ITEM_MINIMUM_SECURITY_LEVEL]    Script Date: 05/12/2009 16:32:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_MINIMUM_SECURITY_LEVEL]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_MINIMUM_SECURITY_LEVEL]...'
	DROP TABLE [dbo].[ITEM_MINIMUM_SECURITY_LEVEL]
END
GO
PRINT 'INFO: Creating table [ITEM_MINIMUM_SECURITY_LEVEL]...'
CREATE TABLE [dbo].[ITEM_MINIMUM_SECURITY_LEVEL](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[LEVEL] [varchar](1) NOT NULL,	
 CONSTRAINT [PK_ITEM_MINIMUM_SECURITY_LEVEL] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]	
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST]    Script Date: 05/12/2009 16:32:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST]...'
	DROP TABLE [dbo].[MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST]
END
GO
PRINT 'INFO: Creating table [MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST]...'
CREATE TABLE [dbo].[MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[NO_OF_MAPPING] [varchar](2) NOT NULL,
	[MAKEUP_1] [varchar](10) NOT NULL,
	[CHUTE_1] [varchar](10) NOT NULL,
	[MAKEUP_2] [varchar](10) NOT NULL,
	[CHUTE_2] [varchar](10) NOT NULL,
	[MAKEUP_3] [varchar](10) NOT NULL,
	[CHUTE_3] [varchar](10) NOT NULL,
	[MAKEUP_4] [varchar](10) NOT NULL,
	[CHUTE_4] [varchar](10) NOT NULL,
	[MAKEUP_5] [varchar](10) NOT NULL,
	[CHUTE_5] [varchar](10) NOT NULL,
	[MAKEUP_6] [varchar](10) NOT NULL,
	[CHUTE_6] [varchar](10) NOT NULL,
	[MAKEUP_7] [varchar](10) NOT NULL,
	[CHUTE_7] [varchar](10) NOT NULL,
	[MAKEUP_8] [varchar](10) NOT NULL,
	[CHUTE_8] [varchar](10) NOT NULL,
	[MAKEUP_9] [varchar](10) NOT NULL,
	[CHUTE_9] [varchar](10) NOT NULL,
	[MAKEUP_10] [varchar](10) NOT NULL,
	[CHUTE_10] [varchar](10) NOT NULL,
 CONSTRAINT [PK_MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]	
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[ITEM_CUSTOMS_SCREENED]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_CUSTOMS_SCREENED]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_CUSTOMS_SCREENED]...'
	DROP TABLE [dbo].[ITEM_CUSTOMS_SCREENED]
END
GO
PRINT 'INFO: Creating table [ITEM_CUSTOMS_SCREENED]...'
CREATE TABLE [dbo].[ITEM_CUSTOMS_SCREENED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[RESULT_TYPE] [varchar](1) NOT NULL,
 CONSTRAINT [PK_ITEM_CUSTOMS_SCREENED] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[ITEM_CUSTOMS_RESULT_TYPES]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_CUSTOMS_RESULT_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_CUSTOMS_RESULT_TYPES]...'
	DROP TABLE [dbo].[ITEM_CUSTOMS_RESULT_TYPES]
END
GO
PRINT 'INFO: Creating table [ITEM_CUSTOMS_RESULT_TYPES]...'
CREATE TABLE [dbo].[ITEM_CUSTOMS_RESULT_TYPES](
	[TYPE] [varchar](1) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ITEM_CUSTOMS_RESULT_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[ITEM_ENCODED]    Script Date: 10/08/2007 13:18:35 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_ENCODED]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_ENCODED]...'
	DROP TABLE [dbo].[ITEM_ENCODED]
END
GO
PRINT 'INFO: Creating table [ITEM_ENCODED]...'
CREATE TABLE [dbo].[ITEM_ENCODED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[DESTINATION] [varchar](20) NOT NULL,
 CONSTRAINT [PK_ITEM_ENCODED] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

PRINT 'INFO: End of Creating New Table.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Views...'
GO






PRINT 'INFO: End of Creating New Views.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Foreign Keys...'
GO



-- ****** Object:  ForeignKey [FK_AIRLINES_DESTINATION]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_AIRLINES_DESTINATION]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[AIRLINES]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_AIRLINES_DESTINATION]...'
	ALTER TABLE [dbo].[AIRLINES] DROP CONSTRAINT [FK_AIRLINES_DESTINATION]
END
PRINT 'INFO: Creating ForeignKey [FK_AIRLINES_DESTINATION]...'
ALTER TABLE [dbo].[AIRLINES]  WITH CHECK ADD  CONSTRAINT [FK_AIRLINES_DESTINATION] FOREIGN KEY([DESTINATION])
REFERENCES [dbo].[DESTINATIONS] ([DESTINATION])
GO
ALTER TABLE [dbo].[AIRLINES] CHECK CONSTRAINT [FK_AIRLINES_DESTINATION]
GO


---- ****** Object:  ForeignKey [FK_BAGS_ACTION]    Script Date: 10/08/2007 13:18:35 *****
--IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_BAGS_ACTION]') 
--		AND parent_object_id = OBJECT_ID(N'[dbo].[BAGS]'))
--BEGIN
--	PRINT 'INFO: Deleting existing ForeignKey [FK_BAGS_ACTION]...'
--	ALTER TABLE [dbo].[BAGS] DROP CONSTRAINT [FK_BAGS_ACTION]
--END
--PRINT 'INFO: Creating ForeignKey [FK_BAGS_ACTION]...'
--ALTER TABLE [dbo].[BAGS] WITH CHECK ADD CONSTRAINT [FK_BAGS_ACTION] FOREIGN KEY([ACTION])
--REFERENCES [dbo].[BSM_FI_ACTIONS] ([ACTION])
--GO
--ALTER TABLE [dbo].[BAGS] CHECK CONSTRAINT [FK_BAGS_ACTION]
--GO


---- ****** Object:  ForeignKey [FK_FLIGHT_PLANS_ACTION]    Script Date: 10/08/2007 13:18:35 *****
--IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FLIGHT_PLANS_ACTION]') 
--		AND parent_object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLANS]'))
--BEGIN
--	PRINT 'INFO: Deleting existing ForeignKey [FK_FLIGHT_PLANS_ACTION]...'
--	ALTER TABLE [dbo].[FLIGHT_PLANS] DROP CONSTRAINT [FK_FLIGHT_PLANS_ACTION]
--END
--PRINT 'INFO: Creating ForeignKey [FK_FLIGHT_PLANS_ACTION]...'
--ALTER TABLE [dbo].[FLIGHT_PLANS] WITH CHECK ADD CONSTRAINT [FK_FLIGHT_PLANS_ACTION] FOREIGN KEY([ACTION])
--REFERENCES [dbo].[BSM_FI_ACTIONS] ([ACTION])
--GO
--ALTER TABLE [dbo].[FLIGHT_PLANS] CHECK CONSTRAINT [FK_FLIGHT_PLANS_ACTION]
--GO


-- ****** Object:  ForeignKey [FK_AUDIT_LOG_EVENT_TYPE]    Script Date: 10/08/2007 13:18:34 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_AUDIT_LOG_EVENT_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[AUDIT_LOG]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_AUDIT_LOG_EVENT_TYPE]...'
	ALTER TABLE [dbo].[AUDIT_LOG] DROP CONSTRAINT [FK_AUDIT_LOG_EVENT_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_AUDIT_LOG_EVENT_TYPE]...'
ALTER TABLE [dbo].[AUDIT_LOG]  WITH CHECK ADD  CONSTRAINT [FK_AUDIT_LOG_EVENT_TYPE] FOREIGN KEY([EVENT_TYPE])
REFERENCES [dbo].[EVENT_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[AUDIT_LOG] CHECK CONSTRAINT [FK_AUDIT_LOG_EVENT_TYPE]
GO


-- ****** Object:  ForeignKey [FK_FLIGHT_PLAN_ALLOC_RESOURCE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FLIGHT_PLAN_ALLOC_RESOURCE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLAN_ALLOC]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FLIGHT_PLAN_ALLOC_RESOURCE]...'
	ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC] DROP CONSTRAINT [FK_FLIGHT_PLAN_ALLOC_RESOURCE]
END
PRINT 'INFO: Creating ForeignKey [FK_FLIGHT_PLAN_ALLOC_RESOURCE]...'
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHT_PLAN_ALLOC_RESOURCE] FOREIGN KEY([RESOURCE])
REFERENCES [dbo].[ALLOC_RESOURCES] ([RESOURCE])
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ALLOC] CHECK CONSTRAINT [FK_FLIGHT_PLAN_ALLOC_RESOURCE]
GO



-- ****** Object:  ForeignKey [FK_FLIGHT_PLAN_SORTING_HIGH_RISK]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FLIGHT_PLAN_SORTING_HIGH_RISK]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLAN_SORTING]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FLIGHT_PLAN_SORTING_HIGH_RISK]...'
	ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING] DROP CONSTRAINT [FK_FLIGHT_PLAN_SORTING_HIGH_RISK]
END
PRINT 'INFO: Creating ForeignKey [FK_FLIGHT_PLAN_SORTING_HIGH_RISK]...'
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHT_PLAN_SORTING_HIGH_RISK] FOREIGN KEY([HIGH_RISK])
REFERENCES [dbo].[HIGH_RISK_NEEDED] ([VALUE])
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING] CHECK CONSTRAINT [FK_FLIGHT_PLAN_SORTING_HIGH_RISK]
GO



---- ****** Object:  ForeignKey [FK_FLIGHT_PLANS_HIGH_RISK]    Script Date: 10/08/2007 13:18:35 ******
--IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FLIGHT_PLANS_HIGH_RISK]') 
--		AND parent_object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLANS]'))
--BEGIN
--	PRINT 'INFO: Deleting existing ForeignKey [FK_FLIGHT_PLANS_HIGH_RISK]...'
--	ALTER TABLE [dbo].[FLIGHT_PLANS] DROP CONSTRAINT [FK_FLIGHT_PLANS_HIGH_RISK]
--END
--PRINT 'INFO: Creating ForeignKey [FK_FLIGHT_PLANS_HIGH_RISK]...'
--ALTER TABLE [dbo].[FLIGHT_PLANS]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHT_PLANS_HIGH_RISK] FOREIGN KEY([HIGH_RISK])
--REFERENCES [dbo].[HIGH_RISK_NEEDED] ([VALUE])
--GO
--ALTER TABLE [dbo].[FLIGHT_PLANS] CHECK CONSTRAINT [FK_FLIGHT_PLANS_HIGH_RISK]
--GO



-- ****** Object:  ForeignKey [FK_FLIGHTS_AIRCRAFT_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FLIGHTS_AIRCRAFT_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FLIGHTS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FLIGHTS_AIRCRAFT_TYPE]...'
	ALTER TABLE [dbo].[FLIGHTS] DROP CONSTRAINT [FK_FLIGHTS_AIRCRAFT_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_FLIGHTS_AIRCRAFT_TYPE]...'
ALTER TABLE [dbo].[FLIGHTS]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHTS_AIRCRAFT_TYPE] FOREIGN KEY([AIRCRAFT_TYPE])
REFERENCES [dbo].[AIRCRAFT_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[FLIGHTS] CHECK CONSTRAINT [FK_FLIGHTS_AIRCRAFT_TYPE]
GO



-- ****** Object:  ForeignKey [FK_FLIGHTS_AIRLINE_CODE_IATA]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FLIGHTS_AIRLINE_CODE_IATA]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FLIGHTS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FLIGHTS_AIRLINE_CODE_IATA]...'
	ALTER TABLE [dbo].[FLIGHTS] DROP CONSTRAINT [FK_FLIGHTS_AIRLINE_CODE_IATA]
END
PRINT 'INFO: Creating ForeignKey [FK_FLIGHTS_AIRLINE_CODE_IATA]...'
ALTER TABLE [dbo].[FLIGHTS]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHTS_AIRLINE_CODE_IATA] FOREIGN KEY([AIRLINE])
REFERENCES [dbo].[AIRLINES] ([CODE_IATA])
GO
ALTER TABLE [dbo].[FLIGHTS] CHECK CONSTRAINT [FK_FLIGHTS_AIRLINE_CODE_IATA]
GO



-- ****** Object:  ForeignKey [FK_FUNCTION_TYPES_GROUP]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FUNCTION_TYPES_GROUP]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FUNCTION_TYPES]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FUNCTION_TYPES_GROUP]...'
	ALTER TABLE [dbo].[FUNCTION_TYPES] DROP CONSTRAINT [FK_FUNCTION_TYPES_GROUP]
END
PRINT 'INFO: Creating ForeignKey [FK_FUNCTION_TYPES_GROUP]...'
ALTER TABLE [dbo].[FUNCTION_TYPES]  WITH CHECK ADD  CONSTRAINT [FK_FUNCTION_TYPES_GROUP] FOREIGN KEY([GROUP])
REFERENCES [dbo].[FUNCTION_TYPE_GROUPS] ([GROUP])
GO
ALTER TABLE [dbo].[FUNCTION_TYPES] CHECK CONSTRAINT [FK_FUNCTION_TYPES_GROUP]
GO




-- ****** Object:  ForeignKey [FK_FUNCTION_ALLOC_GANTT_RESOURCE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FUNCTION_ALLOC_GANTT_RESOURCE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FUNCTION_ALLOC_GANTT]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FUNCTION_ALLOC_GANTT_RESOURCE]...'
	ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT] DROP CONSTRAINT [FK_FUNCTION_ALLOC_GANTT_RESOURCE]
END
PRINT 'INFO: Creating ForeignKey [FK_FUNCTION_ALLOC_GANTT_RESOURCE]...'
ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT]  WITH CHECK ADD  CONSTRAINT [FK_FUNCTION_ALLOC_GANTT_RESOURCE] FOREIGN KEY([RESOURCE])
REFERENCES [dbo].[ALLOC_RESOURCES] ([RESOURCE])
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT] CHECK CONSTRAINT [FK_FUNCTION_ALLOC_GANTT_RESOURCE]
GO


-- ****** Object:  ForeignKey [FK_FUNCTION_ALLOC_LIST_RESOURCE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FUNCTION_ALLOC_LIST_RESOURCE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FUNCTION_ALLOC_LIST]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FUNCTION_ALLOC_LIST_RESOURCE]...'
	ALTER TABLE [dbo].[FUNCTION_ALLOC_LIST] DROP CONSTRAINT [FK_FUNCTION_ALLOC_LIST_RESOURCE]
END
PRINT 'INFO: Creating ForeignKey [FK_FUNCTION_ALLOC_LIST_RESOURCE]...'
ALTER TABLE [dbo].[FUNCTION_ALLOC_LIST]  WITH CHECK ADD  CONSTRAINT [FK_FUNCTION_ALLOC_LIST_RESOURCE] FOREIGN KEY([RESOURCE])
REFERENCES [dbo].[DESTINATIONS] ([DESTINATION])
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_LIST] CHECK CONSTRAINT [FK_FUNCTION_ALLOC_LIST_RESOURCE]
GO




-- ****** Object:  ForeignKey [FK_FUNCTION_ALLOC_GANTT_FUNC_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FUNCTION_ALLOC_GANTT_FUNC_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FUNCTION_ALLOC_GANTT]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FUNCTION_ALLOC_GANTT_FUNC_TYPE]...'
	ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT] DROP CONSTRAINT [FK_FUNCTION_ALLOC_GANTT_FUNC_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_FUNCTION_ALLOC_GANTT_FUNC_TYPE]...'
ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT]  WITH CHECK ADD  CONSTRAINT [FK_FUNCTION_ALLOC_GANTT_FUNC_TYPE] FOREIGN KEY([FUNCTION_TYPE])
REFERENCES [dbo].[FUNCTION_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_GANTT] CHECK CONSTRAINT [FK_FUNCTION_ALLOC_GANTT_FUNC_TYPE]
GO



-- ****** Object:  ForeignKey [FK_FUNCTION_ALLOC_LIST_FUNC_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FUNCTION_ALLOC_LIST_FUNC_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FUNCTION_ALLOC_LIST]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FUNCTION_ALLOC_LIST_FUNC_TYPE]...'
	ALTER TABLE [dbo].[FUNCTION_ALLOC_LIST] DROP CONSTRAINT [FK_FUNCTION_ALLOC_LIST_FUNC_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_FUNCTION_ALLOC_LIST_FUNC_TYPE]...'
ALTER TABLE [dbo].[FUNCTION_ALLOC_LIST]  WITH CHECK ADD  CONSTRAINT [FK_FUNCTION_ALLOC_LIST_FUNC_TYPE] FOREIGN KEY([FUNCTION_TYPE])
REFERENCES [dbo].[FUNCTION_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[FUNCTION_ALLOC_LIST] CHECK CONSTRAINT [FK_FUNCTION_ALLOC_LIST_FUNC_TYPE]
GO



-- ****** Object:  ForeignKey [FK_ITEM_PROCEEDED_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ITEM_PROCEEDED_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[ITEM_PROCEEDED]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_ITEM_PROCEEDED_TYPE]...'
	ALTER TABLE [dbo].[ITEM_PROCEEDED] DROP CONSTRAINT [FK_ITEM_PROCEEDED_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_ITEM_PROCEEDED_TYPE]...'
ALTER TABLE [dbo].[ITEM_PROCEEDED]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_PROCEEDED_TYPE] FOREIGN KEY([PROCEED_TYPE])
REFERENCES [dbo].[ITEM_PROCEED_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_PROCEEDED] CHECK CONSTRAINT [FK_ITEM_PROCEEDED_TYPE]
GO






-- ****** Object:  ForeignKey [FK_ITEM_REDIRECT_SORTATION_REASON]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ITEM_REDIRECT_SORTATION_REASON]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[ITEM_REDIRECT]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_ITEM_REDIRECT_SORTATION_REASON]...'
	ALTER TABLE [dbo].[ITEM_REDIRECT] DROP CONSTRAINT [FK_ITEM_REDIRECT_SORTATION_REASON]
END
PRINT 'INFO: Creating ForeignKey [FK_ITEM_REDIRECT_SORTATION_REASON]...'
ALTER TABLE [dbo].[ITEM_REDIRECT]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_REDIRECT_SORTATION_REASON] FOREIGN KEY([REASON])
REFERENCES [dbo].[SORTATION_REASON] ([REASON])
GO
ALTER TABLE [dbo].[ITEM_REDIRECT] CHECK CONSTRAINT [FK_ITEM_REDIRECT_SORTATION_REASON]
GO



-- ****** Object:  ForeignKey [FK_ITEM_SCANNED_STATUS_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ITEM_SCANNED_STATUS_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[ITEM_SCANNED]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_ITEM_SCANNED_STATUS_TYPE]...'
	ALTER TABLE [dbo].[ITEM_SCANNED] DROP CONSTRAINT [FK_ITEM_SCANNED_STATUS_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_ITEM_SCANNED_STATUS_TYPE]...'
ALTER TABLE [dbo].[ITEM_SCANNED]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_SCANNED_STATUS_TYPE] FOREIGN KEY([STATUS_TYPE])
REFERENCES [dbo].[ITEM_SCAN_STATUS_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_SCANNED] CHECK CONSTRAINT [FK_ITEM_SCANNED_STATUS_TYPE]
GO



-- ****** Object:  ForeignKey [FK_ITEM_SCREENED_RESULT_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ITEM_SCREENED_RESULT_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[ITEM_SCREENED]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_ITEM_SCREENED_RESULT_TYPE]...'
	ALTER TABLE [dbo].[ITEM_SCREENED] DROP CONSTRAINT [FK_ITEM_SCREENED_RESULT_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_ITEM_SCREENED_RESULT_TYPE]...'
ALTER TABLE [dbo].[ITEM_SCREENED]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_SCREENED_RESULT_TYPE] FOREIGN KEY([RESULT_TYPE])
REFERENCES [dbo].[ITEM_SCREEN_RESULT_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_SCREENED] CHECK CONSTRAINT [FK_ITEM_SCREENED_RESULT_TYPE]
GO



-- ****** Object:  ForeignKey [FK_ITEM_SORTATION_EVENT_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ITEM_SORTATION_EVENT_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[ITEM_SORTATION_EVENT]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_ITEM_SORTATION_EVENT_TYPE]...'
	ALTER TABLE [dbo].[ITEM_SORTATION_EVENT] DROP CONSTRAINT [FK_ITEM_SORTATION_EVENT_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_ITEM_SORTATION_EVENT_TYPE]...'
ALTER TABLE [dbo].[ITEM_SORTATION_EVENT]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_SORTATION_EVENT_TYPE] FOREIGN KEY([SORT_EVENT_TYPE])
REFERENCES [dbo].[ITEM_SORTATION_EVENT_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_SORTATION_EVENT] CHECK CONSTRAINT [FK_ITEM_SORTATION_EVENT_TYPE]
GO





-- ****** Object:  ForeignKey [FK_ALLOC_RESOURCES_SUBSYSTEM]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ALLOC_RESOURCES_SUBSYSTEM]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[DESTINATIONS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_ALLOC_RESOURCES_SUBSYSTEM]...'
	ALTER TABLE [dbo].[ALLOC_RESOURCES] DROP CONSTRAINT [FK_ALLOC_RESOURCES_SUBSYSTEM]
END
PRINT 'INFO: Creating ForeignKey [FK_ALLOC_RESOURCES_SUBSYSTEM]...'
ALTER TABLE [dbo].[ALLOC_RESOURCES]  WITH CHECK ADD  CONSTRAINT [FK_ALLOC_RESOURCES_SUBSYSTEM] FOREIGN KEY([SUBSYSTEM])
REFERENCES [dbo].[SUBSYSTEMS] ([SUBSYSTEM])
GO
ALTER TABLE [dbo].[ALLOC_RESOURCES] CHECK CONSTRAINT [FK_ALLOC_RESOURCES_SUBSYSTEM]
GO




-- ****** Object:  ForeignKey [FK_DESTINATIONS_SUBSYSTEM]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DESTINATIONS_SUBSYSTEM]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[DESTINATIONS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_DESTINATIONS_SUBSYSTEM]...'
	ALTER TABLE [dbo].[DESTINATIONS] DROP CONSTRAINT [FK_DESTINATIONS_SUBSYSTEM]
END
PRINT 'INFO: Creating ForeignKey [FK_DESTINATIONS_SUBSYSTEM]...'
ALTER TABLE [dbo].[DESTINATIONS]  WITH CHECK ADD  CONSTRAINT [FK_DESTINATIONS_SUBSYSTEM] FOREIGN KEY([SUBSYSTEM])
REFERENCES [dbo].[SUBSYSTEMS] ([SUBSYSTEM])
GO
ALTER TABLE [dbo].[DESTINATIONS] CHECK CONSTRAINT [FK_DESTINATIONS_SUBSYSTEM]
GO




-- ****** Object:  ForeignKey [FK_DESTINATION_GROUPING_NAME]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DESTINATION_GROUPING_NAME]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[DESTINATION_GROUPING]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_DESTINATION_GROUPING_NAME]...'
	ALTER TABLE [dbo].[DESTINATION_GROUPING] DROP CONSTRAINT [FK_DESTINATION_GROUPING_NAME]
END
PRINT 'INFO: Creating ForeignKey [FK_DESTINATION_GROUPING_NAME]...'
ALTER TABLE [dbo].[DESTINATION_GROUPING]  WITH CHECK ADD  CONSTRAINT [FK_DESTINATION_GROUPING_NAME] FOREIGN KEY([GROUP_NAME])
REFERENCES [dbo].[DESTINATIONS] ([DESTINATION])
GO
ALTER TABLE [dbo].[DESTINATION_GROUPING] CHECK CONSTRAINT [FK_DESTINATION_GROUPING_NAME]
GO


-- ****** Object:  ForeignKey [FK_DESTINATION_GROUPING_LOCATION]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DESTINATION_GROUPING_LOCATION]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[DESTINATION_GROUPING]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_DESTINATION_GROUPING_LOCATION]...'
	ALTER TABLE [dbo].[DESTINATION_GROUPING] DROP CONSTRAINT [FK_DESTINATION_GROUPING_LOCATION]
END
PRINT 'INFO: Creating ForeignKey [FK_DESTINATION_GROUPING_LOCATION]...'
ALTER TABLE [dbo].[DESTINATION_GROUPING]  WITH CHECK ADD  CONSTRAINT [FK_DESTINATION_GROUPING_LOCATION] FOREIGN KEY([LOCATION], [SUBSYSTEM])
REFERENCES [dbo].[LOCATIONS] ([LOCATION], [SUBSYSTEM])
GO
ALTER TABLE [dbo].[DESTINATION_GROUPING] CHECK CONSTRAINT [FK_DESTINATION_GROUPING_LOCATION]
GO



-- ****** Object:  ForeignKey [FK_FALLBACK_MAPPING_DESTINATION]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FALLBACK_MAPPING_DESTINATION]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FALLBACK_MAPPING]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FALLBACK_MAPPING_DESTINATION]...'
	ALTER TABLE [dbo].[FALLBACK_MAPPING] DROP CONSTRAINT [FK_FALLBACK_MAPPING_DESTINATION]
END
PRINT 'INFO: Creating ForeignKey [FK_FALLBACK_MAPPING_DESTINATION]...'
ALTER TABLE [dbo].[FALLBACK_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_FALLBACK_MAPPING_DESTINATION] FOREIGN KEY([DESTINATION])
REFERENCES [dbo].[DESTINATIONS] ([DESTINATION])
GO
ALTER TABLE [dbo].[FALLBACK_MAPPING] CHECK CONSTRAINT [FK_FALLBACK_MAPPING_DESTINATION]
GO



-- ****** Object:  ForeignKey [FK_LOCATIONS_STATUS_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LOCATIONS_STATUS_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[LOCATIONS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_LOCATIONS_STATUS_TYPE]...'
	ALTER TABLE [dbo].[LOCATIONS] DROP CONSTRAINT [FK_LOCATIONS_STATUS_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_LOCATIONS_STATUS_TYPE]...'
ALTER TABLE [dbo].[LOCATIONS]  WITH CHECK ADD  CONSTRAINT [FK_LOCATIONS_STATUS_TYPE] FOREIGN KEY([STATUS_TYPE])
REFERENCES [dbo].[LOCATION_STATUS_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[LOCATIONS] CHECK CONSTRAINT [FK_LOCATIONS_STATUS_TYPE]
GO



-- ****** Object:  ForeignKey [FK_LOCATIONS_SUBSYSTEM]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LOCATIONS_SUBSYSTEM]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[LOCATIONS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_LOCATIONS_SUBSYSTEM]...'
	ALTER TABLE [dbo].[LOCATIONS] DROP CONSTRAINT [FK_LOCATIONS_SUBSYSTEM]
END
PRINT 'INFO: Creating ForeignKey [FK_LOCATIONS_SUBSYSTEM]...'
ALTER TABLE [dbo].[LOCATIONS]  WITH CHECK ADD  CONSTRAINT [FK_LOCATIONS_SUBSYSTEM] FOREIGN KEY([SUBSYSTEM])
REFERENCES [dbo].[SUBSYSTEMS] ([SUBSYSTEM])
GO
ALTER TABLE [dbo].[LOCATIONS] CHECK CONSTRAINT [FK_LOCATIONS_SUBSYSTEM]
GO



-- ****** Object:  ForeignKey [FK_USER_ROLES_ROLEID]    Script Date: 10/08/2007 13:18:36 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_USER_ROLES_ROLEID]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[USERS_ROLES]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_USER_ROLES_ROLEID]...'
	ALTER TABLE [dbo].[USERS_ROLES] DROP CONSTRAINT [FK_USER_ROLES_ROLEID]
END
PRINT 'INFO: Creating ForeignKey [FK_USER_ROLES_ROLEID]...'
ALTER TABLE [dbo].[USERS_ROLES]  WITH CHECK ADD  CONSTRAINT [FK_USER_ROLES_ROLEID] FOREIGN KEY([ROLE_ID])
REFERENCES [dbo].[ROLES] ([ID])
GO
ALTER TABLE [dbo].[USERS_ROLES] CHECK CONSTRAINT [FK_USER_ROLES_ROLEID]
GO



-- ****** Object:  ForeignKey [FK_USER_ROLES_USERID]    Script Date: 10/08/2007 13:18:36 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_USER_ROLES_USERID]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[USERS_ROLES]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_USER_ROLES_USERID]...'
	ALTER TABLE [dbo].[USERS_ROLES] DROP CONSTRAINT [FK_USER_ROLES_USERID]
END
PRINT 'INFO: Creating ForeignKey [FK_USER_ROLES_USERID]...'
ALTER TABLE [dbo].[USERS_ROLES]  WITH CHECK ADD  CONSTRAINT [FK_USER_ROLES_USERID] FOREIGN KEY([USER_ID])
REFERENCES [dbo].[USERS] ([ID])
GO
ALTER TABLE [dbo].[USERS_ROLES] CHECK CONSTRAINT [FK_USER_ROLES_USERID]
GO


-- ****** Object:  ForeignKey [FK_APP_LIVE_MONITORING_STATUS_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_APP_LIVE_MONITORING_STATUS_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[APP_LIVE_MONITORING]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_APP_LIVE_MONITORING_STATUS_TYPE]...'
	ALTER TABLE [dbo].[APP_LIVE_MONITORING] DROP CONSTRAINT [FK_APP_LIVE_MONITORING_STATUS_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_APP_LIVE_MONITORING_STATUS_TYPE]...'
ALTER TABLE [dbo].[APP_LIVE_MONITORING] WITH CHECK ADD CONSTRAINT [FK_APP_LIVE_MONITORING_STATUS_TYPE] FOREIGN KEY([LIVE_STATUS_TYPE])
REFERENCES [dbo].APP_LIVE_STATUS_TYPES ([TYPE])
GO
ALTER TABLE [dbo].[APP_LIVE_MONITORING] CHECK CONSTRAINT [FK_APP_LIVE_MONITORING_STATUS_TYPE]
GO


-- ****** Object:  ForeignKey [FK_TEMPLATES_TEMPLATE_GROUP]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TEMPLATES_TEMPLATE_GROUP]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[TEMPLATES]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_TEMPLATES_TEMPLATE_GROUP]...'
	ALTER TABLE [dbo].[TEMPLATES] DROP CONSTRAINT [FK_TEMPLATES_TEMPLATE_GROUP]
END
PRINT 'INFO: Creating ForeignKey [FK_TEMPLATES_TEMPLATE_GROUP]...'
ALTER TABLE [dbo].[TEMPLATES] WITH CHECK ADD CONSTRAINT [FK_TEMPLATES_TEMPLATE_GROUP] FOREIGN KEY([TEMPLATE_GROUP_ID])
REFERENCES [dbo].[TEMPLATE_GROUPS] ([ID])
GO
ALTER TABLE [dbo].[TEMPLATES] CHECK CONSTRAINT [FK_TEMPLATES_TEMPLATE_GROUP]
GO




-- ****** Object:  ForeignKey [FK_TEMPLATE_ASSIGNMENTS_TEMPLATE_ID]    Script Date: 10/08/2007 13:18:35 *****
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TEMPLATE_ASSIGNMENTS_TEMPLATE_ID]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[TEMPLATE_ASSIGNMENTS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_TEMPLATE_ASSIGNMENTS_TEMPLATE_ID]...'
	ALTER TABLE [dbo].[TEMPLATE_ASSIGNMENTS] DROP CONSTRAINT [FK_TEMPLATE_ASSIGNMENTS_TEMPLATE_ID]
END
PRINT 'INFO: Creating ForeignKey [FK_TEMPLATE_ASSIGNMENTS_TEMPLATE_ID]...'
ALTER TABLE [dbo].[TEMPLATE_ASSIGNMENTS] WITH CHECK ADD CONSTRAINT [FK_TEMPLATE_ASSIGNMENTS_TEMPLATE_ID] FOREIGN KEY([TEMPLATE_ID])
REFERENCES [dbo].[TEMPLATES] ([ID])
GO
ALTER TABLE [dbo].[TEMPLATE_ASSIGNMENTS] CHECK CONSTRAINT [FK_TEMPLATE_ASSIGNMENTS_TEMPLATE_ID]
GO




-- ****** Object:  ForeignKey [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_TEMPLATE_ID]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TEMPLATE_FLIGHT_PLAN_ALLOC_TEMPLATE_ID]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_TEMPLATE_ID]...'
	ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC] DROP CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_TEMPLATE_ID]
END
PRINT 'INFO: Creating ForeignKey [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_TEMPLATE_ID]...'
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC] WITH CHECK ADD CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_TEMPLATE_ID] FOREIGN KEY([TEMPLATE_ID])
REFERENCES [dbo].[TEMPLATES] ([ID])
GO
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC] CHECK CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_TEMPLATE_ID]
GO




-- ****** Object:  ForeignKey [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_SCHEME_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TEMPLATE_FLIGHT_PLAN_ALLOC_SCHEME_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_SCHEME_TYPE]...'
	ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC] DROP CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_SCHEME_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_SCHEME_TYPE]...'
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]  WITH CHECK ADD  CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_SCHEME_TYPE] FOREIGN KEY([SCHEME_TYPE])
REFERENCES [dbo].[SCHEME_TYPE] ([SCHEME_TYPE])
GO
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC] CHECK CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_SCHEME_TYPE]
GO




-- ****** Object:  ForeignKey [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_RESOURCE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_TEMPLATE_FLIGHT_PLAN_ALLOC_RESOURCE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_RESOURCE]...'
	ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC] DROP CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_RESOURCE]
END
PRINT 'INFO: Creating ForeignKey [FK_TFPA_RESOURCE]...'
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC]  WITH CHECK ADD  CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_RESOURCE] FOREIGN KEY([RESOURCE])
REFERENCES [dbo].[ALLOC_RESOURCES] ([RESOURCE])
GO
ALTER TABLE [dbo].[TEMPLATE_FLIGHT_PLAN_ALLOC] CHECK CONSTRAINT [FK_TEMPLATE_FLIGHT_PLAN_ALLOC_RESOURCE]
GO




-- ****** Object:  ForeignKey [FK_CHANGE_MONITORING_SAC_OWS]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CHANGE_MONITORING_SAC_OWS]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[CHANGE_MONITORING]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_CHANGE_MONITORING_SAC_OWS]...'
	ALTER TABLE [dbo].[CHANGE_MONITORING] DROP CONSTRAINT [FK_CHANGE_MONITORING_SAC_OWS]
END
PRINT 'INFO: Creating ForeignKey [FK_CHANGE_MONITORING_SAC_OWS]...'
ALTER TABLE [dbo].[CHANGE_MONITORING]  WITH CHECK ADD  CONSTRAINT [FK_CHANGE_MONITORING_SAC_OWS] FOREIGN KEY([SAC_OWS])
REFERENCES [dbo].[SAC_OWS] ([SAC_OWS])
GO
ALTER TABLE [dbo].[CHANGE_MONITORING] CHECK CONSTRAINT [FK_CHANGE_MONITORING_SAC_OWS]
GO


-- ****** Object:  ForeignKey [FK_ITEM_ENCODING_REQUEST_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ITEM_ENCODING_REQUEST_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[ITEM_ENCODING_REQUEST]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_ITEM_ENCODING_REQUEST_TYPE]...'
	ALTER TABLE [dbo].[ITEM_ENCODING_REQUEST] DROP CONSTRAINT [FK_ITEM_ENCODING_REQUEST_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_ITEM_ENCODING_REQUEST_TYPE]...'
ALTER TABLE [dbo].[ITEM_ENCODING_REQUEST]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_ENCODING_REQUEST_TYPE] FOREIGN KEY([ENCODING_TYPE])
REFERENCES [dbo].[ITEM_ENCODING_REQUEST_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_ENCODING_REQUEST] CHECK CONSTRAINT [FK_ITEM_ENCODING_REQUEST_TYPE]
GO


-- ****** Object:  ForeignKey [FK_SECURITY_TASKS_SECU_CAT_CODE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_TASKS_SECU_CAT_CODE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_TASKS_SECU_CAT_CODE]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_SECURITY_TASKS_SECU_CAT_CODE]...'
	ALTER TABLE [dbo].[SECURITY_TASKS] DROP CONSTRAINT [FK_SECURITY_TASKS_SECU_CAT_CODE]
END
PRINT 'INFO: Creating ForeignKey [FK_SECURITY_TASKS_SECU_CAT_CODE]...'
ALTER TABLE [dbo].[SECURITY_TASKS]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_TASKS_SECU_CAT_CODE] FOREIGN KEY([SECU_CAT_CODE])
REFERENCES [dbo].[SECURITY_CATEGORIES] ([SECU_CAT_CODE])
GO
ALTER TABLE [dbo].[SECURITY_TASKS] CHECK CONSTRAINT [FK_SECURITY_TASKS_SECU_CAT_CODE]
GO


-- ****** Object:  ForeignKey [FK_SECURITY_GROUPS_SECU_CAT_CODE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_GROUPS_SECU_CAT_CODE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_GROUPS_SECU_CAT_CODE]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_SECURITY_GROUPS_SECU_CAT_CODE]...'
	ALTER TABLE [dbo].[SECURITY_GROUPS] DROP CONSTRAINT [FK_SECURITY_GROUPS_SECU_CAT_CODE]
END
PRINT 'INFO: Creating ForeignKey [FK_SECURITY_GROUPS_SECU_CAT_CODE]...'
ALTER TABLE [dbo].[SECURITY_GROUPS]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_GROUPS_SECU_CAT_CODE] FOREIGN KEY([SECU_CAT_CODE])
REFERENCES [dbo].[SECURITY_CATEGORIES] ([SECU_CAT_CODE])
GO
ALTER TABLE [dbo].[SECURITY_GROUPS] CHECK CONSTRAINT [FK_SECURITY_GROUPS_SECU_CAT_CODE]
GO


-- ****** Object:  ForeignKey [FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE]...'
	ALTER TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING] DROP CONSTRAINT [FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE]
END
PRINT 'INFO: Creating ForeignKey [FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE]...'
ALTER TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE] FOREIGN KEY([SECU_TASK_CODE])
REFERENCES [dbo].[SECURITY_TASKS] ([SECU_TASK_CODE])
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING] CHECK CONSTRAINT [FK_SECURITY_GROUP_TASK_MAPPING_SECU_TASK_CODE]
GO


-- ****** Object:  ForeignKey [FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE]...'
	ALTER TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING] DROP CONSTRAINT [FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE]
END
PRINT 'INFO: Creating ForeignKey [FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE]...'
ALTER TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE] FOREIGN KEY([SECU_GROUP_CODE])
REFERENCES [dbo].[SECURITY_GROUPS] ([SECU_GROUP_CODE])
GO
ALTER TABLE [dbo].[SECURITY_GROUP_TASK_MAPPING] CHECK CONSTRAINT [FK_SECURITY_GROUP_TASK_MAPPING_SECU_GROUP_CODE]
GO


-- ****** Object:  ForeignKey [FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE]...'
	ALTER TABLE [dbo].[SECURITY_USER_RIGHTS] DROP CONSTRAINT [FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE]
END
PRINT 'INFO: Creating ForeignKey [FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE]...'
ALTER TABLE [dbo].[SECURITY_USER_RIGHTS]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE] FOREIGN KEY([SECU_GROUP_CODE])
REFERENCES [dbo].[SECURITY_GROUPS] ([SECU_GROUP_CODE])
GO
ALTER TABLE [dbo].[SECURITY_USER_RIGHTS] CHECK CONSTRAINT [FK_SECURITY_USER_RIGHTS_SECU_GROUP_CODE]
GO


-- ****** Object:  ForeignKey [FK_SECURITY_USER_RIGHTS_USER_NAME]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_USER_RIGHTS_USER_NAME]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FK_SECURITY_USER_RIGHTS_USER_NAME]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_SECURITY_USER_RIGHTS_USER_NAME]...'
	ALTER TABLE [dbo].[SECURITY_USER_RIGHTS] DROP CONSTRAINT [FK_SECURITY_USER_RIGHTS_USER_NAME]
END
PRINT 'INFO: Creating ForeignKey [FK_SECURITY_USER_RIGHTS_USER_NAME]...'
ALTER TABLE [dbo].[SECURITY_USER_RIGHTS]  WITH CHECK ADD  CONSTRAINT [FK_SECURITY_USER_RIGHTS_USER_NAME] FOREIGN KEY([USER_NAME])
REFERENCES [dbo].[SECURITY_USERS] ([USER_NAME])
GO
ALTER TABLE [dbo].[SECURITY_USER_RIGHTS] CHECK CONSTRAINT [FK_SECURITY_USER_RIGHTS_USER_NAME]
GO


-- ****** Object:  ForeignKey [FK_BAG_SORTING_BAG]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_BAG_SORTING_BAG]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FK_BAG_SORTING_BAG]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_BAG_SORTING_BAG]...'
	ALTER TABLE [dbo].[BAG_SORTING] DROP CONSTRAINT [FK_BAG_SORTING_BAG]
END
PRINT 'INFO: Creating ForeignKey [FK_BAG_SORTING_BAG]...'
ALTER TABLE [dbo].[BAG_SORTING]  WITH CHECK ADD  CONSTRAINT [FK_BAG_SORTING_BAG] FOREIGN KEY([DATA_ID])
REFERENCES [dbo].[BAGS] ([ID])
GO
ALTER TABLE [dbo].[BAG_SORTING] CHECK CONSTRAINT [FK_BAG_SORTING_BAG]
GO


-- ****** Object:  ForeignKey [FK_BAG_ERROR_BSM_BAG]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_BAG_ERROR_BSM_BAG]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FK_BAG_ERROR_BSM_BAG]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_BAG_ERROR_BSM_BAG]...'
	ALTER TABLE [dbo].[BAG_ERROR_BSM] DROP CONSTRAINT [FK_BAG_ERROR_BSM_BAG]
END
PRINT 'INFO: Creating ForeignKey [FK_BAG_ERROR_BSM_BAG]...'
ALTER TABLE [dbo].[BAG_ERROR_BSM]  WITH CHECK ADD  CONSTRAINT [FK_BAG_ERROR_BSM_BAG] FOREIGN KEY([DATA_ID])
REFERENCES [dbo].[BAGS] ([ID])
GO
ALTER TABLE [dbo].[BAG_ERROR_BSM] CHECK CONSTRAINT [FK_BAG_ERROR_BSM_BAG]
GO


-- ****** Object:  ForeignKey [FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS]...'
	ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING] DROP CONSTRAINT [FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS]
END
PRINT 'INFO: Creating ForeignKey [FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS]...'
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING]  WITH CHECK ADD  CONSTRAINT [FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS] FOREIGN KEY([DATA_ID])
REFERENCES [dbo].[FLIGHT_PLANS] ([ID])
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_SORTING] CHECK CONSTRAINT [FK_FLIGHT_PLAN_SORTING_FLIGHT_PLANS]
GO



-- ****** Object:  ForeignKey [FLIGHT_PLAN_ERROR_FLIGHT_PLANS]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLAN_ERROR_FLIGHT_PLANS]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[FLIGHT_PLAN_ERROR_FLIGHT_PLANS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FLIGHT_PLAN_ERROR_FLIGHT_PLANS]...'
	ALTER TABLE [dbo].[FLIGHT_PLAN_ERROR] DROP CONSTRAINT [FLIGHT_PLAN_ERROR_FLIGHT_PLANS]
END
PRINT 'INFO: Creating ForeignKey [FLIGHT_PLAN_ERROR_FLIGHT_PLANS]...'
ALTER TABLE [dbo].[FLIGHT_PLAN_ERROR]  WITH CHECK ADD  CONSTRAINT [FLIGHT_PLAN_ERROR_FLIGHT_PLANS] FOREIGN KEY([DATA_ID])
REFERENCES [dbo].[FLIGHT_PLANS] ([ID])
GO
ALTER TABLE [dbo].[FLIGHT_PLAN_ERROR] CHECK CONSTRAINT [FLIGHT_PLAN_ERROR_FLIGHT_PLANS]
GO


-- ****** Object:  ForeignKey [FK_BAGGAGE_MEASURE_ARRAY_MSG_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_BAGGAGE_MEASURE_ARRAY_MSG_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[BAGGAGE_MEASURE_ARRAY_MSG]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_BAGGAGE_MEASURE_ARRAY_MSG_TYPE]...'
	ALTER TABLE [dbo].[BAGGAGE_MEASURE_ARRAY_MSG] DROP CONSTRAINT [FK_BAGGAGE_MEASURE_ARRAY_MSG_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_BAGGAGE_MEASURE_ARRAY_MSG_TYPE]...'
ALTER TABLE [dbo].[BAGGAGE_MEASURE_ARRAY_MSG]  WITH CHECK ADD  CONSTRAINT [FK_BAGGAGE_MEASURE_ARRAY_MSG_TYPE] FOREIGN KEY([TYPE])
REFERENCES [dbo].[BAGGAGE_MEASURE_ARRAY_TYPE] ([TYPE])
GO
ALTER TABLE [dbo].[BAGGAGE_MEASURE_ARRAY_MSG] CHECK CONSTRAINT [FK_BAGGAGE_MEASURE_ARRAY_MSG_TYPE]
GO



-- ****** Object:  ForeignKey [FK_ITEM_CUSTOMS_SCREENED_RESULT_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ITEM_CUSTOMS_SCREENED_RESULT_TYPE]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[ITEM_CUSTOMS_SCREENED]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_ITEM_CUSTOMS_SCREENED_RESULT_TYPE]...'
	ALTER TABLE [dbo].[ITEM_CUSTOMS_SCREENED] DROP CONSTRAINT [FK_ITEM_CUSTOMS_SCREENED_RESULT_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_ITEM_CUSTOMS_SCREENED_RESULT_TYPE]...'
ALTER TABLE [dbo].[ITEM_CUSTOMS_SCREENED]  WITH CHECK ADD  CONSTRAINT [FK_ITEM_CUSTOMS_SCREENED_RESULT_TYPE] FOREIGN KEY([RESULT_TYPE])
REFERENCES [dbo].[ITEM_CUSTOMS_RESULT_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[ITEM_CUSTOMS_SCREENED] CHECK CONSTRAINT [FK_ITEM_CUSTOMS_SCREENED_RESULT_TYPE]
GO



PRINT 'INFO: End of Creating New Foreign Keys.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Constraints...'
GO

-- ****** Object:  Constraints [DF_SECURITY_CATEGORIES_IS_ACTIVE]    Script Date: 10/08/2007 13:18:35 ******
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_SECURITY_CATEGORIES_IS_ACTIVE]') AND type = 'D')
BEGIN
	PRINT 'INFO: Deleting existing Constraints [DF_SECURITY_CATEGORIES_IS_ACTIVE]...'
	ALTER TABLE [dbo].[SECURITY_CATEGORIES] DROP CONSTRAINT [DF_SECURITY_CATEGORIES_IS_ACTIVE]
END
PRINT 'INFO: Creating Constraints [DF_SECURITY_CATEGORIES_IS_ACTIVE]...'
ALTER TABLE [dbo].[SECURITY_CATEGORIES] ADD  CONSTRAINT [DF_SECURITY_CATEGORIES_IS_ACTIVE]  DEFAULT ((1)) FOR [IS_ACTIVE]
GO


-- ****** Object:  Constraints [DF_SECURITY_TASKS_IS_ACTIVE]    Script Date: 10/08/2007 13:18:35 ******
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_SECURITY_TASKS_IS_ACTIVE]') AND type = 'D')
BEGIN
	PRINT 'INFO: Deleting existing Constraints [DF_SECURITY_TASKS_IS_ACTIVE]...'
	ALTER TABLE [dbo].[SECURITY_TASKS] DROP CONSTRAINT [DF_SECURITY_TASKS_IS_ACTIVE]
END
PRINT 'INFO: Creating Constraints [DF_SECURITY_TASKS_IS_ACTIVE]...'
ALTER TABLE [dbo].[SECURITY_TASKS] ADD  CONSTRAINT [DF_SECURITY_TASKS_IS_ACTIVE]  DEFAULT ((1)) FOR [IS_ACTIVE]
GO


-- ****** Object:  Constraints [DF_SECURITY_GROUPS_IS_ACTIVE]    Script Date: 10/08/2007 13:18:35 ******
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_SECURITY_GROUPS_IS_ACTIVE]') AND type = 'D')
BEGIN
	PRINT 'INFO: Deleting existing Constraints [DF_SECURITY_GROUPS_IS_ACTIVE]...'
	ALTER TABLE [dbo].[SECURITY_GROUPS] DROP CONSTRAINT [DF_SECURITY_GROUPS_IS_ACTIVE]
END
PRINT 'INFO: Creating Constraints [DF_SECURITY_GROUPS_IS_ACTIVE]...'
ALTER TABLE [dbo].[SECURITY_GROUPS] ADD  CONSTRAINT [DF_SECURITY_GROUPS_IS_ACTIVE]  DEFAULT ((1)) FOR [IS_ACTIVE]
GO


-- ****** Object:  Constraints [DF_SECURITY_USERS_IS_ACTIVE]    Script Date: 10/08/2007 13:18:35 ******
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_SECURITY_USERS_IS_ACTIVE]') AND type = 'D')
BEGIN
	PRINT 'INFO: Deleting existing Constraints [DF_SECURITY_USERS_IS_ACTIVE]...'
	ALTER TABLE [dbo].[SECURITY_USERS] DROP CONSTRAINT [DF_SECURITY_USERS_IS_ACTIVE]
END
PRINT 'INFO: Creating Constraints [DF_SECURITY_USERS_IS_ACTIVE]...'
ALTER TABLE [dbo].[SECURITY_USERS] ADD  CONSTRAINT [DF_SECURITY_USERS_IS_ACTIVE]  DEFAULT ((1)) FOR [IS_ACTIVE]
GO




PRINT 'INFO: End of Creating New Foreign Keys.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Triggers...'
GO


---- ****** Object:  Trigger [INSERT_BAGS]    Script Date: 10/08/2007 13:18:36 ******
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_BAGS]'))
--BEGIN
--	PRINT 'INFO: Deleting existing trigger [INSERT_BAGS]...'
--	DROP TRIGGER [INSERT_BAGS]
--END
--PRINT 'INFO: Creating trigger [INSERT_BAGS]...'
--GO
--CREATE TRIGGER [dbo].[INSERT_BAGS] ON [dbo].[BAGS] 
--AFTER INSERT
--AS
--BEGIN
--	-- Verify [ACTION] field value of inserted record:
--	-- ADD - add in new BSM, UPD - Update existing BSM, DEL - Delete existing BSM
--    DECLARE @ACTION [varchar](10), @TIME_STAMP [datetime], @DICTIONARY_VERSION int, 
--			@SOURCE_INDICATOR [varchar](2), @AIRPORT_CODE [varchar](5),
--			@LICENSE_PLATE [varchar](10), @AIRLINE [varchar](3), @FLIGHT_NUMBER [varchar](5),
--			@SDO [datetime], @DESTINATION [varchar](5), @TRAVEL_CLASS [varchar](1),
--			@INBOUND_AIRLINE [varchar](3), @INBOUND_FLIGHT_NUMBER [varchar](5),
--			@INBOUND_SDO [datetime], @INBOUND_AIRPORT_CODE [varchar](5),
--			@INBOUND_TRAVEL_CLASS [varchar](1), @ONWARD_AIRLINE [varchar](3),
--			@ONWARD_FLIGHT_NUMBER [varchar](5), @ONWARD_SDO [datetime],
--			@ONWARD_AIRPORT_CODE [varchar](5), @ONWARD_TRAVEL_CLASS [varchar](1),
--			@NO_PASSENGER_SAME_SURNAME int,	@SURNAME [nvarchar](30),
--			@GIVEN_NAME [nvarchar](30), @OTHERS_NAME [nvarchar](30),
--			@BAG_EXCEPTION [varchar](10), @CREATED_BY [varchar](15); 
			
--	SELECT  @ACTION=ACTION, @TIME_STAMP=TIME_STAMP, @DICTIONARY_VERSION = DICTIONARY_VERSION,
--			@SOURCE_INDICATOR = SOURCE_INDICATOR, @AIRPORT_CODE = AIRPORT_CODE,
--			@LICENSE_PLATE=LICENSE_PLATE, @AIRLINE=AIRLINE, @FLIGHT_NUMBER=FLIGHT_NUMBER, 
--			@SDO=SDO, @DESTINATION = DESTINATION, @TRAVEL_CLASS=TRAVEL_CLASS,
--			@INBOUND_AIRLINE = INBOUND_AIRLINE, @INBOUND_FLIGHT_NUMBER = INBOUND_FLIGHT_NUMBER,
--			@INBOUND_SDO = INBOUND_SDO, @INBOUND_AIRPORT_CODE = INBOUND_AIRPORT_CODE,			
--			@INBOUND_TRAVEL_CLASS = INBOUND_TRAVEL_CLASS, @ONWARD_AIRLINE = ONWARD_AIRLINE,
--			@ONWARD_FLIGHT_NUMBER = ONWARD_FLIGHT_NUMBER, @ONWARD_SDO = ONWARD_SDO,
--			@ONWARD_AIRPORT_CODE = ONWARD_AIRPORT_CODE, @ONWARD_TRAVEL_CLASS = ONWARD_TRAVEL_CLASS,
--			@NO_PASSENGER_SAME_SURNAME = NO_PASSENGER_SAME_SURNAME,	@SURNAME = SURNAME,
--			@GIVEN_NAME = GIVEN_NAME, @OTHERS_NAME = OTHERS_NAME, @BAG_EXCEPTION=BAG_EXCEPTION,
--			@CREATED_BY=CREATED_BY			
--	FROM INSERTED;
	
--	IF @ACTION = 'NEW'
--	BEGIN
--		DECLARE @COUNT INT 
--		SET @COUNT = (SELECT COUNT(*)	FROM [BAG_SORTING] WHERE LICENSE_PLATE = @LICENSE_PLATE AND AIRLINE = @AIRLINE AND 
--					FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDO AND NO_PASSENGER_SAME_SURNAME = @NO_PASSENGER_SAME_SURNAME AND
--					SURNAME = @SURNAME AND GIVEN_NAME = @GIVEN_NAME AND OTHERS_NAME = @OTHERS_NAME AND
--					TRAVEL_CLASS = @TRAVEL_CLASS AND SOURCE = @SOURCE_INDICATOR AND CREATED_BY = @CREATED_BY AND
--					INBOUND_AIRLINE = @INBOUND_AIRLINE AND	INBOUND_FLIGHT_NUMBER = @INBOUND_FLIGHT_NUMBER AND
--					BAG_EXCEPTION = @BAG_EXCEPTION)
		
--		IF @COUNT = 0
--			INSERT INTO [BAG_SORTING] (
--				TIME_STAMP, LICENSE_PLATE, AIRLINE, FLIGHT_NUMBER, SDO,
--				NO_PASSENGER_SAME_SURNAME, SURNAME, GIVEN_NAME, OTHERS_NAME,
--				TRAVEL_CLASS, SOURCE, CREATED_BY, INBOUND_AIRLINE,
--				INBOUND_FLIGHT_NUMBER, BAG_EXCEPTION) 
--			VALUES ( 
--				@TIME_STAMP,@LICENSE_PLATE,@AIRLINE,@FLIGHT_NUMBER,@SDO, 
--				@NO_PASSENGER_SAME_SURNAME, @SURNAME, @GIVEN_NAME, @OTHERS_NAME,
--				@TRAVEL_CLASS, @SOURCE_INDICATOR, @CREATED_BY, @INBOUND_AIRLINE,
--				@INBOUND_FLIGHT_NUMBER,	@BAG_EXCEPTION);
--		ELSE
--			UPDATE [BAG_SORTING] SET 
--				TIME_STAMP = @TIME_STAMP, AIRLINE = @AIRLINE, 
--				FLIGHT_NUMBER = @FLIGHT_NUMBER, SDO = @SDO,
--				NO_PASSENGER_SAME_SURNAME = @NO_PASSENGER_SAME_SURNAME,
--				SURNAME = @SURNAME, GIVEN_NAME = @GIVEN_NAME, OTHERS_NAME = @OTHERS_NAME,
--				TRAVEL_CLASS = @TRAVEL_CLASS, SOURCE = @SOURCE_INDICATOR, CREATED_BY = @CREATED_BY,
--				INBOUND_AIRLINE = @INBOUND_AIRLINE,	INBOUND_FLIGHT_NUMBER = @INBOUND_FLIGHT_NUMBER,
--				BAG_EXCEPTION = @BAG_EXCEPTION
--			WHERE 
--				LICENSE_PLATE = @LICENSE_PLATE AND AIRLINE = @AIRLINE AND 
--				FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDO AND NO_PASSENGER_SAME_SURNAME = @NO_PASSENGER_SAME_SURNAME AND
--				SURNAME = @SURNAME AND GIVEN_NAME = @GIVEN_NAME AND OTHERS_NAME = @OTHERS_NAME AND
--				TRAVEL_CLASS = @TRAVEL_CLASS AND SOURCE = @SOURCE_INDICATOR AND CREATED_BY = @CREATED_BY AND
--				INBOUND_AIRLINE = @INBOUND_AIRLINE AND	INBOUND_FLIGHT_NUMBER = @INBOUND_FLIGHT_NUMBER AND
--				BAG_EXCEPTION = @BAG_EXCEPTION;
--	END
	
--	IF @ACTION = 'UPD'
--	BEGIN
--		UPDATE [BAG_SORTING] SET 
--			TIME_STAMP = @TIME_STAMP, LICENSE_PLATE = @LICENSE_PLATE, AIRLINE = @AIRLINE,
--			FLIGHT_NUMBER = @FLIGHT_NUMBER, SDO = @SDO, NO_PASSENGER_SAME_SURNAME = @NO_PASSENGER_SAME_SURNAME,
--			SURNAME = @SURNAME, GIVEN_NAME = @GIVEN_NAME, OTHERS_NAME = @OTHERS_NAME,
--			TRAVEL_CLASS = @TRAVEL_CLASS, SOURCE = @SOURCE_INDICATOR, CREATED_BY = @CREATED_BY,
--			INBOUND_AIRLINE = @INBOUND_AIRLINE,	INBOUND_FLIGHT_NUMBER = @INBOUND_FLIGHT_NUMBER,
--			BAG_EXCEPTION = @BAG_EXCEPTION
--		WHERE 
--			LICENSE_PLATE = @LICENSE_PLATE AND AIRLINE = @AIRLINE AND 
--			FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDO;
--	END
	
--	IF @ACTION = 'DEL'
--	BEGIN
--		DELETE FROM [BAG_SORTING] WHERE 
--			LICENSE_PLATE = @LICENSE_PLATE AND AIRLINE = @AIRLINE AND 
--			FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDO;
--	END
--END
--GO


-- ****** Object:  Trigger [INSERT_BAG_ERROR]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_BAG_ERROR]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_BAG_ERROR]...'
	DROP TRIGGER [INSERT_BAG_ERROR]
END
PRINT 'INFO: Creating trigger [INSERT_BAG_ERROR]...'
GO
CREATE TRIGGER [dbo].[INSERT_BAG_ERROR] ON [dbo].[BAG_ERROR_BSM] 
AFTER INSERT
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_BIS_MONITOR';
END



---- ****** Object:  Trigger [INSERT_FLIGHT_PLANS]    Script Date: 10/08/2007 13:18:36 ******
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_FLIGHT_PLANS]'))
--BEGIN
--	PRINT 'INFO: Deleting existing trigger [INSERT_FLIGHT_PLANS]...'
--	DROP TRIGGER [INSERT_FLIGHT_PLANS]
--END
--PRINT 'INFO: Creating trigger [INSERT_FLIGHT_PLANS]...'
--GO
--CREATE TRIGGER [dbo].[INSERT_FLIGHT_PLANS] ON [dbo].[FLIGHT_PLANS] 
--AFTER INSERT
--AS
--BEGIN
--	-- Verify [ACTION] field value of inserted record:
--	-- ADD - add in new BSM, UPD - Update existing BSM, DEL - Delete existing BSM
--    DECLARE @ACTION [varchar](10), @AIRLINE [varchar](3), @FLIGHT_NUMBER [varchar](5), 
--			@FLIGHT_NUMBER_SUFFIX [varchar](3),	@SDO [varchar](8), @HANDLER [varchar](20), 
--			@STO [varchar](14), @ETO [varchar](14), @ITO [varchar](14), @ATO [varchar](14),
--			@BLOCK_OFF_TIME [varchar](14), @FINAL_DEST [varchar](3), @DEST1 [varchar](3),
--			@DEST2 [varchar](3), @DEST3 [varchar](3), @DEST4 [varchar](3), @DEST5 [varchar](3), 
--			@CANCELLED [varchar](1), @AIRCRAFT_TYPE [varchar](4),@HANDLER_SPECIFIC_DESC [varchar](12), 
--			@AIRCRAFT_VERSION [varchar](12), @TERMINAL [varchar](5), @CHECKIN_AREA [varchar](10), 
--			@CHECKIN_STATUS [varchar](10),@PUBLIC_REMARK_CODE [varchar](10), @PIER [varchar] (5), 
--			@GATE [varchar](10), @PARKING_STAND [varchar](5), @NATURE [varchar](15), 
--			@SORTING_DEST [varchar](10), @GENERAL_PURPOSE [varchar](40), @FI_EXCEPTION [varchar](10), 
--			@MASTER_AIRLINE [varchar](3), @MASTER_FLIGHT_NUMBER [varchar](5), @MASTER_FLIGHT_NUMBER_SUFFIX [varchar](3),
--			@MASTER_SDO [varchar](8), @TIME_STAMP [datetime], @CREATED_BY [varchar](15); 
			
--	SELECT  @ACTION=[ACTION], @AIRLINE=[AIRLINE], @FLIGHT_NUMBER=[FLIGHT_NUMBER], 
--			@FLIGHT_NUMBER_SUFFIX = [FLIGHT_NUMBER_SUFFIX], @SDO=[SDO], @HANDLER=[HANDLER],
--			@STO=[STO], @ETO=[ETO], @ITO=[ITO], @ATO=[ATO],
--			@BLOCK_OFF_TIME = [BLOCK_OFF_TIME], @FINAL_DEST=[FINAL_DEST], @DEST1=[DEST1], 
--			@DEST2=[DEST2], @DEST3=[DEST3], @DEST4=[DEST4], @DEST5=[DEST5],
--			@CANCELLED=[CANCELLED], @AIRCRAFT_TYPE=[AIRCRAFT_TYPE], @HANDLER_SPECIFIC_DESC=[HANDLER_SPECIFIC_DESC],
--			@AIRCRAFT_VERSION=[AIRCRAFT_VERSION], @TERMINAL=[TERMINAL], @CHECKIN_AREA=[CHECKIN_AREA], 
--			@CHECKIN_STATUS=[CHECKIN_STATUS], @PUBLIC_REMARK_CODE=[PUBLIC_REMARK_CODE], @PIER=[PIER],
--			@GATE=[GATE], @PARKING_STAND=[PARKING_STAND], @NATURE=[GEORGRAPHICAL_NATURE],
--			@SORTING_DEST=[SORTING_DEST], @GENERAL_PURPOSE=[GENERAL_PURPOSE], @FI_EXCEPTION=[FI_EXCEPTION],
--			@MASTER_AIRLINE=[MASTER_AIRLINE], @MASTER_FLIGHT_NUMBER=[MASTER_FLIGHT_NUMBER], 
--			@MASTER_FLIGHT_NUMBER_SUFFIX=[MASTER_FLIGHT_NUMBER_SUFFIX], @MASTER_SDO=[MASTER_SDO],
--			@TIME_STAMP=[TIME_STAMP], @CREATED_BY=[CREATED_BY]
--	FROM INSERTED;
	
--	--IF LEN(LTRIM(RTRIM(@EDO)))=0 OR (@EDO IS NULL) --Convert "No NULL" and space only string field value to NULL
--	--	SET @EDO=@SDO;
--	--IF LEN(LTRIM(RTRIM(@ETO)))=0 OR (@ETO IS NULL) --Convert "No NULL" and space only string field value to NULL
--	--	SET @ETO=@STO;
--	--IF LEN(LTRIM(RTRIM(@ADO)))=0 OR (@ADO IS NULL) --Convert "No NULL" and space only string field value to NULL
--	--	SET @ADO=@SDO;
--	--IF LEN(LTRIM(RTRIM(@ATO)))=0 OR (@ATO IS NULL) --Convert "No NULL" and space only string field value to NULL
--	--	SET @ATO=@STO;
--	--IF LEN(LTRIM(RTRIM(@IDO)))=0 OR (@IDO IS NULL) --Convert "No NULL" and space only string field value to NULL
--	--	SET @IDO=@SDO;
--	--IF LEN(LTRIM(RTRIM(@ITO)))=0 OR (@ITO IS NULL) --Convert "No NULL" and space only string field value to NULL
--	--	SET @ITO=@STO;
	
--	DECLARE @HOUR_STO VARCHAR(2) = SUBSTRING(@STO,9,2)
--	DECLARE @MINS_STO VARCHAR(2) = SUBSTRING(@STO,11,2)
--	DECLARE @SECS_STO VARCHAR(2) = SUBSTRING(@STO,13,2)	
--	DECLARE @TIME_STO VARCHAR(14) = @HOUR_STO + ':' + @MINS_STO + ':' + @SECS_STO
--	DECLARE @DATE_STO DATETIME = CONVERT (varchar(8),@STO,112)
	
--	DECLARE @HOUR_ETO VARCHAR(2) = SUBSTRING(@ETO,9,2)
--	DECLARE @MINS_ETO VARCHAR(2) = SUBSTRING(@ETO,11,2)
--	DECLARE @SECS_ETO VARCHAR(2) = SUBSTRING(@ETO,13,2)	
--	DECLARE @TIME_ETO VARCHAR(14) = @HOUR_STO + ':' + @MINS_STO + ':' + @SECS_STO
--	DECLARE @DATE_ETO DATETIME = CONVERT (varchar(8),@ETO,112)
	
--	DECLARE @HOUR_ATO VARCHAR(2) = SUBSTRING(@ATO,9,2)
--	DECLARE @MINS_ATO VARCHAR(2) = SUBSTRING(@ATO,11,2)
--	DECLARE @SECS_ATO VARCHAR(2) = SUBSTRING(@ATO,13,2)	
--	DECLARE @TIME_ATO VARCHAR(14) = @HOUR_ATO + ':' + @MINS_ATO + ':' + @SECS_ATO
--	DECLARE @DATE_ATO DATETIME = CONVERT (varchar(8),@ATO,112)
	
--	DECLARE @HOUR_ITO VARCHAR(2) = SUBSTRING(@ITO,9,2)
--	DECLARE @MINS_ITO VARCHAR(2) = SUBSTRING(@ITO,11,2)
--	DECLARE @SECS_ITO VARCHAR(2) = SUBSTRING(@ITO,13,2)	
--	DECLARE @TIME_ITO VARCHAR(14) = @HOUR_ITO + ':' + @MINS_ITO + ':' + @SECS_ITO
--	DECLARE @DATE_ITO DATETIME = CONVERT (varchar(8),@ITO,112)
	
--	SET DATEFIRST 1
--	DECLARE @WEEKDAY CHAR(1) = (SELECT CAST(DATEPART(weekday, (@DATE_STO + CONVERT (varchar(8),@TIME_STO,108))) AS CHAR(1)))
	
--	--DECLARE @SDO_DATETIME datetime = (@DATE_STO + CONVERT (varchar(8),@TIME_STO,108))
	
--	DECLARE @HIGH_RISK CHAR(1)
--	IF @FI_EXCEPTION ='RISK'
--	BEGIN
--		SET @HIGH_RISK = 'Y'
--	END
--	ELSE
--	BEGIN
--		SET @HIGH_RISK = 'N'
--	END	
	
--	IF @ACTION = 'NEW'
--	BEGIN
--		INSERT INTO [FLIGHT_PLAN_SORTING] (
--			[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[ADO],[ATO],[IDO],[ITO],
--            [AIRCRAFT_TYPE],[AIRCRAFT_VERSION],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
--            [HIGH_RISK],[CANCELLED],[TERMINAL],[GATE],
--            [NATURE],[HANDLER],
--            [FINAL_DEST],[DEST1],[DEST2],[DEST3],[DEST4],[DEST5], [SORTING_DEST1],
--            [CHECKIN_AREA], [PIER],
--            [TIME_STAMP],[CREATED_BY],[FI_EXCEPTION],[IS_ALLOCATED],[WEEKDAY])
--		VALUES ( 
--			@AIRLINE, @FLIGHT_NUMBER, @DATE_STO, 
--			@HOUR_STO + @MINS_STO, @DATE_ETO , 
--			@HOUR_ETO + @MINS_ETO, @DATE_ATO , 
--			@HOUR_ATO + @MINS_ATO, @DATE_ITO , 
--			@HOUR_ITO + @MINS_ITO, @AIRCRAFT_TYPE, @AIRCRAFT_VERSION, @MASTER_AIRLINE, 
--			@MASTER_FLIGHT_NUMBER, @HIGH_RISK, @CANCELLED, @TERMINAL, @GATE, @NATURE,
--			@HANDLER, @FINAL_DEST, @DEST1, @DEST2, @DEST3, @DEST4, @DEST5, @SORTING_DEST, 
--		    @CHECKIN_AREA, @PIER, @TIME_STAMP, @CREATED_BY, @FI_EXCEPTION, 0, @WEEKDAY);
--	END
	
--	IF @ACTION = 'UPD'
--	BEGIN
--		UPDATE [FLIGHT_PLAN_SORTING] SET 
--			AIRLINE=@AIRLINE, FLIGHT_NUMBER=@FLIGHT_NUMBER, SDO=@DATE_STO, 
--			STO=@HOUR_STO + @MINS_STO, EDO=@DATE_ETO , 
--			ETO=@HOUR_ETO + @MINS_ETO, ADO=@DATE_ATO , 
--			ATO=@HOUR_ATO + @MINS_ATO, IDO=@DATE_ITO , 
--			ITO=@HOUR_ITO + @MINS_ITO, AIRCRAFT_TYPE=@AIRCRAFT_TYPE, AIRCRAFT_VERSION=@AIRCRAFT_VERSION, 
--			MASTER_AIRLINE=@MASTER_AIRLINE, MASTER_FLIGHT_NUMBER=@MASTER_FLIGHT_NUMBER, 
--			HIGH_RISK=@HIGH_RISK, CANCELLED=@CANCELLED, TERMINAL=@TERMINAL, GATE=@GATE, 
--			NATURE=@NATURE, HANDLER=@HANDLER,
--		    FINAL_DEST=@FINAL_DEST, DEST1=@DEST1, DEST2=@DEST2, DEST3=@DEST3, 
--		    DEST4=@DEST4, DEST5=@DEST5, SORTING_DEST1=@SORTING_DEST, 
--		    CHECKIN_AREA=@CHECKIN_AREA, PIER=@PIER,
--		    TIME_STAMP=@TIME_STAMP, CREATED_BY=@CREATED_BY, FI_EXCEPTION=@FI_EXCEPTION, [WEEKDAY]=@WEEKDAY
--		WHERE 
--			AIRLINE = @AIRLINE AND FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = CONVERT (varchar(8),@SDO,112);
--	END
	
--	IF @ACTION = 'DEL'
--	BEGIN
--		DELETE FROM [FLIGHT_PLAN_SORTING] WHERE 
--			AIRLINE = @AIRLINE AND FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = CONVERT (varchar(8),@SDO,112);
--	END
	
--	DECLARE @EARLY_OPEN_OFFSET varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ERLY_OPEN_OFFSET')
--	DECLARE @EARLY_OPEN_ENABLED varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ERLY_OPEN_ENABLED')
--	DECLARE @ALLOC_OPEN_OFFSET varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ALLOC_OPEN_OFFSET')
--	DECLARE @ALLOC_OPEN_RELATED varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ALLOC_OPEN_RELATED')
--	DECLARE @ALLOC_CLOSE_OFFSET varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ALLOC_CLOSE_OFFSET')
--	DECLARE @ALLOC_CLOSE_RELATED varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ALLOC_CLOSE_RELATED')
--	DECLARE @RUSH_DURATION varchar(15) = ('00'+(SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'RUSH_DURATION'))


--	IF @PIER != NULL OR @PIER != ''
--	BEGIN
--		DECLARE @COUNT int = (SELECT COUNT(*) FROM [BHSDB].[dbo].[FLIGHT_PLAN_ALLOC] 
--								WHERE [AIRLINE] = @AIRLINE AND [FLIGHT_NUMBER] = @FLIGHT_NUMBER AND [SDO] = @DATE_STO )
--		--print 'Number of record = ' + cast(@COUNT as varchar(10))
--		IF @COUNT = 0
--		BEGIN
--		INSERT INTO [BHSDB].[dbo].[FLIGHT_PLAN_ALLOC]
--				   ([AIRLINE], [FLIGHT_NUMBER], [SDO], 
--				   [STO], [RESOURCE], [WEEKDAY],
--				   [EDO], [ETO], 
--				   [ADO], [ATO], 
--				   [IDO], [ITO], 
--				   [EARLY_OPEN_OFFSET], [EARLY_OPEN_ENABLED], [ALLOC_OPEN_OFFSET], [ALLOC_OPEN_RELATED],
--				   [ALLOC_CLOSE_OFFSET], [ALLOC_CLOSE_RELATED], [RUSH_DURATION], [CREATED_BY], [TIME_STAMP])
--			 VALUES
--					(@AIRLINE, @FLIGHT_NUMBER, CONVERT (varchar(8),@SDO,112),
--					(@HOUR_STO + @MINS_STO), @PIER, @WEEKDAY,
--					(@DATE_ETO ), (@HOUR_ETO + @MINS_ETO),
--					(@DATE_ATO ), (@HOUR_ATO + @MINS_ATO), 
--					(@DATE_ITO ), (@HOUR_ITO + @MINS_ITO), 
--					@EARLY_OPEN_OFFSET, @EARLY_OPEN_ENABLED, @ALLOC_OPEN_OFFSET, @ALLOC_OPEN_RELATED, 
--					@ALLOC_CLOSE_OFFSET, @ALLOC_CLOSE_RELATED, @RUSH_DURATION, 'FIS', @TIME_STAMP) 
--		END	
--		ELSE
--		BEGIN
--			UPDATE [BHSDB].[dbo].[FLIGHT_PLAN_ALLOC]
--			   SET [STO] = (@HOUR_STO + @MINS_STO), [RESOURCE] = @PIER, [WEEKDAY] = @WEEKDAY
--				  , [EDO] = @DATE_ETO, [ETO] = (@HOUR_ETO + @MINS_ETO), [ADO] = @DATE_ATO
--				  , [ATO] = (@HOUR_ATO + @MINS_ATO), [IDO] = @DATE_ITO, [ITO] = (@HOUR_ITO + @MINS_ITO)
--				  , [CREATED_BY] = 'FIS', [TIME_STAMP] = @TIME_STAMP
--			 WHERE [AIRLINE] = @AIRLINE AND [FLIGHT_NUMBER] = @FLIGHT_NUMBER AND [SDO] = CONVERT (varchar(8),@SDO,112)
--		END					 
--     END
--END
--GO

-- ****** Object:  Trigger [INSERT_FLIGHT_PLAN_ERROR]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_FLIGHT_PLAN_ERROR]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_FLIGHT_PLAN_ERROR]...'
	DROP TRIGGER [INSERT_FLIGHT_PLAN_ERROR]
END
PRINT 'INFO: Creating trigger [INSERT_FLIGHT_PLAN_ERROR]...'
GO
CREATE TRIGGER [dbo].[INSERT_FLIGHT_PLAN_ERROR] ON [dbo].[FLIGHT_PLAN_ERROR] 
AFTER INSERT
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_FIDS_MONITOR';
END


-- ****** Object:  Trigger [INSERT_FLIGHT_PLAN_SORTING]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_FLIGHT_PLAN_SORTING]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_FLIGHT_PLAN_SORTING]...'
	DROP TRIGGER [INSERT_FLIGHT_PLAN_SORTING]
END
PRINT 'INFO: Creating trigger [INSERT_FLIGHT_PLAN_SORTING]...'
GO
CREATE TRIGGER [dbo].[INSERT_FLIGHT_PLAN_SORTING] ON [dbo].[FLIGHT_PLAN_SORTING] 
AFTER INSERT
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_FLIGHT_PLAN_SORTING';

	--Add query for template
	Declare @AL varchar(3);
	Declare @FN varchar(5);
	Declare @SDO datetime;
	Declare @Resource varchar(10);
	Declare @Count int;

	SELECT @AL=a.AIRLINE,@FN=a.FLIGHT_NUMBER,@SDO=a.SDO,@Resource=t.RESOURCE
		FROM INSERTED a, dbo.TEMPLATE_ASSIGNMENTS ta, dbo.TEMPLATE_FLIGHT_PLAN_ALLOC t
		WHERE
			a.SDO=ta.PRODUCTION_DATE AND
			a.AIRLINE=t.AIRLINE AND
			a.FLIGHT_NUMBER=t.FLIGHT_NUMBER AND
			t.TEMPLATE_ID=ta.TEMPLATE_ID;
	
	SELECT @Count=ISNULL(Count(Flight_Number),0) 
		FROM FLIGHT_PLAN_ALLOC
		WHERE AirLine=@AL AND Flight_Number=@FN AND SDO=@SDO AND Resource=@Resource;
	
	IF(@Count=0)	 	
	BEGIN Try
		INSERT INTO dbo.FLIGHT_PLAN_ALLOC (
				AIRLINE,FLIGHT_NUMBER,SDO,STO,RESOURCE,WEEKDAY,EDO,ETO,
				ADO,ATO,IDO,ITO,TRAVEL_CLASS,HIGH_RISK,HBS_LEVEL_REQUIRED,ALLOC_OPEN_OFFSET,
				ALLOC_OPEN_RELATED,ALLOC_CLOSE_OFFSET,ALLOC_CLOSE_RELATED,RUSH_DURATION,
				SCHEME_TYPE,CREATED_BY,TIME_STAMP,HOUR) 
			SELECT a.AIRLINE,a.FLIGHT_NUMBER,a.SDO,a.STO,t.RESOURCE,t.WEEKDAY,a.EDO,a.ETO,
				a.ADO,a.ATO,a.IDO,a.ITO,'*',a.HIGH_RISK,a.HBS_LEVEL_REQUIRED,t.ALLOC_OPEN_OFFSET,
				t.ALLOC_OPEN_RELATED,t.ALLOC_CLOSE_OFFSET,t.ALLOC_CLOSE_RELATED,t.RUSH_DURATION,
				t.SCHEME_TYPE,t.CREATED_BY,GETDATE(),t.HOUR
			FROM INSERTED a, dbo.TEMPLATE_ASSIGNMENTS ta,dbo.TEMPLATE_FLIGHT_PLAN_ALLOC t
			WHERE
				a.SDO=ta.PRODUCTION_DATE AND
				a.AIRLINE=t.AIRLINE AND
				a.FLIGHT_NUMBER=t.FLIGHT_NUMBER AND
				t.TEMPLATE_ID=ta.TEMPLATE_ID;
	END Try
	BEGIN CATCH
		--Print @@Error
	END CATCH
END	
GO


-- ****** Object:  Trigger [UPDATE_FLIGHT_PLAN_SORTING]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_FLIGHT_PLAN_SORTING]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_FLIGHT_PLAN_SORTING]...'
	DROP TRIGGER UPDATE_FLIGHT_PLAN_SORTING
END
PRINT 'INFO: Creating trigger [UPDATE_FLIGHT_PLAN_SORTING]...'
GO
CREATE TRIGGER [dbo].[UPDATE_FLIGHT_PLAN_SORTING] ON [dbo].[FLIGHT_PLAN_SORTING] 
AFTER UPDATE
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_FLIGHT_PLAN_SORTING';

    DECLARE @AIRLINE [varchar](3), @FLIGHT_NUMBER [varchar](5), 
			@SDO [datetime], @STO [varchar](4), @EDO [datetime], @ETO [varchar](4),
			@ADO [datetime], @ATO [varchar](4), @IDO [datetime], @ITO [varchar](4),
			@WEEKDAY [varchar](1), @HOUR [varchar](10); 
			
	SELECT  @AIRLINE=[AIRLINE], @FLIGHT_NUMBER=[FLIGHT_NUMBER],
			@SDO=[SDO], @STO=[STO], @EDO=[EDO], @ETO=[ETO], 
			@ADO=[ADO], @ATO=[ATO], @IDO=[IDO], @ITO=[ITO], 
			@WEEKDAY=[WEEKDAY], @HOUR=[HOUR]
	FROM INSERTED;

	UPDATE FLIGHT_PLAN_ALLOC SET
		STO = @STO, EDO = @EDO, ETO = @ETO, ADO = @ADO, ATO = @ATO, IDO = @IDO, 
		ITO = @ITO, WEEKDAY = @WEEKDAY,  HOUR = @HOUR 
	WHERE 
		AIRLINE = @AIRLINE AND FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDO;
END
GO



-- ****** Object:  Trigger [DELETE_FLIGHT_PLAN_SORTING]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_FLIGHT_PLAN_SORTING]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_FLIGHT_PLAN_SORTING]...'
	DROP TRIGGER [DELETE_FLIGHT_PLAN_SORTING]
END
PRINT 'INFO: Creating trigger [DELETE_FLIGHT_PLAN_SORTING]...'
GO
CREATE TRIGGER [dbo].[DELETE_FLIGHT_PLAN_SORTING] ON [dbo].[FLIGHT_PLAN_SORTING] 
AFTER DELETE
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_FLIGHT_PLAN_SORTING';

	BEGIN TRY
		DECLARE @AIRLINE [varchar](3), @FLIGHT_NUMBER [varchar](5), @SDO [datetime]; 
				
		SELECT @AIRLINE=[AIRLINE], @FLIGHT_NUMBER=[FLIGHT_NUMBER], @SDO=[SDO] FROM DELETED;
		
		DELETE FROM FLIGHT_PLAN_ALLOC 
				WHERE 1=1 AND SDO=@SDO AND AIRLINE=@AIRLINE AND FLIGHT_NUMBER=@FLIGHT_NUMBER;
	END TRY
	BEGIN CATCH
		-- Print @@Error 
	END CATCH
END
GO



-- ****** Object:  Trigger [INSERT_FLIGHT_PLAN_ALLOC]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_FLIGHT_PLAN_ALLOC]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_FLIGHT_PLAN_ALLOC]...'
	DROP TRIGGER [INSERT_FLIGHT_PLAN_ALLOC]
END
PRINT 'INFO: Creating trigger [INSERT_FLIGHT_PLAN_ALLOC]...'
GO
CREATE  TRIGGER [dbo].[INSERT_FLIGHT_PLAN_ALLOC] ON [dbo].[FLIGHT_PLAN_ALLOC] 
AFTER INSERT
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_FLIGHT_PLAN_ALLOC';

	DECLARE @AIRLINE [varchar](3), @FLIGHT_NUMBER [varchar](5), @SDO [datetime]; 
	DECLARE INS_Cursor CURSOR FOR SELECT [AIRLINE],[FLIGHT_NUMBER],[SDO] FROM INSERTED;
	
	OPEN INS_Cursor;
    FETCH NEXT FROM INS_Cursor INTO @AIRLINE, @FLIGHT_NUMBER, @SDO;
    WHILE @@FETCH_STATUS = 0
    BEGIN
		UPDATE [dbo].[FLIGHT_PLAN_SORTING] SET [IS_ALLOCATED]=1 
			WHERE [AIRLINE]=@AIRLINE AND [FLIGHT_NUMBER]=@FLIGHT_NUMBER AND [SDO]=@SDO;

		FETCH NEXT FROM INS_Cursor INTO @AIRLINE, @FLIGHT_NUMBER, @SDO;
	END;

	CLOSE INS_Cursor;
	DEALLOCATE INS_Cursor;
-------------------------------------------------------------------------------------------------------------------------
	--Protect EDO,ADO,IDO null value problem.
	Declare @Close_Related varchar(4),@Open_Related varchar(4)
	Declare @Close_Do datetime ,@Open_Do datetime
	Declare @Resource varchar(10),@Close_Offset varchar(5)

	SELECT @Close_Related=ALLOC_CLOSE_RELATED,@Open_Related=ALLOC_OPEN_RELATED,
		@Airline=AIRLINE,@Flight_Number=FLIGHT_NUMBER,
		@SDO=SDO,@Resource=RESOURCE,@Close_Offset=ALLOC_CLOSE_OFFSET
		FROM INSERTED;

	--ALLOC_CLOSE_RELATED
	IF(RTRIM(LTRIM(@Close_Related))='STD')
		SELECT @Close_Do=SDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ETD')
		SELECT @Close_Do=EDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ITD')
		SELECT @Close_Do=IDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ATD')
		SELECT @Close_Do=ADO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	IF(@Close_Do IS NULL)
	Begin
		UPDATE [dbo].[FLIGHT_PLAN_ALLOC] SET ALLOC_CLOSE_RELATED='STD'
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO;
	End

	--ALLOC_OPEN_RELATED
	IF(RTRIM(LTRIM(@Open_Related))='STD')
		SELECT @Open_Do=SDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Open_Related))='ETD')
		SELECT @Open_Do=EDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Open_Related))='ITD')
		SELECT @Open_Do=IDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Open_Related))='ATD')
		SELECT @Open_Do=ADO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	IF(@Open_Do IS NULL)
	Begin
		UPDATE [dbo].[FLIGHT_PLAN_ALLOC] SET ALLOC_OPEN_RELATED='STD'
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO;
	End
END
GO



-- ****** Object:  Trigger [UPDATE_FLIGHT_PLAN_ALLOC]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_FLIGHT_PLAN_ALLOC]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_FLIGHT_PLAN_ALLOC]...'
	DROP TRIGGER [UPDATE_FLIGHT_PLAN_ALLOC]
END
PRINT 'INFO: Creating trigger [UPDATE_FLIGHT_PLAN_ALLOC]...'
GO
CREATE  TRIGGER [dbo].[UPDATE_FLIGHT_PLAN_ALLOC] ON [dbo].[FLIGHT_PLAN_ALLOC] 
AFTER UPDATE
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_FLIGHT_PLAN_ALLOC';

/*
	--Prevent ADO,EDO,IDO null value problem
	Declare @PAirline varchar(3),@PFlight_Number varchar(5),@PSDO datetime;
	SELECT @PAirline=AIRLINE,@PFlight_Number=FLIGHT_NUMBER,@PSDO=SDO FROM INSERTED;
	Exec [dbo].[stp_SAC_TDDATEMANAGER] @PAirline,@PFlight_Number,@PSDO
*/
--------------------------------------------------------------------------------------------------------------
	--Protect EDO,ADO,IDO null value problem.
	Declare @Close_Related varchar(4),@Open_Related varchar(4)
	Declare @Close_Do datetime ,@Open_Do datetime
	Declare @Airline varchar(3),@Flight_Number varchar(5),@SDO datetime,@Resource varchar(10),@Close_Offset varchar(5)

	SELECT @Close_Related=ALLOC_CLOSE_RELATED,@Open_Related=ALLOC_OPEN_RELATED,
		@Airline=AIRLINE,@Flight_Number=FLIGHT_NUMBER,
		@SDO=SDO,@Resource=RESOURCE,@Close_Offset=ALLOC_CLOSE_OFFSET
		FROM INSERTED;

	--ALLOC_CLOSE_RELATED
	IF(RTRIM(LTRIM(@Close_Related))='STD')
		SELECT @Close_Do=SDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ETD')
		SELECT @Close_Do=EDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ITD')
		SELECT @Close_Do=IDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ATD')
		SELECT @Close_Do=ADO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	IF(@Close_Do IS NULL)
	Begin
		UPDATE [dbo].[FLIGHT_PLAN_ALLOC] SET ALLOC_CLOSE_RELATED='STD'
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO;
	End

	--ALLOC_OPEN_RELATED
	IF(RTRIM(LTRIM(@Open_Related))='STD')
		SELECT @Open_Do=SDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Open_Related))='ETD')
		SELECT @Open_Do=EDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Open_Related))='ITD')
		SELECT @Open_Do=IDO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	ELSE IF(RTRIM(LTRIM(@Open_Related))='ATD')
		SELECT @Open_Do=ADO FROM [dbo].[FLIGHT_PLAN_ALLOC] 
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO AND RESOURCE=@Resource;
	IF(@Open_Do IS NULL)
	Begin
		UPDATE [dbo].[FLIGHT_PLAN_ALLOC] SET ALLOC_OPEN_RELATED='STD'
		WHERE AIRLINE=@Airline AND FLIGHT_NUMBER=@Flight_Number
		AND SDO=@SDO;
	End
END
GO



-- ****** Object:  Trigger [DELETE_FLIGHT_PLAN_ALLOC]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_FLIGHT_PLAN_ALLOC]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_FLIGHT_PLAN_ALLOC]...'
	DROP TRIGGER [DELETE_FLIGHT_PLAN_ALLOC]
END
PRINT 'INFO: Creating trigger [DELETE_FLIGHT_PLAN_ALLOC]...'
GO
CREATE  TRIGGER [dbo].[DELETE_FLIGHT_PLAN_ALLOC] ON [dbo].[FLIGHT_PLAN_ALLOC] 
AFTER DELETE
AS
BEGIN
	-- Please be Noted: The actual records has been deleted from the table before this DELETE trigger is fired. 
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_FLIGHT_PLAN_ALLOC'
	OR [STATE_CODE] = 'TB_FLIGHT_PLAN_SORTING'

	-- The cursor has to be used in order to verify every records in the group deleting.
	DECLARE	@No int;
	DECLARE @AIRLINE [varchar](3), @FLIGHT_NUMBER [varchar](5), @SDO [datetime]; 
	DECLARE DEL_Cursor CURSOR FOR SELECT [AIRLINE],[FLIGHT_NUMBER],[SDO] FROM DELETED;
	
	OPEN DEL_Cursor;
    FETCH NEXT FROM DEL_Cursor INTO @AIRLINE, @FLIGHT_NUMBER, @SDO;
    WHILE @@FETCH_STATUS = 0
    BEGIN
		SET @No = 0;
		SET @No = (SELECT Count(*) FROM [dbo].[FLIGHT_PLAN_ALLOC] 
						WHERE [AIRLINE]=@AIRLINE AND [FLIGHT_NUMBER]=@FLIGHT_NUMBER AND [SDO]=@SDO);

		IF @No = 0
		BEGIN
			UPDATE [dbo].[FLIGHT_PLAN_SORTING] SET [IS_ALLOCATED]=0 
				WHERE [AIRLINE]=@AIRLINE AND [FLIGHT_NUMBER]=@FLIGHT_NUMBER AND [SDO]=@SDO;
		END;

		FETCH NEXT FROM DEL_Cursor INTO @AIRLINE, @FLIGHT_NUMBER, @SDO;
	END;
	CLOSE DEL_Cursor;
	DEALLOCATE DEL_Cursor;
END
GO



-- ****** Object:  Trigger [INSERT_FUNCTION_ALLOC_GANTT]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_FUNCTION_ALLOC_GANTT]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_FUNCTION_ALLOC_GANTT]...'
	DROP TRIGGER [INSERT_FUNCTION_ALLOC_GANTT]
END
PRINT 'INFO: Creating trigger [INSERT_FUNCTION_ALLOC_GANTT]...'
GO
CREATE TRIGGER [INSERT_FUNCTION_ALLOC_GANTT] ON [dbo].[FUNCTION_ALLOC_GANTT]
AFTER INSERT
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_FUNCTION_ALLOC';
	
	DECLARE @FuncType Varchar(4);
	SELECT @FuncType=FUNCTION_TYPE FROM INSERTED;

	UPDATE [dbo].[FUNCTION_TYPES] SET [IS_ALLOCATED] = 1 WHERE [TYPE] = @FuncType;

	INSERT INTO [AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP, CURRENT_USER, 'INS', 'FUNCTION_ALLOC_GANTT',
			'FUNCTION_TYPE=' + FUNCTION_TYPE + ', RESOURCE=' + RESOURCE + 
			', ALLOC_OPEN_DATETIME=' + CONVERT(varchar(20),ALLOC_OPEN_DATETIME) +
			', ALLOC_CLOSE_DATETIME=' + CONVERT(varchar(20),ALLOC_CLOSE_DATETIME)
		FROM INSERTED;
		
	INSERT INTO [BHSDB].[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
			   ([ALLOC_TYPE]
			   ,[ACTION]
			   ,[FUNCTION_TYPE], [FUNCTION_DATA]
			   ,[RESOURCE]
			   )
	SELECT 'FUN', 'NEW', [FUNCTION_TYPE], [EXCEPTION]
		  ,[RESOURCE]
	  FROM INSERTED;		
END
GO




/****** Object:  Trigger [dbo].[UPDATE_FUNCTION_ALLOC_GANTT]   Script Date: 01/18/2010 14:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_FUNCTION_ALLOC_GANTT]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_FUNCTION_ALLOC_GANTT]...'
	DROP TRIGGER [UPDATE_FUNCTION_ALLOC_GANTT]
END
PRINT 'INFO: Creating trigger [UPDATE_FUNCTION_ALLOC_GANTT]...'
GO
CREATE  TRIGGER [dbo].[UPDATE_FUNCTION_ALLOC_GANTT] ON [dbo].[FUNCTION_ALLOC_GANTT] 
AFTER UPDATE
AS
BEGIN
	-- WHEN TREAT IS CLOSED FUNCTION ALLOCATION AS DELETED ALLOCATION - 1
	-- WHEN TREAT IS CLOSED FUNCTION ALLOCATION NOT AS DELETED ALLOCATION - 0	
	DECLARE @IS_ENABLE_IS_CLOSE_AS_DEL BIT = 0
	
	--Monitor
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_FUNCTION_ALLOC';
	
	IF @IS_ENABLE_IS_CLOSE_AS_DEL = 1
	BEGIN
			-- FOR DATA WHICH NEED TO SEND TO FIS--	
		INSERT INTO [BHSDB].[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
				   ([ALLOC_TYPE]
				   ,[ACTION]
				   ,[FUNCTION_TYPE], [FUNCTION_DATA]
				   ,[RESOURCE]
				   )			   
		SELECT 'FUN', 'UPD', [FUNCTION_TYPE], [EXCEPTION]
			  ,[RESOURCE]
		  FROM INSERTED WHERE [ALLOC_OPEN_DATETIME] != [ALLOC_CLOSE_DATETIME] AND IS_CLOSED = 0
		  
			-- FOR DATA WHICH NEED TO SEND TO FIS--	
		INSERT INTO [BHSDB].[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
				   ([ALLOC_TYPE]
				   ,[ACTION]
				   ,[FUNCTION_TYPE], [FUNCTION_DATA]
				   ,[RESOURCE]
				   )
		SELECT 'FUN', 'DEL', [FUNCTION_TYPE], [EXCEPTION]
			  ,[RESOURCE]
		  FROM INSERTED WHERE [ALLOC_OPEN_DATETIME] != [ALLOC_CLOSE_DATETIME] AND IS_CLOSED = 1	  
	END
	ELSE
	BEGIN
			-- FOR DATA WHICH NEED TO SEND TO FIS--	
		INSERT INTO [BHSDB].[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
				   ([ALLOC_TYPE]
				   ,[ACTION]
				   ,[FUNCTION_TYPE], [FUNCTION_DATA]
				   ,[RESOURCE], [FUNCTION_IS_CLOSED]
				   )			   
		SELECT 'FUN', 'UPD', [FUNCTION_TYPE], [EXCEPTION], 
			  [RESOURCE], [IS_CLOSED]
		  FROM INSERTED WHERE [ALLOC_OPEN_DATETIME] != [ALLOC_CLOSE_DATETIME] 	
	END

	--Fault State(immediate open, immediate close)
	DELETE FROM [dbo].[FUNCTION_ALLOC_GANTT] WHERE [ALLOC_OPEN_DATETIME] = [ALLOC_CLOSE_DATETIME];

	--UPDATE specific function type [IS_ALLOCATED] field value in the table [FUNCTION_TYPES]
	DECLARE @Count int;
	DECLARE @NOW datetime;
	DECLARE @FuncType Varchar(4);
	
	SELECT @FuncType=FUNCTION_TYPE FROM INSERTED;
	SET @Now=DATEADD(ss,-datepart(ss,getdate()),getdate());
	
	SELECT @COUNT=COUNT(FUNCTION_TYPE) FROM FUNCTION_ALLOC_GANTT 
		WHERE ALLOC_CLOSE_DATETIME > @NOW AND FUNCTION_TYPE = @FuncType;
	
	IF @Count>0 
	BEGIN
		UPDATE dbo.FUNCTION_TYPES SET IS_ALLOCATED=1 WHERE [TYPE]=@FuncType;
	END
	ELSE
	BEGIN
		UPDATE dbo.FUNCTION_TYPES SET IS_ALLOCATED=0 WHERE [TYPE]=@FuncType;
	END

	--Record "UPD" event of [FUNCTION_ALLOC_GANTT] into table [AUDIT_LOG]
	INSERT INTO [AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP, CURRENT_USER, 'UPD', 'FUNCTION_ALLOC_GANTT',
			'FUNCTION_TYPE=' + FUNCTION_TYPE + ', RESOURCE=' + RESOURCE + 
			', ALLOC_OPEN_DATETIME=' + CONVERT(varchar(20),ALLOC_OPEN_DATETIME) +
			', ALLOC_CLOSE_DATETIME=' + CONVERT(varchar(20),ALLOC_CLOSE_DATETIME)
		FROM INSERTED;
		    
END
GO


-- ****** Object:  Trigger [DELETE_FUNCTION_ALLOC_GANTT]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_FUNCTION_ALLOC_GANTT]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_FUNCTION_ALLOC_GANTT]...'
	DROP TRIGGER [DELETE_FUNCTION_ALLOC_GANTT]
END
PRINT 'INFO: Creating trigger [DELETE_FUNCTION_ALLOC_GANTT]...'
GO
CREATE  TRIGGER [DELETE_FUNCTION_ALLOC_GANTT] ON [dbo].[FUNCTION_ALLOC_GANTT]
AFTER DELETE
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_FUNCTION_ALLOC';

	DECLARE @funcType Varchar(4);
	DECLARE @funcAliveCount int;
	DECLARE @NOW datetime;
	
	SET @Now=dateadd(ss,-datepart(ss,getdate()),getdate());
	SELECT @funcType=FUNCTION_TYPE FROM DELETED;
	
	--Still Alivecount in RT
	SELECT @funcAliveCount=COUNT(FUNCTION_TYPE) FROM FUNCTION_ALLOC_GANTT
		WHERE FUNCTION_TYPE=@funcType AND ALLOC_CLOSE_DATETIME>@Now;
	
	IF @funcAliveCount=0
	BEGIN
		UPDATE [dbo].[FUNCTION_TYPES] SET [IS_ALLOCATED] = 0 WHERE [TYPE]=@funcType;
	END

	--Record "DEL" event of [FUNCTION_ALLOC_GANTT] into table [AUDIT_LOG]
	INSERT INTO [AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP, CURRENT_USER, 'DEL', 'FUNCTION_ALLOC_GANTT',
			'FUNCTION_TYPE=' + FUNCTION_TYPE + ', RESOURCE=' + RESOURCE + 
			', ALLOC_OPEN_DATETIME=' + CONVERT(varchar(20),ALLOC_OPEN_DATETIME) +
			', ALLOC_CLOSE_DATETIME=' + CONVERT(varchar(20),ALLOC_CLOSE_DATETIME)
		FROM DELETED;
		
	-- Insert into [BHS_FIS_OUTGOING_ALLOCATIONS]
	INSERT INTO [BHSDB].[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
			   ([ALLOC_TYPE]
			   ,[ACTION]
			   ,[FUNCTION_TYPE], [FUNCTION_DATA]
			   ,[RESOURCE]
			   )
	SELECT 'FUN', 'DEL', [FUNCTION_TYPE], [EXCEPTION]
		  ,[RESOURCE]
	  FROM DELETED				
END 
GO



-- ****** Object:  Trigger [INSERT_FUNCTION_TYPES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_FUNCTION_TYPES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_FUNCTION_TYPES]...'
	DROP TRIGGER [INSERT_FUNCTION_TYPES]
END
PRINT 'INFO: Creating trigger [INSERT_FUNCTION_TYPES]...'
GO
CREATE TRIGGER [dbo].[INSERT_FUNCTION_TYPES] ON [dbo].[FUNCTION_TYPES]
AFTER INSERT
AS
BEGIN
	INSERT INTO AUDIT_LOG (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'INS','FUNCTION_TYPES',
			'TYPE=' + [TYPE] + 
			', GROUP=' + [GROUP] + 
			', DESCRIPTION=' + [DESCRIPTION] + 
			', IS_ALLOCATED=' + CAST([IS_ALLOCATED] AS varchar(1)) +
			', IS_ENABLED=' + CAST([IS_ENABLED] AS varchar(1))
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [UPDATE_FUNCTION_TYPES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_FUNCTION_TYPES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_FUNCTION_TYPES]...'
	DROP TRIGGER [UPDATE_FUNCTION_TYPES]
END
PRINT 'INFO: Creating trigger [UPDATE_FUNCTION_TYPES]...'
GO
CREATE  TRIGGER [dbo].[UPDATE_FUNCTION_TYPES] ON [dbo].[FUNCTION_TYPES]
AFTER UPDATE
AS
BEGIN
	INSERT INTO AUDIT_LOG (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'UPD','FUNCTION_TYPES',
			'TYPE=' + [TYPE] + 
			', GROUP=' + [GROUP] + 
			', DESCRIPTION=' + [DESCRIPTION] + 
			', IS_ALLOCATED=' + CAST([IS_ALLOCATED] AS varchar(1)) +
			', IS_ENABLED=' + CAST([IS_ENABLED] AS varchar(1))
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [DELETE_FUNCTION_TYPES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_FUNCTION_TYPES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_FUNCTION_TYPES]...'
	DROP TRIGGER [DELETE_FUNCTION_TYPES]
END
PRINT 'INFO: Creating trigger [DELETE_FUNCTION_TYPES]...'
GO
CREATE  TRIGGER [dbo].[DELETE_FUNCTION_TYPES] ON [dbo].[FUNCTION_TYPES]
AFTER DELETE
AS
BEGIN
	INSERT INTO AUDIT_LOG (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'DEL','FUNCTION_TYPES',
			'TYPE=' + [TYPE] + 
			', GROUP=' + [GROUP] + 
			', DESCRIPTION=' + [DESCRIPTION] + 
			', IS_ALLOCATED=' + CAST([IS_ALLOCATED] AS varchar(1)) +
			', IS_ENABLED=' + CAST([IS_ENABLED] AS varchar(1))
		FROM DELETED;
END
GO



-- ****** Object:  Trigger [INSERT_SYS_CONFIG]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_SYS_CONFIG]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_SYS_CONFIG]...'
	DROP TRIGGER [INSERT_SYS_CONFIG]
END
PRINT 'INFO: Creating trigger [INSERT_SYS_CONFIG]...'
GO
CREATE  TRIGGER [dbo].[INSERT_SYS_CONFIG] ON [dbo].[SYS_CONFIG]
AFTER INSERT
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_SYS_CONFIG'

	INSERT INTO [dbo].[AUDIT_LOG]  (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'INS','SYS_CONFIG',
			'SYS_KEY=' + SYS_KEY + ', SYS_VALUE=' + SYS_VALUE + 
			', DEFAULT_VALUE=' + DEFAULT_VALUE + ', LAST_VALUE=' + LAST_VALUE + 
			', DESCRIPTION=' + DESCRIPTION + ', VALUE_TOKEN=' + VALUE_TOKEN +
			', SYS_ACTION=' + SYS_ACTION + ', GROUP_NAME=' + GROUP_NAME +
			', ORDER_FLAG=' + ORDER_FLAG + ', IS_ENABLED=' + CAST(IS_ENABLED AS varchar(1))	
		FROM INSERTED
END
GO



-- ****** Object:  Trigger [UPDATE_SYS_CONFIG]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_SYS_CONFIG]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_SYS_CONFIG]...'
	DROP TRIGGER [UPDATE_SYS_CONFIG]
END
PRINT 'INFO: Creating trigger [UPDATE_SYS_CONFIG]...'
GO
CREATE  TRIGGER [dbo].[UPDATE_SYS_CONFIG] ON [dbo].[SYS_CONFIG]
AFTER UPDATE
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_SYS_CONFIG'

	INSERT INTO [dbo].[AUDIT_LOG]  (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'UPD','SYS_CONFIG',
			'SYS_KEY=' + SYS_KEY + ', SYS_VALUE=' + SYS_VALUE + 
			', DEFAULT_VALUE=' + DEFAULT_VALUE + ', LAST_VALUE=' + LAST_VALUE + 
			', DESCRIPTION=' + DESCRIPTION + ', VALUE_TOKEN=' + VALUE_TOKEN +
			', SYS_ACTION=' + SYS_ACTION + ', GROUP_NAME=' + GROUP_NAME +
			', ORDER_FLAG=' + ORDER_FLAG + ', IS_ENABLED=' + CAST(IS_ENABLED AS varchar(1))	
		FROM INSERTED
END
GO



-- ****** Object:  Trigger [DELETE_SYS_CONFIG]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_SYS_CONFIG]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_SYS_CONFIG]...'
	DROP TRIGGER [DELETE_SYS_CONFIG]
END
PRINT 'INFO: Creating trigger [DELETE_SYS_CONFIG]...'
GO
CREATE  TRIGGER [dbo].[DELETE_SYS_CONFIG] ON [dbo].[SYS_CONFIG]
AFTER DELETE
AS
BEGIN
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_SYS_CONFIG'

	INSERT INTO [dbo].[AUDIT_LOG]  (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'DEL','SYS_CONFIG',
			'SYS_KEY=' + SYS_KEY + ', SYS_VALUE=' + SYS_VALUE + 
			', DEFAULT_VALUE=' + DEFAULT_VALUE + ', LAST_VALUE=' + LAST_VALUE + 
			', DESCRIPTION=' + DESCRIPTION + ', VALUE_TOKEN=' + VALUE_TOKEN +
			', SYS_ACTION=' + SYS_ACTION + ', GROUP_NAME=' + GROUP_NAME +
			', ORDER_FLAG=' + ORDER_FLAG + ', IS_ENABLED=' + CAST(IS_ENABLED AS varchar(1))	
		FROM DELETED
END
GO



-- ****** Object:  Trigger [INSERT_ROLES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_ROLES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_ROLES]...'
	DROP TRIGGER [INSERT_ROLES]
END
PRINT 'INFO: Creating trigger [INSERT_ROLES]...'
GO
CREATE  TRIGGER [dbo].[INSERT_ROLES] ON [dbo].[ROLES]
AFTER INSERT
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'INS','ROLES',
			'ID=' + ID + ', DESCRIPTION=' + DESCRIPTION
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [UPDATE_ROLES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_ROLES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_ROLES]...'
	DROP TRIGGER [UPDATE_ROLES]
END
PRINT 'INFO: Creating trigger [UPDATE_ROLES]...'
GO
CREATE  TRIGGER [dbo].[UPDATE_ROLES] ON [dbo].[ROLES]
AFTER UPDATE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'UPD','ROLES',
			'ID=' + ID + ', DESCRIPTION=' + DESCRIPTION
		FROM INSERTED;
END
GO




-- ****** Object:  Trigger [DELETE_ROLES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_ROLES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_ROLES]...'
	DROP TRIGGER [DELETE_ROLES]
END
PRINT 'INFO: Creating trigger [DELETE_ROLES]...'
GO
CREATE  TRIGGER [dbo].[DELETE_ROLES] ON [dbo].[ROLES]
AFTER DELETE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'DEL','ROLES',
			'ID=' + ID + ', DESCRIPTION=' + DESCRIPTION
		FROM DELETED;
END
GO



-- ****** Object:  Trigger [INSERT_AIRLINES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_AIRLINES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_AIRLINES]...'
	DROP TRIGGER [INSERT_AIRLINES]
END
PRINT 'INFO: Creating trigger [INSERT_AIRLINES]...'
GO
CREATE  TRIGGER [dbo].[INSERT_AIRLINES] ON [dbo].[AIRLINES] 
AFTER INSERT
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'INS','AIRLINES',
			'CODE_IATA=' + CODE_IATA + ', CODE_ICAO=' + CODE_ICAO +
			', NAME=' + NAME + ', TICKETING_CODE=' + TICKETING_CODE +
			', DESTINATION=' + ISNULL(DESTINATION,'')
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [UPDATE_AIRLINES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_AIRLINES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_AIRLINES]...'
	DROP TRIGGER [UPDATE_AIRLINES]
END
PRINT 'INFO: Creating trigger [UPDATE_AIRLINES]...'
GO
CREATE  TRIGGER [dbo].[UPDATE_AIRLINES] ON [dbo].[AIRLINES] 
AFTER UPDATE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'UPD','AIRLINES',
			'CODE_IATA=' + CODE_IATA + ', CODE_ICAO=' + CODE_ICAO +
			', NAME=' + NAME + ', TICKETING_CODE=' + TICKETING_CODE +
			', DESTINATION=' + ISNULL(DESTINATION,'')
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [DELETE_AIRLINES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_AIRLINES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_AIRLINES]...'
	DROP TRIGGER [DELETE_AIRLINES]
END
PRINT 'INFO: Creating trigger [DELETE_AIRLINES]...'
GO
CREATE  TRIGGER [dbo].[DELETE_AIRLINES] ON [dbo].[AIRLINES] 
AFTER DELETE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'DEL','AIRLINES',
			'CODE_IATA=' + CODE_IATA + ', CODE_ICAO=' + CODE_ICAO +
			', NAME=' + NAME + ', TICKETING_CODE=' + TICKETING_CODE +
			', DESTINATION=' + ISNULL(DESTINATION,'')
		FROM DELETED;
END
GO



-- ****** Object:  Trigger [INSERT_AIRPORTS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_AIRPORTS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_AIRPORTS]...'
	DROP TRIGGER [INSERT_AIRPORTS]
END
PRINT 'INFO: Creating trigger [INSERT_AIRPORTS]...'
GO
CREATE  TRIGGER [dbo].[INSERT_AIRPORTS] ON [dbo].[AIRPORTS] 
AFTER INSERT
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'INS','AIRPORTS',
			'CODE_IATA=' + CODE_IATA + ', CODE_ICAO=' + CODE_ICAO + 
			', NAME=' + NAME + ', COUNTRY=' + COUNTRY + ', CITY=' + CITY
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [UPDATE_AIRPORTS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_AIRPORTS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_AIRPORTS]...'
	DROP TRIGGER [UPDATE_AIRPORTS]
END
PRINT 'INFO: Creating trigger [UPDATE_AIRPORTS]...'
GO
CREATE  TRIGGER [dbo].[UPDATE_AIRPORTS] ON [dbo].[AIRPORTS] 
AFTER UPDATE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'UPD','AIRPORTS',
			'CODE_IATA=' + CODE_IATA + ', CODE_ICAO=' + CODE_ICAO + 
			', NAME=' + NAME + ', COUNTRY=' + COUNTRY + ', CITY=' + CITY
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [DELETE_AIRPORTS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_AIRPORTS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_AIRPORTS]...'
	DROP TRIGGER [DELETE_AIRPORTS]
END
PRINT 'INFO: Creating trigger [DELETE_AIRPORTS]...'
GO
CREATE  TRIGGER [dbo].[DELETE_AIRPORTS] ON [dbo].[AIRPORTS] 
AFTER DELETE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'DEL','AIRPORTS',
			'CODE_IATA=' + CODE_IATA + ', CODE_ICAO=' + CODE_ICAO + 
			', NAME=' + NAME + ', COUNTRY=' + COUNTRY + ', CITY=' + CITY
		FROM DELETED;
END
GO




-- ****** Object:  Trigger [INSERT_FLIGHTS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_FLIGHTS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_FLIGHTS]...'
	DROP TRIGGER [INSERT_FLIGHTS]
END
PRINT 'INFO: Creating trigger [INSERT_FLIGHTS]...'
GO
CREATE   TRIGGER [dbo].[INSERT_FLIGHTS] ON [dbo].[FLIGHTS] 
AFTER INSERT
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'INS','FLIGHTS',
			'FLIGHT_NUMBER=' + FLIGHT_NUMBER + ', AIRLINE=' + AIRLINE +
			', AIRCRAFT_TYPE=' + AIRCRAFT_TYPE + ', FLIGHT_DESC=' + FLIGHT_DESC + 
			', HIGH_RISK=' + HIGH_RISK + ', HBS_LEVEL_REQUIRED=' + HBS_LEVEL_REQUIRED
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [UPDATE_FLIGHTS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_FLIGHTS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_FLIGHTS]...'
	DROP TRIGGER [UPDATE_FLIGHTS]
END
PRINT 'INFO: Creating trigger [UPDATE_FLIGHTS]...'
GO
CREATE   TRIGGER [dbo].[UPDATE_FLIGHTS] ON [dbo].[FLIGHTS] 
AFTER UPDATE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'UPD','FLIGHTS',
			'FLIGHT_NUMBER=' + FLIGHT_NUMBER + ', AIRLINE=' + AIRLINE +
			', AIRCRAFT_TYPE=' + AIRCRAFT_TYPE + ', FLIGHT_DESC=' + FLIGHT_DESC + 
			', HIGH_RISK=' + HIGH_RISK + ', HBS_LEVEL_REQUIRED=' + HBS_LEVEL_REQUIRED
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [DELETE_FLIGHTS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_FLIGHTS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_FLIGHTS]...'
	DROP TRIGGER [DELETE_FLIGHTS]
END
PRINT 'INFO: Creating trigger [DELETE_FLIGHTS]...'
GO
CREATE TRIGGER [dbo].[DELETE_FLIGHTS] ON [dbo].[FLIGHTS] 
AFTER DELETE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'DEL','FLIGHTS',
			'FLIGHT_NUMBER=' + FLIGHT_NUMBER + ', AIRLINE=' + AIRLINE +
			', AIRCRAFT_TYPE=' + AIRCRAFT_TYPE + ', FLIGHT_DESC=' + FLIGHT_DESC + 
			', HIGH_RISK=' + HIGH_RISK + ', HBS_LEVEL_REQUIRED=' + HBS_LEVEL_REQUIRED
		FROM DELETED;
END
GO





-- ****** Object:  Trigger [INSERT_AIRCRAFT_TYPES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_AIRCRAFT_TYPES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_AIRCRAFT_TYPES]...'
	DROP TRIGGER [INSERT_AIRCRAFT_TYPES]
END
PRINT 'INFO: Creating trigger [INSERT_AIRCRAFT_TYPES]...'
GO
CREATE TRIGGER [dbo].[INSERT_AIRCRAFT_TYPES] ON [dbo].[AIRCRAFT_TYPES] 
AFTER INSERT
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'INS','AIRCRAFT_TYPES',
			'TYPE=' + TYPE + ', MAX_PAX=' + CAST(MAX_PAX AS VARCHAR(4)) + 
			', DESCRIPTION=' + DESCRIPTION
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [UPDATE_AIRCRAFT_TYPES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_AIRCRAFT_TYPES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_AIRCRAFT_TYPES]...'
	DROP TRIGGER [UPDATE_AIRCRAFT_TYPES]
END
PRINT 'INFO: Creating trigger [UPDATE_AIRCRAFT_TYPES]...'
GO
CREATE TRIGGER [dbo].[UPDATE_AIRCRAFT_TYPES] ON [dbo].[AIRCRAFT_TYPES] 
AFTER UPDATE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'UPD','AIRCRAFT_TYPES',
			'TYPE=' + TYPE + ', MAX_PAX=' + CAST(MAX_PAX AS VARCHAR(4)) + 
			', DESCRIPTION=' + DESCRIPTION
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [DELETE_AIRCRAFT_TYPES]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_AIRCRAFT_TYPES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_AIRCRAFT_TYPES]...'
	DROP TRIGGER [DELETE_AIRCRAFT_TYPES]
END
PRINT 'INFO: Creating trigger [DELETE_AIRCRAFT_TYPES]...'
GO
CREATE TRIGGER [dbo].[DELETE_AIRCRAFT_TYPES] ON [dbo].[AIRCRAFT_TYPES] 
AFTER DELETE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'DEL','AIRCRAFT_TYPES',
			'TYPE=' + TYPE + ', MAX_PAX=' + CAST(MAX_PAX AS VARCHAR(4)) + 
			', DESCRIPTION=' + DESCRIPTION
		FROM DELETED;
END
GO




-- ****** Object:  Trigger [INSERT_USERS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_USERS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_USERS]...'
	DROP TRIGGER [INSERT_USERS]
END
PRINT 'INFO: Creating trigger [INSERT_USERS]...'
GO
CREATE TRIGGER [dbo].[INSERT_USERS] ON [dbo].[USERS]
AFTER INSERT
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
	SELECT CURRENT_TIMESTAMP,CURRENT_USER,'INS','USERS',
		'ID=' + ID + ', USER_NAME=' + USER_NAME +
		', USER_IP_ADDR=' + ISNULL(USER_IP_ADDR,'') + ', IP_CHECK=' + IP_CHECK +
		', EXPIRY_DATE=' + CAST(ISNULL(EXPIRY_DATE,'2020-01-01') AS VARCHAR(20)) + 
		', CREATED_BY=' + CREATED_BY + ', TIME_STAMP=' + CAST(TIME_STAMP AS VARCHAR(20))
	FROM INSERTED; 
END
GO



-- ****** Object:  Trigger [UPDATE_USERS]    Script Date: 10/08/2007 13:18:37 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_USERS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_USERS]...'
	DROP TRIGGER [UPDATE_USERS]
END
PRINT 'INFO: Creating trigger [UPDATE_USERS]...'
GO
CREATE TRIGGER [dbo].[UPDATE_USERS] ON [dbo].[USERS]
AFTER UPDATE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
	SELECT CURRENT_TIMESTAMP,CURRENT_USER,'UPD','USERS',
		'ID=' + ID + ', USER_NAME=' + USER_NAME +
		', USER_IP_ADDR=' + ISNULL(USER_IP_ADDR,'') + ', IP_CHECK=' + IP_CHECK +
		', EXPIRY_DATE=' + CAST(ISNULL(EXPIRY_DATE,'2020-01-01') AS VARCHAR(20)) + 
		', CREATED_BY=' + CREATED_BY + ', TIME_STAMP=' + CAST(TIME_STAMP AS VARCHAR(20))
	FROM INSERTED;
END
GO



-- ****** Object:  Trigger [DELETE_USERS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_USERS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_USERS]...'
	DROP TRIGGER [DELETE_USERS]
END
PRINT 'INFO: Creating trigger [DELETE_USERS]...'
GO
CREATE   TRIGGER [dbo].[DELETE_USERS] ON [dbo].[USERS]
AFTER DELETE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
	SELECT CURRENT_TIMESTAMP,CURRENT_USER,'DEL','USERS',
		'ID=' + ID + ', USER_NAME=' + USER_NAME +
		', USER_IP_ADDR=' + ISNULL(USER_IP_ADDR,'') + ', IP_CHECK=' + IP_CHECK +
		', EXPIRY_DATE=' + CAST(ISNULL(EXPIRY_DATE,'2020-01-01') AS VARCHAR(20)) + 
		', CREATED_BY=' + CREATED_BY + ', TIME_STAMP=' + CAST(TIME_STAMP AS VARCHAR(20))
	FROM DELETED;
END
GO





-- ****** Object:  Trigger [INSERT_USERS_ROLES]    Script Date: 10/08/2007 13:18:37 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_USERS_ROLES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_USERS_ROLES]...'
	DROP TRIGGER [INSERT_USERS_ROLES]
END
PRINT 'INFO: Creating trigger [INSERT_USERS_ROLES]...'
GO
CREATE TRIGGER [dbo].[INSERT_USERS_ROLES] ON [dbo].[USERS_ROLES]
AFTER INSERT
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'INS','USERS_ROLES',
			'USER_ID=' + USER_ID + ', ROLE_ID=' + ROLE_ID + ', TIME_STAMP=' + CAST(TIME_STAMP AS VARCHAR(20))
		FROM INSERTED;
END
GO




-- ****** Object:  Trigger [UPDATE_USERS_ROLES]    Script Date: 10/08/2007 13:18:37 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_USERS_ROLES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_USERS_ROLES]...'
	DROP TRIGGER [UPDATE_USERS_ROLES]
END
PRINT 'INFO: Creating trigger [UPDATE_USERS_ROLES]...'
GO
CREATE TRIGGER [dbo].[UPDATE_USERS_ROLES] ON [dbo].[USERS_ROLES]
AFTER UPDATE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'UPD','USERS_ROLES',
			'USER_ID=' + USER_ID + ', ROLE_ID=' + ROLE_ID + ', TIME_STAMP=' + CAST(TIME_STAMP AS VARCHAR(20))
		FROM INSERTED;
END
GO



-- ****** Object:  Trigger [DELETE_USERS_ROLES]    Script Date: 10/08/2007 13:18:37 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_USERS_ROLES]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_USERS_ROLES]...'
	DROP TRIGGER [DELETE_USERS_ROLES]
END
PRINT 'INFO: Creating trigger [DELETE_USERS_ROLES]...'
GO
CREATE  TRIGGER [dbo].[DELETE_USERS_ROLES] ON [dbo].[USERS_ROLES]
AFTER DELETE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'DEL','USERS_ROLES',
			'USER_ID=' + USER_ID + ', ROLE_ID=' + ROLE_ID + ', TIME_STAMP=' + CAST(TIME_STAMP AS VARCHAR(20))
		FROM DELETED;
END
GO


/****** Object:  Trigger [dbo].[INSERT_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]    Script Date: 01/18/2010 13:28:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]...'
	DROP TRIGGER [INSERT_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]
END
PRINT 'INFO: Creating trigger [DELETE_USERS_ROLES]...'
GO
CREATE  TRIGGER [dbo].[INSERT_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS] ON [dbo].[FLIGHT_PLAN_ALLOC] 
AFTER INSERT
AS
BEGIN

	DECLARE @AIRLINE [varchar](3), @FLIGHT_NUMBER [varchar](5), @SDO [datetime],
		@STO [varchar](4), @RESOURCE [varchar](10), @WEEKDAY [char](1), @EDO [datetime],
		@ETO [varchar](4), @ADO [datetime], @ATO [varchar](4), @IDO [datetime],
		@ITO [varchar](4), @TRAVEL_CLASS [varchar](1), @HIGH_RISK [char](1), 
		@HBS_LEVEL_REQUIRED [char](1), @EARLY_OPEN_OFFSET [varchar](5),
		@EARLY_OPEN_ENABLED [bit], @ALLOC_OPEN_OFFSET [varchar](5),
		@ALLOC_OPEN_RELATED [varchar](4), @ALLOC_CLOSE_OFFSET [varchar](5),
		@ALLOC_CLOSE_RELATED [varchar](4), @RUSH_DURATION [varchar](5),
		@SCHEME_TYPE [varchar](2), @CREATED_BY [varchar](15), @TIME_STAMP [datetime],
		@HOUR [varchar](2), @IS_MANUAL_CLOSE [bit], @IS_CLOSED [bit];

	SELECT @AIRLINE = [AIRLINE], @FLIGHT_NUMBER = [FLIGHT_NUMBER], @SDO = [SDO],
		  @STO = [STO], @RESOURCE = [RESOURCE], @WEEKDAY = [WEEKDAY], @EDO = [EDO],
		  @ETO = [ETO], @ADO = [ADO], @ATO = [ATO], @IDO = [IDO], @ITO = [ITO],
		  @TRAVEL_CLASS = [TRAVEL_CLASS], @HIGH_RISK = [HIGH_RISK], 
		  @HBS_LEVEL_REQUIRED = [HBS_LEVEL_REQUIRED], @EARLY_OPEN_OFFSET = [EARLY_OPEN_OFFSET],
		  @EARLY_OPEN_ENABLED = [EARLY_OPEN_ENABLED], @ALLOC_OPEN_OFFSET = [ALLOC_OPEN_OFFSET],
		  @ALLOC_OPEN_RELATED = [ALLOC_OPEN_RELATED], @ALLOC_CLOSE_OFFSET = [ALLOC_CLOSE_OFFSET],
		  @ALLOC_CLOSE_RELATED = [ALLOC_CLOSE_RELATED], @RUSH_DURATION = [RUSH_DURATION],
		  @SCHEME_TYPE = [SCHEME_TYPE], @CREATED_BY = [CREATED_BY], @TIME_STAMP = [TIME_STAMP],
		  @HOUR = [HOUR], @IS_MANUAL_CLOSE = [IS_MANUAL_CLOSE], @IS_CLOSED = [IS_CLOSED]
	  FROM INSERTED WHERE CREATED_BY != 'FIS'



	--SELECT @AIRLINE, @FLIGHT_NUMBER, @SDO, @STO, @RESOURCE, @WEEKDAY, @EDO,
	--      @ETO, @ADO, @ATO, @IDO, @ITO, @TRAVEL_CLASS, @HIGH_RISK, 
	--      @HBS_LEVEL_REQUIRED, @EARLY_OPEN_OFFSET, @EARLY_OPEN_ENABLED, 
	--      @ALLOC_OPEN_OFFSET, @ALLOC_OPEN_RELATED, @ALLOC_CLOSE_OFFSET,
	--      @ALLOC_CLOSE_RELATED, @RUSH_DURATION, @SCHEME_TYPE, @CREATED_BY, 
	--      @TIME_STAMP, @HOUR, @IS_MANUAL_CLOSE, @IS_CLOSED 

	IF @CREATED_BY != 'FIS'
	BEGIN
		DECLARE @OPEN_OFFSET AS int
		DECLARE @OPENTIME datetime    
		DECLARE @TEMP datetime 

		IF (LEN(@ALLOC_OPEN_OFFSET) = 4)
		BEGIN
			SET @OPEN_OFFSET = (CAST(SUBSTRING(@ALLOC_OPEN_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(@ALLOC_OPEN_OFFSET,3,2) AS INT))
		END

		IF (LEN(@ALLOC_OPEN_OFFSET) = 5)
		BEGIN
			SET @OPEN_OFFSET = ((CAST(SUBSTRING(@ALLOC_OPEN_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(@ALLOC_OPEN_OFFSET,4,2) AS INT))*-1)
		END
		  
		IF @ALLOC_OPEN_RELATED = 'STD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@SDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@STO,1,2) + ':' + SUBSTRING(@STO,3,2)  ,108) AS TIME))
			
			SET @OPENTIME = (DATEADD(MINUTE,@OPEN_OFFSET,@TEMP))
		END 
		ELSE IF  @ALLOC_OPEN_RELATED = 'ETD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@EDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ETO,1,2) + ':' + SUBSTRING(@ETO,3,2)  ,108) AS TIME))
			
			SET @OPENTIME = (DATEADD(MINUTE,@OPEN_OFFSET,@TEMP))
		END     
		ELSE IF  @ALLOC_OPEN_RELATED = 'ATD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@ADO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ATO,1,2) + ':' + SUBSTRING(@ATO,3,2)  ,108) AS TIME))
			
			SET @OPENTIME = (DATEADD(MINUTE,@OPEN_OFFSET,@TEMP))
		END  
		ELSE IF  @ALLOC_OPEN_RELATED = 'ITD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@IDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ITO,1,2) + ':' + SUBSTRING(@ITO,3,2)  ,108) AS TIME))
			
			SET @OPENTIME = (DATEADD(MINUTE,@OPEN_OFFSET,@TEMP))
		END      

		 
		DECLARE @CLOSE_OFFSET AS int
		DECLARE @CLOSETIME datetime    

		IF (LEN(@ALLOC_CLOSE_OFFSET) = 4)
		BEGIN
			SET @CLOSE_OFFSET = (CAST(SUBSTRING(@ALLOC_CLOSE_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(@ALLOC_CLOSE_OFFSET,3,2) AS INT))
		END

		IF (LEN(@ALLOC_CLOSE_OFFSET) = 5)
		BEGIN
			SET @CLOSE_OFFSET = ((CAST(SUBSTRING(@ALLOC_CLOSE_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(@ALLOC_CLOSE_OFFSET,4,2) AS INT))*-1)
		END
		  
		  
		IF @ALLOC_CLOSE_RELATED = 'STD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@SDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@STO,1,2) + ':' + SUBSTRING(@STO,3,2)  ,108) AS TIME))
			
			SET @CLOSETIME = (DATEADD(MINUTE,@CLOSE_OFFSET,@TEMP))
		END 
		ELSE IF  @ALLOC_CLOSE_RELATED = 'ETD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@EDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ETO,1,2) + ':' + SUBSTRING(@ETO,3,2)  ,108) AS TIME))
			
			SET @CLOSETIME = (DATEADD(MINUTE,@CLOSE_OFFSET,@TEMP))
		END     
		ELSE IF  @ALLOC_CLOSE_RELATED = 'ATD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@ADO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ATO,1,2) + ':' + SUBSTRING(@ATO,3,2)  ,108) AS TIME))
			
			SET @CLOSETIME = (DATEADD(MINUTE,@CLOSE_OFFSET,@TEMP))
		END  
		ELSE IF  @ALLOC_CLOSE_RELATED = 'ITD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@IDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ITO,1,2) + ':' + SUBSTRING(@ITO,3,2)  ,108) AS TIME))
			
			SET @CLOSETIME = (DATEADD(MINUTE,@CLOSE_OFFSET,@TEMP))
		END            



		DECLARE @RUSHTIME datetime
		DECLARE @EARLYTIME datetime

		DECLARE @RUSHDURATION INT = (CAST((SUBSTRING(@RUSH_DURATION,1,2)*60 + SUBSTRING(@RUSH_DURATION,3,2)) AS INT))
		SET @RUSHTIME = DATEADD(MINUTE,-1*@RUSHDURATION,@CLOSETIME)

		DECLARE @EARLY_OFFSET AS int

		IF (LEN(@EARLY_OPEN_OFFSET) = 4)
		BEGIN
			SET @EARLY_OFFSET = (CAST(SUBSTRING(@EARLY_OPEN_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(@EARLY_OPEN_OFFSET,3,2) AS INT))
		END

		IF (LEN(@EARLY_OPEN_OFFSET) = 5)
		BEGIN
			SET @EARLY_OFFSET = ((CAST(SUBSTRING(@EARLY_OPEN_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(@EARLY_OPEN_OFFSET,4,2) AS INT))*-1)
		END

		SET @EARLYTIME = (DATEADD(MINUTE, @EARLY_OFFSET,@OPENTIME))

		DECLARE @STATE VARCHAR(10)

		IF GETDATE() < @EARLYTIME
		BEGIN
			SET @STATE = 'TOOEARLY'
		END

		IF GETDATE() >= @EARLYTIME AND GETDATE() < @OPENTIME
		BEGIN
			SET @STATE = 'EBS'
		END

		IF GETDATE() >= @OPENTIME AND GETDATE() < @RUSHTIME
		BEGIN
			SET @STATE = 'OPEN'
		END

		IF GETDATE() >= @RUSHTIME  AND GETDATE() < @CLOSETIME 
		BEGIN
			SET @STATE = 'RUSH'
		END

		IF GETDATE() > @CLOSETIME 
		BEGIN
			SET @STATE = 'LATE'
		END
		--SELECT @OPENTIME AS O , @CLOSETIME AS C, @RUSHTIME AS RUSH, @EARLYTIME AS EARLY, @STATE AS STAT


		INSERT INTO [BHSDB].[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
				   ([ALLOC_TYPE]
				   ,[ACTION]
				   ,[AIRLINE]
				   ,[FLIGHT_NUMBER]
				   ,[SDO]
				   ,[RESOURCE]
				   ,[STATE]
				   ,[OPEN_TIME]
				   ,[CLOSE_TIME]
				   ,[TRAVEL_CLASS])
			 VALUES
				   ('FLT'
				   ,'NEW'
				   ,@AIRLINE
				   ,@FLIGHT_NUMBER
				   ,@SDO
				   ,@RESOURCE
				   ,@STATE
				   ,@OPENTIME
				   ,@CLOSETIME
				   ,@TRAVEL_CLASS)
	END				    
END
GO



/****** Object:  Trigger [dbo].[UPDATE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]    Script Date: 01/18/2010 13:28:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]...'
	DROP TRIGGER [UPDATE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]
END
PRINT 'INFO: Creating trigger [UPDATE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]...'
GO
CREATE  TRIGGER [dbo].[UPDATE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS] ON [dbo].[FLIGHT_PLAN_ALLOC] 
AFTER UPDATE
AS
BEGIN

	DECLARE @AIRLINE [varchar](3), @FLIGHT_NUMBER [varchar](5), @SDO [datetime],
		@STO [varchar](4), @RESOURCE [varchar](10), @WEEKDAY [char](1), @EDO [datetime],
		@ETO [varchar](4), @ADO [datetime], @ATO [varchar](4), @IDO [datetime],
		@ITO [varchar](4), @TRAVEL_CLASS [varchar](1), @HIGH_RISK [char](1), 
		@HBS_LEVEL_REQUIRED [char](1), @EARLY_OPEN_OFFSET [varchar](5),
		@EARLY_OPEN_ENABLED [bit], @ALLOC_OPEN_OFFSET [varchar](5),
		@ALLOC_OPEN_RELATED [varchar](4), @ALLOC_CLOSE_OFFSET [varchar](5),
		@ALLOC_CLOSE_RELATED [varchar](4), @RUSH_DURATION [varchar](5),
		@SCHEME_TYPE [varchar](2), @CREATED_BY [varchar](15), @TIME_STAMP [datetime],
		@HOUR [varchar](2), @IS_MANUAL_CLOSE [bit], @IS_CLOSED [bit];

	SELECT @AIRLINE = [AIRLINE], @FLIGHT_NUMBER = [FLIGHT_NUMBER], @SDO = [SDO],
		  @STO = [STO], @RESOURCE = [RESOURCE], @WEEKDAY = [WEEKDAY], @EDO = [EDO],
		  @ETO = [ETO], @ADO = [ADO], @ATO = [ATO], @IDO = [IDO], @ITO = [ITO],
		  @TRAVEL_CLASS = [TRAVEL_CLASS], @HIGH_RISK = [HIGH_RISK], 
		  @HBS_LEVEL_REQUIRED = [HBS_LEVEL_REQUIRED], @EARLY_OPEN_OFFSET = [EARLY_OPEN_OFFSET],
		  @EARLY_OPEN_ENABLED = [EARLY_OPEN_ENABLED], @ALLOC_OPEN_OFFSET = [ALLOC_OPEN_OFFSET],
		  @ALLOC_OPEN_RELATED = [ALLOC_OPEN_RELATED], @ALLOC_CLOSE_OFFSET = [ALLOC_CLOSE_OFFSET],
		  @ALLOC_CLOSE_RELATED = [ALLOC_CLOSE_RELATED], @RUSH_DURATION = [RUSH_DURATION],
		  @SCHEME_TYPE = [SCHEME_TYPE], @CREATED_BY = [CREATED_BY], @TIME_STAMP = [TIME_STAMP],
		  @HOUR = [HOUR], @IS_MANUAL_CLOSE = [IS_MANUAL_CLOSE], @IS_CLOSED = [IS_CLOSED]
	  FROM INSERTED WHERE CREATED_BY != 'FIS'



	--SELECT @AIRLINE, @FLIGHT_NUMBER, @SDO, @STO, @RESOURCE, @WEEKDAY, @EDO,
	--      @ETO, @ADO, @ATO, @IDO, @ITO, @TRAVEL_CLASS, @HIGH_RISK, 
	--      @HBS_LEVEL_REQUIRED, @EARLY_OPEN_OFFSET, @EARLY_OPEN_ENABLED, 
	--      @ALLOC_OPEN_OFFSET, @ALLOC_OPEN_RELATED, @ALLOC_CLOSE_OFFSET,
	--      @ALLOC_CLOSE_RELATED, @RUSH_DURATION, @SCHEME_TYPE, @CREATED_BY, 
	--      @TIME_STAMP, @HOUR, @IS_MANUAL_CLOSE, @IS_CLOSED 

	IF @CREATED_BY != 'FIS'
	BEGIN
		DECLARE @OPEN_OFFSET AS int
		DECLARE @OPENTIME datetime    
		DECLARE @TEMP datetime 

		IF (LEN(@ALLOC_OPEN_OFFSET) = 4)
		BEGIN
			SET @OPEN_OFFSET = (CAST(SUBSTRING(@ALLOC_OPEN_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(@ALLOC_OPEN_OFFSET,3,2) AS INT))
		END

		IF (LEN(@ALLOC_OPEN_OFFSET) = 5)
		BEGIN
			SET @OPEN_OFFSET = ((CAST(SUBSTRING(@ALLOC_OPEN_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(@ALLOC_OPEN_OFFSET,4,2) AS INT))*-1)
		END
		  
		IF @ALLOC_OPEN_RELATED = 'STD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@SDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@STO,1,2) + ':' + SUBSTRING(@STO,3,2)  ,108) AS TIME))
			
			SET @OPENTIME = (DATEADD(MINUTE,@OPEN_OFFSET,@TEMP))
		END 
		ELSE IF  @ALLOC_OPEN_RELATED = 'ETD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@EDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ETO,1,2) + ':' + SUBSTRING(@ETO,3,2)  ,108) AS TIME))
			
			SET @OPENTIME = (DATEADD(MINUTE,@OPEN_OFFSET,@TEMP))
		END     
		ELSE IF  @ALLOC_OPEN_RELATED = 'ATD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@ADO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ATO,1,2) + ':' + SUBSTRING(@ATO,3,2)  ,108) AS TIME))
			
			SET @OPENTIME = (DATEADD(MINUTE,@OPEN_OFFSET,@TEMP))
		END  
		ELSE IF  @ALLOC_OPEN_RELATED = 'ITD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@IDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ITO,1,2) + ':' + SUBSTRING(@ITO,3,2)  ,108) AS TIME))
			
			SET @OPENTIME = (DATEADD(MINUTE,@OPEN_OFFSET,@TEMP))
		END      

		 
		DECLARE @CLOSE_OFFSET AS int
		DECLARE @CLOSETIME datetime    

		IF (LEN(@ALLOC_CLOSE_OFFSET) = 4)
		BEGIN
			SET @CLOSE_OFFSET = (CAST(SUBSTRING(@ALLOC_CLOSE_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(@ALLOC_CLOSE_OFFSET,3,2) AS INT))
		END

		IF (LEN(@ALLOC_CLOSE_OFFSET) = 5)
		BEGIN
			SET @CLOSE_OFFSET = ((CAST(SUBSTRING(@ALLOC_CLOSE_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(@ALLOC_CLOSE_OFFSET,4,2) AS INT))*-1)
		END
		  
		  
		IF @ALLOC_CLOSE_RELATED = 'STD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@SDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@STO,1,2) + ':' + SUBSTRING(@STO,3,2)  ,108) AS TIME))
			
			SET @CLOSETIME = (DATEADD(MINUTE,@CLOSE_OFFSET,@TEMP))
		END 
		ELSE IF  @ALLOC_CLOSE_RELATED = 'ETD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@EDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ETO,1,2) + ':' + SUBSTRING(@ETO,3,2)  ,108) AS TIME))
			
			SET @CLOSETIME = (DATEADD(MINUTE,@CLOSE_OFFSET,@TEMP))
		END     
		ELSE IF  @ALLOC_CLOSE_RELATED = 'ATD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@ADO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ATO,1,2) + ':' + SUBSTRING(@ATO,3,2)  ,108) AS TIME))
			
			SET @CLOSETIME = (DATEADD(MINUTE,@CLOSE_OFFSET,@TEMP))
		END  
		ELSE IF  @ALLOC_CLOSE_RELATED = 'ITD'
		BEGIN	
			SET @TEMP = (CAST((CONVERT(DATE,@IDO, 111)) AS DATETIME) +
						 CAST (CONVERT(VARCHAR(5), SUBSTRING(@ITO,1,2) + ':' + SUBSTRING(@ITO,3,2)  ,108) AS TIME))
			
			SET @CLOSETIME = (DATEADD(MINUTE,@CLOSE_OFFSET,@TEMP))
		END            



		DECLARE @RUSHTIME datetime
		DECLARE @EARLYTIME datetime

		DECLARE @RUSHDURATION INT = (CAST((SUBSTRING(@RUSH_DURATION,1,2)*60 + SUBSTRING(@RUSH_DURATION,3,2)) AS INT))
		SET @RUSHTIME = DATEADD(MINUTE,-1*@RUSHDURATION,@CLOSETIME)

		DECLARE @EARLY_OFFSET AS int

		IF (LEN(@EARLY_OPEN_OFFSET) = 4)
		BEGIN
			SET @EARLY_OFFSET = (CAST(SUBSTRING(@EARLY_OPEN_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(@EARLY_OPEN_OFFSET,3,2) AS INT))
		END

		IF (LEN(@EARLY_OPEN_OFFSET) = 5)
		BEGIN
			SET @EARLY_OFFSET = ((CAST(SUBSTRING(@EARLY_OPEN_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(@EARLY_OPEN_OFFSET,4,2) AS INT))*-1)
		END

		SET @EARLYTIME = (DATEADD(MINUTE, @EARLY_OFFSET,@OPENTIME))

		DECLARE @STATE VARCHAR(10)
		

		IF GETDATE() < @EARLYTIME
		BEGIN
			SET @STATE = 'TOOEARLY'
		END

		IF GETDATE() >= @EARLYTIME AND GETDATE() < @OPENTIME
		BEGIN
			SET @STATE = 'EBS'
		END

		IF GETDATE() >= @OPENTIME AND GETDATE() < @RUSHTIME
		BEGIN
			SET @STATE = 'OPEN'
		END

		IF GETDATE() >= @RUSHTIME  AND GETDATE() < @CLOSETIME 
		BEGIN
			SET @STATE = 'RUSH'
		END

		IF GETDATE() > @CLOSETIME 
		BEGIN
			SET @STATE = 'LATE'
		END
		--SELECT @OPENTIME AS O , @CLOSETIME AS C, @RUSHTIME AS RUSH, @EARLYTIME AS EARLY, @STATE AS STAT


		INSERT INTO [BHSDB].[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
				   ([ALLOC_TYPE]
				   ,[ACTION]
				   ,[AIRLINE]
				   ,[FLIGHT_NUMBER]
				   ,[SDO]
				   ,[RESOURCE]
				   ,[STATE]
				   ,[OPEN_TIME]
				   ,[CLOSE_TIME]
				   ,[TRAVEL_CLASS])
			 VALUES
				   ('FLT'
				   ,'UPD'
				   ,@AIRLINE
				   ,@FLIGHT_NUMBER
				   ,@SDO
				   ,@RESOURCE
				   ,@STATE
				   ,@OPENTIME
				   ,@CLOSETIME
				   ,@TRAVEL_CLASS)
	END				    
END
GO



/****** Object:  Trigger [dbo].[DELETE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]    Script Date: 01/18/2010 14:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[DELETE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [DELETE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]...'
	DROP TRIGGER [DELETE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]
END
PRINT 'INFO: Creating trigger [DELETE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS]...'
GO
CREATE  TRIGGER [dbo].[DELETE_FLIGHT_PLAN_ALLOC_BHS_FIS_OUTGOING_ALLOCATIONS] ON [dbo].[FLIGHT_PLAN_ALLOC] 
AFTER DELETE
AS
BEGIN

	DECLARE @AIRLINE [varchar](3), @FLIGHT_NUMBER [varchar](5), @SDO [datetime],
		@STO [varchar](4), @RESOURCE [varchar](10), @WEEKDAY [char](1), @EDO [datetime],
		@ETO [varchar](4), @ADO [datetime], @ATO [varchar](4), @IDO [datetime],
		@ITO [varchar](4), @TRAVEL_CLASS [varchar](1), @HIGH_RISK [char](1), 
		@HBS_LEVEL_REQUIRED [char](1), @EARLY_OPEN_OFFSET [varchar](5),
		@EARLY_OPEN_ENABLED [bit], @ALLOC_OPEN_OFFSET [varchar](5),
		@ALLOC_OPEN_RELATED [varchar](4), @ALLOC_CLOSE_OFFSET [varchar](5),
		@ALLOC_CLOSE_RELATED [varchar](4), @RUSH_DURATION [varchar](5),
		@SCHEME_TYPE [varchar](2), @CREATED_BY [varchar](15), @TIME_STAMP [datetime],
		@HOUR [varchar](2), @IS_MANUAL_CLOSE [bit], @IS_CLOSED [bit];

	SELECT @AIRLINE = [AIRLINE], @FLIGHT_NUMBER = [FLIGHT_NUMBER], @SDO = [SDO],
		  @STO = [STO], @RESOURCE = [RESOURCE], @WEEKDAY = [WEEKDAY], @EDO = [EDO],
		  @ETO = [ETO], @ADO = [ADO], @ATO = [ATO], @IDO = [IDO], @ITO = [ITO],
		  @TRAVEL_CLASS = [TRAVEL_CLASS], @HIGH_RISK = [HIGH_RISK], 
		  @HBS_LEVEL_REQUIRED = [HBS_LEVEL_REQUIRED], @EARLY_OPEN_OFFSET = [EARLY_OPEN_OFFSET],
		  @EARLY_OPEN_ENABLED = [EARLY_OPEN_ENABLED], @ALLOC_OPEN_OFFSET = [ALLOC_OPEN_OFFSET],
		  @ALLOC_OPEN_RELATED = [ALLOC_OPEN_RELATED], @ALLOC_CLOSE_OFFSET = [ALLOC_CLOSE_OFFSET],
		  @ALLOC_CLOSE_RELATED = [ALLOC_CLOSE_RELATED], @RUSH_DURATION = [RUSH_DURATION],
		  @SCHEME_TYPE = [SCHEME_TYPE], @CREATED_BY = [CREATED_BY], @TIME_STAMP = [TIME_STAMP],
		  @HOUR = [HOUR], @IS_MANUAL_CLOSE = [IS_MANUAL_CLOSE], @IS_CLOSED = [IS_CLOSED]
	  FROM DELETED WHERE CREATED_BY != 'FIS'


	IF @CREATED_BY != 'FIS'
	BEGIN
		INSERT INTO [BHSDB].[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
				   ([ALLOC_TYPE]
				   ,[ACTION]
				   ,[AIRLINE]
				   ,[FLIGHT_NUMBER]
				   ,[SDO]
				   ,[RESOURCE]
				   )
			 VALUES
				   ('FLT'
				   ,'DEL'
				   ,@AIRLINE
				   ,@FLIGHT_NUMBER
				   ,@SDO
				   ,@RESOURCE
				  )
	END				    
END
GO      

USE [BHSDB]
GO
/****** Object:  Trigger [dbo].[INSERT_FUNCTION_ALLOC_LIST]    Script Date: 01/18/2010 14:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_FUNCTION_ALLOC_LIST]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_FUNCTION_ALLOC_LIST]...'
	DROP TRIGGER [INSERT_FUNCTION_ALLOC_LIST]
END
PRINT 'INFO: Creating trigger [INSERT_FUNCTION_ALLOC_LIST]...'
GO
CREATE  TRIGGER [dbo].[INSERT_FUNCTION_ALLOC_LIST] ON [dbo].[FUNCTION_ALLOC_LIST] 
AFTER INSERT
AS
BEGIN
	INSERT INTO [BHSDB].[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
			   ([ALLOC_TYPE]
			   ,[ACTION]
			   ,[FUNCTION_TYPE]
			   ,[RESOURCE]
			   )
	SELECT 'FUN', 'NEW', [FUNCTION_TYPE]
		  ,[RESOURCE]
	  FROM INSERTED
		    
END



GO
USE [BHSDB]
GO
/****** Object:  Trigger [dbo].[UPDATE_FUNCTION_ALLOC_LIST]    Script Date: 01/18/2010 14:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[UPDATE_FUNCTION_ALLOC_LIST]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [UPDATE_FUNCTION_ALLOC_LIST]...'
	DROP TRIGGER [UPDATE_FUNCTION_ALLOC_LIST]
END
PRINT 'INFO: Creating trigger [UPDATE_FUNCTION_ALLOC_LIST]...'
GO
CREATE  TRIGGER [dbo].[UPDATE_FUNCTION_ALLOC_LIST] ON [dbo].[FUNCTION_ALLOC_LIST] 
AFTER UPDATE
AS
BEGIN
	INSERT INTO [BHSDB].[dbo].[BHS_FIS_OUTGOING_ALLOCATIONS]
			   ([ALLOC_TYPE]
			   ,[ACTION]
			   ,[FUNCTION_TYPE]
			   ,[RESOURCE]
			   )
	SELECT 'FUN', 'UPD', [FUNCTION_TYPE]
		  ,[RESOURCE]
	  FROM INSERTED
		    
END




PRINT 'INFO: End of Creating New Triggers.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: End of STEP2.1'
GO















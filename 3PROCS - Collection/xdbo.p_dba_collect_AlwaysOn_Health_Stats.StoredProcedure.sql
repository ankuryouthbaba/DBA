USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_collect_AlwaysOn_Health_Stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[p_dba_collect_AlwaysOn_Health_Stats]
  @sendMail bit =0
, @ToEmail varchar(500) = ''
AS 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

/*
---- sample proc execution
EXEC [p_dba_collect_AlwaysOn_Health_Stats]
@sendMail = 1
,@ToEmail = 'DBA-Test-Email-List'

	SELECT Collection_date_time , Primary_Replica, AGGroupName, replica_server_name, DatabaseName, role_desc, synchronization_state_desc, synchronization_health_desc, log_send_queue_size
	, Log_send_rate, secondary_lag_seconds  
	--into #AlwaysOn_Status_HTML
	--FROM #AlwaysOn_Status
	FROM tempAlwaysOn_Status
	WHERE  synchronization_state_desc NOT IN ('SYNCHRONIZING','SYNCHRONIZED') 
	OR  synchronization_health_desc <> 'HEALTHY'  


*/
--variable declaration
DECLARE @RowCount INT=0
DECLARE @Max_Execution_Count INT
DECLARE @p_recipients VARCHAR(1000)
SELECT @p_recipients= info_value
FROM [tb_info] WHERE [Info_Key]=@ToEmail
		
SELECT @p_recipients = ISNULL(@p_recipients,@ToEmail) 
SELECT @p_recipients Recipient_email

--Business logic starts here
--Try Catch Block Start here
BEGIN TRY
	IF OBJECT_ID('tempdb..#AlwaysOn_Status', 'U') IS NOT NULL
	DROP TABLE #AlwaysOn_Status

SELECT top 1 @Max_Execution_Count= (ISNULL(Execution_Count,0)  + 1) FROM [t_dba_collect_AlwaysOn_Health_Stats]
ORDER BY Collection_date_time DESC

SELECT @Max_Execution_Count Execution_Count, getdate() collection_date_time
,@@servername [Primary_Replica], AGS.NAME AS AGGroupName 
    ,AR.replica_server_name 
 , db_name(DRS.database_id) DatabaseName 
    ,HARS.role_desc
    ,DRS.synchronization_state_desc , DRS.is_commit_participant,DRS.synchronization_health_desc, DRS.database_state_desc,DRS.is_suspended,DRS.suspend_reason_desc
,DRS.recovery_lsn, DRS.truncation_lsn	, DRS.last_sent_lsn	, DRS.last_sent_time	, DRS.last_received_lsn	, DRS.last_received_time	, DRS.last_hardened_lsn	
, DRS.last_hardened_time	, DRS.last_redone_lsn	, DRS.last_redone_time	, DRS.log_send_queue_size	, DRS.log_send_rate	, DRS.redo_queue_size	, DRS.redo_rate	, DRS.end_of_log_lsn	, DRS.last_commit_lsn	, DRS.last_commit_time	, DRS.secondary_lag_seconds
INTO #AlwaysOn_Status
FROM sys.dm_hadr_database_replica_states DRS
LEFT JOIN sys.availability_replicas AR ON DRS.replica_id = AR.replica_id
LEFT JOIN sys.availability_groups AGS ON AR.group_id = AGS.group_id
LEFT JOIN sys.dm_hadr_availability_replica_states HARS ON AR.group_id = HARS.group_id AND AR.replica_id = HARS.replica_id

INSERT INTO [t_dba_collect_AlwaysOn_Health_Stats] (
Execution_Count,
collection_date_time,
Primary_Replica,
AGGroupName,
replica_server_name,
DatabaseName,
role_desc,
synchronization_state_desc,
is_commit_participant,
synchronization_health_desc,
database_state_desc,
is_suspended,
suspend_reason_desc,
recovery_lsn,
truncation_lsn,
last_sent_lsn,
last_sent_time,
last_received_lsn,
last_received_time,
last_hardened_lsn,
last_hardened_time,
last_redone_lsn,
last_redone_time,
log_send_queue_size,
log_send_rate,
redo_queue_size,
redo_rate,
end_of_log_lsn,
last_commit_lsn,
last_commit_time,
secondary_lag_seconds)
SELECT * FROM #AlwaysOn_Status

--Business logic Ends here 

--Send email logic starts here 
IF (@sendMail =0) 
SELECT * FROM #AlwaysOn_Status 

IF (@sendMail =1)
BEGIN
	IF OBJECT_ID('tempdb..#AlwaysOn_Status_HTML', 'U') IS NOT NULL
	DROP TABLE #AlwaysOn_Status_HTML

--Creates table which will be used in the html for send dbmail

	SELECT Collection_date_time , Primary_Replica, AGGroupName, replica_server_name, DatabaseName, role_desc, synchronization_state_desc, synchronization_health_desc, log_send_queue_size
	, Log_send_rate, secondary_lag_seconds  
	into #AlwaysOn_Status_HTML
	FROM #AlwaysOn_Status
	--FROM tempAlwaysOn_Status
	WHERE  synchronization_state_desc NOT IN ('SYNCHRONIZING','SYNCHRONIZED') 
	OR  synchronization_health_desc <> 'HEALTHY'  


	SELECT @RowCount= @@ROWCOUNT

----EXIT IF THERE IS NOTHING TO BE SENT IN THE EMAIL. 
	IF @RowCount = 0
		RETURN		

--If there are rows present in the table. Continue with following
--Declare variables
		DECLARE @P_SERVERNAME VARCHAR(100)
		DECLARE @p_subject	  VARCHAR(500) 
		DECLARE @Profile_Name VARCHAR(100)
		DECLARE @Subject_AlwaysOn_Status VARCHAR(500)='!!! AlwaysOn - Not Healthy Status !!!'	--Variable 
		DECLARE @Html_Title_AlwaysOn_Status VARCHAR(500)='Table Showing AlwaysOn Status information per database'	--Variable 

		DECLARE @Html VARCHAR(5000)
		DECLARE @Html_Title VARCHAR(5000)
		DECLARE @Html_AlwaysOn_Status VARCHAR(5000)
		DECLARE @SQL_Text_AlwaysOn_Status VARCHAR(5000)

--assign values to variables to be used in Sp_send_dbmail

		SELECT @P_SERVERNAME = info_value FROM [tb_info] WHERE [Info_Key] = 'SERVERNAME'
		SELECT @Profile_Name= info_value FROM [tb_info] WHERE [Info_Key]= 'Current-DBA-Profile-Name'
		SELECT @SQL_Text_AlwaysOn_Status =  'SELECT  * FROM #AlwaysOn_Status_HTML'

		SELECT @p_subject =  @P_SERVERNAME +' (Alert) --'+ @Subject_AlwaysOn_Status + '('+ 'DBA Mail -'+' ' + CONVERT(VARCHAR, getdate(), 9) + ')'
		SELECT @Html_Title = '<html><p><u><strong><span style="background-color:#eeeeee;"> '+ @Html_Title_AlwaysOn_Status +'</span></strong></u></p> <br> </body></html>'

--Converts the output to html format with the help of Proc
		EXECUTE  dbo.p_DBA_ConvertTableToHtml @SQL_Text_AlwaysOn_Status,@Html_AlwaysOn_Status OUTPUT   

		SELECT @Html  = @Html_Title + @Html_AlwaysOn_Status 

		EXEC msdb.dbo.SP_SEND_DBMAIL
				@Profile_name=@Profile_Name
				,@recipients	= @p_recipients 
				,@subject		= @p_subject
				,@body		= @Html
				,@body_format = 'html'	

--Send email logic Ends here 
	END

END TRY
BEGIN CATCH	
	EXEC p_dba_Call_SqlErrorlog @ObjectID = @@PROCID;

END CATCH----Try Catch Block End Here






GO

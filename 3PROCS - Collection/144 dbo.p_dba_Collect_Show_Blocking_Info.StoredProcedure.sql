-- 14 [p_dba_Collect_Show_Blocking_Info]



USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_Collect_Show_Blocking_Info]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[p_dba_Collect_Show_Blocking_Info] 
@BlockingThreshold_Seconds INT = 0
, @sendMail BIT =0
, @ToEmail VARCHAR(1000) = ''
AS
/*************************************************************************
** Name:p_dba_Collect_Show_Blocking_Info
** Desc:p_dba_Collect_Show_Blocking_Info report proc
**************************************************************************
**History

it is a standard single window Proc.

**************************************************************************
--1. Create new proc to monitor the Currently blocked process and rootblocker

EXEC p_dba_Collect_Show_Blocking_Info  
@BlockingThreshold_Seconds=5
,@SendMail=1
,@ToEmail= ''




**************************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

PRINT 'Blocking Proc Start'
--Try Catch Block Start here
 BEGIN TRY

 --Variable declaration
 --Variable declaration
 --Variable declaration
 --Variable declaration
	
DECLARE @p_Rowcount INT = 0
,@p_recipients VARCHAR(1000)
,@Batch_ID uniqueidentifier  
SET @Batch_ID  = NEWID() 

--PRINT @Batch_ID

SELECT @p_recipients= info_value
FROM [tb_info] WHERE [Info_Key]=@ToEmail
SET @p_recipients =ISNULL(@p_recipients,@ToEmail)

SELECT @p_recipients Recipients_list

IF NOT EXISTS (SELECT 1  FROM sys.sysprocesses WHERE blocked <>0 
AND (waittime/1000) > @BlockingThreshold_Seconds)
BEGIN
	SELECT 'Currently there are no Session in Blocked State on Server' AS [Message]
	RETURN
END

 --Variable declaration
 --Variable declaration
 --Variable declaration
 --Variable declaration



--Business logic start here 
--Business logic start here 
--Business logic start here 
--Business logic start here 

IF OBJECT_ID('tempdb..#temp_Blocking_Info') IS NOT NULL
    DROP TABLE #temp_Blocking_Info
IF OBJECT_ID('tempdb..#temp_Blocking_Info_Final') IS NOT NULL
    DROP TABLE #temp_Blocking_Info_Final



----- first part to identify the root blocker and blocked processes. 

SELECT * INTO #temp_Blocking_Info FROM 
(
SELECT DISTINCT blocked AS SessionID, 0 AS BlockedBy, 'Root Blocker' AS [Description],dbid,cmd,lastwaittype,waitresource,waittime
FROM SYS.SYSPROCESSES s
WHERE blocked NOT IN
(SELECT spid FROM SYS.SYSPROCESSES WHERE blocked <>0) AND blocked<>0
UNION 
SELECT DISTINCT spid AS SessionID, blocked  AS BlockedBy, 'blocked sessions'  AS [Description],dbid,cmd,lastwaittype,waitresource,waittime
FROM SYS.SYSPROCESSES WHERE blocked <>0 AND (waittime/1000) > @BlockingThreshold_Seconds
) A

PRINT 'Blocking spid Captured with RootBlocker'

--- second part to collect the data to be sent on email 
--- second part to collect the data to be sent on email 
SELECT TB.SessionID
,TB.BlockedBy
,TB.[Description] [Description]
,COALESCE(er.STATUS, ss.STATUS) Session_status
,COALESCE(DB_NAME(er.database_id),DB_NAME(TB.dbid)) [Database]	
,ISNULL(OBJECT_NAME(esql.[ObjectId],COALESCE(er.database_id,TB.dbid)), 'AdhocQuery/NA') [Object]
,ss.original_login_name AS [Login]
,ss.Host_Name [Host]
,ss.Program_Name  [Program]
,COALESCE(er.command,TB.cmd) Command
,COALESCE(er.last_wait_type,TB.lastwaittype) Last_Wait_Type
,COALESCE(er.wait_resource,TB.waitresource) Wait_Resource
,COALESCE((er.wait_time/1000),(TB.waittime/1000)) [wait_time (sec)]
,COALESCE(er.reads, ss.reads) + COALESCE(er.writes, ss.writes) + COALESCE(er.logical_reads, ss.logical_reads ) AS Total_IO
,COALESCE(er.cpu_time, ss.cpu_time) [CPU]
,COALESCE(er.reads, ss.reads) Reads
,COALESCE(er.writes, ss.writes) Writes
,COALESCE(er.logical_reads, ss.logical_reads ) Logical_Reads
,ISNULL(er.Percent_Complete,0) Percent_Complete
,COALESCE(er.Total_elapsed_time/(1000*60),ss.Total_elapsed_time) [Elapsed_Time(Min)]
,ss.Last_request_start_time
,ss.Login_time
,er.Open_Transaction_Count
,CASE er.transaction_isolation_level WHEN 0 THEN 'Unspecified' WHEN 1 THEN 'ReadUncomitted' WHEN 2 THEN 'ReadCommitted' WHEN 3 THEN 'Repeatable' WHEN 4 THEN 'Serializable' WHEN 5 THEN 'Snapshot' END [Isolation_level]  
,LEFT((SUBSTRING(esql.[text],ISNULL(er.statement_start_offset,0) / 2+1 , 
( (CASE WHEN ISNULL(er.statement_end_offset,0) = -1 
	THEN (LEN(CONVERT(VARCHAR(MAX),esql.[text])) * 2) 
		ELSE ISNULL(er.statement_end_offset,0) END)  - ISNULL(er.statement_start_offset,0)) / 2+1)),3000)  AS [Executeing_sql] 
,@Batch_ID AS Batch_ID
,er.session_id AS er_session_id
,er.blocking_session_id erblocking_session_id 
,owt.Resource_description
,esql.[ObjectId]
,ss.Last_Request_End_Time
,TB.waittime [Wait_Time(ms)]
,(er.Estimated_Completion_Time/60000) [ETA (Min)] 
,LEFT(esql.[text],3000) [Full_Text] 
INTO #temp_Blocking_Info_Final
FROM #temp_Blocking_Info TB 
LEFT JOIN SYS.DM_EXEC_SESSIONS AS ss  ON TB.sessionID = ss.session_id
LEFT JOIN  SYS.DM_EXEC_REQUESTS er ON er.session_id=TB.sessionid 
LEFT JOIN  SYS.DM_OS_WAITING_TASKs owt ON owt.session_id=TB.sessionid 
OUTER APPLY SYS.DM_EXEC_SQL_TEXT(er.SQL_HANDLE) AS esql 


SET @p_Rowcount = @@ROWCOUNT

PRINT 'Insert BlockingInfo into Table'

IF @p_Rowcount=0
BEGIN
	SELECT 'Currently there are no Session in Blocked State on Server' AS [Message]
	RETURN
END

--Business logic Ends here 
--Business logic Ends here 
--Business logic Ends here 
--Business logic Ends here 



--INSERT The Blocking row into log table
--INSERT The Blocking row into log table
IF @p_Rowcount>0
	BEGIN
		INSERT INTO [t_dba_Blocking_Info]
		(SessionID
		,BlockedBy
		,[Description]
		,Session_status
		,[Database]
		,[Object]
		,Login
		,[Host]
		,[Program]
		,command
		,last_wait_type
		,wait_resource
		,[wait_time (sec)]
		,Total_IO
		,CPU
		,Reads
		,Writes
		,Logical_Reads
		,Percent_Complete
		,[Elapsed_Time(Min)]
		,Last_request_start_time
		,Login_time
		,Open_Transaction_Count
		,Isolation_level
		,Executeing_sql
		,Batch_ID
		,er_session_id
		,erblocking_session_id
		,Resource_description
		,ObjectId
		,Last_Request_End_Time
		,[Wait_Time(ms)]
		,[ETA (Min)]
		,Full_Text
		)
		SELECT
		SessionID
		,BlockedBy
		,[Description]
		,Session_status
		,[Database]
		,[Object]
		,[Login]
		,[Host]
		,[Program]
		,command
		,last_wait_type
		,wait_resource
		,[wait_time (sec)]
		,Total_IO
		,Cpu
		,Reads
		,Writes
		,Logical_Reads
		,Percent_Complete
		,[Elapsed_Time(Min)]
		,Last_request_start_time
		,Login_time
		,Open_Transaction_Count
		,Isolation_level
		,Executeing_sql
		,Batch_ID
		,er_session_id
		,erblocking_session_id
		,Resource_description
		,ObjectId
		,Last_Request_End_Time
		,[Wait_Time(ms)]
		,[ETA (Min)]
		,Full_Text
		FROM 
		#temp_Blocking_Info_Final ORDER BY Last_request_start_time ASC
	END	

--INSERT The Blocking row into log table
--INSERT The Blocking row into log table



--Send email logic start here 
--Send email logic start here 
--Send email logic start here 
--Send email logic start here 

	IF @SendMail = 0
		BEGIN
			 SELECT [Description]
			,SessionID
			,CASE WHEN SessionID=BlockedBy THEN 0 ELSE BlockedBy END BlockedBy
			,Session_status
			,[Database]
			,Object
			,Login
			,Host
			,Program
			,Command
			,Last_Wait_Type
			,Wait_Resource
			,[Wait_Time (sec)]
			,Total_IO
			,Cpu
			,Reads
			,Writes
			,Logical_Reads
			,[Elapsed_Time(Min)]
			,Last_request_start_time
			,Login_time
			,Open_Transaction_Count
			,Isolation_Level
			,Executeing_sql	FROM #temp_Blocking_Info_Final
		RETURN
		END


--EXCEPTION SESSION
--EXCEPTION SESSION


--EXCEPTION SESSION
--EXCEPTION SESSION

PRINT 'Sendmail Section start'

IF (@sendMail =1)
	BEGIN
		IF (@ToEmail ='')
			BEGIN
				RAISERROR('If the value of the parameter @sendMail is 1, we need to specify email address in the @ToEmail parameter 
							else keep the @sendMail=0 and ToEmail=blank..', 16, 1) WITH NOWAIT;
			RETURN
			END
		
		IF NOT EXISTS(SELECT TOP 1 *  FROM [tb_info] WHERE ([Info_Key]=@ToEmail OR @ToEmail LIKE '%@%' )) 
				BEGIN
					RAISERROR('If the value of the parameter @sendMail is 1, we need to specify Correct email address or Correct Email List from the [tb_info] Table in the @ToEmail parameter', 16, 1)WITH NOWAIT;
				RETURN
				END	

			DECLARE @Html  VARCHAR(MAX),@Html_Title VARCHAR(MAX),@Profile_Name SYSNAME,@p_subject VARCHAR(500)
			DECLARE @p_servername VARCHAR(500),@SQL_Text_Blocking_Info VARCHAR(MAX)

			DECLARE @Html_Blocking_Info VARCHAR(MAX)
			DECLARE @Subject_Blocking_Info VARCHAR(500)=' Blocking Info(New Version) '	--Variable 
			DECLARE @Html_Title_Blocking_Info VARCHAR(500)='Table Showing Blocking Info of the server' --Variable 

			SELECT @P_SERVERNAME = info_value FROM[tb_info] WHERE [Info_Key] = 'SERVERNAME'
			SELECT @Profile_Name= info_value FROM [tb_info] WHERE [Info_Key]= 'Current-DBA-Profile-Name'



			SELECT @SQL_Text_Blocking_Info =  
			'SELECT TOP 100 PERCENT 
			 Description
			,SessionID
			,CASE WHEN SessionID=BlockedBy THEN 0 ELSE BlockedBy END BlockedBy
			,Session_status
			,[Database]
			,Object
			,Login
			,Host
			,Program
			,Command
			,Last_Wait_Type
			,Wait_Resource
			,[Wait_Time (sec)]
			,Total_IO
			,Cpu
			,Reads
			,Writes
			,Logical_Reads
			,[Elapsed_Time(Min)]
			,Last_request_start_time
			,Login_time
			,Open_Transaction_Count
			,Isolation_Level
			,LEFT(Executeing_sql,1000) Executeing_sql
		FROM #temp_Blocking_Info_Final'

			SELECT @p_subject =  @P_SERVERNAME +' (Alert) --'+ @Subject_Blocking_Info + '('+ 'DBA Mail -'+' ' + CONVERT(VARCHAR, GETDATE(), 9) + ')'
			SELECT @Html_Title = '<html><p><u><strong><span style="background-color:#eeeeee;"> '+ @Html_Title_Blocking_Info +'</span></strong></u></p> <br> </body></html>'

			EXECUTE  dbo.p_DBA_ConvertTableToHtml @SQL_Text_Blocking_Info,@Html_Blocking_Info OUTPUT   

			SELECT @Html  = @Html_Title + @Html_Blocking_Info 

			EXEC msdb.dbo.SP_SEND_DBMAIL
					@Profile_name=@Profile_Name
					,@recipients	= @p_recipients 
					,@subject		= @p_subject
					,@body		= @Html
					,@body_format = 'html'	
	--Send email logic Ends here
	
PRINT 'Stored Procedure End'
	END
END TRY
BEGIN CATCH	
	EXEC p_dba_Call_SqlErrorlog @ObjectID = @@PROCID;

END CATCH----Try Catch Block End Here
 
GO

-- 14 [p_dba_Collect_Show_Blocking_Info]

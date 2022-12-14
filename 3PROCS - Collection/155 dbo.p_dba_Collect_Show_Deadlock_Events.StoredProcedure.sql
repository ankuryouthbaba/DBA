-- 155 [p_dba_Collect_Show_Deadlock_Events] 


USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_Collect_Show_Deadlock_Events]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE Proc [dbo].[p_dba_Collect_Show_Deadlock_Events]
@sendMail BIT =0
, @ToEmail VARCHAR(1000) = ''
,@SessionName SYSNAME ='DBA_DeadlockEvent'
AS
/***********************************************INTRODUCTION***************************************************

Author: SE AdminDB Experts.

Purpose:	Collects information about transaction whcih are causing deadlock

Description: 
1.	The proc uses session of extended events to collect information about transactions which are causing deadlock.
2.	The proc also provides the email alert with deadlock information.

Parameters Explained:
@sendmail	----	When it is marked 1. Email is sent to the email recipients.
@Toemail	----	It contains the list of email addresses to which the email needs to be sent.
@SessionName	----	The name of the session which is used to monitor the extnded events related to deadlock.

--EXEC Admin..p_DBA_CurrentRunningTrans_For_SQL_Resource_Alert 
@sendmail	=	1
@Toemail	=	'DBA-TEST-EMAIL-LIST'
@SessionName	=	'DBA_DeadlockEvent'

History:
1. 
2. 

****************************************************************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#Events') IS NOT NULL 
DROP TABLE #Events

IF OBJECT_ID('tempdb..#t_dba_deadlock_Events') IS NOT NULL
DROP TABLE #t_dba_deadlock_Events



--PRINT 'Blocking Proc Start'
--Try Catch Block Start here
--BEGIN TRY

--Variable declaration
--Variable declaration
--Variable declaration
--Variable declaration

DECLARE @p_Rowcount INT = 0
,@p_recipients VARCHAR(1000)
,@p_servername VARCHAR(500)
,@Batch_ID UNIQUEIDENTIFIER 
SET @Batch_ID = NEWID() 


--PRINT @Batch_ID

SELECT @p_recipients= info_value
FROM [tb_info] WHERE [Info_Key]=@ToEmail
SET @p_recipients =ISNULL(@p_recipients,@ToEmail)

SELECT @p_recipients Recipients_list
SELECT @P_SERVERNAME = info_value FROM [tb_info] WHERE [Info_Key] = 'SERVERNAME'

--DECLARE @SessionName SYSNAME 
--SELECT @SessionName = 'system_health'

--Variable declaration
--Variable declaration
--Variable declaration
--Variable declaration



--Business logic Start here 
--Business logic Start here 
--Business logic Start here 
--Business logic Start here 


DECLARE @Target_File VarChar(1000)
, @Target_Dir VarChar(1000)
, @Target_File_WildCard VarChar(1000)

SELECT TOP 1 @Target_File = CAST(t.target_data as XML).value('EventFileTarget[1]/File[1]/@name', 'NVARCHAR(256)')
FROM sys.dm_xe_session_targets t
INNER JOIN sys.dm_xe_sessions s ON s.address = t.event_session_address
WHERE s.name = @SessionName
AND t.target_name = 'event_file'
Order by create_time desc
select @Target_File

SELECT @Target_Dir = LEFT(@Target_File, Len(@Target_File) - CHARINDEX('\', REVERSE(@Target_File))) 

SELECT @Target_File_WildCard = @Target_Dir + '\' + 'DBA_DeadlockEvent' + '_*.xel'
select @Target_File_WildCard
--Keep this as a separate table because it's called twice in the next query. You don't want this running twice.
SELECT DeadlockGraph = CAST(event_data AS XML)
, DeadlockID = Row_Number() OVER(ORDER BY file_name, file_offset)
INTO #Events
FROM sys.fn_xe_file_target_read_file(@Target_File_WildCard, null, null, null) AS F
WHERE event_data like '<event name="xml_deadlock_report%'

;WITH Victims AS
(
SELECT VictimID = Deadlock.Victims.value('@id', 'varchar(50)')
, e.DeadlockID 
FROM #Events e
CROSS APPLY e.DeadlockGraph.nodes('/event/data/value/deadlock/victim-list/victimProcess') as Deadlock(Victims)
)
, DeadlockObjects AS
(
SELECT DISTINCT e.DeadlockID
, ObjectName = Deadlock.Resources.value('@objectname', 'nvarchar(256)')
, indexname=Deadlock.Resources.value('@indexname', 'varchar(500)')
FROM #Events e
CROSS APPLY e.DeadlockGraph.nodes('/event/data/value/deadlock/resource-list/*') as Deadlock(Resources)
)
SELECT * INTO #t_dba_deadlock_Events
FROM
(
SELECT e.DeadlockID
, TransactionTime = Deadlock.Process.value('@lasttranstarted', 'datetime')
, DeadlockGraph
, DeadlockObjects = substring((SELECT (', ' + o.ObjectName)
FROM DeadlockObjects o
WHERE o.DeadlockID = e.DeadlockID
ORDER BY o.ObjectName
FOR XML PATH ('')
), 3, 4000)
, Victim = CASE WHEN v.VictimID IS NOT NULL 
THEN 1 
ELSE 0 
END
, SPID = Deadlock.Process.value('@spid', 'INT')
, ProcedureName = Deadlock.Process.value('executionStack[1]/frame[1]/@procname[1]', 'varchar(500)')
, LockMode = Deadlock.Process.value('@lockMode', 'char(1)')
, Code = Deadlock.Process.value('executionStack[1]/frame[1]', 'varchar(1000)')
, ClientApp = CASE LEFT(Deadlock.Process.value('@clientapp', 'varchar(500)'), 29)
WHEN 'SQLAgent - TSQL JobStep (Job '
THEN 'SQLAgent Job: ' + (SELECT name FROM msdb..sysjobs sj WHERE substring(Deadlock.Process.value('@clientapp', 'varchar(500)'),32,32)=(substring(sys.fn_varbintohexstr(sj.job_id),3,100))) + ' - ' + SUBSTRING(Deadlock.Process.value('@clientapp', 'varchar(500)'), 67, len(Deadlock.Process.value('@clientapp', 'varchar(500)'))-67)
ELSE Deadlock.Process.value('@clientapp', 'varchar(500)')
END 
, HostName = Deadlock.Process.value('@hostname', 'varchar(500)')
, LoginName = Deadlock.Process.value('@loginname', 'varchar(500)')
, InputBuffer = Deadlock.Process.value('inputbuf[1]', 'varchar(1000)')
, indexname=substring((SELECT (', ' + o.indexname)
FROM DeadlockObjects o
WHERE o.DeadlockID = e.DeadlockID
ORDER BY o.ObjectName
FOR XML PATH ('')
), 3, 4000)
, waitresource=Deadlock.process.value('@waitresource', 'varchar(500)')
, waittime=Deadlock.Process.value('@waittime', 'varchar(500)')
, transactionname=Deadlock.Process.value('@transactionname', 'varchar(500)')
, status=Deadlock.Process.value('@status', 'varchar(500)')
, lastbatchstarted=Deadlock.Process.value('@lastbatchstarted', 'varchar(500)')
, lastbatchcompleted=Deadlock.Process.value('@lastbatchcompleted', 'varchar(500)')
, isolationlevel=Deadlock.Process.value('@isolationlevel', 'varchar(500)')
, currentdb=Deadlock.Process.value('@currentdb', 'varchar(500)')
, requestType=Deadlock.Process.value('@requestType', 'varchar(500)')

FROM #Events e
CROSS APPLY e.DeadlockGraph.nodes('/event/data/value/deadlock/process-list/process') as Deadlock(Process)
LEFT JOIN Victims v ON v.DeadlockID = e.DeadlockID AND v.VictimID = Deadlock.Process.value('@id', 'varchar(50)')
) X --In a subquery to make filtering easier (use column names, not XML parsing), no other reason
WHERE DeadlockID IN (SELECT TOP 1 DeadlockID FROM #Events ORDER BY DeadlockID DESC)


SET @p_Rowcount = @@ROWCOUNT

IF @p_Rowcount=0
BEGIN
SELECT 'Currently there are no deadlock session on Server' AS [Message]
RETURN
END

--Business logic Ends here 
--Business logic Ends here 
--Business logic Ends here 
--Business logic Ends here 

--INSERT The deadlock event into log table
--INSERT The deadlock event into log table
INSERT INTO t_dba_deadlock_Events
(DeadlockID,TransactionTime,DeadlockGraph,DeadlockObjects,Victim,SPID,ProcedureName,LockMode,Code,ClientApp,HostName
,LoginName,InputBuffer,IndexName,WaitResource,WaitTime,TransactionName,[Status],LastBatchStarted,LastBatchCompleted,IsolationLevel,CurrentDB,RequestType)
SELECT DeadlockID,TransactionTime,DeadlockGraph,DeadlockObjects,Victim,SPID,ProcedureName,LockMode,Code,ClientApp,HostName
,LoginName,InputBuffer,IndexName,WaitResource,WaitTime,TransactionName,[Status],LastBatchStarted,LastBatchCompleted,IsolationLevel,CurrentDB,RequestType
FROM #t_dba_deadlock_Events



IF @sendMail=0
BEGIN
SELECT t.DeadlockID,t.TransactionTime,t.DeadlockObjects,t.Victim,t.SPID,d.Name DBName ,t.ProcedureName,t.LockMode,t.Code,t.ClientApp,t.HostName
,t.LoginName,t.InputBuffer,t.IndexName,t.WaitResource,t.WaitTime,t.TransactionName,t.[Status],t.LastBatchStarted,t.LastBatchCompleted
,t.IsolationLevel,t.RequestType
FROM #t_dba_deadlock_Events t
LEFT JOIN SYS.DATABASES d ON t.CurrentDB=d.database_id ORDER BY Victim DESC
RETURN
END

--INSERT The deadlock event into log table
--INSERT The deadlock event into log table

--Send email logic start here 
--Send email logic start here 
--Send email logic start here 
--Send email logic start here 

DECLARE @Html VARCHAR(MAX),@Html_Title VARCHAR(MAX),@Profile_Name SYSNAME,@p_subject VARCHAR(500)
,@SQL_Text_Deadlock_Events_Html VARCHAR(MAX),@Html_Title_Events_XMLGraph VARCHAR(MAX)
DECLARE @XMLReport VARCHAR(MAX)

DECLARE @Html_Deadlock_Events VARCHAR(MAX)
DECLARE @Subject_Deadlock_Events VARCHAR(500)=' Deadlock_Events (New) '	--Variable 
DECLARE @Html_Title_Deadlock_Events VARCHAR(500)=' A deadlock has occurred, please review the Table... '--Variable 
DECLARE @Html_Title_Deadlock_Events_XMLGraph VARCHAR(500)=' A deadlock has occurred, please review the XMLGraph Report... '--Variable 


SELECT @Profile_Name= info_value FROM [tb_info] WHERE [Info_Key]= 'Current-DBA-Profile-Name'


SELECT t.DeadlockID,t.TransactionTime,t.DeadlockObjects,t.Victim,t.SPID,d.Name DBName ,t.ProcedureName,t.LockMode,t.Code,t.ClientApp,t.HostName
,t.LoginName,t.InputBuffer,t.IndexName,t.WaitResource,t.WaitTime,t.TransactionName,t.[Status],t.LastBatchStarted,t.LastBatchCompleted
,t.IsolationLevel,t.RequestType INTO #t_dba_deadlock_Events_HTML
FROM #t_dba_deadlock_Events t
LEFT JOIN SYS.DATABASES d ON t.CurrentDB=d.database_id


SELECT @SQL_Text_Deadlock_Events_Html ='SELECT * FROM #t_dba_deadlock_Events_HTML' 

SELECT @p_subject = @P_SERVERNAME +' (Alert) --'+ @Subject_Deadlock_Events + '('+ 'DBA Mail -'+' ' + CONVERT(VARCHAR, GETDATE(), 9) + ')'
SELECT @Html_Title = '<html><p><u><strong><span style="background-color:#eeeeee;"> '+ @Html_Title_Deadlock_Events +'</span></strong></u></p> <br> </body></html>'
SELECT @Html_Title_Events_XMLGraph = '<html><p><u><strong><span style="background-color:#eeeeee;"> '+ @Html_Title_Deadlock_Events_XMLGraph +'</span></strong></u></p> <br> </body></html>'

EXECUTE dbo.p_DBA_ConvertTableToHtml @SQL_Text_Deadlock_Events_Html,@Html_Deadlock_Events OUTPUT 

SELECT TOP 1 @XMLReport = CAST(DeadlockGraph AS VARCHAR(MAX))
FROM #t_dba_deadlock_Events 
WHERE Victim=1




SET @Html_Deadlock_Events = REPLACE(@Html_Deadlock_Events,'&lt;','<')
SET @Html_Deadlock_Events = REPLACE(@Html_Deadlock_Events,'&gt;','>')

SET @XMLReport = REPLACE(REPLACE(@XMLReport,'&lt;','<'),'<','[')
SET @XMLReport = REPLACE(REPLACE(@XMLReport,'&gt;','>'),'>',']')


SELECT @Html = @Html_Title + @Html_Deadlock_Events+ @Html_Title_Events_XMLGraph + @XMLReport

EXEC msdb.dbo.SP_SEND_DBMAIL
@Profile_name=@Profile_Name
,@recipients	= @p_recipients 
,@subject	= @p_subject
,@body	= @Html
,@body_format = 'html'	


--Send email logic END here 
--Send email logic END here 
--Send email logic END here 
--Send email logic END here 

--END TRY
--BEGIN CATCH	
--EXEC p_dba_Call_SqlErrorlog @ObjectID = @@PROCID;

--END CATCH----Try Catch Block End Here

GO

-- 155 [p_dba_Collect_Show_Deadlock_Events] 

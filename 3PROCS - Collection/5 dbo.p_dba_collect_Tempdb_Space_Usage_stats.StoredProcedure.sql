-- 5 [p_dba_collect_Tempdb_Space_Usage_stats]

USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_collect_Tempdb_Space_Usage_stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [dbo].[p_dba_collect_Tempdb_Space_Usage_stats]
@SendMail BIT=0
,@ToEmail VARCHAR(100)='DBA-Process-TempdbSpaceUsage-Email-List'
,@TotalIO INT = 100000
,@Limit_Sec INT=60
,@Query_Allocation_MB INT=2048
AS 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

/***********************************************INTRODUCTION***************************************************
	
Author:                SE AdminDB Experts.

Purpose:              Collects information about space stats for Tempdb by currently running transactions.
						
Description:  
1.				This proc uses the SQL DMVs to collect information about tempdb space consumed by currently running transactions.
2.				The Proc also shows the information by sending email alert to inform recipients about transactions which are responsible for taking large space in Tempdb.
3.				The proc also collects the information about temp DB space usage in t_dba_collect_Tempdb_Space_Usage_stats for future records.


Parameters Explained:
@sendmail				----		When it is marked 1 then email needs tobe sent. If it is marked 0 then email needs not to be sent.
@Toemail				----		It contains the list of email addresses to which the email needs to be sent.
@Limit_sec				----		It contains the time in sec. all transactions which are running mroe than @Limit_sec are taken into account by Proc. 
@TotalIO				----		It contains the amount total IO consumed by query. Only queries whcih are consuming more than @TotalIO are taken into account.
@Query_Allocation_MB	----		It contains the task dellocation pages in MB. Queries which aaconsume more than @Query_Allocation_MB are taken into account.

EXEC ADMIN.dbo.p_dba_collect_Tempdb_Space_Usage_stats 
@SendMail=1
,@ToEmail='DBA-TEST-EMAIL-LIST'
,@Limit_Sec=10
,@TotalIO =10000
,@Query_Allocation_MB=20


History:
1.            
2.            

****************************************************************************************************************/

DECLARE @P_SERVERNAME VARCHAR(500)
SELECT @P_SERVERNAME = INFO_VALUE FROM TB_INFO WHERE INFO_KEY = 'SERVERNAME'

DECLARE @Max_Execution_Count INT
SELECT TOP 1 @Max_Execution_Count=(ISNULL(Execution_Count,0)+1) FROM dbo.t_dba_collect_Tempdb_Space_Usage_stats
ORDER BY [Row_Number] DESC

IF NOT EXISTS( SELECT TOP 1 1 FROM dbo.t_dba_collect_Tempdb_Space_Usage_stats)
SET @Max_Execution_Count=1

INSERT INTO dbo.t_dba_collect_Tempdb_Space_Usage_stats (
Session_id,
Request_Id,
Task_Alloc_MB,
Task_Dealloc_MB,
Database_Name,
ProgramName,
Hostname,
Start_Time,
Duration_In_Seconds,
Command,
Open_Transaction_Count,
Percent_Complete,
Estimated_Completion_Time,
Cpu_Time,
Total_Elapsed_Time,
Reads,
Writes,
Logical_Reads,
Granted_Query_Memory,
Query_Text,
Query_Plan,
Execution_Count,
Login_Name,
[Object_Name])

SELECT TOP 5
 tsu.Session_id, tsu.Request_Id, 
 task_alloc_MB = CAST((tsu.task_alloc_pages * 8/1024) AS NUMERIC(10,1)),
 task_dealloc_MB = CAST((tsu.task_dealloc_pages * 8/1024) AS NUMERIC(10,1)),
 DB_NAME(er.database_id) AS [Database_Name],
  s1.PROGRAM_NAME [ProgramName],
  Hostname= CASE WHEN tsu.session_id <= 50 THEN 'SYS' ELSE s1.HOST_NAME END,
 er.Start_Time, DATEDIFF(SS,er.start_time,GETDATE()) Duration_In_Seconds, er.Command, er.Open_Transaction_Count
 , er.Percent_Complete, er.Estimated_Completion_Time, er.Cpu_Time, er.Total_Elapsed_Time, er.Reads,er.Writes, 
er.Logical_Reads, er.Granted_Query_Memory,
 COALESCE((SELECT SUBSTRING([text], statement_start_offset/2 + 1,
  (CASE WHEN statement_end_offset = -1
   THEN LEN(CONVERT(VARCHAR(MAX), [text])) * 8
   ELSE statement_end_offset
   END - statement_start_offset) / 2
  )
  FROM sys.dm_exec_sql_text(er.[sql_handle])) , 'Not currently executing') AS Query_Text
  ,qp.Query_Plan
  ,@Max_Execution_Count AS Execution_Count
  ,s1.login_name
  , CASE WHEN ISNULL(OBJECT_NAME(qp.objectid, qp.DBID),'') = '' THEN 'NA'--'AD-HOC Query'
		ELSE OBJECT_NAME(qp.objectid, qp.DBID) END
FROM
 (SELECT session_id, request_id,
  SUM(internal_objects_alloc_page_count + user_objects_alloc_page_count) as task_alloc_pages,
  SUM(internal_objects_dealloc_page_count + user_objects_dealloc_page_count) as task_dealloc_pages
  FROM sys.dm_db_task_space_usage
  GROUP BY session_id, request_id) AS tsu
 INNER JOIN sys.dm_exec_requests AS er ON tsu.session_id = er.session_id AND tsu.request_id = er.request_id
 OUTER APPLY sys.dm_exec_query_plan(er.[plan_handle]) AS qp
 LEFT JOIN sys.dm_exec_sessions AS s1 ON    tsu.session_id=s1.session_id
WHERE 
tsu.session_id > 50  
--AND database_id > 1
AND DATEDIFF(SS,er.start_time,GETDATE()) > @Limit_Sec
AND er.session_id <> @@SPID
AND (er.reads + er.writes + er.logical_reads) > @TotalIO
AND (er.wait_type <> 'TRACEWRITE' or er.Last_wait_type <> 'TRACEWRITE' ) 
AND command NOT IN ('BRKR TASK','DB MIRROR') -- , 'UPDATE STATISTIC','CREATE INDEX')
--AND (command NOT LIKE 'DBCC%' 
--AND command NOT LIKE 'ALTER Index%' 
--AND command NOT LIKE 'RESTORE%' 
--AND command NOT LIKE 'BACKUP%')
--AND DB_NAME(er.database_id) NOT IN ('Admin','msdb','distribution')
--AND (qp.[text] NOT LIKE  '%sp_replcmds%' 
--AND qp.[text] NOT LIKE  '%xp_cmdshell%')
AND (CAST((tsu.task_alloc_pages * 8/1024) AS NUMERIC(10,1)))> @Query_Allocation_MB
ORDER BY tsu.task_alloc_pages DESC

IF @@ROWCOUNT > 0
	BEGIN	
		SELECT TOP 5
		IDENTITY(INT,1,1) SrNo
		,Session_id [Session id]
		,Login_Name [Login Name]
		,Database_Name [Database Name]
		,ProgramName [Program Name]
		,[Object_Name]  [Procedure Name]
		,Hostname [Host Name]
		,Task_alloc_mb
		,Task_Dealloc_mb
		,(Task_alloc_mb-Task_Dealloc_mb) [Space Used(MB)]--Task_Memory_Usage_MB
		,Start_Time [Session Login Time]
		,Duration_In_Seconds [Query Duration(Sec)]
		,Command
		--,Percent_Complete
		--,Estimated_Completion_Time
		--,Cpu_Time
		--,Total_Elapsed_Time
		--,(Reads+Writes+Logical_Reads) Total_IO
		--,Logical_Reads
		--,Granted_Query_Memory
		,CAST([Query_Text] AS VARCHAR(MAX))  [Query Text]
		INTO #Query_Detail
		FROM t_dba_collect_Tempdb_Space_Usage_stats
		WHERE Date_Time > DATEADD(MINUTE, -6, GETDATE()) --AND (Task_alloc_mb+Task_Dealloc_mb)> 1024
		AND Execution_Count=@Max_Execution_Count
		ORDER BY (Task_alloc_mb-Task_Dealloc_mb) DESC
		
		
		SELECT * FROM #Query_Detail
		
		
/*First HTML Block Starts: Tempdb files uses Details*/

		DECLARE @Html AS VARCHAR(MAX),@Profile_Name SYSNAME,@HtmlFillerTable VARCHAR(MAX)='<HTML><BR></HTML>'
		,@Html_1 AS VARCHAR(MAX)=''
		
		CREATE TABLE [dbo].[#dbsize]
		(
		[TYPE] [TINYINT] NOT NULL,
		[FILE_Name] [SYSNAME] NOT NULL,
		[FILESPACE_MB]  NUMERIC(10,2) NULL,
		[USEDSPACE_MB] NUMERIC(10,2) NULL,
		[FREESPACE_MB] NUMERIC(10,2) NULL,
		[USEDSPACE_%]  NUMERIC(10,2) NULL
		) 
		
		INSERT INTO #dbsize ([FILE_Name],[FILESPACE_MB],[USEDSPACE_MB],[FREESPACE_MB],[USEDSPACE_%],[TYPE])
		EXEC 
		(
		'USE Tempdb
		SELECT 
		[FILE_Name] = A.name
		,[FILESPACE_MB]  = CONVERT(NUMERIC(10,2),A.SIZE/128.0)
		,[USEDSPACE_MB] = CONVERT(NUMERIC(10,2),A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0))
		,[FREESPACE_MB] = CONVERT(NUMERIC(10,2),A.SIZE/128.0 -  CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0)
		,[USEDSPACE_%]  = CONVERT(NUMERIC(10,2),((A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0))/(A.SIZE/128.0))*100)
		--,[FREESPACE_%]  = CONVERT(NUMERIC(10,2)),((A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0)/(A.SIZE/128.0))*100)
		,[TYPE] = A.TYPE
		FROM tempdb.sys.database_files A
		ORDER BY A.TYPE ASC')


		DECLARE @DATAFILESIZE NUMERIC(10,2)
		,@LogFILESIZE NUMERIC(10,2)
		,@TOTALFILESIZE NUMERIC(10,2)

		SET @DATAFILESIZE=(SELECT SUM(USEDSPACE_MB) FROM #dbsize WHERE Type=0)
		SET @LogFILESIZE=(SELECT SUM(USEDSPACE_MB) FROM #dbsize WHERE  Type=1)
		SET @TOTALFILESIZE=(SELECT SUM(USEDSPACE_MB) FROM #dbsize)

		IF @DATAFILESIZE	<=0	SET @DATAFILESIZE	=0.05
		IF @LogFILESIZE		<=0	SET @LogFILESIZE	=0.05
		IF @TOTALFILESIZE	<=0	SET @TOTALFILESIZE	=0.10
		
		SELECT 	
		IDENTITY(INT,2,1) SrNo
		,CASE WHEN TYPE=0 THEN 'DataFilesSize'
		 ELSE 'LogFilesSize' END [Description]		
		,SUM(FILESPACE_MB) AS FILESPACE_MB
		,CASE WHEN TYPE = 0 THEN CAST((@DATAFILESIZE) AS NUMERIC(25,2))
			  WHEN TYPE=1 THEN CAST((@LogFILESIZE)  AS NUMERIC(25,2)) END [USEDSPACE_MB]
		,CASE WHEN TYPE = 0 THEN CAST((@DATAFILESIZE/(SUM(FILESPACE_MB))*100) AS NUMERIC(25,2))
			  WHEN TYPE=1 THEN CAST((@LogFILESIZE/(SUM(FILESPACE_MB))*100)  AS NUMERIC(25,2)) END [USEDSPACE_%]
		INTO #TempdbFilestatus
		FROM #dbsize
		GROUP BY TYPE
		
/*Update t_dba_collect_Tempdb_Space_Usage_stats table for tempdb info at that time for future use */

		DECLARE @SpaceUsed_DataFile NUMERIC(25,2),@SpaceUsed_LogFile NUMERIC(25,2)
		SELECT @SpaceUsed_DataFile=[USEDSPACE_%] FROM #TempdbFilestatus WHERE [Description]='DataFilesSize'
		SELECT @SpaceUsed_LogFile=[USEDSPACE_%] FROM #TempdbFilestatus WHERE [Description]='LogFilesSize'
		
		UPDATE t_dba_collect_Tempdb_Space_Usage_stats
		SET [%SpaceUsed_DataFile]=@SpaceUsed_DataFile,[%SpaceUsed_LogFile]=@SpaceUsed_LogFile
		WHERE Execution_Count=@Max_Execution_Count
		
--insert tempdb Info in out Html table
		
		--SET IDENTITY_INSERT #TempdbFilestatus ON
		--INSERT INTO  #TempdbFilestatus(Srno,Description,TotalSpaceMB,[SpaceUsedMB],[%spaceused])
		--SELECT 1,'TempdbSize',@TotalSizeMB_Tempdb,(@DATAFILESIZE+@LogFILESIZE),(((@DATAFILESIZE+@LogFILESIZE)/(@TotalSizeMB_Tempdb))*100)
		--SET IDENTITY_INSERT #TempdbFilestatus OFF

		DECLARE @HtmlFirstTable_Title AS VARCHAR(MAX) = 
		'<html><p>
		<u>
		Tempdb OverAll Space usage by File Type
		</u>
		</p></body></html>'
		
		DECLARE @SQLText_1 AS VARCHAR(5000)='
		SELECT  TOP (100) PERCENT Description,CAST(FILESPACE_MB AS VARCHAR(50)) [FileSpace_MB]
		,CAST([USEDSPACE_MB] AS VARCHAR(50))[UsedSpace_MB]
		,CAST([USEDSPACE_%] AS VARCHAR(50))[UsedSpace_%] 
		FROM #TempdbFilestatus ORDER BY SrNo ASC'
		
		EXECUTE p_DBA_ConvertTableToHtml @SQLText_1,@Html_1 OUTPUT
		SET @Html_1=@HtmlFirstTable_Title + @Html_1+ @HtmlFillerTable		
		
--/*Second HTML Block Starts: Tempdb files Details*/

		DECLARE @Html_2 AS VARCHAR(MAX)=''
		DECLARE @HtmlSecondTable_Title AS VARCHAR(MAX) = 
		--<strong><span style="background-color:#eeeeee;">
		'<html><p>
		<u>
		All Tempdb files details and space used size in MB:
		</u>
		</p></body></html>'
		--</span></strong>
		DECLARE @SQLText_2 AS VARCHAR(5000)=
		'SELECT TOP (100) PERCENT 
		File_Name,
		CAST(FILESPACE_MB AS VARCHAR(50)) FileSpace_MB,
		CAST(USEDSPACE_MB AS VARCHAR(50)) UsedSpace_MB,
		CAST(FREESPACE_MB AS VARCHAR(50)) FreeSpace_MB,
		CAST([USEDSPACE_%] AS VARCHAR(50))[UsedSpace_%]
		FROM #dbsize
		ORDER BY TYPE ASC'
		EXECUTE p_DBA_ConvertTableToHtml @SQLText_2,@Html_2 OUTPUT

		SET @Html_2=@HtmlSecondTable_Title + @Html_2

/*Third HTML Block Starts: Tempdb Query Details*/
		
		DECLARE @Html_3 AS VARCHAR(MAX)
		DECLARE @HtmlThirdTable_Title AS VARCHAR(MAX) = 
		--<strong><span style="background-color:#eeeeee;">
		'<html><p>
		The query below is consuming more space on the tempdb. Any query consuming large space in tempdb are primarily responsible for growing the tempdb as per as a performance bottleneck.
		<BR>
		Please see if the query below can be optimized.
		<BR>
		</p></body></html>'
		--</span></strong>
		DECLARE @SQLText_3 AS VARCHAR(5000)=  'SELECT * FROM #Query_Detail'
		EXECUTE p_DBA_ConvertTableToHtml @SQLText_3,@Html_3 OUTPUT
		
		SET @Html_3=@HtmlThirdTable_Title + @Html_3+ @HtmlFillerTable

		
/*Added all HTML Block*/

		SET @Html = @Html_1 + @Html_2 + @HtmlFillerTable + @Html_3
				
		IF @SendMail=1
					BEGIN
						DECLARE @p_subject AS VARCHAR(500)=@P_SERVERNAME +' (Alert) '+ '-- TempDB critical Usage ' +  '('+ 'DBA Mail -'+' ' + CONVERT(VARCHAR, GETDATE(), 9) + ')'
						
            DECLARE @p_recipients AS VARCHAR(5000)
						SELECT @p_recipients= info_value
						FROM ADMIN..[tb_info] 
						WHERE [Info_Key]=@ToEmail
              
              Select @ToEmail, @p_recipients
							SET @p_recipients =ISNULL(@p_recipients,@ToEmail)	
              
							SELECT @p_recipients Recipients, @ToEmail ToEmail
							
							SELECT @Profile_Name= info_value
							FROM [tb_info] 
							WHERE [Info_Key]= 'Current-DBA-Profile-Name'

							EXEC msdb.dbo.SP_SEND_DBMAIL
							@Profile_name=@Profile_Name,
							@subject =@p_subject,
							@recipients = @p_recipients,
							@body = @Html,
							@body_format ='HTML',
							@importance =  'HIGH'

		END
					
	END
GO


-- 5 [p_dba_collect_Tempdb_Space_Usage_stats]


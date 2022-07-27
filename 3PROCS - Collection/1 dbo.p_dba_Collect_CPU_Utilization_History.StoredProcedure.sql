--1 [p_dba_Collect_CPU_Utilization_History]


USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_Collect_CPU_Utilization_History]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[p_dba_Collect_CPU_Utilization_History]
	@SendMail BIT = 0,@ToEmail VARCHAR(500)='DBA_TEST',
	@threshold_Avg_CPU numeric(4,2) = 70.00,
	@TopRow int=5
AS
/*************************************************************************
** Name:p_dba_Collect_CPU_Utilization_History
--** Desc:p_dba_Collect_CPU_Utilization_History report proc
**************************************************************************
**History
**************************************************************************
--@SendMail
Posible Values: 
				1 = Email send
				0 = Email not send
		
@ToEmail:To whom need to send email
Posible Values:	
				APP_ADMIN ,DBA_ADMIN,DBA_TEST
				
--EXEC Admin..p_dba_Collect_CPU_Utilization_History @SendMail=1,@ToEmail='DBA_TEST',@threshold_Avg_CPU=0
**************************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET ANSI_PADDING ON


Declare @p_servername varchar(500)
select @p_servername = info_value from tb_info where info_key = 'ServerName'

DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks)FROM sys.dm_os_sys_info); 
DECLARE @Avg_CPU_Running int,@Profile_Name sysname

--DELETING TEMPORARY TABLES INCLUDING ##columns of p_DBA_ConvertTableToHtml
IF  EXISTS (SELECT * FROM tempdb.sys.objects WHERE object_id = OBJECT_ID(N'tempdb..#CPU_Utilization_History') AND type in (N'U')) DROP TABLE [#CPU_Utilization_History]

SELECT TOP (@TopRow) SQLProcessUtilization AS SQL_Server_Process_CPU_Utilization, 
               SystemIdle AS System_Idle_Process, 
               100 - SystemIdle - SQLProcessUtilization AS Other_Process_CPU_Utilization, 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS Event_Time
INTO #CPU_Utilization_History
FROM ( 
   SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
   AS [SystemIdle], 
   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
   'int') 
   AS [SQLProcessUtilization], [timestamp] 
   FROM ( 
   SELECT [timestamp], CONVERT(xml, record) AS [record] 
   FROM sys.dm_os_ring_buffers WITH (NOLOCK)
   WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
   AND record LIKE N'%<SystemHealth>%') AS x 
   ) AS y 
ORDER BY record_id DESC
OPTION (RECOMPILE)

---INSERTING LOG TABLE
INSERT INTO Admin.dbo.t_dba_Collect_CPU_Utilization_History (
SQL_Server_Process_CPU_Utilization,
System_Idle_Process,
Other_Process_CPU_Utilization,
Event_Time)
SELECT 
SQL_Server_Process_CPU_Utilization,
System_Idle_Process,
Other_Process_CPU_Utilization,
Event_Time
FROM #CPU_Utilization_History

--AVG CPU value From TOP 5 
/*******************************************************/
	;WITH CPU_Utilization_History AS
	 ( SELECT SQL_Server_Process_CPU_Utilization,Other_Process_CPU_Utilization FROM #CPU_Utilization_History
	 )
	 SELECT @Avg_CPU_Running =ISNULL(AVG(SQL_Server_Process_CPU_Utilization + Other_Process_CPU_Utilization),0)
	 FROM CPU_Utilization_History

--PRINT @Avg_CPU_Running

		IF (@SendMail=1 AND @Avg_CPU_Running>=@threshold_Avg_CPU)
		BEGIN
	
			DECLARE @Html AS VARCHAR(MAX), @HtmlFirstTable AS VARCHAR(MAX), @HtmlSecondTable AS VARCHAR(MAX), @HtmlFillerTable VARCHAR(MAX),@SQLText2 AS VARCHAR(MAX)
			DECLARE @SQLText1 AS VARCHAR(MAX)--2k5
			SET @SQLText1 = 'SELECT CAST(Event_Time AS VARCHAR) AS Event_Time
									,SQL_Server_Process_CPU_Utilization	AS [SQL_Server_CPU_Used%]
									,Other_Process_CPU_Utilization AS [Other_Process_CPU_Used%]
									,(SQL_Server_Process_CPU_Utilization + Other_Process_CPU_Utilization) AS [Total_CPU_Used%]
									 FROM 
									 #CPU_Utilization_History'

			--SET @SQLText2 = replace(convert(varchar(max),@Report), '<', '***')

			EXECUTE ADMIN.dbo.p_DBA_ConvertTableToHtml @SQLText1,@HtmlFirstTable OUTPUT

			--REPLACING LESS THAN AND GREATER THAN AFTER HIGHLIGHTING
			SET @HtmlFirstTable = REPLACE(@HtmlFirstTable,'&lt;','<')
			SET @HtmlFirstTable = REPLACE(@HtmlFirstTable,'&gt;','>')

			SET @HtmlFillerTable = '<HTML>
			<BR>
			<BR>
			<BR>
			<BR>
			</HTML>' 
			
			----<P>' + @SQLText2 + ' </P>


			SET @Html = @HtmlFirstTable + @HtmlFillerTable 	
									
									--PRINT @HTML			
			
			
				DECLARE @p_subject AS VARCHAR(500)=@P_SERVERNAME +' (Alert) '+ '-- High CPU Utilization ' + '('+ 'DBA Mail -'+' ' + CONVERT(VARCHAR, getdate(), 9) + ')'
				DECLARE @p_recipients AS VARCHAR(5000)
SELECT @p_recipients= info_value
FROM ADMIN..[tb_info] 
WHERE [Info_Key]=@ToEmail

SET @p_recipients=ISNULL(@p_recipients,@ToEmail)

SELECT @p_recipients Recipients_list
					
					SELECT @Profile_Name= info_value
					FROM ADMIN..[tb_info] 
					WHERE [Info_Key]= 'Current-DBA-Profile-Name'

				EXEC msdb..sp_send_dbmail
				@Profile_name=@Profile_Name,
				 @recipients = @p_recipients
				,@subject = @p_subject
				,@body = @Html
				,@body_format ='html'
				,@importance = 'high'
			END
	SET NOCOUNT OFF
	SET ANSI_PADDING OFF
	
	 
	  

GO

--1 [p_dba_Collect_CPU_Utilization_History]

-- 8 [p_dba_StatsCollection_TotalCPU] 


USE [ADMIN]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_StatsCollection_TotalCPU]    Script Date: 12/16/2021 3:26:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_dba_StatsCollection_TotalCPU]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
INSERT INTO [t_dba_TotalCPU_ConsumingQueries] ([Total CPU ms] ,[Avg CPU ms],[Total Executions],[Statement Text],[Plan Handle],[Database Name],[Object Name],
	[Last Execution Time],[Query Hash],[Query Plan Hash])
SELECT TOP 100  
       SUM(Total_CPU_time_ms) AS [Total CPU ms],
       SUM(Total_CPU_time_ms)/SUM(execution_count) AS [Avg CPU ms],
       SUM(execution_count) AS [Total Executions],
       MIN(query_text) AS [Statement Text],
       MIN(plan_handle) AS [Plan Handle],
       MIN(Database_name) AS [Database Name],
       MIN(Object_name) AS [Object Name],
       MIN(last_execution_time) AS [Last Execution Time],
       query_hash AS [Query Hash],
       query_plan_hash AS [Query Plan Hash]
	FROM 
       (
          SELECT 
			   qs.total_worker_time/1000 as 'Total_CPU_time_ms',
               (qs.total_worker_time / qs.execution_count)/1000 AS 'Avg_CPU_time_ms',               
               DB_NAME(qt.dbid) AS 'Database_name',
			   ISNULL(OBJECT_NAME(qt.objectid, qt.dbid), left(qt.text,500) ) AS 'Object_name', 
               qt.[text],qs.query_hash, qs.query_plan_hash, qs.sql_handle, qs.plan_handle,
               qs.execution_count,
               qs.last_execution_time,
               SUBSTRING(qt.[text], qs.statement_start_offset/2, 
               (
                   CASE 
                       WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.[text])) * 2 
                       ELSE qs.statement_end_offset 
                   END - qs.statement_start_offset)/2 
               ) AS query_text
           FROM 
               sys.dm_exec_query_stats AS qs
               CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
			   --WHERE qt.[text] NOT LIKE '%sys.dm_exec_query_stats%' 
			   --ORDER BY [Total_CPU_time_ms] DESC
        ) AS query_stats
    WHERE [Object_Name] NOT LIKE 'p_dba_StatsCollection%'	
	GROUP BY query_hash, query_plan_hash
	ORDER BY [Total CPU ms] DESC  
   
	
GO

-- 8 [p_dba_StatsCollection_TotalCPU] 


-- 10 [p_dba_collect_proc_execution_stats] 



USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_collect_proc_execution_stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_dba_collect_proc_execution_stats] 
@DBname varchar(500) 
AS 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

DECLARE @SQLText varchar(5000)

SET @SQLText  = '
INSERT INTO admin.dbo.t_dba_collect_proc_execution_stats
SELECT	getdate (),
		db_name( database_id) AS [db_name], 
        OBJECT_NAME(object_id, database_id) AS [sp_name],
         last_execution_time, 
         execution_count,
		 cached_time,
		 total_worker_time,
		 last_worker_time,
		 min_worker_time,
		 max_worker_time,
		 total_physical_reads,
		 last_physical_reads,
		 min_physical_reads,
		 max_physical_reads,
		 total_logical_writes,
		 last_logical_writes,
		 min_logical_writes,
		 max_logical_writes,
		 total_logical_reads,
		 last_logical_reads,
		 min_logical_reads,
		 max_logical_reads,
		 total_elapsed_time,
		 last_elapsed_time,
		 min_elapsed_time,
		 max_elapsed_time
FROM sys.dm_exec_procedure_stats AS d 
WHERE db_name( database_id) = '''+  @DBname +''''

PRINT (@sqltext)

EXEC (@sqltext)

GO

-- 10 [p_dba_collect_proc_execution_stats] 

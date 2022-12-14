-- 11 [p_dba_Collect_repl_counters] 



USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_Collect_repl_counters]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--select * from Admin.dbo.t_dba_Collect_repl_counters

CREATE PROC [dbo].[p_dba_Collect_repl_counters]
AS 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
DECLARE @Max_Execution_Count INT
DECLARE @Row_Number INT 
DECLARE @date_time DATETIME
SELECT @date_time =GETDATE()
SELECT top 1 @Max_Execution_Count= (ISNULL(Execution_Count,0)  + 1) FROM Admin.dbo.t_dba_Collect_repl_counters
order by date_time desc

IF OBJECT_ID('tempdb..#t_dba_repl_counters') IS NOT NULL DROP TABLE #t_dba_repl_counters
CREATE table #t_dba_repl_counters (DatabaseName varchar(500), Replicated_Transactions int, Replication_rate_trans_sec varchar(500), Replication_Latency_sec varchar(500), replbeginlsn binary(10), replnextlsn binary(10))

INSERT INTO #t_dba_repl_counters EXEC sp_replcounters

INSERT INTO Admin.dbo.t_dba_Collect_repl_counters (
[DatabaseName],
[Replicated_Transactions],
[Replication_rate_trans_sec],
[Replication_Latency_sec],
[replbeginlsn],
[replnextlsn],
[Execution_Count],
[date_time]
) 	
SELECT [DatabaseName],
[Replicated_Transactions],
[Replication_rate_trans_sec],
[Replication_Latency_sec],
[Replbeginlsn],
[Replnextlsn],
@Max_Execution_Count AS Execution_Count,
 @date_time AS date_time
FROM #t_dba_repl_counters


--select * from #t_dba_repl_counters
--select * from t_dba_Collect_repl_counters




GO

-- 11 [p_dba_Collect_repl_counters] 

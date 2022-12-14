-- 3 p_dba_CollectIOstatsOnly


USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_CollectIOstatsOnly]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_dba_CollectIOstatsOnly] 
AS
--BEGIN TRY
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON
	DECLARE @Max_Execution_Count INT

	SELECT top 1 @Max_Execution_Count= (ISNULL(Execution_Count,0)  + 1) FROM t_dba_CollectIOstats
	order by CollectionDateTime desc

	;WITH BCHR
	AS (
	SELECT (a.cntr_value * 1.0 / ISNULL(NULLIF(b.cntr_value,0),1)) * 100.0 [BCHR] 
	FROM (SELECT cntr_value, 1 x FROM sys.dm_os_performance_counters 
	WHERE counter_name = 'Buffer cache hit ratio') a 
	,
	(SELECT cntr_value, 1 x FROM sys.dm_os_performance_counters 
	WHERE counter_name = 'Buffer cache hit ratio base')b 
	), PLE as 
	 (SELECT ([cntr_value]/60) PageLife_M, cntr_value PageLife_S  FROM sys.dm_os_performance_counters
	WHERE [counter_name] = 'Page life expectancy' AND [instance_name] LIKE ' %'
	), PRC as 
	 (SELECT COUNT(*) PRC_COUNT FROM sys.dm_io_pending_io_requests ) 

	, BPU_raw as 
	(SELECT top 1 CONVERT(DECIMAL(15,3),[cntr_value]*0.0078125) BufferPool FROM sys.dm_os_performance_counters
	WHERE [counter_name] = 'Database pages')
	, BPU_s as 
	 (SELECT CONVERT(DECIMAL(15,3),BufferPool/ISNULL(NULLIF(PLe.PageLife_S,0),1)) BufferPool_MiB_S FROM BPU_raw,PLE )
	, Page_Split as 
	  (SELECT cntr_value as PSplit FROM sys.dm_os_performance_counters WHERE counter_name like 'Page split%')
	, DEADLOCKS AS
	 (SELECT cntr_value AS NumOfDeadLocks FROM sys.dm_os_performance_counters
		WHERE object_name = 'SQLServer:Locks'
		AND counter_name = 'Number of Deadlocks/sec'   AND instance_name = '_Total')
   
	INSERT INTO t_dba_CollectIOstats (BCHR, PLE, BPU, PRC, PSplits,Deadlocks,Execution_Count)
	SELECT BCHR, PageLife_M,BufferPool_MiB_S, PRC_COUNT, Psplit ,NumOfDeadLocks	,@Max_Execution_Count AS Execution_Count
	FROM BCHR, PLE,PRC, BPU_s, Page_Split,DEADLOCKS

--END TRY
--BEGIN CATCH
	
--	EXEC p_dba_Call_SqlErrorlog @ObjectID = @@PROCID;
	
--END CATCH

GO

-- 3 p_dba_CollectIOstatsOnly

-- 6 [p_dba_collect_Wait_Stats]


USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_collect_Wait_Stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[p_dba_collect_Wait_Stats]
AS 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
DECLARE @Max_Execution_Count INT

SELECT top 1 @Max_Execution_Count= (ISNULL(Execution_Count,0)  + 1) FROM t_dba_collect_Wait_Stats
order by date_time desc


INSERT INTO t_dba_collect_Wait_Stats (
	[wait_type], 
	[waiting_tasks_count], 
	[wait_time_ms] ,
    [max_wait_time_ms] ,
    [signal_wait_time_ms],
    Execution_Count)
SELECT [wait_type], [waiting_tasks_count], [wait_time_ms],
       [max_wait_time_ms], [signal_wait_time_ms],@Max_Execution_Count AS Execution_Count 
FROM sys.dm_os_wait_stats 
WHERE wait_time_ms >0


GO

-- 6 [p_dba_collect_Wait_Stats]


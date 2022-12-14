-- 4 p_dba_collect_PLE_Counter_Stats


USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_collect_PLE_Counter_Stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROC [dbo].[p_dba_collect_PLE_Counter_Stats]
AS
/*************************************************************************
** Name:[p_dba_collect_PLE_Counter_Stats]
** Desc:[p_dba_collect_PLE_Counter_Stats] report proc
**************************************************************************
**History
**************************************************************************
1. Create new proc to monitor the Alwayson Latency of the server.

EXEC Admin..[p_dba_collect_PLE_Counter_Stats]

**************************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

--Try Catch Block Start here
BEGIN TRY

--Variable declaretion


--Business logic start here 
--Business logic start here 
--Business logic start here 

--select * from t_dba_PLE_Counter_Stats


--Logging into table start Here
--Logging into table start Here
--Logging into table start Here

INSERT INTO t_dba_PLE_Counter_Stats 
(
[Objectname]
,[CounterName]
,[CounterName_Alias]
,[InstanceName]
,[CounterValue]
)
SELECT [Object_name]
,'Page life expectancy' AS CounterName
,'Page life expectancy' AS CounterName_Alias
,instance_name
, cntr_value AS [Page Life Expectancy]
FROM SYS.DM_OS_PERFORMANCE_COUNTERS WITH (NOLOCK)
WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
AND counter_name = N'Page life expectancy' OPTION (RECOMPILE);


--Logging into table End Here
--Logging into table End Here
--Logging into table End Here

--Business logic Ends here 
--Business logic Ends here 
--Business logic Ends here 

END TRY
BEGIN CATCH	
	EXEC p_dba_Call_SqlErrorlog @ObjectID = @@PROCID;

END CATCH----Try Catch Block End Here


GO


-- 4 p_dba_collect_PLE_Counter_Stats

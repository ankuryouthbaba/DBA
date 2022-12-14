-- 9 [p_dba_collect_index_operational_stats]



USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_collect_index_operational_stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_dba_collect_index_operational_stats] 
@DBname varchar(500) ,  @minPageSize int
--@DBname varchar(500) = 'CCGS_PERF1_Coreissue'
AS 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
DECLARE @Max_Execution_Count INT
--DECLARE @database_name varchar(500) = 'CCGS_PERF1_Coreissue'
DECLARE @SQLText varchar(5000)

SET @SQLText  = '
INSERT INTO admin.dbo.t_dba_collect_index_operational_stats(
date_time, database_name, table_name, index_name,partition_number, NumberOfPages, NumberOfRows, leaf_delete_count, leaf_ghost_count
, leaf_insert_count, leaf_update_count, page_io_latch_wait_count, page_io_latch_wait_in_ms, page_latch_wait_count
, page_latch_wait_in_ms, page_lock_count, page_lock_wait_count, page_lock_wait_in_ms, range_scan_count
, row_lock_count, row_lock_wait_count, row_lock_wait_in_ms, singleton_lookup_count
)
SELECT 
getdate() Date_time,
db_name(ios.database_id) as db_name,
object_name(ios.object_id,ios.database_id) as table_name,
i.name as  index_name,
partition_number,
si.dpages NumberOfPages,
si.rowcnt NumberOfRows,
leaf_delete_count,
leaf_ghost_count,
leaf_insert_count,
leaf_update_count,
page_io_latch_wait_count,
page_io_latch_wait_in_ms,
page_latch_wait_count,
page_latch_wait_in_ms,    
page_lock_count,
page_lock_wait_count,
page_lock_wait_in_ms,
range_scan_count,
row_lock_count,
row_lock_wait_count,
row_lock_wait_in_ms,
singleton_lookup_count
from '+ @DBname + '.sys.dm_db_index_operational_stats( db_id(''' + @DBname + '''), NULL, NULL, NULL) ios
join ' + @DBname + '.sys.indexes  i on ios.object_id = i.object_id and ios.index_id = i.index_id 
join ' + @DBname + '.sys.tables t on ios.object_id = t.object_id 
join ' + @DBname + '..sysindexes  si on ios.object_id = si.id and ios.index_id = si.indid
where I.index_id <>0 --- Ignore Heaps
AND SI.dpages > ' +  convert(varchar,@minPageSize) + '	--- Ignore Heaps
 '

--PRINT (@sqltext)

EXEC (@sqltext)






GO


-- 9 [p_dba_collect_index_operational_stats]

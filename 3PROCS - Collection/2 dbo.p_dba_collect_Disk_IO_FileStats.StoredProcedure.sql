-- 2 [p_dba_collect_Disk_IO_FileStats]

USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_collect_Disk_IO_FileStats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[p_dba_collect_Disk_IO_FileStats]
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @Max_Execution_Count int
SELECT top 1 @Max_Execution_Count= (ISNULL(Execution_Count,0)  + 1) FROM Admin.dbo.t_dba_collect_Disk_IO_FileStats
ORDER BY date_time DESC

INSERT into t_dba_collect_Disk_IO_FileStats 
(
Database_Name, physical_name, io_stall_read_ms, num_of_reads, avg_read_stall_ms, io_stall_write_ms
, num_of_writes, avg_write_stall_ms, io_stalls, total_io, avg_io_stall_ms ,Execution_Count
)
SELECT DB_NAME(fs.database_id) AS [Database_Name], mf.physical_name, io_stall_read_ms, num_of_reads,
CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms],io_stall_write_ms, 
num_of_writes,CAST(io_stall_write_ms/(1.0+num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms],
io_stall_read_ms + io_stall_write_ms AS [io_stalls], num_of_reads + num_of_writes AS [total_io],
CAST((io_stall_read_ms + io_stall_write_ms)/(1.0 + num_of_reads + num_of_writes) AS NUMERIC(10,1)) 
AS [avg_io_stall_ms],@Max_Execution_Count AS Execution_Count
FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]

 

GO

-- 2 [p_dba_collect_Disk_IO_FileStats]


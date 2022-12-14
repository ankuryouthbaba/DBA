--12 [p_dba_collect_Row_Counts]




USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_collect_Row_Counts]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[p_dba_collect_Row_Counts]
AS 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
DECLARE @Max_Execution_Count INT

SELECT top 1 @Max_Execution_Count= (ISNULL(Execution_Count,0) + 1) FROM Admin.dbo.t_dba_Collect_row_counts
order by date_time desc
INSERT INTO t_dba_Collect_row_counts(
[Database_Name],[Table_Name],[Rowcount],[Total_Pages],[Data_Pages],[Used_Pages],[TotalSpaceKB],[UsedSpaceKB],[DataSpaceKB],[Execution_Count]

)
SELECT id as Database_Name, ST.name Table_Name, rowcnt as 'Rowcount'
,reserved as Total_Pages, dpages as Data_Pages,  used as Used_Pages  
,(reserved * 8)  as TotalSpaceKB
,( used * 8) as UsedSpaceKB
,(dpages*8) as DataSpaceKB,
@Max_Execution_Count AS Execution_Count 
FROM sysindexes SI join sys.tables ST on SI.id = ST.OBJECT_ID 
WHERE 1=1
--AND id = OBJECT_ID('ccard_primary') 
and indid in (0,1)
AND (reserved * 8)  > 1
ORDER BY total_pages desc
--select * from Admin.dbo.t_dba_Collect_row_counts order by 1 desc

GO

--12 [p_dba_collect_Row_Counts]

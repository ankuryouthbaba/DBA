-- 166 [p_dba_Collect_SQLErrorLog_HighSeverityErrors_Beta]




USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_Collect_SQLErrorLog_HighSeverityErrors_Beta]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_dba_Collect_SQLErrorLog_HighSeverityErrors_Beta] 
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN

 DECLARE @datetimeFrom  DATETIME
 DECLARE @datetimeTo DATETIME
 DECLARE @LastCapturedDateTime DATETIME

 
 SELECT @datetimeFrom =  DATEADD(DAY,-100,GETDATE())  
 SELECT @datetimeTo =  GETDATE() 


IF NOT EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 't_dba_SQLServerErrorLog_HighSeverityError_LastCapture')
 CREATE TABLE t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
 (
 LogDate DATETIME,
 ProcessInfo VARCHAR(200),
 Text VARCHAR(5000)
 )

TRUNCATE TABLE t_dba_SQLServerErrorLog_HighSeverityError_LastCapture


IF EXISTS (SELECT * FROM SYS.TABLES WHERE NAME = 't_dba_SQLServerErrorLog_HighSeverityError_LogDate')
 DROP TABLE t_dba_SQLServerErrorLog_HighSeverityError_LogDate


INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 0, 1, NULL, NULL, @datetimeFrom, @datetimeTo 

INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 1, 1, NULL, NULL, @datetimeFrom, @datetimeTo 

INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 2, 1, NULL, NULL, @datetimeFrom, @datetimeTo

INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 3, 1, NULL, NULL, @datetimeFrom, @datetimeTo

INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 4, 1, NULL, NULL, @datetimeFrom, @datetimeTo

INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 5, 1, NULL, NULL, @datetimeFrom, @datetimeTo

INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 6, 1, NULL, NULL, @datetimeFrom, @datetimeTo

INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 7, 1, NULL, NULL, @datetimeFrom, @datetimeTo

INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 8, 1, NULL, NULL, @datetimeFrom, @datetimeTo

INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 9, 1, NULL, NULL, @datetimeFrom, @datetimeTo

INSERT INTO t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
EXEC xp_ReadErrorLog 10, 1, NULL, NULL, @datetimeFrom, @datetimeTo


SELECT LogDate 
INTO t_dba_SQLServerErrorLog_HighSeverityError_LogDate
FROM t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
WHERE PATINDEX ('%Error:%Severity:%State:%', [text])  > 0
AND (
		--PATINDEX ('%Severity: 14%', [text])  > 0 OR
		PATINDEX ('%Severity: 15%', [text])  > 0 OR
		PATINDEX ('%Severity: 16%', [text])  > 0 OR
		--PATINDEX ('%Severity: 17%', [text])  > 0 OR 
		--PATINDEX ('%Severity: 18%', [text])  > 0 OR 
		--PATINDEX ('%Severity: 19%', [text])  > 0 OR 
		--PATINDEX ('%Severity: 20%', [text])  > 0 OR 
		PATINDEX ('%Severity: 21%', [text])  > 0 OR 
		PATINDEX ('%Severity: 22%', [text])  > 0 OR 
		PATINDEX ('%Severity: 23%', [text])  > 0 OR 
		PATINDEX ('%Severity: 24%', [text])  > 0 OR
		PATINDEX ('%Severity: 25%', [text])  > 0
	)


SELECT * FROM t_dba_SQLServerErrorLog_HighSeverityError_LastCapture
where LogDate in (SELECT LogDate FROM t_dba_SQLServerErrorLog_HighSeverityError_LogDate)

END


GO

-- 166 [p_dba_Collect_SQLErrorLog_HighSeverityErrors_Beta]


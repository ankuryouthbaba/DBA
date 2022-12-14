-- 133 [p_dba_collect_Repl_Article_information] 



USE [admin]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_collect_Repl_Article_information]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_dba_collect_Repl_Article_information]
AS 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
DECLARE @Max_Execution_Count INT

SELECT top 1 @Max_Execution_Count= (ISNULL(Execution_Count,0)  + 1) FROM t_dba_collect_Repl_Article_information
ORDER BY date_time DESC
INSERT INTO t_dba_collect_Repl_Article_information (
Execution_Count,
 publication_server  
, publisher_db  
, publication_name  
,  article  
,  destination_object  
,  subscription_server  
, subscriber_db  
,  distribution_agent_job_name
    )
-- Get the publication name based on article 
SELECT DISTINCT 
@Max_Execution_Count
,srv.srvname publication_server  
, a.publisher_db 
, p.publication publication_name 
, a.article 
, a.destination_object 
, ss.srvname subscription_server 
, s.subscriber_db 
, da.name AS distribution_agent_job_name 
FROM distribution..MSArticles a  
JOIN distribution..MSpublications p ON a.publication_id = p.publication_id 
JOIN distribution..MSsubscriptions s ON p.publication_id = s.publication_id 
JOIN  master..sysservers ss ON s.subscriber_id = ss.srvid 
JOIN  master..sysservers srv ON srv.srvid = p.publisher_id 
JOIN distribution..MSdistribution_agents da ON da.publisher_id = p.publisher_id  
     AND da.subscriber_id = s.subscriber_id and p.publication = da.publication


GO

-- 133 [p_dba_collect_Repl_Article_information] 


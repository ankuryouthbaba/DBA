USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_Collect_CPU_Utilization_History]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_Collect_CPU_Utilization_History](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[Date_time] [datetime] NOT NULL,
	[SQL_Server_Process_CPU_Utilization] [int] NULL,
	[System_Idle_Process] [int] NULL,
	[Other_Process_CPU_Utilization] [int] NULL,
	[Event_Time] [datetime] NULL,
 CONSTRAINT [PK__t_dba_Co__1DB76FDA6FD49106] PRIMARY KEY NONCLUSTERED 
(
	[Row_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_Collect_CPU_Utilization_History] ADD  DEFAULT (getdate()) FOR [Date_time]
GO

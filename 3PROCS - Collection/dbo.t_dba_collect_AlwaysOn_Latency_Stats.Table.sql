USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_collect_AlwaysOn_Latency_Stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_collect_AlwaysOn_Latency_Stats](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[Execution_Count] [int] NULL,
	[Collection_date_time] [datetime] NULL,
	[Primary_Replica] [varchar](500) NULL,
	[Secondary_Replica] [varchar](500) NULL,
	[DatabaseName] [varchar](500) NULL,
	[Latency] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_collect_AlwaysOn_Latency_Stats] ADD  DEFAULT (getdate()) FOR [Collection_date_time]
GO

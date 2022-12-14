USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_PLE_Counter_Stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_PLE_Counter_Stats](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ObjectName] [varchar](256) NULL,
	[CounterName] [varchar](256) NULL,
	[CounterName_Alias] [varchar](256) NULL,
	[CounterValue] [float] NULL,
	[InstanceName] [varchar](256) NULL,
	[CounterDateTime] [datetime] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_PLE_Counter_Stats] ADD  DEFAULT (getdate()) FOR [CounterDateTime]
GO

USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_collect_Tempdb_Space_Usage_stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_collect_Tempdb_Space_Usage_stats](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[Date_Time] [datetime] NOT NULL,
	[Session_id] [smallint] NULL,
	[Request_Id] [int] NULL,
	[Task_Alloc_MB] [bigint] NULL,
	[Task_Dealloc_MB] [bigint] NULL,
	[Database_Name] [nvarchar](500) NULL,
	[Start_Time] [datetime] NOT NULL,
	[Duration_In_Seconds] [bigint] NULL,
	[Command] [nvarchar](500) NULL,
	[Open_Transaction_Count] [int] NOT NULL,
	[Percent_Complete] [real] NOT NULL,
	[Estimated_Completion_Time] [bigint] NOT NULL,
	[Cpu_Time] [bigint] NOT NULL,
	[Total_Elapsed_Time] [bigint] NOT NULL,
	[Reads] [bigint] NOT NULL,
	[Writes] [bigint] NOT NULL,
	[Logical_Reads] [bigint] NOT NULL,
	[Granted_Query_Memory] [int] NOT NULL,
	[Query_Text] [varchar](max) NULL,
	[Query_Plan] [xml] NULL,
	[Execution_Count] [int] NULL,
	[Object_Name] [nvarchar](256) NULL,
	[Login_Name] [nvarchar](512) NULL,
	[Hostname] [nvarchar](256) NULL,
	[ProgramName] [nvarchar](256) NULL,
	[%SpaceUsed_DataFile] [numeric](25, 2) NULL,
	[%SpaceUsed_LogFile] [numeric](25, 2) NULL,
 CONSTRAINT [PK_Row_Number] PRIMARY KEY NONCLUSTERED 
(
	[Row_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_collect_Tempdb_Space_Usage_stats] ADD  DEFAULT (getdate()) FOR [Date_Time]
GO

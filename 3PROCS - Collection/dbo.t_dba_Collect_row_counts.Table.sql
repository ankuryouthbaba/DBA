USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_Collect_row_counts]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_Collect_row_counts](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[Execution_Count] [int] NULL,
	[date_time] [datetime] NOT NULL,
	[Database_Name] [varchar](500) NULL,
	[Table_Name] [varchar](500) NULL,
	[Rowcount] [bigint] NULL,
	[Total_Pages] [int] NULL,
	[Data_Pages] [int] NULL,
	[Used_Pages] [int] NULL,
	[TotalSpaceKB] [bigint] NULL,
	[UsedSpaceKB] [bigint] NULL,
	[DataSpaceKB] [bigint] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Row_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_Collect_row_counts] ADD  DEFAULT (getdate()) FOR [date_time]
GO

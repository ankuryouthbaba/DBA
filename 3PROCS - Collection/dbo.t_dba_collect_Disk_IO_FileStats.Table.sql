USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_collect_Disk_IO_FileStats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_collect_Disk_IO_FileStats](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[Minute_part] [int] NULL,
	[Hour_part] [int] NULL,
	[Week_day] [nvarchar](30) NULL,
	[Month_year] [nvarchar](30) NULL,
	[Database_Name] [nvarchar](128) NULL,
	[physical_name] [nvarchar](260) NULL,
	[io_stall_read_ms] [bigint] NULL,
	[num_of_reads] [bigint] NULL,
	[avg_read_stall_ms] [numeric](10, 1) NULL,
	[io_stall_write_ms] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[avg_write_stall_ms] [numeric](10, 1) NULL,
	[io_stalls] [bigint] NULL,
	[total_io] [bigint] NULL,
	[avg_io_stall_ms] [numeric](10, 1) NULL,
	[Execution_Count] [int] NULL,
 CONSTRAINT [PK__t_dba_co__1DB76FDA47DBAE45] PRIMARY KEY NONCLUSTERED 
(
	[Row_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_collect_Disk_IO_FileStats] ADD  DEFAULT (getdate()) FOR [date_time]
GO

USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_collect_index_operational_stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_collect_index_operational_stats](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[database_name] [varchar](500) NULL,
	[table_name] [varchar](500) NULL,
	[index_name] [varchar](500) NULL,
	[partition_number] [int] NULL,
	[hobt_id] [bigint] NULL,
	[NumberOfPages] [bigint] NULL,
	[NumberOfRows] [bigint] NULL,
	[leaf_delete_count] [bigint] NULL,
	[leaf_ghost_count] [bigint] NULL,
	[leaf_insert_count] [bigint] NULL,
	[leaf_update_count] [bigint] NULL,
	[page_io_latch_wait_count] [bigint] NULL,
	[page_io_latch_wait_in_ms] [bigint] NULL,
	[page_latch_wait_count] [bigint] NULL,
	[page_latch_wait_in_ms] [bigint] NULL,
	[page_lock_count] [bigint] NULL,
	[page_lock_wait_count] [bigint] NULL,
	[page_lock_wait_in_ms] [bigint] NULL,
	[range_scan_count] [bigint] NULL,
	[row_lock_count] [bigint] NULL,
	[row_lock_wait_count] [bigint] NULL,
	[row_lock_wait_in_ms] [bigint] NULL,
	[singleton_lookup_count] [bigint] NULL,
 CONSTRAINT [PK_DBA_t_dba_collect_index_operational_stats] PRIMARY KEY NONCLUSTERED 
(
	[Row_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_collect_index_operational_stats] ADD  DEFAULT (getdate()) FOR [date_time]
GO

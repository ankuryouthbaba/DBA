USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_indexDefragStatus] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_indexDefragStatus](
	[databaseID] [int] NOT NULL,
	[databaseName] [nvarchar](128) NOT NULL,
	[objectID] [int] NOT NULL,
	[indexID] [int] NOT NULL,
	[partitionNumber] [smallint] NOT NULL,
	[fragmentation] [float] NOT NULL,
	[page_count] [int] NOT NULL,
	[range_scan_count] [bigint] NOT NULL,
	[schemaName] [nvarchar](128) NULL,
	[objectName] [nvarchar](128) NULL,
	[indexName] [nvarchar](128) NULL,
	[scanDate] [datetime] NOT NULL,
	[defragDate] [datetime] NULL,
	[printStatus] [bit] NOT NULL,
	[exclusionMask] [int] NOT NULL,
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_indexDefragStatus_v41] PRIMARY KEY CLUSTERED 
(
	[databaseID] ASC,
	[objectID] ASC,
	[indexID] ASC,
	[partitionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_indexDefragStatus] ADD  DEFAULT ((0)) FOR [printStatus]
GO
ALTER TABLE [dbo].[t_dba_indexDefragStatus] ADD  DEFAULT ((0)) FOR [exclusionMask]
GO

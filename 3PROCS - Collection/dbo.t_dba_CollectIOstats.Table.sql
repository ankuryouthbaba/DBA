USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_CollectIOstats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_CollectIOstats](
	[RowNum] [int] IDENTITY(1,1) NOT NULL,
	[CollectionDateTime] [datetime] NULL,
	[BCHR] [int] NULL,
	[PLE] [int] NULL,
	[BPU] [decimal](15, 3) NULL,
	[PRC] [int] NULL,
	[PSplits] [bigint] NULL,
	[Deadlocks] [int] NOT NULL,
	[Execution_Count] [int] NULL,
 CONSTRAINT [PK__t_dba_Co__4F4A68523EDC53F0] PRIMARY KEY NONCLUSTERED 
(
	[RowNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_CollectIOstats] ADD  DEFAULT (getdate()) FOR [CollectionDateTime]
GO

USE [ADMIN]
GO
/****** Object:  Table [dbo].[t_dba_space_checkfordatabasefreespace_exclusion]    Script Date: 12/2/2021 4:26:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_space_checkfordatabasefreespace_exclusion](
	[File Name] [varchar](100) NULL,
	[Database Name] [sysname] NOT NULL,
	[Included_Excluded] [bit] NOT NULL
) ON [PRIMARY]
GO

USE [ADMIN]
GO
/****** Object:  Table [dbo].[t_dba_space_checkfordatabasefreespace_Collection]    Script Date: 12/2/2021 4:26:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_space_checkfordatabasefreespace_Collection](
	[file_id] [int] NULL,
	[File_Name] [varchar](100) NULL,
	[DBname] [sysname] NOT NULL,
	[FileType] [varchar](50) NULL,
	[File_Size_MB] [varchar](100) NULL,
	[Space_used_MB] [varchar](100) NULL,
	[Free_space_MB] [varchar](100) NULL,
	[Free_Space_Percent] [varchar](100) NULL,
	[Threshold_Space_Used_Percent] [varchar](100) NULL,
	[Space_Used_Percent] [varchar](100) NULL,
	[Rec_created_Dt] [datetime] NULL
) ON [PRIMARY]
GO

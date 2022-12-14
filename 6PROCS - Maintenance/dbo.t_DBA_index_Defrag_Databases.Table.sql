USE [ADMIN]
GO
/****** Object:  Table [dbo].[t_DBA_index_Defrag_Databases]    Script Date: 12/2/2021 4:26:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_DBA_index_Defrag_Databases](
	[DatabaseName] [sysname] NOT NULL,
	[Included_Excluded] [bit] NULL,
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

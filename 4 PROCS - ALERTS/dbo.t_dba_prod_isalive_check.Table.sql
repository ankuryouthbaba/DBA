USE [ADMIN]
GO
/****** Object:  Table [dbo].[t_dba_prod_isalive_check]    Script Date: 12/2/2021 4:26:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_prod_isalive_check](
	[Rec_created_date] [datetime] NOT NULL,
	[ObjectName] [varchar](1000) NULL,
	[latency_Mins] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Rec_created_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_prod_isalive_check] ADD  DEFAULT (getdate()) FOR [Rec_created_date]
GO

USE [Hosp_Payroll]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 4/12/2020 3:27:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employee](
	[Emp_id] [varchar](10) NOT NULL,
	[Name] [varchar](50) NULL,
	[Date_of_Birth] [date] NULL,
	[Gender] [char](1) NULL,
	[Phone] [varchar](15) NULL,
	[address] [varchar](200) NULL,
	[Email] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[Branch] [varchar](3) NULL,
	[Department] [varchar](3) NULL,
	[Designation] [varchar](5) NULL,
	[Company_Date_of_joining] [date] NULL,
	[certificates] [varchar](500) NULL,
	[resume] [varchar](500) NULL,
	[Photo] [varchar](500) NULL,
	[Account_holder_name] [varchar](50) NULL,
	[Account_number] [varchar](50) NULL,
	[Bank_Name] [varchar](100) NULL,
	[Bank_Identifier_Code] [varchar](50) NULL,
	[Branch_location] [varchar](50) NULL,
	[Tax_Payer_id] [varchar](50) NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[Emp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Users]    Script Date: 4/12/2020 3:27:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[Uid] [int] IDENTITY(1,1) NOT NULL,
	[UName] [varchar](50) NULL,
	[UEmail] [varchar](50) NULL,
	[UPassword] [varchar](50) NULL,
	[UPicture] [varchar](50) NULL,
	[ULastLogin] [date] NULL,
	[isDelete] [char](1) NULL,
	[Active] [char](1) NULL,
	[location] [varchar](30) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[Employee] ([Emp_id], [Name], [Date_of_Birth], [Gender], [Phone], [address], [Email], [Password], [Branch], [Department], [Designation], [Company_Date_of_joining], [certificates], [resume], [Photo], [Account_holder_name], [Account_number], [Bank_Name], [Bank_Identifier_Code], [Branch_location], [Tax_Payer_id]) VALUES (N'0', N'WODOOD', CAST(N'2020-01-01' AS Date), N'F', N'03118711062', N'HOUSE NO O/160 KORANGI NO 3', N'WADOOD@LIVE.COM', N'12345', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Date_of_Birth], [Gender], [Phone], [address], [Email], [Password], [Branch], [Department], [Designation], [Company_Date_of_joining], [certificates], [resume], [Photo], [Account_holder_name], [Account_number], [Bank_Name], [Bank_Identifier_Code], [Branch_location], [Tax_Payer_id]) VALUES (N'1', N'SHEIKH MUHAMMAD SAHAL', NULL, N'M', N'03118711062', N'HOUSE NO O/160 KORANGI NO 3 KARACHI', N'S.M.SAHAL786@OUTLOOK.COM', N'12345', N'KAR', N'KAR', N'KARAC', CAST(N'2020-01-01' AS Date), NULL, NULL, NULL, N'SHEIKH MUHAMMAD SAHAL', N'000000000000000001', N'STANDARD CHARTERED BANK', N'000000000000002', N'KARACHI', N'00000000000009')
INSERT [dbo].[Employee] ([Emp_id], [Name], [Date_of_Birth], [Gender], [Phone], [address], [Email], [Password], [Branch], [Department], [Designation], [Company_Date_of_joining], [certificates], [resume], [Photo], [Account_holder_name], [Account_number], [Bank_Name], [Bank_Identifier_Code], [Branch_location], [Tax_Payer_id]) VALUES (N'2', N'SHEIKH MUHAMMAD SAHAL', CAST(N'2020-04-08' AS Date), N'M', N'03118711062', N'HOUSE NO O/160 KORANGI NO 3 KARACHI', N'S.M.SAHAL786@OUTLOOK.COM', N'12345', N'KAR', N'KAR', N'KARAC', CAST(N'2020-01-01' AS Date), NULL, NULL, NULL, N'SHEIKH MUHAMMAD SAHAL', N'000000000000000001', N'STANDARD CHARTERED BANK', N'000000000000002', N'KARACHI', N'00000000000009')
INSERT [dbo].[Employee] ([Emp_id], [Name], [Date_of_Birth], [Gender], [Phone], [address], [Email], [Password], [Branch], [Department], [Designation], [Company_Date_of_joining], [certificates], [resume], [Photo], [Account_holder_name], [Account_number], [Bank_Name], [Bank_Identifier_Code], [Branch_location], [Tax_Payer_id]) VALUES (N'3', N'Munna', CAST(N'2020-04-11' AS Date), N'F', N'0312312312312', N'Munna', N'arsalan@gmail.com', N'123123', NULL, NULL, NULL, CAST(N'2020-04-11' AS Date), NULL, NULL, NULL, N'Arsalan', N'00000002', N'AL Habib Bank', NULL, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Date_of_Birth], [Gender], [Phone], [address], [Email], [Password], [Branch], [Department], [Designation], [Company_Date_of_joining], [certificates], [resume], [Photo], [Account_holder_name], [Account_number], [Bank_Name], [Bank_Identifier_Code], [Branch_location], [Tax_Payer_id]) VALUES (N'4', N'Tooba sahal', NULL, N'F', N'23424234234', NULL, N'toobsahal@gmail.com', N'1234', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (1, N'Sahal', N'sahal@gmail.com', N'.', NULL, NULL, NULL, N'Y', NULL)
INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (2, N'Faheem', N'faheemuzzaman@hotmail.com', N'123', NULL, NULL, NULL, N'Y', NULL)
INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (3, N'Ganja', N'ganja@gmail.com', N'.1', NULL, NULL, NULL, N'N', NULL)
INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (4, N'Sahal', N'sahal.qasim@premier.com.pk', N'123', NULL, NULL, NULL, N'Y', NULL)
SET IDENTITY_INSERT [dbo].[Users] OFF

USE [Hosp_Payroll]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 4/19/2020 5:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employee](
	[Emp_id] [varchar](10) NOT NULL,
	[Name] [varchar](50) NULL,
	[Father_Name] [varchar](50) NULL,
	[CNIC] [varchar](17) NULL,
	[address] [varchar](200) NULL,
	[Phone] [varchar](15) NULL,
	[Email] [varchar](50) NULL,
	[Date_of_Birth] [date] NULL,
	[Gender] [char](1) NULL,
	[Designation] [varchar](50) NULL,
	[Gross_Salary] [varchar](20) NULL,
	[Time_In] [time](7) NULL,
	[Time_Out] [time](7) NULL,
	[Grace_Time_IN] [time](7) NULL,
	[Grace_Time_Out] [time](7) NULL,
	[Overtime_Rate] [varchar](50) NULL,
	[Monday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Monday_WD]  DEFAULT ('N'),
	[Tuesday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Tuesday_WD]  DEFAULT ('N'),
	[Wednesday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Wednesday_WD]  DEFAULT ('N'),
	[Thursday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Thursday_WD]  DEFAULT ('N'),
	[Friday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Friday_WD]  DEFAULT ('N'),
	[Saturday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Saturday_WD]  DEFAULT ('N'),
	[Sunday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Sunday_WD]  DEFAULT ('N'),
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[Emp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Holiday]    Script Date: 4/19/2020 5:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Holiday](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[H_Date] [date] NULL,
	[H_Reason] [varchar](100) NULL,
 CONSTRAINT [PK_Holiday] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Leave_Deduction]    Script Date: 4/19/2020 5:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Leave_Deduction](
	[Emp_id] [int] NULL,
	[Leave_Days] [varchar](5) NULL,
	[From_Date] [date] NULL,
	[To_Date] [date] NULL,
	[Leave_Deduction] [varchar](10) NULL,
	[Total_Leave_Deduction] [varchar](10) NULL,
	[Cancel_YN] [char](1) NULL CONSTRAINT [DF_Leave_Deduction_Cancel_YN]  DEFAULT ('N')
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tax_slab]    Script Date: 4/19/2020 5:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tax_slab](
	[Ts_id] [int] IDENTITY(1,1) NOT NULL,
	[ts_Year] [varchar](20) NULL,
	[Floor_Amount] [varchar](20) NULL,
	[Ceiling_Amount] [varchar](20) NULL,
	[Tax_Amount] [varchar](20) NULL,
	[Tax_Percent] [varchar](20) NULL,
	[Cancel_YN] [char](1) NULL,
 CONSTRAINT [PK_tax_slab] PRIMARY KEY CLUSTERED 
(
	[Ts_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Users]    Script Date: 4/19/2020 5:24:07 AM ******/
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
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Overtime_Rate], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD]) VALUES (N'3', N'irfan bhai', NULL, NULL, NULL, N'03118711062', N'bhai@gmail.com', NULL, N'F', N'manager', N'1000000000', CAST(N'01:00:00' AS Time), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Y', NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Overtime_Rate], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD]) VALUES (N'4', N'ARSALAN', N'SABIR', N'4220167636769', N'HOUSE NO O/169 ', N'03118711062', N'ARSALAN@GMAIL.COM', CAST(N'2020-01-01' AS Date), N'M', N'DEVELOPER', N'30000', CAST(N'01:00:00' AS Time), CAST(N'23:00:00' AS Time), CAST(N'13:00:00' AS Time), CAST(N'12:00:00' AS Time), N'1000', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y')
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Overtime_Rate], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD]) VALUES (N'5', N'sheikh muhammad Sahal', NULL, NULL, NULL, N'03118711062', N's.m.sahal786@outlook.com', NULL, N'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Y', N'Y', N'N', N'Y', N'N', N'N', N'N')
SET IDENTITY_INSERT [dbo].[Holiday] ON 

INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason]) VALUES (1, CAST(N'2020-04-17' AS Date), N'Kashmir day')
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason]) VALUES (2, CAST(N'2020-04-30' AS Date), N'Pakistan Day')
SET IDENTITY_INSERT [dbo].[Holiday] OFF
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (3, N'23', CAST(N'2020-04-17' AS Date), CAST(N'2020-04-17' AS Date), N'123', N'213', N'N')
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (4, N'1000', CAST(N'2019-07-11' AS Date), CAST(N'2021-06-18' AS Date), N'20', N'200000', N'N')
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (2, N'1000', CAST(N'2020-04-01' AS Date), CAST(N'2020-04-17' AS Date), N'123', N'213', N'N')
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (5, N'1000', CAST(N'2020-04-04' AS Date), CAST(N'2020-04-24' AS Date), N'20', N'2323', N'N')
SET IDENTITY_INSERT [dbo].[tax_slab] ON 

INSERT [dbo].[tax_slab] ([Ts_id], [ts_Year], [Floor_Amount], [Ceiling_Amount], [Tax_Amount], [Tax_Percent], [Cancel_YN]) VALUES (1, N'2020', N'1000001', N'2000002', N'3000003', N'40000004', N'N')
INSERT [dbo].[tax_slab] ([Ts_id], [ts_Year], [Floor_Amount], [Ceiling_Amount], [Tax_Amount], [Tax_Percent], [Cancel_YN]) VALUES (2, N'2015', N'50001', N'50002', N'50003', N'50005', N'Y')
SET IDENTITY_INSERT [dbo].[tax_slab] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (1, N'Sahal', N'sahal@gmail.com', N'.', NULL, NULL, NULL, N'Y', NULL)
INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (2, N'Faheem', N'faheemuzzaman@hotmail.com', N'123', NULL, NULL, NULL, N'Y', NULL)
INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (3, N'Ganja', N'ganja@gmail.com', N'.1', NULL, NULL, NULL, N'N', NULL)
INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (4, N'Sahal', N'sahal.qasim@premier.com.pk', N'123', NULL, NULL, NULL, N'Y', NULL)
SET IDENTITY_INSERT [dbo].[Users] OFF

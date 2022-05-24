USE [master]
GO
/****** Object:  Database [Hosp_Payroll]    Script Date: 4/13/2021 5:21:56 PM ******/
CREATE DATABASE [Hosp_Payroll]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Hosp_Payroll', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Hosp_Payroll.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Hosp_Payroll_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Hosp_Payroll_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Hosp_Payroll] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Hosp_Payroll].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Hosp_Payroll] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET ARITHABORT OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Hosp_Payroll] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Hosp_Payroll] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Hosp_Payroll] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Hosp_Payroll] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Hosp_Payroll] SET  MULTI_USER 
GO
ALTER DATABASE [Hosp_Payroll] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Hosp_Payroll] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Hosp_Payroll] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Hosp_Payroll] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [Hosp_Payroll] SET DELAYED_DURABILITY = DISABLED 
GO
USE [Hosp_Payroll]
GO
/****** Object:  User [Jane]    Script Date: 4/13/2021 5:21:56 PM ******/
CREATE USER [Jane] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [SalesPerson]    Script Date: 4/13/2021 5:21:56 PM ******/
CREATE ROLE [SalesPerson]
GO
/****** Object:  Table [dbo].[Activity_log]    Script Date: 4/13/2021 5:21:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Activity_log](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Document] [varchar](50) NULL,
	[Table_flag] [varchar](50) NULL,
	[Activity_Type] [varchar](10) NULL,
	[Activity_Date] [datetime] NULL CONSTRAINT [DF_Activity_log_Activity_Date]  DEFAULT (getdate()),
	[User_id] [int] NULL,
 CONSTRAINT [PK_Activity_log] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Attendance_Sheet]    Script Date: 4/13/2021 5:21:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Attendance_Sheet](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Emp_id] [varchar](10) NULL,
	[Attendance_Date] [date] NULL,
	[Time] [time](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Attendance_Sheet] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 4/13/2021 5:21:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employee](
	[Emp_id] [int] IDENTITY(1,1) NOT NULL,
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
	[Status] [char](1) NULL,
	[Job_type] [char](1) NULL,
	[Leaves] [int] NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[Emp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Holiday]    Script Date: 4/13/2021 5:21:56 PM ******/
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
	[created_by] [varchar](50) NULL,
	[created_date] [date] NULL,
 CONSTRAINT [PK_Holiday] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Leave_Deduction]    Script Date: 4/13/2021 5:21:56 PM ******/
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
/****** Object:  Table [dbo].[Login]    Script Date: 4/13/2021 5:21:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Login](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[User_Name] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[User_status] [char](1) NULL,
	[U_Pic] [varchar](50) NULL,
 CONSTRAINT [PK_Login] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Payroll]    Script Date: 4/13/2021 5:21:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payroll](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Emp_id] [int] NULL,
	[Pyoll_Date] [date] NULL,
	[Working_Days] [int] NULL,
	[Working_Hours] [int] NULL,
	[Holidays] [int] NULL,
	[Current_Abcent] [int] NULL,
	[Current_Salary_Hours] [int] NULL,
	[Over_time_Hours] [int] NULL,
	[Overtime_amount] [int] NULL,
	[Gross_Salary] [int] NULL,
 CONSTRAINT [PK_Payroll] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tax_slab]    Script Date: 4/13/2021 5:21:56 PM ******/
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
/****** Object:  Table [dbo].[Users]    Script Date: 4/13/2021 5:21:56 PM ******/
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
SET IDENTITY_INSERT [dbo].[Activity_log] ON 

INSERT [dbo].[Activity_log] ([Id], [Document], [Table_flag], [Activity_Type], [Activity_Date], [User_id]) VALUES (1, N'Ganja', N'Employee', N'Insert', CAST(N'2021-03-06 18:24:06.020' AS DateTime), 1)
INSERT [dbo].[Activity_log] ([Id], [Document], [Table_flag], [Activity_Type], [Activity_Date], [User_id]) VALUES (2, N'M Sahal Qasim', N'Employee', N'Insert', CAST(N'2021-03-12 16:34:26.787' AS DateTime), 1)
INSERT [dbo].[Activity_log] ([Id], [Document], [Table_flag], [Activity_Type], [Activity_Date], [User_id]) VALUES (3, N'bhabhi', N'Employee', N'Insert', CAST(N'2021-04-09 19:02:15.090' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[Activity_log] OFF
SET IDENTITY_INSERT [dbo].[Attendance_Sheet] ON 

INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (153, N'12', CAST(N'2021-01-25' AS Date), CAST(N'09:11:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (154, N'12', CAST(N'2021-01-25' AS Date), CAST(N'14:42:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (155, N'12', CAST(N'2021-01-25' AS Date), CAST(N'12:11:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (156, N'12', CAST(N'2021-01-25' AS Date), CAST(N'20:11:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (157, N'12', CAST(N'2021-01-26' AS Date), CAST(N'10:42:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (158, N'12', CAST(N'2021-01-26' AS Date), CAST(N'18:49:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (159, N'12', CAST(N'2021-01-27' AS Date), CAST(N'10:55:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (160, N'12', CAST(N'2021-01-27' AS Date), CAST(N'19:00:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (161, N'12', CAST(N'2021-01-28' AS Date), CAST(N'09:18:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (162, N'12', CAST(N'2021-01-28' AS Date), CAST(N'18:00:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (163, N'12', CAST(N'2021-01-29' AS Date), CAST(N'10:55:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (164, N'12', CAST(N'2021-01-29' AS Date), CAST(N'13:59:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (165, N'12', CAST(N'2021-01-29' AS Date), CAST(N'14:03:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (166, N'12', CAST(N'2021-01-29' AS Date), CAST(N'18:15:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (167, N'12', CAST(N'2021-01-30' AS Date), CAST(N'09:00:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (168, N'12', CAST(N'2021-01-30' AS Date), CAST(N'18:15:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (169, N'29', CAST(N'2021-01-25' AS Date), CAST(N'09:11:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (170, N'29', CAST(N'2021-01-25' AS Date), CAST(N'09:42:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (171, N'29', CAST(N'2021-01-25' AS Date), CAST(N'12:11:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (172, N'29', CAST(N'2021-01-25' AS Date), CAST(N'20:11:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (173, N'29', CAST(N'2021-01-26' AS Date), CAST(N'10:42:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (174, N'29', CAST(N'2021-01-26' AS Date), CAST(N'18:49:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (175, N'29', CAST(N'2021-01-27' AS Date), CAST(N'10:55:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (176, N'29', CAST(N'2021-01-27' AS Date), CAST(N'19:00:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (177, N'29', CAST(N'2021-01-28' AS Date), CAST(N'09:18:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (178, N'29', CAST(N'2021-01-28' AS Date), CAST(N'18:00:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (179, N'29', CAST(N'2021-01-29' AS Date), CAST(N'10:55:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (180, N'29', CAST(N'2021-01-29' AS Date), CAST(N'13:59:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (181, N'29', CAST(N'2021-01-29' AS Date), CAST(N'14:03:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (182, N'29', CAST(N'2021-01-29' AS Date), CAST(N'18:15:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (183, N'29', CAST(N'2021-01-30' AS Date), CAST(N'09:00:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (184, N'29', CAST(N'2021-01-30' AS Date), CAST(N'18:15:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (185, N'29', CAST(N'2021-03-25' AS Date), CAST(N'09:11:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (186, N'29', CAST(N'2021-03-25' AS Date), CAST(N'09:42:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (187, N'29', CAST(N'2021-03-25' AS Date), CAST(N'12:11:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (188, N'29', CAST(N'2021-03-25' AS Date), CAST(N'20:11:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (189, N'29', CAST(N'2021-03-26' AS Date), CAST(N'10:42:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (190, N'29', CAST(N'2021-03-26' AS Date), CAST(N'18:49:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (191, N'29', CAST(N'2021-03-27' AS Date), CAST(N'10:55:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (192, N'29', CAST(N'2021-03-27' AS Date), CAST(N'19:00:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (193, N'29', CAST(N'2021-03-28' AS Date), CAST(N'09:18:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (194, N'29', CAST(N'2021-03-28' AS Date), CAST(N'18:00:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (195, N'29', CAST(N'2021-03-29' AS Date), CAST(N'10:55:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (196, N'29', CAST(N'2021-03-29' AS Date), CAST(N'13:59:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (197, N'29', CAST(N'2021-03-29' AS Date), CAST(N'14:03:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (198, N'29', CAST(N'2021-03-29' AS Date), CAST(N'18:15:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (199, N'29', CAST(N'2021-03-30' AS Date), CAST(N'09:00:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (200, N'29', CAST(N'2021-03-30' AS Date), CAST(N'18:15:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1185, N'14', CAST(N'2021-04-13' AS Date), CAST(N'09:00:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1186, N'14', CAST(N'2021-04-13' AS Date), CAST(N'18:00:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1187, N'29', CAST(N'2021-04-25' AS Date), CAST(N'09:11:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1188, N'29', CAST(N'2021-04-25' AS Date), CAST(N'09:42:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1189, N'29', CAST(N'2021-04-25' AS Date), CAST(N'12:11:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1190, N'29', CAST(N'2021-04-25' AS Date), CAST(N'20:11:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1191, N'29', CAST(N'2021-04-26' AS Date), CAST(N'10:42:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1192, N'29', CAST(N'2021-04-26' AS Date), CAST(N'18:49:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1193, N'29', CAST(N'2021-04-27' AS Date), CAST(N'10:55:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1194, N'29', CAST(N'2021-04-27' AS Date), CAST(N'19:00:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1195, N'29', CAST(N'2021-04-28' AS Date), CAST(N'09:18:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1196, N'29', CAST(N'2021-04-28' AS Date), CAST(N'18:00:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1197, N'29', CAST(N'2021-04-29' AS Date), CAST(N'10:55:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1198, N'29', CAST(N'2021-04-29' AS Date), CAST(N'13:59:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1199, N'29', CAST(N'2021-04-29' AS Date), CAST(N'14:03:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1200, N'29', CAST(N'2021-04-29' AS Date), CAST(N'18:15:00' AS Time), 2)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1201, N'29', CAST(N'2021-04-30' AS Date), CAST(N'09:00:00' AS Time), 1)
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (1202, N'29', CAST(N'2021-04-30' AS Date), CAST(N'18:15:00' AS Time), 2)
SET IDENTITY_INSERT [dbo].[Attendance_Sheet] OFF
SET IDENTITY_INSERT [dbo].[Employee] ON 

INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Overtime_Rate], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves]) VALUES (13, N'Irfan ', N'Bhai', N'4220167636769', N'hose n', N'03118788278', NULL, CAST(N'1992-01-01' AS Date), N'M', N'Manager', N'5000', CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'09:15:00' AS Time), CAST(N'18:15:00' AS Time), NULL, N'Y', N'Y', N'Y', N'Y', N'N', N'N', N'N', N'Y', NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Overtime_Rate], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves]) VALUES (14, N'Fahim', N'uz zaman', N'4220167636768', N'House no', N'03118711837', NULL, CAST(N'1994-08-05' AS Date), N'M', N'Developer', N'300', CAST(N'09:00:00' AS Time), CAST(N'17:00:00' AS Time), CAST(N'09:15:00' AS Time), CAST(N'17:15:00' AS Time), NULL, N'Y', N'Y', N'N', N'Y', N'N', N'Y', N'N', N'Y', N'F', 10)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Overtime_Rate], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves]) VALUES (29, N'M Sahal Qasim', N'M Qasim', N'4220167636769', N'HOuse no O/160 korangi no 3 karachi', N'03118711062', NULL, CAST(N'1996-07-20' AS Date), N'M', N'Developer', N'500', CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'09:15:00' AS Time), CAST(N'17:45:00' AS Time), N'100', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'N', N'Y', N'C', 3)
SET IDENTITY_INSERT [dbo].[Employee] OFF
SET IDENTITY_INSERT [dbo].[Holiday] ON 

INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (1, CAST(N'2021-02-17' AS Date), N'Kashmir days', NULL, NULL)
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (2, CAST(N'2021-02-27' AS Date), N'Pakistan Day', NULL, NULL)
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (1002, CAST(N'2021-01-01' AS Date), N'Maire Day', NULL, NULL)
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (1003, CAST(N'2021-03-25' AS Date), N'tery Day', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Holiday] OFF
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (3, N'23', CAST(N'2020-04-17' AS Date), CAST(N'2020-04-17' AS Date), N'123', N'213', N'N')
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (4, N'1000', CAST(N'2019-07-11' AS Date), CAST(N'2021-06-18' AS Date), N'20', N'200000', N'N')
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (2, N'1000', CAST(N'2020-04-01' AS Date), CAST(N'2020-04-17' AS Date), N'123', N'213', N'N')
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (5, N'1000', CAST(N'2020-04-04' AS Date), CAST(N'2020-04-24' AS Date), N'20', N'2323', N'N')
SET IDENTITY_INSERT [dbo].[Login] ON 

INSERT [dbo].[Login] ([id], [User_Name], [Email], [Password], [User_status], [U_Pic]) VALUES (1, N'Sahal', N's.m.sahal786@outlook.com', N'1234', N'Y', NULL)
SET IDENTITY_INSERT [dbo].[Login] OFF
SET IDENTITY_INSERT [dbo].[Payroll] ON 

INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Current_Salary_Hours], [Over_time_Hours], [Overtime_amount], [Gross_Salary]) VALUES (1, 12, CAST(N'2021-02-23' AS Date), 10, 74, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Current_Salary_Hours], [Over_time_Hours], [Overtime_amount], [Gross_Salary]) VALUES (4, 29, CAST(N'2021-03-12' AS Date), 5, 45, 1, 26, 39, 6, 600, 20100)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Current_Salary_Hours], [Over_time_Hours], [Overtime_amount], [Gross_Salary]) VALUES (1002, 29, CAST(N'2021-04-13' AS Date), 6, 54, 0, 24, 48, 6, 600, 24600)
SET IDENTITY_INSERT [dbo].[Payroll] OFF
SET IDENTITY_INSERT [dbo].[tax_slab] ON 

INSERT [dbo].[tax_slab] ([Ts_id], [ts_Year], [Floor_Amount], [Ceiling_Amount], [Tax_Amount], [Tax_Percent], [Cancel_YN]) VALUES (1, N'2020', N'1000001', N'2000002', N'3000003', N'40000004', N'N')
INSERT [dbo].[tax_slab] ([Ts_id], [ts_Year], [Floor_Amount], [Ceiling_Amount], [Tax_Amount], [Tax_Percent], [Cancel_YN]) VALUES (2, N'2015', N'50001', N'50002', N'50003', N'50005', N'Y')
INSERT [dbo].[tax_slab] ([Ts_id], [ts_Year], [Floor_Amount], [Ceiling_Amount], [Tax_Amount], [Tax_Percent], [Cancel_YN]) VALUES (1002, N'2020', N'400', N'500', N'600', N'700', N'Y')
SET IDENTITY_INSERT [dbo].[tax_slab] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (1, N'Sahal', N'sahal@gmail.com', N'.', NULL, NULL, NULL, N'Y', NULL)
INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (2, N'Faheem', N'faheemuzzaman@hotmail.com', N'123', NULL, NULL, NULL, N'Y', NULL)
INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (3, N'Ganja', N'ganja@gmail.com', N'.1', NULL, NULL, NULL, N'N', NULL)
INSERT [dbo].[Users] ([Uid], [UName], [UEmail], [UPassword], [UPicture], [ULastLogin], [isDelete], [Active], [location]) VALUES (4, N'Sahal', N'sahal.qasim@premier.com.pk', N'123', NULL, NULL, NULL, N'Y', NULL)
SET IDENTITY_INSERT [dbo].[Users] OFF
/****** Object:  StoredProcedure [dbo].[attendance_list]    Script Date: 4/13/2021 5:21:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[attendance_list]
as 
select 
e.Emp_id,
e.Name,
ats.Attendance_Date,
format(ats.Attendance_Date,'MMMM,yyyy') Att_Year,
min (ats.time) Time_IN,
(
select max(atts.time) from Attendance_Sheet atts
where atts.status = 2
and atts.Attendance_Date = ats.Attendance_Date
)Time_out,
DATEDIFF(hour, min (ats.time),(
select max(atts.time) from Attendance_Sheet atts
where atts.status = 2
and atts.Attendance_Date = ats.Attendance_Date
)) working_hours
from Attendance_Sheet ats , Employee e
where ats.Emp_id = e.Emp_id
and ats.status = 1
group by ats.Attendance_Date,e.Emp_id, e.Name
order by ats.Attendance_Date desc;
GO
/****** Object:  StoredProcedure [dbo].[calculate_Salary]    Script Date: 4/13/2021 5:21:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[calculate_Salary] @emp_id int, @Date nvarchar(30)
AS
begin
DECLARE @Set_year as nvarchar(30), @Set_Month as nvarchar(30)

set @Set_year = SUBSTRING(@Date, 1, 4);
set @Set_Month = reverse(substring(reverse(@Date), 1, 2));


select count(working_hours.working_hours) - case when working_hours.Leaves > working_hours.tot_abcent then 0 else working_hours.late_status end working_days,
 --working_hours.late_status working_days,
sum(working_hours.working_hours) - (working_hours.working_time * case when working_hours.Leaves > working_hours.tot_abcent then 0 else working_hours.late_status end /*working_hours.late_status*/) working_hours ,
 working_hours.Holiday
,((working_hours.Abcent + case when working_hours.Leaves > working_hours.tot_abcent then 0 else working_hours.tot_abcent end /*working_hours.late_status*/) - working_hours.Holiday) - 
(count(working_hours.working_hours) - case when working_hours.Leaves > working_hours.tot_abcent then 0 else working_hours.late_status end/*working_hours.late_status*/) Current_abcent
,
(sum(working_hours.working_hours) - working_hours.Over_time_hours) -
(working_hours.working_time * case when working_hours.Leaves > working_hours.tot_abcent then 0 else working_hours.late_status end/*working_hours.late_status*/)
 Current_Salary_hours ,
working_hours.Over_time_hours,
working_hours.working_time,
(working_hours.Over_time_hours * working_hours.Overtime_Rate) Overtime_amount,
working_hours.tot_abcent ,
working_hours.late_status,
(((sum(working_hours.working_hours) - working_hours.Over_time_hours) -
 (working_hours.working_time * case when working_hours.Leaves > working_hours.tot_abcent then 0 else working_hours.late_status end/*working_hours.late_status*/)) * working_hours.Gross_Salary )
+ (working_hours.Over_time_hours * working_hours.Overtime_Rate)
 Gross_Salary
from (
select 
DATEDIFF(hour, min (ats.time),(
select max(atts.time) from Attendance_Sheet atts
where atts.status = 2
and atts.Emp_id = @emp_id
and convert(varchar(7), ats.Attendance_Date, 126) = @Date
and atts.Attendance_Date = ats.Attendance_Date
)) working_hours,
e.Gross_Salary,
e.Leaves,
DAY(EOMONTH(CONCAT(@Set_Month,'-02-',@Set_year))) Abcent,
datediff(HOUR, e.Time_In , e.Time_Out) working_time,
ISNULL(e.Overtime_Rate,0) Overtime_Rate,
(select count(h.id) Holiday from Holiday h where convert(varchar(7), h.H_Date, 126) = @Date) Holiday,
(
select count(late_status.att_status) /3 from (
select
case
 when
 DATEDIFF(MINUTE, e.Grace_Time_IN, max(atts.Time)) > 1 then DATEDIFF(MINUTE, e.Grace_Time_IN, max(atts.Time))
 else
 0 end att_status 
from Employee e, Attendance_Sheet atts
where e.Emp_id = atts.Emp_id
and atts.Emp_id = @emp_id
and atts.status =1
and convert(varchar(7), atts.Attendance_Date, 126) = @Date
and FORMAT(atts.Attendance_Date, 'dddd') <> case when e.Monday_WD = 'Y' then e.Monday_WD else 'Monday' end
and FORMAT(atts.Attendance_Date, 'dddd') <> case when e.Tuesday_WD = 'Y' then e.Tuesday_WD else 'Tuesday' end
and FORMAT(atts.Attendance_Date, 'dddd') <> case when e.Wednesday_WD = 'Y' then e.Wednesday_WD else 'Wednesday' end
and FORMAT(atts.Attendance_Date, 'dddd') <> case when e.Thursday_WD = 'Y' then e.Thursday_WD else 'Thursday' end
and FORMAT(atts.Attendance_Date, 'dddd') <> case when e.Friday_WD = 'Y' then e.Friday_WD else 'Friday' end
and FORMAT(atts.Attendance_Date, 'dddd') <> case when e.Saturday_WD = 'Y' then e.Saturday_WD else 'Saturday' end
and FORMAT(atts.Attendance_Date, 'dddd') <> case when e.Sunday_WD = 'Y' then e.Sunday_WD else 'Sunday' end
group by e.Grace_Time_IN, atts.Attendance_Date
having case
 when
 DATEDIFF(MINUTE, e.Grace_Time_IN, max(atts.Time)) > 1 then DATEDIFF(MINUTE, e.Grace_Time_IN, max(atts.Time))
 else
 0 end <> 0 ) late_status) late_status,
 (
select 
sum(
case 
when
currt_working_time.working_hours - currt_working_time.fix_working_hours >= 1 then
currt_working_time.working_hours - currt_working_time.fix_working_hours 
else
0 end)  over_time_hours
 from (
select 
DATEDIFF(hour, min (ats.time),(
select max(atts.time) from Attendance_Sheet atts
where atts.status = 2
and atts.Emp_id = @emp_id
and convert(varchar(7), ats.Attendance_Date, 126) = @Date
and atts.Attendance_Date = ats.Attendance_Date
)) working_hours,

DATEDIFF(HOUR,e.Grace_Time_IN, e.Grace_Time_Out) fix_working_hours ,
ISNULL(e.Overtime_Rate,0) overtime_rate,
ISNULL(e.Gross_Salary,0) per_over_salary
from Attendance_Sheet ats , Employee e
where ats.Emp_id = e.Emp_id
and ats.status = 1
and ats.Emp_id =@emp_id
and convert(varchar(7), ats.Attendance_Date, 126) = @Date
group by ats.Attendance_Date,e.Gross_Salary , e.Grace_Time_IN, 
e.Grace_Time_Out,e.Overtime_Rate,e.Gross_Salary) 
currt_working_time) Over_time_hours,
(select ISNULL(sum(p.Current_Abcent),0) Abcent from Payroll p where p.Emp_id = 29 and year(p.Pyoll_Date) = '2021') tot_abcent
from Attendance_Sheet ats , Employee e
where ats.Emp_id = e.Emp_id
and ats.status = 1
and ats.Emp_id =@emp_id
and convert(varchar(7), ats.Attendance_Date, 126) = @Date
group by ats.Attendance_Date,e.Gross_Salary,e.Overtime_Rate,e.Time_In , e.Time_Out, e.Leaves) working_hours 
group by working_hours.Gross_Salary , working_hours.Holiday, working_hours.late_status,
working_hours.Overtime_Rate , working_hours.Over_time_hours , working_hours.Leaves
, working_hours.Abcent , working_hours.working_time, working_hours.tot_abcent;
end;
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_data]    Script Date: 4/13/2021 5:21:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Dashboard_data]
AS
select count(*) no_employees,
(select count(*) no_holidays from Holiday h
where convert(varchar(7), h.H_Date, 126) = convert(varchar(7), GETDATE(), 126))no_holidays,
(select count(*) from Employee ex where ex.Status = 'N') no_ex_employees
 from Employee e
where e.Status = 'Y'
;
GO
/****** Object:  StoredProcedure [dbo].[exl_dta_shw_rntm]    Script Date: 4/13/2021 5:21:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[exl_dta_shw_rntm] @emp_id int
AS
begin
select e.Name 
from Employee e 
where e.Emp_id = @Emp_id 
and e.Status <> 'N';
end;
GO
USE [master]
GO
ALTER DATABASE [Hosp_Payroll] SET  READ_WRITE 
GO

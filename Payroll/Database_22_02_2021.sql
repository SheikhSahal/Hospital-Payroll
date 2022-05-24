USE [master]
GO
/****** Object:  Database [Hosp_Payroll]    Script Date: 2/22/2021 9:32:26 PM ******/
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
/****** Object:  User [Jane]    Script Date: 2/22/2021 9:32:26 PM ******/
CREATE USER [Jane] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [SalesPerson]    Script Date: 2/22/2021 9:32:26 PM ******/
CREATE ROLE [SalesPerson]
GO
/****** Object:  Table [dbo].[Attendance_Sheet]    Script Date: 2/22/2021 9:32:27 PM ******/
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
	[Time_IN] [time](7) NULL,
	[Time_Out] [time](7) NULL,
 CONSTRAINT [PK_Attendance_Sheet] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 2/22/2021 9:32:27 PM ******/
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
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[Emp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Holiday]    Script Date: 2/22/2021 9:32:27 PM ******/
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
/****** Object:  Table [dbo].[Leave_Deduction]    Script Date: 2/22/2021 9:32:27 PM ******/
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
/****** Object:  Table [dbo].[Login]    Script Date: 2/22/2021 9:32:27 PM ******/
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
/****** Object:  Table [dbo].[Payroll]    Script Date: 2/22/2021 9:32:27 PM ******/
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
	[Working_time] [int] NULL,
	[Holidays] [int] NULL,
	[Abcent] [int] NULL,
	[Late_time_Abcent] [int] NULL,
	[Total_Earning] [int] NULL,
	[Deduction] [int] NULL,
	[Gross_Salary] [int] NULL,
 CONSTRAINT [PK_Payroll] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tax_slab]    Script Date: 2/22/2021 9:32:27 PM ******/
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
/****** Object:  Table [dbo].[Users]    Script Date: 2/22/2021 9:32:27 PM ******/
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
SET IDENTITY_INSERT [dbo].[Attendance_Sheet] ON 

INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1, N'1', CAST(N'2019-01-01' AS Date), CAST(N'13:00:00' AS Time), CAST(N'14:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (2, N'12', CAST(N'2021-02-16' AS Date), CAST(N'10:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (3, N'13', CAST(N'2021-02-16' AS Date), CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (4, N'12', CAST(N'2021-02-21' AS Date), CAST(N'11:00:00' AS Time), CAST(N'21:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1002, N'12', CAST(N'2021-02-18' AS Date), CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1003, N'12', CAST(N'2021-02-22' AS Date), CAST(N'09:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1004, N'12', CAST(N'2021-02-23' AS Date), CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1005, N'12', CAST(N'2021-02-19' AS Date), CAST(N'09:20:00' AS Time), CAST(N'18:30:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1006, N'12', CAST(N'2021-01-01' AS Date), CAST(N'09:00:00' AS Time), CAST(N'19:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1007, N'12', CAST(N'2021-03-20' AS Date), CAST(N'09:30:00' AS Time), CAST(N'20:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1008, N'12', CAST(N'2021-02-04' AS Date), CAST(N'09:25:00' AS Time), CAST(N'19:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1009, N'12', CAST(N'2021-02-03' AS Date), CAST(N'09:30:00' AS Time), CAST(N'18:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1010, N'12', CAST(N'2021-02-01' AS Date), CAST(N'09:31:00' AS Time), CAST(N'06:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1011, N'12', CAST(N'2021-02-04' AS Date), CAST(N'09:42:00' AS Time), CAST(N'15:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1012, N'15', CAST(N'2021-02-22' AS Date), CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1013, N'15', CAST(N'2021-02-24' AS Date), CAST(N'09:10:00' AS Time), CAST(N'18:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1014, N'15', CAST(N'2021-02-25' AS Date), CAST(N'09:13:00' AS Time), CAST(N'18:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1015, N'15', CAST(N'2021-02-27' AS Date), CAST(N'09:14:00' AS Time), CAST(N'18:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1016, N'15', CAST(N'2021-02-23' AS Date), CAST(N'10:00:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1017, N'15', CAST(N'2021-02-26' AS Date), CAST(N'09:30:00' AS Time), CAST(N'17:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1018, N'15', CAST(N'2021-02-28' AS Date), CAST(N'11:13:00' AS Time), CAST(N'16:16:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1019, N'15', CAST(N'2021-02-15' AS Date), CAST(N'09:20:00' AS Time), CAST(N'18:00:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1020, N'15', CAST(N'2021-02-17' AS Date), CAST(N'10:18:00' AS Time), CAST(N'21:25:00' AS Time))
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time_IN], [Time_Out]) VALUES (1021, N'15', CAST(N'2021-02-18' AS Date), CAST(N'09:36:00' AS Time), CAST(N'18:00:00' AS Time))
SET IDENTITY_INSERT [dbo].[Attendance_Sheet] OFF
SET IDENTITY_INSERT [dbo].[Employee] ON 

INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Overtime_Rate], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status]) VALUES (12, N'M Sahal', N'M Qasim', N'4220167636766', N'House P-193', N'03332375463', N's.m.sahal786@outlook.com', CAST(N'1996-07-20' AS Date), N'M', N'Developer', N'500', CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'09:20:00' AS Time), CAST(N'18:00:00' AS Time), NULL, N'Y', N'Y', N'N', N'N', N'Y', N'Y', N'N', N'Y')
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Overtime_Rate], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status]) VALUES (13, N'Irfan ', N'Bhai', N'4220167636769', N'hose n', N'03118788278', NULL, CAST(N'1992-01-01' AS Date), N'M', N'Manager', N'5000', CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'09:15:00' AS Time), CAST(N'18:15:00' AS Time), NULL, N'Y', N'Y', N'Y', N'Y', N'N', N'N', N'N', N'Y')
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Overtime_Rate], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status]) VALUES (14, N'Fahim', N'uz zaman', N'4220167636768', N'House no', N'03118711837', NULL, CAST(N'1994-08-05' AS Date), N'M', N'Developer', N'300', CAST(N'09:00:00' AS Time), CAST(N'17:00:00' AS Time), CAST(N'09:15:00' AS Time), CAST(N'17:15:00' AS Time), NULL, N'Y', N'Y', N'N', N'Y', N'N', N'Y', N'N', N'Y')
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Overtime_Rate], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status]) VALUES (15, N'Ganja', N'ishaque', N'4220167636769', N'house no ', N'03118711062', N'danish.ansari1024@gmail.com', CAST(N'1994-11-04' AS Date), N'M', N'director', N'200', CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'09:15:00' AS Time), CAST(N'18:00:00' AS Time), NULL, N'Y', N'N', N'Y', N'Y', N'N', N'Y', N'N', N'Y')
SET IDENTITY_INSERT [dbo].[Employee] OFF
SET IDENTITY_INSERT [dbo].[Holiday] ON 

INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason]) VALUES (1, CAST(N'2021-02-17' AS Date), N'Kashmir day')
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason]) VALUES (2, CAST(N'2021-02-27' AS Date), N'Pakistan Day')
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason]) VALUES (1002, CAST(N'2021-01-01' AS Date), N'Maire Day')
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason]) VALUES (1003, CAST(N'2021-03-25' AS Date), N'tery Day')
SET IDENTITY_INSERT [dbo].[Holiday] OFF
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (3, N'23', CAST(N'2020-04-17' AS Date), CAST(N'2020-04-17' AS Date), N'123', N'213', N'N')
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (4, N'1000', CAST(N'2019-07-11' AS Date), CAST(N'2021-06-18' AS Date), N'20', N'200000', N'N')
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (2, N'1000', CAST(N'2020-04-01' AS Date), CAST(N'2020-04-17' AS Date), N'123', N'213', N'N')
INSERT [dbo].[Leave_Deduction] ([Emp_id], [Leave_Days], [From_Date], [To_Date], [Leave_Deduction], [Total_Leave_Deduction], [Cancel_YN]) VALUES (5, N'1000', CAST(N'2020-04-04' AS Date), CAST(N'2020-04-24' AS Date), N'20', N'2323', N'N')
SET IDENTITY_INSERT [dbo].[Login] ON 

INSERT [dbo].[Login] ([id], [User_Name], [Email], [Password], [User_status], [U_Pic]) VALUES (1, N'Sahal', N's.m.sahal786@outlook.com', N'1234', N'Y', NULL)
SET IDENTITY_INSERT [dbo].[Login] OFF
SET IDENTITY_INSERT [dbo].[Payroll] ON 

INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Working_time], [Holidays], [Abcent], [Late_time_Abcent], [Total_Earning], [Deduction], [Gross_Salary]) VALUES (1, 0, CAST(N'2021-02-22' AS Date), 10, 74, 12, 2, 18, 0, 37000, 0, 37000)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Working_time], [Holidays], [Abcent], [Late_time_Abcent], [Total_Earning], [Deduction], [Gross_Salary]) VALUES (2, 12, CAST(N'2021-02-22' AS Date), 10, 74, 12, 2, 18, 0, 37000, 0, 37000)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Working_time], [Holidays], [Abcent], [Late_time_Abcent], [Total_Earning], [Deduction], [Gross_Salary]) VALUES (3, 12, CAST(N'2021-02-22' AS Date), 1, 11, 12, 1, 30, 0, 5500, 0, 5500)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Working_time], [Holidays], [Abcent], [Late_time_Abcent], [Total_Earning], [Deduction], [Gross_Salary]) VALUES (4, 12, CAST(N'2021-02-22' AS Date), 10, 74, 12, 2, 18, 0, 37000, 0, 37000)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Working_time], [Holidays], [Abcent], [Late_time_Abcent], [Total_Earning], [Deduction], [Gross_Salary]) VALUES (5, 12, CAST(N'2021-02-22' AS Date), 10, 74, 12, 2, 18, 0, 37000, 0, 37000)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Working_time], [Holidays], [Abcent], [Late_time_Abcent], [Total_Earning], [Deduction], [Gross_Salary]) VALUES (6, 12, CAST(N'2021-02-22' AS Date), 1, 11, 12, 1, 30, 0, 5500, 0, 5500)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Working_time], [Holidays], [Abcent], [Late_time_Abcent], [Total_Earning], [Deduction], [Gross_Salary]) VALUES (7, 12, CAST(N'2021-02-22' AS Date), 10, 74, 12, 2, 18, 0, 37000, 0, 37000)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Working_time], [Holidays], [Abcent], [Late_time_Abcent], [Total_Earning], [Deduction], [Gross_Salary]) VALUES (8, 12, CAST(N'2021-02-22' AS Date), 10, 74, 12, 2, 18, 0, 37000, 0, 37000)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Working_time], [Holidays], [Abcent], [Late_time_Abcent], [Total_Earning], [Deduction], [Gross_Salary]) VALUES (9, 12, CAST(N'2021-02-22' AS Date), 10, 74, 12, 2, 18, 0, 37000, 0, 37000)
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
/****** Object:  StoredProcedure [dbo].[calculate_Salary]    Script Date: 2/22/2021 9:32:27 PM ******/
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


select  payroll.working_days - payroll.late_tim_abcent working_days,
 payroll.working_hours - ( payroll.working_time * payroll.late_tim_abcent) working_hours,
 payroll.working_time ,
payroll.holidays, 
(payroll.Abcent + payroll.late_tim_abcent - payroll.holidays)  - payroll.working_days Abcent,
 payroll.late_tim_abcent , 
 payroll.working_hours * payroll.salary_Gross total_earning,
 (payroll.working_time * payroll.late_tim_abcent) * payroll.salary_Gross deduction ,
  (payroll.working_hours - (payroll.working_time * payroll.late_tim_abcent)) * payroll.salary_Gross Gross_salary
 --payroll.OverTime_rate 
 --(payroll.working_hours - (payroll.working_time * payroll.late_tim_abcent)) * payroll.salary_Gross  + OverTime_rate Net_pay
 from (
select count(*) working_days , 
sum(DATEDIFF(hour, ats.Time_IN, ats.Time_Out)) AS working_hours ,
datediff(HOUR, e.Time_In , e.Time_Out) working_time,
e.Gross_Salary salary_Gross,
(select count(*) holiday from Holiday h where convert(varchar(7), h.H_Date, 126) = @Date) holidays,
DAY(EOMONTH(CONCAT(@Set_Month,'-02-',@Set_year))) Abcent,
(select 
count( case
 when datediff(MINUTE, e.Grace_Time_IN , ats.Time_IN ) > 1 then datediff(MINUTE, e.Grace_Time_IN , ats.Time_IN )
 else
 0 end) /3 as att_status 
from Attendance_Sheet ats , Employee e
where ats.Emp_id = e.Emp_id 
and e.Emp_id = @emp_id
and 0 <> case
		 when datediff(MINUTE, e.Grace_Time_IN , ats.Time_IN ) > 1 then datediff(MINUTE, e.Grace_Time_IN , ats.Time_IN )
		 else
		 0 end
and FORMAT(ats.Attendance_Date, 'dddd') <> case when e.Monday_WD = 'Y' then e.Monday_WD else 'Monday' end
and FORMAT(ats.Attendance_Date, 'dddd') <> case when e.Tuesday_WD = 'Y' then e.Tuesday_WD else 'Tuesday' end
and FORMAT(ats.Attendance_Date, 'dddd') <> case when e.Wednesday_WD = 'Y' then e.Wednesday_WD else 'Wednesday' end
and FORMAT(ats.Attendance_Date, 'dddd') <> case when e.Thursday_WD = 'Y' then e.Thursday_WD else 'Thursday' end
and FORMAT(ats.Attendance_Date, 'dddd') <> case when e.Friday_WD = 'Y' then e.Friday_WD else 'Friday' end
and FORMAT(ats.Attendance_Date, 'dddd') <> case when e.Saturday_WD = 'Y' then e.Saturday_WD else 'Saturday' end
and FORMAT(ats.Attendance_Date, 'dddd') <> case when e.Sunday_WD = 'Y' then e.Sunday_WD else 'Sunday' end
and convert(varchar(7), ats.Attendance_Date, 126) = @Date) late_tim_abcent
from Attendance_Sheet ats, Employee e
where e.Emp_id = ats.Emp_id
and ats.Emp_id = @emp_id and convert(varchar(7), ats.Attendance_Date, 126) = @Date
group by e.Gross_Salary , e.Time_In , e.Time_Out ) payroll;

end;
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_data]    Script Date: 2/22/2021 9:32:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Dashboard_data]
AS
select count(*) no_employees,
(select count(*) no_holidays from Holiday h
where datename(month,h.H_Date) = datename(month,GETDATE()))no_holidays,
(select count(*) from Employee ex where ex.Status = 'N') no_ex_employees
 from Employee e
where e.Status = 'Y'
;
GO
USE [master]
GO
ALTER DATABASE [Hosp_Payroll] SET  READ_WRITE 
GO

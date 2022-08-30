USE [master]
GO
/****** Object:  Database [Hosp_Payroll]    Script Date: 8/30/2022 7:22:23 PM ******/
CREATE DATABASE [Hosp_Payroll]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Hosp_Payroll', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\Hosp_Payroll.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Hosp_Payroll_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\Hosp_Payroll_log.ldf' , SIZE = 2304KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
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
/****** Object:  User [Jane]    Script Date: 8/30/2022 7:22:23 PM ******/
CREATE USER [Jane] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [SalesPerson]    Script Date: 8/30/2022 7:22:23 PM ******/
CREATE ROLE [SalesPerson]
GO
/****** Object:  UserDefinedFunction [dbo].[EMP_Monthly_hours]    Script Date: 8/30/2022 7:22:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[EMP_Monthly_hours]
(
  @Year int,
  @Month int,
  @EMPID int
) returns int
BEGIN
return(
SELECT (dbo.get_weekdays(@EMPID)* dbo.f_count_sundays(@Year,@Month)) * datediff(HOUR,e.Grace_Time_IN , e.Grace_Time_Out) Monthly_hours
from Employee e where e.Emp_id = @EMPID);
END;


GO
/****** Object:  UserDefinedFunction [dbo].[f_count_sundays]    Script Date: 8/30/2022 7:22:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[f_count_sundays]
(
  @Year int,
  @Month int
) returns int
BEGIN
DECLARE @x date = dateadd(month,@month-1+(@year-1900)*12,6)
RETURN datediff(d, dateadd(d,datediff(d,-1,@x)/7*7,-1),dateadd(m,1,@x))/7
END


GO
/****** Object:  UserDefinedFunction [dbo].[Get_EMP_Totalhours]    Script Date: 8/30/2022 7:22:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[Get_EMP_Totalhours]
(
  @Date nvarchar(30),
  @EMPID int
) returns int
BEGIN
return(
select sum( ISNULL(DATEDIFF(hour, r.Time_In ,r.Time_out),0)) Total_hours from (
select e.Emp_id , e.Attendance_Date,
(select f.Time from Attendance_Sheet f
where f.Status like '%1%' 
and f.emp_id = @EMPID 
and convert(varchar(7), f.Attendance_Date, 126) =  @Date
and f.Attendance_Date = e.Attendance_Date 
and f.Emp_id = e.Emp_id)Time_In
,e.Time Time_out
from Attendance_Sheet e
where e.Status like '%2%'
and e.emp_id = @EMPID
and convert(varchar(7), e.Attendance_Date, 126) =  @Date) r);
END;


GO
/****** Object:  UserDefinedFunction [dbo].[get_present_days]    Script Date: 8/30/2022 7:22:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[get_present_days](@yearMonth nvarchar(30),@empid int)
 returns int
 begin
 return(
 (select count(*) count_persent_days from (
select ats.Emp_id emp_id, count(ats.Attendance_Date) att_date
from attendance_sheet ats
where convert(varchar(7), ats.Attendance_Date, 126) =  @yearMonth
and ats.Emp_id = @empid
group by ats.Emp_id, ats.Attendance_Date)
t)
 )
 end
GO
/****** Object:  UserDefinedFunction [dbo].[get_weekdays]    Script Date: 8/30/2022 7:22:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[get_weekdays](@empid int)
 returns int
 begin
 return(
select (f.Monday + f.Tuesday + f.Wednesday + f.Thursday + f.Friday + f.Saturday + f.Sunday) weekdays_h  from (
select 
case when r.Monday_WD = 'Y' then 1 else 0 end Monday,
case when r.Tuesday_WD = 'Y' then 1 else 0 end Tuesday,
case when r.Wednesday_WD = 'Y' then 1 else 0 end Wednesday,
case when r.Thursday_WD = 'Y' then 1 else 0 end Thursday,
case when r.Friday_WD = 'Y' then 1 else 0 end Friday,
case when r.Saturday_WD = 'Y' then 1 else 0 end Saturday,
case when r.Sunday_WD = 'Y' then 1 else 0 end Sunday
from employee r
where r.Emp_id = @empid ) f);
end;
GO
/****** Object:  UserDefinedFunction [dbo].[getSundaysandSaturdays]    Script Date: 8/30/2022 7:22:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE function [dbo].[getSundaysandSaturdays]
    (
        @Year int,
        @Month int

    ) 
    RETURNS int
    as 
    begin
    declare     @fdays int 
        ;with dates as
        (
            select dateadd(month,@month-1,dateadd(year,@year-1900,0)) as StartDate
            union all
            select startdate + 1 from dates where month(startdate+1) = @Month
        )
        select @fdays=count(*) from dates where datepart(dw,StartDate) =1
      return @fdays
      end

GO
/****** Object:  UserDefinedFunction [dbo].[total_no_days]    Script Date: 8/30/2022 7:22:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[total_no_days] (@date varchar(20))
 returns int
 begin
 return(
 SELECT DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@date),0)))
 )
 end
GO
/****** Object:  Table [dbo].[Activity_log]    Script Date: 8/30/2022 7:22:23 PM ******/
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
/****** Object:  Table [dbo].[Attendance_Sheet]    Script Date: 8/30/2022 7:22:23 PM ******/
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
	[Status] [varchar](2) NULL,
 CONSTRAINT [PK_Attendance_Sheet] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 8/30/2022 7:22:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employee](
	[Emp_id] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[Father_Name] [varchar](50) NULL,
	[CNIC] [varchar](17) NULL,
	[address] [varchar](200) NULL,
	[Phone] [varchar](15) NULL,
	[Email] [varchar](50) NULL,
	[Date_of_Birth] [date] NULL,
	[Gender] [char](1) NULL,
	[Designation] [varchar](50) NULL,
	[Gross_Salary] [float] NULL,
	[Time_In] [time](7) NULL,
	[Time_Out] [time](7) NULL,
	[Grace_Time_IN] [time](7) NULL,
	[Grace_Time_Out] [time](7) NULL,
	[Monday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Monday_WD]  DEFAULT ('N'),
	[Tuesday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Tuesday_WD]  DEFAULT ('N'),
	[Wednesday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Wednesday_WD]  DEFAULT ('N'),
	[Thursday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Thursday_WD]  DEFAULT ('N'),
	[Friday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Friday_WD]  DEFAULT ('N'),
	[Saturday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Saturday_WD]  DEFAULT ('N'),
	[Sunday_WD] [char](1) NULL CONSTRAINT [DF_Employee_Sunday_WD]  DEFAULT ('N'),
	[Status] [char](1) NULL,
	[Job_type] [char](50) NULL,
	[Leaves] [int] NULL,
	[Adv_staff] [int] NULL,
	[I_Tax] [int] NULL,
	[Telephone] [int] NULL,
	[EOBI] [int] NULL,
	[Overtime_day] [float] NULL,
	[Days] [float] NULL,
	[Overtime_Rate] [float] NULL,
	[Gross_Salary01] [float] NULL,
	[Total_Leaves] [int] NULL,
	[Date_joining] [date] NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[Emp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Holiday]    Script Date: 8/30/2022 7:22:23 PM ******/
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
/****** Object:  Table [dbo].[Leave_Deduction]    Script Date: 8/30/2022 7:22:23 PM ******/
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
	[Cancel_YN] [char](1) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Login]    Script Date: 8/30/2022 7:22:23 PM ******/
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
/****** Object:  Table [dbo].[Payroll]    Script Date: 8/30/2022 7:22:23 PM ******/
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
	[Leaves] [int] NULL,
	[Gross_Salary] [float] NULL,
	[Adv_Staff] [int] NULL,
	[I_Tax] [int] NULL,
	[Telephone] [int] NULL,
	[EOBI] [int] NULL,
	[Overtime_day] [float] NULL,
	[Overtime_Rate] [float] NULL,
	[Days] [float] NULL,
 CONSTRAINT [PK_Payroll] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sales]    Script Date: 8/30/2022 7:22:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[sales](
	[id] [int] NULL,
	[Sale_name] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tax_slab]    Script Date: 8/30/2022 7:22:23 PM ******/
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
/****** Object:  Table [dbo].[Users]    Script Date: 8/30/2022 7:22:23 PM ******/
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
INSERT [dbo].[Activity_log] ([Id], [Document], [Table_flag], [Activity_Type], [Activity_Date], [User_id]) VALUES (4, N'Fahim', N'Employee', N'Insert', CAST(N'2021-12-08 12:44:12.903' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[Activity_log] OFF
SET IDENTITY_INSERT [dbo].[Attendance_Sheet] ON 

INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9889, N'90', CAST(N'2022-05-01' AS Date), CAST(N'05:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9890, N'80', CAST(N'2022-05-01' AS Date), CAST(N'07:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9891, N'82', CAST(N'2022-05-01' AS Date), CAST(N'07:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9892, N'83', CAST(N'2022-05-01' AS Date), CAST(N'07:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9893, N'86', CAST(N'2022-05-01' AS Date), CAST(N'07:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9894, N'44', CAST(N'2022-05-01' AS Date), CAST(N'07:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9895, N'52', CAST(N'2022-05-01' AS Date), CAST(N'07:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9896, N'66', CAST(N'2022-05-01' AS Date), CAST(N'08:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9897, N'48', CAST(N'2022-05-01' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9898, N'42', CAST(N'2022-05-01' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9899, N'50', CAST(N'2022-05-01' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9900, N'40', CAST(N'2022-05-01' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9901, N'51', CAST(N'2022-05-01' AS Date), CAST(N'08:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9902, N'47', CAST(N'2022-05-01' AS Date), CAST(N'08:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9903, N'11', CAST(N'2022-05-01' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9904, N'73', CAST(N'2022-05-01' AS Date), CAST(N'08:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9905, N'49', CAST(N'2022-05-01' AS Date), CAST(N'08:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9906, N'11', CAST(N'2022-05-01' AS Date), CAST(N'08:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9907, N'65', CAST(N'2022-05-01' AS Date), CAST(N'08:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9908, N'76', CAST(N'2022-05-01' AS Date), CAST(N'08:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9909, N'69', CAST(N'2022-05-01' AS Date), CAST(N'09:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9910, N'21', CAST(N'2022-05-01' AS Date), CAST(N'09:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9911, N'38', CAST(N'2022-05-01' AS Date), CAST(N'10:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9912, N'27', CAST(N'2022-05-01' AS Date), CAST(N'10:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9913, N'7', CAST(N'2022-05-01' AS Date), CAST(N'10:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9914, N'35', CAST(N'2022-05-01' AS Date), CAST(N'11:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9915, N'65', CAST(N'2022-05-01' AS Date), CAST(N'12:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9916, N'44', CAST(N'2022-05-01' AS Date), CAST(N'13:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9917, N'35', CAST(N'2022-05-01' AS Date), CAST(N'13:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9918, N'45', CAST(N'2022-05-01' AS Date), CAST(N'13:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9919, N'46', CAST(N'2022-05-01' AS Date), CAST(N'14:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9920, N'53', CAST(N'2022-05-01' AS Date), CAST(N'14:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9921, N'51', CAST(N'2022-05-01' AS Date), CAST(N'14:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9922, N'69', CAST(N'2022-05-01' AS Date), CAST(N'18:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9923, N'70', CAST(N'2022-05-01' AS Date), CAST(N'19:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9924, N'40', CAST(N'2022-05-01' AS Date), CAST(N'19:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9925, N'80', CAST(N'2022-05-01' AS Date), CAST(N'19:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9926, N'59', CAST(N'2022-05-01' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9927, N'75', CAST(N'2022-05-01' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9928, N'86', CAST(N'2022-05-01' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9929, N'83', CAST(N'2022-05-01' AS Date), CAST(N'19:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9930, N'85', CAST(N'2022-05-01' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9931, N'48', CAST(N'2022-05-01' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9932, N'52', CAST(N'2022-05-01' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9933, N'49', CAST(N'2022-05-01' AS Date), CAST(N'20:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9934, N'45', CAST(N'2022-05-01' AS Date), CAST(N'20:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9935, N'42', CAST(N'2022-05-01' AS Date), CAST(N'20:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9936, N'46', CAST(N'2022-05-01' AS Date), CAST(N'20:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9937, N'11', CAST(N'2022-05-01' AS Date), CAST(N'20:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9938, N'73', CAST(N'2022-05-01' AS Date), CAST(N'20:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9939, N'38', CAST(N'2022-05-01' AS Date), CAST(N'20:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9940, N'27', CAST(N'2022-05-01' AS Date), CAST(N'21:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9941, N'21', CAST(N'2022-05-01' AS Date), CAST(N'21:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9942, N'83', CAST(N'2022-05-02' AS Date), CAST(N'07:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9943, N'47', CAST(N'2022-05-02' AS Date), CAST(N'07:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9944, N'86', CAST(N'2022-05-02' AS Date), CAST(N'07:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9945, N'23', CAST(N'2022-05-02' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9946, N'40', CAST(N'2022-05-02' AS Date), CAST(N'07:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9947, N'44', CAST(N'2022-05-02' AS Date), CAST(N'08:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9948, N'50', CAST(N'2022-05-02' AS Date), CAST(N'08:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9949, N'92', CAST(N'2022-05-02' AS Date), CAST(N'08:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9950, N'52', CAST(N'2022-05-02' AS Date), CAST(N'08:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9951, N'67', CAST(N'2022-05-02' AS Date), CAST(N'08:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9952, N'53', CAST(N'2022-05-02' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9953, N'41', CAST(N'2022-05-02' AS Date), CAST(N'08:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9954, N'51', CAST(N'2022-05-02' AS Date), CAST(N'08:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9955, N'85', CAST(N'2022-05-02' AS Date), CAST(N'08:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9956, N'48', CAST(N'2022-05-02' AS Date), CAST(N'08:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9957, N'73', CAST(N'2022-05-02' AS Date), CAST(N'08:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9958, N'75', CAST(N'2022-05-02' AS Date), CAST(N'08:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9959, N'80', CAST(N'2022-05-02' AS Date), CAST(N'08:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9960, N'49', CAST(N'2022-05-02' AS Date), CAST(N'08:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9961, N'58', CAST(N'2022-05-02' AS Date), CAST(N'08:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9962, N'81', CAST(N'2022-05-02' AS Date), CAST(N'08:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9963, N'64', CAST(N'2022-05-02' AS Date), CAST(N'08:30:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9964, N'60', CAST(N'2022-05-02' AS Date), CAST(N'08:38:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9965, N'16', CAST(N'2022-05-02' AS Date), CAST(N'08:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9966, N'28', CAST(N'2022-05-02' AS Date), CAST(N'08:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9967, N'6', CAST(N'2022-05-02' AS Date), CAST(N'08:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9968, N'69', CAST(N'2022-05-02' AS Date), CAST(N'09:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9969, N'14', CAST(N'2022-05-02' AS Date), CAST(N'09:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9970, N'65', CAST(N'2022-05-02' AS Date), CAST(N'09:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9971, N'24', CAST(N'2022-05-02' AS Date), CAST(N'09:36:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9972, N'89', CAST(N'2022-05-02' AS Date), CAST(N'09:37:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9973, N'27', CAST(N'2022-05-02' AS Date), CAST(N'09:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9974, N'12', CAST(N'2022-05-02' AS Date), CAST(N'09:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9975, N'21', CAST(N'2022-05-02' AS Date), CAST(N'10:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9976, N'13', CAST(N'2022-05-02' AS Date), CAST(N'10:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9977, N'15', CAST(N'2022-05-02' AS Date), CAST(N'10:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9978, N'29', CAST(N'2022-05-02' AS Date), CAST(N'10:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9979, N'38', CAST(N'2022-05-02' AS Date), CAST(N'10:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9980, N'26', CAST(N'2022-05-02' AS Date), CAST(N'11:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9981, N'20', CAST(N'2022-05-02' AS Date), CAST(N'11:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9982, N'71', CAST(N'2022-05-02' AS Date), CAST(N'11:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9983, N'55', CAST(N'2022-05-02' AS Date), CAST(N'11:40:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9984, N'65', CAST(N'2022-05-02' AS Date), CAST(N'11:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9985, N'77', CAST(N'2022-05-02' AS Date), CAST(N'11:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9986, N'72', CAST(N'2022-05-02' AS Date), CAST(N'11:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9987, N'74', CAST(N'2022-05-02' AS Date), CAST(N'12:09:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9988, N'16', CAST(N'2022-05-02' AS Date), CAST(N'13:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9989, N'18', CAST(N'2022-05-02' AS Date), CAST(N'13:36:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9990, N'67', CAST(N'2022-05-02' AS Date), CAST(N'13:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9991, N'46', CAST(N'2022-05-02' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9992, N'42', CAST(N'2022-05-02' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9993, N'45', CAST(N'2022-05-02' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9994, N'40', CAST(N'2022-05-02' AS Date), CAST(N'13:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9995, N'88', CAST(N'2022-05-02' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9996, N'93', CAST(N'2022-05-02' AS Date), CAST(N'14:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9997, N'3', CAST(N'2022-05-02' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9998, N'35', CAST(N'2022-05-02' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (9999, N'9', CAST(N'2022-05-02' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10000, N'78', CAST(N'2022-05-02' AS Date), CAST(N'14:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10001, N'6', CAST(N'2022-05-02' AS Date), CAST(N'14:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10002, N'44', CAST(N'2022-05-02' AS Date), CAST(N'14:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10003, N'41', CAST(N'2022-05-02' AS Date), CAST(N'14:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10004, N'60', CAST(N'2022-05-02' AS Date), CAST(N'14:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10005, N'58', CAST(N'2022-05-02' AS Date), CAST(N'14:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10006, N'53', CAST(N'2022-05-02' AS Date), CAST(N'14:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10007, N'80', CAST(N'2022-05-02' AS Date), CAST(N'14:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10008, N'51', CAST(N'2022-05-02' AS Date), CAST(N'14:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10009, N'92', CAST(N'2022-05-02' AS Date), CAST(N'14:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10010, N'37', CAST(N'2022-05-02' AS Date), CAST(N'14:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10011, N'73', CAST(N'2022-05-02' AS Date), CAST(N'14:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10012, N'87', CAST(N'2022-05-02' AS Date), CAST(N'14:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10013, N'32', CAST(N'2022-05-02' AS Date), CAST(N'14:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10014, N'34', CAST(N'2022-05-02' AS Date), CAST(N'15:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10015, N'47', CAST(N'2022-05-02' AS Date), CAST(N'15:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10016, N'57', CAST(N'2022-05-02' AS Date), CAST(N'15:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10017, N'24', CAST(N'2022-05-02' AS Date), CAST(N'15:43:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10018, N'25', CAST(N'2022-05-02' AS Date), CAST(N'15:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10019, N'14', CAST(N'2022-05-02' AS Date), CAST(N'16:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10020, N'39', CAST(N'2022-05-02' AS Date), CAST(N'16:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10021, N'89', CAST(N'2022-05-02' AS Date), CAST(N'16:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10022, N'38', CAST(N'2022-05-02' AS Date), CAST(N'17:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10023, N'74', CAST(N'2022-05-02' AS Date), CAST(N'17:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10024, N'12', CAST(N'2022-05-02' AS Date), CAST(N'17:35:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10025, N'64', CAST(N'2022-05-02' AS Date), CAST(N'17:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10026, N'69', CAST(N'2022-05-02' AS Date), CAST(N'17:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10027, N'71', CAST(N'2022-05-02' AS Date), CAST(N'17:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10028, N'72', CAST(N'2022-05-02' AS Date), CAST(N'17:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10029, N'77', CAST(N'2022-05-02' AS Date), CAST(N'18:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10030, N'15', CAST(N'2022-05-02' AS Date), CAST(N'18:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10031, N'55', CAST(N'2022-05-02' AS Date), CAST(N'18:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10032, N'31', CAST(N'2022-05-02' AS Date), CAST(N'18:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10033, N'18', CAST(N'2022-05-02' AS Date), CAST(N'19:36:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10034, N'85', CAST(N'2022-05-02' AS Date), CAST(N'19:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10035, N'70', CAST(N'2022-05-02' AS Date), CAST(N'19:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10036, N'66', CAST(N'2022-05-02' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10037, N'83', CAST(N'2022-05-02' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10038, N'86', CAST(N'2022-05-02' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10039, N'26', CAST(N'2022-05-02' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10040, N'76', CAST(N'2022-05-02' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10041, N'75', CAST(N'2022-05-02' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10042, N'48', CAST(N'2022-05-02' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10043, N'50', CAST(N'2022-05-02' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10044, N'57', CAST(N'2022-05-02' AS Date), CAST(N'20:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10045, N'7', CAST(N'2022-05-02' AS Date), CAST(N'20:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10046, N'88', CAST(N'2022-05-02' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10047, N'3', CAST(N'2022-05-02' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10048, N'42', CAST(N'2022-05-02' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10049, N'9', CAST(N'2022-05-02' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10050, N'11', CAST(N'2022-05-02' AS Date), CAST(N'20:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10051, N'78', CAST(N'2022-05-02' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10052, N'45', CAST(N'2022-05-02' AS Date), CAST(N'20:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10053, N'28', CAST(N'2022-05-02' AS Date), CAST(N'20:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10054, N'27', CAST(N'2022-05-02' AS Date), CAST(N'21:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10055, N'93', CAST(N'2022-05-02' AS Date), CAST(N'22:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10056, N'13', CAST(N'2022-05-02' AS Date), CAST(N'22:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10057, N'21', CAST(N'2022-05-02' AS Date), CAST(N'23:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10058, N'20', CAST(N'2022-05-02' AS Date), CAST(N'23:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10059, N'68', CAST(N'2022-05-03' AS Date), CAST(N'00:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10060, N'44', CAST(N'2022-05-03' AS Date), CAST(N'07:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10061, N'50', CAST(N'2022-05-03' AS Date), CAST(N'07:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10062, N'85', CAST(N'2022-05-03' AS Date), CAST(N'07:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10063, N'7', CAST(N'2022-05-03' AS Date), CAST(N'07:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10064, N'48', CAST(N'2022-05-03' AS Date), CAST(N'07:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10065, N'70', CAST(N'2022-05-03' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10066, N'51', CAST(N'2022-05-03' AS Date), CAST(N'08:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10067, N'92', CAST(N'2022-05-03' AS Date), CAST(N'08:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10068, N'75', CAST(N'2022-05-03' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10069, N'11', CAST(N'2022-05-03' AS Date), CAST(N'08:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10070, N'76', CAST(N'2022-05-03' AS Date), CAST(N'08:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10071, N'81', CAST(N'2022-05-03' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10072, N'86', CAST(N'2022-05-03' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10073, N'93', CAST(N'2022-05-03' AS Date), CAST(N'08:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10074, N'28', CAST(N'2022-05-03' AS Date), CAST(N'09:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10075, N'65', CAST(N'2022-05-03' AS Date), CAST(N'09:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10076, N'21', CAST(N'2022-05-03' AS Date), CAST(N'10:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10077, N'38', CAST(N'2022-05-03' AS Date), CAST(N'10:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10078, N'44', CAST(N'2022-05-03' AS Date), CAST(N'13:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10079, N'51', CAST(N'2022-05-03' AS Date), CAST(N'14:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10080, N'92', CAST(N'2022-05-03' AS Date), CAST(N'14:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10081, N'93', CAST(N'2022-05-03' AS Date), CAST(N'18:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10082, N'82', CAST(N'2022-05-03' AS Date), CAST(N'19:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10083, N'83', CAST(N'2022-05-03' AS Date), CAST(N'19:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10084, N'70', CAST(N'2022-05-03' AS Date), CAST(N'19:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10085, N'8', CAST(N'2022-05-03' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10086, N'50', CAST(N'2022-05-03' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10087, N'86', CAST(N'2022-05-03' AS Date), CAST(N'20:03:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10088, N'53', CAST(N'2022-05-03' AS Date), CAST(N'20:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10089, N'52', CAST(N'2022-05-03' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10090, N'81', CAST(N'2022-05-03' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10091, N'76', CAST(N'2022-05-03' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10092, N'48', CAST(N'2022-05-03' AS Date), CAST(N'20:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10093, N'61', CAST(N'2022-05-03' AS Date), CAST(N'20:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10094, N'28', CAST(N'2022-05-03' AS Date), CAST(N'20:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10095, N'65', CAST(N'2022-05-03' AS Date), CAST(N'20:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10096, N'39', CAST(N'2022-05-03' AS Date), CAST(N'21:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10097, N'21', CAST(N'2022-05-03' AS Date), CAST(N'21:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10098, N'44', CAST(N'2022-05-04' AS Date), CAST(N'07:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10099, N'82', CAST(N'2022-05-04' AS Date), CAST(N'07:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10100, N'59', CAST(N'2022-05-04' AS Date), CAST(N'07:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10101, N'52', CAST(N'2022-05-04' AS Date), CAST(N'07:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10102, N'51', CAST(N'2022-05-04' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10103, N'80', CAST(N'2022-05-04' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10104, N'50', CAST(N'2022-05-04' AS Date), CAST(N'08:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10105, N'8', CAST(N'2022-05-04' AS Date), CAST(N'08:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10106, N'92', CAST(N'2022-05-04' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10107, N'83', CAST(N'2022-05-04' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10108, N'86', CAST(N'2022-05-04' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10109, N'48', CAST(N'2022-05-04' AS Date), CAST(N'08:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10110, N'41', CAST(N'2022-05-04' AS Date), CAST(N'08:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10111, N'76', CAST(N'2022-05-04' AS Date), CAST(N'08:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10112, N'20', CAST(N'2022-05-04' AS Date), CAST(N'08:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10113, N'21', CAST(N'2022-05-04' AS Date), CAST(N'09:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10114, N'27', CAST(N'2022-05-04' AS Date), CAST(N'10:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10115, N'3', CAST(N'2022-05-04' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10116, N'86', CAST(N'2022-05-04' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10117, N'92', CAST(N'2022-05-04' AS Date), CAST(N'14:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10118, N'41', CAST(N'2022-05-04' AS Date), CAST(N'14:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10119, N'44', CAST(N'2022-05-04' AS Date), CAST(N'14:38:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10120, N'61', CAST(N'2022-05-04' AS Date), CAST(N'15:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10121, N'38', CAST(N'2022-05-04' AS Date), CAST(N'15:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10122, N'53', CAST(N'2022-05-04' AS Date), CAST(N'19:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10123, N'80', CAST(N'2022-05-04' AS Date), CAST(N'19:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10124, N'40', CAST(N'2022-05-04' AS Date), CAST(N'19:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10125, N'70', CAST(N'2022-05-04' AS Date), CAST(N'19:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10126, N'71', CAST(N'2022-05-04' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10127, N'82', CAST(N'2022-05-04' AS Date), CAST(N'19:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10128, N'59', CAST(N'2022-05-04' AS Date), CAST(N'20:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10129, N'76', CAST(N'2022-05-04' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10130, N'49', CAST(N'2022-05-04' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10131, N'83', CAST(N'2022-05-04' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10132, N'75', CAST(N'2022-05-04' AS Date), CAST(N'20:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10133, N'3', CAST(N'2022-05-04' AS Date), CAST(N'20:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10134, N'48', CAST(N'2022-05-04' AS Date), CAST(N'20:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10135, N'21', CAST(N'2022-05-04' AS Date), CAST(N'20:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10136, N'20', CAST(N'2022-05-04' AS Date), CAST(N'21:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10137, N'62', CAST(N'2022-05-04' AS Date), CAST(N'21:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10138, N'27', CAST(N'2022-05-04' AS Date), CAST(N'21:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10139, N'82', CAST(N'2022-05-05' AS Date), CAST(N'07:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10140, N'53', CAST(N'2022-05-05' AS Date), CAST(N'07:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10141, N'83', CAST(N'2022-05-05' AS Date), CAST(N'07:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10142, N'72', CAST(N'2022-05-05' AS Date), CAST(N'07:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10143, N'51', CAST(N'2022-05-05' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10144, N'68', CAST(N'2022-05-05' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10145, N'48', CAST(N'2022-05-05' AS Date), CAST(N'08:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10146, N'58', CAST(N'2022-05-05' AS Date), CAST(N'08:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10147, N'9', CAST(N'2022-05-05' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10148, N'75', CAST(N'2022-05-05' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10149, N'49', CAST(N'2022-05-05' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10150, N'86', CAST(N'2022-05-05' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10151, N'60', CAST(N'2022-05-05' AS Date), CAST(N'08:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10152, N'71', CAST(N'2022-05-05' AS Date), CAST(N'08:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10153, N'40', CAST(N'2022-05-05' AS Date), CAST(N'08:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10154, N'92', CAST(N'2022-05-05' AS Date), CAST(N'08:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10155, N'41', CAST(N'2022-05-05' AS Date), CAST(N'08:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10156, N'76', CAST(N'2022-05-05' AS Date), CAST(N'08:39:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10157, N'38', CAST(N'2022-05-05' AS Date), CAST(N'08:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10158, N'28', CAST(N'2022-05-05' AS Date), CAST(N'08:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10159, N'89', CAST(N'2022-05-05' AS Date), CAST(N'09:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10160, N'62', CAST(N'2022-05-05' AS Date), CAST(N'09:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10161, N'21', CAST(N'2022-05-05' AS Date), CAST(N'10:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10162, N'45', CAST(N'2022-05-05' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10163, N'3', CAST(N'2022-05-05' AS Date), CAST(N'14:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10164, N'60', CAST(N'2022-05-05' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10165, N'92', CAST(N'2022-05-05' AS Date), CAST(N'14:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10166, N'53', CAST(N'2022-05-05' AS Date), CAST(N'14:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10167, N'58', CAST(N'2022-05-05' AS Date), CAST(N'14:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10168, N'72', CAST(N'2022-05-05' AS Date), CAST(N'14:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10169, N'37', CAST(N'2022-05-05' AS Date), CAST(N'14:40:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10170, N'41', CAST(N'2022-05-05' AS Date), CAST(N'14:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10171, N'39', CAST(N'2022-05-05' AS Date), CAST(N'15:39:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10172, N'68', CAST(N'2022-05-05' AS Date), CAST(N'18:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10173, N'83', CAST(N'2022-05-05' AS Date), CAST(N'18:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10174, N'70', CAST(N'2022-05-05' AS Date), CAST(N'19:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10175, N'8', CAST(N'2022-05-05' AS Date), CAST(N'19:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10176, N'82', CAST(N'2022-05-05' AS Date), CAST(N'19:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10177, N'40', CAST(N'2022-05-05' AS Date), CAST(N'19:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10178, N'52', CAST(N'2022-05-05' AS Date), CAST(N'19:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10179, N'3', CAST(N'2022-05-05' AS Date), CAST(N'19:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10180, N'75', CAST(N'2022-05-05' AS Date), CAST(N'20:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10181, N'45', CAST(N'2022-05-05' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10182, N'76', CAST(N'2022-05-05' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10183, N'49', CAST(N'2022-05-05' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10184, N'85', CAST(N'2022-05-05' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10185, N'71', CAST(N'2022-05-05' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10186, N'37', CAST(N'2022-05-05' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10187, N'51', CAST(N'2022-05-05' AS Date), CAST(N'20:11:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10188, N'9', CAST(N'2022-05-05' AS Date), CAST(N'20:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10189, N'28', CAST(N'2022-05-05' AS Date), CAST(N'21:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10190, N'82', CAST(N'2022-05-06' AS Date), CAST(N'07:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10191, N'47', CAST(N'2022-05-06' AS Date), CAST(N'07:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10192, N'59', CAST(N'2022-05-06' AS Date), CAST(N'07:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10193, N'51', CAST(N'2022-05-06' AS Date), CAST(N'07:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10194, N'23', CAST(N'2022-05-06' AS Date), CAST(N'08:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10195, N'68', CAST(N'2022-05-06' AS Date), CAST(N'08:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10196, N'44', CAST(N'2022-05-06' AS Date), CAST(N'08:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10197, N'53', CAST(N'2022-05-06' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10198, N'52', CAST(N'2022-05-06' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10199, N'58', CAST(N'2022-05-06' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10200, N'67', CAST(N'2022-05-06' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10201, N'8', CAST(N'2022-05-06' AS Date), CAST(N'08:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10202, N'75', CAST(N'2022-05-06' AS Date), CAST(N'08:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10203, N'60', CAST(N'2022-05-06' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10204, N'49', CAST(N'2022-05-06' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10205, N'66', CAST(N'2022-05-06' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10206, N'85', CAST(N'2022-05-06' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10207, N'41', CAST(N'2022-05-06' AS Date), CAST(N'08:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10208, N'73', CAST(N'2022-05-06' AS Date), CAST(N'08:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10209, N'92', CAST(N'2022-05-06' AS Date), CAST(N'08:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10210, N'81', CAST(N'2022-05-06' AS Date), CAST(N'08:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10211, N'64', CAST(N'2022-05-06' AS Date), CAST(N'08:29:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10212, N'40', CAST(N'2022-05-06' AS Date), CAST(N'08:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10213, N'56', CAST(N'2022-05-06' AS Date), CAST(N'08:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10214, N'76', CAST(N'2022-05-06' AS Date), CAST(N'08:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10215, N'65', CAST(N'2022-05-06' AS Date), CAST(N'08:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10216, N'69', CAST(N'2022-05-06' AS Date), CAST(N'09:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10217, N'14', CAST(N'2022-05-06' AS Date), CAST(N'09:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10218, N'20', CAST(N'2022-05-06' AS Date), CAST(N'09:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10219, N'6', CAST(N'2022-05-06' AS Date), CAST(N'09:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10220, N'27', CAST(N'2022-05-06' AS Date), CAST(N'09:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10221, N'12', CAST(N'2022-05-06' AS Date), CAST(N'10:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10222, N'15', CAST(N'2022-05-06' AS Date), CAST(N'10:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10223, N'13', CAST(N'2022-05-06' AS Date), CAST(N'10:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10224, N'16', CAST(N'2022-05-06' AS Date), CAST(N'10:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10225, N'2', CAST(N'2022-05-06' AS Date), CAST(N'10:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10226, N'29', CAST(N'2022-05-06' AS Date), CAST(N'10:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10227, N'71', CAST(N'2022-05-06' AS Date), CAST(N'11:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10228, N'26', CAST(N'2022-05-06' AS Date), CAST(N'11:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10229, N'77', CAST(N'2022-05-06' AS Date), CAST(N'13:37:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10230, N'44', CAST(N'2022-05-06' AS Date), CAST(N'13:41:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10231, N'40', CAST(N'2022-05-06' AS Date), CAST(N'13:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10232, N'74', CAST(N'2022-05-06' AS Date), CAST(N'13:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10233, N'93', CAST(N'2022-05-06' AS Date), CAST(N'13:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10234, N'67', CAST(N'2022-05-06' AS Date), CAST(N'13:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10235, N'42', CAST(N'2022-05-06' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10236, N'60', CAST(N'2022-05-06' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10237, N'45', CAST(N'2022-05-06' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10238, N'9', CAST(N'2022-05-06' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10239, N'3', CAST(N'2022-05-06' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10240, N'46', CAST(N'2022-05-06' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10241, N'6', CAST(N'2022-05-06' AS Date), CAST(N'14:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10242, N'53', CAST(N'2022-05-06' AS Date), CAST(N'14:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10243, N'41', CAST(N'2022-05-06' AS Date), CAST(N'14:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10244, N'78', CAST(N'2022-05-06' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10245, N'58', CAST(N'2022-05-06' AS Date), CAST(N'14:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10246, N'73', CAST(N'2022-05-06' AS Date), CAST(N'14:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10247, N'87', CAST(N'2022-05-06' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10248, N'51', CAST(N'2022-05-06' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10249, N'47', CAST(N'2022-05-06' AS Date), CAST(N'14:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10250, N'18', CAST(N'2022-05-06' AS Date), CAST(N'14:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10251, N'88', CAST(N'2022-05-06' AS Date), CAST(N'14:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10252, N'35', CAST(N'2022-05-06' AS Date), CAST(N'14:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10253, N'37', CAST(N'2022-05-06' AS Date), CAST(N'14:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10254, N'56', CAST(N'2022-05-06' AS Date), CAST(N'14:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10255, N'72', CAST(N'2022-05-06' AS Date), CAST(N'14:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10256, N'34', CAST(N'2022-05-06' AS Date), CAST(N'14:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10257, N'31', CAST(N'2022-05-06' AS Date), CAST(N'14:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10258, N'23', CAST(N'2022-05-06' AS Date), CAST(N'14:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10259, N'2', CAST(N'2022-05-06' AS Date), CAST(N'15:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10260, N'43', CAST(N'2022-05-06' AS Date), CAST(N'15:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10261, N'16', CAST(N'2022-05-06' AS Date), CAST(N'15:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10262, N'22', CAST(N'2022-05-06' AS Date), CAST(N'15:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10263, N'17', CAST(N'2022-05-06' AS Date), CAST(N'15:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10264, N'57', CAST(N'2022-05-06' AS Date), CAST(N'15:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10265, N'32', CAST(N'2022-05-06' AS Date), CAST(N'15:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10266, N'33', CAST(N'2022-05-06' AS Date), CAST(N'15:29:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10267, N'25', CAST(N'2022-05-06' AS Date), CAST(N'15:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10268, N'14', CAST(N'2022-05-06' AS Date), CAST(N'15:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10269, N'55', CAST(N'2022-05-06' AS Date), CAST(N'16:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10270, N'39', CAST(N'2022-05-06' AS Date), CAST(N'16:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10271, N'38', CAST(N'2022-05-06' AS Date), CAST(N'16:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10272, N'27', CAST(N'2022-05-06' AS Date), CAST(N'18:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10273, N'71', CAST(N'2022-05-06' AS Date), CAST(N'18:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10274, N'12', CAST(N'2022-05-06' AS Date), CAST(N'18:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10275, N'15', CAST(N'2022-05-06' AS Date), CAST(N'19:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10276, N'85', CAST(N'2022-05-06' AS Date), CAST(N'19:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10277, N'74', CAST(N'2022-05-06' AS Date), CAST(N'19:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10278, N'11', CAST(N'2022-05-06' AS Date), CAST(N'19:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10279, N'52', CAST(N'2022-05-06' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10280, N'70', CAST(N'2022-05-06' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10281, N'86', CAST(N'2022-05-06' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10282, N'7', CAST(N'2022-05-06' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10283, N'26', CAST(N'2022-05-06' AS Date), CAST(N'20:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10284, N'3', CAST(N'2022-05-06' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10285, N'9', CAST(N'2022-05-06' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10286, N'57', CAST(N'2022-05-06' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10287, N'76', CAST(N'2022-05-06' AS Date), CAST(N'20:03:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10288, N'37', CAST(N'2022-05-06' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10289, N'50', CAST(N'2022-05-06' AS Date), CAST(N'20:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10290, N'75', CAST(N'2022-05-06' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10291, N'59', CAST(N'2022-05-06' AS Date), CAST(N'20:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10292, N'48', CAST(N'2022-05-06' AS Date), CAST(N'20:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10293, N'92', CAST(N'2022-05-06' AS Date), CAST(N'20:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10294, N'49', CAST(N'2022-05-06' AS Date), CAST(N'20:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10295, N'77', CAST(N'2022-05-06' AS Date), CAST(N'20:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10296, N'79', CAST(N'2022-05-06' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10297, N'93', CAST(N'2022-05-06' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10298, N'78', CAST(N'2022-05-06' AS Date), CAST(N'20:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10299, N'46', CAST(N'2022-05-06' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10300, N'45', CAST(N'2022-05-06' AS Date), CAST(N'20:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10301, N'43', CAST(N'2022-05-06' AS Date), CAST(N'20:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10302, N'42', CAST(N'2022-05-06' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10303, N'88', CAST(N'2022-05-06' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10304, N'82', CAST(N'2022-05-06' AS Date), CAST(N'20:37:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10305, N'13', CAST(N'2022-05-06' AS Date), CAST(N'20:40:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10306, N'18', CAST(N'2022-05-06' AS Date), CAST(N'20:40:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10307, N'72', CAST(N'2022-05-06' AS Date), CAST(N'20:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10308, N'65', CAST(N'2022-05-06' AS Date), CAST(N'20:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10309, N'55', CAST(N'2022-05-06' AS Date), CAST(N'20:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10310, N'28', CAST(N'2022-05-06' AS Date), CAST(N'20:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10311, N'21', CAST(N'2022-05-06' AS Date), CAST(N'20:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10312, N'29', CAST(N'2022-05-06' AS Date), CAST(N'20:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10313, N'64', CAST(N'2022-05-06' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10314, N'69', CAST(N'2022-05-06' AS Date), CAST(N'21:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10315, N'20', CAST(N'2022-05-06' AS Date), CAST(N'21:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10316, N'81', CAST(N'2022-05-06' AS Date), CAST(N'21:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10317, N'17', CAST(N'2022-05-06' AS Date), CAST(N'21:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10318, N'34', CAST(N'2022-05-06' AS Date), CAST(N'21:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10319, N'31', CAST(N'2022-05-06' AS Date), CAST(N'21:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10320, N'35', CAST(N'2022-05-06' AS Date), CAST(N'21:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10321, N'33', CAST(N'2022-05-06' AS Date), CAST(N'21:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10322, N'22', CAST(N'2022-05-06' AS Date), CAST(N'21:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10323, N'87', CAST(N'2022-05-06' AS Date), CAST(N'22:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10324, N'32', CAST(N'2022-05-06' AS Date), CAST(N'22:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10325, N'68', CAST(N'2022-05-06' AS Date), CAST(N'23:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10326, N'82', CAST(N'2022-05-07' AS Date), CAST(N'07:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10327, N'47', CAST(N'2022-05-07' AS Date), CAST(N'07:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10328, N'86', CAST(N'2022-05-07' AS Date), CAST(N'07:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10329, N'92', CAST(N'2022-05-07' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10330, N'44', CAST(N'2022-05-07' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10331, N'53', CAST(N'2022-05-07' AS Date), CAST(N'07:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10332, N'23', CAST(N'2022-05-07' AS Date), CAST(N'07:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10333, N'52', CAST(N'2022-05-07' AS Date), CAST(N'07:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10334, N'51', CAST(N'2022-05-07' AS Date), CAST(N'07:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10335, N'59', CAST(N'2022-05-07' AS Date), CAST(N'07:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10336, N'58', CAST(N'2022-05-07' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10337, N'93', CAST(N'2022-05-07' AS Date), CAST(N'08:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10338, N'49', CAST(N'2022-05-07' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10339, N'50', CAST(N'2022-05-07' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10340, N'67', CAST(N'2022-05-07' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10341, N'60', CAST(N'2022-05-07' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10342, N'48', CAST(N'2022-05-07' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10343, N'68', CAST(N'2022-05-07' AS Date), CAST(N'08:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10344, N'75', CAST(N'2022-05-07' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10345, N'85', CAST(N'2022-05-07' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10346, N'7', CAST(N'2022-05-07' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10347, N'66', CAST(N'2022-05-07' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10348, N'11', CAST(N'2022-05-07' AS Date), CAST(N'08:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10349, N'73', CAST(N'2022-05-07' AS Date), CAST(N'08:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10350, N'40', CAST(N'2022-05-07' AS Date), CAST(N'08:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10351, N'41', CAST(N'2022-05-07' AS Date), CAST(N'08:40:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10352, N'56', CAST(N'2022-05-07' AS Date), CAST(N'08:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10353, N'76', CAST(N'2022-05-07' AS Date), CAST(N'08:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10354, N'28', CAST(N'2022-05-07' AS Date), CAST(N'08:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10355, N'65', CAST(N'2022-05-07' AS Date), CAST(N'09:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10356, N'14', CAST(N'2022-05-07' AS Date), CAST(N'09:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10357, N'69', CAST(N'2022-05-07' AS Date), CAST(N'09:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10358, N'6', CAST(N'2022-05-07' AS Date), CAST(N'09:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10359, N'81', CAST(N'2022-05-07' AS Date), CAST(N'09:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10360, N'62', CAST(N'2022-05-07' AS Date), CAST(N'09:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10361, N'20', CAST(N'2022-05-07' AS Date), CAST(N'09:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10362, N'27', CAST(N'2022-05-07' AS Date), CAST(N'09:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10363, N'21', CAST(N'2022-05-07' AS Date), CAST(N'10:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10364, N'12', CAST(N'2022-05-07' AS Date), CAST(N'10:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10365, N'13', CAST(N'2022-05-07' AS Date), CAST(N'10:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10366, N'29', CAST(N'2022-05-07' AS Date), CAST(N'10:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10367, N'16', CAST(N'2022-05-07' AS Date), CAST(N'10:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10368, N'15', CAST(N'2022-05-07' AS Date), CAST(N'10:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10369, N'71', CAST(N'2022-05-07' AS Date), CAST(N'11:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10370, N'2', CAST(N'2022-05-07' AS Date), CAST(N'11:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10371, N'26', CAST(N'2022-05-07' AS Date), CAST(N'11:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10372, N'74', CAST(N'2022-05-07' AS Date), CAST(N'13:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10373, N'72', CAST(N'2022-05-07' AS Date), CAST(N'13:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10374, N'40', CAST(N'2022-05-07' AS Date), CAST(N'13:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10375, N'78', CAST(N'2022-05-07' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10376, N'42', CAST(N'2022-05-07' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10377, N'45', CAST(N'2022-05-07' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10378, N'67', CAST(N'2022-05-07' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10379, N'88', CAST(N'2022-05-07' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10380, N'44', CAST(N'2022-05-07' AS Date), CAST(N'13:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10381, N'43', CAST(N'2022-05-07' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10382, N'60', CAST(N'2022-05-07' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10383, N'3', CAST(N'2022-05-07' AS Date), CAST(N'14:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10384, N'9', CAST(N'2022-05-07' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10385, N'92', CAST(N'2022-05-07' AS Date), CAST(N'14:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10386, N'46', CAST(N'2022-05-07' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10387, N'79', CAST(N'2022-05-07' AS Date), CAST(N'14:04:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10388, N'18', CAST(N'2022-05-07' AS Date), CAST(N'14:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10389, N'53', CAST(N'2022-05-07' AS Date), CAST(N'14:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10390, N'6', CAST(N'2022-05-07' AS Date), CAST(N'14:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10391, N'58', CAST(N'2022-05-07' AS Date), CAST(N'14:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10392, N'35', CAST(N'2022-05-07' AS Date), CAST(N'14:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10393, N'51', CAST(N'2022-05-07' AS Date), CAST(N'14:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10394, N'47', CAST(N'2022-05-07' AS Date), CAST(N'14:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10395, N'22', CAST(N'2022-05-07' AS Date), CAST(N'14:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10396, N'73', CAST(N'2022-05-07' AS Date), CAST(N'14:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10397, N'34', CAST(N'2022-05-07' AS Date), CAST(N'14:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10398, N'55', CAST(N'2022-05-07' AS Date), CAST(N'14:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10399, N'41', CAST(N'2022-05-07' AS Date), CAST(N'14:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10400, N'56', CAST(N'2022-05-07' AS Date), CAST(N'14:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10401, N'23', CAST(N'2022-05-07' AS Date), CAST(N'15:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10402, N'17', CAST(N'2022-05-07' AS Date), CAST(N'15:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10403, N'16', CAST(N'2022-05-07' AS Date), CAST(N'15:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10404, N'31', CAST(N'2022-05-07' AS Date), CAST(N'15:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10405, N'57', CAST(N'2022-05-07' AS Date), CAST(N'15:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10406, N'87', CAST(N'2022-05-07' AS Date), CAST(N'15:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10407, N'32', CAST(N'2022-05-07' AS Date), CAST(N'15:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10408, N'39', CAST(N'2022-05-07' AS Date), CAST(N'16:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10409, N'71', CAST(N'2022-05-07' AS Date), CAST(N'17:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10410, N'12', CAST(N'2022-05-07' AS Date), CAST(N'18:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10411, N'8', CAST(N'2022-05-07' AS Date), CAST(N'19:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10412, N'85', CAST(N'2022-05-07' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10413, N'3', CAST(N'2022-05-07' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10414, N'68', CAST(N'2022-05-07' AS Date), CAST(N'19:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10415, N'48', CAST(N'2022-05-07' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10416, N'52', CAST(N'2022-05-07' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10417, N'70', CAST(N'2022-05-07' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10418, N'93', CAST(N'2022-05-07' AS Date), CAST(N'20:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10419, N'91', CAST(N'2022-05-07' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10420, N'76', CAST(N'2022-05-07' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10421, N'26', CAST(N'2022-05-07' AS Date), CAST(N'20:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10422, N'86', CAST(N'2022-05-07' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10423, N'49', CAST(N'2022-05-07' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10424, N'9', CAST(N'2022-05-07' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10425, N'57', CAST(N'2022-05-07' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10426, N'50', CAST(N'2022-05-07' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10427, N'82', CAST(N'2022-05-07' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10428, N'79', CAST(N'2022-05-07' AS Date), CAST(N'20:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10429, N'59', CAST(N'2022-05-07' AS Date), CAST(N'20:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10430, N'61', CAST(N'2022-05-07' AS Date), CAST(N'20:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10431, N'69', CAST(N'2022-05-07' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10432, N'66', CAST(N'2022-05-07' AS Date), CAST(N'20:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10433, N'43', CAST(N'2022-05-07' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10434, N'42', CAST(N'2022-05-07' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10435, N'46', CAST(N'2022-05-07' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10436, N'45', CAST(N'2022-05-07' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10437, N'18', CAST(N'2022-05-07' AS Date), CAST(N'20:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10438, N'15', CAST(N'2022-05-07' AS Date), CAST(N'20:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10439, N'78', CAST(N'2022-05-07' AS Date), CAST(N'20:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10440, N'88', CAST(N'2022-05-07' AS Date), CAST(N'20:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10441, N'65', CAST(N'2022-05-07' AS Date), CAST(N'20:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10442, N'62', CAST(N'2022-05-07' AS Date), CAST(N'20:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10443, N'35', CAST(N'2022-05-07' AS Date), CAST(N'20:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10444, N'21', CAST(N'2022-05-07' AS Date), CAST(N'20:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10445, N'87', CAST(N'2022-05-07' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10446, N'32', CAST(N'2022-05-07' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10447, N'28', CAST(N'2022-05-07' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10448, N'55', CAST(N'2022-05-07' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10449, N'64', CAST(N'2022-05-07' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10450, N'72', CAST(N'2022-05-07' AS Date), CAST(N'21:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10451, N'20', CAST(N'2022-05-07' AS Date), CAST(N'21:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10452, N'81', CAST(N'2022-05-07' AS Date), CAST(N'21:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10453, N'17', CAST(N'2022-05-07' AS Date), CAST(N'21:39:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10454, N'22', CAST(N'2022-05-07' AS Date), CAST(N'21:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10455, N'27', CAST(N'2022-05-07' AS Date), CAST(N'21:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10456, N'13', CAST(N'2022-05-07' AS Date), CAST(N'22:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10457, N'82', CAST(N'2022-05-08' AS Date), CAST(N'07:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10458, N'86', CAST(N'2022-05-08' AS Date), CAST(N'07:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10459, N'47', CAST(N'2022-05-08' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10460, N'11', CAST(N'2022-05-08' AS Date), CAST(N'07:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10461, N'45', CAST(N'2022-05-08' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10462, N'52', CAST(N'2022-05-08' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10463, N'58', CAST(N'2022-05-08' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10464, N'66', CAST(N'2022-05-08' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10465, N'49', CAST(N'2022-05-08' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10466, N'48', CAST(N'2022-05-08' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10467, N'42', CAST(N'2022-05-08' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10468, N'50', CAST(N'2022-05-08' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10469, N'8', CAST(N'2022-05-08' AS Date), CAST(N'08:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10470, N'60', CAST(N'2022-05-08' AS Date), CAST(N'08:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10471, N'91', CAST(N'2022-05-08' AS Date), CAST(N'08:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10472, N'40', CAST(N'2022-05-08' AS Date), CAST(N'08:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10473, N'81', CAST(N'2022-05-08' AS Date), CAST(N'08:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10474, N'65', CAST(N'2022-05-08' AS Date), CAST(N'08:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10475, N'21', CAST(N'2022-05-08' AS Date), CAST(N'09:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10476, N'83', CAST(N'2022-05-08' AS Date), CAST(N'09:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10477, N'76', CAST(N'2022-05-08' AS Date), CAST(N'09:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10478, N'27', CAST(N'2022-05-08' AS Date), CAST(N'09:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10479, N'38', CAST(N'2022-05-08' AS Date), CAST(N'10:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10480, N'40', CAST(N'2022-05-08' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10481, N'60', CAST(N'2022-05-08' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10482, N'43', CAST(N'2022-05-08' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10483, N'46', CAST(N'2022-05-08' AS Date), CAST(N'14:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10484, N'45', CAST(N'2022-05-08' AS Date), CAST(N'14:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10485, N'58', CAST(N'2022-05-08' AS Date), CAST(N'14:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10486, N'47', CAST(N'2022-05-08' AS Date), CAST(N'14:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10487, N'91', CAST(N'2022-05-08' AS Date), CAST(N'19:47:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10488, N'86', CAST(N'2022-05-08' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10489, N'52', CAST(N'2022-05-08' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10490, N'81', CAST(N'2022-05-08' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10491, N'11', CAST(N'2022-05-08' AS Date), CAST(N'20:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10492, N'11', CAST(N'2022-05-08' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10493, N'7', CAST(N'2022-05-08' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10494, N'48', CAST(N'2022-05-08' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10495, N'75', CAST(N'2022-05-08' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10496, N'50', CAST(N'2022-05-08' AS Date), CAST(N'20:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10497, N'43', CAST(N'2022-05-08' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10498, N'42', CAST(N'2022-05-08' AS Date), CAST(N'20:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10499, N'46', CAST(N'2022-05-08' AS Date), CAST(N'20:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10500, N'78', CAST(N'2022-05-08' AS Date), CAST(N'20:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10501, N'21', CAST(N'2022-05-08' AS Date), CAST(N'20:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10502, N'39', CAST(N'2022-05-08' AS Date), CAST(N'21:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10503, N'62', CAST(N'2022-05-08' AS Date), CAST(N'21:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10504, N'82', CAST(N'2022-05-08' AS Date), CAST(N'21:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10505, N'83', CAST(N'2022-05-08' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10506, N'65', CAST(N'2022-05-08' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10507, N'38', CAST(N'2022-05-08' AS Date), CAST(N'21:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10508, N'27', CAST(N'2022-05-08' AS Date), CAST(N'21:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10509, N'59', CAST(N'2022-05-09' AS Date), CAST(N'07:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10510, N'53', CAST(N'2022-05-09' AS Date), CAST(N'07:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10511, N'23', CAST(N'2022-05-09' AS Date), CAST(N'07:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10512, N'92', CAST(N'2022-05-09' AS Date), CAST(N'07:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10513, N'44', CAST(N'2022-05-09' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10514, N'52', CAST(N'2022-05-09' AS Date), CAST(N'07:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10515, N'91', CAST(N'2022-05-09' AS Date), CAST(N'07:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10516, N'83', CAST(N'2022-05-09' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10517, N'51', CAST(N'2022-05-09' AS Date), CAST(N'08:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10518, N'48', CAST(N'2022-05-09' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10519, N'50', CAST(N'2022-05-09' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10520, N'86', CAST(N'2022-05-09' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10521, N'73', CAST(N'2022-05-09' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10522, N'58', CAST(N'2022-05-09' AS Date), CAST(N'08:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10523, N'68', CAST(N'2022-05-09' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10524, N'67', CAST(N'2022-05-09' AS Date), CAST(N'08:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10525, N'60', CAST(N'2022-05-09' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10526, N'80', CAST(N'2022-05-09' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10527, N'11', CAST(N'2022-05-09' AS Date), CAST(N'08:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10528, N'75', CAST(N'2022-05-09' AS Date), CAST(N'08:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10529, N'41', CAST(N'2022-05-09' AS Date), CAST(N'08:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10530, N'40', CAST(N'2022-05-09' AS Date), CAST(N'08:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10531, N'7', CAST(N'2022-05-09' AS Date), CAST(N'08:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10532, N'81', CAST(N'2022-05-09' AS Date), CAST(N'08:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10533, N'65', CAST(N'2022-05-09' AS Date), CAST(N'08:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10534, N'20', CAST(N'2022-05-09' AS Date), CAST(N'09:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10535, N'28', CAST(N'2022-05-09' AS Date), CAST(N'09:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10536, N'56', CAST(N'2022-05-09' AS Date), CAST(N'09:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10537, N'89', CAST(N'2022-05-09' AS Date), CAST(N'09:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10538, N'14', CAST(N'2022-05-09' AS Date), CAST(N'09:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10539, N'6', CAST(N'2022-05-09' AS Date), CAST(N'09:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10540, N'62', CAST(N'2022-05-09' AS Date), CAST(N'09:36:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10541, N'24', CAST(N'2022-05-09' AS Date), CAST(N'09:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10542, N'21', CAST(N'2022-05-09' AS Date), CAST(N'09:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10543, N'27', CAST(N'2022-05-09' AS Date), CAST(N'09:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10544, N'15', CAST(N'2022-05-09' AS Date), CAST(N'10:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10545, N'12', CAST(N'2022-05-09' AS Date), CAST(N'10:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10546, N'29', CAST(N'2022-05-09' AS Date), CAST(N'10:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10547, N'16', CAST(N'2022-05-09' AS Date), CAST(N'10:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10548, N'13', CAST(N'2022-05-09' AS Date), CAST(N'10:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10549, N'38', CAST(N'2022-05-09' AS Date), CAST(N'11:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10550, N'71', CAST(N'2022-05-09' AS Date), CAST(N'11:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10551, N'26', CAST(N'2022-05-09' AS Date), CAST(N'11:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10552, N'74', CAST(N'2022-05-09' AS Date), CAST(N'13:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10553, N'93', CAST(N'2022-05-09' AS Date), CAST(N'13:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10554, N'18', CAST(N'2022-05-09' AS Date), CAST(N'13:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10555, N'44', CAST(N'2022-05-09' AS Date), CAST(N'13:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10556, N'77', CAST(N'2022-05-09' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10557, N'78', CAST(N'2022-05-09' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10558, N'40', CAST(N'2022-05-09' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10559, N'42', CAST(N'2022-05-09' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10560, N'45', CAST(N'2022-05-09' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10561, N'88', CAST(N'2022-05-09' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10562, N'60', CAST(N'2022-05-09' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10563, N'3', CAST(N'2022-05-09' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10564, N'9', CAST(N'2022-05-09' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10565, N'46', CAST(N'2022-05-09' AS Date), CAST(N'14:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10566, N'80', CAST(N'2022-05-09' AS Date), CAST(N'14:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10567, N'53', CAST(N'2022-05-09' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10568, N'67', CAST(N'2022-05-09' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10569, N'43', CAST(N'2022-05-09' AS Date), CAST(N'14:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10570, N'35', CAST(N'2022-05-09' AS Date), CAST(N'14:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10571, N'6', CAST(N'2022-05-09' AS Date), CAST(N'14:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10572, N'58', CAST(N'2022-05-09' AS Date), CAST(N'14:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10573, N'92', CAST(N'2022-05-09' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10574, N'79', CAST(N'2022-05-09' AS Date), CAST(N'14:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10575, N'41', CAST(N'2022-05-09' AS Date), CAST(N'14:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10576, N'73', CAST(N'2022-05-09' AS Date), CAST(N'14:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10577, N'37', CAST(N'2022-05-09' AS Date), CAST(N'14:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10578, N'72', CAST(N'2022-05-09' AS Date), CAST(N'14:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10579, N'34', CAST(N'2022-05-09' AS Date), CAST(N'14:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10580, N'55', CAST(N'2022-05-09' AS Date), CAST(N'14:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10581, N'56', CAST(N'2022-05-09' AS Date), CAST(N'14:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10582, N'23', CAST(N'2022-05-09' AS Date), CAST(N'15:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10583, N'16', CAST(N'2022-05-09' AS Date), CAST(N'15:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10584, N'17', CAST(N'2022-05-09' AS Date), CAST(N'15:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10585, N'32', CAST(N'2022-05-09' AS Date), CAST(N'15:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10586, N'31', CAST(N'2022-05-09' AS Date), CAST(N'15:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10587, N'57', CAST(N'2022-05-09' AS Date), CAST(N'15:30:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10588, N'87', CAST(N'2022-05-09' AS Date), CAST(N'15:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10589, N'25', CAST(N'2022-05-09' AS Date), CAST(N'15:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10590, N'14', CAST(N'2022-05-09' AS Date), CAST(N'16:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10591, N'39', CAST(N'2022-05-09' AS Date), CAST(N'16:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10592, N'89', CAST(N'2022-05-09' AS Date), CAST(N'17:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10593, N'38', CAST(N'2022-05-09' AS Date), CAST(N'17:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10594, N'26', CAST(N'2022-05-09' AS Date), CAST(N'17:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10595, N'71', CAST(N'2022-05-09' AS Date), CAST(N'17:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10596, N'24', CAST(N'2022-05-09' AS Date), CAST(N'18:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10597, N'8', CAST(N'2022-05-09' AS Date), CAST(N'19:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10598, N'91', CAST(N'2022-05-09' AS Date), CAST(N'19:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10599, N'82', CAST(N'2022-05-09' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10600, N'83', CAST(N'2022-05-09' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10601, N'93', CAST(N'2022-05-09' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10602, N'74', CAST(N'2022-05-09' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10603, N'3', CAST(N'2022-05-09' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10604, N'52', CAST(N'2022-05-09' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10605, N'85', CAST(N'2022-05-09' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10606, N'86', CAST(N'2022-05-09' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10607, N'76', CAST(N'2022-05-09' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10608, N'77', CAST(N'2022-05-09' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10609, N'15', CAST(N'2022-05-09' AS Date), CAST(N'20:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10610, N'59', CAST(N'2022-05-09' AS Date), CAST(N'20:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10611, N'50', CAST(N'2022-05-09' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10612, N'75', CAST(N'2022-05-09' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10613, N'49', CAST(N'2022-05-09' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10614, N'48', CAST(N'2022-05-09' AS Date), CAST(N'20:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10615, N'70', CAST(N'2022-05-09' AS Date), CAST(N'20:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10616, N'57', CAST(N'2022-05-09' AS Date), CAST(N'20:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10617, N'9', CAST(N'2022-05-09' AS Date), CAST(N'20:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10618, N'61', CAST(N'2022-05-09' AS Date), CAST(N'20:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10619, N'37', CAST(N'2022-05-09' AS Date), CAST(N'20:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10620, N'51', CAST(N'2022-05-09' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10621, N'43', CAST(N'2022-05-09' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10622, N'66', CAST(N'2022-05-09' AS Date), CAST(N'20:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10623, N'79', CAST(N'2022-05-09' AS Date), CAST(N'20:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10624, N'88', CAST(N'2022-05-09' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10625, N'42', CAST(N'2022-05-09' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10626, N'45', CAST(N'2022-05-09' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10627, N'46', CAST(N'2022-05-09' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10628, N'18', CAST(N'2022-05-09' AS Date), CAST(N'20:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10629, N'62', CAST(N'2022-05-09' AS Date), CAST(N'20:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10630, N'78', CAST(N'2022-05-09' AS Date), CAST(N'20:39:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10631, N'21', CAST(N'2022-05-09' AS Date), CAST(N'20:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10632, N'72', CAST(N'2022-05-09' AS Date), CAST(N'20:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10633, N'55', CAST(N'2022-05-09' AS Date), CAST(N'20:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10634, N'34', CAST(N'2022-05-09' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10635, N'29', CAST(N'2022-05-09' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10636, N'29', CAST(N'2022-05-09' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10637, N'87', CAST(N'2022-05-09' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10638, N'35', CAST(N'2022-05-09' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10639, N'28', CAST(N'2022-05-09' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10640, N'65', CAST(N'2022-05-09' AS Date), CAST(N'21:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10641, N'31', CAST(N'2022-05-09' AS Date), CAST(N'21:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10642, N'20', CAST(N'2022-05-09' AS Date), CAST(N'21:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10643, N'81', CAST(N'2022-05-09' AS Date), CAST(N'21:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10644, N'17', CAST(N'2022-05-09' AS Date), CAST(N'21:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10645, N'22', CAST(N'2022-05-09' AS Date), CAST(N'21:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10646, N'13', CAST(N'2022-05-09' AS Date), CAST(N'22:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10647, N'27', CAST(N'2022-05-09' AS Date), CAST(N'22:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10648, N'68', CAST(N'2022-05-09' AS Date), CAST(N'23:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10649, N'82', CAST(N'2022-05-10' AS Date), CAST(N'07:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10650, N'51', CAST(N'2022-05-10' AS Date), CAST(N'07:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10651, N'86', CAST(N'2022-05-10' AS Date), CAST(N'07:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10652, N'23', CAST(N'2022-05-10' AS Date), CAST(N'07:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10653, N'44', CAST(N'2022-05-10' AS Date), CAST(N'07:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10654, N'52', CAST(N'2022-05-10' AS Date), CAST(N'07:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10655, N'41', CAST(N'2022-05-10' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10656, N'73', CAST(N'2022-05-10' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10657, N'67', CAST(N'2022-05-10' AS Date), CAST(N'08:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10658, N'53', CAST(N'2022-05-10' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10659, N'61', CAST(N'2022-05-10' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10660, N'8', CAST(N'2022-05-10' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10661, N'80', CAST(N'2022-05-10' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10662, N'68', CAST(N'2022-05-10' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10663, N'58', CAST(N'2022-05-10' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10664, N'75', CAST(N'2022-05-10' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10665, N'48', CAST(N'2022-05-10' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10666, N'49', CAST(N'2022-05-10' AS Date), CAST(N'08:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10667, N'50', CAST(N'2022-05-10' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10668, N'83', CAST(N'2022-05-10' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10669, N'91', CAST(N'2022-05-10' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10670, N'60', CAST(N'2022-05-10' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10671, N'66', CAST(N'2022-05-10' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10672, N'40', CAST(N'2022-05-10' AS Date), CAST(N'08:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10673, N'85', CAST(N'2022-05-10' AS Date), CAST(N'08:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10674, N'81', CAST(N'2022-05-10' AS Date), CAST(N'08:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10675, N'65', CAST(N'2022-05-10' AS Date), CAST(N'08:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10676, N'89', CAST(N'2022-05-10' AS Date), CAST(N'08:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10677, N'28', CAST(N'2022-05-10' AS Date), CAST(N'08:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10678, N'69', CAST(N'2022-05-10' AS Date), CAST(N'09:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10679, N'20', CAST(N'2022-05-10' AS Date), CAST(N'09:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10680, N'6', CAST(N'2022-05-10' AS Date), CAST(N'09:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10681, N'76', CAST(N'2022-05-10' AS Date), CAST(N'09:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10682, N'14', CAST(N'2022-05-10' AS Date), CAST(N'09:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10683, N'27', CAST(N'2022-05-10' AS Date), CAST(N'09:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10684, N'21', CAST(N'2022-05-10' AS Date), CAST(N'09:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10685, N'62', CAST(N'2022-05-10' AS Date), CAST(N'10:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10686, N'15', CAST(N'2022-05-10' AS Date), CAST(N'10:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10687, N'24', CAST(N'2022-05-10' AS Date), CAST(N'10:19:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10688, N'12', CAST(N'2022-05-10' AS Date), CAST(N'10:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10689, N'29', CAST(N'2022-05-10' AS Date), CAST(N'10:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10690, N'16', CAST(N'2022-05-10' AS Date), CAST(N'10:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10691, N'2', CAST(N'2022-05-10' AS Date), CAST(N'10:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10692, N'38', CAST(N'2022-05-10' AS Date), CAST(N'10:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10693, N'13', CAST(N'2022-05-10' AS Date), CAST(N'11:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10694, N'71', CAST(N'2022-05-10' AS Date), CAST(N'11:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10695, N'26', CAST(N'2022-05-10' AS Date), CAST(N'11:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10696, N'26', CAST(N'2022-05-10' AS Date), CAST(N'12:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10697, N'93', CAST(N'2022-05-10' AS Date), CAST(N'13:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10698, N'74', CAST(N'2022-05-10' AS Date), CAST(N'13:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10699, N'45', CAST(N'2022-05-10' AS Date), CAST(N'13:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10700, N'42', CAST(N'2022-05-10' AS Date), CAST(N'13:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10701, N'67', CAST(N'2022-05-10' AS Date), CAST(N'13:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10702, N'77', CAST(N'2022-05-10' AS Date), CAST(N'13:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10703, N'60', CAST(N'2022-05-10' AS Date), CAST(N'13:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10704, N'78', CAST(N'2022-05-10' AS Date), CAST(N'14:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10705, N'3', CAST(N'2022-05-10' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10706, N'44', CAST(N'2022-05-10' AS Date), CAST(N'14:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10707, N'9', CAST(N'2022-05-10' AS Date), CAST(N'14:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10708, N'40', CAST(N'2022-05-10' AS Date), CAST(N'14:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10709, N'18', CAST(N'2022-05-10' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10710, N'6', CAST(N'2022-05-10' AS Date), CAST(N'14:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10711, N'46', CAST(N'2022-05-10' AS Date), CAST(N'14:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10712, N'37', CAST(N'2022-05-10' AS Date), CAST(N'14:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10713, N'80', CAST(N'2022-05-10' AS Date), CAST(N'14:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10714, N'58', CAST(N'2022-05-10' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10715, N'88', CAST(N'2022-05-10' AS Date), CAST(N'14:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10716, N'73', CAST(N'2022-05-10' AS Date), CAST(N'14:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10717, N'53', CAST(N'2022-05-10' AS Date), CAST(N'14:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10718, N'35', CAST(N'2022-05-10' AS Date), CAST(N'14:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10719, N'61', CAST(N'2022-05-10' AS Date), CAST(N'14:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10720, N'72', CAST(N'2022-05-10' AS Date), CAST(N'14:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10721, N'41', CAST(N'2022-05-10' AS Date), CAST(N'14:40:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10722, N'55', CAST(N'2022-05-10' AS Date), CAST(N'14:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10723, N'34', CAST(N'2022-05-10' AS Date), CAST(N'14:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10724, N'16', CAST(N'2022-05-10' AS Date), CAST(N'14:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10725, N'17', CAST(N'2022-05-10' AS Date), CAST(N'15:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10726, N'87', CAST(N'2022-05-10' AS Date), CAST(N'15:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10727, N'57', CAST(N'2022-05-10' AS Date), CAST(N'15:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10728, N'31', CAST(N'2022-05-10' AS Date), CAST(N'15:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10729, N'32', CAST(N'2022-05-10' AS Date), CAST(N'16:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10730, N'39', CAST(N'2022-05-10' AS Date), CAST(N'17:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10731, N'38', CAST(N'2022-05-10' AS Date), CAST(N'17:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10732, N'89', CAST(N'2022-05-10' AS Date), CAST(N'17:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10733, N'71', CAST(N'2022-05-10' AS Date), CAST(N'17:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10734, N'24', CAST(N'2022-05-10' AS Date), CAST(N'18:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10735, N'12', CAST(N'2022-05-10' AS Date), CAST(N'18:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10736, N'15', CAST(N'2022-05-10' AS Date), CAST(N'19:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10737, N'86', CAST(N'2022-05-10' AS Date), CAST(N'19:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10738, N'26', CAST(N'2022-05-10' AS Date), CAST(N'19:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10739, N'52', CAST(N'2022-05-10' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10740, N'49', CAST(N'2022-05-10' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10741, N'68', CAST(N'2022-05-10' AS Date), CAST(N'19:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10742, N'76', CAST(N'2022-05-10' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10743, N'75', CAST(N'2022-05-10' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10744, N'82', CAST(N'2022-05-10' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10745, N'50', CAST(N'2022-05-10' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10746, N'93', CAST(N'2022-05-10' AS Date), CAST(N'20:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10747, N'83', CAST(N'2022-05-10' AS Date), CAST(N'20:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10748, N'7', CAST(N'2022-05-10' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10749, N'3', CAST(N'2022-05-10' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10750, N'74', CAST(N'2022-05-10' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10751, N'51', CAST(N'2022-05-10' AS Date), CAST(N'20:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10752, N'91', CAST(N'2022-05-10' AS Date), CAST(N'20:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10753, N'77', CAST(N'2022-05-10' AS Date), CAST(N'20:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10754, N'37', CAST(N'2022-05-10' AS Date), CAST(N'20:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10755, N'9', CAST(N'2022-05-10' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10756, N'18', CAST(N'2022-05-10' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10757, N'88', CAST(N'2022-05-10' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10758, N'42', CAST(N'2022-05-10' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10759, N'45', CAST(N'2022-05-10' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10760, N'46', CAST(N'2022-05-10' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10761, N'85', CAST(N'2022-05-10' AS Date), CAST(N'20:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10762, N'87', CAST(N'2022-05-10' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10763, N'78', CAST(N'2022-05-10' AS Date), CAST(N'20:40:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10764, N'21', CAST(N'2022-05-10' AS Date), CAST(N'20:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10765, N'69', CAST(N'2022-05-10' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10766, N'29', CAST(N'2022-05-10' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10767, N'62', CAST(N'2022-05-10' AS Date), CAST(N'21:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10768, N'28', CAST(N'2022-05-10' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10769, N'65', CAST(N'2022-05-10' AS Date), CAST(N'21:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10770, N'20', CAST(N'2022-05-10' AS Date), CAST(N'21:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10771, N'14', CAST(N'2022-05-10' AS Date), CAST(N'21:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10772, N'55', CAST(N'2022-05-10' AS Date), CAST(N'21:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10773, N'81', CAST(N'2022-05-10' AS Date), CAST(N'21:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10774, N'72', CAST(N'2022-05-10' AS Date), CAST(N'21:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10775, N'17', CAST(N'2022-05-10' AS Date), CAST(N'21:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10776, N'31', CAST(N'2022-05-10' AS Date), CAST(N'21:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10777, N'32', CAST(N'2022-05-10' AS Date), CAST(N'21:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10778, N'34', CAST(N'2022-05-10' AS Date), CAST(N'21:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10779, N'35', CAST(N'2022-05-10' AS Date), CAST(N'21:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10780, N'22', CAST(N'2022-05-10' AS Date), CAST(N'21:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10781, N'13', CAST(N'2022-05-10' AS Date), CAST(N'22:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10782, N'27', CAST(N'2022-05-10' AS Date), CAST(N'22:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10783, N'47', CAST(N'2022-05-11' AS Date), CAST(N'07:29:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10784, N'44', CAST(N'2022-05-11' AS Date), CAST(N'07:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10785, N'52', CAST(N'2022-05-11' AS Date), CAST(N'07:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10786, N'59', CAST(N'2022-05-11' AS Date), CAST(N'07:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10787, N'51', CAST(N'2022-05-11' AS Date), CAST(N'07:56:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10788, N'23', CAST(N'2022-05-11' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10789, N'86', CAST(N'2022-05-11' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10790, N'85', CAST(N'2022-05-11' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10791, N'42', CAST(N'2022-05-11' AS Date), CAST(N'07:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10792, N'60', CAST(N'2022-05-11' AS Date), CAST(N'07:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10793, N'83', CAST(N'2022-05-11' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10794, N'58', CAST(N'2022-05-11' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10795, N'50', CAST(N'2022-05-11' AS Date), CAST(N'07:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10796, N'80', CAST(N'2022-05-11' AS Date), CAST(N'08:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10797, N'49', CAST(N'2022-05-11' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10798, N'73', CAST(N'2022-05-11' AS Date), CAST(N'08:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10799, N'67', CAST(N'2022-05-11' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10800, N'91', CAST(N'2022-05-11' AS Date), CAST(N'08:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10801, N'53', CAST(N'2022-05-11' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10802, N'68', CAST(N'2022-05-11' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10803, N'39', CAST(N'2022-05-11' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10804, N'41', CAST(N'2022-05-11' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10805, N'75', CAST(N'2022-05-11' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10806, N'7', CAST(N'2022-05-11' AS Date), CAST(N'08:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10807, N'40', CAST(N'2022-05-11' AS Date), CAST(N'08:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10808, N'81', CAST(N'2022-05-11' AS Date), CAST(N'08:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10809, N'28', CAST(N'2022-05-11' AS Date), CAST(N'08:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10810, N'56', CAST(N'2022-05-11' AS Date), CAST(N'08:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10811, N'76', CAST(N'2022-05-11' AS Date), CAST(N'08:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10812, N'6', CAST(N'2022-05-11' AS Date), CAST(N'09:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10813, N'65', CAST(N'2022-05-11' AS Date), CAST(N'09:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10814, N'69', CAST(N'2022-05-11' AS Date), CAST(N'09:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10815, N'89', CAST(N'2022-05-11' AS Date), CAST(N'09:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10816, N'14', CAST(N'2022-05-11' AS Date), CAST(N'09:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10817, N'20', CAST(N'2022-05-11' AS Date), CAST(N'09:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10818, N'24', CAST(N'2022-05-11' AS Date), CAST(N'09:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10819, N'27', CAST(N'2022-05-11' AS Date), CAST(N'09:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10820, N'29', CAST(N'2022-05-11' AS Date), CAST(N'10:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10821, N'62', CAST(N'2022-05-11' AS Date), CAST(N'10:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10822, N'12', CAST(N'2022-05-11' AS Date), CAST(N'10:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10823, N'63', CAST(N'2022-05-11' AS Date), CAST(N'10:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10824, N'15', CAST(N'2022-05-11' AS Date), CAST(N'10:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10825, N'16', CAST(N'2022-05-11' AS Date), CAST(N'10:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10826, N'38', CAST(N'2022-05-11' AS Date), CAST(N'11:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10827, N'13', CAST(N'2022-05-11' AS Date), CAST(N'11:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10828, N'71', CAST(N'2022-05-11' AS Date), CAST(N'11:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10829, N'26', CAST(N'2022-05-11' AS Date), CAST(N'11:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10830, N'93', CAST(N'2022-05-11' AS Date), CAST(N'13:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10831, N'80', CAST(N'2022-05-11' AS Date), CAST(N'13:43:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10832, N'44', CAST(N'2022-05-11' AS Date), CAST(N'13:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10833, N'67', CAST(N'2022-05-11' AS Date), CAST(N'13:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10834, N'60', CAST(N'2022-05-11' AS Date), CAST(N'13:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10835, N'41', CAST(N'2022-05-11' AS Date), CAST(N'13:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10836, N'77', CAST(N'2022-05-11' AS Date), CAST(N'13:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10837, N'18', CAST(N'2022-05-11' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10838, N'43', CAST(N'2022-05-11' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10839, N'3', CAST(N'2022-05-11' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10840, N'51', CAST(N'2022-05-11' AS Date), CAST(N'13:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10841, N'45', CAST(N'2022-05-11' AS Date), CAST(N'14:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10842, N'58', CAST(N'2022-05-11' AS Date), CAST(N'14:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10843, N'9', CAST(N'2022-05-11' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10844, N'40', CAST(N'2022-05-11' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10845, N'78', CAST(N'2022-05-11' AS Date), CAST(N'14:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10846, N'88', CAST(N'2022-05-11' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10847, N'6', CAST(N'2022-05-11' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10848, N'74', CAST(N'2022-05-11' AS Date), CAST(N'14:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10849, N'16', CAST(N'2022-05-11' AS Date), CAST(N'14:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10850, N'35', CAST(N'2022-05-11' AS Date), CAST(N'14:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10851, N'37', CAST(N'2022-05-11' AS Date), CAST(N'14:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10852, N'23', CAST(N'2022-05-11' AS Date), CAST(N'14:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10853, N'22', CAST(N'2022-05-11' AS Date), CAST(N'14:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10854, N'55', CAST(N'2022-05-11' AS Date), CAST(N'14:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10855, N'72', CAST(N'2022-05-11' AS Date), CAST(N'14:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10856, N'34', CAST(N'2022-05-11' AS Date), CAST(N'15:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10857, N'56', CAST(N'2022-05-11' AS Date), CAST(N'15:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10858, N'32', CAST(N'2022-05-11' AS Date), CAST(N'15:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10859, N'33', CAST(N'2022-05-11' AS Date), CAST(N'15:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10860, N'17', CAST(N'2022-05-11' AS Date), CAST(N'15:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10861, N'57', CAST(N'2022-05-11' AS Date), CAST(N'15:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10862, N'31', CAST(N'2022-05-11' AS Date), CAST(N'15:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10863, N'87', CAST(N'2022-05-11' AS Date), CAST(N'15:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10864, N'39', CAST(N'2022-05-11' AS Date), CAST(N'16:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10865, N'38', CAST(N'2022-05-11' AS Date), CAST(N'17:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10866, N'71', CAST(N'2022-05-11' AS Date), CAST(N'17:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10867, N'24', CAST(N'2022-05-11' AS Date), CAST(N'18:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10868, N'12', CAST(N'2022-05-11' AS Date), CAST(N'18:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10869, N'17', CAST(N'2022-05-11' AS Date), CAST(N'19:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10870, N'8', CAST(N'2022-05-11' AS Date), CAST(N'19:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10871, N'91', CAST(N'2022-05-11' AS Date), CAST(N'19:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10872, N'74', CAST(N'2022-05-11' AS Date), CAST(N'19:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10873, N'15', CAST(N'2022-05-11' AS Date), CAST(N'19:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10874, N'52', CAST(N'2022-05-11' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10875, N'26', CAST(N'2022-05-11' AS Date), CAST(N'19:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10876, N'3', CAST(N'2022-05-11' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10877, N'48', CAST(N'2022-05-11' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10878, N'49', CAST(N'2022-05-11' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10879, N'83', CAST(N'2022-05-11' AS Date), CAST(N'19:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10880, N'82', CAST(N'2022-05-11' AS Date), CAST(N'19:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10881, N'75', CAST(N'2022-05-11' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10882, N'86', CAST(N'2022-05-11' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10883, N'85', CAST(N'2022-05-11' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10884, N'70', CAST(N'2022-05-11' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10885, N'11', CAST(N'2022-05-11' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10886, N'76', CAST(N'2022-05-11' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10887, N'57', CAST(N'2022-05-11' AS Date), CAST(N'20:05:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10888, N'53', CAST(N'2022-05-11' AS Date), CAST(N'20:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10889, N'77', CAST(N'2022-05-11' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10890, N'37', CAST(N'2022-05-11' AS Date), CAST(N'20:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10891, N'50', CAST(N'2022-05-11' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10892, N'93', CAST(N'2022-05-11' AS Date), CAST(N'20:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10893, N'9', CAST(N'2022-05-11' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10894, N'81', CAST(N'2022-05-11' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10895, N'61', CAST(N'2022-05-11' AS Date), CAST(N'20:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10896, N'43', CAST(N'2022-05-11' AS Date), CAST(N'20:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10897, N'59', CAST(N'2022-05-11' AS Date), CAST(N'20:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10898, N'78', CAST(N'2022-05-11' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10899, N'46', CAST(N'2022-05-11' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10900, N'88', CAST(N'2022-05-11' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10901, N'42', CAST(N'2022-05-11' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10902, N'45', CAST(N'2022-05-11' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10903, N'69', CAST(N'2022-05-11' AS Date), CAST(N'20:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10904, N'28', CAST(N'2022-05-11' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10905, N'72', CAST(N'2022-05-11' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10906, N'55', CAST(N'2022-05-11' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10907, N'62', CAST(N'2022-05-11' AS Date), CAST(N'21:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10908, N'18', CAST(N'2022-05-11' AS Date), CAST(N'21:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10909, N'29', CAST(N'2022-05-11' AS Date), CAST(N'21:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10910, N'65', CAST(N'2022-05-11' AS Date), CAST(N'21:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10911, N'21', CAST(N'2022-05-11' AS Date), CAST(N'21:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10912, N'35', CAST(N'2022-05-11' AS Date), CAST(N'21:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10913, N'34', CAST(N'2022-05-11' AS Date), CAST(N'21:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10914, N'87', CAST(N'2022-05-11' AS Date), CAST(N'21:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10915, N'33', CAST(N'2022-05-11' AS Date), CAST(N'21:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10916, N'31', CAST(N'2022-05-11' AS Date), CAST(N'21:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10917, N'32', CAST(N'2022-05-11' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10918, N'20', CAST(N'2022-05-11' AS Date), CAST(N'21:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10919, N'14', CAST(N'2022-05-11' AS Date), CAST(N'21:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10920, N'22', CAST(N'2022-05-11' AS Date), CAST(N'21:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10921, N'13', CAST(N'2022-05-11' AS Date), CAST(N'22:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10922, N'27', CAST(N'2022-05-11' AS Date), CAST(N'22:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10923, N'68', CAST(N'2022-05-11' AS Date), CAST(N'23:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10924, N'82', CAST(N'2022-05-12' AS Date), CAST(N'07:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10925, N'8', CAST(N'2022-05-12' AS Date), CAST(N'07:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10926, N'92', CAST(N'2022-05-12' AS Date), CAST(N'07:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10927, N'51', CAST(N'2022-05-12' AS Date), CAST(N'07:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10928, N'23', CAST(N'2022-05-12' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10929, N'48', CAST(N'2022-05-12' AS Date), CAST(N'07:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10930, N'85', CAST(N'2022-05-12' AS Date), CAST(N'08:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10931, N'58', CAST(N'2022-05-12' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10932, N'41', CAST(N'2022-05-12' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10933, N'59', CAST(N'2022-05-12' AS Date), CAST(N'08:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10934, N'50', CAST(N'2022-05-12' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10935, N'49', CAST(N'2022-05-12' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10936, N'68', CAST(N'2022-05-12' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10937, N'53', CAST(N'2022-05-12' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10938, N'52', CAST(N'2022-05-12' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10939, N'83', CAST(N'2022-05-12' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10940, N'60', CAST(N'2022-05-12' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10941, N'91', CAST(N'2022-05-12' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10942, N'73', CAST(N'2022-05-12' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10943, N'61', CAST(N'2022-05-12' AS Date), CAST(N'08:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10944, N'40', CAST(N'2022-05-12' AS Date), CAST(N'08:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10945, N'75', CAST(N'2022-05-12' AS Date), CAST(N'08:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10946, N'86', CAST(N'2022-05-12' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10947, N'11', CAST(N'2022-05-12' AS Date), CAST(N'08:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10948, N'93', CAST(N'2022-05-12' AS Date), CAST(N'08:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10949, N'81', CAST(N'2022-05-12' AS Date), CAST(N'08:35:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10950, N'56', CAST(N'2022-05-12' AS Date), CAST(N'08:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10951, N'65', CAST(N'2022-05-12' AS Date), CAST(N'08:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10952, N'28', CAST(N'2022-05-12' AS Date), CAST(N'08:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10953, N'62', CAST(N'2022-05-12' AS Date), CAST(N'09:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10954, N'89', CAST(N'2022-05-12' AS Date), CAST(N'09:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10955, N'76', CAST(N'2022-05-12' AS Date), CAST(N'09:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10956, N'69', CAST(N'2022-05-12' AS Date), CAST(N'09:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10957, N'20', CAST(N'2022-05-12' AS Date), CAST(N'09:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10958, N'6', CAST(N'2022-05-12' AS Date), CAST(N'09:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10959, N'21', CAST(N'2022-05-12' AS Date), CAST(N'09:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10960, N'27', CAST(N'2022-05-12' AS Date), CAST(N'09:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10961, N'24', CAST(N'2022-05-12' AS Date), CAST(N'10:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10962, N'12', CAST(N'2022-05-12' AS Date), CAST(N'10:30:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10963, N'63', CAST(N'2022-05-12' AS Date), CAST(N'10:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10964, N'29', CAST(N'2022-05-12' AS Date), CAST(N'10:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10965, N'15', CAST(N'2022-05-12' AS Date), CAST(N'10:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10966, N'16', CAST(N'2022-05-12' AS Date), CAST(N'10:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10967, N'13', CAST(N'2022-05-12' AS Date), CAST(N'10:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10968, N'38', CAST(N'2022-05-12' AS Date), CAST(N'11:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10969, N'71', CAST(N'2022-05-12' AS Date), CAST(N'11:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10970, N'2', CAST(N'2022-05-12' AS Date), CAST(N'11:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10971, N'26', CAST(N'2022-05-12' AS Date), CAST(N'11:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10972, N'74', CAST(N'2022-05-12' AS Date), CAST(N'13:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10973, N'77', CAST(N'2022-05-12' AS Date), CAST(N'13:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10974, N'60', CAST(N'2022-05-12' AS Date), CAST(N'13:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10975, N'78', CAST(N'2022-05-12' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10976, N'53', CAST(N'2022-05-12' AS Date), CAST(N'14:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10977, N'3', CAST(N'2022-05-12' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10978, N'43', CAST(N'2022-05-12' AS Date), CAST(N'14:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10979, N'88', CAST(N'2022-05-12' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10980, N'79', CAST(N'2022-05-12' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10981, N'40', CAST(N'2022-05-12' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10982, N'72', CAST(N'2022-05-12' AS Date), CAST(N'14:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10983, N'41', CAST(N'2022-05-12' AS Date), CAST(N'14:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10984, N'18', CAST(N'2022-05-12' AS Date), CAST(N'14:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10985, N'92', CAST(N'2022-05-12' AS Date), CAST(N'14:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10986, N'73', CAST(N'2022-05-12' AS Date), CAST(N'14:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10987, N'9', CAST(N'2022-05-12' AS Date), CAST(N'14:12:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10988, N'58', CAST(N'2022-05-12' AS Date), CAST(N'14:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10989, N'6', CAST(N'2022-05-12' AS Date), CAST(N'14:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10990, N'35', CAST(N'2022-05-12' AS Date), CAST(N'14:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10991, N'22', CAST(N'2022-05-12' AS Date), CAST(N'14:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10992, N'23', CAST(N'2022-05-12' AS Date), CAST(N'14:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10993, N'34', CAST(N'2022-05-12' AS Date), CAST(N'14:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10994, N'55', CAST(N'2022-05-12' AS Date), CAST(N'14:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10995, N'16', CAST(N'2022-05-12' AS Date), CAST(N'14:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10996, N'56', CAST(N'2022-05-12' AS Date), CAST(N'15:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10997, N'57', CAST(N'2022-05-12' AS Date), CAST(N'15:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10998, N'31', CAST(N'2022-05-12' AS Date), CAST(N'15:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (10999, N'17', CAST(N'2022-05-12' AS Date), CAST(N'15:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11000, N'32', CAST(N'2022-05-12' AS Date), CAST(N'15:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11001, N'33', CAST(N'2022-05-12' AS Date), CAST(N'15:29:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11002, N'39', CAST(N'2022-05-12' AS Date), CAST(N'16:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11003, N'38', CAST(N'2022-05-12' AS Date), CAST(N'17:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11004, N'89', CAST(N'2022-05-12' AS Date), CAST(N'17:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11005, N'24', CAST(N'2022-05-12' AS Date), CAST(N'17:41:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11006, N'71', CAST(N'2022-05-12' AS Date), CAST(N'17:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11007, N'12', CAST(N'2022-05-12' AS Date), CAST(N'18:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11008, N'15', CAST(N'2022-05-12' AS Date), CAST(N'19:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11009, N'91', CAST(N'2022-05-12' AS Date), CAST(N'19:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11010, N'86', CAST(N'2022-05-12' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11011, N'26', CAST(N'2022-05-12' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11012, N'68', CAST(N'2022-05-12' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11013, N'50', CAST(N'2022-05-12' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11014, N'85', CAST(N'2022-05-12' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11015, N'52', CAST(N'2022-05-12' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11016, N'75', CAST(N'2022-05-12' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11017, N'61', CAST(N'2022-05-12' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11018, N'76', CAST(N'2022-05-12' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11019, N'49', CAST(N'2022-05-12' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11020, N'59', CAST(N'2022-05-12' AS Date), CAST(N'20:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11021, N'82', CAST(N'2022-05-12' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11022, N'83', CAST(N'2022-05-12' AS Date), CAST(N'20:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11023, N'66', CAST(N'2022-05-12' AS Date), CAST(N'20:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11024, N'93', CAST(N'2022-05-12' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11025, N'9', CAST(N'2022-05-12' AS Date), CAST(N'20:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11026, N'7', CAST(N'2022-05-12' AS Date), CAST(N'20:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11027, N'74', CAST(N'2022-05-12' AS Date), CAST(N'20:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11028, N'18', CAST(N'2022-05-12' AS Date), CAST(N'20:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11029, N'11', CAST(N'2022-05-12' AS Date), CAST(N'20:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11030, N'70', CAST(N'2022-05-12' AS Date), CAST(N'20:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11031, N'77', CAST(N'2022-05-12' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11032, N'57', CAST(N'2022-05-12' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11033, N'51', CAST(N'2022-05-12' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11034, N'43', CAST(N'2022-05-12' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11035, N'46', CAST(N'2022-05-12' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11036, N'78', CAST(N'2022-05-12' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11037, N'48', CAST(N'2022-05-12' AS Date), CAST(N'20:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11038, N'88', CAST(N'2022-05-12' AS Date), CAST(N'20:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11039, N'37', CAST(N'2022-05-12' AS Date), CAST(N'20:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11040, N'21', CAST(N'2022-05-12' AS Date), CAST(N'20:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11041, N'69', CAST(N'2022-05-12' AS Date), CAST(N'20:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11042, N'28', CAST(N'2022-05-12' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11043, N'29', CAST(N'2022-05-12' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11044, N'55', CAST(N'2022-05-12' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11045, N'31', CAST(N'2022-05-12' AS Date), CAST(N'21:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11046, N'65', CAST(N'2022-05-12' AS Date), CAST(N'21:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11047, N'35', CAST(N'2022-05-12' AS Date), CAST(N'21:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11048, N'62', CAST(N'2022-05-12' AS Date), CAST(N'21:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11049, N'32', CAST(N'2022-05-12' AS Date), CAST(N'21:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11050, N'87', CAST(N'2022-05-12' AS Date), CAST(N'21:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11051, N'33', CAST(N'2022-05-12' AS Date), CAST(N'21:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11052, N'72', CAST(N'2022-05-12' AS Date), CAST(N'21:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11053, N'14', CAST(N'2022-05-12' AS Date), CAST(N'21:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11054, N'17', CAST(N'2022-05-12' AS Date), CAST(N'21:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11055, N'20', CAST(N'2022-05-12' AS Date), CAST(N'21:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11056, N'81', CAST(N'2022-05-12' AS Date), CAST(N'21:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11057, N'22', CAST(N'2022-05-12' AS Date), CAST(N'22:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11058, N'13', CAST(N'2022-05-12' AS Date), CAST(N'22:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11059, N'27', CAST(N'2022-05-12' AS Date), CAST(N'22:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11060, N'82', CAST(N'2022-05-13' AS Date), CAST(N'07:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11061, N'59', CAST(N'2022-05-13' AS Date), CAST(N'07:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11062, N'92', CAST(N'2022-05-13' AS Date), CAST(N'07:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11063, N'44', CAST(N'2022-05-13' AS Date), CAST(N'07:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11064, N'83', CAST(N'2022-05-13' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11065, N'52', CAST(N'2022-05-13' AS Date), CAST(N'07:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11066, N'48', CAST(N'2022-05-13' AS Date), CAST(N'07:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11067, N'86', CAST(N'2022-05-13' AS Date), CAST(N'07:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11068, N'50', CAST(N'2022-05-13' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11069, N'53', CAST(N'2022-05-13' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11070, N'68', CAST(N'2022-05-13' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11071, N'93', CAST(N'2022-05-13' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11072, N'51', CAST(N'2022-05-13' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11073, N'41', CAST(N'2022-05-13' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11074, N'91', CAST(N'2022-05-13' AS Date), CAST(N'08:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11075, N'73', CAST(N'2022-05-13' AS Date), CAST(N'08:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11076, N'40', CAST(N'2022-05-13' AS Date), CAST(N'08:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11077, N'60', CAST(N'2022-05-13' AS Date), CAST(N'08:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11078, N'49', CAST(N'2022-05-13' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11079, N'75', CAST(N'2022-05-13' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11080, N'61', CAST(N'2022-05-13' AS Date), CAST(N'08:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11081, N'7', CAST(N'2022-05-13' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11082, N'66', CAST(N'2022-05-13' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11083, N'11', CAST(N'2022-05-13' AS Date), CAST(N'08:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11084, N'85', CAST(N'2022-05-13' AS Date), CAST(N'08:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11085, N'65', CAST(N'2022-05-13' AS Date), CAST(N'08:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11086, N'56', CAST(N'2022-05-13' AS Date), CAST(N'08:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11087, N'89', CAST(N'2022-05-13' AS Date), CAST(N'08:58:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11088, N'28', CAST(N'2022-05-13' AS Date), CAST(N'08:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11089, N'76', CAST(N'2022-05-13' AS Date), CAST(N'09:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11090, N'24', CAST(N'2022-05-13' AS Date), CAST(N'09:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11091, N'20', CAST(N'2022-05-13' AS Date), CAST(N'09:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11092, N'14', CAST(N'2022-05-13' AS Date), CAST(N'09:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11093, N'62', CAST(N'2022-05-13' AS Date), CAST(N'09:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11094, N'81', CAST(N'2022-05-13' AS Date), CAST(N'09:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11095, N'69', CAST(N'2022-05-13' AS Date), CAST(N'09:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11096, N'6', CAST(N'2022-05-13' AS Date), CAST(N'09:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11097, N'21', CAST(N'2022-05-13' AS Date), CAST(N'09:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11098, N'27', CAST(N'2022-05-13' AS Date), CAST(N'09:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11099, N'29', CAST(N'2022-05-13' AS Date), CAST(N'10:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11100, N'12', CAST(N'2022-05-13' AS Date), CAST(N'10:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11101, N'63', CAST(N'2022-05-13' AS Date), CAST(N'10:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11102, N'13', CAST(N'2022-05-13' AS Date), CAST(N'10:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11103, N'16', CAST(N'2022-05-13' AS Date), CAST(N'10:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11104, N'71', CAST(N'2022-05-13' AS Date), CAST(N'10:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11105, N'38', CAST(N'2022-05-13' AS Date), CAST(N'11:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11106, N'15', CAST(N'2022-05-13' AS Date), CAST(N'11:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11107, N'74', CAST(N'2022-05-13' AS Date), CAST(N'13:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11108, N'44', CAST(N'2022-05-13' AS Date), CAST(N'13:41:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11109, N'78', CAST(N'2022-05-13' AS Date), CAST(N'13:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11110, N'67', CAST(N'2022-05-13' AS Date), CAST(N'13:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11111, N'43', CAST(N'2022-05-13' AS Date), CAST(N'13:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11112, N'60', CAST(N'2022-05-13' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11113, N'42', CAST(N'2022-05-13' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11114, N'45', CAST(N'2022-05-13' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11115, N'79', CAST(N'2022-05-13' AS Date), CAST(N'14:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11116, N'40', CAST(N'2022-05-13' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11117, N'3', CAST(N'2022-05-13' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11118, N'9', CAST(N'2022-05-13' AS Date), CAST(N'14:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11119, N'41', CAST(N'2022-05-13' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11120, N'53', CAST(N'2022-05-13' AS Date), CAST(N'14:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11121, N'92', CAST(N'2022-05-13' AS Date), CAST(N'14:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11122, N'77', CAST(N'2022-05-13' AS Date), CAST(N'14:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11123, N'6', CAST(N'2022-05-13' AS Date), CAST(N'14:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11124, N'73', CAST(N'2022-05-13' AS Date), CAST(N'14:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11125, N'18', CAST(N'2022-05-13' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11126, N'88', CAST(N'2022-05-13' AS Date), CAST(N'14:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11127, N'46', CAST(N'2022-05-13' AS Date), CAST(N'14:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11128, N'35', CAST(N'2022-05-13' AS Date), CAST(N'14:30:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11129, N'34', CAST(N'2022-05-13' AS Date), CAST(N'14:40:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11130, N'32', CAST(N'2022-05-13' AS Date), CAST(N'14:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11131, N'72', CAST(N'2022-05-13' AS Date), CAST(N'14:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11132, N'55', CAST(N'2022-05-13' AS Date), CAST(N'14:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11133, N'56', CAST(N'2022-05-13' AS Date), CAST(N'15:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11134, N'16', CAST(N'2022-05-13' AS Date), CAST(N'15:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11135, N'33', CAST(N'2022-05-13' AS Date), CAST(N'15:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11136, N'31', CAST(N'2022-05-13' AS Date), CAST(N'15:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11137, N'87', CAST(N'2022-05-13' AS Date), CAST(N'15:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11138, N'57', CAST(N'2022-05-13' AS Date), CAST(N'15:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11139, N'17', CAST(N'2022-05-13' AS Date), CAST(N'15:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11140, N'39', CAST(N'2022-05-13' AS Date), CAST(N'16:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11141, N'89', CAST(N'2022-05-13' AS Date), CAST(N'16:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11142, N'38', CAST(N'2022-05-13' AS Date), CAST(N'16:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11143, N'24', CAST(N'2022-05-13' AS Date), CAST(N'17:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11144, N'71', CAST(N'2022-05-13' AS Date), CAST(N'17:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11145, N'12', CAST(N'2022-05-13' AS Date), CAST(N'18:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11146, N'15', CAST(N'2022-05-13' AS Date), CAST(N'19:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11147, N'8', CAST(N'2022-05-13' AS Date), CAST(N'19:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11148, N'70', CAST(N'2022-05-13' AS Date), CAST(N'19:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11149, N'91', CAST(N'2022-05-13' AS Date), CAST(N'19:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11150, N'3', CAST(N'2022-05-13' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11151, N'26', CAST(N'2022-05-13' AS Date), CAST(N'19:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11152, N'63', CAST(N'2022-05-13' AS Date), CAST(N'19:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11153, N'86', CAST(N'2022-05-13' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11154, N'66', CAST(N'2022-05-13' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11155, N'83', CAST(N'2022-05-13' AS Date), CAST(N'19:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11156, N'49', CAST(N'2022-05-13' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11157, N'76', CAST(N'2022-05-13' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11158, N'85', CAST(N'2022-05-13' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11159, N'50', CAST(N'2022-05-13' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11160, N'75', CAST(N'2022-05-13' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11161, N'48', CAST(N'2022-05-13' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11162, N'93', CAST(N'2022-05-13' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11163, N'59', CAST(N'2022-05-13' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11164, N'18', CAST(N'2022-05-13' AS Date), CAST(N'20:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11165, N'77', CAST(N'2022-05-13' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11166, N'37', CAST(N'2022-05-13' AS Date), CAST(N'20:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11167, N'43', CAST(N'2022-05-13' AS Date), CAST(N'20:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11168, N'9', CAST(N'2022-05-13' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11169, N'57', CAST(N'2022-05-13' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11170, N'78', CAST(N'2022-05-13' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11171, N'42', CAST(N'2022-05-13' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11172, N'45', CAST(N'2022-05-13' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11173, N'46', CAST(N'2022-05-13' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11174, N'88', CAST(N'2022-05-13' AS Date), CAST(N'20:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11175, N'81', CAST(N'2022-05-13' AS Date), CAST(N'20:38:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11176, N'72', CAST(N'2022-05-13' AS Date), CAST(N'20:39:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11177, N'62', CAST(N'2022-05-13' AS Date), CAST(N'20:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11178, N'55', CAST(N'2022-05-13' AS Date), CAST(N'20:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11179, N'21', CAST(N'2022-05-13' AS Date), CAST(N'20:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11180, N'69', CAST(N'2022-05-13' AS Date), CAST(N'20:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11181, N'29', CAST(N'2022-05-13' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11182, N'17', CAST(N'2022-05-13' AS Date), CAST(N'21:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11183, N'65', CAST(N'2022-05-13' AS Date), CAST(N'21:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11184, N'28', CAST(N'2022-05-13' AS Date), CAST(N'21:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11185, N'34', CAST(N'2022-05-13' AS Date), CAST(N'21:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11186, N'31', CAST(N'2022-05-13' AS Date), CAST(N'21:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11187, N'20', CAST(N'2022-05-13' AS Date), CAST(N'21:31:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11188, N'14', CAST(N'2022-05-13' AS Date), CAST(N'21:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11189, N'87', CAST(N'2022-05-13' AS Date), CAST(N'21:38:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11190, N'35', CAST(N'2022-05-13' AS Date), CAST(N'21:40:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11191, N'33', CAST(N'2022-05-13' AS Date), CAST(N'21:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11192, N'32', CAST(N'2022-05-13' AS Date), CAST(N'21:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11193, N'22', CAST(N'2022-05-13' AS Date), CAST(N'22:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11194, N'13', CAST(N'2022-05-13' AS Date), CAST(N'22:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11195, N'27', CAST(N'2022-05-13' AS Date), CAST(N'22:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11196, N'68', CAST(N'2022-05-13' AS Date), CAST(N'23:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11197, N'82', CAST(N'2022-05-14' AS Date), CAST(N'07:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11198, N'92', CAST(N'2022-05-14' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11199, N'23', CAST(N'2022-05-14' AS Date), CAST(N'07:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11200, N'44', CAST(N'2022-05-14' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11201, N'53', CAST(N'2022-05-14' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11202, N'50', CAST(N'2022-05-14' AS Date), CAST(N'07:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11203, N'86', CAST(N'2022-05-14' AS Date), CAST(N'08:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11204, N'8', CAST(N'2022-05-14' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11205, N'51', CAST(N'2022-05-14' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11206, N'67', CAST(N'2022-05-14' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11207, N'40', CAST(N'2022-05-14' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11208, N'68', CAST(N'2022-05-14' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11209, N'73', CAST(N'2022-05-14' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11210, N'85', CAST(N'2022-05-14' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11211, N'59', CAST(N'2022-05-14' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11212, N'75', CAST(N'2022-05-14' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11213, N'48', CAST(N'2022-05-14' AS Date), CAST(N'08:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11214, N'91', CAST(N'2022-05-14' AS Date), CAST(N'08:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11215, N'49', CAST(N'2022-05-14' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11216, N'58', CAST(N'2022-05-14' AS Date), CAST(N'08:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11217, N'93', CAST(N'2022-05-14' AS Date), CAST(N'08:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11218, N'60', CAST(N'2022-05-14' AS Date), CAST(N'08:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11219, N'66', CAST(N'2022-05-14' AS Date), CAST(N'08:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11220, N'41', CAST(N'2022-05-14' AS Date), CAST(N'08:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11221, N'65', CAST(N'2022-05-14' AS Date), CAST(N'08:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11222, N'56', CAST(N'2022-05-14' AS Date), CAST(N'08:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11223, N'76', CAST(N'2022-05-14' AS Date), CAST(N'08:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11224, N'89', CAST(N'2022-05-14' AS Date), CAST(N'08:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11225, N'62', CAST(N'2022-05-14' AS Date), CAST(N'08:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11226, N'28', CAST(N'2022-05-14' AS Date), CAST(N'08:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11227, N'6', CAST(N'2022-05-14' AS Date), CAST(N'09:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11228, N'69', CAST(N'2022-05-14' AS Date), CAST(N'09:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11229, N'81', CAST(N'2022-05-14' AS Date), CAST(N'09:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11230, N'20', CAST(N'2022-05-14' AS Date), CAST(N'09:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11231, N'21', CAST(N'2022-05-14' AS Date), CAST(N'09:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11232, N'21', CAST(N'2022-05-14' AS Date), CAST(N'09:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11233, N'14', CAST(N'2022-05-14' AS Date), CAST(N'09:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11234, N'24', CAST(N'2022-05-14' AS Date), CAST(N'09:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11235, N'27', CAST(N'2022-05-14' AS Date), CAST(N'09:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11236, N'12', CAST(N'2022-05-14' AS Date), CAST(N'10:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11237, N'29', CAST(N'2022-05-14' AS Date), CAST(N'10:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11238, N'15', CAST(N'2022-05-14' AS Date), CAST(N'10:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11239, N'13', CAST(N'2022-05-14' AS Date), CAST(N'10:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11240, N'26', CAST(N'2022-05-14' AS Date), CAST(N'11:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11241, N'71', CAST(N'2022-05-14' AS Date), CAST(N'11:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11242, N'2', CAST(N'2022-05-14' AS Date), CAST(N'11:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11243, N'77', CAST(N'2022-05-14' AS Date), CAST(N'13:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11244, N'74', CAST(N'2022-05-14' AS Date), CAST(N'13:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11245, N'82', CAST(N'2022-05-14' AS Date), CAST(N'13:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11246, N'67', CAST(N'2022-05-14' AS Date), CAST(N'13:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11247, N'3', CAST(N'2022-05-14' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11248, N'78', CAST(N'2022-05-14' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11249, N'42', CAST(N'2022-05-14' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11250, N'45', CAST(N'2022-05-14' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11251, N'43', CAST(N'2022-05-14' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11252, N'79', CAST(N'2022-05-14' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11253, N'88', CAST(N'2022-05-14' AS Date), CAST(N'14:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11254, N'44', CAST(N'2022-05-14' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11255, N'9', CAST(N'2022-05-14' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11256, N'72', CAST(N'2022-05-14' AS Date), CAST(N'14:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11257, N'6', CAST(N'2022-05-14' AS Date), CAST(N'14:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11258, N'18', CAST(N'2022-05-14' AS Date), CAST(N'14:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11259, N'24', CAST(N'2022-05-14' AS Date), CAST(N'14:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11260, N'53', CAST(N'2022-05-14' AS Date), CAST(N'14:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11261, N'73', CAST(N'2022-05-14' AS Date), CAST(N'14:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11262, N'37', CAST(N'2022-05-14' AS Date), CAST(N'14:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11263, N'60', CAST(N'2022-05-14' AS Date), CAST(N'14:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11264, N'35', CAST(N'2022-05-14' AS Date), CAST(N'14:30:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11265, N'58', CAST(N'2022-05-14' AS Date), CAST(N'14:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11266, N'92', CAST(N'2022-05-14' AS Date), CAST(N'14:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11267, N'23', CAST(N'2022-05-14' AS Date), CAST(N'14:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11268, N'41', CAST(N'2022-05-14' AS Date), CAST(N'14:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11269, N'34', CAST(N'2022-05-14' AS Date), CAST(N'14:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11270, N'55', CAST(N'2022-05-14' AS Date), CAST(N'14:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11271, N'56', CAST(N'2022-05-14' AS Date), CAST(N'15:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11272, N'33', CAST(N'2022-05-14' AS Date), CAST(N'15:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11273, N'31', CAST(N'2022-05-14' AS Date), CAST(N'15:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11274, N'32', CAST(N'2022-05-14' AS Date), CAST(N'15:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11275, N'17', CAST(N'2022-05-14' AS Date), CAST(N'15:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11276, N'57', CAST(N'2022-05-14' AS Date), CAST(N'15:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11277, N'87', CAST(N'2022-05-14' AS Date), CAST(N'15:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11278, N'25', CAST(N'2022-05-14' AS Date), CAST(N'15:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11279, N'39', CAST(N'2022-05-14' AS Date), CAST(N'16:30:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11280, N'77', CAST(N'2022-05-14' AS Date), CAST(N'17:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11281, N'89', CAST(N'2022-05-14' AS Date), CAST(N'17:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11282, N'71', CAST(N'2022-05-14' AS Date), CAST(N'17:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11283, N'12', CAST(N'2022-05-14' AS Date), CAST(N'18:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11284, N'52', CAST(N'2022-05-14' AS Date), CAST(N'19:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11285, N'91', CAST(N'2022-05-14' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11286, N'15', CAST(N'2022-05-14' AS Date), CAST(N'19:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11287, N'74', CAST(N'2022-05-14' AS Date), CAST(N'19:53:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11288, N'26', CAST(N'2022-05-14' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11289, N'85', CAST(N'2022-05-14' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11290, N'76', CAST(N'2022-05-14' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11291, N'68', CAST(N'2022-05-14' AS Date), CAST(N'20:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11292, N'86', CAST(N'2022-05-14' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11293, N'70', CAST(N'2022-05-14' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11294, N'18', CAST(N'2022-05-14' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11295, N'48', CAST(N'2022-05-14' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11296, N'93', CAST(N'2022-05-14' AS Date), CAST(N'20:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11297, N'66', CAST(N'2022-05-14' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11298, N'37', CAST(N'2022-05-14' AS Date), CAST(N'20:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11299, N'59', CAST(N'2022-05-14' AS Date), CAST(N'20:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11300, N'43', CAST(N'2022-05-14' AS Date), CAST(N'20:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11301, N'40', CAST(N'2022-05-14' AS Date), CAST(N'20:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11302, N'50', CAST(N'2022-05-14' AS Date), CAST(N'20:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11303, N'11', CAST(N'2022-05-14' AS Date), CAST(N'20:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11304, N'7', CAST(N'2022-05-14' AS Date), CAST(N'20:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11305, N'51', CAST(N'2022-05-14' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11306, N'9', CAST(N'2022-05-14' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11307, N'45', CAST(N'2022-05-14' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11308, N'42', CAST(N'2022-05-14' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11309, N'88', CAST(N'2022-05-14' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11310, N'78', CAST(N'2022-05-14' AS Date), CAST(N'20:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11311, N'33', CAST(N'2022-05-14' AS Date), CAST(N'20:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11312, N'55', CAST(N'2022-05-14' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11313, N'31', CAST(N'2022-05-14' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11314, N'35', CAST(N'2022-05-14' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11315, N'69', CAST(N'2022-05-14' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11316, N'87', CAST(N'2022-05-14' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11317, N'72', CAST(N'2022-05-14' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11318, N'65', CAST(N'2022-05-14' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11319, N'28', CAST(N'2022-05-14' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11320, N'81', CAST(N'2022-05-14' AS Date), CAST(N'21:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11321, N'62', CAST(N'2022-05-14' AS Date), CAST(N'21:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11322, N'20', CAST(N'2022-05-14' AS Date), CAST(N'21:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11323, N'17', CAST(N'2022-05-14' AS Date), CAST(N'21:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11324, N'22', CAST(N'2022-05-14' AS Date), CAST(N'22:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11325, N'13', CAST(N'2022-05-14' AS Date), CAST(N'22:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11326, N'27', CAST(N'2022-05-14' AS Date), CAST(N'22:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11327, N'59', CAST(N'2022-05-15' AS Date), CAST(N'07:40:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11328, N'82', CAST(N'2022-05-15' AS Date), CAST(N'07:40:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11329, N'52', CAST(N'2022-05-15' AS Date), CAST(N'07:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11330, N'44', CAST(N'2022-05-15' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11331, N'53', CAST(N'2022-05-15' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11332, N'83', CAST(N'2022-05-15' AS Date), CAST(N'07:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11333, N'45', CAST(N'2022-05-15' AS Date), CAST(N'08:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11334, N'51', CAST(N'2022-05-15' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11335, N'91', CAST(N'2022-05-15' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11336, N'73', CAST(N'2022-05-15' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11337, N'50', CAST(N'2022-05-15' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11338, N'11', CAST(N'2022-05-15' AS Date), CAST(N'08:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11339, N'85', CAST(N'2022-05-15' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11340, N'11', CAST(N'2022-05-15' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11341, N'86', CAST(N'2022-05-15' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11342, N'48', CAST(N'2022-05-15' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11343, N'66', CAST(N'2022-05-15' AS Date), CAST(N'08:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11344, N'40', CAST(N'2022-05-15' AS Date), CAST(N'08:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11345, N'76', CAST(N'2022-05-15' AS Date), CAST(N'08:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11346, N'28', CAST(N'2022-05-15' AS Date), CAST(N'08:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11347, N'62', CAST(N'2022-05-15' AS Date), CAST(N'09:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11348, N'7', CAST(N'2022-05-15' AS Date), CAST(N'09:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11349, N'44', CAST(N'2022-05-15' AS Date), CAST(N'13:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11350, N'43', CAST(N'2022-05-15' AS Date), CAST(N'13:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11351, N'42', CAST(N'2022-05-15' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11352, N'40', CAST(N'2022-05-15' AS Date), CAST(N'14:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11353, N'51', CAST(N'2022-05-15' AS Date), CAST(N'14:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11354, N'45', CAST(N'2022-05-15' AS Date), CAST(N'14:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11355, N'70', CAST(N'2022-05-15' AS Date), CAST(N'19:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11356, N'8', CAST(N'2022-05-15' AS Date), CAST(N'19:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11357, N'91', CAST(N'2022-05-15' AS Date), CAST(N'19:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11358, N'82', CAST(N'2022-05-15' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11359, N'83', CAST(N'2022-05-15' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11360, N'52', CAST(N'2022-05-15' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11361, N'59', CAST(N'2022-05-15' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11362, N'75', CAST(N'2022-05-15' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11363, N'50', CAST(N'2022-05-15' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11364, N'85', CAST(N'2022-05-15' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11365, N'49', CAST(N'2022-05-15' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11366, N'73', CAST(N'2022-05-15' AS Date), CAST(N'20:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11367, N'86', CAST(N'2022-05-15' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11368, N'46', CAST(N'2022-05-15' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11369, N'48', CAST(N'2022-05-15' AS Date), CAST(N'20:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11370, N'11', CAST(N'2022-05-15' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11371, N'42', CAST(N'2022-05-15' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11372, N'43', CAST(N'2022-05-15' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11373, N'21', CAST(N'2022-05-15' AS Date), CAST(N'20:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11374, N'39', CAST(N'2022-05-15' AS Date), CAST(N'21:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11375, N'28', CAST(N'2022-05-15' AS Date), CAST(N'21:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11376, N'38', CAST(N'2022-05-15' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11377, N'82', CAST(N'2022-05-16' AS Date), CAST(N'07:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11378, N'23', CAST(N'2022-05-16' AS Date), CAST(N'07:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11379, N'52', CAST(N'2022-05-16' AS Date), CAST(N'07:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11380, N'41', CAST(N'2022-05-16' AS Date), CAST(N'07:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11381, N'44', CAST(N'2022-05-16' AS Date), CAST(N'07:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11382, N'58', CAST(N'2022-05-16' AS Date), CAST(N'08:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11383, N'53', CAST(N'2022-05-16' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11384, N'8', CAST(N'2022-05-16' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11385, N'67', CAST(N'2022-05-16' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11386, N'68', CAST(N'2022-05-16' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11387, N'50', CAST(N'2022-05-16' AS Date), CAST(N'08:07:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11388, N'83', CAST(N'2022-05-16' AS Date), CAST(N'08:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11389, N'60', CAST(N'2022-05-16' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11390, N'93', CAST(N'2022-05-16' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11391, N'91', CAST(N'2022-05-16' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11392, N'59', CAST(N'2022-05-16' AS Date), CAST(N'08:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11393, N'85', CAST(N'2022-05-16' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11394, N'48', CAST(N'2022-05-16' AS Date), CAST(N'08:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11395, N'47', CAST(N'2022-05-16' AS Date), CAST(N'08:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11396, N'73', CAST(N'2022-05-16' AS Date), CAST(N'08:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11397, N'86', CAST(N'2022-05-16' AS Date), CAST(N'08:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11398, N'75', CAST(N'2022-05-16' AS Date), CAST(N'08:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11399, N'40', CAST(N'2022-05-16' AS Date), CAST(N'08:39:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11400, N'51', CAST(N'2022-05-16' AS Date), CAST(N'08:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11401, N'89', CAST(N'2022-05-16' AS Date), CAST(N'08:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11402, N'65', CAST(N'2022-05-16' AS Date), CAST(N'08:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11403, N'56', CAST(N'2022-05-16' AS Date), CAST(N'08:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11404, N'28', CAST(N'2022-05-16' AS Date), CAST(N'08:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11405, N'81', CAST(N'2022-05-16' AS Date), CAST(N'09:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11406, N'64', CAST(N'2022-05-16' AS Date), CAST(N'09:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11407, N'14', CAST(N'2022-05-16' AS Date), CAST(N'09:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11408, N'21', CAST(N'2022-05-16' AS Date), CAST(N'09:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11409, N'69', CAST(N'2022-05-16' AS Date), CAST(N'09:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11410, N'6', CAST(N'2022-05-16' AS Date), CAST(N'09:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11411, N'20', CAST(N'2022-05-16' AS Date), CAST(N'09:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11412, N'27', CAST(N'2022-05-16' AS Date), CAST(N'09:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11413, N'70', CAST(N'2022-05-16' AS Date), CAST(N'10:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11414, N'63', CAST(N'2022-05-16' AS Date), CAST(N'10:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11415, N'24', CAST(N'2022-05-16' AS Date), CAST(N'10:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11416, N'26', CAST(N'2022-05-16' AS Date), CAST(N'10:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11417, N'16', CAST(N'2022-05-16' AS Date), CAST(N'10:39:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11418, N'29', CAST(N'2022-05-16' AS Date), CAST(N'10:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11419, N'38', CAST(N'2022-05-16' AS Date), CAST(N'11:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11420, N'15', CAST(N'2022-05-16' AS Date), CAST(N'11:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11421, N'2', CAST(N'2022-05-16' AS Date), CAST(N'11:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11422, N'12', CAST(N'2022-05-16' AS Date), CAST(N'11:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11423, N'71', CAST(N'2022-05-16' AS Date), CAST(N'11:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11424, N'13', CAST(N'2022-05-16' AS Date), CAST(N'12:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11425, N'74', CAST(N'2022-05-16' AS Date), CAST(N'13:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11426, N'44', CAST(N'2022-05-16' AS Date), CAST(N'13:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11427, N'43', CAST(N'2022-05-16' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11428, N'60', CAST(N'2022-05-16' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11429, N'67', CAST(N'2022-05-16' AS Date), CAST(N'13:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11430, N'3', CAST(N'2022-05-16' AS Date), CAST(N'13:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11431, N'78', CAST(N'2022-05-16' AS Date), CAST(N'14:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11432, N'42', CAST(N'2022-05-16' AS Date), CAST(N'14:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11433, N'45', CAST(N'2022-05-16' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11434, N'9', CAST(N'2022-05-16' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11435, N'18', CAST(N'2022-05-16' AS Date), CAST(N'14:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11436, N'88', CAST(N'2022-05-16' AS Date), CAST(N'14:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11437, N'40', CAST(N'2022-05-16' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11438, N'53', CAST(N'2022-05-16' AS Date), CAST(N'14:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11439, N'6', CAST(N'2022-05-16' AS Date), CAST(N'14:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11440, N'46', CAST(N'2022-05-16' AS Date), CAST(N'14:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11441, N'35', CAST(N'2022-05-16' AS Date), CAST(N'14:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11442, N'37', CAST(N'2022-05-16' AS Date), CAST(N'14:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11443, N'58', CAST(N'2022-05-16' AS Date), CAST(N'14:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11444, N'73', CAST(N'2022-05-16' AS Date), CAST(N'14:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11445, N'41', CAST(N'2022-05-16' AS Date), CAST(N'14:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11446, N'34', CAST(N'2022-05-16' AS Date), CAST(N'14:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11447, N'47', CAST(N'2022-05-16' AS Date), CAST(N'14:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11448, N'22', CAST(N'2022-05-16' AS Date), CAST(N'14:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11449, N'72', CAST(N'2022-05-16' AS Date), CAST(N'14:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11450, N'23', CAST(N'2022-05-16' AS Date), CAST(N'14:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11451, N'55', CAST(N'2022-05-16' AS Date), CAST(N'14:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11452, N'16', CAST(N'2022-05-16' AS Date), CAST(N'15:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11453, N'56', CAST(N'2022-05-16' AS Date), CAST(N'15:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11454, N'32', CAST(N'2022-05-16' AS Date), CAST(N'15:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11455, N'33', CAST(N'2022-05-16' AS Date), CAST(N'15:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11456, N'31', CAST(N'2022-05-16' AS Date), CAST(N'15:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11457, N'87', CAST(N'2022-05-16' AS Date), CAST(N'15:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11458, N'39', CAST(N'2022-05-16' AS Date), CAST(N'16:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11459, N'38', CAST(N'2022-05-16' AS Date), CAST(N'17:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11460, N'89', CAST(N'2022-05-16' AS Date), CAST(N'17:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11461, N'24', CAST(N'2022-05-16' AS Date), CAST(N'17:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11462, N'12', CAST(N'2022-05-16' AS Date), CAST(N'18:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11463, N'71', CAST(N'2022-05-16' AS Date), CAST(N'19:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11464, N'74', CAST(N'2022-05-16' AS Date), CAST(N'19:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11465, N'52', CAST(N'2022-05-16' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11466, N'26', CAST(N'2022-05-16' AS Date), CAST(N'19:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11467, N'76', CAST(N'2022-05-16' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11468, N'86', CAST(N'2022-05-16' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11469, N'70', CAST(N'2022-05-16' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11470, N'85', CAST(N'2022-05-16' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11471, N'75', CAST(N'2022-05-16' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11472, N'48', CAST(N'2022-05-16' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11473, N'49', CAST(N'2022-05-16' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11474, N'91', CAST(N'2022-05-16' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11475, N'93', CAST(N'2022-05-16' AS Date), CAST(N'20:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11476, N'83', CAST(N'2022-05-16' AS Date), CAST(N'20:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11477, N'50', CAST(N'2022-05-16' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11478, N'37', CAST(N'2022-05-16' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11479, N'61', CAST(N'2022-05-16' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11480, N'15', CAST(N'2022-05-16' AS Date), CAST(N'20:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11481, N'11', CAST(N'2022-05-16' AS Date), CAST(N'20:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11482, N'57', CAST(N'2022-05-16' AS Date), CAST(N'20:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11483, N'7', CAST(N'2022-05-16' AS Date), CAST(N'20:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11484, N'9', CAST(N'2022-05-16' AS Date), CAST(N'20:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11485, N'66', CAST(N'2022-05-16' AS Date), CAST(N'20:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11486, N'78', CAST(N'2022-05-16' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11487, N'45', CAST(N'2022-05-16' AS Date), CAST(N'20:25:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11488, N'42', CAST(N'2022-05-16' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11489, N'46', CAST(N'2022-05-16' AS Date), CAST(N'20:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11490, N'43', CAST(N'2022-05-16' AS Date), CAST(N'20:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11491, N'51', CAST(N'2022-05-16' AS Date), CAST(N'20:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11492, N'21', CAST(N'2022-05-16' AS Date), CAST(N'20:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11493, N'62', CAST(N'2022-05-16' AS Date), CAST(N'20:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11494, N'64', CAST(N'2022-05-16' AS Date), CAST(N'20:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11495, N'81', CAST(N'2022-05-16' AS Date), CAST(N'20:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11496, N'55', CAST(N'2022-05-16' AS Date), CAST(N'20:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11497, N'72', CAST(N'2022-05-16' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11498, N'29', CAST(N'2022-05-16' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11499, N'88', CAST(N'2022-05-16' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11500, N'69', CAST(N'2022-05-16' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11501, N'28', CAST(N'2022-05-16' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11502, N'34', CAST(N'2022-05-16' AS Date), CAST(N'21:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11503, N'18', CAST(N'2022-05-16' AS Date), CAST(N'21:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11504, N'35', CAST(N'2022-05-16' AS Date), CAST(N'21:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11505, N'32', CAST(N'2022-05-16' AS Date), CAST(N'21:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11506, N'20', CAST(N'2022-05-16' AS Date), CAST(N'21:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11507, N'14', CAST(N'2022-05-16' AS Date), CAST(N'21:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11508, N'31', CAST(N'2022-05-16' AS Date), CAST(N'21:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11509, N'87', CAST(N'2022-05-16' AS Date), CAST(N'21:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11510, N'33', CAST(N'2022-05-16' AS Date), CAST(N'21:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11511, N'22', CAST(N'2022-05-16' AS Date), CAST(N'21:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11512, N'13', CAST(N'2022-05-16' AS Date), CAST(N'22:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11513, N'27', CAST(N'2022-05-16' AS Date), CAST(N'22:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11514, N'68', CAST(N'2022-05-16' AS Date), CAST(N'23:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11515, N'82', CAST(N'2022-05-17' AS Date), CAST(N'07:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11516, N'52', CAST(N'2022-05-17' AS Date), CAST(N'07:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11517, N'59', CAST(N'2022-05-17' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11518, N'83', CAST(N'2022-05-17' AS Date), CAST(N'07:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11519, N'23', CAST(N'2022-05-17' AS Date), CAST(N'07:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11520, N'41', CAST(N'2022-05-17' AS Date), CAST(N'07:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11521, N'51', CAST(N'2022-05-17' AS Date), CAST(N'07:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11522, N'44', CAST(N'2022-05-17' AS Date), CAST(N'07:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11523, N'93', CAST(N'2022-05-17' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11524, N'50', CAST(N'2022-05-17' AS Date), CAST(N'08:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11525, N'67', CAST(N'2022-05-17' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11526, N'68', CAST(N'2022-05-17' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11527, N'86', CAST(N'2022-05-17' AS Date), CAST(N'08:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11528, N'53', CAST(N'2022-05-17' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11529, N'91', CAST(N'2022-05-17' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11530, N'7', CAST(N'2022-05-17' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11531, N'66', CAST(N'2022-05-17' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11532, N'61', CAST(N'2022-05-17' AS Date), CAST(N'08:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11533, N'73', CAST(N'2022-05-17' AS Date), CAST(N'08:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11534, N'48', CAST(N'2022-05-17' AS Date), CAST(N'08:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11535, N'49', CAST(N'2022-05-17' AS Date), CAST(N'08:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11536, N'75', CAST(N'2022-05-17' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11537, N'58', CAST(N'2022-05-17' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11538, N'85', CAST(N'2022-05-17' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11539, N'47', CAST(N'2022-05-17' AS Date), CAST(N'08:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11540, N'11', CAST(N'2022-05-17' AS Date), CAST(N'08:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11541, N'92', CAST(N'2022-05-17' AS Date), CAST(N'08:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11542, N'60', CAST(N'2022-05-17' AS Date), CAST(N'08:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11543, N'40', CAST(N'2022-05-17' AS Date), CAST(N'08:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11544, N'65', CAST(N'2022-05-17' AS Date), CAST(N'08:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11545, N'89', CAST(N'2022-05-17' AS Date), CAST(N'08:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11546, N'56', CAST(N'2022-05-17' AS Date), CAST(N'08:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11547, N'76', CAST(N'2022-05-17' AS Date), CAST(N'09:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11548, N'28', CAST(N'2022-05-17' AS Date), CAST(N'09:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11549, N'62', CAST(N'2022-05-17' AS Date), CAST(N'09:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11550, N'69', CAST(N'2022-05-17' AS Date), CAST(N'09:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11551, N'14', CAST(N'2022-05-17' AS Date), CAST(N'09:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11552, N'81', CAST(N'2022-05-17' AS Date), CAST(N'09:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11553, N'64', CAST(N'2022-05-17' AS Date), CAST(N'09:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11554, N'20', CAST(N'2022-05-17' AS Date), CAST(N'09:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11555, N'21', CAST(N'2022-05-17' AS Date), CAST(N'09:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11556, N'27', CAST(N'2022-05-17' AS Date), CAST(N'09:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11557, N'24', CAST(N'2022-05-17' AS Date), CAST(N'10:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11558, N'13', CAST(N'2022-05-17' AS Date), CAST(N'10:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11559, N'29', CAST(N'2022-05-17' AS Date), CAST(N'10:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11560, N'15', CAST(N'2022-05-17' AS Date), CAST(N'10:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11561, N'12', CAST(N'2022-05-17' AS Date), CAST(N'10:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11562, N'71', CAST(N'2022-05-17' AS Date), CAST(N'11:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11563, N'38', CAST(N'2022-05-17' AS Date), CAST(N'11:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11564, N'26', CAST(N'2022-05-17' AS Date), CAST(N'11:39:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11565, N'74', CAST(N'2022-05-17' AS Date), CAST(N'13:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11566, N'44', CAST(N'2022-05-17' AS Date), CAST(N'13:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11567, N'67', CAST(N'2022-05-17' AS Date), CAST(N'13:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11568, N'43', CAST(N'2022-05-17' AS Date), CAST(N'13:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11569, N'88', CAST(N'2022-05-17' AS Date), CAST(N'13:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11570, N'3', CAST(N'2022-05-17' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11571, N'78', CAST(N'2022-05-17' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11572, N'77', CAST(N'2022-05-17' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11573, N'40', CAST(N'2022-05-17' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11574, N'42', CAST(N'2022-05-17' AS Date), CAST(N'14:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11575, N'45', CAST(N'2022-05-17' AS Date), CAST(N'14:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11576, N'41', CAST(N'2022-05-17' AS Date), CAST(N'14:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11577, N'18', CAST(N'2022-05-17' AS Date), CAST(N'14:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11578, N'35', CAST(N'2022-05-17' AS Date), CAST(N'14:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11579, N'53', CAST(N'2022-05-17' AS Date), CAST(N'14:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11580, N'51', CAST(N'2022-05-17' AS Date), CAST(N'14:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11581, N'92', CAST(N'2022-05-17' AS Date), CAST(N'14:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11582, N'37', CAST(N'2022-05-17' AS Date), CAST(N'14:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11583, N'60', CAST(N'2022-05-17' AS Date), CAST(N'14:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11584, N'46', CAST(N'2022-05-17' AS Date), CAST(N'14:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11585, N'79', CAST(N'2022-05-17' AS Date), CAST(N'14:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11586, N'58', CAST(N'2022-05-17' AS Date), CAST(N'14:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11587, N'22', CAST(N'2022-05-17' AS Date), CAST(N'14:33:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11588, N'72', CAST(N'2022-05-17' AS Date), CAST(N'14:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11589, N'32', CAST(N'2022-05-17' AS Date), CAST(N'14:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11590, N'34', CAST(N'2022-05-17' AS Date), CAST(N'14:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11591, N'23', CAST(N'2022-05-17' AS Date), CAST(N'14:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11592, N'33', CAST(N'2022-05-17' AS Date), CAST(N'15:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11593, N'55', CAST(N'2022-05-17' AS Date), CAST(N'15:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11594, N'31', CAST(N'2022-05-17' AS Date), CAST(N'15:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11595, N'56', CAST(N'2022-05-17' AS Date), CAST(N'15:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11596, N'87', CAST(N'2022-05-17' AS Date), CAST(N'15:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11597, N'17', CAST(N'2022-05-17' AS Date), CAST(N'15:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11598, N'9', CAST(N'2022-05-17' AS Date), CAST(N'15:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11599, N'39', CAST(N'2022-05-17' AS Date), CAST(N'16:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11600, N'57', CAST(N'2022-05-17' AS Date), CAST(N'17:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11601, N'38', CAST(N'2022-05-17' AS Date), CAST(N'17:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11602, N'89', CAST(N'2022-05-17' AS Date), CAST(N'17:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11603, N'12', CAST(N'2022-05-17' AS Date), CAST(N'17:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11604, N'24', CAST(N'2022-05-17' AS Date), CAST(N'17:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11605, N'15', CAST(N'2022-05-17' AS Date), CAST(N'19:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11606, N'8', CAST(N'2022-05-17' AS Date), CAST(N'19:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11607, N'91', CAST(N'2022-05-17' AS Date), CAST(N'19:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11608, N'61', CAST(N'2022-05-17' AS Date), CAST(N'19:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11609, N'82', CAST(N'2022-05-17' AS Date), CAST(N'19:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11610, N'83', CAST(N'2022-05-17' AS Date), CAST(N'19:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11611, N'3', CAST(N'2022-05-17' AS Date), CAST(N'19:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11612, N'86', CAST(N'2022-05-17' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11613, N'93', CAST(N'2022-05-17' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11614, N'77', CAST(N'2022-05-17' AS Date), CAST(N'19:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11615, N'50', CAST(N'2022-05-17' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11616, N'70', CAST(N'2022-05-17' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11617, N'57', CAST(N'2022-05-17' AS Date), CAST(N'19:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11618, N'85', CAST(N'2022-05-17' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11619, N'75', CAST(N'2022-05-17' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11620, N'76', CAST(N'2022-05-17' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11621, N'52', CAST(N'2022-05-17' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11622, N'49', CAST(N'2022-05-17' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11623, N'59', CAST(N'2022-05-17' AS Date), CAST(N'20:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11624, N'18', CAST(N'2022-05-17' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11625, N'68', CAST(N'2022-05-17' AS Date), CAST(N'20:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11626, N'66', CAST(N'2022-05-17' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11627, N'26', CAST(N'2022-05-17' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11628, N'47', CAST(N'2022-05-17' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11629, N'37', CAST(N'2022-05-17' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11630, N'43', CAST(N'2022-05-17' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11631, N'88', CAST(N'2022-05-17' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11632, N'78', CAST(N'2022-05-17' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11633, N'42', CAST(N'2022-05-17' AS Date), CAST(N'20:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11634, N'45', CAST(N'2022-05-17' AS Date), CAST(N'20:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11635, N'46', CAST(N'2022-05-17' AS Date), CAST(N'20:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11636, N'73', CAST(N'2022-05-17' AS Date), CAST(N'20:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11637, N'21', CAST(N'2022-05-17' AS Date), CAST(N'20:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11638, N'33', CAST(N'2022-05-17' AS Date), CAST(N'20:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11639, N'20', CAST(N'2022-05-17' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11640, N'29', CAST(N'2022-05-17' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11641, N'31', CAST(N'2022-05-17' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11642, N'32', CAST(N'2022-05-17' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11643, N'69', CAST(N'2022-05-17' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11644, N'62', CAST(N'2022-05-17' AS Date), CAST(N'21:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11645, N'87', CAST(N'2022-05-17' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11646, N'28', CAST(N'2022-05-17' AS Date), CAST(N'21:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11647, N'72', CAST(N'2022-05-17' AS Date), CAST(N'21:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11648, N'65', CAST(N'2022-05-17' AS Date), CAST(N'21:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11649, N'55', CAST(N'2022-05-17' AS Date), CAST(N'21:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11650, N'64', CAST(N'2022-05-17' AS Date), CAST(N'21:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11651, N'81', CAST(N'2022-05-17' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11652, N'14', CAST(N'2022-05-17' AS Date), CAST(N'21:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11653, N'17', CAST(N'2022-05-17' AS Date), CAST(N'21:40:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11654, N'27', CAST(N'2022-05-17' AS Date), CAST(N'21:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11655, N'22', CAST(N'2022-05-17' AS Date), CAST(N'21:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11656, N'13', CAST(N'2022-05-17' AS Date), CAST(N'22:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11657, N'83', CAST(N'2022-05-18' AS Date), CAST(N'06:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11658, N'82', CAST(N'2022-05-18' AS Date), CAST(N'06:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11659, N'59', CAST(N'2022-05-18' AS Date), CAST(N'07:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11660, N'23', CAST(N'2022-05-18' AS Date), CAST(N'07:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11661, N'41', CAST(N'2022-05-18' AS Date), CAST(N'07:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11662, N'50', CAST(N'2022-05-18' AS Date), CAST(N'07:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11663, N'44', CAST(N'2022-05-18' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11664, N'61', CAST(N'2022-05-18' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11665, N'8', CAST(N'2022-05-18' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11666, N'52', CAST(N'2022-05-18' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11667, N'66', CAST(N'2022-05-18' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11668, N'92', CAST(N'2022-05-18' AS Date), CAST(N'07:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11669, N'51', CAST(N'2022-05-18' AS Date), CAST(N'08:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11670, N'58', CAST(N'2022-05-18' AS Date), CAST(N'08:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11671, N'53', CAST(N'2022-05-18' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11672, N'47', CAST(N'2022-05-18' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11673, N'68', CAST(N'2022-05-18' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11674, N'67', CAST(N'2022-05-18' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11675, N'93', CAST(N'2022-05-18' AS Date), CAST(N'08:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11676, N'60', CAST(N'2022-05-18' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11677, N'73', CAST(N'2022-05-18' AS Date), CAST(N'08:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11678, N'49', CAST(N'2022-05-18' AS Date), CAST(N'08:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11679, N'40', CAST(N'2022-05-18' AS Date), CAST(N'08:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11680, N'86', CAST(N'2022-05-18' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11681, N'75', CAST(N'2022-05-18' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11682, N'91', CAST(N'2022-05-18' AS Date), CAST(N'08:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11683, N'85', CAST(N'2022-05-18' AS Date), CAST(N'08:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11684, N'56', CAST(N'2022-05-18' AS Date), CAST(N'08:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11685, N'81', CAST(N'2022-05-18' AS Date), CAST(N'08:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11686, N'65', CAST(N'2022-05-18' AS Date), CAST(N'08:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11687, N'76', CAST(N'2022-05-18' AS Date), CAST(N'08:55:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11688, N'64', CAST(N'2022-05-18' AS Date), CAST(N'08:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11689, N'89', CAST(N'2022-05-18' AS Date), CAST(N'08:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11690, N'28', CAST(N'2022-05-18' AS Date), CAST(N'09:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11691, N'69', CAST(N'2022-05-18' AS Date), CAST(N'09:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11692, N'14', CAST(N'2022-05-18' AS Date), CAST(N'09:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11693, N'20', CAST(N'2022-05-18' AS Date), CAST(N'09:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11694, N'21', CAST(N'2022-05-18' AS Date), CAST(N'09:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11695, N'27', CAST(N'2022-05-18' AS Date), CAST(N'09:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11696, N'29', CAST(N'2022-05-18' AS Date), CAST(N'10:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11697, N'13', CAST(N'2022-05-18' AS Date), CAST(N'10:40:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11698, N'12', CAST(N'2022-05-18' AS Date), CAST(N'10:40:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11699, N'15', CAST(N'2022-05-18' AS Date), CAST(N'10:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11700, N'38', CAST(N'2022-05-18' AS Date), CAST(N'11:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11701, N'26', CAST(N'2022-05-18' AS Date), CAST(N'11:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11702, N'2', CAST(N'2022-05-18' AS Date), CAST(N'11:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11703, N'74', CAST(N'2022-05-18' AS Date), CAST(N'13:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11704, N'88', CAST(N'2022-05-18' AS Date), CAST(N'13:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11705, N'44', CAST(N'2022-05-18' AS Date), CAST(N'13:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11706, N'43', CAST(N'2022-05-18' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11707, N'45', CAST(N'2022-05-18' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11708, N'42', CAST(N'2022-05-18' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11709, N'78', CAST(N'2022-05-18' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11710, N'3', CAST(N'2022-05-18' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11711, N'60', CAST(N'2022-05-18' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11712, N'41', CAST(N'2022-05-18' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11713, N'77', CAST(N'2022-05-18' AS Date), CAST(N'14:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11714, N'35', CAST(N'2022-05-18' AS Date), CAST(N'14:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11715, N'92', CAST(N'2022-05-18' AS Date), CAST(N'14:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11716, N'9', CAST(N'2022-05-18' AS Date), CAST(N'14:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11717, N'58', CAST(N'2022-05-18' AS Date), CAST(N'14:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11718, N'53', CAST(N'2022-05-18' AS Date), CAST(N'14:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11719, N'46', CAST(N'2022-05-18' AS Date), CAST(N'14:29:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11720, N'37', CAST(N'2022-05-18' AS Date), CAST(N'14:37:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11721, N'22', CAST(N'2022-05-18' AS Date), CAST(N'14:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11722, N'47', CAST(N'2022-05-18' AS Date), CAST(N'14:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11723, N'23', CAST(N'2022-05-18' AS Date), CAST(N'14:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11724, N'72', CAST(N'2022-05-18' AS Date), CAST(N'14:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11725, N'67', CAST(N'2022-05-18' AS Date), CAST(N'14:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11726, N'34', CAST(N'2022-05-18' AS Date), CAST(N'14:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11727, N'55', CAST(N'2022-05-18' AS Date), CAST(N'15:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11728, N'32', CAST(N'2022-05-18' AS Date), CAST(N'15:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11729, N'56', CAST(N'2022-05-18' AS Date), CAST(N'15:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11730, N'31', CAST(N'2022-05-18' AS Date), CAST(N'15:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11731, N'87', CAST(N'2022-05-18' AS Date), CAST(N'15:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11732, N'57', CAST(N'2022-05-18' AS Date), CAST(N'15:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11733, N'17', CAST(N'2022-05-18' AS Date), CAST(N'15:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11734, N'14', CAST(N'2022-05-18' AS Date), CAST(N'16:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11735, N'26', CAST(N'2022-05-18' AS Date), CAST(N'16:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11736, N'39', CAST(N'2022-05-18' AS Date), CAST(N'16:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11737, N'38', CAST(N'2022-05-18' AS Date), CAST(N'16:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11738, N'90', CAST(N'2022-05-18' AS Date), CAST(N'17:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11739, N'12', CAST(N'2022-05-18' AS Date), CAST(N'18:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11740, N'83', CAST(N'2022-05-18' AS Date), CAST(N'19:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11741, N'15', CAST(N'2022-05-18' AS Date), CAST(N'19:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11742, N'2', CAST(N'2022-05-18' AS Date), CAST(N'19:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11743, N'74', CAST(N'2022-05-18' AS Date), CAST(N'19:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11744, N'11', CAST(N'2022-05-18' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11745, N'86', CAST(N'2022-05-18' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11746, N'76', CAST(N'2022-05-18' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11747, N'70', CAST(N'2022-05-18' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11748, N'52', CAST(N'2022-05-18' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11749, N'9', CAST(N'2022-05-18' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11750, N'57', CAST(N'2022-05-18' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11751, N'63', CAST(N'2022-05-18' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11752, N'73', CAST(N'2022-05-18' AS Date), CAST(N'19:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11753, N'75', CAST(N'2022-05-18' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11754, N'93', CAST(N'2022-05-18' AS Date), CAST(N'20:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11755, N'91', CAST(N'2022-05-18' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11756, N'40', CAST(N'2022-05-18' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11757, N'49', CAST(N'2022-05-18' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11758, N'87', CAST(N'2022-05-18' AS Date), CAST(N'20:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11759, N'85', CAST(N'2022-05-18' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11760, N'7', CAST(N'2022-05-18' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11761, N'50', CAST(N'2022-05-18' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11762, N'51', CAST(N'2022-05-18' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11763, N'43', CAST(N'2022-05-18' AS Date), CAST(N'20:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11764, N'61', CAST(N'2022-05-18' AS Date), CAST(N'20:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11765, N'88', CAST(N'2022-05-18' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11766, N'66', CAST(N'2022-05-18' AS Date), CAST(N'20:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11767, N'59', CAST(N'2022-05-18' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11768, N'45', CAST(N'2022-05-18' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11769, N'46', CAST(N'2022-05-18' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11770, N'42', CAST(N'2022-05-18' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11771, N'78', CAST(N'2022-05-18' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11772, N'64', CAST(N'2022-05-18' AS Date), CAST(N'20:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11773, N'81', CAST(N'2022-05-18' AS Date), CAST(N'20:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11774, N'37', CAST(N'2022-05-18' AS Date), CAST(N'20:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11775, N'77', CAST(N'2022-05-18' AS Date), CAST(N'20:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11776, N'55', CAST(N'2022-05-18' AS Date), CAST(N'20:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11777, N'72', CAST(N'2022-05-18' AS Date), CAST(N'20:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11778, N'21', CAST(N'2022-05-18' AS Date), CAST(N'20:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11779, N'62', CAST(N'2022-05-18' AS Date), CAST(N'20:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11780, N'29', CAST(N'2022-05-18' AS Date), CAST(N'20:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11781, N'28', CAST(N'2022-05-18' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11782, N'20', CAST(N'2022-05-18' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11783, N'65', CAST(N'2022-05-18' AS Date), CAST(N'21:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11784, N'34', CAST(N'2022-05-18' AS Date), CAST(N'21:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11785, N'32', CAST(N'2022-05-18' AS Date), CAST(N'21:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11786, N'22', CAST(N'2022-05-18' AS Date), CAST(N'21:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11787, N'13', CAST(N'2022-05-18' AS Date), CAST(N'22:04:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11788, N'27', CAST(N'2022-05-18' AS Date), CAST(N'22:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11789, N'68', CAST(N'2022-05-18' AS Date), CAST(N'23:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11790, N'92', CAST(N'2022-05-19' AS Date), CAST(N'07:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11791, N'41', CAST(N'2022-05-19' AS Date), CAST(N'07:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11792, N'82', CAST(N'2022-05-19' AS Date), CAST(N'07:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11793, N'23', CAST(N'2022-05-19' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11794, N'53', CAST(N'2022-05-19' AS Date), CAST(N'07:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11795, N'50', CAST(N'2022-05-19' AS Date), CAST(N'07:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11796, N'51', CAST(N'2022-05-19' AS Date), CAST(N'08:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11797, N'67', CAST(N'2022-05-19' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11798, N'44', CAST(N'2022-05-19' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11799, N'52', CAST(N'2022-05-19' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11800, N'59', CAST(N'2022-05-19' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11801, N'58', CAST(N'2022-05-19' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11802, N'91', CAST(N'2022-05-19' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11803, N'60', CAST(N'2022-05-19' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11804, N'68', CAST(N'2022-05-19' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11805, N'93', CAST(N'2022-05-19' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11806, N'49', CAST(N'2022-05-19' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11807, N'40', CAST(N'2022-05-19' AS Date), CAST(N'08:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11808, N'61', CAST(N'2022-05-19' AS Date), CAST(N'08:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11809, N'11', CAST(N'2022-05-19' AS Date), CAST(N'08:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11810, N'66', CAST(N'2022-05-19' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11811, N'47', CAST(N'2022-05-19' AS Date), CAST(N'08:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11812, N'75', CAST(N'2022-05-19' AS Date), CAST(N'08:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11813, N'86', CAST(N'2022-05-19' AS Date), CAST(N'08:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11814, N'85', CAST(N'2022-05-19' AS Date), CAST(N'08:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11815, N'7', CAST(N'2022-05-19' AS Date), CAST(N'08:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11816, N'65', CAST(N'2022-05-19' AS Date), CAST(N'08:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11817, N'56', CAST(N'2022-05-19' AS Date), CAST(N'08:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11818, N'76', CAST(N'2022-05-19' AS Date), CAST(N'08:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11819, N'89', CAST(N'2022-05-19' AS Date), CAST(N'08:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11820, N'28', CAST(N'2022-05-19' AS Date), CAST(N'08:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11821, N'69', CAST(N'2022-05-19' AS Date), CAST(N'09:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11822, N'81', CAST(N'2022-05-19' AS Date), CAST(N'09:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11823, N'64', CAST(N'2022-05-19' AS Date), CAST(N'09:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11824, N'83', CAST(N'2022-05-19' AS Date), CAST(N'09:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11825, N'14', CAST(N'2022-05-19' AS Date), CAST(N'09:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11826, N'20', CAST(N'2022-05-19' AS Date), CAST(N'09:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11827, N'6', CAST(N'2022-05-19' AS Date), CAST(N'09:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11828, N'27', CAST(N'2022-05-19' AS Date), CAST(N'09:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11829, N'21', CAST(N'2022-05-19' AS Date), CAST(N'10:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11830, N'24', CAST(N'2022-05-19' AS Date), CAST(N'10:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11831, N'29', CAST(N'2022-05-19' AS Date), CAST(N'10:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11832, N'15', CAST(N'2022-05-19' AS Date), CAST(N'10:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11833, N'16', CAST(N'2022-05-19' AS Date), CAST(N'10:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11834, N'12', CAST(N'2022-05-19' AS Date), CAST(N'10:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11835, N'13', CAST(N'2022-05-19' AS Date), CAST(N'10:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11836, N'38', CAST(N'2022-05-19' AS Date), CAST(N'10:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11837, N'26', CAST(N'2022-05-19' AS Date), CAST(N'11:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11838, N'71', CAST(N'2022-05-19' AS Date), CAST(N'11:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11839, N'74', CAST(N'2022-05-19' AS Date), CAST(N'13:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11840, N'67', CAST(N'2022-05-19' AS Date), CAST(N'13:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11841, N'72', CAST(N'2022-05-19' AS Date), CAST(N'13:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11842, N'77', CAST(N'2022-05-19' AS Date), CAST(N'13:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11843, N'3', CAST(N'2022-05-19' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11844, N'42', CAST(N'2022-05-19' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11845, N'43', CAST(N'2022-05-19' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11846, N'45', CAST(N'2022-05-19' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11847, N'60', CAST(N'2022-05-19' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11848, N'40', CAST(N'2022-05-19' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11849, N'44', CAST(N'2022-05-19' AS Date), CAST(N'14:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11850, N'9', CAST(N'2022-05-19' AS Date), CAST(N'14:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11851, N'41', CAST(N'2022-05-19' AS Date), CAST(N'14:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11852, N'79', CAST(N'2022-05-19' AS Date), CAST(N'14:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11853, N'51', CAST(N'2022-05-19' AS Date), CAST(N'14:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11854, N'46', CAST(N'2022-05-19' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11855, N'6', CAST(N'2022-05-19' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11856, N'58', CAST(N'2022-05-19' AS Date), CAST(N'14:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11857, N'35', CAST(N'2022-05-19' AS Date), CAST(N'14:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11858, N'37', CAST(N'2022-05-19' AS Date), CAST(N'14:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11859, N'78', CAST(N'2022-05-19' AS Date), CAST(N'14:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11860, N'18', CAST(N'2022-05-19' AS Date), CAST(N'14:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11861, N'32', CAST(N'2022-05-19' AS Date), CAST(N'14:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11862, N'22', CAST(N'2022-05-19' AS Date), CAST(N'14:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11863, N'55', CAST(N'2022-05-19' AS Date), CAST(N'14:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11864, N'56', CAST(N'2022-05-19' AS Date), CAST(N'14:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11865, N'16', CAST(N'2022-05-19' AS Date), CAST(N'14:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11866, N'34', CAST(N'2022-05-19' AS Date), CAST(N'14:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11867, N'87', CAST(N'2022-05-19' AS Date), CAST(N'14:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11868, N'33', CAST(N'2022-05-19' AS Date), CAST(N'15:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11869, N'17', CAST(N'2022-05-19' AS Date), CAST(N'15:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11870, N'57', CAST(N'2022-05-19' AS Date), CAST(N'15:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11871, N'39', CAST(N'2022-05-19' AS Date), CAST(N'16:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11872, N'90', CAST(N'2022-05-19' AS Date), CAST(N'16:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11873, N'38', CAST(N'2022-05-19' AS Date), CAST(N'17:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11874, N'89', CAST(N'2022-05-19' AS Date), CAST(N'17:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11875, N'24', CAST(N'2022-05-19' AS Date), CAST(N'17:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11876, N'71', CAST(N'2022-05-19' AS Date), CAST(N'18:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11877, N'12', CAST(N'2022-05-19' AS Date), CAST(N'18:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11878, N'15', CAST(N'2022-05-19' AS Date), CAST(N'19:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11879, N'8', CAST(N'2022-05-19' AS Date), CAST(N'19:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11880, N'70', CAST(N'2022-05-19' AS Date), CAST(N'19:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11881, N'52', CAST(N'2022-05-19' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11882, N'86', CAST(N'2022-05-19' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11883, N'68', CAST(N'2022-05-19' AS Date), CAST(N'19:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11884, N'3', CAST(N'2022-05-19' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11885, N'91', CAST(N'2022-05-19' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11886, N'47', CAST(N'2022-05-19' AS Date), CAST(N'19:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11887, N'93', CAST(N'2022-05-19' AS Date), CAST(N'19:59:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11888, N'66', CAST(N'2022-05-19' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11889, N'77', CAST(N'2022-05-19' AS Date), CAST(N'20:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11890, N'48', CAST(N'2022-05-19' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11891, N'74', CAST(N'2022-05-19' AS Date), CAST(N'20:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11892, N'59', CAST(N'2022-05-19' AS Date), CAST(N'20:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11893, N'50', CAST(N'2022-05-19' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11894, N'75', CAST(N'2022-05-19' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11895, N'76', CAST(N'2022-05-19' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11896, N'18', CAST(N'2022-05-19' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11897, N'85', CAST(N'2022-05-19' AS Date), CAST(N'20:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11898, N'49', CAST(N'2022-05-19' AS Date), CAST(N'20:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11899, N'37', CAST(N'2022-05-19' AS Date), CAST(N'20:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11900, N'43', CAST(N'2022-05-19' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11901, N'42', CAST(N'2022-05-19' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11902, N'45', CAST(N'2022-05-19' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11903, N'26', CAST(N'2022-05-19' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11904, N'83', CAST(N'2022-05-19' AS Date), CAST(N'20:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11905, N'73', CAST(N'2022-05-19' AS Date), CAST(N'20:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11906, N'78', CAST(N'2022-05-19' AS Date), CAST(N'20:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11907, N'9', CAST(N'2022-05-19' AS Date), CAST(N'20:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11908, N'57', CAST(N'2022-05-19' AS Date), CAST(N'20:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11909, N'21', CAST(N'2022-05-19' AS Date), CAST(N'20:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11910, N'29', CAST(N'2022-05-19' AS Date), CAST(N'20:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11911, N'28', CAST(N'2022-05-19' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11912, N'72', CAST(N'2022-05-19' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11913, N'69', CAST(N'2022-05-19' AS Date), CAST(N'21:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11914, N'55', CAST(N'2022-05-19' AS Date), CAST(N'21:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11915, N'20', CAST(N'2022-05-19' AS Date), CAST(N'21:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11916, N'81', CAST(N'2022-05-19' AS Date), CAST(N'21:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11917, N'17', CAST(N'2022-05-19' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11918, N'65', CAST(N'2022-05-19' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11919, N'61', CAST(N'2022-05-19' AS Date), CAST(N'21:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11920, N'14', CAST(N'2022-05-19' AS Date), CAST(N'21:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11921, N'13', CAST(N'2022-05-19' AS Date), CAST(N'22:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11922, N'35', CAST(N'2022-05-19' AS Date), CAST(N'22:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11923, N'33', CAST(N'2022-05-19' AS Date), CAST(N'22:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11924, N'62', CAST(N'2022-05-19' AS Date), CAST(N'22:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11925, N'31', CAST(N'2022-05-19' AS Date), CAST(N'22:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11926, N'87', CAST(N'2022-05-19' AS Date), CAST(N'22:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11927, N'32', CAST(N'2022-05-19' AS Date), CAST(N'22:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11928, N'27', CAST(N'2022-05-19' AS Date), CAST(N'22:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11929, N'90', CAST(N'2022-05-19' AS Date), CAST(N'23:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11930, N'82', CAST(N'2022-05-20' AS Date), CAST(N'07:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11931, N'73', CAST(N'2022-05-20' AS Date), CAST(N'07:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11932, N'47', CAST(N'2022-05-20' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11933, N'52', CAST(N'2022-05-20' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11934, N'8', CAST(N'2022-05-20' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11935, N'23', CAST(N'2022-05-20' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11936, N'92', CAST(N'2022-05-20' AS Date), CAST(N'07:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11937, N'85', CAST(N'2022-05-20' AS Date), CAST(N'08:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11938, N'50', CAST(N'2022-05-20' AS Date), CAST(N'08:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11939, N'75', CAST(N'2022-05-20' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11940, N'91', CAST(N'2022-05-20' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11941, N'83', CAST(N'2022-05-20' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11942, N'44', CAST(N'2022-05-20' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11943, N'41', CAST(N'2022-05-20' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11944, N'53', CAST(N'2022-05-20' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11945, N'93', CAST(N'2022-05-20' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11946, N'86', CAST(N'2022-05-20' AS Date), CAST(N'08:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11947, N'68', CAST(N'2022-05-20' AS Date), CAST(N'08:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11948, N'51', CAST(N'2022-05-20' AS Date), CAST(N'08:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11949, N'40', CAST(N'2022-05-20' AS Date), CAST(N'08:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11950, N'49', CAST(N'2022-05-20' AS Date), CAST(N'08:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11951, N'58', CAST(N'2022-05-20' AS Date), CAST(N'08:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11952, N'48', CAST(N'2022-05-20' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11953, N'60', CAST(N'2022-05-20' AS Date), CAST(N'08:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11954, N'28', CAST(N'2022-05-20' AS Date), CAST(N'08:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11955, N'62', CAST(N'2022-05-20' AS Date), CAST(N'08:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11956, N'6', CAST(N'2022-05-20' AS Date), CAST(N'09:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11957, N'89', CAST(N'2022-05-20' AS Date), CAST(N'09:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11958, N'66', CAST(N'2022-05-20' AS Date), CAST(N'09:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11959, N'69', CAST(N'2022-05-20' AS Date), CAST(N'09:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11960, N'65', CAST(N'2022-05-20' AS Date), CAST(N'09:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11961, N'76', CAST(N'2022-05-20' AS Date), CAST(N'09:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11962, N'14', CAST(N'2022-05-20' AS Date), CAST(N'09:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11963, N'81', CAST(N'2022-05-20' AS Date), CAST(N'09:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11964, N'64', CAST(N'2022-05-20' AS Date), CAST(N'09:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11965, N'20', CAST(N'2022-05-20' AS Date), CAST(N'09:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11966, N'27', CAST(N'2022-05-20' AS Date), CAST(N'10:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11967, N'15', CAST(N'2022-05-20' AS Date), CAST(N'10:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11968, N'63', CAST(N'2022-05-20' AS Date), CAST(N'10:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11969, N'21', CAST(N'2022-05-20' AS Date), CAST(N'10:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11970, N'24', CAST(N'2022-05-20' AS Date), CAST(N'10:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11971, N'29', CAST(N'2022-05-20' AS Date), CAST(N'10:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11972, N'12', CAST(N'2022-05-20' AS Date), CAST(N'10:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11973, N'26', CAST(N'2022-05-20' AS Date), CAST(N'10:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11974, N'16', CAST(N'2022-05-20' AS Date), CAST(N'10:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11975, N'13', CAST(N'2022-05-20' AS Date), CAST(N'10:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11976, N'38', CAST(N'2022-05-20' AS Date), CAST(N'11:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11977, N'71', CAST(N'2022-05-20' AS Date), CAST(N'11:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11978, N'2', CAST(N'2022-05-20' AS Date), CAST(N'11:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11979, N'74', CAST(N'2022-05-20' AS Date), CAST(N'13:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11980, N'42', CAST(N'2022-05-20' AS Date), CAST(N'13:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11981, N'45', CAST(N'2022-05-20' AS Date), CAST(N'13:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11982, N'44', CAST(N'2022-05-20' AS Date), CAST(N'13:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11983, N'43', CAST(N'2022-05-20' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11984, N'3', CAST(N'2022-05-20' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11985, N'41', CAST(N'2022-05-20' AS Date), CAST(N'14:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11986, N'88', CAST(N'2022-05-20' AS Date), CAST(N'14:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11987, N'78', CAST(N'2022-05-20' AS Date), CAST(N'14:06:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11988, N'40', CAST(N'2022-05-20' AS Date), CAST(N'14:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11989, N'9', CAST(N'2022-05-20' AS Date), CAST(N'14:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11990, N'35', CAST(N'2022-05-20' AS Date), CAST(N'14:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11991, N'18', CAST(N'2022-05-20' AS Date), CAST(N'14:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11992, N'77', CAST(N'2022-05-20' AS Date), CAST(N'14:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11993, N'53', CAST(N'2022-05-20' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11994, N'92', CAST(N'2022-05-20' AS Date), CAST(N'14:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11995, N'6', CAST(N'2022-05-20' AS Date), CAST(N'14:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11996, N'37', CAST(N'2022-05-20' AS Date), CAST(N'14:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11997, N'60', CAST(N'2022-05-20' AS Date), CAST(N'14:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11998, N'58', CAST(N'2022-05-20' AS Date), CAST(N'14:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (11999, N'72', CAST(N'2022-05-20' AS Date), CAST(N'14:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12000, N'34', CAST(N'2022-05-20' AS Date), CAST(N'14:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12001, N'55', CAST(N'2022-05-20' AS Date), CAST(N'14:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12002, N'23', CAST(N'2022-05-20' AS Date), CAST(N'14:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12003, N'87', CAST(N'2022-05-20' AS Date), CAST(N'14:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12004, N'16', CAST(N'2022-05-20' AS Date), CAST(N'14:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12005, N'33', CAST(N'2022-05-20' AS Date), CAST(N'15:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12006, N'31', CAST(N'2022-05-20' AS Date), CAST(N'15:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12007, N'57', CAST(N'2022-05-20' AS Date), CAST(N'15:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12008, N'32', CAST(N'2022-05-20' AS Date), CAST(N'16:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12009, N'39', CAST(N'2022-05-20' AS Date), CAST(N'16:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12010, N'90', CAST(N'2022-05-20' AS Date), CAST(N'17:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12011, N'38', CAST(N'2022-05-20' AS Date), CAST(N'17:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12012, N'89', CAST(N'2022-05-20' AS Date), CAST(N'17:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12013, N'24', CAST(N'2022-05-20' AS Date), CAST(N'17:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12014, N'71', CAST(N'2022-05-20' AS Date), CAST(N'17:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12015, N'12', CAST(N'2022-05-20' AS Date), CAST(N'17:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12016, N'15', CAST(N'2022-05-20' AS Date), CAST(N'18:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12017, N'2', CAST(N'2022-05-20' AS Date), CAST(N'19:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12018, N'11', CAST(N'2022-05-20' AS Date), CAST(N'19:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12019, N'50', CAST(N'2022-05-20' AS Date), CAST(N'19:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12020, N'52', CAST(N'2022-05-20' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12021, N'75', CAST(N'2022-05-20' AS Date), CAST(N'19:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12022, N'57', CAST(N'2022-05-20' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12023, N'74', CAST(N'2022-05-20' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12024, N'70', CAST(N'2022-05-20' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12025, N'91', CAST(N'2022-05-20' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12026, N'83', CAST(N'2022-05-20' AS Date), CAST(N'20:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12027, N'82', CAST(N'2022-05-20' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12028, N'9', CAST(N'2022-05-20' AS Date), CAST(N'20:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12029, N'77', CAST(N'2022-05-20' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12030, N'49', CAST(N'2022-05-20' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12031, N'61', CAST(N'2022-05-20' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12032, N'26', CAST(N'2022-05-20' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12033, N'85', CAST(N'2022-05-20' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12034, N'7', CAST(N'2022-05-20' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12035, N'48', CAST(N'2022-05-20' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12036, N'3', CAST(N'2022-05-20' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12037, N'37', CAST(N'2022-05-20' AS Date), CAST(N'20:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12038, N'93', CAST(N'2022-05-20' AS Date), CAST(N'20:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12039, N'43', CAST(N'2022-05-20' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12040, N'51', CAST(N'2022-05-20' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12041, N'78', CAST(N'2022-05-20' AS Date), CAST(N'20:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12042, N'73', CAST(N'2022-05-20' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12043, N'42', CAST(N'2022-05-20' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12044, N'45', CAST(N'2022-05-20' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12045, N'46', CAST(N'2022-05-20' AS Date), CAST(N'20:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12046, N'88', CAST(N'2022-05-20' AS Date), CAST(N'20:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12047, N'76', CAST(N'2022-05-20' AS Date), CAST(N'20:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12048, N'21', CAST(N'2022-05-20' AS Date), CAST(N'20:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12049, N'20', CAST(N'2022-05-20' AS Date), CAST(N'20:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12050, N'29', CAST(N'2022-05-20' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12051, N'34', CAST(N'2022-05-20' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12052, N'31', CAST(N'2022-05-20' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12053, N'62', CAST(N'2022-05-20' AS Date), CAST(N'20:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12054, N'69', CAST(N'2022-05-20' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12055, N'28', CAST(N'2022-05-20' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12056, N'65', CAST(N'2022-05-20' AS Date), CAST(N'21:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12057, N'35', CAST(N'2022-05-20' AS Date), CAST(N'21:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12058, N'55', CAST(N'2022-05-20' AS Date), CAST(N'21:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12059, N'33', CAST(N'2022-05-20' AS Date), CAST(N'21:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12060, N'72', CAST(N'2022-05-20' AS Date), CAST(N'21:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12061, N'64', CAST(N'2022-05-20' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12062, N'81', CAST(N'2022-05-20' AS Date), CAST(N'21:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12063, N'18', CAST(N'2022-05-20' AS Date), CAST(N'21:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12064, N'32', CAST(N'2022-05-20' AS Date), CAST(N'21:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12065, N'87', CAST(N'2022-05-20' AS Date), CAST(N'21:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12066, N'13', CAST(N'2022-05-20' AS Date), CAST(N'22:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12067, N'27', CAST(N'2022-05-20' AS Date), CAST(N'22:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12068, N'90', CAST(N'2022-05-20' AS Date), CAST(N'23:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12069, N'68', CAST(N'2022-05-20' AS Date), CAST(N'23:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12070, N'59', CAST(N'2022-05-21' AS Date), CAST(N'07:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12071, N'82', CAST(N'2022-05-21' AS Date), CAST(N'07:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12072, N'83', CAST(N'2022-05-21' AS Date), CAST(N'07:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12073, N'92', CAST(N'2022-05-21' AS Date), CAST(N'07:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12074, N'52', CAST(N'2022-05-21' AS Date), CAST(N'07:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12075, N'44', CAST(N'2022-05-21' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12076, N'53', CAST(N'2022-05-21' AS Date), CAST(N'08:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12077, N'73', CAST(N'2022-05-21' AS Date), CAST(N'08:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12078, N'23', CAST(N'2022-05-21' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12079, N'58', CAST(N'2022-05-21' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12080, N'67', CAST(N'2022-05-21' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12081, N'68', CAST(N'2022-05-21' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12082, N'47', CAST(N'2022-05-21' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12083, N'93', CAST(N'2022-05-21' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12084, N'51', CAST(N'2022-05-21' AS Date), CAST(N'08:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12085, N'11', CAST(N'2022-05-21' AS Date), CAST(N'08:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12086, N'60', CAST(N'2022-05-21' AS Date), CAST(N'08:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12087, N'27', CAST(N'2022-05-21' AS Date), CAST(N'08:18:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12088, N'48', CAST(N'2022-05-21' AS Date), CAST(N'08:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12089, N'50', CAST(N'2022-05-21' AS Date), CAST(N'08:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12090, N'85', CAST(N'2022-05-21' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12091, N'91', CAST(N'2022-05-21' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12092, N'49', CAST(N'2022-05-21' AS Date), CAST(N'08:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12093, N'7', CAST(N'2022-05-21' AS Date), CAST(N'08:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12094, N'40', CAST(N'2022-05-21' AS Date), CAST(N'08:38:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12095, N'41', CAST(N'2022-05-21' AS Date), CAST(N'08:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12096, N'89', CAST(N'2022-05-21' AS Date), CAST(N'08:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12097, N'86', CAST(N'2022-05-21' AS Date), CAST(N'08:40:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12098, N'21', CAST(N'2022-05-21' AS Date), CAST(N'08:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12099, N'65', CAST(N'2022-05-21' AS Date), CAST(N'08:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12100, N'81', CAST(N'2022-05-21' AS Date), CAST(N'08:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12101, N'62', CAST(N'2022-05-21' AS Date), CAST(N'08:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12102, N'64', CAST(N'2022-05-21' AS Date), CAST(N'09:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12103, N'28', CAST(N'2022-05-21' AS Date), CAST(N'09:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12104, N'76', CAST(N'2022-05-21' AS Date), CAST(N'09:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12105, N'69', CAST(N'2022-05-21' AS Date), CAST(N'09:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12106, N'14', CAST(N'2022-05-21' AS Date), CAST(N'09:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12107, N'6', CAST(N'2022-05-21' AS Date), CAST(N'09:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12108, N'20', CAST(N'2022-05-21' AS Date), CAST(N'09:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12109, N'24', CAST(N'2022-05-21' AS Date), CAST(N'10:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12110, N'13', CAST(N'2022-05-21' AS Date), CAST(N'10:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12111, N'29', CAST(N'2022-05-21' AS Date), CAST(N'10:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12112, N'15', CAST(N'2022-05-21' AS Date), CAST(N'10:30:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12113, N'12', CAST(N'2022-05-21' AS Date), CAST(N'10:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12114, N'16', CAST(N'2022-05-21' AS Date), CAST(N'10:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12115, N'71', CAST(N'2022-05-21' AS Date), CAST(N'11:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12116, N'26', CAST(N'2022-05-21' AS Date), CAST(N'11:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12117, N'2', CAST(N'2022-05-21' AS Date), CAST(N'11:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12118, N'55', CAST(N'2022-05-21' AS Date), CAST(N'12:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12119, N'74', CAST(N'2022-05-21' AS Date), CAST(N'13:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12120, N'78', CAST(N'2022-05-21' AS Date), CAST(N'13:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12121, N'44', CAST(N'2022-05-21' AS Date), CAST(N'13:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12122, N'67', CAST(N'2022-05-21' AS Date), CAST(N'13:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12123, N'60', CAST(N'2022-05-21' AS Date), CAST(N'13:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12124, N'35', CAST(N'2022-05-21' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12125, N'45', CAST(N'2022-05-21' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12126, N'72', CAST(N'2022-05-21' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12127, N'3', CAST(N'2022-05-21' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12128, N'43', CAST(N'2022-05-21' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12129, N'46', CAST(N'2022-05-21' AS Date), CAST(N'14:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12130, N'88', CAST(N'2022-05-21' AS Date), CAST(N'14:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12131, N'40', CAST(N'2022-05-21' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12132, N'58', CAST(N'2022-05-21' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12133, N'9', CAST(N'2022-05-21' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12134, N'92', CAST(N'2022-05-21' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12135, N'53', CAST(N'2022-05-21' AS Date), CAST(N'14:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12136, N'6', CAST(N'2022-05-21' AS Date), CAST(N'14:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12137, N'32', CAST(N'2022-05-21' AS Date), CAST(N'14:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12138, N'37', CAST(N'2022-05-21' AS Date), CAST(N'14:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12139, N'51', CAST(N'2022-05-21' AS Date), CAST(N'14:36:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12140, N'22', CAST(N'2022-05-21' AS Date), CAST(N'14:43:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12141, N'23', CAST(N'2022-05-21' AS Date), CAST(N'14:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12142, N'41', CAST(N'2022-05-21' AS Date), CAST(N'14:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12143, N'34', CAST(N'2022-05-21' AS Date), CAST(N'15:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12144, N'33', CAST(N'2022-05-21' AS Date), CAST(N'15:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12145, N'87', CAST(N'2022-05-21' AS Date), CAST(N'15:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12146, N'31', CAST(N'2022-05-21' AS Date), CAST(N'15:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12147, N'18', CAST(N'2022-05-21' AS Date), CAST(N'15:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12148, N'57', CAST(N'2022-05-21' AS Date), CAST(N'15:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12149, N'16', CAST(N'2022-05-21' AS Date), CAST(N'16:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12150, N'39', CAST(N'2022-05-21' AS Date), CAST(N'16:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12151, N'12', CAST(N'2022-05-21' AS Date), CAST(N'17:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12152, N'89', CAST(N'2022-05-21' AS Date), CAST(N'17:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12153, N'24', CAST(N'2022-05-21' AS Date), CAST(N'17:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12154, N'71', CAST(N'2022-05-21' AS Date), CAST(N'17:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12155, N'68', CAST(N'2022-05-21' AS Date), CAST(N'19:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12156, N'8', CAST(N'2022-05-21' AS Date), CAST(N'19:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12157, N'2', CAST(N'2022-05-21' AS Date), CAST(N'19:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12158, N'82', CAST(N'2022-05-21' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12159, N'83', CAST(N'2022-05-21' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12160, N'26', CAST(N'2022-05-21' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12161, N'91', CAST(N'2022-05-21' AS Date), CAST(N'19:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12162, N'3', CAST(N'2022-05-21' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12163, N'75', CAST(N'2022-05-21' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12164, N'66', CAST(N'2022-05-21' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12165, N'9', CAST(N'2022-05-21' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12166, N'15', CAST(N'2022-05-21' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12167, N'50', CAST(N'2022-05-21' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12168, N'49', CAST(N'2022-05-21' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12169, N'70', CAST(N'2022-05-21' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12170, N'37', CAST(N'2022-05-21' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12171, N'59', CAST(N'2022-05-21' AS Date), CAST(N'20:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12172, N'48', CAST(N'2022-05-21' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12173, N'47', CAST(N'2022-05-21' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12174, N'74', CAST(N'2022-05-21' AS Date), CAST(N'20:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12175, N'45', CAST(N'2022-05-21' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12176, N'85', CAST(N'2022-05-21' AS Date), CAST(N'20:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12177, N'78', CAST(N'2022-05-21' AS Date), CAST(N'20:29:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12178, N'43', CAST(N'2022-05-21' AS Date), CAST(N'20:35:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12179, N'76', CAST(N'2022-05-21' AS Date), CAST(N'20:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12180, N'21', CAST(N'2022-05-21' AS Date), CAST(N'20:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12181, N'73', CAST(N'2022-05-21' AS Date), CAST(N'20:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12182, N'29', CAST(N'2022-05-21' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12183, N'28', CAST(N'2022-05-21' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12184, N'69', CAST(N'2022-05-21' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12185, N'55', CAST(N'2022-05-21' AS Date), CAST(N'21:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12186, N'64', CAST(N'2022-05-21' AS Date), CAST(N'21:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12187, N'81', CAST(N'2022-05-21' AS Date), CAST(N'21:11:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12188, N'72', CAST(N'2022-05-21' AS Date), CAST(N'21:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12189, N'65', CAST(N'2022-05-21' AS Date), CAST(N'21:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12190, N'20', CAST(N'2022-05-21' AS Date), CAST(N'21:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12191, N'14', CAST(N'2022-05-21' AS Date), CAST(N'21:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12192, N'18', CAST(N'2022-05-21' AS Date), CAST(N'21:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12193, N'93', CAST(N'2022-05-21' AS Date), CAST(N'21:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12194, N'34', CAST(N'2022-05-21' AS Date), CAST(N'22:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12195, N'13', CAST(N'2022-05-21' AS Date), CAST(N'22:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12196, N'35', CAST(N'2022-05-21' AS Date), CAST(N'22:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12197, N'31', CAST(N'2022-05-21' AS Date), CAST(N'22:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12198, N'88', CAST(N'2022-05-21' AS Date), CAST(N'22:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12199, N'33', CAST(N'2022-05-21' AS Date), CAST(N'22:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12200, N'87', CAST(N'2022-05-21' AS Date), CAST(N'22:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12201, N'27', CAST(N'2022-05-21' AS Date), CAST(N'22:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12202, N'32', CAST(N'2022-05-21' AS Date), CAST(N'23:40:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12203, N'82', CAST(N'2022-05-22' AS Date), CAST(N'07:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12204, N'47', CAST(N'2022-05-22' AS Date), CAST(N'07:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12205, N'42', CAST(N'2022-05-22' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12206, N'85', CAST(N'2022-05-22' AS Date), CAST(N'08:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12207, N'50', CAST(N'2022-05-22' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12208, N'86', CAST(N'2022-05-22' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12209, N'48', CAST(N'2022-05-22' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12210, N'11', CAST(N'2022-05-22' AS Date), CAST(N'08:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12211, N'81', CAST(N'2022-05-22' AS Date), CAST(N'08:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12212, N'78', CAST(N'2022-05-22' AS Date), CAST(N'08:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12213, N'8', CAST(N'2022-05-22' AS Date), CAST(N'08:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12214, N'75', CAST(N'2022-05-22' AS Date), CAST(N'08:35:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12215, N'60', CAST(N'2022-05-22' AS Date), CAST(N'08:35:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12216, N'91', CAST(N'2022-05-22' AS Date), CAST(N'08:36:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12217, N'27', CAST(N'2022-05-22' AS Date), CAST(N'08:37:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12218, N'69', CAST(N'2022-05-22' AS Date), CAST(N'08:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12219, N'65', CAST(N'2022-05-22' AS Date), CAST(N'09:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12220, N'21', CAST(N'2022-05-22' AS Date), CAST(N'09:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12221, N'76', CAST(N'2022-05-22' AS Date), CAST(N'09:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12222, N'38', CAST(N'2022-05-22' AS Date), CAST(N'10:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12223, N'43', CAST(N'2022-05-22' AS Date), CAST(N'13:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12224, N'45', CAST(N'2022-05-22' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12225, N'49', CAST(N'2022-05-22' AS Date), CAST(N'13:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12226, N'40', CAST(N'2022-05-22' AS Date), CAST(N'14:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12227, N'52', CAST(N'2022-05-22' AS Date), CAST(N'19:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12228, N'50', CAST(N'2022-05-22' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12229, N'11', CAST(N'2022-05-22' AS Date), CAST(N'20:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12230, N'91', CAST(N'2022-05-22' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12231, N'11', CAST(N'2022-05-22' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12232, N'11', CAST(N'2022-05-22' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12233, N'81', CAST(N'2022-05-22' AS Date), CAST(N'20:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12234, N'85', CAST(N'2022-05-22' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12235, N'11', CAST(N'2022-05-22' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12236, N'66', CAST(N'2022-05-22' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12237, N'7', CAST(N'2022-05-22' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12238, N'49', CAST(N'2022-05-22' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12239, N'75', CAST(N'2022-05-22' AS Date), CAST(N'20:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12240, N'47', CAST(N'2022-05-22' AS Date), CAST(N'20:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12241, N'42', CAST(N'2022-05-22' AS Date), CAST(N'20:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12242, N'45', CAST(N'2022-05-22' AS Date), CAST(N'20:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12243, N'82', CAST(N'2022-05-22' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12244, N'86', CAST(N'2022-05-22' AS Date), CAST(N'20:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12245, N'78', CAST(N'2022-05-22' AS Date), CAST(N'20:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12246, N'43', CAST(N'2022-05-22' AS Date), CAST(N'20:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12247, N'21', CAST(N'2022-05-22' AS Date), CAST(N'20:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12248, N'69', CAST(N'2022-05-22' AS Date), CAST(N'21:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12249, N'65', CAST(N'2022-05-22' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12250, N'38', CAST(N'2022-05-22' AS Date), CAST(N'21:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12251, N'39', CAST(N'2022-05-22' AS Date), CAST(N'21:29:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12252, N'27', CAST(N'2022-05-22' AS Date), CAST(N'22:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12253, N'82', CAST(N'2022-05-23' AS Date), CAST(N'07:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12254, N'59', CAST(N'2022-05-23' AS Date), CAST(N'07:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12255, N'44', CAST(N'2022-05-23' AS Date), CAST(N'07:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12256, N'52', CAST(N'2022-05-23' AS Date), CAST(N'07:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12257, N'23', CAST(N'2022-05-23' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12258, N'83', CAST(N'2022-05-23' AS Date), CAST(N'07:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12259, N'50', CAST(N'2022-05-23' AS Date), CAST(N'07:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12260, N'66', CAST(N'2022-05-23' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12261, N'60', CAST(N'2022-05-23' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12262, N'58', CAST(N'2022-05-23' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12263, N'41', CAST(N'2022-05-23' AS Date), CAST(N'08:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12264, N'53', CAST(N'2022-05-23' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12265, N'67', CAST(N'2022-05-23' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12266, N'7', CAST(N'2022-05-23' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12267, N'91', CAST(N'2022-05-23' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12268, N'68', CAST(N'2022-05-23' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12269, N'51', CAST(N'2022-05-23' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12270, N'47', CAST(N'2022-05-23' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12271, N'85', CAST(N'2022-05-23' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12272, N'75', CAST(N'2022-05-23' AS Date), CAST(N'08:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12273, N'49', CAST(N'2022-05-23' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12274, N'27', CAST(N'2022-05-23' AS Date), CAST(N'08:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12275, N'11', CAST(N'2022-05-23' AS Date), CAST(N'08:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12276, N'92', CAST(N'2022-05-23' AS Date), CAST(N'08:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12277, N'86', CAST(N'2022-05-23' AS Date), CAST(N'08:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12278, N'65', CAST(N'2022-05-23' AS Date), CAST(N'08:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12279, N'28', CAST(N'2022-05-23' AS Date), CAST(N'08:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12280, N'56', CAST(N'2022-05-23' AS Date), CAST(N'08:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12281, N'81', CAST(N'2022-05-23' AS Date), CAST(N'09:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12282, N'64', CAST(N'2022-05-23' AS Date), CAST(N'09:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12283, N'20', CAST(N'2022-05-23' AS Date), CAST(N'09:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12284, N'69', CAST(N'2022-05-23' AS Date), CAST(N'09:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12285, N'21', CAST(N'2022-05-23' AS Date), CAST(N'09:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12286, N'14', CAST(N'2022-05-23' AS Date), CAST(N'09:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12287, N'6', CAST(N'2022-05-23' AS Date), CAST(N'09:38:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12288, N'24', CAST(N'2022-05-23' AS Date), CAST(N'10:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12289, N'29', CAST(N'2022-05-23' AS Date), CAST(N'10:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12290, N'13', CAST(N'2022-05-23' AS Date), CAST(N'10:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12291, N'15', CAST(N'2022-05-23' AS Date), CAST(N'10:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12292, N'63', CAST(N'2022-05-23' AS Date), CAST(N'10:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12293, N'71', CAST(N'2022-05-23' AS Date), CAST(N'11:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12294, N'12', CAST(N'2022-05-23' AS Date), CAST(N'11:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12295, N'26', CAST(N'2022-05-23' AS Date), CAST(N'11:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12296, N'26', CAST(N'2022-05-23' AS Date), CAST(N'11:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12297, N'16', CAST(N'2022-05-23' AS Date), CAST(N'11:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12298, N'40', CAST(N'2022-05-23' AS Date), CAST(N'13:30:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12299, N'88', CAST(N'2022-05-23' AS Date), CAST(N'13:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12300, N'47', CAST(N'2022-05-23' AS Date), CAST(N'13:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12301, N'92', CAST(N'2022-05-23' AS Date), CAST(N'13:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12302, N'78', CAST(N'2022-05-23' AS Date), CAST(N'13:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12303, N'42', CAST(N'2022-05-23' AS Date), CAST(N'13:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12304, N'45', CAST(N'2022-05-23' AS Date), CAST(N'13:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12305, N'77', CAST(N'2022-05-23' AS Date), CAST(N'13:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12306, N'67', CAST(N'2022-05-23' AS Date), CAST(N'13:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12307, N'44', CAST(N'2022-05-23' AS Date), CAST(N'13:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12308, N'3', CAST(N'2022-05-23' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12309, N'41', CAST(N'2022-05-23' AS Date), CAST(N'14:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12310, N'46', CAST(N'2022-05-23' AS Date), CAST(N'14:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12311, N'58', CAST(N'2022-05-23' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12312, N'9', CAST(N'2022-05-23' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12313, N'53', CAST(N'2022-05-23' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12314, N'6', CAST(N'2022-05-23' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12315, N'80', CAST(N'2022-05-23' AS Date), CAST(N'14:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12316, N'37', CAST(N'2022-05-23' AS Date), CAST(N'14:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12317, N'22', CAST(N'2022-05-23' AS Date), CAST(N'14:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12318, N'72', CAST(N'2022-05-23' AS Date), CAST(N'14:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12319, N'34', CAST(N'2022-05-23' AS Date), CAST(N'14:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12320, N'32', CAST(N'2022-05-23' AS Date), CAST(N'14:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12321, N'55', CAST(N'2022-05-23' AS Date), CAST(N'14:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12322, N'56', CAST(N'2022-05-23' AS Date), CAST(N'14:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12323, N'18', CAST(N'2022-05-23' AS Date), CAST(N'14:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12324, N'23', CAST(N'2022-05-23' AS Date), CAST(N'14:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12325, N'33', CAST(N'2022-05-23' AS Date), CAST(N'15:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12326, N'31', CAST(N'2022-05-23' AS Date), CAST(N'15:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12327, N'57', CAST(N'2022-05-23' AS Date), CAST(N'15:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12328, N'87', CAST(N'2022-05-23' AS Date), CAST(N'15:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12329, N'16', CAST(N'2022-05-23' AS Date), CAST(N'15:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12330, N'39', CAST(N'2022-05-23' AS Date), CAST(N'16:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12331, N'60', CAST(N'2022-05-23' AS Date), CAST(N'16:30:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12332, N'24', CAST(N'2022-05-23' AS Date), CAST(N'17:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12333, N'71', CAST(N'2022-05-23' AS Date), CAST(N'17:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12334, N'12', CAST(N'2022-05-23' AS Date), CAST(N'19:39:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12335, N'8', CAST(N'2022-05-23' AS Date), CAST(N'19:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12336, N'82', CAST(N'2022-05-23' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12337, N'86', CAST(N'2022-05-23' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12338, N'83', CAST(N'2022-05-23' AS Date), CAST(N'19:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12339, N'26', CAST(N'2022-05-23' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12340, N'76', CAST(N'2022-05-23' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12341, N'3', CAST(N'2022-05-23' AS Date), CAST(N'19:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12342, N'70', CAST(N'2022-05-23' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12343, N'91', CAST(N'2022-05-23' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12344, N'51', CAST(N'2022-05-23' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12345, N'75', CAST(N'2022-05-23' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12346, N'57', CAST(N'2022-05-23' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12347, N'9', CAST(N'2022-05-23' AS Date), CAST(N'20:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12348, N'49', CAST(N'2022-05-23' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12349, N'52', CAST(N'2022-05-23' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12350, N'80', CAST(N'2022-05-23' AS Date), CAST(N'20:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12351, N'51', CAST(N'2022-05-23' AS Date), CAST(N'20:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12352, N'59', CAST(N'2022-05-23' AS Date), CAST(N'20:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12353, N'78', CAST(N'2022-05-23' AS Date), CAST(N'20:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12354, N'85', CAST(N'2022-05-23' AS Date), CAST(N'20:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12355, N'73', CAST(N'2022-05-23' AS Date), CAST(N'20:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12356, N'79', CAST(N'2022-05-23' AS Date), CAST(N'20:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12357, N'42', CAST(N'2022-05-23' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12358, N'45', CAST(N'2022-05-23' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12359, N'46', CAST(N'2022-05-23' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12360, N'37', CAST(N'2022-05-23' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12361, N'15', CAST(N'2022-05-23' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12362, N'88', CAST(N'2022-05-23' AS Date), CAST(N'20:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12363, N'62', CAST(N'2022-05-23' AS Date), CAST(N'20:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12364, N'21', CAST(N'2022-05-23' AS Date), CAST(N'20:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12365, N'29', CAST(N'2022-05-23' AS Date), CAST(N'20:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12366, N'69', CAST(N'2022-05-23' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12367, N'55', CAST(N'2022-05-23' AS Date), CAST(N'21:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12368, N'28', CAST(N'2022-05-23' AS Date), CAST(N'21:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12369, N'72', CAST(N'2022-05-23' AS Date), CAST(N'21:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12370, N'20', CAST(N'2022-05-23' AS Date), CAST(N'21:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12371, N'65', CAST(N'2022-05-23' AS Date), CAST(N'21:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12372, N'14', CAST(N'2022-05-23' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12373, N'18', CAST(N'2022-05-23' AS Date), CAST(N'21:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12374, N'64', CAST(N'2022-05-23' AS Date), CAST(N'21:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12375, N'81', CAST(N'2022-05-23' AS Date), CAST(N'21:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12376, N'22', CAST(N'2022-05-23' AS Date), CAST(N'21:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12377, N'13', CAST(N'2022-05-23' AS Date), CAST(N'22:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12378, N'34', CAST(N'2022-05-23' AS Date), CAST(N'22:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12379, N'31', CAST(N'2022-05-23' AS Date), CAST(N'22:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12380, N'35', CAST(N'2022-05-23' AS Date), CAST(N'22:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12381, N'32', CAST(N'2022-05-23' AS Date), CAST(N'22:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12382, N'33', CAST(N'2022-05-23' AS Date), CAST(N'22:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12383, N'87', CAST(N'2022-05-23' AS Date), CAST(N'22:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12384, N'27', CAST(N'2022-05-23' AS Date), CAST(N'22:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12385, N'68', CAST(N'2022-05-23' AS Date), CAST(N'23:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12386, N'59', CAST(N'2022-05-24' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12387, N'44', CAST(N'2022-05-24' AS Date), CAST(N'07:58:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12388, N'73', CAST(N'2022-05-24' AS Date), CAST(N'08:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12389, N'52', CAST(N'2022-05-24' AS Date), CAST(N'08:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12390, N'27', CAST(N'2022-05-24' AS Date), CAST(N'08:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12391, N'67', CAST(N'2022-05-24' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12392, N'83', CAST(N'2022-05-24' AS Date), CAST(N'08:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12393, N'58', CAST(N'2022-05-24' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12394, N'53', CAST(N'2022-05-24' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12395, N'51', CAST(N'2022-05-24' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12396, N'41', CAST(N'2022-05-24' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12397, N'8', CAST(N'2022-05-24' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12398, N'85', CAST(N'2022-05-24' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12399, N'60', CAST(N'2022-05-24' AS Date), CAST(N'08:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12400, N'91', CAST(N'2022-05-24' AS Date), CAST(N'08:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12401, N'47', CAST(N'2022-05-24' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12402, N'68', CAST(N'2022-05-24' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12403, N'75', CAST(N'2022-05-24' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12404, N'40', CAST(N'2022-05-24' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12405, N'49', CAST(N'2022-05-24' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12406, N'80', CAST(N'2022-05-24' AS Date), CAST(N'08:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12407, N'86', CAST(N'2022-05-24' AS Date), CAST(N'08:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12408, N'89', CAST(N'2022-05-24' AS Date), CAST(N'08:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12409, N'65', CAST(N'2022-05-24' AS Date), CAST(N'08:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12410, N'21', CAST(N'2022-05-24' AS Date), CAST(N'08:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12411, N'76', CAST(N'2022-05-24' AS Date), CAST(N'08:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12412, N'28', CAST(N'2022-05-24' AS Date), CAST(N'09:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12413, N'20', CAST(N'2022-05-24' AS Date), CAST(N'09:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12414, N'14', CAST(N'2022-05-24' AS Date), CAST(N'09:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12415, N'81', CAST(N'2022-05-24' AS Date), CAST(N'09:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12416, N'64', CAST(N'2022-05-24' AS Date), CAST(N'09:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12417, N'62', CAST(N'2022-05-24' AS Date), CAST(N'09:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12418, N'24', CAST(N'2022-05-24' AS Date), CAST(N'10:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12419, N'29', CAST(N'2022-05-24' AS Date), CAST(N'10:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12420, N'63', CAST(N'2022-05-24' AS Date), CAST(N'10:40:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12421, N'38', CAST(N'2022-05-24' AS Date), CAST(N'10:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12422, N'15', CAST(N'2022-05-24' AS Date), CAST(N'10:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12423, N'12', CAST(N'2022-05-24' AS Date), CAST(N'11:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12424, N'71', CAST(N'2022-05-24' AS Date), CAST(N'11:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12425, N'26', CAST(N'2022-05-24' AS Date), CAST(N'11:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12426, N'16', CAST(N'2022-05-24' AS Date), CAST(N'11:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12427, N'2', CAST(N'2022-05-24' AS Date), CAST(N'11:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12428, N'13', CAST(N'2022-05-24' AS Date), CAST(N'13:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12429, N'74', CAST(N'2022-05-24' AS Date), CAST(N'13:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12430, N'67', CAST(N'2022-05-24' AS Date), CAST(N'13:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12431, N'77', CAST(N'2022-05-24' AS Date), CAST(N'13:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12432, N'78', CAST(N'2022-05-24' AS Date), CAST(N'13:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12433, N'46', CAST(N'2022-05-24' AS Date), CAST(N'13:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12434, N'45', CAST(N'2022-05-24' AS Date), CAST(N'13:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12435, N'42', CAST(N'2022-05-24' AS Date), CAST(N'13:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12436, N'60', CAST(N'2022-05-24' AS Date), CAST(N'13:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12437, N'41', CAST(N'2022-05-24' AS Date), CAST(N'13:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12438, N'43', CAST(N'2022-05-24' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12439, N'3', CAST(N'2022-05-24' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12440, N'40', CAST(N'2022-05-24' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12441, N'58', CAST(N'2022-05-24' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12442, N'79', CAST(N'2022-05-24' AS Date), CAST(N'14:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12443, N'44', CAST(N'2022-05-24' AS Date), CAST(N'14:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12444, N'9', CAST(N'2022-05-24' AS Date), CAST(N'14:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12445, N'47', CAST(N'2022-05-24' AS Date), CAST(N'14:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12446, N'51', CAST(N'2022-05-24' AS Date), CAST(N'14:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12447, N'53', CAST(N'2022-05-24' AS Date), CAST(N'14:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12448, N'73', CAST(N'2022-05-24' AS Date), CAST(N'14:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12449, N'88', CAST(N'2022-05-24' AS Date), CAST(N'14:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12450, N'32', CAST(N'2022-05-24' AS Date), CAST(N'14:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12451, N'35', CAST(N'2022-05-24' AS Date), CAST(N'14:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12452, N'72', CAST(N'2022-05-24' AS Date), CAST(N'14:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12453, N'22', CAST(N'2022-05-24' AS Date), CAST(N'14:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12454, N'34', CAST(N'2022-05-24' AS Date), CAST(N'14:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12455, N'55', CAST(N'2022-05-24' AS Date), CAST(N'14:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12456, N'56', CAST(N'2022-05-24' AS Date), CAST(N'14:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12457, N'33', CAST(N'2022-05-24' AS Date), CAST(N'15:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12458, N'31', CAST(N'2022-05-24' AS Date), CAST(N'15:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12459, N'18', CAST(N'2022-05-24' AS Date), CAST(N'15:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12460, N'87', CAST(N'2022-05-24' AS Date), CAST(N'15:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12461, N'57', CAST(N'2022-05-24' AS Date), CAST(N'15:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12462, N'16', CAST(N'2022-05-24' AS Date), CAST(N'16:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12463, N'39', CAST(N'2022-05-24' AS Date), CAST(N'17:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12464, N'38', CAST(N'2022-05-24' AS Date), CAST(N'17:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12465, N'89', CAST(N'2022-05-24' AS Date), CAST(N'17:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12466, N'24', CAST(N'2022-05-24' AS Date), CAST(N'17:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12467, N'71', CAST(N'2022-05-24' AS Date), CAST(N'17:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12468, N'12', CAST(N'2022-05-24' AS Date), CAST(N'18:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12469, N'82', CAST(N'2022-05-24' AS Date), CAST(N'18:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12470, N'83', CAST(N'2022-05-24' AS Date), CAST(N'18:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12471, N'86', CAST(N'2022-05-24' AS Date), CAST(N'19:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12472, N'15', CAST(N'2022-05-24' AS Date), CAST(N'19:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12473, N'74', CAST(N'2022-05-24' AS Date), CAST(N'19:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12474, N'80', CAST(N'2022-05-24' AS Date), CAST(N'19:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12475, N'76', CAST(N'2022-05-24' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12476, N'68', CAST(N'2022-05-24' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12477, N'11', CAST(N'2022-05-24' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12478, N'91', CAST(N'2022-05-24' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12479, N'70', CAST(N'2022-05-24' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12480, N'50', CAST(N'2022-05-24' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12481, N'57', CAST(N'2022-05-24' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12482, N'9', CAST(N'2022-05-24' AS Date), CAST(N'20:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12483, N'49', CAST(N'2022-05-24' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12484, N'48', CAST(N'2022-05-24' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12485, N'75', CAST(N'2022-05-24' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12486, N'85', CAST(N'2022-05-24' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12487, N'52', CAST(N'2022-05-24' AS Date), CAST(N'20:08:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12488, N'37', CAST(N'2022-05-24' AS Date), CAST(N'20:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12489, N'7', CAST(N'2022-05-24' AS Date), CAST(N'20:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12490, N'59', CAST(N'2022-05-24' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12491, N'42', CAST(N'2022-05-24' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12492, N'45', CAST(N'2022-05-24' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12493, N'46', CAST(N'2022-05-24' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12494, N'79', CAST(N'2022-05-24' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12495, N'78', CAST(N'2022-05-24' AS Date), CAST(N'20:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12496, N'43', CAST(N'2022-05-24' AS Date), CAST(N'20:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12497, N'88', CAST(N'2022-05-24' AS Date), CAST(N'20:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12498, N'66', CAST(N'2022-05-24' AS Date), CAST(N'20:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12499, N'26', CAST(N'2022-05-24' AS Date), CAST(N'20:32:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12500, N'62', CAST(N'2022-05-24' AS Date), CAST(N'20:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12501, N'64', CAST(N'2022-05-24' AS Date), CAST(N'20:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12502, N'20', CAST(N'2022-05-24' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12503, N'55', CAST(N'2022-05-24' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12504, N'72', CAST(N'2022-05-24' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12505, N'29', CAST(N'2022-05-24' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12506, N'28', CAST(N'2022-05-24' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12507, N'18', CAST(N'2022-05-24' AS Date), CAST(N'21:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12508, N'65', CAST(N'2022-05-24' AS Date), CAST(N'21:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12509, N'35', CAST(N'2022-05-24' AS Date), CAST(N'21:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12510, N'14', CAST(N'2022-05-24' AS Date), CAST(N'21:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12511, N'31', CAST(N'2022-05-24' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12512, N'33', CAST(N'2022-05-24' AS Date), CAST(N'21:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12513, N'87', CAST(N'2022-05-24' AS Date), CAST(N'21:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12514, N'22', CAST(N'2022-05-24' AS Date), CAST(N'21:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12515, N'13', CAST(N'2022-05-24' AS Date), CAST(N'22:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12516, N'27', CAST(N'2022-05-24' AS Date), CAST(N'22:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12517, N'83', CAST(N'2022-05-25' AS Date), CAST(N'06:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12518, N'59', CAST(N'2022-05-25' AS Date), CAST(N'07:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12519, N'44', CAST(N'2022-05-25' AS Date), CAST(N'07:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12520, N'92', CAST(N'2022-05-25' AS Date), CAST(N'07:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12521, N'86', CAST(N'2022-05-25' AS Date), CAST(N'07:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12522, N'52', CAST(N'2022-05-25' AS Date), CAST(N'07:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12523, N'53', CAST(N'2022-05-25' AS Date), CAST(N'08:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12524, N'73', CAST(N'2022-05-25' AS Date), CAST(N'08:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12525, N'85', CAST(N'2022-05-25' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12526, N'68', CAST(N'2022-05-25' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12527, N'51', CAST(N'2022-05-25' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12528, N'67', CAST(N'2022-05-25' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12529, N'50', CAST(N'2022-05-25' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12530, N'41', CAST(N'2022-05-25' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12531, N'80', CAST(N'2022-05-25' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12532, N'27', CAST(N'2022-05-25' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12533, N'91', CAST(N'2022-05-25' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12534, N'75', CAST(N'2022-05-25' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12535, N'49', CAST(N'2022-05-25' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12536, N'7', CAST(N'2022-05-25' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12537, N'58', CAST(N'2022-05-25' AS Date), CAST(N'08:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12538, N'11', CAST(N'2022-05-25' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12539, N'47', CAST(N'2022-05-25' AS Date), CAST(N'08:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12540, N'48', CAST(N'2022-05-25' AS Date), CAST(N'08:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12541, N'60', CAST(N'2022-05-25' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12542, N'40', CAST(N'2022-05-25' AS Date), CAST(N'08:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12543, N'65', CAST(N'2022-05-25' AS Date), CAST(N'08:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12544, N'28', CAST(N'2022-05-25' AS Date), CAST(N'08:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12545, N'62', CAST(N'2022-05-25' AS Date), CAST(N'08:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12546, N'69', CAST(N'2022-05-25' AS Date), CAST(N'08:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12547, N'76', CAST(N'2022-05-25' AS Date), CAST(N'09:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12548, N'56', CAST(N'2022-05-25' AS Date), CAST(N'09:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12549, N'89', CAST(N'2022-05-25' AS Date), CAST(N'09:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12550, N'66', CAST(N'2022-05-25' AS Date), CAST(N'09:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12551, N'81', CAST(N'2022-05-25' AS Date), CAST(N'09:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12552, N'64', CAST(N'2022-05-25' AS Date), CAST(N'09:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12553, N'14', CAST(N'2022-05-25' AS Date), CAST(N'09:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12554, N'20', CAST(N'2022-05-25' AS Date), CAST(N'09:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12555, N'24', CAST(N'2022-05-25' AS Date), CAST(N'09:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12556, N'29', CAST(N'2022-05-25' AS Date), CAST(N'10:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12557, N'15', CAST(N'2022-05-25' AS Date), CAST(N'10:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12558, N'13', CAST(N'2022-05-25' AS Date), CAST(N'10:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12559, N'63', CAST(N'2022-05-25' AS Date), CAST(N'10:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12560, N'12', CAST(N'2022-05-25' AS Date), CAST(N'10:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12561, N'38', CAST(N'2022-05-25' AS Date), CAST(N'10:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12562, N'71', CAST(N'2022-05-25' AS Date), CAST(N'11:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12563, N'26', CAST(N'2022-05-25' AS Date), CAST(N'11:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12564, N'16', CAST(N'2022-05-25' AS Date), CAST(N'11:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12565, N'88', CAST(N'2022-05-25' AS Date), CAST(N'12:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12566, N'74', CAST(N'2022-05-25' AS Date), CAST(N'13:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12567, N'78', CAST(N'2022-05-25' AS Date), CAST(N'13:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12568, N'41', CAST(N'2022-05-25' AS Date), CAST(N'13:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12569, N'67', CAST(N'2022-05-25' AS Date), CAST(N'13:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12570, N'45', CAST(N'2022-05-25' AS Date), CAST(N'13:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12571, N'42', CAST(N'2022-05-25' AS Date), CAST(N'13:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12572, N'44', CAST(N'2022-05-25' AS Date), CAST(N'13:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12573, N'3', CAST(N'2022-05-25' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12574, N'40', CAST(N'2022-05-25' AS Date), CAST(N'14:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12575, N'9', CAST(N'2022-05-25' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12576, N'92', CAST(N'2022-05-25' AS Date), CAST(N'14:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12577, N'43', CAST(N'2022-05-25' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12578, N'53', CAST(N'2022-05-25' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12579, N'79', CAST(N'2022-05-25' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12580, N'37', CAST(N'2022-05-25' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12581, N'47', CAST(N'2022-05-25' AS Date), CAST(N'14:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12582, N'60', CAST(N'2022-05-25' AS Date), CAST(N'14:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12583, N'46', CAST(N'2022-05-25' AS Date), CAST(N'14:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12584, N'58', CAST(N'2022-05-25' AS Date), CAST(N'14:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12585, N'35', CAST(N'2022-05-25' AS Date), CAST(N'14:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12586, N'87', CAST(N'2022-05-25' AS Date), CAST(N'14:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12587, N'55', CAST(N'2022-05-25' AS Date), CAST(N'14:50:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12588, N'22', CAST(N'2022-05-25' AS Date), CAST(N'14:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12589, N'18', CAST(N'2022-05-25' AS Date), CAST(N'14:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12590, N'56', CAST(N'2022-05-25' AS Date), CAST(N'14:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12591, N'34', CAST(N'2022-05-25' AS Date), CAST(N'14:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12592, N'33', CAST(N'2022-05-25' AS Date), CAST(N'15:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12593, N'31', CAST(N'2022-05-25' AS Date), CAST(N'15:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12594, N'16', CAST(N'2022-05-25' AS Date), CAST(N'15:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12595, N'39', CAST(N'2022-05-25' AS Date), CAST(N'16:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12596, N'32', CAST(N'2022-05-25' AS Date), CAST(N'16:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12597, N'89', CAST(N'2022-05-25' AS Date), CAST(N'17:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12598, N'38', CAST(N'2022-05-25' AS Date), CAST(N'17:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12599, N'24', CAST(N'2022-05-25' AS Date), CAST(N'17:43:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12600, N'71', CAST(N'2022-05-25' AS Date), CAST(N'17:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12601, N'12', CAST(N'2022-05-25' AS Date), CAST(N'18:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12602, N'51', CAST(N'2022-05-25' AS Date), CAST(N'19:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12603, N'74', CAST(N'2022-05-25' AS Date), CAST(N'19:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12604, N'86', CAST(N'2022-05-25' AS Date), CAST(N'19:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12605, N'8', CAST(N'2022-05-25' AS Date), CAST(N'19:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12606, N'80', CAST(N'2022-05-25' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12607, N'70', CAST(N'2022-05-25' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12608, N'9', CAST(N'2022-05-25' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12609, N'75', CAST(N'2022-05-25' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12610, N'83', CAST(N'2022-05-25' AS Date), CAST(N'19:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12611, N'3', CAST(N'2022-05-25' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12612, N'76', CAST(N'2022-05-25' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12613, N'26', CAST(N'2022-05-25' AS Date), CAST(N'19:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12614, N'85', CAST(N'2022-05-25' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12615, N'52', CAST(N'2022-05-25' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12616, N'50', CAST(N'2022-05-25' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12617, N'59', CAST(N'2022-05-25' AS Date), CAST(N'20:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12618, N'48', CAST(N'2022-05-25' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12619, N'15', CAST(N'2022-05-25' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12620, N'49', CAST(N'2022-05-25' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12621, N'87', CAST(N'2022-05-25' AS Date), CAST(N'20:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12622, N'88', CAST(N'2022-05-25' AS Date), CAST(N'20:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12623, N'37', CAST(N'2022-05-25' AS Date), CAST(N'20:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12624, N'73', CAST(N'2022-05-25' AS Date), CAST(N'20:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12625, N'79', CAST(N'2022-05-25' AS Date), CAST(N'20:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12626, N'78', CAST(N'2022-05-25' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12627, N'42', CAST(N'2022-05-25' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12628, N'46', CAST(N'2022-05-25' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12629, N'45', CAST(N'2022-05-25' AS Date), CAST(N'20:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12630, N'43', CAST(N'2022-05-25' AS Date), CAST(N'20:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12631, N'91', CAST(N'2022-05-25' AS Date), CAST(N'20:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12632, N'66', CAST(N'2022-05-25' AS Date), CAST(N'20:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12633, N'64', CAST(N'2022-05-25' AS Date), CAST(N'20:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12634, N'81', CAST(N'2022-05-25' AS Date), CAST(N'20:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12635, N'65', CAST(N'2022-05-25' AS Date), CAST(N'20:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12636, N'55', CAST(N'2022-05-25' AS Date), CAST(N'20:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12637, N'62', CAST(N'2022-05-25' AS Date), CAST(N'20:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12638, N'29', CAST(N'2022-05-25' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12639, N'69', CAST(N'2022-05-25' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12640, N'21', CAST(N'2022-05-25' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12641, N'14', CAST(N'2022-05-25' AS Date), CAST(N'20:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12642, N'28', CAST(N'2022-05-25' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12643, N'33', CAST(N'2022-05-25' AS Date), CAST(N'21:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12644, N'34', CAST(N'2022-05-25' AS Date), CAST(N'21:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12645, N'31', CAST(N'2022-05-25' AS Date), CAST(N'21:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12646, N'18', CAST(N'2022-05-25' AS Date), CAST(N'21:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12647, N'20', CAST(N'2022-05-25' AS Date), CAST(N'21:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12648, N'13', CAST(N'2022-05-25' AS Date), CAST(N'22:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12649, N'27', CAST(N'2022-05-25' AS Date), CAST(N'22:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12650, N'68', CAST(N'2022-05-25' AS Date), CAST(N'22:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12651, N'82', CAST(N'2022-05-26' AS Date), CAST(N'07:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12652, N'23', CAST(N'2022-05-26' AS Date), CAST(N'07:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12653, N'44', CAST(N'2022-05-26' AS Date), CAST(N'07:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12654, N'52', CAST(N'2022-05-26' AS Date), CAST(N'07:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12655, N'59', CAST(N'2022-05-26' AS Date), CAST(N'07:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12656, N'92', CAST(N'2022-05-26' AS Date), CAST(N'07:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12657, N'51', CAST(N'2022-05-26' AS Date), CAST(N'07:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12658, N'83', CAST(N'2022-05-26' AS Date), CAST(N'07:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12659, N'53', CAST(N'2022-05-26' AS Date), CAST(N'07:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12660, N'85', CAST(N'2022-05-26' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12661, N'58', CAST(N'2022-05-26' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12662, N'8', CAST(N'2022-05-26' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12663, N'66', CAST(N'2022-05-26' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12664, N'73', CAST(N'2022-05-26' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12665, N'41', CAST(N'2022-05-26' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12666, N'27', CAST(N'2022-05-26' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12667, N'50', CAST(N'2022-05-26' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12668, N'49', CAST(N'2022-05-26' AS Date), CAST(N'08:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12669, N'86', CAST(N'2022-05-26' AS Date), CAST(N'08:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12670, N'60', CAST(N'2022-05-26' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12671, N'68', CAST(N'2022-05-26' AS Date), CAST(N'08:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12672, N'75', CAST(N'2022-05-26' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12673, N'47', CAST(N'2022-05-26' AS Date), CAST(N'08:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12674, N'91', CAST(N'2022-05-26' AS Date), CAST(N'08:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12675, N'80', CAST(N'2022-05-26' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12676, N'40', CAST(N'2022-05-26' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12677, N'48', CAST(N'2022-05-26' AS Date), CAST(N'08:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12678, N'62', CAST(N'2022-05-26' AS Date), CAST(N'08:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12679, N'76', CAST(N'2022-05-26' AS Date), CAST(N'08:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12680, N'56', CAST(N'2022-05-26' AS Date), CAST(N'08:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12681, N'28', CAST(N'2022-05-26' AS Date), CAST(N'08:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12682, N'6', CAST(N'2022-05-26' AS Date), CAST(N'09:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12683, N'69', CAST(N'2022-05-26' AS Date), CAST(N'09:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12684, N'89', CAST(N'2022-05-26' AS Date), CAST(N'09:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12685, N'20', CAST(N'2022-05-26' AS Date), CAST(N'09:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12686, N'14', CAST(N'2022-05-26' AS Date), CAST(N'09:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12687, N'81', CAST(N'2022-05-26' AS Date), CAST(N'09:21:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12688, N'64', CAST(N'2022-05-26' AS Date), CAST(N'09:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12689, N'21', CAST(N'2022-05-26' AS Date), CAST(N'09:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12690, N'24', CAST(N'2022-05-26' AS Date), CAST(N'10:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12691, N'63', CAST(N'2022-05-26' AS Date), CAST(N'10:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12692, N'38', CAST(N'2022-05-26' AS Date), CAST(N'10:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12693, N'15', CAST(N'2022-05-26' AS Date), CAST(N'10:33:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12694, N'12', CAST(N'2022-05-26' AS Date), CAST(N'10:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12695, N'29', CAST(N'2022-05-26' AS Date), CAST(N'10:41:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12696, N'13', CAST(N'2022-05-26' AS Date), CAST(N'10:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12697, N'26', CAST(N'2022-05-26' AS Date), CAST(N'11:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12698, N'71', CAST(N'2022-05-26' AS Date), CAST(N'11:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12699, N'16', CAST(N'2022-05-26' AS Date), CAST(N'11:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12700, N'2', CAST(N'2022-05-26' AS Date), CAST(N'11:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12701, N'92', CAST(N'2022-05-26' AS Date), CAST(N'13:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12702, N'74', CAST(N'2022-05-26' AS Date), CAST(N'13:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12703, N'78', CAST(N'2022-05-26' AS Date), CAST(N'13:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12704, N'77', CAST(N'2022-05-26' AS Date), CAST(N'13:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12705, N'60', CAST(N'2022-05-26' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12706, N'43', CAST(N'2022-05-26' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12707, N'3', CAST(N'2022-05-26' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12708, N'79', CAST(N'2022-05-26' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12709, N'44', CAST(N'2022-05-26' AS Date), CAST(N'14:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12710, N'72', CAST(N'2022-05-26' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12711, N'41', CAST(N'2022-05-26' AS Date), CAST(N'14:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12712, N'9', CAST(N'2022-05-26' AS Date), CAST(N'14:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12713, N'58', CAST(N'2022-05-26' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12714, N'42', CAST(N'2022-05-26' AS Date), CAST(N'14:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12715, N'45', CAST(N'2022-05-26' AS Date), CAST(N'14:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12716, N'88', CAST(N'2022-05-26' AS Date), CAST(N'14:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12717, N'40', CAST(N'2022-05-26' AS Date), CAST(N'14:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12718, N'6', CAST(N'2022-05-26' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12719, N'53', CAST(N'2022-05-26' AS Date), CAST(N'14:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12720, N'46', CAST(N'2022-05-26' AS Date), CAST(N'14:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12721, N'65', CAST(N'2022-05-26' AS Date), CAST(N'14:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12722, N'37', CAST(N'2022-05-26' AS Date), CAST(N'14:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12723, N'51', CAST(N'2022-05-26' AS Date), CAST(N'14:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12724, N'32', CAST(N'2022-05-26' AS Date), CAST(N'14:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12725, N'73', CAST(N'2022-05-26' AS Date), CAST(N'14:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12726, N'47', CAST(N'2022-05-26' AS Date), CAST(N'14:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12727, N'35', CAST(N'2022-05-26' AS Date), CAST(N'14:30:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12728, N'23', CAST(N'2022-05-26' AS Date), CAST(N'14:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12729, N'55', CAST(N'2022-05-26' AS Date), CAST(N'14:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12730, N'56', CAST(N'2022-05-26' AS Date), CAST(N'14:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12731, N'34', CAST(N'2022-05-26' AS Date), CAST(N'15:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12732, N'18', CAST(N'2022-05-26' AS Date), CAST(N'15:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12733, N'33', CAST(N'2022-05-26' AS Date), CAST(N'15:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12734, N'31', CAST(N'2022-05-26' AS Date), CAST(N'15:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12735, N'87', CAST(N'2022-05-26' AS Date), CAST(N'15:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12736, N'57', CAST(N'2022-05-26' AS Date), CAST(N'15:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12737, N'16', CAST(N'2022-05-26' AS Date), CAST(N'16:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12738, N'39', CAST(N'2022-05-26' AS Date), CAST(N'16:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12739, N'38', CAST(N'2022-05-26' AS Date), CAST(N'17:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12740, N'71', CAST(N'2022-05-26' AS Date), CAST(N'17:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12741, N'24', CAST(N'2022-05-26' AS Date), CAST(N'17:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12742, N'12', CAST(N'2022-05-26' AS Date), CAST(N'19:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12743, N'15', CAST(N'2022-05-26' AS Date), CAST(N'19:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12744, N'68', CAST(N'2022-05-26' AS Date), CAST(N'19:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12745, N'86', CAST(N'2022-05-26' AS Date), CAST(N'19:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12746, N'11', CAST(N'2022-05-26' AS Date), CAST(N'19:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12747, N'91', CAST(N'2022-05-26' AS Date), CAST(N'19:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12748, N'74', CAST(N'2022-05-26' AS Date), CAST(N'19:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12749, N'80', CAST(N'2022-05-26' AS Date), CAST(N'19:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12750, N'57', CAST(N'2022-05-26' AS Date), CAST(N'19:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12751, N'9', CAST(N'2022-05-26' AS Date), CAST(N'19:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12752, N'26', CAST(N'2022-05-26' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12753, N'52', CAST(N'2022-05-26' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12754, N'70', CAST(N'2022-05-26' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12755, N'76', CAST(N'2022-05-26' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12756, N'83', CAST(N'2022-05-26' AS Date), CAST(N'20:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12757, N'82', CAST(N'2022-05-26' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12758, N'75', CAST(N'2022-05-26' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12759, N'49', CAST(N'2022-05-26' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12760, N'7', CAST(N'2022-05-26' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12761, N'48', CAST(N'2022-05-26' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12762, N'50', CAST(N'2022-05-26' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12763, N'59', CAST(N'2022-05-26' AS Date), CAST(N'20:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12764, N'3', CAST(N'2022-05-26' AS Date), CAST(N'20:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12765, N'85', CAST(N'2022-05-26' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12766, N'88', CAST(N'2022-05-26' AS Date), CAST(N'20:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12767, N'42', CAST(N'2022-05-26' AS Date), CAST(N'20:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12768, N'78', CAST(N'2022-05-26' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12769, N'46', CAST(N'2022-05-26' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12770, N'45', CAST(N'2022-05-26' AS Date), CAST(N'20:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12771, N'2', CAST(N'2022-05-26' AS Date), CAST(N'20:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12772, N'43', CAST(N'2022-05-26' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12773, N'37', CAST(N'2022-05-26' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12774, N'65', CAST(N'2022-05-26' AS Date), CAST(N'20:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12775, N'55', CAST(N'2022-05-26' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12776, N'29', CAST(N'2022-05-26' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12777, N'28', CAST(N'2022-05-26' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12778, N'35', CAST(N'2022-05-26' AS Date), CAST(N'21:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12779, N'32', CAST(N'2022-05-26' AS Date), CAST(N'21:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12780, N'31', CAST(N'2022-05-26' AS Date), CAST(N'21:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12781, N'72', CAST(N'2022-05-26' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12782, N'33', CAST(N'2022-05-26' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12783, N'87', CAST(N'2022-05-26' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12784, N'62', CAST(N'2022-05-26' AS Date), CAST(N'21:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12785, N'21', CAST(N'2022-05-26' AS Date), CAST(N'21:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12786, N'69', CAST(N'2022-05-26' AS Date), CAST(N'21:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12787, N'64', CAST(N'2022-05-26' AS Date), CAST(N'21:14:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12788, N'81', CAST(N'2022-05-26' AS Date), CAST(N'21:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12789, N'14', CAST(N'2022-05-26' AS Date), CAST(N'21:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12790, N'20', CAST(N'2022-05-26' AS Date), CAST(N'21:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12791, N'18', CAST(N'2022-05-26' AS Date), CAST(N'21:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12792, N'13', CAST(N'2022-05-26' AS Date), CAST(N'22:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12793, N'27', CAST(N'2022-05-26' AS Date), CAST(N'22:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12794, N'44', CAST(N'2022-05-27' AS Date), CAST(N'07:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12795, N'82', CAST(N'2022-05-27' AS Date), CAST(N'07:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12796, N'52', CAST(N'2022-05-27' AS Date), CAST(N'07:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12797, N'23', CAST(N'2022-05-27' AS Date), CAST(N'07:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12798, N'92', CAST(N'2022-05-27' AS Date), CAST(N'07:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12799, N'83', CAST(N'2022-05-27' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12800, N'80', CAST(N'2022-05-27' AS Date), CAST(N'07:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12801, N'50', CAST(N'2022-05-27' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12802, N'85', CAST(N'2022-05-27' AS Date), CAST(N'07:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12803, N'91', CAST(N'2022-05-27' AS Date), CAST(N'08:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12804, N'58', CAST(N'2022-05-27' AS Date), CAST(N'08:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12805, N'27', CAST(N'2022-05-27' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12806, N'60', CAST(N'2022-05-27' AS Date), CAST(N'08:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12807, N'48', CAST(N'2022-05-27' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12808, N'53', CAST(N'2022-05-27' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12809, N'41', CAST(N'2022-05-27' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12810, N'51', CAST(N'2022-05-27' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12811, N'67', CAST(N'2022-05-27' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12812, N'73', CAST(N'2022-05-27' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12813, N'68', CAST(N'2022-05-27' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12814, N'7', CAST(N'2022-05-27' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12815, N'40', CAST(N'2022-05-27' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12816, N'75', CAST(N'2022-05-27' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12817, N'49', CAST(N'2022-05-27' AS Date), CAST(N'08:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12818, N'86', CAST(N'2022-05-27' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12819, N'11', CAST(N'2022-05-27' AS Date), CAST(N'08:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12820, N'47', CAST(N'2022-05-27' AS Date), CAST(N'08:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12821, N'66', CAST(N'2022-05-27' AS Date), CAST(N'08:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12822, N'76', CAST(N'2022-05-27' AS Date), CAST(N'08:38:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12823, N'62', CAST(N'2022-05-27' AS Date), CAST(N'08:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12824, N'28', CAST(N'2022-05-27' AS Date), CAST(N'08:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12825, N'89', CAST(N'2022-05-27' AS Date), CAST(N'09:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12826, N'65', CAST(N'2022-05-27' AS Date), CAST(N'09:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12827, N'69', CAST(N'2022-05-27' AS Date), CAST(N'09:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12828, N'21', CAST(N'2022-05-27' AS Date), CAST(N'09:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12829, N'20', CAST(N'2022-05-27' AS Date), CAST(N'09:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12830, N'81', CAST(N'2022-05-27' AS Date), CAST(N'09:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12831, N'64', CAST(N'2022-05-27' AS Date), CAST(N'09:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12832, N'14', CAST(N'2022-05-27' AS Date), CAST(N'09:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12833, N'6', CAST(N'2022-05-27' AS Date), CAST(N'09:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12834, N'24', CAST(N'2022-05-27' AS Date), CAST(N'09:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12835, N'29', CAST(N'2022-05-27' AS Date), CAST(N'10:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12836, N'12', CAST(N'2022-05-27' AS Date), CAST(N'10:40:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12837, N'13', CAST(N'2022-05-27' AS Date), CAST(N'10:43:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12838, N'38', CAST(N'2022-05-27' AS Date), CAST(N'11:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12839, N'26', CAST(N'2022-05-27' AS Date), CAST(N'11:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12840, N'15', CAST(N'2022-05-27' AS Date), CAST(N'11:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12841, N'16', CAST(N'2022-05-27' AS Date), CAST(N'11:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12842, N'71', CAST(N'2022-05-27' AS Date), CAST(N'11:27:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12843, N'74', CAST(N'2022-05-27' AS Date), CAST(N'13:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12844, N'67', CAST(N'2022-05-27' AS Date), CAST(N'13:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12845, N'88', CAST(N'2022-05-27' AS Date), CAST(N'13:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12846, N'42', CAST(N'2022-05-27' AS Date), CAST(N'13:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12847, N'43', CAST(N'2022-05-27' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12848, N'44', CAST(N'2022-05-27' AS Date), CAST(N'13:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12849, N'40', CAST(N'2022-05-27' AS Date), CAST(N'14:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12850, N'3', CAST(N'2022-05-27' AS Date), CAST(N'14:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12851, N'41', CAST(N'2022-05-27' AS Date), CAST(N'14:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12852, N'58', CAST(N'2022-05-27' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12853, N'79', CAST(N'2022-05-27' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12854, N'92', CAST(N'2022-05-27' AS Date), CAST(N'14:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12855, N'53', CAST(N'2022-05-27' AS Date), CAST(N'14:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12856, N'46', CAST(N'2022-05-27' AS Date), CAST(N'14:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12857, N'9', CAST(N'2022-05-27' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12858, N'45', CAST(N'2022-05-27' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12859, N'35', CAST(N'2022-05-27' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12860, N'37', CAST(N'2022-05-27' AS Date), CAST(N'14:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12861, N'47', CAST(N'2022-05-27' AS Date), CAST(N'14:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12862, N'51', CAST(N'2022-05-27' AS Date), CAST(N'14:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12863, N'51', CAST(N'2022-05-27' AS Date), CAST(N'14:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12864, N'22', CAST(N'2022-05-27' AS Date), CAST(N'14:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12865, N'34', CAST(N'2022-05-27' AS Date), CAST(N'14:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12866, N'72', CAST(N'2022-05-27' AS Date), CAST(N'14:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12867, N'20', CAST(N'2022-05-27' AS Date), CAST(N'14:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12868, N'23', CAST(N'2022-05-27' AS Date), CAST(N'14:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12869, N'32', CAST(N'2022-05-27' AS Date), CAST(N'15:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12870, N'31', CAST(N'2022-05-27' AS Date), CAST(N'15:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12871, N'55', CAST(N'2022-05-27' AS Date), CAST(N'15:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12872, N'18', CAST(N'2022-05-27' AS Date), CAST(N'15:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12873, N'87', CAST(N'2022-05-27' AS Date), CAST(N'15:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12874, N'57', CAST(N'2022-05-27' AS Date), CAST(N'15:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12875, N'16', CAST(N'2022-05-27' AS Date), CAST(N'15:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12876, N'39', CAST(N'2022-05-27' AS Date), CAST(N'16:37:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12877, N'38', CAST(N'2022-05-27' AS Date), CAST(N'16:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12878, N'89', CAST(N'2022-05-27' AS Date), CAST(N'17:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12879, N'24', CAST(N'2022-05-27' AS Date), CAST(N'17:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12880, N'12', CAST(N'2022-05-27' AS Date), CAST(N'18:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12881, N'15', CAST(N'2022-05-27' AS Date), CAST(N'19:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12882, N'8', CAST(N'2022-05-27' AS Date), CAST(N'19:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12883, N'74', CAST(N'2022-05-27' AS Date), CAST(N'19:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12884, N'82', CAST(N'2022-05-27' AS Date), CAST(N'19:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12885, N'80', CAST(N'2022-05-27' AS Date), CAST(N'19:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12886, N'83', CAST(N'2022-05-27' AS Date), CAST(N'19:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12887, N'9', CAST(N'2022-05-27' AS Date), CAST(N'19:53:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12888, N'57', CAST(N'2022-05-27' AS Date), CAST(N'19:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12889, N'86', CAST(N'2022-05-27' AS Date), CAST(N'19:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12890, N'70', CAST(N'2022-05-27' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12891, N'26', CAST(N'2022-05-27' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12892, N'3', CAST(N'2022-05-27' AS Date), CAST(N'19:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12893, N'91', CAST(N'2022-05-27' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12894, N'76', CAST(N'2022-05-27' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12895, N'75', CAST(N'2022-05-27' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12896, N'50', CAST(N'2022-05-27' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12897, N'85', CAST(N'2022-05-27' AS Date), CAST(N'20:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12898, N'59', CAST(N'2022-05-27' AS Date), CAST(N'20:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12899, N'88', CAST(N'2022-05-27' AS Date), CAST(N'20:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12900, N'49', CAST(N'2022-05-27' AS Date), CAST(N'20:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12901, N'37', CAST(N'2022-05-27' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12902, N'51', CAST(N'2022-05-27' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12903, N'73', CAST(N'2022-05-27' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12904, N'43', CAST(N'2022-05-27' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12905, N'48', CAST(N'2022-05-27' AS Date), CAST(N'20:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12906, N'42', CAST(N'2022-05-27' AS Date), CAST(N'20:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12907, N'46', CAST(N'2022-05-27' AS Date), CAST(N'20:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12908, N'45', CAST(N'2022-05-27' AS Date), CAST(N'20:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12909, N'21', CAST(N'2022-05-27' AS Date), CAST(N'20:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12910, N'64', CAST(N'2022-05-27' AS Date), CAST(N'20:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12911, N'81', CAST(N'2022-05-27' AS Date), CAST(N'20:43:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12912, N'55', CAST(N'2022-05-27' AS Date), CAST(N'20:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12913, N'72', CAST(N'2022-05-27' AS Date), CAST(N'20:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12914, N'29', CAST(N'2022-05-27' AS Date), CAST(N'20:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12915, N'69', CAST(N'2022-05-27' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12916, N'28', CAST(N'2022-05-27' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12917, N'35', CAST(N'2022-05-27' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12918, N'87', CAST(N'2022-05-27' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12919, N'31', CAST(N'2022-05-27' AS Date), CAST(N'21:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12920, N'65', CAST(N'2022-05-27' AS Date), CAST(N'21:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12921, N'32', CAST(N'2022-05-27' AS Date), CAST(N'21:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12922, N'62', CAST(N'2022-05-27' AS Date), CAST(N'21:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12923, N'14', CAST(N'2022-05-27' AS Date), CAST(N'21:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12924, N'13', CAST(N'2022-05-27' AS Date), CAST(N'21:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12925, N'22', CAST(N'2022-05-27' AS Date), CAST(N'21:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12926, N'68', CAST(N'2022-05-27' AS Date), CAST(N'22:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12927, N'27', CAST(N'2022-05-27' AS Date), CAST(N'22:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12928, N'82', CAST(N'2022-05-28' AS Date), CAST(N'07:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12929, N'59', CAST(N'2022-05-28' AS Date), CAST(N'07:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12930, N'73', CAST(N'2022-05-28' AS Date), CAST(N'07:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12931, N'27', CAST(N'2022-05-28' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12932, N'23', CAST(N'2022-05-28' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12933, N'50', CAST(N'2022-05-28' AS Date), CAST(N'07:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12934, N'85', CAST(N'2022-05-28' AS Date), CAST(N'07:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12935, N'91', CAST(N'2022-05-28' AS Date), CAST(N'07:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12936, N'48', CAST(N'2022-05-28' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12937, N'58', CAST(N'2022-05-28' AS Date), CAST(N'07:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12938, N'51', CAST(N'2022-05-28' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12939, N'53', CAST(N'2022-05-28' AS Date), CAST(N'08:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12940, N'75', CAST(N'2022-05-28' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12941, N'47', CAST(N'2022-05-28' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12942, N'8', CAST(N'2022-05-28' AS Date), CAST(N'08:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12943, N'67', CAST(N'2022-05-28' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12944, N'68', CAST(N'2022-05-28' AS Date), CAST(N'08:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12945, N'86', CAST(N'2022-05-28' AS Date), CAST(N'08:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12946, N'49', CAST(N'2022-05-28' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12947, N'40', CAST(N'2022-05-28' AS Date), CAST(N'08:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12948, N'65', CAST(N'2022-05-28' AS Date), CAST(N'08:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12949, N'92', CAST(N'2022-05-28' AS Date), CAST(N'08:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12950, N'76', CAST(N'2022-05-28' AS Date), CAST(N'08:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12951, N'12', CAST(N'2022-05-28' AS Date), CAST(N'08:36:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12952, N'41', CAST(N'2022-05-28' AS Date), CAST(N'08:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12953, N'6', CAST(N'2022-05-28' AS Date), CAST(N'08:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12954, N'56', CAST(N'2022-05-28' AS Date), CAST(N'08:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12955, N'62', CAST(N'2022-05-28' AS Date), CAST(N'08:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12956, N'28', CAST(N'2022-05-28' AS Date), CAST(N'08:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12957, N'66', CAST(N'2022-05-28' AS Date), CAST(N'09:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12958, N'89', CAST(N'2022-05-28' AS Date), CAST(N'09:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12959, N'81', CAST(N'2022-05-28' AS Date), CAST(N'09:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12960, N'14', CAST(N'2022-05-28' AS Date), CAST(N'09:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12961, N'64', CAST(N'2022-05-28' AS Date), CAST(N'09:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12962, N'20', CAST(N'2022-05-28' AS Date), CAST(N'09:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12963, N'21', CAST(N'2022-05-28' AS Date), CAST(N'09:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12964, N'21', CAST(N'2022-05-28' AS Date), CAST(N'09:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12965, N'24', CAST(N'2022-05-28' AS Date), CAST(N'09:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12966, N'29', CAST(N'2022-05-28' AS Date), CAST(N'10:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12967, N'13', CAST(N'2022-05-28' AS Date), CAST(N'10:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12968, N'15', CAST(N'2022-05-28' AS Date), CAST(N'10:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12969, N'26', CAST(N'2022-05-28' AS Date), CAST(N'11:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12970, N'71', CAST(N'2022-05-28' AS Date), CAST(N'11:18:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12971, N'2', CAST(N'2022-05-28' AS Date), CAST(N'11:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12972, N'74', CAST(N'2022-05-28' AS Date), CAST(N'13:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12973, N'80', CAST(N'2022-05-28' AS Date), CAST(N'13:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12974, N'78', CAST(N'2022-05-28' AS Date), CAST(N'13:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12975, N'67', CAST(N'2022-05-28' AS Date), CAST(N'13:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12976, N'77', CAST(N'2022-05-28' AS Date), CAST(N'13:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12977, N'3', CAST(N'2022-05-28' AS Date), CAST(N'13:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12978, N'43', CAST(N'2022-05-28' AS Date), CAST(N'14:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12979, N'45', CAST(N'2022-05-28' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12980, N'9', CAST(N'2022-05-28' AS Date), CAST(N'14:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12981, N'58', CAST(N'2022-05-28' AS Date), CAST(N'14:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12982, N'53', CAST(N'2022-05-28' AS Date), CAST(N'14:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12983, N'6', CAST(N'2022-05-28' AS Date), CAST(N'14:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12984, N'92', CAST(N'2022-05-28' AS Date), CAST(N'14:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12985, N'72', CAST(N'2022-05-28' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12986, N'35', CAST(N'2022-05-28' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12987, N'88', CAST(N'2022-05-28' AS Date), CAST(N'14:22:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12988, N'32', CAST(N'2022-05-28' AS Date), CAST(N'14:22:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12989, N'37', CAST(N'2022-05-28' AS Date), CAST(N'14:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12990, N'46', CAST(N'2022-05-28' AS Date), CAST(N'14:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12991, N'34', CAST(N'2022-05-28' AS Date), CAST(N'14:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12992, N'55', CAST(N'2022-05-28' AS Date), CAST(N'15:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12993, N'18', CAST(N'2022-05-28' AS Date), CAST(N'15:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12994, N'41', CAST(N'2022-05-28' AS Date), CAST(N'15:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12995, N'56', CAST(N'2022-05-28' AS Date), CAST(N'15:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12996, N'87', CAST(N'2022-05-28' AS Date), CAST(N'15:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12997, N'31', CAST(N'2022-05-28' AS Date), CAST(N'15:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12998, N'57', CAST(N'2022-05-28' AS Date), CAST(N'15:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (12999, N'89', CAST(N'2022-05-28' AS Date), CAST(N'17:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13000, N'71', CAST(N'2022-05-28' AS Date), CAST(N'17:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13001, N'24', CAST(N'2022-05-28' AS Date), CAST(N'17:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13002, N'12', CAST(N'2022-05-28' AS Date), CAST(N'18:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13003, N'87', CAST(N'2022-05-28' AS Date), CAST(N'18:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13004, N'15', CAST(N'2022-05-28' AS Date), CAST(N'19:38:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13005, N'86', CAST(N'2022-05-28' AS Date), CAST(N'19:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13006, N'2', CAST(N'2022-05-28' AS Date), CAST(N'19:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13007, N'39', CAST(N'2022-05-28' AS Date), CAST(N'19:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13008, N'68', CAST(N'2022-05-28' AS Date), CAST(N'19:50:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13009, N'40', CAST(N'2022-05-28' AS Date), CAST(N'19:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13010, N'74', CAST(N'2022-05-28' AS Date), CAST(N'19:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13011, N'26', CAST(N'2022-05-28' AS Date), CAST(N'19:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13012, N'70', CAST(N'2022-05-28' AS Date), CAST(N'19:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13013, N'11', CAST(N'2022-05-28' AS Date), CAST(N'19:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13014, N'9', CAST(N'2022-05-28' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13015, N'77', CAST(N'2022-05-28' AS Date), CAST(N'19:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13016, N'52', CAST(N'2022-05-28' AS Date), CAST(N'19:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13017, N'73', CAST(N'2022-05-28' AS Date), CAST(N'19:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13018, N'50', CAST(N'2022-05-28' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13019, N'47', CAST(N'2022-05-28' AS Date), CAST(N'20:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13020, N'80', CAST(N'2022-05-28' AS Date), CAST(N'20:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13021, N'91', CAST(N'2022-05-28' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13022, N'59', CAST(N'2022-05-28' AS Date), CAST(N'20:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13023, N'49', CAST(N'2022-05-28' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13024, N'82', CAST(N'2022-05-28' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13025, N'48', CAST(N'2022-05-28' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13026, N'51', CAST(N'2022-05-28' AS Date), CAST(N'20:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13027, N'88', CAST(N'2022-05-28' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13028, N'43', CAST(N'2022-05-28' AS Date), CAST(N'20:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13029, N'85', CAST(N'2022-05-28' AS Date), CAST(N'20:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13030, N'46', CAST(N'2022-05-28' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13031, N'45', CAST(N'2022-05-28' AS Date), CAST(N'20:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13032, N'78', CAST(N'2022-05-28' AS Date), CAST(N'20:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13033, N'37', CAST(N'2022-05-28' AS Date), CAST(N'20:34:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13034, N'7', CAST(N'2022-05-28' AS Date), CAST(N'20:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13035, N'62', CAST(N'2022-05-28' AS Date), CAST(N'20:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13036, N'29', CAST(N'2022-05-28' AS Date), CAST(N'20:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13037, N'64', CAST(N'2022-05-28' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13038, N'81', CAST(N'2022-05-28' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13039, N'28', CAST(N'2022-05-28' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13040, N'34', CAST(N'2022-05-28' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13041, N'65', CAST(N'2022-05-28' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13042, N'21', CAST(N'2022-05-28' AS Date), CAST(N'21:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13043, N'35', CAST(N'2022-05-28' AS Date), CAST(N'21:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13044, N'72', CAST(N'2022-05-28' AS Date), CAST(N'21:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13045, N'55', CAST(N'2022-05-28' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13046, N'18', CAST(N'2022-05-28' AS Date), CAST(N'21:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13047, N'14', CAST(N'2022-05-28' AS Date), CAST(N'21:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13048, N'20', CAST(N'2022-05-28' AS Date), CAST(N'21:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13049, N'13', CAST(N'2022-05-28' AS Date), CAST(N'21:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13050, N'27', CAST(N'2022-05-28' AS Date), CAST(N'22:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13051, N'71', CAST(N'2022-05-29' AS Date), CAST(N'07:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13052, N'21', CAST(N'2022-05-29' AS Date), CAST(N'07:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13053, N'44', CAST(N'2022-05-29' AS Date), CAST(N'07:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13054, N'82', CAST(N'2022-05-29' AS Date), CAST(N'07:43:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13055, N'46', CAST(N'2022-05-29' AS Date), CAST(N'07:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13056, N'52', CAST(N'2022-05-29' AS Date), CAST(N'07:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13057, N'50', CAST(N'2022-05-29' AS Date), CAST(N'07:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13058, N'85', CAST(N'2022-05-29' AS Date), CAST(N'07:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13059, N'91', CAST(N'2022-05-29' AS Date), CAST(N'07:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13060, N'48', CAST(N'2022-05-29' AS Date), CAST(N'07:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13061, N'40', CAST(N'2022-05-29' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13062, N'11', CAST(N'2022-05-29' AS Date), CAST(N'07:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13063, N'86', CAST(N'2022-05-29' AS Date), CAST(N'07:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13064, N'51', CAST(N'2022-05-29' AS Date), CAST(N'07:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13065, N'83', CAST(N'2022-05-29' AS Date), CAST(N'07:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13066, N'11', CAST(N'2022-05-29' AS Date), CAST(N'08:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13067, N'73', CAST(N'2022-05-29' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13068, N'53', CAST(N'2022-05-29' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13069, N'41', CAST(N'2022-05-29' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13070, N'58', CAST(N'2022-05-29' AS Date), CAST(N'08:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13071, N'49', CAST(N'2022-05-29' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13072, N'66', CAST(N'2022-05-29' AS Date), CAST(N'08:40:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13073, N'28', CAST(N'2022-05-29' AS Date), CAST(N'08:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13074, N'7', CAST(N'2022-05-29' AS Date), CAST(N'09:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13075, N'62', CAST(N'2022-05-29' AS Date), CAST(N'09:35:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13076, N'38', CAST(N'2022-05-29' AS Date), CAST(N'10:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13077, N'41', CAST(N'2022-05-29' AS Date), CAST(N'12:47:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13078, N'45', CAST(N'2022-05-29' AS Date), CAST(N'13:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13079, N'42', CAST(N'2022-05-29' AS Date), CAST(N'13:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13080, N'44', CAST(N'2022-05-29' AS Date), CAST(N'14:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13081, N'43', CAST(N'2022-05-29' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13082, N'58', CAST(N'2022-05-29' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13083, N'40', CAST(N'2022-05-29' AS Date), CAST(N'14:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13084, N'83', CAST(N'2022-05-29' AS Date), CAST(N'14:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13085, N'53', CAST(N'2022-05-29' AS Date), CAST(N'14:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13086, N'51', CAST(N'2022-05-29' AS Date), CAST(N'14:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13087, N'46', CAST(N'2022-05-29' AS Date), CAST(N'15:00:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13088, N'21', CAST(N'2022-05-29' AS Date), CAST(N'19:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13089, N'71', CAST(N'2022-05-29' AS Date), CAST(N'19:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13090, N'8', CAST(N'2022-05-29' AS Date), CAST(N'19:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13091, N'70', CAST(N'2022-05-29' AS Date), CAST(N'19:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13092, N'91', CAST(N'2022-05-29' AS Date), CAST(N'19:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13093, N'82', CAST(N'2022-05-29' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13094, N'52', CAST(N'2022-05-29' AS Date), CAST(N'19:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13095, N'86', CAST(N'2022-05-29' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13096, N'75', CAST(N'2022-05-29' AS Date), CAST(N'20:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13097, N'73', CAST(N'2022-05-29' AS Date), CAST(N'20:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13098, N'49', CAST(N'2022-05-29' AS Date), CAST(N'20:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13099, N'85', CAST(N'2022-05-29' AS Date), CAST(N'20:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13100, N'45', CAST(N'2022-05-29' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13101, N'42', CAST(N'2022-05-29' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13102, N'43', CAST(N'2022-05-29' AS Date), CAST(N'20:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13103, N'11', CAST(N'2022-05-29' AS Date), CAST(N'20:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13104, N'66', CAST(N'2022-05-29' AS Date), CAST(N'20:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13105, N'50', CAST(N'2022-05-29' AS Date), CAST(N'20:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13106, N'28', CAST(N'2022-05-29' AS Date), CAST(N'21:37:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13107, N'38', CAST(N'2022-05-29' AS Date), CAST(N'21:39:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13108, N'82', CAST(N'2022-05-30' AS Date), CAST(N'07:44:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13109, N'44', CAST(N'2022-05-30' AS Date), CAST(N'07:45:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13110, N'52', CAST(N'2022-05-30' AS Date), CAST(N'07:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13111, N'92', CAST(N'2022-05-30' AS Date), CAST(N'07:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13112, N'85', CAST(N'2022-05-30' AS Date), CAST(N'07:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13113, N'91', CAST(N'2022-05-30' AS Date), CAST(N'07:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13114, N'66', CAST(N'2022-05-30' AS Date), CAST(N'07:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13115, N'58', CAST(N'2022-05-30' AS Date), CAST(N'08:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13116, N'53', CAST(N'2022-05-30' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13117, N'73', CAST(N'2022-05-30' AS Date), CAST(N'08:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13118, N'8', CAST(N'2022-05-30' AS Date), CAST(N'08:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13119, N'50', CAST(N'2022-05-30' AS Date), CAST(N'08:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13120, N'51', CAST(N'2022-05-30' AS Date), CAST(N'08:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13121, N'86', CAST(N'2022-05-30' AS Date), CAST(N'08:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13122, N'27', CAST(N'2022-05-30' AS Date), CAST(N'08:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13123, N'67', CAST(N'2022-05-30' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13124, N'47', CAST(N'2022-05-30' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13125, N'68', CAST(N'2022-05-30' AS Date), CAST(N'08:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13126, N'75', CAST(N'2022-05-30' AS Date), CAST(N'08:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13127, N'80', CAST(N'2022-05-30' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13128, N'40', CAST(N'2022-05-30' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13129, N'49', CAST(N'2022-05-30' AS Date), CAST(N'08:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13130, N'83', CAST(N'2022-05-30' AS Date), CAST(N'08:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13131, N'65', CAST(N'2022-05-30' AS Date), CAST(N'08:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13132, N'56', CAST(N'2022-05-30' AS Date), CAST(N'08:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13133, N'89', CAST(N'2022-05-30' AS Date), CAST(N'08:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13134, N'28', CAST(N'2022-05-30' AS Date), CAST(N'08:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13135, N'81', CAST(N'2022-05-30' AS Date), CAST(N'09:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13136, N'64', CAST(N'2022-05-30' AS Date), CAST(N'09:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13137, N'6', CAST(N'2022-05-30' AS Date), CAST(N'09:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13138, N'20', CAST(N'2022-05-30' AS Date), CAST(N'09:14:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13139, N'21', CAST(N'2022-05-30' AS Date), CAST(N'09:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13140, N'69', CAST(N'2022-05-30' AS Date), CAST(N'09:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13141, N'14', CAST(N'2022-05-30' AS Date), CAST(N'09:38:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13142, N'24', CAST(N'2022-05-30' AS Date), CAST(N'09:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13143, N'15', CAST(N'2022-05-30' AS Date), CAST(N'10:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13144, N'12', CAST(N'2022-05-30' AS Date), CAST(N'10:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13145, N'38', CAST(N'2022-05-30' AS Date), CAST(N'10:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13146, N'71', CAST(N'2022-05-30' AS Date), CAST(N'11:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13147, N'26', CAST(N'2022-05-30' AS Date), CAST(N'11:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13148, N'16', CAST(N'2022-05-30' AS Date), CAST(N'11:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13149, N'2', CAST(N'2022-05-30' AS Date), CAST(N'11:32:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13150, N'74', CAST(N'2022-05-30' AS Date), CAST(N'13:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13151, N'88', CAST(N'2022-05-30' AS Date), CAST(N'13:25:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13152, N'67', CAST(N'2022-05-30' AS Date), CAST(N'13:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13153, N'3', CAST(N'2022-05-30' AS Date), CAST(N'13:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13154, N'44', CAST(N'2022-05-30' AS Date), CAST(N'13:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13155, N'92', CAST(N'2022-05-30' AS Date), CAST(N'13:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13156, N'34', CAST(N'2022-05-30' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13157, N'78', CAST(N'2022-05-30' AS Date), CAST(N'14:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13158, N'45', CAST(N'2022-05-30' AS Date), CAST(N'14:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13159, N'42', CAST(N'2022-05-30' AS Date), CAST(N'14:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13160, N'9', CAST(N'2022-05-30' AS Date), CAST(N'14:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13161, N'35', CAST(N'2022-05-30' AS Date), CAST(N'14:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13162, N'6', CAST(N'2022-05-30' AS Date), CAST(N'14:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13163, N'40', CAST(N'2022-05-30' AS Date), CAST(N'14:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13164, N'53', CAST(N'2022-05-30' AS Date), CAST(N'14:13:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13165, N'43', CAST(N'2022-05-30' AS Date), CAST(N'14:13:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13166, N'58', CAST(N'2022-05-30' AS Date), CAST(N'14:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13167, N'79', CAST(N'2022-05-30' AS Date), CAST(N'14:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13168, N'47', CAST(N'2022-05-30' AS Date), CAST(N'14:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13169, N'72', CAST(N'2022-05-30' AS Date), CAST(N'14:37:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13170, N'22', CAST(N'2022-05-30' AS Date), CAST(N'14:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13171, N'73', CAST(N'2022-05-30' AS Date), CAST(N'14:41:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13172, N'55', CAST(N'2022-05-30' AS Date), CAST(N'14:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13173, N'56', CAST(N'2022-05-30' AS Date), CAST(N'15:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13174, N'18', CAST(N'2022-05-30' AS Date), CAST(N'15:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13175, N'23', CAST(N'2022-05-30' AS Date), CAST(N'15:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13176, N'37', CAST(N'2022-05-30' AS Date), CAST(N'15:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13177, N'31', CAST(N'2022-05-30' AS Date), CAST(N'15:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13178, N'32', CAST(N'2022-05-30' AS Date), CAST(N'15:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13179, N'33', CAST(N'2022-05-30' AS Date), CAST(N'15:24:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13180, N'57', CAST(N'2022-05-30' AS Date), CAST(N'15:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13181, N'87', CAST(N'2022-05-30' AS Date), CAST(N'15:35:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13182, N'93', CAST(N'2022-05-30' AS Date), CAST(N'15:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13183, N'14', CAST(N'2022-05-30' AS Date), CAST(N'15:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13184, N'16', CAST(N'2022-05-30' AS Date), CAST(N'16:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13185, N'39', CAST(N'2022-05-30' AS Date), CAST(N'16:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13186, N'38', CAST(N'2022-05-30' AS Date), CAST(N'16:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13187, N'89', CAST(N'2022-05-30' AS Date), CAST(N'17:05:00' AS Time), N'2
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13188, N'24', CAST(N'2022-05-30' AS Date), CAST(N'17:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13189, N'71', CAST(N'2022-05-30' AS Date), CAST(N'17:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13190, N'12', CAST(N'2022-05-30' AS Date), CAST(N'17:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13191, N'86', CAST(N'2022-05-30' AS Date), CAST(N'19:47:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13192, N'74', CAST(N'2022-05-30' AS Date), CAST(N'19:50:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13193, N'11', CAST(N'2022-05-30' AS Date), CAST(N'19:51:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13194, N'26', CAST(N'2022-05-30' AS Date), CAST(N'19:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13195, N'76', CAST(N'2022-05-30' AS Date), CAST(N'19:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13196, N'91', CAST(N'2022-05-30' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13197, N'80', CAST(N'2022-05-30' AS Date), CAST(N'19:56:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13198, N'9', CAST(N'2022-05-30' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13199, N'57', CAST(N'2022-05-30' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13200, N'70', CAST(N'2022-05-30' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13201, N'7', CAST(N'2022-05-30' AS Date), CAST(N'20:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13202, N'59', CAST(N'2022-05-30' AS Date), CAST(N'20:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13203, N'50', CAST(N'2022-05-30' AS Date), CAST(N'20:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13204, N'48', CAST(N'2022-05-30' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13205, N'85', CAST(N'2022-05-30' AS Date), CAST(N'20:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13206, N'3', CAST(N'2022-05-30' AS Date), CAST(N'20:06:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13207, N'66', CAST(N'2022-05-30' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13208, N'2', CAST(N'2022-05-30' AS Date), CAST(N'20:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13209, N'49', CAST(N'2022-05-30' AS Date), CAST(N'20:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13210, N'51', CAST(N'2022-05-30' AS Date), CAST(N'20:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13211, N'15', CAST(N'2022-05-30' AS Date), CAST(N'20:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13212, N'78', CAST(N'2022-05-30' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13213, N'43', CAST(N'2022-05-30' AS Date), CAST(N'20:25:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13214, N'79', CAST(N'2022-05-30' AS Date), CAST(N'20:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13215, N'62', CAST(N'2022-05-30' AS Date), CAST(N'20:28:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13216, N'42', CAST(N'2022-05-30' AS Date), CAST(N'20:29:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13217, N'45', CAST(N'2022-05-30' AS Date), CAST(N'20:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13218, N'77', CAST(N'2022-05-30' AS Date), CAST(N'20:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13219, N'65', CAST(N'2022-05-30' AS Date), CAST(N'20:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13220, N'82', CAST(N'2022-05-30' AS Date), CAST(N'20:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13221, N'37', CAST(N'2022-05-30' AS Date), CAST(N'20:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13222, N'83', CAST(N'2022-05-30' AS Date), CAST(N'20:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13223, N'29', CAST(N'2022-05-30' AS Date), CAST(N'20:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13224, N'21', CAST(N'2022-05-30' AS Date), CAST(N'20:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13225, N'88', CAST(N'2022-05-30' AS Date), CAST(N'20:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13226, N'72', CAST(N'2022-05-30' AS Date), CAST(N'20:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13227, N'69', CAST(N'2022-05-30' AS Date), CAST(N'21:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13228, N'13', CAST(N'2022-05-30' AS Date), CAST(N'21:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13229, N'55', CAST(N'2022-05-30' AS Date), CAST(N'21:03:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13230, N'28', CAST(N'2022-05-30' AS Date), CAST(N'21:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13231, N'35', CAST(N'2022-05-30' AS Date), CAST(N'21:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13232, N'64', CAST(N'2022-05-30' AS Date), CAST(N'21:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13233, N'81', CAST(N'2022-05-30' AS Date), CAST(N'21:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13234, N'20', CAST(N'2022-05-30' AS Date), CAST(N'21:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13235, N'18', CAST(N'2022-05-30' AS Date), CAST(N'21:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13236, N'33', CAST(N'2022-05-30' AS Date), CAST(N'21:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13237, N'31', CAST(N'2022-05-30' AS Date), CAST(N'21:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13238, N'93', CAST(N'2022-05-30' AS Date), CAST(N'21:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13239, N'32', CAST(N'2022-05-30' AS Date), CAST(N'21:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13240, N'22', CAST(N'2022-05-30' AS Date), CAST(N'21:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13241, N'87', CAST(N'2022-05-30' AS Date), CAST(N'22:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13242, N'68', CAST(N'2022-05-30' AS Date), CAST(N'22:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13243, N'27', CAST(N'2022-05-30' AS Date), CAST(N'23:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13244, N'82', CAST(N'2022-05-31' AS Date), CAST(N'07:45:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13245, N'92', CAST(N'2022-05-31' AS Date), CAST(N'07:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13246, N'23', CAST(N'2022-05-31' AS Date), CAST(N'07:54:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13247, N'52', CAST(N'2022-05-31' AS Date), CAST(N'07:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13248, N'86', CAST(N'2022-05-31' AS Date), CAST(N'07:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13249, N'73', CAST(N'2022-05-31' AS Date), CAST(N'08:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13250, N'44', CAST(N'2022-05-31' AS Date), CAST(N'08:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13251, N'51', CAST(N'2022-05-31' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13252, N'53', CAST(N'2022-05-31' AS Date), CAST(N'08:04:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13253, N'58', CAST(N'2022-05-31' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13254, N'68', CAST(N'2022-05-31' AS Date), CAST(N'08:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13255, N'83', CAST(N'2022-05-31' AS Date), CAST(N'08:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13256, N'67', CAST(N'2022-05-31' AS Date), CAST(N'08:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13257, N'75', CAST(N'2022-05-31' AS Date), CAST(N'08:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13258, N'85', CAST(N'2022-05-31' AS Date), CAST(N'08:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13259, N'91', CAST(N'2022-05-31' AS Date), CAST(N'08:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13260, N'49', CAST(N'2022-05-31' AS Date), CAST(N'08:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13261, N'50', CAST(N'2022-05-31' AS Date), CAST(N'08:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13262, N'66', CAST(N'2022-05-31' AS Date), CAST(N'08:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13263, N'48', CAST(N'2022-05-31' AS Date), CAST(N'08:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13264, N'80', CAST(N'2022-05-31' AS Date), CAST(N'08:16:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13265, N'40', CAST(N'2022-05-31' AS Date), CAST(N'08:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13266, N'27', CAST(N'2022-05-31' AS Date), CAST(N'08:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13267, N'47', CAST(N'2022-05-31' AS Date), CAST(N'08:21:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13268, N'11', CAST(N'2022-05-31' AS Date), CAST(N'08:22:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13269, N'7', CAST(N'2022-05-31' AS Date), CAST(N'08:30:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13270, N'76', CAST(N'2022-05-31' AS Date), CAST(N'08:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13271, N'65', CAST(N'2022-05-31' AS Date), CAST(N'08:53:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13272, N'24', CAST(N'2022-05-31' AS Date), CAST(N'08:58:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13273, N'56', CAST(N'2022-05-31' AS Date), CAST(N'08:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13274, N'28', CAST(N'2022-05-31' AS Date), CAST(N'09:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13275, N'89', CAST(N'2022-05-31' AS Date), CAST(N'09:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13276, N'14', CAST(N'2022-05-31' AS Date), CAST(N'09:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13277, N'69', CAST(N'2022-05-31' AS Date), CAST(N'09:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13278, N'64', CAST(N'2022-05-31' AS Date), CAST(N'09:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13279, N'81', CAST(N'2022-05-31' AS Date), CAST(N'09:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13280, N'20', CAST(N'2022-05-31' AS Date), CAST(N'09:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13281, N'6', CAST(N'2022-05-31' AS Date), CAST(N'09:36:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13282, N'21', CAST(N'2022-05-31' AS Date), CAST(N'09:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13283, N'15', CAST(N'2022-05-31' AS Date), CAST(N'10:06:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13284, N'12', CAST(N'2022-05-31' AS Date), CAST(N'10:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13285, N'29', CAST(N'2022-05-31' AS Date), CAST(N'10:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13286, N'62', CAST(N'2022-05-31' AS Date), CAST(N'10:38:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13287, N'38', CAST(N'2022-05-31' AS Date), CAST(N'10:53:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13288, N'71', CAST(N'2022-05-31' AS Date), CAST(N'11:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13289, N'26', CAST(N'2022-05-31' AS Date), CAST(N'11:20:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13290, N'16', CAST(N'2022-05-31' AS Date), CAST(N'11:26:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13291, N'13', CAST(N'2022-05-31' AS Date), CAST(N'11:39:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13292, N'77', CAST(N'2022-05-31' AS Date), CAST(N'13:46:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13293, N'67', CAST(N'2022-05-31' AS Date), CAST(N'13:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13294, N'79', CAST(N'2022-05-31' AS Date), CAST(N'13:51:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13295, N'44', CAST(N'2022-05-31' AS Date), CAST(N'13:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13296, N'78', CAST(N'2022-05-31' AS Date), CAST(N'13:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13297, N'43', CAST(N'2022-05-31' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13298, N'92', CAST(N'2022-05-31' AS Date), CAST(N'14:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13299, N'74', CAST(N'2022-05-31' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13300, N'3', CAST(N'2022-05-31' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13301, N'42', CAST(N'2022-05-31' AS Date), CAST(N'14:02:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13302, N'45', CAST(N'2022-05-31' AS Date), CAST(N'14:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13303, N'9', CAST(N'2022-05-31' AS Date), CAST(N'14:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13304, N'58', CAST(N'2022-05-31' AS Date), CAST(N'14:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13305, N'73', CAST(N'2022-05-31' AS Date), CAST(N'14:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13306, N'88', CAST(N'2022-05-31' AS Date), CAST(N'14:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13307, N'72', CAST(N'2022-05-31' AS Date), CAST(N'14:12:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13308, N'51', CAST(N'2022-05-31' AS Date), CAST(N'14:14:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13309, N'6', CAST(N'2022-05-31' AS Date), CAST(N'14:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13310, N'35', CAST(N'2022-05-31' AS Date), CAST(N'14:19:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13311, N'32', CAST(N'2022-05-31' AS Date), CAST(N'14:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13312, N'46', CAST(N'2022-05-31' AS Date), CAST(N'14:30:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13313, N'55', CAST(N'2022-05-31' AS Date), CAST(N'14:43:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13314, N'22', CAST(N'2022-05-31' AS Date), CAST(N'14:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13315, N'56', CAST(N'2022-05-31' AS Date), CAST(N'14:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13316, N'34', CAST(N'2022-05-31' AS Date), CAST(N'14:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13317, N'23', CAST(N'2022-05-31' AS Date), CAST(N'15:02:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13318, N'87', CAST(N'2022-05-31' AS Date), CAST(N'15:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13319, N'33', CAST(N'2022-05-31' AS Date), CAST(N'15:07:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13320, N'31', CAST(N'2022-05-31' AS Date), CAST(N'15:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13321, N'37', CAST(N'2022-05-31' AS Date), CAST(N'15:27:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13322, N'57', CAST(N'2022-05-31' AS Date), CAST(N'15:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13323, N'93', CAST(N'2022-05-31' AS Date), CAST(N'15:52:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13324, N'14', CAST(N'2022-05-31' AS Date), CAST(N'15:57:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13325, N'16', CAST(N'2022-05-31' AS Date), CAST(N'16:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13326, N'39', CAST(N'2022-05-31' AS Date), CAST(N'17:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13327, N'24', CAST(N'2022-05-31' AS Date), CAST(N'17:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13328, N'71', CAST(N'2022-05-31' AS Date), CAST(N'18:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13329, N'12', CAST(N'2022-05-31' AS Date), CAST(N'18:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13330, N'38', CAST(N'2022-05-31' AS Date), CAST(N'18:11:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13331, N'8', CAST(N'2022-05-31' AS Date), CAST(N'19:37:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13332, N'74', CAST(N'2022-05-31' AS Date), CAST(N'19:52:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13333, N'26', CAST(N'2022-05-31' AS Date), CAST(N'19:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13334, N'47', CAST(N'2022-05-31' AS Date), CAST(N'19:54:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13335, N'3', CAST(N'2022-05-31' AS Date), CAST(N'19:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13336, N'77', CAST(N'2022-05-31' AS Date), CAST(N'19:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13337, N'68', CAST(N'2022-05-31' AS Date), CAST(N'19:57:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13338, N'9', CAST(N'2022-05-31' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13339, N'57', CAST(N'2022-05-31' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13340, N'80', CAST(N'2022-05-31' AS Date), CAST(N'19:58:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13341, N'75', CAST(N'2022-05-31' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13342, N'50', CAST(N'2022-05-31' AS Date), CAST(N'19:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13343, N'70', CAST(N'2022-05-31' AS Date), CAST(N'20:00:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13344, N'48', CAST(N'2022-05-31' AS Date), CAST(N'20:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13345, N'82', CAST(N'2022-05-31' AS Date), CAST(N'20:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13346, N'83', CAST(N'2022-05-31' AS Date), CAST(N'20:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13347, N'40', CAST(N'2022-05-31' AS Date), CAST(N'20:05:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13348, N'91', CAST(N'2022-05-31' AS Date), CAST(N'20:08:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13349, N'79', CAST(N'2022-05-31' AS Date), CAST(N'20:09:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13350, N'88', CAST(N'2022-05-31' AS Date), CAST(N'20:19:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13351, N'45', CAST(N'2022-05-31' AS Date), CAST(N'20:20:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13352, N'15', CAST(N'2022-05-31' AS Date), CAST(N'20:23:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13353, N'76', CAST(N'2022-05-31' AS Date), CAST(N'20:23:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13354, N'78', CAST(N'2022-05-31' AS Date), CAST(N'20:28:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13355, N'85', CAST(N'2022-05-31' AS Date), CAST(N'20:31:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13356, N'21', CAST(N'2022-05-31' AS Date), CAST(N'20:44:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13357, N'64', CAST(N'2022-05-31' AS Date), CAST(N'20:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13358, N'81', CAST(N'2022-05-31' AS Date), CAST(N'20:49:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13359, N'69', CAST(N'2022-05-31' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13360, N'29', CAST(N'2022-05-31' AS Date), CAST(N'20:55:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13361, N'55', CAST(N'2022-05-31' AS Date), CAST(N'20:56:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13362, N'72', CAST(N'2022-05-31' AS Date), CAST(N'21:00:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13363, N'28', CAST(N'2022-05-31' AS Date), CAST(N'21:01:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13364, N'62', CAST(N'2022-05-31' AS Date), CAST(N'21:01:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13365, N'37', CAST(N'2022-05-31' AS Date), CAST(N'21:05:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13366, N'65', CAST(N'2022-05-31' AS Date), CAST(N'21:08:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13367, N'33', CAST(N'2022-05-31' AS Date), CAST(N'21:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13368, N'35', CAST(N'2022-05-31' AS Date), CAST(N'21:16:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13369, N'34', CAST(N'2022-05-31' AS Date), CAST(N'21:17:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13370, N'31', CAST(N'2022-05-31' AS Date), CAST(N'21:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13371, N'32', CAST(N'2022-05-31' AS Date), CAST(N'21:26:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13372, N'20', CAST(N'2022-05-31' AS Date), CAST(N'21:33:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13373, N'87', CAST(N'2022-05-31' AS Date), CAST(N'21:42:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13374, N'93', CAST(N'2022-05-31' AS Date), CAST(N'21:46:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13375, N'22', CAST(N'2022-05-31' AS Date), CAST(N'22:04:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13376, N'13', CAST(N'2022-05-31' AS Date), CAST(N'22:31:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13377, N'27', CAST(N'2022-05-31' AS Date), CAST(N'23:10:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13378, N'1', CAST(N'2022-06-01' AS Date), CAST(N'15:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13379, N'1', CAST(N'2022-06-02' AS Date), CAST(N'18:11:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13380, N'1', CAST(N'2022-06-03' AS Date), CAST(N'12:42:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13381, N'1', CAST(N'2022-06-04' AS Date), CAST(N'12:49:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13382, N'1', CAST(N'2022-06-05' AS Date), CAST(N'12:55:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13383, N'1', CAST(N'2022-06-06' AS Date), CAST(N'13:10:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13384, N'1', CAST(N'2022-06-07' AS Date), CAST(N'13:25:00' AS Time), N'3
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13385, N'1', CAST(N'2022-06-08' AS Date), CAST(N'13:34:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13386, N'1', CAST(N'2022-06-09' AS Date), CAST(N'13:48:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13387, N'1', CAST(N'2022-06-10' AS Date), CAST(N'13:55:00' AS Time), N'1
')
GO
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13388, N'1', CAST(N'2022-06-11' AS Date), CAST(N'13:59:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13389, N'1', CAST(N'2022-06-12' AS Date), CAST(N'14:03:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13390, N'1', CAST(N'2022-06-13' AS Date), CAST(N'14:15:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13391, N'1', CAST(N'2022-06-14' AS Date), CAST(N'14:17:00' AS Time), N'1
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13392, N'1', CAST(N'2022-06-01' AS Date), CAST(N'14:48:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13393, N'1', CAST(N'2022-06-02' AS Date), CAST(N'14:53:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13394, N'1', CAST(N'2022-06-03' AS Date), CAST(N'14:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13395, N'1', CAST(N'2022-06-04' AS Date), CAST(N'14:59:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13396, N'1', CAST(N'2022-06-05' AS Date), CAST(N'15:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13397, N'1', CAST(N'2022-06-06' AS Date), CAST(N'15:07:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13398, N'1', CAST(N'2022-06-07' AS Date), CAST(N'15:09:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13399, N'1', CAST(N'2022-06-08' AS Date), CAST(N'15:12:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13400, N'1', CAST(N'2022-06-09' AS Date), CAST(N'15:15:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13401, N'1', CAST(N'2022-06-10' AS Date), CAST(N'15:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13402, N'1', CAST(N'2022-06-11' AS Date), CAST(N'15:18:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13403, N'1', CAST(N'2022-06-12' AS Date), CAST(N'15:21:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13404, N'1', CAST(N'2022-06-13' AS Date), CAST(N'15:24:00' AS Time), N'2
')
INSERT [dbo].[Attendance_Sheet] ([id], [Emp_id], [Attendance_Date], [Time], [Status]) VALUES (13405, N'1', CAST(N'2022-06-14' AS Date), CAST(N'15:30:00' AS Time), N'2
')
SET IDENTITY_INSERT [dbo].[Attendance_Sheet] OFF
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (1, N'DR M. HUSSAIN', N'Suleman', N'4230110097979', N'Flat # 208 Alabbas Center, Shahrah e Liaquat, Karachi', N'03002127895', N'fatimabaihospital@hotmail.com', CAST(N'1971-09-14' AS Date), N'M', N'MS', 92707, CAST(N'11:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'00:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 32, NULL, 5000, NULL, 230, NULL, NULL, NULL, 92707, 40, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (2, N'MUHAMMAD SALMAN', N'Saleem Mohammad', N'4220106140775', N'H 99/13 Patel Para, Jehangir Road West.', N'03338822001', N'msalmany2k@hotmail.com', CAST(N'1981-09-07' AS Date), N'M', N'Accountant', 61000, CAST(N'11:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'12:00:00' AS Time), CAST(N'18:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, 2770, NULL, 230, NULL, NULL, NULL, 61000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (3, N'DR ABRAR KHAN', N'Irshad Ahmed Khan', N'4210162741665', N'H # 746, Block 9, Dastagir, F.B.Area', N'03452676132', N'fatimabaihospital@hotmail.com', CAST(N'1967-02-05' AS Date), N'M', N'Rmo', 60000, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, 1500, NULL, 230, NULL, NULL, NULL, 60000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (4, N'DR ANSAR KHAN ', N'Irshad Ahmed Khan', N'4210132660541', N'H # A-215, Sector 11 A, Gulshan e osman Karachi.', N'03463034810', N'fatimabaihospital@hotmail.com', CAST(N'1957-05-01' AS Date), N'M', N'          Rmo', 55000, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, 2000, NULL, NULL, 1, 31, 55000, 55000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (5, N'DR ANITA ALI FIRDOUS', N'Firdos Ali', N'4220138065570', N'Flat # B 4, GREEN GARDEN , GARDEN EAST, KARACHI', N'03042472972', N'fatimabaihospital@yahoo.com', CAST(N'1957-10-20' AS Date), N'F', N'          Rmo', 65000, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 65000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (6, N'DR YASMEEN ABBAS', N'Mohammad Abbas Haider', N'4220102398993', N'H # B 219, Block 4, Gulshan e Iqbal, Karachi', N'03062465161', N'fatimabaihospital@yahoo.com', CAST(N'1957-11-04' AS Date), N'F', N'          Rmo', 26400, CAST(N'09:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'09:15:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, 503, NULL, 10, 26400, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (7, N'DR. YOUSUF ', N'Aman Khan', N'4250164922557', N'Muhala Machar Colony Super Highyway Mlir', N'03002162127', N'fatimabaihospital@yahoo.com', CAST(N'1989-03-23' AS Date), N'M', N'          Rmo', 60000, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 60000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (8, N'DR. ALI ASGHAR', N'Muhammad Yousuf', N'4210194385321', N'Sakhpuran Madmon Dak khana Sajawal Tahseel Zila Thatta', N'03132837995', N'fatimabaihospital@yahoo.com', CAST(N'1957-12-15' AS Date), N'M', N' Rmo', 60000, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 60000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (9, N'DR. FARKHUNDA', N'zohaib ', N'4230196199982', N'Alfalah Road House No. 2 C 7, Gali No. 07, Mohalla Ahmed, ARCADE Bihar colony Karachi South', N'03463505342', N'farkhunda_razzak@yahoo.com', CAST(N'1992-01-30' AS Date), N'F', N'          Rmo', 65000, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 65000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (10, N'Dr. Samra Saleem', N's/o Syed Salman Pervaiz w/o Salman Zahidi  ', N'4220179968628', N'F-2 Dolmen Arcade, Bahadurabad Karachi', N'03360249791', N'samra.saleem43@yahoo.com', CAST(N'1989-02-16' AS Date), N'F', N'          Rmo', 65000, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 65000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (11, N'Dr. Shahnaaz', N'Qaim Ali Khuwaja', N'4140212134172', N'Goath tar Khuwaja Dak Khana Jati Sattar Zila Sajawal', N'32410178', N'fatimabaihospital@yahoo.com', CAST(N'1976-03-15' AS Date), N'F', N'RMO', 65000, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'F                                                 ', 0, NULL, 2000, NULL, 230, NULL, NULL, NULL, 65000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (12, N'ABDUL RAZZAQ BROHI', N'Eid Mohammad Brohi', N'4250115684463', N'H # G 37/34, Steel Twon Ship, Bin Qasim Karachi.', N'03333867271', N'fatimabaihospital@yahoo.com', CAST(N'1978-01-01' AS Date), N'M', N'Account', 28080, CAST(N'10:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'11:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 28080, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (13, N'SYED UL MUNTAHA', N'Syed Shujauddin', N'4220173611249', N'H # C-12 Opposite Bilal Masjid, Abysinia Line, Lines Area, Karachi.', N'03212695211', N'fatimabaihospital@yahoo.com', CAST(N'1988-11-19' AS Date), N'M', N'LDC', 26400, CAST(N'10:00:00' AS Time), CAST(N'22:00:00' AS Time), CAST(N'11:00:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 26400, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (14, N'Shagufta ', N'Abdul Hafiz', N'4220149972302', N'MALIR ', N'03158694634', N'fatimabaihospital@yahoo.com', CAST(N'1978-05-04' AS Date), N'F', N'Operator', 14000, CAST(N'09:30:00' AS Time), CAST(N'16:00:00' AS Time), CAST(N'09:30:00' AS Time), CAST(N'16:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, 230, NULL, NULL, NULL, 14000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (15, N'Khurram Saeed', N'Ajma Saeed khan', N'4220117354637', N'Al zafar squre plot no 1.k/5 flate no 10-A 4th floor nazimabad', N'03333356008', N'fatimabaihospital@yahoo.com', CAST(N'1979-11-27' AS Date), N'M', N'Store Department', 33000, CAST(N'10:00:00' AS Time), CAST(N'19:00:00' AS Time), CAST(N'10:00:00' AS Time), CAST(N'19:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 33000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (16, N'SITARA ZAIDI', N'Syed Aal e Hassan Zaidi', N'4220125904038', N'H # B-3, Jamshed Road Police Line, Karachi', N'03323599085', N'fatimabaihospital@yahoo.com', CAST(N'1969-01-01' AS Date), N'F', N'Reception', 14719, CAST(N'11:00:00' AS Time), CAST(N'15:00:00' AS Time), CAST(N'11:00:00' AS Time), CAST(N'15:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, 4, 31, 14179, 14719, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (17, N'NASEEM KHAN', N'Irshad Ali Khan', N'4220139142333', N'H # F-88, Jamshed Road # 2, Karachi', N'03313356650', N'fatimabaihospital@yahoo.com', CAST(N'1955-12-01' AS Date), N'M', N'Reception', 14377, CAST(N'15:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'15:15:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 14377, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (18, N'NOOR UDDIN', N'Qamaruddin', N'4210108397361', N'FLAT # 11, Adeel Mini Square, F.B.Area, Karachi', N'03122446647', N'fatimabaihospital@yahoo.com', CAST(N'1957-05-09' AS Date), N'M', N'Reception', 13934, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 13934, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (19, N'MUHAMMAD SAMEER', N'MUHAMMAD IQBAL', N'42401', N'MALIR KARACHI', N'03022696059', N'fatimabaihospital@yahoo.com', CAST(N'1996-01-01' AS Date), N'M', N'RECEPTIONIST', 14000, CAST(N'15:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'15:15:00' AS Time), CAST(N'20:30:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'N', N'0                                                 ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (20, N'SABA KHAN', N'M. Sharif Khan', N'4240187343586', N'Moon apt 1st floor plot no 11 -Dziyauddin hospital nazimabad', N'03178904391', N'fatimabaihospital@yahoo.com', CAST(N'1992-08-14' AS Date), N'F', N'Reception', 30000, CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 30000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (21, N'Hamza Nafees Khan', N'Abdul Nafees khan', N'4250124875199', N'C-I Area Liaquatabad Karachi', N'03218386192', N'fatimabaihospital@yahoo.com', CAST(N'1998-09-20' AS Date), N'M', N'Reception', 19800, CAST(N'21:00:00' AS Time), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'09:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, 230, NULL, NULL, NULL, 19800, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (22, N'WAZEERA ', N'GUL MUHAMMAD BARAN', N'4220136952674', N'HOUSE # B-96 MUHALLA GHOUSIA COLONY, NISHTAR ROAD, KARACHI', N'03336589331', N'fatimabaihospital@yahoo.com', CAST(N'2003-01-10' AS Date), N'F', N'INFORMATION', 14000, CAST(N'15:00:00' AS Time), CAST(N'22:00:00' AS Time), CAST(N'15:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (23, N'Erum Nafees Khan', N'Nafees Khan ', N'4250143192562', N'C-I Area Liaquatabad Karachi', N'03241835744', N'fatimabaihospital@yahoo.com', CAST(N'1997-06-16' AS Date), N'F', N'Information', 14000, CAST(N'08:00:00' AS Time), CAST(N'15:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'15:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 14000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (24, N'Malik Kiran Israr', N'Aas Muhammad', N'4220104673262', N'H/no26/A near 104 Jmashad', N'03147112596', N'fatimabaihospital@yahoo.com', CAST(N'1983-01-22' AS Date), N'F', N'Asstt. Account', 20000, CAST(N'10:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'10:15:00' AS Time), CAST(N'17:30:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, 2, 31, 20000, 20000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (25, N'Nida', N'Muhammad Asif', N'4220143774016', N'Flat no G-217 apt garden', N'03352294823', N'fatimabaihospital@yahoo.com', CAST(N'1985-10-11' AS Date), N'F', N'Operator', 14000, CAST(N'16:00:00' AS Time), CAST(N'22:00:00' AS Time), CAST(N'16:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 14000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (26, N'AFTAB AHMED SAMOO', N'Allah Bachya Samoo', N'4230131307721', N'H # 127-A-1, Street # 12, Bihar Colony # 1, Lyari, Karachi', N'03333506226', N'fatimabaihospital@yahoo.com', CAST(N'1965-01-01' AS Date), N'M', N'Maintenance Supervisor', 45000, CAST(N'11:30:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'11:30:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 45000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (27, N'JAVED AKHTER ', N'Mohammad Haneef', N'4240164746143', N'H # H 457, Block L, Wilayat Ali Shah Colony, Sector 11 , Orangi Twon.', N'03412074281', N'fatimabaihospital@yahoo.com', CAST(N'1963-01-01' AS Date), N'M', N'Gen Operatoer', 23466, CAST(N'10:00:00' AS Time), CAST(N'22:00:00' AS Time), CAST(N'10:15:00' AS Time), CAST(N'21:30:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 23466, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (28, N'Abdullah ', N'Peer Bakhsh', N'4240171038713', N'H. no 7F 226 stree 32 faisal bloach orangi', N'0000', N'fatimabaihospital@yahoo.com', CAST(N'1987-03-22' AS Date), N'M', N'Wardboy', 16500, CAST(N'10:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'10:00:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 16500, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (29, N'M AKRAM', N'Mohammad Yaqoob', N'4210135803867', N'H # 7/6, C-1 Area, Liaquatabad, Karachi', N'03332380889', N'fatimabaihospital@yahoo.com', CAST(N'1976-06-03' AS Date), N'M', N'X Ray', 35190, CAST(N'10:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'10:00:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, 307, NULL, 5, 35190, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (30, N'SARWAR KHAN AWAN', N'Sher Ahmed', N'4230143538549', N'Flat # E-801,Belle View Towers, Block E, Garden East, Karachi.', N'03332241422', N'fatimabaihospital@yahoo.com', CAST(N'1958-02-24' AS Date), N'M', N'OT Incharg', 21144, CAST(N'03:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'03:30:00' AS Time), CAST(N'20:45:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 21144, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (31, N'MOZZAMULLAH KHAN', N'Naimatullah Khan', N'4220134712253', N'Quarter # 20, Civil Hospital Quarters, karachi', N'03012627694', N'fatimabaihospital@yahoo.com', CAST(N'1963-01-01' AS Date), N'M', N'OT Tec', 17732, CAST(N'03:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'03:15:00' AS Time), CAST(N'21:15:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 17732, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (32, N'NABIL AWAN', N'Mohammad Ismail', N'4230141446565', N'Flat # 206, 2nd Floor, Al Habib Arcade, Plot # 151, Jam Street, Garden west.', N'03453301125', N'fatimabaihospital@yahoo.com', CAST(N'1990-04-24' AS Date), N'M', N'OT Tec', 17193, CAST(N'15:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'15:15:00' AS Time), CAST(N'21:15:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 17193, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (33, N'MOHAMMAD ASLAM', N'Maroof Khan', N'4230107663853', N'Quarter # 4, Civil Hospital Quarters, karachi', N'03322428065', N'fatimabaihospital@yahoo.com', CAST(N'1963-01-01' AS Date), N'M', N'OT Wardboy', 13340, CAST(N'15:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'15:00:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 13340, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (34, N'SAMEER AHMED', N'Akhtar Ali', N'4230150686659', N'House no K 21 street no 8 gabol road kla koat liyari karaci', N'03242424197', N'fatimabaihospital@yahoo.com', CAST(N'1994-01-01' AS Date), N'M', N'OT Tec', 17250, CAST(N'15:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'15:15:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 17250, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (35, N'UBAID', N'Abdul Majeed', N'4230159684273', N'Street no 10 Gul muhammd leen Liyari Siddique Hotel Krachi', N'03032775697', N'fatimabaihospital@yahoo.com', CAST(N'1995-11-20' AS Date), N'M', N'OT Tec', 11900, CAST(N'15:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'15:15:00' AS Time), CAST(N'20:30:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 11900, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (36, N'Ahmed Zaib Khan ', N'Pasha Gul', N'15505-0280268-1', N'Dairan sar kozpao dak khana tahsil puran zila shakla', N'', N'-', CAST(N'1981-09-07' AS Date), N'M', N'Aid nurse', 32000, NULL, NULL, NULL, NULL, N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'Nursing                                           ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 32000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (37, N'MUKESH', N'Kirshan', N'4230108255197', N'Kmc ramsawami  tawer gazdar abad nishtar road saddar karachi', N'00', N'fatimabaihospital@yahoo.com', CAST(N'1997-05-13' AS Date), N'M', N'OT Sweeper', 10580, CAST(N'14:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'14:15:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, NULL, NULL, NULL, 10580, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (38, N'PERVAIZ AKHTAR', N'Manshe Dad', N'4230124581001', N'H # 6, street N/9/H Agra Taj Colony, Karachi', N'03012480093', N'fatimabaihospital@yahoo.com', CAST(N'1964-11-06' AS Date), N'M', N'Supervisor', 24740, CAST(N'10:00:00' AS Time), CAST(N'16:00:00' AS Time), CAST(N'10:15:00' AS Time), CAST(N'16:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, 1, 31, 24740, 24740, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (39, N'JABRAN KHAN', N'Fatha Khan', N'4240189983605', N'H # 405, Sector A, Mohammad Pure, Qasba Colony, Nr Paracha Hospital, Manghopir Road', N'03122829872', N'fatimabaihospital@yahoo.com', CAST(N'1993-01-12' AS Date), N'M', N'Supervisor', 20000, CAST(N'16:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'16:15:00' AS Time), CAST(N'07:45:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, 31, 31, 32000, 20000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (40, N'Farooq', N'Muhammad Ghani', N'15302-9640488-1', N'Katan Pain Dak Khana Bagh do Shakeel Taimair Girah Zila Loyer Dair ', N'', N'-', CAST(N'1981-09-07' AS Date), N'M', N'Staffnurse', 22000, NULL, NULL, NULL, NULL, N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'Nursing                                           ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 22000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (41, N'Shahina ', N'Meer Baiz Khan', N'4210160114296', N'Flate no 479-Sultana bad colony gul bahar no 1', N'03482099600', N'fatimabaihospital@yahoo.com', CAST(N'1992-04-20' AS Date), N'F', N'Staff nurse', 23000, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 23000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (42, N'Shabnam ', N'SHER Afzal', N'4240137307986', N'Par Wak Bla Dak Kahan tahseel zila chitral', N'00', N'fatimabaihospital@yahoo.com', CAST(N'2000-06-04' AS Date), N'F', N'Aid nurse', 16500, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 16500, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (43, N'Munawar Sultana ', N'ff', N'111', N'ff', N'000000000000', N'fatimabaihospital@yahoo.com', CAST(N'1981-09-07' AS Date), N'F', N'Midwife', 17000, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 17000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (44, N'Sharoon', N'Robin Sun', N'4220119172856', N'H, no. 35 c/ 147 Liyari Taiser Town Krachi', N'03303164885', N'fatimabaihospital@yahoo.com', CAST(N'1992-01-11' AS Date), N'F', N'Staff nurse', 18500, CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, 2, 31, 18500, 18500, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (45, N'Perveen', N'Zaar khan', N'1520166903934', N'Zila barshgram karimabad chitral', N'03498496500', N'fatimabaihospital@yahoo.com', CAST(N'1997-03-15' AS Date), N'F', N'Staff nurse', 18150, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 18150, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (46, N'Gulnaz', N'Noor Malik Shah', N'4240121358308', N'Street no 3 sec .4 orangi town karachi', N'03482241630', N'fatimabaihospital@yahoo.com', CAST(N'2002-04-02' AS Date), N'F', N'Aid nurse', 16500, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 16500, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (47, N'HUMAIRA NOUREEN', N'Noman Qayum Khan', N'4230108670962', N'Flat # 3, Karim Manzil, Jamila street, Jubilee Cinema, Karachi', N'03100278177', N'fatimabaihospital@yahoo.com', CAST(N'1981-06-08' AS Date), N'F', N'Mid wife', 18360, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 18360, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (48, N'Naseema ', N'Fidos khan', N'1520130828390', N'Bhy Hospital near choti masjid street no, 4clifton karachi', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1997-03-20' AS Date), N'F', N'Mid wife', 28000, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 28000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (49, N'Saima Maqsood', N'Syed maqsood ali', N'4220135959892', N'H. no F -205/1 martin Q/R jahangir road', N'03032920902', N'fatimabaihospital@yahoo.com', CAST(N'1979-11-04' AS Date), N'F', N'Aid nurse', 26400, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'Y', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 26400, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (50, N'Shehla ', N'Samad khan', N'152014614078', N'Muhala orak dak khana  garam chshma chitral', N'0000', N'fatimabaihospital@yahoo.com', CAST(N'1996-01-02' AS Date), N'F', N'OT staff', 20700, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20700, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (51, N'ZUBAIDA  ', N'Anjum Khan', N'4210178396230', N'H # 1324, Block 8, Azizabad, F.B.Area, Karachi', N'4210178396230', N'fatimabaihospital@yahoo.com', CAST(N'1987-02-15' AS Date), N'F', N'Staff nurse', 20040, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20040, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (52, N'Humaira D/O Sawat Khan', N'Mir Sawat Khan', N'4230108670962', N'White Arkari Citral', N'03112935956', N'fatimabaihospital@yahoo.com', CAST(N'1981-06-08' AS Date), N'F', N'Midwife', 28000, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'Y', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 28000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (53, N'SOFIA SHOUKAT', N'EUBERT', N'4210106534366', N'H.no51/A PWD Mrtin Q/R Jamshed road.no 3', N'03433194497', N'fatimabaihospital@yahoo.com', CAST(N'1985-02-25' AS Date), N'F', N'Staff nurse', 18000, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 18000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (54, N'FARHAT GILL', N'Nelson Gill', N'4230182821582', N'H # 1490, Street #25 Azam Town Karachi.', N'03441323578', N'fatimabaihospital@yahoo.com', CAST(N'1971-12-18' AS Date), N'F', N'Staff nurse', 22425, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'N', N'Y', N'Y', N'Y', N'Y', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 22425, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (55, N'LUBNA', N'Feroz Ali Khyiani', N'4220191640622', N'H. 13 P I B colony khuwaja compound karachi', N'03362001673', N'fatimabaihospital@yahoo.com', CAST(N'1972-08-27' AS Date), N'F', N'Aid nurse', 15000, CAST(N'15:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'15:00:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 15000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (56, N'HABIBUN NISA', N'Abdul Lateef', N'4210138737354', N'H # 112, Sector 4, Rehmania Mor, North Karachi', N'03343754323', N'fatimabaihospital@yahoo.com', CAST(N'1944-01-01' AS Date), N'F', N'Midwife', 16964, CAST(N'08:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, 2, 31, 16964, 16964, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (57, N'SHAMIM BANO', N'Zahoor Khan', N'4210114564384', N'H # A-13/3 Azam Nagar, Liaquatabad, Karachi', N'03172675782', N'fatimabaihospital@yahoo.com', CAST(N'1969-04-12' AS Date), N'F', N'Staff ', 21000, CAST(N'15:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'15:15:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 21000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (58, N'MOHAMMAD ARIF', N'MOHAMMAD ALI', N'4210114206447', N'H # 250, Street # 11, Ferozabad Colony, Nazimabad, Karachi.', N'03022686915', N'fatimabaihospital@yahoo.com', CAST(N'1956-01-01' AS Date), N'M', N'Aid nurse', 17250, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, 1, 31, 17250, 17250, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (59, N'MOHAMMAD RAFIQ', N'Sher Khan', N'4220107942209', N'H # E-821, 100 Quarters, Korangi.', N'03131120374', N'fatimabaihospital@yahoo.com', CAST(N'1971-12-31' AS Date), N'M', N'Aid nurse', 27541, CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, 2, 31, 27541, 27541, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (60, N'ARSHAD MASIH', N'Patras Masih', N'4220121129589', N'H # 632, Sector B, Nasir Colony, Korangi No 1.', N'03442410500', N'fatimabaihospital@yahoo.com', CAST(N'1983-04-20' AS Date), N'M', N'Aid nurse', 20400, CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, 25000, NULL, NULL, 230, NULL, NULL, 30000, 20400, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (61, N'CHRISTOPHER JHON', N'Arif Tanveer', N'4210164698845', N'H # A-60, Rizvia Imaam Bargha, Golimar Chorangi, Karachi.', N'03145877138', N'fatimabaihospital@yahoo.com', CAST(N'1992-01-05' AS Date), N'M', N'Aid nurse', 27600, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, 7, 31, 27600, 27600, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (62, N'TAHIR FAKHAR', N'Fakhar Uddin', N'4220137085801', N'House no H. S Jahangir road west karachi', N'03003344979', N'fatimabaihospital@yahoo.com', CAST(N'1986-01-01' AS Date), N'M', N'Wardboy', 17600, CAST(N'22:00:00' AS Time), CAST(N'09:00:00' AS Time), CAST(N'22:00:00' AS Time), CAST(N'09:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, 31, 1, 17600, 17600, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (63, N'MOHAMMAD TARIQ', N'Mohammad Aslam', N'4230141910445', N'H # RC 10/18 Mahajin wari Compound Ghazdarabad Nishter Road', N'03452805179', N'fatimabaihospital@yahoo.com', CAST(N'1990-02-04' AS Date), N'M', N'Wardboy', 13050, CAST(N'10:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'10:00:00' AS Time), CAST(N'09:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 13050, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (64, N'AMJAD', N'Mohammad Azeem', N'4220128008487', N'H # 172/71 Jehangir Road, Baloch Para', N'03153689044', N'fatimabaihospital@yahoo.com', CAST(N'1989-09-15' AS Date), N'M', N'Wardboy', 20000, CAST(N'09:00:00' AS Time), CAST(N'19:00:00' AS Time), CAST(N'09:00:00' AS Time), CAST(N'19:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, 4, 31, 20000, 20000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (65, N'SALMAN YOUNUS', N'Mohammad Younus', N'4230155177199', N'Flat # 49, 5th Floor, Al Siddiq Center, Shoe Market, Amli Street Karachi.', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1985-05-13' AS Date), N'M', N'Wardboy', 21584, CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 21584, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (66, N'Raees ', N'Muhammad Aslam', N'00', N'Street no 15 ,Mohala new kumarwara liyari dak khana chakiwara karachi', N'00', N'fatimabaihospital@yahoo.com', CAST(N'1981-01-01' AS Date), N'M', N'Wardboy', 15000, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 15000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (67, N'Yawar', N'Jmeel ud Din', N'4210194985657', N'Flate no B- 5/8 Azam nagar liaqtabad karachi', N'000', N'fatimabaihospital@yahoo.com', CAST(N'2001-08-22' AS Date), N'M', N'Ward boy', 8250, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 8250, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (68, N'Sabir', N'Shamsul Isalm', N'4230123693267', N'1 floor kmc Q/R Jinah Abad no 2 flat no 9/44', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1987-08-15' AS Date), N'M', N'Ward boy', 16500, CAST(N'08:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'18:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 16500, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (69, N'YAQOOB KHAN', N'Zar Mohammad ', N'4220128337599', N'H # M-104/12, Near Quarter F-372, Patel Para, Karachi', N'0000', N'fatimabaihospital@yahoo.com', CAST(N'1984-12-25' AS Date), N'M', N'Ward boy', 17250, CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, 3, 31, 17250, 17250, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (70, N'M ZABOOR', N'Kareem Daad', N'4220105102181', N'H # F/193/A Jehangir Road West, Patel Para.', N'00', N'fatimabaihospital@yahoo.com', CAST(N'1974-01-01' AS Date), N'M', N'Driver', 22422, CAST(N'20:00:00' AS Time), CAST(N'09:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'09:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 22422, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (71, N'SEEMA BIBI', N'Arif Masih', N'4230160681514', N'Dhak Tabaela, Near Jubilee Cenima, Karachi', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1970-12-03' AS Date), N'F', N'Aya', 8980, CAST(N'11:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'11:00:00' AS Time), CAST(N'18:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 8980, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (72, N'FOUZIA NAZ', N'Mohammad Azeem', N'3740555777054', N'H # 236 Dhok Rata, Block A Railway Quarter, Rawal Pindi', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1984-01-01' AS Date), N'F', N'Aya', 10560, CAST(N'00:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'00:00:00' AS Time), CAST(N'18:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, 230, 1, 31, 10560, 10560, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (73, N'Kainaat ', N'M Yaqoob khan', N'4210114247635', N'H/ no  2040 sikandar azam nagar liaqat abad akarachi dak khana', N'0000', N'fatimabaihospital@yahoo.com', CAST(N'1988-06-17' AS Date), N'F', N'Aya', 8500, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 8500, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (74, N'Sumaira', N'Waqas Hussain khan', N'424010309926', N'House no 222 sec 8 A orangi town', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1984-01-08' AS Date), N'F', N'Aya', 10000, CAST(N'00:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'00:00:00' AS Time), CAST(N'18:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 10000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (75, N'Zainab', N'Ghulam Abbas', N'4230107088518', N'Line zairia  H/no  A 9 bilding nizami road ', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1981-09-07' AS Date), N'F', N'Aya', 14950, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14950, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (76, N'Kulsoom', N'Muhammad Umer', N'4230134069143', N'1st floor babar plaza  gawadar', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1960-10-08' AS Date), N'F', N'Aya', 13800, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 13800, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (77, N'Haleema', N'Muahammad Hroon', N'4230107018380', N'Mustafa bilding Flate no 1 usmana abad', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1978-01-01' AS Date), N'F', N'Aya', 8250, CAST(N'00:00:00' AS Time), CAST(N'18:00:00' AS Time), CAST(N'00:00:00' AS Time), CAST(N'18:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, 3, 31, 8250, 8250, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (78, N'RAZIA ', N'Amanullah', N'4210106816300', N'Flat # D-23, 4th Floor, Rahel Plaza, North karachi', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1954-01-01' AS Date), N'F', N'Aya', 9240, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 9240, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (79, N'Anila Asif', N'Muhammad ASIF', N'4230102175220', N'1 floor ghanchi bilding old haji camp flate no 11kaka .karachi', N'03222835876', N'fatimabaihospital@yahoo.com', CAST(N'1978-01-01' AS Date), N'F', N'Aya', 8000, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 8000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (80, N'SHAMIM AKHTER', N'Mehmood Ali', N'4210135567596', N'H # 1/554, Sultanabad, Firdous Colony, Gulbahar, Karachi', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1957-01-01' AS Date), N'F', N'Aya', 10500, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, 5, 31, 10500, 10500, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (81, N'SAJIDA', N'Mohammad Azeem', N'4200075457794', N'H # 172/71 Jehangir Road, Baloch Para', N'00', N'fatimabaihospital@yahoo.com', CAST(N'1966-01-01' AS Date), N'F', N'Aya', 18900, CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time), CAST(N'09:00:00' AS Time), CAST(N'21:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 18900, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (82, N'Abdul Hameed', N'Bihar khan', N'5440066063053', N'Saryab road kali chaktan gahi khan chok koeta', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1965-01-01' AS Date), N'M', N'Watch man', 15000, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 15000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (83, N'Azeem', N'Raees ahmad siddique', N'4210114400747', N'Lalo khet C.1 Area k. 7/A liaqta abad karachi', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1963-01-01' AS Date), N'M', N'Watch man', 15000, CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 15000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (84, N'MUHAMMAD JAVED ', N'KALLO', N'4210120852197', N'Makan no 2/B gulistan e johar block 8 karachi', N'03158405252', N'fatimabaihospital@yahoo.com', CAST(N'1988-01-05' AS Date), N'M', N'AID NURSE', 25000, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (85, N'Shareefullah', N'Dunya Khan', N'1550563072987', N'Kadorai koaz pao tahseel puran zila shangla', N'000', N'fatimabaihospital@yahoo.com', CAST(N'1997-02-04' AS Date), N'M', N'Aid nurse', 20000, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (86, N'KabIra', N'Abdul Raheem', N'030367686854', N'Flate no 367 AL AmIN 37 Garden West Karachi  Sindh', N'03461811864', N'fatimabaihospital@yahoo.com', CAST(N'1981-09-07' AS Date), N'F', N'Mid wife', 17000, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 17000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (87, N'Deepak', N'Ksoor Bhana', N'4220157804227', N'H, no 87 ,Chand Bibi Road Rancor line Karachi ', N'000', N'fatimabaihospital@yahoo.com', CAST(N'2000-09-15' AS Date), N'M', N'Sweeper', 10000, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 10000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (88, N'Faiza ', N'Jumait Ali', N'4240160361920', N'H.187, sec A muhammad village old golimar karachi', N'00', N'fatimabaihospital@yahoo.com', CAST(N'1997-06-16' AS Date), N'F', N'Aid nurse', 16500, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 16500, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (89, N'Maida Khokhar', N'Alin Khokar ', N'4230118581450', N'Flate no 7 Niyazi chok darya abad  liyari kharachi', N'03242705103', N'fatimabaihospital@yahoo.com', CAST(N'1980-07-31' AS Date), N'F', N'Receptionist', 20000, CAST(N'09:00:00' AS Time), CAST(N'17:00:00' AS Time), CAST(N'09:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (90, N'Haseeb', N'Babud Deen', N'4230190108733', N'Flate no 33 anees plaza badshahi road  shoe market', N'00', N'fatimabaihospital@yahoo.com', CAST(N'2004-09-27' AS Date), N'M', N'Ward boy', 7700, CAST(N'17:00:00' AS Time), CAST(N'23:00:00' AS Time), CAST(N'17:00:00' AS Time), CAST(N'23:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7700, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (91, N'QADIRULLAH', N'00', N'00', N'Sunwan dak khana khas tahseel koat adoo zila muzafar goath', N'00', N'fatimabaihospital@yahoo.com', CAST(N'1981-09-07' AS Date), N'M', N'AID NURSE', 17000, CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 17000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (92, N'Zehrish', N'Qmar uz zaman', N'361047136800', N'Soldier bazar no 3 Domocian Sister house', N'00', N'fatimabaihospital@yahoo.com', CAST(N'1994-05-12' AS Date), N'F', N'Staff nurse', 17000, CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'14:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 17000, NULL, NULL)
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (93, N'Shabana ', N'Muhammad Hamid', N'4240116193400', N'H, no 205, Street no 5, Mohala Data nagr Orangi Town Krachi', N'03422941706', N'fatimabaihospital@yahoo.com', CAST(N'1982-12-02' AS Date), N'F', N'Aya', 10000, CAST(N'14:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time), N'Y', N'Y', N'Y', N'Y', N'Y', N'Y', N'N', N'Y', N'F                                                 ', 0, 99, 200, 100, 700, 15, 31, 2000, 10000, NULL, CAST(N'2001-01-01' AS Date))
INSERT [dbo].[Employee] ([Emp_id], [Name], [Father_Name], [CNIC], [address], [Phone], [Email], [Date_of_Birth], [Gender], [Designation], [Gross_Salary], [Time_In], [Time_Out], [Grace_Time_IN], [Grace_Time_Out], [Monday_WD], [Tuesday_WD], [Wednesday_WD], [Thursday_WD], [Friday_WD], [Saturday_WD], [Sunday_WD], [Status], [Job_type], [Leaves], [Adv_staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Days], [Overtime_Rate], [Gross_Salary01], [Total_Leaves], [Date_joining]) VALUES (94, N'MUSHRAF ILYAS ', N'ILYAS ', N'3610410829925', N'A-1 CENTRE', N'03126346133', N'FATIMABAIHOSPITAL@YAHOO.COM', CAST(N'1980-05-15' AS Date), N'M', N'AID NURSE ', 15000, CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), CAST(N'08:00:00' AS Time), CAST(N'20:00:00' AS Time), N'N', N'Y', N'N', N'Y', N'Y', N'Y', N'N', N'N', N'F                                                 ', 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 15000, 33, CAST(N'1996-07-20' AS Date))
SET IDENTITY_INSERT [dbo].[Holiday] ON 

INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (1, CAST(N'2021-02-17' AS Date), N'Kashmir days', NULL, NULL)
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (2, CAST(N'2021-02-27' AS Date), N'Pakistan Day', NULL, NULL)
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (1002, CAST(N'2021-01-01' AS Date), N'Maire Day', NULL, NULL)
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (1003, CAST(N'2021-03-25' AS Date), N'tery Day', NULL, NULL)
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (1004, CAST(N'2022-06-01' AS Date), N'eid 01', NULL, CAST(N'2022-06-02' AS Date))
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (1005, CAST(N'2022-05-05' AS Date), N'eid 02', NULL, CAST(N'2022-06-02' AS Date))
INSERT [dbo].[Holiday] ([id], [H_Date], [H_Reason], [created_by], [created_date]) VALUES (1006, CAST(N'2022-05-04' AS Date), N'eid 02', NULL, CAST(N'2022-06-02' AS Date))
SET IDENTITY_INSERT [dbo].[Holiday] OFF
SET IDENTITY_INSERT [dbo].[Login] ON 

INSERT [dbo].[Login] ([id], [User_Name], [Email], [Password], [User_status], [U_Pic]) VALUES (1, N'Sahal', N's.m.sahal786@outlook.com', N'1234', N'Y', NULL)
SET IDENTITY_INSERT [dbo].[Login] OFF
SET IDENTITY_INSERT [dbo].[Payroll] ON 

INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (857, 3, CAST(N'2022-05-28' AS Date), 54, 0, 0, 0, 22, 102786, 0, 1500, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (858, 4, CAST(N'2022-05-28' AS Date), 29, 0, 0, 0, 22, 51226, 0, 2000, 0, 0, 1, 55000, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (859, 5, CAST(N'2022-05-28' AS Date), 29, 0, 0, 0, 22, 60806, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (860, 6, CAST(N'2022-05-28' AS Date), 48, 0, 0, 0, 22, 45907, 0, 0, 0, 0, 503, 10, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (861, 7, CAST(N'2022-05-28' AS Date), 36, 0, 0, 0, 0, 69677, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (862, 8, CAST(N'2022-05-28' AS Date), 36, 0, 0, 0, 0, 69677, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (863, 9, CAST(N'2022-05-28' AS Date), 53, 0, 0, 0, 22, 111129, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (864, 10, CAST(N'2022-05-28' AS Date), 7, 0, 0, 0, 0, 14677, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (865, 11, CAST(N'2022-05-28' AS Date), 35, 0, 0, 0, 0, 71157, 0, 2000, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (866, 12, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 46872, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (867, 13, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 44054, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (868, 14, CAST(N'2022-05-28' AS Date), 30, 0, 0, 0, 0, 13318, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (869, 15, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 55125, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (870, 16, CAST(N'2022-05-28' AS Date), 48, 0, 0, 0, 22, 24390, 0, 0, 0, 230, 4, 14179, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (871, 17, CAST(N'2022-05-28' AS Date), 40, 0, 0, 0, 22, 18321, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (872, 18, CAST(N'2022-05-28' AS Date), 50, 0, 0, 0, 22, 22244, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (873, 20, CAST(N'2022-05-28' AS Date), 53, 0, 0, 0, 22, 51060, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (874, 21, CAST(N'2022-05-28' AS Date), 38, 0, 0, 0, 0, 24041, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (875, 22, CAST(N'2022-05-28' AS Date), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (876, 23, CAST(N'2022-05-28' AS Date), 49, 0, 0, 0, 22, 21899, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (877, 24, CAST(N'2022-05-28' AS Date), 49, 0, 0, 0, 22, 32673, 0, 0, 0, 230, 2, 20000, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (878, 25, CAST(N'2022-05-28' AS Date), 33, 0, 0, 0, 22, 14673, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (879, 26, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 75254, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (880, 27, CAST(N'2022-05-28' AS Date), 56, 0, 0, 0, 22, 42160, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (881, 28, CAST(N'2022-05-28' AS Date), 56, 0, 0, 0, 22, 29806, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (882, 29, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 60333, 0, 0, 0, 230, 307, 5, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (883, 30, CAST(N'2022-05-28' AS Date), 29, 0, 0, 0, 22, 19780, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (884, 31, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 29514, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (885, 32, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 28610, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (886, 33, CAST(N'2022-05-28' AS Date), 45, 0, 0, 0, 22, 19135, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (887, 34, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 28705, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (888, 35, CAST(N'2022-05-28' AS Date), 53, 0, 0, 0, 22, 20115, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (889, 36, CAST(N'2022-05-28' AS Date), 7, 0, 0, 0, 0, 7226, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (890, 37, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 17517, 0, 0, 0, 230, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (891, 38, CAST(N'2022-05-28' AS Date), 55, 0, 0, 0, 22, 44462, 0, 0, 0, 230, 1, 24740, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (892, 39, CAST(N'2022-05-28' AS Date), 57, 0, 0, 0, 22, 68544, 0, 0, 0, 230, 31, 32000, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (893, 40, CAST(N'2022-05-28' AS Date), 37, 0, 0, 0, 0, 26258, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (894, 41, CAST(N'2022-05-28' AS Date), 31, 0, 0, 0, 0, 23000, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (895, 42, CAST(N'2022-05-28' AS Date), 32, 0, 0, 0, 0, 17032, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (896, 43, CAST(N'2022-05-28' AS Date), 31, 0, 0, 0, 0, 17000, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (897, 44, CAST(N'2022-05-28' AS Date), 55, 0, 0, 0, 22, 34016, 0, 0, 0, 0, 2, 18500, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (898, 45, CAST(N'2022-05-28' AS Date), 57, 0, 0, 0, 22, 33373, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (899, 46, CAST(N'2022-05-28' AS Date), 32, 0, 0, 0, 0, 17032, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (900, 47, CAST(N'2022-05-28' AS Date), 50, 0, 0, 0, 22, 29613, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (901, 48, CAST(N'2022-05-28' AS Date), 36, 0, 0, 0, 0, 32516, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (902, 49, CAST(N'2022-05-28' AS Date), 59, 0, 0, 0, 22, 50245, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (903, 50, CAST(N'2022-05-28' AS Date), 37, 0, 0, 0, 0, 24706, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (904, 51, CAST(N'2022-05-28' AS Date), 58, 0, 0, 0, 22, 37494, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (905, 52, CAST(N'2022-05-28' AS Date), 38, 0, 0, 0, 0, 34323, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (906, 53, CAST(N'2022-05-28' AS Date), 58, 0, 0, 0, 22, 33677, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (907, 54, CAST(N'2022-05-28' AS Date), 29, 0, 0, 0, 22, 20978, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (908, 55, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 25161, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (909, 56, CAST(N'2022-05-28' AS Date), 47, 0, 0, 0, 22, 26814, 0, 0, 0, 0, 2, 16964, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (910, 57, CAST(N'2022-05-28' AS Date), 51, 0, 0, 0, 22, 34548, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (911, 58, CAST(N'2022-05-28' AS Date), 54, 0, 0, 0, 22, 30605, 0, 0, 0, 0, 1, 17250, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (912, 59, CAST(N'2022-05-28' AS Date), 51, 0, 0, 0, 22, 47086, 0, 0, 0, 0, 2, 27541, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (913, 60, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 8989, 25000, 0, 0, 230, 0, 30000, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (914, 61, CAST(N'2022-05-28' AS Date), 42, 0, 0, 0, 22, 43626, 0, 0, 0, 0, 7, 27600, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (915, 62, CAST(N'2022-05-28' AS Date), 55, 0, 0, 0, 22, 576826, 0, 0, 0, 0, 31, 17600, 1)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (916, 63, CAST(N'2022-05-28' AS Date), 39, 0, 0, 0, 22, 16418, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (917, 64, CAST(N'2022-05-28' AS Date), 46, 0, 0, 0, 22, 32258, 0, 0, 0, 0, 4, 20000, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (918, 65, CAST(N'2022-05-28' AS Date), 56, 0, 0, 0, 22, 38990, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (919, 66, CAST(N'2022-05-28' AS Date), 34, 0, 0, 0, 0, 16452, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (920, 67, CAST(N'2022-05-28' AS Date), 49, 0, 0, 0, 22, 13040, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (921, 68, CAST(N'2022-05-28' AS Date), 53, 0, 0, 0, 22, 28210, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (922, 69, CAST(N'2022-05-28' AS Date), 51, 0, 0, 0, 22, 29818, 0, 0, 0, 230, 3, 17250, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (923, 70, CAST(N'2022-05-28' AS Date), 57, 0, 0, 0, 22, 41228, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (924, 71, CAST(N'2022-05-28' AS Date), 54, 0, 0, 0, 22, 15643, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (925, 72, CAST(N'2022-05-28' AS Date), 52, 0, 0, 0, 22, 17824, 0, 0, 0, 230, 1, 10560, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (926, 73, CAST(N'2022-05-28' AS Date), 33, 0, 0, 0, 0, 9048, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (927, 74, CAST(N'2022-05-28' AS Date), 29, 0, 0, 0, 0, 9355, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (928, 75, CAST(N'2022-05-28' AS Date), 60, 0, 0, 0, 22, 28935, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (929, 76, CAST(N'2022-05-28' AS Date), 59, 0, 0, 0, 22, 26265, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (930, 77, CAST(N'2022-05-28' AS Date), 47, 0, 0, 0, 22, 13306, 0, 0, 0, 0, 3, 8250, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (931, 78, CAST(N'2022-05-28' AS Date), 53, 0, 0, 0, 22, 15797, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (932, 79, CAST(N'2022-05-28' AS Date), 22, 0, 0, 0, 0, 5677, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (933, 80, CAST(N'2022-05-28' AS Date), 43, 0, 0, 0, 22, 16258, 0, 0, 0, 0, 5, 10500, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (934, 81, CAST(N'2022-05-28' AS Date), 55, 0, 0, 0, 22, 33532, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (935, 82, CAST(N'2022-05-28' AS Date), 58, 0, 0, 0, 22, 28065, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (936, 83, CAST(N'2022-05-28' AS Date), 33, 0, 0, 0, 0, 15968, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (937, 84, CAST(N'2022-05-28' AS Date), 7, 0, 0, 0, 0, 5645, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (938, 85, CAST(N'2022-05-28' AS Date), 36, 0, 0, 0, 0, 23226, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (939, 86, CAST(N'2022-05-28' AS Date), 38, 0, 0, 0, 0, 20839, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (940, 87, CAST(N'2022-05-28' AS Date), 30, 0, 0, 0, 0, 9677, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (941, 88, CAST(N'2022-05-28' AS Date), 29, 0, 0, 0, 0, 15435, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (942, 89, CAST(N'2022-05-28' AS Date), 50, 0, 0, 0, 22, 32258, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (943, 90, CAST(N'2022-05-28' AS Date), 11, 0, 0, 0, 0, 2732, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (944, 91, CAST(N'2022-05-28' AS Date), 32, 0, 0, 0, 0, 17548, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (945, 92, CAST(N'2022-05-28' AS Date), 29, 0, 0, 0, 0, 15903, 0, 0, 0, 0, 0, 0, 0)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (946, 93, CAST(N'2022-05-28' AS Date), 25, 0, 0, 0, 0, 7933, 99, 200, 100, 700, 15, 2000, 31)
INSERT [dbo].[Payroll] ([id], [Emp_id], [Pyoll_Date], [Working_Days], [Working_Hours], [Holidays], [Current_Abcent], [Leaves], [Gross_Salary], [Adv_Staff], [I_Tax], [Telephone], [EOBI], [Overtime_day], [Overtime_Rate], [Days]) VALUES (1921, 1, CAST(N'2022-06-28' AS Date), 29, 0, 0, 0, 10, 84387, 0, 5000, 0, 230, 0, 0, 0)
SET IDENTITY_INSERT [dbo].[Payroll] OFF
INSERT [dbo].[sales] ([id], [Sale_name]) VALUES (2, N'hellow')
INSERT [dbo].[sales] ([id], [Sale_name]) VALUES (2, N'hellow')
INSERT [dbo].[sales] ([id], [Sale_name]) VALUES (2, N'hellow01')
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
ALTER TABLE [dbo].[Leave_Deduction] ADD  CONSTRAINT [DF_Leave_Deduction_Cancel_YN]  DEFAULT ('N') FOR [Cancel_YN]
GO
/****** Object:  StoredProcedure [dbo].[att_list]    Script Date: 8/30/2022 7:22:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[att_list] as 
select ep.Emp_id, ep.Name, count(atds.Attendance_Date) day_att ,atds.Attendance_Date
  from Attendance_Sheet atds, Employee ep
where atds.Emp_id = ep.Emp_id
group by ep.Emp_id,atds.Attendance_Date, ep.Name;
GO
/****** Object:  StoredProcedure [dbo].[attendance_list]    Script Date: 8/30/2022 7:22:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[attendance_list]
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
where atts.Status = '2'
and atts.Attendance_Date = ats.Attendance_Date
)) working_hours
from Attendance_Sheet ats , Employee e
where ats.Emp_id = e.Emp_id
and ats.Status = '1'
group by ats.Attendance_Date,e.Emp_id, e.Name
order by ats.Attendance_Date desc;

GO
/****** Object:  StoredProcedure [dbo].[calculate_Salary]    Script Date: 8/30/2022 7:22:24 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Dashboard_data]    Script Date: 8/30/2022 7:22:24 PM ******/
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
/****** Object:  StoredProcedure [dbo].[exl_dta_shw_rntm]    Script Date: 8/30/2022 7:22:24 PM ******/
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
/****** Object:  StoredProcedure [dbo].[export_data_excel]    Script Date: 8/30/2022 7:22:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[export_data_excel](@Date nvarchar(30))
as
begin
DECLARE @Set_year as nvarchar(30), @Set_Month as nvarchar(30)

set @Set_year = SUBSTRING(@Date, 1, 4);
set @Set_Month = reverse(substring(reverse(@Date), 1, 2));

select e.Emp_id,	e.Name,	e.Father_Name,	e.CNIC,	e.address, e.Phone,e.Email,	e.Date_of_Birth,	
case when e.Gender = 'M' then 'Male' else 'Female' end Gender,	e.Designation,	e.Overtime_Rate,	
e.Job_type,	e.Leaves,	ISNULL(e.Adv_staff,0)Adv_staff,	
ISNULL(e.I_Tax,0)I_Tax,ISNULL(e.Telephone,0)Telephone,	ISNULL(e.EOBI,0)EOBI,
dbo.[get_present_days](@Date,e.Emp_id) get_present_days,
dbo.[total_no_days](CONCAT(@Set_year,@Set_Month,'01'))total_no_days,
e.Gross_Salary,
e.Gross_Salary - (ISNULL(e.Adv_staff,0) + ISNULL(e.I_Tax,0) + ISNULL(e.Telephone,0)+ ISNULL(e.EOBI,0)) Gross_Salary_after_subtrate
 from Employee e
 where e.Status <> 'N';
end;
GO
/****** Object:  StoredProcedure [dbo].[getEmpSal]    Script Date: 8/30/2022 7:22:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getEmpSal] @emp_id int, @Date nvarchar(30)
AS
begin
DECLARE @Set_year as nvarchar(30), @Set_Month as nvarchar(30)

set @Set_year = SUBSTRING(@Date, 1, 4);
set @Set_Month = reverse(substring(reverse(@Date), 1, 2));

select r.total_precent_days  , r.Adv_staff , r.EOBI , r.I_Tax , r.Telephone , r.Days , r.Overtime_day,
r.Overtime_Rate ,
round(Cast((((r.total_precent_days * r.per_day)+r.add_Salary)- r.deduction) as money),2)  Net_Salary ,
 r.Leaves
from (
select f.total_precent_days , 
case when ISNULL(f.Days,0) = 0 then 
((f.Overtime_day * f.Overtime_Rate)) 
else
--Cast((f.Overtime_Rate / f.Days) * f.Overtime_day) as decimal(7,4))
(f.Overtime_Rate / f.Days) * f.Overtime_day
end add_Salary,
f.Adv_staff, f.EOBI ,f.I_Tax , f.Telephone , f.Days , f.Overtime_day , f.Overtime_Rate, (f.Gross_Salary / f.DaysInMonth) per_day 
, ( ISNULL(f.Adv_staff,0) + ISNULL(f.EOBI,0) + ISNULL(f.I_Tax,0) + ISNULL(f.Telephone,0)) deduction ,f.Leaves
 from (
 --3 use for temporary i will remove after this month
select (t.No_days + (t.get_weekdays * t.Get_sunday )+ t.get_holiday + t.Leaves) total_precent_days,
--t.DaysInMonth -(t.No_days+t.No_sundays) total_abcent_days,
t.employee_salary - (ISNULL(t.Adv_staff,0) + ISNULL(t.I_Tax,0) + ISNULL(t.Telephone,0) + ISNULL(t.EOBI,0)) Net_Salary,
t.Overtime_day, t.Overtime_Rate , t.Days,
ISNULL(t.Adv_staff,0)Adv_staff, ISNULL(t.I_Tax,0)I_Tax , ISNULL(t.Telephone,0) Telephone, ISNULL(t.EOBI,0)EOBI,
t.Gross_Salary , t.DaysInMonth , t.gross_salary01 , t.Leaves
 from (
select count(e.att_date) No_days , dbo.[getSundaysandSaturdays](@Set_year,@Set_Month) No_sundays,
(select e.Gross_Salary from Employee e where e.Emp_id =@emp_id) employee_salary,
(select ISNULL(e.Adv_staff,0)Adv_staff from Employee e where e.Emp_id =@emp_id)Adv_staff,
(select ISNULL(e.I_Tax,0) from Employee e where e.Emp_id =@emp_id)I_Tax,
(select ISNULL(e.Telephone,0) from Employee e where e.Emp_id =@emp_id)Telephone,
(select ISNULL(e.EOBI,0)EOBI from Employee e where e.Emp_id =@emp_id)EOBI,
(select ISNULL(e.Overtime_Rate,0)Overtime_Rate from Employee e where e.Emp_id =@emp_id)Overtime_Rate,
(select ISNULL(e.Overtime_day,0)Overtime_day from Employee e where e.Emp_id =@emp_id)Overtime_day,
(select ISNULL(e.Days,0)Days from Employee e where e.Emp_id =@emp_id)Days,
(select ISNULL(e.Gross_Salary,0)Gross_Salary from Employee e where e.Emp_id = @emp_id)Gross_Salary,
(select ISNULL(e.Gross_Salary01,0)Gross_Salary from Employee e where e.Emp_id = @emp_id)gross_salary01,
(SELECT DAY(EOMONTH(CONCAT(@Set_year,@Set_Month,'01'))))DaysInMonth,
(SELECT dbo.f_count_sundays(@Set_year,@Set_Month)) Get_sunday,
(select dbo.get_weekdays(@emp_id) from Employee e where e.Emp_id = @emp_id) get_weekdays,
(select count(*) holiday_count from Holiday h where convert(varchar(7), h.H_Date, 126) = @Date) get_holiday,
(select ISNULL(e.Leaves,0) from Employee e where e.Emp_id = @emp_id) Leaves
from (
select ats.Emp_id emp_id, count(ats.Attendance_Date) att_date
from attendance_sheet ats
where convert(varchar(7), ats.Attendance_Date, 126) =  @Date
and ats.Emp_id = @emp_id
group by ats.Emp_id, ats.Attendance_Date)
e) t ) f) r;
/*
select t.No_days + t.No_sundays total_no_working_days_per_month ,
(select e.Gross_Salary G_Salary from Employee e where e.Emp_id = @emp_id) e_salary,
(SELECT DAY(EOMONTH(CONCAT(@Set_year,@Set_Month,'01'))) - t.No_sundays) - t.No_days abcent,
(select sum(p.Current_Abcent) total_emp_abcent_emp from Payroll p
where p.Emp_id = @emp_id)total_emp_abcent,
(select e.Leaves from Employee e where e.Emp_id = @emp_id) total_leave
from (
select count(e.att_date) No_days , dbo.[getSundaysandSaturdays](@Set_year,@Set_Month) No_sundays
from (
select ats.Emp_id emp_id, count(ats.Attendance_Date) att_date
from attendance_sheet ats
where convert(varchar(7), ats.Attendance_Date, 126) = @Date
and ats.Emp_id = @emp_id
group by ats.Emp_id, ats.Attendance_Date)
e) t;*/
end;
GO
USE [master]
GO
ALTER DATABASE [Hosp_Payroll] SET  READ_WRITE 
GO

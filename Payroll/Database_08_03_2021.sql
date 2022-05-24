USE [master]
GO
/****** Object:  Database [Hosp_Payroll]    Script Date: 3/8/2021 4:41:18 PM ******/
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
/****** Object:  User [Jane]    Script Date: 3/8/2021 4:41:18 PM ******/
CREATE USER [Jane] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [SalesPerson]    Script Date: 3/8/2021 4:41:18 PM ******/
CREATE ROLE [SalesPerson]
GO
/****** Object:  Table [dbo].[Activity_log]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  Table [dbo].[Attendance_Sheet]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  Table [dbo].[Employee]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  Table [dbo].[Holiday]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  Table [dbo].[Leave_Deduction]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  Table [dbo].[Login]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  Table [dbo].[Payroll]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  Table [dbo].[tax_slab]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  Table [dbo].[Users]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  StoredProcedure [dbo].[attendance_list]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  StoredProcedure [dbo].[calculate_Salary]    Script Date: 3/8/2021 4:41:19 PM ******/
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

select count(working_hours.working_hours) - working_hours.late_status working_days,
sum(working_hours.working_hours) - (working_hours.working_time * working_hours.late_status) working_hours ,
 working_hours.Holiday
,((working_hours.Abcent + working_hours.late_status) - working_hours.Holiday) - 
(count(working_hours.working_hours) - working_hours.late_status) Current_abcent
, 
(sum(working_hours.working_hours) - working_hours.Over_time_hours) -
(working_hours.working_time * working_hours.late_status)
 Current_Salary_hours ,
working_hours.Over_time_hours,
(working_hours.Over_time_hours * working_hours.Overtime_Rate) Overtime_amount,
(((sum(working_hours.working_hours) - working_hours.Over_time_hours) -
 (working_hours.working_time * working_hours.late_status)) * working_hours.Gross_Salary )
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
currt_working_time) Over_time_hours

from Attendance_Sheet ats , Employee e
where ats.Emp_id = e.Emp_id
and ats.status = 1
and ats.Emp_id =@emp_id
and convert(varchar(7), ats.Attendance_Date, 126) = @Date
group by ats.Attendance_Date,e.Gross_Salary,e.Overtime_Rate,e.Time_In , e.Time_Out) working_hours 
group by working_hours.Gross_Salary , working_hours.Holiday, working_hours.late_status,
working_hours.Overtime_Rate , working_hours.Over_time_hours 
, working_hours.Abcent , working_hours.working_time;
end;
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_data]    Script Date: 3/8/2021 4:41:19 PM ******/
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
/****** Object:  StoredProcedure [dbo].[exl_dta_shw_rntm]    Script Date: 3/8/2021 4:41:19 PM ******/
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

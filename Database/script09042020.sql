USE [Hosp_Payroll]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 4/9/2020 3:34:00 AM ******/
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

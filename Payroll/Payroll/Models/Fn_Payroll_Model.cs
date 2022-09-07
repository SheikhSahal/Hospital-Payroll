using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Payroll.Models
{
    public class Fn_Payroll_Model
    {
        public int Emp_id { get; set; }
        public DateTime Payroll_date { get; set; }
        public double Total_Monthly_Salary { get; set; }
        public double Employee_Get_salary_perM { get; set; }
        public double Late_Hour_Salary { get; set; }
        public double Overtime_Hour_Salary { get; set; } 
        public double Leave_days { get; set; }
        public double Leave_Hours_Salary { get; set; }
        public double Holiday_Days { get; set; }
        public double Holidays_Hours_Salary { get; set; }
        public double Total_Gross { get; set; }

    }
}
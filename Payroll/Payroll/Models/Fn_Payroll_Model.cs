using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Payroll.Models
{
    public class Fn_Payroll_Model
    {
        public int Emp_id { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string Designation { get; set; }
        public string Phone { get; set; }
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
        public int Adv_Staff { get; set; }
        public int I_tax { get; set; }
        public int Telephone { get; set; }
        public int EOBI { get; set; }
        public int Remaining_leaves { get; set; }
    }
}
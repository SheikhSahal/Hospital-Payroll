using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Payroll.Models
{
    public class Payroll_Data
    {
        public int id { get; set; }
        public int emp_id { get; set; }
        public DateTime date { get; set; }

        public string payroll_date { get; set; }
        public int Working_days { get; set; }
        public int Working_hours { get; set; }
        public int Working_time { get; set; }
        public int Holidays { get; set; }
        public int Abcent { get; set; }
        public int Current_Salary_Hours { get; set; }
        public int Overtime_Time_hours { get; set; }
        public int Overtime_Amount { get; set; }
        public int total_earning { get; set; }
        public int dedcution { get; set; }
        public int Gross_salary { get; set; }
        public string Leaves { get; set; }

        public int Adv_Staff { get; set; }
        public int I_tax { get; set; }
        public int Telephone { get; set; }
        public int EOBI { get; set; }

        public int Overtime_rate { get; set; }
        public int Overtime_days { get; set; }
        public int Days { get; set; }

        public int Count_emp { get; set; }

        public string Name { get; set; }
        public string CNIC { get; set; }
        public string Email { get; set; }
        public string Month { get; set; }
        public string Designation { get; set; }
        public string Phone { get; set; }
        public string basic_sal { get; set; }
    }
}
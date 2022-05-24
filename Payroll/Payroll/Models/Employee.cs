using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Payroll.Models
{
    public class Employee
    {
        public int Emp_id { get; set; }
        public string Name { get; set; }
        public string Father_Name { get; set; }
        public string CNIC { get; set; }
        public string address { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public DateTime Date_of_Birth { get; set; }
        public string Gender { get; set; }
        public string Designation { get; set; }
        public string Gross_Salary { get; set; }
        public string Time_In { get; set; }
        public string Time_Out { get; set; }
        public string Grace_Time_IN { get; set; }
        public string Grace_Time_Out { get; set; }
        public string Overtime_Rate { get; set; }
        public string Monday_WD { get; set; }
        public string Tuesday_WD { get; set; }
        public string Wednesday_WD { get; set; }
        public string Thursday_WD { get; set; }
        public string Friday_WD { get; set; }
        public string Saturday_WD { get; set; }
        public string Sunday_WD { get; set; }
        public string Status { get; set; }
        public string Job_type { get; set; }
        public string Leaves { get; set; }

        public string Adv_Staff { get; set; }
        public string I_tax { get; set; }
        public string Telephone { get; set; }
        public string EOBI { get; set; }
        public string get_present_day { get; set; }
        public string total_no_days { get; set; }
        public string Gross_Salary_after_subtrate { get; set; }

        public int Working_Days { get; set; }
        public string Attendance_status { get; set; }

    }
}
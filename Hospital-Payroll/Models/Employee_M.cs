using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Hospital_Payroll.Models
{
    public class Employee_M
    {
        public int Emp_id { get; set; }
        public string Name { get; set; }
        public string Father_Name { get; set; }
        public string Date_of_Birth { get; set; }
        public string CNIC { get; set; }
        public string address { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
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


    }
}

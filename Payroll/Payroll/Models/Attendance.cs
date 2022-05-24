using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Payroll.Models
{
    public class Attendance
    {
        public int id { get; set; }
        public int Emp_id { get; set; }
        public string Ename { get; set; }
        public DateTime Attendance_Date { get; set; }
        public string Time_IN { get; set; }
        public string Time_Out { get; set; }
        public string DateDiff { get; set; }
        public string Att_Year { get; set; }

        //Excel loader

        public string Employee_id { get; set; }
        public string Employee_name { get; set; }
        public string Hour { get; set; }
        public string Mint { get; set; }
        public string Time_Status { get; set; }
        public string Status { get; set; }
        public string attendance_status { get; set; }
        public string att_date { get; set; }
    }
}

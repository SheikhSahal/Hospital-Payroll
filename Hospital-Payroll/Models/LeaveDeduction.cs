using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Hospital_Payroll.Models
{
    public class LeaveDeduction
    {
        public int Emp_id { get; set; }
        public string Name { get; set; }
        public string Leave_Days { get; set; }
        public string From_Date { get; set; }
        public string To_Date { get; set; }
        public string Leave_Deduction { get; set; }
        public string Total_Leave_Deduction { get; set; }

        public string Cancel_YN { get; set; }


    }
}

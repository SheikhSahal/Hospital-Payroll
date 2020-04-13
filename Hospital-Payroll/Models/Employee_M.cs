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

        
        public string Date_of_Birth { get; set; }
        public string Gender { get; set; }
        public string Phone { get; set; }
        public string address { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string Branch { get; set; }
        public string Department { get; set; }
        public string Designation { get; set; }
        public string Company_Date_of_joining { get; set; }
        public string certificates { get; set; }
        public string resume { get; set; }
        public string Photo { get; set; }
        public string Account_holder_name { get; set; }
        public string Account_number { get; set; }
        public string Bank_Name { get; set; }
        public string Bank_Identifier_Code { get; set; }
        public string Branch_location { get; set; }
        public string Tax_Payer_id { get; set; }

    }
}

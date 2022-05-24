using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Payroll.Models
{
    public class Holidays
    {
        public int id { get; set; }
        public DateTime Holidays_Date { get; set; }
        public string Reason { get; set; }
        public string Created_by { get; set; }
        public DateTime Created_date { get; set; }
    }
}
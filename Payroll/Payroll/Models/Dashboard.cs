using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Payroll.Models
{
    public class Dashboard
    {
        public int employees { get; set; }
        public int Holidays { get; set; }
        public int ex_employess { get; set; }
        public int leaves { get; set; }
    }
}
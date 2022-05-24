using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Payroll.Models
{
    public class Activity_log
    {
        public string Document { get; set; }
        public string Table_flag { get; set; }
        public string Activity_type { get; set; }
        public string User_id { get; set; }
    }
}
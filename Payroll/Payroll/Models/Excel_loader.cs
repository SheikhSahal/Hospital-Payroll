using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Payroll.Models
{
    public class Excel_loader
    {
        public virtual ICollection<Attendance> Attendance { get; set; }
    }
}
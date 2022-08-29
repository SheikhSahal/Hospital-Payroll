using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Payroll.Models
{
    public class EMPDataSet
    {
        public virtual ICollection<Employee> Employee { get; set; }
    }
}
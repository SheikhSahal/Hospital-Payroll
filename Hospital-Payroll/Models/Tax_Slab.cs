using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Hospital_Payroll.Models
{
    public class Tax_Slab
    {
        public int Ts_id { get; set; }
        public string ts_Year { get; set; }
        public string Floor_Amount { get; set; }
        public string Ceiling_Amount { get; set; }
        public string Tax_Amount { get; set; }
        public string Tax_Percent { get; set; }
        public string Cancel_YN { get; set; }

    }
}

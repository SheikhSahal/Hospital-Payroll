using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Payroll.Database;
using Payroll.Models;

namespace Payroll.Controllers
{
    public class MultiPayrollController : Controller
    {
        DB db = new DB();
        // GET: MultiPayroll
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Index(string Month)
        {
            bool status = false;
            List<Employee> excel_dta = db.Export_Excel(Month);
            

            foreach (var s in excel_dta)
            {
                int id = s.Emp_id;
                Payroll_Data valid_salary = db.Check_Payslip_data(id, Month);
                Fn_Payroll_Model empdata = db.Payroll_Data(id, Month);

                empdata.Emp_id = id;
                DateTime get_date = Convert.ToDateTime(Month + "-28");
                empdata.Payroll_date = get_date;

                if (valid_salary.Count_emp != 1)
                {
                    db.InsertPayroll(empdata);
                }
            }

            status = true;

            return new JsonResult { Data = new { status = status } };
        }
    }
}
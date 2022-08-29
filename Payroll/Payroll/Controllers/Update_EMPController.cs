using Payroll.Database;
using Payroll.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Payroll.Controllers
{
    public class Update_EMPController : Controller
    {
        DB db = new DB();
        // GET: Update_EMP
        public ActionResult Index()
        {
            List<Employee> upd_Emp = db.Get_list();
            ViewBag.getlist = upd_Emp;
            return View();
        }

        [HttpPost]
        public ActionResult Save(EMPDataSet EMP)
        {
            bool status = false;
            foreach(var s in EMP.Employee)
            {
                db.Update_Employees_Sal(s);
            }
            
            status = true;
            return new JsonResult { Data = new { status = status } };
        }
    }
}
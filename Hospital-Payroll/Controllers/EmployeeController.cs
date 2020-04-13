using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Hospital_Payroll.Models;
using Hospital_Payroll.Database;
using Microsoft.AspNetCore.Http;

namespace Hospital_Payroll.Controllers
{
    public class EmployeeController : Controller
    {
        DB db = new DB();
        public IActionResult Index()
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (string.IsNullOrEmpty(HttpContext.Session.GetString("_login")))
            {

                return RedirectToAction("Index", "login");
                
            }
            else
            {
                //Max id GET
                Employee_M empid = db.Emp_id_Generate();
                TempData["Empid"] = empid.Emp_id;
                return View();
            }
        }

        [HttpPost]
        public IActionResult Index(Employee_M e)
        {
            bool status = false;

            //Max id POST
            Employee_M empid = db.Emp_id_Generate();
            e.Emp_id = empid.Emp_id;

            if (e.Name is null || e.Phone is null || e.Email is null || e.Password is null)
            {
                status = false;
            }
            else
            {
                db.InsertEmployee(e);
                status = true;
            }

            return Json(new { success = status });
        }

        public IActionResult GetData()
        {
            Employee_M Empid = db.Emp_id_Generate();

            return Json(new { success = true, fetchdata = Empid.Emp_id });
        }
    }
}
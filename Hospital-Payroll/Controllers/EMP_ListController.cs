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
    public class EMP_ListController : Controller
    {
        DB db = new DB();
        public IActionResult Index()
        {

            string sessionlogin = HttpContext.Session.GetString("_login");

            if (string.IsNullOrEmpty(sessionlogin))
            {
                return RedirectToAction("Index", "login");

                
            }
            else
            {
                List<Employee_M> emp_list = db.EMP_Tab_Data();

                ViewBag.emplist = emp_list;
                return View();
            }
        }
    }
}
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
    public class Update_EMPController : Controller
    {
        DB db = new DB();
        public IActionResult Index(int id)
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            { 
                Employee_M Emplist = db.EMPdetailbyid(id);
                TempData["Empdata"] = Emplist;
                TempData["Empid"] = id;
                return View();
            }
            else
            {
                return RedirectToAction("Index", "login");
            }
        }


        [HttpPost]
        public IActionResult Index(Employee_M e)
        {

            bool status = false;

            var empid = TempData["Empid"];

            e.Emp_id = Convert.ToInt32(empid);
            db.Update_EMP(e);

            status = true;

            return Json(new { success = status });
        }


    }
}
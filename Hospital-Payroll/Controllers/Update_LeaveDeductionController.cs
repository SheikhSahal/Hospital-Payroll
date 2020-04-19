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
    public class Update_LeaveDeductionController : Controller
    {
        DB db = new DB();
        public IActionResult Index(int id)
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            {

                //Dropdown list
                List<Employee_M> empid_Name = db.Leave_Deduction_id_Name();
                ViewBag.Emp_id_Name = empid_Name;

                LeaveDeduction lve_dedlist = db.leaveDeductiondetailbyid(id);
                TempData["lve_deddata"] = lve_dedlist;
                TempData["Empid"] = id;


                return View();
            }
            else
            {
                return RedirectToAction("Index", "login");
            }
        }

        [HttpPost]
        public IActionResult Index(LeaveDeduction ld)
        {

            bool status = false;

            var empid = TempData["Empid"];

            ld.Emp_id = Convert.ToInt32(empid);

            db.Update_LeaveDeduction(ld);

            status = true;

            return Json(new { success = status });
        }

    }
}
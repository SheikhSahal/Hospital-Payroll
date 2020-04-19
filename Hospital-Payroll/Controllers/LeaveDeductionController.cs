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
    public class LeaveDeductionController : Controller
    {
        DB db = new DB();

        public IActionResult Index()
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            {
                List<Employee_M> empid_Name = db.Leave_Deduction_id_Name();
                ViewBag.Emp_id_Name = empid_Name;
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

            if (ld.Leave_Days is null || ld.From_Date is null || ld.To_Date is null || ld.Leave_Deduction is null || ld.Total_Leave_Deduction is null)
            {
                status = false;
            }
            else
            {
                db.InsertLeaveDeduction(ld);
                status = true;
            }



            return Json(new { success = status });
        }
    }
}
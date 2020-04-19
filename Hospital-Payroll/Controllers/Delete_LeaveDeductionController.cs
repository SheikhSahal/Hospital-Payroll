using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Hospital_Payroll.Database;
using Microsoft.AspNetCore.Http;

namespace Hospital_Payroll.Controllers
{
    public class Delete_LeaveDeductionController : Controller
    {
        DB db = new DB();
        public IActionResult Index(int id)
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            {
                db.Delete_LeaveDeduction(id);
                return RedirectToAction("Index", "LeaveDeduction_List");
            }
            else
            {
                return RedirectToAction("Index", "login");
            }
        }
    }
}
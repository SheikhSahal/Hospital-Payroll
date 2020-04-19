using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Hospital_Payroll.Database;
using Microsoft.AspNetCore.Http;

namespace Hospital_Payroll.Controllers
{
    public class Delete_HolidayController : Controller
    {
        DB db = new DB();
        public IActionResult Index(int id)
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            {


                db.Delete_Holiday(id);
                return RedirectToAction("Index", "Holiday_List");
            }
            else
            {
                return RedirectToAction("Index", "login");
            }

        }
    }
}
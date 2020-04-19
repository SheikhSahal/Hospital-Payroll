using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Hospital_Payroll.Database;
using Hospital_Payroll.Models;
using Microsoft.AspNetCore.Http;

namespace Hospital_Payroll.Controllers
{
    public class Holiday_ListController : Controller
    {
        DB db = new DB();
        public IActionResult Index()
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            {
                List<Holidays> holi_list = db.Holiday_List();
                ViewBag.holilist = holi_list;
            }
            else
            {
                return RedirectToAction("Index", "login");
            }

            return View();
        }
    }
}
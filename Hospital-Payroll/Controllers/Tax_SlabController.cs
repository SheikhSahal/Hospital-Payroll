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
    public class Tax_SlabController : Controller
    {

        DB db = new DB();
        public IActionResult Index()
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            {
                return View();
            }
            else
            {
                return RedirectToAction("Index", "login");
            }
        }


        [HttpPost]
        public IActionResult Index(Tax_Slab ts)
        {
            bool status = false;

            if (ts.ts_Year is null || ts.Floor_Amount is null || ts.Ceiling_Amount is null || ts.Tax_Amount is null || ts.Tax_Percent is null)
            {
                status = false;
            }
            else
            {
                db.InsertTax_slab(ts);
                status = true;
            }



            return Json(new { success = status });
        }
    }

}
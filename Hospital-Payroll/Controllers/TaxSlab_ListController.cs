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
    public class TaxSlab_ListController : Controller
    {

        DB db = new DB();
        public IActionResult Index()
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            {

                List<Tax_Slab> txsl_list = db.Tax_Slab_Data();
                ViewBag.tax_sl_list = txsl_list;
                return View();
            }
            else
            {
                return RedirectToAction("Index", "login");
            }
        }
    }
}
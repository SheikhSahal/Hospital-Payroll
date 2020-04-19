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
    public class Update_TaxSlabController : Controller
    {
        DB db = new DB();
        public IActionResult Index(int id)
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            {

                Tax_Slab txsl_list = db.taxslabdetailbyid(id);
                ViewBag.tax_sl_list = txsl_list;
                TempData["id"] = id;
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

            var ts_id = TempData["id"];

            ts.Ts_id = Convert.ToInt32(ts_id);
            db.Update_TaxSlab(ts);

            status = true;

            return Json(new { success = status });
        }
    }
}
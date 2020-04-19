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
    public class Delete_TaxSlabController : Controller
    {
        DB db = new DB();
        public IActionResult Index(int id)
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            {

                db.Delete_tax_slab(id);
                return RedirectToAction("Index", "TaxSlab_list");
            }
            else
            {
                return RedirectToAction("Index", "login");
            }
        }
    }
}
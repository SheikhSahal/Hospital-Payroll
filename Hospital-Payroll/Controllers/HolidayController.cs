using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Hospital_Payroll.Models;
using Hospital_Payroll.Database;

namespace Hospital_Payroll.Controllers
{
    public class HolidayController : Controller
    {
        DB db = new DB();
        public IActionResult Index()
        {
            return View();
        }


        [HttpPost]
        public IActionResult Index(Holidays h)
        {
            bool status = false;

            if (h.H_Date is null || h.H_Reason is null)
            {
                status = false;
            }
            else
            {
                db.InsertHoliday(h);
                status = true;
            }



            return Json(new { success = status });
        }
    }
}
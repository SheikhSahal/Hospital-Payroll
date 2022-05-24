using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Payroll.Models;
using Payroll.Database;

namespace Payroll.Controllers
{
    public class HolidaysController : Controller
    {
        DB db = new DB();
        Activity_log al = new Activity_log();
        // GET: Holidays
        public ActionResult Index()
        {
            List<Holidays> hlist = db.Holiday_list();
            ViewBag.hlist = hlist;
            return View();
        }


        public ActionResult add_holiday()
        {
            return View();
        }

        [HttpPost]
        public ActionResult add_holiday(Holidays h)
        {
            bool status = false;
            db.Insertholiday(h);
            status = true;
            return new JsonResult { Data = new { status = status } };
        }

        public ActionResult Update_holiday(int id)
        {
            Holidays hlist = db.Per_Holiday(id);
            ViewBag.hlist = hlist;

            return View();
        }

        [HttpPost]
        public ActionResult Update_holiday(Holidays h)
        {
            bool status = false;
            db.Update_holidays(h);
            status = true;
            return new JsonResult { Data = new { status = status } };
        }

        public ActionResult Delete_holiday(int id)
        {
            db.DeleteHoliday(id);

            return RedirectToAction("Index", "Holidays");
        }
    }
}
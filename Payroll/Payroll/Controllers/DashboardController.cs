using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Payroll.Models;
using Payroll.Database;

namespace Payroll.Controllers
{
    public class DashboardController : Controller
    {
        DB db = new DB();
        // GET: Dashboard
        public ActionResult Index()
        {

            if (Session["Username"] == null)
            {
                return RedirectToAction("Index", "Login");
            }
            else
            {
                Dashboard dashboard_data = db.Dashboard_data();
                ViewBag.dashboard = dashboard_data;

                List<Employee> emplist = db.New_Employee_list();
                ViewBag.emplist = emplist;
                return View();
            }
        }
    }
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Payroll.Models;
using Payroll.Database;
using System.IO;
using ClosedXML.Excel;
using System.Data;
using OfficeOpenXml;
using System.Drawing;

namespace Payroll.Controllers
{
    public class Excel_ExportController : Controller
    {
        DB db = new DB();
        // GET: Excel_Export
        public ActionResult Index()
        {
            if (Session["Username"] == null)
            {
                return RedirectToAction("Index", "Login");
            }
            else
            {
                return View();
            }
        }

        
        public ActionResult ExportToExcel(string Month)
        {
            List<Employee> excel_dta = db.Export_Excel(Month);

            return Json(excel_dta, JsonRequestBehavior.AllowGet);

        }

    }
}
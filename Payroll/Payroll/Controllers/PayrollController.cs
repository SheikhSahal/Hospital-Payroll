using Payroll.Database;
using Payroll.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Syncfusion.Pdf.Grid;
using System.Data;
using Syncfusion.Pdf.Tables;
using Syncfusion.Pdf;
using Syncfusion.Pdf.Graphics;
using System.Drawing;

namespace Payroll.Controllers
{
    public class PayrollController : Controller
    {
        DB db = new DB();
        // GET: Payroll
        public ActionResult Index()
        {

            if (Session["Username"] == null)
            {
                return RedirectToAction("Index", "Login");
            }
            else
            {
                List<Payroll_Data> pd = db.Payroll_list();
                ViewBag.payroll_data = pd;
                return View();
            }
        }

        public ActionResult Add_Salary()
        {

            if (Session["Username"] == null)
            {
                return RedirectToAction("Index", "Login");
            }
            else
            {
                List<Employee> emplist = db.DropdownEmployee_list();
                ViewBag.Emplist = emplist;

                return View();
            }
        }

        [HttpPost]
        public ActionResult Add_Salary(int id, string Month)
        {
            bool status = false;
            Fn_Payroll_Model empdata = db.Payroll_Data(id, Month);
            empdata.Emp_id = id;
            DateTime get_date = Convert.ToDateTime(Month + "-28");
            empdata.Payroll_date = get_date;


            Payroll_Data valid_salary = db.Check_Payslip_data(id,Month);
            
            if (valid_salary.Count_emp != 1)
            {
                db.InsertPayroll(empdata);
                status = true;
            }
            else
            {
                status = false;
            }
            
            

            return new JsonResult { Data = new { status = status } };
        }


        

        public ActionResult Get_Salary_data(int id, string Month)
        {
            Fn_Payroll_Model empdata = db.Payroll_Data(id,Month);
            return new JsonResult { Data = new { Status = empdata } };
        }


        public ActionResult Payslip(int empid , DateTime date)
        {
            string datevalid = date.ToString("dd-MM-yyyy");
            Payroll_Data payslipdata = db.Payslip_data(empid,date);
            ViewBag.payslip_data = payslipdata;
            return View();
        }


        public ActionResult Generate_payslip()
        {

            return View();
        }

        [HttpPost]
        public ActionResult Generate_payslip(string Month)
        {
            //bool status = false;
            List<Employee> Empdata = db.DropdownEmployee_list();
            foreach(var emp in Empdata)
            {
                Fn_Payroll_Model empdata = db.Payroll_Data(emp.Emp_id, Month);
                empdata.Emp_id = emp.Emp_id;
                DateTime get_date = Convert.ToDateTime(Month + "-28");
                empdata.Payroll_date = get_date;
                db.InsertPayroll(empdata);
            }

            List<Payroll_Data> bulkempdata = db.Bulk_Payslip_data(Convert.ToDateTime(Month));
            
            return Json(bulkempdata,JsonRequestBehavior.AllowGet);
        }


        public ActionResult Delete_Payroll(int id)
        {
            db.DeletePayroll(id);
            return RedirectToAction("Index","Payroll");
        }
    }
}
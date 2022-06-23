using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Payroll.Models;
using Payroll.Database;

namespace Payroll.Controllers
{
    public class Employee_ListController : Controller
    {
        DB db = new DB();
        Activity_log al = new Activity_log();
        // GET: Employee_List
        public ActionResult Index()
        {
            if (Session["Username"] == null)
            {
                return RedirectToAction("Index", "Login");
            }
            else
            {
                List<Employee> emplist = db.Employee_list();
                ViewBag.emplist = emplist;
                return View();
            }
            
            
        }

        public ActionResult Add_Employee()
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

        [HttpPost]
        public ActionResult Add_Employee(Employee e)
        {
            bool status = false;
            Employee emp = db.Max_Empid();
            e.Emp_id = emp.Emp_id;
            db.InsertBatchHeader(e);
            al.Document = e.Name;
            al.User_id = Convert.ToString(Session["User_id"]);
            al.Table_flag = "Employee";
            db.Activity_log(al);
            status = true;
            return new JsonResult { Data = new { status = status } };
        }



        public ActionResult Update_Employee(int id)
        {
            Employee emplist = db.Employee_Detail(id);
            ViewBag.emplist = emplist;
            return View();
        }


        [HttpPost]
        public ActionResult Update_Employee(Employee e)
        {
            bool status = false;
            db.Update_Employees(e);
            status = true;
            return new JsonResult { Data = new { status = status } };
        }


        
        public ActionResult Delete_Employee(int id)
        {
            db.DeleteEmployee(id);

            return RedirectToAction("Index", "Employee_List");
        }

    }
}
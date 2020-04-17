using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Hospital_Payroll.Models;
using Hospital_Payroll.Database;

namespace Hospital_Payroll.Controllers
{
    public class LeaveDeduction_ListController : Controller
    {
        DB db = new DB();
        public IActionResult Index()
        {

            List<LeaveDeduction> leavededuction_list = db.Leave_Deduction_List();

            ViewBag.leavelist = leavededuction_list;

            return View();
        }
    }
}
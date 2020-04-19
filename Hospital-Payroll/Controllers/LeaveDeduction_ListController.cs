﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Hospital_Payroll.Models;
using Hospital_Payroll.Database;
using Microsoft.AspNetCore.Http;

namespace Hospital_Payroll.Controllers
{
    public class LeaveDeduction_ListController : Controller
    {
        DB db = new DB();
        public IActionResult Index()
        {
            string sessionlogin = HttpContext.Session.GetString("_login");

            if (sessionlogin == "true")
            {
                List<LeaveDeduction> leavededuction_list = db.Leave_Deduction_List();
                ViewBag.leavelist = leavededuction_list;
                return View();
            }
            else
            {
                return RedirectToAction("Index", "login");
            }
        }
    }
}
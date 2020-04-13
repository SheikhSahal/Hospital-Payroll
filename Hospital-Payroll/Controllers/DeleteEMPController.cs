using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Hospital_Payroll.Database;
using Hospital_Payroll.Models;


namespace Hospital_Payroll.Controllers
{
    public class DeleteEMPController : Controller
    {

        DB db = new DB();
        public IActionResult Index(int id)
        {
            db.EMPdeleterecord(id);


            return RedirectToAction("Index", "EMP_List");
        }
    }
}
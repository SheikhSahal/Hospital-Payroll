using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Payroll.Models;
using Payroll.Database;
using System.Web.Security;

namespace Payroll.Controllers
{
    public class LoginController : Controller
    {
        DB db = new DB();
        // GET: Login
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Index(string email, string pass)
        {
            string status = null;
            var userdata = db.user_login(email, pass);
            if (userdata.Email == email && userdata.Password == pass)
            {
                status = "done";
                Session["Username"] = userdata.Name;
                Session["User_id"] = userdata.Emp_id;
            }
            else
            {
                status = "err";
            }

            return new JsonResult { Data = new { status = status } };
        }


        public ActionResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            Session.RemoveAll();
            Session["Username"] = null;

            FormsAuthentication.SignOut();


            this.Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
            this.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            this.Response.Cache.SetNoStore();

            return RedirectToAction("index", "Login");

        }
    }
}
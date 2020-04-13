using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using Microsoft.AspNetCore.Http;
using Hospital_Payroll;

namespace Hospital_Payroll.Controllers
{
    public class LoginController : Controller
    {
        SqlConnection con = new SqlConnection();
        SqlCommand com = new SqlCommand();
        SqlDataReader dr;
        const string SessionLogin = "_Status";
        const string StatusLogin = "_login";
        string connectString = Database_Connection.connectString;


        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Index(string username, string password)
        {
            bool status = false;
            con = new SqlConnection(connectString);
            con.Open();
            com.Connection = con;
            com = new SqlCommand("select u.uName,u.UEmail, u.Upassword from users u  where u.UEmail = '" + username + "' and u.UPassword = '" + password + "' and u.Active = 'Y' ", con);
            dr = com.ExecuteReader();

            if (dr.Read())
            {
                string un = dr["uName"].ToString();
                string u = dr["UEmail"].ToString();
                string p = dr["UPassword"].ToString();

                if (u == username && p == password)
                {
                    HttpContext.Session.SetString(StatusLogin, "true");
                    HttpContext.Session.SetString(SessionLogin, un);
                    status = true;
                }
                else
                {
                    HttpContext.Session.SetString(StatusLogin, "false");
                    HttpContext.Session.SetString(SessionLogin, null);
                    status = false;
                }
                con.Close();
            }

            return Json(new { success = status });
        }



        public IActionResult Logout()
        {

            //string sessionlogin = HttpContext.Session.GetString(StatusLogin);
            //string status = HttpContext.Session.GetString(SessionLogin);
            //if (sessionlogin == "true")
            //{
            HttpContext.Session.Clear();
                //HttpContext.Session.SetString(StatusLogin, "false");
            return RedirectToAction("Index", "login");
            //string slogin = HttpContext.Session.GetString(StatusLogin);

            //    HttpContext.Session.SetString(SessionLogin, "");
            //    return RedirectToAction("Index", "login");
            //}
            //else
            //{
            //    return RedirectToAction("Index", "EMP_List");
            //}
        }
    }
}
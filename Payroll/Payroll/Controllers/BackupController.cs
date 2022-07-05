using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data;
using System.Data.SqlClient;
using System.Net;

namespace Payroll.Controllers
{
    public class BackupController : Controller
    {
        // GET: Backup
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


        [HttpPost]
        public ActionResult Index(string val)
        {

            try
            {
                string backlocation = Server.MapPath("~/Backu/");
                string downloadfilename = "Hosp_Payroll" + DateTime.Now.ToString("ddMMyyyy_HHmmss") + ".Bak'";
                string backupfile = backlocation + DateTime.Now.ToString("ddMMyyyy_HHmmss") + ".Bak'";
                String query = "backup database " + "Hosp_Payroll" + " to disk='" + backupfile;
                String mycon = @"Server=.; Database=Hosp_Payroll; UID=sa; PWD=Optiplex@242244;";
                //String mycon = @"Data Source=PSLKHI-SAHAL; Initial Catalog=Hosp_Payroll; Integrated Security=true";
                //String mycon = @"Data Source=PSLKHI-SAHAL; Initial Catalog=Hosp_Payroll;";
                SqlConnection con = new SqlConnection(mycon);
                con.Open();
                SqlCommand cmd = new SqlCommand();
                cmd.CommandText = query;
                cmd.Connection = con;
                cmd.ExecuteNonQuery();
                con.Close();

                WebClient req = new WebClient();
                HttpResponse response = System.Web.HttpContext.Current.Response;
                response.Clear();
                response.ClearContent();
                response.ClearHeaders();
                response.Buffer = true;

                Response.AppendHeader("Content-Disposition", "attachment; filename=" + downloadfilename);
                byte[] data = req.DownloadData(Server.MapPath(backupfile));
                response.BinaryWrite(data);
                response.End();
                ViewBag.text = "Backup Has Been Created and Started Download";
            }
            catch (Exception ex)
            {
                ViewBag.text = "Error Occured While Creating Backup of Database Error Code" + ex.ToString();

            }

            return View();
        }
    }
}
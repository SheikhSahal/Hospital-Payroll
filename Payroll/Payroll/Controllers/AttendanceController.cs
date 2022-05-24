using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Payroll.Models;
using Payroll.Database;
using Excel = Microsoft.Office.Interop.Excel;
using System.IO;

namespace Payroll.Controllers
{
    public class AttendanceController : Controller
    {
        DB db = new DB();
        // GET: Addendance
        public ActionResult Index()
        {

            if (Session["Username"] == null)
            {
                return RedirectToAction("Index", "Login");
            }
            else
            {
                List<Attendance> attlist = db.Attendance_sheet_List();
                ViewBag.attlist = attlist;
                return View();
            }
        }


        public ActionResult Add_Attendance()
        {

            if (Session["Username"] == null)
            {
                return RedirectToAction("Index", "Login");
            }
            else
            {
                List<Employee> emplist = db.DropdownEmployee_list();
                ViewBag.emplist = emplist;
                return View();
            }
        }

        [HttpPost]
        public ActionResult Add_Attendance(Attendance a)
        {
            if (Session["Username"] == null)
            {
                return RedirectToAction("Index", "Login");
            }
            else
            {
            bool status = false;
            db.InsertAttendance(a);
            status = true;
            return new JsonResult { Data = new { status = status } };
            }
        }


        public ActionResult Update_Attendance(int id)
        {
            Attendance att_details = db.Attendance_sheet_List_Detail(id);
            ViewBag.att_list = att_details;

            List<Employee> emplist = db.DropdownEmployee_list();
            ViewBag.emplist = emplist;
            return View();
        }

        [HttpPost]
        public ActionResult Update_Attendance(Attendance a)
        {
            bool status = false;
            db.Update_Attendance(a);
            status = true;

            return new JsonResult { Data = new { status = status } };
        }


        public ActionResult Bulk_attendance()
        {

            if (Session["Username"] == null)
            {
                return RedirectToAction("Index", "Login");
            }
            else
            {

                return View(new List<Attendance>());
            } 
        }

        [HttpPost]
        public ActionResult Bulk_attendance(HttpPostedFileBase excelfile)
        {
            
            if (excelfile == null || excelfile.ContentLength == 0)
            {
                ViewBag.error = "Please select a excel file";
                return View();
            }
            else
            {
                //if (excelfile.FileName.EndsWith("csv") || excelfile.FileName.EndsWith("xlsx"))
                    if (excelfile.FileName.EndsWith("csv"))
                    {
                    string path = Server.MapPath("~/Content/Files/" + excelfile.FileName);

                    if (System.IO.File.Exists(path))
                        System.IO.File.Delete(path);
                    excelfile.SaveAs(path);
                    
                    // Read data from excel file
                    //Excel.Application application = new Excel.Application();
                    //Excel.Workbook workbook = application.Workbooks.Open(path);
                    //Excel.Worksheet worksheet = workbook.ActiveSheet;
                    //Excel.Range range = worksheet.UsedRange;
                    List<Attendance> listproduct = new List<Attendance>();
                    List<CustomerModel> customers = new List<CustomerModel>();



                    string csvData = System.IO.File.ReadAllText(path);

                    foreach (string row in csvData.Split('\n').Skip(1))
                    {
                        if (!string.IsNullOrEmpty(row))
                        {
                            Attendance s = new Attendance();
                            s.Employee_id = row.Split(',')[0];
                            s.att_date = row.Split(',')[2] + '/' + row.Split(',')[3] + '/' + row.Split(',')[1];
                            s.Attendance_Date = Convert.ToDateTime(s.att_date);
                            s.Time_IN = row.Split(',')[4] + ':' + row.Split(',')[5];
                            s.Status = row.Split(',')[7];
                            Employee emp_name = db.Excel_data_reader(s.Employee_id);
                            s.Employee_name = emp_name.Name;
                            listproduct.Add(s);

                            //listproduct.Add(new Attendance
                            //{
                            //    Employee_id = row.Split(',')[0],
                            //    Attendance_Date = Convert.ToDateTime(row.Split(',')[2] + '/' + row.Split(',')[3] + '/' + row.Split(',')[1]),
                            //    Time_IN = row.Split(',')[4] + ':' + row.Split(',')[5],
                            //    Status = row.Split(',')[7],

                            //});
                        }
                    }

                    ViewBag.list = listproduct;
                    return View(listproduct);

                    //for (int row = 2; row <= csvData.Split('\n'); row++)
                    //{
                    //    Attendance s = new Attendance();
                    //    s.Employee_id = ((Excel.Range)range.Cells[row, 1]).Text;
                    //    s.Attendance_Date = Convert.ToDateTime( ((Excel.Range)range.Cells[row, 3]).Text + '/' + ((Excel.Range)range.Cells[row, 4]).Text + '/'+ ((Excel.Range)range.Cells[row, 2]).Text);
                    //    s.Time_IN = ((Excel.Range)range.Cells[row, 5]).Text +':'+((Excel.Range)range.Cells[row, 6]).Text;
                    //    s.Status = ((Excel.Range)range.Cells[row, 8]).Text;
                    //    Employee emp_name = db.Excel_data_reader(s.Employee_id);
                    //    s.Employee_name = emp_name.Name;
                    //    listproduct.Add(s);
                    //}

                    //workbook.Close(true);

                    //ViewBag.list = listproduct;
                    //return View(listproduct);
                }
                else
                {
                    ViewBag.error = "File type is incorrect only CSV is accepted";
                    return View();
                }
            }

        }



        public ActionResult Excel_loader(Excel_loader el)
        {
            bool status = false;

            foreach(var s in el.Attendance)
            {
                s.Attendance_Date= s.Attendance_Date.Date;
                db.Excel_data_save(s);
            }
            status = true;

            return new JsonResult { Data = new { status = status } };
        }
    }
}
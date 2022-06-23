using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Payroll;
using Payroll.Models;
using System.Data.SqlClient;

namespace Payroll.Database
{
    public class DB
    {
        string connectString = Connection_string.connectString;


        public void InsertBatchHeader(Employee e)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("insert into Employee (Emp_id, Name,	Father_Name,	CNIC,	address,	Phone,	Email,	Date_of_Birth,	Gender,	Designation,	Gross_Salary,	Time_In,	Time_Out, Grace_Time_IN, Grace_Time_Out,	Overtime_Rate,	Monday_WD,	Tuesday_WD,	Wednesday_WD,	Thursday_WD,	Friday_WD,	Saturday_WD,	Sunday_WD , Status,Job_type,Leaves, Adv_staff, I_Tax, Telephone, EOBI , Overtime_day ,  Days)  values(@Emp_id, @Name,	@Father_Name,	@CNIC,	@address,	@Phone,	@Email,	@Date_of_Birth,	@Gender,	@Designation,	@Gross_Salary,	@Time_In,	@Time_Out,@Grace_Time_IN, @Grace_Time_Out,	@Overtime_Rate,	@Monday_WD,	@Tuesday_WD,	@Wednesday_WD,	@Thursday_WD,	@Friday_WD,	@Saturday_WD,	@Sunday_WD, @Status,@Job_type,@Leaves, @Adv_staff, @I_Tax, @Telephone, @EOBI , @Overtime_day ,  @Days )", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", e.Emp_id);
                    cmd.Parameters.AddWithValue("@Name", e.Name);
                    cmd.Parameters.AddWithValue("@Father_Name", e.Father_Name);
                    cmd.Parameters.AddWithValue("@CNIC", e.CNIC);
                    cmd.Parameters.AddWithValue("@address", e.address);
                    cmd.Parameters.AddWithValue("@Phone", e.Phone);

                    if (e.Email != null)
                    {
                        cmd.Parameters.AddWithValue("@Email", e.Email);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Email", DBNull.Value);
                    }
                    cmd.Parameters.AddWithValue("@Date_of_Birth", e.Date_of_Birth);
                    cmd.Parameters.AddWithValue("@Gender", e.Gender);
                    cmd.Parameters.AddWithValue("@Designation", e.Designation);
                    cmd.Parameters.AddWithValue("@Gross_Salary", e.Gross_Salary);
                    cmd.Parameters.AddWithValue("@Time_In", e.Time_In);
                    cmd.Parameters.AddWithValue("@Time_Out", e.Time_Out);
                    cmd.Parameters.AddWithValue("@Grace_Time_IN", e.Grace_Time_IN);
                    cmd.Parameters.AddWithValue("@Grace_Time_Out", e.Grace_Time_Out);
                    if (e.Overtime_Rate != null)
                    {
                        cmd.Parameters.AddWithValue("@Overtime_Rate", e.Overtime_Rate);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Overtime_Rate", DBNull.Value);
                    }

                    if (e.Overtime_day != null)
                    {
                        cmd.Parameters.AddWithValue("@Overtime_day", e.Overtime_day);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Overtime_day", DBNull.Value);
                    }

                    if (e.Days != null)
                    {
                        cmd.Parameters.AddWithValue("@Days", e.Days);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Days", DBNull.Value);
                    }

                    cmd.Parameters.AddWithValue("@Monday_WD", e.Monday_WD);
                    cmd.Parameters.AddWithValue("@Tuesday_WD", e.Tuesday_WD);
                    cmd.Parameters.AddWithValue("@Wednesday_WD", e.Wednesday_WD);
                    cmd.Parameters.AddWithValue("@Thursday_WD", e.Thursday_WD);
                    cmd.Parameters.AddWithValue("@Friday_WD", e.Friday_WD);
                    cmd.Parameters.AddWithValue("@Saturday_WD", e.Saturday_WD);
                    cmd.Parameters.AddWithValue("@Sunday_WD", e.Sunday_WD);
                    cmd.Parameters.AddWithValue("@Status", e.Status);
                    if (e.Job_type != "0")
                    {
                        cmd.Parameters.AddWithValue("@Job_type", e.Job_type);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Job_type", DBNull.Value);
                    }

                    if (e.Leaves != null)
                    {
                        cmd.Parameters.AddWithValue("@Leaves", e.Leaves);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Leaves", DBNull.Value);
                    }

                    if (e.Adv_Staff != null)
                    {
                        cmd.Parameters.AddWithValue("@Adv_Staff", e.Adv_Staff);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Adv_Staff", DBNull.Value);
                    }


                    if (e.I_tax != null)
                    {
                        cmd.Parameters.AddWithValue("@I_tax", e.I_tax);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@I_tax", DBNull.Value);
                    }

                    if (e.Telephone != null)
                    {
                        cmd.Parameters.AddWithValue("@Telephone", e.Telephone);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Telephone", DBNull.Value);
                    }

                    if (e.EOBI != null)
                    {
                        cmd.Parameters.AddWithValue("@EOBI", e.EOBI);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@EOBI", DBNull.Value);
                    }
                    cmd.ExecuteNonQuery();
                }
            }

        }

        public List<Employee> Employee_list()
        {
            List<Employee> DBase = new List<Employee>();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select * from Employee order by Emp_id desc", conn))
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Employee emp = new Employee();

                        emp.Emp_id = Convert.ToInt32(reader["Emp_id"]);

                        emp.Name = Convert.ToString(reader["Name"]);
                        emp.Father_Name = Convert.ToString(reader["Father_Name"]);
                        emp.CNIC = Convert.ToString(reader["CNIC"]);
                        emp.Phone = Convert.ToString(reader["Phone"]);
                        emp.Gender = Convert.ToString(reader["Gender"]);

                        DBase.Add(emp);

                    }
                }
            }
            return DBase;
        }



        public List<Employee> New_Employee_list()
        {
            List<Employee> DBase = new List<Employee>();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select top 4 * from Employee order by Emp_id desc", conn))
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Employee emp = new Employee();

                        emp.Emp_id = Convert.ToInt32(reader["Emp_id"]);
                        emp.Name = Convert.ToString(reader["Name"]);
                        emp.Father_Name = reader["Father_Name"].ToString();
                        

                        if (reader["CNIC"] != DBNull.Value)
                        {
                            emp.CNIC = reader["CNIC"].ToString();
                        }

                        if (reader["address"] != DBNull.Value)
                        {
                            emp.address = reader["address"].ToString();
                        }

                        if (reader["Phone"] != DBNull.Value)
                        {
                            emp.Phone = reader["Phone"].ToString();
                        }

                        if (reader["Email"] != DBNull.Value)
                        {
                            emp.Email = reader["Email"].ToString();
                        }

                        if (reader["Date_of_Birth"] != DBNull.Value)
                        {
                            emp.Date_of_Birth = Convert.ToDateTime(reader["Date_of_Birth"]);
                        }
                        
                        emp.Gender = reader["Gender"].ToString();
                        emp.Designation = reader["Designation"].ToString();
                        emp.Gross_Salary = reader["Gross_Salary"].ToString();
                        emp.Time_In = reader["Time_In"].ToString();
                        emp.Time_Out = reader["Time_Out"].ToString();
                        emp.Grace_Time_IN = reader["Grace_Time_IN"].ToString();
                        emp.Grace_Time_Out = reader["Grace_Time_Out"].ToString();
                        if (reader["Overtime_Rate"] != DBNull.Value)
                        {
                            emp.Overtime_Rate = reader["Overtime_Rate"].ToString();
                        }
                        emp.Monday_WD = reader["Monday_WD"].ToString();
                        emp.Tuesday_WD = reader["Tuesday_WD"].ToString();
                        emp.Wednesday_WD = reader["Wednesday_WD"].ToString();
                        emp.Thursday_WD = reader["Thursday_WD"].ToString();
                        emp.Friday_WD = reader["Friday_WD"].ToString();
                        emp.Saturday_WD = reader["Saturday_WD"].ToString();
                        emp.Sunday_WD = reader["Sunday_WD"].ToString();
                        emp.Status = reader["Status"].ToString();


                        DBase.Add(emp);

                    }
                }
            }
            return DBase;
        }


        public Employee Employee_Detail(int id)
        {
            Employee emp = new Employee();

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select * from Employee where Emp_id = @p_id", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@p_id", id);
                    SqlDataReader reader = cmd.ExecuteReader();

                    reader.Read();

                    emp.Emp_id = Convert.ToInt32(reader["Emp_id"]);
                    emp.Name = Convert.ToString(reader["Name"]);
                    emp.Father_Name = reader["Father_Name"].ToString();


                    if (reader["CNIC"] != DBNull.Value)
                    {
                        emp.CNIC = reader["CNIC"].ToString();
                    }

                    if (reader["address"] != DBNull.Value)
                    {
                        emp.address = reader["address"].ToString();
                    }

                    if (reader["Phone"] != DBNull.Value)
                    {
                        emp.Phone = reader["Phone"].ToString();
                    }

                    if (reader["Email"] != DBNull.Value)
                    {
                        emp.Email = reader["Email"].ToString();
                    }

                    if (reader["Date_of_Birth"] != DBNull.Value)
                    {
                        emp.Date_of_Birth = Convert.ToDateTime(reader["Date_of_Birth"]);
                    }

                    emp.Gender = reader["Gender"].ToString();
                    emp.Designation = reader["Designation"].ToString();
                    emp.Gross_Salary = reader["Gross_Salary"].ToString();
                    emp.Time_In = reader["Time_In"].ToString();
                    emp.Time_Out = reader["Time_Out"].ToString();
                    emp.Grace_Time_IN = reader["Grace_Time_IN"].ToString();
                    emp.Grace_Time_Out = reader["Grace_Time_Out"].ToString();
                    if (reader["Overtime_Rate"] != DBNull.Value)
                    {
                        emp.Overtime_Rate = reader["Overtime_Rate"].ToString();
                    }

                    if (reader["Overtime_day"] != DBNull.Value)
                    {
                        emp.Overtime_day = reader["Overtime_day"].ToString();
                    }

                    if (reader["Days"] != DBNull.Value)
                    {
                        emp.Days = reader["Days"].ToString();
                    }
                    emp.Monday_WD = reader["Monday_WD"].ToString();
                    emp.Tuesday_WD = reader["Tuesday_WD"].ToString();
                    emp.Wednesday_WD = reader["Wednesday_WD"].ToString();
                    emp.Thursday_WD = reader["Thursday_WD"].ToString();
                    emp.Friday_WD = reader["Friday_WD"].ToString();
                    emp.Saturday_WD = reader["Saturday_WD"].ToString();
                    emp.Sunday_WD = reader["Sunday_WD"].ToString();
                    emp.Status = reader["Status"].ToString();
                    if (reader["Job_type"] != DBNull.Value)
                    {
                        emp.Job_type = reader["Job_type"].ToString();
                    }
                    if (reader["Leaves"] != DBNull.Value)
                    {
                        emp.Leaves = reader["Leaves"].ToString();
                    }

                    if (reader["total_leaves"] != DBNull.Value)
                    {
                        emp.T_Leaves = reader["total_leaves"].ToString();
                    }


                    if (reader["Adv_staff"] != DBNull.Value)
                    {
                        emp.Adv_Staff = reader["Adv_staff"].ToString();
                    }

                    if (reader["I_Tax"] != DBNull.Value)
                    {
                        emp.I_tax = reader["I_Tax"].ToString();
                    }

                    if (reader["Telephone"] != DBNull.Value)
                    {
                        emp.Telephone = reader["Telephone"].ToString();
                    }

                    if (reader["EOBI"] != DBNull.Value)
                    {
                        emp.EOBI = reader["EOBI"].ToString();
                    }


                }
            }
            return emp;
        }

        public void Update_Employees(Employee e)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("update Employee set Name=@Name,	Father_Name=@Father_Name,	CNIC=@CNIC,	address=@address,	Phone=@Phone,	Email=@Email,	Date_of_Birth=@Date_of_Birth,	Gender=@Gender,	Designation=@Designation,	Gross_Salary=@Gross_Salary,	Time_In=@Time_In,	Time_Out=@Time_Out,	Grace_Time_IN=@Grace_Time_IN, Grace_Time_Out=@Grace_Time_Out, Overtime_Rate=@Overtime_Rate,	Monday_WD=@Monday_WD,	Tuesday_WD=@Tuesday_WD,	Wednesday_WD=@Wednesday_WD,	Thursday_WD=@Thursday_WD,	Friday_WD=@Friday_WD,	Saturday_WD=@Saturday_WD,	Sunday_WD=@Sunday_WD, Status = @Status,Leaves = @Leaves, total_leaves = @total_leaves,Job_type = @Job_type, Adv_staff= @Adv_staff,I_Tax= @I_Tax,Telephone =@Telephone,EOBI= @EOBI,Overtime_day = @Overtime_day, Days= @Days  where Emp_id = @emp_id", conn))
                {
                    conn.Open();
                    cmd.Parameters.AddWithValue("@emp_id", e.Emp_id);
                    cmd.Parameters.AddWithValue("@Name", e.Name);
                    cmd.Parameters.AddWithValue("@Father_Name", e.Father_Name);
                    cmd.Parameters.AddWithValue("@CNIC", e.CNIC);
                    cmd.Parameters.AddWithValue("@address", e.address);
                    cmd.Parameters.AddWithValue("@Phone", e.Phone);
                    if (e.Email != null)
                    {
                        cmd.Parameters.AddWithValue("@Email", e.Email);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Email", DBNull.Value);
                    }

                    if (e.Overtime_day != null)
                    {
                        cmd.Parameters.AddWithValue("@Overtime_day", e.Overtime_day);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Overtime_day", DBNull.Value);
                    }

                    if (e.Days != null)
                    {
                        cmd.Parameters.AddWithValue("@Days", e.Days);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Days", DBNull.Value);
                    }
                    cmd.Parameters.AddWithValue("@Date_of_Birth", e.Date_of_Birth);
                    cmd.Parameters.AddWithValue("@Gender", e.Gender);
                    cmd.Parameters.AddWithValue("@Designation", e.Designation);
                    cmd.Parameters.AddWithValue("@Gross_Salary", e.Gross_Salary);
                    cmd.Parameters.AddWithValue("@Time_In", e.Time_In);
                    cmd.Parameters.AddWithValue("@Time_Out", e.Time_Out);
                    cmd.Parameters.AddWithValue("@Grace_Time_IN", e.Grace_Time_IN);
                    cmd.Parameters.AddWithValue("@Grace_Time_Out", e.Grace_Time_Out);
                    if (e.Overtime_Rate != null)
                    {
                        cmd.Parameters.AddWithValue("@Overtime_Rate", e.Overtime_Rate);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Overtime_Rate", DBNull.Value);
                    }
                    cmd.Parameters.AddWithValue("@Monday_WD", e.Monday_WD);
                    cmd.Parameters.AddWithValue("@Tuesday_WD", e.Tuesday_WD);
                    cmd.Parameters.AddWithValue("@Wednesday_WD", e.Wednesday_WD);
                    cmd.Parameters.AddWithValue("@Thursday_WD", e.Thursday_WD);
                    cmd.Parameters.AddWithValue("@Friday_WD", e.Friday_WD);
                    cmd.Parameters.AddWithValue("@Saturday_WD", e.Saturday_WD);
                    cmd.Parameters.AddWithValue("@Sunday_WD", e.Sunday_WD);
                    cmd.Parameters.AddWithValue("@Status", e.Status);
                    if (e.Leaves != null)
                    {
                        cmd.Parameters.AddWithValue("@Leaves", e.Leaves);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Leaves", DBNull.Value);
                    }

                    if (e.T_Leaves != null)
                    {
                        cmd.Parameters.AddWithValue("@total_leaves", e.T_Leaves);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@total_leaves", DBNull.Value);
                    }

                    if (e.Job_type != null)
                    {
                        cmd.Parameters.AddWithValue("@Job_type", e.Job_type);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Job_type", DBNull.Value);
                    }
                    if (e.Adv_Staff != null)
                    {
                        cmd.Parameters.AddWithValue("@Adv_Staff", e.Adv_Staff);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Adv_Staff", DBNull.Value);
                    }


                    if (e.I_tax != null)
                    {
                        cmd.Parameters.AddWithValue("@I_tax", e.I_tax);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@I_tax", DBNull.Value);
                    }

                    if (e.Telephone != null)
                    {
                        cmd.Parameters.AddWithValue("@Telephone", e.Telephone);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Telephone", DBNull.Value);
                    }

                    if (e.EOBI != null)
                    {
                        cmd.Parameters.AddWithValue("@EOBI", e.EOBI);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@EOBI", DBNull.Value);
                    }

                    cmd.ExecuteNonQuery();

                }
            }
        }


        public void DeleteEmployee(int id)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("delete from Employee where Emp_id = @emp_id", conn))
                {
                    conn.Open();

                    cmd.Parameters.AddWithValue("@emp_id", id);
                    cmd.ExecuteNonQuery();

                }
            }
        }

        public void InsertAttendance(Attendance a)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("insert into Attendance_Sheet (Emp_id,	Attendance_Date,	Time,	Status)values(@Emp_id,	@Attendance_Date,	@Time,	@Status)", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", a.Emp_id);
                    cmd.Parameters.AddWithValue("@Attendance_Date", a.Attendance_Date);
                    cmd.Parameters.AddWithValue("@Time", a.Time_IN);
                    cmd.Parameters.AddWithValue("@Status", a.Time_Out);

                    cmd.ExecuteNonQuery();
                }
            }
        }


        public List<Employee> DropdownEmployee_list()
        {
            List<Employee> DBase = new List<Employee>();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select * from employee where ISNULL(Status,'N') =  'Y'", conn))
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Employee emp = new Employee();

                        emp.Emp_id = Convert.ToInt32(reader["Emp_id"]);
                        emp.Name = Convert.ToString(reader["Name"]);
                        emp.Designation = Convert.ToString(reader["Designation"]);

                        DBase.Add(emp);

                    }
                }
            }
            return DBase;
        }


        public List<Attendance> Attendance_sheet_List()
        {
            List<Attendance> DBase = new List<Attendance>();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("attendance_list", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Attendance emp = new Attendance();

                        //emp.id = Convert.ToInt32(reader["id"]);
                        emp.Emp_id = Convert.ToInt32(reader["Emp_id"]);
                        emp.Ename = Convert.ToString(reader["Name"]);
                        emp.Attendance_Date = Convert.ToDateTime(reader["Attendance_Date"]);
                        emp.Att_Year = Convert.ToString(reader["Att_Year"]);
                        emp.Time_IN = Convert.ToString(reader["Time_IN"]);
                        emp.Time_Out = Convert.ToString(reader["Time_out"]);
                        emp.DateDiff = Convert.ToString(reader["working_hours"]);

                        DBase.Add(emp);

                    }
                }
            }
            return DBase;
        }


        public List<Attendance> Attendance_sheet()
        {
            List<Attendance> DBase = new List<Attendance>();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("att_list", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Attendance emp = new Attendance();

                        //emp.id = Convert.ToInt32(reader["id"]);
                        emp.Emp_id = Convert.ToInt32(reader["Emp_id"]);
                        emp.Ename = Convert.ToString(reader["Name"]);
                        emp.Attendance_Date = Convert.ToDateTime(reader["Attendance_Date"]);
                        emp.Att_Year = Convert.ToString(reader["day_att"]);
                        //emp.Time_IN = Convert.ToString(reader["Time_IN"]);
                        //emp.Time_Out = Convert.ToString(reader["Time_out"]);
                        //emp.DateDiff = Convert.ToString(reader["working_hours"]);

                        DBase.Add(emp);

                    }
                }
            }
            return DBase;
        }



        public List<Employee> Export_Excel(string Monthyear)
        {
            List<Employee> DBase = new List<Employee>();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("export_data_excel", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    conn.Open();
                    cmd.Parameters.AddWithValue("@Date", Monthyear);
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Employee emp = new Employee();


                        if (reader["Emp_id"] != DBNull.Value)
                        {
                        emp.Emp_id = Convert.ToInt32(reader["Emp_id"]);
                        }

                        if (reader["Name"] != DBNull.Value)
                        {
                            emp.Name = Convert.ToString(reader["Name"]);
                        }

                        if (reader["Father_Name"] != DBNull.Value)
                        {
                            emp.Father_Name = Convert.ToString(reader["Father_Name"]);
                        }

                        if (reader["CNIC"] != DBNull.Value)
                        {
                            emp.CNIC = Convert.ToString(reader["CNIC"]);
                        }

                        if (reader["address"] != DBNull.Value)
                        {
                            emp.address = Convert.ToString(reader["address"]);
                        }

                        if (reader["Phone"] != DBNull.Value)
                        {
                            emp.Phone = Convert.ToString(reader["Phone"]);
                        }

                        if (reader["Email"] != DBNull.Value)
                        {
                            emp.Email = Convert.ToString(reader["Email"]);
                        }

                        if (reader["Date_of_Birth"] != DBNull.Value)
                        {
                            emp.Date_of_Birth = Convert.ToDateTime(reader["Date_of_Birth"]);
                        }

                        if (reader["Gender"] != DBNull.Value)
                        {
                            emp.Gender = Convert.ToString(reader["Gender"]);
                        }

                        if (reader["Designation"] != DBNull.Value)
                        {
                            emp.Designation = Convert.ToString(reader["Designation"]);
                        }

                        if (reader["Overtime_Rate"] != DBNull.Value)
                        {
                            emp.Overtime_Rate = Convert.ToString(reader["Overtime_Rate"]);
                        }

                        if (reader["Job_type"] != DBNull.Value)
                        {
                            emp.Job_type = Convert.ToString(reader["Job_type"]);
                        }

                        if (reader["Leaves"] != DBNull.Value)
                        {
                            emp.Leaves = Convert.ToString(reader["Leaves"]);
                        }
                        if (reader["Adv_staff"] != DBNull.Value)
                        {
                            emp.Adv_Staff = Convert.ToString(reader["Adv_staff"]);
                        }

                        if (reader["I_Tax"] != DBNull.Value)
                        {
                            emp.I_tax = Convert.ToString(reader["I_Tax"]);
                        }

                        if (reader["Telephone"] != DBNull.Value)
                        {
                            emp.Telephone = Convert.ToString(reader["Telephone"]);
                        }

                        if (reader["EOBI"] != DBNull.Value)
                        {
                            emp.EOBI = Convert.ToString(reader["EOBI"]);
                        }

                        if (reader["total_no_days"] != DBNull.Value)
                        {
                            emp.total_no_days = Convert.ToString(reader["total_no_days"]);
                        }

                        if (reader["get_present_days"] != DBNull.Value)
                        {
                            emp.get_present_day = Convert.ToString(reader["get_present_days"]);
                        }

                        if (reader["Gross_Salary_after_subtrate"] != DBNull.Value)
                        {
                            emp.Gross_Salary_after_subtrate = Convert.ToString(reader["Gross_Salary_after_subtrate"]);
                        }

                        if (reader["Gross_Salary"] != DBNull.Value)
                        {
                            emp.Gross_Salary = Convert.ToString(reader["Gross_Salary"]);
                        }
                        DBase.Add(emp);

                    }
                }
            }
            return DBase;
        }


        public Attendance Attendance_sheet_List_Detail(int id)
        {
            Attendance emp = new Attendance();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select * from Attendance_Sheet where id = @emp_id", conn))
                {
                    conn.Open();
                    cmd.Parameters.AddWithValue("@emp_id", id);
                    SqlDataReader reader = cmd.ExecuteReader();


                    reader.Read();

                    emp.id = Convert.ToInt32(reader["id"]);
                    emp.Emp_id = Convert.ToInt32(reader["Emp_id"]);
                    emp.Attendance_Date = Convert.ToDateTime(reader["Attendance_Date"]);
                    emp.Time_IN = Convert.ToString(reader["Time_IN"]);
                    emp.Time_Out = Convert.ToString(reader["Time_Out"]);


                }
            }
            return emp;
        }

        public void Update_Attendance(Attendance a)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("update Attendance_Sheet  set Emp_id = @Emp_id , Attendance_Date =@Attendance_Date , Time_IN =@Time_IN , Time_Out = @Time_Out where id = @id", conn))
                {
                    conn.Open();
                    cmd.Parameters.AddWithValue("@id", a.id);
                    cmd.Parameters.AddWithValue("@Emp_id", a.Emp_id);
                    cmd.Parameters.AddWithValue("@Attendance_Date", a.Attendance_Date);
                    cmd.Parameters.AddWithValue("@Time_IN", a.Time_IN);
                    cmd.Parameters.AddWithValue("@Time_Out", a.Time_Out);
                   
                    cmd.ExecuteNonQuery();

                }
            }
        }


        public List<Payroll_Data> Payroll_list()
        {
            List<Payroll_Data> DBase = new List<Payroll_Data>();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select e.emp_id, e.Name, p.pyoll_date ,  e.CNIC , e.Email , format(p.pyoll_date,'MMMM,yyyy') Month , p.Gross_salary from payroll p , Employee e where p.emp_id = e.Emp_id", conn))
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Payroll_Data emp = new Payroll_Data();

                        emp.emp_id = Convert.ToInt32(reader["emp_id"]);
                        emp.Name = Convert.ToString(reader["Name"]);
                        emp.date = Convert.ToDateTime(reader["pyoll_date"]);
                        emp.CNIC = Convert.ToString(reader["CNIC"]);
                        emp.Email = Convert.ToString(reader["Email"]);
                        emp.Month = Convert.ToString(reader["Month"]);
                        emp.Gross_salary = Convert.ToInt32(reader["Gross_salary"]);

                        DBase.Add(emp);

                    }
                }
            }
            return DBase;
        }

        public Payroll_Data Payroll_Data(int id,string Monthyear)
        {
            Payroll_Data emp = new Payroll_Data();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("getEmpSal", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    conn.Open();
                    cmd.Parameters.AddWithValue("@emp_id", id);
                    cmd.Parameters.AddWithValue("@Date", Monthyear);
                    SqlDataReader reader = cmd.ExecuteReader();


                    if (reader.Read())
                    {

                        if (reader["total_precent_days"] != DBNull.Value)
                        {
                            emp.Working_days = Convert.ToInt32(reader["total_precent_days"]);
                        }

                        if (reader["Overtime_Rate"] != DBNull.Value)
                        {
                            emp.Overtime_rate = Convert.ToInt32(reader["Overtime_Rate"]);
                        }

                        if (reader["Days"] != DBNull.Value)
                        {
                            emp.Days = Convert.ToInt32(reader["Days"]);
                        }

                        if (reader["Overtime_day"] != DBNull.Value)
                        {
                            emp.Overtime_days = Convert.ToInt32(reader["Overtime_day"]);
                        }

                        if (reader["leaves"] != DBNull.Value)
                        {
                            emp.Leaves = reader["leaves"].ToString();
                        }

                        if (reader["Net_Salary"] != DBNull.Value)
                        {
                            emp.Gross_salary = Convert.ToInt32(reader["Net_Salary"]);
                        }

                        if (reader["Adv_staff"] != DBNull.Value)
                        {
                            emp.Adv_Staff = Convert.ToInt32(reader["Adv_staff"]);
                        }
                        if (reader["I_tax"] != DBNull.Value)
                        {
                            emp.I_tax = Convert.ToInt32(reader["I_tax"]);
                        }

                        if (reader["Telephone"] != DBNull.Value)
                        {
                            emp.Telephone = Convert.ToInt32(reader["Telephone"]);
                        }
                        if (reader["EOBI"] != DBNull.Value)
                        {
                            emp.EOBI = Convert.ToInt32(reader["EOBI"]);
                        }
                        
                        //emp.Working_days = Convert.ToInt32(reader["working_days"]);
                        //emp.Working_hours = Convert.ToInt32(reader["working_hours"]);
                        //emp.Holidays = Convert.ToInt32(reader["Holiday"]);
                        //emp.Abcent = Convert.ToInt32(reader["Current_abcent"]);
                        //emp.Current_Salary_Hours = Convert.ToInt32(reader["Current_Salary_hours"]);
                        //emp.Overtime_Time_hours = Convert.ToInt32(reader["Over_time_hours"]);
                        //emp.Overtime_Amount = Convert.ToInt32(reader["Overtime_amount"]);
                        //emp.Gross_salary = Convert.ToInt32(reader["Gross_salary"]);

                    };
                }
            }
            return emp;
        }


        public void InsertPayroll(Payroll_Data pd)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("insert into Payroll (Emp_id,	Pyoll_Date,	Working_Days,	Working_Hours,	Holidays,	Current_Abcent,	Leaves,Gross_Salary , Adv_staff, I_Tax , Telephone, EOBI, Overtime_day, Overtime_Rate, Days)  values (@Emp_id,	@Pyoll_Date,	@Working_Days,	@Working_Hours,	@Holidays,	@Current_Abcent,	@Leaves,@Gross_Salary , @Adv_staff, @I_Tax , @Telephone, @EOBI, @Overtime_day, @Overtime_Rate, @Days)", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", pd.emp_id);
                    cmd.Parameters.AddWithValue("@Pyoll_Date", pd.date);
                    cmd.Parameters.AddWithValue("@Working_Days", pd.Working_days);
                    cmd.Parameters.AddWithValue("@Working_Hours", pd.Working_hours);
                    cmd.Parameters.AddWithValue("@Holidays", pd.Holidays);
                    cmd.Parameters.AddWithValue("@Current_Abcent", pd.Abcent);
                    if (pd.Leaves != null)
                    {
                        cmd.Parameters.AddWithValue("@Leaves", pd.Leaves);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Leaves", "0");
                    }
                    cmd.Parameters.AddWithValue("@Gross_Salary", pd.Gross_salary);
                    cmd.Parameters.AddWithValue("@Adv_staff", pd.Adv_Staff);
                    cmd.Parameters.AddWithValue("@I_Tax", pd.I_tax);
                    cmd.Parameters.AddWithValue("@Telephone", pd.Telephone);
                    cmd.Parameters.AddWithValue("@EOBI", pd.EOBI);
                    cmd.Parameters.AddWithValue("@Overtime_day", pd.Overtime_days);
                    cmd.Parameters.AddWithValue("@Overtime_Rate", pd.Overtime_rate);
                    cmd.Parameters.AddWithValue("@Days", pd.Days);
                    cmd.ExecuteNonQuery();
                }
            }
        }


        public Dashboard Dashboard_data()
        {
            Dashboard emp = new Dashboard();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("Dashboard_data", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    conn.Open();

                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        emp.employees = Convert.ToInt32(reader["no_employees"]);
                        emp.Holidays = Convert.ToInt32(reader["no_holidays"]);
                        emp.ex_employess = Convert.ToInt32(reader["no_ex_employees"]);
                    };
                }
            }
            return emp;
        }


        public Employee user_login(string email, string password)
        {
            Employee employee = new Employee();

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select * from login l where l.Email = @user_email and l.Password = @user_password and l.User_status = 'Y'", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@user_email", email);
                    cmd.Parameters.AddWithValue("@user_password", password);

                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        if (reader["id"] != DBNull.Value)
                        {
                            employee.Emp_id = Convert.ToInt32(reader["id"]);
                        }
                        if (reader["User_Name"] != DBNull.Value)
                        {
                            employee.Name = Convert.ToString(reader["User_Name"]);
                        }
                        if (reader["Email"] != DBNull.Value)
                        {
                            employee.Email = Convert.ToString(reader["Email"]);
                        }
                        if (reader["Password"] != DBNull.Value)
                        {
                            employee.Password = Convert.ToString(reader["Password"]);
                        }
                    }


                }
            }
            return employee;
        }


        public Employee Max_Empid()
        {
            Employee employee = new Employee();

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select max(e.Emp_id) +1 emp_id from Employee e", conn))
                {

                    conn.Open();

                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        if (reader["emp_id"] != DBNull.Value)
                        {
                            employee.Emp_id = Convert.ToInt32(reader["emp_id"]);
                        }
                    }


                }
            }
            return employee;
        }

        public Payroll_Data Check_Payslip_data(int emp_id, string Monthwithdate)
        {
            Payroll_Data employee = new Payroll_Data();

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select count(*)emp_count from Payroll p where p.Emp_id = @emp_id and  convert(varchar(7), p.Pyoll_Date, 126)  = convert(varchar(7), @Month, 126)", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@emp_id", emp_id);
                    cmd.Parameters.AddWithValue("@Month", Monthwithdate);

                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        if (reader["emp_count"] != DBNull.Value)
                        {
                            employee.Count_emp = Convert.ToInt32(reader["emp_count"]);
                        }
                    }


                }
            }
            return employee;
        }

        public Payroll_Data Payslip_data(int emp_id, DateTime Month)
        {
            Payroll_Data employee = new Payroll_Data();

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select e.Emp_id, e.Name, e.Gross_Salary basic_sal , e.Email,e.Designation,e.Phone,p.Pyoll_Date,p.Working_Days, p.Holidays, p.Current_Abcent ,  p.Overtime_day, p.Overtime_Rate , p.Gross_Salary , p.Days, p.Adv_Staff , p.I_Tax , p.Telephone , p.EOBI  from payroll p , Employee e   where p.Emp_id = e.Emp_id  and e.Emp_id = @emp_id and e.Status = 'Y' and  convert(varchar(7), p.Pyoll_Date, 126) = convert(varchar(7), @P_Date, 126)", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@emp_id", emp_id);
                    cmd.Parameters.AddWithValue("@P_Date", Month);

                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        if (reader["Emp_id"] != DBNull.Value)
                        {
                            employee.emp_id = Convert.ToInt32(reader["Emp_id"]);
                        }
                        if (reader["Name"] != DBNull.Value)
                        {
                            employee.Name = Convert.ToString(reader["Name"]);
                        }
                        if (reader["Email"] != DBNull.Value)
                        {
                            employee.Email = Convert.ToString(reader["Email"]);
                        }

                        if (reader["basic_sal"] != DBNull.Value)
                        {
                            employee.basic_sal = Convert.ToString(reader["basic_sal"]);
                        }
                        if (reader["Designation"] != DBNull.Value)
                        {
                            employee.Designation = Convert.ToString(reader["Designation"]);
                        }
                        if (reader["Phone"] != DBNull.Value)
                        {
                            employee.Phone = Convert.ToString(reader["Phone"]);
                        }
                        if (reader["Pyoll_Date"] != DBNull.Value)
                        {
                            employee.date= Convert.ToDateTime(reader["Pyoll_Date"]);
                        }
                        if (reader["Working_Days"] != DBNull.Value)
                        {
                            employee.Working_days = Convert.ToInt32(reader["Working_Days"]);
                        }

                        if (reader["Holidays"] != DBNull.Value)
                        {
                            employee.Holidays = Convert.ToInt32(reader["Holidays"]);
                        }

                        if (reader["Overtime_day"] != DBNull.Value)
                        {
                            employee.Overtime_days = Convert.ToInt32(reader["Overtime_day"]);
                        }

                        if (reader["Overtime_Rate"] != DBNull.Value)
                        {
                            employee.Overtime_rate = Convert.ToInt32(reader["Overtime_Rate"]);
                        }

                        if (reader["Days"] != DBNull.Value)
                        {
                            employee.Days = Convert.ToInt32(reader["Days"]);
                        }

                        if (reader["Current_Abcent"] != DBNull.Value)
                        {
                            employee.Abcent = Convert.ToInt32(reader["Current_Abcent"]);
                        }

                        

                        if (reader["Gross_Salary"] != DBNull.Value)
                        {
                            employee.Gross_salary = Convert.ToInt32(reader["Gross_Salary"]);
                        }

                        if (reader["Adv_Staff"] != DBNull.Value)
                        {
                            employee.Adv_Staff = Convert.ToInt32(reader["Adv_Staff"]);
                        }

                        if (reader["I_Tax"] != DBNull.Value)
                        {
                            employee.I_tax = Convert.ToInt32(reader["I_Tax"]);
                        }

                        if (reader["Telephone"] != DBNull.Value)
                        {
                            employee.Telephone = Convert.ToInt32(reader["Telephone"]);
                        }

                        if (reader["EOBI"] != DBNull.Value)
                        {
                            employee.EOBI = Convert.ToInt32(reader["EOBI"]);
                        }
                    }


                }
            }
            return employee;
        }


        public List<Payroll_Data> Bulk_Payslip_data(DateTime Month)
        {
            List<Payroll_Data> employee = new List<Payroll_Data>();

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select e.Emp_id, e.Name, e.Email,e.Designation,e.Phone,p.Pyoll_Date,p.Working_Days, p.Holidays, p.Current_Abcent , p.Current_Salary_Hours, p.Over_time_Hours, p.Overtime_amount , p.Gross_Salary  from payroll p , Employee e   where p.Emp_id = e.Emp_id  and e.Status = 'Y' and  convert(varchar(7), p.Pyoll_Date, 126) = convert(varchar(7), @P_Date, 126)", conn))
                {

                    conn.Open();

                    //cmd.Parameters.AddWithValue("@emp_id", emp_id);
                    cmd.Parameters.AddWithValue("@P_Date", Month);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Payroll_Data paydata = new Payroll_Data();
                        if (reader["Emp_id"] != DBNull.Value)
                        {
                            paydata.emp_id = Convert.ToInt32(reader["Emp_id"]);
                        }
                        if (reader["Name"] != DBNull.Value)
                        {
                            paydata.Name = Convert.ToString(reader["Name"]);
                        }
                        if (reader["Email"] != DBNull.Value)
                        {
                            paydata.Email = Convert.ToString(reader["Email"]);
                        }
                        if (reader["Designation"] != DBNull.Value)
                        {
                            paydata.Designation = Convert.ToString(reader["Designation"]);
                        }
                        if (reader["Phone"] != DBNull.Value)
                        {
                            paydata.Phone = Convert.ToString(reader["Phone"]);
                        }
                        if (reader["Pyoll_Date"] != DBNull.Value)
                        {
                            paydata.date = Convert.ToDateTime(reader["Pyoll_Date"]);
                        }
                        if (reader["Pyoll_Date"] != DBNull.Value)
                        {
                            paydata.payroll_date = Convert.ToString(reader["Pyoll_Date"]);
                        }
                        if (reader["Working_Days"] != DBNull.Value)
                        {
                            paydata.Working_days = Convert.ToInt32(reader["Working_Days"]);
                        }

                        if (reader["Holidays"] != DBNull.Value)
                        {
                            paydata.Holidays = Convert.ToInt32(reader["Holidays"]);
                        }

                        if (reader["Current_Abcent"] != DBNull.Value)
                        {
                            paydata.Abcent = Convert.ToInt32(reader["Current_Abcent"]);
                        }

                        if (reader["Current_Salary_Hours"] != DBNull.Value)
                        {
                            paydata.Current_Salary_Hours = Convert.ToInt32(reader["Current_Salary_Hours"]);
                        }

                        if (reader["Over_time_Hours"] != DBNull.Value)
                        {
                            paydata.Overtime_Time_hours = Convert.ToInt32(reader["Over_time_Hours"]);
                        }

                        if (reader["Overtime_amount"] != DBNull.Value)
                        {
                            paydata.Overtime_Amount = Convert.ToInt32(reader["Overtime_amount"]);
                        }

                        if (reader["Gross_Salary"] != DBNull.Value)
                        {
                            paydata.Gross_salary = Convert.ToInt32(reader["Gross_Salary"]);
                        }

                        employee.Add(paydata);
                    }


                }
            }
            return employee;
        }


        public Employee Excel_data_reader(string employee_id)
        {
            Employee att = new Employee();

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("exl_dta_shw_rntm", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", employee_id);

                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        if (reader["Name"] != DBNull.Value)
                        {
                            att.Name = Convert.ToString(reader["Name"]);
                        }
                    }


                }
            }
            return att;
        }


        public void Excel_data_save(Attendance a)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("insert into Attendance_Sheet(Emp_id, Attendance_Date,Time, Status) values (@Emp_id, @Attendance_Date,@Time, @Status)", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", a.Emp_id);
                    cmd.Parameters.AddWithValue("@Attendance_Date", a.Attendance_Date.Date);
                    cmd.Parameters.AddWithValue("@Time", a.Time_IN);
                    cmd.Parameters.AddWithValue("@Status", a.Status);
                   
                    cmd.ExecuteNonQuery();
                }
            }

        }




        public void Activity_log(Activity_log al)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("insert into Activity_log (Document, Table_flag, Activity_Type, User_id) values(@Document, @Table_flag, @Activity_Type, @User_id)", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@Document", al.Document);
                    cmd.Parameters.AddWithValue("@Table_flag", al.Table_flag);
                    cmd.Parameters.AddWithValue("@Activity_Type", "Insert");
                    cmd.Parameters.AddWithValue("@User_id", al.User_id);

                    cmd.ExecuteNonQuery();
                }
            }
        }


        public List<Holidays> Holiday_list()
        {
            List<Holidays> DBase = new List<Holidays>();
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select id,H_Date, H_Reason from Holiday", conn))
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Holidays emp = new Holidays();

                        emp.id = Convert.ToInt32(reader["id"]);
                        emp.Holidays_Date = Convert.ToDateTime(reader["H_Date"]);
                        emp.Reason = Convert.ToString(reader["H_Reason"]);

                        DBase.Add(emp);

                    }
                }
            }
            return DBase;
        }

        public void Insertholiday(Holidays h)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("insert into Holiday(H_Date, H_Reason,created_by, created_date) values (@H_Date, @H_Reason,@created_by, @created_date)", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@H_Date", h.Holidays_Date);
                    cmd.Parameters.AddWithValue("@H_Reason", h.Reason);

                    if (h.Created_by != null)
                    {
                        cmd.Parameters.AddWithValue("@Created_by", h.Created_by);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Created_by", DBNull.Value);
                    }
                        cmd.Parameters.AddWithValue("@created_date", DateTime.Now);


                    cmd.ExecuteNonQuery();
                }
            }

        }


        public Holidays Per_Holiday(int id)
        {
            Holidays emp = new Holidays();

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select * from Holiday h where h.id =@h_id", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@h_id", id);
                    SqlDataReader reader = cmd.ExecuteReader();

                    reader.Read();

                    emp.id = Convert.ToInt32(reader["id"]);
                    emp.Holidays_Date = Convert.ToDateTime(reader["H_Date"]);
                    emp.Reason = reader["H_Reason"].ToString();
                }
            }
            return emp;
        }

        public void Update_holidays(Holidays e)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("update Holiday set H_Date = @H_Date, H_Reason = @H_Reason where id = @h_id", conn))
                {
                    conn.Open();
                    cmd.Parameters.AddWithValue("@h_id", e.id);
                    cmd.Parameters.AddWithValue("@H_Date", e.Holidays_Date);
                    cmd.Parameters.AddWithValue("@H_Reason", e.Reason);
                   
                    cmd.ExecuteNonQuery();

                }
            }
        }


        public void DeleteHoliday(int id)
        {
            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("delete from Holiday where id = @id", conn))
                {
                    conn.Open();

                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();

                }
            }
        }

    }
}
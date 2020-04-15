using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Hospital_Payroll.Models;
using Hospital_Payroll.Database;
using System.Data.SqlClient;


namespace Hospital_Payroll.Database
{
    public class DB
    {
        string connectString = Database_Connection.connectString;
        public void InsertEmployee(Employee_M empm)
        {
            DateTime datetime = DateTime.Today;

            using (SqlConnection conn = new SqlConnection(connectString))
            {

                using (SqlCommand cmd = new SqlCommand("insert into Employee (Emp_id,	Name,	Father_Name,	CNIC,	address,	Phone,	Email,	Date_of_Birth,	Gender,	Designation,	Gross_Salary,	Time_In,	Time_Out,	Grace_Time_IN,	Grace_Time_Out,	Overtime_Rate,	Monday_WD,	Tuesday_WD,	Wednesday_WD,	Thursday_WD,	Friday_WD,	Saturday_WD,	Sunday_WD) values(@Emp_id,	@Name,	@Father_Name,	@CNIC,	@address,	@Phone,	@Email,	@Date_of_Birth,	@Gender,	@Designation,	@Gross_Salary,	@Time_In,	@Time_Out,	@Grace_Time_IN,	@Grace_Time_Out,	@Overtime_Rate,	@Monday_WD,	@Tuesday_WD,	@Wednesday_WD,	@Thursday_WD,	@Friday_WD,	@Saturday_WD,	@Sunday_WD)", conn))
                {
                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", empm.Emp_id);

                    if (string.IsNullOrEmpty(empm.Name))
                    {
                        cmd.Parameters.AddWithValue("@Name", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Name", empm.Name);
                    }

                    if (string.IsNullOrEmpty(empm.Father_Name))
                    {
                        cmd.Parameters.AddWithValue("@Father_Name", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Father_Name", empm.Father_Name);
                    }

                    if (string.IsNullOrEmpty(empm.CNIC))
                    {
                        cmd.Parameters.AddWithValue("@CNIC", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@CNIC", empm.CNIC);
                    }

                    if (string.IsNullOrEmpty(empm.address))
                    {
                        cmd.Parameters.AddWithValue("@address", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@address", empm.address);
                    }

                    if (string.IsNullOrEmpty(empm.Phone))
                    {
                        cmd.Parameters.AddWithValue("@Phone", DBNull.Value);
                    }
                    else { cmd.Parameters.AddWithValue("@Phone", empm.Phone); }
                    if (string.IsNullOrEmpty(empm.Email)) { cmd.Parameters.AddWithValue("@Email", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Email", empm.Email); }
                    if (string.IsNullOrEmpty(empm.Date_of_Birth)) { cmd.Parameters.AddWithValue("@Date_of_Birth", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Date_of_Birth", empm.Date_of_Birth); }
                    if (string.IsNullOrEmpty(empm.Gender)) { cmd.Parameters.AddWithValue("@Gender", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Gender", empm.Gender); }
                    if (string.IsNullOrEmpty(empm.Designation)) { cmd.Parameters.AddWithValue("@Designation", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Designation", empm.Designation); }
                    if (string.IsNullOrEmpty(empm.Gross_Salary)) { cmd.Parameters.AddWithValue("@Gross_Salary", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Gross_Salary", empm.Gross_Salary); }
                    if (string.IsNullOrEmpty(empm.Time_In)) { cmd.Parameters.AddWithValue("@Time_In", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Time_In", empm.Time_In); }
                    if (string.IsNullOrEmpty(empm.Time_Out)) { cmd.Parameters.AddWithValue("@Time_Out", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Time_Out", empm.Time_Out); }
                    if (string.IsNullOrEmpty(empm.Grace_Time_IN)) { cmd.Parameters.AddWithValue("@Grace_Time_IN", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Grace_Time_IN", empm.Grace_Time_IN); }
                    if (string.IsNullOrEmpty(empm.Grace_Time_Out)) { cmd.Parameters.AddWithValue("@Grace_Time_Out", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Grace_Time_Out", empm.Grace_Time_Out); }
                    if (string.IsNullOrEmpty(empm.Overtime_Rate)) { cmd.Parameters.AddWithValue("@Overtime_Rate", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Overtime_Rate", empm.Overtime_Rate); }
                    if (string.IsNullOrEmpty(empm.Monday_WD)) { cmd.Parameters.AddWithValue("@Monday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Monday_WD", empm.Monday_WD); }
                    if (string.IsNullOrEmpty(empm.Tuesday_WD)) { cmd.Parameters.AddWithValue("@Tuesday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Tuesday_WD", empm.Tuesday_WD); }
                    if (string.IsNullOrEmpty(empm.Wednesday_WD)) { cmd.Parameters.AddWithValue("@Wednesday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Wednesday_WD", empm.Wednesday_WD); }
                    if (string.IsNullOrEmpty(empm.Thursday_WD)) { cmd.Parameters.AddWithValue("@Thursday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Thursday_WD", empm.Thursday_WD); }
                    if (string.IsNullOrEmpty(empm.Friday_WD)) { cmd.Parameters.AddWithValue("@Friday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Friday_WD", empm.Friday_WD); }
                    if (string.IsNullOrEmpty(empm.Saturday_WD)) { cmd.Parameters.AddWithValue("@Saturday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Saturday_WD", empm.Saturday_WD); }
                    if (string.IsNullOrEmpty(empm.Sunday_WD)) { cmd.Parameters.AddWithValue("@Sunday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Sunday_WD", empm.Sunday_WD); }




                    cmd.ExecuteNonQuery();
                }
            }

        }


        public Employee_M Emp_id_Generate()
        {
            Employee_M Emp = new Employee_M();
            SqlConnection con = new SqlConnection(connectString);
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "select isnull(max(e.Emp_id),0)+1 Emp_id from Employee e";
            cmd.Connection = con;
            con.Open();

            SqlDataReader reader = cmd.ExecuteReader();

            reader.Read();

            Emp.Emp_id = Convert.ToInt16(reader["Emp_id"]);

            reader.Close();
            return Emp;
        }


        public List<Employee_M> EMP_Tab_Data()
        {
            List<Employee_M> DBase = new List<Employee_M>();

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select e.Emp_id,e.Name, e.Date_of_Birth , e.Gender, e.Phone, e.Email from Employee e", conn))
                {
                    conn.Open();

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Employee_M awm = new Employee_M();

                        awm.Emp_id = Convert.ToInt32(reader["Emp_id"]);
                        awm.Name = Convert.ToString(reader["Name"]);

                        if (reader["Date_of_Birth"] != DBNull.Value)
                        {
                            awm.Date_of_Birth = Convert.ToDateTime(reader["Date_of_Birth"]).ToString("yyyy-MM-dd");
                        }
                        awm.Gender = Convert.ToString(reader["Gender"]);
                        awm.Phone = Convert.ToString(reader["Phone"]);
                        awm.Email = Convert.ToString(reader["Email"]);


                        DBase.Add(awm);
                    }
                }
            }
            return DBase;
        }


        public Employee_M EMPdetailbyid(int id)
        {
            Employee_M updateEMPDetail = new Employee_M();

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("select * from Employee e where e.Emp_id = @Emp_id", conn))
                {
                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", id);
                    SqlDataReader reader = cmd.ExecuteReader();

                    reader.Read();

                    updateEMPDetail.Emp_id = Convert.ToInt32(reader["Emp_id"]);

                    if (reader["Name"] != DBNull.Value) { updateEMPDetail.Name = reader["Name"].ToString(); }
                    if (reader["Father_Name"] != DBNull.Value) { updateEMPDetail.Father_Name = reader["Father_Name"].ToString(); }
                    if (reader["CNIC"] != DBNull.Value) { updateEMPDetail.CNIC = reader["CNIC"].ToString(); }
                    if (reader["address"] != DBNull.Value) { updateEMPDetail.address = reader["address"].ToString(); }
                    if (reader["Phone"] != DBNull.Value) { updateEMPDetail.Phone = reader["Phone"].ToString(); }
                    if (reader["Email"] != DBNull.Value) { updateEMPDetail.Email = reader["Email"].ToString(); }
                    if (reader["Date_of_Birth"] != DBNull.Value) { updateEMPDetail.Date_of_Birth = reader["Date_of_Birth"].ToString(); }
                    if (reader["Gender"] != DBNull.Value) { updateEMPDetail.Gender = reader["Gender"].ToString(); }
                    if (reader["Designation"] != DBNull.Value) { updateEMPDetail.Designation = reader["Designation"].ToString(); }
                    if (reader["Gross_Salary"] != DBNull.Value) { updateEMPDetail.Gross_Salary = reader["Gross_Salary"].ToString(); }
                    if (reader["Time_In"] != DBNull.Value) { updateEMPDetail.Time_In = reader["Time_In"].ToString(); }
                    if (reader["Time_Out"] != DBNull.Value) { updateEMPDetail.Time_Out = reader["Time_Out"].ToString(); }
                    if (reader["Grace_Time_IN"] != DBNull.Value) { updateEMPDetail.Grace_Time_IN = reader["Grace_Time_IN"].ToString(); }
                    if (reader["Grace_Time_Out"] != DBNull.Value) { updateEMPDetail.Grace_Time_Out = reader["Grace_Time_Out"].ToString(); }
                    if (reader["Overtime_Rate"] != DBNull.Value) { updateEMPDetail.Overtime_Rate = reader["Overtime_Rate"].ToString(); }
                    if (reader["Monday_WD"] != DBNull.Value) { updateEMPDetail.Monday_WD = reader["Monday_WD"].ToString(); }
                    if (reader["Tuesday_WD"] != DBNull.Value) { updateEMPDetail.Tuesday_WD = reader["Tuesday_WD"].ToString(); }
                    if (reader["Wednesday_WD"] != DBNull.Value) { updateEMPDetail.Wednesday_WD = reader["Wednesday_WD"].ToString(); }
                    if (reader["Thursday_WD"] != DBNull.Value) { updateEMPDetail.Thursday_WD = reader["Thursday_WD"].ToString(); }
                    if (reader["Friday_WD"] != DBNull.Value) { updateEMPDetail.Friday_WD = reader["Friday_WD"].ToString(); }
                    if (reader["Saturday_WD"] != DBNull.Value) { updateEMPDetail.Saturday_WD = reader["Saturday_WD"].ToString(); }
                    if (reader["Sunday_WD"] != DBNull.Value) { updateEMPDetail.Sunday_WD = reader["Sunday_WD"].ToString(); }






                }
            }
            return updateEMPDetail;
        }


        public void Update_EMP(Employee_M e)
        {

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("update Employee set Emp_id= @Emp_id,	Name= @Name,	Father_Name= @Father_Name,	CNIC= @CNIC,	address= @address,	Phone= @Phone,	Email= @Email,	Date_of_Birth= @Date_of_Birth,	Gender= @Gender,	Designation= @Designation,	Gross_Salary= @Gross_Salary,	Time_In= @Time_In,	Time_Out= @Time_Out,	Grace_Time_IN= @Grace_Time_IN,	Grace_Time_Out= @Grace_Time_Out,	Overtime_Rate= @Overtime_Rate,	Monday_WD= @Monday_WD,	Tuesday_WD= @Tuesday_WD,	Wednesday_WD= @Wednesday_WD,	Thursday_WD= @Thursday_WD,	Friday_WD= @Friday_WD,	Saturday_WD= @Saturday_WD,	Sunday_WD= @Sunday_WD where Emp_id = @Emp_id;", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", e.Emp_id);


                    if (string.IsNullOrEmpty(e.Name)) { cmd.Parameters.AddWithValue("@Name", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Name", e.Name); }
                    if (string.IsNullOrEmpty(e.Father_Name)) { cmd.Parameters.AddWithValue("@Father_Name", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Father_Name", e.Father_Name); }
                    if (string.IsNullOrEmpty(e.CNIC)) { cmd.Parameters.AddWithValue("@CNIC", DBNull.Value); } else { cmd.Parameters.AddWithValue("@CNIC", e.CNIC); }
                    if (string.IsNullOrEmpty(e.address)) { cmd.Parameters.AddWithValue("@address", DBNull.Value); } else { cmd.Parameters.AddWithValue("@address", e.address); }
                    if (string.IsNullOrEmpty(e.Phone)) { cmd.Parameters.AddWithValue("@Phone", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Phone", e.Phone); }
                    if (string.IsNullOrEmpty(e.Email)) { cmd.Parameters.AddWithValue("@Email", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Email", e.Email); }
                    if (string.IsNullOrEmpty(e.Date_of_Birth)) { cmd.Parameters.AddWithValue("@Date_of_Birth", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Date_of_Birth", e.Date_of_Birth); }
                    if (string.IsNullOrEmpty(e.Gender)) { cmd.Parameters.AddWithValue("@Gender", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Gender", e.Gender); }
                    if (string.IsNullOrEmpty(e.Designation)) { cmd.Parameters.AddWithValue("@Designation", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Designation", e.Designation); }
                    if (string.IsNullOrEmpty(e.Gross_Salary)) { cmd.Parameters.AddWithValue("@Gross_Salary", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Gross_Salary", e.Gross_Salary); }
                    if (string.IsNullOrEmpty(e.Time_In)) { cmd.Parameters.AddWithValue("@Time_In", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Time_In", e.Time_In); }
                    if (string.IsNullOrEmpty(e.Time_Out)) { cmd.Parameters.AddWithValue("@Time_Out", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Time_Out", e.Time_Out); }
                    if (string.IsNullOrEmpty(e.Grace_Time_IN)) { cmd.Parameters.AddWithValue("@Grace_Time_IN", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Grace_Time_IN", e.Grace_Time_IN); }
                    if (string.IsNullOrEmpty(e.Grace_Time_Out)) { cmd.Parameters.AddWithValue("@Grace_Time_Out", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Grace_Time_Out", e.Grace_Time_Out); }
                    if (string.IsNullOrEmpty(e.Overtime_Rate)) { cmd.Parameters.AddWithValue("@Overtime_Rate", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Overtime_Rate", e.Overtime_Rate); }
                    if (string.IsNullOrEmpty(e.Monday_WD)) { cmd.Parameters.AddWithValue("@Monday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Monday_WD", e.Monday_WD); }
                    if (string.IsNullOrEmpty(e.Tuesday_WD)) { cmd.Parameters.AddWithValue("@Tuesday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Tuesday_WD", e.Tuesday_WD); }
                    if (string.IsNullOrEmpty(e.Wednesday_WD)) { cmd.Parameters.AddWithValue("@Wednesday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Wednesday_WD", e.Wednesday_WD); }
                    if (string.IsNullOrEmpty(e.Thursday_WD)) { cmd.Parameters.AddWithValue("@Thursday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Thursday_WD", e.Thursday_WD); }
                    if (string.IsNullOrEmpty(e.Friday_WD)) { cmd.Parameters.AddWithValue("@Friday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Friday_WD", e.Friday_WD); }
                    if (string.IsNullOrEmpty(e.Saturday_WD)) { cmd.Parameters.AddWithValue("@Saturday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Saturday_WD", e.Saturday_WD); }
                    if (string.IsNullOrEmpty(e.Sunday_WD)) { cmd.Parameters.AddWithValue("@Sunday_WD", DBNull.Value); } else { cmd.Parameters.AddWithValue("@Sunday_WD", e.Sunday_WD); }


                    cmd.ExecuteNonQuery();
                }
            }
        }


        public void EMPdeleterecord(int id)
        {

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("delete from Employee where Emp_id = @Emp_id", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", id);

                    cmd.ExecuteNonQuery();

                }

            }
        }


    }
}

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

                using (SqlCommand cmd = new SqlCommand("insert into Employee (Emp_id,Name,	Date_of_Birth,	Gender,	Phone,	address,	Email,	Password,	Branch,	Department,	Designation,	Company_Date_of_joining,	Account_holder_name,	Account_number,	Bank_Name,	Bank_Identifier_Code,	Branch_location,	Tax_Payer_id) values(@Emp_id,@Name,	@Date_of_Birth,	@Gender,	@Phone,	@address,	@Email,	@Password,	@Branch,	@Department,	@Designation,	@Company_Date_of_joining,	@Account_holder_name,	@Account_number,	@Bank_Name,	@Bank_Identifier_Code,	@Branch_location,	@Tax_Payer_id)", conn))
                {
                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", empm.Emp_id);
                    cmd.Parameters.AddWithValue("@Name", empm.Name);

                    if (string.IsNullOrEmpty(empm.Date_of_Birth))
                    {
                        cmd.Parameters.AddWithValue("@Date_of_Birth", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Date_of_Birth", empm.Date_of_Birth);
                    }

                    cmd.Parameters.AddWithValue("@Gender", empm.Gender);
                    cmd.Parameters.AddWithValue("@Phone", empm.Phone);

                    if (string.IsNullOrEmpty(empm.address))
                    {
                        cmd.Parameters.AddWithValue("@address", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@address", empm.address);
                    }

                    cmd.Parameters.AddWithValue("@Email", empm.Email);
                    cmd.Parameters.AddWithValue("@Password", empm.Password);

                    if (string.IsNullOrEmpty(empm.Branch))
                    {
                        cmd.Parameters.AddWithValue("@Branch", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Branch", empm.Branch);
                    }


                    if (string.IsNullOrEmpty(empm.Department))
                    {
                        cmd.Parameters.AddWithValue("@Department", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Department", empm.Department);
                    }

                    if (string.IsNullOrEmpty(empm.Designation))
                    {
                        cmd.Parameters.AddWithValue("@Designation", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Designation", empm.Designation);
                    }

                    if (string.IsNullOrEmpty(empm.Company_Date_of_joining))
                    {
                        cmd.Parameters.AddWithValue("@Company_Date_of_joining", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Company_Date_of_joining", empm.Company_Date_of_joining);
                    }

                    if (string.IsNullOrEmpty(empm.Account_holder_name))
                    {
                        cmd.Parameters.AddWithValue("@Account_holder_name", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Account_holder_name", empm.Account_holder_name);
                    }

                    if (string.IsNullOrEmpty(empm.Account_number))
                    {
                        cmd.Parameters.AddWithValue("@Account_number", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Account_number", empm.Account_number);
                    }

                    if (string.IsNullOrEmpty(empm.Bank_Name))
                    {
                        cmd.Parameters.AddWithValue("@Bank_Name", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Bank_Name", empm.Bank_Name);
                    }

                    if (string.IsNullOrEmpty(empm.Bank_Identifier_Code))
                    {
                        cmd.Parameters.AddWithValue("@Bank_Identifier_Code", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Bank_Identifier_Code", empm.Bank_Identifier_Code);
                    }

                    if (string.IsNullOrEmpty(empm.Branch_location))
                    {
                        cmd.Parameters.AddWithValue("@Branch_location", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Branch_location", empm.Branch_location);
                    }

                    if (string.IsNullOrEmpty(empm.Tax_Payer_id))
                    {
                        cmd.Parameters.AddWithValue("@Tax_Payer_id", DBNull.Value);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Tax_Payer_id", empm.Tax_Payer_id);
                    }

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

                    if (reader["Name"] != DBNull.Value)
                    {
                        updateEMPDetail.Name = reader["Name"].ToString();
                    }

                    if (reader["Date_of_Birth"] != DBNull.Value)
                    {
                        updateEMPDetail.Date_of_Birth = Convert.ToDateTime(reader["Date_of_Birth"]).ToString("yyyy-MM-dd");
                    }

                    if (reader["Gender"] != DBNull.Value)
                    {
                        updateEMPDetail.Gender = reader["Gender"].ToString();
                    }

                    if (reader["Phone"] != DBNull.Value)
                    {
                        updateEMPDetail.Phone = reader["Phone"].ToString();

                    }

                    if (reader["address"] != DBNull.Value)
                    {
                        updateEMPDetail.address = reader["address"].ToString();

                    }

                    if (reader["Email"] != DBNull.Value)
                    {
                        updateEMPDetail.Email = reader["Email"].ToString();

                    }

                    if (reader["Password"] != DBNull.Value)
                    {
                        updateEMPDetail.Password = reader["Password"].ToString();

                    }

                    if (reader["Branch"] != DBNull.Value)
                    {
                        updateEMPDetail.Branch = reader["Branch"].ToString();

                    }

                    if (reader["Department"] != DBNull.Value)
                    {
                        updateEMPDetail.Department = reader["Department"].ToString();

                    }

                    if (reader["Designation"] != DBNull.Value)
                    {
                        updateEMPDetail.Designation = reader["Designation"].ToString();

                    }

                    if (reader["Company_Date_of_joining"] != DBNull.Value)
                    {
                        updateEMPDetail.Company_Date_of_joining = Convert.ToDateTime(reader["Company_Date_of_joining"]).ToString("yyyy-MM-dd");

                    }

                    if (reader["certificates"] != DBNull.Value)
                    {
                        updateEMPDetail.certificates = reader["certificates"].ToString();

                    }

                    if (reader["resume"] != DBNull.Value)
                    {
                        updateEMPDetail.resume = reader["resume"].ToString();

                    }

                    if (reader["Photo"] != DBNull.Value)
                    {
                        updateEMPDetail.Photo = reader["Photo"].ToString();

                    }

                    if (reader["Account_holder_name"] != DBNull.Value)
                    {
                        updateEMPDetail.Account_holder_name = reader["Account_holder_name"].ToString();

                    }

                    if (reader["Account_number"] != DBNull.Value)
                    {
                        updateEMPDetail.Account_number = reader["Account_number"].ToString();

                    }

                    if (reader["Bank_Name"] != DBNull.Value)
                    {
                        updateEMPDetail.Bank_Name = reader["Bank_Name"].ToString();

                    }

                    if (reader["Bank_Identifier_Code"] != DBNull.Value)
                    {
                        updateEMPDetail.Bank_Identifier_Code = reader["Bank_Identifier_Code"].ToString();

                    }

                    if (reader["Branch_location"] != DBNull.Value)
                    {
                        updateEMPDetail.Branch_location = reader["Branch_location"].ToString();

                    }

                    if (reader["Tax_Payer_id"] != DBNull.Value)
                    {
                        updateEMPDetail.Tax_Payer_id = reader["Tax_Payer_id"].ToString();

                    }




                }
            }
            return updateEMPDetail;
        }


        public void Update_EMP(Employee_M e)
        {

            using (SqlConnection conn = new SqlConnection(connectString))
            {
                using (SqlCommand cmd = new SqlCommand("update Employee set Name=@Name,	Date_of_Birth=@Date_of_Birth,	Gender=@Gender,	Phone=@Phone,	address=@address,	Email=@Email,	Password=@Password,	Branch=@Branch,	Department=@Department,	Designation=@Designation,	Company_Date_of_joining=@Company_Date_of_joining,	Account_holder_name=@Account_holder_name,	Account_number=@Account_number,	Bank_Name=@Bank_Name,	Bank_Identifier_Code=@Bank_Identifier_Code,	Branch_location=@Branch_location,	Tax_Payer_id=@Tax_Payer_id where Emp_id = @Emp_id;", conn))
                {

                    conn.Open();

                    cmd.Parameters.AddWithValue("@Emp_id", e.Emp_id);


                    if (string.IsNullOrEmpty(e.Name)) { 
                        cmd.Parameters.AddWithValue("@Name", DBNull.Value);
                    }
                    else {
                        cmd.Parameters.AddWithValue("@Name", e.Name); 
                    }
                    if (string.IsNullOrEmpty(e.Date_of_Birth)) { 
                        cmd.Parameters.AddWithValue("@Date_of_Birth", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Date_of_Birth", e.Date_of_Birth); 
                    }
                    if (string.IsNullOrEmpty(e.Gender)) { 
                        cmd.Parameters.AddWithValue("@Gender", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Gender", e.Gender); 
                    }
                    if (string.IsNullOrEmpty(e.Phone)) { 
                        cmd.Parameters.AddWithValue("@Phone", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Phone", e.Phone); 
                    }
                    if (string.IsNullOrEmpty(e.address)) { 
                        cmd.Parameters.AddWithValue("@address", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@address", e.address); 
                    }
                    if (string.IsNullOrEmpty(e.Email)) { 
                        cmd.Parameters.AddWithValue("@Email", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Email", e.Email);
                    }

                    if (string.IsNullOrEmpty(e.Password)) 
                    { 
                        cmd.Parameters.AddWithValue("@Password", DBNull.Value); 
                    } else 
                    { 
                        cmd.Parameters.AddWithValue("@Password", e.Password);
                    }
                    if (string.IsNullOrEmpty(e.Branch)) {
                        cmd.Parameters.AddWithValue("@Branch", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Branch", e.Branch); 
                    }
                    if (string.IsNullOrEmpty(e.Department)) { 
                        cmd.Parameters.AddWithValue("@Department", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Department", e.Department); 
                    }
                    if (string.IsNullOrEmpty(e.Designation)) { 
                        cmd.Parameters.AddWithValue("@Designation", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Designation", e.Designation); 
                    }
                    if (string.IsNullOrEmpty(e.Company_Date_of_joining)) { 
                        cmd.Parameters.AddWithValue("@Company_Date_of_joining", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Company_Date_of_joining", e.Company_Date_of_joining); 
                    }


                    if (string.IsNullOrEmpty(e.Account_holder_name)) { 
                        cmd.Parameters.AddWithValue("@Account_holder_name", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Account_holder_name", e.Account_holder_name); 
                    }
                    if (string.IsNullOrEmpty(e.Account_number)) { 
                        cmd.Parameters.AddWithValue("@Account_number", DBNull.Value);
                    } else { 
                        cmd.Parameters.AddWithValue("@Account_number", e.Account_number); 
                    }
                    if (string.IsNullOrEmpty(e.Bank_Name)) { 
                        cmd.Parameters.AddWithValue("@Bank_Name", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Bank_Name", e.Bank_Name); 
                    }

                    if (string.IsNullOrEmpty(e.Bank_Identifier_Code)) {
                        cmd.Parameters.AddWithValue("@Bank_Identifier_Code", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Bank_Identifier_Code", e.Bank_Identifier_Code); 
                    }
                    if (string.IsNullOrEmpty(e.Branch_location)) { 
                        cmd.Parameters.AddWithValue("@Branch_location", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Branch_location", e.Branch_location); 
                    }

                    if (string.IsNullOrEmpty(e.Tax_Payer_id)) { 
                        cmd.Parameters.AddWithValue("@Tax_Payer_id", DBNull.Value); 
                    } else { 
                        cmd.Parameters.AddWithValue("@Tax_Payer_id", e.Tax_Payer_id); 
                    }







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

#pragma checksum "C:\Users\sahal.qasim.PREMIER\Desktop\Hospital-Payroll\Views\LeaveDeduction\Index.cshtml" "{ff1816ec-aa5e-4d10-87f7-6f4963833460}" "472123fde759306f83c04bebb2163bfb3633e45a"
// <auto-generated/>
#pragma warning disable 1591
[assembly: global::Microsoft.AspNetCore.Razor.Hosting.RazorCompiledItemAttribute(typeof(AspNetCore.Views_LeaveDeduction_Index), @"mvc.1.0.view", @"/Views/LeaveDeduction/Index.cshtml")]
namespace AspNetCore
{
    #line hidden
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Mvc.Rendering;
    using Microsoft.AspNetCore.Mvc.ViewFeatures;
#nullable restore
#line 1 "C:\Users\sahal.qasim.PREMIER\Desktop\Hospital-Payroll\Views\_ViewImports.cshtml"
using Hospital_Payroll;

#line default
#line hidden
#nullable disable
#nullable restore
#line 2 "C:\Users\sahal.qasim.PREMIER\Desktop\Hospital-Payroll\Views\_ViewImports.cshtml"
using Hospital_Payroll.Models;

#line default
#line hidden
#nullable disable
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"472123fde759306f83c04bebb2163bfb3633e45a", @"/Views/LeaveDeduction/Index.cshtml")]
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"e0cae958cae2bccb3d009c34a18f8cd53e58f5f5", @"/Views/_ViewImports.cshtml")]
    public class Views_LeaveDeduction_Index : global::Microsoft.AspNetCore.Mvc.Razor.RazorPage<dynamic>
    {
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_0 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("class", new global::Microsoft.AspNetCore.Html.HtmlString("forms-sample"), global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        #line hidden
        #pragma warning disable 0649
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperExecutionContext __tagHelperExecutionContext;
        #pragma warning restore 0649
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperRunner __tagHelperRunner = new global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperRunner();
        #pragma warning disable 0169
        private string __tagHelperStringValueBuffer;
        #pragma warning restore 0169
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperScopeManager __backed__tagHelperScopeManager = null;
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperScopeManager __tagHelperScopeManager
        {
            get
            {
                if (__backed__tagHelperScopeManager == null)
                {
                    __backed__tagHelperScopeManager = new global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperScopeManager(StartTagHelperWritingScope, EndTagHelperWritingScope);
                }
                return __backed__tagHelperScopeManager;
            }
        }
        private global::Microsoft.AspNetCore.Mvc.TagHelpers.FormTagHelper __Microsoft_AspNetCore_Mvc_TagHelpers_FormTagHelper;
        private global::Microsoft.AspNetCore.Mvc.TagHelpers.RenderAtEndOfFormTagHelper __Microsoft_AspNetCore_Mvc_TagHelpers_RenderAtEndOfFormTagHelper;
        private global::Microsoft.AspNetCore.Mvc.TagHelpers.OptionTagHelper __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper;
        #pragma warning disable 1998
        public async override global::System.Threading.Tasks.Task ExecuteAsync()
        {
            WriteLiteral("\r\n");
#nullable restore
#line 2 "C:\Users\sahal.qasim.PREMIER\Desktop\Hospital-Payroll\Views\LeaveDeduction\Index.cshtml"
  
    ViewData["Title"] = "Index";
    Layout = "Form_panel";

#line default
#line hidden
#nullable disable
            WriteLiteral(@"<div class=""page-header"">
    <h3 class=""page-title""> LEAVE DEDUCTION </h3>
    <nav aria-label=""breadcrumb"">
        <ol class=""breadcrumb"">
            <li class=""breadcrumb-item""><a href=""#"">Leave Deduction</a></li>
            <li class=""breadcrumb-item active"" aria-current=""page"">Create</li>
        </ol>
    </nav>
</div>
<div class=""row"">
    <div class=""col-md-12 grid-margin stretch-card"">
        <div class=""card"">
            <div class=""card-body"">
");
            WriteLiteral("                ");
            __tagHelperExecutionContext = __tagHelperScopeManager.Begin("form", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "472123fde759306f83c04bebb2163bfb3633e45a4571", async() => {
                WriteLiteral(@"

                    <div class=""col-md-6 form-center"">

                        <div class=""form-group Emp_id"">
                            <label for=""Emp_id"">Employee</label>

                            <select class=""form-control"" id=""Emp_id"">
");
#nullable restore
#line 30 "C:\Users\sahal.qasim.PREMIER\Desktop\Hospital-Payroll\Views\LeaveDeduction\Index.cshtml"
                                 foreach (var Name in ViewBag.Emp_id_Name as List<Hospital_Payroll.Models.Employee_M>)
                                {

#line default
#line hidden
#nullable disable
                WriteLiteral("                                    ");
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("option", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "472123fde759306f83c04bebb2163bfb3633e45a5489", async() => {
#nullable restore
#line 32 "C:\Users\sahal.qasim.PREMIER\Desktop\Hospital-Payroll\Views\LeaveDeduction\Index.cshtml"
                                                            Write(Name.Name);

#line default
#line hidden
#nullable disable
                }
                );
                __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.OptionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper);
                BeginWriteTagHelperAttribute();
#nullable restore
#line 32 "C:\Users\sahal.qasim.PREMIER\Desktop\Hospital-Payroll\Views\LeaveDeduction\Index.cshtml"
                                       WriteLiteral(Name.Emp_id);

#line default
#line hidden
#nullable disable
                __tagHelperStringValueBuffer = EndWriteTagHelperAttribute();
                __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper.Value = __tagHelperStringValueBuffer;
                __tagHelperExecutionContext.AddTagHelperAttribute("value", __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper.Value, global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                WriteLiteral("\r\n");
#nullable restore
#line 33 "C:\Users\sahal.qasim.PREMIER\Desktop\Hospital-Payroll\Views\LeaveDeduction\Index.cshtml"
                                }

#line default
#line hidden
#nullable disable
                WriteLiteral("\r\n                            </select>\r\n");
                WriteLiteral(@"                        </div>


                        <div class=""form-group Leave_Days"">
                            <label for=""Leave_Days"">Leave Days</label>
                            <input type=""text"" class=""form-control"" id=""Leave_Days"" placeholder=""Leave Days"" maxlength=""50"">
                            <span class=""error""><span class=""mdi mdi-alert-circle""></span> Enter the Leave Days</span>
                        </div>

                        <div class=""form-group Date_From"">
                            <label for=""Date_From"">From Date</label>
                            <input type=""date"" class=""form-control"" id=""Date_From"" placeholder=""Date_From"" maxlength=""50"">
                            <span class=""error""><span class=""mdi mdi-alert-circle""></span> Enter the Date From</span>
                        </div>

                        <div class=""form-group Date_To"">
                            <label for=""Date_To"">To Date</label>
                            <input type=""dat");
                WriteLiteral(@"e"" class=""form-control"" id=""Date_To"" placeholder=""Date To"" maxlength=""50"">
                            <span class=""error""><span class=""mdi mdi-alert-circle""></span> Enter the To_Date</span>
                        </div>

                        <div class=""form-group Leave_Deduction"">
                            <label for=""Leave_Deduction"">Leave Deduction</label>
                            <input type=""text"" class=""form-control"" id=""Leave_Deduction"" placeholder=""Leave Deduction"" maxlength=""50"">
                            <span class=""error""><span class=""mdi mdi-alert-circle""></span> Enter the Leave Deduction</span>
                        </div>

                        <div class=""form-group Total_Leave_Deduction"">
                            <label for=""Total_Leave_Deduction"">Total Leave Deduction</label>
                            <input type=""text"" class=""form-control"" id=""Total_Leave_Deduction"" placeholder=""Total Leave Deduction"" maxlength=""50"">
                            <span class=");
                WriteLiteral(@"""error""><span class=""mdi mdi-alert-circle""></span> Enter the Total Leave Deduction</span>
                        </div>



                        <button type=""button"" id=""Save"" class=""btn btn-gradient-primary mr-2"">Submit</button>
                        <span class=""text-success message"">Record Saved Successfully...!</span>
                    </div>

                ");
            }
            );
            __Microsoft_AspNetCore_Mvc_TagHelpers_FormTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.FormTagHelper>();
            __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_FormTagHelper);
            __Microsoft_AspNetCore_Mvc_TagHelpers_RenderAtEndOfFormTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.RenderAtEndOfFormTagHelper>();
            __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_RenderAtEndOfFormTagHelper);
            __tagHelperExecutionContext.AddHtmlAttribute(__tagHelperAttribute_0);
            await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
            if (!__tagHelperExecutionContext.Output.IsContentModified)
            {
                await __tagHelperExecutionContext.SetOutputContentAsync();
            }
            Write(__tagHelperExecutionContext.Output);
            __tagHelperExecutionContext = __tagHelperScopeManager.End();
            WriteLiteral(@"
            </div>
        </div>
    </div>

</div>

<style>
    .error {
        color: red;
        font-size: 10px;
        display: none;
    }

    .valid {
        color: red;
        font-size: 10px;
        display: none;
    }

    .message {
        font-size: 10px;
        display: none;
    }

    .form-center {
        margin-left: 30%;
    }

    ");
            WriteLiteral(@"@media only screen and (max-width: 600px) {
        .form-center {
            margin-left: 0;
        }
    }
</style>


<script src=""https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js""></script>
<script>



    $(document).ready(function () {

        $('select').select2();

        $(""#Save"").click(function () {
            var isAllValid = true;

            if (!($('#Emp_id').val().trim() != '')) {
                isAllValid = false;
                $('.Emp_id .error').css('display', 'block');
            }
            else {
                $('.Emp_id .error').css('display', 'none');
            }

            if (!($('#Leave_Days').val().trim() != '')) {
                isAllValid = false;
                $('.Leave_Days .error').css('display', 'block');
            }
            else {
                $('.Leave_Days .error').css('display', 'none');
            }

            if (!($('#Date_From').val().trim() != '')) {
                isAllValid = fals");
            WriteLiteral(@"e;
                $('.Date_From .error').css('display', 'block');
            }
            else {
                $('.Date_From .error').css('display', 'none');
            }

            if (!($('#Date_To').val().trim() != '')) {
                isAllValid = false;
                $('.Date_To .error').css('display', 'block');
            }
            else {
                $('.Date_To .error').css('display', 'none');
            }

            if (!($('#Leave_Deduction').val().trim() != '')) {
                isAllValid = false;
                $('.Leave_Deduction .error').css('display', 'block');
            }
            else {
                $('.Leave_Deduction .error').css('display', 'none');
            }


            if (!($('#Total_Leave_Deduction').val().trim() != '')) {
                isAllValid = false;
                $('.Total_Leave_Deduction .error').css('display', 'block');
            }
            else {
                $('.Total_Leave_Deduction .error').css");
            WriteLiteral(@"('display', 'none');
            }


            if (isAllValid) {

                var data = {
                    Emp_id: $('#Emp_id').val(),
                    Leave_Days: $('#Leave_Days').val(),
                    Date_From: $('#Date_From').val(),
                    Date_To: $('#Date_To').val(),
                    Leave_Deduction: $('#Leave_Deduction').val(),
                    Total_Leave_Deduction: $('#Total_Leave_Deduction').val()
                }

                $.ajax({
                    type: 'POST',
                    url: '/LeaveDeduction/Index',
                    data: {
                        'Emp_id': data.Emp_id,
                        'Leave_Days': data.Leave_Days,
                        'From_Date': data.Date_From,
                        'To_Date': data.Date_To,
                        'Leave_Deduction': data.Leave_Deduction,
                        'Total_Leave_Deduction': data.Total_Leave_Deduction
                    },
                    succes");
            WriteLiteral(@"s: function (response) {
                        if (response.success) {
                            $('.message').delay(300).fadeIn();
                            $('.message').delay(200).fadeOut();
                            $('#Emp_id,	#Leave_Days,	#Date_From,	#Date_To,	#Leave_Deduction,	#Total_Leave_Deduction').val('');
                        }
                    }

                });
            }

        });


    });
</script>

");
        }
        #pragma warning restore 1998
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.ViewFeatures.IModelExpressionProvider ModelExpressionProvider { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IUrlHelper Url { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IViewComponentHelper Component { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IJsonHelper Json { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IHtmlHelper<dynamic> Html { get; private set; }
    }
}
#pragma warning restore 1591
report 50131 "TFB Send Vendor Updates"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = true;
    Caption = 'Send Vendor Status Updates';

    dataset
    {


        dataitem(Vendor; Vendor)
        {


            trigger OnPreDataItem()

            begin
                HTMLTemplate := CommonCU.GetHTMLTemplateActive(TitleTxt, SubtitleTxt);
                SetRange("TFB Vendor Type", "TFB Vendor Type"::TRADE);
                SetRange("TFB Receive Updates", true);
                SetRange(Blocked, Blocked::" ");
                Window.Open(Text001Msg);

            end;

            trigger OnAfterGetRecord()

            var

            begin

                if VendorCU.SendVendorStatusEmail("No.", HTMLTemplate, false) then
                    Window.Update(1, STRSUBSTNO('%1 %2', "No.", Name));

            end;

            trigger OnPostDataItem()

            begin


                Window.Close();

            end;

        }

    }

    requestpage
    {

        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {

                }
            }
        }


    }


    var
        VendorCU: CodeUnit "TFB Vendor Mgmt";
        CommonCU: CodeUnit "TFB Common Library";
        Window: Dialog;
        HTMLTemplate: Text;

        TitleTxt: label 'Vendor status';
        SubtitleTxt: label '';

        Text001Msg: Label 'Sending Vendor Updates:\#1############################Msg', comment = '%1=vendor';


}
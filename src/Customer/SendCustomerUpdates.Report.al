report 50123 "TFB Send Customer Updates"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = True;
    Caption = 'Send Customer Status Updates';

    dataset
    {


        dataitem(Customer; Customer)
        {

            RequestFilterFields = Blocked;
            trigger OnPreDataItem()

            var
                cu: CodeUnit "TFB Common Library";

            begin
                //HTMLTemplate := CustomerCU.GetHTMLTemplate(TopicTxt, TitleTxt);
                HTMLTemplate := cu.GetHTMLTemplateActive(TitleTxt, SubtitleTxt);
                Window.Open(Text001Msg);

            end;

            trigger OnAfterGetRecord()

            var

            begin

                If CustomerCU.SendCustomerStatusEmail("No.", HTMLTemplate) then
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
        CustomerCU: CodeUnit "TFB Customer Mgmt";
        Window: Dialog;
        HTMLTemplate: Text;
        Text001Msg: Label 'Sending Customer Updates:\#1##################2##########Msg', Comment = '%1=Customer number,%2=Customer name';


        SubtitleTxt: Label 'Please find below our latest information on pending orders that have not yet been shipped or invoiced and recent invoices that have been sent';
        TitleTxt: Label 'Order Status';



    local procedure UpdateDatesAndReleaseShipments()

    var
        WhseShipheader: Record "Warehouse Shipment Header";
        ReleaseWhseShipment: CodeUnit "Whse.-Shipment Release";
        DateFormula: DateFormula;


    begin
        WhseShipheader.SetRange(Status, WhseShipheader.Status::Open);
        Evaluate(DateFormula, '1D');
        If WhseShipheader.Findfirst() then
            repeat
                WhseShipheader."Shipment Date" := CalcDate(DateFormula, Today());
                WhseShipheader."Posting Date" := CalcDate(DateFormula, Today());
                WhseShipheader.Modify();
                ReleaseWhseShipment.Release(WhseShipheader);

            Until WhseShipheader.Next() = 0;

    end;

}
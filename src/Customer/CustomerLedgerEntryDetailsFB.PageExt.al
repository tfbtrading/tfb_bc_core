pageextension 50211 "TFB Cust. Ledger Entry Factbox" extends "Customer Ledger Entry FactBox"
{
    layout
    {
        addafter("Due Date")
        {
            field(ExpectedDateText; ExpectedDateText)
            {
                ApplicationArea = All;
                Style = Unfavorable;
                StyleExpr = IsExpectedDatePastDue;
                ToolTip = 'Add date and notes';
                Caption = 'Expected Date';
                DrillDown = true;
                trigger OnDrillDown()

                var
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                    Customer: Record Customer;
                    SalesInvoiceHeaderTemp: Record "Sales Invoice Header" temporary;
                    AddPaymentNote: Page "TFB Payment Note";
                begin
                    If Rec."Document Type" = Rec."Document Type"::Invoice then begin

                        If not SalesInvoiceHeader.Get(Rec."Document No.") then exit;

                        if not SalesInvoiceHeader.Closed then begin
                            Customer.Get(SalesInvoiceHeader."Sell-to Customer No.");
                            AddPaymentNote.SetupCustomerInfo(Customer, SalesInvoiceHeader."TFB Expected Payment Note", SalesInvoiceHeader."TFB Expected Payment Date", SalesInvoiceHeader."TFB Expected Note TimeStamp");
                            SalesInvoiceHeaderTemp := SalesInvoiceHeader;
                            If AddPaymentNote.RunModal() = Action::OK then begin
                                SalesInvoiceHeaderTemp."TFB Expected Payment Note" := AddPaymentNote.GetExpectedPaymentNote();
                                SalesInvoiceHeaderTemp."TFB Expected Payment Date" := AddPaymentNote.GetExpectedPaymentDate();
                                CODEUNIT.Run(CODEUNIT::"TFB Pstd. Sales Inv. Hdr. Edit", SalesInvoiceHeaderTemp);
                                CurrPage.Update();
                            end

                        end
                    end;
                end;
            }

        }
        // Add changes to page layout here
    }


    trigger OnAfterGetRecord()

    var
        SalesInvoiceHeader: Record "Sales Invoice Header";

    begin
        Clear(ExpectedDateText);

        If Rec."Document Type" = Rec."Document Type"::Invoice then begin

            If not SalesInvoiceHeader.Get(Rec."Document No.") then exit;


            If not SalesInvoiceHeader.Closed then begin
                If SalesInvoiceHeader."TFB Expected Payment Date" > 0D then
                    ExpectedDateText := format(SalesInvoiceHeader."TFB Expected Payment Date")
                else
                    if SalesInvoiceHeader."TFB Expected Payment Note" = '' then
                        ExpectedDateText := '➕'
                    else
                        ExpectedDateText := '📄';
            end
            else
                ExpectedDateText := '';

            If (SalesInvoiceHeader."TFB Expected Payment Date" < WorkDate()) and (not SalesInvoiceHeader.Closed) and (SalesInvoiceHeader."TFB Expected Payment Date" > 0D) then
                IsExpectedDatePastDue := true
            else
                IsExpectedDatePastDue := false;
        end;
    end;

    var
        IsExpectedDatePastDue: Boolean;
        ExpectedDateText: Text;
}
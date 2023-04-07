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
                    TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
                    AddPaymentNote: Page "TFB Payment Note";
                begin
                    if Rec."Document Type" = Rec."Document Type"::Invoice then begin

                        if not SalesInvoiceHeader.Get(Rec."Document No.") then exit;

                        if not SalesInvoiceHeader.Closed then begin
                            Customer.Get(SalesInvoiceHeader."Sell-to Customer No.");
                            AddPaymentNote.SetupCustomerInfo(Customer, SalesInvoiceHeader."TFB Expected Payment Note", SalesInvoiceHeader."TFB Expected Payment Date", SalesInvoiceHeader."TFB Expected Note TimeStamp");
                            TempSalesInvoiceHeader := SalesInvoiceHeader;
                            if AddPaymentNote.RunModal() = Action::OK then begin
                                TempSalesInvoiceHeader."TFB Expected Payment Note" := AddPaymentNote.GetExpectedPaymentNote();
                                TempSalesInvoiceHeader."TFB Expected Payment Date" := AddPaymentNote.GetExpectedPaymentDate();
                                CODEUNIT.Run(CODEUNIT::"TFB Pstd. Sales Inv. Hdr. Edit", TempSalesInvoiceHeader);
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

        if Rec."Document Type" = Rec."Document Type"::Invoice then begin

            if not SalesInvoiceHeader.Get(Rec."Document No.") then exit;


            if not SalesInvoiceHeader.Closed then begin
                if SalesInvoiceHeader."TFB Expected Payment Date" > 0D then
                    ExpectedDateText := format(SalesInvoiceHeader."TFB Expected Payment Date")
                else
                    if SalesInvoiceHeader."TFB Expected Payment Note" = '' then
                        ExpectedDateText := '➕'
                    else
                        ExpectedDateText := '📄';
            end
            else
                ExpectedDateText := '';

            if (SalesInvoiceHeader."TFB Expected Payment Date" < WorkDate()) and (not SalesInvoiceHeader.Closed) and (SalesInvoiceHeader."TFB Expected Payment Date" > 0D) then
                IsExpectedDatePastDue := true
            else
                IsExpectedDatePastDue := false;
        end;
    end;

    var
        IsExpectedDatePastDue: Boolean;
        ExpectedDateText: Text;
}
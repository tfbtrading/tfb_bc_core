pageextension 50151 "TFB Posted Sales Invoices" extends "Posted Sales Invoices" //143
{
    layout
    {
        moveafter("Posting Date"; "No.")
        modify("Posting Date")
        {
            Visible = true;
        }
        addafter("Due Date")
        {
            field("TFB Brokerage Shipment"; Rec."TFB Brokerage Shipment")
            {
                ApplicationArea = All;
                Importance = Standard;
                Visible = Rec."TFB Brokerage Shipment" <> '';
                ToolTip = 'Specifies brokerage shipment if relevant';
            }

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
                    Customer: Record Customer;
                    TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
                    AddPaymentNote: Page "TFB Payment Note";
                begin

                    if not Rec.Closed then begin
                        Customer.Get(Rec."Sell-to Customer No.");
                        AddPaymentNote.SetupCustomerInfo(Customer, Rec."TFB Expected Payment Note", Rec."TFB Expected Payment Date", Rec."TFB Expected Note TimeStamp");
                        TempSalesInvoiceHeader := Rec;
                        If AddPaymentNote.RunModal() = Action::OK then begin
                            TempSalesInvoiceHeader."TFB Expected Payment Note" := AddPaymentNote.GetExpectedPaymentNote();
                            TempSalesInvoiceHeader."TFB Expected Payment Date" := AddPaymentNote.GetExpectedPaymentDate();
                            CODEUNIT.Run(CODEUNIT::"TFB Pstd. Sales Inv. Hdr. Edit", TempSalesInvoiceHeader);
                        end

                    end

                end;
            }

        }

        addbefore("Amount Including VAT")
        {
            field("Prepayment Invoice"; Rec."Prepayment Invoice")
            {
                Caption = 'Pre-payment';
                Width = 8;
                ApplicationArea = All;
                Visible = Rec."Prepayment Invoice";
            }
        }

        modify("Due Date")
        {
            Style = Unfavorable;
            StyleExpr = IsPastDue;
        }



        addlast(factboxes)
        {
            part(PODInfo; "TFB Sales POD FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
                Caption = 'POD Info';
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(TFBSendPODRequest)
            {
                Caption = 'Send POD request';
                ToolTip = 'Sends a proof of delivery request to the relevant party who managed the delivery';
                ApplicationArea = All;
                Image = SendMail;


                trigger OnAction()
                var
                    PurchInvCU: CodeUnit "TFB Purch. Inv. Mgmt";
                begin
                    PurchInvCU.SendPODRequestForInvoice(Rec."No.");
                end;


            }
            action(TFBRegisterPayments)
            {
                Caption = 'Register Customer Payment';
                ApplicationArea = All;
                Image = Payment;

                RunObject = Page "Payment Registration";
                RunPageLink = "Source No." = FIELD("Sell-to Customer No.");
                ToolTip = 'Process your customer payments by matching amounts received on your bank account with the related unpaid sales invoices, and then post the payments.';
            }
        }
        addlast(Category_Process)
        {
            actionref(TFBRegisterPayments_Promoted; TFBRegisterPayments)
            {

            }
        }
        addlast(Category_Category7)
        {
            actionref(TFBSendPODRequest_Promoted; TFBSendPODRequest)
            {

            }
        }

    }

    views
    {

    }

    trigger OnAfterGetRecord()

    begin
        Clear(ExpectedDateText);

        If (Rec."Due Date" < WorkDate()) and (not Rec.Closed) then
            IsPastDue := true
        else
            IsPastDue := false;

        If not Rec.Closed then begin
            If Rec."TFB Expected Payment Date" > 0D then
                ExpectedDateText := format(Rec."TFB Expected Payment Date")
            else
                if Rec."TFB Expected Payment Note" = '' then
                    ExpectedDateText := '➕'
                else
                    ExpectedDateText := '📄';
        end
        else
            ExpectedDateText := '';

        If (Rec."TFB Expected Payment Date" < WorkDate()) and (not Rec.Closed) and (Rec."TFB Expected Payment Date" > 0D) then
            IsExpectedDatePastDue := true
        else
            IsExpectedDatePastDue := false;
    end;

    var
        IsPastDue: Boolean;
        IsExpectedDatePastDue: Boolean;
        ExpectedDateText: Text;
}
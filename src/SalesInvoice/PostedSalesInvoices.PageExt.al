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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Payment Registration";
                RunPageLink = "Source No." = FIELD("Sell-to Customer No.");
                ToolTip = 'Process your customer payments by matching amounts received on your bank account with the related unpaid sales invoices, and then post the payments.';
            }
        }
    }

    views
    {

    }
}
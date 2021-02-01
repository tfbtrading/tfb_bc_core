pageextension 50168 "TFB Customer Ledger Entries" extends "Customer Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(processing)
        {
            action(TFBRegisterPayments)
            {
                Caption = 'Register Customer Payment';
                ApplicationArea = All;
                Enabled = Rec."Remaining Amount" > 0;
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Payment Registration";
                RunPageLink = "Source No." = FIELD("Customer No.");
                ToolTip = 'Process your customer payments by matching amounts received on your bank account with the related unpaid sales invoices, and then post the payments.';
            }
        }
    }

    var
        myInt: Integer;
}
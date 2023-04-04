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


                RunObject = Page "Payment Registration";
                RunPageLink = "Source No." = FIELD("Customer No.");
                ToolTip = 'Process your customer payments by matching amounts received on your bank account with the related unpaid sales invoices, and then post the payments.';
            }

            action(TFBSendInvoicesToCustomer)
            {
                Caption = 'Send Invoices to Accounts';

                ApplicationArea = All;
                Image = Email;

                ToolTip = 'Gathers up selected invoices and prepares an email to be sent to the customer with those invoices already attached';

                trigger OnAction()

                var
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                    CustCollectionsMgmt: CodeUnit "TFB Cust. Collections Mgmt";
                begin
                    CurrPage.SetSelectionFilter(CustLedgerEntry);
                    CustCollectionsMgmt.SendDraftEmailWithSelectedInvoices(CustLedgerEntry);

                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(TFBRegisterPayments_Promoted; TFBRegisterPayments)
            {

            }
            actionref(TFBPSendInvoicesToCustomer; TFBSendInvoicesToCustomer)
            {

            }
        }
    }


}
pageextension 50170 "TFB Bank Acc. Ledg. Entries" extends "Bank Account Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(processing)
        {
            action("TFBWithoutIncomingDocs")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Documents;
                Caption = 'Show Entries without Incoming Docs';
                ToolTip = 'Shows the entries related to the general ledger account setup for the bank account';
                trigger OnAction()
                var
                    cu: CodeUnit "TFB Banking";

                begin
                    cu.OpenMissingIncomingDocsPage(Rec."Bank Account No.");
                end;
            }
        }
    }

}
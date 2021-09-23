pageextension 50214 "TFB Posted Purchase Invoices" extends "Posted Purchase Invoices"
{
    layout
    {
        addlast(factboxes)
        {
            part(TFB; "TFB Vend. Applied Entries FB")
            {
                ApplicationArea = All;
                SubPageLink = "Vendor Ledger Entry No." = field("Vendor Ledger Entry No.");
                Visible = Rec."Remaining Amount" < Rec.Amount;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()

    begin
        Rec.CalcFields("Remaining Amount");
    end;

    var
        myInt: Integer;
}
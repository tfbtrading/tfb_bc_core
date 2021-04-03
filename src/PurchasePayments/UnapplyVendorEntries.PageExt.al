pageextension 50201 "TFB Unapply Vendor Entries" extends "Unapply Vendor Entries"
{
    layout
    {
        addafter(DocumentNo)
        {
            field(tfbExternRefNo; getExternalDocNo())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Initial External Doc. No.';
                ToolTip = 'Specifies the external number provided by the vendor for which the document is unapplied.';
            }
        }
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }

    local procedure getExternalDocNo(): Text[100]
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        if VendLedgEntry.Get(Rec."Vendor Ledger Entry No.") and (Rec."Initial Document Type" = Rec."Initial Document Type"::Invoice) then
            exit(VendLedgEntry."External Document No.");
    end;
}
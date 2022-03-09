tableextension 50130 "TFB Vendor Ledger Entry" extends "Vendor Ledger Entry"
{
    fields
    {
        field(50500;"TFB Forex Amount";Decimal)
        {
            Caption = 'Forex Coverage Amount';
            FieldClass = FlowField;
            CalcFormula = sum("TFB Forex Mgmt Entry"."Original Amount" where("Source Document No." = field("External Document No."), EntryType=const(Assignment)));
            
        }
        // Add changes to table fields here
    }

    fieldgroups
    {

        addlast(DropDown; "External Document No.", "Remaining Amount")
        { }

    }
}
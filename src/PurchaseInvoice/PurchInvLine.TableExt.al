tableextension 50106 "TFB Purch. Inv. Line" extends "Purch. Inv. Line"
{
    fields
    {
        field(50100; "TFB Vendor Invoice No."; Text[100])
        {
            Caption = 'Vendor Invoice No.';
            FieldClass = FlowField;
            CalcFormula = lookup ("Purch. Inv. Header"."Vendor Invoice No." where("No." = field("Document No.")));

        }
        field(50110; "TFB Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup ("Purch. Inv. Header"."Buy-from Vendor Name" where("No." = field("Document No.")));
        }

    }

    keys
    {

    }
}
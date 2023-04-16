tableextension 50136 "TFB Phys. Invt. Order Header" extends "Phys. Invt. Order Header"
{
    fields
    {
        field(50100; "TFB No. of Recordings"; Integer)
        {
            Caption = 'No. of Recordings';
            FieldClass = FlowField;
            CalcFormula = count("Phys. Invt. Record Header" where("Order No." = field("No.")));

        }
    }


}
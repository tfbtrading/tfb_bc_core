tableextension 50180 "TFB Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50182; "TFB Container Entry Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ValidateTableRelation = true;
            Caption = 'Cont. Entry No.';

        }
    }


}

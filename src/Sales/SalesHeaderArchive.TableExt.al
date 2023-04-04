tableextension 50134 "TFB Sales Header Archive" extends "Sales Header Archive"
{
    fields
    {
        field(50100; "TFB Instructions"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Instructions';

        }

    }


}
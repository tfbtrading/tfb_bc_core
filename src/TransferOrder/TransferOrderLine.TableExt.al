tableextension 50171 "TFB Transfer Order Line" extends "Transfer Line" //
{
    fields
    {

        field(50007; "TFB Container Entry No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Container Entry";
            ValidateTableRelation = True;
            Editable = true;
            Caption = 'Container Entry No.';
        }
        field(50008; "TFB Container No. LookUp"; Text[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("TFB Container Entry"."Container No." where ("No." = field ("TFB Container Entry No.")));
            Editable = false;
            Caption = 'Container Lookup';
        }
        field(50020; "TFB Container No."; Text[20])
        {
            Caption = 'Container No.';

        }

    }

}
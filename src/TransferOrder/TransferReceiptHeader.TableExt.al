tableextension 50105 "TFB Transfer Receipt Header" extends "Transfer Receipt Header" //5746
{
    fields
    {
        field(50010; "TFB Transfer Type"; enum "TFB Transfer Order Type")
        {
            DataClassification = CustomerContent;

        }
        field(50020; "TFB Order Reference"; code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50007; "TFB Container Entry No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Container Entry";
            ValidateTableRelation = true;
            Editable = true;
            Caption = 'Container Entry No.';
        }
        field(50008; "TFB Container No. LookUp"; Text[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("TFB Container Entry"."Container No." where("No." = field("TFB Container Entry No.")));
            Editable = false;
            Caption = 'Container Lookup';
        }
    }

}
tableextension 50172 "TFB Transfer Shipment Line" extends "Transfer Shipment Line" //MyTargetTableId
{
    fields
    {
        field(50007; "TFB Container Entry No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Container Entry";
            ValidateTableRelation = True;
            Editable = false;
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
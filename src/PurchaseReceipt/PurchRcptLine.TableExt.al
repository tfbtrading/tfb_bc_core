tableextension 50200 "TFB Purch. Rcpt. Line." extends "Purch. Rcpt. Line" //121
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
            CalcFormula = lookup("TFB Container Entry"."Container No." where("Order Reference" = field("Order No.")));
            Editable = false;
            Caption = 'Container Lookup';
        }
        field(50010; "TFB Vendor Order No. Lookup"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Purch. Rcpt. Header"."Vendor Order No." where("No." = field("Document No.")));
            Editable = false;
            Caption = 'Vendor Order No.';
        }
        field(50020; "TFB Container No."; Text[20])
        {
            ObsoleteReason = 'Replaced by flowfield lookup on order reference';
            ObsoleteTag = 'ReplacedByFlowField';
            ObsoleteState = Pending;
            Caption = 'Container No.';

        }

    }


}
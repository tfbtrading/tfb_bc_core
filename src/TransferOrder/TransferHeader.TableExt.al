tableextension 50177 "TFB Transfer Header" extends "Transfer Header" //MyTargetTableId
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


            trigger OnValidate()

            var

                ContainerCU: CodeUnit "TFB Container Mgmt";

            begin

                If Rec."TFB Container Entry No." <> xRec."TFB Container Entry No." then
                    If ContainerCU.UpdateTransferHeader(Rec, Rec."TFB Container Entry No.") then
                        Message('Container Details Transferred to Transfer Order');


                If Rec."TFB Container Entry No." <> '' then
                    "TFB Transfer Type" := "TFB Transfer Type"::Container
                else
                    "TFB Transfer Type" := "TFB Transfer Type"::Standard;

            end;
        }

        field(50010; "TFB Transfer Type"; enum "TFB Transfer Order Type")
        {
            Caption = 'Transfer Type';
            DataClassification = CustomerContent;
            Editable = true;

        }
        field(50020; "TFB Order Reference"; code[20])
        {
            Caption = 'Order Reference';
            DataClassification = CustomerContent;
            Editable = false;
        }


    }

}
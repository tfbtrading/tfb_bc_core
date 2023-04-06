pageextension 50178 "TFB Transfer Orders" extends "Transfer Orders" //5742
{
    layout
    {
        addafter("No.")
        {
            field("TFB Transfer Type"; Rec."TFB Transfer Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies transfer order type. Standard or specific for container';
            }
            field("TFB Order Reference"; Rec."TFB Order Reference")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies related order reference for transfer order';
            }
            field("TFB Container Entry No."; Rec."TFB Container Entry No.")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies container entry number';
            }
            field("TFB Container No"; ContainerNo)
            {
                ApplicationArea = All;
                Caption = 'Container No.';
                Tooltip = 'Specifies related container number for transfer';

            }
        }

    }

    actions
    {
    }

    var
        ContainerNo: Text[100];

    trigger OnAfterGetRecord()

    var

        Container: Record "TFB Container Entry";

    begin

        Clear(ContainerNo);

        if Rec."TFB Container Entry No." <> '' then
            if Container.Get(Rec."TFB Container Entry No.") then
                if Container."Container No." <> '' then
                    ContainerNo := Container."Container No.";


    end;
}
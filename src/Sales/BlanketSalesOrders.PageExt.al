pageextension 50135 "TFB Blanket Sales Orders" extends "Blanket Sales Orders"
{
    layout
    {
        addafter("External Document No.")
        {
            field("TFB Start Date"; Rec."TFB Start Date")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies the date from which shipments occur';
            }
            field("TFB End Date"; Rec."TFB End Date")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies date by which shipments should have been completed';
            }
            field("TFB Blanket DropShip"; Rec."TFB Blanket DropShip")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies if the blanket order is for dropshipments';
            }

        }

    }

    actions
    {
    }
}
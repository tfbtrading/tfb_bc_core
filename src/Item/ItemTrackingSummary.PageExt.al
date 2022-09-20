pageextension 50143 "TFB Item Tracking Summary" extends "Item Tracking Summary"
{
    layout
    {
        addafter("Total Available Quantity")
        {
            field("TFB Lot Blocked"; Rec."TFB Lot Blocked")
            {
                Caption = 'Lot Blocked';
                Editable = false;
                ApplicationArea = All;
                ToolTip = 'Specifies if the lot is blocked from being sold';
                DrillDown = false;

            }
            field("TFB Date Available"; Rec."TFB Date Available")
            {
                Caption = 'Date Available (if Blocked)';
                Editable = false;
                ApplicationArea = All;
                ToolTip = 'Specifies date of estimated availability if the lot is blocked';
            }

        }
    }


}
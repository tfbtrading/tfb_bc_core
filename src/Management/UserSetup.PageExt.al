pageextension 50200 "TFB User Setup" extends "User Setup"
{
    layout
    {
        addafter("Register Time")
        {
            field("TFB Show External IDs"; Rec."TFB Show External IDs")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if pages that can display external IDs show then or not';

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
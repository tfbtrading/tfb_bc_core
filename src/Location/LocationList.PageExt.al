pageextension 50208 "TFB Location List" extends "Location List"
{
    layout
    {
        addlast(Control1)
        {
            field("TFB Enabled"; Rec."TFB Enabled")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the location is enabled for use in inventory';
            }
            field("TFB Location Type"; Rec."TFB Location Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies what type of location it is. Used to indicate special purposes';
            }
            field("E-Mail"; Rec."E-Mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the e-mail for contacting the location for any warehouse logistics purposes';
            }

        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
pageextension 50208 "TFB Location List" extends "Location List"
{
    layout
    {
        addlast(Control1)
        {
            field("TFB Enabled"; Rec."TFB Enabled")
            {
                ApplicationArea = All;
            }
            field("TFB Location Type"; Rec."TFB Location Type")
            {
                ApplicationArea = All;
            }
            field("E-Mail"; Rec."E-Mail")
            {
                ApplicationArea = All;
            }

        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
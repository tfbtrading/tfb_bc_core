pageextension 50161 "TFB Ship-to Address" extends "Ship-to Address"
{
    layout
    {
        addbefore("E-Mail")
        {
            field("TFB Notify Contact"; Rec."TFB Notify Contact")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the contact and email specified should be emailed separately';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
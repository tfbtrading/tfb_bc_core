pageextension 50164 "TFB Pstd Purch Inv. Lines" extends "Posted Purchase Invoice Lines"
{
    layout
    {
        addfirst(Control1)
        {
            field("TFB Vendor Invoice No."; Rec."TFB Vendor Invoice No.")
            {
                ApplicationArea = All;
                Visible = true;
                ToolTip = 'External reference number for invoice';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
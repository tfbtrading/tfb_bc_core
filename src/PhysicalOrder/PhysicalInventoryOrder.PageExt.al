pageextension 50145 "TFB Physical Inventory Order" extends "Physical Inventory Order"
{
    layout
    {
        addbefore("No. Finished Recordings")
        {
            field("TFB No. of Recordings"; Rec."TFB No. of Recordings")
            {
                ApplicationArea = All;
                Importance = Promoted;
                ToolTip = 'Specifies all the recordings for this order';
            }

        }

        modify("Shortcut Dimension 1 Code")
        {
            Visible = false;
        }
        modify("Shortcut Dimension 2 Code")
        {
            Visible = false;
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
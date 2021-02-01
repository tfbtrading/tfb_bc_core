pageextension 50154 "TFB Purchase Order Archives" extends "Purchase Order Archives"
{
    layout
    {
        addafter("No.")
        {
            field("Vendor Order No."; Rec."Vendor Order No.")
            {
                ToolTip = 'Specifies the vendors order number corresponding to sale';
                Visible = true;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
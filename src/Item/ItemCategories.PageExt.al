pageextension 50146 "TFB Item Categories" extends "Item Categories"
{
    layout
    {
        addafter(Description)
        {
            field("TFB Catalogue Priority"; Rec."TFB Catalogue Priority")
            {
                ApplicationArea = All;
                ToolTip = 'Used for sorting first and then by description';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
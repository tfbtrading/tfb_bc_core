pageextension 50215 "TFB Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            field("TFB MSDS Word Template"; Rec."TFB MSDS Word Template")
            {
                Importance = Promoted;
                ApplicationArea = All;
                ToolTip = 'Specifies the word template to use when generating an MSDS material sheet for an item';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
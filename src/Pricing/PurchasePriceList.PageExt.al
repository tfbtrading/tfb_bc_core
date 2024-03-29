pageextension 50192 "TFB Purchase Price List" extends "Purchase Price List"
{
    layout
    {
        addlast(General)
        {
            field("TFB Price Unit"; Rec."TFB Price Unit")
            {
                ToolTip = 'Specifies the price unit select for all prices shown in list';
                Enabled = not (Rec."Source Type" = Rec."Source Type"::Vendor);
                ApplicationArea = All;
                Importance = Standard;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
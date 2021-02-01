pageextension 50137 "TFB Shipping Agents" extends "Shipping Agents"
{
    layout
    {
        addbefore("Internet Address")
        {
            field("TFB Service Default"; Rec."TFB Service Default")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies service default for shipping agent';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
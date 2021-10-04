/// <summary>
/// PageExtension TFB Sales Lines (ID 50103) extends Record Sales Lines //516.
/// </summary>
pageextension 50103 "TFB Sales Lines" extends "Sales Lines" //516
{
    layout
    {
        addafter("Sell-to Customer No.")
        {
            field("TFB CustomerName"; Rec."TFB Customer Name")
            {
                ApplicationArea = All;
                DrillDown = false;
                ToolTip = 'Specifies customer name';
            }
        }

    }

    actions
    {
    }
}
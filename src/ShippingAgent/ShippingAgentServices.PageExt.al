pageextension 50213 "TFB Shipping Agent Services" extends "Shipping Agent Services"
{
    layout
    {
        addafter("Shipping Time")
        {
            field("TFB Shipping Time Max"; Rec."TFB Shipping Time Max")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the maximum potential time for shipment with this agent service. If blank assume shipping time is min and max';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

}
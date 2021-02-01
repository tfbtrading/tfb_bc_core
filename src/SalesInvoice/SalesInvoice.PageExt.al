pageextension 50190 "TFB Sales Invoice" extends "Sales Invoice" //MyTargetPageId
{
    layout
    {
        addbefore("External Document No.")
        {
            group(BrokerageDetails)
            {
                showcaption = false;
                Visible = Rec."TFB Brokerage Shipment" <> '';


                field("TFB Brokerage Shipment"; Rec."TFB Brokerage Shipment")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the related brokerage invoice for a brokerage shipment';
                }
            }
        }
    }

    actions
    {
    }
}
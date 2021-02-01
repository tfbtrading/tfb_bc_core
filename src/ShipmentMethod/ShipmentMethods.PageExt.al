pageextension 50116 "TFB Shipment Methods" extends "Shipment Methods" //11
{
    layout
    {
        addafter(Description)
        {
            field("TFB Freight Exclusive"; Rec."TFB Freight Exclusive")
            {
                ApplicationArea = All;
                Editable = true;
                Visible = true;
                ToolTip = 'Specifies if shipment method is exclusive of freight';
            }
            field("TFB Pickup at Location"; Rec."TFB Pickup at Location")
            {
                ApplicationArea = All;
                Editable = true;
                Visible = true;
                ToolTip = 'Specifies if it is a custmer order that it should be picked-up at location';
            }

        }

    }

    actions
    {
    }
}
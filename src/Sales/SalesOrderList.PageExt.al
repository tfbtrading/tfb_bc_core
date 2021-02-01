pageextension 50133 "TFB Sales Order List" extends "Sales Order List" //9305
{
    layout
    {
        addafter("Requested Delivery Date")
        {
            field("Promised Delivery Date"; Rec."Promised Delivery Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the promised delivery date to the customer';
            }

        }

    }

    actions
    {
    }


}
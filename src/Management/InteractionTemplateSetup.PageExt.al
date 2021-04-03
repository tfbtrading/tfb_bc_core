pageextension 50195 "TFB Interaction Template Setup" extends "Interaction Template Setup"
{
    layout
    {
        addlast(Sales)
        {

            field("TFB Brokerage Cust. Update"; Rec."TFB Brokerage Cust. Update")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the template used when sending brokerage cust. updates';
            }
            field("TFB Certificate of Analysis"; Rec."TFB Certificate of Analysis")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the template used when sending certificate of analysis';
            }
            field("TFB Shipment Status Enquiry"; Rec."TFB Shipment Status Enquiry")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the template used when sending the status enquiry';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

}
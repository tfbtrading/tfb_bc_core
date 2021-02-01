pageextension 50129 "TFB Purchase Prices" extends "Purchase Prices"
{
    layout
    {
        // Add changes to page layout here
        addafter("Item No.")
        {
            field("TFB Item Description"; Rec."TFB Item Description")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies the item description';
            }
        }
        addafter("Direct Unit Cost")
        {
            field("TFB VendorPriceUnit"; Rec."TFB Vendor Price Unit")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the vendors price unit';

            }
            field("TFB VendorPriceByWeight"; Rec."TFB VendorPriceByWeight")
            {
                ApplicationArea = All;
                DecimalPlaces = 2 :;
                Tooltip = 'Specifies the price in the vendors price unit';


            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
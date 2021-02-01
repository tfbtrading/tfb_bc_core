page 50311 "TFB Postcode Zone List"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Postcode Zone";
    Caption = 'Postcode Delivery Zones';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies code for delivery zone';
                }
                field(CustomerSalesGroup; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies linked customer price group for delivery zone';

                }
                field("Filter"; Rec."Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies filter of included postal zones covered by code';
                }


            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {

    }
}
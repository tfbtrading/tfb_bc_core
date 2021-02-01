page 50303 "TFB Costing Scenario SubForm"
{
    caption = 'Zone Rates';
    PageType = ListPart;
    SourceTable = "TFB Postcode Zone Rate";
    DelayedInsert = false;

    layout
    {
        area(Content)
        {

            repeater(Group)
            {

                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies delivery zone code';
                }
                field("Surcharge Rate"; Rec."Base Rate")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies surchage rate for delivery zone';
                }
                field("Fuel Surcharge"; Rec."Fuel Surcharge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies amount of fuel surcharge based on percentage fuel surcharge';
                }
                field("Total Charge"; Rec."Total Charge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies total charge for delivery including fuel levy';
                }


            }
        }

    }

    actions
    {

    }


}
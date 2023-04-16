page 50303 "TFB Costing Scenario SubForm"
{
    caption = 'Zone Rates';
    PageType = ListPart;
    SourceTable = "TFB Postcode Zone Rate";
    DelayedInsert = false;
    ApplicationArea = All;


    layout
    {
        area(Content)
        {

            repeater(Group)
            {

                field("Zone Code"; Rec."Zone Code")
                {
                    ToolTip = 'Specifies delivery zone code';
                }
                field("Surcharge Rate"; Rec."Base Rate")
                {
                    Tooltip = 'Specifies surchage rate for delivery zone';
                }
                field("Fuel Surcharge"; Rec."Fuel Surcharge")
                {
                    ToolTip = 'Specifies amount of fuel surcharge based on percentage fuel surcharge';
                }
                field("Total Charge"; Rec."Total Charge")
                {
                    ToolTip = 'Specifies total charge for delivery including fuel levy';
                }


            }
        }

    }

    actions
    {

    }


}
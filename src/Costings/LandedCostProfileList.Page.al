page 50342 "TFB Landed Cost Profile List"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Landed Cost Profile";
    Editable = false;
    CardPageId = "TFB Landed Cost Profile";
    Caption = 'Landed Cost Profiles';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies unique code for landed cost profile';
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Specifies description';

                }
                field("Scenario"; Rec."Scenario")
                {
                    Tooltip = 'Specifies default scenario';
                }
                field("Purchase Type"; Rec."Purchase Type")
                {
                    Tooltip = 'Specifies purchase type';
                }
                field("Container Cost"; Rec."Container Cost")
                {
                    Tooltip = 'Specifies calculated landed costs for container';
                }
                field("Pallet Cost"; Rec."Pallet Cost")
                {
                    ToolTip = 'Specifies calculated landed costs per pallet';
                }
                field("Per Weight Cost"; Rec."Per Weight Cost")
                {
                    ToolTip = 'Specifies calculated landed costs per weight unit';

                }


            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    { }

}
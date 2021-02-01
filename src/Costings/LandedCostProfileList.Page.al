page 50342 "TFB Landed Cost Profile List"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Landed Cost Profile";
    Editable = False;
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies unique code for landed cost profile';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies description';

                }
                field("Scenario"; Rec."Scenario")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies default scenario';
                }
                field("Purchase Type"; Rec."Purchase Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies purchase type';
                }
                field("Container Cost"; Rec."Container Cost")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies calculated landed costs for container';
                }
                field("Pallet Cost"; Rec."Pallet Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies calculated landed costs per pallet';
                }
                field("Per Weight Cost"; Rec."Per Weight Cost")
                {
                    ApplicationArea = All;
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
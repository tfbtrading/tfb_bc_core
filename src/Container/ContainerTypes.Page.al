page 50138 "TFB Container Types"
{
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "TFB ContainerType";
    Caption = 'Container Types';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies code for container type';

                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Width = 40;
                    ToolTip = 'Specifies description';
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies type of container';
                }
                field("Width"; Rec."Width") { ApplicationArea = All; Tooltip = 'Specifies width'; }
                field("Height"; Rec."Height") { ApplicationArea = All; ToolTip = 'Specifies height'; }
                field("Length"; Rec."Length") { ApplicationArea = All; ToolTip = 'Specifies length'; }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {

        }
    }
}
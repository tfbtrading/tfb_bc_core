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
                    ToolTip = 'Specifies code for container type';

                }
                field("Description"; Rec."Description")
                {
                    Width = 40;
                    ToolTip = 'Specifies description';
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies type of container';
                }
                field("Width"; Rec."Width") { Tooltip = 'Specifies width'; }
                field("Height"; Rec."Height") { ToolTip = 'Specifies height'; }
                field("Length"; Rec."Length") { ToolTip = 'Specifies length'; }
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
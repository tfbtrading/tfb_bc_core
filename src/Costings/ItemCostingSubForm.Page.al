page 50346 "TFB Item Costing Subform"
{
    PageType = ListPart;
    SourceTable = "TFB Item Costing Lines";
    SourceTableView = sorting("Price (Base)") order(ascending);
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies line type';

                }
                field("Line Key"; Rec."Line Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies line key';
                }

                field("Price (Base)"; Rec."Price (Base)")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies price base cost';
                }
                field("Price Per Weight Unit"; Rec."Price Per Weight Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies price per weight unit';
                }
                field("Market Price (Base)"; Rec."Market Price (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies market price unit price';
                }
                field("Market price Per Weight Unit"; Rec."Market price Per Weight Unit")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies market price per weight unit';
                }
            }
        }

    }

    actions
    {
    }
}
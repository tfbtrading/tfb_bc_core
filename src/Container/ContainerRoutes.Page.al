page 50159 "TFB Container Routes"
{
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "TFB Container Route";
    Caption = 'Inbound Shipment Routes';
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies code for container route';

                }
                field("Ship Via"; Rec."Ship Via")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    Tooltip = 'Specifies shipment via';
                }
                field("Ship To"; Rec."Ship To")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    Tooltip = 'Specifies location to ship-to';
                }
                field("Route Description"; Rec."Route Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies route description';
                }
                field("Days to Port"; Rec."Days to Port") { ApplicationArea = All; Tooltip = 'Specifies days to port'; }
                field("Days to Clear"; Rec."Days to Clear") { ApplicationArea = All; Tooltip = 'Specifies days to clear'; }

                field(Transhipment; Rec.Transhipment) { ApplicationArea = All; Tooltip = 'Specifies if route includes transhipment'; }
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
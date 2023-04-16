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
                    ToolTip = 'Specifies code for container route';

                }
                field("Ship Via"; Rec."Ship Via")
                {
                    Lookup = true;
                    Tooltip = 'Specifies shipment via';
                }
                field("Ship To"; Rec."Ship To")
                {
                    Lookup = true;
                    Tooltip = 'Specifies location to ship-to';
                }
                field("Route Description"; Rec."Route Description")
                {
                    Tooltip = 'Specifies route description';
                }
                field("Days to Port"; Rec."Days to Port") { Tooltip = 'Specifies days to port'; }
                field("Days to Clear"; Rec."Days to Clear") { Tooltip = 'Specifies days to clear'; }

                field(Transhipment; Rec.Transhipment) { Tooltip = 'Specifies if route includes transhipment'; }
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
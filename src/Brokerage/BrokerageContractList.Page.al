page 50241 "TFB Brokerage Contract List"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Brokerage Contract";
    SourceTableView = sorting("No.") order(descending);
    Editable = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = true;
    CardPageId = "TFB Brokerage Contract";
    Caption = 'Brokerage Contracts';
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies no. for brokerage contract';


                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies vendor no.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies vendor name';

                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies customer no.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies customer name';
                }

                field("External Reference No."; Rec."External Reference No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies external reference no.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies current status for contract';
                    Style = Attention;
                    StyleExpr = Rec.Status = Rec.status::Draft;
                }

                field("Crop Year"; Rec."Crop Year")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies crop year for contract';
                }
                field("Date Signed"; Rec."Date Signed")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies date signed';
                }
                field("Total Value"; Rec."Total Value")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Tooltip = 'Specifies total value of contract. Calculated automatically.';
                }
                field("Total Brokerage"; Rec."Total Brokerage")
                {
                    ApplicationArea = All;
                    DrillDown = False;
                    Tooltip = 'Specifies total brokerage value of contract. Calculated automatically.';
                }

                field("No. of Shipments"; Rec."No. of Shipments")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    ToolTip = 'Specifies the no. of active shipments';
                }

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
            action(NewShipment)
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                Image = New;
                Caption = 'New shipment';
                ApplicationArea = All;
                ToolTip = 'Create a new shipment against the contract';

                trigger OnAction()

                var
                    Shipment: Record "TFB Brokerage Shipment";
                    ShipmentPage: Page "TFB Brokerage Shipment";

                begin

                    Clear(Shipment);
                    Shipment.Init();
                    Shipment.Validate("Buy From Vendor No.", Rec."Vendor No.");
                    Shipment.Validate("Customer No.", Rec."Customer No.");
                    Shipment.Validate("Contract No.", Rec."No.");

                    Shipment."Document Date" := today();
                    Shipment.Insert(true);

                    ShipmentPage.Editable := true;
                    ShipmentPage.SetRecord(Shipment);

                end;
            }
        }
    }
}
page 50151 "TFB Pstd. Sales Inv. Lines"
{
    PageType = List;
    SourceTable = "Sales Invoice Line";
    Caption = 'Pstd. Invoice Lines';
    SourceTableView = sorting("Sell-to Customer No.", "Posting Date") order(descending) where(Type = filter(Item), Quantity = filter(> 0));

    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = false;
                    ToolTip = 'Specifies document number for sales invoice line';
                    TableRelation = "Sales Invoice Header"."No.";

                }

                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = false;
                    ToolTip = 'Specifies sell-to-customer for sales invoice line';
                    TableRelation = customer."No.";

                }
                field("TFB Customer Name"; Rec."TFB Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies customers name';

                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = false;
                    ToolTip = 'Specifies item number that was sold';
                    TableRelation = item."No.";
                    LookupPageId = "Item List";
                }
                field(Description; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies description of item sold';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies posting date of the invoice';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies intended shipment date for item';

                }
                field("Shipment No."; Rec."Shipment No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipment number related to the invoice';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity that was invoiced in sales unit of measure';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies sales unit of measure';
                    TableRelation = "Unit of Measure".Code;
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. per UoM';
                    ToolTip = 'Specifies base qty per unit of measure';
                }
                field("Drop Shipment"; Rec."Drop Shipment")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies if item invoice relates to drop shipment';

                }

                field("Unit Price"; Rec."Unit Price")
                {
                    Lookup = true;
                    LookupPageId = "Purchase Order";
                    ApplicationArea = All;
                    ToolTip = 'Specifies unit price for invoiced item';
                }

                field("TFB Price Per Kg"; PricePerKg)
                {

                    ApplicationArea = All;
                    Caption = 'Per Kg Price';
                    ToolTip = 'Specifies price per kilogram for invoiced item';

                }
                field("TFB Pre-Order"; Rec."TFB Pre-Order")
                {
                    ApplicationArea = All;
                    Caption = 'Pre-Order';
                    ToolTip = 'Specifies if line was a pre-order';
                }
                field("TFB Pre-Order Unit Price Adj."; Rec."TFB Pre-Order Unit Price Adj.")
                {
                    ApplicationArea = All;
                    Caption = 'Pre-Order Adj';
                    ToolTip = 'Specifies the pre-order adjustment on a unit price basis';

                }



            }
        }
        area(Factboxes)
        {
            Part(Item; "Item Invoicing FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }

        }
    }


    actions
    {

        area(Navigation)
        {

            action(Invoice)
            {
                RunObject = Page "Posted Sales Invoice";
                RunPageLink = "No." = field("Document No.");
                RunPageMode = View;

                ApplicationArea = All;
                Image = Sales;
                ToolTip = 'Open invoice for invoiced line';
            }

            action(Shipment)
            {


                ApplicationArea = All;
                Image = Shipment;
                ToolTip = 'Open shipment for invoiced line';

                trigger OnAction()

                var
                    ItemLedger: Record "Item Ledger Entry";
                    ValueEntry: Record "Value Entry";
                    SalesShipment: Record "Sales Shipment Header";
                    SalesShipmentPage: Page "Posted Sales Shipment";
                begin

                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                    ValueEntry.SetRange("Document No.", rec."Document No.");
                    ValueEntry.SetRange("Document Line No.", rec."Line No.");

                    If ValueEntry.FindFirst() then begin

                        ItemLedger.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
                        ItemLedger.Findset(false);

                        If ItemLedger.Count > 0 then
                            If SalesShipment.Get(ItemLedger."Document No.") then begin
                                SalesShipmentPage.SetRecord(SalesShipment);
                                SalesShipmentPage.Run();
                            end;


                    end;

                end;
            }
            action(Customer)
            {
                RunObject = Page "Customer Card";
                RunPageLink = "No." = field("Sell-to Customer No.");
                RunPageMode = View;

                ApplicationArea = All;
                Image = Customer;
                ToolTip = 'Open customer related to invoiced line';
            }
            action("Ledger entries")
            {
                ApplicationArea = All;
                Image = LedgerEntries;
                ToolTip = 'Open ledger entry related to invoiced line';

                trigger OnAction()

                var
                    ItemLedger: Record "Item Ledger Entry";
                    ValueEntry: Record "Value Entry";
                    ILEP: Page "Item Ledger Entries";



                begin
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                    ValueEntry.SetRange("Document No.", rec."Document No.");
                    ValueEntry.SetRange("Document Line No.", rec."Line No.");

                    If ValueEntry.FindFirst() then begin

                        ItemLedger.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
                        ItemLedger.Findset(false);

                        If ItemLedger.Count > 0 then begin
                            ILEP.SetTableView(ItemLedger);
                            ILEP.Run();
                        end;

                    end;
                end;
            }
        }
        area(Processing)
        {
            action(TFBSendPODRequest)
            {
                Caption = 'Send POD request';
                ApplicationArea = All;
                Image = SendMail;

                ToolTip = 'Send a proof of delivery request to relevant party';

                trigger OnAction()
                var
                    PurchInvCU: CodeUnit "TFB Purch. Inv. Mgmt";
                begin
                    PurchInvCU.SendPODRequest(Rec."No.", Rec."Line No.");
                end;


            }
        }
        area(Promoted)
        {
            group(Category_Home)
            {
                Caption = 'Home';

                actionref(ActionRefName; TFBSendPODRequest)
                {

                }

            }
            group(Category_InvoiceLine)
            {
                Caption = 'Invoice Line';

                actionref(CustomerRef; Customer)
                {

                }
                actionref(InvoiceRef; Invoice)
                {

                }
                actionref(ShipmentRef; Shipment)
                {

                }
                actionref(LedgerEntryRef; "Ledger entries")
                {

                }
            }
        }
    }

    views
    {
        view("Dropships")
        {
            Caption = 'Dropships';
            Filters = where("Drop Shipment" = const(true));
        }


    }

    var

        PricingCU: Codeunit "TFB Pricing Calculations";
        PricePerKg: Decimal;
        PricingUnit: Enum "TFB Price Unit";

    trigger OnAfterGetRecord()

    begin

        PricingUnit := PricingUnit::KG;

        PricePerKg := PricingCU.CalculatePriceUnitByUnitPrice(Rec."No.", Rec."Unit of Measure Code", PricingUnit, Rec."Unit Price");

    end;

}
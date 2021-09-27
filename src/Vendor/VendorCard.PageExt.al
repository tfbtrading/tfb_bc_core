pageextension 50125 "TFB Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter(Name)
        {
            field("TFB Vendor Type"; Rec."TFB Vendor Type")
            {
                ApplicationArea = All;
                Importance = Promoted;
                Tooltip = 'Specifies the type of vendor. This will support which fields are shown and when the vendor is listed';

                trigger OnValidate()

                begin
                    case Rec."TFB Vendor Type" of
                        Rec."TFB Vendor Type"::TRADE:
                            Rec.Validate("TFB Vendor Price Unit", Rec."TFB Vendor Price Unit"::"MT")
                        else
                            Rec.Validate("TFB Vendor Price Unit", Rec."TFB Vendor Price Unit"::"N/A");
                    end;
                end;
            }
        }
        addafter("Purchaser Code")
        {
            field("TFB Vendor Price Unit"; Rec."TFB Vendor Price Unit")
            {
                ApplicationArea = All;
                Importance = Promoted;
                Tooltip = 'Specifies the vendors default price unit';

            }
            field("TFB Vendor Provides Ref."; Rec."TFB Vendor Provides Ref.")
            {
                ApplicationArea = All;
                Importance = Standard;
                ToolTip = 'Specifies if the vendor always provides an order confirmation';
            }
        }



        addbefore("Lead Time Calculation")
        {
            group(LeadTime)
            {
                Visible = Rec."TFB Vendor Type" = Rec."TFB Vendor Type"::TRADE;
                ShowCaption = false;

                field("TFB DropShip Date Override"; Rec."TFB DropShip Date Override")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if any drop ships related to this vendor override the default date behaviour on a sales and purchase order';
                }
                field("TFB Max Products Per Pallet"; Rec."TFB Max Products Per Pallet")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the vendor allows more than product per pallet in normal business operations';

                }

                field("TFB Dispatch Lead Time"; Rec."TFB Dispatch Lead Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum lead time until the supplier usually dispatches the product from their warehouse';
                    Enabled = Rec."TFB DropShip Date Override";
                }
                field("TFB Dispatch Lead Time Max"; Rec."TFB Dispatch Lead Time Max")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum lead time until the supplier usually dispatches the product from their warehouse';
                    Enabled = Rec."TFB DropShip Date Override";
                }

            }
        }
        addafter("Shipment Method Code")
        {

            field("Shipping Agent Code"; Rec."Shipping Agent Code")
            {
                ApplicationArea = All;
                Importance = Standard;
                Tooltip = 'Specifies the shipping agents code';
            }
            group(OverseasVendorFields)
            {
                ShowCaption = false;
                Visible = (Rec."TFB Vendor Type" = Rec."TFB Vendor Type"::TRADE) and (Rec."Country/Region Code" <> 'AU');
                field("TFB Ship Via Default"; Rec."TFB Ship Via Default")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    Tooltip = 'Specifies the ship via defaults for containers';
                }

                field("TFB Landed Cost Profile"; Rec."TFB Landed Cost Profile")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Tooltip = 'Specifies landed cost profile for vendors shipping conatiners';
                }
                field("TFB Delivery SLA"; Rec."TFB Delivery SLA")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    MultiLine = True;
                    Tooltip = 'Specifies delivery SLA for local deliveries if a drop ship vendor';
                }
            }
        }

        addafter("E-Mail")
        {
            field("TFB Receive Updates"; Rec."TFB Receive Updates")
            {
                ApplicationArea = All;
                Importance = Promoted;
                Tooltip = 'Specifies if vendor receives order updates';

            }
        }

        modify(ABN)
        {
            Editable = not Rec."Foreign Vend";
            Style = Unfavorable;
            StyleExpr = (Rec."Foreign Vend") and (Rec.ABN <> '');
        }

        modify(Registered)
        {
            Editable = not Rec."Foreign Vend";
            Style = Unfavorable;
            StyleExpr = (Rec."Foreign Vend") and (Rec.ABN <> '');
        }

    }

    actions
    {
        // Add changes to page actions here
        addafter(Prices)
        {
            action("TFB ZoneModifiers")
            {
                ApplicationArea = All;
                Caption = 'Postal zone surcharges';
                Tooltip = 'Show postal zone surcharges';
                Image = ZoneCode;
                trigger OnAction()
                var
                    RecVendorZoneRate: record "TFB Vendor Zone Rate";
                    PagVendorZoneRate: page "TFB Vendor Zone Rate SubForm";
                begin
                    RecVendorZoneRate.SetRange("Vendor No.", Rec."No.");
                    PagVendorZoneRate.SetTableView(RecVendorZoneRate);
                    PagVendorZoneRate.RunModal()

                end;
            }
            action("TFB Costings")
            {
                ApplicationArea = All;
                Caption = 'Item costings';
                Tooltip = 'Show item costings';
                Image = CostEntries;
                RunObject = page "TFB Item Costing List";
                RunPageLink = "Vendor No." = field("No."), Current = const(true);
                RunPageMode = View;

            }
        }

        addafter(PayVendor)
        {
            action(SendOrderUpdateByEmail)
            {
                Caption = 'Send order update';
                Tooltip = 'Send order update to vendor';
                Promoted = True;
                PromotedCategory = Process;
                Image = Email;
                ApplicationArea = All;

                trigger OnAction()

                var
                    VendorCU: Codeunit "TFB Vendor Mgmt";

                begin
                    VendorCU.SendOneVendorStatusEmail(Rec."No.");
                end;
            }
        }
    }






}

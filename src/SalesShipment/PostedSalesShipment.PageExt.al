pageextension 50182 "TFB Posted Sales Shipment" extends "Posted Sales Shipment" //MyTargetPageId
{
    layout
    {

        addbefore("Sell-to Customer Name")
        {
            field(TFBSellToCustomerNo; Rec."Sell-to Customer No.")
            {
                Caption = 'Sell-to Customer No.';
                DrillDown = true;
                Visible = true;
                Importance = Standard;
                ToolTip = 'Speciefies the sell-to customer no.';

            }
        }

        moveafter("Sell-to Customer Name"; "Ship-to Code", "Ship-to Name")
        modify("Ship-to Name")
        {
            Caption = 'Ship-to Name';
            Style = Strong;
            StyleExpr = Rec."Ship-to Code" <> '';
        }
        addbefore("Package Tracking No.")
        {
            field("TFB 3PL Booking No."; Rec."TFB 3PL Booking No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies 3PL booking number reference';
            }
            field(TFBFreightCharges; CalculatedFreightCharges)
            {
                ApplicationArea = All;
                Caption = 'Freight Charges Assigned';
                ToolTip = 'Specifies freight assigned from freight company invoices on item shipments';
                Editable = false;
                trigger OnDrillDown()

                var

                begin
                    ShipmentCU.OpenItemChargesForSalesShipment(Rec."No.", 'S-FREIGHT');
                end;
            }
        }

        modify("Order No.")
        {

            trigger OnDrillDown()


            var
                SalesMgmt: CodeUnit "TFB Sales Mgmt";
            begin

                SalesMgmt.OpenOpenOrArchivedOrder(Enum::"Sales Document Type"::Order, Rec."Order No.");

            end;
        }

        modify("Sell-to Customer Name")
        {
            DrillDownPageId = "Customer Card";
            LookupPageId = "Customer Card";
        }

    }

    actions
    {
        addafter("&Track Package")

        {
            Action(TFBNotifyCustomer)
            {
                Caption = 'Email shipment notification';
                Tooltip = 'Emails a details notification about the shipment to the customer';
                Image = Email;

                ApplicationArea = All;

                trigger OnAction()

                var

                    ShipmentCU: Codeunit "TFB Sales Shipment Mgmt";

                begin

                    if ShipmentCU.SendOneShipmentNotificationEmail(Rec."No.") = true then
                        Message('Notification sent');

                end;


            }
        }

        addafter("&Track Package_Promoted")
        {
            actionref(TFBNotifyCustomer_Promoted; TFBNotifyCustomer)
            {

            }
        }


    }
    var
        ShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";
        CalculatedFreightCharges: Decimal;


    trigger OnAfterGetRecord()

    var


    begin

        CalculatedFreightCharges := -ShipmentCU.GetItemChargesForSalesShipment(Rec."No.", 'S-FREIGHT');

    end;

}
pageextension 50182 "TFB Posted Sales Shipment" extends "Posted Sales Shipment" //MyTargetPageId
{
    layout
    {

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

    }

    actions
    {
        addafter("&Track Package")

        {
            Action(Notify)
            {
                Caption = 'Email shipment notification';
                Tooltip = 'Emails a details notification about the shipment to the customer';
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
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
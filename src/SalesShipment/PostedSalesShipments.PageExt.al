pageextension 50134 "TFB Posted Sales Shipments" extends "Posted Sales Shipments" //142
{
    layout
    {
        moveafter("Shipping Agent Code"; "Ship-to Code", "Ship-to Name")

        modify("Ship-to Code")
        {
            Visible = true;
        }
        modify("Ship-to Name")
        {
            Visible = true;
        }

        addbefore("External Document No.")
        {
            field("Order No."; Rec."Order No.")
            {
                Visible = true;
                ApplicationArea = All;
                ToolTip = 'Specifies sales order number for the shipment';
            }
        }
        addbefore("Package Tracking No.")
        {
            field("TFB 3PL Booking No."; Rec."TFB 3PL Booking No.")
            {
                Visible = true;
                ApplicationArea = All;
                ToolTip = 'Specifies the 3PL booking number for the shipment';
            }
        }

    }

    actions
    {

        addfirst(Navigation)
        {
            action("TFBOpenOrder")
            {
                RunObject = Page "Sales Order";
                RunPageLink = "No." = field("Order No.");
                RunPageMode = View;
                Image = Sales;
                Caption = 'Sales Order';
                ToolTip = 'Open relaed sales order';
                ApplicationArea = All;
            }
        }

        addlast("&Shipment")
        {
            action("Notify")
            {
                ApplicationArea = All;
                Image = SendAsPDF;
                Promoted = True;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                Caption = 'Email notification';
                ToolTip = 'Email shipment notification to customer that shipment has occured';


                trigger OnAction()
                var
                    ShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";
                begin

                    If Rec."No." <> '' then
                        If ShipmentCU.SendOneShipmentNotificationEmail(Rec."No.") then
                            Message('Sent Notification');

                end;

            }


            action("Send CoA(s)")
            {
                ApplicationArea = All;
                Caption = 'Send CoA(s)';
                Image = SendAsPDF;
                Promoted = True;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                ToolTip = 'Email certificates of analysis to customer for items in shipment';


                trigger OnAction()
                var
                    CommonCU: Codeunit "TFB Common Library";
                begin

                    If Rec."No." <> '' then
                        If CommonCU.CheckAndSendCoA(Rec."Order No.", false, false, true) then
                            Message('Sent COA(s) to customer')
                        else
                            Message('No CoA(s) to send to customer');

                end;

            }
        }
    }
}
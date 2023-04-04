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
                DrillDown = true;
                trigger OnDrillDown()


                var
                    SalesMgmt: CodeUnit "TFB Sales Mgmt";
                begin

                    SalesMgmt.OpenOpenOrArchivedOrder(Enum::"Sales Document Type"::Order, Rec."Order No.");

                end;
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

                Image = Sales;
                Caption = 'Sales Order';
                ToolTip = 'Open relaed sales order';
                ApplicationArea = All;

                trigger OnAction()
                var
                    SalesMgmt: CodeUnit "TFB Sales Mgmt";
                begin

                    SalesMgmt.OpenOpenOrArchivedOrder(Enum::"Sales Document Type"::Order, Rec."Order No.");

                end;
            }
        }

        addlast("&Shipment")
        {
            action(TFBNotifyCustomer)
            {
                ApplicationArea = All;
                Image = SendAsPDF;

                Caption = 'Email Customer Notification';
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


            action(TFBSendCOA)
            {
                ApplicationArea = All;
                Caption = 'Send CoA(s)';
                Image = SendAsPDF;

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
        addfirst(Category_Category4)
        {
            actionref(TFBSendCOA_Promoted; TFBSendCOA)
            {

            }
            actionref(TFBNotifyCustomer_Promoted; TFBNotifyCustomer)
            {

            }
        }
        addlast(Category_Category5)
        {
            actionref(TFBOpenOrder_Promoted; TFBOpenOrder)
            {

            }
        }
    }
}
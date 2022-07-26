pageextension 50136 "TFB Sales Shipment Lines" extends "Sales Shipment Lines" //5824
{


    layout
    {
        addafter("Document No.")
        {
            field("TFB Customer Name"; Rec."TFB Customer Name")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies customer name for shipment';
                DrillDown = false;
            }
            field("Order No."; Rec."Order No.")
            {
                ApplicationArea = All;
                Caption = 'Sales Order No.';
                Tooltip = 'Specifies order number';
            }
            field("TFB 3PL Booking No Lookup"; Rec."TFB 3PL Booking No Lookup")
            {
                ApplicationArea = All;
                Caption = '3PL Booking No.';
                Tooltip = 'Specifies 3PL Booking No';
            }

            field(TFBFreightCharges; CalculatedFreightCharges)
            {
                ApplicationArea = All;
                Caption = 'Freight Charged';
                ToolTip = 'Specifies freight charged on item shipment';

                trigger OnDrillDown()

                var

                begin
                    ShipmentCU.OpenItemChargesForSalesShipment(Rec."Document No.", Rec."Line No.", 'S-FREIGHT');
                end;
            }

            field("Drop Shipment"; Rec."Drop Shipment")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if item shipment is a drop shipment';

            }
            field("Purchase Order No."; Rec."Purchase Order No.")
            {
                ApplicationArea = All;
                Caption = 'Purch. Order No.';
                Tooltip = 'Specifies purchase order number for the dropshipment';
                Visible = false;
            }
            field("Posting Date"; Rec."Posting Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specify the date on which the shipment is posted';
            }

        }

    }
    actions
    {
    }
    views
    {
        addlast
        {
            view("Charge Assign. from WHS")
            {
                OrderBy = descending("Posting Date", "Document No.");
                Filters = where("Drop Shipment" = filter(false));
                SharedLayout = false;

                layout
                {
                    Modify("Drop Shipment")
                    {
                        Visible = false;
                    }
                    Modify("Purchase Order No.")
                    {
                        Visible = false;
                    }
                }
            }
            view("Drop Ships")
            {
                Caption = 'Drop Ships';
                Filters = where("Drop Shipment" = filter(true));
                SharedLayout = false;

                layout
                {
                    modify("Drop Shipment")
                    {
                        Visible = false;
                    }
                    modify("Purchase Order No.")
                    {
                        Visible = true;
                    }

                }
            }
        }
    }

    var
        ShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";
        "3PLBookingNoLookup": Text[30];
        CalculatedFreightCharges: Decimal;


    trigger OnAfterGetRecord()

    var
        ShipmentHeader: Record "Sales Shipment Header";

    begin
        Rec.CalcFields("TFB Customer Name");

        If ShipmentHeader.Get(rec."Document No.") then
            "3PLBookingNoLookup" := ShipmentHeader."TFB 3PL Booking No.";

        CalculatedFreightCharges := ShipmentCU.GetItemChargesForSalesShipment(Rec."Document No.", Rec."Line No.", 'S-FREIGHT');

    end;

    trigger OnOpenPage()

    begin

        Rec.SetCurrentKey("Posting Date");
        Rec.Ascending(false);

    end;



}
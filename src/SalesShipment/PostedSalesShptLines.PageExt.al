pageextension 50184 "TFB Posted Sales Shpt. Lines" extends "Posted Sales Shipment Lines" //525
{
    layout
    {
        addafter("Document No.")
        {
            field("Posting Date"; Rec."Posting Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies date shipment was posted';
            }
            field(TFB3PLBookingNo; Rec."TFB 3PL Booking No Lookup")
            {
                Caption = '3PL Booking No.';
                ApplicationArea = All;
                ToolTip = 'Specifies 3PL booking reference number';
            }



        }

        addafter("Sell-to Customer No.")
        {
            field("TFB Customer Name"; Rec."TFB Customer Name")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies customer name';
            }
        }

        addbefore("Location Code")
        {
            field("Drop Shipment"; Rec."Drop Shipment")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies if order line is a drop shipment';

            }

            field("Purchase Order No."; Rec."Purchase Order No.")
            {
                ApplicationArea = All;
                Caption = 'Purch. Order No.';
                ToolTip = 'Specifies purchase order for drop shipment line';
                Visible = true;
                DrillDown = true;

                trigger OnDrillDown()

                var
                    Lines: Record "Purch. Rcpt. Line";
                    LinesPage: Page "Posted Purchase Receipt Lines";

                begin

                    Lines.SetRange("Order No.", Rec."Purchase Order No.");
                    Lines.SetRange("Order Line No.", Rec."Purch. Order Line No.");

                    LinesPage.SetTableView(Lines);
                    LinesPage.Run();

                end;
            }
        }



    }



    actions
    {
    }





}


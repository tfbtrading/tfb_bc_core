pageextension 50112 "TFB Cust. Statistics FactBox" extends "Customer Statistics FactBox" //9082
{
    layout
    {

        addfirst(Sales)
        {
            field("TFB Date of Last Open Order"; Rec."TFB Date of Last Open Order")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date on which the last open order was placed';
            }
            field("TFB Date of Last Sale"; Rec."TFB Date of Last Sale")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date on which the last open order was placed';
            }
            field("TFB Date of First Sale"; Rec."TFB Date of First Sale")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date on which the first order was placed in the system';
            }
        }
        modify("Outstanding Orders (LCY)")
        {
            Visible = false;
        }
        modify("Outstanding Invoices (LCY)")
        {
            Visible = false;
        }
        modify("Shipped Not Invoiced (LCY)")
        {
            Visible = false;
        }

        addafter("Balance (LCY)")
        {
            field("TFB No. Of Fav. Items"; Rec."TFB No. Of Fav. Items")
            {
                Caption = 'Favourited Items';
                ApplicationArea = All;
                ToolTip = 'Specifies the number of items selected as favourites';

                DrillDown = true;
            }
        }
        addafter("Outstanding Orders (LCY)")
        {
            field("TFB Outstanding Brokerage"; Rec."TFB Outstanding Brokerage")
            {
                Caption = 'Outstanding Brokerage';
                ApplicationArea = All;
                ToolTip = 'Specifies the outstanding brokerage amount for the customer';

                trigger OnDrillDown()

                var
                    Header: Record "TFB Brokerage Shipment";
                    ListPage: Page "TFB Brokerage Shipment List";

                begin

                    Header.SetRange(Status, Header.Status::Approved, Header.Status::"In Progress");
                    Header.SetRange("Customer No.", Rec."No.");

                    ListPage.SetTableView(Header);
                    ListPage.Run();

                end;
            }
        }
    }

    actions
    {
    }
}
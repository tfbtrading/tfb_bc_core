page 50115 "TFB Post Dropship from Sale"
{
    PageType = Worksheet;
    Caption = 'Post drop ship sales lines';


    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sales Line";
    SourceTableView = sorting("Shipment Date", "Sell-to Customer No.") order(ascending) where("Outstanding Quantity" = filter(> 0), Type = const(Item), "Drop Shipment" = const(true), "Document Type" = const(Order), "Planned Shipment Date" = filter('<=today+7D'));

    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = true;
    Editable = true;

    PromotedActionCategories = 'New,Process,Item,Navigation';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                ShowAsTree = true;

                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    DrillDown = True;
                    ToolTip = 'Specifies the drop shipment purchase order related to the sales line';
                    Editable = false;
                    ApplicationArea = All;
                    trigger OnDrillDown()

                    begin

                        OpenDropShipOrder();

                    end;
                }
                field("TFB Buy-from Vendor No."; Rec."TFB Buy-from Vendor No.")
                {

                    ApplicationArea = All;
                    ToolTip = 'Specifies who is supply the drop shipment item';

                    DrillDown = true;
                    DrillDownPageId = "Vendor Card";
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;

                    DrillDown = true;
                    DrillDownPageId = "Sales Order";
                    tooltip = 'Specifies document number for pending sales line';
                    Editable = false;

                    trigger OnDrillDown()

                    var
                        SalesRec: record "Sales Header";


                    begin
                        SalesRec.SetRange("Document Type", Rec."Document Type"::Order);
                        SalesRec.SetRange("No.", Rec."Document No.");

                        If SalesRec.FindFirst() then
                            PAGE.RUN(PAGE::"Sales Order", SalesRec);



                    end;

                }

                field(ExternalRefNo; Rec."TFB External Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customers PO Ref';
                    ToolTip = 'Specifies customers external reference number i.e. po number';
                    Editable = false;
                }








                field("TFB CustomerName"; Rec."TFB Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    DrillDown = true;
                    ToolTip = 'Specifies the customers name';

                    Trigger OnDrillDown()

                    var
                        Customer: Record Customer;
                        CustomerPage: Page "Customer Card";

                    begin
                        If Customer.Get(Rec."Sell-to Customer No.") then begin
                            CustomerPage.SetRecord(Customer);
                            CustomerPage.Run();
                        end;


                    end;

                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the description of the item';
                    Editable = false;
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the requested delivery date for the item';
                    Editable = false;
                }
                field("Planned Shipment Date"; Rec."Planned Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currently planned shipment date';
                    Editable = false;
                }


                field("Outstanding Quantity"; Rec."Outstanding Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the outstanding quantity in the sales unit of measure';
                    Editable = false;
                }


                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. per UoM';
                    ToolTip = 'Specifies base quantity per unit of measure';
                    Editable = false;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent that will deliver the item';
                    Editable = false;

                }


                field("TFB Package Tracking  No"; _packageTrackingNo)
                {
                    ApplicationArea = All;
                    Caption = 'Package Tracking No';
                    ToolTip = 'Specifies the package tracking number';
                    Editable = true;
                }
                field("TFB Date Shipped"; _dateShipped)
                {
                    ApplicationArea = All;
                    Caption = 'Date Shipped';
                    ToolTip = 'Specifies the date the goods were shipped from the supplier';
                    Editable = true;
                }
            }

        }



    }


    actions
    {

        area(Processing)
        {
            action(PostDropShip)
            {
                ApplicationArea = All;
                Caption = 'Post Dropship';
                ToolTip = 'Post the drop ship receipt';
                Image = Post;

                trigger OnAction()

                var

                    Line: Record "Sales Line";
                begin
                    CurrPage.SetSelectionFilter(Line);
                    Message('Post %1 with package tracking %2 on %3', Rec."Purchase Order No.", _packageTrackingNo, _dateShipped);

                    if Line.FindSet() then
                        repeat
                            Message('Selected %1, Line $%2', line."Purchase Order No.", Line."Purch. Order Line No.");

                        until Line.Next() < 1;


                end;
            }
        }

    }

    var

        SalesCU: CodeUnit "TFB Sales Mgmt";
        _availability: Text;
        _dateShipped: Date;

        _packageTrackingNo: Text[50];


    trigger OnAfterGetRecord()

    var


    begin

        _availability := SalesCU.GetSalesLineStatusEmoji(Rec);
    end;

    local procedure OpenDropShipOrder()

    var
        Purchase: Record "Purchase Header";
        PurchasePage: Page "Purchase Order";

    begin

        Purchase.SetRange("Document Type", Purchase."Document Type"::Order);
        Purchase.SetRange("No.", Rec."Purchase Order No.");

        If Purchase.FindFirst() then begin
            PurchasePage.SetRecord(Purchase);
            PurchasePage.Run();
        end;

    end;



}
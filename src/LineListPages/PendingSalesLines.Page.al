page 50147 "TFB Pending Sales Lines"
{
    PageType = List;
    Caption = 'Pending Sales Order Lines';


    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sales Line";
    SourceTableView = sorting("Shipment Date", "Sell-to Customer No.") order(ascending) where("Outstanding Quantity" = filter(> 0), Type = const(Item), "Document Type" = const(Order));

    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = true;
    Editable = false;

    PromotedActionCategories = 'New,Process,Item,Navigation';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;

                    DrillDown = true;
                    DrillDownPageId = "Sales Order";
                    tooltip = 'Specifies document number for pending sales line';


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
                }

                field(Status; Rec."TFB Document Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies status of current sales line';
                }
                field("TFB Pre-Order"; Rec."TFB Pre-Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if line item on sales order is a pre-order with floating exchange';
                }


                field("TFB Availability"; _availability)
                {
                    ApplicationArea = All;
                    Caption = 'Avail. Info';
                    Visible = true;
                    Width = 1;
                    Editable = false;
                    ToolTip = 'Specifies a graphical indicator of availability for line item dependant on the whether it is a drop ship or from inventory';

                    trigger OnDrillDown()

                    var

                    begin
                        If Rec.type = Rec.type::Item then
                            If not (Rec."Drop Shipment" or Rec."Special Order") then
                                Rec.ShowReservation()
                            else
                                If Rec."Purchase Order No." <> '' then
                                    OpenRelatedPurchaseOrder();
                    end;
                }


                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = false;
                    ToolTip = 'Specifies the customer number';

                }
                field("TFB CustomerName"; Rec."TFB Customer Name")
                {
                    ApplicationArea = All;

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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = false;
                    ToolTip = 'Specifies the item number';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the description of the item';
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the requested delivery date for the item';
                }
                field("Planned Shipment Date"; Rec."Planned Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currently planned shipment date';
                }
                field("Shipment Status Update"; _StatusUpdate)
                {
                    ApplicationArea = All;
                    Caption = 'Shipment Status';
                    ToolTip = 'Captures the suppliers status update';
                    Editable = true;
                    Visible = false;
                }
                field("Planned Delivery Date"; Rec."Planned Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currently planned delivery date';

                }

                field("Outstanding Quantity"; Rec."Outstanding Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the outstanding quantity in the sales unit of measure';
                }
                field("Whse. Outstanding Qty."; Rec."Whse. Outstanding Qty.")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. Whse. Shipment';
                    ToolTip = 'Specifies the quantity currently on a warehouse shipment';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the sales unit of measure';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. per UoM';
                    ToolTip = 'Specifies base quantity per unit of measure';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping agent that will deliver the item';
                }
                field("Drop Shipment"; Rec."Drop Shipment")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies if the item is a drop shipment';
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    DrillDown = True;
                    ToolTip = 'Specifies the drop shipment purchase order related to the sales line';

                    ApplicationArea = All;
                    trigger OnDrillDown()



                    begin

                        OpenRelatedPurchaseOrder();

                    end;
                }
                field("TFB Buy-from Vendor No."; Rec."TFB Buy-from Vendor No.")
                {

                    ApplicationArea = All;
                    Caption = 'Buy-from Vendor No.';
                    ToolTip = 'Specifies who is supply the drop shipment item';

                    DrillDown = true;
                    DrillDownPageId = "Vendor Card";
                }


            }

        }

        area(Factboxes)
        {
            /*   Part(AvailInfo; "TFB Sales Line FactBox")
              {
                  ApplicationArea = All;
                  SubPageLink = "Document No." = field("Document No."), "Line No." = field("Line No."), "Document Type" = field("Document Type");
                  Caption = 'Availability Info';
              }
   */
        }

    }


    actions
    {

        area(Navigation)
        {
            action("Sales order")
            {
                RunPageMode = edit;
                ApplicationArea = all;
                Image = Sales;
                RunObject = Page "Sales Order";
                RunPageLink = "Document Type" = field("Document Type"), "No." = field("Document No.");
                Caption = 'Sales order';
                Tooltip = 'Opens related sales order';
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
            }
            action("Customer card")
            {
                RunPageMode = view;
                ApplicationArea = all;
                Image = Customer;
                RunObject = Page "Customer Card";
                RunPageLink = "No." = field("Sell-to Customer No.");
                Caption = 'Customer card';
                Tooltip = 'Opens related customer card';
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
            }


        }
        area(Processing)
        {
            action("Update shipping agent details")
            {
                ApplicationArea = All;
                Image = UpdateShipment;
                ToolTip = 'Updates shipping agent details based on latest rules and defaults for pending lines';


                trigger OnAction()
                begin
                    FixShippingAgentDetails();
                end;


            }
        }
    }

    views
    {
        view("Dropships")
        {
            Caption = 'Dropships';
            Filters = where("Drop Shipment" = const(true));
            SharedLayout = false;
            layout
            {
                movefirst(General; "TFB Buy-from Vendor No.", "Purchase Order No.", "Shipping Agent Code")


                modify("TFB Availability")
                {
                    Visible = false;
                }
                modify(Status)
                {
                    Visible = false;
                }
                modify("Drop Shipment")
                {
                    Visible = false;
                }
                modify("No.")
                {
                    Visible = false;
                }
                modify("Whse. Outstanding Qty.")
                {
                    Visible = false;
                }
                modify("Shipment Status Update")
                {
                    Visible = true;
                }
            }
        }
        view("Late Lines")
        {
            Caption = 'Not Shipped Ontime';
            Filters = where("Planned Shipment Date" = filter('< TODAY'));
            SharedLayout = true;
        }
        view("Ready to Ship")
        {
            Caption = 'Ready to Ship';
            Filters = where("Whse. Outstanding Qty." = filter('0'), "Drop Shipment" = filter(false), "Planned Shipment Date" = filter('<= TODAY'));
            SharedLayout = true;
        }
        view("Pre-Orders")
        {
            Caption = 'On Pre-Order';
            Filters = where("TFB Pre-Order" = const(true), "Drop Shipment" = filter(false));
            SharedLayout = true;
        }
    }

    var

        SalesCU: CodeUnit "TFB Sales Mgmt";
        _availability: Text;
        _statusUpdate: Text;


    trigger OnAfterGetRecord()

    var


    begin

        _availability := SalesCU.GetSalesLineStatusEmoji(Rec);
    end;

    local procedure OpenRelatedPurchaseOrder()

    var
        Purchase: Record "Purchase Header";
        PurchasePage: Page "Purchase Order";

    begin

        Purchase.SetRange("Document Type", Purchase."Document Type"::Order);

        If Rec."Drop Shipment" then
            Purchase.SetRange("No.", Rec."Purchase Order No.")
        else
            if Rec."Special Order" then
                Purchase.SetRange("No.", Rec."Special Order Purchase No.");

        If Purchase.FindFirst() then begin
            PurchasePage.SetRecord(Purchase);
            PurchasePage.Run();
        end;

    end;

    local procedure FixShippingAgentDetails()

    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ItemRec: Record Item;
        ItemCU: CodeUnit "TFB Item Mgmt";
        ReleaseCU: CodeUnit "Release Sales Document";
        Released: Boolean;

    begin

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("Outstanding Quantity", '>0');
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("Drop Shipment", true);

        if SalesLine.FindSet() then
            repeat
                //Initialise
                Clear(Released);
                Clear(SalesHeader);
                Clear(ItemRec);

                //Check Details
                If ItemRec.Get(SalesLine."No.") then begin
                    SalesHeader.SetRange("Document Type", SalesLine."Document Type");
                    SalesHeader.SetRange("No.", SalesLine."Document No.");
                    If SalesHeader.FindFirst() then begin
                        case SalesHeader.Status of
                            SalesHeader.Status::Released:
                                begin
                                    Released := true;
                                    ReleaseCU.Reopen(SalesHeader);
                                end;
                        end;
                        ItemCU.UpdateDropShipSalesLineAgent(ItemRec, SalesLine);
                        SalesLine.Modify(false);
                        If Released = true then begin
                            ReleaseCU.SetSkipCheckReleaseRestrictions();
                            ReleaseCU.PerformManualRelease(SalesHeader);
                        end;
                    end;
                end;
            until SalesLine.Next() < 1;


    end;

}
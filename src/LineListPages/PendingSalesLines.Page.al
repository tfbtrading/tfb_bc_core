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


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {

                    DrillDown = true;
                    DrillDownPageId = "Sales Order";
                    tooltip = 'Specifies document number for pending sales line';


                    trigger OnDrillDown()

                    var
                        SalesRec: record "Sales Header";

                    begin

                        SalesRec.SetRange("Document Type", Rec."Document Type"::Order);
                        SalesRec.SetRange("No.", Rec."Document No.");

                        if SalesRec.FindFirst() then
                            PAGE.RUN(PAGE::"Sales Order", SalesRec);



                    end;

                }

                field(ExternalRefNo; Rec."TFB External Document No.")
                {
                    Caption = 'Customers PO Ref';
                    ToolTip = 'Specifies customers external reference number i.e. po number';
                }

                field(Status; Rec."TFB Document Status")
                {
                    ToolTip = 'Specifies status of current sales line';
                }
                field("TFB Pre-Order"; Rec."TFB Pre-Order")
                {
                    ToolTip = 'Specifies if line item on sales order is a pre-order with floating exchange';
                }


                field("TFB Availability"; _availability)
                {
                    Caption = 'Avail. Info';
                    Visible = true;
                    Width = 1;
                    Editable = false;
                    ToolTip = 'Specifies a graphical indicator of availability for line item dependant on the whether it is a drop ship or from inventory';

                    trigger OnDrillDown()

                    var

                    begin
                        if Rec.type = Rec.type::Item then
                            if not (Rec."Drop Shipment" or Rec."Special Order") then
                                Rec.ShowReservation()
                            else
                                if Rec."Purchase Order No." <> '' then
                                    OpenRelatedPurchaseOrder();
                    end;
                }
                field("TFB Payment Status"; _paymentstatus)
                {
                    Caption = 'Prepay. Info';
                    Visible = true;
                    Width = 1;
                    Editable = false;
                    ToolTip = 'Specifies a graphical indicator of payment status of the sales line';

                    trigger OnDrillDown()

                    var
                        SalesInvoiceHeader: Record "Sales Invoice Header";


                    begin
                        SalesInvoiceHeader.FilterGroup(2);
                        SalesInvoiceHeader.SetRange("Prepayment Order No.", Rec."Document No.");
                        SalesInvoiceHeader.SetRange("Prepayment Invoice", true);
                        SalesInvoiceHeader.FilterGroup(0);

                        If SalesInvoiceHeader.Count > 0 then
                            Page.Run(Page::"Posted Sales Invoices", SalesInvoiceHeader);

                    end;
                }

                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    Lookup = false;
                    DrillDown = false;
                    ToolTip = 'Specifies the customer number';

                }
                field("TFB CustomerName"; Rec."TFB Customer Name")
                {

                    DrillDown = true;
                    ToolTip = 'Specifies the customers name';

                    trigger OnDrillDown()

                    var
                        Customer: Record Customer;
                        CustomerPage: Page "Customer Card";

                    begin
                        if Customer.Get(Rec."Sell-to Customer No.") then begin
                            CustomerPage.SetRecord(Customer);
                            CustomerPage.Run();
                        end;


                    end;

                }
                field("No."; Rec."No.")
                {
                    Lookup = false;
                    DrillDown = false;
                    ToolTip = 'Specifies the item number';
                }
                field("Description"; Rec."Description")
                {
                    Tooltip = 'Specifies the description of the item';
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ToolTip = 'Specifies the requested delivery date for the item';
                }
                field("Planned Shipment Date"; Rec."Planned Shipment Date")
                {
                    ToolTip = 'Specifies the currently planned shipment date';
                }
                field("Shipment Status Update"; _StatusUpdate)
                {
                    Caption = 'Shipment Status';
                    ToolTip = 'Captures the suppliers status update';
                    Editable = true;
                    Visible = false;
                }
                field("Planned Delivery Date"; Rec."Planned Delivery Date")
                {
                    ToolTip = 'Specifies the currently planned delivery date';

                }

                field("Outstanding Quantity"; Rec."Outstanding Quantity")
                {
                    ToolTip = 'Specifies the outstanding quantity in the sales unit of measure';
                }
                field("Whse. Outstanding Qty."; Rec."Whse. Outstanding Qty.")
                {
                    Caption = 'Qty. Whse. Shipment';
                    ToolTip = 'Specifies the quantity currently on a warehouse shipment';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Tooltip = 'Specifies the sales unit of measure';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    Caption = 'Qty. per UoM';
                    ToolTip = 'Specifies base quantity per unit of measure';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ToolTip = 'Specifies the shipping agent that will deliver the item';
                }
                field("Drop Shipment"; Rec."Drop Shipment")
                {
                    Tooltip = 'Specifies if the item is a drop shipment';
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    DrillDown = true;
                    ToolTip = 'Specifies the drop shipment purchase order related to the sales line';
                    trigger OnDrillDown()



                    begin

                        OpenRelatedPurchaseOrder();

                    end;
                }
                field("TFB Buy-from Vendor No."; Rec."TFB Buy-from Vendor No.")
                {
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
                Image = Sales;
                RunObject = Page "Sales Order";
                RunPageLink = "Document Type" = field("Document Type"), "No." = field("Document No.");
                Caption = 'Sales order';
                Tooltip = 'Opens related sales order';

            }
            action("Customer card")
            {
                RunPageMode = view;
                Image = Customer;
                RunObject = Page "Customer Card";
                RunPageLink = "No." = field("Sell-to Customer No.");
                Caption = 'Customer card';
                Tooltip = 'Opens related customer card';

            }


        }
        area(Processing)
        {
            action("Update shipping agent details")
            {
                Image = UpdateShipment;
                ToolTip = 'Updates shipping agent details based on latest rules and defaults for pending lines';


                trigger OnAction()
                begin
                    FixShippingAgentDetails();
                end;


            }
            action(OrderPromising)
            {
                AccessByPermission = TableData "Order Promising Line" = R;
                ApplicationArea = OrderPromising;
                Caption = 'Order &Promising';
                Image = OrderPromising;
                ToolTip = 'Calculate the shipment and delivery dates based on the item''s known and expected availability dates, and then promise the dates to the customer.';


                trigger OnAction()
                begin
                    OrderPromisingLine();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Home)
            {
                Caption = 'Home';
                actionref(OrderPromisingRef; OrderPromising)
                {

                }

            }
            group(Category_SalesLine)
            {
                Caption = 'Sales Line';
                actionref(SalesOrderRef; "Sales order")
                {

                }
                actionref(CustomerCardRef; "Customer card")
                {

                }

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
        _paymentstatus: Text;
        _statusUpdate: Text;

    /// <summary>
    /// Duplicates order promising functionality 
    /// </summary>
    procedure OrderPromisingLine()
    var
        SalesHeader: Record "Sales Header";
        TempOrderPromisingLine: Record "Order Promising Line" temporary;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        OrderPromisingLines: Page "Order Promising Lines";


    begin
        Rec.calcFields("TFB Document Status");
        if Rec."TFB Document Status" <> Rec."TFB Document Status"::Open then
            if Dialog.Confirm('Do you want to first open document before order promising?', true) then begin
                SalesHeader.Get(Rec."Document Type", Rec."Document No.");
                ReleaseSalesDoc.PerformManualReopen(SalesHeader);
            end
            else
                exit;

        TempOrderPromisingLine.SetRange("Source Type", Rec."Document Type");
        TempOrderPromisingLine.SetRange("Source ID", Rec."Document No.");
        TempOrderPromisingLine.SetRange("Source Line No.", Rec."Line No.");

        OrderPromisingLines.SetSource(Enum::"Order Promising Line Source Type"::Sales);
        OrderPromisingLines.SetTableView(TempOrderPromisingLine);
        OrderPromisingLines.RunModal();
    end;

    trigger OnAfterGetRecord()

    var


    begin

        _availability := SalesCU.GetSalesLineStatusEmoji(Rec);
        _paymentstatus := SalesCU.GetPaymentStatusEmoji(Rec);
    end;

    local procedure OpenRelatedPurchaseOrder()

    var
        Purchase: Record "Purchase Header";
        PurchasePage: Page "Purchase Order";

    begin

        Purchase.SetRange("Document Type", Purchase."Document Type"::Order);

        if Rec."Drop Shipment" then
            Purchase.SetRange("No.", Rec."Purchase Order No.")
        else
            if Rec."Special Order" then
                Purchase.SetRange("No.", Rec."Special Order Purchase No.");

        if Purchase.FindFirst() then begin
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
                if ItemRec.Get(SalesLine."No.") then begin
                    SalesHeader.SetRange("Document Type", SalesLine."Document Type");
                    SalesHeader.SetRange("No.", SalesLine."Document No.");
                    if SalesHeader.FindFirst() then begin
                        case SalesHeader.Status of
                            SalesHeader.Status::Released:
                                begin
                                    Released := true;
                                    ReleaseCU.Reopen(SalesHeader);
                                end;
                        end;
                        ItemCU.UpdateDropShipSalesLineAgent(ItemRec, SalesLine);
                        SalesLine.Modify(false);
                        if Released = true then begin
                            ReleaseCU.SetSkipCheckReleaseRestrictions();
                            ReleaseCU.PerformManualRelease(SalesHeader);
                        end;
                    end;
                end;
            until SalesLine.Next() < 1;


    end;

}
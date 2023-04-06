page 50103 "TFB Pending Purch. Order Lines"
{
    PageType = List;
    Caption = 'Pending Purchase Order Lines';

    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Purchase Line";
    SourceTableView = sorting("Expected Receipt Date", "Buy-from Vendor No.") order(ascending) where("Outstanding Quantity" = filter(> 0), Type = const(Item), "Document Type" = const(Order));

    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;



    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = true;
                    ToolTip = 'Specifies document no. for line';

                    trigger OnDrillDown()

                    var
                        PurchRec: record "Purchase Header";
                        PurchOrder: page "Purchase Order";


                    begin
                        PurchRec.SetRange("Document Type", Rec."Document Type"::Order);
                        PurchRec.SetRange("No.", Rec."Document No.");
                        PurchRec.FindFirst();

                        PurchOrder.SetRecord(PurchRec);
                        PurchOrder.Run();

                    end;

                }
                field("TFB Ext. No. Lookup"; Rec."TFB Ext. No. Lookup")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the vendors order number reference';
                    DrillDown = false;
                }

                field(Status; Rec."TFB Order Status")
                {
                    Caption = 'Status';
                    ApplicationArea = All;
                    ToolTip = 'Specifies status of document';
                    DrillDown = false;
                }

                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = true;
                    DrillDownPageId = "Vendor Card";
                    ToolTip = 'Specifies vendor no. for purchase order line';

                }
                field("TFB VendorName"; Rec."TFB VendorName")
                {
                    ApplicationArea = All;

                    DrillDown = false;
                    Tooltip = 'Specifies vendor name';



                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = true;
                    DrillDownPageId = "Item Card";
                    ToolTip = 'Specifies item number';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies description of item';
                }
                field(tfbSailingDate; getSailingDate())
                {
                    ApplicationArea = All;
                    Caption = 'Container sailing date';
                    ToolTip = 'Specifies date on which purchase order departs origin if it is on a container';
                    //Visible = Rec."TFB Container Entry No." <> '';
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies date goods are expected to be received';
                }
                field("Planned Receipt Date"; Rec."Planned Receipt Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies planned receipt date';

                }
                field("TFBDaysDiff"; _PlanDayDifference)
                {
                    Caption = 'Delay';
                    ToolTip = 'Specifies days ahead or delayed';
                    Style = Favorable;
                    StyleExpr = _PlanDayDifference <= 0;
                    ApplicationArea = all;
                }

                field("Outstanding Quantity"; Rec."Outstanding Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies outstanding quantity in order unit of measure';
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies unit of measure for quantity';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. per UoM';
                    Tooltip = 'Specifies quantiy of base unit per purchase unit of measure';

                }

                field("Sales Order No."; Rec."Sales Order No.")
                {
                    DrillDown = true;
                    Tooltip = 'Specifies related sales order no. if item is drop ship or special order';
                    ApplicationArea = All;
                    trigger OnDrillDown()

                    var
                        SalesOrder: Record "Sales Header";
                        SalesOrderPage: Page "Sales Order";

                    begin

                        SalesOrder.SetRange("Document Type", SalesOrder."Document Type"::Order);
                        SalesOrder.SetRange("No.", Rec."Sales Order No.");

                        if SalesOrder.FindFirst() then begin
                            SalesOrderPage.SetRecord(SalesOrder);
                            SalesOrderPage.Run();
                        end;

                    end;
                }
                field(CustomerName; Rec."TFB SO Cust. Name")
                {

                    ApplicationArea = All;
                    ToolTip = 'Specifies customers name if it is a drop shipment';

                    DrillDown = true;
                    trigger OnDrillDown()

                    var
                        SalesOrder: Record "Sales Header";

                        Customer: Record Customer;
                        CustomerPage: Page "Customer Card";
                    begin

                        SalesOrder.SetRange("Document Type", SalesOrder."Document Type"::Order);
                        SalesOrder.SetRange("No.", Rec."Sales Order No.");

                        if SalesOrder.FindFirst() then
                            if Customer.Get(SalesOrder."Sell-to Customer No.") then begin

                                CustomerPage.SetRecord(Customer);
                                CustomerPage.Run();

                            end;
                    end;
                }


            }
        }

    }


    actions
    {

        area(Navigation)
        {


        }
        area(Processing)
        {
        }
    }

    views
    {
        view("Dropships")
        {
            Caption = 'Dropships';
            Filters = where("Drop Shipment" = const(true));
        }
        view("Late Lines")
        {
            Caption = 'Not Shipped Ontime';
            Filters = where("Expected Receipt Date" = filter('< TODAY'));
        }

    }

    var

        _PlanDayDifference: Integer;


    trigger OnAfterGetRecord()

    var

    begin
        // _PlanDayDifference := "Planned Receipt Date" - "Requested Receipt Date";
    end;

    local procedure getSailingDate(): Date
    var
        Container: Record "TFB Container Entry";

    begin

        if Container.Get(Rec."TFB Container Entry No.") then
            exit(Container."Est. Departure Date");


    end;



}
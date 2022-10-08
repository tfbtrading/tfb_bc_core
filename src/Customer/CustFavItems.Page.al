page 50122 "TFB Cust. Fav. Items"
{
    PageType = List;
    Caption = 'Customers favourite items';
    DataCaptionFields = "Customer No.";
    SourceTableView = sorting(Description);
    UsageCategory = None;
    SourceTable = "TFB Cust. Fav. Item";
    Editable = true;

    InsertAllowed = true;
    DeleteAllowed = true;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Item Number';


                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item Description';
                    Editable = false;
                    DrillDown = false;

                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the source for the added favourite item';
                }

                field(TFBSalesPrice; SalesPriceVar)
                {
                    Caption = 'Local Sales Price Per Kg';
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the local sales price per kg';
                    Style = Favorable;
                    StyleExpr = SalesPriceVar < LastPricePaid;
                    Editable = false;

                    trigger OnDrillDown()

                    var
                        PriceListLine: Record "Price List Line";
                        PriceListLineReview: Page "Price List Line Review";

                    begin
                        PriceListLine.SetRange("Asset No.", Rec."Item No.");
                        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
                        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
                        PriceListLine.Setrange(Status, PriceListLine.Status::Active);
                        PriceListLine.SetFilter("Ending Date", '=%1|>=%2', 0D, WorkDate());
                        PriceListLineReview.SetTableView(PriceListLine);
                        PriceListLineReview.LookupMode(false);
                        PriceListLineReview.RunModal();

                    end;

                }
                field(TFBLastPriceChangedDate; LastChangedDateVar)
                {
                    Caption = 'Last Changed';
                    ApplicationArea = All;
                    BlankNumbers = BlankZero;
                    ToolTip = 'Specifies the date the local sales price was changed';
                }
                field(TFBLastPricePaid; LastPricePaid)
                {
                    Caption = 'Last Price Paid';
                    ApplicationArea = All;
                    BlankNumbers = BlankZero;
                    ToolTip = 'Specifies the last price paid by the customer';
                    DrillDown = true;
                    DrillDownPageId = "TFB Pstd. Sales Inv. Lines";

                    Enabled = true;

                    trigger OnDrillDown()

                    var
                        SalesInvoice: Record "Sales Invoice Line";
                        SalesInvoiceLine: Page "TFB Pstd. Sales Inv. Lines";

                    begin

                        SalesInvoice.SetRange("Sell-to Customer No.");
                        SalesInvoice.SetRange("No.");
                        SalesInvoice.SetCurrentKey("Posting Date");
                        SalesInvoice.SetAscending("Posting Date", false);

                        SalesInvoiceLine.SetTableView(SalesInvoice);
                        SalesInvoiceLine.Run();

                    end;
                }

                field(TFBLastDatePurchased; LastDatePurchased)
                {
                    Caption = 'Last Purchased On';
                    ApplicationArea = All;
                    BlankNumbers = BlankZero;
                    ToolTip = 'Specifies the date item was last purchased by customer';
                    DrillDown = true;
                    DrillDownPageId = "TFB Pstd. Sales Inv. Lines";


                    Enabled = true;

                    trigger OnDrillDown()

                    var
                        SalesInvoice: Record "Sales Invoice Line";
                        SalesInvoiceLine: Page "TFB Pstd. Sales Inv. Lines";

                    begin

                        SalesInvoice.SetRange("Sell-to Customer No.");
                        SalesInvoice.SetRange("No.");
                        SalesInvoice.SetCurrentKey("Posting Date");
                        SalesInvoice.SetAscending("Posting Date", false);

                        SalesInvoiceLine.SetTableView(SalesInvoice);
                        SalesInvoiceLine.Run();

                    end;
                }

                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specificies current inventory availability';

                    trigger OnDrillDown()

                    var
                        ItemLedger: Record "Item Ledger Entry";
                        LedgerEntries: Page "Item Ledger Entries";
                    begin

                        ItemLedger.SetRange("Item No.", Rec."Item No.");
                        ItemLedger.SetFilter("Remaining Quantity", '>0');
                        ItemLedger.SetFilter("Document Type", '%1|%2|%3', Enum::"Item Ledger Document Type"::"Purchase Receipt", Enum::"Item Ledger Document Type"::"Sales Return Receipt", Enum::"Item Ledger Document Type"::"Transfer Receipt");

                        LedgerEntries.SetTableView(ItemLedger);
                        LedgerEntries.Run();
                    end;
                }

                field("Reserved Qty. on Inventory"; Rec."Reserved Qty. on Inventory")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specificies reserved sales on inventory';
                }
                field("Qty. On Sales Order"; Rec."Qty. On Sales Order")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "TFB Pending Sales Lines";
                    BlankZero = true;
                    ToolTip = 'Specificies current quantity on order by customer';
                }
                field("Sales (Qty.)"; Rec."Sales (Qty.)")
                {
                    ApplicationArea = All;
                    Caption = 'Historical Sales Qty';
                    ToolTip = 'Specificies current quantity on order by customer';
                }
                field("Substitutes Exist"; Rec."Substitutes Exist")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies that a substitute exists for this item.';
                }

            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AutoPopulate)
            {
                ApplicationArea = All;


                Image = ExecuteBatch;
                Caption = 'Refresh';
                ToolTip = 'Populates items in the favourites for customer';

                trigger OnAction()

                var
                    CU: CodeUnit "TFB Cust. Fav. Items";
                begin

                    CU.PopulateOneCustomer(Rec."Customer No.");
                end;
            }

            action(CreateSalesOrder)
            {
                ApplicationArea = All;

                Image = NewOrder;

                Caption = 'Make Order';
                ToolTip = 'Create Sales Order from selected from one or more selected items for this customer';

                trigger OnAction()

                var
                    SalesLine: Record "Sales Line";
                    SalesOrder: Record "Sales Header";
                    SourceLines: Record "TFB Cust. Fav. Item";
                    SalesOrderPage: Page "Sales Order";
                    DocNo: Code[20];
                    LineCount: Integer;

                begin

                    SalesOrder.Init();
                    SalesOrder."Document Type" := SalesOrder."Document Type"::Order;
                    SalesOrder.Validate("Sell-to Customer No.", Rec."Customer No.");



                    If SalesOrder.Insert(true) then begin

                        Commit();

                        DocNo := SalesOrder."No.";

                        CurrPage.SetSelectionFilter(SourceLines);

                        If SourceLines.FindSet() then
                            repeat
                                LineCount += 10000;
                                SalesLine.Init();
                                SalesLine."Line No." := LineCount;
                                SalesLine.validate("Document Type", SalesLine."Document Type"::Order);
                                SalesLine.validate("Document No.", DocNo);
                                SalesLine.Validate(Type, SalesLine.Type::Item);
                                SalesLine.Validate("No.", SourceLines."Item No.");
                                SalesLine.Insert(true);

                            until SourceLines.Next() = 0;


                        SalesOrderPage.SetRecord(SalesOrder);
                        SalesOrderPage.Run();
                    end

                end;
            }
        }

        area(Promoted)
        {
            Group(Category_Home)
            {
                Caption = 'Home';
                actionref(CreateSalesOrderRef; CreateSalesOrder)
                {

                }
                actionref(AutoPopulateRef; AutoPopulate)
                {

                }
            }
        }

    }

    trigger OnAfterGetRecord()

    begin

        Clear(SalesPriceVar);
        Clear(LastChangedDateVar);
        Clear(LastPricePaid);
        Clear(LastDatePurchased);

        ItemMgmt.GetItemDynamicDetails(Rec."Item No.", Rec."Customer No.", SalesPriceVar, LastChangedDateVar, LastPricePaid, LastDatePurchased);
    end;

    var
        ItemMgmt: CodeUnit "TFB Item Mgmt";
        LastChangedDateVar: Date;
        LastDatePurchased: Date;
        [InDataSet]
        LastPricePaid: Decimal;
        [InDataSet]
        SalesPriceVar: Decimal;

}
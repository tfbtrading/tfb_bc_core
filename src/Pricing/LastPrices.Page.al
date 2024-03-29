page 50178 "TFB Last Prices"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TFB Last Prices";
    SourceTableTemporary = true;
    DataCaptionExpression = 'Last Prices for ' + _ItemName;
    SourceTableView = sorting("Document Date", "Document No.") order(descending);
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Last Prices';


    layout
    {
        area(Content)
        {
            group(Context)
            {
                grid(GridDetails)
                {
                    ShowCaption = false;

                    field(_CustomerName; _RelationshipName)
                    {
                        Caption = 'Customer Name';
                        Editable = false;
                        ToolTip = 'Specifies the customer for which we are reviewing price history.';
                    }
                    field(_LinePrice; _LinePrice)
                    {
                        Caption = 'Current Unit Price';
                        Editable = false;
                        ToolTip = 'Specifies the current item unit price for the line we are reviewing price history for.';
                    }
                    field(_LineDiscount; _LineDiscount)
                    {
                        Caption = 'Current Unit Discount';
                        Editable = false;
                        ToolTip = 'Specifies the current item unit price for the line we are reviewing price history for.';
                    }
                    field(_LinePriceAfterDiscount; _LinePrice - _LineDiscount)
                    {
                        Caption = 'Current Unit Price After Discount';
                        Editable = false;
                        ToolTip = 'Specifies the current item unit price after discount that we are reviewing price history for';
                    }
                    field(_LinePriceGroup; _LinePriceGroup)
                    {
                        Caption = 'Current Price Group';
                        Editable = false;
                        ToolTip = 'Specifies the current item unit price for the line we are reviewing price history for.';
                    }

                }
            }
            group(Filters)
            {

                grid(GridFilters)
                {
                    field(_FilterByRelationship; _FilterByRelationship)
                    {
                        Caption = 'Restrict to customer/vendor';
                        ToolTip = 'Specifies whether the page shows price history for the item across all customers/vendors or just the current one';

                        trigger OnValidate()

                        begin
                            RefreshData();
                        end;
                    }
                    field(_FilterByPriceGroup; _FilterByPriceGroup)
                    {
                        Caption = 'Restrict to the price group';
                        ToolTip = 'Specifies whether the page shows price history for the item across all customer price groups or just the current one';

                        trigger OnValidate()

                        begin
                            RefreshData();
                        end;
                    }
                    field(_MaxNoEntries; _MaxNoEntries)
                    {
                        Caption = 'Maximum lines shown';
                        ToolTip = 'Specifies how many lines are returned for review';
                        Width = 4;

                        trigger OnValidate()

                        begin
                            RefreshData();
                        end;
                    }

                }
            }



            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    Caption = 'Document';
                    ToolTip = 'Specifies the value of the Document No. field.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        RecordManagement: Codeunit "Page Management";

                    begin

                        RecordManagement.PageRun(Rec.DrillDownRecordId);

                    end;
                }
                field("Document Type"; Rec."Document Type")
                {
                    Caption = 'Type';
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Customer/Vendor No."; Rec."Customer/Vendor No.")
                {
                    Visible = not _FilterByRelationship;

                    TableRelation = Customer;
                    ToolTip = 'Show customer number where filter is set to generic';

                }
                field("Document Date"; Rec."Document Date")
                {
                    Caption = 'Date';
                    ToolTip = 'Specifies the value of the Document Date field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Caption = 'UoM';
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the value of the Unit Price field.';
                }
                field("Unit Discount Amount"; Rec."Unit Discount Amount")
                {
                    Caption = 'Discount';
                    ToolTip = 'Specifies the value of the Unit Discount Amount field.';
                    StyleExpr = _StyleExpression;

                }
                field("Unit Price After Discount"; Rec."Unit Price After Discount")
                {
                    Caption = 'Price After Disc.';
                    ToolTip = 'Specifies the value of the Unit Price After Discount field.';
                }
                field("Price Unit Price"; Rec."Price Unit Price")
                {
                    Caption = 'Per Kg Price';
                    ToolTip = 'Specifies the value of the Price Unit Price field.';
                }
                field("Price Unit Discount Amount"; Rec."Price Unit Discount Amount")
                {
                    Caption = 'Per Kg Discount';
                    ToolTip = 'Specifies the value of the Price Unit Discount Amount field.';
                }
                field("Price Unit After Discount"; Rec."Price Unit After Discount")
                {
                    Caption = 'Per Kg Price After Disc.';
                    ToolTip = 'Specifies the value of the Price Unit After Discount field.';
                    StyleExpr = _StyleExpression;
                }
                field("Price Group"; Rec."Price Group")
                {
                    ToolTip = 'Specifies the value of the Price Group field.';

                }
            }
        }
    }

    actions
    {

    }

    var
        _CalledByRecordId: Recordid;
        _LinePrice: Decimal;
        _LinePriceGroup: Code[10];
        _RelationshipName: Text[100];
        _RelationshipCode: Code[20];
        _LineDiscount: Decimal;
        _ItemName: Text[100];
        _ItemNo: Code[20];

        _FilterByRelationship: Boolean;
        _FilterByPriceGroup: Boolean;

        _MaxNoEntries: Integer;
        _RelationshipType: Enum "TFB Last Prices Rel. Type";

    procedure SetPopulatedData(var PopulatedRecord: Record "TFB Last Prices")

    begin

        Rec.Reset();
        Rec.DeleteAll();
        if PopulatedRecord.FindSet() then
            repeat
                Rec.Init();
                Rec := PopulatedRecord;
                Rec.Insert();
            until PopulatedRecord.Next() = 0;

    end;

    procedure RefreshData()

    var
        TempLastPrices: Record "TFB Last Prices" temporary;
        LastPricesCU: CodeUnit "TFB Last Prices";
    begin
        LastPricesCU.PopulateLastPrices(_RelationshipType, _RelationshipCode, _ItemNo, _MaxNoEntries, _CalledByRecordId, _FilterByRelationship, _FilterByPriceGroup, _LinePriceGroup);
        LastPricesCU.GetLastPrices(TempLastPrices);
        SetPopulatedData(TempLastPrices);
        Rec.SetCurrentKey("Document Date");
        Rec.Ascending(false);
        Rec.SetAscending("Document Date", false);

    end;

    procedure AddContext(RelationshipType: Enum "TFB Last Prices Rel. Type"; ContextLine: RecordRef)
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";

    begin
        _MaxNoEntries := 10;
        _FilterByRelationship := true;
        _FilterByPriceGroup := true;

        case ContextLine.Number of
            Database::"Sales Line":
                begin
                    _RelationshipType := _RelationshipType::Customer;
                    SalesHeader.SetLoadFields("Sell-to Customer Name");
                    ContextLine.SetTable(SalesLine);
                    SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
                    _RelationshipName := SalesHeader."Sell-to Customer Name";
                    _LinePrice := SalesLine."Unit Price";
                    _LineDiscount := SalesLine."Line Discount Amount" / SalesLine.Quantity;
                    _LinePriceGroup := SalesLine."Customer Price Group";
                    _ItemName := SalesLine.Description;
                    _RelationshipCode := SalesLine."Sell-to Customer No.";
                    _ItemNo := SalesLine."No.";
                    _CalledByRecordId := SalesHeader.RecordId;
                end;
            Database::"Purchase Line":
                begin
                    ContextLine.SetTable(PurchaseLine);
                    PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
                    _RelationshipName := PurchaseHeader."Buy-from Vendor Name";
                    _LinePrice := PurchaseLine."Unit Cost";
                    _LineDiscount := PurchaseLine."Line Discount Amount" / PurchaseLine.Quantity;
                    _LinePriceGroup := '';
                    _ItemName := PurchaseLine.Description;
                    _RelationshipCode := PurchaseLine."Buy-from Vendor No.";
                    _ItemNo := PurchaseLine."No.";
                    _CalledByRecordId := PurchaseHeader.RecordId;
                    _RelationshipType := _RelationshipType::Vendor;
                end;

        end;



    end;

    var


        _StyleExpression: text;

    trigger OnAfterGetCurrRecord()

    begin

        if rec."Unit Price After Discount" > (_LinePrice - _LineDiscount) then
            _StyleExpression := 'Unfavourable'
        else
            if
           rec."Unit Price After Discount" < (_LinePrice - _LineDiscount) then
                _StyleExpression := 'Favourable'
            else
                _StyleExpression := 'None';

    end;

}
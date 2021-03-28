page 50142 "TFB Price List Line Factbox"
{
    PageType = CardPart;
    SourceTable = "Price List Line";

    layout
    {
        area(Content)
        {
            group(CostingDetails)
            {
                ShowCaption = false;
                Caption = 'General';
                field(costingExists; _costingExists)
                {
                    ApplicationArea = all;
                    Caption = 'Costing exists';
                }
                field(costingPrice; _costingPrice)
                {
                    ApplicationArea = all;
                    Caption = 'Last cost price';
                    //Style = Favorable;
                    //StyleExpr = _costingPrice = rec."Unit Price";

                    trigger OnDrillDown()

                    var
                        ItemCosting: Record "TFB Item Costing";
                        ItemCostingPage: Page "TFB Item Costing";

                    begin

                        ItemCosting.SetRange("Item No.", costingLine."Item No.");
                        ItemCosting.SetRange("Costing Type", costingLine."Costing Type");
                        ItemCosting.SetRange("Effective Date", costingLine."Effective Date");

                        If not ItemCosting.FindFirst() then exit;

                        ItemCostingPage.SetRecord(ItemCosting);
                        ItemCostingPage.Run();

                    end;
                }

                field(costingPricePerKg; _costingPricePerKg)
                {
                    ApplicationArea = all;
                    Caption = 'Last cost price per kg';
                    //Style = Favorable;
                    //StyleExpr = _costingPrice = rec."Unit Price";
                }
                field(costingLastUpdate; _costingLastChangeDate)
                {
                    ApplicationArea = all;
                    Caption = 'Date costing last updated';
                }
                field(lastPriceChange; _lastPrice)
                {
                    ApplicationArea = all;
                    Caption = 'Last price';

                    trigger OnDrillDown()

                    var
                        PriceList: Record "Price List Header";
                    begin

                        If not PriceList.Get(pricelistline."Price List Code") then exit;

                        Page.Run(Page::"Sales Price List", PriceList);
                    end;
                }
                field(lastPriceChangePerKg; _lastPricePerKg)
                {
                    ApplicationArea = all;
                    Caption = 'Last price per kg';


                }
                field(lastPriceChangeDate; _lastPriceChangeDate)
                {
                    ApplicationArea = all;
                    Caption = 'Last date price changed';
                }


            }
        }
    }



    trigger OnAfterGetRecord()

    begin
        If PriceListCU.FindLastPriceChange(rec, pricelistline) then begin

            _lastPrice := pricelistline."Unit Price";
            _lastPriceChangeDate := pricelistline."Ending Date";
            _lastPricePerKg := GetPerKgPrice(_lastPrice);
        end
        else begin
            _lastPrice := 0;
            _lastPricePerKg := 0;
            _lastPriceChangeDate := 0D;
        end;

        If PriceListCU.FindMatchingCosting(rec, costingLine) then begin
            _costingExists := true;
            _costingLastChangeDate := DT2Date(costingLine.SystemModifiedAt);
            _costingPrice := costingLine."Price (Base)";
            _costingPricePerKg := GetPerKgPrice(_costingPrice);
        end
        else begin
            _costingExists := false;
            _costingLastChangeDate := 0D;
            _costingPricePerKg := 0;
            _costingPrice := 0;
        end;

    end;

    local procedure GetPerKgPrice(UnitPrice: Decimal): Decimal

    var
        Item: Record Item;

    begin

        If not (Rec."Asset Type" = Rec."Asset Type"::Item) then exit;
        if not Item.Get(Rec."Asset No.") then exit;
        If not (Item."Net Weight" > 0) then exit;
        Exit(PricingCU.CalcPerKgFromUnit(Rec."Unit Price", Item."Net Weight"));

    end;

    var
        PriceListCU: codeunit "TFB Price List Mgmt";
        PricingCU: codeunit "TFB Pricing Calculations";
        pricelistline: record "Price List Line";
        costingLine: record "TFB Item Costing Lines";


        _costingExists: Boolean;
        _costingPrice: Decimal;
        _costingLastChangeDate: Date;
        _lastPrice: Decimal;
        _lastPriceChangeDate: Date;
        _costingPricePerKg: Decimal;
        _lastPricePerKg: Decimal;
}
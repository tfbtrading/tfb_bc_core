page 50143 "TFB Purch. Price List Factbox"
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
                    //StyleExpr = _costingPrice = rec."Direct Unit Cost";

                    trigger OnDrillDown()

                    var

                        ItemCostingPage: Page "TFB Item Costing";

                    begin

                        If not costing.IsEmpty then begin

                            ItemCostingPage.SetRecord(costing);
                            ItemCostingPage.Run();
                        end
                    end;
                }
                field(costingpriceunit; _VendorPriceUnit)
                {
                    ApplicationArea = All;
                    Caption = 'Costing pricing unit';
                }

                field(costingPricePerUnit; _costingPrice)
                {
                    ApplicationArea = all;
                    Caption = 'Last cost price per unit';
                   // Style = Favorable;
                   // StyleExpr = _costingPrice = rec."Unit Price";
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

                        Page.Run(Page::"Purchase Price List", PriceList);
                    end;
                }
                field(lastPriceChangePerPriceUnit; _lastPricePerPriceUnit)
                {
                    ApplicationArea = all;
                    Caption = 'Last price per price unit';
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
        GetPriceUnitForVendor();
        If PriceListCU.FindLastPriceChange(rec, pricelistline) then begin

            _lastPrice := pricelistline."Unit Price";
            _lastPriceChangeDate := pricelistline."Ending Date";
            _lastPricePerPriceUnit := GetPerPriceUnitPrice(_lastPrice);
        end
        else begin
            _lastPrice := 0;
            _lastPricePerPriceUnit := 0;
            _lastPriceChangeDate := 0D;
        end;

        If PriceListCU.FindMatchingCosting(rec, costing) then begin
            _costingExists := true;
            _costingLastChangeDate := DT2Date(costing.SystemModifiedAt);
            _costingPrice := PricingCU.CalculateUnitPriceByPriceUnit(Rec."Asset No.", Rec."Unit of Measure Code", _VendorPriceUnit, costing."Average Cost");
            _costingPricePerPriceUnit := costing."Average Cost";
        end
        else begin
            _costingExists := false;
            _costingLastChangeDate := 0D;
            _costingPricePerPriceUnit := 0;
            _costingPrice := 0;
        end;

    end;

    local procedure GetPriceUnitForVendor()

    var
        Vendor: Record Vendor;

    begin

        If not (Rec."Source Type" = Rec."Source Type"::Vendor) then exit;

        If Vendor.Get(Rec."Source No.") then
            _VendorPriceUnit := Vendor."TFB Vendor Price Unit"
        else
            _VendorPriceUnit := _VendorPriceUnit::UNIT;


    end;

    local procedure GetPerPriceUnitPrice(UnitPrice: Decimal): Decimal

    var
        Item: Record Item;

    begin

        If not (Rec."Asset Type" = Rec."Asset Type"::Item) then exit;
        if not Item.Get(Rec."Asset No.") then exit;
        If not (Item."Net Weight" > 0) then exit;
        Exit(PricingCU.CalculatePriceUnitByUnitPrice(Rec."Asset No.", Rec."Unit of Measure Code", _VendorPriceUnit, Rec."Direct Unit Cost"));

    end;

    var
        PriceListCU: codeunit "TFB Price List Mgmt";
        PricingCU: codeunit "TFB Pricing Calculations";
        pricelistline: record "Price List Line";
        costing: record "TFB Item Costing";

        _VendorPriceUnit: Enum "TFB Price Unit";


        _costingExists: Boolean;
        _costingPrice: Decimal;
        _costingLastChangeDate: Date;
        _lastPrice: Decimal;
        _lastPriceChangeDate: Date;
        _costingPricePerPriceUnit: Decimal;
        _lastPricePerPriceUnit: Decimal;
}
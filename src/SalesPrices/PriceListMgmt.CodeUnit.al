codeunit 50114 "TFB Price List Mgmt"
{
    trigger OnRun()
    begin

    end;

    /// <summary>
    /// Find last price change takes a price list item and uses those values to search for a new price list item;
    /// </summary>
    /// <param name="PriceListLine">Record "Price List Line".</param>
    /// <param name="PreviousPriceListLine">VAR Record "Price List Line".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure FindLastPriceChange(PriceListLine: Record "Price List Line"; var PreviousPriceListLine: Record "Price List Line"): Boolean

    var
        NewPriceListLines: record "Price List Line";
        PriceListHeader: record "Price List Header";

        breakline: Boolean;

    begin

        NewPriceListLines.SetCurrentKey("Ending Date", "Asset Type");
        NewPriceListLines.SetAscending("Ending Date", false);
        NewPriceListLines.SetRange("Asset No.", PriceListLine."Asset No.");
        NewPriceListLines.SetRange("Price Type", PriceListLine."Price Type");
        NewPriceListLines.SetRange("Asset Type", PriceListLine."Asset Type");
        NewPriceListLines.SetRange("Source Type", PriceListLine."Source Type");
        NewPriceListLines.SetRange("Source No.", PriceListLine."Source No.");
        NewPriceListLines.SetRange("Unit of Measure Code", PriceListLine."Unit of Measure Code");
        NewPriceListLines.SetFilter("Ending Date", '..%1', PriceListLine."Starting Date");



        If NewPriceListLines.FindSet(false, false) then
            repeat begin

                If NewPriceListLines."Unit Price" <> PriceListLine."Unit Price" then
                    If PriceListHeader.get(NewPriceListLines."Price List Code") then
                        If not (PriceListHeader.Status = PriceListHeader.Status::Draft) then begin
                            PreviousPriceListLine := NewPriceListLines;
                            exit(true);
                        end;

            end until (NewPriceListLines.Next() = 0) or breakline;

    end;

    internal procedure FindMatchingCosting(PriceListLine: Record "Price List Line"; var ItemCosting: record "TFB Item Costing"): Boolean

    var
        FindItemCosting: Record "TFB Item Costing";

    begin
        FindItemCosting.SetRange("Item No.", PriceListLine."Asset No.");
        FindItemCosting.SetRange(Current, true);
        FindItemCosting.SetRange("Costing Type", FindItemCosting."Costing Type"::Standard);

        If FindItemCosting.FindFirst() then begin
            ItemCosting := FindItemCosting;
            Exit(true);
        end;


    end;

    internal procedure FindMatchingCosting(PriceListLine: Record "Price List Line"; var NewItemCostingLine: record "TFB Item Costing Lines"): Boolean
    var

        PostCodeZone: Record "TFB Postcode Zone";
        //SalesPrices: Record "Sales Price";

        PriceListHeader: Record "Price List Header";

        // SalesPriceWksh: Record "Sales Price Worksheet";
        CostingSetup: Record "TFB Costings Setup";
        TargetCustomerGroup: Code[20];
        TargetPostcodeZone: Code[20];
        ExistingPrice: Boolean;
        CustomerGroup: Boolean;
        ExWarehousePricing: Boolean;
        LineNo: Integer;
        ItemCostingLines: record "TFB Item Costing Lines";


    begin

        If not PriceListHeader.Get(PriceListLine."Price List Code") then exit;
        case PriceListHeader."Price Type" of
            PriceListHeader."Price Type"::Sale:
                begin
                    If not (PriceListHeader."Source Type" = PriceListHeader."Source Type"::"Customer Price Group") then exit;

                    PostCodeZone.SetRange("Customer Price Group", PriceListHeader."Source No.");
                    IF PostCodeZone.FindFirst() then
                        //Get the correct customer group mapping for the postcode zone
                        TargetPostcodeZone := PostCodeZone.Code
                    else
                        Exit;


                    If CostingSetup.Get() then
                        If CostingSetup.ExWarehouseEnabled then
                            if CostingSetup.ExWarehousePricingGroup = PriceListHeader."Source No." then
                                ExWarehousePricing := true;


                    ItemCostingLines.Reset();
                    ItemCostingLines.SetRange(Current, true);


                    If ExWarehousePricing then begin
                        ItemCostingLines.SetRange("Line Type", ItemCostingLines."Line Type"::EXP);
                        ItemCostingLines.SetRange("Line Key", '-');
                    end
                    else begin
                        ItemCostingLines.SetRange("Line Type", ItemCostingLines."Line Type"::DZP);
                        ItemCostingLines.SetRange("Line Key", TargetPostcodeZone);
                    end;
                    ItemCostingLines.SetRange("Costing Type", ItemCostingLines."Costing Type"::Standard);
                    ItemCostingLines.SetRange("Item No.", PriceListLine."Asset No.");
                end;

            PriceListHeader."Price Type"::Purchase:
                begin
                    exit;
                end;

        end;



        if ItemCostingLines.FindFirst() then begin
            NewItemCostingLine := ItemCostingLines;
            exit(true);
        end;
    end;


}
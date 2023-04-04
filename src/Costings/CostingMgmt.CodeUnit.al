codeunit 50304 "TFB Costing Mgmt"
{




    /// <summary>
    /// Update costing details run through all item costs and ensure costing lines reflect the latest profile details
    /// </summary>
    /// <param name="UpdateExchRate">Boolean.</param>
    /// <param name="UpdateMargins">Boolean.</param>
    /// <param name="UpdatePrices">Boolean.</param>
    procedure UpdateCurrentCostingsDetails(UpdateExchRate: Boolean; UpdateMargins: Boolean; UpdatePrices: Boolean)
    var

        //Price 
        LCProfile: Record "TFB Landed Cost Profile";
        LCScenario: Record "TFB Costing Scenario";
        ItemCost: Record "TFB Item Costing";

    begin

        if UpdateExchRate then
            if LCProfile.FindSet(true, false) then
                repeat

                    LCProfile.CalculateCosts();

                until LCProfile.Next() < 1;


        ItemCost.SetRange(Current, true);


        if ItemCost.FindSet(true) then
            repeat
                If LCProfile.get(ItemCost."Landed Cost Profile") then begin


                    if LCScenario.get(LCProfile.Scenario) then
                        if UpdateExchRate and not ItemCost."Fix Exch. Rate" then
                            ItemCost."Exch. Rate" := LCScenario."Exchange Rate";
                    If UpdateMargins then begin
                        ItemCost."Market Price Margin %" := LCScenario."Market Price Margin %";
                        ItemCost."Pricing Margin %" := LCScenario."Pricing Margin %";
                        ItemCost."Full Load Margin %" := LCScenario."Full Load Margin %";
                    end;
                end;


                ItemCost.Modify();
                ItemCost.CalcCostings(ItemCost);

            until ItemCost.Next() < 1;
    end;

    procedure GetCurrPricePerKg(Item: Record Item): Decimal;

    var
        CoreSetup: Record "TFB Core Setup";
        PriceListLine: Record "Price List Line";
        PCE: CodeUnit "TFB Pricing Calculations";

    begin

        CoreSetup.Get();

        If CoreSetup."Def. Customer Price Group" <> '' then begin

            PriceListLine.SetRange("Asset ID", Item.SystemId);
            PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
            PriceListLine.SetRange("Source Type", PriceListLine."Source Type"::"Customer Price Group");
            PriceListLine.SetRange("Source No.", CoreSetup."Def. Customer Price Group");
            PriceListLine.SetRange("Ending Date", 0D);
            PriceListLine.SetRange(Status, PriceListLine.Status::Active);

            If PriceListLine.FindLast() then
                Exit(PCE.CalcPerKgFromUnit(PriceListLine."Unit Price", Item."Net Weight"));

        end;
    end;



    procedure GetLastPurchasePrice(Item: Record Item; Costing: Record "TFB Item Costing"): Decimal

    var
        PR: Record "Purch. Rcpt. Line";
        PCE: CodeUnit "TFB Pricing Calculations";

    begin

        PR.SetRange("No.", Item."No.");
        PR.SetCurrentKey("Posting Date");
        PR.SetAscending("Posting Date", false);

        If PR.FindFirst() then
            Exit(PCE.CalculatePriceUnitByUnitPrice(Item."No.", PR."Unit of Measure Code", Costing."Purchase Price Unit", PR."Unit Cost"))
        else
            Exit(0);

    end;

    procedure GetNextPurchasePrice(Item: Record Item; Costing: Record "TFB Item Costing"): Decimal

    var
        PurchaseLine: Record "Purchase Line";
        PricingCalculations: CodeUnit "TFB Pricing Calculations";

    begin

        PurchaseLine.SetRange("No.", Item."No.");
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetFilter("Outstanding Qty. (Base)", '>0');
        PurchaseLine.SetCurrentKey("Expected Receipt Date");
        PurchaseLine.SetAscending("Expected Receipt Date", true);

        If PurchaseLine.FindFirst() then
            Exit(PricingCalculations.CalculatePriceUnitByUnitPrice(Item."No.", PurchaseLine."Unit of Measure Code", Costing."Purchase Price Unit", PurchaseLine."Unit Cost"))
        else
            Exit(0);

    end;

    procedure GetCurrentItemCost(Item: Record Item; Costing: Record "TFB Item Costing"): Decimal

    var
        PricingCalculations: CodeUnit "TFB Pricing Calculations";
    begin
        Exit(PricingCalculations.CalculatePriceUnitByUnitPrice(Item."No.", Item."Base Unit of Measure", Costing."Purchase Price Unit", Item."Unit Cost"));
    end;







    local procedure CheckValidRecords(Header: record "TFB Item Costing"; var Item: Record Item; var Vendor: Record Vendor; var LCProfile: Record "TFB Landed Cost Profile"): Boolean

    begin

        Exit(item.get(Header."Item No.") and Vendor.get(Header."Vendor No.") and LCProfile.get(Header."Landed Cost Profile"));

    end;

    procedure GenerateCostingLines(var Header: record "TFB Item Costing"): Boolean

    var
        //Records
        Item: Record Item;
        Vendor: Record Vendor;
        Lines: Record "TFB Item Costing Lines";
        LCProfile: Record "TFB Landed Cost Profile";
        Scenario: Record "TFB Costing Scenario";
        PostCodeZoneRate: Record "TFB Postcode Zone Rate";
        CoreSetup: Record "TFB Core Setup";


        //CodeUnits
        CommonCU: Codeunit "TFB Common Library";

        //Variables
        ItemWeight: Decimal;
        Palletweight: Decimal;
        ExchRate: Decimal;
        EffectiveIR: Decimal;
        DaysStored: Decimal;
        StorageCost: Decimal;
        HandlingCost: Decimal;
        DeliveryCost: Decimal;
        CalcBaseDesc: TextBuilder;


        i: Integer;
        j: Integer;

        //Array - 1 = Pallet Based, 2 = Direct Container Delivered
        LCUnitCostLCY: Array[2] of Decimal;
        ACUnitCostLCY: Array[2] of Decimal;


        //Array - 1 = Average cost - 2 = Market Cost
        UnitCost: Array[2] of Decimal;
        UnitCostLCY: Array[2] of Decimal;
        UnitFinanceCost: Array[2] of Decimal;

        PriceWithDuty: Array[2] of Decimal;
        DutyMultiplier: Decimal;


        //Array - 2 dimension - First Average/Market and second Pallet/Direct Container
        TotalLCUnitCostLCY: Array[2, 2] of Decimal;
        TotalUnitCostLCY: Array[2, 2] of Decimal;
        TotalUnitSalesPriceLCY: Array[2, 2] of Decimal;
        TotalUnitSalesPriceRndLCY: Array[2, 2] of Decimal;
        TotalUnitSalesPriceDelRndLCY: Array[2, 2] of Decimal;

    begin

        //Get default details and exit with false if details missing

        CoreSetup.Get();
        If not CheckValidRecords(Header, Item, Vendor, LCProfile) then exit(false);


        ItemWeight := item."Net Weight";
        PalletWeight := ItemWeight * Header."Pallet Qty";


        If not (Vendor."Currency Code" = '') then
            ExchRate := Header."Exch. Rate"
        else
            ExchRate := 1;


        CalcBaseDesc.Append(StrSubstNo('Pallet weight is %1, Item Weight is %2, Exch rate is %3', PalletWeight, ItemWeight, ExchRate));


        //Get correct scenario - adjusting for if it has been overriden in the item costing
        If Header."Scenario Override" <> '' then
            Scenario.Get(Header."Scenario Override")
        else
            Scenario.Get(LCProfile.Scenario);

        If Scenario.IsEmpty() then Exit(false);

        if not Header.Dropship then begin



            //Add landed cost
            LCUnitCostLCY[1] := LCProfile.CalculateUnitCostStandard(ItemWeight, LCProfile.Pallets, ExchRate, Scenario, false, CalcBaseDesc);
            LCUnitCostLCY[2] := LCProfile.CalculateUnitCostStandard(ItemWeight, LCProfile.Pallets, ExchRate, Scenario, true, CalcBaseDesc);

            //Calculate storage costs
            DaysStored := CommonCU.ConvertDurationToDays(Header."Est. Storage Duration");
            StorageCost := (Round((DaysStored / 7), 1.0, '>') * Scenario.Storage) / header."Pallet Qty";

            CalcBaseDesc.AppendLine(StrSubstNo('Additional Storage Cost %1', StorageCost));
            //Calculate handling charges prior to dispatch and delivery
            HandlingCost := (Scenario."Pallet Out Charge" + Scenario."Order Handling" + Scenario.Labelling) / header."Pallet Qty";

            CalcBaseDesc.AppendLine(StrSubstNo('Additional OutBound Handling %1', handlingCost));

            ACUnitCostLCY[1] := StorageCost + HandlingCost;

        end;

        If LCProfile."Import Duties Charged" then
            DutyMultiplier := 1 + CoreSetup."Import Duty Rate"
        else
            DutyMultiplier := 1;


        PriceWithDuty[1] := Header."Average Cost" * DutyMultiplier;
        PriceWithDuty[2] := Header."Market Price" * DutyMultiplier;

        //Calculate unit cost for both average and market price with duty multiplier

        For i := 1 to 2 do begin
            UnitCost[i] := PricingCU.CalculateUnitPriceByPriceUnit(Item."No.", Item."Base Unit of Measure", Header."Purchase Price Unit", PriceWithDuty[i]);
            UnitCostLCY[i] := UnitCost[i] / ExchRate;
        end;


        //Calculate effective finance costs 

        EffectiveIR := CommonCU.CalcEffectiveIR(Scenario."Finance Rate", Header."Days Financed");
        If LCProfile.Financed then
            for i := 1 to 2 do
                UnitFinanceCost[i] := EffectiveIR * UnitCostLCY[i];

        //calculate total costs - multiple dimensions - first cost/market and then container/pallet
        //Add margins to total cost for products

        For i := 1 to 2 do
            for j := 1 to 2 do begin
                TotalLCUnitCostLCY[i, j] := UnitCostLCY[i] + LCUnitCostLCY[j];
                TotalUnitCostLCY[i, j] := TotalLCUnitCostLCY[i, j] + UnitFinanceCost[i] + ACUnitCostLCY[j];

                If (j = 1) then //Pallet pricing
                    if (i = 1) then //Average Cost pricing
                        TotalUnitSalesPriceLCY[i, j] := AddMargin(Header."Pricing Margin %", TotalUnitCostLCY[i, j])
                    else //Market Price pricing
                        TotalUnitSalesPriceLCY[i, j] := AddMargin(Header."Market Price Margin %", TotalUnitCostLCY[i, j])
                else //Container direct
                    if (i = 1) then //Average Cost pricing
                        TotalUnitSalesPriceLCY[i, j] := RemoveDiscount(Header."Full Load Margin %", AddMargin(Header."Pricing Margin %", TotalUnitCostLCY[i, j]))
                    else //Market Price pricing
                        TotalUnitSalesPriceLCY[i, j] := RemoveDiscount(Header."Full Load Margin %", AddMargin(Header."Market Price Margin %", TotalUnitCostLCY[i, j]));

                //Now calculate rounded unit price, first converting to kilograms,rounding and then base for even division
                TotalUnitSalesPriceRndLCY[i, j] := Round(PricingCU.CalcUnitFromPerKg(Round(PricingCU.CalcPerKgFromUnit(TotalUnitSalesPriceLCY[i, j], ItemWeight), 0.02, '>'), ItemWeight), 0.01, '=');


            end;

        //clear item costing lines

        Lines.SetRange("Item No.", Header."Item No.");
        Lines.SetRange("Costing Type", Header."Costing Type");
        Lines.SetRange("Effective Date", Header."Effective Date");
        Lines.DeleteAll();

        //Generate costing line items

        //Generate total landed cost line
        Lines.Init();
        Lines."Item No." := Header."Item No.";
        Lines.Description := Item.Description;
        Lines."Costing Type" := Header."Costing Type";
        Lines."Effective Date" := Header."Effective Date";
        Lines."Line Type" := Lines."Line Type"::TLC;
        Lines."Line Key" := '-';
        Lines."Price (Base)" := TotalLCUnitCostLCY[1, 1];
        Lines."Price Per Weight Unit" := PricingCU.CalcPerKgFromUnit(TotalLCUnitCostLCY[1, 1], ItemWeight);
        Lines."Market Price (Base)" := TotalLCUnitCostLCY[2, 1];
        Lines."Market price Per Weight Unit" := PricingCU.CalcPerKgFromUnit(TotalLCUnitCostLCY[2, 1], ItemWeight);
        Lines.CalcDesc := CopyStr(CalcBaseDesc.ToText(), 1, 2048);
        Lines.Insert();

        //Generate total costs including outbound handling

        Lines.Init();
        Lines."Item No." := Header."Item No.";
        Lines.Description := Item.Description;
        Lines."Costing Type" := Header."Costing Type";
        Lines."Effective Date" := Header."Effective Date";
        Lines."Line Type" := Lines."Line Type"::TCG;
        Lines."Line Key" := '-';
        Lines."Price (Base)" := TotalUnitCostLCY[1, 1];
        Lines."Price Per Weight Unit" := PricingCU.CalcPerKgFromUnit(TotalUnitCostLCY[1, 1], ItemWeight);
        Lines."Market Price (Base)" := TotalUnitCostLCY[2, 1];
        Lines."Market price Per Weight Unit" := PricingCU.CalcPerKgFromUnit(TotalUnitCostLCY[2, 1], ItemWeight);
        Lines.CalcDesc := CopyStr(CalcBaseDesc.ToText(), 1, 2048);
        Lines.Insert();

        //Generate total direct container / semi-load pricing

        Lines.Init();
        Lines."Item No." := Header."Item No.";
        Lines.Description := Item.Description;
        Lines."Costing Type" := Header."Costing Type";
        Lines."Effective Date" := Header."Effective Date";
        Lines."Line Type" := Lines."Line Type"::DCP;
        Lines."Line Key" := '-';
        Lines."Price (Base)" := TotalUnitSalesPriceRndLCY[1, 2];
        Lines."Price Per Weight Unit" := PricingCU.CalcPerKgFromUnit(TotalUnitSalesPriceRndLCY[1, 2], ItemWeight);
        Lines."Market Price (Base)" := TotalUnitSalesPriceRndLCY[2, 2];
        Lines."Market price Per Weight Unit" := PricingCU.CalcPerKgFromUnit(TotalUnitSalesPriceRndLCY[2, 2], ItemWeight);
        Lines.Insert();

        //Generate ex-warehouse pricing

        Lines.Init();
        Lines."Item No." := Header."Item No.";
        Lines.Description := Item.Description;
        Lines."Costing Type" := Header."Costing Type";
        Lines."Effective Date" := Header."Effective Date";
        Lines."Line Type" := Lines."Line Type"::EXP;
        Lines."Line Key" := '-';
        Lines."Price (Base)" := TotalUnitSalesPriceRndLCY[1, 1];
        Lines."Price Per Weight Unit" := PricingCU.CalcPerKgFromUnit(TotalUnitSalesPriceRndLCY[1, 1], ItemWeight);
        Lines."Market Price (Base)" := TotalUnitSalesPriceRndLCY[2, 1];
        Lines."Market price Per Weight Unit" := PricingCU.CalcPerKgFromUnit(TotalUnitSalesPriceRndLCY[2, 1], ItemWeight);

        Lines.Insert();

        //Generate lines for each postal code zone area

        PostCodeZoneRate.SetRange("Costing Scenario Code", Scenario.Code);

        if PostCodeZoneRate.FindSet() then
            repeat

                If not Header.Dropship then begin

                    //Calculate out delivered pricing for zone
                    DeliveryCost := RoundByPerKgForUnit((PostCodeZoneRate."Total Charge") / Header."Pallet Qty", ItemWeight);
                    For i := 1 to 2 do
                        for j := 1 to 2 do
                            TotalUnitSalesPriceDelRndLCY[i, j] := TotalUnitSalesPriceRndLCY[i, j] + DeliveryCost;

                end else begin

                    DeliveryCost := PricingCU.GetVendorZoneRate(Header."Vendor No.", Item."No.", PostCodeZoneRate."Zone Code");

                    For i := 1 to 2 do
                        for j := 1 to 2 do
                            TotalUnitSalesPriceDelRndLCY[i, j] := TotalUnitSalesPriceRndLCY[i, j] + DeliveryCost;

                end;

                Lines.Init();

                Lines."Item No." := Header."Item No.";
                Lines.Description := Item.Description;
                Lines."Costing Type" := Header."Costing Type";
                Lines."Effective Date" := Header."Effective Date";
                Lines."Line Type" := Lines."Line Type"::DZP;
                Lines."Line Key" := PostCodeZoneRate."Zone Code";
                Lines."Price (Base)" := TotalUnitSalesPriceDelRndLCY[1, 1];
                Lines."Price Per Weight Unit" := PricingCU.CalcPerKgFromUnit(TotalUnitSalesPriceDelRndLCY[1, 1], ItemWeight);
                Lines."Market Price (Base)" := TotalUnitSalesPriceDelRndLCY[2, 1];
                Lines."Market price Per Weight Unit" := PricingCU.CalcPerKgFromUnit(TotalUnitSalesPriceDelRndLCY[2, 1], ItemWeight);

                Lines.Insert()


            until PostCodeZoneRate.Next() < 1;

    end;


    procedure CheckAndObseleteOldRecords(var Header: record "TFB Item Costing")

    var
        OldItemCostings: Record "TFB Item Costing";

    begin
        //Switch any old costings to be non-current if current costing is current

        If (Header.Current) and (Header."Effective Date" > 0D) then begin
            OldItemCostings.Init();

            OldItemCostings.SetRange("Item No.", Header."Item No.");
            OldItemCostings.SetRange("Costing Type", Header."Costing Type");

            if OldItemCostings.FindSet(true) then
                repeat

                    if OldItemCostings."Effective Date" < Header."Effective Date" then begin
                        OldItemCostings.Current := false;
                        OldItemCostings.Modify();
                    end;

                until OldItemCostings.Next() < 1;
        end;
    end;

    local procedure CopyToWorksheetLine(ToPriceListLine: Record "Price List Line"; FromPriceListLine: Record "Price List Line"; CreateNewLine: Boolean)
    var
        PriceWorksheetLine: Record "Price Worksheet Line";
    begin
        PriceWorksheetLine.TransferFields(ToPriceListLine);
        PriceWorksheetLine."Existing Unit Price" := FromPriceListLine."Unit Price";
        PriceWorksheetLine."Existing Direct Unit Cost" := FromPriceListLine."Direct Unit Cost";
        PriceWorksheetLine."Existing Unit Cost" := FromPriceListLine."Unit Cost";
        PriceWorksheetLine.Validate("Existing Line", not CreateNewLine);
        PriceWorksheetLine.Insert(true);
    end;

    local procedure CopyToWorksheetLine(ToPriceListLine: Record "Price List Line")
    var
        PriceWorksheetLine: Record "Price Worksheet Line";
    begin
        PriceWorksheetLine.TransferFields(ToPriceListLine);
        PriceWorksheetLine.Validate("Existing Line", false);
        PriceWorksheetLine.Insert(true);
    end;

    internal procedure CopyCurrentCostingToPriceList(var PriceListHeader: Record "Price List Header")



    var
        ItemCostingLines: Record "TFB Item Costing Lines";
        Item: Record Item;
        PostCodeZone: Record "TFB Postcode Zone";
        FromPriceListLine: Record "Price List Line";
        ToPriceListLine: Record "Price List Line";
        CoreSetup: Record "TFB Core Setup";
        PriceAsset: Record "Price Asset";
        DateFormula: DateFormula;
        DayBefore: Date;
        WorkSheet: Boolean;
        ProgressMsg: Label 'Reviewing Items: #1#### @2@@@@', Comment = '%1 = Item No and %2 = Item Description';
        ProgressEXWMsg: Label 'Reviewing ExW: #1#### @2@@@@', Comment = '%1 = Item No and %2 = Item Description';
        ApproxCount: Integer;
        Progress: Dialog;
        Counter: Integer;
        desc: Text;

    begin
        Evaluate(DateFormula, '-1D');
        DayBefore := CalcDate(DateFormula, WorkDate());
        WorkSheet := PriceListHeader.IsTemporary;

        FromPriceListLine.SetRange("Price List Code", PriceListHeader.Code);


        ItemCostingLines.Reset();
        ItemCostingLines.SetRange(Current, true);
        ItemCostingLines.SetRange("Line Type", ItemCostingLines."Line Type"::DZP);
        ItemCostingLines.SetRange("Costing Type", ItemCostingLines."Costing Type"::Standard);
        ApproxCount := ItemCostingLines.CountApprox;
        Progress.Open(ProgressMsg, desc);
        if ItemCostingLines.FindSet() then
            repeat
                Item.Get(ItemCostingLines."Item No.");
                Counter += 1;
                Progress.Update(1, Item.Description);
                Progress.Update(2, Round(Counter / ApproxCount * 10000, 1));

                If not (Item."TFB Publishing Block" and Item.Blocked) then begin  //Ignore price processing changes if 
                    //Check if existing sales price worksheet item exists
                    FromPriceListLine.Reset();
                    FromPriceListLine.SetRange("Price List Code", PriceListHeader.Code);
                    FromPriceListLine.SetRange("Starting Date", System.WorkDate());
                    FromPriceListLine.SetRange("Asset No.", ItemCostingLines."Item No.");
                    FromPriceListLine.SetRange("Asset Type", FromPriceListLine."Asset Type"::Item);
                    FromPriceListLine.SetRange("Source Type", FromPriceListLine."Source Type"::"Customer Price Group");

                    If PostCodeZone.get(ItemCostingLines."Line Key") then

                        //Get the correct customer group mapping for the postcode zone
                        FromPriceListLine.SetRange("Source No.", PostCodeZone."Customer Price Group");

                    If FromPriceListLine.FindFirst() then begin
                        If ItemCostingLines."Price (Base)" <> FromPriceListLine."Unit Price" then begin
                            ToPriceListLine := FromPriceListLine;
                            //Update existing price on sales price worksheet
                            ToPriceListLine.Validate("Unit Price", ItemCostingLines."Price (Base)");
                            ToPriceListLine."Price Includes VAT" := false;

                            If WorkSheet then
                                CopyToWorksheetLine(ToPriceListLine, FromPriceListLine, false)
                            else
                                ToPriceListLine.Modify();
                        end;
                    end

                    else begin

                        //Check first if price is different to existing sales price
                        FromPriceListLine.Reset();
                        FromPriceListLine.SetRange("Price List Code", PriceListHeader.Code);
                        FromPriceListLine.SetRange("Asset No.", ItemCostingLines."Item No.");
                        FromPriceListLine.SetRange("Asset Type", FromPriceListLine."Asset Type"::Item);
                        FromPriceListLine.SetRange("Source Type", FromPriceListLine."Source Type"::"Customer Price Group");
                        FromPriceListLine.SetRange("Source No.", PostCodeZone."Customer Price Group");
                        FromPriceListLine.SetFilter("Unit of Measure Code", '');
                        FromPriceListLine.SetFilter("Ending Date", '');

                        If FromPriceListLine.FindLast() then begin

                            //Check if price is different
                            If ItemCostingLines."Price (Base)" <> FromPriceListLine."Unit Price" then begin

                                PriceAsset."Price Type" := PriceListHeader."Price Type";
                                PriceAsset.Validate("Asset Type", PriceAsset."Asset Type"::Item);
                                PriceAsset.Validate("Asset No.", ItemCostingLines."Item No.");
                                PriceAsset.Validate("Unit of Measure Code", '');


                                If PriceAsset."Asset No." <> '' then
                                    If AddLine(PriceListHeader, FromPriceListLine, PriceAsset, ItemCostingLines, PostCodeZone."Customer Price Group", false) then begin
                                        ToPriceListLine := FromPriceListLine;
                                        ToPriceListLine."Ending Date" := DayBefore;
                                        If WorkSheet then
                                            CopyToWorksheetLine(ToPriceListLine, FromPriceListLine, false)
                                        else
                                            ToPriceListLine.Modify(true);
                                    end;

                            end;
                        end
                        else begin

                            PriceAsset."Price Type" := PriceListHeader."Price Type";
                            PriceAsset.Validate("Asset Type", PriceAsset."Asset Type"::Item);
                            PriceAsset.Validate("Asset No.", ItemCostingLines."Item No.");
                            PriceAsset.Validate("Unit of Measure Code", '');

                            If PriceAsset."Asset No." <> '' then
                                AddLine(PriceListHeader, FromPriceListLine, PriceAsset, ItemCostingLines, PostCodeZone."Customer Price Group", true);

                        end;

                    end
                end;

            until ItemCostingLines.Next() < 1;
        Progress.Close();
        //Process any ex-warehouse line items
        CoreSetup.Get();

        If CoreSetup.ExWarehouseEnabled then
            if CoreSetup.ExWarehousePricingGroup <> '' then begin


                ItemCostingLines.Reset();
                ItemCostingLines.SetRange(Current, true);
                ItemCostingLines.SetRange("Costing Type", ItemCostingLines."Costing Type"::Standard);
                ItemCostingLines.SetRange("Line Type", ItemCostingLines."Line Type"::EXP);
                ItemCostingLines.SetRange("Line Key", '-');
                Progress.Open(ProgressEXWMsg, desc);

                if ItemCostingLines.FindSet() then
                    repeat
                        Item.Get(ItemCostingLines."Item No.");
                        Counter += 1;
                        Progress.Update(1, Item.Description);
                        Progress.Update(2, Round(Counter / ApproxCount * 10000, 1));
                        If not (Item."TFB Publishing Block" and Item.Blocked) then begin
                            FromPriceListLine.Reset();

                            FromPriceListLine.SetRange("Price List Code", PriceListHeader.Code);
                            FromPriceListLine.SetRange("Starting Date", System.WorkDate());
                            FromPriceListLine.SetRange("Asset No.", ItemCostingLines."Item No.");
                            FromPriceListLine.SetRange("Asset Type", FromPriceListLine."Asset Type"::Item);
                            FromPriceListLine.SetRange("Source Type", FromPriceListLine."Source Type"::"Customer Price Group");
                            FromPriceListLine.SetRange("Source No.", CoreSetup.ExWarehousePricingGroup);

                            If FromPriceListLine.FindFirst() then begin
                                If ItemCostingLines."Price (Base)" <> FromPriceListLine."Unit Price" then begin
                                    ToPriceListLine := FromPriceListLine;
                                    //Update existing price on sales price worksheet as it was found
                                    ToPriceListLine.Validate("Unit Price", ItemCostingLines."Price (Base)");
                                    ToPriceListLine."Price Includes VAT" := false;

                                    If WorkSheet then
                                        CopyToWorksheetLine(ToPriceListLine, FromPriceListLine, false)
                                    else
                                        ToPriceListLine.Modify();
                                end;

                            end
                            else begin
                                FromPriceListLine.Reset();
                                FromPriceListLine.SetRange("Price List Code", PriceListHeader.Code);
                                FromPriceListLine.SetRange("Asset No.", ItemCostingLines."Item No.");
                                FromPriceListLine.SetRange("Asset Type", FromPriceListLine."Asset Type"::Item);
                                FromPriceListLine.SetRange("Source Type", FromPriceListLine."Source Type"::"Customer Price Group");
                                FromPriceListLine.SetRange("Source No.", CoreSetup.ExWarehousePricingGroup);
                                FromPriceListLine.SetFilter("Unit of Measure Code", '');
                                FromPriceListLine.SetFilter("Ending Date", '');


                                If FromPriceListLine.FindLast() then begin

                                    //Check if price is different
                                    If ItemCostingLines."Price (Base)" <> FromPriceListLine."Unit Price" then begin

                                        //Add new item into sales price worksheet
                                        PriceAsset."Price Type" := PriceListHeader."Price Type";
                                        PriceAsset.Validate("Asset Type", PriceAsset."Asset Type"::Item);
                                        PriceAsset.Validate("Asset No.", ItemCostingLines."Item No.");
                                        PriceAsset.Validate("Unit of Measure Code", '');


                                        If PriceAsset."Asset No." <> '' then
                                            If AddLine(PriceListHeader, FromPriceListLine, PriceAsset, ItemCostingLines, CoreSetup.ExWarehousePricingGroup, false) then begin

                                                ToPriceListLine := FromPriceListLine;
                                                ToPriceListLine."Ending Date" := DayBefore;
                                                If WorkSheet then
                                                    CopyToWorksheetLine(ToPriceListLine, FromPriceListLine, false)
                                                else
                                                    ToPriceListLine.Modify(true);
                                            end;

                                    end;
                                end
                                else begin

                                    //No Sales Price Found So Insert

                                    PriceAsset."Price Type" := PriceListHeader."Price Type";
                                    PriceAsset.Validate("Asset Type", PriceAsset."Asset Type"::Item);
                                    PriceAsset.Validate("Asset No.", ItemCostingLines."Item No.");
                                    PriceAsset.Validate("Unit of Measure Code", '');

                                    If PriceAsset."Asset No." <> '' then
                                        AddLine(PriceListHeader, FromPriceListLine, PriceAsset, ItemCostingLines, CoreSetup.ExWarehousePricingGroup, true);
                                end;
                            end;
                        end;
                    until ItemCostingLines.Next() < 1;
                Progress.Close();



            end;
    end;

    local procedure AddLine(var
                                PriceListHeader: Record "Price List Header";
                                FromPriceListLine: Record "Price List Line";
                                PriceAsset: Record "Price Asset";
                                ItemCostingLine: Record "TFB Item Costing Lines";
                                customerPriceGroup: Code[20];
                                NewPricing: Boolean): Boolean
    var
        ToPriceListLine: Record "Price List Line";
    begin

        ToPriceListLine."Price List Code" := PriceListHeader.Code;
        ToPriceListLine."Line No." := 0; // autoincrement
        PriceListHeader."Allow Updating Defaults" := false; // to copy defaults
        ToPriceListLine.CopyFrom(PriceListHeader);
        ToPriceListLine."Amount Type" := "Price Amount Type"::Price;
        ToPriceListLine."Minimum Quantity" := 0;
        ToPriceListLine."Starting Date" := WorkDate();
        ToPriceListLine."Source Type" := ToPriceListLine."Source Type"::"Customer Price Group";
        ToPriceListLine."Source No." := customerPriceGroup;
        ToPriceListLine.CopyFrom(PriceAsset);
        ToPriceListLine.Validate("Unit Price", ItemCostingLine."Price (Base)");

        If PriceListHeader.IsTemporary then
            if NewPricing then
                CopyToWorksheetLine(ToPriceListLine)
            else
                CopyToWorksheetLine(ToPriceListLine, FromPriceListLine, true)
        else
            ToPriceListLine.Insert(true);

        Exit(True)
    end;

    local procedure AddMargin(Margin: Decimal; BaseValue: Decimal): Decimal

    begin
        Exit(BaseValue * (1 + (Margin / 100)));
    end;

    local procedure RemoveDiscount(Discount: Decimal; BaseValue: Decimal): Decimal

    begin
        Exit(BaseValue - (BaseValue * (Discount / 100)));
    end;

    local procedure RoundByPerKgForUnit(UnitPrice: Decimal; ItemWeight: Decimal): Decimal

    begin
        Exit(Round(PricingCU.CalcUnitFromPerKg(Round(PricingCU.CalcPerKgFromUnit(UnitPrice, ItemWeight), 0.02, '>'), ItemWeight), 0.01, '='));
    end;


    //Code Unit 
    var
        PricingCU: CodeUnit "TFB Pricing Calculations";
}
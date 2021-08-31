codeunit 50304 "TFB Costing Mgmt"
{


    [EventSubscriber(ObjectType::Table, Database::"Sales Price", 'OnBeforeNewSalesPriceInsert', '', false, false)]
    local procedure HandleNewSalesPriceInsert(SalesPrice: Record "Sales Price"; var NewSalesPrice: Record "Sales Price")

    var
        Item: Record Item;

        PriceUnit: Enum "TFB Price Unit";
        UoMCode: Code[10];



    begin

        Item.Get(NewSalesPrice."Item No.");
        PriceUnit := PriceUnit::KG;

        If NewSalesPrice."Unit of Measure Code" = '' then
            UoMCode := Item."Base Unit of Measure"
        else
            UoMCode := NewSalesPrice."Unit of Measure Code";


        NewSalesPrice."TFB PriceByWeight" := PricingCU.CalculatePriceUnitByUnitPrice(NewSalesPrice."Item No.", UoMCode, PriceUnit, NewSalesPrice."Unit Price");

    end;

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
        SalesSetup: Record "Sales & Receivables Setup";
        PCE: CodeUnit "TFB Pricing Calculations";
        PriceListLine: Record "Price List Line";

    begin

        SalesSetup.Get();

        If SalesSetup."TFB Def. Customer Price Group" <> '' then begin

            PriceListLine.SetRange("Asset ID", Item.SystemId);
            PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
            PriceListLine.SetRange("Source Type", PriceListLine."Source Type"::"Customer Price Group");
            PriceListLine.SetRange("Source No.", SalesSetup."TFB Def. Customer Price Group");
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



    procedure CopyCurrentCostingToSalesWorkSheet(ItemNo: Code[20]): Boolean

    var
        ItemCostingLines: Record "TFB Item Costing Lines";
        PostCodeZone: Record "TFB Postcode Zone";
        SalesPrices: Record "Sales Price";
        SalesPriceWksh: Record "Sales Price Worksheet";
        CostingSetup: Record "TFB Costings Setup";
        ExistingPrice: Boolean;
        Dirty: Boolean;

    begin
        Clear(Dirty);
        ItemCostingLines.Reset();
        ItemCostingLines.SetRange(Current, true);
        ItemCostingLines.SetRange("Item No.", ItemNo);
        ItemCostingLines.SetRange("Line Type", ItemCostingLines."Line Type"::DZP);
        ItemCostingLines.SetRange("Costing Type", ItemCostingLines."Costing Type"::Standard);
        if ItemCostingLines.FindSet() then
            repeat

                //Check if existing sales price worksheet item exists
                SalesPriceWksh.Reset();
                SalesPriceWksh.SetRange("Starting Date", System.WorkDate());
                SalesPriceWksh.SetRange("Item No.", ItemCostingLines."Item No.");
                SalesPriceWksh.SetRange("Sales Type", SalesPriceWksh."Sales Type"::"Customer Price Group");


                IF PostCodeZone.get(ItemCostingLines."Line Key") then

                    //Get the correct customer group mapping for the postcode zone
                    SalesPriceWksh.SetRange("Sales Code", PostCodeZone."Customer Price Group");

                If SalesPriceWksh.FindFirst() then begin

                    //Update existing price on sales price worksheet
                    SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                    SalesPriceWksh."Price Includes VAT" := false;
                    SalesPriceWksh.Modify();
                    Dirty := true
                end
                else begin

                    //Check first if price is different to existing sales price
                    Clear(SalesPrices);
                    SalesPrices.SetRange("Item No.", ItemCostingLines."Item No.");
                    SalesPrices.SetRange("Sales Type", SalesPriceWksh."Sales Type"::"Customer Price Group");
                    SalesPrices.SetRange("Sales Code", PostCodeZone."Customer Price Group");
                    SalesPrices.SetFilter("Unit of Measure Code", '');
                    SalesPrices.SetFilter("Ending Date", '');

                    If SalesPrices.FindLast() then begin

                        //Check if price is different
                        If ItemCostingLines."Price (Base)" <> SalesPrices."Unit Price" then begin

                            //Add new item into sales price worksheet
                            SalesPriceWksh.Init();
                            SalesPriceWksh."Item No." := ItemCostingLines."Item No.";
                            SalesPriceWksh."Starting Date" := WorkDate();
                            SalesPriceWksh."Sales Type" := SalesPriceWksh."Sales Type"::"Customer Price Group";
                            SalesPriceWksh."Sales Code" := PostCodeZone."Customer Price Group";
                            SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                            SalesPriceWksh."Price Includes VAT" := false;
                            SalesPriceWksh.CalcCurrentPrice(ExistingPrice);
                            SalesPriceWksh.Insert();
                            Dirty := true;
                        end;
                    end
                    else begin

                        //No Sales Price Found So Insert
                        SalesPriceWksh.Init();
                        SalesPriceWksh."Item No." := ItemCostingLines."Item No.";
                        SalesPriceWksh."Starting Date" := System.WorkDate();
                        SalesPriceWksh."Sales Type" := SalesPriceWksh."Sales Type"::"Customer Price Group";
                        SalesPriceWksh."Sales Code" := PostCodeZone."Customer Price Group";
                        SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                        SalesPriceWksh."Price Includes VAT" := false;
                        SalesPriceWksh.Insert();
                        Dirty := true;

                    end;
                end;

            until ItemCostingLines.Next() < 1;

        //Process any ex-warehouse line items

        If CostingSetup.FindFirst() then
            If CostingSetup.ExWarehouseEnabled then
                if CostingSetup.ExWarehousePricingGroup <> '' then begin


                    ItemCostingLines.Reset();
                    ItemCostingLines.SetRange(Current, true);
                    ItemCostingLines.SetRange("Costing Type", ItemCostingLines."Costing Type"::Standard);
                    ItemCostingLines.SetRange("Line Type", ItemCostingLines."Line Type"::EXP);
                    ItemCostingLines.SetRange("Line Key", '-');
                    if ItemCostingLines.FindSet() then
                        repeat

                            SalesPriceWksh.Reset();
                            SalesPriceWksh.SetRange("Starting Date", System.WorkDate());
                            SalesPriceWksh.SetRange("Item No.", ItemCostingLines."Item No.");
                            SalesPriceWksh.SetRange("Sales Type", SalesPriceWksh."Sales Type"::"Customer Price Group");

                            //Get the correct customer group mapping for the ex warehouse pricing type
                            SalesPriceWksh.SetRange("Sales Code", CostingSetup.ExWarehousePricingGroup);

                            If SalesPriceWksh.FindFirst() then begin

                                SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                                SalesPriceWksh."Price Includes VAT" := false;
                                SalesPriceWksh.Modify();
                                Dirty := true

                            end
                            else begin

                                Clear(SalesPrices);
                                SalesPrices.SetRange("Item No.", ItemCostingLines."Item No.");
                                SalesPrices.SetRange("Sales Type", SalesPriceWksh."Sales Type"::"Customer Price Group");
                                SalesPrices.SetRange("Sales Code", CostingSetup.ExWarehousePricingGroup);
                                SalesPrices.SetFilter("Unit of Measure Code", '');
                                SalesPrices.SetFilter("Ending Date", '');

                                If SalesPrices.FindLast() then begin

                                    //Check if price is different
                                    If ItemCostingLines."Price (Base)" <> SalesPrices."Unit Price" then begin

                                        SalesPriceWksh."Item No." := ItemCostingLines."Item No.";
                                        SalesPriceWksh."Starting Date" := System.WorkDate();
                                        SalesPriceWksh."Sales Type" := SalesPriceWksh."Sales Type"::"Customer Price Group";
                                        SalesPriceWksh."Sales Code" := CostingSetup.ExWarehousePricingGroup;
                                        SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                                        SalesPriceWksh."Price Includes VAT" := false;
                                        SalesPriceWksh.Insert();
                                        Dirty := true;

                                    end;
                                end
                                else begin
                                    SalesPriceWksh."Item No." := ItemCostingLines."Item No.";
                                    SalesPriceWksh."Starting Date" := System.WorkDate();
                                    SalesPriceWksh."Sales Type" := SalesPriceWksh."Sales Type"::"Customer Price Group";
                                    SalesPriceWksh."Sales Code" := CostingSetup.ExWarehousePricingGroup;
                                    SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                                    SalesPriceWksh."Price Includes VAT" := false;
                                    SalesPriceWksh.Insert();
                                    Dirty := true;
                                end;
                            end;
                        until ItemCostingLines.Next() < 1;
                end;


        Exit(Dirty);
    end;

    procedure CopyCurrentCostingToSalesWorkSheet()
    var
        ItemCostingLines: Record "TFB Item Costing Lines";
        PostCodeZone: Record "TFB Postcode Zone";
        SalesPrices: Record "Sales Price";
        SalesPriceWksh: Record "Sales Price Worksheet";
        CostingSetup: Record "TFB Costings Setup";
        ExistingPrice: Boolean;



    begin
        ItemCostingLines.Reset();
        ItemCostingLines.SetRange(Current, true);
        ItemCostingLines.SetRange("Line Type", ItemCostingLines."Line Type"::DZP);
        ItemCostingLines.SetRange("Costing Type", ItemCostingLines."Costing Type"::Standard);
        if ItemCostingLines.FindSet() then
            repeat

                //Check if existing sales price worksheet item exists
                SalesPriceWksh.Reset();
                SalesPriceWksh.SetRange("Starting Date", System.WorkDate());
                SalesPriceWksh.SetRange("Item No.", ItemCostingLines."Item No.");
                SalesPriceWksh.SetRange("Sales Type", SalesPriceWksh."Sales Type"::"Customer Price Group");


                IF PostCodeZone.get(ItemCostingLines."Line Key") then

                    //Get the correct customer group mapping for the postcode zone
                    SalesPriceWksh.SetRange("Sales Code", PostCodeZone."Customer Price Group");

                If SalesPriceWksh.FindFirst() then begin

                    //Update existing price on sales price worksheet
                    SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                    SalesPriceWksh."Price Includes VAT" := false;
                    SalesPriceWksh.Modify()
                end
                else begin

                    //Check first if price is different to existing sales price
                    Clear(SalesPrices);
                    SalesPrices.SetRange("Item No.", ItemCostingLines."Item No.");
                    SalesPrices.SetRange("Sales Type", SalesPriceWksh."Sales Type"::"Customer Price Group");
                    SalesPrices.SetRange("Sales Code", PostCodeZone."Customer Price Group");
                    SalesPrices.SetFilter("Unit of Measure Code", '');
                    SalesPrices.SetFilter("Ending Date", '');

                    If SalesPrices.FindLast() then begin

                        //Check if price is different
                        If ItemCostingLines."Price (Base)" <> SalesPrices."Unit Price" then begin

                            //Add new item into sales price worksheet
                            SalesPriceWksh.Init();
                            SalesPriceWksh."Item No." := ItemCostingLines."Item No.";
                            SalesPriceWksh."Starting Date" := WorkDate();
                            SalesPriceWksh."Sales Type" := SalesPriceWksh."Sales Type"::"Customer Price Group";
                            SalesPriceWksh."Sales Code" := PostCodeZone."Customer Price Group";
                            SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                            SalesPriceWksh."Price Includes VAT" := false;
                            SalesPriceWksh.CalcCurrentPrice(ExistingPrice);
                            SalesPriceWksh.Insert();
                        end;
                    end
                    else begin

                        //No Sales Price Found So Insert
                        SalesPriceWksh.Init();
                        SalesPriceWksh."Item No." := ItemCostingLines."Item No.";
                        SalesPriceWksh."Starting Date" := System.WorkDate();
                        SalesPriceWksh."Sales Type" := SalesPriceWksh."Sales Type"::"Customer Price Group";
                        SalesPriceWksh."Sales Code" := PostCodeZone."Customer Price Group";
                        SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                        SalesPriceWksh."Price Includes VAT" := false;
                        SalesPriceWksh.Insert();

                    end;
                end;

            until ItemCostingLines.Next() < 1;

        //Process any ex-warehouse line items

        If CostingSetup.FindFirst() then
            If CostingSetup.ExWarehouseEnabled then
                if CostingSetup.ExWarehousePricingGroup <> '' then begin


                    ItemCostingLines.Reset();
                    ItemCostingLines.SetRange(Current, true);
                    ItemCostingLines.SetRange("Costing Type", ItemCostingLines."Costing Type"::Standard);
                    ItemCostingLines.SetRange("Line Type", ItemCostingLines."Line Type"::EXP);
                    ItemCostingLines.SetRange("Line Key", '-');
                    if ItemCostingLines.FindSet() then
                        repeat

                            SalesPriceWksh.Reset();
                            SalesPriceWksh.SetRange("Starting Date", System.WorkDate());
                            SalesPriceWksh.SetRange("Item No.", ItemCostingLines."Item No.");
                            SalesPriceWksh.SetRange("Sales Type", SalesPriceWksh."Sales Type"::"Customer Price Group");

                            //Get the correct customer group mapping for the ex warehouse pricing type
                            SalesPriceWksh.SetRange("Sales Code", CostingSetup.ExWarehousePricingGroup);

                            If SalesPriceWksh.FindFirst() then begin

                                SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                                SalesPriceWksh."Price Includes VAT" := false;
                                SalesPriceWksh.Modify()


                            end
                            else begin

                                Clear(SalesPrices);
                                SalesPrices.SetRange("Item No.", ItemCostingLines."Item No.");
                                SalesPrices.SetRange("Sales Type", SalesPriceWksh."Sales Type"::"Customer Price Group");
                                SalesPrices.SetRange("Sales Code", CostingSetup.ExWarehousePricingGroup);
                                SalesPrices.SetFilter("Unit of Measure Code", '');
                                SalesPrices.SetFilter("Ending Date", '');

                                If SalesPrices.FindLast() then begin

                                    //Check if price is different
                                    If ItemCostingLines."Price (Base)" <> SalesPrices."Unit Price" then begin

                                        SalesPriceWksh."Item No." := ItemCostingLines."Item No.";
                                        SalesPriceWksh."Starting Date" := System.WorkDate();
                                        SalesPriceWksh."Sales Type" := SalesPriceWksh."Sales Type"::"Customer Price Group";
                                        SalesPriceWksh."Sales Code" := CostingSetup.ExWarehousePricingGroup;
                                        SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                                        SalesPriceWksh."Price Includes VAT" := false;
                                        SalesPriceWksh.Insert();

                                    end;
                                end
                                else begin
                                    SalesPriceWksh."Item No." := ItemCostingLines."Item No.";
                                    SalesPriceWksh."Starting Date" := System.WorkDate();
                                    SalesPriceWksh."Sales Type" := SalesPriceWksh."Sales Type"::"Customer Price Group";
                                    SalesPriceWksh."Sales Code" := CostingSetup.ExWarehousePricingGroup;
                                    SalesPriceWksh.Validate("New Unit Price", ItemCostingLines."Price (Base)");
                                    SalesPriceWksh."Price Includes VAT" := false;
                                    SalesPriceWksh.Insert();
                                end;
                            end;
                        until ItemCostingLines.Next() < 1;
                end;
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


        //Array - 2 dimension - First Average/Market and second Pallet/Direct Container
        TotalLCUnitCostLCY: Array[2, 2] of Decimal;
        TotalUnitCostLCY: Array[2, 2] of Decimal;
        TotalUnitSalesPriceLCY: Array[2, 2] of Decimal;
        TotalUnitSalesPriceRndLCY: Array[2, 2] of Decimal;
        TotalUnitSalesPriceDelRndLCY: Array[2, 2] of Decimal;

    begin

        //Get default details and exit with false if details missing

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

        //Get Standard Cost Basis
        UnitCost[1] := PricingCU.CalculateUnitPriceByPriceUnit(Item."No.", Item."Base Unit of Measure", Header."Purchase Price Unit", Header."Average Cost");
        UnitCostLCY[1] := UnitCost[1] / ExchRate;


        //Get Market Cost Basis
        UnitCost[2] := PricingCU.CalculateUnitPriceByPriceUnit(Item."No.", Item."Base Unit of Measure", Header."Purchase Price Unit", Header."Market Price");
        UnitCostLCY[2] := UnitCost[2] / ExchRate;


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

    internal procedure CopyCurrentCostingToPriceList(PriceListHeader: Record "Price List Header")



    var
        ItemCostingLines: Record "TFB Item Costing Lines";
        Item: Record Item;
        PostCodeZone: Record "TFB Postcode Zone";
        PriceLine: Record "Price List Line";
        PriceLineNew: Record "Price List Line";
        CostingSetup: Record "TFB Costings Setup";
        PriceAsset: Record "Price Asset";
        DateFormula: DateFormula;
        DayBefore: Date;




    begin
        Evaluate(DateFormula, '-1D');
        DayBefore := CalcDate(DateFormula, WorkDate());

        PriceLine.SetRange("Price List Code", PriceListHeader.Code);


        ItemCostingLines.Reset();
        ItemCostingLines.SetRange(Current, true);
        ItemCostingLines.SetRange("Line Type", ItemCostingLines."Line Type"::DZP);
        ItemCostingLines.SetRange("Costing Type", ItemCostingLines."Costing Type"::Standard);
        if ItemCostingLines.FindSet() then
            repeat
                Item.Get(ItemCostingLines."Item No.");

                If not (Item."TFB Publishing Block" and Item.Blocked) then begin  //Ignore price processing changes if 
                    //Check if existing sales price worksheet item exists
                    PriceLine.Reset();
                    PriceLine.SetRange("Price List Code", PriceListHeader.Code);
                    PriceLine.SetRange("Starting Date", System.WorkDate());
                    PriceLine.SetRange("Asset No.", ItemCostingLines."Item No.");
                    PriceLine.SetRange("Asset Type", PriceLine."Asset Type"::Item);
                    PriceLine.SetRange("Source Type", PriceLine."Source Type"::"Customer Price Group");

                    If PostCodeZone.get(ItemCostingLines."Line Key") then

                        //Get the correct customer group mapping for the postcode zone
                        PriceLine.SetRange("Source No.", PostCodeZone."Customer Price Group");

                    If PriceLine.FindFirst() then begin

                        //Update existing price on sales price worksheet
                        PriceLine.Validate("Unit Price", ItemCostingLines."Price (Base)");
                        PriceLine."Price Includes VAT" := false;
                        PriceLine.Modify();
                    end
                    else begin

                        //Check first if price is different to existing sales price
                        PriceLine.Reset();
                        PriceLine.SetRange("Price List Code", PriceListHeader.Code);
                        PriceLine.SetRange("Asset No.", ItemCostingLines."Item No.");
                        PriceLine.SetRange("Asset Type", PriceLine."Asset Type"::Item);
                        PriceLine.SetRange("Source Type", PriceLine."Source Type"::"Customer Price Group");
                        PriceLine.SetRange("Source No.", PostCodeZone."Customer Price Group");
                        PriceLine.SetFilter("Unit of Measure Code", '');
                        PriceLine.SetFilter("Ending Date", '');

                        If PriceLine.FindLast() then begin

                            //Check if price is different
                            If ItemCostingLines."Price (Base)" <> PriceLine."Unit Price" then begin

                                PriceAsset."Price Type" := PriceListHeader."Price Type";
                                PriceAsset.Validate("Asset Type", PriceAsset."Asset Type"::Item);
                                PriceAsset.Validate("Asset No.", ItemCostingLines."Item No.");
                                PriceAsset.Validate("Unit of Measure Code", '');


                                If PriceAsset."Asset No." <> '' then
                                    If AddLine(PriceListHeader, PriceAsset, ItemCostingLines, PostCodeZone."Customer Price Group") then begin
                                        PriceLine.validate("Ending Date", DayBefore);
                                        PriceLine.Modify(true);
                                    end;

                            end;
                        end
                        else begin

                            PriceAsset."Price Type" := PriceListHeader."Price Type";
                            PriceAsset.Validate("Asset Type", PriceAsset."Asset Type"::Item);
                            PriceAsset.Validate("Asset No.", ItemCostingLines."Item No.");
                            PriceAsset.Validate("Unit of Measure Code", '');

                            If PriceAsset."Asset No." <> '' then
                                AddLine(PriceListHeader, PriceAsset, ItemCostingLines, PostCodeZone."Customer Price Group");

                        end;

                    end
                end;
            until ItemCostingLines.Next() < 1;

        //Process any ex-warehouse line items

        If CostingSetup.FindFirst() then
            If CostingSetup.ExWarehouseEnabled then
                if CostingSetup.ExWarehousePricingGroup <> '' then begin


                    ItemCostingLines.Reset();
                    ItemCostingLines.SetRange(Current, true);
                    ItemCostingLines.SetRange("Costing Type", ItemCostingLines."Costing Type"::Standard);
                    ItemCostingLines.SetRange("Line Type", ItemCostingLines."Line Type"::EXP);
                    ItemCostingLines.SetRange("Line Key", '-');

                    if ItemCostingLines.FindSet() then
                        repeat

                            If not (Item."TFB Publishing Block" and Item.Blocked) then begin
                                PriceLine.Reset();
                                PriceLine.SetRange("Price List Code", PriceListHeader.Code);
                                PriceLine.SetRange("Starting Date", System.WorkDate());
                                PriceLine.SetRange("Asset No.", ItemCostingLines."Item No.");
                                PriceLine.SetRange("Asset Type", PriceLine."Asset Type"::Item);
                                PriceLine.SetRange("Source Type", PriceLine."Source Type"::"Customer Price Group");
                                PriceLine.SetRange("Source No.", CostingSetup.ExWarehousePricingGroup);

                                If PriceLine.FindFirst() then begin

                                    //Update existing price on sales price worksheet as it was found
                                    PriceLine.Validate("Unit Price", ItemCostingLines."Price (Base)");
                                    PriceLine."Price Includes VAT" := false;
                                    PriceLine.Modify();

                                end
                                else begin
                                    PriceLine.Reset();
                                    PriceLine.SetRange("Price List Code", PriceListHeader.Code);
                                    PriceLine.SetRange("Asset No.", ItemCostingLines."Item No.");
                                    PriceLine.SetRange("Asset Type", PriceLine."Asset Type"::Item);
                                    PriceLine.SetRange("Source Type", PriceLine."Source Type"::"Customer Price Group");
                                    PriceLine.SetRange("Source No.", CostingSetup.ExWarehousePricingGroup);
                                    PriceLine.SetFilter("Unit of Measure Code", '');
                                    PriceLine.SetFilter("Ending Date", '');


                                    If PriceLine.FindLast() then begin

                                        //Check if price is different
                                        If ItemCostingLines."Price (Base)" <> PriceLine."Unit Price" then begin

                                            //Add new item into sales price worksheet
                                            PriceAsset."Price Type" := PriceListHeader."Price Type";
                                            PriceAsset.Validate("Asset Type", PriceAsset."Asset Type"::Item);
                                            PriceAsset.Validate("Asset No.", ItemCostingLines."Item No.");
                                            PriceAsset.Validate("Unit of Measure Code", '');


                                            If PriceAsset."Asset No." <> '' then
                                                If AddLine(PriceListHeader, PriceAsset, ItemCostingLines, CostingSetup.ExWarehousePricingGroup) then begin
                                                    PriceLine.validate("Ending Date", DayBefore);
                                                    PriceLine.Modify(true);
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
                                            AddLine(PriceListHeader, PriceAsset, ItemCostingLines, CostingSetup.ExWarehousePricingGroup);
                                    end;
                                end;
                            end;
                        until ItemCostingLines.Next() < 1;
                end;
    end;


    local procedure AddLine(ToPriceListHeader: Record "Price List Header"; PriceAsset: Record "Price Asset"; ItemCostingLine: Record "TFB Item Costing Lines"; customerPriceGroup: Code[20]): Boolean
    var
        PriceListLine: Record "Price List Line";
    begin

        PriceListLine."Price List Code" := ToPriceListHeader.Code;
        PriceListLine."Line No." := 0; // autoincrement
        ToPriceListHeader."Allow Updating Defaults" := false; // to copy defaults
        PriceListLine.CopyFrom(ToPriceListHeader);
        PriceListLine."Amount Type" := "Price Amount Type"::Price;
        PriceListLine.Validate("Minimum Quantity", 0);
        PriceListLine.validate("Starting Date", WorkDate());
        PriceListLine.validate("Source Type", PriceListLine."Source Type"::"Customer Price Group");
        PriceListLine.validate("Source No.", customerPriceGroup);
        PriceListLine.CopyFrom(PriceAsset);
        PriceListLine.Validate("Unit Price", ItemCostingLine."Price (Base)");

        Exit(PriceListLine.Insert(true));
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
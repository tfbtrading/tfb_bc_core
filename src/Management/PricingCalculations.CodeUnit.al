codeunit 50140 "TFB Pricing Calculations"
{



    //Subscribe to event in sales price worksheet that identifies a new price so that we can update current per kilogram price

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterCalcCurrentPriceFound', '', false, false)]
    local procedure HandleOnAfterCalcCurrentPriceFound(var SalesPriceWorksheet: Record "Sales Price Worksheet");
    var
        PriceUnit: enum "TFB Price Unit";

    begin

        PriceUnit := PriceUnit::KG;
        SalesPriceWorksheet."TFB Current Per Kg Price" := CalculatePriceUnitByUnitPrice(SalesPriceWorksheet."Item No.", SalesPriceWorksheet."Unit of Measure Code", PriceUnit, SalesPriceWorksheet."Current Unit Price");

    end;





    //Procedure elaborated to handle change in fields that drive price per kilogram

    procedure CalcLineTotalKg(NetWeight: decimal; QtyBase: decimal): Decimal;

    var
        LineTotalKg: decimal;
    begin

        LineTotalKg := NetWeight * QtyBase;
        Exit(LineTotalKg);
    end;

    procedure CalcLineTotalKg(ItemNo: code[20]; UomCode: code[10]; Qty: decimal): Decimal;

    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        UOM: Record "Unit of Measure";
        Multiplier: Decimal;
        Weight: Decimal;
        LineTotalKg: decimal;
    begin
        Item.Get(ItemNo);
        Weight := Item."Net Weight";
        UOM.Get(UomCode);
        ItemUOM.Get(Item."No.", UOM.Code);
        Multiplier := ItemUOM."Qty. per Unit of Measure";


        LineTotalKg := Weight * Qty * Multiplier;

        Exit(LineTotalKg);
    end;


    procedure CalcPerKgFromUnit(UnitPrice: Decimal; Weight: Decimal): Decimal

    begin
        If Weight > 0 then
            Exit(UnitPrice / Weight)
        else
            Exit(0);
    end;

    procedure CalcUnitFromPerKg(PerKgPrice: Decimal; Weight: Decimal): Decimal

    begin
        If Weight > 0 then
            Exit(PerKgPrice * Weight)
        else
            Exit(0);
    end;

    procedure CalculateUnitPriceByPriceUnit(ItemNo: code[20]; UomCode: code[10]; PriceUnit: enum "TFB Price Unit"; PriceByPriceUnit: decimal) Value: Decimal;
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        UOM: Record "Unit of Measure";
        Multiplier: Decimal;
        UnitPrice: Decimal;
        Weight: Decimal;

    begin
        Item.Get(ItemNo);
        Weight := Item."Net Weight";

        If UomCode <> '' then
            UOM.Get(UomCode)
        else
            UOM.Get(Item."Base Unit of Measure");

        ItemUOM.Get(Item."No.", UOM.Code);
        Multiplier := ItemUOM."Qty. per Unit of Measure";

        if ((PriceByPriceUnit) <> 0) and (Weight <> 0) and (Multiplier <> 0) then begin
            case PriceUnit of
                PriceUnit::MT:
                    UnitPrice := PriceByPriceUnit * (Weight * Multiplier) / 1000;
                PriceUnit::LB:
                    UnitPrice := PriceByPriceUnit * (Weight * Multiplier) * 2.204642;
                PriceUnit::KG:
                    UnitPrice := PriceByPriceUnit * (Weight * Multiplier);
                PriceUnit::UNIT:
                    UnitPrice := PriceByPriceUnit;
            end;
            EXIT(UnitPrice);

        end;
    end;

    procedure FixExistingPerKgPricing()

    var
        SalesPrice: Record "Sales Price";
        Item: Record Item;
        PriceUnit: Enum "TFB Price Unit";
        UoM: Code[10];

    begin

        SalesPrice.SetRange("TFB PriceByWeight", 0);
        PriceUnit := PriceUnit::KG;

        if SalesPrice.FindSet(true, false) then
            repeat

                Item.Get(SalesPrice."Item No.");

                If SalesPrice."Unit of Measure Code" = '' then
                    UoM := Item."Base Unit of Measure"
                else
                    UoM := SalesPrice."Unit of Measure Code";

                If Item."Net Weight" > 0 then begin
                    SalesPrice."TFB PriceByWeight" := CalculatePriceUnitByUnitPrice(SalesPrice."Item No.", uoM, PriceUnit, SalesPrice."Unit Price");
                    SalesPrice.Modify();
                end;
            until SalesPrice.Next() < 1;


    end;


    /// <summary> 
    /// Based on information about a current price, looks for the old price and ensures it is expired
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="SalesType">Parameter of type Enum "Sales Price Type".</param>
    /// <param name="SalesCode">Parameter of type Code[20].</param>
    /// <param name="StartingDate">Parameter of type Date.</param>
    local procedure ExpireOldPrice(ItemNo: Code[20]; SalesType: Enum "Sales Price Type"; SalesCode: Code[20]; StartingDate: Date)

    var
        SalesPrice: Record "Sales Price";
        DateFormula: DateFormula;
        DayBefore: Date;


    begin

        Evaluate(DateFormula, '-1D');
        Clear(SalesPrice);
        SalesPrice.SetRange("Item No.", ItemNo);
        SalesPrice.SetRange("Sales Type", SalesType);
        SalesPrice.SetRange("Currency Code", '');
        SalesPrice.SetRange("Sales Code", SalesCode);
        DayBefore := CalcDate(DateFormula, StartingDate);
        SalesPrice.SetFilter("Starting Date", '..%1', DayBefore);
        SalesPrice.SetRange("Ending Date", 0D);

        if SalesPrice.FindSet(true, true) then
            repeat

                SalesPrice."Ending Date" := DayBefore;
                SalesPrice.Modify();

            until SalesPrice.Next() < 1;

    end;

    procedure CheckPriceHealth()

    var
        SalesPrice: Record "Sales Price";
        SalesSetup: Record "Sales & Receivables Setup";
        CustomerPriceGroup: Record "Customer Price Group";
        Item: Record Item;
    begin

        SalesSetup.Get();

        if Item.FindSet(true, false) then
            repeat
                Clear(CustomerPriceGroup);
                If CustomerPriceGroup.FindSet(False, false) then
                    repeat

                        Clear(SalesPrice);
                        SalesPrice.SetRange("Item No.", Item."No.");
                        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
                        SalesPrice.SetRange("Sales Code", CustomerPriceGroup.Code);
                        SalesPrice.SetRange("Ending Date", 0D);


                        if SalesPrice.FindLast() then begin
                            ExpireOldPrice(Item."No.", SalesPrice."Sales Type", SalesPrice."Sales Code", SalesPrice."Starting Date");

                            If CustomerPriceGroup.code = SalesSetup."TFB Item Price Group" then begin
                                Item."Unit Price" := SalesPrice."Unit Price";
                                Item."TFB Unit Price Source" := CustomerPriceGroup.Code;
                                Item.Modify(false);
                            end;
                        end;

                    until CustomerPriceGroup.Next() < 1;

            until Item.Next() < 1;


    end;

    procedure CalculatePriceUnitByUnitPrice(ItemNo: code[20]; UomCode: code[10]; PriceUnit: enum "TFB Price Unit"; UnitPrice: decimal) Value: Decimal;
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        UOM: Record "Unit of Measure";
        Multiplier: Decimal;
        PriceByPriceUnit: Decimal;
        Weight: Decimal;


    begin
        Item.Get(ItemNo);
        Weight := Item."Net Weight";
        If UomCode <> '' then
            UOM.Get(UomCode)
        else
            UOM.Get(Item."Base Unit of Measure");

        ItemUOM.Get(Item."No.", UOM.Code);
        Multiplier := ItemUOM."Qty. per Unit of Measure";


        if ((UnitPrice) <> 0) and (Weight <> 0) and (Multiplier <> 0) then begin
            case PriceUnit of
                PriceUnit::MT:
                    PriceByPriceUnit := UnitPrice / (Weight * Multiplier) * 1000;
                PriceUnit::LB:
                    PriceByPriceUnit := UnitPrice / (Weight * Multiplier) / 2.204642;
                PriceUnit::KG:
                    PriceByPriceUnit := UnitPrice / (Weight * Multiplier);
                PriceUnit::UNIT:
                    PriceByPriceUnit := UnitPrice;
            end;
            EXIT(PriceByPriceUnit);

        end;
    end;

    procedure CalculateQtyPriceUnit(ItemNo: code[20]; PriceUnit: enum "TFB Price Unit"; QtyByBaseUnit: decimal) Value: Decimal;
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        UOM: Record "Unit of Measure";
        Vendor: Record Vendor;
        Multiplier: Decimal;
        QtyPriceUnit: Decimal;
        Weight: Decimal;
    begin
        Item.Get(ItemNo);

        Weight := Item."Net Weight";
        UOM.Get(item."Base Unit of Measure");
        ItemUOM.Get(Item."No.", UOM.Code);
        Multiplier := ItemUOM."Qty. per Unit of Measure";

        if (QtyByBaseUnit <> 0) and (Weight <> 0) and (Multiplier <> 0) then begin
            case PriceUnit of
                Vendor."TFB Vendor Price Unit"::MT:
                    QtyPriceUnit := QtyByBaseUnit * (Weight * Multiplier) / 1000;

                Vendor."TFB Vendor Price Unit"::LB:
                    QtyPriceUnit := QtyByBaseUnit * (Weight * Multiplier) * 2.204642;

                Vendor."TFB Vendor Price Unit"::KG:
                    QtyPriceUnit := QtyByBaseUnit * (Weight * Multiplier);
                Vendor."TFB Vendor Price Unit"::UNIT:
                    QtyPriceUnit := QtyByBaseUnit
            end;
            EXIT(QtyPriceUnit);

        end;
    end;


    Procedure GetVendorZoneRate(VendorNo: Code[20]; ItemNo: Code[20]; ZoneCode: Code[20]): Decimal

    var
        VendorZoneRate: Record "TFB Vendor Zone Rate";
        Item: Record Item;
        NotificationMessage: Notification;
        RatePerUnit: Decimal;

    begin

        Item.Get(ItemNo);

        VendorZoneRate.Reset();
        VendorZoneRate.SetRange("Vendor No.", VendorNo);
        VendorZoneRate.SetRange("Zone Code", ZoneCode);
        VendorZoneRate.SetRange("Sales Type", VendorZoneRate."Sales Type"::Item);
        VendorZoneRate.SetRange("Sales Code", ItemNo);


        If VendorZoneRate.FindFirst() then
            //Found item specific rate and should use this
            RatePerUnit := CalculateUnitPriceByPriceUnit(ItemNo, item."Base Unit of Measure", VendorZoneRate."Rate Type", VendorZoneRate."Surcharge Rate")

        else begin
            //Search for general postzone rate

            VendorZoneRate.Reset();
            VendorZoneRate.SetRange("Vendor No.", VendorNo);
            VendorZoneRate.SetRange("Zone Code", ZoneCode);
            VendorZoneRate.SetRange("Sales Type", VendorZoneRate."Sales Type"::All);

            If VendorZoneRate.FindFirst() then
                //Found general postzone rate
                 RatePerUnit := CalculateUnitPriceByPriceUnit(ItemNo, item."Base Unit of Measure", VendorZoneRate."Rate Type", VendorZoneRate."Surcharge Rate")

            else begin
                //Could not find any rate specified for the dropship vendor
                NotificationMessage.Message := 'Item Costing is set to drop ship, but no vendor zone rates is defined for zone';
                NotificationMessage.Scope := NotificationMessage.Scope() ::LocalScope;
                NotificationMessage.Send();
                RatePerUnit := 0;

            end;

        end;

        Exit(RatePerUnit);
    end;

    internal procedure CheckPriceHealthOnPriceList(Rec: Record "Price List Header")
    begin
        Error('Procedure CheckPriceHealthOnPriceList not implemented.');
    end;
}
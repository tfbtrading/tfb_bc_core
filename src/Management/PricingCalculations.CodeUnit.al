codeunit 50140 "TFB Pricing Calculations"
{



    //Subscribe to event in sales price worksheet that identifies a new price so that we can update current per kilogram price

    


    //Procedure elaborated to handle change in fields that drive price per kilogram

    procedure CalcLineTotalKg(NetWeight: decimal; QtyBase: decimal): Decimal;

    var
        LineTotalKg: decimal;
    begin

        LineTotalKg := NetWeight * QtyBase;
        exit(LineTotalKg);
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

        exit(LineTotalKg);
    end;


    procedure CalcPerKgFromUnit(UnitPrice: Decimal; Weight: Decimal): Decimal

    begin
        if Weight > 0 then
            exit(UnitPrice / Weight)
        else
            exit(0);
    end;

    procedure CalcUnitFromPerKg(PerKgPrice: Decimal; Weight: Decimal): Decimal

    begin
        if Weight > 0 then
            exit(PerKgPrice * Weight)
        else
            exit(0);
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
        if not Item.Get(ItemNo) then exit(0);
        Weight := Item."Net Weight";

        if UomCode <> '' then
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
            exit(UnitPrice);

        end;
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
        if not Item.Get(ItemNo) then exit(0);
        Weight := Item."Net Weight";
        if UomCode <> '' then
            UOM.Get(UomCode)
        else
            UOM.Get(Item."Base Unit of Measure");

        if ItemUOM.Get(Item."No.", UOM.Code) then
            Multiplier := ItemUOM."Qty. per Unit of Measure"
        else
            Multiplier := 1;


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
            exit(PriceByPriceUnit);

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
        if not Item.Get(ItemNo) then exit(0);

        Weight := Item."Net Weight";
        UOM.Get(item."Base Unit of Measure");
        if ItemUOM.Get(Item."No.", UOM.Code) then
            Multiplier := ItemUOM."Qty. per Unit of Measure"
        else
            Multiplier := 1;

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
            exit(QtyPriceUnit);

        end;
    end;


    procedure GetVendorZoneRate(VendorNo: Code[20]; ItemNo: Code[20]; ZoneCode: Code[20]): Decimal

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


        if VendorZoneRate.FindFirst() then
            //Found item specific rate and should use this
            RatePerUnit := CalculateUnitPriceByPriceUnit(ItemNo, item."Base Unit of Measure", VendorZoneRate."Rate Type", VendorZoneRate."Surcharge Rate")

        else begin
            //Search for general postzone rate

            VendorZoneRate.Reset();
            VendorZoneRate.SetRange("Vendor No.", VendorNo);
            VendorZoneRate.SetRange("Zone Code", ZoneCode);
            VendorZoneRate.SetRange("Sales Type", VendorZoneRate."Sales Type"::All);

            if VendorZoneRate.FindFirst() then
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

        exit(RatePerUnit);
    end;

    internal procedure CheckPriceHealthOnPriceList(Rec: Record "Price List Header")
    begin
        Error('Procedure CheckPriceHealthOnPriceList not implemented.');
    end;
}
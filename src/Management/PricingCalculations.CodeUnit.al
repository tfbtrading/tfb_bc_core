codeunit 50140 "TFB Pricing Calculations"
{



    //Subscribe to event in sales price worksheet that identifies a new price so that we can update current per kilogram price

    


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
        If not Item.Get(ItemNo) then exit(0);
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

   
    procedure CalculatePriceUnitByUnitPrice(ItemNo: code[20]; UomCode: code[10]; PriceUnit: enum "TFB Price Unit"; UnitPrice: decimal) Value: Decimal;
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        UOM: Record "Unit of Measure";
        Multiplier: Decimal;
        PriceByPriceUnit: Decimal;
        Weight: Decimal;


    begin
        If not Item.Get(ItemNo) then exit(0);
        Weight := Item."Net Weight";
        If UomCode <> '' then
            UOM.Get(UomCode)
        else
            UOM.Get(Item."Base Unit of Measure");

        If ItemUOM.Get(Item."No.", UOM.Code) then
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
        If not Item.Get(ItemNo) then exit(0);

        Weight := Item."Net Weight";
        UOM.Get(item."Base Unit of Measure");
        If ItemUOM.Get(Item."No.", UOM.Code) then
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
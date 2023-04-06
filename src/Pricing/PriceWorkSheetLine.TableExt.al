tableextension 50131 "TFB Price Worksheet Line" extends "Price Worksheet Line"
{
    fields
    {
        // Add changes to table fields here
    }
    
 procedure UpdateUnitPriceFromAltPrice(AltPrice: Decimal)

    begin

        if Rec."Asset Type" = Rec."Asset Type"::Item then
            case "Price Type" of
                "Price Type"::Sale:
                    Rec.Validate("Unit Price", TFBPricingLogic.CalculateUnitPriceByPriceUnit(rec."Asset No.", rec."Unit of Measure Code", GetPriceUnit(), AltPrice));
                "Price Type"::Purchase:
                    Rec.Validate("Direct Unit Cost", TFBPricingLogic.CalculateUnitPriceByPriceUnit(rec."Asset No.", rec."Unit of Measure Code", GetPriceUnit(), AltPrice));
            end;

    end;

    procedure GetPriceUnit(): Enum "TFB Price Unit"

    var
        Vendor: record Vendor;
        PriceListHeader: Record "Price List Header";
        _PriceUnit: Enum "TFB Price Unit";

    begin
        case "Price Type" of
            "Price Type"::Purchase:
                if "Source Type" = "Source Type"::Vendor then begin
                    Vendor.SetLoadFields("TFB Vendor Price Unit");
                    if Vendor.GetBySystemId(rec."Source ID") then
                        _PriceUnit := Vendor."TFB Vendor Price Unit"
                end
                else begin
                    PriceListHeader.SetLoadFields("TFB Price Unit");
                    if PriceListHeader.Get(Rec."Price List Code") then
                        _PriceUnit := PriceListHeader."TFB Price Unit";
                end;
            "Price Type"::Sale:
                _PriceUnit := _PriceUnit::KG;
        end;

        exit(_PriceUnit);

    end;

    procedure GetItemWeight(): Decimal;

    var
        Item: Record Item;

    begin
        if "Asset Type" = "Asset Type"::Item then
            if Item.GetBySystemId("Asset ID") then
                exit(Item."Net Weight");

    end;

    procedure GetPriceAltPriceFromUnitPrice(): Decimal

    begin
        if Rec."Asset Type" = Rec."Asset Type"::Item then
            case "Price Type" of
                "Price Type"::Sale:
                    exit(TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."Asset No.", rec."Unit of Measure Code", GetPriceUnit(), rec."Unit Price"));
                "Price Type"::Purchase:
                    exit(TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."Asset No.", rec."Unit of Measure Code", GetPriceUnit(), rec."Direct Unit Cost"));
            end;


    end;

    var

        TFBPricingLogic: Codeunit "TFB Pricing Calculations";
}
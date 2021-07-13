tableextension 50123 "TFB Price List Line" extends "Price List Line"
{
    fields
    {
        // Add changes to table fields here
    }

    procedure UpdateUnitPriceFromAltPrice(AltPrice: Decimal)

    begin

        If Rec."Asset Type" = Rec."Asset Type"::Item then
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
                If "Source Type" = "Source Type"::Vendor then begin
                    Vendor.SetLoadFields("TFB Vendor Price Unit");
                    If Vendor.GetBySystemId(rec."Source ID") then
                        _PriceUnit := Vendor."TFB Vendor Price Unit"
                end
                else begin
                    PriceListHeader.SetLoadFields("TFB Price Unit");
                    If PriceListHeader.Get(Rec."Price List Code") then
                        _PriceUnit := PriceListHeader."TFB Price Unit";
                end;
            "Price Type"::Sale:
                _PriceUnit := _PriceUnit::KG;
        end;

        Exit(_PriceUnit);

    end;

    procedure GetItemWeight(): Decimal;

    var
        Item: Record Item;

    begin
        If "Asset Type" = "Asset Type"::Item then
            If Item.GetBySystemId("Asset ID") then
                Exit(Item."Net Weight");

    end;

    procedure GetPriceAltPriceFromUnitPrice(): Decimal

    begin
        If Rec."Asset Type" = Rec."Asset Type"::Item then
            case "Price Type" of
                "Price Type"::Sale:
                    Exit(TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."Asset No.", rec."Unit of Measure Code", GetPriceUnit(), rec."Unit Price"));
                "Price Type"::Purchase:
                    Exit(TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."Asset No.", rec."Unit of Measure Code", GetPriceUnit(), rec."Direct Unit Cost"));
            end;


    end;

    var

        TFBPricingLogic: Codeunit "TFB Pricing Calculations";


}
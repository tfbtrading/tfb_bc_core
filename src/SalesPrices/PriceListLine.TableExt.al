tableextension 50123 "TFB Price List Line" extends "Price List Line"
{
    fields
    {
        // Add changes to table fields here
    }

    procedure UpdateUnitPriceFromPerKgPrice(NewPricePerKg: Decimal)

    begin
        PriceUnit := PriceUnit::KG;
        If Rec."Asset Type" = Rec."Asset Type"::Item then
            Rec.Validate("Unit Price", TFBPricingLogic.CalculateUnitPriceByPriceUnit(rec."Asset No.", rec."Unit of Measure Code", PriceUnit, NewPricePerKg));
    end;

    procedure GetPricePerKgFromUnitPrice(): Decimal

    begin
        PriceUnit := PriceUnit::KG;
        If Rec."Asset Type" = Rec."Asset Type"::Item then
            Exit(TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."Asset No.", rec."Unit of Measure Code", PriceUnit, rec."Unit Price"));
    end;

    var

        TFBPricingLogic: Codeunit "TFB Pricing Calculations";
        PriceUnit: Enum "TFB Price Unit";

}
tableextension 50147 "TFB Sales Price Worksheet" extends "Sales Price Worksheet" //7023
{
    fields
    {

        field(50148; "TFB New Per Kg Price"; Decimal)
        {
            Caption = 'New Per Kg Price';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Old code no longer used';
            DecimalPlaces = 2 : 4;
            MinValue = 0;
            MaxValue = 1000;


            trigger OnValidate()

            begin
                UpdateUnitPrice();
            end;
        }
        field(50149; "TFB Current Per Kg Price"; Decimal)
        {
            Caption = 'Existing Per Kg Price';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Old code no longer used';
            DecimalPlaces = 2 : 4;
            MinValue = 0;
            MaxValue = 1000;
            Editable = false;
        }
        field(50150; "TFB Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Old code no longer used';
            CalcFormula = sum(Item."Net Weight" where("No." = field("Item No.")));
            Editable = False;
        }

        modify("New Unit Price")
        {
            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
            end;
        }

        modify("Unit of Measure Code")
        {
            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
            end;
        }



    }



    local procedure UpdateUnitPrice()

    begin
        PriceUnit := PriceUnit::KG;
        If Item."No." <> '' then
            Rec.Validate("New Unit Price", TFBPricingLogic.CalculateUnitPriceByPriceUnit(rec."Item No.", rec."Unit of Measure Code", PriceUnit, rec."TFB New Per Kg Price"));
    end;

    local procedure UpdatePriceUnitPrice()

    begin
        PriceUnit := PriceUnit::KG;
        If Item."No." <> '' then
            "TFB New Per Kg Price" := TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."Item No.", rec."Unit of Measure Code", PriceUnit, rec."New Unit Price");
    end;

    var

        TFBPricingLogic: Codeunit "TFB Pricing Calculations";
        PriceUnit: Enum "TFB Price Unit";

}
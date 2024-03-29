pageextension 50199 "TFB Price List Lines" extends "Price List Lines"
{
    layout
    {
        addafter("Unit Price")
        {

            field(PriceByWeight; _PricePerKg)
            {
                ApplicationArea = All;
                DecimalPlaces = 2 : 4;
                BlankZero = true;
                Caption = 'Price per kg';
                Tooltip = 'Specifies the price per kg';
                Editable = Rec."Asset Type" = Rec."Asset Type"::Item;

                trigger OnValidate()

                begin
                    rec.UpdateUnitPriceFromAltPrice(_PricePerKg);
                end;

            }



        }

        modify("Unit Price")
        {
            trigger OnAfterValidate()

            begin
                _PricePerKg := GetPricePerKg();
            end;
        }

        modify("Asset No.")
        {

            trigger OnAfterValidate()

            begin
                _PricePerKg := GetPricePerKg();
            end;

        }

        modify(CurrencyCode)
        {
            Visible = false;
        }

        modify("Variant Code")
        {
            Visible = false;
        }
        modify("Work Type Code")
        {
            Visible = false;
        }
        modify("Unit of Measure Code")
        {
            Visible = true;
        }
        modify("Minimum Quantity")
        {
            Visible = false;
        }
        modify("Cost Factor")
        {
            Visible = false;
        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        PricingCU: CodeUnit "TFB Pricing Calculations";
        _PricePerKg: Decimal;

    trigger OnAfterGetRecord()

    begin
        _PricePerKg := GetPricePerKg();
    end;

    local procedure GetPricePerKg(): Decimal

    var
        Item: Record Item;

    begin
        if (Rec."Asset Type" = Rec."Asset Type"::Item) and (Rec."Asset No." <> '') then begin
            Item.Get(Rec."Asset No.");
            if Item."Net Weight" > 0 then
                exit(PricingCU.CalcPerKgFromUnit(Rec."Unit Price", Item."Net Weight"))
            else
                exit(0);
        end
        else
            exit(0);
    end;
}
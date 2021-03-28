pageextension 50199 "TFB Price List Lines" extends "Price List Lines"
{
    layout
    {
        addafter("Unit Price")
        {
            field(ProductWeight; _ProductWeight)
            {
                ApplicationArea = All;
                BlankZero = true;
                Caption = 'Product Weight';
                ToolTip = 'Specifies the weight of the product if applicable';
                Editable = false;
            }

            Field(PriceByWeight; _PricePerKg)
            {
                ApplicationArea = All;
                DecimalPlaces = 2 : 4;
                BlankZero = true;
                Caption = 'Price per kg';
                Tooltip = 'Specifies the price per kg';
                Editable = Rec."Asset Type" = Rec."Asset Type"::Item;

                trigger OnValidate()

                begin
                    rec.UpdateUnitPriceFromPerKgPrice(_PricePerKg);
                end;

            }



        }
        modify("Minimum Quantity")
        {
            Visible = false;
        }

        modify("Cost Factor")
        {
            Visible = false;
        }

        modify("Unit Price")
        {
            trigger OnAfterValidate()

            begin
                _PricePerKg := GetPricePerKgAndWeight();
            end;
        }

        modify("Asset No.")
        {

            trigger OnAfterValidate()

            begin
                _PricePerKg := GetPricePerKgAndWeight();
            end;

        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        PricingCU: CodeUnit "TFB Pricing Calculations";
        _ProductWeight: Decimal;
        _PricePerKg: Decimal;

    trigger OnAfterGetRecord()

    begin
        GetPricePerKgAndWeight();
    end;

    local procedure GetPricePerKgAndWeight(): Decimal

    var
        Item: Record Item;

    begin
        _PricePerKg := 0;

        If not (Rec."Asset Type" = Rec."Asset Type"::Item) then exit;
        if not Item.Get(Rec."Asset No.") then exit;
        If not (Item."Net Weight" > 0) then exit;
        _PricePerKg := PricingCU.CalcPerKgFromUnit(Rec."Unit Price", Item."Net Weight");
        _ProductWeight := Item."Net Weight";
    end;
}
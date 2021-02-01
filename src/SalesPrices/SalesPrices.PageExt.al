pageextension 50145 "TFB Sales Prices" extends "Sales Prices"
{
    layout
    {
        addafter("Unit Price")
        {

            Field(PriceByWeight; _PricePerKg)
            {
                ApplicationArea = All;
                DecimalPlaces = 2 : 4;
                BlankZero = true;
                Caption = 'Price per kg';
                Tooltip = 'Specifies the price per kg';

            }
        }
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        PricingCU: CodeUnit "TFB Pricing Calculations";
        _PricePerKg: Decimal;

    local procedure UpdatePricePerKg()

    var
        Item: Record Item;

    begin

        Item.Get(Rec."Item No.");
        If Item."Net Weight" > 0 then
            _PricePerKg := PricingCU.CalcPerKgFromUnit(Rec."Unit Price", Item."Net Weight")
        else
            _PricePerKg := 0;
    end;
}
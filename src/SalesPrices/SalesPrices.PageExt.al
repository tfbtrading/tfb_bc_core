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
 
        _PricePerKg: Decimal;

    
}
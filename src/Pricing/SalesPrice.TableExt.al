tableextension 50140 "TFB Sales Price" extends "Sales Price" //7002
{
    fields
    {
        field(50141; "TFB PriceByWeight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Per Kg Price';
            DecimalPlaces = 2 : 4;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by dynamic calculation';


        }


    }


}
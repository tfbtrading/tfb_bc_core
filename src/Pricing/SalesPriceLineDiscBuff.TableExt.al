tableextension 50148 "TFB Sales Price Line Disc Buff" extends "Sales Price and Line Disc Buff" //1304
{
    fields
    {
        field(50010; "TFB Price Per Kg"; Decimal)
        {
            Caption = 'Price Per Kg';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Calculated dynamically';
        }


    }

}
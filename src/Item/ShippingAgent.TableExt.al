tableextension 50107 "TFB Shipping Agent" extends "Shipping Agent"
{
    fields
    {
        field(50100; "TFB Service Default"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field(Code));
            ValidateTableRelation = true;
            Caption = 'Service Default';
        }

    }


}
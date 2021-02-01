tableextension 50103 "TFB Shipment Method" extends "Shipment Method" //10
{
    fields
    {
        field(50100; "TFB Freight Exclusive"; Boolean)
        {
            Caption = 'Freight Exclusive';
            DataClassification = CustomerContent;
        }

        field(50101; "TFB Pickup at Location"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Pickup at Store';
        }


    }

}
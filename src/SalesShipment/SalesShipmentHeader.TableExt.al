tableextension 50183 "TFB Sales Shipment Header" extends "Sales Shipment Header" //MyTargetTableId
{
    fields
    {
        field(50180; "TFB 3PL Booking No."; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = '3PL Booking No.';

        }


    }

}
table 50122 "TFB Customer Sales Line Buffer"
{
    DataClassification = CustomerContent;
    Caption = 'Sales Line Buffer';

    fields
    {
        field(10; "Order No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(20; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(30; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(40; "Quantity (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50; "Item Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(60; "Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(70; "Per Kg Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(80; "Order Created"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(90; Status; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(100; "Planned Shipment Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(110; "Planned Delivery Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(120; "Actual Shipment Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(130; DropShip; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(140; "Vendor Name"; text[100])
        {
            DataClassification = CustomerContent;
        }
        field(150; "Drop Ship Lead Time"; text[100])
        {
            DataClassification = CustomerContent;
        }
        field(160; "Qty Reserved from Stock"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(170; "Qty Reserved from Incoming"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(180; "Qty Shipped"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(190; "Incoming Details"; text[255])
        {
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; "Order No.", "Line No.")
        {
            Clustered = true;
        }
    }

}
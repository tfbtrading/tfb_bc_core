table 50126 "TFB Last Prices"
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {

        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Price Calculation Method"; Enum "Price Calculation Method")
        {

        }
        field(3; "Cost Calculation Method"; Enum "Price Calculation Method")
        {

        }
        field(5; "Item No."; Code[20])
        {

        }
        field(6; "Variant Code"; Code[10])
        {

        }
        field(7; "Item Disc. Group"; Code[20])
        {

        }
        field(8; "Dropship"; Boolean)
        {

        }

        field(10; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }

        field(13; "Prices Including Tax"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Tax %"; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(18; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(19; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(20; "Qty. per Unit of Measure"; Decimal)
        {

        }
        field(21; "Unit Discount Amount"; Decimal)
        {

        }

        field(24; "Unit Price"; Decimal)
        {

        }
        field(41; "Unit Price After Discount"; Decimal)
        {

        }
        field(50; "Price Unit Price"; Decimal)
        {

        }
        field(51; "Price Unit Discount Amount"; Decimal)
        {

        }
        field(52; "Price Unit After Discount"; Decimal)
        {

        }
        field(25; "Price Type"; Enum "Price Type")
        {

        }

        field(30; "Document Date"; Date)
        {

        }
        field(32; "Document No."; Code[20])
        {

        }
        field(37; "Document Type"; Enum "Sales Document Type")
        {

        }
        field(33; "Line No."; Integer)
        {

        }
        field(35; "Customer/Vendor No."; code[20])
        {
            Caption = 'Business Partner No.';

        }
        field(39; "Relationship Type"; Enum "TFB Last Prices Rel. Type")
        {

        }

        field(34; DrillDownRecordId; RecordId)
        {

        }
        field(42; "Price Group"; Code[10])
        {

        }

    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Date; "Document Date", "Document No.")
        {

        }
        key(Document; "Document No.", "Document Type")
        {

        }
    }

    var




}
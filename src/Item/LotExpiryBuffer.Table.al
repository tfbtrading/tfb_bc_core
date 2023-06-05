table 50107 "TFB Lot Expiry Buffer"
{
    Caption = 'Lot Expiry Buffer';
    ReplicateData = false;
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
            DataClassification = SystemMetadata;
        }
        field(10; "Description"; Text[100])
        {

        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
        }

        field(6; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Expiry Date"; Date)
        {
            Caption = 'Expiry Date';
            DataClassification = SystemMetadata;
        }
        field(7; "Qty. (Base)"; Decimal)
        {
            Caption = 'Qty. (Base)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Lot No.", "Expiry Date")
        {
            Clustered = true;
        }
        key(Expiry; "Expiry Date", "Item No.", "Lot No.", "Variant Code")
        {

        }

    }

    fieldgroups
    {
    }
}


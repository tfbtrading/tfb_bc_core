table 50120 "TFB Item Costing Filters"
{
#pragma warning disable AS0034
    TableType = Temporary;
#pragma warning restore AS0034

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(3; "Product Filter"; Text[2048])
        {
            Caption = 'Product Filter';
            DataClassification = SystemMetadata;
        }
        
        field(8; "Price List Code"; Code[20])
        {
            Caption = 'From Price List Code';
            DataClassification = SystemMetadata;
            TableRelation = "Price List Header";

        }

        field(18; "Close Existing Lines"; Boolean)
        {
            Caption = 'Copy Price List';
            DataClassification = SystemMetadata;
        }
        field(19; Worksheet; Boolean)
        {
            Caption = 'Worksheet';
            DataClassification = SystemMetadata;
        }
        
    }

    keys
    {
        key(PK; "Primary Key")
        { }
    }

    var

    procedure Initialize(PriceListHeader: Record "Price List Header"; CloseExistingLines: Boolean)
    var
    begin
   
       "Price List Code":= PriceListHeader.Code;
        Validate("Close Existing Lines", CloseExistingLines);
    end;
   

}
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

        "Price List Code" := PriceListHeader.Code;
        Validate("Close Existing Lines", CloseExistingLines);
    end;

    procedure EditAssetFilter()
    var
        ObjectTranslation: Record "Object Translation";
        PrimaryKeyField: Record "Field";
        FilterPageBuilder: FilterPageBuilder;
        TableCaptionValue: Text;
    begin
        TableCaptionValue :=
            ObjectTranslation.TranslateObject(ObjectTranslation."Object Type"::Table, Database::"TFB Item Costing Revised Lines");
        FilterPageBuilder.AddTable(TableCaptionValue, Database::"TFB Item Costing Revised Lines");
        if GetPrimaryKeyFields(Database::"TFB Item Costing Revised Lines", PrimaryKeyField) then
            repeat
                FilterPageBuilder.AddFieldNo(TableCaptionValue, PrimaryKeyField."No.")
            until PrimaryKeyField.Next() = 0;
        SetFilterByFilterPageBuilder("Product Filter", TableCaptionValue, FilterPageBuilder);
    end;

    local procedure GetPrimaryKeyFields(TableId: Integer; var PrimaryKeyField: Record "Field"): Boolean;
    begin
        PrimaryKeyField.Reset();
        PrimaryKeyField.SetRange(TableNo, TableId);
        PrimaryKeyField.Setrange(IsPartOfPrimaryKey, true);
        exit(PrimaryKeyField.FindSet());
    end;

    local procedure SetFilterByFilterPageBuilder(var FilterValue: Text[2048]; TableCaptionValue: Text; var FilterPageBuilder: FilterPageBuilder)
    begin
        if FilterValue <> '' then
            FilterPageBuilder.SetView(TableCaptionValue, FilterValue);
        if FilterPageBuilder.RunModal() then
            FilterValue := CopyStr(FilterPageBuilder.GetView(TableCaptionValue, false), 1, MaxStrLen(FilterValue));

    end;

}
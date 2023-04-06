table 50111 "TFB Generic Item"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Generic Items";
    DrillDownPageId = "TFB Generic Items";
    Caption = 'Generic Item';

    fields
    {

        field(10; "Description"; Text[255])
        {
            Caption = 'Description';
        }
        field(15; Type; Enum "TFB Generic Item Type")
        {
            Caption = 'Type';
            Editable = false;

        }
        field(20; "Rich Description"; Text[2048])
        {
            Caption = 'Marketing Copy';
        }
        field(25; "Full Description"; Blob)
        {
            Caption = 'Full Description';
            DataClassification = CustomerContent;
            ObsoleteReason = 'Replaced by marketing copy';
            ObsoleteState = Pending;
        }
        field(30; "Alternative Names"; Text[255])
        {
            Caption = 'Alternative Names';
            DataClassification = CustomerContent;

        }
        field(92; Picture; MediaSet)
        {
            Caption = 'Picture';

            trigger OnValidate()

            var
                Item: Record Item;
                Index: Integer;

            begin

                Item.SetRange("TFB Generic Item ID", SystemId);

                If Item.Findset(true) then
                    repeat
                        If Rec.Picture.Count > 0 then
                            For Index := 1 to Rec.Picture.Count do begin
                                Item.Picture.Insert(Rec.Picture.Item(Index));
                                Item.Modify(true);
                            end;

                    until Item.Next() = 0;

            end;
        }
        field(100; "Do Not Publish"; Boolean)
        {
            Caption = 'Do Not Publish';

        }
        field(5702; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";

            trigger OnValidate()

            begin

                UpdateItemCategoryId();
            end;
        }

        field(8005; "Item Category Id"; Guid)
        {
            Caption = 'Item Category Id';
            DataClassification = SystemMetadata;
            TableRelation = "Item Category".SystemId;

            trigger OnValidate()
            begin
                UpdateItemCategoryCode();
            end;
        }

        field(9000; "No. Of Items"; Integer)
        {
            Caption = 'No. Of Items';
            FieldClass = FlowField;
            CalcFormula = Count(Item where("TFB Generic Item ID" = field(SystemId)));

        }
        field(9010; "External ID"; Text[255])
        {
            Caption = 'External ID';

        }


    }

    keys
    {
        key(Description; Description)
        {
            Clustered = true;
        }

    }

    fieldgroups
    {
        fieldgroup(Brick; Description, "Item Category Code", Type, "No. Of Items", Picture)
        { }

        fieldgroup(Dropdown; Description, "Item Category Code", Type, "No. Of Items")
        { }
    }

    local procedure UpdateItemCategoryCode()
    var
        ItemCategory: Record "Item Category";
    begin
        if IsNullGuid("Item Category Id") then
            ItemCategory.GetBySystemId("Item Category Id");

        "Item Category Code" := ItemCategory.Code;
    end;

    /// <summary>
    /// UpdateItemCategoryId.
    /// </summary>
    local procedure UpdateItemCategoryId()
    var
        ItemCategory: Record "Item Category";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if IsTemporary then
            exit;

        if not GraphMgtGeneralTools.IsApiEnabled() then
            exit;

        if "Item Category Code" = '' then begin
            Clear("Item Category Id");
            exit;
        end;

        if not ItemCategory.Get("Item Category Code") then
            exit;

        "Item Category Id" := ItemCategory.SystemId;
    end;



    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()

    var
        Item: Record Item;
        GenericItemMarketRel: Record "TFB Generic Item Market Rel.";
        GuidVar: Guid;
    begin

        If Rec.Type = Rec.Type::ItemExtension then begin

            Item.SetRange("TFB Generic Item ID", Rec.SystemId);
            If Item.FindFirst() then begin
                clear(GuidVar);
                Item."TFB Generic Item ID" := GuidVar;
                Item."TFB Parent Generic Item Name" := '';
                Item."TFB Act As Generic" := false;
                Item.Modify(false);
            end;

        end
        else begin

            Item.SetRange("TFB Generic Item ID", Rec.SystemId);
            If item.Count() > 0 then
                If Confirm('Items exist. Do you still want to delete this item?', false) then
                    If Item.FindSet() then
                        repeat
                            Clear(Item."TFB Generic Item ID");
                            Item."TFB Parent Generic Item Name" := '';
                            Item."TFB Act As Generic" := false;
                            Item.Modify(false);
                        until Item.Next() = 0
                    else
                        error('Items exist cannot delete parent');
        end;


        GenericItemMarketRel.SetRange(GenericItemID, Rec.SystemId);
        If GenericItemMarketRel.Count > 0 then
            GenericItemMarketRel.DeleteAll(false);


    end;




    trigger OnRename()
    begin

    end;

    /// <summary>
    /// Switch type should be the only way in which the type of the record can be changed with a new record.
    /// </summary>
    /// <param name="NewType">Enum "TFB Generic Item Type".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure SwitchType(NewType: Enum "TFB Generic Item Type"): Boolean
    var
        Item: Record Item;
    begin

        case Rec.Type of
            Rec.Type::ItemParent:


                case NewType of
                    NewType::ItemParent:
                        Error('No change to current type');
                    NewType::ItemExtension:
                        begin
                            Item.SetRange("TFB Generic Item ID", Rec.SystemId);
                            Case Item.Count() of
                                0:
                                    Error('No items currently are set to this generic item');
                                1:
                                    If Item.FindFirst() then begin
                                        Item."TFB Act As Generic" := true;
                                        Item.Modify(false);
                                        Rec.Type := NewType;
                                        Rec.Modify(false);
                                    end
                                    else
                                        error('More than one item refers to this generic item. It cannot be turned into an extension');
                            end;

                        end;

                end;



            Rec.Type::ItemExtension:

                case NewType of
                    NewType::ItemParent:
                        begin
                            Item.SetRange("TFB Generic Item ID", Rec.SystemId);
                            Case Item.Count() of
                                0:
                                    begin
                                        Rec.Type := NewType;
                                        Rec.Modify();
                                    end;
                                1:
                                    If Item.FindFirst() then begin
                                        Item."TFB Act As Generic" := false;
                                        Item."TFB Parent Generic Item Name" := Rec.Description;
                                        Item."TFB Generic Item ID" := Rec.SystemId;
                                        Item.Modify(false);
                                        Rec.Type := NewType;
                                        Rec.Modify(false);
                                    end
                                    else begin
                                        Rec.Type := NewType;
                                        Rec.Modify();
                                    end;
                            end;
                        end;
                    NewType::ItemExtension:
                        Error('No change to current type');
                end;


        end;

    end;



}
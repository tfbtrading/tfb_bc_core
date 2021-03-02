table 50111 "TFB Generic Item"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Generic Items";
    DrillDownPageId = "TFB Generic Items";

    fields
    {

        field(10; "Description"; Text[255])
        {
            Caption = 'Short Description';
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
        field(92; Picture; MediaSet)
        {
            Caption = 'Picture';
        }
        field(5702; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";

            trigger OnValidate()
            var
                ItemAttributeManagement: Codeunit "Item Attribute Management";
            begin

                UpdateItemCategoryId;
            end;
        }

        field(8005; "Item Category Id"; Guid)
        {
            Caption = 'Item Category Id';
            DataClassification = SystemMetadata;
            TableRelation = "Item Category".SystemId;

            trigger OnValidate()
            begin
                UpdateItemCategoryCode;
            end;
        }

        field(9000; "No. Of Items"; Integer)
        {
            Caption = 'No. Of Items';
            FieldClass = FlowField;
            CalcFormula = Count(Item where("TFB Generic Item ID" = field(SystemId)));

        }

    }

    keys
    {
        key(Description; Description)
        {
            Clustered = true;
        }

    }

    local procedure UpdateItemCategoryCode()
    var
        ItemCategory: Record "Item Category";
    begin
        if IsNullGuid("Item Category Id") then
            ItemCategory.GetBySystemId("Item Category Id");

        "Item Category Code" := ItemCategory.Code;
    end;

    procedure UpdateItemCategoryId()
    var
        ItemCategory: Record "Item Category";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if IsTemporary then
            exit;

        if not GraphMgtGeneralTools.IsApiEnabled then
            exit;

        if "Item Category Code" = '' then begin
            Clear("Item Category Id");
            exit;
        end;

        if not ItemCategory.Get("Item Category Code") then
            exit;

        "Item Category Id" := ItemCategory.SystemId;
    end;

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()

    var
        Item: Record Item;
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
            If item.Count() > 0 then begin
                If Confirm('Items exist. Do you still want to delete this item?', false) then
                    If Item.FindSet() then
                        repeat begin
                            Clear(Item."TFB Generic Item ID");
                            Item."TFB Parent Generic Item Name" := '';
                            Item."TFB Act As Generic" := false;
                            Item.Modify(false);
                        end until Item.Next() = 0
                    else
                        error('Items exist cannot delete parent');
            end;
        end;
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
                begin

                    case NewType of
                        NewType::ItemParent:
                            begin

                                Error('No change to current type');

                            end;

                        NewType::ItemExtension:
                            begin

                                Item.SetRange("TFB Generic Item ID", Rec.SystemId);
                                Case Item.Count() of
                                    0:
                                        Error('No items currently are set to this generic item');
                                    1:
                                        begin

                                            If Item.FindFirst() then begin
                                                Item."TFB Act As Generic" := true;
                                                Item.Modify(false);
                                                Rec.Type := NewType;
                                                Rec.Modify(false);
                                            end

                                        end;
                                    else
                                        error('More than one item refers to this generic item. It cannot be turned into an extension');
                                end;

                            end;

                    end;

                end;

            Rec.Type::ItemExtension:
                begin
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
                                        begin

                                            If Item.FindFirst() then begin
                                                Item."TFB Act As Generic" := false;
                                                Item.Modify(false);
                                                Rec.Type := NewType;
                                                Rec.Modify(false);
                                            end

                                        end;
                                    else begin
                                            Rec.Type := NewType;
                                            Rec.Modify();
                                        end;

                                end;
                            end;
                        NewType::ItemExtension:
                            begin

                                Error('No change to current type');

                            end;

                    end;


                end;

        end;

    end;

}
/// <summary>
/// Page TFB APIV2 - Generic Items (ID 50140).
/// </summary>
page 50140 "TFB APIV2 - Generic Items"
{
    APIVersion = 'v2.0';
    EntityCaption = 'GenericItem';
    EntitySetCaption = 'GenericItems';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'genericitem';
    EntitySetName = 'genericitems';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "TFB Generic Item";
    Extensible = false;
    APIPublisher = 'tfb';
    APIGroup = 'supplychain';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }

                field(displayName; Rec.Description)
                {
                    Caption = 'DisplayName';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Description));
                    end;
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Type));
                    end;
                }
                field(itemCategoryId; Rec."Item Category Id")
                {
                    Caption = 'Item Category Id';

                    trigger OnValidate()
                    begin
                        if Rec."Item Category Id" = BlankGUID then
                            Rec."Item Category Code" := ''
                        else begin
                            if not ItemCategory.GetBySystemId(Rec."Item Category Id") then
                                Error(ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr);

                            Rec."Item Category Code" := ItemCategory.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Item Category Code"));
                        RegisterFieldSet(Rec.FieldNo("Item Category Id"));
                    end;
                }
                field(itemCategoryCode; Rec."Item Category Code")
                {
                    Caption = 'Item Category Code';

                    trigger OnValidate()
                    begin
                        if ItemCategory.Code <> '' then begin
                            if ItemCategory.Code <> Rec."Item Category Code" then
                                Error(ItemCategoriesValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Item Category Code" = '' then
                            Rec."Item Category Id" := BlankGUID
                        else begin
                            if not ItemCategory.Get(Rec."Item Category Code") then
                                Error(ItemCategoryCodeDoesNotMatchATaxGroupErr);

                            Rec."Item Category Id" := ItemCategory.SystemId;
                        end;
                    end;
                }
                field(alternativeNames; Rec."Alternative Names")
                {
                    Caption = 'Alternative Names';
                    Editable = true;
                }


                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                field(externalID; Rec."External ID")
                {
                    Caption = 'External ID';
                    Editable = true;

                }
                field(doNotPublish; Rec."Do Not Publish")
                {
                    Caption = 'External ID';
                    Editable = true;
                }

                part(picture; "TFB APIV2 - Custom Pictures")
                {
                    Caption = 'Picture';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(GenericItem);
                }

            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin


        InsertGenericItem(Rec, TempFieldSet);

        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        GenericItem: Record "TFB Generic Item";
    begin

        GenericItem.GetBySystemId(Rec.SystemId);

        if Rec.Description = GenericItem.Description then
            Rec.Modify(true)
        else begin
            GenericItem.TransferFields(Rec, false);
            GenericItem.Rename(Rec.Description);
            Rec.TransferFields(GenericItem, true);
        end;

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields("No. Of Items");
    end;


    /// <summary>
    /// InsertGenericItem.
    /// </summary>
    /// <param name="GenericItem">VAR Record "TFB Generic Item".</param>
    /// <param name="TempFieldSet">Temporary VAR Record "Field".</param>
    [Scope('Cloud')]
    procedure InsertGenericItem(var GenericItem: Record "TFB Generic Item"; var LclTempFieldSet: Record "Field" temporary)
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecRef: RecordRef;
    begin
        If IsNullGuid(GenericItem.SystemId) then
            GenericItem.Insert(true)
        else
            GenericItem.Insert(true, true);

        RecRef.GetTable(GenericItem);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, LclTempFieldSet, GenericItem.SystemModifiedAt);
        RecRef.SetTable(GenericItem);

        GenericItem.Modify(true);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

        ItemCategory: Record "Item Category";

        //GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item"; Doesn't appear to yet serve a useful function
        BlankGUID: Guid;
        ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr: Label 'The "itemCategoryId" does not match to a specific Item Category group.', Comment = 'itemCategoryId is a field name and should not be translated.';
        ItemCategoriesValuesDontMatchErr: Label 'The item categories values do not match to a specific item category.';
        ItemCategoryCodeDoesNotMatchATaxGroupErr: Label 'The "itemCategoryCode" does not match to a Item Category.', Comment = 'itemCategoryCode is a field name and should not be translated.';


    local procedure SetCalculatedFields()
    var

    begin
        // Inventory

    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(Rec.SystemId);

        TempFieldSet.DeleteAll();
    end;


    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Item, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Item;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}
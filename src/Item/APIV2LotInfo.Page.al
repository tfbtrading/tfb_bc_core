page 50165 "TFB APIV2 - Lot Info"
{
    APIVersion = 'v2.0';
    EntityCaption = 'LotNoInfo';
    EntitySetCaption = 'LotNoInfoList';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'lotNoInfo';
    EntitySetName = 'lotNoInfoList';
    ODataKeyFields = SystemId;
    PageType = API;
    APIPublisher = 'tfb';
    APIGroup = 'supplychain';
    SourceTable = "Lot No. Information";
    Extensible = false;
    InsertAllowed = false;

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
                field(number; Rec."Item No.")
                {
                    Caption = 'Number';
                    Editable = false;
                }

                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'VariantCode';
                    Editable = false;
                }
                field(lotNo; Rec."Lot No.")
                {
                    Caption = 'LotNo';
                }

                field(LatestReceiptDate; LatestReceiptDate)
                {
                    Caption = 'LatestReceiptDate';
                }
                field(LatestReceiptReference; LatestReceiptReference)
                {
                    Caption = 'LatestReceiptReference';
                }
                field(LatestReceiptWarehouseLocation; LatestReceiptWarehouseLocation)
                {
                    Caption = 'LatestReceiptWarehouseLocation';
                }
                field(displayName; Rec."TFB Item Description")
                {
                    Caption = 'DisplayName';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Rec."TFB Item Description"));
                    end;
                }


                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Blocked));
                    end;
                }

                field(blockedUntil; Rec."TFB Date Available")
                {
                    Caption = 'Blocked Until';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB Date Available"));
                    end;
                }
                field(sampleImageExists; Rec."TFB Sample Picture Exists")
                {
                    Caption = 'SampeImageExists';

                    Editable = false;
                }

                part(picture; "TFB APIV2 - Custom Pictures")
                {
                    Caption = 'Picture';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(Sample);
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }


            }


        }
    }

    actions
    {
    }

    var
        LatestReceiptDate: Date;
        LatestReceiptReference: Code[20];
        LatestReceiptWarehouseLocation: Code[20];


    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        exit(InsertItem());
    end;

    trigger OnModifyRecord(): Boolean
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        if IsInsert then
            exit(InsertItem());

        if TempFieldSet.Get(Database::Item, Rec.FieldNo(Inventory)) then
            error('Cannot update inventory quantity via API');

        LotNoInfo.GetBySystemId(Rec.SystemId);

        if (Rec."Item No." = LotNoInfo."Item No.") and (Rec."Variant Code" = LotNoInfo."Variant Code") and (Rec."Lot No." = LotNoInfo."Lot No.") then
            Rec.Modify(true)
        else
            error('Cannot rename a lot no information record');


        SetCalculatedFields();

        exit(false);
    end;

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields(Inventory);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsInsert := true;
        ClearCalculatedFields();
    end;

    var
        TempFieldSet: Record 2000000041 temporary;
        ItemCategory: Record "Item Category";
        TaxGroup: Record "Tax Group";
        ValidateUnitOfMeasure: Record "Unit of Measure";
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
        InventoryValue: Decimal;
        BlankGUID: Guid;
        BaseUnitOfMeasureIdValidated: Boolean;
        BaseUnitOfMeasureCodeValidated: Boolean;
        IsInsert: Boolean;
        TaxGroupValuesDontMatchErr: Label 'The tax group values do not match to a specific Tax Group.';
        TaxGroupIdDoesNotMatchATaxGroupErr: Label 'The "taxGroupId" does not match to a Tax Group.', Comment = 'taxGroupId is a field name and should not be translated.';
        TaxGroupCodeDoesNotMatchATaxGroupErr: Label 'The "taxGroupCode" does not match to a Tax Group.', Comment = 'taxGroupCode is a field name and should not be translated.';
        ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr: Label 'The "itemCategoryId" does not match to a specific Item Category group.', Comment = 'itemCategoryId is a field name and should not be translated.';
        ItemCategoriesValuesDontMatchErr: Label 'The item categories values do not match to a specific item category.';
        ItemCategoryCodeDoesNotMatchATaxGroupErr: Label 'The "itemCategoryCode" does not match to a Item Category.', Comment = 'itemCategoryCode is a field name and should not be translated.';
        InventoryCannotBeChangedInAPostRequestErr: Label 'Inventory cannot be changed during on insert.';
        UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr: Label 'The "baseUnitOfMeasureId" does not match to a Unit of Measure.', Comment = 'baseUnitOfMeasureId is a field name and should not be translated.';
        UnitOfMeasureValuesDontMatchErr: Label 'The unit of measure values do not match to a specific Unit of Measure.';

    local procedure InsertItem(): Boolean
    begin
        if TempFieldSet.Get(Database::Item, Rec.FieldNo(Inventory)) then
            Error(InventoryCannotBeChangedInAPostRequestErr);


        GraphModifyLotNoInfo(Rec, TempFieldSet);

        SetCalculatedFields();
        Clear(IsInsert);
        exit(false);
    end;

    local procedure "Pic as JSON"(LotNoInfoID: GUID): Text;
    var
        LotNoInfo: Record "Lot No. Information";
        TenantMedia: Record "Tenant Media";
        PicText: Text;
        PicInstr: InStream;
        JObject: JsonObject;
        JToken: JsonToken;
        TempBlob: Codeunit "Temp Blob";
        PicOStr: OutStream;
        Base64: Codeunit "Base64 Convert";
    begin
        LotNoInfo.Get(LotNoInfoID);
        If LotNoInfo."TFB Sample Picture".Count = 0 then
            exit('');
        TenantMedia.Get(LotNoInfo."TFB Sample Picture".Item(1));
        TenantMedia.CalcFields(Content);
        if TenantMedia.Content.HasValue then begin
            Clear(PicText);
            Clear(PicInstr);
            TenantMedia.Content.CreateInStream(PicInstr);
            PicText := Base64.ToBase64(PicInstr);
            JObject.Add('picture', PicText);
            JObject.SelectToken('picture', JToken);
        end;
        exit(JToken.AsValue().AsText());
    end;

    procedure GraphModifyLotNoInfo(var LotNoInfo: Record "Lot No. Information"; var TempFieldSet: Record "Field" temporary)
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(LotNoInfo);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, TempFieldSet, LotNoInfo.SystemModifiedAt);
        RecRef.SetTable(LotNoInfo);

        LotNoInfo.Modify(true);
    end;

    local procedure SetCalculatedFields()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ReceiptLine: Record "Purch. Rcpt. Line";
    begin
        // Inventory
        InventoryValue := Rec.Inventory;

        ItemLedgerEntry.SetRange("Lot No.", Rec."Lot No.");
        ItemLedgerEntry.SetRange("Item No.", Rec."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", Rec."Variant Code");
        ItemLedgerEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Purchase Receipt", ItemLedgerEntry."Document Type"::"Transfer Receipt");

        ItemLedgerEntry.SetLoadFields("Document Line No.", "Document No.", "Location Code", "Posting Date");
        If ItemLedgerEntry.FindLast() then begin
            LatestReceiptDate := ItemLedgerEntry."Posting Date";
            LatestReceiptWarehouseLocation := ItemLedgerEntry."Location Code";
            ReceiptLine.SetLoadFields("Order No.");
            if ReceiptLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                LatestReceiptReference := ReceiptLine."Order No.";

        end;

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
page 50168 "TFB APIV2 - Item Ledger Rcpt."
{
    APIVersion = 'v2.0';
    EntityCaption = 'ItemLedgerReceipt';
    EntitySetCaption = 'ItemLedgerReceipts';
    ChangeTrackingAllowed = true;
    ModifyAllowed = false;
    EntityName = 'itemLedgerReceipt';
    EntitySetName = 'itemLedgerReceipts';
    ODataKeyFields = SystemId;
    PageType = API;
    APIPublisher = 'tfb';
    APIGroup = 'supplychain';
    SourceTable = "Item Ledger Entry";
    SourceTableView = where("Entry Type" = filter(Purchase | Transfer), Quantity = filter(> 0), Nonstock = const(false), "Lot No." = filter(<> ''), "Document Type" = const("Purchase Invoice"));
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
                field(dropShipment; Rec."Drop Shipment")
                {
                    Caption = 'DropShipment';

                }

                field(LatestReceiptDate; Rec."Posting Date")
                {
                    Caption = 'LatestReceiptDate';
                }
                field(LatestReceiptReference; Rec."Order No.")
                {
                    Caption = 'LatestReceiptReference';
                }
                field(LatestReceiptWarehouseLocation; Rec."Location Code")
                {
                    Caption = 'LatestReceiptWarehouseLocation';
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'DisplayName';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Rec.Description));
                    end;
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



    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

    end;

    trigger OnModifyRecord(): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin



        ItemLedgerEntry.GetBySystemId(Rec.SystemId);

        if (Rec."Item No." = ItemLedgerEntry."Item No.") and (Rec."Variant Code" = ItemLedgerEntry."Variant Code") and (Rec."Lot No." = ItemLedgerEntry."Lot No.") then
            Rec.Modify(true)
        else
            error('Cannot rename a lot no information record');


        SetCalculatedFields();

        exit(false);
    end;

    trigger OnOpenPage()
    begin

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

    /*   procedure GraphModifyLotNoInfo(var LotNoInfo: Record "Lot No. Information"; var TempFieldSet: Record "Field" temporary)
      var
          GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
          RecRef: RecordRef;
      begin
          RecRef.GetTable(LotNoInfo);
          GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, TempFieldSet, LotNoInfo.SystemModifiedAt);
          RecRef.SetTable(LotNoInfo);

          LotNoInfo.Modify(true);
      end; */

    local procedure SetCalculatedFields()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ReceiptLine: Record "Purch. Rcpt. Line";
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
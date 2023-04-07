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
    ApplicationArea = All;


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

                field(latestReceiptDate; LatestReceiptDate)
                {
                    Caption = 'LatestReceiptDate';
                }
                field(latestReceiptReference; LatestReceiptReference)
                {
                    Caption = 'LatestReceiptReference';
                }
                field(latestReceiptWarehouseLocation; LatestReceiptWarehouseLocation)
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
                    SubPageLink = Id = field(SystemId), "Parent Type" = const(Sample);
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
        LatestReceiptReference: Code[20];
        LatestReceiptWarehouseLocation: Code[20];
        LatestReceiptDate: Date;


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
     
       
        IsInsert: Boolean;
        InventoryValue: Decimal;
        InventoryCannotBeChangedInAPostRequestErr: Label 'Inventory cannot be changed during on insert.';
        

    local procedure InsertItem(): Boolean
    begin
        if TempFieldSet.Get(Database::Item, Rec.FieldNo(Inventory)) then
            Error(InventoryCannotBeChangedInAPostRequestErr);


        GraphModifyLotNoInfo(Rec, TempFieldSet);

        SetCalculatedFields();
        Clear(IsInsert);
        exit(false);
    end;

    

    procedure GraphModifyLotNoInfo(var LotNoInfo: Record "Lot No. Information"; var LclTempFieldSet: Record "Field" temporary)
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(LotNoInfo);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, LclTempFieldSet, LotNoInfo.SystemModifiedAt);
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
        if ItemLedgerEntry.FindLast() then begin
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
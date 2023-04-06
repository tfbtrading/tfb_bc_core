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
    SourceTableView = where("Entry Type" = filter(Purchase | Transfer), Quantity = filter(> 0), Nonstock = const(false), "Drop Shipment" = const(false), "Lot No." = filter('<>'''''), "Document Type" = filter('<>Purchase Invoice'), Positive = const(true), "Location Code" = filter('EFFLOG'), "Posting Date" = filter('>today-60d'));
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

                field(latestReceiptDate; Rec."Posting Date")
                {
                    Caption = 'LatestReceiptDate';
                }
                field(latestReceiptReference; Rec."Order No.")
                {
                    Caption = 'LatestReceiptReference';
                }
                field(latestReceiptWarehouseLocation; Rec."Location Code")
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
                field(lotImageCount; Rec."TFB No. Of Lot Images")
                {
                    Caption = 'LotImageCount';
                    Editable = false;

                }



                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }

                part(lotImages; "TFB APIV2 - Lot Images")
                {
                    Caption = 'LotImages';
                    Multiplicity = Many;
                    EntityName = 'lotImage';
                    EntitySetName = 'lotImages';
                    SubPageLink = "Item Ledger Entry ID" = field(SystemId);
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


        IsInsert: Boolean;




    local procedure SetCalculatedFields()
    var

    begin
        // Inventory
        Rec.CalcFields("TFB No. Of Lot Images");



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
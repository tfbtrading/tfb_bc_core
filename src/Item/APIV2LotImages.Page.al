page 50169 "TFB APIV2 - Lot Images"
{
    APIVersion = 'v2.0';
    EntityCaption = 'LotImage';
    EntitySetCaption = 'LotImages';
    ChangeTrackingAllowed = true;

    EntityName = 'lotImage';
    EntitySetName = 'lotImages';
    ODataKeyFields = SystemId;
    PageType = API;
    APIPublisher = 'tfb';
    APIGroup = 'supplychain';
    SourceTable = "TFB Lot Image";
    Extensible = false;
    InsertAllowed = true;
    ModifyAllowed = true;
    DelayedInsert = true;

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
                field(itemLedgerEntryID; Rec."Item Ledger Entry ID")
                {

                    Caption = 'ItemLedgerEntryID';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Rec."Item Ledger Entry ID"));
                    end;
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
                field(displayName; Rec.Description)
                {
                    Caption = 'DisplayName';
                    Editable = false;

                }


                field(lotNo; Rec."Lot No.")
                {
                    Caption = 'LotNo';
                    Editable = false;

                }
                field(importSequenceNo; Rec."Import Sequence No.")
                {
                    Caption = 'ImportSequenceNo';
                    Editable = false;

                }
                field(originalBlobImageName; Rec."Orig. Image Blob Name")
                {
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Rec."Orig. Image Blob Name"));
                    end;
                }
                field(isolatedBlobImageName; Rec."Isol. Image Blob Name")
                {
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Rec."Isol. Image Blob Name"));
                    end;
                }

                field(createdAt; Rec.SystemCreatedAt)
                {
                    Caption = 'LatestReceiptDate';
                    Editable = false;
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

    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if not Rec.InitFromItemLedgerEntryID(Rec."Item Ledger Entry ID") then
            error('No valid item ledger entry identifier provided');
        Rec."Import Sequence No." := Rec.GetNextSequence();
    end;

    trigger OnModifyRecord(): Boolean
    var

        LotImage: Record "TFB Lot Image";
    begin



        LotImage.GetBySystemId(Rec.SystemId);

        if (Rec."Item No." = LotImage."Item No.") and (Rec."Item Ledger Entry ID" = LotImage."Item Ledger Entry ID") and (Rec."Variant Code" = LotImage."Variant Code") and (Rec."Lot No." = LotImage."Lot No.") then
            Rec.Modify(true)
        else
            error('Cannot change key details of a lot image record');




        exit(false);
    end;

    trigger OnOpenPage()

    var
        StorageServiceAuth: CodeUnit "Storage Service Authorization";
        ContainerName: Text;
        SharedKey: Text;
        StorageAccount: Text;
    begin
        ContainerName := '';
        StorageAccount := '';
        Authorization := StorageServiceAuth.CreateSharedKey(SharedKey);
        ABSClient.Initialize(StorageAccount, ContainerName, Authorization);
    end;

    procedure SetupAzure()

    begin

    end;


    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsInsert := true;



    end;

    var


        TempFieldSet: Record 2000000041 temporary;

        ABSClient: CodeUnit "ABS Blob Client";

        IsInsert: Boolean;

        Authorization: Interface "Storage Service Authorization";







    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::"TFB Lot Image", FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::"TFB Lot Image";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}
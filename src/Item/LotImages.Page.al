page 50170 "TFB Lot Images"
{

    PageType = List;
    Caption = 'Lot Images';
    SourceTable = "TFB Lot Image";
    UsageCategory = Administration;
    ApplicationArea = All;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    DelayedInsert = false;
    Editable = true;
    InstructionalText = 'Used to view lot images';

    layout
    {
        area(content)
        {
            repeater(Group)
            {

                field("Item No."; Rec."Item No.")
                {
                    Caption = 'Item No.';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }

                field(Description; Rec.Description)
                {
                    Caption = 'Item Description';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Description field.';

                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {
                    Caption = 'Ledger Entry No.';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Ledger Entry No. field.';
                    DrillDown = false;
                }
                field("Item Ledger Entry Type"; Rec."Item Ledger Entry Type")
                {
                    Caption = 'Ledger Entry Type';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Ledger Entry Type field.';
                    DrillDown = false;
                }

                field("Lot No."; Rec."Lot No.")
                {
                    Caption = 'Lot No';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Lot No field.';

                }
                field("Import Sequence No."; Rec."Import Sequence No.")
                {
                    Caption = 'Import Sequence No';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Sequence No field.';
                }

                field(createdAt; getCreatedDateTime())
                {
                    Caption = 'Created on';
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';

                }


            }


        }
    }

    actions
    {
        area(Processing)
        {
            action("TFB Get Lot Image Wizard")
            {
                ApplicationArea = All;
                Image = Picture;
                Caption = 'Get Lot Image Wizard';
                Enabled = true;
                ToolTip = 'Open lot image wizard';

                trigger OnAction()

                var
                    ItemLedger: Record "Item Ledger Entry";
                    GetWizard: Page "TFB Lot Get Image Wizard";
                begin
                    If not ItemLedger.GetBySystemId(Rec."Item Ledger Entry ID") then exit;
                    GetWizard.InitFromItemLedger(ItemLedger);
                    GetWizard.RunModal();

                end;
            }
        }

        area(Promoted)
        {
            Group(Category_Home)
            {
                Caption = 'Home';

                actionref(ActionRefName; "TFB Get Lot Image Wizard")
                {

                }
            }
        }
    }

    var



    trigger OnAfterGetRecord()
    begin

    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        If not Rec.InitFromItemLedgerEntryID(Rec."Item Ledger Entry ID") then
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
        ContainerName := 'images';
        StorageAccount := 'tfbmanipulator';
        SharedKey := 'ZcRda2sapxTDjYc3nfGFN0UpDK5XQiq3lDgQ8iP2WEkdnleReEo+pbKVzMbPOpOKj8ZatNM7PugEQrp+MeVkjA==';
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




        ABSClient: CodeUnit "ABS Blob Client";


        IsInsert: Boolean;

        Authorization: Interface "Storage Service Authorization";








    local procedure getCreatedDateTime(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        Exit(TypeHelper.FormatDateTime(rec.SystemCreatedAt, 'dd/MM/yy HH:mm', TypeHelper.GetCultureName()))

    end;
}
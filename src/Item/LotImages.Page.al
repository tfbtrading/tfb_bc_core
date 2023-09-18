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
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }

                field(Description; Rec.Description)
                {
                    Caption = 'Item Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Description field.';

                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {
                    Caption = 'Ledger Entry No.';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Ledger Entry No. field.';
                    DrillDown = false;
                }
                field("Item Ledger Entry Type"; Rec."Item Ledger Entry Type")
                {
                    Caption = 'Ledger Entry Type';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Ledger Entry Type field.';
                    DrillDown = false;
                }

                field("Lot No."; Rec."Lot No.")
                {
                    Caption = 'Lot No';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Lot No field.';

                }
                field("Import Sequence No."; Rec."Import Sequence No.")
                {
                    Caption = 'Import Sequence No';
                    ToolTip = 'Specifies the value of the Import Sequence No field.';
                }
                field("Isol. Image Blob Name"; Rec."Isol. Image Blob Name")
                {
                    Caption = 'Isolated Blob Name';
                    ToolTip = 'Specifies the name of the isolated blob image';
                    Visible = false;
                }
                field("Default for Generic Item"; Rec."Default for Generic Item")
                {
                    Caption = 'Def. for Generic Item';
                    Visible = true;
                    ToolTip = 'Indicates if lot image is default for a generic item';
                }
                field("Default for Item"; Rec."Default for Item")
                {
                    Caption = 'Def. for Item';
                    Visible = true;
                    ToolTip = 'Indicates if lot image is default for an item';
                }


                field(createdAt; getCreatedDateTime())
                {
                    Caption = 'Created on';
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';

                }


            }


        }
        area(FactBoxes)
        {
            part(Picture; "TFB Lot Image Picture")
            {
                SubPageLink = SystemId = field(SystemId);
            }

        }
    }

    actions
    {
        area(Processing)
        {
            action("TFB Get Lot Image Wizard")
            {
                Image = Picture;
                Caption = 'Get Lot Image Wizard';
                Enabled = true;
                ToolTip = 'Open lot image wizard';

                trigger OnAction()

                var
                    ItemLedger: Record "Item Ledger Entry";
                    GetWizard: Page "TFB Lot Get Image Wizard";
                begin
                    if not ItemLedger.GetBySystemId(Rec."Item Ledger Entry ID") then exit;
                    GetWizard.InitFromItemLedger(ItemLedger);
                    GetWizard.RunModal();

                end;
            }
            action(SetAsItemDefault)
            {
                Image = Item;
                Caption = 'Set as Item Default';
                Enabled = not Rec."Default for Item";
                ApplicationArea = All;
                ToolTip = 'Specifies that the item should be a default for the item';

                trigger OnAction()

                begin
                    Rec.Validate("Default for Item", true);
                    Rec.Modify(false);
                end;
            }
            action(SetAsGenericItemDefault)
            {
                Image = Item;
                Caption = 'Set as Generic Item Default';
                Enabled = not Rec."Default for Generic Item";
                ApplicationArea = All;
                ToolTip = 'Specifies that the item should be a default for the generic item';

                trigger OnAction()

                begin
                    Rec.Validate("Default for Generic Item", true);
                    Rec.Modify(false);
                end;
            }
        }

        area(Promoted)
        {
            group(Category_Home)
            {
                Caption = 'Home';

                actionref(GetLotImageP; "TFB Get Lot Image Wizard")
                {

                }
                actionref(SetItemDefaultP; SetAsItemDefault)
                {

                }
                actionref(SetGenericDefaultP; SetAsGenericItemDefault)
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
        exit(TypeHelper.FormatDateTime(rec.SystemCreatedAt, 'dd/MM/yy HH:mm', TypeHelper.GetCultureName()))

    end;
}
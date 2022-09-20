table 50124 "TFB Lot Image"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "TFB Lot Images";
    LookupPageId = "TFB Lot Images";

    fields
    {
        field(200; "Item Ledger Entry ID"; GUID)
        {
            TableRelation = "Item Ledger Entry".SystemId;

        }
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(12; "Orig. Image Blob Name"; Text[100])
        {

        }
        field(13; "Isol. Image Blob Name"; Text[100])
        {
            Caption = 'Isolated Image Blob Name';
        }
        field(14; "Import Sequence No."; Integer)
        {
            Caption = 'Imported Sequence Number';
        }
        field(16; "Item Ledger Entry No."; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Item Ledger Entry"."Entry No." where(SystemId = field("Item Ledger Entry ID")));
        }
        field(18; "Item Ledger Entry Type"; Enum "Item Ledger Entry Type")
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Item Ledger Entry"."Entry Type" where(SystemId = field("Item Ledger Entry ID")));
        }
        field(20; "Original Image"; MediaSet)
        {

        }
        field(22; "Isolated Image"; MediaSet)
        {

        }

    }

    keys
    {
        key(PK; "Item No.", "Variant Code", "Lot No.", "Import Sequence No.")
        {
            Clustered = true;
        }
        key(Key2; "Item No.", "Variant Code", "Lot No.", SystemCreatedAt)
        {

        }
    }

    var


    procedure GetNextSequence(): Integer

    var
        LotImage2: Record "TFB Lot Image";

    begin
        LotImage2.SetRange("Item No.", Rec."Item No.");
        LotImage2.SetRange("Variant Code", Rec."Variant Code");
        LotImage2.SetRange("Lot No.", Rec."Lot No.");
        LotImage2.SetAscending("Import Sequence No.", true);

        If LotImage2.FindLast() then
            Exit(LotImage2."Import Sequence No." + 1)
        else
            Exit(1);

    end;

    procedure InitFromItemLedgerEntry(ItemLedgerEntry: Record "Item Ledger Entry"): Boolean

    begin
        If ItemLedgerEntry."Entry No." = 0 then exit;

        Rec."Item Ledger Entry ID" := ItemLedgerEntry.SystemId;
        Rec."Item No." := ItemLedgerEntry."Item No.";
        Rec."Variant Code" := ItemLedgerEntry."Variant Code";
        Rec."Lot No." := ItemLedgerEntry."Lot No.";
        Rec.Description := ItemLedgerEntry.Description;
        Exit(true);

    end;

    procedure InitFromItemLedgerEntryID(ItemLedgerEntryID: GUID): Boolean

    var
        ItemLedgerEntry: Record "Item Ledger Entry";

    begin
        If not ItemLedgerEntry.GetBySystemId(ItemLedgerEntryID) then exit;

        Rec."Item Ledger Entry ID" := ItemLedgerEntry.SystemId;
        Rec."Item No." := ItemLedgerEntry."Item No.";
        Rec."Variant Code" := ItemLedgerEntry."Variant Code";
        Rec."Lot No." := ItemLedgerEntry."Lot No.";
        Rec.Description := ItemLedgerEntry.Description;
        Exit(true);

    end;

    procedure SetFiltersFromItemLedgerEntry(ItemLedgerEntry: record "Item Ledger Entry"): Boolean



    begin


        Rec.SetRange("Item Ledger Entry ID", ItemLedgerEntry.SystemId);

        Exit(true);

    end;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
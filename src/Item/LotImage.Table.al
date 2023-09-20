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
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
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
        field(23; "Generic Item ID"; GUID)
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item."TFB Generic Item ID" where("No." = field("Item No.")));
        }
        field(24; "Default for Item"; Boolean)
        {

            trigger OnValidate()
            var
                LotImage2: record "TFB Lot Image";
                ConfirmMgmt: codeunit "Confirm Management";
            begin
                LotImage2.SetFilter("Item No.", '%1', Rec."Item No.");
                LotImage2.SetRange("Default for Item", true);

                if Rec."Default for Item" then begin
                    if LotImage2.FindFirst() then
                        if ConfirmMgmt.GetResponseOrDefault('Override existing default for this item?', true) then begin
                            LotImage2."Default for Item" := false;
                            LotImage2.modify(false);
                            OnUpdateDefaultItemLotImage(Rec);
                        end
                        else
                            Rec."Default for Item" := false;
                end
                else
                    if LotImage2.IsEmpty() then
                        FieldError("Default for Item", 'Must be default for item as no other lot image exists');
            end;


        }
        field(25; "Default for Generic Item"; Boolean)
        {

            trigger OnValidate()
            var
                LotImage2: record "TFB Lot Image";
                ConfirmMgmt: codeunit "Confirm Management";
            begin
                Rec.CalcFields("Generic Item ID");
                LotImage2.SetFilter("Generic Item ID", '%1', Rec."Generic Item ID");
                LotImage2.SetRange("Default for Generic Item", true);

                if Rec."Default for Generic Item" then begin
                    if LotImage2.FindFirst() then
                        if ConfirmMgmt.GetResponseOrDefault('Override existing default for this generic item?', true) then begin
                            LotImage2."Default for Generic Item" := false;
                            LotImage2.modify(false);
                            OnUpdateDefaultGenericItemLotImage(Rec);
                        end
                        else
                            Rec."Default for Generic Item" := false;
                end
                else
                    if LotImage2.IsEmpty() then
                        FieldError("Default for Generic Item", 'Cannot be non-primary, no other primary exists');
            end;

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


    procedure GetNextSequence(): Integer

    var
        LotImage2: Record "TFB Lot Image";

    begin
        LotImage2.SetRange("Item No.", Rec."Item No.");
        LotImage2.SetRange("Variant Code", Rec."Variant Code");
        LotImage2.SetRange("Lot No.", Rec."Lot No.");
        LotImage2.SetAscending("Import Sequence No.", true);

        if LotImage2.FindLast() then
            exit(LotImage2."Import Sequence No." + 1)
        else
            exit(1);

    end;

    procedure InitFromItemLedgerEntry(ItemLedgerEntry: Record "Item Ledger Entry"): Boolean

    begin
        if ItemLedgerEntry."Entry No." = 0 then exit;

        Rec."Item Ledger Entry ID" := ItemLedgerEntry.SystemId;
        Rec."Item No." := ItemLedgerEntry."Item No.";
        Rec."Variant Code" := ItemLedgerEntry."Variant Code";
        Rec."Lot No." := ItemLedgerEntry."Lot No.";
        Rec.Description := ItemLedgerEntry.Description;
        exit(true);

    end;

    procedure InitFromItemLedgerEntryID(ItemLedgerEntryID: GUID): Boolean

    var
        ItemLedgerEntry: Record "Item Ledger Entry";

    begin
        if not ItemLedgerEntry.GetBySystemId(ItemLedgerEntryID) then exit;

        Rec."Item Ledger Entry ID" := ItemLedgerEntry.SystemId;
        Rec."Item No." := ItemLedgerEntry."Item No.";
        Rec."Variant Code" := ItemLedgerEntry."Variant Code";
        Rec."Lot No." := ItemLedgerEntry."Lot No.";
        Rec.Description := ItemLedgerEntry.Description;
        exit(true);

    end;

    procedure SetFiltersFromItemLedgerEntry(ItemLedgerEntry: record "Item Ledger Entry"): Boolean



    begin


        Rec.SetRange("Item Ledger Entry ID", ItemLedgerEntry.SystemId);

        exit(true);

    end;



    trigger OnInsert()
    var
        LotImage2: record "TFB Lot Image";
        LotImage3: record "TFB Lot Image";
    begin


        if "Item No." <> '' then begin
            LotImage3.SetFilter("Item No.", '%1', Rec."Item No.");
            LotImage3.SetRange("Default for Item", true);
            if LotImage3.IsEmpty then begin
                rec."Default for Item" := true;
                OnInsertNewDefaultItemLotImage(Rec);
            end;
        end;
        Rec.CalcFields("Generic Item ID");

        if not IsNullGuid("Generic Item ID") then begin
            LotImage2.SetFilter("Generic Item ID", '%1', Rec."Generic Item ID");
            LotImage2.SetRange("Default for Generic Item", true);
            if LotImage2.IsEmpty then
                Rec."Default for Generic Item" := true;
            OnInsertNewDefaultGenericItemLotImage(Rec);
        end;

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

    [IntegrationEvent(false, false)]
    local procedure OnInsertNewDefaultItemLotImage(Rec: Record "TFB Lot Image")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertNewDefaultGenericItemLotImage(Rec: Record "TFB Lot Image")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateDefaultItemLotImage(Rec: Record "TFB Lot Image")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateDefaultGenericItemLotImage(Rec: Record "TFB Lot Image")
    begin
    end;

}
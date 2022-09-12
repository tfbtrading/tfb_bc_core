table 50119 "TFB Forex Mgmt Entry"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(10; EntryType; Enum "TFB Forex Mgmt Entry Type")
        {
            trigger OnValidate()

            begin
                if EntryType = EntryType::Assignment then Rec."Applying Entry" := true else Rec."Applying Entry" := false;
            end;

        }
        field(20; "Source Document No."; Code[20])
        {


            trigger OnValidate()

            var
                ForexMgmtEntries: Record "TFB Forex Mgmt Entry";

            begin
                case EntryType of
                    EntryType::Assignment:
                        begin

                            ForexMgmtEntries.SetRange("External Document No.", "Source Document No.");
                            If ForexMgmtEntries.FindFirst() then begin
                                "Source Entry No." := ForexMgmtEntries."Source Entry No.";
                                "Currency Code" := ForexMgmtEntries."Currency Code";
                                "Covered Rate" := ForexMgmtEntries."Covered Rate";
                            end;
                        end;

                end;
            end;

            trigger OnLookup()

            var
                ForexMgmtEntry: Record "TFB Forex Mgmt Entry";

            begin
                case EntryType of
                    EntryType::Assignment:
                        begin
                            ForexMgmtEntry.Reset();
                            ForexMgmtEntry.SetRange(EntryType, ForexMgmtEntry.EntryType::ForexContract);

                            If Page.RunModal(Page::"TFB Forex Mgmt Entries", ForexMgmtEntry) = Action::LookupOK then
                                Rec.Validate("Source Document No.", ForexMgmtEntry."External Document No.");

                        end;
                end;
            end;
        }

        field(30; "Source Entry No."; Integer)
        {
            TableRelation = If (EntryType = const(VendorLedgerEntry)) "Vendor Ledger Entry" where(Open = const(true), "Document Type" = const(Invoice));
        }
        field(40; "Original Amount"; Decimal)
        {

            trigger OnValidate()

            begin
                UpdateAmounts();
            end;

        }
        field(43; "Est. Interest"; Decimal)
        {

            trigger OnValidate()

            begin
                UpdateAmounts();
            end;

        }
        Field(44; "Total Incl. Interest"; Decimal)
        {
            Editable = false;

        }
        field(45; "Covered Rate"; Decimal)
        {
            DecimalPlaces = 4 : 5;
        }
        field(47; "Original Rate"; Decimal)
        {
            DecimalPlaces = 4 : 5;
            Editable = false;
        }
        field(11; "Currency Code"; Code[10])
        {
            TableRelation = Currency.Code;
        }
        field(50; "Due Date"; Date)
        {

        }
        field(63; "External Document No."; Code[20])
        {

        }
        field(65; "Interest Rate"; Decimal)
        {
            AutoFormatType = 10;
            AutoFormatExpression = '<precision, 2:4><standard format,0>%';
        }
        field(34; "Applies-to Doc. Type"; Enum "TFB Forex Mgmt Applies-To Type")
        {
            trigger OnValidate()

            begin
                if Rec."Applies-to Doc. Type" <> xRec."Applies-to Doc. Type" then
                    "Applies-to Doc No." := '';
            end;

        }
        field(35; "Applies-to Doc No."; Code[20])
        {


            trigger OnLookup()

            var
                VendorLedgerEntry: Record "Vendor Ledger Entry";
                PurchaseHeader: Record "Purchase Header";

            begin

                case "Applies-to Doc. Type" of
                    "Applies-to Doc. Type"::VendorLedgerEntry:
                        begin
                            VendorLedgerEntry.SetRange(Open, true);
                            VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::" ", VendorLedgerEntry."Document Type"::Invoice);
                            VendorLedgerEntry.SetRange("Currency Code", Rec."Currency Code");

                            If Page.RunModal(Page::"Vendor Ledger Entries", VendorLedgerEntry) = Action::LookupOK then begin
                                VendorLedgerEntry.CalcFields("Remaining Amount", "TFB Forex Amount");
                                Rec."Applies-to Doc No." := VendorLedgerEntry."External Document No.";
                                Rec."Original Rate" := VendorLedgerEntry."Original Currency Factor";
                                Rec."Due Date" := VendorLedgerEntry."Due Date";
                                Rec."Applies-to id" := VendorLedgerEntry.SystemId;
                                Rec."Original Amount" := -VendorLedgerEntry."Remaining Amount" - VendorLedgerEntry."TFB Forex Amount";
                                Rec."Applies-to Entry Doc. No." := VendorLedgerEntry."Document No.";
                                Rec."Applies-to Posting Date" := VendorLedgerEntry."Posting Date";
                            end;

                        end;

                    "Applies-to Doc. Type"::PurchaseOrder:
                        begin
                            PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                            PurchaseHeader.SetRange("Currency Code", Rec."Currency Code");

                            If Page.RunModal(Page::"Purchase Order List", PurchaseHeader) = Action::LookupOK then begin
                                Rec."Applies-to Doc No." := PurchaseHeader."No.";
                                Rec."Original Rate" := PurchaseHeader."Currency Factor";
                                Rec."Due Date" := PurchaseHeader."Due Date";
                            end;

                        end;

                end;
            end;

        }
        field(90; "Applies-to id"; GUID)
        {

        }
        field(92; "Applies-to Entry Doc. No."; Code[20])
        {

        }
        field(94; "Applies-to Posting Date"; Date)
        {

        }
        field(86; "Applying Entry"; Boolean)
        {

        }

        field(87; "Status"; Enum "TFB Forex Mgmt Entry Status")
        {

        }
        field(36; Open; Boolean)
        {

        }


    }



    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;

        }
        key(Key1; "External Document No.")
        {

        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "External Document No.", "Currency Code", "Covered Rate", "Due Date")
        {

        }
        fieldgroup(Brick; "External Document No.", "Currency Code", "Covered Rate", "Due Date")
        {

        }
    }
    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
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


    procedure getRemainingAmount(entryNo: Integer): Decimal

    var
        ForexMgmtEntry: Record "TFB Forex Mgmt Entry";
        ForexMgmtEntry2: Record "TFB Forex Mgmt Entry";
        LedgerEntry: Record "Vendor Ledger Entry";
        PurchaseHeader: Record "Purchase Header";

    begin

        If not ForexMgmtEntry.Get("Entry No.") then exit;

        case ForexMgmtEntry.EntryType of
            "TFB Forex Mgmt Entry Type"::ForexContract:
                begin
                    ForexMgmtEntry2.SetRange(EntryType, ForexMgmtEntry2.EntryType::Assignment);
                    ForexMgmtEntry2.SetRange("Source Document No.", ForexMgmtEntry."External Document No.");
                    ForexMgmtEntry2.CalcSums("Original Amount", "Est. Interest");

                    Exit(ForexMgmtEntry."Original Amount" - (ForexMgmtEntry2."Original Amount" + ForexMgmtEntry2."Est. Interest"));

                end;

            "TFB Forex Mgmt Entry Type"::Assignment:

                case ForexMgmtEntry."Applies-to Doc. Type" of
                    "TFB Forex Mgmt Applies-To Type"::VendorLedgerEntry:
                        begin

                            LedgerEntry.SetRange("External Document No.", ForexMgmtEntry."Applies-to Doc No.");
                            LedgerEntry.SetRange(Reversed, false);
                            If LedgerEntry.FindFirst() then begin

                                ForexMgmtEntry2.SetRange(EntryType, ForexMgmtEntry2.EntryType::Assignment);
                                ForexMgmtEntry2.SetRange("Applies-to Doc No.", ForexMgmtEntry."Applies-to Doc No.");
                                ForexMgmtEntry2.SetFilter("Entry No.", '<>%1', ForexMgmtEntry."Entry No.");
                                ForexMgmtEntry2.CalcSums("Original Amount", "Est. Interest");
                                LedgerEntry.CalcFields("Remaining Amount");
                                if LedgerEntry.Open then
                                    Exit(-LedgerEntry."Remaining Amount" - ForexMgmtEntry2."Original Amount" - ForexMgmtEntry."Original Amount")
                                else
                                    Exit(0);

                            end;

                        end;

                    "TFB Forex Mgmt Applies-To Type"::PurchaseOrder:
                        begin
                            PurchaseHeader.SetRange("No.", ForexMgmtEntry."Applies-to Doc No.");
                            PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                            If PurchaseHeader.FindFirst() then begin

                                ForexMgmtEntry2.SetRange(EntryType, ForexMgmtEntry2.EntryType::Assignment);
                                ForexMgmtEntry2.SetRange("Applies-to Doc No.", ForexMgmtEntry."Applies-to Doc No.");
                                ForexMgmtEntry2.SetFilter("Entry No.", '<>%1', ForexMgmtEntry."Entry No.");
                                ForexMgmtEntry2.CalcSums("Original Amount", "Est. Interest");
                                Exit(PurchaseHeader."Amount Including VAT" - ForexMgmtEntry2."Original Amount" - ForexMgmtEntry."Original Amount");

                            end;
                        end;

                end;
            "TFB Forex Mgmt Entry Type"::VendorLedgerEntry:

                begin
                    LedgerEntry.SetLoadFields(Amount);
                    If LedgerEntry.GetBySystemId(Rec."Applies-to id") then begin
                        LedgerEntry.CalcFields("Remaining Amount");
                        Exit(LedgerEntry."Remaining Amount");
                    end;
                end;

        end;


    end;

    procedure getRemainingAmountByAppliesToId(appliesToId: GUID): Decimal

    var
        ForexMgmtEntry: Record "TFB Forex Mgmt Entry";
        ForexMgmtEntry2: Record "TFB Forex Mgmt Entry";
        LedgerEntry: Record "Vendor Ledger Entry";


    begin

        if LedgerEntry.GetBySystemId("Applies-to id") then begin


            ForexMgmtEntry2.SetRange(EntryType, ForexMgmtEntry2.EntryType::Assignment);
            ForexMgmtEntry2.SetRange("Applies-to id", appliesToId);
            ForexMgmtEntry2.CalcSums("Original Amount", "Est. Interest");
            LedgerEntry.CalcFields("Remaining Amount");
            if LedgerEntry.Open then
                Exit(-LedgerEntry."Remaining Amount" - ForexMgmtEntry2."Original Amount")
            else
                Exit(0);

        end;

    end;

    procedure getRemainingAmountByVendorLedgerEntry(LedgerEntry: Record "Vendor Ledger Entry"): Decimal

    var
        ForexMgmtEntry: Record "TFB Forex Mgmt Entry";
        ForexMgmtEntry2: Record "TFB Forex Mgmt Entry";


    begin

        ForexMgmtEntry2.SetRange(EntryType, ForexMgmtEntry2.EntryType::Assignment);
        ForexMgmtEntry2.SetRange("Applies-to Doc No.", ForexMgmtEntry."Applies-to Doc No.");
        ForexMgmtEntry2.SetFilter("Entry No.", '<>%1', ForexMgmtEntry."Entry No.");
        ForexMgmtEntry2.CalcSums("Original Amount", "Est. Interest");
        LedgerEntry.CalcFields("Remaining Amount");
        if LedgerEntry.Open then
            Exit(-LedgerEntry."Remaining Amount" - ForexMgmtEntry2."Original Amount")
        else
            Exit(0);


    end;

    internal procedure UpdateOpenStatus()

    begin
        Rec.Open := IsOpen();
    end;

    internal procedure IsOpen() Open: Boolean


    var

        LedgerEntry: Record "Vendor Ledger Entry";


    begin

        Open := true;

        case Rec.EntryType of

            Rec.EntryType::Assignment:

                case Rec."Applies-to Doc. Type" of
                    Rec."Applies-to Doc. Type"::VendorLedgerEntry:
                        begin
                            LedgerEntry.SetLoadFields(Open);
                            If LedgerEntry.GetBySystemId("Applies-to id") then
                                Exit(LedgerEntry.Open);

                        end;
                end;
            Rec.EntryType::ForexContract:

                Exit(not (getRemainingAmount(Rec."Entry No.") = 0));

        end;
    end;

    local procedure UpdateAmounts()
    begin
        Rec."Total Incl. Interest" := Rec."Original Amount" + Rec."Est. Interest";
    end;

}
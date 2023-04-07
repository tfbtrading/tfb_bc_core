codeunit 50121 "TFB Pstd. Purch Inv. Hdr. Edit"
{
    Permissions = TableData "Purch. Inv. Header" = m, tabledata "Vendor Ledger Entry" = m;
    TableNo = "Purch. Inv. Header";

    trigger OnRun()
    var
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        PurchInvoiceHeader := Rec;
        PurchInvoiceHeader.LockTable();
        PurchInvoiceHeader.Find();

        case _Scenario of
            _Scenario::PaymentNote:
                begin
                    PurchInvoiceHeader."TFB Expected Payment Note" := Rec."TFB Expected Payment Note";
                    PurchInvoiceHeader."TFB Expected Payment Date" := Rec."TFB Expected Payment Date";
                    PurchInvoiceHeader."TFB Expected Note TimeStamp" := CurrentDateTime;
                end;
            _Scenario::ExternalDocumentNo:
                begin
                    PurchInvoiceHeader."Vendor Invoice No." := Rec."Vendor Invoice No.";
                    PurchInvoiceHeader."TFB Orig. External Doc. No." := Rec."TFB Orig. External Doc. No.";

                    VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
                    VendorLedgerEntry.SetRange("Document No.", PurchInvoiceHeader."No.");

                    if VendorLedgerEntry.FindFirst() then begin
                        VendorLedgerEntry.Validate("External Document No.", Rec."Vendor Invoice No.");
                        VendorLedgerEntry.Modify();
                    end;



                end;

        end;

        PurchInvoiceHeader.TestField("No.", Rec."No.");
        PurchInvoiceHeader.Modify();
        Rec := PurchInvoiceHeader;
    end;

    procedure SetScenario(Scenario: Enum "TFB Pstd. SInv.-Edit Scen.")

    begin
        _Scenario := Scenario;
    end;

    var
        _Scenario: Enum "TFB Pstd. SInv.-Edit Scen.";

}
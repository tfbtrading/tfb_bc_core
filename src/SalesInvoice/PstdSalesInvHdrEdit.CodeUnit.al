codeunit 50117 "TFB Pstd. Sales Inv. Hdr. Edit"
{
    Permissions = TableData "Sales Invoice Header" = m;
    TableNo = "Sales Invoice Header";

    trigger OnRun()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader := Rec;
        SalesInvoiceHeader.LockTable();
        SalesInvoiceHeader.Find();

        case _Scenario of
            _Scenario::PaymentNote:
                begin
                    SalesInvoiceHeader."TFB Expected Payment Note" := Rec."TFB Expected Payment Note";
                    SalesInvoiceHeader."TFB Expected Payment Date" := Rec."TFB Expected Payment Date";
                    SalesInvoiceHeader."Due Date" := Rec."Due Date";
                    SalesInvoiceHeader."TFB Expected Note TimeStamp" := CurrentDateTime;
                end;
            _Scenario::ExternalDocumentNo:
                begin
                    SalesInvoiceHeader."External Document No." := Rec."External Document No.";
                    SalesInvoiceHeader."TFB Orig. External Doc. No." := Rec."TFB Orig. External Doc. No.";
                end;

        end;

        SalesInvoiceHeader.TestField("No.", Rec."No.");
        SalesInvoiceHeader.Modify();
        Rec := SalesInvoiceHeader;
    end;

    procedure SetScenario(Scenario: Enum "TFB Pstd. SInv.-Edit Scen.")

    begin
        _Scenario := Scenario;
    end;

    var
        _Scenario: Enum "TFB Pstd. SInv.-Edit Scen.";

}
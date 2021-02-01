tableextension 50121 "TFB To-do" extends "To-do"
{
    fields
    {
        field(50100; "TFB Sale or Purchase"; Enum "TFB To-do Trans. Type")
        {
            DataClassification = CustomerContent;
        }
        field(50110; "TFB Posted or Archived"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50120; "TFB Trans. Record ID"; RecordID)
        {
            Caption = 'Transaction Record ID';
        }
        field(50130; "TFB Trans. Description"; Text[250])
        {
            Caption = 'Transaction Description';
        }


    }
    keys
    {
        key(RecordID; "TFB Trans. Record ID")
        {

        }
        key(Trans; "TFB Sale or Purchase", "TFB Posted or Archived", "TFB Trans. Record ID")
        {

        }
    }


    /// <summary>
    /// CreateTaskFromPurchaseHeader.
    /// </summary>
    /// <param name="PurchaseHeader">Record "Sales Header".</param>
    procedure CreateTaskFromPurchaseHeader(PurchaseHeader: Record "Purchase Header")
    var
        TransText: Text;
    begin
        DeleteAll();
        Init();
        Validate("Contact No.", PurchaseHeader."Buy-from Contact No.");
        SetRange("Contact No.", PurchaseHeader."Buy-from Contact No.");
        if PurchaseHeader."Purchaser Code" <> '' then begin
            "Salesperson Code" := PurchaseHeader."Purchaser Code";
            SetRange("Salesperson Code", PurchaseHeader."Purchaser Code");
        end;

        Rec."TFB Sale or Purchase" := Rec."TFB Sale or Purchase"::Purchases;
        Rec."TFB Trans. Record ID" := PurchaseHeader.RecordId;

        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Quote:
                TransText := StrSubstNo('Purchase Quote #%1', PurchaseHeader."No.");
            PurchaseHeader."Document Type"::Order:
                TransText := StrSubstNo('Purchase Order #%1', PurchaseHeader."No.");
            PurchaseHeader."Document Type"::Invoice:
                TransText := StrSubstNo('Purchase Invoice #%1', PurchaseHeader."No.")
        end;
        Rec."TFB Trans. Description" := TransText;
        OnCreateTaskFromPurchaseHeaderOnBeforeStartWizard(Rec, PurchaseHeader);

        StartWizard();
    end;


    procedure CreateTaskFromPstdDocument(RecRef: RecordRef)
    var
        TransText: Text;
        RecordContactNo: Code[20];
        SalesPurchCode: Code[20];
        SalesInvoice: Record "Sales Invoice Header";
        PurchInvoice: Record "Purch. Inv. Header";
        SalesOrPurchase: Enum "TFB To-do Trans. Type";
    begin

        case RecRef.Number of
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvoice);
                    RecordContactNo := SalesInvoice."Sell-to Contact No.";
                    SalesPurchCode := SalesInvoice."Salesperson Code";
                    SalesOrPurchase := SalesOrPurchase::Sales;
                    TransText := StrSubstNo('Pstd Sales Invoice #%1', SalesInvoice."No.");
                end;

            Database::"Purch. Inv. Header":
                begin
                    RecRef.SetTable(PurchInvoice);
                    RecordContactNo := PurchInvoice."Buy-from Contact No.";
                    SalesPurchCode := PurchInvoice."Purchaser Code";
                    SalesOrPurchase := SalesOrPurchase::Purchases;
                    TransText := StrSubstNo('Pstd Purch. Invoice #%1', PurchInvoice."No.");
                end;

        end;

        If TransText <> '' then begin
            DeleteAll();
            Init();
            Validate("Contact No.", RecordContactNo);
            SetRange("Contact No.", RecordContactNo);
            if SalesPurchCode <> '' then begin
                "Salesperson Code" := SalesPurchCode;
                SetRange("Salesperson Code", SalesPurchCode);
            end;

            Rec."TFB Sale or Purchase" := SalesOrPurchase;
            Rec."TFB Trans. Record ID" := RecRef.RecordId;
            Rec."TFB Trans. Description" := TransText;

            OnCreateTaskFromPstdDocOnBeforeStartWizard(Rec, RecRef);

            StartWizard();
        end;

    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateTaskFromPstdDocOnBeforeStartWizard(var Task: Record "To-do"; RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateTaskFromPurchaseHeaderOnBeforeStartWizard(var Task: Record "To-do"; PurchRec: Record "Purchase Header")
    begin
    end;
}
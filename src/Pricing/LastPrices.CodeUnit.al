codeunit 50135 "TFB Last Prices"
{
    trigger OnRun()
    begin

    end;

    var
        LastPrices: Record "TFB Last Prices";


    procedure CheckIfLastPriceExists(RelationshipType: Enum "TFB Last Prices Rel. Type"; CustomerVendorNo: Code[20]; ItemNo: Code[20]; MaxPricesCount: Integer; CalledByRecordId: RecordId; FilterByRelationship: Boolean; FilterByPriceGroup: Boolean; LinePriceGroup: Code[10]): Boolean

    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PricesExist: Boolean;


    begin

        PricesExist := false;
        if RelationshipType <> RelationshipType::Customer then exit;
        if FilterByRelationship then
            SalesLine.SetRange("Sell-to Customer No.", CustomerVendorNo);
        if FilterByPriceGroup then
            SalesLine.SetRange("Customer Price Group", LinePriceGroup);
        SalesLine.SetRange("Completely Shipped", false);
        SalesLine.SetRange("No.", ItemNo);
        SalesHeader.SetLoadFields("Order Date", "Document Date");
        SalesInvoiceHeader.SetLoadFields(Cancelled, "Posting Date", "Document Date");

        if SalesLine.FindSet() then
            repeat
                SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
                if not (SalesHeader.RecordId = CalledByRecordId) then
                    PricesExist := true;

            until (SalesLine.Next() = 0) or (PricesExist);

        if FilterByRelationship then
            SalesInvoiceLine.SetRange("Sell-to Customer No.", CustomerVendorNo);
        if FilterByPriceGroup then
            SalesInvoiceLine.SetRange("Customer Price Group", LinePriceGroup);
        SalesInvoiceLine.SetRange("No.", ItemNo);
        SalesInvoiceLine.SetFilter(Quantity, '>0');

        if not PricesExist and SalesInvoiceLine.FindSet() then
            repeat
                SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
                if not SalesInvoiceHeader.Cancelled and not (SalesInvoiceHeader.RecordId = CalledByRecordId) then
                    PricesExist := true

            until (SalesInvoiceLine.Next() = 0) or (PricesExist);

        exit(PricesExist);
    end;

    procedure PopulateLastPrices(RelationshipType: Enum "TFB Last Prices Rel. Type"; CustomerVendorNo: Code[20]; ItemNo: Code[20]; MaxPricesCount: Integer; CalledByRecordId: RecordId; FilterByRelationship: Boolean; FilterByPriceGroup: Boolean; LinePriceGroup: Code[10])
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PriceMgmt: CodeUnit "TFB Pricing Calculations";
        EntryNo: Integer;
        PricesRetrieved: Integer;

    begin
        LastPrices.DeleteAll();

        if MaxPricesCount = 0 then MaxPricesCount := 10;
        if RelationshipType <> RelationshipType::Customer then exit;
        if FilterByRelationship then
            SalesLine.SetRange("Sell-to Customer No.", CustomerVendorNo);
        if FilterByPriceGroup then
            SalesLine.SetRange("Customer Price Group", LinePriceGroup);
        SalesLine.SetRange("Completely Shipped", false);
        SalesLine.SetRange("No.", ItemNo);
        SalesLine.SetCurrentKey(SystemCreatedAt);
        SalesLine.SetAscending(SystemCreatedAt, false);
        SalesLine.SetLoadFields("Document No.", "Sell-to Customer No.", "Line No.", "Document Type", "Unit Price", "Line Discount Amount", Quantity, "No.", "Quantity (Base)", "Unit of Measure Code", "Unit Price", "Net Weight", "Customer Price Group");
        SalesHeader.SetLoadFields("Order Date", "Document Date");
        SalesInvoiceHeader.SetLoadFields(Cancelled, "Posting Date", "Document Date");

        if SalesLine.FindSet() then
            repeat
                SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
                if not (SalesHeader.RecordId = CalledByRecordId) then begin

                    LastPrices.Init();
                    EntryNo += 1000;
                    PricesRetrieved += 1;
                    LastPrices."Entry No." := EntryNo;
                    LastPrices."Relationship Type" := RelationshipType;
                    LastPrices."Document No." := SalesLine."Document No.";
                    LastPrices."Customer/Vendor No." := SalesLine."Sell-to Customer No.";
                    LastPrices."Line No." := SalesLine."Line No.";
                    LastPrices."Document Type" := salesLine."Document Type";
                    LastPrices."Unit Price" := SalesLine."Unit Price";
                    LastPrices."Unit Discount Amount" := SalesLine."Line Discount Amount" / SalesLine.Quantity;
                    LastPrices."Unit Price After Discount" := LastPrices."Unit Price" - LastPrices."Unit Discount Amount";
                    LastPrices."Item No." := SalesLine."No.";
                    LastPrices.Quantity := SalesLine."Quantity (Base)";
                    LastPrices."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                    LastPrices."Price Unit Price" := PriceMgmt.CalcPerKgFromUnit(SalesLine."Unit Price", SalesLine."Net Weight");
                    LastPrices."Price Unit Discount Amount" := PriceMgmt.CalcPerKgFromUnit(LastPrices."Unit Discount Amount", SalesLine."Net Weight");
                    LastPrices."Price Unit After Discount" := LastPrices."Price Unit Price" - LastPrices."Price Unit Discount Amount";
                    lastPrices."Document Date" := SalesHeader."Order Date";
                    LastPrices."Price Group" := SalesLine."Customer Price Group";
                    LastPrices.DrillDownRecordId := SalesHeader.RecordId;
                    LastPrices.Insert();
                end;
            until (SalesLine.Next() = 0) or (PricesRetrieved >= MaxPricesCount);

        if FilterByRelationship then
            SalesInvoiceLine.SetRange("Sell-to Customer No.", CustomerVendorNo);
        if FilterByPriceGroup then
            SalesInvoiceLine.SetRange("Customer Price Group", LinePriceGroup);
        SalesInvoiceLine.SetRange("No.", ItemNo);
        SalesInvoiceLine.SetCurrentKey("Posting Date");
        SalesInvoiceLine.SetAscending("Posting Date", false);
        SalesInvoiceLine.SetLoadFields("Document No.", "Sell-to Customer No.", "Line No.", "Unit Price", "Line Discount Amount", Quantity, "No.", "Quantity (Base)", "Unit of Measure Code", "Unit Price", "Net Weight", "Customer Price Group");
        SalesInvoiceLine.SetFilter(Quantity, '>0');

        if SalesInvoiceLine.FindSet() then
            repeat

                SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
                if not SalesInvoiceHeader.Cancelled and not (SalesInvoiceHeader.RecordId = CalledByRecordId) then begin

                    EntryNo += 1000;
                    LastPrices."Entry No." := EntryNo;
                    PricesRetrieved += 1;
                    LastPrices."Document No." := SalesInvoiceLine."Document No.";
                    LastPrices."Customer/Vendor No." := SalesInvoiceLine."Sell-to Customer No.";
                    LastPrices."Relationship Type" := RelationshipType;
                    LastPrices."Line No." := SalesInvoiceLine."Line No.";
                    LastPrices."Document Type" := salesLine."Document Type"::Invoice;
                    LastPrices."Unit Price" := SalesInvoiceLine."Unit Price";
                    LastPrices."Unit Discount Amount" := SalesInvoiceLine."Line Discount Amount" / SalesInvoiceLine.Quantity;
                    LastPrices."Unit Price After Discount" := LastPrices."Unit Price" - LastPrices."Unit Discount Amount";
                    LastPrices."Item No." := SalesInvoiceLine."No.";
                    LastPrices.Quantity := SalesInvoiceLine."Quantity (Base)";
                    LastPrices."Unit of Measure Code" := SalesInvoiceLine."Unit of Measure Code";
                    LastPrices."Price Unit Price" := PriceMgmt.CalcPerKgFromUnit(SalesInvoiceLine."Unit Price", SalesInvoiceLine."Net Weight");
                    LastPrices."Price Unit Discount Amount" := PriceMgmt.CalcPerKgFromUnit(LastPrices."Unit Discount Amount", SalesInvoiceLine."Net Weight");
                    LastPrices."Price Unit After Discount" := LastPrices."Price Unit Price" - LastPrices."Price Unit Discount Amount";
                    lastPrices."Document Date" := SalesInvoiceHeader."Document Date";
                    LastPrices."Price Group" := SalesInvoiceLine."Customer Price Group";
                    LastPrices.DrillDownRecordId := SalesInvoiceHeader.RecordId;
                    LastPrices.Insert();

                end;

            until (SalesInvoiceLine.Next() = 0) or (PricesRetrieved >= MaxPricesCount);

    end;

    procedure ShowLastPrices(ContextLine: RecordRef)

    var
        LastPricesPage: Page "TFB Last Prices";

    begin

        LastPricesPage.SetPopulatedData(LastPrices);
        LastPricesPage.AddContext(GetContextType(ContextLine), ContextLine);
        LastPricesPage.RunModal();

    end;

    procedure GetLastPrices(var pLastPrices: record "TFB Last Prices"): Boolean

    begin
        pLastPrices.Reset();
        pLastPrices.DeleteAll();
        if LastPrices.FindSet() then
            repeat
                pLastPrices.Init();
                pLastPrices := LastPrices;
                pLastPrices.Insert();
            until LastPrices.Next() = 0;
        if pLastPrices.Count > 0 then
            exit(true);
    end;

    local procedure GetContextType(ContextLine: RecordRef): Enum "TFB Last Prices Rel. Type"
    var

    begin

        case ContextLine.Number of
            Database::"Sales Line":
                exit(Enum::"TFB Last Prices Rel. Type"::Customer);
            Database::"Purchase Line":
                exit(Enum::"TFB Last Prices Rel. Type"::Vendor);
        end;
    end;
}
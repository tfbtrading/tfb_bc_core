codeunit 50240 "TFB Purch. Rcpt. Mgmt"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchRcptLineInsert', '', false, false)]
    local procedure HandlePurchRcptLine(var PurchRcptLine: Record "Purch. Rcpt. Line")
    var

        ContainerEntry: Record "TFB Container Entry";

    begin

        if ContainerEntry.Get(PurchRcptLine."TFB Container Entry No.") then
            PurchRcptLine."TFB Container Entry No." := ContainerEntry."No.";


    end;

    procedure GetSalesOrderReferenceFromReceiptLine(ReceiptLine: record "Purch. Rcpt. Line"): code[20]

    begin
        If (ReceiptLine."Special Order Sales No." <> '') and (ReceiptLine."Special Order Sales Line No." > 0) then
            exit(ReceiptLine."Special Order Sales No.")
        else
            if (ReceiptLine."Sales Order No." <> '') and (ReceiptLine."Sales Order Line No." > 0) then
                exit(ReceiptLine."Sales Order No.")
            else
                exit('');
    end;

    procedure OpenRelatedSalesOrder(DocNo: Code[20])

    var
        SO: Record "Sales Header";
        SOA: Record "Sales Header Archive";

    begin

        //Check if sales order is still open
        SO.SetRange("No.", DocNo);
        SO.SetRange("Document Type", SO."Document Type"::Order);

        If SO.FindFirst() then
            PAGE.Run(Page::"Sales Order", SO)

        else begin

            SOA.SetRange("No.", DocNo);
            SOA.SetRange("Document Type", SOA."Document Type"::Order);

            If SOA.FindLast() then
                PAGE.Run(Page::"Sales Order Archive", SOA);

        end;


    end;

    procedure OpenRelatedPurchaseOrder(DocNo: Code[20])

    var
        Header: Record "Purchase Header";
        ArchiveHeader: Record "Purchase Header Archive";

    begin

        //Check if sales order is still open
        Header.SetRange("No.", DocNo);
        Header.SetRange("Document Type", Header."Document Type"::Order);

        If Header.FindFirst() then
            PAGE.Run(Page::"Purchase Order", Header)

        else begin

            ArchiveHeader.SetRange("No.", DocNo);
            ArchiveHeader.SetRange("Document Type", ArchiveHeader."Document Type"::Order);

            If ArchiveHeader.FindLast() then
                PAGE.Run(Page::"Purchase Order Archive", ArchiveHeader);

        end;


    end;

    procedure GetItemChargesForReceipt(DocNo: Code[20]; LineNo: Integer; ItemCharge: Code[20]; var TotalChargeAmount: Decimal; var SameChargeAmount: Decimal): Boolean

    var
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";

    begin
        TotalChargeAmount := 0;
        SameChargeAmount := 0;

        //Find corresponding item ledger entry
        ItemLedger.SetRange("Document No.", DocNo);
        ItemLedger.SetRange("Document Type", ItemLedger."Document Type"::"Purchase Receipt");

        If ItemLedger.FindSet(false) then
            repeat

                //Calculate total charges
                Clear(ValueEntry);
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
                ValueEntry.SetRange("Item Ledger Entry No.", ItemLedger."Entry No.");
                ValueEntry.SetFilter("Item Charge No.", '<>%1', '');
                ValueEntry.CalcSums("Cost Amount (Actual)"); //Total up values in column
                TotalChargeAmount += ValueEntry."Cost Amount (Actual)"; //Add up value entry assigned

                //Calculate same charges
                Clear(ValueEntry);
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
                ValueEntry.SetRange("Item Ledger Entry No.", ItemLedger."Entry No.");
                ValueEntry.SetRange("Item Charge No.", ItemCharge);
                ValueEntry.CalcSums("Cost Amount (Actual)"); //Total up values in column
                SameChargeAmount += ValueEntry."Cost Amount (Actual)"; //Add up value entry assigned

            until ItemLedger.Next() < 1;
        If (TotalChargeAmount > 0) or (SameChargeAmount > 0) then
            Exit(true)
        else
            Exit(false);
    end;


    procedure OpenItemChargesForReceipt(DocNo: Code[20]; LineNo: Integer): Decimal

    var
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ValueEntries: Page "Value Entries";
        FilterCriteria: TextBuilder;


    begin

        //Find corresponding item ledger entry
        ItemLedger.SetRange("Document No.", DocNo);
        ItemLedger.SetRange("Document Line No.", LineNo);
        ItemLedger.SetRange("Document Type", ItemLedger."Document Type"::"Purchase Receipt");

        If ItemLedger.FindSet(false) then
            repeat

                If FilterCriteria.Length() > 0 then
                    FilterCriteria.Append('|');

                FilterCriteria.Append(Format(ItemLedger."Entry No."));


            until ItemLedger.Next() < 1;

        //Open Page

        Clear(ValueEntry);
        If FilterCriteria.Length() > 0 then begin
            ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
            ValueEntry.SetFilter("Item Ledger Entry No.", FilterCriteria.ToText());
            ValueEntry.SetFilter("Item Charge No.", '<>%1', '');
            ValueEntries.SetTableView(ValueEntry);
            ValueEntries.Run();
        end;
    end;

    procedure GetRelatedContainerEntry(DocNo: Code[20]): Code[20]

    var
        Line: Record "Purch. Rcpt. Line";

    begin
        Line.SetRange("Document No.", DocNo);

        If Line.FindFirst() then
            Exit(Line."TFB Container Entry No.");
    end;

    procedure OpenRelatedContainer(EntryNo: Code[20])
    var
        ContainerEntry: Record "TFB Container Entry";
        ContainerEntryPage: Page "TFB Container Entry";
    begin

        ContainerEntry.SetRange("No.", EntryNo);

        If ContainerEntry.FindFirst() then begin
            ContainerEntryPage.SetRecord(ContainerEntry);
            ContainerEntryPage.Run();
        end;

    end;

    internal procedure GetReceiptLineType(ReceiptLine: Record "Purch. Rcpt. Line"): Text[40]
    begin
        If (ReceiptLine."Special Order Sales No." <> '') and (ReceiptLine."Special Order Sales Line No." > 0) then
            exit('Special Order')
        else
            if (ReceiptLine."Sales Order No." <> '') and (ReceiptLine."Sales Order Line No." > 0) then
                exit('Drop Shipment')
            else
                exit('Normal');
    end;
}
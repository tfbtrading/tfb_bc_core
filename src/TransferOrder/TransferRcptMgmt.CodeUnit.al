codeunit 50124 "TFB Transfer Rcpt. Mgmt"
{



    procedure OpenRelatedPurchaseOrder(DocNo: Code[20])

    var
        PO: Record "Purchase Header";
        POA: Record "Purchase Header Archive";

    begin

        //Check if sales order is still open
        PO.SetRange("No.", DocNo);
        PO.SetRange("Document Type", PO."Document Type"::Order);

        If PO.FindFirst() then
            PAGE.Run(Page::"Purchase Order", PO)

        else begin

            POA.SetRange("No.", DocNo);
            POA.SetRange("Document Type", POA."Document Type"::Order);

            If POA.FindLast() then
                PAGE.Run(Page::"Purchase Order Archive", POA);

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
        ItemLedger.SetRange("Document Type", ItemLedger."Document Type"::"Transfer Receipt");

        If ItemLedger.FindSet(false) then
            repeat

                //Calculate total charges
                Clear(ValueEntry);
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Transfer);
                ValueEntry.SetRange("Item Ledger Entry No.", ItemLedger."Entry No.");
                ValueEntry.SetFilter("Item Charge No.", '<>%1', '');
                ValueEntry.CalcSums("Cost Amount (Actual)"); //Total up values in column
                TotalChargeAmount += ValueEntry."Cost Amount (Actual)"; //Add up value entry assigned

                //Calculate same charges
                Clear(ValueEntry);
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Transfer);
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
        Entry: Record "TFB Container Entry";
        Container: Page "TFB Container Entry";
    begin

        Entry.SetRange("No.", EntryNo);

        If Entry.FindFirst() then begin
            Container.SetRecord(Entry);
            Container.Run();
        end;

    end;
}
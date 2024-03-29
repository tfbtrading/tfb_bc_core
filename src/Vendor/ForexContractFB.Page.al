page 50160 "TFB Forex Contract FB"
{
    Caption = 'Forex Contract Details';
    PageType = ListPart;
    SourceTable = "TFB Forex Mgmt Entry";
    SourceTableView = where(EntryType = const(ForexContract));
    ApplicationArea = All;


    layout
    {
        area(Content)
        {

            field(UncoveredLedgerEntries; _UncoveredLedgerEntries)
            {
                Caption = 'Uncovered Invoices';
                ToolTip = 'Specifies the value of ledger entries uncovered.';
            }
            field(UncoveredPurchases; _UncoveredPurchases)
            {
                Caption = 'Uncovered Purchase Orders';
                ToolTip = 'Specifies the value of the Invoice Amount Paid field.';
            }


        }


    }


    actions
    {

    }

    local procedure CalculateLedgerEntriesUncovered() CalcTotal: Decimal
    var
        VendorLedgerEntry: record "Vendor Ledger Entry";
        Vendor: Record vendor;
    begin

        VendorLedgerEntry.SetRange("Currency Code", Rec."Currency Code");
        VendorLedgerEntry.SetFilter("Remaining Amount", '<0');

        if VendorLedgerEntry.Findset(false) then
            repeat
                Vendor.SetLoadFields("Vendor Posting Group");
                VendorLedgerEntry.CalcFields("TFB Forex Amount", "Remaining Amount");
                if Vendor.Get(VendorLedgerEntry."Vendor No.") then
                    //Reverse sign on Remaining 
                    CalcTotal += -VendorLedgerEntry."Remaining Amount" - VendorLedgerEntry."TFB Forex Amount";

            until VendorLedgerEntry.next() = 0;
        exit(CalcTotal);
    end;

    local procedure CalculatePurchasesUncovered() CalcTotal: Decimal

    var

        ContainerEntry: Record "TFB Container Entry";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";


    begin

        ContainerEntry.SetRange(Closed, false);

        if ContainerEntry.Findset(false) then
            repeat
                if ContainerEntry.Status = ContainerEntry.Status::ShippedFromPort then
                    if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, ContainerEntry."Order Reference") then begin
                        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                        if PurchaseLine.Findset(false) then
                            repeat
                                if (PurchaseLine.Quantity - PurchaseLine."Quantity Invoiced") > 0 then
                                    CalcTotal += PurchaseLine."Line Amount" * ((PurchaseLine.Quantity - PurchaseLine."Quantity Invoiced") / PurchaseLine.Quantity)
                            until PurchaseLine.Next() = 0;
                    end;
            until ContainerEntry.Next() = 0;

        exit(CalcTotal);
    end;


    trigger OnAfterGetRecord()

    begin
        _UncoveredLedgerEntries := CalculateLedgerEntriesUncovered();
        _UncoveredPurchases := CalculatePurchasesUncovered();


    end;

    var
        _UncoveredLedgerEntries: Decimal;
        _UncoveredPurchases: Decimal;


}
page 50160 "TFB Forex Contract FB"
{
    Caption = 'Forex Contract Details';
    PageType = ListPart;
    SourceTable = "TFB Forex Mgmt Entry";
    SourceTableView = where(EntryType = const(ForexContract));

    layout
    {
        area(Content)
        {

            field(UncoveredLedgerEntries; _UncoveredLedgerEntries)
            {
                ApplicationArea = All;
                Caption = 'Uncovered Invoices';
                ToolTip = 'Specifies the value of ledger entries uncovered.';
            }
            field(UncoveredPurchases; _UncoveredPurchases)
            {
                ApplicationArea = All;
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
                If Vendor.Get(VendorLedgerEntry."Vendor No.") then
                    //Reverse sign on Remaining 
                    CalcTotal += -VendorLedgerEntry."Remaining Amount" - VendorLedgerEntry."TFB Forex Amount";

            until VendorLedgerEntry.next() = 0;
        Exit(CalcTotal);
    end;

    local procedure CalculatePurchasesUncovered() CalcTotal: Decimal

    var

        ContainerEntry: Record "TFB Container Entry";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";


    begin

        ContainerEntry.SetRange(Closed, false);

        If ContainerEntry.Findset(false) then
            repeat
                If ContainerEntry.Status = ContainerEntry.Status::ShippedFromPort then
                    If PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, ContainerEntry."Order Reference") then begin
                        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                        If PurchaseLine.Findset(false) then
                            repeat
                                If (PurchaseLine.Quantity - PurchaseLine."Quantity Invoiced") > 0 then
                                    CalcTotal += PurchaseLine."Line Amount" * ((PurchaseLine.Quantity - PurchaseLine."Quantity Invoiced") / PurchaseLine.Quantity)
                            until PurchaseLine.Next() = 0;
                    end;
            until ContainerEntry.Next() = 0;

        Exit(CalcTotal);
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
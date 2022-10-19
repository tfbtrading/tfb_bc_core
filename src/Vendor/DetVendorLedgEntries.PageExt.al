pageextension 50100 "TFB Det. Vendor Ledg. Entries" extends "Detailed Vendor Ledg. Entries" //574
{
    layout
    {
        modify("Document No.")
        {
            Visible = false;
        }
        addafter("Document No.")
        {
            field(TFBPaymentExtRef; ExtRef)
            {
                Caption = 'Ext. Doc. No.';
                Tooltip = 'Specifies external reference for vendor';
                ApplicationArea = All;
                Editable = false;
            }
        }
        addafter(Amount)
        {
            field("TFB Implied Exchange Rate"; _ImpExchRate)
            {
                Caption = 'Implied Exch. Rate';
                ToolTip = 'Specifies the exchange rate implied by the different being overseas and local currency';
                ApplicationArea = All;
                Editable = false;
                BlankZero = true;
            }
            field(GetUnrealizedGainLossAmount; Rec.GetUnrealizedGainLossAmount(Rec."Entry No."))
            {
                Caption = 'Unrealised Gain/Loss';
                Tooltip = 'Specifies unrealised gain/loss amount';
                ApplicationArea = All;
                Editable = false;
            }
        }


    }

    actions
    {
        addafter("&Navigate")
        {
            action(TFBAppliedEntry)
            {
                ApplicationArea = All;
                Caption = 'Applied entry';
                Tooltip = 'Opens any applied entries to the ledger entry';
                Image = Entry;

                trigger OnAction()

                var
                    TempAppliedVendLedgerEntries: Record "Vendor Ledger Entry" temporary;
                    VendorLedger: CodeUnit "VendEntry-Apply Posted Entries";
                    VendorLedgerEntries: Page "Vendor Ledger Entries";

                begin
                    VendorLedger.GetAppliedVendLedgerEntries(TempAppliedVendLedgerEntries, Rec."Vendor Ledger Entry No.");
                    VendorLedgerEntries.SetRecord(TempAppliedVendLedgerEntries);
                    VendorLedgerEntries.Run();
                end;

            }
        }

        addfirst(Promoted)
        {
            actionref(TFBAppliedEntry_Promoted; TFBAppliedEntry)
            {

            }
        }
    }

    trigger OnAfterGetRecord()

    begin

        //For each record we want to go and retrieve external reference number and set for field variable
        Clear(VendorLedgerEntry);
        ExtRef := '';
        CalcImplExchRate();

        //Check if payment allocation and get applied vendor ledger entry reference
        If rec."Entry Type" = rec."Entry Type"::Application then
            if VendorLedgerEntry.Get(rec."Vendor Ledger Entry No.") then
                ExtRef := VendorLedgerEntry."External Document No.";

        //If initial entry and not a payment get external reference number from vendor ledger
        if rec."Entry Type" = rec."Entry Type"::"Initial Entry" then
            if rec."Document Type" <> rec."Document Type"::Payment then
                If VendorLedgerEntry.Get(rec."Vendor Ledger Entry No.") then
                    ExtRef := VendorLedgerEntry."External Document No.";

    end;

    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ExtRef: Text;

        _ImpExchRate: Decimal;

    local procedure CalcImplExchRate(): Decimal

    var

    begin
        _ImpExchRate := 0;
        If (Rec.Amount <> 0) and (Rec."Currency Code" <> '') then
            if Rec.Amount <> Rec."Amount (LCY)" then
                _ImpExchRate := Round(Rec.Amount / Rec."Amount (LCY)", 0.0001, '=');

    end;

}
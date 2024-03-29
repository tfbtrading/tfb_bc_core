page 50153 "TFB Vend. Applied Entries FB"
{
    Caption = 'Invoice Applied Payments';
    PageType = ListPart;
    SourceTable = "Detailed Vendor Ledg. Entry";
    SourceTableView = where("Entry Type" = const(Application), "Document Type" = const(Payment), "Initial Document Type" = const(Invoice));
    ApplicationArea = All;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    Caption = 'Paid On';
                    ToolTip = 'Specifies the value of the Paid On field.';
                }
                field(Amount; Rec.Amount)
                {
                    Caption = 'Invoice Amount Paid';
                    ToolTip = 'Specifies the value of the Invoice Amount Paid field.';
                }
                field(TotalPaymentAmount; _TotalPaymentAmount)
                {
                    Caption = 'Total in Payment';
                    ToolTip = 'Specifies the value of the Total in Payment field.';
                }
                field(PaymentDetail; _PaymentDetails)
                {
                    Caption = 'Paid from';
                    ToolTip = 'Specifies the value of the Paid from field.';
                }


            }
        }

    }


    actions
    {

    }


    trigger OnAfterGetRecord()

    begin
        SetDetailedPaymentLedgerEntry();
        _TotalPaymentAmount := GetTotalPaymentAmount();
        _PaymentDetails := GetPaymentDetails();

    end;

    local procedure SetDetailedPaymentLedgerEntry()

    begin
        DetailedVendorLedgerEntry2.SetRange("Document No.", Rec."Document No.");
        DetailedVendorLedgerEntry2.SetRange("Entry Type", DetailedVendorLedgerEntry2."Entry Type"::Application);
        DetailedVendorLedgerEntry2.SetFilter("Initial Document Type", '%1|%2', DetailedVendorLedgerEntry2."Initial Document Type"::Payment, DetailedVendorLedgerEntry2."Initial Document Type"::"Credit Memo");
        DetailedVendorLedgerEntry2.SetLoadFields("Vendor Ledger Entry No.", "Source Code");

        if DetailedVendorLedgerEntry2.FindFirst() then
            VendorLedgerEntry2.Get(DetailedVendorLedgerEntry2."Vendor Ledger Entry No.")
        else
            Clear(VendorLedgerEntry2);
    end;

    local procedure GetTotalPaymentAmount(): Decimal


    begin
        exit(-(DetailedVendorLedgerEntry2.Amount));
    end;

    local procedure GetPaymentDetails(): Text[100]
    var
        Bank: Record "Bank Account";

    begin

        if not (VendorLedgerEntry2.IsEmpty()) then
            if VendorLedgerEntry2."Bal. Account Type" = VendorLedgerEntry2."Bal. Account Type"::"Bank Account" then
                if Bank.Get(VendorLedgerEntry2."Bal. Account No.") then
                    exit(StrSubstNo('Paid from %1 using %2', Bank.Name, VendorLedgerEntry2."Source Code"));


    end;

    var
        DetailedVendorLedgerEntry2: Record "Detailed Vendor Ledg. Entry";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        _TotalPaymentAmount: Decimal;

        _PaymentDetails: Text;

}
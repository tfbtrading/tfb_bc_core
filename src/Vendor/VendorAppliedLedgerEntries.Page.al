page 50153 "TFB Vend. Applied Entries FB"
{
    Caption = 'Invoice Applied Payments';
    PageType = ListPart;
    SourceTable = "Detailed Vendor Ledg. Entry";
    SourceTableView = where("Entry Type" = const(Application), "Document Type" = const(Payment), "Initial Document Type" = const(Invoice));

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Paid On';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Invoice Amount Paid';
                }
                field(TotalPaymentAmount; GetTotalPaymentAmount())
                {
                    ApplicationArea = All;
                    Caption = 'Total in Payment';
                }
                field(PaymentDetail; GetPaymentDetails())
                {
                    ApplicationArea = All;
                    Caption = 'Paid from';
                }


            }
        }

    }


    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }


    trigger OnAfterGetRecord()

    begin

    end;

    local procedure SetDetailedPaymentLedgerEntry()

    begin
        DetailedVendorLedgerEntry2.SetRange("Document No.", Rec."Document No.");
        DetailedVendorLedgerEntry2.SetRange("Entry Type", DetailedVendorLedgerEntry2."Entry Type"::Application);
        DetailedVendorLedgerEntry2.SetFilter("Initial Document Type", '%1|%2', DetailedVendorLedgerEntry2."Initial Document Type"::Payment, DetailedVendorLedgerEntry2."Initial Document Type"::"Credit Memo");

        If DetailedVendorLedgerEntry2.FindFirst() then begin
            VendorLedgerEntry2.Get(DetailedVendorLedgerEntry2."Vendor Ledger Entry No.");

        end
        else
            Clear(VendorLedgerEntry2);
    end;

    local procedure GetTotalPaymentAmount(): Decimal


    begin
        Exit(-(DetailedVendorLedgerEntry2.Amount));
    end;

    local procedure GetPaymentDetails(): Text[100]
    var
        Bank: Record "Bank Account";

    begin

        If not (VendorLedgerEntry2.IsEmpty()) then begin
            If VendorLedgerEntry2."Bal. Account Type" = VendorLedgerEntry2."Bal. Account Type"::"Bank Account" then
                If Bank.Get(VendorLedgerEntry2."Bal. Account No.") then
                    Exit(StrSubstNo('Paid from %1 using %2', Bank.Name, VendorLedgerEntry2."Source Code"));
        end;

    end;

    var
        DetailedVendorLedgerEntry2: Record "Detailed Vendor Ledg. Entry";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";

}
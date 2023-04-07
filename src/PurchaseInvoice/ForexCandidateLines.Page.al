page 50164 "TFB Forex Candidate Lines"
{

    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "TFB Forex Mgmt Entry";
    SourceTableTemporary = true;
    AutoSplitKey = true;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    DelayedInsert = true;
    SourceTableView = where(EntryType = filter('PurchaseOrder|VendorLedgerEntry'));
    ApplicationArea = All;



    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                }

                field("External Document No."; Rec."External Document No.")
                {
                    ToolTip = 'Specifies the value of the External Document No. field.';

                }

                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';

                }
                field("Original Amount"; Rec."Original Amount")
                {
                    ToolTip = 'Specifies the value of the Original Amount field.';
                    Caption = 'Amount';

                }

                field(RemainingAmount; RemainingAmount)
                {
                    ToolTip = 'Specifies the remaining amount after ';
                    Caption = 'Remaining Amount';
                    Editable = false;
                }
                field("Original Currency Factor"; Rec."Covered Rate")
                {
                    ToolTip = 'Specifies the value of the Original Currency Factor field.';

                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the value of the Due Date field.';


                }

                field(Open; Rec.Open)
                {
                    Style = Favorable;
                    StyleExpr = not Rec.Open;
                    ToolTip = 'Specifies whether the application or original forex entry are still open';
                    Caption = 'Open';
                }

            }


            group(Totals)
            {
                ShowCaption = false;
                label(Control13)
                {
                    ApplicationArea = Basic, Suite;
                    ShowCaption = false;
                    Caption = ' ';
                }

                field(TotalBalance; TotalBalance)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = GetCurrencyCode();
                    AutoFormatType = 1;
                    Caption = 'Total Balance';
                    Editable = false;

                    ToolTip = 'Specifies the accumulated balance of the bank reconciliation, which consists of the Balance Last Statement field, plus the balance in the Statement Amount field.';
                }
                field(TotalRemaining; TotalRemaining)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = GetCurrencyCode();
                    AutoFormatType = 1;
                    Caption = 'Total Remaining';
                    Editable = false;

                    ToolTip = 'Specifies the total amount of the Difference field for all the lines on the bank reconciliation.';
                }
            }

        }



    }
    actions
    {

    }
    trigger OnAfterGetRecord()

    begin
        RemainingAmount := Rec.getRemainingAmountByAppliesToId(Rec."Applies-to id");
    end;



    procedure GetCurrencyCode(): Code[10]
    var

    begin
        exit(Rec."Currency Code");

    end;

    procedure GetStyle(): Text
    begin

        if Rec.getRemainingAmountByAppliesToId(Rec."Applies-to id") = 0 then
            exit('Favorable');
        exit('');
    end;


    procedure PrepareEntries()

    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
     

    begin

        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetFilter("Currency Code", '<>%1', '');
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.LoadFields(Amount, "Due Date", Open, "Adjusted Currency Factor", "External Document No.", "Currency Code", "Original Amount");

        if VendorLedgerEntry.Findset(false) then
            repeat
                if Rec.getRemainingAmountByVendorLedgerEntry(VendorLedgerEntry) > 0 then begin
                    Rec.Init();
                    Rec."Entry No." := VendorLedgerEntry."Entry No.";

                    VendorLedgerEntry.CalcFields(Amount, "Remaining Amount", "TFB Forex Amount", "Original Amount");
                    Rec.Validate(EntryType, Rec.EntryType::VendorLedgerEntry);
                    Rec.validate("External Document No.", VendorLedgerEntry."External Document No.");

                    Rec.validate("Currency Code", VendorLedgerEntry."Currency Code");
                    Rec."Applies-to id" := VendorLedgerEntry.SystemId;
                    Rec."Original Amount" := -VendorLedgerEntry."Original Amount";
                    Rec.validate("Covered Rate", VendorLedgerEntry."Adjusted Currency Factor");
                    Rec."Applies-to id" := VendorLedgerEntry.SystemId;

                    Rec.validate("Due Date", VendorLedgerEntry."Due Date");
                    Rec.validate(Open, VendorLedgerEntry.Open);
                    Rec.insert();

                    TotalBalance := TotalBalance + (-VendorLedgerEntry."Original Amount");
                    TotalRemaining := TotalRemaining + Rec.getRemainingAmountByVendorLedgerEntry(VendorLedgerEntry);
                end;
            until VendorLedgerEntry.Next() = 0;

    end;



    var

        RemainingAmount: Decimal;
        TotalBalance: Decimal;
        TotalRemaining: Decimal;

    


    trigger OnOpenPage()

    begin
        PrepareEntries();
    end;

}



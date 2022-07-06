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
    SourceTableView = Where(EntryType = filter('PurchaseOrder|VendorLedgerEntry'));


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = All;
                    Visible = false;
                }

                field("External Document No."; Rec."External Document No.")
                {
                    ToolTip = 'Specifies the value of the External Document No. field.';
                    ApplicationArea = All;

                }

                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    ApplicationArea = All;

                }
                field("Original Amount"; Rec."Original Amount")
                {
                    ToolTip = 'Specifies the value of the Original Amount field.';
                    Caption = 'Amount';
                    ApplicationArea = All;

                }

                field(RemainingAmount; RemainingAmount)
                {
                    ToolTip = 'Specifies the remaining amount after ';
                    Caption = 'Remaining Amount';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Original Currency Factor"; Rec."Covered Rate")
                {
                    ToolTip = 'Specifies the value of the Original Currency Factor field.';
                    ApplicationArea = All;

                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the value of the Due Date field.';
                    ApplicationArea = All;


                }

                field(Open; Rec.Open)
                {
                    Style = Favorable;
                    StyleExpr = not Rec.Open;
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the application or original forex entry are still open';
                    Caption = 'Open';
                }

            }




        }



    }
    actions
    {

    }

    trigger OnAfterGetCurrRecord()
    begin
        RemainingAmount := Rec.getRemainingAmount(Rec."Entry No.");
    end;

    procedure GetCurrencyCode(): Code[10]
    var

    begin
        Exit(Rec."Currency Code");

    end;

    procedure GetStyle(): Text
    begin
        if Rec.getRemainingAmount(Rec."Entry No.") = 0 then
            exit('Favorable');
        exit('');
    end;


    procedure PrepareEntries()

    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchaseHeader: Record "Purchase Header";
        EntryNo: Integer;

    begin

        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetFilter("Currency Code", '<>%1', '');
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.LoadFields("Due Date", Open, "Adjusted Currency Factor", "External Document No.", "Currency Code", "Original Amount");

        If VendorLedgerEntry.FindSet(false, false) then
            repeat
                Rec.Init();
                Rec."Entry No." += 1000;
                VendorLedgerEntry.CalcFields("Remaining Amount", "TFB Forex Amount");
                Rec.Validate(EntryType, Rec.EntryType::VendorLedgerEntry);
                Rec.validate("External Document No.", VendorLedgerEntry."External Document No.");

                Rec.validate("Currency Code", VendorLedgerEntry."Currency Code");
                Rec."Applies-to id" := VendorLedgerEntry.SystemId;
                Rec.validate("Original Amount", -VendorLedgerEntry."Original Amount");
                Rec.validate("Covered Rate", VendorLedgerEntry."Adjusted Currency Factor");
                Rec.validate("Due Date", VendorLedgerEntry."Due Date");
                Rec.validate(Open, VendorLedgerEntry.Open);
                Rec.insert();

            until VendorLedgerEntry.Next() = 0;

    end;



    var

        RemainingAmount: Decimal;
        PastDue: Boolean;


        StyleTxt: Text;
        [InDataSet]
        TotalBalance: Decimal;
        [InDataSet]
        TotalRemaining: Decimal;
        [InDataSet]
        TotalBalanceEnable: Boolean;
        [InDataSet]
        TotalRemainingEnable: Boolean;


    trigger OnOpenPage()

    begin
        PrepareEntries();
    end;

}


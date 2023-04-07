page 50114 "TFB Bank Account Part List"
{

    Caption = 'Bank Account List';
    PageType = ListPart;
    SourceTable = "Bank Account";
    SourceTableView = where(Blocked = const(false));


    layout
    {
        area(content)
        {
            repeater(General)
            {

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies name of the bank account';
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        Bank: Record "Bank Account";
                        BankCard: Page "Bank Account Card";


                    begin

                        if Bank.Get(Rec."No.") then begin
                            BankCard.SetRecord(Bank);
                            BankCard.Run();

                        end;
                    end;
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies balance of the account currently';
                }

                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Width = 5;
                    Visible = false;
                    ToolTip = 'Specifies the currency of the bank account';
                }
                field("TFB No. Open Trans."; Rec."TFB No. Open Trans.")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = Rec."TFB No. Open Trans." > 0;
                    ToolTip = 'Specifies number of open transactions not reconcilied in the account';
                }

                field("TFB Difference"; _BalanceStatementDifference)
                {

                    ApplicationArea = All;
                    Caption = 'Unreconciled';
                    Style = Favorable;
                    StyleExpr = _BalanceStatementDifference = 0;
                    ToolTip = 'Specifies unreconciled amount';
                }


                field(TFBLastStatementDate; Rec."TFB Latest Statement Date")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies last statement no';
                    Caption = 'Last Statement Date';


                }
            }
        }


    }
    actions
    {
        area(Processing)
        {
            action(ImportBankSatement)
            {
                ApplicationArea = All;
                Scope = Page;
                Caption = 'Payment Reconciliation..';
                AccessByPermission = TableData "Bank Export/Import Setup" = IMD;

                Image = Import;
                RunObject = Codeunit "Pmt. Rec. Jnl. Import Trans.";
                ToolTip = 'To start the process of reconciling new payments, import a bank feed or electronic file containing the related bank transactions.';


            }

            action(ShowIncomingDocs)
            {
                ApplicationArea = All;
                Scope = Repeater;
                Caption = 'Show Missing IC Docs';

                Image = Documents;
                ToolTip = 'Show entries with missing incoming documents related to underlying general ledger';

                trigger OnAction()

                var

                    cu: CodeUnit "TFB Banking";

                begin

                    cu.OpenMissingIncomingDocsPage(rec."Bank Account No.");
                end;
            }
        }

    }

    var
        _BalanceStatementDifference: Decimal;


    trigger OnAfterGetRecord()


    begin
        Rec.CalcFields(Balance);
        _BalanceStatementDifference := Rec.Balance - GetLatestStatementAmount();

    end;

    /// <summary> 
    /// Description for GetLatestStatementAmount.
    /// </summary>
    /// <returns>Return variable "Decimal".</returns>
    local procedure GetLatestStatementAmount(): Decimal

    var
        BS: Record "Bank Account Statement";


    begin

        BS.SetRange("Bank Account No.", Rec."No.");
        BS.SetCurrentKey("Statement Date");
        BS.SetAscending("Statement Date", false);
        if BS.FindFirst() then
            exit(BS."Statement Ending Balance")
        else
            exit(0);

    end;

}

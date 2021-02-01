pageextension 50104 "TFB BankAccountList" extends "Bank Account List" //371
{
    layout
    {

        modify("Phone No.")
        {
            Visible = false;
        }
        modify(Contact)
        {
            Visible = false;
        }
        modify(IBAN)
        {
            Visible = false;
        }
        modify("SWIFT Code")
        {
            Visible = false;
        }
        modify("Bank Acc. Posting Group")
        {
            Visible = false;
        }
        addafter("Bank Account No.")
        {

            field(Balance; Rec.Balance)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies balance on account';
            }

            field("TFB No. Open Trans."; Rec."TFB No. Open Trans.")
            {
                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = "Bank Account Ledger Entries";
                ToolTip = 'Specific no. of open transactions';
            }
            field("Balance Last Statement"; Rec."Balance Last Statement")
            {

                ApplicationArea = All;
                ToolTip = 'Specifies balance at last statement';
            }


            field("Last Statement No."; Rec."Last Statement No.")
            {
                ApplicationArea = All;
                DrillDown = true;
                ToolTip = 'Specifies last statement no';

                Trigger OnDrillDown()

                var
                    Stmt: Record "Bank Account Statement";
                    StmtPage: Page "Bank Account Statement";


                begin

                    Stmt.SetRange("Bank Account No.", Rec."Bank Account No.");
                    Stmt.SetRange("Statement No.", Rec."Last Statement No.");

                    If Stmt.FindFirst() then begin

                        StmtPage.SetRecord(Stmt);
                        StmtPage.Run();
                    end;
                end;

            }
        }

    }

    actions
    {
    }





}
page 50162 "TFB Forex Contract Lines"
{

    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "TFB Forex Mgmt Entry";
    AutoSplitKey = true;
    Editable = true;
    InsertAllowed = true;
    LinksAllowed = false;
    DelayedInsert = true;
    SourceTableView = where(EntryType = const(ForexContract));
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
                    Editable = not Rec."Applying Entry";
                }

                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    Editable = Rec."Applying Entry" = false;
                }
                field("Original Amount"; Rec."Original Amount")
                {
                    ToolTip = 'Specifies the value of the Original Amount field.';
                    Caption = 'Amount';

                    trigger OnValidate()

                    begin
                        if Rec."Entry No." <> 0 then
                            RemainingAmount := Rec.getRemainingAmount(Rec."Entry No.");
                    end;

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
                    Enabled = Rec."Currency Code" <> '';
                    Editable = Rec."Applying Entry" = false;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the value of the Due Date field.';
                    Editable = Rec."Applying Entry" = false;

                }

                field(Open; Rec.IsOpen())
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
        area(Processing)
        {

        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."Entry No." <> 0 then
            CalcBalance();
        SetUserInteractions();
    end;

    procedure GetCurrencyCode(): Code[10]
    var

    begin
        exit(Rec."Currency Code");

    end;

    procedure GetStyle(): Text
    begin
        if Rec.getRemainingAmount(Rec."Entry No.") = 0 then
            exit('Favorable');

        exit('');
    end;



    local procedure CalcBalance()

    var
        ForexMgmtEntryTemp: Record "TFB Forex Mgmt Entry";
    begin
        TotalRemaining := 0;
        ForexMgmtEntryTemp.Copy(Rec);


        if ForexMgmtEntryTemp.CalcSums("Original Amount") then
            TotalBalance := ForexMgmtEntryTemp."Original Amount";

        if ForexMgmtEntryTemp.FindSet() then
            repeat
                TotalRemaining += ForexMgmtEntryTemp.getRemainingAmount(ForexMgmtEntryTemp."Entry No.");
            until ForexMgmtEntryTemp.Next() = 0;

    end;

    local procedure SetUserInteractions()
    begin

    end;

    trigger OnAfterGetRecord()

    begin
        if Rec."Entry No." <> 0 then
            RemainingAmount := Rec.getRemainingAmount(Rec."Entry No.");
    end;


    procedure ToggleShowOpenEntriesFilter(ShowOpenEntriesOnly: Boolean)
    begin
        if ShowOpenEntriesOnly then
            Rec.SetRange(Open, true)
        else
            Rec.SetRange(Open);
        CurrPage.Update();
    end;

    var

        RemainingAmount: Decimal;

        TotalBalance: Decimal;

        TotalRemaining: Decimal;





}



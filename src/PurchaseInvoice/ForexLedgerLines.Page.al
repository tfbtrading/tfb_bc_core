page 50163 "TFB Forex Ledger Lines"
{

    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "TFB Forex Mgmt Entry";
    AutoSplitKey = true;
    Editable = true;

    InsertAllowed = true;
    LinksAllowed = true;
    DelayedInsert = true;
    SourceTableView = where(EntryType = const(Assignment));
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


                field("Source Document No."; Rec."Source Document No.")
                {
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                    Editable = true;
                    Enabled = true;
                }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    ToolTip = 'Specifies the value of the Source Entry No. field.';
                    Visible = false;
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ToolTip = 'Specifies the value of the Applies-to Doc. Type field.';
                    Enabled = Rec."Applying Entry" = true;
                }
                field("Applies-to Doc No."; Rec."Applies-to Doc No.")
                {
                    ToolTip = 'Specifies the value of the Applies-to Doc No. field.';
                    Enabled = Rec."Applying Entry" = true;
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
                field("Est. Interest"; Rec."Est. Interest")
                {
                    ToolTip = 'Specifies the estimated interest amount to be charged by the trade finance';
                    Enabled = Rec."Applying Entry";
                    Editable = Rec."Applying Entry";
                }
                field(Total; Rec."Original Amount" + Rec."Est. Interest")
                {
                    Caption = 'Total';
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the total amount inclusive of finance amount and interest';
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ToolTip = 'Specifies the anticipated interest rate to be charged for this trade finance';
                    Enabled = Rec."Applying Entry";
                    Editable = Rec."Applying Entry";

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
        area(Processing)
        {

        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Validate(EntryType, Enum::"TFB Forex Mgmt Entry Type"::Assignment);
    end;

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

    procedure ToggleShowOpenEntriesFilter(ShowOpenEntriesOnly: Boolean)
    begin
        if ShowOpenEntriesOnly then
            Rec.SetRange(Open, true)
        else
            Rec.SetRange(Open);
        CurrPage.Update();
    end;

    procedure GetStyle(): Text
    begin
        if Rec.getRemainingAmountByAppliesToId(Rec."Applies-to id") = 0 then
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

    procedure ToggleContractFilter(DocNoFilter: Code[20])
    begin
        if DocNoFilter <> '' then begin
            Rec.SetRange("Source Document No.", DocNoFilter);
            CurrPage.Editable := false;
        end
        else begin
            Rec.SetRange("Source Document No.");
            CurrPage.Editable := false;
        end;
        CurrPage.Update();

    end;



    var
        RemainingAmount: Decimal;
        TotalBalance: Decimal;
        TotalRemaining: Decimal;





}



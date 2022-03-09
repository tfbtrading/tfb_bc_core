page 50156 "TFB Forex Mgmt Entries"
{
    ApplicationArea = All;
    Caption = 'Forex Management Entries';
    PageType = List;
    SourceTable = "TFB Forex Mgmt Entry";
    UsageCategory = Lists;
    AutoSplitKey = true;
    Editable = true;
    InsertAllowed = true;
    DelayedInsert = true;
    PromotedActionCategories = 'New,Process,Navigation,Related';


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
                field(EntryType; Rec.EntryType)
                {
                    ToolTip = 'Specifies the value of the EntryType field.';
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ToolTip = 'Specifies the value of the External Document No. field.';
                    ApplicationArea = All;
                    Editable = not Rec."Applying Entry";
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                    ApplicationArea = All;
                    Editable = (Rec.EntryType = Rec.EntryType::PurchaseOrder) or (Rec.EntryType = Rec.EntryType::VendorLedgerEntry) or (Rec.EntryType = Rec.EntryType::Assignment);
                }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    ToolTip = 'Specifies the value of the Source Entry No. field.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    ApplicationArea = All;
                    Editable = Rec."Applying Entry" = false;
                }
                field("Original Amount"; Rec."Original Amount")
                {
                    ToolTip = 'Specifies the value of the Original Amount field.';
                    Caption = 'Amount';
                    ApplicationArea = All;

                    trigger OnValidate()

                    begin
                        If Rec."Entry No." <> 0 then
                            RemainingAmount := Rec.getRemainingAmount(Rec."Entry No.");
                    end;

                }
                field("Est. Interest"; Rec."Est. Interest")
                {
                    ToolTip = 'Specifies the estimated interest amount to be charged by the trade finance';
                    ApplicationArea = All;
                    Enabled = Rec."Applying Entry";
                    Editable = Rec."Applying Entry";
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ToolTip = 'Specifies the anticipated interest rate to be charged for this trade finance';
                    ApplicationArea = All;
                    Enabled = Rec."Applying Entry";
                    Editable = Rec."Applying Entry";

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
                    Enabled = Rec."Currency Code" <> '';
                    Editable = Rec."Applying Entry" = false;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the value of the Due Date field.';
                    ApplicationArea = All;
                    Editable = Rec."Applying Entry" = false;
                    Style = Unfavorable;
                    StyleExpr = PastDue;
                }


                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ToolTip = 'Specifies the value of the Applies-to Doc. Type field.';
                    ApplicationArea = All;
                    Enabled = Rec."Applying Entry" = true;
                }
                field("Applies-to Doc No."; Rec."Applies-to Doc No.")
                {
                    ToolTip = 'Specifies the value of the Applies-to Doc No. field.';
                    ApplicationArea = All;
                    Enabled = Rec."Applying Entry" = true;
                }

                field("Applying Entry"; Rec."Applying Entry")
                {
                    ToolTip = 'Specifies the value of the Applying Entry field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Open; Rec.Open)
                {
                    Style = Favorable;
                    StyleExpr = not Rec.Open;
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the application or original forex entry are still open';

                }

            }

        }
        area(factboxes)
        {
            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
                SubPageLink = "Posting Date" = field("Applies-to Posting Date"), "Document No." = field("Applies-to Entry Doc. No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }


    }
    actions
    {
        area(Navigation)
        {
            action(OpenSource)
            {
                ApplicationArea = All;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Promoted = true;
                Image = Open;
                Caption = 'Open Applied Document';
                ToolTip = 'Opens the applied document if spceified';
                Enabled = Rec."Applies-to Doc No." <> '';

                trigger OnAction()
                var
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                begin

                    case Rec."Applies-to Doc. Type" of
                        Rec."Applies-to Doc. Type"::VendorLedgerEntry:

                            If VendorLedgerEntry.GetBySystemId(Rec."Applies-to id") then
                                Page.Run(Page::"Vendor Ledger Entries", VendorLedgerEntry);

                    end;

                end;
            }
        }
    }

    trigger OnAfterGetRecord()

    begin
        If Rec."Entry No." <> 0 then
            RemainingAmount := Rec.getRemainingAmount(Rec."Entry No.");

        If Rec."Due Date" < Today() then
            PastDue := true;
    end;

    var

        RemainingAmount: Decimal;
        PastDue: Boolean;
}

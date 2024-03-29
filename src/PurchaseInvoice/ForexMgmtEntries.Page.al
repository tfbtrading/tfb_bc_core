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
                field(EntryType; Rec.EntryType)
                {
                    ToolTip = 'Specifies the value of the EntryType field.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ToolTip = 'Specifies the value of the External Document No. field.';
                    Editable = not Rec."Applying Entry";
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                    Editable = (Rec.EntryType = Rec.EntryType::PurchaseOrder) or (Rec.EntryType = Rec.EntryType::VendorLedgerEntry) or (Rec.EntryType = Rec.EntryType::Assignment);
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




                field("Applying Entry"; Rec."Applying Entry")
                {
                    ToolTip = 'Specifies the value of the Applying Entry field.';
                    Editable = false;
                }
                field(Open; Rec.IsOpen())
                {
                    Style = Favorable;
                    StyleExpr = not Rec.Open;
                    ToolTip = 'Specifies whether the application or original forex entry are still open';
                    Caption = 'Open';
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
            part(LedgerEntry; "TFB Forex Vend.Ledg. Factbox")
            {
                ShowFilter = false;
                SubPageLink = SystemId = field("Applies-to id");
                Visible = Rec."Applies-to Doc. Type" = Rec."Applies-to Doc. Type"::VendorLedgerEntry;
            }
            part(ContractEntry; "TFB Forex Contract FB")
            {
                ShowFilter = false;
                SubPageLink = SystemId = field(SystemId);
                Visible = Rec.EntryType = Rec.EntryType::ForexContract;
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

                            if VendorLedgerEntry.GetBySystemId(Rec."Applies-to id") then begin
                                VendorLedgerEntry.SetRecFilter();
                                Page.Run(Page::"Vendor Ledger Entries", VendorLedgerEntry);
                            end;
                    end;

                end;
            }
        }
        area(Promoted)
        {
            actionref(OpenSourceRef; OpenSource)
            {


            }
        }
    }

    trigger OnAfterGetRecord()

    begin
        if Rec."Entry No." <> 0 then
            RemainingAmount := Rec.getRemainingAmount(Rec."Entry No.");
    end;



    var

        RemainingAmount: Decimal;
     
}

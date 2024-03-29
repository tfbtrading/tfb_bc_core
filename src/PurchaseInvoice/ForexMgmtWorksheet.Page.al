page 50161 "TFB Forex Mgmt Worksheet"
{
    PageType = ListPlus;
    ApplicationArea = All;
    UsageCategory = Administration;
    SaveValues = false;
    Caption = 'Forex Mgmt Worksheet';


    layout
    {
        area(Content)
        {
            group(General)
            {
                field(ForexContract; _ForexContractFilter)
                {
                    TableRelation = "TFB Forex Mgmt Entry" where(EntryType = const(ForexContract));
                    Caption = 'Forex Contract';
                    ToolTip = 'Allows filtering of which Forex Contract is shown';


                    trigger OnValidate()
                    var
                        ForexMgmtEntry: Record "TFB Forex Mgmt Entry";

                    begin
                        if ForexMgmtEntry.Get(_ForexContractFilter) then
                            CurrPage.AppliedLedgerEntries.Page.ToggleContractFilter(ForexMgmtEntry."External Document No.");
                    end;
                }
                field(ShowOpenntries; _ShowOpenEntriesFilter)
                {
                    Caption = 'Show Closed Entries';
                    ToolTip = 'Specifies whether open or closed entries are shown';


                    trigger OnValidate()

                    begin
                        CurrPage.ForexContracts.Page.ToggleShowOpenEntriesFilter(_ShowOpenEntriesFilter);
                        CurrPage.AppliedLedgerEntries.Page.ToggleShowOpenEntriesFilter(_ShowOpenEntriesFilter);
                    end;
                }
            }
            group(ForexContractsGroup)
            {
                ShowCaption = true;
                Caption = 'Forex Contracts';
                part(ForexContracts; "TFB Forex Contract Lines")
                {
                    Caption = 'Lines';
                    UpdatePropagation = Both;

                }

            }
            group(ForexEntriesGroup)
            {
                ShowCaption = true;
                Caption = 'Contract Assignments';
                part(AppliedLedgerEntries; "TFB Forex Ledger Lines")
                {
                    Caption = 'Lines';
                    UpdatePropagation = Both;
                }
            }

            group(Pending)
            {
                ShowCaption = true;
                Caption = 'Outstanding Invoices';

                part(PendingLedgerEntries; "TFB Forex Candidate Lines")
                {
                    Caption = 'Lines';
                    UpdatePropagation = Both;
                }
            }
        }
        area(factboxes)
        {


            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
                Provider = AppliedLedgerEntries;
                SubPageLink = "Posting Date" = field("Applies-to Posting Date"), "Document No." = field("Applies-to Entry Doc. No.");
            }
            part(LedgerEntry; "TFB Forex Vend.Ledg. Factbox")
            {
                ShowFilter = false;
                Provider = AppliedLedgerEntries;
                SubPageLink = SystemId = field("Applies-to id");

            }
            part(ContractEntry; "TFB Forex Contract FB")
            {
                ShowFilter = false;
                Provider = ContractEntry;
                SubPageLink = SystemId = field(SystemId);

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

        area(Processing)
        {
            action(UpdateOpenStatus)
            {
                Image = UpdateDescription;
                Caption = 'Update entry status';
                ToolTip = 'Performs a batch update of entry status records';

                trigger OnAction()

                begin
                    Codeunit.Run(CodeUnit::"TFB Update Forex Entry Status");
                end;

            }
        }

        area(Promoted)
        {
            actionref(UpdateOpenStatusRef; UpdateOpenStatus)
            {

            }
        }
    }

    var
        
        _ForexContractFilter: Integer;

        _ShowOpenEntriesFilter: Boolean;


    trigger OnOpenPage()
    begin
        SetInitialFilters();

        Codeunit.Run(Codeunit::"TFB Update Forex Entry Status");
    end;

    local procedure SetInitialFilters()
    begin
        _ShowOpenEntriesFilter := true;
    end;


}
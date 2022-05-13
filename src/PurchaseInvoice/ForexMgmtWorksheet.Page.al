page 50161 "TFB Forex Mgmt Worksheet"
{
    PageType = ListPlus;
    ApplicationArea = All;
    UsageCategory = Administration;
    PromotedActionCategories = 'New,Process,Report';
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
                    ApplicationArea = All;
                    TableRelation = "TFB Forex Mgmt Entry" where(EntryType = const(ForexContract));
                    Caption = 'Forex Contract';
                    ToolTip = 'Allows filtering of which Forex Contract is shown';

                    trigger OnValidate()
                    var
                        ForexMgmtEntry: Record "TFB Forex Mgmt Entry";

                    begin
                        If ForexMgmtEntry.Get(_ForexContractFilter) then
                            CurrPage.AppliedLedgerEntries.Page.ToggleContractFilter(ForexMgmtEntry."External Document No.");
                    end;
                }
                field(ShowClosedEntries; _ShowClosedEntriesFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Show Closed Entries';
                    ToolTip = 'Specifies whether open or closed entries are shown';


                    trigger OnValidate()

                    begin
                        CurrPage.ForexContracts.Page.ToggleOpenFilter(_ShowClosedEntriesFilter);
                        CurrPage.AppliedLedgerEntries.Page.ToggleOpenFilter(_ShowClosedEntriesFilter);
                    end;
                }
            }
            group(SubPages)
            {
                ShowCaption = false;
                part(ForexContracts; "TFB Forex Contract Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Forex Contract Lines';
                }
                part(AppliedLedgerEntries; "TFB Forex Ledger Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Applied Ledger Lines';
                }
            }

            group(Pending)
            {
                part(PendingLedgerEntries; "TFB Forex Candidate Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Candidate Ledger and Order Lines';
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
                ApplicationArea = All;
                ShowFilter = false;
                Provider = AppliedLedgerEntries;
                SubPageLink = SystemId = field("Applies-to id");

            }
            part(ContractEntry; "TFB Forex Contract FB")
            {
                ApplicationArea = All;
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
        area(navigation)
        {

        }
    }

    var
        myInt: Integer;
        _ForexContractFilter: Integer;

        _ShowClosedEntriesFilter: Boolean;


    trigger OnOpenPage()
    begin
        SetInitialFilters();
    end;

    local procedure SetInitialFilters()
    begin

    end;
}
/// <summary>
/// Codeunit TFB Sales Credit Mgmt (ID 50112).
/// </summary>
codeunit 50112 "TFB Sales Credit Mgmt"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnPostUnApplyCustomerCommitOnAfterGetCustLedgEntry', '', false, false)]
    local procedure OnPostUnApplyCustomerCommitOnAfterGetCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry");
    begin
    end;


}
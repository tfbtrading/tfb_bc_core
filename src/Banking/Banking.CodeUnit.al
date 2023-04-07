codeunit 50101 "TFB Banking"
{

    /// <summary> 
    /// Provides a quick link from bank account to underlying general ledger entries for incoming docs
    /// </summary>
    /// <param name="BankAccountNo">Parameter of type Code[20].</param>
    procedure OpenMissingIncomingDocsPage(BankAccountNo: Code[30])
    var

        r: record "Posted Docs. With No Inc. Buf.";
        Posting: record "Bank Account Posting Group";
        Bank: record "Bank Account";
        p: page "Posted Docs. With No Inc. Doc.";

    begin
        if Bank.Get(BankAccountNo) then
            if Posting.Get(Bank."Bank Acc. Posting Group") then begin
                r.GetDocNosWithoutIncomingDoc(r, 'p1..today', '', Posting."G/L Account No.", '');
                r.UpdateIncomingDocuments();
                p.SetRecord(r);
                p.Run();

            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Reconciliation Post", 'OnBeforeBankAccStmtInsert', '', false, false)]
    /// <summary> 
    /// Description for HandleOnBeforeBankAccStmtInsert.
    /// </summary>
    /// <param name="BankAccReconciliation">Parameter of type Record "Bank Acc. Reconciliation".</param>
    /// <param name="BankAccStatement">Parameter of type Record "Bank Account Statement".</param>
    local procedure HandleOnBeforeBankAccStmtInsert(BankAccReconciliation: Record "Bank Acc. Reconciliation"; var BankAccStatement: Record "Bank Account Statement")

    var
        BankAccRecLine: Record "Bank Acc. Reconciliation Line";

    begin

        BankAccRecLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccRecLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccRecLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");

        BankAccRecLine.SetCurrentKey("Transaction Date");
        BankAccRecLine.SetAscending("Transaction Date", false);

        //Find the last transaction line by date and set the statement date to the date of the last transaction
        if BankAccRecLine.FindFirst() then
            BankAccStatement."Statement Date" := BankAccRecLine."Transaction Date";


    end;
}
codeunit 50225 "TFB Cust. Collections Mgmt"
{
    trigger OnRun()
    begin

    end;

    internal procedure SendDraftEmailWithSelectedInvoices(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        CompanyInfo: Record "Company Information";
        CustInvoice: Record "Sales Invoice Header";
        Customer: Record Customer;
        CustomReportSelection: Record "Custom Report Selection";
        ReportSelections: Record "Report Selections";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        InStream: InStream;
        OutStream: OutStream;
        AttachmentGenerated: Boolean;
        Recipients: List of [Text];
        TitleTxt: Label 'Invoices for Collection';
        FileNameBuilder: TextBuilder;
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;


    begin

        CompanyInfo.Get();

        SubjectNameBuilder.Append(TitleTxt);


        EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);
        if CustLedgerEntry.Findset(false) then
            repeat
                if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice then
                    if CustInvoice.get(CustLedgerEntry."Document No.") then begin
                        clear(TempBlob);
                        RecordRef.GetTable(CustInvoice);

                        Customer.SetLoadFields("E-Mail");
                        Customer.Get(CustLedgerEntry."Sell-to Customer No.");
                        if not Recipients.Contains(Customer."E-Mail") then
                            Recipients.Add(Customer."E-Mail"); //TODO Add in logic to check for who gets invoices

                        // Check for custom report layours
                        CustomReportSelection.SetRange(Usage, Enum::"Report Selection Usage"::"S.Invoice");
                        CustomReportSelection.SetRange("Source No.", Customer."No.");
                        CustomReportSelection.SetRange("Source Type", Database::Customer);
                        CustomReportSelection.SetRange("Use for Email Attachment", true);
                        TempBlob.CreateOutStream();
                        if CustomReportSelection.FindFirst() then
                            if Report.SaveAs(CustomReportSelection."Report ID", '', ReportFormat::Pdf, OutStream, RecordRef) then
                                AttachmentGenerated := true;

                        if not AttachmentGenerated then begin
                            ReportSelections.SetRange(Usage, Enum::"Report Selection Usage"::"S.Invoice");
                            ReportSelections.SetRange("Use for Email Attachment", true);

                            if ReportSelections.FindFirst() then
                                if Report.SaveAs(ReportSelections."Report ID", '', ReportFormat::Pdf, OutStream, RecordRef) then
                                    AttachmentGenerated := true;

                        end;



                        if TempBlob.HasValue() then begin
                            Clear(FileNameBuilder);
                            FileNameBuilder.Append('Copy of ' + CustInvoice.GetDefaultEmailDocumentName());
                            TempBlob.CreateInStream(InStream);
                            EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/PDF', InStream);
                            Email.AddRelation(EmailMessage, Database::"Sales Invoice Header", CustInvoice.SystemId, Enum::"Email Relation Type"::"Related Entity", enum::"Email Relation Origin"::"Compose Context");
                        end;
                    end





            until CustLedgerEntry.Next() < 1;


        Email.AddRelation(EmailMessage, Database::Customer, Customer.SystemId, Enum::"Email Relation Type"::"Related Entity", eNUM::"Email Relation Origin"::"Compose Context");

        Email.OpenInEditorModally(EmailMessage, Enum::"Email Scenario"::"Customer Statement");

    end;


    var

}
codeunit 50137 "TFB Batch Send PO"
{
    trigger OnRun()

    var


    begin
        SendReadyDocuments();
    end;

    /// <summary> 
    /// Check for and send any sales invoices that are ready
    /// </summary>
    procedure SendReadyDocuments()

    var
        PurchaseHeader: Record "Purchase Header";
        ReportSelections: Record "Report Selections";
        BodyReportSelections: Record "Report Selections";
        BodyReportSelections2: Record "Report Selections";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";

        ReportDistributionManagement: Codeunit "Report Distribution Management";
        TempBlob: CodeUnit "Temp Blob";
        RecordRef: RecordRef;
        Instream2: InStream;
        Instream: Instream;
        OutStream2: OutStream;
        OutStream: Outstream;
        DocNo: Code[20];
        ReportUsage: Enum "Report Selection Usage";
        DocName: Text[150];
        HTMLTemplate: Text;
        Recipients: List of [Text];

    begin

        PurchaseHeader.SetRange("No. Printed", 0);
        PurchaseHeader.SetRange("TFB Send Hold", false);
        PurchaseHeader.SetFilter("Document Date", '>=%1', today());

        if PurchaseHeader.FindSet(false) then
            repeat

                DocNo := PurchaseHeader."No.";
                DocName := ReportDistributionManagement.GetFullDocumentTypeText(PurchaseHeader);

                RecordRef.GetTable(PurchaseHeader);

                BodyReportSelections.SetEmailBodyUsageFilters(Enum::"Report Selection Usage"::"P.Order");


                if BodyReportSelections.FindEmailBodyUsageForVend(ReportSelections.Usage::"P.Order", PurchaseHeader."Buy-from Vendor No.", BodyReportSelections2) then
                    repeat
                        TempBlob.CreateOutStream(OutStream);
                        Report.SaveAs(BodyReportSelections2."Report ID", '', ReportFormat::Html, OutStream, RecordRef);
                        TempBlob.CreateInStream(Instream);
                        Recipients.Add(BodyReportSelections.GetEmailAddressForVend(PurchaseHeader."Buy-from Vendor No.", PurchaseHeader, ReportUsage::"P.Order"));

                        Instream.ReadText(HTMLTemplate);


                    until BodyReportSelections2.Next() = 0;

                EmailMessage.Create(Recipients, 'Your purchase order' + DocNo, HTMLTemplate, true);

                if ReportSelections.FindEmailAttachmentUsageForVend(ReportSelections.Usage::"P.Order", PurchaseHeader."Buy-from Vendor No.", BodyReportSelections) then
                    repeat

                        Clear(TempBlob);
                        TempBlob.CreateOutStream(OutStream2);
                        Report.SaveAs(ReportSelections."Report ID", '', ReportFormat::Pdf, OutStream2, RecordRef);
                        TempBlob.CreateInStream(Instream2);
                        EmailMessage.AddAttachment(DocName + DocNo, 'attachment/Pdf', Instream2);
                    until BodyReportSelections2.Next() = 0;


                Email.Enqueue(EmailMessage, Enum::"Email Scenario"::"Purchase Order");
                PurchaseHeader."No. Printed" += 1;
                PurchaseHeader.Modify();



            until PurchaseHeader.Next() = 0;

    end;


}
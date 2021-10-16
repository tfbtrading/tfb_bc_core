pageextension 50172 "TFB Incoming Documents" extends "Incoming Documents"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(PDFViewer; "PDF Viewer Part")
            {
                Caption = 'PDF Viewer';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()
    begin
        ShowPdfInViewer();
    end;

    local procedure ShowPdfInViewer()
    var

        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        TempBlobCodeUnit: CodeUnit "Temp Blob";
    begin
        if not Rec.GetMainAttachment(IncomingDocumentAttachment) then
            exit;

        if IncomingDocumentAttachment.Type <> IncomingDocumentAttachment.Type::PDF then
            exit;

        IncomingDocumentAttachment.CalcFields(Content);
        if not IncomingDocumentAttachment.Content.HasValue() then
            exit;

        CurrPage.PDFViewer.Page.LoadPdfFromBase64(IncomingDocumentAttachment.ToBase64String());
    end;
}
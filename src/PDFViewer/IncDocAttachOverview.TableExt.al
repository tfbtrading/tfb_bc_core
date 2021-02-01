tableextension 50112 "TFB Inc. Doc. Attach. Overview" extends "Inc. Doc. Attachment Overview" // 137
{
    procedure ViewAttachment()
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        NotAvailableAttachmentMsg: Label 'The attachment is no longer available.';
    begin
        if IncomingDocumentAttachment.Get("Incoming Document Entry No.", "Line No.") then
            IncomingDocumentAttachment.ViewAttachment()
        else
            Message(NotAvailableAttachmentMsg);
    end;


}
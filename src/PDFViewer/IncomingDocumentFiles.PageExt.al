pageextension 50171 "TFB Incoming Document Files" extends "Incoming Doc. Attach. FactBox" // 193
{
    actions
    {
        addafter(Export)
        {
            action(ViewPDF)
            {
                ApplicationArea = All;
                Caption = 'View';
                Image = View;
                Visible = Rec.Type = Rec.Type::PDF;
                Scope = "Repeater";
                tooltip = 'Preview attachment';

                trigger OnAction()
                begin
                    ViewAttachment();
                end;
            }
        }
    }

    procedure ViewAttachment()
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        NotAvailableAttachmentMsg: Label 'The attachment is no longer available.';
    begin
        if IncomingDocumentAttachment.Get(Rec."Incoming Document Entry No.", Rec."Line No.") then
            IncomingDocumentAttachment.ViewAttachment()
        else
            Message(NotAvailableAttachmentMsg);
    end;

}
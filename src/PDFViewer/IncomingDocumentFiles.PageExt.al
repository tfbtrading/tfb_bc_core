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
                    Rec.ViewAttachment();
                end;
            }
        }
    }
}
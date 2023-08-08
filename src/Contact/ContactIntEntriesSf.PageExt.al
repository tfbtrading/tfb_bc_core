pageextension 50215 "TFB Contact Int. Entries Sf" extends "Contact Int. Entries Subform"
{

    layout
    {
        moveafter(Description; Evaluation)
        modify(Evaluation)
        {
            Visible = true;
        }
        addafter(Title)
        {
            field("Information Flow"; Rec."Information Flow")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies direction of information';
            }
        }


    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnOpenPage()

    begin
        Rec.SetCurrentKey(Date);
        Rec.SetAscending(Date, false);
        CurrPage.Activate(true);
    end;
}
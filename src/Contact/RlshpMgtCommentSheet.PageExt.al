pageextension 50129 "TFB Rlshp. Mgt. Comment Sheet" extends "Rlshp. Mgt. Comment Sheet"
{
    layout
    {
        addafter(Comment)
        {
            field(TFBCreatedBy; getCreatedByName())
            {
                ApplicationArea = All;
                Caption = 'Created By';
                Editable = False;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        User: record User;

    local procedure getCreatedByName(): Text[100]

    begin
        If not User.GetBySystemId(Rec.SystemCreatedBy) then
            exit('')
        else
            Exit(user."Full Name");

    end;
}
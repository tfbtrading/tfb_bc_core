pageextension 50102 "TFB Return Receipt Lines" extends "Return Receipt Lines" //6667
{
    layout
    {
        addafter("Document No.")
        {
            field("TFBPosting Date"; Rec."Posting Date")
            {
                ApplicationArea = All;
                Editable = false;
                Tooltip = 'Specifies posting date of return receipt';
            }

            field("TFBReturn Order No."; Rec."Return Order No.")
            {
                ApplicationArea = All;
                Editable = False;
                Tooltip = 'Specifies return order no.';
            }
        }

    }

    actions
    {
    }
}
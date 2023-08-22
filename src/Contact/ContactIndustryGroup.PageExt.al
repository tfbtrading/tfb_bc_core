pageextension 50219 "TFB Contact Industry Group" extends "Contact Industry Groups"
{
    layout
    {
        addlast(Control1)
        {
            field("TFB Primary"; Rec."TFB Primary")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if this should be the primary industry';
            }
        }

        modify("Industry Group Code")
        {
            Style = Strong;
            StyleExpr = Rec."TFB Primary";
        }
        modify("Industry Group Description")
        {
            Style = Strong;
            StyleExpr = Rec."TFB Primary";
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var

}
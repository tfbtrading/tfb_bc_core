pageextension 50221 "TFB Contact Job Respons." extends "Contact Job Responsibilities"
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

        modify("Job Responsibility Code")
        {
            Style = Strong;
            StyleExpr = Rec."TFB Primary";
        }
        modify("Job Responsibility Description")
        {
            Style = Strong;
            StyleExpr = Rec."TFB Primary";
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
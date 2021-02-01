pageextension 50180 "TFB Interaction Log Entry" extends "Interaction Log Entries"
{
    layout
    {
        addafter(Description)
        {
            field("TFB Further Details"; Rec."TFB Further Details")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies any further details)';
            }
        }

        modify("Cost (LCY)")
        {
            Visible = false;
        }
        modify("Entry No.")
        {
            Visible = false;
        }
        modify("Duration (Min.)")
        {
            Visible = false;
        }
    }


    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
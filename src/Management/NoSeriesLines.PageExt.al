pageextension 50124 "TFB No. Series Lines" extends "No. Series Lines"
{
    layout
    {
        addafter("Series Code")
        {
            field(TFBSequenceName; Rec."Sequence Name")
            {
                ApplicationArea = All;
                Caption = 'Sequence Name';
                ToolTip = 'Required for new validation check error';
                Editable = true;
                Enabled = true;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

}

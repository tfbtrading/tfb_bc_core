pageextension 50212 "TFB Get Receipt Lines" extends "Get Receipt Lines" //5709
{
    layout
    {
        addafter("Document No.")
        {
            field("TFBOrder No."; Rec."Order No.")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies purchase order number for receipt';
            }
            field("TFB Container No. LookUp"; Rec."TFB Container No. LookUp")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies container number if it exists for receipt';
            }
        }

    }

    actions
    {
    }
}
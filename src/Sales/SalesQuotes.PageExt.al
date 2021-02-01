pageextension 50157 "TFB Sales Quotes" extends "Sales Quotes"
{
    layout
    {
        modify("Posting Date")
        {
            Visible = false;
        }
        modify("Due Date")
        {
            Visible = false;
        }
        modify("External Document No.")
        {
            Visible = false;
        }
        addafter("Sell-to Customer Name")
        {
            field("TFB Group Purchase"; Rec."TFB Group Purchase")
            {
                Visible = true;
                ApplicationArea = All;
                ToolTip = 'Specifies whether the quote is part of a group purchase';
            }
            field("TFB Group Purchase Quote No."; Rec."TFB Group Purchase Quote No.")
            {
                Visible = true;
                ApplicationArea = all;
                Tooltip = 'Specifies the group purchase quote no.';

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
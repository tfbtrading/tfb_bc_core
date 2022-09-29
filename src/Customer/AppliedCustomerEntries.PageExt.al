pageextension 50216 "TFB Applied Customer Entries" extends "Applied Customer Entries"
{
    layout
    {
        addafter("Original Amount")
        {
            field("Due Date"; Rec."Due Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date that the customer ledger is due';
            }

        }
    }

}
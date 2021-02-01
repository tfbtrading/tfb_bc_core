pageextension 50153 "TFB Vendor Ledger Entries" extends "Vendor Ledger Entries"
{


    layout
    {
        addafter(Amount)
        {
            field("Adjusted Currency Factor"; Rec."Adjusted Currency Factor")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the adjusted currency rate';
                DecimalPlaces = 2 : 4;
            }

            field("Original Currency Factor"; Rec."Original Currency Factor")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the original currency rate';
                DecimalPlaces = 2 : 4;
            }


        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
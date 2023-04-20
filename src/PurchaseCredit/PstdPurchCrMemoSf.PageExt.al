pageextension 50183 "TFB Pstd. Purch. Cr. Memo Sf" extends "Posted Purch. Cr. Memo Subform"
{
    layout
    {
        modify("Unit Price (LCY)")
        {
            Visible = false;
        }

        addafter("Line Amount")
        {
            field(tfbOrderNo; Rec."Order No.")
            {
                ToolTip = 'Specifies the related Purchase Order number for the credit if it exists';
                Caption = 'Order No.';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

   
}
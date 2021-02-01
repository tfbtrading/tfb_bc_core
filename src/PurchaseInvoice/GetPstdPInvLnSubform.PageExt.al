pageextension 50126 "TFB Get Pstd-P.InvLn Subform" extends "Get Post.Doc - P.InvLn Subform"
{
    layout
    {
        addbefore("Document No.")
        {
            field("TFB Vendor Invoice No."; Rec."TFB Vendor Invoice No.")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies vendors invoice number';

                
            }
            field("Order No."; Rec."Order No.")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies purchase order number';
            }

        }

        modify("No.")
        {
            Visible = false;
        }
    }

    actions
    {
        
    }


}
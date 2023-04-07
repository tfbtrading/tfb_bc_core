pageextension 50149 "TFB Sales Hist. Sell-to FB" extends "Sales Hist. Sell-to FactBox" //MyTargetPageId
{
    layout
    {
        addafter(NoofOrdersTile)
        {
            field(TFBNoOrderLinesTile; Rec."TFB No. Order Lines")
            {
                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = "TFB Pending Sales Lines";
                Caption = 'Ongoing Sales Lines';
                Visible = true;
                Tooltip = 'Shows the number of sales line not shipped and invoiced';


            }
        }
        addafter(NoofPstdInvoicesTile)
        {
            field(TFBNoOfPstdInvLinesTitle; Rec."TFB No. Pstd. Inv. Lines")
            {
                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = "TFB Pstd. Sales Inv. Lines";
                Visible = true;
                Caption = 'Posted Sales Invoice Lines';
                ToolTip = 'Shows the number of posted sales invoice lines';
            }
        }

    }


    actions
    {
    }
}
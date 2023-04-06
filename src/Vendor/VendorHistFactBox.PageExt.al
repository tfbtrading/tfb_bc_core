pageextension 50105 "TFB Vendor Hist. FactBox" extends "Vendor Hist. Buy-from FactBox" //MyTargetPageId
{
    layout
    {
        addafter(CueOrders)
        {
            field("TFB No. Order Lines"; Rec."TFB No. Order Lines")
            {
                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = "TFB Pending Purch. Order Lines";
                Visible = true;
                Tooltip = 'Specifies the number of ongoing order lines';
            }
        }

        addafter(CuePostedInvoices)
        {
            field("TFB No. Pstd. Inv. Lines"; Rec."TFB No. Pstd. Inv. Lines")
            {
                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = "TFB Pstd. Purch. Inv. Lines";
                Visible = true;
                Tooltip = 'Specifies the number of posted invoice lines';
            }
        }

        addafter(CueIncomingDocuments)
        {
            field("TFB No. Certifications"; Rec."TFB No. Certifications")
            {
                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = "TFB Vendor Certification List";
                Tooltip = 'Specifies the number of certifications';
            }
        }

    }

    actions
    {
    }
}
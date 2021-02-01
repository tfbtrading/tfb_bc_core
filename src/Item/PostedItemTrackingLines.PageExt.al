pageextension 50296 "TFB Posted Item Tracking Lines" extends "Posted Item Tracking Lines"
{
    PromotedActionCategories = 'Navigation';
    layout
    {

    }

    actions
    {
        addfirst(Navigation)
        {
            action(TFBOpenLotInfo)
            {
                ApplicationArea = All;
                RunObject = Page "Lot No. Information Card";
                RunPageLink = "Item No." = field("Item No."), "Lot No." = field("Lot No."), "Variant Code" = field("Variant Code");
                RunPageMode = Edit;
                Image = LotInfo;
                Caption = 'Lot no info Card';
                ToolTip = 'Open lot number information card';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = New;

                trigger OnAction()
                begin

                end;
            }
        }
    }
}
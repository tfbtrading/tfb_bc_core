pageextension 50296 "TFB Posted Item Tracking Lines" extends "Posted Item Tracking Lines"
{

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
                Caption = 'Lot No. Info Card';
                ToolTip = 'Open lot number information card';


                trigger OnAction()
                begin

                end;
            }
        }
        addlast(Promoted)
        {
            group(TFBItemTracking)
            {
                Caption = 'Item Tracking';

                actionref(ActionRefName; TFBOpenLotInfo)
                {

                }
            }
        }
    }
}
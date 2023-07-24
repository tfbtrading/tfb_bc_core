pageextension 50198 "TFB Sales Price List" extends "Sales Price List"
{
    layout
    {
    }

    actions
    {
        addafter(SuggestLines)
        {
            action(TFBCopyItemCostings)
            {
                ApplicationArea = All;
                Caption = 'Suggest based on item costings';
                Image = CostBudget;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Add suggested sales prices based on item costing worksheets';

                trigger OnAction()
                var
                    CostingCU: Codeunit "TFB Costing Mgmt";

                begin

                    CostingCU.CopyCurrentCostingToPriceList(Rec,'');
                end;
            }


        }
    }


}
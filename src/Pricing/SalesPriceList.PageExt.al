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
                Promoted = True;
                PromotedCategory = Process;
                ToolTip = 'Add suggested sales prices based on item costing worksheets';

                trigger OnAction()
                var
                    CostingCU: Codeunit "TFB Costing Mgmt";

                begin
                   
                    CostingCU.CopyCurrentCostingToPriceList(Rec);
                end;
            }

            action(TFBFixExistingPricing)
            {
                ApplicationArea = All;
                Caption = 'Fix existing sales prices';
                ToolTip = 'Run a process that corrects dates to ensure that existing prices are correct';
                Image = Insert;

                trigger OnAction()

                var
                    PricingCU: CodeUnit "TFB Pricing Calculations";

                begin
                    PricingCU.FixExistingPerKgPricing();
                    PricingCu.CheckPriceHealth();
                    PricingCU.CheckPriceHealthOnPriceList(Rec);
                end;

            }
        }
    }


}
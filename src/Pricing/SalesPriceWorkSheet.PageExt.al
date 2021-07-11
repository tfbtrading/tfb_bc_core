pageextension 50146 "TFB Sales Price WorkSheet" extends "Sales Price Worksheet" //MyTargetPageId
{
    layout
    {

        addafter("Minimum Quantity")
        {
            field("TFB Net Weight"; Rec."TFB Net Weight")
            {
                ApplicationArea = All;
                Editable = False;
                ToolTip = 'Specifies the items net weight';
            }
        }

        addafter("Current Unit Price")
        {
            field("TFB Current Per Kg Price"; Rec."TFB Current Per Kg Price")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies the current price per kilogram';
            }

        }
        addafter("New Unit Price")
        {
            field("TFB New Per Kg Price"; Rec."TFB New Per Kg Price")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies the new price per kilogram';

            }
        }


    }

    actions
    {
        addafter("Suggest &Sales Price on Wksh.")
        {
            action(TFBCopyItemCostings)
            {
                ApplicationArea = All;
                Caption = 'Suggest based on item costings';
                Image = CostBudget;
                Promoted = True;
                PromotedCategory = Process;
                ToolTip = 'Add suggested sales prices based on item costing worksheets';

                trigger OnAction()
                var
                    CostingCU: Codeunit "TFB Costing Mgmt";

                begin
                    CostingCU.CopyCurrentCostingToSalesWorkSheet();
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
                end;

            }
        }
    }
}
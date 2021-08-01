pageextension 50209 "TFB Price Worksheet" extends "Price Worksheet"
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
                    TFBPriceListManagement: CodeUnit "TFB Price List Management";
                    TempWorkSheetPriceListHeader: Record "Price List Header" temporary;
                begin

                    TFBPriceListManagement.AddLines(TempWorksheetPriceListHeader);

                    CurrPage.Update(false);
                end;

            }

        }

    }
}
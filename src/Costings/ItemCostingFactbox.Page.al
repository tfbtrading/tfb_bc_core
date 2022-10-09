page 50102 "TFB Item Costing Factbox"
{

    Caption = 'Supporting Info';

    PageType = CardPart;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            group(Details)
            {

                Caption = 'Details';
                field("No."; Rec."No.")
                {
                    Caption = 'Item No.';
                    DrillDown = true;
                    DrillDownPageId = "Item Card";
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item No. for drilldown purposes';
                }
                field("Purchasing Code"; Rec."Purchasing Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies default purchasing code';
                }
                field(_CurrPricePerKg; _CurrPricePerKg)
                {
                    ApplicationArea = All;
                    Caption = 'Curr. Price Per Kg';
                    Tooltip = 'Specifies the current price per kilogram based on the default pricing group setup';
                    Style = AttentionAccent;
                    StyleExpr = _CostingPricePerKg <> _CurrPricePerKg;
                }
                field(_currPurchPrice;
                _CurrPurchPrice)
                {
                    ApplicationArea = All;
                    Caption = 'Curr. Vendor Purch Price';
                    ToolTip = 'Specifies what the current defaul vendor purchase price is';
                    Style = Attention;

                }
                field("Net Weight";
                Rec."Net Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies net weight of item unit being purchased';
                }

            }
            group(General)
            {
                ShowCaption = true;
                Caption = 'Inventory';
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies qty of inventory on hand';


                }
                field("Reserved Qty. on Inventory"; Rec."Reserved Qty. on Inventory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies qty of inventory reserved and on hand';
                }
                field("TFB Out. Qty. On Sales Order"; Rec."TFB Out. Qty. On Sales Order")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the sales qty currently sold';
                    Caption = 'Total qty on order';
                }

                field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies qty of item on purchase orders not yet received';
                }
                field("Reserved Qty. on Purch. Orders"; Rec."Reserved Qty. on Purch. Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies qty reserved from future purchase orders';
                }
                field("Qty. on Sales Order"; Rec."Qty. on Sales Order")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies qty sold';
                }

            }
            group(Costing)
            {
                Caption = 'Inventory Costing';
                Visible = not _IsDropShipCosting;

                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies current unit cost according to costing scheme';
                }
                field(_CurrentLandedCost; _CurrentLandedCost)
                {
                    ApplicationArea = All;
                    Caption = 'Current Landed Cost';
                    Tooltip = 'Specifies current cost in costing unit of measure';

                }

                field(_CurrentLandedCostInPurchaseCurr; _CurrentLandedCostInPurchaseCurr)
                {
                    ApplicationArea = All;
                    Caption = 'Current Landed Cost (in Purchase Exch)';
                    Tooltip = 'Specifies current cost in costing unit of measure in foreign currency based on current item costing rate';

                }

                field(_LastPreLandedCost; _LastPreLandedCost)
                {
                    ApplicationArea = All;
                    Caption = 'Last Purchase Cost';
                    Tooltip = 'Specifies last purchase cost (prior to any landed costs) in costing unit of measure';

                }
                field(_NextPreLandedCost; _NextPreLandedCost)
                {
                    ApplicationArea = All;
                    Caption = 'Next Purchase Cost';
                    Tooltip = 'Specifies next cost on order in costing unit of measure';

                }
            }
        }
    }

    trigger OnAfterGetRecord()

    var
        ItemCosting: Record "TFB Item Costing";
        TempPriceListLine: Record "Price List Line" temporary;
        CCU: CodeUnit "TFB Costing Mgmt";
        PricingLogic: CodeUnit "TFB Pricing Calculations";
        PriceManagement: CodeUnit "Price Calculation - V16";

    begin

        clear(_CurrentLandedCost);
        clear(_LastPreLandedCost);
        clear(_NextPreLandedCost);
        clear(_CurrPricePerKg);
        clear(_MarketPrice);

        ItemCosting.SetRange("Item No.", Rec."No.");
        ItemCosting.SetRange(Current, true);
        ItemCosting.SetRange("Costing Type", ItemCosting."Costing Type"::Standard);


        If ItemCosting.FindFirst() then begin
            _CurrentLandedCost := CCU.GetCurrentItemCost(rec, ItemCosting);
            ItemCosting.CalcFields("Vendor Currency");
            If ItemCosting."Vendor Currency" <> '' then
                _CurrentLandedCostInPurchaseCurr := _CurrentLandedCost * ItemCosting."Exch. Rate"
            else
                _CurrentLandedCostInPurchaseCurr := _CurrentLandedCost;
            _LastPreLandedCost := CCU.GetLastPurchasePrice(rec, ItemCosting);
            _NextPreLandedCost := CCU.GetNextPurchasePrice(rec, ItemCosting);
            _CurrPricePerKg := CCU.GetCurrPricePerKg(Rec);
            _MarketPrice := ItemCosting."Market Price";
            ItemCosting.CalcFields("Mel Metro Kg");
            _CostingPricePerKg := ItemCosting."Mel Metro Kg";
            _IsDropShipCosting := ItemCosting.Dropship;

        end;
        TempPriceListLine."Source Type" := TempPriceListLine."Source Type"::Vendor;
        TempPriceListLine."Price Type" := TempPriceListLine."Price Type"::Purchase;
        TempPriceListLine."Source No." := Rec."Vendor No.";
        TempPriceListLine."Unit of Measure Code" := Rec."Base Unit of Measure";
        TempPriceListLine."Starting Date" := today;

        If PriceManagement.FindPrice(TempPriceListLine, false) then
            _CurrPurchPrice := PricingLogic.CalculatePriceUnitByUnitPrice(Rec."No.", Rec."Base Unit of Measure", ItemCosting."Purchase Price Unit", TempPriceListLine."Direct Unit Cost")
        else
            _CurrPurchPrice := 0;
    end;

    trigger OnOpenPage()

    begin
        SalesSetup.Get();
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        _CurrentLandedCost: Decimal;
        _CurrPricePerKg: Decimal;
        _CostingPricePerKg: Decimal;

        _IsDropShipCosting: Boolean;
        _CurrPurchPrice: Decimal;
        _LastPreLandedCost: Decimal;
        _MarketPrice: Decimal;
        _NextPreLandedCost: Decimal;
        _CurrentLandedCostInPurchaseCurr: Decimal;


}

page 50145 "TFB Gross Profit Sales Lines"
{
    PageType = List;
    Caption = 'Gross Profit on Sales';

    SourceTable = "Sales Line";
    SourceTableView = sorting("Shipment Date", "Sell-to Customer No.") order(ascending) where("Quantity (Base)" = filter(> 0), Type = const(Item), "Document Type" = const(Order));

    ModifyAllowed = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;
    Editable = true;
    DataCaptionFields = "Sell-to Customer No.", "Document No.";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    width = 10;

                    DrillDown = true;
                    ToolTip = 'Specifies the item number';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Tooltip = 'Specifies the description of the item';
                }


                field("Outstanding Quantity"; Rec."Outstanding Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the outstanding quantity in the sales unit of measure';
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the sales unit of measure';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. per UoM';
                    ToolTip = 'Specifies base quantity per unit of measure';
                }

                field("Cost Price By"; _CostPriceBy)
                {
                    ApplicationArea = All;
                    Caption = 'Cost Price By';
                    ToolTip = 'Specifies how cost price is determined';
                    Editable = true;

                    trigger OnValidate()

                    begin
                        updateLineVariables();
                        notdefaultcostby := true;
                    end;
                }

                field("Cost Price"; _CostPricePerKg)
                {
                    ApplicationArea = All;
                    Caption = 'Estimated Cost Per Kg';
                    ToolTip = 'Specifies the cost price';
                    Editable = true;
                }
                field("Est. Delivery Cost"; _EstDeliveryCost)
                {
                    ApplicationArea = All;
                    Caption = 'Estimated Delivery Per Kg';
                    ToolTip = 'Specifies the delivery cost per kg additional to cost';
                    Editable = true;
                }
                field(TotalCost; _linecost)
                {
                    ApplicationArea = All;
                    Caption = 'Total Cost Excl. GST';
                    ToolTip = 'Specifies the total cost of the line';
                    Editable = false;
                    width = 20;
                }
                field("TFB Price Unit Cost"; Rec."TFB Price Unit Cost")
                {
                    ApplicationArea = All;
                    Caption = 'Price Per Kg';
                    ToolTip = 'Specifies the price per kg';
                    Editable = true;
                    width = 10;

                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Excl. GST';
                    ToolTip = 'Specifies the total sale price';
                    Editable = false;
                    Enabled = false;
                }
                field(GrossProfit; _GrossProfit)
                {
                    ApplicationArea = All;
                    Caption = 'Estimated Profit';
                    ToolTip = 'Specifies the estimated gross profit for the line';
                    Enabled = false;
                    Editable = false;
                    width = 10;
                }
                field(GrossProfitPerc; _GrossProfitPerc)
                {
                    ApplicationArea = All;
                    Caption = 'Estimated Profit %';
                    ToolTip = 'Specifies the estimated percentage of profit';
                    AutoFormatExpression = '<precision,2:2><standard format,0>%';
                    AutoFormatType = 10;
                    Enabled = false;
                    Editable = false;
                    width = 10;
                }

                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    DrillDown = True;
                    ToolTip = 'Specifies the drop shipment purchase order related to the sales line';
                    Editable = false;

                    ApplicationArea = All;
                    trigger OnDrillDown()



                    begin

                        OpenRelatedPurchaseOrder();

                    end;
                }



            }

            group(Summary)
            {
                ShowCaption = false;
                group(Control49)
                {


                }
                group(Control35)
                {
                    Caption = 'Total Summary';
                    ShowCaption = true;
                    field("Total Item Cost"; _totalcost)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = Rec."Currency Code";
                        AutoFormatType = 1;

                        Caption = 'Total Cost';
                        Editable = false;
                        ToolTip = 'Specifies the sum of the estimated total cost.';
                    }
                    field("Total Delivery Cost"; _totaldeliverycost)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = Rec."Currency Code";
                        AutoFormatType = 1;

                        Caption = 'Total Delivery Cost';
                        Editable = false;
                        ToolTip = 'Specifies the sum of the estimated total cost for delivery.';
                    }
                    field("Total Profit"; _TotalGrossProfit)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = Rec."Currency Code";
                        AutoFormatType = 1;

                        Caption = 'Total Profit';
                        Editable = false;
                        ToolTip = 'Specifies the total profit shown for all the lines.';

                    }
                    field("Overall Profit"; _TotalProfitPerc)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = '<precision,2:2><standard format,0>%';
                        AutoFormatType = 10;
                        Caption = 'Overall Profit %';
                        DrillDown = false;
                        Editable = false;
                        ToolTip = 'Specifies the estimated profit across all the lines as a percentage.';
                    }

                }
            }


        }



        area(Factboxes)
        {

        }

    }


    actions
    {


    }

    views
    {

    }

    var
        notdefaultcostby: Boolean;
        SalesCU: CodeUnit "TFB Sales Mgmt";
        _availability: Text;
        _statusUpdate: Text;
        _costpriceBy: Enum "TFB Cost Price By";
        _CostPricePerKg: Decimal;
        _linecost: Decimal;
        _grossprofit: Decimal;
        _grossprofitperc: Decimal;

        _totalprofitperc: Decimal;
        _totalgrossprofit: Decimal;

        _totalcost: Decimal;
        _estDeliveryCost: Decimal;
        _linedeliverycost: Decimal;

        CostPriceByDictionary: dictionary of [integer, enum "TFB Cost Price By"];
        CostPriceDictionary: dictionary of [integer, Decimal];
        DeliveryPriceDictionary: dictionary of [integer, Decimal];


        _totaldeliverycost: Decimal;


    trigger OnAfterGetRecord()



    begin
        _costpriceBy := _costpriceBy::ItemCost;
        updateLineVariables();


    end;



    local procedure updateLineVariables()
    var
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        ItemCosting: Record "TFB Item Costing";
        ItemCostingLine: Record "TFB Item Costing Lines";
        PostCodeZoneRate: Record "TFB Postcode Zone Rate";

        PostCodeZone: Record "TFB Postcode Zone";
        PricingCU: Codeunit "TFB Pricing Calculations";


    begin
        _CostPricePerKg := 0;
        _linecost := 0;
        _grossprofit := 0;
        _grossprofitperc := 0;

        _totalcost := 100;
        _totalgrossprofit := 100;
        _totalprofitperc := 0.2;
        ItemCosting.SetRange("Item No.", Rec."No.");
        ItemCosting.Setrange(Current, true);
        ItemCosting.Setrange("Costing Type", ItemCosting."Costing Type"::Standard);


        if not item.get(rec."No.") then exit;

        PostCodeZone.SetRange("Customer Price Group", Rec."Customer Price Group");

        if PostCodeZone.FindFirst() and ItemCosting.FindFirst() then begin

            PostCodeZoneRate.SetRange("Zone Code", PostCodeZone.Code);
            PostCodeZoneRate.SetRange("Costing Scenario Code", ItemCosting.GetRelatedScenario().Code);

            if PostCodeZoneRate.FindFirst() and not Rec."Drop Shipment" then
                _estDeliveryCost := PricingCU.CalcPerKgFromUnit((PostCodeZoneRate."Total Charge" / ItemCosting."Pallet Qty"), Item."Net Weight");

        end;



        case _costpriceBy of
            _costpriceBy::ItemCost:
                begin
                    if Rec."Drop Shipment" and Purchaseline.Get(PurchaseLine."Document Type"::Order, Rec."Purchase Order No.", Rec."Purch. Order Line No.") then
                        _CostPricePerKg := PricingCU.CalcPerKgFromUnit(PurchaseLine."Unit Cost", Item."Net Weight")
                    else
                        _CostPricePerKg := PricingCu.CalcPerKgFromUnit(Item."Unit Cost", Item."Net Weight");

                    _linecost := _CostPricePerKg * Item."Net Weight" * Rec."Quantity (Base)";
                    _linedeliverycost := _estDeliveryCost * Item."Net Weight" * Rec."Quantity (Base)";
                    _grossprofit := Rec.Amount - (_linecost - _linedeliverycost);
                    _grossprofitperc := _grossprofit / rec.Amount;


                end;


            _costpriceBy::ItemCosting:
                begin
                    ItemCostingLine.SetRange("Item No.", Rec."No.");
                    ItemCostingLine.SetRange("Costing Type", ItemCostingLine."Costing Type"::Standard);
                    ItemCostingLine.SetRange(Current, true);
                    ItemCostingLine.SetRange("Line Type", ItemCostingLine."Line Type"::TCG);
                    If ItemCostingLine.FindFirst() then begin
                        _CostPricePerKg := PricingCU.CalcPerKgFromUnit(ItemCostingLine."Price (Base)", Item."Net Weight");
                        _linecost := _CostPricePerKg * Item."Net Weight" * Rec."Quantity (Base)";
                        _linedeliverycost := _estDeliveryCost * Item."Net Weight" * Rec."Quantity (Base)";
                        _grossprofit := Rec.Amount - (_linecost - _linedeliverycost);
                        _grossprofitperc := _grossprofit / rec.Amount;
                    end
                    else begin
                        _CostPricePerKg := 0;
                        _linecost := 0;
                        _grossprofit := 0;
                        _grossprofitperc := 0;
                    end;
                end;

        end;

        CostPriceByDictionary.Add(Rec."Line No.", _costpriceBy);
        CostPriceDictionary.Add(Rec."Line No.", _CostPricePerKg);
        DeliveryPriceDictionary.Add(Rec."Line No.", _estDeliveryCost);

        If CostPriceByDictionary.Count() = Rec.Count() then
            updateProfitTotals();
    end;

    local procedure updateProfitTotals()

    var
        SalesLine2: Record "Sales Line";
        Item: Record Item;
        PricingCU: Codeunit "TFB Pricing Calculations";


    begin

        SalesLine2 := Rec;
        _totalcost := 0;
        _totalgrossprofit := 0;
        _totaldeliverycost := 0;
        _totalprofitperc := 0;

        If SalesLine2.FindSet() then
            repeat
                If SalesLine2.Type = Salesline2.type::Item then begin
                    _totalcost := _totalcost + (CostPriceDictionary.get(SalesLine2."Line No.") * Item."Net Weight" * SalesLine2."Quantity (Base)");
                    _totaldeliverycost := _totaldeliverycost + (DeliveryPriceDictionary.get(SalesLine2."Line No.") * Item."Net Weight" * SalesLine2."Quantity (Base)");
                    _totalgrossprofit := SalesLine2.Amount - _totalcost - _totaldeliverycost;
                    _totalprofitperc := _totalgrossprofit / SalesLine2.Amount;
                end;
            until SalesLine2.Next() = 0;

    end;

    local procedure OpenRelatedPurchaseOrder()

    var
        Purchase: Record "Purchase Header";
        PurchasePage: Page "Purchase Order";

    begin

        Purchase.SetRange("Document Type", Purchase."Document Type"::Order);

        If Rec."Drop Shipment" then
            Purchase.SetRange("No.", Rec."Purchase Order No.")
        else
            if Rec."Special Order" then
                Purchase.SetRange("No.", Rec."Special Order Purchase No.");

        If Purchase.FindFirst() then begin
            PurchasePage.SetRecord(Purchase);
            PurchasePage.Run();
        end;

    end;



}
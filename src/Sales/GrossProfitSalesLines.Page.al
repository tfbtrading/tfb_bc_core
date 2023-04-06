page 50145 "TFB Gross Profit Sales Lines"
{
    PageType = List;
    Caption = 'Gross Profit on Sales';

    SourceTable = "Sales Line";
    SourceTableView = sorting("Shipment Date", "Sell-to Customer No.") order(ascending) where("Quantity (Base)" = filter(> 0), Type = const(Item));

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

                    DrillDown = false;
                    ToolTip = 'Specifies the item number';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Tooltip = 'Specifies the description of the item';
                    Enabled = false;
                }


                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the outstanding quantity in the sales unit of measure';
                    Editable = false;
                    Enabled = false;
                }
                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the net weight per unit';
                    Editable = false;
                    Enabled = false;
                }

                field("Cost Using"; Rec."TFB Cost Using")
                {
                    ApplicationArea = All;
                    Caption = 'Cost Using';
                    ToolTip = 'Specifies how cost price is determined';
                    Editable = true;

                    trigger OnValidate()

                    begin
                        updateLineVariables();
                        notdefaultcostby := true;
                        CurrPage.Update();

                    end;
                }

                field("Cost Price"; _CostPricePerKg)
                {
                    ApplicationArea = All;
                    Caption = 'Est. Cost Per Kg';
                    ToolTip = 'Specifies the cost price';
                    Editable = true;
                }
                field("Est. Delivery Cost"; _EstDeliveryCost)
                {
                    ApplicationArea = All;
                    Caption = 'Est. Delivery Cost Per Kg';
                    ToolTip = 'Specifies the delivery cost per kg additional to cost';
                    Editable = false;
                    Enabled = false;
                }
                field(TotalCost; _linecost)
                {
                    ApplicationArea = All;
                    Caption = 'Est. Item Costs excl. Delivery';
                    ToolTip = 'Specifies the total cost of the line excl. GST';
                    Editable = false;
                    width = 20;
                }
                field("TFB Price Unit Cost"; Rec."TFB Price Unit Cost")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Price Per Kg';
                    ToolTip = 'Specifies the price per kg';
                    Editable = true;
                    width = 10;

                    trigger OnValidate()

                    begin

                        updateLineVariables();
                    end;
                }
                field("TFB Price Unit Discount"; Rec."TFB Price Unit Discount")
                {
                    ApplicationArea = All;
                    BlankNumbers = BlankZero;
                    Editable = Rec."TFB Price Unit Cost" > 0;
                    Caption = 'Per Kg Discount';
                    ToolTip = 'Specifies the discount as a per kilogram price';

                    trigger OnValidate()

                    begin
                        updateLineVariables();
                        CurrPage.Update();
                    end;

                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Amount';
                    ToolTip = 'Specifies the total sale price';
                    Editable = false;
                    Enabled = false;
                }
                field(GrossProfit; _GrossProfit)
                {
                    ApplicationArea = All;
                    Caption = 'Est. Profit';
                    ToolTip = 'Specifies the estimated gross profit for the line';
                    Enabled = false;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = _grossprofitperc < 0;
                    width = 10;
                }
                field(GrossProfitPerc; _GrossProfitPerc)
                {
                    ApplicationArea = All;
                    Caption = 'Est.Profit %';
                    ToolTip = 'Specifies the estimated percentage of profit';
                    AutoFormatExpression = '<precision,2:2><standard format,0>%';
                    AutoFormatType = 10;
                    Style = Unfavorable;
                    StyleExpr = _grossprofitperc < 0;
                    Enabled = false;
                    Editable = false;
                    width = 10;
                }

                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    DrillDown = True;
                    Caption = 'Drop Ship P.O.';
                    ToolTip = 'Specifies the drop shipment purchase order related to the sales line';
                    Editable = false;
                    visible = (Rec."Document Type" = Rec."Document Type"::Order) and Rec."Drop Shipment";
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
                    field("Total Sales Amount"; _totalsalesamount)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = Rec."Currency Code";
                        AutoFormatType = 1;

                        Caption = 'Total Sales Amount';
                        Editable = false;
                        ToolTip = 'Specifies the sum of the total sales revenue on order.';
                    }
                    field("Total Item Cost"; _totalcost)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = Rec."Currency Code";
                        AutoFormatType = 1;

                        Caption = 'Total Est. Cost';
                        Editable = false;
                        ToolTip = 'Specifies the sum of the estimated total cost.';
                    }
                    field("Total Delivery Cost"; _totaldeliverycost)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = Rec."Currency Code";
                        AutoFormatType = 1;

                        Caption = 'Total Est. Delivery Cost';
                        Editable = false;
                        ToolTip = 'Specifies the sum of the estimated total cost for delivery.';
                    }
                    field("Total Discount"; _totaldiscount)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = Rec."Currency Code";
                        AutoFormatType = 1;

                        Caption = 'Total Invoice and Line Discount';
                        Editable = false;
                        ToolTip = 'Specifies the total discount incorporated in the sales amount on a line.';
                    }
                    field("Total Profit"; _TotalGrossProfit)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = Rec."Currency Code";
                        AutoFormatType = 1;
                        Style = Unfavorable;
                        StyleExpr = _grossprofitperc < 0;
                        Caption = 'Total Est. Profit';
                        Editable = false;
                        ToolTip = 'Specifies the total profit shown for all the lines.';

                    }
                    field("Overall Profit"; _TotalProfitPerc)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatExpression = '<precision,2:2><standard format,0>%';
                        AutoFormatType = 10;
                        Caption = 'Overall Est. Profit %';
                        DrillDown = false;
                        Editable = false;
                        Style = Unfavorable;
                        StyleExpr = _grossprofitperc < 0;
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
        SalesCU: CodeUnit "TFB Sales Mgmt";
        notdefaultcostby: Boolean;

        LineDictionary: dictionary of [integer, Dictionary of [code[20], decimal]];


        _CostPricePerKg: Decimal;
        _estDeliveryCost: Decimal;
        _grossprofit: Decimal;
        _grossprofitperc: Decimal;
        _linecost: Decimal;
        _linedeliverycost: Decimal;
        _totalcost: Decimal;
        _totaldeliverycost: Decimal;
        _totaldiscount: Decimal;
        _totaldiscountperc: Decimal;
        _totalgrossprofit: Decimal;
        _totalprofitperc: Decimal;
        _totalsalesamount: Decimal;

        _availability: Text;
        _statusUpdate: Text;









    trigger OnAfterGetCurrRecord()



    begin
        updateLineVariables();
    end;

    trigger OnAfterGetRecord()



    begin
        updateLineVariables();
    end;





    local procedure updateLineVariables()
    var
        LineDetailDictionary: dictionary of [code[20], Decimal];
        Item: Record Item;
        ItemCosting: Record "TFB Item Costing";
        ItemCostingLine: Record "TFB Item Costing Lines";
        PostCodeZone: Record "TFB Postcode Zone";
        PostCodeZoneRate: Record "TFB Postcode Zone Rate";
        PurchaseLine: Record "Purchase Line";
        PricingCU: Codeunit "TFB Pricing Calculations";



    begin
        _CostPricePerKg := 0;
        _linecost := 0;
        _grossprofit := 0;
        _grossprofitperc := 0;

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



        case Rec."TFB Cost Using" of
            Rec."TFB Cost Using"::ItemCost:
                begin
                    if Rec."Drop Shipment" then
                        if Purchaseline.Get(PurchaseLine."Document Type"::Order, Rec."Purchase Order No.", Rec."Purch. Order Line No.") then
                            _CostPricePerKg := PricingCU.CalculatePriceUnitByUnitPrice(Item."No.", PurchaseLine."Unit of Measure Code", Enum::"TFB Price Unit"::KG, PurchaseLine."Unit Cost")
                        else begin

                            ItemCostingLine.SetRange("Item No.", Rec."No.");
                            ItemCostingLine.SetRange("Costing Type", ItemCostingLine."Costing Type"::Standard);
                            ItemCostingLine.SetRange(Current, true);
                            ItemCostingLine.SetRange("Line Type", ItemCostingLine."Line Type"::TCG);
                            If ItemCostingLine.FindFirst() then begin
                                _CostPricePerKg := PricingCU.CalcPerKgFromUnit(ItemCostingLine."Price (Base)" + PricingCU.GetVendorZoneRate(Item."Vendor No.", Item."No.", PostCodeZoneRate."Zone Code"), Item."Net Weight");
                                _linecost := _CostPricePerKg * Item."Net Weight" * Rec."Quantity (Base)";
                                _linedeliverycost := _estDeliveryCost * Item."Net Weight" * Rec."Quantity (Base)";
                                _grossprofit := Rec.Amount - (_linecost + _linedeliverycost);
                                _grossprofitperc := _grossprofit / rec.Amount;
                            end
                        end

                    else
                        _CostPricePerKg := PricingCu.CalcPerKgFromUnit(Item."Unit Cost", Item."Net Weight");

                    _linecost := _CostPricePerKg * Item."Net Weight" * Rec."Quantity (Base)";
                    _linedeliverycost := _estDeliveryCost * Item."Net Weight" * Rec."Quantity (Base)";
                    _grossprofit := Rec.Amount - (_linecost + _linedeliverycost);
                    _grossprofitperc := _grossprofit / rec.Amount;


                end;
            Rec."TFB Cost Using"::LastPurchasePrice:
                begin
                    //TODO Same as item cost for now - but will be changed in the future to run an item based on the most recent purchase price
                    if Rec."Drop Shipment" and Purchaseline.Get(PurchaseLine."Document Type"::Order, Rec."Purchase Order No.", Rec."Purch. Order Line No.") then
                        _CostPricePerKg := PricingCU.CalcPerKgFromUnit(PurchaseLine."Unit Cost", Item."Net Weight")
                    else
                        _CostPricePerKg := PricingCu.CalcPerKgFromUnit(Item."Unit Cost", Item."Net Weight");

                    _linecost := _CostPricePerKg * Item."Net Weight" * Rec."Quantity (Base)";
                    _linedeliverycost := _estDeliveryCost * Item."Net Weight" * Rec."Quantity (Base)";
                    _grossprofit := Rec.Amount - (_linecost + _linedeliverycost);
                    _grossprofitperc := _grossprofit / rec.Amount;

                end;

            Rec."TFB Cost Using"::ItemCosting:
                begin

                    //Uses the item costing - which calculated out the basis for the current pricing
                    ItemCostingLine.SetRange("Item No.", Rec."No.");
                    ItemCostingLine.SetRange("Costing Type", ItemCostingLine."Costing Type"::Standard);
                    ItemCostingLine.SetRange(Current, true);
                    ItemCostingLine.SetRange("Line Type", ItemCostingLine."Line Type"::TCG);
                    If ItemCostingLine.FindFirst() then begin
                        _CostPricePerKg := PricingCU.CalcPerKgFromUnit(ItemCostingLine."Price (Base)", Item."Net Weight");
                        _linecost := _CostPricePerKg * Item."Net Weight" * Rec."Quantity (Base)";
                        _linedeliverycost := _estDeliveryCost * Item."Net Weight" * Rec."Quantity (Base)";
                        _grossprofit := Rec.Amount - (_linecost + _linedeliverycost);
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

        LineDetailDictionary.Add('SALE', Rec.Amount);
        LineDetailDictionary.Add('ITEMCOST', _CostPricePerKg);
        LineDetailDictionary.Add('DELIVERYCOST', _estDeliveryCost);

        If LineDictionary.ContainsKey(Rec."Line No.") then
            LineDictionary.Set(Rec."Line No.", LineDetailDictionary)
        else
            LineDictionary.Add(Rec."Line No.", LineDetailDictionary);


        updateProfitTotals();
    end;

    local procedure updateProfitTotals()

    var
        Item: Record Item;
        SalesLine2: Record "Sales Line";
        PricingCU: Codeunit "TFB Pricing Calculations";
        LineDetailDictionary: dictionary of [code[20], Decimal];


    begin
        SalesLine2.Reset();
        SalesLine2.CopyFilters(Rec);
        _totalcost := 0;
        _totalgrossprofit := 0;
        _totaldeliverycost := 0;
        _totalprofitperc := 0;
        _totalsalesamount := 0;

        If SalesLine2.Findset(false) then
            repeat
                If (SalesLine2.Type = Salesline2.type::Item) and LineDictionary.ContainsKey(SalesLine2."Line No.") then begin
                    Item.Get(SalesLine2."No.");
                    _totalcost := _totalcost + (LineDictionary.Get(SalesLine2."Line No.").Get('ITEMCOST') * Item."Net Weight" * SalesLine2."Quantity (Base)");
                    _totaldeliverycost := _totaldeliverycost + (LineDictionary.Get(SalesLine2."Line No.").Get('DELIVERYCOST') * Item."Net Weight" * SalesLine2."Quantity (Base)");
                    _totalsalesamount := _totalsalesamount + LineDictionary.Get(SalesLine2."Line No.").Get('SALE');
                    _totaldiscount := _totaldiscount + SalesLine2."Inv. Discount Amount" + SalesLine2."Line Discount Amount";
                    _totalgrossprofit := _totalsalesamount - (_totalcost + _totaldeliverycost);
                    _totalprofitperc := _totalgrossprofit / _totalsalesamount;
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
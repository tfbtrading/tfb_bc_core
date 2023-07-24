pageextension 50209 "TFB Price Worksheet" extends "Price Worksheet"
{
    layout
    {

        addafter("Asset No.")
        {
            field(Description; Rec.Description)
            {
                ApplicationArea = All;
                Visible = true;
                ToolTip = 'Specifies a description of the asset/product';
            }
        }
        addafter("Existing Unit Price")
        {
            field(ExistingPriceByWeight; _ExistingPricePerKg)
            {
                ApplicationArea = All;
                DecimalPlaces = 2 : 4;
                BlankZero = true;
                Caption = 'Existing Price per kg';
                Tooltip = 'Specifies the price per kg';
                Editable = false;

            }
        }
        addafter("Unit Price")
        {

            field(PriceByWeight; _PricePerKg)
            {
                ApplicationArea = All;
                DecimalPlaces = 2 : 4;
                BlankZero = true;
                Caption = 'Price per kg';
                Tooltip = 'Specifies the price per kg';
                Editable = Rec."Asset Type" = Rec."Asset Type"::Item;

                trigger OnValidate()

                begin
                    rec.UpdateUnitPriceFromAltPrice(_PricePerKg);
                end;

            }



        }

        modify("Unit Price")
        {
            trigger OnAfterValidate()

            begin
                _PricePerKg := UpdatePricePerKg(Rec."Unit Price");
            end;
        }

        modify("Asset No.")
        {

            trigger OnAfterValidate()

            begin
                _PricePerKg := UpdatePricePerKg(Rec."Unit Price");
                _ExistingPricePerKg := UpdatePricePerKg(Rec."Existing Unit Price");
            end;

        }

        modify("Currency Code")
        {
            Visible = false;
        }

        modify("Variant Code")
        {
            Visible = false;
        }
        modify("Work Type Code")
        {
            Visible = false;
        }
        modify("Unit of Measure Code")
        {
            Visible = true;
        }
        modify("Cost-plus %")
        {
            Visible = false;
        }
        modify("Published Price")
        {
            Visible = false;
        }
        modify("Line Discount %")
        {
            Visible = false;
        }
        modify("Minimum Quantity")
        {
            Visible = false;
        }
        modify("Cost Factor")
        {
            Visible = false;
        }
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

                ToolTip = 'Add suggested sales prices based on item costing worksheets';

                trigger OnAction()
                var
                    ItemCostingFilters: Record "TFB Item Costing Filters";
                    PriceListHeader: Record "Price List Header";
                    TempPriceListHeader: Record "Price List Header" temporary;
                    CostingCU: Codeunit "TFB Costing Mgmt";
                    SuggestItemCostingLines: Page "TFB Suggest Item Costing Lines";


                begin


                    SuggestItemCostingLines.SetRecord(ItemCostingFilters);
                    if SuggestItemCostingLines.RunModal() = Action::OK then begin
                        SuggestItemCostingLines.GetRecord(ItemCostingFilters);
                        if ItemCostingFilters."Price List Code" = '' then exit;
                        PriceListHeader.Get(ItemCostingFilters."Price List Code");
                        TempPriceListHeader := PriceListHeader;
                        CostingCU.CopyCurrentCostingToPriceList(TempPriceListHeader, ItemCostingFilters."Product Filter");

                    end;
                end;

            }

        }

        addfirst(Promoted)
        {
            actionref(TFBCopyItemCostings_Promoted; TFBCopyItemCostings)
            {

            }
        }
    }

    var
        Item: Record Item;
        PricingCU: CodeUnit "TFB Pricing Calculations";

        _PricePerKg: Decimal;
        _ExistingPricePerKg: Decimal;

    trigger OnAfterGetRecord()

    begin
        Item.SetLoadFields(Item."No.", Item."Net Weight");
        if Rec."Asset Type" = Rec."Asset Type"::Item then
            Item.Get(Rec."Asset No.");

        _PricePerKg := UpdatePricePerKg(Rec."Unit Price");
        _ExistingPricePerKg := UpdatePricePerKg(Rec."Existing Unit Price");
    end;


    local procedure UpdatePricePerKg(UnitPrice: Decimal): Decimal


    begin

        if Item."Net Weight" > 0 then
            exit(PricingCU.CalcPerKgFromUnit(UnitPrice, Item."Net Weight"))
        else
            exit(0);

    end;


}
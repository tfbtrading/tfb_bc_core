pageextension 50124 "TFB Get Sales Price" extends "Get Sales Price"
{
    layout
    {
        addbefore("Unit Price")
        {
            field("TFB PriceByWeight"; PriceByPriceUnit)
            {
                ApplicationArea = All;
                Caption = 'Price Per Kg';
                ToolTip = 'Specifies price per kg';
            }

        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        PricingCU: CodeUnit "TFB Pricing Calculations";
        PriceByPriceUnit: Decimal;
        PriceUnit: Enum "TFB Price Unit";


    trigger OnAfterGetRecord()

    var
        Item: Record Item;
        UoM: Code[10];

    begin

        PriceUnit := PriceUnit::KG;
        UoM := rec."Unit of Measure Code";
        if Rec."Unit of Measure Code" = '' then
            If Item.Get(Rec."Item No.") then
                UoM := Item."Base Unit of Measure";


        PriceByPriceUnit := PricingCU.CalculatePriceUnitByUnitPrice(rec."Item No.", UoM, PriceUnit, rec."Unit Price");


    end;

}
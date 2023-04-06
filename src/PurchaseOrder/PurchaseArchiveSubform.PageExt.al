pageextension 50123 "TFB Purchase Archive SubForm" extends "Purchase Order Archive Subform"
{
    layout
    {
        addafter("Direct Unit Cost")
        {

            field("TFB Price Unit Cost"; PriceByPriceUnit)
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Caption = 'Price By Price Unit';
                Tooltip = 'Specifies the price in the vendors price unit';

            }
            field("TFB Price Unit"; PriceUnit)
            {
                ApplicationArea = All;
                Caption = 'Price Unit';
                ToolTip = 'Specifies the vendors price unit';

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
        Vendor: record Vendor;
    begin
        if Rec.Type = Rec.Type::Item then begin
            Vendor.get(rec."Buy-from Vendor No.");
            PriceUnit := Vendor."TFB Vendor Price Unit";
            PriceByPriceUnit := PricingCU.CalculatePriceUnitByUnitPrice(rec."No.", rec."Unit of Measure Code", PriceUnit, rec."Direct Unit Cost");

        end;
    end;
}
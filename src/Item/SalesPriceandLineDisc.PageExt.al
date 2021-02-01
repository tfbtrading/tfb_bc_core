pageextension 50118 "TFB Sales Price and Line Disc." extends "Sales Price and Line Discounts" //1345
{
    layout
    {
        modify("Line Type")
        {
            Visible = false;
        }
        modify(Type)
        {
            Visible = false;
        }
        modify("Minimum Quantity")
        {
            Visible = false;
        }
        addbefore("Unit Price")
        {
            field(PerKgPrice; _PricePerKg)
            {
                ApplicationArea = All;
                Caption = 'Kg Price';
                BlankZero = true;
                ToolTip = 'Specifies price per kilogram';
            }
        }
    }

    actions
    {
    }


    var
        PricingCU: CodeUnit "TFB Pricing Calculations";
        _PricePerKg: Decimal;

    trigger OnAfterGetRecord()

    var
        Item: Record Item;
        UoM: Code[10];
        PriceUnit: Enum "TFB Price Unit";

    begin
        _PricePerKg := 0;
        PriceUnit := PriceUnit::KG;
        If Item.Get(Rec."Loaded Item No.") then begin
            If Rec."Unit of Measure Code" = '' then
                UoM := Item."Base Unit of Measure" else
                UoM := Rec."Unit of Measure Code";
            _PricePerKg := PricingCU.CalculatePriceUnitByUnitPrice(Rec."Loaded Item No.", UoM, PriceUnit, Rec."Unit Price")
        end;
    end;

    trigger OnOpenPage()

    begin

    end;


}
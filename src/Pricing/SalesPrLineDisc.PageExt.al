pageextension 50144 "TFB Sales Pr. & Line Disc." extends "Sales Pr. & Line Disc. Part" //1347
{
    layout
    {
        addafter("Unit Price")
        {
            field("TFB Price Per Kg"; _pricePerKg)
            {
                ApplicationArea = All;
                Caption = 'Price per kg';
                ToolTip = 'Specifies price per kilogram';

            }
        }
        modify("Sales Code")
        {
            Visible = true;
        }

    }

    actions
    {
    }

    trigger OnOpenPage()

    begin

    end;

    var
        PricingCU: CodeUnit "TFB Pricing Calculations";
        _pricePerKg: Decimal;

    local procedure UpdatePerKgPricing()

    var
        Item: Record Item;
    begin

        if Item.Get(Rec."Loaded Item No.") then
            _pricePerKg := PricingCU.CalcPerKgFromUnit(Rec."Unit Price", Item."Net Weight")
        else
            _pricePerKg := 0;

    end;

    trigger OnAfterGetRecord()

    begin
        UpdatePerKgPricing();

    end;

    procedure SetToCurrentOnly()

    begin
        rec.SetFilter("Ending Date", '''|%2..', 0D, Today());

    end;



}
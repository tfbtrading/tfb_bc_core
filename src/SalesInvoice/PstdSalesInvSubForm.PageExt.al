pageextension 50114 "TFB Pstd. Sales Inv. SubForm" extends "Posted Sales Invoice Subform" //133
{
    layout
    {
        addbefore("Unit Price")
        {
            field(TFBPricePerKg; PricePerKg)
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Price Per Kg';
                BlankZero = true;
                ToolTip = 'Specifies the price per kilogram for the line item';
            }
            field("TFB Pre-Order"; Rec."TFB Pre-Order")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Pre-Order';
                ToolTip = 'Specifies if line was a pre-order';
            }

        }
        addafter("Line Discount %")
        {
            field("TFB Price Unit Discount"; PriceUnitDiscount)
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Editable = false;
                Caption = 'Per Kg Discount';
                ToolTip = 'Specifies the discount as a per kilogram price';

            }
        }
        addafter("Unit of Measure Code")
        {
            field(LineWeight; CalculatedLineWeight)
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Line Weight';
                BlankZero = true;
                Tooltip = 'Specifies the line weight';
            }


        }
        addafter("Total Amount Incl. VAT")
        {
            field(TFBAmtRemaining; getRemainingAmount())
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Remaining Amount';
                ToolTip = 'Specifies amount remaining to be paid on invoice';
                Style = Strong;
            }
        }

    }

    actions
    {
    }

    local procedure getRemainingAmount(): Decimal

    var
        Header: Record "Sales Invoice Header";

    begin

        Header.SetRange("No.", Rec."Document No.");

        If Header.FindFirst() then begin
            Header.CalcFields("Remaining Amount");
            Exit(Header."Remaining Amount")
        end
        else
            Exit(0);

    end;

    var
        PricingCU: CodeUnit "TFB Pricing Calculations";
        PricePerKg: Decimal;
        CalculatedLineWeight: Decimal;
        PriceUnitDiscount: Decimal;


    trigger OnAfterGetRecord()

    begin

        If rec.Type = rec.Type::Item then begin
            PricePerKg := PricingCU.CalcPerKgFromUnit(rec."Unit Price", rec."Net Weight");
            CalculatedLineWeight := rec."Net Weight" * rec.Quantity;
            PriceUnitDiscount := Rec."Line Discount Amount" / Rec."Net Weight" / Rec.Quantity;

        end
        else begin
            PricePerKg := 0;
            CalculatedLineWeight := 0;
            PriceUnitDiscount := 0;
        end;

    end;
}
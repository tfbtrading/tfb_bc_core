pageextension 50185 "TFB Sales Order Archive Sf" extends "Sales Order Archive Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field("Item Weight"; GetTotalLineWeight())
            {
                Caption = 'Total Weight';
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Editable = false;
                ToolTip = 'Specifies the net weight of the line item';
            }

            field("TFB Price Unit Cost"; GetPricePerKg())
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Caption = 'Price Per Kg';
                Editable = false;
                ToolTip = 'Specifies the price per kilogram of the item after discount';
            }

        }
        addlast(Control1)
        {
            field("Purchase Order No."; Rec."Purchase Order No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies if there was a drop ship purchase order associated';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    local procedure GetTotalLineWeight(): Decimal

    begin
        exit(Rec."Net Weight" * Rec.Quantity);
    end;

    local procedure GetPricePerKg(): Decimal

    begin
        if (Rec."Line Amount" > 0) and (GetTotalLineWeight() > 0) then
            exit(Rec."Line Amount" / GetTotalLineWeight())
        else
            exit(0);
    end;
}
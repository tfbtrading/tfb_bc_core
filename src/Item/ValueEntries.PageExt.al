pageextension 50159 "TFB Value Entries" extends "Value Entries"
{
    layout
    {
        modify("Document No.")
        {
            Visible = false;
        }
        moveafter("Document Type"; "External Document No.")
        addbefore("Cost per Unit")
        {
            field(TFBPricePerKg; _PricePerKg)
            {
                ApplicationArea = All;
                Caption = 'Cost Per Kg';
                ToolTip = 'Specifies the cost per unit in per kg terms';
                Editable = false;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        PriceCU: CodeUnit "TFB Pricing Calculations";
        _PricePerKg: Decimal;

    trigger OnAfterGetRecord()

    var
        Item: record Item;

    begin
        If Rec."Cost per Unit" > 0 then begin
            Item.Get(Rec."Item No.");
            _PricePerKg := PriceCU.CalcPerKgFromUnit(Rec."Cost per Unit", Item."Net Weight");
        end;
    end;
}
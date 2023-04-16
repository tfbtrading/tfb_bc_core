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
        addafter("Ent&ry")
        {
            action(TFBItemLedger)
            {
                ApplicationArea = All;
                Caption = 'Item Ledger';
                RunObject = page "Item Ledger Entries";
                RunPageLink = "Entry No." = field("Item Ledger Entry No.");
                Image = ItemLedger;
                Visible = true;
                Enabled = Rec."Item Ledger Entry No." > 0;
                ToolTip  = 'Opens up related item ledger entries';
            }
        }

        addafter("General Ledger_Promoted")
        {
            actionref(TFBPItemLedger; TFBItemLedger)
            {

            }
        }
        // Add changes to page actions here
    }

    var
        PriceCU: CodeUnit "TFB Pricing Calculations";
        _PricePerKg: Decimal;

    trigger OnAfterGetRecord()

    var
        Item: record Item;

    begin
        if Rec."Cost per Unit" > 0 then begin
            Item.Get(Rec."Item No.");
            _PricePerKg := PriceCU.CalcPerKgFromUnit(Rec."Cost per Unit", Item."Net Weight");
        end;
    end;
}
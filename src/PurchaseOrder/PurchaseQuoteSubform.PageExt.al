pageextension 50155 "TFB Purchase Quote Subform" extends "Purchase Quote Subform"
{
    layout
    {
        addlast(Control31)
        {
            field(TFBTotalQty; _TotalQty)
            {
                Caption = 'Total Qty (Base)';
                ToolTip = 'Specifies the total qty in base unit o measure of items on lines';
                ApplicationArea = All;
                Editable = false;
            }
        }

        addafter("Direct Unit Cost")
        {

            field("TFB Line Total Weight"; Rec."TFB Line Total Weight")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Editable = false;
                Tooltip = 'Specifies total weight of line';
            }

            field("TFB Price Unit Lookup"; Rec."TFB Price Unit Lookup")
            {
                DrillDown = false;
                Caption = 'Vendor Price Unit';
                ApplicationArea = All;
                Editable = false;
                Tooltip = 'Specifies vendors price unit';
            }

            field("TFB Price Unit Cost"; Rec."TFB Price By Price Unit")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Tooltip = 'Specifies price in vendors price unit';

            }


        }
        modify("Qty. to Assign")
        {
            Visible = false;
        }
        modify("Qty. Assigned")
        {
            Visible = false;
        }

        modify(Quantity)
        {
            trigger OnAfterValidate()

            begin
                UpdateTotalQty();
            end;
        }


    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetCurrRecord()

    begin
        UpdateTotalQty();

    end;

    local procedure UpdateTotalQty()

    begin
        PurchaseLine.CopyFilters(Rec);
        PurchaseLine.CalcSums("Quantity (Base)");
        _TotalQty := PurchaseLine."Quantity (Base)";
    end;



    var
        PurchaseLine: record "Purchase Line";
        _TotalQty: Integer;

}
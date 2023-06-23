pageextension 50163 "TFB Blank. Sales Order Subform" extends "Blanket Sales Order Subform"
{
    layout
    {
        addafter("Unit Price")
        {
            field("TFB Line Total Weight"; Rec."TFB Line Total Weight")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Editable = false;
                Caption = 'Line Weight';
                ToolTip = 'Specifies the total line weight';
            }


            field("TFB Price Unit Cost"; Rec."TFB Price Unit Cost")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Tooltip = 'Specifies the price per kilogram';
            }

        }
        addafter(Quantity)
        {
            field("TFB Consume Blanket Order"; Rec."TFB Consume Blanket Order")
            {
                Caption = 'Automically Consume';
                ToolTip = 'Specifies that new sales order for customer that add this item will automatically add details for this blanket order line';
                Enabled = Rec."Outstanding Qty. (Base)" > 0;
                ApplicationArea = All;
            }
        }
        addbefore("Quantity Shipped")
        {
            field(_UnpostedQty; _UnpostedQty)
            {
                ApplicationArea = All;
                Caption = 'Quantity Ordered';
                ToolTip = 'Specifies quantity ordered but not yet shipped';
                Editable = false;
                DrillDown = true;

                trigger OnDrillDown()

                var
                    Line: Record "Sales Line";
                    LinesPage: Page "TFB Pending Sales Lines";


                begin
                    Line.SetRange("Blanket Order No.", Rec."Document No.");
                    Line.SetRange("Blanket Order Line No.", Rec."Line No.");
                    Line.SetRange("Document Type", Line."Document Type"::Order);
                    LinesPage.SetTableView(Line);
                    LinesPage.Run();

                end;
            }

        }
        addafter("Quantity Shipped")
        {
            field(_RemainingQty; _RemainingQty)
            {
                ApplicationArea = All;
                Caption = 'Quantity Remaining';
                ToolTip = 'Quantity remainining inclusive of unposted and posted quantities';
                Editable = false;
            }
        }
    }

    actions
    {

    }

    trigger OnAfterGetRecord()

    var

    begin
        _RemainingQty := 0;
        _UnpostedQty := 0;
        _UnpostedQty := GetUnpostedQty();
        _RemainingQty := GetRemainingQtyInclUnposted();

    end;

    local procedure GetUnpostedQty(): Decimal

    var

        Line: Record "Sales Line";
    begin

        Line.SetRange("Blanket Order No.", Rec."Document No.");
        Line.SetRange("Blanket Order Line No.", Rec."Line No.");
        Line.SetRange("Document Type", Line."Document Type"::Order);

        if Line.CalcSums("Outstanding Quantity") then
            exit(Line."Outstanding Quantity");


    end;

    local procedure GetRemainingQtyInclUnposted(): Decimal

    var
    begin
        exit(Rec.Quantity - (_UnpostedQty + Rec."Quantity Shipped"));
    end;

    var

        _UnpostedQty: Decimal;
        _RemainingQty: Decimal;
}
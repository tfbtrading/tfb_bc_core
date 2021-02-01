pageextension 50120 "TFB Blanket Purch. SubForm" extends "Blanket Purchase Order Subform"
{
    layout
    {
        addafter("Direct Unit Cost")
        {
            field("TFB Line Total Weight"; Rec."TFB Line Total Weight")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Editable = false;
                Caption = 'Line Weight';
                ToolTip = 'Specifies the total line weight';
            }

            field("TFB Price Unit Lookup"; Rec."TFB Price Unit Lookup")
            {
                DrillDown = false;
                Caption = 'Vendor Price Unit';
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the vendors price unit';
            }

            field("TFB Price Unit Cost"; Rec."TFB Price By Price Unit")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Caption = 'Price By Price Unit';
                Tooltip = 'Specifies the price using vendors price unit';

            }


        }
        addbefore("Quantity Received")
        {
            field(_UnpostedQty; _UnpostedQty)
            {
                ApplicationArea = All;
                Caption = 'Quantity Ordered';
                ToolTip = 'Specifies Quantity Ordered but not yet received';
                Editable = false;
                DrillDown = true;

                trigger OnDrillDown()

                var
                    Line: Record "Purchase Line";
                    LinesPage: Page "TFB Pending Purch. Order Lines";


                begin
                    Line.SetRange("Blanket Order No.", Rec."Document No.");
                    Line.SetRange("Blanket Order Line No.", Rec."Line No.");
                    Line.SetRange("Document Type", Line."Document Type"::Order);
                    LinesPage.SetTableView(Line);
                    LinesPage.Run();

                end;
            }

        }
        addafter("Quantity Received")
        {
            field(_RemainingQty; _RemainingQty)
            {
                ApplicationArea = All;
                Caption = 'Quantity Remaining';
                ToolTip = 'Quantity remainining inclusive of unposed and posted quantities';
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

        Line: Record "Purchase Line";
    begin

        Line.SetRange("Blanket Order No.", Rec."Document No.");
        Line.SetRange("Blanket Order Line No.", Rec."Line No.");
        Line.SetRange("Document Type", Line."Document Type"::Order);

        If Line.CalcSums("Outstanding Qty. (Base)") then
            Exit(Line."Outstanding Qty. (Base)");


    end;

    local procedure GetRemainingQtyInclUnposted(): Decimal

    var
    begin
        Exit(Rec.Quantity - (_UnpostedQty + Rec."Quantity Received"));
    end;

    var

        _UnpostedQty: Decimal;
        _RemainingQty: Decimal;


}
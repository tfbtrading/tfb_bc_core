pageextension 50128 "TFB Purchase Lines" extends "Purchase Lines"
{

    layout
    {
        addafter("Document No.")
        {
            field("TFBVendorOrderNo"; GetVendorOrderNoFromHeader())
            {
                ApplicationArea = All;
                Caption = 'Vendor Order No.';
                ToolTip = 'Specifies the vendor order number from the header of the document';
            }
        }
        addafter("Outstanding Quantity")
        {
            field(_UnpostedQty; _UnpostedQty)
            {
                ApplicationArea = All;
                Caption = 'Blanket Qty Ordered';
                ToolTip = 'Specifies Quantity Ordered but not yet received';
                Editable = false;
                DrillDown = true;
                Visible = Rec."Document Type" = Rec."Document Type"::"Blanket Order";

                trigger OnDrillDown()

                var
                    Line: Record "Purchase Line";
                    LinesPage: Page "TFB Pending Purch. Order Lines";


                begin
                    if Rec."Document Type" <> Rec."Document Type"::"Blanket Order" then
                        exit;

                    Line.SetRange("Blanket Order No.", Rec."Document No.");
                    Line.SetRange("Blanket Order Line No.", Rec."Line No.");
                    Line.SetRange("Document Type", Line."Document Type"::Order);
                    LinesPage.SetTableView(Line);
                    LinesPage.Run();

                end;
            }
            field(_RemainingQty; _RemainingQty)
            {
                ApplicationArea = All;
                Caption = 'Blanket Qty Ordered';
                ToolTip = 'Specifies Quantity Ordered but not yet received';
                Editable = false;
                DrillDown = true;
                Visible = Rec."Document Type" = Rec."Document Type"::"Blanket Order";


            }

        }



        addafter("Direct Unit Cost")
        {
            field("TFB Price By Price Unit"; Rec."TFB Price By Price Unit")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the price in the vendors price unit';
            }
            field("TFB Price Unit"; Rec."TFB Price Unit Lookup")
            {
                ApplicationArea = All;
                tooltip = 'Specifies the vendors price unit';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    /// <summary> 
    /// Find and returns the text from the header vendor order number
    /// </summary>
    /// <returns>Return variable "Text".</returns>
    local procedure GetVendorOrderNoFromHeader(): Text
    var
        Header: Record "Purchase Header";

    begin

        Header.SetRange("No.", Rec."Document No.");
        Header.SetRange("Document Type", Rec."Document Type");

        if Header.FindFirst() then
            exit(Header."Vendor Order No.");

    end;



    trigger OnAfterGetRecord()

    var
        Line: Record "Purchase Line";
    begin

        Clear(_UnpostedQty);
        Clear(_RemainingQty);

        if Rec."Document Type" = Rec."Document Type"::"Blanket Order" then begin
            Line.SetRange("Blanket Order No.", Rec."Document No.");
            Line.SetRange("Blanket Order Line No.", Rec."Line No.");
            Line.SetRange("Document Type", Line."Document Type"::Order);

            if Line.CalcSums("Outstanding Qty. (Base)") then
                _UnpostedQty := Line."Outstanding Qty. (Base)";


        end;

        _UnpostedQty := Rec.Quantity - (_UnpostedQty + Rec."Quantity Received")
    end;



    var

        _UnpostedQty: Decimal;
        _RemainingQty: Decimal;

}
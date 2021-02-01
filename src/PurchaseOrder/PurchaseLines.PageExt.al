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
            field(_UnpostedQty; GetUnpostedQty())
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
                    If Rec."Document Type" <> Rec."Document Type"::"Blanket Order" then
                        Exit;

                    Line.SetRange("Blanket Order No.", Rec."Document No.");
                    Line.SetRange("Blanket Order Line No.", Rec."Line No.");
                    Line.SetRange("Document Type", Line."Document Type"::Order);
                    LinesPage.SetTableView(Line);
                    LinesPage.Run();

                end;
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

        If Header.FindFirst() then
            Exit(Header."Vendor Order No.");

    end;

    local procedure GetUnpostedQty(): Decimal

    var

        Line: Record "Purchase Line";
    begin

        If Rec."Document Type" = Rec."Document Type"::"Blanket Order" then begin
            Line.SetRange("Blanket Order No.", Rec."Document No.");
            Line.SetRange("Blanket Order Line No.", Rec."Line No.");
            Line.SetRange("Document Type", Line."Document Type"::Order);

            If Line.CalcSums("Outstanding Qty. (Base)") then
                Exit(Line."Outstanding Qty. (Base)");
        end
        else
            exit(0);


    end;
}
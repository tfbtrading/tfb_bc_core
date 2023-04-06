pageextension 50150 "TFB Blanket Purchase Orders" extends "Blanket Purchase Orders"
{
    layout
    {
        addafter("No.")
        {
            field("Vendor Order No."; Rec."Vendor Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the vendors order no.';
            }
        }

        addafter("Buy-from Vendor Name")
        {
            field("LinesDesc"; GetOrderLines())
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the lines on the order';
                MultiLine = false;
                Editable = false;
                Caption = 'Lines';
            }
        }
        modify("Assigned User ID")
        {
            Visible = false;
        }
        modify("Vendor Authorization No.")
        {
            Visible = false;
        }


    }

    actions
    {
        // Add changes to page actions here
    }
    local procedure GetOrderLines(): Text

    var
        PurchaseLines: Record "Purchase Line";
        LineBuilder: TextBuilder;

    begin
        PurchaseLines.SetRange("Document Type", Rec."Document Type");
        PurchaseLines.SetRange("Document No.", Rec."No.");
        if PurchaseLines.Findset(false) then
            repeat
                PurchaseLines.CalcFields("TFB Price Unit Lookup");
                LineBuilder.AppendLine(StrSubstNo('%1 - %2 %3 at %4', PurchaseLines.Description, PurchaseLines.Quantity, PurchaseLines."TFB Price Unit Lookup", PurchaseLines."TFB Price By Price Unit"));

            until PurchaseLines.Next() = 0;
        exit(LineBuilder.ToText());
    end;

}
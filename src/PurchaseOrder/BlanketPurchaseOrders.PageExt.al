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
    Local Procedure GetOrderLines(): Text

    var
        PurchaseLines: Record "Purchase Line";
        LineBuilder: TextBuilder;

    begin
        PurchaseLines.SetRange("Document Type", Rec."Document Type");
        PurchaseLines.SetRange("Document No.", Rec."No.");
        If PurchaseLines.Findset(false, false) then
            repeat

                LineBuilder.AppendLine(StrSubstNo('%1 - %2 %3 at %4', PurchaseLines.Description, PurchaseLines.Quantity, PurchaseLines."TFB Price Unit", PurchaseLines."TFB Price By Price Unit"));

            until PurchaseLines.Next() = 0;
        exit(LineBuilder.ToText());
    end;

}
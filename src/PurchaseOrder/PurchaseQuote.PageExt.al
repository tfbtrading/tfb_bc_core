pageextension 50156 "TFB Purchase Quote" extends "Purchase Quote"
{
    layout
    {
        addlast(General)
        {

            field("TFB Group Purchase"; Rec."TFB Group Purchase")
            {
                ApplicationArea = All;
                Importance = Promoted;
                ToolTip = 'Specifies if the quote is for a group purchase';
            }

            group(GroupPurchase)
            {
                Visible = Rec."TFB Group Purchase";
                ShowCaption = false;

                field("TFB Group Purch. Rollover Date"; Rec."TFB Group Purch. Rollover Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies date on which quote expires and rollsover';

                }

                field(TFBGroupBuyQty; _GroupBuyQty)
                {
                    Caption = 'Group Buy Sold Qty';
                    ToolTip = 'Specifies quantity of group buy sold';
                    Importance = Standard;
                    ApplicationArea = All;
                    Editable = false;
                }

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()

    begin
        UpdateGroupBuyQty();
    end;

    local procedure UpdateGroupBuyQty()

    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";

    begin
        _GroupBuyQty := 0;
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange("TFB Group Purchase Quote No.", Rec."No.");

        If SalesHeader.FindSet(false, false) then
            repeat

                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                SalesLine.SetFilter("Quantity (Base)", '>0');
                SalesLine.CalcSums("Quantity (Base)");
                _GroupBuyQty += SalesLine."Quantity (Base)";


            until SalesHeader.next() = 0;

    end;

    var
        _GroupBuyQty: Integer;

}
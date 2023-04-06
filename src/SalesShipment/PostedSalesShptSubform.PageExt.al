pageextension 50173 "TFB Posted Sales Shpt. Subform" extends "Posted Sales Shpt. Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Quantity Invoiced")
        {
            field("Purchase Order No."; Rec."Purchase Order No.")
            {
                ApplicationArea = All;
                Caption = 'Drop Ship PO';
                Visible = isPONoVisible;
                ToolTip = 'Specifies corresponding drop ship PO';

                trigger OnDrillDown()

                var
                    POReceipt: Record "Purch. Rcpt. Header";
                    POReceiptLine: Record "Purch. Rcpt. Line";

                begin

                    POReceiptLine.SetRange("Order No.", Rec."Purchase Order No.");
                    POReceiptLine.SetRange("Order Line No.", Rec."Purch. Order Line No.");

                    if POReceiptLine.FindFirst() then
                        if POReceipt.Get(POReceiptLine."Document No.") then
                            PAGE.Run(Page::"Posted Purchase Receipt", POReceipt);


                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()

    begin
        if Rec."Drop Shipment" and (Rec."Purchase Order No." <> '') then
            isPONoVisible := true
        else
            isPONoVisible := false;
    end;

    var
        isPONoVisible: Boolean;
}
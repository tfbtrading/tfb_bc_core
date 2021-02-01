pageextension 50274 "TFB Item Tracking Entries" extends "Item Tracking Entries" 
{
    layout
    {
        addafter("Document No.")
        {
            field("Posting Date"; Rec."Posting Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies date item tracking was posted';
            }

            field("TFB Order No."; OrderNo)
            {
                ApplicationArea = All;
                Caption = 'Order No';
                ToolTip = 'Specifies order number for item tracking';
            }
            field("TFBExternal Document No."; Rec."External Document No.")
            {
                ApplicationArea = All;
                Caption = 'Ext. Doc. No.';
                ToolTip = 'Specifies vendor/customer reference number';
            }
            field("TFB Source No."; Rec."Source No.")
            {
                ApplicationArea = All;
                Caption = 'Source No.';
                ToolTip = 'Specifies source no.';
            }
            field("TFB Source Desc."; SourceDesc)
            {
                ApplicationArea = All;
                Caption = 'Source Desc.';
                ToolTip = 'Specifies item description';
            }
        }

    }

    actions
    {
    }

    trigger OnAfterGetRecord()

    begin
        //Populate Item Ledger Details if Sales Shipment
        UpdateSalesShipmentDetails();

    end;

    local procedure UpdateSalesShipmentDetails(): Boolean

    var

    begin

        Clear(ShipmentRec);
        Clear(ReceiptRec);
        Clear(SourceDesc);
        Clear(OrderNo);

        case Rec."Document Type" of
            Rec."Document Type"::"Sales Shipment":

                If (Rec."Source Type" = Rec."Source Type"::Customer) and (Rec."Source No." <> '') then
                    If ShipmentRec.Get(Rec."Document No.") then begin
                        OrderNo := ShipmentRec."Order No.";
                        SourceDesc := ShipmentRec."Sell-to Customer Name";
                    end;

            Rec."Document Type"::"Purchase Receipt":

                if (Rec."Source Type" = Rec."Source Type"::Vendor) and (Rec."Source No." <> '') then
                    If ReceiptRec.Get(Rec."Document No.") then begin
                        OrderNo := ReceiptRec."Order No.";
                        SourceDesc := ReceiptRec."Buy-from Vendor Name";
                    end;

        end;

    end;

    var
        ShipmentRec: Record "Sales Shipment Header";
        ReceiptRec: Record "Purch. Rcpt. Header";
        SourceDesc: Text[100];
        OrderNo: Text[100];
}
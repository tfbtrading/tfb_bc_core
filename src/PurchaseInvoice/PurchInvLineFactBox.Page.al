/// <summary>
/// Page TFB Purch. Inv. Line Factbox (ID 50123).
/// </summary>
page 50123 "TFB Purch. Inv. Line Factbox"
{
    PageType = CardPart;

    SourceTable = "Purchase Line";
    Caption = 'Line Source Details';
    ApplicationArea = All;


    layout
    {
        area(Content)
        {
            group(General)

            {
                showCaption = false;
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of line item';
                }
                field(SourcedFrom; _SourcedFrom)
                {
                    Caption = 'Sourced from Receipt';
                    ToolTip = 'Specifies the type of document the line was sourced from';
                }
                field(OriginalOrder; _OrderNo)
                {
                    Caption = 'Purchase Order';
                    Tooltip = 'Specifies the related purchase order';

                    trigger OnDrillDown()

                    begin
                        PurchRcptCU.OpenRelatedPurchaseOrder(_OrderNo);
                    end;
                }
                field(ReceiptLineType; _ReceiptLineType)
                {
                    Caption = 'Receipt Line Type';
                    Tooltip = 'Specifies whether the line is part of a drop shipment or special order';
                }
                field(_SalesOrderNo; _SalesOrderNo)
                {
                    Caption = 'Related Sales Order';
                    Tooltip = 'Specifies the sales order for the related drop shipment';
                    //Visible = Rec."Drop Shipment";

                    trigger OnDrillDown()

                    begin
                        PurchRcptCU.OpenRelatedSalesOrder(_SalesOrderNo);
                    end;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {

        }
    }

    trigger OnAfterGetRecord()

    var
        ReceiptLine: Record "Purch. Rcpt. Line";

    begin
        Clear(_SourcedFrom);
        Clear(_OrderNo);
        Clear(_SalesOrderNo);

        if Rec."Receipt No." <> '' then begin
            _SourcedFrom := true;
            if ReceiptLine.Get(Rec."Receipt No.", Rec."Receipt Line No.") then begin

                _OrderNo := ReceiptLine."Order No.";
                _SalesOrderNo := PurchRcptCU.GetSalesOrderReferenceFromReceiptLine(ReceiptLine);
                _ReceiptLineType := PurchRcptCU.GetReceiptLineType(ReceiptLine);

            end
        end
        else
            _SourcedFrom := false;

    end;



    var
        PurchRcptCU: CodeUnit "TFB Purch. Rcpt. Mgmt";
        _SourcedFrom: Boolean;
        _OrderNo: Code[20];
        _SalesOrderNo: Code[20];
        _ReceiptLineType: Text[40];
}
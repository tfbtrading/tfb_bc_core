/// <summary>
/// Page TFB Purch. Inv. Line Factbox (ID 50123).
/// </summary>
page 50123 "TFB Purch. Inv. Line Factbox"
{
    PageType = CardPart;

    SourceTable = "Purchase Line";
    Caption = 'Line Source Details';

    layout
    {
        area(Content)
        {
            group(General)

            {
                showCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of line item';
                }
                field(SourcedFrom; _SourcedFrom)
                {
                    ApplicationArea = All;
                    Caption = 'Sourced from Receipt';
                    ToolTip = 'Specifies the type of document the line was sourced from';
                }
                field(OriginalOrder; _OrderNo)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Order';
                    Tooltip = 'Specifies the related purchase order';

                    trigger OnDrillDown()

                    var
                        OpenOrder: Record "Purchase Header";
                        ArchiveOrder: Record "Purchase Header Archive";
                        OpenOrderPage: Page "Purchase Order";
                        ArchiveOrderPage: Page "Purchase Order Archive";

                    begin

                        OpenOrder.SetRange("Document Type", OpenOrder."Document Type"::Order);
                        OpenOrder.SetRange("No.", Rec."Order No.");

                        If OpenOrder.FindFirst() then begin

                            OpenOrderPage.SetRecord(OpenOrder);
                            OpenOrderPage.Run();
                        end
                        else begin
                            ArchiveOrder.SetRange("Document Type", ArchiveOrder."Document Type"::Order);
                            ArchiveOrder.SetRange("No.", Rec."Order No.");

                            If ArchiveOrder.FindLast() then begin
                                ArchiveOrderPage.SetRecord(ArchiveOrder);
                                ArchiveOrderPage.Run();
                            end;

                        end;

                    end;
                }
                field("Drop Shipment"; Rec."Drop Shipment")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies whether the line is part of a drop shipment';
                }
                field(_SalesOrderNo; _SalesOrderNo)
                {
                    ApplicationArea = All;
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
            If ReceiptLine.Get(Rec."Receipt No.", Rec."Receipt Line No.") then begin
                _OrderNo := ReceiptLine."Order No.";
                _SalesOrderNo := ReceiptLine."Sales Order No.";
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
}
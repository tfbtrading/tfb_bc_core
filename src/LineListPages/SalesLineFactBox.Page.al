page 50111 "TFB Sales Line FactBox"
{

    PageType = CardPart;
    SourceTable = "Sales Line";
    Caption = 'TFB Sales Line FactBox';

    layout
    {
        area(content)
        {
            group(General)
            {
                ShowCaption = false;
                field(AvailInfo; _availInfo)
                {
                    ShowCaption = false;
                    Caption = 'Availability Info';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies availability information for sales line';

                    MultiLine = true;
                }
                field(Link; _linkText)
                {
                    Caption = 'Link to related record';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies link details for availability information';
                    trigger OnDrillDown()

                    var
                        SalesCU: Codeunit "TFB Sales Mgmt";

                    begin
                        SalesCU.OpenRelatedAvailabilityInfo(SalesLineStatus, RelatedRecRef);
                    end;

                }

                field(TestNotes; _notes)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Related notes';
                    ToolTip = 'Specifies related notes for availability information';
                    MultiLine = true;
                    ShowCaption = false;


                }
            }
        }
    }


    trigger OnAfterGetRecord()

    var


    begin

        DisplayAvailabilityInfo();


    end;

    procedure DisplayAvailabilityInfo()

    var
        Purchase: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        WhseShipLine: Record "Warehouse Shipment Line";
        Container: Record "TFB Container Entry";
        LedgerEntry: Record "Item Ledger Entry";
        LotNoInfo: Record "Lot No. Information";
        SalesCU: CodeUnit "TFB Sales Mgmt";
        RetAvailInfo: Text[512];
        ShipDatePlanned: Date;


    begin

        Clear(Purchase);
        Clear(Container);
        Clear(RetAvailInfo);
        Clear(ShipDatePlanned);
        Clear(RelatedRecRef);

        If SalesCU.GetItemSalesLineAvailability(rec, RetAvailInfo, ShipDatePlanned, SalesLineStatus, RelatedRecRef) then begin
            _availInfo := RetAvailInfo;

            case SalesLineStatus of
                SalesLineStatus::SentToWarehouse:
                    begin
                        RelatedRecRef.SetTable(WhseShipLine);
                        _linkText := 'Warehouse Shipment ' + WhseShipLine."No.";
                    end;
                SalesLineStatus::ReservedFromLocalPO:
                    begin
                        RelatedRecRef.SetTable(PurchaseLine);
                        _linkText := 'Warehouse PO ' + PurchaseLine."No.";
                    end;
                SalesLineStatus::ReservedFromInboundContainer:
                    begin
                        RelatedRecRef.SetTable(Container);
                        _linkText := Container."Container No.";
                    end;
                SalesLineStatus::ReservedFromPlannedContainer:
                    begin
                        RelatedRecRef.SetTable(Container);
                        _linkText := 'Planned container ' + Container."No.";
                    end;
                SalesLineStatus::ReservedFromArrivedContainer:
                    begin
                        RelatedRecRef.SetTable(Container);
                        _linkText := Container."Container No.";
                    end;
                SalesLineStatus::ReservedFromStock:
                    begin
                        RelatedRecRef.SetTable(LedgerEntry);
                        _linkText := 'Stock ledger ' + format(LedgerEntry."Entry No.");
                    end;
                SalesLineStatus::ReservedFromStockPendingRelease:
                    begin
                        RelatedRecRef.SetTable(LotNoInfo);
                        _linkText := 'Lot Info ' + format(LedgerEntry."Entry No.");
                    end;
                SalesLineStatus::ConfirmedByDropShipSupplier:
                    begin
                        RelatedRecRef.SetTable(Purchase);
                        _linkText := 'Drop ship ' + Purchase."No.";

                    end;
                SalesLineStatus::NotConfirmedByDropShipSupplier:
                    begin
                        _linkText := 'Sales Order ' + rec."Document No.";
                        clear(RelatedRecRef);
                    end
                else
                    _linkText := 'Not Set';

            end;
        end
        else
            _availInfo := '';
    end;

    var
        RelatedRecRef: RecordRef;
        _availInfo: Text[512];
        _linkText: Text;
        SalesLineStatus: Enum "TFB Sales Line Status";
        _notes: Text;
}

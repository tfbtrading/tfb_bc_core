codeunit 50102 "TFB Lot Intelligence"
{

    procedure CheckSalesLineItemTrackingOkay(DocNo: Code[20]; LineNo: Integer; QtyBaseToCheck: Decimal): Boolean
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";

        RecRef: RecordRef;
        QtyTracked: Decimal;
    begin


        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", DocNo);
        SalesLine.SetRange("Line No.", LineNo);
        If SalesLine.FindFirst() then begin

            //check if tracking is enabled for line item

            If SalesLine.Type = SalesLine.Type::Item then begin

                if Item.Get(SalesLine."No.") then begin

                    If Item."Item Tracking Code" <> '' then begin

                        ItemTrackingCode.Get(Item."Item Tracking Code");

                        If ItemTrackingCode."Lot Sales Outbound Tracking" then begin
                            RecRef.GetTable(SalesLine);
                            QtyTracked := CheckSalesLineTrackedQty(RecRef);

                            If QtyBaseToCheck = QtyTracked then
                                Exit(true)
                            else
                                Exit(false);
                        end
                        else
                            Exit(true); //No lot tracking on sales outbound
                    end
                    else
                        Exit(true); //No lot tracking policy
                end
                else
                    Exit(false); //Error no line item found
            end
            else
                exit(true); //Indicate true not an inventory item found

        end else
            exit(false); //Issue no line item found

        //Compress Tracking specification

    end;

    procedure CheckWhsLineItemTrackingOkay(DocNo: Code[20]): Boolean

    var

        Line: Record "Warehouse Shipment Line";
        IssueFound: Boolean;


    begin
        Line.SetRange("No.", DocNo);
        Line.SetRange("Source Document", Line."Source Document"::"Sales Order");
        IssueFound := false;

        if Line.FindSet() then
            repeat

                //Not return indicates that line item tracking is missing and set issue found to true
                If (not IssueFound) and (not CheckSalesLineItemTrackingOkay(Line."Source No.", Line."Source Line No.", Line."Qty. to Ship (Base)")) then
                    IssueFound := true;

            until Line.Next() < 1;

        If IssueFound then
            exit(false)
        else
            exit(True);
    end;


    local procedure CheckSalesLineTrackedQty(RecRef: RecordRef): Decimal

    var
        ReservationEntry: Record "Reservation Entry";
        FldRef: FieldRef;

        TotalQtyToHandle: Decimal;



    begin
        FldRef := RecRef.Field(3); // Document No
        ReservationEntry.SetRange("Source ID", FldRef.Value());
        FldRef := RecRef.Field(4); // Line No
        ReservationEntry.SetRange("Source Ref. No.", FldRef.Value());
        FldRef := RecRef.Field(6); // No.
        ReservationEntry.SetRange("Item No.", FldRef.Value());

        ReservationEntry.SetRange("Source Type", RecRef.Number());
        ReservationEntry.SetFilter("Item Tracking", '> %1', ReservationEntry."Item Tracking"::None);
        if ReservationEntry.FindSet() then
            repeat


                TotalQtyToHandle := TotalQtyToHandle + ABS(ReservationEntry."Qty. to Handle (Base)");

            until ReservationEntry.Next() = 0;

        exit(TotalQtyToHandle);
    end;

    procedure GetEmoji(LotStatus: Enum "TFB Lot Status"): Text

    begin
        case LotStatus of
            LotStatus::DoesNotExist:
                Exit('🔴');

            LotStatus::ExistsNoIssue:
                Exit('✔️');

            LotStatus::ExistsWithIssue:
                Exit('🔔');

            LotStatus::NotRequired:
                Exit('⚪️');

        end;
    end;

    procedure CheckIfLotNoRequired(ItemNo: Code[20]): Boolean
    var

        LotPolicy: Record "Item Tracking Code";
        Item: Record Item;
        Required: Boolean;

    begin

        Item.Get(ItemNo);

        If (LotPolicy.Get(Item."Item Tracking Code")) then
            If LotPolicy."Lot Specific Tracking" and LotPolicy."Lot Purchase Inbound Tracking" then
                Required := true;

        Exit(Required);

    end;

    procedure CheckIfLotIssueExists(ResEntry: Record "Reservation Entry"; CoARequired: Boolean): Boolean
    var
        LotInfo: Record "Lot No. Information";
        LotPolicy: Record "Item Tracking Code";
        Item: Record Item;
        PersBlobCU: CodeUnit "Persistent Blob";
        IssueExists: Boolean;

    begin

        LotInfo.SetRange("Lot No.", ResEntry."Lot No.");
        LotInfo.SetRange("Item No.", ResEntry."Item No.");
        LotInfo.SetRange("Variant Code", ResEntry."Variant Code");

        Item.Get(ResEntry."Item No.");

        If (LotPolicy.Get(Item."Item Tracking Code")) then
            If LotPolicy."Lot Info. Inbound Must Exist" then
                If not (LotInfo.FindFirst()) then
                    IssueExists := true
                else
                    If CoARequired and not (PersBlobCU.Exists(LotInfo."TFB CoA Attach.")) then
                        IssueExists := true;

        Exit(IssueExists);


    end;


    procedure CheckIfLotIssueExists(ItemLedger: Record "Item Ledger Entry"; CoARequired: Boolean): Boolean
    var
        LotInfo: Record "Lot No. Information";
        Item: Record Item;
        LotPolicy: Record "Item Tracking Code";
        PersBlobCU: CodeUnit "Persistent Blob";
        IssueExists: Boolean;

    begin

        LotInfo.SetRange("Lot No.", ItemLedger."Lot No.");
        LotInfo.SetRange("Item No.", ItemLedger."Item No.");
        LotInfo.SetRange("Variant Code", ItemLedger."Variant Code");

        Item.Get(ItemLedger."Item No.");

        If (LotPolicy.Get(Item."Item Tracking Code")) then
            If LotPolicy."Lot Info. Inbound Must Exist" then
                If not (LotInfo.FindFirst()) then
                    IssueExists := true
                else
                    If CoARequired and not (PersBlobCU.Exists(LotInfo."TFB CoA Attach.")) then
                        IssueExists := true;

        Exit(IssueExists);


    end;
}
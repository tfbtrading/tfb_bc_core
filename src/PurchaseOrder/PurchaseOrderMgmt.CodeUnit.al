/// <summary>
/// Codeunit TFB Purchase Order Mgmt (ID 50106).
/// </summary>
codeunit 50106 "TFB Purchase Order Mgmt"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateBlanketOrderLineNo', '', false, false)]
    local procedure OnBeforeValidateBlanketOrderLineNo(var PurchaseLine: Record "Purchase Line"; var InHandled: Boolean);

    var
        PurchLine2: Record "Purchase Line";
    begin

        if InHandled then
            exit;

        PurchaseLine.TestField(PurchaseLine."Quantity Received", 0);
        if PurchaseLine."Blanket Order Line No." <> 0 then begin
            PurchLine2.Get(PurchaseLine."Document Type"::"Blanket Order", PurchaseLine."Blanket Order No.", PurchaseLine."Blanket Order Line No.");
            PurchLine2.TestField(Type, PurchaseLine.Type);
            PurchLine2.TestField("No.", PurchaseLine."No.");
            PurchLine2.TestField("Pay-to Vendor No.", PurchaseLine."Pay-to Vendor No.");
            PurchLine2.TestField("Buy-from Vendor No.", PurchaseLine."Buy-from Vendor No.");
            if PurchaseLine."Drop Shipment" then begin
                PurchLine2.TestField("Variant Code", PurchaseLine."Variant Code");
                PurchLine2.TestField("Location Code", PurchaseLine."Location Code");
                PurchLine2.TestField("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
            end else begin
                PurchaseLine.Validate("Variant Code", PurchLine2."Variant Code");
                //Removed inheretance of location from blanket purchase order as it should not matter
                //All other code is copied directly
                PurchaseLine.Validate("Unit of Measure Code", PurchLine2."Unit of Measure Code");
            end;
            PurchaseLine.Validate("Direct Unit Cost", PurchLine2."Direct Unit Cost");
            PurchaseLine.Validate("Line Discount %", PurchLine2."Line Discount %");
        end;

        InHandled := true;
    end;

    local procedure GetNextWorkDay(Location: Code[20]; TargetDate: Date): Date

    var
        CompanyInfo: Record "Company Information";
        CustomCalChange: Record "Customized Calendar Change";
        CalendarMgt: CodeUnit "Calendar Management";
        CalcDateFormula: DateFormula;
        NonWorking: Boolean;

    begin
        Evaluate(CalcDateFormula, '1D');
        TargetDate := CalcDate(CalcDateFormula, TargetDate);
        CompanyInfo.Get();
        CustomCalChange.SetSource(CustomCalChange."Source Type"::Location, Location, '', CompanyInfo."Base Calendar Code");
        repeat

            If CalendarMgt.IsNonworkingDay(TargetDate, CustomCalChange) then
                TargetDate := CalcDate(CalcDateFormula, TargetDate);
        Until Not NonWorking;

        Exit(TargetDate);
    end;





    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidatePromisedReceiptDate', '', false, false)]
    local procedure OnBeforeValidatePromisedReceiptDate(var PurchaseLine: Record "Purchase Line"; CallingFieldNo: Integer; var IsHandled: Boolean; xPurchaseLine: Record "Purchase Line");

    var
        SupplyResEntry: Record "Reservation Entry";
        DemandResEntry: Record "Reservation Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Location: record Location;
        DateFormula: DateFormula;
        AlreadyReleased: Boolean;

    begin



        Evaluate(DateFormula, '+2D');
        PurchaseLine.CalcFields("Reserved Qty. (Base)");


        If (not PurchaseLine."Drop Shipment") and (PurchaseLine."Reserved Qty. (Base)" > 0) then begin
            If not Confirm(StrSubstNo('Update shipment date on sales reservations from %1 to %2?', xPurchaseLine."Promised Receipt Date", PurchaseLine."Promised Receipt Date")) then
                exit;





            SupplyResEntry.SetRange("Source ID", PurchaseLine."Document No.");
            SupplyResEntry.SetRange("Source Ref. No.", PurchaseLine."Line No.");
            SupplyResEntry.SetRange("Item No.", PurchaseLine."No.");
            SupplyResEntry.SetRange(Positive, true);

            If SupplyResEntry.FindFirst() then begin

                DemandResEntry.SetRange(Positive, false);
                DemandResEntry.SetRange("Entry No.", SupplyResEntry."Entry No.");

                If DemandResEntry.FindFirst() then
                    case DemandResEntry."Source Type" of

                        37:
                            begin

                                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                                SalesLine.SetRange("Document No.", DemandResEntry."Source ID");
                                SalesLine.SetRange("Line No.", DemandResEntry."Source Ref. No.");

                                If SalesLine.FindFirst() then
                                    If SalesLine."Shipment Date" <= CalcDate(Location."Inbound Whse. Handling Time", PurchaseLine."Promised Receipt Date") then begin

                                        SalesHeader.SetRange("Document Type", SalesLine."Document Type");
                                        SalesHeader.SetRange("No.", SalesLine."Document No.");

                                        SalesHeader.FindFirst();
                                        Location.Get(SalesLine."Location Code");

                                        SalesHeader.SetStatus(SalesHeader.Status::Open.AsInteger());
                                        SalesLine.Validate("Shipment Date", GetNextWorkDay(SalesLine."Location Code", CalcDate(Location."Inbound Whse. Handling Time", PurchaseLine."Promised Receipt Date")));
                                        SalesLine.Modify(true);
                                        SalesHeader.SetStatus(SalesHeader.Status::Released.AsInteger());

                                    end;

                            end;

                    end;

            end;
        end
        else
            if (PurchaseLine."Drop Shipment") then
                If SalesHeader.Get(SalesHeader."Document Type"::Order, PurchaseLine."Sales Order No.") then begin
                    Clear(AlreadyReleased);
                    If SalesHeader.Status = SalesHeader.Status::Released then begin
                        SalesHeader.SetStatus(SalesHeader.Status::Open.AsInteger());
                        AlreadyReleased := true;
                    end;

                    SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                    SalesLine.SetRange("Document No.", DemandResEntry."Source ID");
                    SalesLine.SetRange("Line No.", DemandResEntry."Source Ref. No.");

                    If SalesLine.FindFirst() and Confirm(StrSubstNo('Update dropship sales order item receipt date from %1 to %2?', SalesLine."Promised Delivery Date", PurchaseLine."Promised Receipt Date")) then begin
                        SalesLine.Validate("Planned Shipment Date", PurchaseLine."Promised Receipt Date");
                        SalesLine.Modify(true);
                        If AlreadyReleased then
                            SalesHeader.SetStatus(SalesHeader.Status::Released.AsInteger());
                    end
                end;



        if CallingFieldNo <> 0 then
            if PurchaseLine."Promised Receipt Date" <> 0D then
                PurchaseLine.Validate("Planned Receipt Date", PurchaseLine."Promised Receipt Date")
            else
                PurchaseLine.Validate("Requested Receipt Date")
        else
            PurchaseLine.Validate("Planned Receipt Date", Purchaseline."Promised Receipt Date");
        IsHandled := true;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateExpectedReceiptDateOnBeforeCheckDateConflict', '', false, false)]
    local procedure HandlePurchaseLineDateChange(var IsHandled: Boolean; var PurchaseLine: Record "Purchase Line")
    var
    /*     SupplyResEntry: Record "Reservation Entry";
        DemandResEntry: Record "Reservation Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReservDateCheck: CodeUnit "Reservation-Check Date Confl.";
        DateFormula: DateFormula; */

    begin
        /* 
        Message('Showing handle purchase line date change');
        Evaluate(DateFormula, '+2D');
        PurchaseLine.CalcFields("Reserved Qty. (Base)");


        If (not PurchaseLine."Drop Shipment") and (PurchaseLine."Reserved Qty. (Base)" > 0) then begin
            Message('Custom code added');
            ReservDateCheck.PurchLineCheck(PurchaseLine, false);
            IsHandled := true;



            SupplyResEntry.SetRange("Source ID", PurchaseLine."Document No.");
            SupplyResEntry.SetRange("Source Ref. No.", PurchaseLine."Line No.");
            SupplyResEntry.SetRange("Item No.", PurchaseLine."No.");
            SupplyResEntry.SetRange(Positive, true);

            If SupplyResEntry.FindFirst() then begin

                DemandResEntry.SetRange(Positive, false);
                DemandResEntry.SetRange("Entry No.", SupplyResEntry."Entry No.");

                If DemandResEntry.FindFirst() then
                    case DemandResEntry."Source Type" of

                        37:
                            begin

                                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                                SalesLine.SetRange("Document No.", DemandResEntry."Source ID");
                                SalesLine.SetRange("Line No.", DemandResEntry."Source Ref. No.");

                                If SalesLine.FindFirst() then
                                    If Confirm('Change Sales Line for Order %1 dispatch date from %2 to %3', true, SalesLine."Document No.", SalesLine."Shipment Date", PurchaseLine."Expected Receipt Date") then begin

                                        SalesHeader.SetRange("Document Type", SalesLine."Document Type");
                                        SalesHeader.SetRange("No.", SalesLine."Document No.");

                                        SalesHeader.FindFirst();

                                        SalesHeader.SetStatus(SalesHeader.Status::Open);
                                        SalesLine.Validate("Shipment Date", CalcDate(DateFormula, PurchaseLine."Expected Receipt Date"));
                                        SalesLine.Modify(true);
                                        SalesHeader.SetStatus(SalesHeader.Status::Released);

                                    end;

                            end;

                    end;

            end;
        end; */
    end;

    // TODO Add real docs
    /// <summary>
    /// GetLineLotStatus.
    /// </summary>
    /// <param name="Line">Record "Purchase Line".</param>
    /// <returns>Return value of type Enum "TFB Lot Status".</returns>
    procedure GetLineLotStatus(Line: Record "Purchase Line"): Enum "TFB Lot Status"
    var
        ItemLedger: Record "Item Ledger Entry";
        LotStatus: Enum "TFB Lot Status";

    begin
        LotStatus := LotStatus::ExistsWithIssue;
        If Line.Type = Line.Type::Item then
            If Line."Quantity Received" = Line.Quantity then begin
                If GetItemLedgerForPOLine(Line, ItemLedger) then
                    GetLedgerEntryLotStatus(Line."Quantity (Base)", Line, LotStatus);

            end
            else
                GetPurchaseLineLotStatus(Line."Quantity (Base)", Line, LotStatus)
        else
            LotStatus := LotStatus::NotRequired;
        Exit(LotStatus);
    end;

    local procedure GetItemLedgerForPOLine(Line: Record "Purchase Line"; var ItemLedger: Record "Item Ledger Entry"): Boolean
    var
        ReceiptLine: Record "Purch. Rcpt. Line";

    begin

        ReceiptLine.SetRange("Order No.", Line."Document No.");
        ReceiptLine.SetRange("Order Line No.", Line."Line No.");

        If ReceiptLine.FindFirst() then begin

            ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Purchase);
            ItemLedger.SetRange("Document Type", ItemLedger."Document Type"::"Purchase Receipt");
            ItemLedger.SetRange("Document No.", ReceiptLine."Document No.");
            ItemLedger.SetRange("Document Line No.", ReceiptLine."Line No.");

            If ItemLedger.FindFirst() then
                Exit(true);
        end;

    end;

    local procedure GetPurchaseLineLotStatus(QtyToTrack: Decimal; Line: Record "Purchase Line"; var LotStatus: Enum "TFB Lot Status")

    var
        ReservationEntry: Record "Reservation Entry";
        LotCU: CodeUnit "TFB Lot Intelligence";
        QtyTracked: Decimal;
        IssueFlagged: Boolean;

    begin



        If LotCU.CheckIfLotNoRequired(Line."No.") then begin

            //Check if Lot Information is Required

            ReservationEntry.SetRange("Source ID", Line."Document No.");
            ReservationEntry.SetRange("Source Ref. No.", Line."Line No.");
            ReservationEntry.SetRange("Item No.", Line."No.");

            ReservationEntry.SetRange("Source Type", 39);
            ReservationEntry.SetFilter("Item Tracking", '> %1', ReservationEntry."Item Tracking"::None);
            if ReservationEntry.FindSet() then
                repeat

                    QtyTracked := QtyTracked + ABS(ReservationEntry."Qty. to Handle (Base)");
                    IssueFlagged := LotCU.CheckIfLotIssueExists(ReservationEntry, true);

                until ReservationEntry.Next() = 0;

            If QtyTracked = 0 then
                LotStatus := LotStatus::DoesNotExist
            else
                if QtyTracked < QtyToTrack then
                    LotStatus := LotStatus::ExistsWithIssue
                else
                    if QtyTracked = QtyToTrack then
                        LotStatus := LotStatus::ExistsNoIssue;

            If IssueFlagged then
                LotStatus := LotStatus::ExistsWithIssue;
        end
        else
            LotStatus := LotStatus::NotRequired;

    end;



    local procedure GetLedgerEntryLotStatus(QtyToTrack: Decimal; PurchaseLine: Record "Purchase Line"; var LotStatus: Enum "TFB Lot Status")

    var

        ReceiptLine: Record "Purch. Rcpt. Line";
        ItemLedger: Record "Item Ledger Entry";
        LotCU: CodeUnit "TFB Lot Intelligence";
        QtyTracked: Decimal;
        IssueFlagged: Boolean;

    begin

        //Check if Lot Information is Required

        If LotCU.CheckIfLotNoRequired(PurchaseLine."No.") then begin

            ReceiptLine.SetRange("Order No.", PurchaseLine."Document No.");
            ReceiptLine.SetRange("Order Line No.", PurchaseLine."Line No.");

            If ReceiptLine.FindSet() then
                repeat

                    ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Purchase);
                    ItemLedger.SetRange("Document Type", ItemLedger."Document Type"::"Purchase Receipt");
                    ItemLedger.SetRange("Document No.", ReceiptLine."Document No.");
                    ItemLedger.SetRange("Document Line No.", ReceiptLine."Line No.");

                    If ItemLedger.FindSet() then
                        repeat

                            QtyTracked := QtyTracked + ABS(ItemLedger.Quantity);
                            IssueFlagged := LotCU.CheckIfLotIssueExists(ItemLedger, true);

                        until ItemLedger.Next() = 0;





                until ReceiptLine.Next() = 0;




            If QtyTracked = 0 then
                LotStatus := LotStatus::DoesNotExist
            else
                if QtyTracked < QtyToTrack then
                    LotStatus := LotStatus::ExistsWithIssue
                else
                    if QtyTracked = QtyToTrack then
                        LotStatus := LotStatus::ExistsNoIssue;

            If IssueFlagged then
                LotStatus := LotStatus::ExistsWithIssue;
        end
        else
            LotStatus := LotStatus::NotRequired;



    end;
}
codeunit 50122 "TFB Sales Mgmt"
{



    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInitInsert', '', false, false)]
    local procedure MyProcedure(var IsHandled: Boolean; var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")
    begin

        SalesHeader."Compress Prepayment" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document-Mailing", 'OnBeforeGetAttachmentFileName', '', false, false)]
    local procedure OnBeforeGetAttachmentFileName(var AttachmentFileName: Text[250]; PostedDocNo: Code[20]; EmailDocumentName: Text[250]; ReportUsage: Integer);
    var
        SalesOrder: record "Sales Header";

    begin

        case ReportUsage of
            Enum::"Report Selection Usage"::"S.Order".AsInteger():

                If SalesOrder.Get(Enum::"Sales Document Type"::Order.AsInteger(), PostedDocNo) and (SalesOrder."Prepayment %" = 100) then
                    AttachmentFileName := StrSubstNo('Sales Contract (Proforma) %1.pdf', PostedDocNo)
                else
                    AttachmentFileName := StrSubstNo('Sales Contract %1.pdf', PostedDocNo)

        end;

    end;

    procedure OpenExistingSalesOrder(DuplicateNotification: Notification): Text
    var
        SalesOrderSystemID: Guid;
        SalesHeader: Record "Sales Header";
        SalesOrderPage: Page "Sales Order";

    begin
        SalesOrderSystemID := DuplicateNotification.GetData('SystemId');
        SalesHeader.GetBySystemId(SalesOrderSystemID);
        SalesOrderPage.SetRecord(SalesHeader);
        SalesOrderPage.Run();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterSalesShptHeaderInsert', '', false, false)]
    local procedure OnAfterSalesShptHeaderInsert(var SalesShipmentHeader: Record "Sales Shipment Header"; SalesOrderHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PurchHeader: Record "Purchase Header");
    begin

        SalesShipmentHeader."Package Tracking No." := CopyStr(Purchheader."Vendor Shipment No.", 1, 30);
    end;



    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeCheckAssocPurchOrder', '', false, false)]
    local procedure HandleOnBeforeCheckAssocPurchOrder(TheFieldCaption: Text[250]; var IsHandled: Boolean; var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    var
        PurchaseLine: Record "Purchase Line";
        ContinueChangeQtyMsg: Label 'Do you want to change qty in associated PO?';
    begin


        /* 

                If (SalesLine."Quantity (Base)" <> xSalesLine."Quantity (Base)") and (xSalesLine."Quantity (Base)" = xSalesLine."Outstanding Qty. (Base)") then begin
                    PurchaseLine.SetRange("Document No.", SalesLine."Purchase Order No.");
                    PurchaseLine.SetRange("Line No.", SalesLine."Purch. Order Line No.");
                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);

                    If PurchaseLine.FindFirst() and (PurchaseLine."Quantity (Base)" <> SalesLine."Quantity (Base)") then
                        If Dialog.Confirm(ContinueChangeQtyMsg) then begin
                            PurchaseLine.validate(Quantity, SalesLine.Quantity);
                            PurchaseLine.Modify();
                            IsHandled := true;
                        end; */

        //TODO Determine if we actually need to recreate additional checks and code to duplicate other checks performed by this function
        //  end;

    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterUpdateSalesLineBeforePost', '', false, false)]
    local procedure HandleUpdateSalesLineBeforePost(CommitIsSuppressed: Boolean; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; WhseReceive: Boolean; WhseShip: Boolean)


    var
        ExchangeRate: Record "Currency Exchange Rate";
        Rate: Decimal;
        NewUnitPrice: Decimal;
        RateDiff: Decimal;
        RateDiffPerc: Decimal;
        UnitPriceDiff: Decimal;

    begin

        If (SalesLine."TFB Pre-Order") and (SalesLine."Qty. to Invoice" > 0) then begin

            //Transfer across fields

            Rate := ExchangeRate.ExchangeRate(SalesHeader."Posting Date", CopyStr(SalesLine."TFB Pre-Order Currency", 1, 10));
            RateDiff := Rate - SalesLine."TFB Pre-Order Exch. Rate";
            RateDiffPerc := RateDiff / SalesLine."TFB Pre-Order Exch. Rate";
            NewUnitPrice := Round(SalesLine."Unit Price" * (1 - RateDiffPerc), 0.01);
            UnitPriceDiff := Round(NewUnitPrice - SalesLine."Unit Price", 0.01);


            SalesLine.SuspendStatusCheck(true);
            SalesLine."TFB Pre-Order Adj. Exch. Rate" := Rate;
            SalesLine."TFB Pre-Order Unit Price Adj." := UnitPriceDiff;
            SalesLine.Validate("Unit Price", SalesLine."Unit Price" + UnitPriceDiff);
            SalesLine."TFB Pre-Order Adj. Date" := SalesHeader."Posting Date";
            SalesHeader.SuspendStatusCheck(false);
            Message('Updated unit price by %1 with exch rate perc diff of %2', UnitPriceDiff, RateDiffPerc);

        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    local procedure HandleOnBeforeReleaseSalesDoc(PreviewMode: Boolean; var SalesHeader: Record "Sales Header")

    var

        Customer: Record Customer;

    begin

        Customer.Get(SalesHeader."Sell-to Customer No.");

        If (Customer."TFB External No. Req.") and (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then
            If SalesHeader."External Document No." = '' then
                Error('Cannot release. External Reference No. is required for customers orders');


    end;

    procedure GetShipmentNoForInvoiceLine(DocumentNo: Code[20]; LineNo: Integer): Code[20]

    var
        ValueEntry: Record "Value Entry";
        ItemLedger: Record "Item Ledger Entry";
        SalesShipment: Record "Sales Shipment Header";

    begin
        ValueEntry.SetRange("Document No.", DocumentNo);
        ValueEntry.SetRange("Document Line No.", LineNo);
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetRange(Adjustment, false);

        if ValueEntry.FindFirst() then
            //Locate shipment
            If ItemLedger.Get(ValueEntry."Item Ledger Entry No.") then
                If ItemLedger."Document Type" = ItemLedger."Document Type"::"Sales Shipment" then
                    If SalesShipment.Get(ItemLedger."Document No.") then
                        //Return the shipment document number
                        Exit(SalesShipment."No.");
    end;

    procedure SendPODRequest(DocumentNo: Code[20]; LineNo: Integer)

    var
        ValueEntry: Record "Value Entry";
        ItemLedger: Record "Item Ledger Entry";
        SalesShipment: Record "Sales Shipment Header";
        ShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";

    begin
        ValueEntry.SetRange("Document No.", DocumentNo);
        If LineNo > 0 then
            ValueEntry.SetRange("Document Line No.", LineNo);
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetRange(Adjustment, false);

        if ValueEntry.FindSet(false, false) then
            repeat

                //Locate shipments
                If ItemLedger.Get(ValueEntry."Item Ledger Entry No.") then begin

                    //Retrieve sales shipment
                    Clear(SalesShipment);
                    If ItemLedger."Document Type" = ItemLedger."Document Type"::"Sales Shipment" then
                        If SalesShipment.Get(ItemLedger."Document No.") then
                            //Call Sales Shipment CU
                            ShipmentCU.SendShipmentStatusQuery(SalesShipment, DocumentNo);
                end;


            until ValueEntry.Next() < 1;

    end;

    procedure AdjustSalesLinePlannedDateByItemRes(ItemLedgerEntry: Record "Item Ledger Entry"): Boolean

    var
        ResEntry: Record "Reservation Entry";
        ResEntryDemand: Record "Reservation Entry";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        LotInfo: Record "Lot No. Information";
        DateFormula: DateFormula;
        BlockDate: Date;

    begin

        If Dialog.Confirm('Defer shipments by 1 day from today for %1?', false, ItemLedgerEntry.Description) then
            Evaluate(DateFormula, '+1D')
        else
            Evaluate(DateFormula, '0D');

        LotInfo.SetRange("Item No.", ItemLedgerEntry."Item No.");
        LotInfo.SetRange("Lot No.", ItemLedgerEntry."Lot No.");
        LotInfo.SetRange("Variant Code", ItemLedgerEntry."Variant Code");

        if LotInfo.FindFirst() then
            If (LotInfo.Blocked) and (LotInfo."TFB Date Available" > 0D) then
                BlockDate := LotInfo."TFB Date Available" else
                BlockDate := today();


        ResEntry.SetRange("Item No.", ItemLedgerEntry."Item No.");
        ResEntry.SetRange("Source Ref. No.", ItemLedgerEntry."Entry No.");
        ResEntry.SetRange("Source Type", 32);
        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Reservation);

        If Dialog.Confirm('Found %1 Reservations to Adjust. Continue?', true, ResEntry.Count()) then
            if ResEntry.FindSet(false, false) then
                repeat
                    Clear(ResEntryDemand);
                    Clear(SalesLine);
                    ResEntryDemand.SetRange("Entry No.", ResEntry."Entry No.");
                    ResEntryDemand.SetRange(Positive, false);
                    ResEntryDemand.SetRange("Source Type", 37);



                    If ResEntryDemand.FindFirst() then begin
                        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                        SalesLine.SetRange("Document No.", ResEntryDemand."Source ID");
                        SalesLine.SetRange("Line No.", ResEntryDemand."Source Ref. No.");
                        SalesLine.SetRange("Whse. Outstanding Qty. (Base)", 0);

                        If SalesLine.FindFirst() then begin

                            SalesHeader.SetRange("Document Type", SalesLine."Document Type");
                            SalesHeader.SetRange("No.", SalesLine."Document No.");
                            SalesHeader.FindFirst();

                            If Dialog.Confirm('Change date from %1 to %2 for order %3 to %4 originally requested on %5', true, SalesLine."Shipment Date", CalcDate(DateFormula, BlockDate), SalesLine."Document No.", SalesHeader."Sell-to Customer Name", SalesHeader."Requested Delivery Date") then begin

                                SalesHeader.SetRange("Document Type", SalesLine."Document Type");
                                SalesHeader.SetRange("No.", SalesLine."Document No.");

                                SalesHeader.FindFirst();

                                SalesHeader.Status := SalesHeader.Status::Open;
                                SalesHeader.Modify();
                                SalesLine.Validate("Shipment Date", CalcDate(DateFormula, BlockDate));
                                SalesLine.Modify();
                                SalesHeader.Status := SalesHeader.Status::Released;
                                SalesHeader.Modify();

                            end;
                        end;

                    end;
                until ResEntry.Next() < 1;

    end;

    procedure GetSalesLineStatusEmoji(SalesLine: Record "Sales Line"): Text

    var
        Item: Record Item;
        _availability: Text;
        emojiDropShipTxt: Label '📦';
        emojiDropShipPendingTxt: Label '🛒';
        emojiSpecialTxt: Label '🔐';
        emojiAvailableTxt: Label '🟢';
        emojiReservedTxt: Label '👌';
        emojiNotAvailableTxt: Label '🟠';
        emojiShippedTxt: Label '😀';
        emojiReservedWaitingStockTxt: Label '🪂';
        emojiNotApplicable: Label '';

    begin
        _availability := '';

        SalesLine.CalcFields(SalesLine."Reserved Qty. (Base)");


        If SalesLine.Type = SalesLine.Type::Item then
            If Item.Get(SalesLine."No.") then begin
                Item.SetRange("Location Filter", SalesLine."Location Code");
                Item.CalcFields(Inventory);
                If not ((SalesLine."Drop Shipment") or (SalesLine."Special Order")) then
                    If SalesLine."Outstanding Qty. (Base)" = 0 then
                        _availability := emojiShippedTxt
                    else
                        If SalesLine."Reserved Qty. (Base)" = SalesLine."Outstanding Qty. (Base)" then
                            if Item.Inventory > SalesLine."Outstanding Qty. (Base)" then
                                _availability := emojiReservedTxt
                            else
                                _availability := emojiReservedWaitingStockTxt
                        else
                            if Item.Inventory > SalesLine."Outstanding Qty. (Base)" then
                                _availability := emojiAvailableTxt
                            else
                                _availability := emojiNotAvailableTxt
                else
                    If SalesLine."Outstanding Qty. (Base)" = 0 then
                        _availability := emojiShippedTxt
                    else begin

                        if SalesLine."Drop Shipment" then
                            If SalesLine."Purchase Order No." <> '' then
                                _availability := emojiDropShipTxt else
                                _availability := emojiDropShipPendingTxt;

                        if SalesLine."Special Order" then
                            If SalesLine."Purchase Order No." <> '' then
                                _availability := emojiSpecialTxt else
                                _availability := emojiDropShipPendingTxt;
                    end;
            end
            else
                _availability := emojiNotApplicable
        else
            _availability := emojiNotApplicable;
        Exit(_availability);
    end;



    procedure OpenRelatedAvailabilityInfo(SalesLineStatus: Enum "TFB Sales Line Status"; RelatedRecRef: RecordRef)

    var
        Purchase: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        WhseShipLine: Record "Warehouse Shipment Line";
        WhseShip: Record "Warehouse Shipment Header";
        Container: Record "TFB Container Entry";
        LedgerEntry: Record "Item Ledger Entry";
        LotNoInfo: Record "Lot No. Information";

        PurchasePage: Page "Purchase Order";
        ContainerPage: Page "TFB Container Entry";
        LedgerEntryPage: Page "Item Ledger Entries";
        LotNoInfoPage: Page "Lot No. Information Card";
        WhseShipPage: Page "Warehouse Shipment";

    begin

        case RelatedRecRef.Number() of
            Database::"Purchase Line":
                begin
                    RelatedRecRef.SetTable(PurchaseLine);
                    Purchase.SetRange("No.", PurchaseLine."Document No.");
                    Purchase.SetRange("Document Type", PurchaseLine."Document Type");
                    If Purchase.FindFirst() then begin
                        PurchasePage.SetRecord(Purchase);
                        PurchasePage.Run();
                    end;

                end;
            Database::"TFB Container Entry":
                begin
                    RelatedRecRef.SetTable(Container);
                    If not Container.IsEmpty() then begin
                        ContainerPage.SetRecord(Container);
                        ContainerPage.Run();
                    end;

                end;
            Database::"Item Ledger Entry":
                begin
                    RelatedRecRef.SetTable(LedgerEntry);
                    If not LedgerEntry.IsEmpty() then begin
                        LedgerEntryPage.SetTableView(LedgerEntry);
                        LedgerEntryPage.Run();
                    end;

                end;
            Database::"Purchase Header":
                begin
                    RelatedRecRef.SetTable(Purchase);
                    If not Purchase.IsEmpty() then begin
                        PurchasePage.SetRecord(Purchase);
                        PurchasePage.Run();
                    end;
                end;
            Database::"Lot No. Information":
                begin
                    RelatedRecRef.SetTable(LotNoInfo);
                    If not LotNoInfo.IsEmpty() then begin
                        LotNoInfoPage.SetRecord(LotNoInfo);
                        LotNoInfoPage.Run();
                    end;
                end;
            Database::"Warehouse Shipment Line":
                begin
                    RelatedRecRef.SetTable(WhseShipLine);
                    WhseShip.SetRange("No.", WhseShipLine."No.");
                    If WhseShip.FindFirst() then begin

                        WhseShipPage.SetRecord(WhseShip);
                        WhseShipPage.Run();
                    end;


                end;
        end;
    end;

    procedure GetItemSalesLineAvailability(SalesLine: Record "Sales Line"; var AvailInfo: Text[512]; var ShipDatePlanned: Date; var LineStatus: Enum "TFB Sales Line Status"; var RelatedRecRef: RecordRef): Boolean

    var
        DemandResEntry: Record "Reservation Entry";
        SupplyResEntry: Record "Reservation Entry";
        LedgerEntry: Record "Item Ledger Entry";
        LotNoInfo: Record "Lot No. Information";
        Purchase: Record "Purchase Header";
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        Container: Record "TFB Container Entry";
        WhseShptLine: Record "Warehouse Shipment Line";

        Status: Text[512];
        DeliverySLA: TExt;


    begin

        SalesLine.CalcFields("Whse. Outstanding Qty.");

        If SalesLine."Qty. Shipped (Base)" = 0 then

            //Check if drop ship

            if not SalesLine."Drop Shipment" then

                //Check if anything is scheduled on warehouse shipment

                if SalesLine."Whse. Outstanding Qty." = 0 then begin

                    //Provide details of warehouse shipment
                    Status := 'Planned for dispatch';
                    SalesLine.CalcFields("Reserved Qty. (Base)");
                    If SalesLine."Reserved Qty. (Base)" = SalesLine."Outstanding Qty. (Base)" then begin

                        DemandResEntry.SetRange("Source ID", SalesLine."Document No.");
                        DemandResEntry.SetRange("Source Ref. No.", SalesLine."Line No.");
                        DemandResEntry.SetRange("Item No.", SalesLine."No.");
                        DemandResEntry.SetRange(Positive, false);

                        If DemandResEntry.FindFirst() then begin

                            SupplyResEntry.SetRange(Positive, true);
                            SupplyResEntry.SetRange("Entry No.", DemandResEntry."Entry No.");

                            If SupplyResEntry.FindFirst() then
                                case SupplyResEntry."Source Type" of
                                    32: //Item Ledger Entry

                                        If LedgerEntry.Get(SupplyResEntry."Source Ref. No.") then begin

                                            Status += StrSubstNo(' from stock already in inventory');
                                            LineStatus := LineStatus::ReservedFromStock;
                                            RelatedRecRef.GetTable(LedgerEntry);

                                            LotNoInfo.SetRange("Item No.", LedgerEntry."Item No.");
                                            LotNoInfo.SetRange("Lot No.", LedgerEntry."Lot No.");
                                            LotNoInfo.SetRange("Variant Code", LedgerEntry."Variant Code");


                                            If LotNoInfo.FindFirst() then
                                                If (LotNoInfo.Blocked = true) and (LotNoInfo."TFB Date Available" > 0D) then begin
                                                    Status += StrSubstNo(' and pending release on %1', LotNoInfo."TFB Date Available");
                                                    LineStatus := LineStatus::ReservedFromStockPendingRelease;
                                                    RelatedRecRef.GetTable(LotNoInfo);

                                                end;

                                        end;

                                    39: //Purchase Order Entry
                                        begin
                                            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                                            PurchaseLine.SetRange("Line No.", SupplyResEntry."Source Ref. No.");
                                            PurchaseLine.SetRange("Document No.", SupplyResEntry."Source ID");

                                            If PurchaseLine.FindFirst() then
                                                case PurchaseLine."TFB Container Entry No." of
                                                    '':
                                                        begin
                                                            Status += StrSubstNo(' based on arrival from local purchase order due into warehouse on %1', purchaseline."Expected Receipt Date");
                                                            LineStatus := LineStatus::ReservedFromLocalPO;
                                                            RelatedRecRef.GetTable(PurchaseLine);
                                                        end;
                                                    else
                                                        If Container.Get(PurchaseLine."TFB Container Entry No.") then begin
                                                            RelatedRecRef.GetTable(Container);
                                                            case Container.Status of

                                                                Container.Status::Planned:
                                                                    begin

                                                                        Status += StrSubstNo(' based on planned overseas container due for arrival on %1 and estimated to be available on %2', Container."Est. Arrival Date", Container."Est. Warehouse");
                                                                        LineStatus := LineStatus::ReservedFromPlannedContainer;

                                                                    end;
                                                                Container.Status::ShippedFromPort:
                                                                    begin
                                                                        Status += StrSubstNo(' based on shipped container %1, due for arrival on %2 and estimated to be available on %3', Container."Container No.", Container."Est. Arrival Date", Container."Est. Warehouse");
                                                                        LineStatus := LineStatus::ReservedFromInboundContainer;
                                                                    end;
                                                                Container.Status::PendingFumigation:
                                                                    begin
                                                                        Status += StrSubstNo(' based on container that arrived on %1.', Container."Arrival Date");
                                                                        If Container."Fumigation Req." then
                                                                            Status += ' Fumigation Currently In Progress.';
                                                                        If Container."Inspection Req." or Container."IFIP Req." then
                                                                            Status += ' Inspection Req.';

                                                                        LineStatus := LineStatus::ReservedFromArrivedContainer;
                                                                    end;
                                                                Container.Status::PendingClearance:
                                                                    begin
                                                                        Status += StrSubstNo(' based on container that arrived on %1.', Container."Arrival Date");
                                                                        If Container."Fumigation Req." then
                                                                            Status += ' Fumigation Complete.';
                                                                        If Container."Inspection Req." or Container."IFIP Req." then
                                                                            If Container."Inspection Date" > 0D then
                                                                                Status += StrSubstNo(' Inspection Booked On %1.', Container."Inspection Date")
                                                                            else
                                                                                Status += ' Still Waiting for Inspection Date to Be Booked';

                                                                        LineStatus := LineStatus::ReservedFromArrivedContainer;
                                                                    end;
                                                            end;
                                                        end;
                                                end;
                                        end;
                                end;
                        end;

                    end;
                    //Get reservation entries for this line
                end
                //Get Location of reservation

                else begin

                    WhseShptLine.SetRange("Source Document", WhseShptLine."Source Document"::"Sales Order");
                    WhseShptLine.SetRange("Source No.", SalesLine."Document No.");
                    WhseShptLine.SetRange("Source Line No.", SalesLine."Line No.");

                    if WhseShptLine.FindFirst() then begin
                        ShipDatePlanned := WhseShptLine."Shipment Date";
                        LineStatus := LineStatus::SentToWarehouse;
                        Status := StrSubstNo('Being prepared by warehouse for dispatch on %1', WhseShptLine."Shipment Date");
                        RelatedRecRef.GetTable(WhseShptLine);

                    end;
                end
            else begin
                //Get Vendor Details
                Clear(PurchaseLine);
                Purchase.SetRange("Document Type", Purchase."Document Type"::Order);
                Purchase.SetRange("No.", SalesLine."Purchase Order No.");
                PurchaseLine.SetRange("Document No.", SalesLine."Purchase Order No.");
                PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SetRange("Line No.", SalesLine."Purch. Order Line No.");

                If Purchase.FindFirst() and PurchaseLine.FindFirst() then begin
                    If Purchase."TFB Delivery SLA" = '' then begin
                        Vendor.Get(Purchase."Buy-from Vendor No.");
                        DeliverySLA := Vendor."TFB Delivery SLA"
                    end
                    else
                        DeliverySLA := Purchase."TFB Delivery SLA";

                    Status := StrSubstNo('Confirmed by %1 for drop-ship on %2 with SLA of %3', Purchase."Buy-from Vendor Name", PurchaseLine."Planned Receipt Date", DeliverySLA);
                    LineStatus := LineStatus::ConfirmedByDropShipSupplier;
                    RelatedRecRef.GetTable(Purchase);
                end else begin
                    Status := 'Pending confirmation for drop-ship';
                    LineStatus := LineStatus::NotConfirmedByDropShipSupplier;
                    RelatedRecRef.gettable(SalesLine);
                end;
            end
        else

            If SalesLine."Qty. Shipped (Base)" < SalesLine."Quantity (Base)" then begin

                //Partially Shipped

                Status := format(SalesLine."Qty. Shipped (Base)") + ' already shipped. Remainder planned for dispatch.';
                LineStatus := LineStatus::ShippedPendingInvoice;
            end

            else

                //Fully Shipped
                If SalesLine."Qty. Invoiced (Base)" = SalesLine."Qty. Shipped (Base)" then begin
                    Status := 'Shipped and invoiced';
                    LineStatus := LineStatus::ShippedPendingInvoice;

                end
                else begin
                    Status := 'Shipped, but pending invoicing';
                    LineStatus := LineStatus::ShippedPendingInvoice;
                end;

        AvailInfo := Status;
        If LineStatus.AsInteger() > 0 then exit(true) else exit(false);


    end;

}
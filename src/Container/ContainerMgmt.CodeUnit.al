/// <summary>
/// Codeunit TFB Container Mgmt (ID 50200).
/// </summary>
codeunit 50200 "TFB Container Mgmt"
{

    /// <summary> 
    /// Description for GetContainerContents.
    /// </summary>
    /// <param name="Contents">Parameter of type record "TFB ContainerContents" temporary.</param>
    /// <param name="ContainerEntry">Parameter of type Record "TFB Container Entry".</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure GetContainerContents(var Contents: record "TFB ContainerContents" temporary; ContainerEntry: Record "TFB Container Entry"): Boolean

    var

    begin

        Contents.DeleteAll();
        ContainerEntry.CalcFields("Qty. On Purch. Rcpt", "Qty. On Transfer Ship.", "Qty. On Transfer Rcpt", "Qty. On Transfer Order");

        if not ContainerEntry.IsEmpty() then
            case ContainerEntry.Type of


                ContainerEntry.Type::"PurchaseOrder":

                    if ContainerEntry."Qty. On Transfer Rcpt" > 0 then
                        PopulateTransferLines(ContainerEntry, Contents)
                    else
                        if ContainerEntry."Qty. On Transfer Ship." > 0 then
                            PopulateTransferLines(ContainerEntry, Contents)
                        else
                            if ContainerEntry."Qty. On Transfer Order" > 0 then
                                PopulateTransferLines(ContainerEntry, Contents)
                            else
                                if ContainerENtry."Qty. On Purch. Rcpt" > 0 then
                                    PopulateReceiptLines(ContainerEntry, Contents)
                                else
                                    PopulateOrderOrderLines(ContainerEntry, Contents);


            end;

    end;

    /// <summary> 
    /// Description for GetContainerCoAStream.
    /// </summary>
    /// <param name="ContainerEntry">Parameter of type Record "TFB ContainerContents" temporary.</param>
    /// <param name="TempBlob">Parameter of type CodeUnit "Temp Blob".</param>
    /// <param name="FileName">Parameter of type Text.</param>
    /// <returns>Return variable "Boolean".</returns>

    procedure GetWarehouseLocation(ContainerEntry: Record "TFB Container Entry"): Record Location

    var


    begin

        if not ContainerEntry.IsEmpty() then begin

            ContainerEntry.CalcFields("Qty. On Transfer Rcpt", "Qty. On Transfer Ship.", "Qty. On Transfer Order", "Qty. On Purch. Rcpt");
            case ContainerEntry.Type of


                ContainerEntry.Type::"PurchaseOrder":

                    if ContainerEntry."Qty. On Transfer Rcpt" > 0 then
                        exit(GetLocationByDocumentType(ContainerEntry, Database::"Transfer Receipt Line"))
                    else
                        if ContainerEntry."Qty. On Transfer Ship." > 0 then
                            exit(GetLocationByDocumentType(ContainerEntry, Database::"Transfer Shipment Line"))
                        else
                            if ContainerEntry."Qty. On Transfer Order" > 0 then
                                exit(GetLocationByDocumentType(ContainerEntry, Database::"Transfer Line"))
                            else
                                if ContainerENtry."Qty. On Purch. Rcpt" > 0 then
                                    exit(GetLocationByDocumentType(ContainerEntry, Database::"Purch. Rcpt. Line"))
                                else
                                    exit(GetLocationByDocumentType(ContainerEntry, Database::"Purchase Line"))


            end;
        end;

    end;

    local procedure GetLocationByDocumentType(ContainerEntry: Record "TFB Container Entry"; Table: Integer): Record Location

    var
        Location: Record Location;
        PurchaseLine: Record "Purchase Line";
        ReceiptLine: Record "Purch. Rcpt. Line";
        TransferLine: Record "Transfer Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferReceiptLine: Record "Transfer Receipt Line";

    begin

        case Table of
            Database::"Purchase Line":
                begin

                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                    PurchaseLine.SetRange("Document No.", ContainerEntry."Order Reference");
                    PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                    if PurchaseLine.FindFirst() and Location.Get(PurchaseLine."Location Code") then
                        exit(Location);
                end;

            Database::"Transfer Line":
                begin

                    TransferLine.SetRange("TFB Container Entry No.", ContainerEntry."Vendor No.");
                    TransferLine.SetFilter(Quantity, '>0');


                    if TransferLine.FindFirst() and Location.Get(TransferLine."Transfer-to Code") then
                        exit(Location);
                end;

            Database::"Transfer Shipment Line":
                begin

                    TransferShipmentLine.SetRange("TFB Container Entry No.", ContainerEntry."No.");
                    TransferShipmentLine.SetFilter(Quantity, '>0');

                    if TransferShipmentLine.FindFirst() and Location.Get(TransferShipmentLine."Transfer-to Code") then
                        exit(Location);

                end;
            Database::"Transfer Receipt Line":
                begin

                    TransferReceiptLine.SetRange("TFB Container Entry No.", ContainerEntry."No.");
                    TransferReceiptLine.SetFilter(Quantity, '>0');

                    if TransferReceiptLine.FindFirst() and Location.Get(TransferReceiptLine."Transfer-to Code") then
                        exit(Location);

                end;
            Database::"Purch. Rcpt. Line":
                begin

                    ReceiptLine.SetRange("Order No.", ContainerEntry."Order Reference");
                    ReceiptLine.SetRange(Type, ReceiptLine.Type::Item);
                    ReceiptLine.SetFilter(Quantity, '>0');

                    //Get Header Defaults and Calculate Totals
                    if ReceiptLine.FindFirst() and Location.Get(ReceiptLine."Location Code") then
                        exit(Location);

                end;

        end;
    end;

    procedure UpdateLotInfoWithInspectionStatus(ContainerEntry: Record "TFB Container Entry"; Inspected: Boolean)

    var
        ReceiptLine: Record "Purch. Rcpt. Line";
        ResEntry: Record "Reservation Entry";
        OrderLine: Record "Purchase Line";
        TempContainerContents: Record "TFB ContainerContents" temporary;
        LotInfo: Record "Lot No. Information";
        ItemLedger: Record "Item Ledger Entry";


        RecRef: RecordRef;

        LineLotNo: Text;


    begin
        GetContainerContents(TempContainerContents, ContainerEntry);
        if TempContainerContents.FindSet() then
            repeat
                Clear(LineLotNo);

                case TempContainerContents."Link Type" of
                    TempContainerContents."Link Type"::"Purchase Order Receipt":
                        begin
                            RecRef.GetTable(ReceiptLine);

                            ReceiptLine.SetRange("Order No.", TempContainerContents.OrderReference);
                            ReceiptLine.SetRange("Order Line No.", TempContainerContents.LineNo);
                            ReceiptLine.SetFilter("Quantity (Base)", '>%1', 0);

                            if ReceiptLine.FindFirst() then begin

                                ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Purchase);
                                ItemLedger.SetRange("Document No.", ReceiptLine."Document No.");
                                ItemLedger.SetRange("Document Line No.", ReceiptLine."Line No.");

                                if ItemLedger.FindFirst() then

                                    //Get Lot No
                                    LineLotNo := ItemLedger."Lot No.";

                            end;





                        end;

                    TempContainerContents."Link Type"::"Purchase Order":
                        begin
                            RecRef.GetTable(OrderLine);
                            ResEntry.SetFilter("Reservation Status", '%1|%2', ResEntry."Reservation Status"::Surplus, ResEntry."Reservation Status"::Reservation);
                            ResEntry.SetRange("Source ID", TempContainerContents.OrderReference);
                            ResEntry.SetRange("Source Ref. No.", TempContainerContents.LineNo);
                            ResEntry.SetFilter("Quantity (Base)", '>0');
                            ResEntry.SetRange("Source Type", RecRef.Number());
                            ResEntry.SetRange("Item No.", TempContainerContents."Item Code");
                            ResEntry.SetFilter("Lot No.", '<>%1', '');

                            if ResEntry.FindFirst() then

                                //Get Lot No
                                LineLotNo := ResEntry."Lot No.";

                        end;


                end;


                if LineLotNo <> '' then begin

                    //Get Lot Info 
                    LotInfo.SetRange("Lot No.", LineLotNo);
                    LotInfo.SetRange("Item No.", TempContainerContents."Item Code");

                    if LotInfo.FindFirst() then begin

                        if Inspected then
                            LotInfo.Validate(Blocked, false)
                        else begin
                            LotInfo.Blocked := true;
                            if ContainerEntry."Inspection Date" = 0D then
                                LotInfo."TFB Date Available" := CalcDate('<-1D>', ContainerEntry."Est. Warehouse")
                            else
                                LotInfo."TFB Date Available" := ContainerEntry."Inspection Date";
                        end;

                        LotInfo.Modify(true);

                    end;
                end;





            until TempContainerContents.Next() < 1;


    end;

    procedure GetContainerCoAStream(ContainerEntry: Record "TFB Container Entry"; var TempBlob: CodeUnit "Temp Blob"; var FileName: Text; var FileType: Text): Boolean

    var
        ReceiptLine: Record "Purch. Rcpt. Line";
        ResEntry: Record "Reservation Entry";
        OrderLine: Record "Purchase Line";
        TempLines: Record "TFB ContainerContents" temporary;
        LotNoInformation: Record "Lot No. Information";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TempBlobList: CodeUnit "Temp Blob List";
        TempBlobCu: CodeUnit "Temp Blob";
        PersBlobCU: CodeUnit "Persistent Blob";
        ZipTempBlob: CodeUnit "Temp Blob";
        DataCompCU: CodeUnit "Data Compression";
        RecRef: RecordRef;
        FileNameList: List of [Text];
        FileNameBuilder: TextBuilder;
        OrderNo: Text;
        Instream: InStream;
        OutStream: Outstream;

        LineLotNo: Text;
        i: Integer;



    begin
        GetContainerContents(TempLines, ContainerEntry);
        if TempLines.FindSet() then
            repeat
                Clear(LineLotNo);
                OrderNo := TempLines.OrderReference;
                case TempLines."Link Type" of
                    TempLines."Link Type"::"Purchase Order Receipt":
                        begin
                            RecRef.GetTable(ReceiptLine);

                            ReceiptLine.SetRange("Order No.", TempLines.OrderReference);
                            ReceiptLine.SetRange("Order Line No.", TempLines.LineNo);
                            ReceiptLine.SetFilter("Quantity (Base)", '>%1', 0);

                            if ReceiptLine.FindFirst() then begin

                                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Purchase);
                                ItemLedgerEntry.SetRange("Document No.", ReceiptLine."Document No.");
                                ItemLedgerEntry.SetRange("Document Line No.", ReceiptLine."Line No.");

                                if ItemLedgerEntry.FindFirst() then

                                    //Get Lot No
                                    LineLotNo := ItemLedgerEntry."Lot No.";
                            end;





                        end;

                    TempLines."Link Type"::"Purchase Order":
                        begin
                            RecRef.GetTable(OrderLine);
                            ResEntry.SetFilter("Reservation Status", '%1|%2', ResEntry."Reservation Status"::Surplus, ResEntry."Reservation Status"::Reservation);
                            ResEntry.SetRange("Source ID", TempLines.OrderReference);
                            ResEntry.SetRange("Source Ref. No.", TempLines.LineNo);
                            ResEntry.SetFilter("Quantity (Base)", '>0');
                            ResEntry.SetRange("Source Type", RecRef.Number());
                            ResEntry.SetRange("Item No.", TempLines."Item Code");
                            ResEntry.SetFilter("Lot No.", '<>%1', '');

                            if ResEntry.FindFirst() then

                                //Get Lot No
                                LineLotNo := ResEntry."Lot No.";

                        end;


                end;


                if LineLotNo <> '' then begin

                    //Get Lot Info 
                    LotNoInformation.SetRange("Lot No.", LineLotNo);
                    LotNoInformation.SetRange("Item No.", TempLines."Item Code");

                    if LotNoInformation.FindFirst() then begin

                        RecRef.GetTable(LotNoInformation);
                        TempBlobCu.CreateInStream(InStream);
                        TempBlobCu.CreateOutStream(OutStream);
                        PersBlobCU.CopyToOutStream(LotNoInformation."TFB CoA Attach.", OutStream);
                        CopyStream(OutStream, InStream);

                        if TempBlobCu.HasValue() then begin
                            TempBlobList.Add(TempBlobCu);
                            clear(FileNameBuilder);
                            FileNameBuilder.Append('COA_');
                            FileNameBuilder.Append(TempLines."Item Code");
                            FileNameBuilder.Append('_');
                            FileNameBuilder.Append(LineLotNo);
                            FileNameBuilder.Append('.pdf');
                            FileNameList.Add(FileNameBuilder.ToText());
                            FileType := 'Application/pdf';
                        end;
                    end;


                end;


            until TempLines.Next() < 1;


        case TempBlobList.Count() of
            0:
                Dialog.Message('No CoA to Download');
            1:
                begin
                    TempBlobList.Get(1, TempBlobCu);
                    TempBlob := TempBlobCu;
                    FileName := FileNameList.Get(1);

                end;

            else begin

                DataCompCU.CreateZipArchive();

                for i := 1 to TempBlobList.Count() do begin
                    TempBlobList.Get(i, TempBlobCu);
                    TempBlobCu.CreateInStream(InStream);
                    FileName := FileNameList.Get(i);
                    DataCompCU.AddEntry(InStream, FileName);

                end;

                DataCompCU.SaveZipArchive(ZipTempBlob);
                TempBlob := ZipTempBlob;
                FileType := 'Application/zip';
                FileName := StrSubstNo('CoAs for %1.zip', OrderNo);
            end;
        end;




    end;

    procedure DownloadContainerCoA(var Lines: Record "TFB ContainerContents" temporary)

    var

        ReceiptLine: Record "Purch. Rcpt. Line";
        ResEntry: Record "Reservation Entry";
        OrderLine: Record "Purchase Line";
        LotInfo: Record "Lot No. Information";
        ItemLedger: Record "Item Ledger Entry";
        TempBlobList: CodeUnit "Temp Blob List";
        TempBlobCu: CodeUnit "Temp Blob";
        PersBlobCU: CodeUnit "Persistent Blob";
        ZipTempBlob: CodeUnit "Temp Blob";
        DataCompCU: CodeUnit "Data Compression";
        RecRef: RecordRef;
        FileNameList: List of [Text];
        FileNameBuilder: TextBuilder;
        OrderNo: Text;
        FileName: Text;
        InStream: InStream;
        OutStream: Outstream;

        LineLotNo: Text;
        i: Integer;



    begin

        if Lines.FindSet() then
            repeat
                Clear(LineLotNo);
                OrderNo := Lines.OrderReference;
                case Lines."Link Type" of
                    Lines."Link Type"::"Purchase Order Receipt":
                        begin
                            RecRef.GetTable(ReceiptLine);

                            ReceiptLine.SetRange("Order No.", Lines.OrderReference);
                            ReceiptLine.SetRange("Order Line No.", Lines.LineNo);
                            ReceiptLine.SetFilter("Quantity (Base)", '>%1', 0);

                            if ReceiptLine.FindFirst() then begin

                                ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Purchase);
                                ItemLedger.SetRange("Document No.", ReceiptLine."Document No.");
                                ItemLedger.SetRange("Document Line No.", ReceiptLine."Line No.");

                                if ItemLedger.FindFirst() then

                                    //Get Lot No
                                    LineLotNo := ItemLedger."Lot No.";
                            end;





                        end;

                    Lines."Link Type"::"Purchase Order":
                        begin
                            RecRef.GetTable(OrderLine);
                            ResEntry.SetFilter("Reservation Status", '%1|%2', ResEntry."Reservation Status"::Surplus, ResEntry."Reservation Status"::Reservation);
                            ResEntry.SetRange("Source ID", Lines.OrderReference);
                            ResEntry.SetRange("Source Ref. No.", Lines.LineNo);
                            ResEntry.SetFilter("Quantity (Base)", '>0');
                            ResEntry.SetRange("Source Type", RecRef.Number());
                            ResEntry.SetRange("Item No.", Lines."Item Code");
                            ResEntry.SetFilter("Lot No.", '<>%1', '');

                            if ResEntry.FindFirst() then

                                //Get Lot No
                                LineLotNo := ResEntry."Lot No.";

                        end;


                end;


                if LineLotNo <> '' then begin

                    //Get Lot Info 
                    LotInfo.SetRange("Lot No.", LineLotNo);
                    LotInfo.SetRange("Item No.", Lines."Item Code");

                    if LotInfo.FindFirst() then begin

                        RecRef.GetTable(LotInfo);
                        TempBlobCu.CreateInStream(InStream);
                        TempBlobCu.CreateOutStream(OutStream);
                        PersBlobCU.CopyToOutStream(LotInfo."TFB CoA Attach.", OutStream);
                        CopyStream(OutStream, InStream);

                        if TempBlobCu.HasValue() then begin
                            TempBlobList.Add(TempBlobCu);
                            clear(FileNameBuilder);
                            FileNameBuilder.Append('COA_');
                            FileNameBuilder.Append(Lines."Item Code");
                            FileNameBuilder.Append('_');
                            FileNameBuilder.Append(LineLotNo);
                            FileNameBuilder.Append('.pdf');
                            FileNameList.Add(FileNameBuilder.ToText());

                        end;
                    end;


                end;


            until Lines.Next() < 1;


        case TempBlobList.Count() of
            0:
                Dialog.Message('No CoA to Download');
            1:
                begin
                    TempBlobList.Get(1, TempBlobCu);
                    TempBlobCu.CreateInStream(InStream);
                    FileName := FileNameList.Get(1);
                    if not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
                        Error('File %1 not downloaded', FileName);
                end;

            else begin

                DataCompCU.CreateZipArchive();

                for i := 1 to TempBlobList.Count() do begin
                    TempBlobList.Get(i, TempBlobCu);
                    TempBlobCu.CreateInStream(InStream);
                    FileName := FileNameList.Get(i);
                    DataCompCU.AddEntry(InStream, FileName);

                end;

                DataCompCU.SaveZipArchive(ZipTempBlob);
                ZipTempBlob.CreateInStream(InStream);
                FileName := StrSubstNo('CoAs for %1.zip', OrderNo);
                if not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
                    Error('File %1 not downloaded', FileName);
            end;
        end;






    end;




    procedure UpdateTransferHeader(var TransferHeader: Record "Transfer Header"; ContainerEntryNo: Code[20]): Boolean

    var
        ContainerEntry: record "TFB Container Entry";

    begin

        if ContainerEntry.get(ContainerEntryNo) then begin

            TransferHeader."Shipment Date" := ContainerEntry."Est. Departure Date";
            TransferHeader."Receipt Date" := ContainerEntry."Est. Warehouse";
            TransferHeader."Shipping Agent Code" := CopyStr(ContainerEntry."Shipping Line", 1, 10);
            TransferHeader."Shipping Advice" := TransferHeader."Shipping Advice"::Complete;
            TransferHeader."TFB Order Reference" := ContainerEntry."Order Reference";

        end;
    end;

    procedure CheckForOrderReceiptLines(OrderNo: Code[20]; var ReceiptNo: Code[20]): Boolean

    var

        //Check to see whether container has been received
        ReceiptLine: Record "Purch. Rcpt. Line";

    begin

        ReceiptLine.SetRange("Order No.", OrderNo);
        ReceiptLine.SetRange(Type, ReceiptLine.Type::Item);

        if ReceiptLine.FindFirst() then begin
            ReceiptNo := ReceiptLine."Document No.";
            exit(true);
        end
        else
            exit(false);

    end;

    procedure CheckForOpenOrderLines(OrderNo: Code[20]): Boolean

    var
        PurchaseLine: Record "Purchase Line";


    begin
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", orderNo);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("Qty. Received (Base)", 0);

        if PurchaseLine.IsEmpty() then
            exit(true)
        else
            exit(false);

    end;

    procedure CheckForTransferStatus(ContainerEntryNo: Code[20]; var ContainerStatus: Enum "TFB Container Status"; var TransferNo: Code[20]; var PstdTransferShptNo: Code[20]; var PstdTransferRcptNo: Code[20]): Boolean

    var
        TransferLine: Record "Transfer Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferReceiptLine: Record "Transfer Receipt Line";


    begin
        TransferLine.SetRange("TFB Container Entry No.", ContainerEntryNo);

        if TransferLine.FindFirst() then begin

            //Check Status
            if TransferLine."Quantity Shipped" > 0 then begin

                TransferNo := TransferLine."Document No.";

                TransferShipmentLine.SetRange("Transfer Order No.", TransferNo);
                TransferShipmentLine.SetFilter(Quantity, '>0');
                if TransferShipmentLine.FindFirst() then
                    PstdTransferShptNo := TransferShipmentLine."Document No.";
            end
            else
                TransferNo := TransferLine."Document No.";

            exit(true); //Check Status to be positive
        end
        else begin

            //Check for posted shipment

            TransferShipmentLine.SetRange("TFB Container Entry No.", ContainerEntryNo);
            TransferShipmentLine.SetFilter(Quantity, '>0');
            TransferReceiptLine.SetRange("TFB Container Entry No.", ContainerEntryNo);
            TransferReceiptLine.SetFilter(Quantity, '>0');

            if TransferShipmentLine.FindFirst() then begin

                if TransferReceiptLine.FindFirst() then begin

                    PstdTransferShptNo := TransferShipmentLine."Document No.";
                    PstdTransferRcptNo := TransferReceiptLine."Document No.";
                    TransferNo := TransferReceiptLine."Transfer Order No.";
                end
                else
                    PstdTransferShptNo := TransferShipmentLine."Document No.";
                exit(true);
            end
            else
                exit(false);



        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document-Mailing", 'OnBeforeGetAttachmentFileName', '', false, false)]
    local procedure OnBeforeDeliverEmailWithAttachment(ReportUsage: Integer; EmailDocumentName: Text[250]; PostedDocNo: Code[20]; var AttachmentFileName: Text[250]);
    begin

        case ReportUsage of
            Enum::"Report Selection Usage"::"P.Inbound.Shipment.Warehouse".AsInteger():
                AttachmentFileName := StrSubstNo('Container Entry %1.pdf', PostedDocNo);
        end;
    end;

    procedure GetPurchaseReceiptNo(Container: Record "TFB Container Entry"): Code[20]

    var

        PurchaseReceipt: record "Purch. Rcpt. Line";

    begin

        PurchaseReceipt.SetRange("TFB Container Entry No.", Container."Container No.");

        if PurchaseReceipt.FindFirst() then
            exit(PurchaseReceipt."Document No.");

    end;




    procedure CheckForPlannedTransferStatus(ContainerEntryNo: Code[20]; var ContainerStatus: Enum "TFB Container Status"; var TransferNo: Code[20]): Boolean

    var
        TransferHeader: Record "Transfer Header";


    begin
        TransferHeader.SetRange("TFB Container Entry No.", ContainerEntryNo);

        if TransferHeader.FindFirst() then begin

            //Check Status

            TransferNo := TransferHeader."No.";
            exit(true); //Check Status to be positive
        end

    end;

    procedure PopulateOrderOrderLines(ContainerEntry: record "TFB Container Entry"; var Lines: Record "TFB ContainerContents" temporary): Boolean

    var
        PurchaseLine: Record "Purchase Line";
        LandedCostProfile: Record "TFB Landed Cost Profile";
        Vendor: Record Vendor;
        CodePricing: Codeunit "TFB Pricing Calculations";
        TempPriceUnit: Enum "TFB Price Unit";

        TempEstAlloc: Decimal;
        TempLineAlloc: Decimal;
        TempLineUnitAlloc: Decimal;
        TempTotal: Decimal;



    begin

        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", ContainerEntry."Order Reference");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);

        //Get Header Defaults and Calculate Totals
        if not PurchaseLine.IsEmpty() then begin

            if Vendor.Get(PurchaseLine."Buy-from Vendor No.") then
                TempPriceUnit := Vendor."TFB Vendor Price Unit";


            Lines.Reset();
            Lines.DeleteAll();


        end;

        if PurchaseLine.FINDSET() then
            repeat
                Lines."Item Code" := PurchaseLine."No.";
                Lines.OrderReference := ContainerEntry."Order Reference";
                Lines.LineNo := PurchaseLine."Line No.";
                Lines."Item Description" := PurchaseLine.Description;
                Lines.UnitOfMeasure := PurchaseLine."Unit of Measure Code";
                Lines.Quantity := PurchaseLine.Quantity;
                Lines."Unit Cost" := PurchaseLine."Unit Cost";
                Lines."Link Type" := Lines."Link Type"::"Purchase Order";


                Lines."Price Unit" := TempPriceUnit;
                Lines."Price Unit Cost" := CodePricing.CalculatePriceUnitByUnitPrice(PurchaseLine."No.", PurchaseLine."Unit of Measure Code", TempPriceUnit, PurchaseLine."Unit Cost");
                //Error gettig caught in loop on this field.

                // Get Landed Cost Profile
                if LandedCostProfile.get() then begin

                    TempLineUnitAlloc := LandedCostProfile.CalculateCostPerUnit(PurchaseLine."Net Weight");
                    TempLineAlloc := TempLineUnitAlloc * PurchaseLine.Quantity;

                    TempEstAlloc := CodePricing.CalculatePriceUnitByUnitPrice(PurchaseLine."No.", PurchaseLine."Unit of Measure Code", TempPriceUnit, TempLineUnitAlloc);
                    TempTotal := TempEstAlloc + Lines."Price Unit Cost";
                end;

                Lines."Price Unit Alloc." := TempEstAlloc;
                Lines."Price Unit. Incl. Alloc." := TempTotal;
                Lines."Line Allocation" := TempLineAlloc;
                Lines."Line Total" := PurchaseLine.Amount;

                PurchaseLine.CalcFields("Reserved Qty. (Base)");
                Lines."Qty Sold (Base)" := PurchaseLine."Reserved Qty. (Base)";

                Lines.Insert();

            until PurchaseLine.NEXT() = 0;

    end;





    procedure PopulateReceiptLines(ContainerEntry: Record "TFB Container Entry"; var Lines: Record "TFB ContainerContents" temporary): Boolean

    var
        ReceiptLine: Record "Purch. Rcpt. Line";
        LandedCostProfile: Record "TFB Landed Cost Profile";
        Vendor: Record Vendor;
        ItemLedger: Record "Item Ledger Entry";
        CodePricing: Codeunit "TFB Pricing Calculations";
        TempPriceUnit: Enum "TFB Price Unit";

        TempEstAlloc: Decimal;
        TempLineAlloc: Decimal;
        TempLineUnitAlloc: Decimal;
        TempTotal: Decimal;


        LineNo: Integer;


    begin


        ReceiptLine.SetRange("Order No.", ContainerEntry."Order Reference");
        ReceiptLine.SetRange(Type, ReceiptLine.Type::Item);
        ReceiptLine.SetFilter(Quantity, '>0');

        //Get Header Defaults and Calculate Totals
        if not ReceiptLine.IsEmpty() then begin

            if Vendor.Get(ReceiptLine."Buy-from Vendor No.") then
                TempPriceUnit := Vendor."TFB Vendor Price Unit";


            Lines.Reset();
            Lines.DeleteAll();


        end;
        clear(Lines);
        clear(LineNo);
        if ReceiptLine.FindSet() then
            repeat
                LineNo += 10000;
                Lines.Init();
                Lines."Item Code" := ReceiptLine."No.";
                Lines.OrderReference := ContainerEntry."Order Reference";
                Lines.LineNo := LineNo;
                Lines."Item Description" := ReceiptLine.Description;
                Lines.UnitOfMeasure := ReceiptLine."Unit of Measure Code";
                Lines.Quantity := ReceiptLine.Quantity;
                Lines."Unit Cost" := ReceiptLine."Unit Cost";
                Lines."Link Type" := Lines."Link Type"::"Purchase Order Receipt";




                Lines."Price Unit" := TempPriceUnit;
                Lines."Price Unit Cost" := CodePricing.CalculatePriceUnitByUnitPrice(ReceiptLine."No.", ReceiptLine."Unit of Measure Code", TempPriceUnit, ReceiptLine."Unit Cost");
                //Error gettig caught in loop on this field.

                // Get Landed Cost Profile
                if LandedCostProfile.get() then begin

                    TempLineUnitAlloc := LandedCostProfile.CalculateCostPerUnit(ReceiptLine."Net Weight");
                    TempLineAlloc := TempLineUnitAlloc * ReceiptLine.Quantity;

                    TempEstAlloc := CodePricing.CalculatePriceUnitByUnitPrice(ReceiptLine."No.", ReceiptLine."Unit of Measure Code", TempPriceUnit, TempLineUnitAlloc);
                    TempTotal := TempEstAlloc + Lines."Price Unit Cost";
                end;

                Lines."Price Unit Alloc." := TempEstAlloc;
                Lines."Price Unit. Incl. Alloc." := TempTotal;
                Lines."Line Allocation" := TempLineAlloc;
                Lines."Line Total" := ReceiptLine."Unit Cost" * ReceiptLine.Quantity;

                ReceiptLine.FilterPstdDocLnItemLedgEntries(ItemLedger);
                ItemLedger.SetRange("Document Type", ItemLedger."Document Type"::"Purchase Receipt");
                ItemLedger.SetRange("Document No.", ReceiptLine."Document No.");
                ItemLedger.SetRange("Document Line No.", ReceiptLine."Line No.");
                ItemLedger.SetFilter("Remaining Quantity", '>0');
                ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Purchase);
                if ItemLedger.FindSet() then
                    repeat
                        ItemLedger.CalcFields("Reserved Quantity");
                        Lines."Qty Sold (Base)" += ItemLedger."Reserved Quantity";
                    until ItemLedger.Next() < 1;



                Lines.Insert();

            until ReceiptLine.NEXT() = 0;

    end;



    procedure PopulateTransferLines(ContainerEntry: record "TFB Container Entry"; var Lines: Record "TFB ContainerContents" temporary): Boolean


    begin

        if ContainerEntry."Qty. On Transfer Rcpt" > 0 then
            exit(PopulateTransferReceiptLines(ContainerEntry, Lines))
        else
            if ContainerEntry."Qty. On Transfer Ship." > 0 then
                exit(PopulateTransferShipmentLines(ContainerEntry, Lines))
            else
                exit(PopulateTransferOrderLines(ContainerEntry, Lines));

    end;



    procedure PopulateTransferOrderLines(ContainerEntry: Record "TFB Container Entry"; var Lines: Record "TFB ContainerContents" temporary): Boolean

    var

        TransferLine: Record "Transfer Line";


        LandedCostProfile: Record "TFB Landed Cost Profile";
        Vendor: Record Vendor;
        CodePricing: Codeunit "TFB Pricing Calculations";
        TempPriceUnit: Enum "TFB Price Unit";
        TempEstAlloc: Decimal;
        TempLineAlloc: Decimal;
        TempLineUnitAlloc: Decimal;
        TempTotal: Decimal;


    begin

        TransferLine.SetRange("TFB Container Entry No.", ContainerEntry."Vendor No.");
        TransferLine.SetFilter(Quantity, '>0');


        if not TransferLine.IsEmpty() then begin


            if Vendor.Get(ContainerEntry."Vendor No.") then
                TempPriceUnit := Vendor."TFB Vendor Price Unit";

            Lines.Reset();
            Lines.DeleteAll();


        end;

        if TransferLine.FindSet() then
            repeat
                Lines."Item Code" := TransferLine."Item No.";
                Lines.OrderReference := ContainerEntry."Order Reference";
                Lines.LineNo := TransferLine."Line No.";
                Lines."Item Description" := TransferLine.Description;
                Lines.UnitOfMeasure := TransferLine."Unit of Measure Code";
                Lines.Quantity := TransferLine.Quantity;
                Lines."Unit Cost" := 0; //Look to retrieve value
                Lines."Link Type" := Lines."Link Type"::"Transfer Order";

                Lines."Price Unit" := TempPriceUnit;
                //Lines."Price Unit Cost" := CodePricing.CalculatePriceUnitByUnitPrice(TransferLine."No.", TransferLine."Unit of Measure Code", TempPriceUnit, TransferLine."Unit Cost");
                //Look to retrieve value from original receipt

                // Get Landed Cost Profile
                if LandedCostProfile.get() then begin

                    TempLineUnitAlloc := LandedCostProfile.CalculateCostPerUnit(TransferLine."Net Weight");
                    TempLineAlloc := TempLineUnitAlloc * TransferLine.Quantity;

                    TempEstAlloc := CodePricing.CalculatePriceUnitByUnitPrice(TransferLine."Item No.", TransferLine."Unit of Measure Code", TempPriceUnit, TempLineUnitAlloc);
                    TempTotal := TempEstAlloc + Lines."Price Unit Cost";
                end;

                Lines."Price Unit Alloc." := TempEstAlloc;
                Lines."Price Unit. Incl. Alloc." := TempTotal;
                Lines."Line Allocation" := TempLineAlloc;
                Lines."Line Total" := 0; //Look to retrieve value at future point

                Lines.Insert();

            until TransferLine.NEXT() = 0;

    end;


    procedure PopulateTransferShipmentLines(ContainerEntry: Record "TFB Container Entry"; var Lines: Record "TFB ContainerContents" temporary): Boolean

    var

        TransferLine: Record "Transfer Shipment Line";


        LandedCostProfile: Record "TFB Landed Cost Profile";
        Vendor: Record Vendor;
        CodePricing: Codeunit "TFB Pricing Calculations";
        TempPriceUnit: Enum "TFB Price Unit";

        TempEstAlloc: Decimal;
        TempLineAlloc: Decimal;
        TempLineUnitAlloc: Decimal;
        TempTotal: Decimal;


    begin

        TransferLine.SetRange("TFB Container Entry No.", ContainerEntry."No.");
        TransferLine.SetFilter(Quantity, '>0');

        if not TransferLine.IsEmpty() then begin


            if Vendor.Get(ContainerEntry."Vendor No.") then
                TempPriceUnit := Vendor."TFB Vendor Price Unit";

            Lines.Reset();
            Lines.DeleteAll();


        end;

        if TransferLine.FindSet() then
            repeat
                Lines."Item Code" := TransferLine."Item No.";
                Lines.OrderReference := ContainerEntry."Order Reference";
                Lines.LineNo := TransferLine."Line No.";
                Lines."Item Description" := TransferLine.Description;
                Lines.UnitOfMeasure := TransferLine."Unit of Measure Code";
                Lines.Quantity := TransferLine.Quantity;
                Lines."Unit Cost" := 0; //Look to retrieve value


                Lines."Price Unit" := TempPriceUnit;
                //Lines."Price Unit Cost" := CodePricing.CalculatePriceUnitByUnitPrice(TransferLine."No.", TransferLine."Unit of Measure Code", TempPriceUnit, TransferLine."Unit Cost");
                //Look to retrieve value from original receipt

                // Get Landed Cost Profile
                if LandedCostProfile.get() then begin

                    TempLineUnitAlloc := LandedCostProfile.CalculateCostPerUnit(TransferLine."Net Weight");
                    TempLineAlloc := TempLineUnitAlloc * TransferLine.Quantity;

                    TempEstAlloc := CodePricing.CalculatePriceUnitByUnitPrice(TransferLine."Item No.", TransferLine."Unit of Measure Code", TempPriceUnit, TempLineUnitAlloc);
                    TempTotal := TempEstAlloc + Lines."Price Unit Cost";
                end;

                Lines."Price Unit Alloc." := TempEstAlloc;
                Lines."Price Unit. Incl. Alloc." := TempTotal;
                Lines."Line Allocation" := TempLineAlloc;
                Lines."Line Total" := 0; //Look to retrieve value at future point

                Lines.Insert();

            until TransferLine.NEXT() = 0;

    end;

    procedure PopulateTransferReceiptLines(ContainerEntry: Record "TFB Container Entry"; var Lines: Record "TFB ContainerContents" temporary): Boolean

    var

        TransferLine: Record "Transfer Receipt Line";


        LandedCostProfile: Record "TFB Landed Cost Profile";
        Vendor: Record Vendor;
        CodePricing: Codeunit "TFB Pricing Calculations";
        TempPriceUnit: Enum "TFB Price Unit";

        TempEstAlloc: Decimal;
        TempLineAlloc: Decimal;
        TempLineUnitAlloc: Decimal;
        TempTotal: Decimal;

        LineNo: Integer;

    begin

        TransferLine.SetRange("TFB Container Entry No.", ContainerEntry."No.");
        TransferLine.SetFilter(Quantity, '>0');

        if not TransferLine.IsEmpty() then begin


            if Vendor.Get(ContainerEntry."Vendor No.") then
                TempPriceUnit := Vendor."TFB Vendor Price Unit";

            Lines.Reset();
            Lines.DeleteAll();
            LineNo := 10000;


        end;

        if TransferLine.FindSet() then
            repeat

                Lines."Item Code" := TransferLine."Item No.";
                Lines.OrderReference := ContainerEntry."Order Reference";
                Lines.LineNo := LineNo;
                Lines."Item Description" := TransferLine.Description;
                Lines.UnitOfMeasure := TransferLine."Unit of Measure Code";
                Lines.Quantity := TransferLine.Quantity;
                Lines."Unit Cost" := 0; //Look to retrieve value
                Lines."Link Type" := Lines."Link Type"::"Transfer Receipt";




                Lines."Price Unit" := TempPriceUnit;


                // Get Landed Cost Profile
                if LandedCostProfile.get() then begin

                    TempLineUnitAlloc := LandedCostProfile.CalculateCostPerUnit(TransferLine."Net Weight");
                    TempLineAlloc := TempLineUnitAlloc * TransferLine.Quantity;

                    TempEstAlloc := CodePricing.CalculatePriceUnitByUnitPrice(TransferLine."Item No.", TransferLine."Unit of Measure Code", TempPriceUnit, TempLineUnitAlloc);
                    TempTotal := TempEstAlloc + Lines."Price Unit Cost";
                end;

                Lines."Price Unit Alloc." := TempEstAlloc;
                Lines."Price Unit. Incl. Alloc." := TempTotal;
                Lines."Line Allocation" := TempLineAlloc;
                Lines."Line Total" := 0; //Look to retrieve value at future point

                Lines.Insert();
                LineNo += 10000;

            until TransferLine.NEXT() = 0;

    end;

    procedure PopulateBrokerageLines(OrderNo: Code[20]; var Lines: Record "TFB ContainerContents" temporary): Boolean

    var
        BrokerageLine: Record "TFB Brokerage Shipment Line";
        Vendor: Record Vendor;
        Item: Record Item;
        CodePricing: Codeunit "TFB Pricing Calculations";

        LineNo: Integer;

    begin

        Lines.Reset();
        Lines.DeleteAll();


        BrokerageLine.SetRange("Document No.", OrderNo);

        LineNo := 10000;


        if BrokerageLine.FIND('-') then
            repeat

                Lines."Item Code" := BrokerageLine."Item No.";
                Item.Get(BrokerageLine."Item No.");
                /*                If Shipment.Get(BrokerageLine."Document No.") then begin

                                   BuyFromVendorNo := Shipment."Buy From Vendor No.";
                                   Vendor.get(BuyFromVendorNo);
                               end; */
                Lines.OrderReference := OrderNo;
                Lines.LineNo := LineNo;
                Lines."Item Description" := BrokerageLine.Description;
                Lines.UnitOfMeasure := Item."Base Unit of Measure";
                Lines.Quantity := BrokerageLine.Quantity;
                Lines."Unit Cost" := 0;


                Lines."Price Unit" := Vendor."TFB Vendor Price Unit"::MT;
                Lines."Price Unit Cost" := BrokerageLine."Agreed Price";

                CodePricing.CalculateUnitPriceByPriceUnit(BrokerageLine."Item No.", Item."Base Unit of Measure", Lines."Price Unit", BrokerageLine."Agreed Price");


                Lines."Price Unit Alloc." := 0;
                Lines."Price Unit. Incl. Alloc." := 0;
                Lines."Line Allocation" := 0;
                Lines."Line Total" := BrokerageLine.Amount;

                Lines.Insert();

                LineNo := LineNo + 10000;

            until BrokerageLine.NEXT() = 0;


    end;



    procedure GetArrivalDate(TransferReceiptNo: Code[20]): Date

    var
        Receipt: Record "Transfer Receipt Header";

    begin

        Receipt.SetRange("No.", TransferReceiptNo);

        if Receipt.FindFirst() then
            exit(Receipt."Receipt Date");

    end;

    procedure GetDepartureDate(TransferShipmentNo: Code[20]): Date

    var
        Receipt: Record "Transfer Shipment Header";

    begin

        Receipt.SetRange("No.", TransferShipmentNo);

        if Receipt.FindFirst() then
            exit(Receipt."Shipment Date");

    end;
}
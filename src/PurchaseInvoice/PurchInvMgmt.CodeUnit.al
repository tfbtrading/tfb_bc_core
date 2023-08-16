codeunit 50285 "TFB Purch. Inv. Mgmt"
{

    procedure SendPODRequestForInvoice(DocumentNo: Code[20])

    var
        InvoiceLine: Record "Sales Invoice Line";
    begin
        //Send with no line number
        InvoiceLine.SetRange("Document No.", DocumentNo);
        InvoiceLine.SetFilter("Quantity (Base)", '>0');

        if InvoiceLine.FindFirst() then
            SendPODRequest(DocumentNo, InvoiceLine."Line No.");
    end;

    local procedure CheckIfAssignmentRequired(Line: Record "Purchase Line"): Boolean

    var

    begin

        if (Line.Type = Line.Type::"Charge (Item)") and (Line.Description <> '') then
            if (Line.Quantity > 0) and (Line."Qty. to Assign" < Line.Quantity) then
                //Conditions correct for assigning item charge
                exit(true)
            else
                exit(false)
        else
            exit(false);


    end;


    procedure CheckAndRetrieveAssignmentLines(var Line: Record "Purchase Line"; Suppress: Boolean): Boolean

    var

        Header: Record "Purchase Header";
        TokenClass: Enum "TFB Assignment Class";
        Reference: Text[100];
        Result: Boolean;

    begin


        Clear(Result);
        if CheckIfAssignmentRequired(Line) then begin




            Header.SetRange("Document Type", Line."Document Type");
            Header.SetRange("No.", Line."Document No.");



            Reference := ExtractReference(Line.Description, TokenClass);
            if Reference = '' then
                if Header.FindFirst() then
                    Reference := ExtractReference(Header."TFB Charge Assignment", TokenClass);

            if not (Reference = '') then
                case TokenClass of

                    TokenClass::"Purchase Order":
                        Result := GetPurchaseReceiptByPOReference(Line, Reference);
                    TokenClass::"Inbound Container":
                        Result := GetPurchaseReceiptByCntReference(Line, Reference);
                    TokenClass::"Warehouse Shipment":
                        Result := GetSalesShipmentByWarehouseReference(Line, Reference);
                    TokenClass::"3PL Booking":
                        Result := GetSalesShipmentByBookingReference(Line, Reference);
                end;
        end;
        exit(result);

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Get Receipt", 'OnAfterInsertLines', '', false, false)]
    local procedure OnAfterInsertLines(var PurchHeader: Record "Purchase Header");
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Line", 'OnAfterInsertInvLineFromRcptLine', '', false, false)]
    local procedure OnAfterInsertInvLineFromRcptLine(var PurchLine: Record "Purchase Line"; PurchOrderLine: Record "Purchase Line"; NextLineNo: Integer; PurchRcptLine: Record "Purch. Rcpt. Line");
    begin
    end;

    procedure ExtractReference(Description: Text; var TokenClass: Enum "TFB Assignment Class"): Text[100]

    var
        CoreSetup: Record "TFB Core Setup";
        StartNum: Integer;
        TokenLen: Integer;
        Reference: Text[100];

    begin

        StartNum := Description.IndexOf('3PL');
        CoreSetup.Get();

        if (StartNum > 0) then begin
            TokenLen := STRLEN(Description) - (StartNum + 4);

            Reference := Copystr(Description.Substring(StartNum + 4, TokenLen), 1, 100);
            TokenClass := TokenClass::"3PL Booking";
            exit(Reference);
        end;




        StartNum := Description.IndexOf(CoreSetup."Shipment Prefix");

        if StartNum > 0 then begin
            Reference := Description.Substring(StartNum, 13);
            TokenClass := TokenClass::"Sales Shipment";
            exit(Reference);
        end;


        StartNum := Description.IndexOf(CoreSetup."Warehouse Prefix");

        if StartNum > 0 then begin
            Reference := Description.Substring(StartNum, 12);
            TokenClass := TokenClass::"Warehouse Shipment";
            exit(Reference);
        end;

        StartNum := Description.IndexOf('CNT');

        if StartNum > 0 then begin

            Reference := Description.SubString(StartNum + 4, 11);
            TokenClass := TokenClass::"Inbound Container";
            exit(Reference);
        end;

        StartNum := Description.IndexOf('PO');

        if StartNum > 0 then begin

            Reference := Description.Substring(StartNum, 7);
            TokenClass := TokenClass::"Purchase Order";
            exit(Reference);
        end;

    end;

    procedure SendPODRequest(DocumentNo: Code[20]; LineNo: Integer)

    var
        ValueEntry: Record "Value Entry";
        ItemLedger: Record "Item Ledger Entry";
        SalesShipment: Record "Sales Shipment Header";
        ShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";

    begin
        Clear(ValueEntry);
        ValueEntry.SetRange("Document No.", DocumentNo);
        if LineNo > 0 then
            ValueEntry.SetRange("Document Line No.", LineNo);

        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetRange(Adjustment, false);

        if ValueEntry.Findset(false) then
            repeat

                //Locate shipments
                if ItemLedger.Get(ValueEntry."Item Ledger Entry No.") then begin

                    //Retrieve sales shipment
                    Clear(SalesShipment);
                    if ItemLedger."Document Type" = ItemLedger."Document Type"::"Sales Shipment" then
                        if SalesShipment.Get(ItemLedger."Document No.") then
                            //Call Sales Shipment CU
                            ShipmentCU.SendShipmentStatusQuery(SalesShipment, DocumentNo);
                end;


            until ValueEntry.Next() < 1;

    end;

    local procedure GetPurchaseReceiptLinesByPOReference(var Lines: Record "Purch. Rcpt. Line"; Reference: Text[100])

    begin
        Lines.SetRange("Order No.", Reference);
        Lines.SetRange(Type, Lines.Type::Item);
        Lines.SetFilter(Quantity, '>0');
    end;

    procedure IsPOTokenValid(Reference: Text[100]): Boolean

    var
        Line: Record "Purch. Rcpt. Line";

    begin

        GetPurchaseReceiptLinesByPOReference(Line, Reference);

        exit(not Line.IsEmpty());
    end;



    procedure GetPurchaseReceiptByPOReference(var PurchLine: Record "Purchase Line"; Reference: Text[100]): Boolean

    var
        TempICAssignment: Record "Item Charge Assignment (Purch)" temporary;
        Line: Record "Purch. Rcpt. Line";
        ICAssignmentCU: CodeUnit "Item Charge Assgnt. (Purch.)";
        PurchaseReceiptCU: Codeunit "TFB Purch. Rcpt. Mgmt";
        TotalExistingItemCharges: Decimal;
        SameExistingItemCharges: Decimal;
        LineNo: Integer;
        ChargesAssigned: Boolean;

    begin

        LineNo := 10000;

        //Retrieve Lines

        Clear(Line);
        GetPurchaseReceiptLinesByPOReference(Line, Reference);

        if Line.Findset(false) then begin
            if PurchaseReceiptCU.GetItemChargesForReceipt(Line."Document No.", Line."Line No.", PurchLine."No.", TotalExistingItemCharges, SameExistingItemCharges) then
                if not Dialog.Confirm(StrSubstNo('Charges already exist. Same Item Charge of %1 and total charges of %2 - Continue?', SameExistingItemCharges, TotalExistingItemCharges)) then
                    exit(false);
            repeat
                CLEAR(TempICAssignment);
                TempICAssignment."Document No." := PurchLine."Document No.";
                TempICAssignment."Document Type" := PurchLine."Document Type";
                TempICAssignment."Document Line No." := PurchLine."Line No.";
                TempICAssignment."Line No." := LineNo;
                TempICAssignment."Item Charge No." := PurchLine."No.";
                TempICAssignment."Item No." := Line."No.";
                TempICAssignment.Description := Line.Description;
                TempICAssignment."Applies-to Doc. No." := Line."Document No.";
                TempICAssignment."Applies-to Doc. Line No." := Line."Line No.";
                TempICAssignment."Applies-to Doc. Type" := TempICAssignment."Applies-to Doc. Type"::Receipt;


                LineNo := LineNo + 10000; //Increment line count as it appears it doesn't happen automatically
                ICAssignmentCU.CreateRcptChargeAssgnt(Line, TempICAssignment);
                ChargesAssigned := true;

            until Line.Next() < 1;
        end;

        if ChargesAssigned = true then begin

            ICAssignmentCU.AssignItemCharges(PurchLine, PurchLine.Quantity, PurchLine.Amount, ICAssignmentCU.AssignByWeightMenuText());
            Line.CalcFields("TFB Container No. LookUp");
            if Line."TFB Container Entry No." <> '' then
                PurchLine.Description := PurchLine.Description + StrSubstNo(' for container %1 on %2', line."TFB Container No. LookUp", Line."Posting Date")
            else
                PurchLine.Description := PurchLine.Description + StrSubstNo(' receipted as semiload on %1', Line."Posting Date");
            PurchLine.Modify(false);
            PurchLine.CalcFields("Qty. to Assign");
            exit(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Line", 'OnBeforeInsertInvLineFromRcptLineBeforeInsertTextLine', '', false, false)]
    /// <summary> 
    /// Event subscriber to alter text inserted to the more friendly and useful order number
    /// </summary>
    /// <param name="PurchRcptLine">Parameter of type Record "Purch. Rcpt. Line".</param>
    /// <param name="PurchLine">Parameter of type Record "Purchase Line".</param>
    /// <param name="NextLineNo">Parameter of type Integer.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    local procedure OnBeforeInsertInvLineFromRcptLineBeforeInsertTextLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchLine: Record "Purchase Line"; var NextLineNo: Integer; var Handled: Boolean);

    var
        Text000Msg: Label 'Invoiced from order %1 receipt:', Comment = '%1 = sales order number';
    begin

        PurchLine.Description := StrSubstNo(Text000Msg, PurchRcptLine."Order No.");

    end;



    procedure GetPurchaseReceiptLinesByCntReference(var Lines: Record "Purch. Rcpt. Line"; Reference: Text[100])

    begin

        Lines.SetRange("TFB Container No. LookUp", Reference);
        Lines.SetRange(Type, Lines.Type::Item);
        Lines.SetFilter(Quantity, '>0');

    end;

    procedure isCntTokenValid(Reference: Text[100]): Boolean

    var
        Lines: Record "Purch. Rcpt. Line";

    begin

        GetPurchaseReceiptLinesByCntReference(Lines, Reference);
        exit(not Lines.IsEmpty());

    end;

    procedure GetPurchaseReceiptByCntReference(var PurchLine: Record "Purchase Line"; Reference: Text[100]): Boolean

    var
        TempICAssignment: Record "Item Charge Assignment (Purch)" temporary;
        PurchRcptLines: Record "Purch. Rcpt. Line";
        TransferReceiptLine: Record "Transfer Receipt Line";
        ICAssignmentCU: CodeUnit "Item Charge Assgnt. (Purch.)";
        PurchaseReceiptCU: Codeunit "TFB Purch. Rcpt. Mgmt";
        TransferReceiptCU: Codeunit "TFB Transfer Rcpt. Mgmt";
        TotalExistingItemCharges: Decimal;
        SameExistingItemCharges: Decimal;
        LineNo: Integer;
        ChargesAssigned: Boolean;

    begin



        //Retrieve Lines

        Clear(PurchRcptLines);
        LineNo := 10000;

        GetTransferReceiptLinesByCntReference(TransferReceiptLine, Reference);
        GetPurchaseReceiptLinesByCntReference(PurchRcptLines, Reference);

        if TransferReceiptLine.Findset(false) then begin
            if TransferReceiptCU.GetItemChargesForReceipt(TransferReceiptLine."Document No.", TransferReceiptLine."Line No.", PurchLine."No.", TotalExistingItemCharges, SameExistingItemCharges) then
                if not Dialog.Confirm(StrSubstNo('Charges already exist. Same Item Charge of %1 and total charges of %2 - Continue?', SameExistingItemCharges, TotalExistingItemCharges)) then
                    exit(false);

            repeat
                CLEAR(TempICAssignment);
                LineNo := LineNo + 10000; //Increment line count as it appears it doesn't happen automatically
                TempICAssignment."Document No." := PurchLine."Document No.";
                TempICAssignment."Document Type" := PurchLine."Document Type";
                TempICAssignment."Document Line No." := PurchLine."Line No.";
                TempICAssignment."Line No." := LineNo;
                TempICAssignment."Item Charge No." := PurchLine."No.";
                TempICAssignment."Item No." := TransferReceiptLine."Item No.";
                TempICAssignment.Description := TransferReceiptLine.Description;
                TempICAssignment."Applies-to Doc. No." := TransferReceiptLine."Document No.";
                TempICAssignment."Applies-to Doc. Line No." := TransferReceiptLine."Line No.";
                TempICAssignment."Applies-to Doc. Type" := TempICAssignment."Applies-to Doc. Type"::"Transfer Receipt";
                ICAssignmentCU.CreateTransferRcptChargeAssgnt(TransferReceiptLine, TempICAssignment);
                ChargesAssigned := true;

            until PurchRcptLines.Next() = 0;

            if ChargesAssigned = true then begin
                ICAssignmentCU.AssignItemCharges(PurchLine, PurchLine.Quantity, PurchLine.Amount, ICAssignmentCU.AssignByWeightMenuText());
                TransferReceiptLine.CalcFields("TFB Container No. LookUp");
                PurchLine.Description := PurchLine.Description + StrSubstNo(' for order %1 shipped in %2 received on %3', TransferReceiptLine."Document No.", TransferReceiptLine."TFB Container No.", TransferReceiptLine."Receipt Date");
                PurchLine.Modify(false);
                PurchLine.CalcFields("Qty. to Assign");
                exit(true);
            end;
        end;

        if PurchRcptLines.Findset(false) then begin

            if PurchaseReceiptCU.GetItemChargesForReceipt(PurchRcptLines."Document No.", PurchRcptLines."Line No.", PurchLine."No.", TotalExistingItemCharges, SameExistingItemCharges) then
                if not Dialog.Confirm(StrSubstNo('Charges already exist. Same Item Charge of %1 and total charges of %2 - Continue?', SameExistingItemCharges, TotalExistingItemCharges)) then
                    exit(false);
            repeat
                CLEAR(TempICAssignment);
                LineNo := LineNo + 10000; //Increment line count as it appears it doesn't happen automatically
                TempICAssignment."Document No." := PurchLine."Document No.";
                TempICAssignment."Document Type" := PurchLine."Document Type";
                TempICAssignment."Document Line No." := PurchLine."Line No.";
                TempICAssignment."Line No." := LineNo;
                TempICAssignment."Item Charge No." := PurchLine."No.";
                TempICAssignment."Item No." := PurchRcptLines."No.";
                TempICAssignment.Description := PurchRcptLines.Description;
                TempICAssignment."Applies-to Doc. No." := PurchRcptLines."Document No.";
                TempICAssignment."Applies-to Doc. Line No." := PurchRcptLines."Line No.";
                TempICAssignment."Applies-to Doc. Type" := TempICAssignment."Applies-to Doc. Type"::Receipt;
                ICAssignmentCU.CreateRcptChargeAssgnt(PurchRcptLines, TempICAssignment);
                ChargesAssigned := true;

            until PurchRcptLines.Next() = 0;

            if ChargesAssigned = true then begin
                ICAssignmentCU.AssignItemCharges(PurchLine, PurchLine.Quantity, PurchLine.Amount, ICAssignmentCU.AssignByWeightMenuText());
                PurchRcptLines.CalcFields("TFB Container No. LookUp");
                PurchLine.Description := PurchLine.Description + StrSubstNo(' for order %1 shipped in %2 received on %3', PurchRcptLines."Order No.", PurchRcptLines."TFB Container No. LookUp", PurchRcptLines."Posting Date");
                PurchLine.Modify(false);
                PurchLine.CalcFields("Qty. to Assign");
                exit(true);
            end;
        end;
    end;

    procedure IsSalesShipmentTokenValid(Reference: Text[100]): Boolean

    var
        ShipHeader: Record "Sales Shipment Header";
        ShipLine: Record "Sales Shipment Line";
        HeaderDocNoFilter: TextBuilder;
    begin
        ShipHeader.SetRange("TFB 3PL Booking No.", Reference);

        if ShipHeader.Findset(false) then begin

            repeat
                if HeaderDocNoFilter.Length() >= 1 then HeaderDocNoFilter.Append('|');
                HeaderDocNoFilter.Append(ShipHeader."No.");

            until ShipHeader.Next() < 1;


            ShipLine.SetFilter("Document No.", HeaderDocNoFilter.ToText());
            ShipLine.SetRange(Type, ShipLine.Type::Item);
            ShipLine.SetRange("Drop Shipment", false);
            ShipLine.SetFilter(Quantity, '>0');

            exit(not ShipLine.IsEmpty());

        end;
    end;

    procedure GetSalesShipmentByBookingReference(var PurchLine: Record "Purchase Line"; Reference: Text[100]): Boolean

    var
        TempICAssignment: Record "Item Charge Assignment (Purch)" temporary;
        ShipHeader: Record "Sales Shipment Header";
        ShipLine: Record "Sales Shipment Line";
        ICAssignmentCU: CodeUnit "Item Charge Assgnt. (Purch.)";
        HeaderDocNoFilter: TextBuilder;

    begin

        //Check if freight allocation already exists
        PurchLine.UpdateAmounts();


        TempICAssignment.SetRange("Document No.", PurchLine."Document No.");
        TempICAssignment.SetRange("Document Type", PurchLine."Document Type");
        TempICAssignment.SetRange("Document Line No.", PurchLine."Line No.");

        if not TempICAssignment.IsEmpty() then
            if Dialog.Confirm('Assignment lines already exist - Remove them first?') then
                TempICAssignment.DeleteAll(false);


        TempICAssignment."Document No." := PurchLine."Document No.";
        TempICAssignment."Document Type" := PurchLine."Document Type";
        TempICAssignment."Document Line No." := PurchLine."Line No.";
        TempICAssignment."Item Charge No." := PurchLine."No.";

        ShipHeader.SetRange("TFB 3PL Booking No.", Reference);

        if ShipHeader.Findset(false) then begin

            repeat
                if HeaderDocNoFilter.Length() >= 1 then HeaderDocNoFilter.Append('|');
                HeaderDocNoFilter.Append(ShipHeader."No.");

            until ShipHeader.Next() < 1;


            ShipLine.SetFilter("Document No.", HeaderDocNoFilter.ToText());
            ShipLine.SetRange(Type, ShipLine.Type::Item);
            ShipLine.SetRange("Drop Shipment", false);
            ShipLine.SetFilter(Quantity, '>0');

            if ShipLine.Findset(false) then begin

                ICAssignmentCU.CreateSalesShptChargeAssgnt(ShipLine, TempICAssignment);
                ICAssignmentCU.AssignItemCharges(PurchLine, PurchLine.Quantity, PurchLine.Amount, ICAssignmentCU.AssignByWeightMenuText());
                PurchLine.Description := 'Sales Freight for ' + Reference + StrSubstNo(' for %1 on %2', ShipHeader."Ship-to Name", ShipHeader."Posting Date");
                PurchLine.CalcFields("Qty. to Assign");
                exit(true);
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Charge Assgnt. (Purch.)", 'OnBeforeCreateSalesShptChargeAssgnt', '', false, false)]
    local procedure HandleOnBeforeCreateSalesShptChargeAssgnt(ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; var FromSalesShptLine: Record "Sales Shipment Line"; var IsHandled: Boolean)
    var
        ShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";

    begin
        if ShipmentCU.GetItemChargesForSalesShipment(FromSalesShptLine."Document No.", FromSalesShptLine."Line No.", ItemChargeAssgntPurch."Item Charge No.") > 0 then
            if not Dialog.Confirm('Charges already exist for shipment lines - Continue?') then
                IsHandled := true;

    end;

    local procedure GetWarehouseShipmentLines(var Lines: Record "Sales Shipment Line"; reference: Text[100]; var NewCustomerList: Text; var PostingDate: Date): Boolean

    var
        WhseHeader: Record "Posted Whse. Shipment Header";
        WhseLine: Record "Posted Whse. Shipment Line";
        ShipmentHeader: Record "Sales Shipment Header";
        CustomerList: TextBuilder;
        HeaderDocNoFilter: TextBuilder;
        HeaderDocList: List of [Code[20]];
        DocNo: Code[20];
    begin
        WhseHeader.SetRange("Whse. Shipment No.", Reference);
        Clear(HeaderDocList);

        if WhseHeader.Findset(false) then begin
            repeat

                //Retrieve Lines

                WhseLine.SetRange("No.", WhseHeader."No.");
                WhseLine.SetRange("Posted Source Document", WhseLine."Posted Source Document"::"Posted Shipment");
                WhseLine.SetFilter(Quantity, '>0');

                if WhseLine.Findset(false) then
                    repeat

                        //Get SalesShipment
                        ShipmentHeader.SetRange("No.", WhseLine."Posted Source No.");
                        if ShipmentHeader.Findset(false) then
                            repeat

                                if CustomerList.ToText() <> ShipmentHeader."Sell-to Customer Name" then begin
                                    if CustomerList.Length() > 0 then CustomerList.Append(', ');
                                    CustomerList.Append(ShipmentHeader."Sell-to Customer Name");
                                end;

                                if not HeaderDocList.Contains(WhseLine."Posted Source No.") then
                                    HeaderDocList.Add(WhseLine."Posted Source No.");

                            until ShipmentHeader.Next() < 1;


                    until WhseLine.Next() < 1;

            until WhseHeader.Next() < 1;

            foreach DocNo in HeaderDocList do begin
                if HeaderDocNoFilter.Length() >= 1 then
                    HeaderDocNoFilter.Append('|');
                HeaderDocNoFilter.Append(DocNo);
            end;



            Lines.SetFilter("Document No.", HeaderDocNoFilter.ToText());
            Lines.SetRange(Type, Lines.Type::Item);
            Lines.SetRange("Drop Shipment", false);
            Lines.SetFilter(Quantity, '>0');

            NewCustomerList := CustomerList.ToText();
            PostingDate := WhseHeader."Posting Date";
        end;

        exit(HeaderDocList.Count > 0)
    end;

    local procedure GetTransferReceiptLinesByCntReference(var Lines: Record "Transfer Receipt Line"; Reference: Text[100])
    begin
        Lines.SetRange("TFB Container No.", Reference);
        Lines.SetFilter(Quantity, '>0');
    end;

    procedure IsWarehouseReferenceValid(Reference: Text[100]): Boolean

    var

        ShipLine: Record "Sales Shipment Line";
        PostingDate: Date;
        CustomerList: Text;

    begin

        GetWarehouseShipmentLines(ShipLine, Reference, CustomerList, PostingDate);
        exit(not ShipLine.IsEmpty());

    end;

    procedure GetSalesShipmentByWarehouseReference(var PurchLine: Record "Purchase Line"; Reference: Text[100]): Boolean

    var
        TempICAssignment: Record "Item Charge Assignment (Purch)" temporary;
        ShipLine: Record "Sales Shipment Line";
        ICAssignmentCU: CodeUnit "Item Charge Assgnt. (Purch.)";
        SalesShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";
        CustomerList: Text;
        PostingDate: Date;
        TotalExistingItemCharges, SameExistingItemCharges : Decimal;


    begin

        PurchLine.UpdateAmounts();

        TempICAssignment.SetRange("Document No.", PurchLine."Document No.");
        TempICAssignment.SetRange("Document Type", PurchLine."Document Type");
        TempICAssignment.SetRange("Document Line No.", PurchLine."Line No.");

        if not TempICAssignment.IsEmpty() then
            if Dialog.Confirm('Assignment lines already exist - Remove them first?') then
                TempICAssignment.DeleteAll(false);

        TempICAssignment."Document No." := PurchLine."Document No.";
        TempICAssignment."Document Type" := PurchLine."Document Type";
        TempICAssignment."Document Line No." := PurchLine."Line No.";
        TempICAssignment."Item Charge No." := PurchLine."No.";

        if GetWarehouseShipmentLines(ShipLine, Reference, CustomerList, PostingDate) then
            if ShipLine.Findset(false) then begin
                if SalesShipmentCU.GetItemChargesForShipment(Text.CopyStr(PurchLine."No.", 1, 10), ShipLine."Document No.", TotalExistingItemCharges, SameExistingItemCharges) then
                    if not Dialog.Confirm(StrSubstNo('Charges already exist. Same Item Charge of %1 and total charges of %2 - Continue?', SameExistingItemCharges, TotalExistingItemCharges)) then
                        exit(false);

                ICAssignmentCU.CreateSalesShptChargeAssgnt(ShipLine, TempICAssignment);
                ICAssignmentCU.AssignItemCharges(PurchLine, PurchLine.Quantity, PurchLine.Amount, ICAssignmentCU.AssignByWeightMenuText());
                PurchLine.Description := Text.CopyStr(StrSubstNo('%1 Shipment to %2 on %3', Reference, CustomerList, PostingDate), 1, 100);
                PurchLine.CalcFields("Qty. to Assign");
                PurchLine.Modify(false);
                exit(true);
            end;

    end;
}
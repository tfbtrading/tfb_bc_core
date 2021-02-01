codeunit 50285 "TFB Purch. Inv. Mgmt"
{

    procedure SendPODRequestForInvoice(DocumentNo: Code[20])

    var
        InvoiceLine: Record "Sales Invoice Line";
    begin
        //Send with no line number
        InvoiceLine.SetRange("Document No.", DocumentNo);
        InvoiceLine.SetFilter("Quantity (Base)", '>0');

        If InvoiceLine.FindFirst() then
            SendPODRequest(DocumentNo, InvoiceLine."Line No.");
    end;

    local procedure CheckIfAssignmentRequired(Line: Record "Purchase Line"): Boolean

    var

    begin

        If (Line.Type = Line.Type::"Charge (Item)") and (Line.Description <> '') then
            If (Line.Quantity > 0) and (Line."Qty. to Assign" < Line.Quantity) then
                //Conditions correct for assigning item charge
                Exit(true)
            else
                Exit(false)
        else
            Exit(false);


    end;

    procedure CheckAndRetrieveAssignmentLines(var Line: Record "Purchase Line"; Suppress: Boolean): Boolean

    var

        Header: Record "Purchase Header";
        TokenClass: Enum "TFB Assignment Class";
        Reference: Text[100];
        Result: Boolean;

    begin


        Clear(Result);
        If CheckIfAssignmentRequired(Line) then begin




            Header.SetRange("Document Type", enum::"Purchase Document Type"::Invoice);
            Header.SetRange("No.", Line."Document No.");



            Reference := ExtractReference(Line.Description, TokenClass);
            If Reference = '' then
                If Header.FindFirst() then
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
        Exit(result);

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
        StartNum: Integer;
        TokenLen: Integer;
        Reference: Text[100];

    begin

        StartNum := Description.IndexOf('3PL');

        If (StartNum > 0) then begin
            TokenLen := STRLEN(Description) - (StartNum + 4);

            Reference := Copystr(Description.Substring(StartNum + 4, TokenLen), 1, 100);
            TokenClass := TokenClass::"3PL Booking";
            Exit(Reference);
        end;




        StartNum := Description.IndexOf('S-SHP');

        If StartNum > 0 then begin
            Reference := Description.Substring(StartNum, 13);
            TokenClass := TokenClass::"Sales Shipment";
            Exit(Reference);
        end;


        StartNum := Description.IndexOf('W-SHP');

        If StartNum > 0 then begin
            Reference := Description.Substring(StartNum, 12);
            TokenClass := TokenClass::"Warehouse Shipment";
            Exit(Reference);
        end;

        StartNum := Description.IndexOf('CNT');

        If StartNum > 0 then begin

            Reference := Description.SubString(StartNum + 4, 11);
            TokenClass := TokenClass::"Inbound Container";
            Exit(Reference);
        end;

        StartNum := Description.IndexOf('PO');

        If StartNum > 0 Then begin

            Reference := Description.Substring(StartNum, 7);
            TokenClass := TokenClass::"Purchase Order";
            Exit(Reference);
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

        Exit(not Line.IsEmpty());
    end;



    procedure GetPurchaseReceiptByPOReference(var PurchLine: Record "Purchase Line"; Reference: Text[100]): Boolean

    var
        ICAssignment: Record "Item Charge Assignment (Purch)" temporary;
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

        If Line.FindSet(False, false) then begin
            If PurchaseReceiptCU.GetItemChargesForReceipt(Line."Document No.", Line."Line No.", PurchLine."No.", TotalExistingItemCharges, SameExistingItemCharges) then
                If not Dialog.Confirm(StrSubstNo('Charges already exist. Same Item Charge of %1 and total charges of %2 - Continue?', SameExistingItemCharges, TotalExistingItemCharges)) then
                    exit(false);
            repeat
                CLEAR(ICAssignment);
                ICAssignment."Document No." := PurchLine."Document No.";
                ICAssignment."Document Type" := PurchLine."Document Type"::Invoice;
                ICAssignment."Document Line No." := PurchLine."Line No.";
                ICAssignment."Line No." := LineNo;
                ICAssignment."Item Charge No." := PurchLine."No.";
                ICAssignment."Item No." := Line."No.";
                ICAssignment.Description := Line.Description;
                ICAssignment."Applies-to Doc. No." := Line."Document No.";
                ICAssignment."Applies-to Doc. Line No." := Line."Line No.";
                ICAssignment."Applies-to Doc. Type" := ICAssignment."Applies-to Doc. Type"::Receipt;


                LineNo := LineNo + 10000; //Increment line count as it appears it doesn't happen automatically
                ICAssignmentCU.CreateRcptChargeAssgnt(Line, ICAssignment);
                ChargesAssigned := true;

            until Line.Next() < 1;
        end;

        if ChargesAssigned = true then begin

            ICAssignmentCU.AssignItemCharges(PurchLine, PurchLine.Quantity, PurchLine.Amount, ICAssignmentCU.AssignByWeightMenuText());
            Line.CalcFields("TFB Container No. LookUp");
            If Line."TFB Container Entry No." <> '' then
                PurchLine.Description := PurchLine.Description + StrSubstNo(' for container %1 on %2', line."TFB Container No. LookUp", Line."Posting Date")
            else
                PurchLine.Description := PurchLine.Description + StrSubstNo(' receipted as semiload on %1', Line."Posting Date");
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

        Lines.SetRange("TFB Container No.", Reference);
        Lines.SetRange(Type, Lines.Type::Item);
        Lines.SetFilter(Quantity, '>0');

    end;

    procedure isCntTokenValid(Reference: Text[100]): Boolean

    var
        Lines: Record "Purch. Rcpt. Line";

    begin

        GetPurchaseReceiptLinesByCntReference(Lines, Reference);
        Exit(Not Lines.IsEmpty());

    end;

    procedure GetPurchaseReceiptByCntReference(var PurchLine: Record "Purchase Line"; Reference: Text[100]): Boolean

    var
        ICAssignment: Record "Item Charge Assignment (Purch)" temporary;
        Lines: Record "Purch. Rcpt. Line";
        ICAssignmentCU: CodeUnit "Item Charge Assgnt. (Purch.)";
        PurchaseReceiptCU: Codeunit "TFB Purch. Rcpt. Mgmt";
        TotalExistingItemCharges: Decimal;
        SameExistingItemCharges: Decimal;
        LineNo: Integer;
        ChargesAssigned: Boolean;

    begin



        //Retrieve Lines

        Clear(Lines);
        LineNo := 10000;
        GetPurchaseReceiptLinesByCntReference(Lines, Reference);

        If Lines.FindSet(False, false) then begin

            If PurchaseReceiptCU.GetItemChargesForReceipt(Lines."Document No.", Lines."Line No.", PurchLine."No.", TotalExistingItemCharges, SameExistingItemCharges) then
                If not Dialog.Confirm(StrSubstNo('Charges already exist. Same Item Charge of %1 and total charges of %2 - Continue?', SameExistingItemCharges, TotalExistingItemCharges)) then
                    exit(false);
            repeat
                CLEAR(ICAssignment);
                LineNo := LineNo + 10000; //Increment line count as it appears it doesn't happen automatically
                ICAssignment."Document No." := PurchLine."Document No.";
                ICAssignment."Document Type" := PurchLine."Document Type"::Invoice;
                ICAssignment."Document Line No." := PurchLine."Line No.";
                ICAssignment."Line No." := LineNo;
                ICAssignment."Item Charge No." := PurchLine."No.";
                ICAssignment."Item No." := Lines."No.";
                ICAssignment.Description := Lines.Description;
                ICAssignment."Applies-to Doc. No." := Lines."Document No.";
                ICAssignment."Applies-to Doc. Line No." := Lines."Line No.";
                ICAssignment."Applies-to Doc. Type" := ICAssignment."Applies-to Doc. Type"::Receipt;
                ICAssignmentCU.CreateRcptChargeAssgnt(Lines, ICAssignment);
                ChargesAssigned := true;

            until Lines.Next() < 1;

            If ChargesAssigned = true then begin
                ICAssignmentCU.AssignItemCharges(PurchLine, PurchLine.Quantity, PurchLine.Amount, ICAssignmentCU.AssignByWeightMenuText());
                Lines.CalcFields("TFB Container No. LookUp");
                PurchLine.Description := PurchLine.Description + StrSubstNo(' for order %1 shipped in %2 received on %3', Lines."Order No.", Lines."TFB Container No. LookUp", Lines."Posting Date");
                PurchLine.CalcFields("Qty. to Assign");
                Exit(true);
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

        If ShipHeader.FindSet(false, false) then begin

            repeat
                if HeaderDocNoFilter.Length() >= 1 then HeaderDocNoFilter.Append('|');
                HeaderDocNoFilter.Append(ShipHeader."No.");

            until ShipHeader.Next() < 1;


            ShipLine.SetFilter("Document No.", HeaderDocNoFilter.ToText());
            ShipLine.SetRange(Type, ShipLine.Type::Item);
            ShipLine.SetRange("Drop Shipment", false);
            ShipLine.SetFilter(Quantity, '>0');

            Exit(not ShipLine.IsEmpty());

        end;
    end;

    procedure GetSalesShipmentByBookingReference(var PurchLine: Record "Purchase Line"; Reference: Text[100]): Boolean

    var
        ICAssignment: Record "Item Charge Assignment (Purch)" temporary;
        ShipHeader: Record "Sales Shipment Header";
        ShipLine: Record "Sales Shipment Line";
        ICAssignmentCU: CodeUnit "Item Charge Assgnt. (Purch.)";
        HeaderDocNoFilter: TextBuilder;

    begin

        //Check if freight allocation already exists
        PurchLine.UpdateAmounts();


        ICAssignment.SetRange("Document No.", PurchLine."Document No.");
        ICAssignment.SetRange("Document Type", PurchLine."Document Type"::Invoice);
        ICAssignment.SetRange("Document Line No.", PurchLine."Line No.");

        If not ICAssignment.IsEmpty() then
            If Dialog.Confirm('Assignment lines already exist - Remove them first?') then
                ICAssignment.DeleteAll(false);


        ICAssignment."Document No." := PurchLine."Document No.";
        ICAssignment."Document Type" := PurchLine."Document Type"::Invoice;
        ICAssignment."Document Line No." := PurchLine."Line No.";
        ICAssignment."Item Charge No." := PurchLine."No.";

        ShipHeader.SetRange("TFB 3PL Booking No.", Reference);

        If ShipHeader.FindSet(false, false) then begin

            repeat
                if HeaderDocNoFilter.Length() >= 1 then HeaderDocNoFilter.Append('|');
                HeaderDocNoFilter.Append(ShipHeader."No.");

            until ShipHeader.Next() < 1;


            ShipLine.SetFilter("Document No.", HeaderDocNoFilter.ToText());
            ShipLine.SetRange(Type, ShipLine.Type::Item);
            ShipLine.SetRange("Drop Shipment", false);
            ShipLine.SetFilter(Quantity, '>0');

            If ShipLine.FindSet(False, false) then begin

                ICAssignmentCU.CreateSalesShptChargeAssgnt(ShipLine, ICAssignment);
                ICAssignmentCU.AssignItemCharges(PurchLine, PurchLine.Quantity, PurchLine.Amount, ICAssignmentCU.AssignByWeightMenuText());
                PurchLine.Description := 'Sales Freight for ' + Reference + StrSubstNo(' for %1 on %2', ShipHeader."Ship-to Name", ShipHeader."Posting Date");
                PurchLine.CalcFields("Qty. to Assign");
                Exit(true);
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Charge Assgnt. (Purch.)", 'OnBeforeCreateSalesShptChargeAssgnt', '', false, false)]
    local procedure HandleOnBeforeCreateSalesShptChargeAssgnt(ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; var FromSalesShptLine: Record "Sales Shipment Line"; var IsHandled: Boolean)
    var
        ShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";

    begin
        If ShipmentCU.GetItemChargesForSalesShipment(FromSalesShptLine."Document No.", FromSalesShptLine."Line No.", ItemChargeAssgntPurch."Item Charge No.") > 0 then
            If not Dialog.Confirm('Charges already exist for shipment lines - Continue?') then
                IsHandled := true;

    end;

    local procedure GetWarehouseShipmentLines(var Lines: Record "Sales Shipment Line"; reference: Text[100]; var NewCustomerList: Text; var PostingDate: Date)

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

        If WhseHeader.FindSet(false, false) then begin
            repeat

                //Retrieve Lines

                WhseLine.SetRange("No.", WhseHeader."No.");
                WhseLine.SetRange("Posted Source Document", WhseLine."Posted Source Document"::"Posted Shipment");
                WhseLine.SetFilter(Quantity, '>0');

                If WhseLine.FindSet(False, false) then
                    repeat

                        //Get SalesShipment
                        ShipmentHeader.SetRange("No.", WhseLine."Posted Source No.");
                        If ShipmentHeader.FindSet(false, false) then
                            repeat

                                If CustomerList.ToText() <> ShipmentHeader."Sell-to Customer Name" then begin
                                    If CustomerList.Length() > 0 then CustomerList.Append(', ');
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
    end;

    procedure IsWarehouseReferenceValid(Reference: Text[100]): Boolean

    var

        ShipLine: Record "Sales Shipment Line";
        PostingDate: Date;
        CustomerList: Text;

    begin

        GetWarehouseShipmentLines(ShipLine, Reference, CustomerList, PostingDate);
        Exit(not ShipLine.IsEmpty());

    end;

    procedure GetSalesShipmentByWarehouseReference(var PurchLine: Record "Purchase Line"; Reference: Text[100]): Boolean

    var
        ICAssignment: Record "Item Charge Assignment (Purch)" temporary;
        ShipLine: Record "Sales Shipment Line";
        ICAssignmentCU: CodeUnit "Item Charge Assgnt. (Purch.)";
        CustomerList: Text;
        PostingDate: Date;

    begin

        PurchLine.UpdateAmounts();

        ICAssignment.SetRange("Document No.", PurchLine."Document No.");
        ICAssignment.SetRange("Document Type", PurchLine."Document Type"::Invoice);
        ICAssignment.SetRange("Document Line No.", PurchLine."Line No.");

        If not ICAssignment.IsEmpty() then
            If Dialog.Confirm('Assignment lines already exist - Remove them first?') then
                ICAssignment.DeleteAll(false);

        ICAssignment."Document No." := PurchLine."Document No.";
        ICAssignment."Document Type" := PurchLine."Document Type"::Invoice;
        ICAssignment."Document Line No." := PurchLine."Line No.";
        ICAssignment."Item Charge No." := PurchLine."No.";

        GetWarehouseShipmentLines(ShipLine, Reference, CustomerList, PostingDate);

        If ShipLine.FindSet(False, false) then begin

            ICAssignmentCU.CreateSalesShptChargeAssgnt(ShipLine, ICAssignment);
            ICAssignmentCU.AssignItemCharges(PurchLine, PurchLine.Quantity, PurchLine.Amount, ICAssignmentCU.AssignByWeightMenuText());
            PurchLine.Description := Text.CopyStr(StrSubstNo('%1 Shipment to %2 on %3', Reference, CustomerList, PostingDate), 1, 100);
            PurchLine.CalcFields("Qty. to Assign");
            Exit(true);
        end;

    end;
}
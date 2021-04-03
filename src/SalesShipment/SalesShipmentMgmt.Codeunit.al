codeunit 50181 "TFB Sales Shipment Mgmt"
{



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure HandleOnAfterPostSalesDoc(CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; RetRcpHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesShptHdrNo: Code[20]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var SalesHeader: Record "Sales Header")
    var
        ShipmentCu: Codeunit "TFB Sales Shipment Mgmt";

    begin

        if (not CommitIsSuppressed) then
            If SalesShptHdrNo <> '' then
                //Check if document already sent
                If not CheckIfSent(SalesShptHdrNo) then
                    shipmentcu.SendOneShipmentNotificationEmail(SalesShptHdrNo);

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterInsertCombinedSalesShipment', '', false, false)]
    local procedure HandlePurchaseOrderDropShipAdvice(var SalesShipmentHeader: Record "Sales Shipment Header")
    var
        ShipmentCu: Codeunit "TFB Sales Shipment Mgmt";

    begin
        If SalesShipmentHeader."No." <> '' then
            //do something
            If not CheckIfSent(SalesShipmentHeader."No.") then
                shipmentcu.SendOneShipmentNotificationEmail(SalesShipmentHeader."No.");
    end;

    local procedure getShipmentReferenceNo(Shipment: record "Sales Shipment Header"): Text

    var

    begin

        If Shipment.IsEmpty then exit;

        If Shipment."External Document No." <> '' then exit(StrSubstNo('your purchase order %1', Shipment."External Document No."));

        If Shipment."Order No." <> '' then exit(StrSubstNo('our order %1', Shipment."Order No."));

        exit(StrSubstNo('our shipment %1', Shipment."No."));

    end;


    procedure GetRelatedShipmentInvoice(Invoice: Record "Sales Invoice Header"; var Shipment: Record "Sales Shipment Header"): Boolean

    var
        InvoiceLine: Record "Sales Invoice Line";
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";

    begin

        InvoiceLine.SetRange("Document No.", Invoice."No.");
        InvoiceLine.SetFilter("Quantity (Base)", '>0');

        If InvoiceLine.FindFirst() then begin

            ValueEntry.SetRange("Document No.", InvoiceLine."Document No.");
            ValueEntry.SetRange("Document Line No.", InvoiceLine."Line No.");
            ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
            ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
            ValueEntry.SetRange(Adjustment, false);


            if ValueEntry.FindSet(false, false) then
                repeat

                    //Locate shipments
                    If ItemLedger.Get(ValueEntry."Item Ledger Entry No.") then
                        If ItemLedger."Document Type" = ItemLedger."Document Type"::"Sales Shipment" then
                            If Shipment.Get(ItemLedger."Document No.") then
                                //Call Sales Shipment CU
                                Exit(true);



                until ValueEntry.Next() < 1;

        end;

    end;

    procedure GetShipmentStatusQueryText(Header: Record "Sales Shipment Header"): Text

    var
        Line: Record "Sales Shipment Line";
        Location: Record Location;
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        Content: TextBuilder;


    begin

        Line.SetRange("Document No.", Header."No.");
        Line.SetFilter("Quantity (Base)", '>0');

        If Line.FindFirst() then

            //Check if drop ship

            If Line."Drop Shipment" then begin

                PurchaseHeaderArchive.SetRange("No.", Line."Purchase Order No.");
                PurchaseHeaderArchive.SetRange("Document Type", PurchaseHeaderArchive."Document Type"::Order);

                If PurchaseHeaderArchive.FindLast() then begin
                    Content.Append(StrSubstNo('Drop shipped against %1 from %2', PurchaseHeaderArchive."No.", PurchaseHeaderArchive."Buy-from Vendor Name"));
                    If Header."Package Tracking No." <> '' then
                        Content.Append(StrSubstNo('. Tracking No %1 shipped via %2.', Header."Package Tracking No.", Header."Shipping Agent Code"));
                end;
            end
            else begin


                Location.get(Line."Location Code");
                Content.Append(StrSubstNo('Shipped from warehouse %1 against %2 with 3PL booking ref %3.', Location.Name, RetrieveWhseShipReference(Line."Document No."), Header."TFB 3PL Booking No."));


            end;

        Exit(Content.ToText());

    end;

    procedure SendShipmentStatusQuery(Header: record "Sales Shipment Header"; OriginalRef: Code[20]): Boolean

    var
        CommEntry: Record "TFB Communication Entry";
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        Line: Record "Sales Shipment Line";
        Location: Record Location;
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        User: Record User;
        Vendor: Record Vendor;
        CommonCU: CodeUnit "TFB Common Library";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        Window: Dialog;
        EmailAction: Enum "Email Action";
        EmailScenEnum: Enum "Email Scenario";
        BCCRecipients: List of [Text];
        CCRecipients: List of [Text];
        ContactName: Text;
        CustomerName: Text;
        EmailID: Text;
        HTMLTemplate: Text;
        Recipients: List of [Text];
        Reference2: Text;
        Reference: Text;
        SubTitleTxt: Label 'Please find below our shipment status query for POD. ';
        TitleTxt: Label 'Order Status';
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;






    begin


        HTMLTemplate := CommonCU.GetHTMLTemplateActive(TitleTxt, SubTitleTxt);


        CompanyInfo.Get();

        If not Customer.Get(Header."Sell-to Customer No.") then
            exit(false);

        CustomerName := Customer.Name;
        //Find first line to check for drop ship 
        Line.SetRange("Document No.", Header."No.");
        Line.SetFilter("Quantity (Base)", '>0');

        If Line.FindFirst() then begin

            //Check if drop ship

            If Line."Drop Shipment" then begin

                PurchaseHeaderArchive.SetRange("No.", Line."Purchase Order No.");
                PurchaseHeaderArchive.SetRange("Document Type", PurchaseHeaderArchive."Document Type"::Order);

                If PurchaseHeaderArchive.FindLast() then begin
                    ContactName := PurchaseHeaderArchive."Buy-from Vendor Name";
                    Vendor.Get(PurchaseHeaderArchive."Buy-from Vendor No.");
                    EmailID := Vendor."E-Mail";
                    Reference := PurchaseHeaderArchive."No." + ' ' + PurchaseHeaderArchive."Vendor Order No.";
                end;
            end
            else begin



                Location.get(Line."Location Code");
                ContactName := Location.Name;
                EmailID := Location."E-Mail";
                Reference := Header."TFB 3PL Booking No.";
                Reference2 := RetrieveWhseShipReference(Line."Document No.");


            end;

            //Retrieve and construct message

            SubjectNameBuilder.Append(StrSubstNo('Shipment Status Query from TFB Trading for %1 against customer reference %2', Reference, OriginalRef));
            Recipients.Add(EmailID);




            HTMLBuilder.Append(HTMLTemplate);
            //HTMLBuilder.Replace('%1', 'Shipment Status Query');
            If GenerateShipmentStatusQueryContent(ContactName, Reference, Reference2, CustomerName, HTMLBuilder) then begin

                //Check that content has been generated to send

                User.Get(UserSecurityId());
                CCRecipients.Add(User."Contact Email");


                EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true, CCRecipients, BCCRecipients);
                If not (Email.OpenInEditorModally(EmailMessage, EmailScenEnum::Logistics) = EmailAction::Discarded) then begin

                    CommEntry.Init();
                    CommEntry."Source Type" := CommEntry."Source Type"::Customer;
                    CommEntry."Source ID" := Customer."No.";
                    CommEntry."Source Name" := Customer.Name;
                    CommEntry."Record Type" := commEntry."Record Type"::SOC;
                    CommEntry."Record Table No." := Database::"Sales Shipment Header";
                    CommEntry."Record No." := Header."No.";
                    CommEntry.Direction := CommEntry.Direction::Outbound;
                    CommEntry.MessageContent := CopyStr(HTMLBuilder.ToText(), 1, 2048);
                    CommEntry.Method := CommEntry.Method::EMAIL;
                    CommEntry.Insert();

                    Exit(True)
                end;
            end

        end;

        Window.Close();

    end;

    /// <summary> 
    /// Description for Setup and send a single notification
    /// </summary>
    /// <param name="RefNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure SendOneShipmentNotificationEmail(RefNo: Code[20]): Boolean
    var
        CLib: CodeUnit "TFB Common Library";
        Window: Dialog;
        Result: Boolean;
        SubTitleTxt: Label '';
        Text001Msg: Label 'Sending Shipment Notification:\#1############################', Comment = '%1=Shipment Number';
        TitleTxt: Label 'Order Status Update';
    begin

        Window.Open(Text001Msg);
        Window.Update(1, STRSUBSTNO('%1 %2', RefNo, ''));
        Result := SendShipmentNotificationEmail(RefNo, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt));
        Exit(Result);
    end;

    local procedure AddLocationContactRecipient(var Recipients: List of [Text]; var Shipment: Record "Sales Shipment Header")

    var
        CompanyContact: Record Contact;
        Customer: Record Customer;
        Location: Record "Ship-to Address";
        OtherContacts: Record Contact;
        PrimaryContact: Record Contact;
        Responsibility: record "Contact Job Responsibility";
        SalesSetup: Record "Sales & Receivables Setup";


    begin

        If Location.get(Shipment."Ship-to Code") then
            If Location."TFB Notify Contact" then
                If not Recipients.Contains(Location."E-Mail") then
                    Recipients.Add(Location."E-Mail");

        //Find any designated people and also add them to recipient list
        Customer.Get(Shipment."Sell-to Customer No.");
        PrimaryContact.Get(Customer."Primary Contact No.");
        CompanyContact.Get(PrimaryContact."Company No.");

        OtherContacts.SetRange("Company No.", CompanyContact."No.");

        //Iterate through other contacts with the same company contact to check for their purchasing responsibilities
        if OtherContacts.FindSet() then begin

            SalesSetup.Get();
            repeat
                If SalesSetup."TFB PL Def. Job Resp. Rec." <> '' then begin
                    Responsibility.SetRange("Job Responsibility Code", SalesSetup."TFB ASN Def. Job Resp. Rec.");
                    Responsibility.SetRange("Contact No.", OtherContacts."No.");

                    If not Responsibility.IsEmpty() then

                        //Contact has purchasing responsibility
                        If not Recipients.Contains(OtherContacts."E-Mail") then

                            //New email address is found and needs to be added
                            Recipients.Add(OtherContacts."E-Mail");

                end;

            until OtherContacts.Next() < 1;
        end;

    end;

    /// <summary> 
    /// Sends a transaction email to customer notifying them of a shipment
    /// </summary>
    /// <param name="RefNo">Parameter of type Code[20].</param>
    /// <param name="HTMLTemplate">Parameter of type Text.</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure SendShipmentNotificationEmail(RefNo: Code[20]; HTMLTemplate: Text): Boolean

    var
        CommEntry: Record "TFB Communication Entry";
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        DocAttachment: Record "Document Attachment";
        LedgerEntry: Record "Item Ledger Entry";
        LotInfo: Record "Lot No. Information";
        PurchaseLine: Record "Purchase Line";
        Shipment: Record "Sales Shipment Header";
        ShipmentLine: Record "Sales Shipment Line";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        PersBlobCU: CodeUnit "Persistent Blob";
        TempBlobCU2: CodeUnit "Temp Blob";
        TempBlobCU: Codeunit "Temp Blob";
        TempBlobAtc: Array[10] of Codeunit "Temp Blob";
        InStream, InStream2 : InStream;
        OutStream, OutStream2 : Outstream;
        inStreamReportAtc: Array[10] of InStream;
        outStreamReportAtc: Array[10] of OutStream;
        Ref: BigInteger;
        LastLotNo: Code[50];
        LoopCount, i : Integer;
        EmailScenEnum: Enum "Email Scenario";
        BCCRecipients: List of [Text];
        CCRecipients: List of [Text];
        EmailID: Text;
        Recipients: List of [Text];
        FileNameBuilder: TextBuilder;
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;





    begin

        CompanyInfo.Get();

        If not Shipment.Get(RefNo) then
            exit(false);

        If not Customer.Get(Shipment."Sell-to Customer No.") then
            exit(false);

        If Customer."E-Mail" = '' then
            exit(false);


        LastLotNo := '';
        EmailID := Customer."E-Mail";

        SubjectNameBuilder.Append(StrSubstNo('Shipment Notification related to %1 from TFB Trading', getShipmentReferenceNo(Shipment)));

        If Customer."TFB CoA Required" then
            SubjectNameBuilder.Append(' [COA Requested]');

        Recipients.Add(EmailID);

        //Add location email address
        AddLocationContactRecipient(Recipients, Shipment);



        HTMLBuilder.Append(HTMLTemplate);

        //Check that content has been generated to send
        If GenerateShipmentNotificationContent(RefNo, HTMLBuilder) then
            If (Customer."TFB CoA Required") and ((Customer."TFB CoA Alt. Email") <> '') then
                CCRecipients.Add(Customer."TFB CoA Alt. Email");

        EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true, CCRecipients, BCCRecipients);


        If (Customer."TFB CoA Required") then begin
            //Perform additional functionality to send CoA


            Clear(ShipmentLine);
            ShipmentLine.SetRange("Document No.", RefNo);

            i := 1; //set loop for PO attachments
            if ShipmentLine.FindSet(false, false) then
                repeat

                    //Retrieve SalesOrder to get External Document No
                    //Find Lines for Shipment
                    Clear(LedgerEntry);
                    LedgerEntry.SetRange("Source Type", LedgerEntry."Source Type"::Customer);
                    LedgerEntry.SetRange("Document Type", LedgerEntry."Document Type"::"Sales Shipment");
                    LedgerEntry.SetRange("Document No.", ShipmentLine."Document No.");
                    LedgerEntry.SetRange("Document Line No.", ShipmentLine."Line No.");

                    If LedgerEntry.FindSet(false, false) then
                        repeat

                            If LastLotNo <> LedgerEntry."Lot No." then begin
                                //Get Lot Info
                                Clear(LotInfo);
                                LotInfo.SetRange("Item No.", LedgerEntry."Item No.");
                                LotInfo.SetRange("Lot No.", LedgerEntry."Lot No.");
                                LotInfo.SetRange("Variant Code", LedgerEntry."Variant Code");

                                If LotInfo.FindFirst() then begin

                                    //Indicate that Lot COA has been found
                                    LoopCount := LoopCount + 1;

                                    Ref := LotInfo."TFB CoA Attach.";

                                    If (Ref > 0) and (PersBlobCU.Exists(Ref)) then begin
                                        //Add attachmemnt details

                                        TempBlobCU.CreateOutStream(OutStream);
                                        PersBlobCU.CopyToOutStream(Ref, OutStream);
                                        TempBlobCU.CreateInStream(InStream);

                                        Clear(FileNameBuilder);
                                        FileNameBuilder.Append('CoA_');
                                        FileNameBuilder.Append(LotInfo."Item No.");
                                        FileNameBuilder.Append(LotInfo."Variant Code");
                                        FileNameBuilder.Append('_' + LotInfo."Lot No.");
                                        FileNameBuilder.Append('.pdf');

                                        EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/pdf', InStream);



                                    end;

                                    Ref := LotInfo."TFB OPC Attach.";


                                    Clear(FileNameBuilder);

                                    If (Ref > 0) and (PersBlobCU.Exists(Ref)) then begin
                                        //Add attachmemnt details

                                        TempBlobCU2.CreateOutStream(OutStream2);
                                        PersBlobCU.CopyToOutStream(Ref, OutStream2);
                                        TempBlobCU2.CreateInStream(InStream2);
                                        Clear(FileNameBuilder);
                                        FileNameBuilder.Append('Organic_');
                                        FileNameBuilder.Append(LotInfo."Item No.");
                                        FileNameBuilder.Append(LotInfo."Variant Code");
                                        FileNameBuilder.Append('_' + LotInfo."Lot No.");
                                        FileNameBuilder.Append('.pdf');

                                        EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/pdf', InStream2);
                                    end;

                                end;
                            end;

                            LastLotNo := LedgerEntry."Lot No.";
                        until LedgerEntry.Next() < 1;

                    //Check to see if drop shipment with current PO

                    If (ShipmentLine."Drop Shipment") and (ShipmentLine."Purchase Order No." <> '') then
                        If PurchaseLine.Get(PurchaseLine."Document Type"::Order, ShipmentLine."Purchase Order No.", ShipmentLine."Purch. Order Line No.") then begin
                            PurchaseLine.CalcFields("Attached Doc Count");
                            If PurchaseLine."Attached Doc Count" > 0 then begin
                                DocAttachment.SetRange("Table ID", 39);
                                DocAttachment.SetRange("No.", PurchaseLine."Document No.");
                                DocAttachment.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                                DocAttachment.SetRange("Line No.", PurchaseLine."Line No.");

                                If DocAttachment.FindSet(false, false) then
                                    repeat
                                        If DocAttachment."Document Reference ID".HasValue then begin
                                            TempBlobAtc[i].CreateOutStream(outStreamReportAtc[i]);
                                            TempBlobAtc[i].CreateInStream(inStreamReportAtc[i]);
                                            Clear(FileNameBuilder);
                                            FileNameBuilder.Append('COA_');
                                            FileNameBuilder.Append(PurchaseLine."No.");
                                            FileNameBuilder.Append('_' + format(i));
                                            FileNameBuilder.Append('.' + DocAttachment."File Extension");
                                            if DocAttachment."Document Reference ID".ExportStream(outStreamReportAtc[i]) then
                                                //Mail Attachments
                                                EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/pdf', inStreamReportAtc[i]);

                                            i += 1;
                                        end;

                                    until DocAttachment.Next() < 1;


                            end;
                        end;


                until ShipmentLine.Next() < 1;
        end;



        Email.Enqueue(EmailMessage, EmailScenEnum::Logistics);


        CommEntry.Init();
        CommEntry."Source Type" := CommEntry."Source Type"::Customer;
        CommEntry."Source ID" := Customer."No.";
        CommEntry."Source Name" := Customer.Name;
        CommEntry."Record Type" := commEntry."Record Type"::ASN;
        CommEntry."Record Table No." := Database::"Sales Shipment Header";
        CommEntry."Record No." := Shipment."No.";
        CommEntry.Direction := CommEntry.Direction::Outbound;
        CommEntry.MessageContent := CopyStr(HTMLBuilder.ToText(), 1, 2048);
        CommEntry.Method := CommEntry.Method::EMAIL;
        CommEntry.Insert();

        Exit(True)

    end;



    local procedure GenerateShipmentStatusQueryContent(ContactName: Text; Reference: Text; Reference2: Text; CustomerName: Text; var HTMLBuilder: TextBuilder): Boolean

    var
        BodyBuilder: TextBuilder;



    begin
        HTMLBuilder.Replace('%{ExplanationCaption}', 'Request Type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Status Update for Shipped Goods');
        HTMLBuilder.Replace('%{DateCaption}', 'Requested on');
        HTMLBuilder.Replace('%{DateValue}', format(today()));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'Order details');
        HTMLBuilder.Replace('%{ReferenceValue}', Reference);

        BodyBuilder.AppendLine(StrSubstNo('<h2>We have a customer query against shipment %1 for customer %2.</h2>', Reference, CustomerName));
        If Reference2 <> '' then
            BodyBuilder.AppendLine(StrSubstNo('<p>You can also cross reference against <b>%1</b> to verify the request', Reference2));
        BodyBuilder.AppendLine(StrSubstNo('<p>This email is intended for <b>%1</b>. If you have received this in error please let us know', ContactName));
        BodyBuilder.AppendLine('<br><br>');
        BodyBuilder.AppendLine(StrSubstNo('Our customer wants to know the status of the shipment and for us to provide a Proof of Delivery (POD)'));
        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        Exit(true);

    end;



    /// <summary> 
    /// Description for Generate Shipment Notification Content to HTML Builder variable that is passed
    /// </summary>
    /// <param name="RefNo">Parameter of type Code[20].</param>
    /// <param name="HTMLBuilder">Parameter of type TextBuilder.</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure GenerateShipmentNotificationContent(RefNo: Code[20]; var HTMLBuilder: TextBuilder): Boolean

    var
        CustCalendarChange: Array[2] of Record "Customized Calendar Change";
        Customer: Record Customer;
        Header: Record "Sales Shipment Header";
        Item: Record Item;
        Line: Record "Sales Shipment Line";
        OrderLine: Record "Sales Line";
        Purchase: Record "Purchase Header";
        ShippingAgent: Record "Shipping Agent";
        UoM: Record "Unit of Measure";
        Vendor: Record Vendor;
        CalMgmt: CodeUnit "Calendar Management";
        SuppressLine, PendingLines : Boolean;
        ExpectedDate: Date;
        LineCount: Integer;
        SourceLineNo: List of [Integer];
        ShippingAgentName: Text;
        tdTxt: label '<td valign="top" style="line-height:15px;">%1</td>', comment = '%1=table data html';
        BodyBuilder: TextBuilder;
        CommentBuilder: TextBuilder;
        LineBuilder: TextBuilder;
        ReferenceBuilder: TextBuilder;
        TempBodyBuilder: TextBuilder;




    begin

        //Start with content introducing customer

        If not Header.Get(RefNo) then
            exit(false);

        If not Customer.Get(Header."Sell-to Customer No.") then
            exit(false);

        Clear(Line);
        Line.SetRange("Document No.", RefNo);
        Line.SetRange(Type, Line.Type::Item);
        Line.SetFilter("Quantity (Base)", '>0');



        If Line.FindSet(false) then begin

            HTMLBuilder.Replace('%{ExplanationCaption}', 'Notification type');
            HTMLBuilder.Replace('%{ExplanationValue}', 'Shipment notification');
            HTMLBuilder.Replace('%{DateCaption}', 'Shipped On');
            HTMLBuilder.Replace('%{DateValue}', Format(Header."Posting Date", 0, 4));
            HTMLBuilder.Replace('%{ReferenceCaption}', 'Order References');
            ReferenceBuilder.Append(StrSubstNo('Our order %1', Line."Order No."));

            If Header."External Document No." <> '' then
                ReferenceBuilder.Append(StrSubstNo(' and <b>your PO#</b> is %1', Header."External Document No."));

            if (Header."TFB 3PL Booking No." <> '') and (not Line."Drop Shipment") then
                ReferenceBuilder.Append(StrSubstNo('.Connote may also show ref no. %1 from our 3PL</h3>', Header."TFB 3PL Booking No."));

            HTMLBuilder.Replace('%{ReferenceValue}', ReferenceBuilder.ToText());

            If (Customer."TFB CoA Required") then
                if not Line."Drop Shipment" then
                    HTMLBuilder.Replace('%{AlertText}', 'Certificates of Analysis should be included as requested.')
                else
                    HTMLBuilder.Replace('%{AlertText}', 'Certificates of Analysis will be requested from dropship supplier as requested')
            else
                HTMLBuilder.Replace('%{AlertText}', '');

            BodyBuilder.AppendLine('<table class="tfbdata" role="presentation" width="100%" cellspacing="0" cellpadding="10" border="0">');
            BodyBuilder.AppendLine('<thead>');

            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="40%">Item Desc.</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Qty Ordered</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Weight</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="40%">Comments</th></thead>');

            repeat
                SuppressLine := false;
                Item.Get(Line."No.");

                If Item.Type = Item.Type::Inventory then begin



                    UoM.Get(Item."Base Unit of Measure");
                    Clear(LineBuilder);
                    Clear(CommentBuilder);
                    //BodyBuilder.AppendLine('<tr>');
                    LineBuilder.AppendLine('<tr>');
                    LineBuilder.Append(StrSubstNo(tdTxt, Line.Description));
                    LineBuilder.Append(StrSubstNo(tdTxt, Line."Quantity (Base)"));
                    LineBuilder.Append(StrSubstNo(tdTxt, Format(Line."Net Weight" * Line.Quantity) + 'kg'));




                    If Line."Drop Shipment" then begin
                        CommentBuilder.Append('Drop shipped against supplier PO No. ' + Line."Purchase Order No." + '</br>');

                        Purchase.SetRange("Document Type", Purchase."Document Type"::Order);
                        Purchase.SetRange("No.", Line."Purchase Order No.");

                        If Purchase.FindFirst() then
                            If Vendor.Get(Purchase."Buy-from Vendor No.") then
                                If Vendor."TFB Delivery SLA" <> '' then begin
                                    If ShippingAgent.Get(Vendor."Shipping Agent Code") then
                                        ShippingAgentName := ShippingAgent.Name
                                    else
                                        ShippingAgentName := 'unknown';

                                    CommentBuilder.Append(StrSubstNo('Supplier has delivery SLA of %1 and uses %2 for freight', vendor."TFB Delivery SLA", ShippingAgent.Name));
                                    If (ShippingAgent."Internet Address" <> '') and (Header."Package Tracking No." <> '') then
                                        CommentBuilder.Append(StrSubstNo('<p>. Tracking No is <b>%1</b> </p>', Header."Package Tracking No."))
                                end;
                    end
                    else begin
                        //Add details on expected arrival
                        ShippingAgent.Get(Header."Shipping Agent Code");

                        CustCalendarChange[1].Description := 'Source';
                        CustCalendarChange[1]."Source Type" := CustCalendarChange[1]."Source Type"::"Shipping Agent";
                        CustCalendarChange[1]."Source Code" := ShippingAgent.Code;
                        CustCalendarChange[1]."Additional Source Code" := Header."Shipping Agent Service Code";

                        CustCalendarChange[2].Description := 'Customer';
                        CustCalendarChange[2]."Source Type" := CustCalendarChange[2]."Source Type"::Customer;
                        CustCalendarChange[2]."Source Code" := Header."Sell-to Customer No.";

                        ExpectedDate := CalMgmt.CalcDateBOC(format(Line."Shipping Time"), Header."Posting Date", CustCalendarChange, true);
                        If ExpectedDate = Header."Posting Date" then
                            CommentBuilder.AppendLine(StrSubstNo('Dispatched today for same delivery by %1.', ShippingAgent.Name))
                        else
                            CommentBuilder.Append(StrSubstNo('Expected delivery on %1 using %2', ExpectedDate, ShippingAgent.Name));

                    end;
                    LineBuilder.Append(StrSubstNo(tdTxt, CommentBuilder.ToText()));


                    LineBuilder.AppendLine('</tr>');
                    If not SuppressLine then begin
                        BodyBuilder.Append(LineBuilder.ToText());
                        PendingLines := true;
                        LineCount := LineCount + 1;
                        SourceLineNo.Add(Line."Order Line No.");
                    end;
                end;
            until Line.Next() < 1;

            BodyBuilder.AppendLine('</table>');


            //Now add content for items still not shipped

            OrderLine.SetRange("Document No.", Line."Order No.");
            OrderLine.SetRange(Type, OrderLine.Type::Item);
            OrderLine.SetRange("Completely Shipped", false);
            OrderLine.SetRange("Document Type", OrderLine."Document Type"::Order);

            if OrderLine.FindSet(false, false) then
                repeat

                    Clear(Item);
                    Item.Get(OrderLine."No.");

                    If Item.Type = Item.Type::Inventory then begin



                        UoM.Get(Item."Base Unit of Measure");
                        Clear(LineBuilder);
                        Clear(CommentBuilder);
                        Clear(TempBodyBuilder);
                        //BodyBuilder.AppendLine('<tr>');
                        LineBuilder.AppendLine('<tr>');
                        LineBuilder.Append(StrSubstNo(tdTxt, OrderLine.Description));
                        LineBuilder.Append(StrSubstNo(tdTxt, OrderLine."Outstanding Qty. (Base)"));
                        LineBuilder.Append(StrSubstNo(tdTxt, Format(OrderLine."Net Weight" * OrderLine."Outstanding Quantity") + 'kg'));




                        If OrderLine."Drop Shipment" then begin
                            CommentBuilder.Append('Item will be drop shipped against supplier PO No. ' + OrderLine."Purchase Order No." + '</br>');

                            Purchase.SetRange("Document Type", Purchase."Document Type"::Order);
                            Purchase.SetRange("No.", OrderLine."Purchase Order No.");

                            If Purchase.FindFirst() then
                                If Vendor.Get(Purchase."Buy-from Vendor No.") then
                                    If Vendor."TFB Delivery SLA" <> '' then begin
                                        If ShippingAgent.Get(Vendor."Shipping Agent Code") then
                                            ShippingAgentName := ShippingAgent.Name
                                        else
                                            ShippingAgentName := 'unknown';

                                        CommentBuilder.Append(StrSubstNo('Supplier has delivery SLA of %1 and uses %2 for freight', vendor."TFB Delivery SLA", ShippingAgent.Name));


                                    end;
                        end
                        else begin
                            //Add details on expected arrival
                            ShippingAgent.Get(Header."Shipping Agent Code");
                            ExpectedDate := OrderLine."Planned Delivery Date";
                            CommentBuilder.Append(StrSubstNo('Expected delivery on %1 using %2', ExpectedDate, ShippingAgent.Name));

                        end;
                        LineBuilder.Append(StrSubstNo(tdTxt, CommentBuilder.ToText()));


                        LineBuilder.AppendLine('</tr>');
                        If (not SuppressLine) or (not SourceLineNo.Contains(OrderLine."Line No.")) then begin
                            TempBodyBuilder.Append(LineBuilder.ToText());
                            PendingLines := true;
                            LineCount := LineCount + 1;
                        end;
                    end;

                until OrderLine.Next() < 1;

            //TODO Need to investigate why following section is always shown when doing a drop shipment
            /*    If PendingLines then begin
                   BodyBuilder.AppendLine(StrSubstNo('<H3> Items not yet shipped from order</H3>'));
                   BodyBuilder.AppendLine('<table class="tfbdata" width="100%" cellspacing="0" cellpadding="10" border="0">');
                   BodyBuilder.AppendLine('<thead>');

                   BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="50%">Item Desc.</th>');
                   BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="12%">Qty Ordered</th>');
                   BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="12%">Weight</th>');
                   BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="26%">Comments</th></thead>');
                   BodyBuilder.Append(TempBodyBuilder.ToText());
                   BodyBuilder.AppendLine('</table>');
               end; */


        end;
        If not PendingLines then
            BodyBuilder.AppendLine('<h2>No shipment details found. Please contact TFB for more info</h2>');

        If LineCount > 0 then begin
            HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
            Exit(true);
        end
        else
            Exit(false);
    end;

    procedure CheckIfSent(RefNo: Code[20]): Boolean

    var
        CommEntry: record "TFB Communication Entry";
        Header: record "Sales Shipment Header";

    begin

        If not Header.Get(RefNo) then
            exit(false);

        CommEntry.SetRange("Record Type", CommEntry."Record Type"::ASN);
        Commentry.SetRange("Record No.", Header."No.");
        CommEntry.SetRange("Record Table No.", Database::"Sales Shipment Header");
        CommEntry.SetRange(Direction, CommEntry.Direction::Outbound);

        If not CommEntry.IsEmpty() then
            Exit(true)
        else
            Exit(False);
    end;

    procedure AddCoAToShipmentStatusEmail(RefNo: Code[20]; var EmailMessage: CodeUnit "Email Message"): Boolean

    var
        Customer: Record Customer;
        LedgerEntry: Record "Item Ledger Entry";
        LotInfo: Record "Lot No. Information";
        ShipmentLine: Record "Sales Shipment Line";
        PersBlobCU: CodeUnit "Persistent Blob";
        TempBlobCU: CodeUnit "Temp Blob";
        InStream: InStream;
        OutStream: Outstream;
        Ref: BigInteger;
        LastLotNo: Code[50];
        LoopCount: Integer;
        FileNameBuilder: TextBuilder;

    begin


        ShipmentLine.SetRange("Document No.", RefNo);
        LastLotNo := '';

        if ShipmentLine.FindSet(false, false) then
            repeat

                //Double check
                If Customer.Get(ShipmentLine."Sell-to Customer No.") then begin
                    If not Customer."TFB CoA Required" then
                        Exit(false)

                end
                else
                    Exit(false);

                //Check to See if Customer wants COA's


                //Retrieve SalesOrder to get External Document No
                //Find Lines for Shipment
                LedgerEntry.SetRange("Source Type", LedgerEntry."Source Type"::Customer);
                LedgerEntry.SetRange("Document Type", LedgerEntry."Document Type"::"Sales Shipment");
                LedgerEntry.SetRange("Document No.", ShipmentLine."Document No.");
                LedgerEntry.SetRange("Document Line No.", ShipmentLine."Line No.");

                If LedgerEntry.FindSet(false, false) then
                    repeat

                        If LastLotNo <> LedgerEntry."Lot No." then begin
                            //Get Lot Info
                            LotInfo.SetRange("Item No.", LedgerEntry."Item No.");
                            LotInfo.SetRange("Lot No.", LedgerEntry."Lot No.");
                            LotInfo.SetRange("Variant Code", LedgerEntry."Variant Code");

                            If LotInfo.FindFirst() then begin

                                //Indicate that Lot COA has been found
                                LoopCount := LoopCount + 1;
                                Clear(InStream);
                                Ref := LotInfo."TFB CoA Attach.";

                                If (Ref > 0) and PersBlobCU.Exists(Ref) then begin
                                    //Add attachmemnt details

                                    Clear(FileNameBuilder);
                                    FileNameBuilder.Append('CoA_');
                                    FileNameBuilder.Append(LotInfo."Item No.");
                                    FileNameBuilder.Append(LotInfo."Variant Code");
                                    FileNameBuilder.Append('_' + LotInfo."Lot No.");
                                    FileNameBuilder.Append('.pdf');

                                    TempBlobCU.CreateInStream(InStream);
                                    TempBlobCU.CreateOutStream(OutStream);
                                    PersBlobCU.CopyToOutStream(Ref, OutStream);
                                    CopyStream(Outstream, Instream);

                                    EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/pdf', InStream);


                                end;

                            end;
                        end;

                        LastLotNo := LedgerEntry."Lot No.";
                    until LedgerEntry.Next() < 1;

            until ShipmentLine.Next() < 1;

    end;


    procedure GetItemChargesForSalesShipment(DocNo: Code[20]; LineNo: Integer; ChargeCode: Code[20]): Decimal

    var
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        TotalCharge: Decimal;

    begin

        //Find corresponding item ledger entry
        ItemLedger.SetRange("Document No.", DocNo);
        ItemLedger.SetRange("Document Line No.", LineNo);
        ItemLedger.SetRange("Document Type", ItemLedger."Document Type"::"Sales Shipment");

        If ItemLedger.FindSet(false) then
            repeat

                Clear(ValueEntry);
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
                ValueEntry.SetRange("Item Ledger Entry No.", ItemLedger."Entry No.");
                ValueEntry.SetRange("Item Charge No.", ChargeCode);
                ValueEntry.CalcSums("Cost Amount (Non-Invtbl.)"); //Total up values in column
                TotalCharge += ValueEntry."Cost Amount (Non-Invtbl.)"; //Add up value entry assigned

            until ItemLedger.Next() < 1;

        Exit(TotalCharge);
    end;

    procedure GetItemChargesForSalesShipment(DocNo: Code[20]; ChargeCode: Code[20]): Decimal

    var
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        TotalCharge: Decimal;

    begin

        //Find corresponding item ledger entry
        ItemLedger.SetRange("Document No.", DocNo);
        ItemLedger.SetRange("Document Type", ItemLedger."Document Type"::"Sales Shipment");

        If ItemLedger.FindSet(false) then
            repeat

                Clear(ValueEntry);
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
                ValueEntry.SetRange("Item Ledger Entry No.", ItemLedger."Entry No.");
                ValueEntry.SetRange("Item Charge No.", ChargeCode);
                ValueEntry.CalcSums("Cost Amount (Non-Invtbl.)"); //Total up values in column
                TotalCharge += ValueEntry."Cost Amount (Non-Invtbl.)"; //Add up value entry assigned

            until ItemLedger.Next() < 1;

        Exit(TotalCharge);
    end;

    procedure OpenItemChargesForSalesShipment(DocNo: Code[20]; LineNo: Integer; ChargeCode: Code[20]): Decimal

    var
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ValueEntries: Page "Value Entries";
        LedgerEntryFilter: TextBuilder;


    begin

        //Find corresponding item ledger entry
        ItemLedger.SetRange("Document No.", DocNo);
        ItemLedger.SetRange("Document Line No.", LineNo);
        ItemLedger.SetRange("Document Type", ItemLedger."Document Type"::"Sales Shipment");

        If ItemLedger.FindSet(false) then
            repeat
                If LedgerEntryFilter.Length() > 0 then
                    LedgerEntryFilter.Append('|');

                LedgerEntryFilter.Append(Format(ItemLedger."Entry No."));

            until ItemLedger.Next() < 1;

        Clear(ValueEntry);
        If LedgerEntryFilter.Length() > 0 then begin
            ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
            ValueEntry.SetFilter("Item Ledger Entry No.", LedgerEntryFilter.ToText());
            ValueEntry.SetRange("Item Charge No.", ChargeCode);

            ValueEntries.SetTableView(ValueEntry);
            ValueEntries.Run();
        end;

    end;

    procedure OpenItemChargesForSalesShipment(DocNo: Code[20]; ChargeCode: Code[20]): Decimal

    var
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ValueEntries: Page "Value Entries";
        LedgerEntryFilter: TextBuilder;


    begin

        //Find corresponding item ledger entry
        ItemLedger.SetRange("Document No.", DocNo);
        ItemLedger.SetRange("Document Type", ItemLedger."Document Type"::"Sales Shipment");

        If ItemLedger.FindSet(false) then
            repeat
                If LedgerEntryFilter.Length() > 0 then
                    LedgerEntryFilter.Append('|');

                LedgerEntryFilter.Append(Format(ItemLedger."Entry No."));

            until ItemLedger.Next() < 1;

        Clear(ValueEntry);
        If LedgerEntryFilter.Length() > 0 then begin
            ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
            ValueEntry.SetFilter("Item Ledger Entry No.", LedgerEntryFilter.ToText());
            ValueEntry.SetRange("Item Charge No.", ChargeCode);

            ValueEntries.SetTableView(ValueEntry);
            ValueEntries.Run();
        end;

    end;

    procedure RetrieveWhseShipReference(ShipmentNo: Code[20]): Code[20]

    var
        WhseHeader: Record "Posted Whse. Shipment Header";
        WhseLines: Record "Posted Whse. Shipment Line";

    begin

        WhseLines.SetRange("Posted Source No.", ShipmentNo);
        WhseLines.SetRange("Posted Source Document", WhseLines."Posted Source Document"::"Posted Shipment");

        If WhseLines.FindFirst() then
            If WhseHeader.Get(WhseLines."No.") then
                Exit(WhseHeader."Whse. Shipment No.");




    end;


    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Shipment Header - Edit", 'OnBeforeSalesShptHeaderModify', '', false, false)]
    local procedure HandeShipmentHeaderUpdate(FromSalesShptHeader: Record "Sales Shipment Header"; var SalesShptHeader: Record "Sales Shipment Header")

    var
        ShptLine: Record "Sales Shipment Line";

    begin

        SalesShptHeader."TFB 3PL Booking No." := FromSalesShptHeader."TFB 3PL Booking No.";

        ShptLine.SetRange("Document No.", SalesShptHeader."No.");

        if ShptLine.FindSet() then
            repeat

                ShptLine."TFB 3PL Booking No" := FromSalesShptHeader."TFB 3PL Booking No.";
                ShptLine.Modify();

            until ShptLine.Next() < 1;



    end;

}
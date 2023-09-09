codeunit 50107 "TFB Item Mgmt"
{
    trigger OnRun()
    begin


    end;



    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterCopyFromItem', '', true, true)]

    local procedure HandleOnAfterCopyFromItem(Item: Record Item; var SalesLine: Record "Sales Line")

    var
        NotificationId: Guid;

    begin
        //SalesLine.Validate("Purchasing Code", Item."TFB Default Purch. Code"); //No longer required
        UpdateDropShipSalesLineAgent(Item, SalesLine);

        CheckAndWarnIfItemOnQuote(Item, SalesLine, NotificationId);
    end;



    procedure DownloadItemSpecification(Item: Record Item)


    var
        CommonCU: CodeUnit "TFB Common Library";
        TempBlobCU: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;

    begin

        TempBlobCU := CommonCU.GetSpecificationTempBlob(Item);
        TempBlobCu.CreateInStream(InStream);
        FileName := StrSubstNo('Spec For %1 (%2).pdf', Item.Description, Item."No.");
        if not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
            Error('File %1 not downloaded', FileName);

    end;

    internal procedure UpdateDropShipSalesLineAgent(Item: Record Item; var SalesLine: Record "Sales Line"): Boolean

    var
        Vendor: Record Vendor;
        ShippingAgent: Record "Shipping Agent";
        AgentServices: Record "Shipping Agent Services";
        PostcodeZone: Record "TFB Postcode Zone";

    begin
        if Item.Get(SalesLine."No.") then
            if SalesLine."Drop Shipment" = true then

                //Check if there is an override shipping agent and service

                if Vendor.Get(Item."Vendor No.") then
                    if GetZoneRateForSalesLine(SalesLine, PostcodeZone) then
                        if GetVendorShippingAgentOverride(Vendor."No.", PostcodeZone.Code, AgentServices) then begin
                            SalesLine.Validate("Shipping Agent Code", AgentServices."Shipping Agent Code");
                            Salesline.validate("Shipping Agent Service Code", AgentServices.Code);
                        end
                        else
                            //if no override exists but here is a valid vendor then use default service for vendor
                            if ShippingAgent.Get(Vendor."Shipping Agent Code") then begin
                                SalesLine.Validate("Shipping Agent Code", ShippingAgent.Code);
                                Salesline.validate("Shipping Agent Service Code", ShippingAgent."TFB Service Default");
                            end;

    end;

    internal procedure DownloadItemMSDS(Item: Record Item)

    var
        CoreSetup: Record "TFB Core Setup";

        WordTemplate: CodeUnit "Word Template";

        InStream: InStream;
        FileName: Text;
        NoTemplateSetupMsg: Label 'No word template has been configured in inventory setup for the MSDS';
        NoRecordsSelectedMsg: Label 'No records have been selected for the merge';
    begin
        Item.SetRecFilter();
        CoreSetup.Get();
        if CoreSetup."MSDS Word Template" = '' then begin
            Message(NoTemplateSetupMsg);
            exit;
        end;

        if Item.Count = 0 then begin
            Message(NoRecordsSelectedMsg);
            exit;
        end;

        WordTemplate.Load(CoreSetup."MSDS Word Template");
        if Item.Count > 1 then
            WordTemplate.Merge(Item, true, Enum::"Word Templates Save Format"::PDF)
        else
            WordTemplate.Merge(Item, false, Enum::"Word Templates Save Format"::PDF);

        WordTemplate.GetDocument(InStream);

        if Item.Count > 1 then
            FileName := StrSubstNo('MSDS Collection on %1.zip', today)
        else
            FileName := StrSubstNo('MSDS for %1 (%2).pdf', Item.Description, Item."No.");
        if not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
            Error('File %1 not downloaded', FileName);
    end;

    internal procedure EmailSpecification(var Item: Record Item; Recipients: List of [Text]; HTMLTemplate: Text; ContactIds: List of [Guid])

    var

        CommonCU: CodeUnit "TFB Common Library";
        TempBlobCU: Codeunit "Temp Blob";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        InStream: InStream;

        FileNameBuilder: TextBuilder;
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;
        ContactID: Guid;

    begin

        HTMLBuilder.Append(HTMLTemplate);


        GenerateItemSpecificationDocumentsContent(Item, HTMLBuilder);
        EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);



        if Item.Findset(false) then
            repeat
                TempBlobCU := CommonCU.GetSpecificationTempBlob(Item);
                if TempBlobCU.HasValue() then begin
                    TempBlobCu.CreateInStream(InStream);
                    Clear(FileNameBuilder);
                    FileNameBuilder.Append(StrSubstNo('Spec For %1 (%2).pdf', Item.Description, Item."No."));
                    EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/PDF', InStream);
                end;
            until Item.Next() < 1;

        foreach ContactID in ContactIds do

            Email.AddRelation(EmailMessage, Database::Contact, ContactID, Enum::"Email Relation Type"::"Related Entity", enum::"Email Relation Origin"::"Compose Context");



        Email.OpenInEditorModally(EmailMessage, Enum::"Email Scenario"::Quality)


    end;

    internal procedure SendShelfExtensionEmail(Rec: Record "Item Ledger Entry")

    var
        Customer: Record Customer;
        CoreSetup: Record "TFB Core Setup";
        WordTemplate: CodeUnit "Word Template";
        EmailMessage: CodeUnit "Email Message";
        Email: CodeUnit Email;
        Recipient: List of [Text];
        InStream: InStream;

    begin
        CoreSetup.SetLoadFields("Shelf Life Word Template");
        CoreSetup.Get();
        Customer.SetLoadFields("E-Mail", "TFB CoA Alt. Email");
        Customer.Get(Rec."Source No.");

        WordTemplate.Load(CoreSetup."Shelf Life Word Template");
        WordTemplate.Merge(Rec, false, Enum::"Word Templates Save Format"::PDF);
        WordTemplate.GetDocument(InStream);
        Rec.SetRecFilter();
        Recipient.Add(Customer."E-Mail");
        Recipient.Add(Customer."TFB CoA Alt. Email");
        EmailMessage.Create(Recipient, StrSubstNo('Shelf life extension letter for %1 - Lot %2', Rec.Description, Rec."Lot No."), 'Details about the shelf life extension', true);
        EmailMessage.AddAttachment(StrSubstNo('Shelf Life Extension %1 - %2.pdf', Rec.Description, Rec."Lot No."), 'Application/PDF', InStream);
        Email.AddRelation(EmailMessage, Database::"Item Ledger Entry", Rec.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::Customer, Customer.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        if not (Email.OpenInEditorModally(EmailMessage, Enum::"Email Scenario"::Logistics) = Enum::"Email Action"::Discarded) then begin


        end;
    end;

    procedure SendSelectedItemSpecifications(var Item: Record Item)

    var
        Contact: Record Contact;

        CLib: CodeUnit "TFB Common Library";
        ItemMgmt: CodeUnit "TFB Item Mgmt";
        ContactList: Page "Contact List";
        Recipients: List of [Text];
        ContactIds: List of [Guid];
        SubTitleTxt: Label '';
        TitleTxt: Label 'Item Specifications';


    begin

        //Determine if multiple items have been selected


        if Item.Count() = 0 then exit;
        Contact.SetFilter("E-Mail", '>%1', '');
        ContactList.LookupMode(true);
        ContactList.SetTableView(Contact);

        if ContactList.RunModal() = Action::LookupOK then begin
            ContactList.getrecord(Contact);
            Contact.SetFilter("No.", ContactList.GetSelectionFilter());

            if Contact.Findset(false) then
                repeat
                    if Contact."E-Mail" <> '' then
                        if not Recipients.Contains(Contact."E-Mail") then begin
                            Recipients.Add(Contact."E-Mail");
                            ContactIds.Add(Contact.SystemId);
                        end;
                until Contact.Next() = 0;

            if Recipients.Count > 0 then
                ItemMgmt.EmailSpecification(Item, Recipients, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt), ContactIds);

        end;


    end;

    local procedure GetZoneRateForSalesLine(SalesLine: Record "Sales Line"; var PostcodeZone: Record "TFB Postcode Zone"): Boolean

    var
        SalesHeader: Record "Sales Header";

    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", SalesLine."Document No.");

        if SalesHeader.FindFirst() then begin

            PostcodeZone.SetRange("Customer Price Group", SalesHeader."Customer Price Group");

            if PostcodeZone.FindFirst() then
                exit(true);
        end;

    end;

    local procedure CheckAndWarnIfItemOnQuote(Item: Record Item; var SalesLine: Record "Sales Line"; var NotificationID: Guid)

    var

        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        NotificationOnQuote: Notification;
        QuoteDocumentNo: Code[20];
        NotificationMsg: Label 'This customer has a quote %1 that includes item %2 already.', Comment = '%1 = quote number, %2 = item name';

        NotificationFunctionTok: Label 'OpenExistingQuote';
        NotificationLbl: Label 'Open quote';
    begin

        if not (SalesLine."Document Type" = SalesLine."Document Type"::Order) then exit;

        if not quoteforitemexists(Item, SalesLine, QuoteDocumentNo) then exit;

        NotificationOnQuote.Id := NotificationID;
        NotificationOnQuote.Message := StrSubstNo(NotificationMsg, SalesLine.GetSalesHeader()."Sell-to Customer Name", SalesLine.Description);
        NotificationOnQuote.AddAction(NotificationLbl, CODEUNIT::"TFB Sales Order Notifications", NotificationFunctionTok);
        NotificationOnQuote.Scope := NOTIFICATIONSCOPE::LocalScope;
        NotificationOnQuote.SetData('DocumentNo', QuoteDocumentNo);
        NotificationLifecycleMgt.SendNotification(NotificationOnQuote, SalesLine.RecordId);
    end;

    local procedure quoteforitemexists(Item: record Item; var SalesLine: Record "Sales Line"; var QuoteDocumentNo: Code[20]): Boolean
    var
        SalesQuoteLine: Record "Sales Line";
    begin
        SalesQuoteLine.SetRange("Sell-to Customer No.", SalesLine."Sell-to Customer No.");
        SalesQuoteLine.SetRange("Document Type", SalesQuoteLine."Document Type"::Quote);
        SalesQuoteLine.SetRange("No.", Item."No.");

        if not SalesQuoteLine.FindFirst() then exit;

        QuoteDocumentNo := SalesQuoteLine."No.";
        exit(true);

    end;

    local procedure GenerateItemSpecificationDocumentsContent(var Item: Record Item; HTMLBuilder: TextBuilder): Boolean
    var

        BodyBuilder: TextBuilder;
        CommentBuilder: TextBuilder;
        LineBuilder: TextBuilder;
        tdTxt: label '<td valign="top" class="tfbdata" style="line-height:15px;">%1</td>', Comment = '%1=Table data html content';
    begin

        HTMLBuilder.Replace('%{ExplanationCaption}', 'Request Type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Item Specifications');
        HTMLBuilder.Replace('%{DateCaption}', 'Requested on');
        HTMLBuilder.Replace('%{DateValue}', format(today()));
        HTMLBuilder.Replace('%{ReferenceCaption}', '');
        HTMLBuilder.Replace('%{ReferenceValue}', '');
        HTMLBuilder.Replace('%{AlertText}', '');

        BodyBuilder.AppendLine(StrSubstNo('<h2>Please find selected item specifications</h2><br>'));

        BodyBuilder.AppendLine('<table class="tfbdata" width="60%" cellspacing="10" cellpadding="10" border="0">');
        BodyBuilder.AppendLine('<thead>');

        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="30%">Item Code</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="70%">Description</th>');

        if Item.Findset(false) then begin
            repeat

                Clear(LineBuilder);
                Clear(CommentBuilder);
                LineBuilder.AppendLine('<tr>');

                LineBuilder.Append(StrSubstNo(tdTxt, Item."No."));
                LineBuilder.Append(StrSubstNo(tdTxt, Item.Description));
                LineBuilder.AppendLine('</tr>');
                BodyBuilder.AppendLine(LineBuilder.ToText());

            until Item.Next() < 1;
            BodyBuilder.AppendLine('</table>');
        end
        else
            BodyBuilder.AppendLine('<h2>No item specifications selected</h2>');

        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        exit(true);
    end;

    procedure GetVendorShippingAgentOverride(VendorNo: Code[20]; ShippingZone: Code[20]; var ShippingAgentService: Record "Shipping Agent Services"): Boolean

    var
        VendorZoneRate: Record "TFB Vendor Zone Rate";

    begin

        VendorZoneRate.SetRange("Sales Type", VendorZoneRate."Sales Type"::All);
        VendorZoneRate.SetRange("Zone Code", ShippingZone);
        VendorZoneRate.SetRange("Vendor No.", VendorNo);

        if VendorZoneRate.FindFirst() then
            if VendorZoneRate."Agent Service Code" <> '' then
                exit(ShippingAgentService.Get(VendorZoneRate."Shipping Agent", VendorZoneRate."Agent Service Code"))
    end;

    procedure GetItemDynamicDetails(ItemNo: Code[20]; var SalesPrice: Decimal; var LastChanged: Date)

    var
        CoreSetup: Record "TFB Core Setup";
        Item: Record Item;
        PriceListLine: Record "Price List Line";

        PricingCU: CodeUnit "TFB Pricing Calculations";
    begin
        CoreSetup.Get();

        if (CoreSetup."Def. Customer Price Group" <> '') and Item.Get(ItemNo) then begin
            PriceListLine.SetRange("Asset No.", ItemNo);
            PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
            PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
            PriceListLine.Setrange(Status, PriceListLine.Status::Active);
            PriceListLine.SetRange("Source Type", PriceListLine."Source Type"::"Customer Price Group");
            PriceListLine.SetRange("Source No.", CoreSetup."Def. Customer Price Group");
            PriceListLine.SetFilter("Ending Date", '=%1|>=%2', 0D, WorkDate());


            if PriceListLine.FindLast() then begin
                SalesPrice := PricingCU.CalcPerKgFromUnit(PriceListLine."Unit Price", Item."Net Weight");
                LastChanged := PriceListLine."Starting Date";
            end;
        end;



    end;


    procedure GetItemDynamicDetails(ItemNo: Code[20]; CustNo: Code[20]; var SalesPrice: Decimal; var LastChanged: Date; var LastPricePaid: Decimal; var LastDatePurchased: Date)

    var

        SalesInvoiceLine: Record "Sales Invoice Line";
        Item: Record Item;
        PricingCU: CodeUnit "TFB Pricing Calculations";
    begin

        GetItemDynamicDetails(ItemNo, SalesPrice, LastChanged);


        SalesInvoiceLine.SetRange("Sell-to Customer No.", CustNo);
        SalesInvoiceLine.SetRange("No.", ItemNo);
        SalesInvoiceLine.SetCurrentKey("Posting Date");
        SalesInvoiceLine.SetAscending("Posting Date", false);

        if SalesInvoiceLine.FindFirst() and Item.Get(ItemNo) then begin
            LastPricePaid := PricingCU.CalcPerKgFromUnit(SalesInvoiceLine."Unit Price", SalesInvoiceLine."Net Weight");
            LastDatePurchased := SalesInvoiceLine."Posting Date";
        end;
    end;

}
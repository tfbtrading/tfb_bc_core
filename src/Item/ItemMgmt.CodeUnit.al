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
        If not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
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

                If Vendor.Get(Item."Vendor No.") then
                    If GetZoneRateForSalesLine(SalesLine, PostcodeZone) then
                        If GetVendorShippingAgentOverride(Vendor."No.", PostcodeZone.Code, AgentServices) then begin
                            SalesLine.Validate("Shipping Agent Code", AgentServices."Shipping Agent Code");
                            Salesline.validate("Shipping Agent Service Code", AgentServices.Code);
                        end
                        else
                            //if no override exists but here is a valid vendor then use default service for vendor
                            If ShippingAgent.Get(Vendor."Shipping Agent Code") then begin
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
        If CoreSetup."MSDS Word Template" = '' then begin
            Message(NoTemplateSetupMsg);
            exit;
        end;

        If Item.Count = 0 then begin
            Message(NoRecordsSelectedMsg);
            Exit;
        end;

        WordTemplate.Load(CoreSetup."MSDS Word Template");
        If Item.Count > 1 then
            WordTemplate.Merge(Item, true, Enum::"Word Templates Save Format"::PDF)
        else
            WordTemplate.Merge(Item, false, Enum::"Word Templates Save Format"::PDF);

        WordTemplate.GetDocument(InStream);

        If Item.Count > 1 then
            FileName := StrSubstNo('MSDS Collection on %1.zip', today)
        else
            FileName := StrSubstNo('MSDS for %1 (%2).pdf', Item.Description, Item."No.");
        If not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
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



        If Item.Findset(false) then
            repeat
                TempBlobCU := CommonCU.GetSpecificationTempBlob(Item);
                If TempBlobCU.HasValue() then begin
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


        If Item.Count() = 0 then exit;
        Contact.SetFilter("E-Mail", '>%1', '');
        ContactList.LookupMode(true);
        ContactList.SetTableView(Contact);

        If ContactList.RunModal() = Action::LookupOK then begin
            ContactList.getrecord(Contact);
            Contact.SetFilter("No.", ContactList.GetSelectionFilter());

            If Contact.Findset(false) then
                repeat
                    If Contact."E-Mail" <> '' then
                        If not Recipients.Contains(Contact."E-Mail") then begin
                            Recipients.Add(Contact."E-Mail");
                            ContactIds.Add(Contact.SystemId);
                        end;
                until Contact.Next() = 0;

            If Recipients.Count > 0 then
                ItemMgmt.EmailSpecification(Item, Recipients, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt), ContactIds);

        end;


    end;

    local procedure GetZoneRateForSalesLine(SalesLine: Record "Sales Line"; var PostcodeZone: Record "TFB Postcode Zone"): Boolean

    var
        SalesHeader: Record "Sales Header";

    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", SalesLine."Document No.");

        If SalesHeader.FindFirst() then begin

            PostcodeZone.SetRange("Customer Price Group", SalesHeader."Customer Price Group");

            If PostcodeZone.FindFirst() then
                Exit(true);
        end;

    end;

    local procedure CheckAndWarnIfItemOnQuote(Item: Record Item; var SalesLine: Record "Sales Line"; var NotificationID: Guid)

    var

        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        ItemAlreadyQuotedNotification: Notification;
        QuoteDocumentNo: Code[20];
        NotificationMsg: Label 'This customer has a quote %1 that includes item %2 already.', Comment = '%1 = quote number, %2 = item name';

        NotificationFunctionTok: Label 'NotifyItemOnQuote';
        NotificationLbl: Label 'Open quote';
    begin

        If not (SalesLine."Document Type" = SalesLine."Document Type"::Order) then exit;

        If not quoteforitemexists(Item, SalesLine, QuoteDocumentNo) then exit;

        ItemAlreadyQuotedNotification.Id := NotificationID;
        ItemAlreadyQuotedNotification.Message := StrSubstNo(NotificationMsg, SalesLine.GetSalesHeader()."Sell-to Customer Name", SalesLine.Description);
        ItemAlreadyQuotedNotification.AddAction(NotificationLbl, CODEUNIT::"Document Notifications", NotificationFunctionTok);
        ItemAlreadyQuotedNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        ItemAlreadyQuotedNotification.SetData('No.', QuoteDocumentNo);
        NotificationLifecycleMgt.SendNotification(ItemAlreadyQuotedNotification, SalesLine.RecordId);
    end;

    local procedure quoteforitemexists(Item: record Item; var SalesLine: Record "Sales Line"; QuoteDocumentNo: Code[20]): Boolean
    var
        SalesQuoteLine: Record "Sales Line";
    begin
        SalesQuoteLine.SetRange("Sell-to Customer No.", SalesLine."Sell-to Customer No.");
        SalesQuoteLine.SetRange("Document Type", SalesQuoteLine."Document Type"::Quote);
        SalesQuoteLine.SetRange("No.", Item."No.");


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
        Exit(true);
    end;

    procedure GetVendorShippingAgentOverride(VendorNo: Code[20]; ShippingZone: Code[20]; var ShippingAgentService: Record "Shipping Agent Services"): Boolean

    var
        VendorZoneRate: Record "TFB Vendor Zone Rate";

    begin

        VendorZoneRate.SetRange("Sales Type", VendorZoneRate."Sales Type"::All);
        VendorZoneRate.SetRange("Zone Code", ShippingZone);
        VendorZoneRate.SetRange("Vendor No.", VendorNo);

        If VendorZoneRate.FindFirst() then
            If VendorZoneRate."Agent Service Code" <> '' then
                Exit(ShippingAgentService.Get(VendorZoneRate."Shipping Agent", VendorZoneRate."Agent Service Code"))
    end;

    procedure GetItemDynamicDetails(ItemNo: Code[20]; var SalesPrice: Decimal; var LastChanged: Date)

    var
        CoreSetup: Record "TFB Core Setup";
        Item: Record Item;
        PriceListLine: Record "Price List Line";

        PricingCU: CodeUnit "TFB Pricing Calculations";
    begin
        CoreSetup.Get();

        If (CoreSetup."Def. Customer Price Group" <> '') and Item.Get(ItemNo) then begin
            PriceListLine.SetRange("Asset No.", ItemNo);
            PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
            PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
            PriceListLine.Setrange(Status, PriceListLine.Status::Active);
            PriceListLine.SetRange("Source Type", PriceListLine."Source Type"::"Customer Price Group");
            PriceListLine.SetRange("Source No.", CoreSetup."Def. Customer Price Group");
            PriceListLine.SetFilter("Ending Date", '=%1|>=%2', 0D, WorkDate());


            If PriceListLine.FindLast() then begin
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

        If SalesInvoiceLine.FindFirst() and Item.Get(ItemNo) then begin
            LastPricePaid := PricingCU.CalcPerKgFromUnit(SalesInvoiceLine."Unit Price", SalesInvoiceLine."Net Weight");
            LastDatePurchased := SalesInvoiceLine."Posting Date";
        end;
    end;

}
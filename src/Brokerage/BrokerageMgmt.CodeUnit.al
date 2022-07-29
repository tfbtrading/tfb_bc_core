codeunit 50242 "TFB Brokerage Mgmt"
{
    trigger OnRun()
    begin

    end;

    #region email
    /// <summary> 
    /// Description for SendOneBrokerageUpdateEmail.
    /// </summary>
    /// <param name="RefNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Boolean".</returns>

    procedure SendOneBrokerageUpdateEmail(RefNo: Code[20]): Boolean
    var
        CLib: CodeUnit "TFB Common Library";
        Window: Dialog;
        Result: Boolean;
        SubTitleTxt: Label '';
        Text001Msg: Label 'Sending Brokerage Update Notification:\#1############################', Comment = '%1=Shipment Number';
        TitleTxt: Label 'Brokerage Shipment Update';
    begin

        Window.Open(Text001Msg);
        Window.Update(1, STRSUBSTNO(Text001Msg, RefNo));
        Result := SendBrokerageUpdateNotificationEmail(RefNo, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt));
        Exit(Result);
    end;


    /// <summary> 
    /// Send to customer an ad-hoc notification for filled in details
    /// </summary>
    /// <param name="RefNo">Parameter of type Code[20].</param>
    /// <param name="HTMLTemplate">Parameter of type Text.</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure SendBrokerageUpdateNotificationEmail(RefNo: Code[20]; HTMLTemplate: Text): Boolean

    var

        CommEntry: Record "TFB Communication Entry";
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        Shipment: Record "TFB Brokerage Shipment";
        Contract: Record "TFB Brokerage Contract";
        Contact: Record Contact;

        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";

        EmailID: Text;
        ShipmentRef: Text;
        Recipients: List of [Text];
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;
        SubjectTxt: Label 'Brokerage Shipment Update Notification %1 from TFB Trading', comment = '%1 = Shipment No.';
        EmailScenEnum: Enum "Email Scenario";
        EmailAction: Enum "Email Action";
    begin


        CompanyInfo.Get();

        If not Shipment.Get(RefNo) then exit(false);

        If not Contract.Get(Shipment."Contract No.") then exit(false);

        If not Customer.Get(Shipment."Customer No.") then exit(false);

        If Contact.Get(Contract."Sell-to Contact No.") and (Contact."E-Mail" <> '') then
            EmailID := Contact."E-Mail"
        else
            Customer."E-Mail" := '';


        If Shipment."Customer Reference" <> '' then
            ShipmentRef := Shipment."Customer Reference"
        else
            ShipmentRef := Shipment."No.";
        SubjectNameBuilder.Append(StrSubstNo(SubjectTxt, ShipmentRef));
        Recipients.Add(EmailID);

        HTMLBuilder.Append(HTMLTemplate);

        //Check that content has been generated to send
        If GenerateBrokerageUpdateContent(RefNo, HTMLBuilder) then begin
            EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);
            Email.AddRelation(EmailMessage, Database::"TFB Brokerage Shipment", Shipment.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
            Email.AddRelation(EmailMessage, Database::Customer, Customer.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");
            If not (Email.OpenInEditorModally(EmailMessage, EmailScenEnum::Logistics) = EmailAction::Discarded) then begin
                CommEntry.Init();
                CommEntry."Source Type" := CommEntry."Source Type"::Customer;
                CommEntry."Source ID" := Customer."No.";
                CommEntry."Source Name" := Customer.Name;
                CommEntry."Record Type" := commEntry."Record Type"::SOC;
                CommEntry."Record Table No." := Database::"TFB Brokerage Shipment";
                CommEntry."Record No." := Shipment."No.";
                CommEntry.Direction := CommEntry.Direction::Outbound;
                CommEntry.MessageContent := CopyStr(HTMLBuilder.ToText(), 1, 2048);
                CommEntry.Method := CommEntry.Method::EMAIL;
                CommEntry.Insert();

                Exit(True)
            end
        end;
    end;

    /// <summary> 
    /// Description for GenerateBrokerageUpdateContent.
    /// </summary>
    /// <param name="RefNo">Parameter of type Code[20].</param>
    /// <param name="HTMLBuilder">Parameter of type TextBuilder.</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure GenerateBrokerageUpdateContent(RefNo: Code[20]; var HTMLBuilder: TextBuilder): Boolean

    var
        Customer: Record Customer;
        Header: Record "TFB Brokerage Shipment";
        Vendor: Record Vendor;
        FieldRef: FieldRef;
        RecordRef: RecordRef;
        FieldList: List of [Integer];
        FieldNo: Integer;
        tdTxt: label '<td valign="top" style="line-height:15px;">%1</td>', comment = '%1=table data html';
        BodyBuilder: TextBuilder;
        LineBuilder: TextBuilder;
        ReferenceBuilder: TextBuilder;
        OrderNoTxt: label 'Our order %1', comment = '%1 = Order No';
        CustomerRefTxt: label ' and your ref no. is %1', comment = '%1 = External No';
        VendorNoTxt: label '. Vendor invoice no. is %1', comment = '%1 = Vendor Invoice No';

    begin

        //Start with content introducing customer

        If not Header.Get(RefNo) then
            exit(false);

        If not Customer.Get(Header."Customer No.") then
            exit(false);

        If not Vendor.Get(Header."Buy From Vendor No.") then
            exit(false);


        HTMLBuilder.Replace('%{ExplanationCaption}', 'Notification type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Brokerage shipment update');
        HTMLBuilder.Replace('%{DateCaption}', 'Updated On');
        HTMLBuilder.Replace('%{DateValue}', Format(Today(), 0, 4));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'Order References');
        ReferenceBuilder.Append(StrSubstNo(OrderNoTxt, Header."No."));

        If Header."Customer Reference" <> '' then
            ReferenceBuilder.Append(StrSubstNo(CustomerRefTxt, Header."Customer Reference"));

        if Header."Vendor Invoice No." <> '' then
            ReferenceBuilder.Append(StrSubstNo(VendorNoTxt, Header."Vendor Invoice No."));

        HTMLBuilder.Replace('%{ReferenceValue}', ReferenceBuilder.ToText());

        HTMLBuilder.Replace('%{AlertText}', '');

        BodyBuilder.AppendLine('<table class="tfbdata" role="presentation" width="100%" cellspacing="0" cellpadding="10" border="0">');
        BodyBuilder.AppendLine('<thead>');

        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="40%">Detail</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="60%">Current Info</th></thead>');

        FieldList.Add(Header.FieldNo("Buy From Vendor Name"));
        FieldList.Add(Header.FieldNo("Required Arrival Date"));
        FieldList.Add(Header.FieldNo("Est. Departure Date"));
        FieldList.Add(Header.FieldNo("Est. Arrival Date"));
        FieldList.Add(Header.FieldNo("Shipping Agent Code"));
        FieldList.Add(Header.FieldNo("Vessel Details"));
        FieldList.Add(Header.FieldNo("Container No."));
        If Header."Vendor Invoice Due Date" > 0D then
            FieldList.Add(Header.FieldNo("Vendor Invoice Due Date"));


        RecordRef.GetTable(Header);

        foreach FieldNo in FieldList do begin

            FieldRef := RecordRef.Field(FieldNo);

            If format(FieldRef.Value()) <> '' then begin
                Clear(LineBuilder);
                LineBuilder.AppendLine('<tr>');
                LineBuilder.Append(StrSubstNo(tdTxt, FieldRef.Caption));
                If FieldRef.Type = FieldRef.Type::Date then
                    LineBuilder.Append(StrSubstNo(tdTxt, Format(FieldRef.Value, 0, 4)))
                else
                    LineBuilder.Append(StrSubstNo(tdTxt, Format(FieldRef.Value)));

                LineBuilder.AppendLine('</tr>');
                BodyBuilder.Append(LineBuilder.ToText());
            end;

        end;

        BodyBuilder.AppendLine('<br>');


        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        Exit(true);

    end;
    #endregion
    /// <summary> 
    /// Calculate Vendor Invoice Due Date by looking for standard vendor payment terms and calculating the date
    /// </summary>
    /// <param name="VendorNo">Parameter of type Code[20].</param>
    /// <param name="InvoiceDate">Parameter of type Date.</param>
    /// <returns>Return variable "Date".</returns>
    procedure CalcInvDueDate(VendorNo: Code[20]; InvoiceDate: Date): Date
    var
        PaymentTerms: Record "Payment Terms";
        Vendor: Record Vendor;

    begin

        If Vendor.Get(VendorNo) then
            If PaymentTerms.Get(Vendor."Payment Terms Code") then
                Exit(CalcDate(PaymentTerms."Due Date Calculation", InvoiceDate));

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnShowSource', '', false, false)]
    local procedure OnShowSource(SourceTableId: Integer; SourceSystemId: Guid; var IsHandled: Boolean);

    var
        TFBBrokerageShipment: Record "TFB Brokerage Shipment";
    begin

        If IsHandled then exit;

        case SourceTableId of
            Database::"TFB Brokerage Shipment":
                If TFBBrokerageShipment.GetBySystemId(SourceSystemId) then begin
                    Page.Run(PAGE::"TFB Brokerage Shipment", TFBBrokerageShipment);
                    IsHandled := true;

                end;

        end;
    end;


    procedure RaiseInvoiceFromShipment(var BrokShipment: Record "TFB Brokerage Shipment"; var Header: record "Sales Header"): Boolean

    var
        Invoice: Record "Sales Invoice Header";
        Line: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        WorkDesc: BigText;
        OutStream: OutStream;
        InsertSuccess: Boolean;
        CustomerNo: Code[20];
        ErrorMsg: Label 'No brokerage service item defined';





    begin

        SalesSetup.Get();

        If SalesSetup."TFB Brokerage Service Item" = '' then
            Error(ErrorMsg);

        //Check if invoice or posted invoice already created
        Invoice.SetRange("TFB Brokerage Shipment", BrokShipment."No.");
        Header.SetRange("Document Type", Header."Document Type"::Invoice);
        Header.SetRange("TFB Brokerage Shipment", BrokShipment."No.");

        If (Invoice.IsEmpty()) and (Header.IsEmpty()) then
            If GetCustomerNoForBrokerageVendor(BrokShipment."Buy From Vendor No.", CustomerNo) then begin
                //Create new sales header and line

                Header.Init();
                Header.Validate("Document Type", Header."Document Type"::Invoice);
                Header.Validate("Sell-to Customer No.", CustomerNo);
                Header.Validate("Your Reference", BrokShipment."Vendor Invoice No.");
                Header.Validate("Posting Date", BrokShipment."Vendor Invoice Due Date");
                Header.Validate("Document Date", BrokShipment."Vendor Invoice Due Date");
                Header.Validate("TFB Brokerage Shipment", BrokShipment."No.");

                Header."Work Description".CreateOutStream(OutStream);

                WorkDesc.AddText(StrSubstNo('Brokerage against your invoice %1 for container %2 shipped to %3 against our brokerage contract %4', BrokShipment."Vendor Invoice No.", BrokShipment."Container No.", BrokShipment."Customer Name", BrokShipment."No."));
                WorkDesc.Write(OutStream);

                /*              DataMgmtCU.GetRecordRef(Header, RecordRef);
                             DataMgmtCU.FindFieldByName(RecordRef, FieldRef, 'Work Description');
                             TempBlobCU.ToRecordRef(RecordRef, FieldRef.Number()); */

                If Header.Insert(true) then begin

                    Line.Init();

                    Line."Document Type" := Header."Document Type";
                    Line."Document No." := Header."No.";
                    Line.Type := Line.Type::Item;
                    Line."Line No." := 10000;
                    Line.Validate("No.", SalesSetup."TFB Brokerage Service Item");
                    Line.Description := StrSubstNo('Brokerage fee against invoice %1', BrokShipment."Vendor Invoice No.");
                    Line.Validate(Quantity, 1);
                    BrokShipment.CalcFields(Amount, "Brokerage Fee");
                    Line.Validate("Unit Price", BrokShipment."Brokerage Fee");
                    If Line.Insert(true) then
                        InsertSuccess := true;

                end;

            end;

        If InsertSuccess then begin

            BrokShipment."Applied Invoice" := Header."No.";
            BrokShipment.Status := BrokShipment.Status::"Supplier Invoiced";
            BrokShipment.Modify(false);




            Exit(true);

        end;




    end;

    local procedure GetCustomerNoForBrokerageVendor(VendNo: Code[20]; var CustomerNo: Code[20]): Boolean

    var
        ContactRel: Record "Contact Business Relation";
        ContactNo: Code[20];

    begin

        ContactNo := ContactRel.GetContactNo(ContactRel."Link to Table"::Vendor, VendNo);
        If ContactRel.FindByContact(ContactRel."Link to Table"::Customer, ContactNo) then begin
            CustomerNo := (ContactRel."No.");
            Exit(true);
        end;
    end;


    procedure CalculateBrokerage(ItemNo: Code[20]; Quantity: Decimal; AgreedPrice: Decimal; BrokerageContractNo: Code[20]): Decimal

    var
        BrokerageContract: record "TFB Brokerage Contract";
        Item: record Item;
        PriceCodeUnit: Codeunit "TFB Pricing Calculations";
        Amount: Decimal;
        PricingUnitQty: Decimal;
        TotalMT: Decimal;


    begin
        Item.Get(ItemNo);
        BrokerageContract.Get(BrokerageContractNo);

        //Check that we will not get any divide by 0 errors - if any value is 0 so would be the brokerage commission
        if (Item."Net Weight" > 0) and (Quantity > 0) and (AgreedPrice > 0) then begin

            //Calculate out the Values used by the system

            TotalMT := (Item."Net Weight" * Quantity) / 1000;
            PricingUnitQty := PriceCodeUnit.CalculateQtyPriceUnit(ItemNo, BrokerageContract."Vendor Price Unit", Quantity);
            Amount := AgreedPrice * PricingUnitQty;



            case BrokerageContract."Commission Type" of
                BrokerageContract."Commission Type"::"$ per MT":
                    //Set Brokerage as Value per Metric Tonne Sold
                    Exit(TotalMT * BrokerageContract."Fixed Rate");
                BrokerageContract."Commission Type"::"% of Value":
                    //Set Brokerage as % of Total Line Value - Assume that Percentage Field needs to be divided by 100
                    Exit(Amount * BrokerageContract.Percentage / 100);
            end;
        end
        else
            Exit(0)
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePosting', '', false, false)]
    local procedure SubScribeToSalesPostingFinalization(CommitIsSuppressed: Boolean; PreviewMode: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var ReturnReceiptHeader: Record "Return Receipt Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesShipmentHeader: Record "Sales Shipment Header")
    var
        BrokerageShipment: Record "TFB Brokerage Shipment";

    begin

        If SalesInvoiceHeader."TFB Brokerage Shipment" <> '' then
            //Update reference  with posted document

            if BrokerageShipment.Get(SalesInvoiceHeader."TFB Brokerage Shipment") then
                BrokerageShipment."Applied Invoice" := SalesInvoiceHeader."No.";





    end;
}
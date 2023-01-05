codeunit 50120 "TFB Customer Mgmt"
{


    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforeGetCustEmailAddress', '', false, false)]
    local procedure HandleOnBeforeGetCustEmailAddress(BillToCustomerNo: Code[20]; ReportUsage: Option; var IsHandled: Boolean; var ToAddress: Text)

    var
        ReportSelections: Record "Report Selections";
        CustomerLayouts: Record "Custom Report Selection";
        Customer: Record Customer;
        TempToAddress: Text;

    begin

        case ReportUsage of
            ReportSelections.Usage::Reminder.AsInteger():
                begin

                    //Reminder should use report selection for customer invoice


                    CustomerLayouts.SetRange("Source Type", 18);
                    CustomerLayouts.SetRange("Source No.", BillToCustomerNo);
                    CustomerLayouts.SetRange(Usage, CustomerLayouts.Usage::"C.Statement");
                    CustomerLayouts.SetRange("Use for Email Attachment", True);

                    if CustomerLayouts.FindFirst() then
                        TempToAddress := CustomerLayouts."Send To Email"
                    else
                        If Customer.Get(BillToCustomerNo) then
                            TempToAddress := Customer."E-Mail";

                    If TempToAddress <> '' then begin
                        ToAddress := TempToAddress;
                        IsHandled := true;
                    end
                    else
                        IsHandled := false;

                end;


        end;

    end;

    procedure SendStatementToOneCustomer(CustomerNo: Code[20])

    var
        RepSelSales: Record "Report Selections";
        RepSelEmail: Record "Report Selections";
        Common: CodeUnit "TFB Common Library";
        XmlParameters: Text;
        SubTitleTxt: Label 'Please find below your latest statement';
        EditEmailMsg: Label 'Edit email before sending?';
        TitleTxt: Label 'Statement';
        HTMLTemplate: Text;


    begin


        RepSelSales.SetRange(Usage, RepSelSales.Usage::"C.Statement");


        HTMLTemplate := Common.GetHTMLTemplateActive(TitleTxt, SubTitleTxt);


        If RepSelSales.FindFirst() then
            XmlParameters := Report.RunRequestPage(RepSelSales."Report ID");

        SendCustomerStatement(CustomerNo, Today(), XmlParameters, HTMLTemplate, Confirm(EditEmailMsg, true));
    end;

    procedure SendCustomerStatementBatch()

    var
        RepSelSales: Record "Report Selections";
        Customer: Record Customer;
        Common: CodeUnit "TFB Common Library";
        XmlParameters: Text;
        SubTitleTxt: Label 'Please find below your latest statement';
        TitleTxt: Label 'Statement';
        HTMLTemplate: Text;

    begin

        Customer.SetFilter("Balance (LCY)", '>0');
        Customer.SetRange(Blocked, Customer.Blocked::" ");

        RepSelSales.SetRange(Usage, RepSelSales.Usage::"C.Statement");

        HTMLTemplate := Common.GetHTMLTemplateActive(TitleTxt, SubTitleTxt);

        If RepSelSales.FindFirst() then
            XmlParameters := Report.RunRequestPage(RepSelSales."Report ID");
        if Customer.FindSet() then
            repeat

                SendCustomerStatement(Customer."No.", Today(), XmlParameters, HTMLTemplate, false);
            until Customer.Next() < 1;
    end;



    procedure SendCustomerStatement(CustNo: Code[20]; AsAtDate: Date; XmlParameters: Text; HTMLTemplate: Text; EditEmail: Boolean): Boolean

    var

        RepSelSales: Record "Report Selections";
        RepSelEmail: Record "Report Selections";
        Customer: Record Customer;
        CustomerLayouts: Record "Custom Report Selection";
        CustomReportSelection: Record "Custom Report Selection";
        ReportLayoutSelection: Record "Report Layout Selection";
        CompanyInfo: Record "Company Information";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        TempBlobCU: Codeunit "Temp Blob";
        TempBlobEmail: CodeUnit "Temp Blob";
        Base64Convert: CodeUnit "Base64 Convert";
        EmailRecordRef: RecordRef;
        VarEmailRecordRef: RecordRef;
        FieldRefVar: FieldRef;
        EmailScenEnum: Enum "Email Scenario";
        EmailID: Text;
        Base64: Text;

        IStream: InStream;
        OStream: OutStream;
        I2Stream: InStream;
        O2Stream: OutStream;
        HTML: Text;
        FileNameBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;
        HTMLBuilder: TextBuilder;
        Recipients: List of [Text];


    begin

        CompanyInfo.Get();

        If not Customer.Get(CustNo) then
            exit(false);

        FileNameBuilder.Append('Statement For ');
        FileNameBuilder.Append(DelChr(Customer.Name, '=', ' '));
        FileNameBuilder.Append('.pdf');
        FileNameBuilder.Replace('/', '-');

        SubjectNameBuilder.Append(StrSubstNo('Statement for %1 from Tfb Trading as at %2', Customer.Name, Format(AsAtDate)));


        RepSelSales.SetRange(Usage, RepSelSales.Usage::"C.Statement");

        If RepSelSales.FindFirst() then begin

            TempBlobCU.CreateOutStream(OStream, TextEncoding::UTF8);
            TempBlobCU.CreateInStream(IStream, TextEncoding::UTF8);


            EmailRecordRef.GetTable(Customer);
            FieldRefVar := EmailRecordRef.Field(Customer.FieldNo("No."));
            FieldRefVar.SetRange(Customer."No.");

            CustomerLayouts.SetRange("Source Type", 18);
            CustomerLayouts.SetRange("Source No.", Customer."No.");
            CustomerLayouts.SetRange(Usage, CustomerLayouts.Usage::"C.Statement");
            CustomerLayouts.SetRange("Use for Email Attachment", True);

            if CustomerLayouts.FindFirst() then
                If CustomerLayouts."Send To Email" <> '' then
                    EmailID := CustomerLayouts."Send To Email"

                else
                    EmailID := Customer."E-Mail"
            else
                EmailID := Customer."E-Mail";

            If EmailID = '' then
                Message(StrSubstNo('No email for company %1', Customer.Name));

            //Find customer layout selection

            If EmailRecordRef.Count() > 0 then begin

                VarEmailRecordRef := EmailRecordRef;


                Report.SaveAs(RepSelSales."Report ID", XmlParameters, ReportFormat::Pdf, OStream, VarEmailRecordRef);


                Recipients := EmailID.Split(';');
                Clear(HTMLBuilder);
                HTMLBuilder.Append(HTMLTemplate);

                RepSelEmail.SetRange(Usage, RepSelEmail.Usage::"C.Statement");
                RepSelEmail.SetRange("Use for Email Body", true);

                If RepSelEmail.FindFirst() then begin
                    ReportLayoutSelection.SetTempLayoutSelected(RepSelEmail."Email Body Layout Code");
                    TempBlobEmail.CreateOutStream(O2Stream);
                    If not Report.SaveAs(RepSelEmail."Report ID", XmlParameters, ReportFormat::Html, O2Stream, VarEmailRecordRef) then
                        Message('No content returned for email body by report');
                    TempBlobEmail.CreateInStream(I2Stream);
                    HTMLBuilder.Clear();
                    I2Stream.Read(HTML);

                    HTMLBuilder.Append(HTML);
                end
                else
                    GenerateCustomerStatementContent(Customer, HTMLBuilder);

                EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);
                EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/PDF', IStream);
                Email.AddRelation(EmailMessage, Database::Customer, Customer.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

                If EditEmail then
                    Email.OpenInEditorModally(EmailMessage, EmailScenEnum::"Customer Statement")
                else
                    Email.Enqueue(EmailMessage, EmailScenEnum::"Customer Statement");


            end;

        end;
    end;



    procedure SendOneCustomerStatusEmail(CustNo: Code[20]): Boolean
    var
        cu: CodeUnit "TFB Common Library";
        Window: Dialog;
        Text001Msg: Label 'Sending Customer Updates:\#1############################', Comment = '%1 is the customer number';
        SubtitleTxt: Label 'Please find below our latest information on pending orders that have not yet been shipped or invoiced and recent invoices that have been sent';
        TitleTxt: Label 'Order Status';
        Result: Boolean;

    begin

        Window.Open(Text001Msg);
        Window.Update(1, STRSUBSTNO('%1 %2', CustNo, ''));
        Result := SendCustomerStatusEmail(CustNo, cu.GetHTMLTemplateActive(TitleTxt, SubtitleTxt));
        Exit(Result);
    end;

    procedure SendCustomerStatusEmail(CustNo: Code[20]; HTMLTemplate: Text): Boolean

    var



        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        EmailScenEnum: Enum "Email Scenario";
        SubjectTxt: Label 'Order status update for %1 from TFB Trading Australia', Comment = '%1 is Customer Name';

        //Email address to send to
        EmailID: Text;

        //TextBuilders to generate FileName and Other Details
        SubjectNameBuilder, HTMLBuilder : TextBuilder;
        Recipients: List of [Text];

        NoData: Boolean;


    begin


        CompanyInfo.Get();


        If not Customer.Get(CustNo) then
            exit(false);

        If Customer."E-Mail" = '' then
            exit(false);

        EmailID := Customer."E-Mail";
        SubjectNameBuilder.Append(StrSubstNo(SubjectTxt, Customer.Name));


        Recipients.Add(EmailID);


        HTMLBuilder.Append(HTMLTemplate);

        If Customer."TFB Order Update Preference" = Enum::"TFB Order Update Preference"::OptOut then
            exit(true);

        GenerateCustomerOrderStatusContent(Customer."No.", HTMLBuilder, NoData);

        If Customer."TFB Order Update Preference" = Enum::"TFB Order Update Preference"::DataOnly then
            if NoData then
                exit(true);



        EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);
        Email.AddRelation(EmailMessage, Database::Customer, Customer.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");
        Email.Enqueue(EmailMessage, EmailScenEnum::Logistics);

    end;


    procedure CheckIfCreditHoldApplies(Customer: Record Customer; NewShipmentValue: Decimal; var overdue: Boolean; var overCreditLimit: Boolean): Boolean

    var

        CoreSetup: Record "TFB Core Setup";
        BalanceAfterShipment: Decimal;

    begin

        Clear(overdue);
        Clear(overCreditLimit);
        CoreSetup.Get();
        Customer.SetRange("Date Filter", 0D, today());
        Customer.CalcFields("Balance (LCY)");
        Customer.CalcFields("Balance Due (LCY)");

        //Check if any invoices are overdue
        If Customer."Balance Due (LCY)" > 0 then
            if Customer."Balance Due (LCY)" > CoreSetup."Credit Tolerance" then
                overdue := true;

        //Check if new order to be shipped take customer over credit limit
        BalanceAfterShipment := Customer."Balance (LCY)" + NewShipmentValue;
        if BalanceAfterShipment > (Customer."Credit Limit (LCY)" + CoreSetup."Credit Tolerance") then
            overCreditLimit := true;

        If overdue or overCreditLimit then exit(true) else exit(false);
    end;

    procedure GetValueOfShipment(Customer: Record Customer): Decimal

    var
        Line: Record "Sales Line";
        DateFormula: DateFormula;
        TotalValue: Decimal;

    begin

        Line.SetRange("Sell-to Customer No.", Customer."No.");
        Line.SetRange("Document Type", Line."Document Type"::Order);

        Evaluate(DateFormula, '+7D');
        Line.SetFilter("Planned Shipment Date", '..%1', CalcDate(DateFormula, Today()));
        Line.SetFilter("Outstanding Qty. (Base)", '>0');

        if Line.FindSet() then
            repeat
                TotalValue += Line."Outstanding Quantity" * (Line."Line Amount" / Line.Quantity);
            until Line.Next() < 1;

        Exit(TotalValue);

    end;

    local procedure GenerateCustomerOrderStatusContent(CustNo: Code[20]; var HTMLBuilder: TextBuilder; var NoData: Boolean): Boolean

    var
        Customer: Record Customer;
        Item: Record Item;
        UoM: Record "Unit of Measure";
        SalesOrder: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Invoice: Record "Sales Invoice Header";
        InvoiceLine: Record "Sales Invoice Line";
        LotNoInfo: Record "Lot No. Information";
        WhseShptLine: Record "Warehouse Shipment Line";
        Purchase: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Container: Record "TFB Container Entry";
        DemandResEntry: Record "Reservation Entry";
        SupplyResEntry: Record "Reservation Entry";
        LedgerEntry: Record "Item Ledger Entry";
        CoreSetup: Record "TFB Core Setup";
        Vendor: Record Vendor;

        PricingCU: CodeUnit "TFB Pricing Calculations";


        Count: Integer;

        BodyBuilder: TextBuilder;
        LineBuilder: TextBuilder;

        tdTxt: label '<td valign="top" style="line-height:15px;">%1</td>', Comment = '%1 = html content for the content of the table data cell';
        Status, DeliverySLA : text;
        overdue, overCreditLimit, SuppressLine : Boolean;


        PricingUnit: Enum "TFB Price Unit";


    begin

        //Start with content introducing customer

        PricingUnit := PricingUnit::KG;
        NoData := true;

        If not Customer.Get(CustNo) then
            exit;

        CoreSetup.Get();

        //First get open pending sales lines

        Clear(SalesLine);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Sell-to Customer No.", Customer."No.");
        SalesLine.SetCurrentKey("Planned Shipment Date");

        //Caclculate credit situation
        Customer.SetRange("Date Filter", 0D, today());
        Customer.CalcFields("Balance (LCY)");
        Customer.CalcFields("Balance Due (LCY)");

        Count := 0;
        HTMLBuilder.Replace('%{ExplanationCaption}', 'Notification type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Periodic Update');
        HTMLBuilder.Replace('%{DateCaption}', 'Generated On');
        HTMLBuilder.Replace('%{DateValue}', Format(Today(), 0, 4));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'Customer Name');
        HTMLBuilder.Replace('%{ReferenceValue}', Customer.Name);

        If CheckIfCreditHoldApplies(Customer, GetValueOfShipment(Customer), overdue, overCreditLimit) and OverDue then
            HTMLBuilder.Replace('%{AlertText}', StrSubstNo('There are invoices valued at %1 currently overdue. Note. We provide a tolerance of %2 AUD so small amounts do not hold anything up. Please call or email to discuss so we can get these goods to you as fast as possible.', Customer."Balance Due (LCY)", CoreSetup."Credit Tolerance"))
        else
            HTMLBuilder.Replace('%{AlertText}', '');

        if SalesLine.FindSet() then begin

            BodyBuilder.AppendLine('<h2>Items still to be fulfilled or invoiced</h2>');


            BodyBuilder.AppendLine('<table class="tfbdata"  role="presentation"  width="100%" cellspacing="0" cellpadding="10" border="0">');
            BodyBuilder.AppendLine('<thead>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Order No.</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Your Ref.No.</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Dispatch Planned</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Ordered On</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Item Desc.</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="5%">Qty Ordered</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Per Kg</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="25%">Comments</th></thead>');

            repeat

                Count := Count + 1;
                SuppressLine := false;
                LineBuilder.Clear();
                Clear(SalesOrder);
                SalesOrder.SetRange("Document Type", SalesOrder."Document Type"::Order);
                SalesOrder.SetRange("No.", SalesLine."Document No.");
                SalesOrder.FindFirst();
                Item.Get(salesLine."No.");
                UoM.Get(Item."Base Unit of Measure");
                SalesLine.CalcFields("Reserved Qty. (Base)", "Whse. Outstanding Qty.");


                //BodyBuilder.AppendLine('<tr>');

                If SalesLine."Qty. Shipped (Base)" = 0 then

                    //Check if drop ship

                    if not SalesLine."Drop Shipment" then

                        //Check if anything is scheduled on warehouse shipment

                        if SalesLine."Whse. Outstanding Qty." = 0 then begin

                            //Provide details of warehouse shipment
                            Status := 'Planned for dispatch';
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

                                                    LotNoInfo.SetRange("Item No.", LedgerEntry."Item No.");
                                                    LotNoInfo.SetRange("Lot No.", LedgerEntry."Lot No.");
                                                    LotNoInfo.SetRange("Variant Code", LedgerEntry."Variant Code");

                                                    If LotNoInfo.FindFirst() then
                                                        If (LotNoInfo.Blocked = true) and (LotNoInfo."TFB Date Available" > 0D) then
                                                            Status += StrSubstNo(' and pending release on %1', LotNoInfo."TFB Date Available")

                                                end;

                                            39: //Purchase Order Entry
                                                begin
                                                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                                                    PurchaseLine.SetRange("Line No.", SupplyResEntry."Source Ref. No.");
                                                    PurchaseLine.SetRange("Document No.", SupplyResEntry."Source ID");

                                                    If PurchaseLine.FindFirst() then
                                                        case PurchaseLine."TFB Container Entry No." of
                                                            '':
                                                                Status += StrSubstNo(' based on arrival from local purchase order due into warehouse on %1', purchaseline."Expected Receipt Date");

                                                            else
                                                                If Container.Get(PurchaseLine."TFB Container Entry No.") then
                                                                    case Container.Status of

                                                                        Container.Status::Planned:

                                                                            Status += StrSubstNo(' based on planned overseas container due for arrival on %1 and estimated to be available on %2', Container."Est. Arrival Date", Container."Est. Warehouse");


                                                                        Container.Status::ShippedFromPort:

                                                                            Status += StrSubstNo(' based on shipped container %1, due for arrival on %2 and estimated to be available on %3', Container."Container No.", Container."Est. Arrival Date", Container."Est. Warehouse");


                                                                        Container.Status::PendingClearance:
                                                                            begin
                                                                                Status += StrSubstNo(' based on container that arrived on %1.');
                                                                                If Container."Fumigation Req." then
                                                                                    Status += ' Fumigation Req.';
                                                                                If Container."Inspection Req." or Container."IFIP Req." then
                                                                                    Status += ' Inspection Req.';
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
                            Status := 'Being prepared by warehouse';
                            WhseShptLine.SetRange("Source Document", WhseShptLine."Source Document"::"Sales Order");
                            WhseShptLine.SetRange("Source No.", SalesLine."Document No.");
                            WhseShptLine.SetRange("Source Line No.", SalesLine."Line No.");

                            //if WhseShptLine.FindFirst() then
                            //ShipDatePlanned := WhseShptLine."Shipment Date"; //TODO Check if we need to add ship date
                        end
                    else begin
                        //Get Vendor Details
                        Clear(PurchaseLine);
                        Purchase.SetRange("Document Type", Purchase."Document Type"::Order);
                        Purchase.SetRange("No.", SalesLine."Purchase Order No.");
                        If Purchase.FindFirst() then begin
                            If Purchase."TFB Delivery SLA" = '' then begin
                                Vendor.Get(Purchase."Buy-from Vendor No.");
                                DeliverySLA := Vendor."TFB Delivery SLA"
                            end
                            else
                                DeliverySLA := Purchase."TFB Delivery SLA";

                            Status := 'Confirmed by ' + Purchase."Buy-from Vendor Name" + ' for drop-ship with SLA of ' + DeliverySLA;
                        end else
                            Status := 'Pending confirmation for drop-ship';
                    end
                else

                    If SalesLine."Qty. Shipped (Base)" < SalesLine."Quantity (Base)" then

                        //Partially Shipped

                        Status := format(SalesLine."Qty. Shipped (Base)") + ' already shipped. Remainder planned for dispatch.'
                    else

                        //Fully Shipped
                        If SalesLine."Qty. Invoiced (Base)" = SalesLine."Qty. Shipped (Base)" then begin
                            Status := 'Shipped and invoiced';
                            SuppressLine := true;
                        end
                        else
                            Status := 'Shipped, but pending invoicing';


                LineBuilder.AppendLine('<tr>');
                LineBuilder.Append(StrSubstNo(tdTxt, SalesLine."Document No."));
                LineBuilder.Append(StrSubstNo(tdTxt, SalesOrder."External Document No."));
                LineBuilder.Append(StrSubstNo(tdTxt, format(SalesLine."Planned Shipment Date")));
                LineBuilder.Append(StrSubstNo(tdTxt, format(Salesorder."Order Date")));
                LineBuilder.Append(StrSubstNo(tdTxt, SalesLine.Description + '<br><span class="small">' + Format(Item."Net Weight") + 'kg ' + UoM.Description + '</span>'));
                LineBuilder.Append(StrSubstNo(tdTxt, Format(SalesLine."Quantity (Base)")));
                LineBuilder.Append(StrSubstNo(tdTxt, Format(PricingCU.CalculatePriceUnitByUnitPrice(SalesLine."No.", SalesLine."Unit of Measure Code", PricingUnit, SalesLine."Unit Price"), 0, '$<Precision,2:2><Standard Format,0>')));
                LineBuilder.Append(StrSubstNo(tdTxt, Status));
                LineBuilder.AppendLine('</tr>');

                If not SuppressLine then
                    BodyBuilder.Append(LineBuilder.ToText());

            until SalesLine.Next() < 1;

            BodyBuilder.AppendLine('</table>');
            NoData := false;
        end else
            BodyBuilder.AppendLine('<h2>No pending sales to be delivered or invoiced</h2>');


        BodyBuilder.AppendLine('<hr>');
        //check for items recently invoiced
        InvoiceLine.SetRange("Sell-to Customer No.", Customer."No.");
        InvoiceLine.SetFilter("Posting Date", StrSubstNo('> %1', CalcDate('<-7d>', Today())));
        InvoiceLine.SetFilter("Quantity (Base)", '>0');
        InvoiceLine.SetRange(Type, InvoiceLine.Type::Item);


        if InvoiceLine.FindSet(false, false) then begin

            BodyBuilder.AppendLine('<h2>Items invoiced in the last seven days</h2>');
            BodyBuilder.AppendLine('<table class="tfbdata"  role="presentation"  cellspacing="0" cellpadding="10" border="0">');
            BodyBuilder.AppendLine('<thead><th class="tfbdata" width="15%" style="text-align:left">Order No.</th><th class="tfbdata" width="15%" style="text-align:left">Invoice No.</th><th class="tfbdata" style="text-align:left" width="20%">Issued On</th><th class="tfbdata" style="text-align:left" width="20%">Item Desc.</th><th class="tfbdata" style="text-align:left" width="20%">Qty Invoiced</th><th class="tfbdata" style="text-align:left" width="10%">Pricing</th></thead>');

            repeat
                Clear(Invoice);

                Invoice.SetRange("No.", InvoiceLine."Document No.");

                Invoice.FindFirst();
                BodyBuilder.AppendLine('<tr>');
                BodyBuilder.Append(StrSubstNo(tdTxt, Invoice."Order No."));
                BodyBuilder.Append(StrSubstNo(tdTxt, InvoiceLine."Document No."));
                BodyBuilder.Append(StrSubstNo(tdTxt, format(InvoiceLine."Posting Date")));
                BodyBuilder.Append(StrSubstNo(tdTxt, InvoiceLine.Description));
                BodyBuilder.Append(StrSubstNo(tdTxt, Format(InvoiceLine."Quantity (Base)")));
                BodyBuilder.Append(StrSubstNo(tdTxt, Format(InvoiceLine."Unit Price" / InvoiceLine."Qty. per Unit of Measure", 0, '$<Precision,2:2><Standard Format,0>') + '<br> ( ' + Format(PricingCU.CalculatePriceUnitByUnitPrice(InvoiceLine."No.", InvoiceLine."Unit of Measure Code", PricingUnit, InvoiceLine."Unit Price"), 0, '$<Precision,2:2><Standard Format,0>') + ' per kg )'));


                BodyBuilder.AppendLine('</tr>');

            until InvoiceLine.Next() < 1;

            BodyBuilder.AppendLine('</table>');
            NoData := false;
        end
        else
            BodyBuilder.AppendLine('<h2>No invoices issued in the last 7 days</h2>');
        BodyBuilder.AppendLine('<hr>');
        BodyBuilder.AppendLine('<p><em>Please note we can set your preference to opt-out completely, receive if there data to report or always receive this update</em></p>');
        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        Exit(true);
    end;



    local procedure GenerateCustomerStatementContent(Customer: Record Customer; var HTMLBuilder: TextBuilder): Boolean

    var

        CoreSetup: Record "TFB Core Setup";
        BodyBuilder: TextBuilder;
        overdue, overCreditLimit : Boolean;


    begin

        //Start with content introducing customer

        CoreSetup.Get();
        HTMLBuilder.Replace('%{ExplanationCaption}', 'Notification type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Customer Statement');
        HTMLBuilder.Replace('%{DateCaption}', 'Generated On');
        HTMLBuilder.Replace('%{DateValue}', Format(Today(), 0, 4));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'Customer Name');
        HTMLBuilder.Replace('%{ReferenceValue}', Customer.Name);

        If CheckIfCreditHoldApplies(Customer, 0, overdue, overCreditLimit) and OverDue then
            HTMLBuilder.Replace('%{AlertText}', StrSubstNo('There are invoices valued at %1 currently overdue. Note. We provide a tolerance of %2 AUD so small amounts do not hold anything up. Please call or email to discuss so we can get these goods to you as fast as possible.', Customer."Balance Due (LCY)", CoreSetup."Credit Tolerance"))
        else
            HTMLBuilder.Replace('%{AlertText}', '');

        BodyBuilder.AppendLine('<p>Attached to this email is your latest statement. Please let us know as soon as convenient if you have any queries with regards to the details on the statement.</p>');
        BodyBuilder.AppendLine('<p>We have the ability to send order updates, invoices and statements to different email address. Please let us know if you would like these details changed.');
        BodyBuilder.AppendLine('<p>We appreciate your business and look forward to supporting you in the future.</p>');

        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        Exit(true);
    end;
}





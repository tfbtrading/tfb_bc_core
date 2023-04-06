codeunit 50130 "TFB Vendor Mgmt"
{


    procedure SendOneVendorStatusEmail(VendNo: Code[20]): Boolean

    var
        CommonCU: CodeUnit "TFB Common Library";
        Window: Dialog;
        Text001Msg: Label 'Sending Vendor Updates:\#1############################Msg', comment = '%1=vendor';
        TitleTxt: label 'Vendor status';
        SubtitleTxt: label '';
        Result: Boolean;

    begin
        Window.Open(Text001Msg);
        Window.Update(1, STRSUBSTNO('%1 %2', VendNo, ''));
        Result := SendVendorStatusEmail(VendNo, CommonCU.GetHTMLTemplateActive(TitleTxt, SubtitleTxt), true);
        Window.Close();
        Exit(Result);
    end;

    procedure SendVendorStatusEmail(VendNo: Code[20]; HTMLTemplate: Text; EditEmail: Boolean): Boolean

    var

        CompanyInfo: Record "Company Information";
        Vendor: Record Vendor;
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        EmailScenEnum: Enum "Email Scenario";
        EmailID: Text;

        //TextBuilders to generate FileName and Other Details
        SubjectNameBuilder: TextBuilder;
        HTMLBuilder: TextBuilder;
        Recipients: List of [Text];



    begin


        CompanyInfo.Get();


        If not Vendor.Get(VendNo) then
            exit(false);

        If Vendor."E-Mail" = '' then
            exit(false);



        EmailID := Vendor."E-Mail";
        SubjectNameBuilder.Append('Order Status Info from TFB Trading');


        Recipients.Add(EmailID);


        HTMLBuilder.Append(HTMLTemplate);

        GenerateVendorOrderStatusContent(Vendor."No.", HTMLBuilder);


        EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);

        Email.AddRelation(EmailMessage, Database::Vendor, Vendor.SystemId, Enum::"Email Relation Type"::"Related Entity", enum::"Email Relation Origin"::"Compose Context");
        If EditEmail then
            Email.OpenInEditorModally(EmailMessage, EmailScenEnum::"Purchase Order") else
            Email.Enqueue(EmailMessage, EmailScenEnum::"Purchase Order");

    end;


    local procedure GenerateVendorOrderStatusContent(VendNo: Code[20]; var HTMLBuilder: TextBuilder): Boolean

    var
        Vendor: Record Vendor;
        Item: Record Item;
        UoM: Record "Unit of Measure";
        Order: Record "Purchase Header";
        OrderLine: Record "Purchase Line";
        SalesOrder: Record "Sales Header";
        SalesOrderArchive: Record "Sales Header Archive";
        Invoice: Record "Purch. Inv. Header";
        InvoiceLine: Record "Purch. Inv. Line";
        Receipt: Record "Purch. Rcpt. Header";
        Container: Record "TFB Container Entry";
        ChangeLog: Record "Change Log Entry";
        PricingCU: CodeUnit "TFB Pricing Calculations";
        DateFormula: DateFormula;
        Count: Integer;
        SuppressLine: Boolean;
        BodyBuilder: TextBuilder;
        LineBuilder: TextBuilder;
        tdTxt: label '<td valign="top" style="line-height:15px;">%1</td>', comment = '%1=html content for tabledata';
        Status: text;
        Dest: text;
        LastWeek: Date;
        ThisTime: Time;

        ExpectedDate: Text;

        PricingUnit: Enum "TFB Price Unit";

    begin

        //Start with content introducing customer


        If not Vendor.Get(VendNo) then
            exit;


        PricingUnit := Vendor."TFB Vendor Price Unit";

        //First get open pending sales lines

        Clear(OrderLine);
        OrderLine.SetRange(Type, OrderLine.Type::Item);
        OrderLine.SetRange("Document Type", OrderLine."Document Type"::Order);
        OrderLine.SetRange("Buy-from Vendor No.", Vendor."No.");
        OrderLine.SetRange(Type, OrderLine.Type::Item);
        OrderLine.SetCurrentKey("Planned Receipt Date");


        HTMLBuilder.Replace('%{ExplanationCaption}', 'Request Type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Vendor Order Status Update');
        HTMLBuilder.Replace('%{DateCaption}', 'Requested on');
        HTMLBuilder.Replace('%{DateValue}', format(today()));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'Vendor');
        HTMLBuilder.Replace('%{ReferenceValue}', Vendor.Name);
        Count := 0;

        if OrderLine.FindSet() then begin

            BodyBuilder.AppendLine('<h2>Items still to be confirmed as dispatched and/or invoiced</h2>');
            BodyBuilder.AppendLine('<table class="tfbdata" width="100%" cellspacing="0" cellpadding="10" border="0">');
            BodyBuilder.AppendLine('<thead>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Order No.</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Your Ref.No.</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="8%">Dispatch Planned</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="8%">Ordered On</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="14%">Destination</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Item Desc.</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="5%">Qty Ordered</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="5%">Per ' + format(PricingUnit) + ' </th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Comments</th></thead>');

            repeat

                Count := Count + 1;
                SuppressLine := false;
                LineBuilder.Clear();
                Clear(Order);
                Order.SetRange("Document Type", Order."Document Type"::Order);
                Order.SetRange("No.", OrderLine."Document No.");
                Order.FindFirst();

                Item.Get(OrderLine."No.");
                UoM.Get(Item."Base Unit of Measure");
                Evaluate(DateFormula, '-7D');
                LastWeek := CalcDate(DateFormula, Today());
                ThisTime := Time();
                ChangeLog.SetRange("Table No.", Database::"Purchase Line");
                ChangeLog.SetRange("Record ID", OrderLine.RecordId());
                ChangeLog.SetRange("Field No.", OrderLine.FieldNo("Expected Receipt Date"));
                ChangeLog.SetFilter("Date and Time", '> %1', CreateDateTime(LastWeek, ThisTime));


                //Found a record which indicates date has changed in the last week
                If ChangeLog.FindLast() then
                    ExpectedDate := StrSubstNo('<b> Change to %1 from %2 </b>', OrderLine."Expected Receipt Date", ChangeLog.GetLocalOldValue())
                else
                    ExpectedDate := format(OrderLine."Expected Receipt Date");

                //BodyBuilder.AppendLine('<tr>');
                LineBuilder.AppendLine('<tr>');
                LineBuilder.Append(StrSubstNo(tdTxt, OrderLine."Document No."));
                LineBuilder.Append(StrSubstNo(tdTxt, Order."Vendor Order No."));
                LineBuilder.Append(StrSubstNo(tdTxt, format(OrderLine."Expected Receipt Date")));
                LineBuilder.Append(StrSubstNo(tdTxt, format(Order."Order Date")));

                If OrderLine."Drop Shipment" then begin
                    //Get Customer Details
                    Clear(SalesOrder);
                    SalesOrder.SetRange("Document Type", SalesOrder."Document Type"::Order);
                    SalesOrder.SetRange("No.", OrderLine."Sales Order No.");
                    If SalesOrder.FindFirst() then
                        Dest := SalesOrder."Sell-to Customer Name"
                    else begin
                        SalesOrderArchive.SetRange("Document Type", SalesOrder."Document Type"::Order);
                        SalesOrderArchive.SetRange("No.", OrderLine."Sales Order No.");
                        If SalesOrder.IsEmpty() then
                            Dest := 'Error cannot find drop ship order'
                        else
                            Dest := SalesOrderArchive."Sell-to Customer Name";
                    end;
                end
                else
                    Dest := 'Our warehouse';

                LineBuilder.Append(StrSubstNo(tdTxt, Dest));
                LineBuilder.Append(StrSubstNo(tdTxt, OrderLine.Description + '<br><span class="small">' + Format(Item."Net Weight") + 'kg ' + UoM.Description + '</span>'));
                LineBuilder.Append(StrSubstNo(tdTxt, Format(OrderLine."Quantity (Base)")));
                LineBuilder.Append(StrSubstNo(tdTxt, Format(PricingCU.CalculatePriceUnitByUnitPrice(OrderLine."No.", OrderLine."Unit of Measure Code", PricingUnit, OrderLine."Unit Cost"), 0, '$<Precision,2:2><Standard Format,0>')));


                If OrderLine."Qty. Received (Base)" > 0 then

                    //Check if drop ship
                    If OrderLine."Outstanding Qty. (Base)" > 0 then

                        //Partially Shipped
                        Status := format(OrderLine."Qty. Received (Base)") + ' already shipped. Remainder still to be received.'
                    else

                        //Fully Shipped
                        If OrderLine."Qty. Invoiced (Base)" = OrderLine."Qty. Received (Base)" then begin
                            Status := 'Dispatched and invoiced';
                            SuppressLine := true;

                        end
                        else
                            Status := 'Dispatched, but pending invoicing'
                else
                    Status := 'Not yet dispatched';

                LineBuilder.Append(StrSubstNo(tdTxt, Status));

                LineBuilder.AppendLine('</tr>');
                If not SuppressLine then
                    BodyBuilder.Append(LineBuilder.ToText());

            until OrderLine.Next() < 1;

            BodyBuilder.AppendLine('</table>');
        end else
            BodyBuilder.AppendLine('<h2>No pending purchase orders to be dispatched or invoiced</h2>');


        BodyBuilder.AppendLine('<hr>');


        //Check for containers underway that have been received
        Clear(Container);

        Container.SetRange(Type, Container.Type::PurchaseOrder);
        Container.SetRange("Vendor No.", Vendor."No.");
        Container.SetRange(Status, Container.Status::ShippedFromPort);

        if Container.FindSet() then begin



            BodyBuilder.AppendLine('<h2>Containers that have been shipped from port</h2>');
            BodyBuilder.AppendLine('<table class="tfbdata" width="100%" cellspacing="0" cellpadding="10" border="0">');
            BodyBuilder.AppendLine('<thead>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">Order No.</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="10%">BoL Date</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Vessel</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">ETA</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Line</th>');
            BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Your. Ref. No.</th></thead>');


            repeat

                Count := Count + 1;
                SuppressLine := false;
                LineBuilder.Clear();

                Clear(Receipt);
                Receipt.SetRange("Order No.", Container."Order Reference");
                Receipt.SetRange("Buy-from Vendor No.", Container."Vendor No.");


                //BodyBuilder.AppendLine('<tr>');
                LineBuilder.AppendLine('<tr>');
                LineBuilder.Append(StrSubstNo(tdTxt, Container."Order Reference"));
                LineBuilder.Append(StrSubstNo(tdTxt, Format(Container."Departure Date")));
                LineBuilder.Append(StrSubstNo(tdTxt, container."Vessel Details"));
                LineBuilder.Append(StrSubstNo(tdTxt, format(Container."Est. Arrival Date")));
                LineBuilder.Append(StrSubstNo(tdTxt, container."Shipping Line"));

                If Receipt.FindFirst() then
                    LineBuilder.Append(StrSubstNo(tdTxt, Receipt."Vendor Order No."))
                else
                    LineBuilder.Append(StrSubstNo(tdTxt, Receipt."Vendor Order No."));

                LineBuilder.AppendLine('</tr>');
                If not SuppressLine then
                    BodyBuilder.Append(LineBuilder.ToText());

            until Container.Next() < 1;

            BodyBuilder.AppendLine('</table>');
        end else
            BodyBuilder.AppendLine('<h2>No containers on-route from origin to destination</h2>');

        BodyBuilder.AppendLine('<hr>');
        //check for items recently invoiced
        InvoiceLine.SetRange("Buy-from Vendor No.", Vendor."No.");
        InvoiceLine.SetFilter("Posting Date", StrSubstNo('> %1', CalcDate('<-7d>', Today())));
        InvoiceLine.SetFilter("Quantity (Base)", '>0');


        if InvoiceLine.Findset(false) then begin

            BodyBuilder.AppendLine('<h2>Items invoiced in the last seven days</h2>');
            BodyBuilder.AppendLine('<table class="tfbdata" cellspacing="0" cellpadding="10" border="0">');
            BodyBuilder.AppendLine('<thead><th class="tfbdata" width="15%" style="text-align:left">Order No.</th><th class="tfbdata" width="15%" style="text-align:left">Invoice No.</th><th class="tfbdata" style="text-align:left" width="20%">Issued On</th><th class="tfbdata" style="text-align:left" width="20%">Item Desc.</th><th class="tfbdata" style="text-align:left" width="20%">Qty Invoiced</th><th class="tfbdata" style="text-align:left" width="10%">Pricing</th></thead>');

            repeat
                Clear(Invoice);

                Invoice.SetRange("No.", InvoiceLine."Document No.");

                Invoice.FindFirst();
                BodyBuilder.AppendLine('<tr>');
                BodyBuilder.Append(StrSubstNo(tdTxt, InvoiceLine."Order No."));
                BodyBuilder.Append(StrSubstNo(tdTxt, Invoice."Vendor Invoice No."));
                BodyBuilder.Append(StrSubstNo(tdTxt, format(InvoiceLine."Posting Date")));
                BodyBuilder.Append(StrSubstNo(tdTxt, InvoiceLine.Description));
                BodyBuilder.Append(StrSubstNo(tdTxt, Format(InvoiceLine."Quantity (Base)")));
                BodyBuilder.Append(StrSubstNo(tdTxt, Format(PricingCU.CalculatePriceUnitByUnitPrice(InvoiceLine."No.", InvoiceLine."Unit of Measure Code", PricingUnit, InvoiceLine."Unit Cost"), 0, '$<Precision,2:2><Standard Format,0>') + ' per ' + format(PricingUnit)));


                BodyBuilder.AppendLine('</tr>');

            until InvoiceLine.Next() < 1;

            BodyBuilder.AppendLine('</table>');
        end
        else
            BodyBuilder.AppendLine('<h2>No invoices issued in the last 7 days</h2>');

        BodyBuilder.AppendLine('<hr>');

        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        Exit(true);
    end;


}





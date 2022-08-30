codeunit 50142 "TFB Common Library"
{

    /// <summary> 
    /// Retrieves the active HTML email transaction template from Azure Blob Storage that has been setup
    /// </summary>
    /// <param name="RecId">RecordId.</param>
    /// <returns>Return variable "Text".</returns>

    procedure ShowValueHistory(RecId: RecordId)


    var
        Log: Record "Change Log Entry";
        LogP: Page "Change Log Entries";
    begin

        Log.SetRange("Record ID", RecId);
        Log.SetFilter("Old Value", '<>0');
        Log.SetRange("Type of Change", Log."Type of Change"::Modification);
        Log.SetCurrentKey("Date and Time");
        Log.SetAscending("Date and Time", false);

        If not Log.IsEmpty then begin

            LogP.SetTableView(Log);
            LogP.Run();
        end;

    end;

    /// <summary>
    /// GetHTMLTemplateActive.
    /// </summary>
    /// <param name="TitleText">Text.</param>
    /// <param name="SubTitleText">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure GetHTMLTemplateActive(TitleText: Text; SubTitleText: Text): Text
    var
        EmailSetup: Record "TFB Notification Email Setup";
        TempBlobCU: Codeunit "Temp Blob";

        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        IStream: InStream;
        OStream: OutStream;
        BlobText: Text;
        urlTok: text;
        HTMLBuilder: TextBuilder;

    begin

        EmailSetup.Get();
        urlTok := EmailSetup."Email Template Active";

        If urlTok = '' then Error('No URL defined for transactional email template');

        HttpClient.Get(urlTok, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(IStream);
        TempBlobCU.CreateOutStream(OStream);
        CopyStream(OStream, IStream);

        TempBlobCU.CreateInStream(IStream);


        While not (IStream.EOS()) do begin
            IStream.ReadText(BlobText);
            HTMLBuilder.AppendLine(BlobText);
        end;


        HTMLBuilder.Replace('%{EmailTitle}', TitleText);
        HTMLBuilder.Replace('%{EmailSubTitle}', SubTitleText);
        Exit(HTMLBuilder.ToText())
    end;



    procedure GetSpecificationURL(Item: Record Item): Text

    var
        SalesSetup: Record "Sales & Receivables Setup";
        urlTok: text;
    begin
        SalesSetup.Get();
        urlTok := SalesSetup."TFB Specification URL Pattern";
        If urlTok = '' then Error('No URL defined for transactional email template');
        if Item."No." = '' then Error('No valid item code defined');
        Exit(StrSubstNo(urlTok, Item."No."));
    end;

    procedure GetLotImagesURL(type: Text; blobName: Text): Text

    var
        //SalesSetup: Record "Sales & Receivables Setup";
        urlTok: text;
    begin
        //SalesSetup.Get();
        //urlTok := SalesSetup."TFB Specification URL Pattern";
        urlTok := 'https://tfb-manipulator.azurewebsites.net/api/%1?image_path=https://tfbmanipulator.blob.core.windows.net/images/isolated/%2';

        if (urlTok = '') or (type = '') or (blobName = '') then error('Incorrect details provided for url construction');
        Exit(StrSubstNo(urlTok, type, blobName));
    end;


    procedure GetIsolatedImagesURL(originalBlobName: text): Text

    var
        //SalesSetup: Record "Sales & Receivables Setup";
        urlTok: text;
    begin
        //SalesSetup.Get();
        //urlTok := SalesSetup."TFB Specification URL Pattern";
        urlTok := 'https://tfb-manipulator.azurewebsites.net/api/isolate?image_path=https://tfbmanipulator.blob.core.windows.net/images/%1';


        Exit(StrSubstNo(urlTok, originalBlobName));
    end;

    procedure GetSpecificationTempBlob(Item: Record Item): Codeunit "Temp Blob"
    var

        TempBlobCU: Codeunit "Temp Blob";
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        IStream: InStream;
        OStream: OutStream;
    begin

        HttpClient.Get(GetSpecificationURL(Item), HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(IStream);
        TempBlobCU.CreateOutStream(OStream);
        CopyStream(OStream, IStream);

        Exit(TempBlobCU);
    end;

    procedure GetLotImagesTempBlob(type: text; blobName: text): Codeunit "Temp Blob"
    var

        TempBlobCU: Codeunit "Temp Blob";
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        IStream: InStream;
        OStream: OutStream;
    begin

        HttpClient.Get(GetLotImagesURL(type, blobName), HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(IStream);
        TempBlobCU.CreateOutStream(OStream);
        CopyStream(OStream, IStream);

        Exit(TempBlobCU);
    end;

    procedure GetIsolatedImagesTempBlob(OriginalBlobName: text): Codeunit "Temp Blob"
    var

        TempBlobCU: Codeunit "Temp Blob";
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        IStream: InStream;
        OStream: OutStream;
    begin

        HttpClient.Get(GetIsolatedImagesURL(OriginalBlobName), HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(IStream);
        TempBlobCU.CreateOutStream(OStream);
        CopyStream(OStream, IStream);

        Exit(TempBlobCU);
    end;

    procedure GetCustDelInstr(CustomerNo: Code[20]; ShipToCode: Code[10]): Text[2048]
    var
        Customer: record Customer;
        ShipToAddress: record "Ship-to Address";
        DelInstrBuilder: TextBuilder;

    begin


        begin
            DelInstrBuilder.Clear();
            If ShipToAddress.Get(CustomerNo, ShipToCode) then begin
                DelInstrBuilder.Append(ShipToAddress."TFB Delivery Instructions");
                If ShipToAddress."TFB Override Pallet Details" and (ShipToAddress."TFB Pallet Account No." <> '') then begin
                    DelInstrBuilder.AppendLine(format(ShipToAddress."TFB Pallet Acct Type"));
                    DelInstrBuilder.Append('-' + ShipToAddress."TFB Pallet Account No.");
                end
                else
                    If Customer."TFB Pallet Account No" <> '' then begin
                        DelInstrBuilder.AppendLine(format(Customer."TFB Pallet Acct Type"));
                        DelInstrBuilder.AppendLine('-' + Customer."TFB Pallet Account No");
                    end;
            end
            else
                If Customer.get(CustomerNo) then begin

                    DelInstrBuilder.Append(Customer."TFB Delivery Instructions");
                    If Customer."TFB Pallet Account No" <> '' then begin
                        DelInstrBuilder.AppendLine(format(Customer."TFB Pallet Acct Type"));
                        DelInstrBuilder.AppendLine(Customer."TFB Pallet Account No");
                    end;

                end;

            Exit(CopyStr(DelInstrBuilder.ToText(), 1, 2048));


        end;
    end;

    procedure CalcEffectiveIR(AnnualRate: Decimal; Days: Decimal): Decimal

    var
        EffectiveIR: Decimal;

    begin

        EffectiveIR := (AnnualRate / 100 / 365) * Days;
        Exit(EffectiveIR);

    end;

    procedure ConvertDurationToDays(Duration: Duration): Decimal

    begin
        Exit(Duration / 3600000 / 24)
    end;

    procedure CheckAndSendCoA(OrderNo: Code[20]; SuppressErr: Boolean; CheckPref: Boolean; Resend: Boolean): Boolean

    var

        //Variables Related to Retrieving Data
        SalesOrder: Record "Sales Header";
        Customer: Record Customer;
        Shipment: Record "Sales Shipment Header";
        SalesLine: Record "Sales Line";
        ShipmentLine: Record "Sales Shipment Line";
        ReservationEntry: Record "Reservation Entry";
        CommEntry: Record "TFB Communication Entry";
        LedgerEntry: Record "Item Ledger Entry";
        LotInfo: Record "Lot No. Information";
        CompanyInfo: Record "Company Information";
        PersBlobCU: CodeUnit "Persistent Blob";
        TempBlobCU: CodeUnit "Temp Blob";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        EmailScenEnum: Enum "Email Scenario";
        LoopCount: Integer;
        HeaderSetup: Boolean;

        //Variables Related to Sending Email



        InStream: InStream;
        OutStream: OutStream;
        EmailID: Text;
        FileNameBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;
        Recipients: List of [Text];

        BodyBuilder: TextBuilder;
        FirstShipment: Boolean;

    //Supporting Variables



    begin


        CompanyInfo.Get();
        HeaderSetup := false;



        //Check If Order is UnPosted
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", OrderNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        Salesline.SetFilter(Quantity, '>0');

        If SalesLine.FindSet(true, false) then begin

            //Check to See if Customer wants COA's
            Customer.Get(SalesLine."Sell-to Customer No.");
            If (not Customer."TFB CoA Required") and (checkPref = true) then
                Exit(false);

            if Customer."TFB CoA Alt. Email" = '' then
                EmailID := Customer."E-Mail"
            else
                EmailID := Customer."TFB CoA Alt. Email";


            //Retrieve SalesOrder to get External Document No
            SalesOrder.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesOrder.SetRange("No.", SalesLine."Document No.");

            SubjectNameBuilder.Append('CoA details for Order No. ');
            SubjectNameBuilder.Append(OrderNo);

            if SalesOrder."External Document No." <> '' then begin
                SubjectNameBuilder.Append(' for your PO Ref ');
                SubjectNameBuilder.Append(SalesOrder."External Document No.");
            end;


            Recipients.Add(EmailID);

            EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), BodyBuilder.ToText(), true);
            BodyBuilder.AppendLine('Hi ' + Customer.Name);
            BodyBuilder.AppendLine('<br>');
            BodyBuilder.AppendLine('Please find attached Certificate of analysis details for our order ' + OrderNo);
            BodyBuilder.AppendLine('<table><tr><th>Item Name</th><th>Item Code</th><th>File Name</th>');
            HeaderSetup := True;


            //Document is so look for reservation entries, not ledger entries
            repeat
                if (not SalesLine."TFB CoA Sent") or (Resend = true) then begin
                    ReservationEntry.SetRange("Source Type", 37);
                    ReservationEntry.SetRange("Source ID", OrderNo);
                    ReservationEntry.SetRange("Source Subtype", 1);
                    ReservationEntry.SetRange("Source Ref. No.", SalesLine."Line No.");


                    If ReservationEntry.FindSet(false, false) then
                        repeat
                            //Look through reservation entries
                            LotInfo.SetRange("Item No.", ReservationEntry."Item No.");
                            LotInfo.SetRange("Lot No.", ReservationEntry."Lot No.");
                            LotInfo.SetRange("Variant Code", ReservationEntry."Variant Code");

                            If LotInfo.FindFirst() then begin
                                LoopCount := LoopCount + 1;

                                If PersBlobCU.Exists(LotInfo."TFB CoA Attach.") then begin

                                    //Add attachmemnt details
                                    TempBlobCU.CreateOutStream(OutStream);
                                    TempBlobCU.CreateInStream(InStream);
                                    PersBlobCU.CopyToOutStream(LotInfo."TFB CoA Attach.", OutStream);
                                    CopyStream(OutStream, InStream);

                                    Clear(FileNameBuilder);
                                    FileNameBuilder.Append('CoA_');
                                    FileNameBuilder.Append(LotInfo."Item No.");
                                    FileNameBuilder.Append(LotInfo."Variant Code");
                                    FileNameBuilder.Append('_' + LotInfo."Lot No.");
                                    FileNameBuilder.Append('.pdf');


                                    BodyBuilder.AppendLine(StrSubstNo('<tr><td>%1</td><td>%2</td><td>%3</td></tr>', SalesLine.Description, LotInfo."Item No.", FileNameBuilder.ToText()));
                                    SalesLine."TFB CoA Sent" := true;
                                    SalesLine.Modify();
                                end else
                                    BodyBuilder.AppendLine(StrSubstNo('<tr><td>%1</td><td>%2</td><td>%3</td></tr>', LotInfo.Description, LotInfo."Item No.", 'No File Located'));



                            end;
                        until ReservationEntry.Next() = 0;
                end;
            until SalesLine.Next() = 0;


        end;

        //Check posted details in item ledger against sales shipment
        //Ensure we only create header once
        FirstShipment := true;
        ShipmentLine.SetRange("Order No.", OrderNo);
        ShipmentLine.SetFilter(Quantity, '>0');


        if ShipmentLine.FindSet(true, false) then
            repeat
                If (not ShipmentLine."TFB CoA Sent") or (Resend = false) then begin

                    if FirstShipment and not HeaderSetup then begin
                        //Check to See if Customer wants COA's
                        Customer.Get(ShipmentLine."Sell-to Customer No.");
                        If not Customer."TFB CoA Required" then
                            Exit(false);

                        If (not Customer."TFB CoA Required") and (checkPref = true) then
                            EmailID := Customer."E-Mail"
                        else
                            EmailID := Customer."TFB CoA Alt. Email";


                        //Retrieve SalesOrder to get External Document No

                        SubjectNameBuilder.Append('CoA details for Order No. ');
                        SubjectNameBuilder.Append(OrderNo);

                        //Retrieve Shipment
                        Shipment.SetRange("Order No.", OrderNo);
                        If Shipment.FindFirst() then
                            if Shipment."External Document No." <> '' then begin
                                SubjectNameBuilder.Append(' for your PO Ref ');
                                SubjectNameBuilder.Append(Shipment."External Document No.");
                            end;



                        Recipients.Add(EmailID);

                        BodyBuilder.AppendLine('Hi ' + Customer.Name);
                        BodyBuilder.AppendLine('<br><br>');
                        BodyBuilder.AppendLine('Please find attached Certificate of analysis details for our order ' + OrderNo);

                        If SalesOrder."External Document No." <> '' then
                            BodyBuilder.Append(' and your order reference ' + SalesOrder."External Document No.");

                        BodyBuilder.AppendLine('<table><tr><th>Item Name</th><th>Item Code</th><th>File Name</th>');
                        FirstShipment := false;
                    end;

                    //Find Lines for Shipment
                    LedgerEntry.SetRange("Source Type", LedgerEntry."Source Type"::Customer);
                    LedgerEntry.SetRange("Document Type", LedgerEntry."Document Type"::"Sales Shipment");
                    LedgerEntry.SetRange("Document No.", ShipmentLine."Document No.");

                    If LedgerEntry.FindSet(false, false) then
                        repeat

                            //Get Lot Info
                            LotInfo.SetRange("Item No.", LedgerEntry."Item No.");
                            LotInfo.SetRange("Lot No.", LedgerEntry."Lot No.");
                            LotInfo.SetRange("Variant Code", LedgerEntry."Variant Code");

                            If LotInfo.FindFirst() then begin

                                //Indicate that Lot COA has been found
                                LoopCount := LoopCount + 1;
                                If PersBlobCU.Exists(LotInfo."TFB CoA Attach.") then begin

                                    //Add attachmemnt details
                                    TempBlobCU.CreateOutStream(OutStream);
                                    TempBlobCU.CreateInStream(InStream);
                                    PersBlobCU.CopyToOutStream(LotInfo."TFB CoA Attach.", OutStream);
                                    CopyStream(OutStream, InStream);

                                    Clear(FileNameBuilder);
                                    FileNameBuilder.Append('CoA_');
                                    FileNameBuilder.Append(LotInfo."Item No.");
                                    FileNameBuilder.Append(LotInfo."Variant Code");
                                    FileNameBuilder.Append('_' + LotInfo."Lot No.");
                                    FileNameBuilder.Append('.pdf');



                                    BodyBuilder.AppendLine(StrSubstNo('<tr><td>%1</td><td>%2</td><td>%3</td></tr>', LotInfo.Description, LotInfo."Item No.", FileNameBuilder.ToText()));
                                    ShipmentLine."TFB CoA Sent" := true;
                                    ShipmentLine.Modify(false);

                                end else
                                    BodyBuilder.AppendLine(StrSubstNo('<tr><td>%1</td><td>%2</td><td>%3</td></tr>', LotInfo.Description, LotInfo."Item No.", 'No File Located'));
                            end;
                        until LedgerEntry.Next() < 1;
                end;

            until ShipmentLine.Next() < 1;


        //All Sales Shipment Found - Send For Order
        BodyBuilder.AppendLine('</table>');
        BodyBuilder.AppendLine('<HR> This is a system generated mail. Please do not reply');


        If LoopCount > 0 then begin

            EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), BodyBuilder.ToText(), true);
            EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/PDF', InStream);
            Email.AddRelation(EmailMessage, Database::Customer, Customer.SystemId, Enum::"Email Relation Type"::"Related Entity");
            Email.Enqueue(EmailMessage, EmailScenEnum::Quality);

            CommEntry.Init();
            CommEntry."Source Type" := CommEntry."Source Type"::Customer;
            CommEntry."Source ID" := Customer."No.";
            CommEntry."Source Name" := Customer.Name;
            CommEntry."Record Type" := commEntry."Record Type"::QDI;
            CommEntry."Record Table No." := Database::"Sales Header";
            CommEntry."Record No." := SalesOrder."No.";
            CommEntry.Direction := CommEntry.Direction::Outbound;
            CommEntry.MessageContent := CopyStr(BodyBuilder.ToText(), 1, 2048);
            CommEntry.Method := CommEntry.Method::EMAIL;
            CommEntry.Insert();

            Exit(True);

        end else
            Exit(False);

    end;

    procedure CheckIfExternalIdsVisible(): Boolean
    var
        UserSetup: Record "User Setup";
        User: record User;

    begin

        If User.Get(Database.UserSecurityId()) then
            If UserSetup.Get(User."User Name") then
                Exit(UserSetup."TFB Show External IDs");

    end;
}
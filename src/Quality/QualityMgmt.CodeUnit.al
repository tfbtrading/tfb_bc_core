codeunit 50104 "TFB Quality Mgmt"
{

    procedure CalcDaysToExpiry(ExpiryDate: Date): Integer
    var
        DaysToExpiry: Integer;

    begin

        if ExpiryDate <> 0D then
            DaysToExpiry := ExpiryDate - Today();

        exit(DaysToExpiry);

    end;

    procedure GetCurrentStatus(Archived: Boolean; Inherent: Boolean; ExpiryDate: Date): Enum "TFB Quality Certificate Status";

    var
        DaysToExpiry: Integer;
        Status: Enum "TFB Quality Certificate Status";


    begin
        if not Archived then begin
            if not Inherent then
                if ExpiryDate > 0D then begin

                    DaysToExpiry := CalcDaysToExpiry(ExpiryDate);

                    case DaysToExpiry of
                        -10000 .. -1:
                            Status := Status::Expired;
                        0 .. 5:
                            Status := Status::"About to Expire";

                        6 .. 30:
                            Status := Status::"Expiring Soon";
                        else
                            Status := Status::Active;

                    end;
                end
                else
                    Status := Status::Pending
            else
                Status := Status::Inherent;
        end
        else
            Status := Status::Archived;
        exit(Status);
    end;


    procedure GetCertificateFileName(Certification: record "TFB Vendor Certification"): Text

    var
        FileNameBuilder: TextBuilder;

    begin
        FileNameBuilder.Append('Certificate_');
        FileNameBuilder.Append(Certification."Vendor No.");
        if Certification.Site <> '' then begin
            FileNameBuilder.Append('-');
            FileNameBuilder.Append(Certification.Site);
        end;
        FileNameBuilder.Append('_');
        FileNameBuilder.Append(Certification."Certification Type");
        FileNameBuilder.Append('.pdf');
        exit(FileNameBuilder.ToText());

    end;

    procedure GetCertificateFileName(Certification: record "TFB Company Certification"): Text

    var
        FileNameBuilder: TextBuilder;

    begin
        FileNameBuilder.Append('Certificate');
        if Certification."Location Specific" then
            FileNameBuilder.Append('_' + Certification."Location Code");
        FileNameBuilder.Append('_');
        FileNameBuilder.Append(Certification."Certification Type");
        FileNameBuilder.Append('.pdf');
        exit(FileNameBuilder.ToText());

    end;

    procedure GetStatusEmoticon(Status: Enum "TFB Quality Certificate Status"): Text

    begin

        case Status of
            status::"About to Expire":
                exit('⚠️');

            status::"Expiring Soon":
                exit('🔖');

            status::Expired:
                exit('❌');

            status::Active:
                exit('✔️');

            status::Pending:
                exit('🕙');
            status::Inherent:
                exit('🔘');
            status::Archived:
                exit('🗄️')
        end;
    end;

    procedure GatherCustomerQualityDocuments(CustomerNo: Code[20]; var DictVendors: Dictionary of [Code[20], List of [Code[20]]]; var ListOfCertifications: Record "TFB Vendor Certification" temporary; IncludeReligiousCertifications: Boolean): Boolean

    var
        VendorCertification: Record "TFB Vendor Certification";
        ListQuery: Query "TFB Items Shipped";
        DictItems: Dictionary of [Code[20], Integer];

        ListItems: List of [Code[20]];
        VendorNo: Code[20];



    begin
        CLEAR(ListOfCertifications);
        ListQuery.SetRange(Sell_to_Customer_No_, CustomerNo);
        ListQuery.SetFilter(Posting_Date, 't-1y..t');
        ListQuery.Open();

        while ListQuery.Read() do begin
            DictItems.Add(ListQuery.No_, ListQuery.Count_);
            if DictVendors.ContainsKey(ListQuery.Vendor_No_) then
                DictVendors.Get(ListQuery.Vendor_No_).Add(ListQuery.No_)
            else begin
                ListItems.Add(ListQuery.No_);
                DictVendors.Add(ListQuery.Vendor_No_, ListItems);
                Clear(ListItems);
            end;
        end;

        foreach VendorNo in DictVendors.Keys() do begin
            //Retrieve quality documentation
            VendorCertification.SetRange("Vendor No.", VendorNo);
            VendorCertification.SetAutoCalcFields(VendorCertification."Certificate Class");

            if VendorCertification.FindSet() then
                repeat
                    if not IncludeReligiousCertifications and not (VendorCertification."Certificate Class" = VendorCertification."Certificate Class"::Quality) then begin
                        ListOfCertifications := VendorCertification;
                        ListOfCertifications.Insert(false);
                    end
                    else
                        if (VendorCertification."Certificate Class" = VendorCertification."Certificate Class"::Quality) then begin
                            ListOfCertifications := VendorCertification;
                            ListOfCertifications.Insert(false);
                        end;
                until VendorCertification.Next() < 1;

        end;

        exit(ListOfCertifications.Count() > 0);

    end;

    procedure SendQualityDocumentsToCustomer(CustomerNo: Code[20]; HideDialog: Boolean): Boolean

    var

        Customer: Record Customer;
        TempVendorCertifications: Record "TFB Vendor Certification" temporary;
        CLib: CodeUnit "TFB Common Library";
        DialogChoices: Page "TFB Quality Docs Dialog";

        SubTitleTxt: Label '';
        TitleTxt: Label 'Vendor certifications';
        DictVendors: Dictionary of [Code[20], List of [Code[20]]];

    begin
        DialogChoices.SetCustomerNo(CustomerNo);
        if not HideDialog then
            if not (DialogChoices.RunModal() = Action::OK) then exit;

        if Customer.get(CustomerNo) and GatherCustomerQualityDocuments(CustomerNo, DictVendors, TempVendorCertifications, DialogChoices.getVendCertSel()) then
            if (DialogChoices.GetRecipients().Count > 0) or DialogChoices.getDownloadSel() then
                ProcessVendorCertifications(TempVendorCertifications, DictVendors, DialogChoices, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt), Customer.SystemId);

    end;


    internal procedure SendVendorCertificationEmail(var VendorCerts: Record "TFB Vendor Certification"; Recipients: List of [Text]; HTMLTemplate: Text)

    var

        CustomerSystemID: GUID;

    begin

        SendVendorCertificationEmail(VendorCerts, Recipients, HTMLTemplate, CustomerSystemID);

    end;

    internal procedure SendCompanyCertificationEmail(var CompanyCerts: Record "TFB Company Certification"; Recipients: List of [Text]; HTMLTemplate: Text)

    var

        CustomerSystemID: GUID;

    begin

        SendCompanyCertificationEmail(CompanyCerts, Recipients, HTMLTemplate, CustomerSystemID);

    end;

    internal procedure SendVendorCertificationEmail(var VendorCerts: Record "TFB Vendor Certification"; Recipients: List of [Text]; HTMLTemplate: Text; CustomerSystemID: GUID)

    var
        CompanyInfo: Record "Company Information";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        PersBlobCU: CodeUnit "Persistent Blob";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;

        FileNameBuilder: TextBuilder;
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;

    begin

        CompanyInfo.Get();

        SubjectNameBuilder.Append(QualityTitleTxt);


        HTMLBuilder.Append(HTMLTemplate);

        GenerateQualityDocumentsContent(VendorCerts, HTMLBuilder);

        EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);
        if VendorCerts.Findset(false) then
            repeat
                if PersBlobCU.Exists(VendorCerts."Certificate Attach.") then begin
                    Clear(FileNameBuilder);
                    FileNameBuilder.Append(StrSubstNo('Cert %1_%2_%3.pdf', VendorCerts."Vendor Name", VendorCerts.Site, VendorCerts."Certification Type"));
                    TempBlob.CreateOutStream(Outstream);
                    PersBlobCU.CopyToOutStream(VendorCerts."Certificate Attach.", OutStream);
                    TempBlob.CreateInStream(InStream);
                    EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/PDF', InStream);
                end


            until VendorCerts.Next() < 1;

        if not IsNullGuid(CustomerSystemID) then
            Email.AddRelation(EmailMessage, Database::Customer, CustomerSystemID, Enum::"Email Relation Type"::"Related Entity", eNUM::"Email Relation Origin"::"Compose Context");
        Email.OpenInEditorModally(EmailMessage, Enum::"Email Scenario"::Quality)

    end;

    internal procedure ProcessVendorCertifications(var VendorCerts: Record "TFB Vendor Certification"; DictVendors: Dictionary of [Code[20], List of [Code[20]]]; DialogChoices: Page "TFB Quality Docs Dialog"; HTMLTemplate: Text; CustomerSystemID: GUID)

    var
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        CompanyCert: Record "TFB Company Certification";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        PersBlobCU: CodeUnit "Persistent Blob";
        DataCompCU: CodeUnit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        ZipTempBlob: CodeUnit "Temp Blob";
        TempBlobList: CodeUnit "Temp Blob List";

        InStream: InStream;
        InstreamExcel: Instream;
        OutStream: OutStream;
        TitleTxt: Label 'Quality Documents Request';
        FileNameBuilder: TextBuilder;
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;
        i: integer;
        FileName: Text;
        FileNameList: List of [Text];
    begin

        CompanyInfo.Get();

        SubjectNameBuilder.Append(TitleTxt);


        HTMLBuilder.Append(HTMLTemplate);
        Customer.GetBySystemId(CustomerSystemID);
        GenerateQualityDocumentsContent(DialogChoices, Customer, VendorCerts, DictVendors, HTMLBuilder);

        if not DialogChoices.getDownloadSel() then
            EmailMessage.Create(DialogChoices.getRecipients(), SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);

        if VendorCerts.Findset(false) then
            repeat
                if PersBlobCU.Exists(VendorCerts."Certificate Attach.") then begin
                    Clear(FileNameBuilder);
                    FileNameBuilder.Append(StrSubstNo('Cert %1_%2_%3.pdf', VendorCerts."Vendor Name", VendorCerts.Site, VendorCerts."Certification Type"));
                    TempBlob.CreateOutStream(Outstream);
                    PersBlobCU.CopyToOutStream(VendorCerts."Certificate Attach.", OutStream);
                    TempBlob.CreateInStream(InStream);

                    if (not DialogChoices.getDownloadSel()) and (not DialogChoices.getCompressSel()) then
                        EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/PDF', InStream)
                    else begin
                        TempBlobList.Add(TempBlob);
                        FileNameList.Add(FileNameBuilder.ToText());
                    end;
                end


            until VendorCerts.Next() < 1;

        if DialogChoices.getCompCertSel() then
            if CompanyCert.FindSet(false) then
                repeat
                    if PersBlobCU.Exists(CompanyCert."Certificate Attach.") then begin
                        Clear(FileNameBuilder);
                        FileNameBuilder.Append(StrSubstNo('Cert %1_%2_%3.pdf', 'TFB', '', CompanyCert."Certification Type"));
                        TempBlob.CreateOutStream(Outstream);
                        PersBlobCU.CopyToOutStream(CompanyCert."Certificate Attach.", OutStream);
                        TempBlob.CreateInStream(InStream);

                        if (not DialogChoices.getDownloadSel()) and (not DialogChoices.getCompressSel()) then
                            EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/PDF', InStream)
                        else begin
                            TempBlobList.Add(TempBlob);
                            FileNameList.Add(FileNameBuilder.ToText());
                        end;
                    end;

                until CompanyCert.Next() = 0;


        if GenerateExcelDocument(DialogChoices, VendorCerts, CompanyCert, DictVendors, TempBlob) then begin
            TempBlob.CreateInStream(InstreamExcel);
            if not DialogChoices.getDownloadSel() then
                EmailMessage.AddAttachment('Quality Documents Index.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', InstreamExcel)
            else begin
                TempBlobList.Add(TempBlob);
                FileNameList.Add('Quality Documents Index.xlsx');
            end;
        end;

        if DialogChoices.getDownloadSel() or DialogChoices.getCompressSel() then
            if TempBlobList.Count() >= 1 then begin
                DataCompCU.CreateZipArchive();

                for i := 1 to TempBlobList.Count() do begin
                    TempBlobList.Get(i, TempBlob);
                    TempBlob.CreateInStream(InStream);
                    FileName := FileNameList.Get(i);
                    DataCompCU.AddEntry(InStream, FileName);
                end;

                DataCompCU.SaveZipArchive(ZipTempBlob);
                ZipTempBlob.CreateInStream(InStream);
                FileName := StrSubstNo('All quality certificates x %1.zip', TempBlobList.Count());
            end;

        if not DialogChoices.getDownloadSel() then begin
            if not IsNullGuid(CustomerSystemID) then
                Email.AddRelation(EmailMessage, Database::Customer, CustomerSystemID, Enum::"Email Relation Type"::"Related Entity", eNUM::"Email Relation Origin"::"Compose Context");
            if DialogChoices.getCompressSel() then
                EmailMessage.AddAttachment(FileName, 'Application/ZIP', InStream);
            Email.OpenInEditorModally(EmailMessage, Enum::"Email Scenario"::Quality)
        end
        else
            if not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
                Error('File %1 not downloaded', FileName);
    end;



    internal procedure SendCompanyCertificationEmail(var CompanyCerts: Record "TFB Company Certification"; Recipients: List of [Text]; HTMLTemplate: Text; CustomerSystemID: GUID)

    var
        CompanyInfo: Record "Company Information";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        PersBlobCU: CodeUnit "Persistent Blob";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;

        FileNameBuilder: TextBuilder;
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;

    begin

        CompanyInfo.Get();

        SubjectNameBuilder.Append(QualityTitleTxt);


        HTMLBuilder.Append(HTMLTemplate);

        GenerateQualityDocumentsContent(CompanyCerts, HTMLBuilder);

        EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);
        if CompanyCerts.Findset(false) then
            repeat
                if PersBlobCU.Exists(CompanyCerts."Certificate Attach.") then begin
                    Clear(FileNameBuilder);
                    FileNameBuilder.Append(StrSubstNo('Cert %1', CompanyCerts."Certification Type"));
                    if CompanyCerts."Location Specific" then
                        FileNameBuilder.Append(StrSubstNo('_%2', CompanyCerts."Location Code"));
                    FileNameBuilder.Append('.pdf');
                    TempBlob.CreateOutStream(Outstream);
                    PersBlobCU.CopyToOutStream(CompanyCerts."Certificate Attach.", OutStream);
                    TempBlob.CreateInStream(InStream);
                    EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(), 1, 250), 'Application/PDF', InStream);
                end

            until CompanyCerts.Next() < 1;

        if not IsNullGuid(CustomerSystemID) then
            Email.AddRelation(EmailMessage, Database::Customer, CustomerSystemID, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");
        Email.OpenInEditorModally(EmailMessage, Enum::"Email Scenario"::Quality)

    end;




    local procedure GenerateQualityDocumentsContent(var VendorCertification: Record "TFB Vendor Certification"; var HTMLBuilder: TextBuilder): Boolean

    var
        PersBlob: CodeUnit "Persistent Blob";
        BodyBuilder: TextBuilder;
        CommentBuilder: TextBuilder;
        LineBuilder: TextBuilder;

    begin

        HTMLBuilder.Replace('%{ExplanationCaption}', 'Request Type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Updated Vendor Certifications');
        HTMLBuilder.Replace('%{DateCaption}', 'Requested on');
        HTMLBuilder.Replace('%{DateValue}', format(today()));
        HTMLBuilder.Replace('%{ReferenceCaption}', '');
        HTMLBuilder.Replace('%{ReferenceValue}', '');
        HTMLBuilder.Replace('%{AlertText}', '');

        BodyBuilder.AppendLine(StrSubstNo('<h2>Please find our latest quality documents as requested</h2><br>'));

        BodyBuilder.AppendLine('<table class="tfbdata" width="100%" cellspacing="10" cellpadding="10" border="0">');
        BodyBuilder.AppendLine('<thead>');

        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="40%">Vendor</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Location</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="25%">Type</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="7.5%">Expiry</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="7.5%">Attachment</th></thead>');

        if VendorCertification.Findset(false) then begin
            repeat

                Clear(LineBuilder);
                Clear(CommentBuilder);
                LineBuilder.AppendLine('<tr>');

                LineBuilder.Append(StrSubstNo(tdTxt, VendorCertification."Vendor Name"));
                LineBuilder.Append(StrSubstNo(tdTxt, VendorCertification.Site));
                LineBuilder.Append(StrSubstNo(tdTxt, VendorCertification."Certification Type"));
                LineBuilder.Append(StrSubstNo(tdTxt, VendorCertification."Expiry Date"));
                LineBuilder.Append(StrSubstNo(tdTxt, PersBlob.Exists(VendorCertification."Certificate Attach.")));
                LineBuilder.AppendLine('</tr>');
                BodyBuilder.AppendLine(LineBuilder.ToText());



            until VendorCertification.Next() < 1;
            BodyBuilder.AppendLine('</table>');
        end
        else
            BodyBuilder.AppendLine('<h2>No quality documents found for vendor items shipped</h2>');

        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        exit(true);
    end;

    local procedure GenerateQualityDocumentsContent(DialogChoices: Page "TFB Quality Docs Dialog"; Customer: Record Customer; var VendorCertification: Record "TFB Vendor Certification"; DictVendors: Dictionary of [Code[20], List of [Code[20]]]; var HTMLBuilder: TextBuilder): Boolean

    var
        Item: Record Item;
        CompanyCertifications: Record "TFB Company Certification";
        PersBlob: CodeUnit "Persistent Blob";
        BodyBuilder: TextBuilder;
        CommentBuilder: TextBuilder;
        LineBuilder: TextBuilder;
        ItemBuilder: TextBuilder;
        ItemList: List of [Code[20]];
        ItemNo: Code[20];

    begin

        HTMLBuilder.Replace('%{ExplanationCaption}', 'Request Type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Updated Vendor Certifications');
        HTMLBuilder.Replace('%{DateCaption}', 'Requested on');
        HTMLBuilder.Replace('%{DateValue}', format(today()));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'customer');
        HTMLBuilder.Replace('%{ReferenceValue}', Customer.name);
        HTMLBuilder.Replace('%{AlertText}', '');

        BodyBuilder.AppendLine(StrSubstNo('<p>Please find our latest quality documents as requested</p>'));

        BodyBuilder.AppendLine('<table class="tfbdata" width="70%" cellspacing="10" cellpadding="10" border="0">');
        BodyBuilder.AppendLine('<thead style="border-bottom: 1pt solid #ff000d">');

        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Vendor</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Location</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="25%">Type</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="7.5%">Expiry</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="7.5%">Attachment</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" vertical-align="top" width="20%">Related items</th></thead>');
        Item.SetLoadFields(Description);

        if DialogChoices.getCompCertSel() then
            if CompanyCertifications.Findset(false) then
                repeat
                    Clear(LineBuilder);
                    Clear(CommentBuilder);
                    LineBuilder.AppendLine('<tr>');

                    LineBuilder.Append(StrSubstNo(tdTxt, 'TFB Certification'));
                    LineBuilder.Append(StrSubstNo(tdTxt, ''));
                    LineBuilder.Append(StrSubstNo(tdTxt, CompanyCertifications."Certification Type"));
                    LineBuilder.Append(StrSubstNo(tdTxt, CompanyCertifications."Expiry Date"));
                    LineBuilder.Append(StrSubstNo(tdTxt, PersBlob.Exists(CompanyCertifications."Certificate Attach.")));

                    LineBuilder.Append(StrSubstNo(tdTxt, 'All items'));
                    Clear(ItemBuilder);
                    Clear(ItemList);
                    LineBuilder.AppendLine('</tr>');
                    BodyBuilder.AppendLine(LineBuilder.ToText());
                until CompanyCertifications.Next() = 0;

        if VendorCertification.Findset(false) then begin
            repeat

                Clear(LineBuilder);
                Clear(CommentBuilder);
                LineBuilder.AppendLine('<tr>');

                LineBuilder.Append(StrSubstNo(tdTxt, VendorCertification."Vendor Name"));
                LineBuilder.Append(StrSubstNo(tdTxt, VendorCertification.Site));
                LineBuilder.Append(StrSubstNo(tdTxt, VendorCertification."Certification Type"));
                LineBuilder.Append(StrSubstNo(tdTxt, VendorCertification."Expiry Date"));
                LineBuilder.Append(StrSubstNo(tdTxt, PersBlob.Exists(VendorCertification."Certificate Attach.")));
                if DictVendors.ContainsKey(VendorCertification."Vendor No.") then begin
                    ItemList := DictVendors.Get(VendorCertification."Vendor No.");
                    foreach ItemNo in ItemList do begin
                        Item.Get(ItemNo);
                        ItemBuilder.AppendLine(Item.Description + '<br>');
                    end;
                end;
                LineBuilder.Append(StrSubstNo(tdTxt, ItemBuilder.ToText()));
                Clear(ItemBuilder);
                Clear(ItemList);
                LineBuilder.AppendLine('</tr>');
                BodyBuilder.AppendLine(LineBuilder.ToText());



            until VendorCertification.Next() < 1;
            BodyBuilder.AppendLine('</table>');
        end
        else
            BodyBuilder.AppendLine('<h2>No quality documents found for vendor items shipped</h2>');

        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        exit(true);
    end;

    local procedure GenerateQualityDocumentsContent(var CompanyCertification: Record "TFB Company Certification"; var HTMLBuilder: TextBuilder): Boolean

    var
        PersBlob: CodeUnit "Persistent Blob";

        BodyBuilder: TextBuilder;
        CommentBuilder: TextBuilder;
        LineBuilder: TextBuilder;

    begin

        HTMLBuilder.Replace('%{ExplanationCaption}', 'Request Type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Updated Vendor Certifications');
        HTMLBuilder.Replace('%{DateCaption}', 'Requested on');
        HTMLBuilder.Replace('%{DateValue}', format(today()));
        HTMLBuilder.Replace('%{ReferenceCaption}', '');
        HTMLBuilder.Replace('%{ReferenceValue}', '');
        HTMLBuilder.Replace('%{AlertText}', '');

        BodyBuilder.AppendLine(StrSubstNo('<h2>Please find out latest quality documents as requested</h2><br>'));

        BodyBuilder.AppendLine('<table class="tfbdata" width="100%" cellspacing="10" cellpadding="10" border="0">');
        BodyBuilder.AppendLine('<thead>');

        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Location</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="25%">Type</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="7.5%">Expiry</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="7.5%">Attachment</th></thead>');

        if CompanyCertification.Findset(false) then begin
            repeat

                Clear(LineBuilder);
                Clear(CommentBuilder);
                LineBuilder.AppendLine('<tr>');
                CompanyCertification.CalcFields(Location);
                if CompanyCertification."Location Specific" then
                    LineBuilder.Append(StrSubstNo(tdTxt, 'Company wide'))
                else
                    LineBuilder.Append(StrSubstNo(tdTxt, CompanyCertification.Location));
                LineBuilder.Append(StrSubstNo(tdTxt, CompanyCertification."Certification Type"));
                LineBuilder.Append(StrSubstNo(tdTxt, CompanyCertification."Expiry Date"));
                LineBuilder.Append(StrSubstNo(tdTxt, PersBlob.Exists(CompanyCertification."Certificate Attach.")));
                LineBuilder.AppendLine('</tr>');
                BodyBuilder.AppendLine(LineBuilder.ToText());



            until CompanyCertification.Next() < 1;
            BodyBuilder.AppendLine('</table>');
        end
        else
            BodyBuilder.AppendLine('<h2>No quality documents found for vendor items shipped</h2>');

        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        exit(true);
    end;

    local procedure GenerateExcelDocument(DialogChoices: Page "TFB Quality Docs Dialog"; var VendorCertification: Record "TFB Vendor Certification"; CompanyCertification: Record "TFB Company Certification"; DictVendors: Dictionary of [Code[20], List of [Code[20]]]; var TempBlob: CodeUnit "Temp Blob"): Boolean
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        Item: Record Item;
        PersBlob: CodeUnit "Persistent Blob";

        QualityDocumentIndexLbl: Label 'Quality Document Index';
        ExcelFileNameLbl: Label 'Quality Document Index';
        LineBuilder: TextBuilder;
        CommentBuilder: TextBuilder;
        ItemBuilder: TextBuilder;
        ItemList: List of [Code[20]];
        ItemNo: Code[20];
        FirstItem: Boolean;
        OutStream: Outstream;
    begin

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.CreateNewBook(ExcelFileNameLbl);
        TempExcelBuffer.NewRow();

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn('Vendor', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(VendorCertification.FieldCaption(Site), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Certification Type', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(VendorCertification.FieldCaption("Expiry Date"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Attachment Exists', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Related Items', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.NewRow();
        Item.SetLoadFields(Description);


        if DialogChoices.getCompCertSel() then
            if CompanyCertification.Findset(false) then
                repeat
                    Clear(LineBuilder);
                    Clear(CommentBuilder);

                    TempExcelBuffer.AddColumn('TFB Trading', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(CompanyCertification."Certification Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(CompanyCertification."Expiry Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                    TempExcelBuffer.AddColumn(PersBlob.Exists(CompanyCertification."Certificate Attach."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn('All Items', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.NewRow();
                    Clear(ItemBuilder);
                    Clear(ItemList);
                until CompanyCertification.Next() = 0;


        if VendorCertification.Findset(false) then begin
            repeat

                Clear(LineBuilder);
                Clear(CommentBuilder);

                TempExcelBuffer.AddColumn(VendorCertification."Vendor Name", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorCertification.Site, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorCertification."Certification Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorCertification."Expiry Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                TempExcelBuffer.AddColumn(PersBlob.Exists(VendorCertification."Certificate Attach."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                if DictVendors.ContainsKey(VendorCertification."Vendor No.") then begin
                    ItemList := DictVendors.Get(VendorCertification."Vendor No.");
                    FirstItem := true;
                    foreach ItemNo in ItemList do begin
                        Item.Get(ItemNo);
                        if FirstItem then begin
                            TempExcelBuffer.AddColumn(Item.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            FirstItem := false;
                        end
                        else begin
                            TempExcelBuffer.NewRow();
                            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn(Item.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                        end;


                    end;
                end;
                TempExcelBuffer.NewRow();
                Clear(ItemBuilder);
                Clear(ItemList);

            until VendorCertification.Next() < 1;
            TempBlob.CreateOutStream(OutStream);
            TempExcelBuffer.WriteSheet(QualityDocumentIndexLbl, CompanyName, UserId);
            TempExcelBuffer.CloseBook();
            TempExcelBuffer.SaveToStream(OutStream, true);

            exit(true);
        end
        else
            exit(false);
    end;


    var
        QualityTitleTxt: Label 'Quality Documents Request';
        tdTxt: label '<td valign="top" class="tfbdata" style="line-height:15px; vertical-align:top">%1</td>', Comment = '%1=Table data html content';
}
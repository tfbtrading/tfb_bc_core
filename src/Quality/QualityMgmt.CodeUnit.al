codeunit 50104 "TFB Quality Mgmt"
{

    procedure CalcDaysToExpiry(ExpiryDate: Date): Integer
    var
        DaysToExpiry: Integer;

    begin

        If ExpiryDate <> 0D then
            DaysToExpiry := ExpiryDate - Today();

        Exit(DaysToExpiry);

    end;

    procedure GetCurrentStatus(Certificate: Record "TFB Vendor Certification"): Enum "TFB Quality Certificate Status";

    var
        DaysToExpiry: Integer;
        Status: Enum "TFB Quality Certificate Status";


    begin

        If Certificate."Expiry Date" > 0D then begin

            DaysToExpiry := CalcDaysToExpiry(Certificate."Expiry Date");

            case DaysToExpiry of
                -1000 .. -1:
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
            Status := Status::Pending;

        exit(Status);
    end;


    procedure GetCertificateFileName(Certification: record "TFB Vendor Certification"): Text

    var
        FileNameBuilder: TextBuilder;

    begin
        FileNameBuilder.Append('Certificate_');
        FileNameBuilder.Append(Certification."Vendor No.");
        If Certification.Site <> '' then begin
            FileNameBuilder.Append('-');
            FileNameBuilder.Append(Certification.Site);
        end;
        FileNameBuilder.Append('_');
        FileNameBuilder.Append(Certification."Certification Type");
        FileNameBuilder.Append('.pdf');
        Exit(FileNameBuilder.ToText());

    end;

    procedure GetStatusEmoticon(Status: Enum "TFB Quality Certificate Status"): Text

    begin

        case Status of
            status::"About to Expire":
                Exit('⚠️');

            status::"Expiring Soon":
                Exit('🔖');

            status::Expired:
                Exit('❌');

            status::Active:
                Exit('✅');

            status::Pending:
                Exit('🕙');
        end;
    end;

    procedure GatherCustomerQualityDocuments(CustomerNo: Code[20]; var ListOfCertifications: Record "TFB Vendor Certification" temporary; var TempBlobList: Codeunit "Temp Blob List"): Boolean

    var
        ShipmentLine: Record "Sales Shipment Line";
        VendorCertification: Record "TFB Vendor Certification";
        TempBlob: Codeunit "Temp Blob";
        ListQuery: Query "TFB Items Shipped";
        ListOfItems: Dictionary of [Code[20], Integer];
        ListOfVendors: Dictionary of [Code[20], Integer];
        VendorNo: Code[20];



    begin

        ShipmentLine.SetRange("Sell-to Customer No.", CustomerNo);


        ListQuery.SetRange(Sell_to_Customer_No_, CustomerNo);
        ListQuery.Open();
        while ListQuery.Read() do begin
            ListOfItems.Add(ListQuery.No_, ListQuery.Count_);
            If not ListOfVendors.ContainsKey(ListQuery.Vendor_No_) then
                ListOfVendors.Add(ListQuery.Vendor_No_, 1)
            else
                ListOfVendors.Set(ListQuery.Vendor_No_, ListOfVendors.Get(ListQuery.Vendor_No_) + 1);
        end;

        foreach VendorNo in ListOfVendors.Keys() do begin
            //Retrieve quality documentation
            VendorCertification.SetRange("Vendor No.", VendorNo);


            if VendorCertification.FindSet() then
                repeat
                    CLEAR(ListOfCertifications);
                    ListOfCertifications := VendorCertification;
                    ListOfCertifications.Insert(false);
                    TempBlob.FromRecord(VendorCertification, VendorCertification.FieldNo(Certificate));
                    If TempBlob.HasValue() then
                        TempBlobList.Add(TempBlob);


                until VendorCertification.Next() < 1;

        end;

        If ListOfCertifications.Count() > 0 then
            Exit(True) else
            Exit(False)

    end;

    procedure SendQualityDocumentsToCustomer(CustomerNo: Code[20]; QualityOnly: Boolean): Boolean

    var
        CompanyInfo: Record "Company Information";
        CommonCU: CodeUnit "TFB Common Library";
        Customer: Record Customer;
        ListOfCertifications: Record "TFB Vendor Certification" temporary;
        User: Record User;
        SalesShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        EmailScenEnum: Enum "Email Scenario";

        TempBlob: Codeunit "Temp Blob";
        TempBlobList: Codeunit "Temp Blob List";

        InStream: InStream;
        i: Integer;
        CCRecipients: List of [Text];
        BCCRecipients: List of [Text];
        HTMLTemplate: Text;
        Recipients: List of [Text];

        Text001Msg: Label 'Sending Quality Documents:\#1#######################2#####', Comment = '%1=Customer No, %2=Customer Name';
        TitleTxt: Label 'Quality Documents Request';
        SubTitleText: Label 'Please find attached the following quality documents';
        FileNameBuilder: TextBuilder;
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;


    begin

        If GatherCustomerQualityDocuments(CustomerNo, ListOfCertifications, TempBlobList) and Customer.get(CustomerNo) then begin


            HTMLTemplate := CommonCU.GetHTMLTemplateActive(TitleTxt, SubTitleText);


            CompanyInfo.Get();

            SubjectNameBuilder.Append(TitleTxt);
            Recipients.Add(Customer."E-Mail");




            if User.Get(UserSecurityId()) then begin
                CCRecipients.Add(User."Contact Email");

            end;

            HTMLBuilder.Append(HTMLTemplate);

            GenerateQualityDocumentsContent(Customer, ListOfCertifications, HTMLBuilder);

            EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true, CCRecipients, BCCRecipients);
            if ListOfCertifications.FindSet() then begin
                Message('Found %1 Certifications', ListOfCertifications.Count());
                repeat
                    FileNameBuilder.Append(StrSubstNo('Cert %1_%2_%3.pdf', ListOfCertifications."Vendor Name", ListOfCertifications.Site, ListOfCertifications."Certification Type"));
                    i += 1;
                    TempBlobList.Get(i, TempBlob);
                    If not TempBlob.HasValue() then begin
                        TempBlob.CreateInStream(InStream);
                        EmailMessage.AddAttachment(FileNameBuilder.ToText(), 'Application/PDF', InStream);
                    end;

                until ListOfCertifications.Next() < 1;
            end;
            Email.OpenInEditorModally(EmailMessage, EmailScenEnum::Quality)

        end
    end;


    local procedure GenerateQualityDocumentsContent(Customer: Record Customer; var ListOfCertifications: Record "TFB Vendor Certification" temporary; var HTMLBuilder: TextBuilder): Boolean

    var
        tdTxt: label '<td valign="top" style="line-height:15px;">%1</td>', Comment = '%1=Table data html content';
        BodyBuilder: TextBuilder;
        CommentBuilder: TextBuilder;
        LineBuilder: TextBuilder;

    begin

        HTMLBuilder.Replace('%{ExplanationCaption}', 'Request Type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Updated Vendor Certifications');
        HTMLBuilder.Replace('%{DateCaption}', 'Requested on');
        HTMLBuilder.Replace('%{DateValue}', format(today()));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'For customer');
        HTMLBuilder.Replace('%{ReferenceValue}', Customer.Name);

        BodyBuilder.AppendLine(StrSubstNo('<h2>Please find out latest quality documents for items from vendors shipped to you'));

        BodyBuilder.AppendLine('<table class="tfbdata" width="60%" cellspacing="0" cellpadding="10" border="0">');
        BodyBuilder.AppendLine('<thead>');

        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="40%">Vendor</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Location</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="25%">Type</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="15%">Expiry</th></thead>');

        if ListOfCertifications.FindSet() then
            repeat

                Clear(LineBuilder);
                Clear(CommentBuilder);
                LineBuilder.AppendLine('<tr>');

                LineBuilder.Append(StrSubstNo(tdTxt, ListOfCertifications."Vendor Name"));
                LineBuilder.Append(StrSubstNo(tdTxt, ListOfCertifications.Site));
                LineBuilder.Append(StrSubstNo(tdTxt, ListOfCertifications."Certification Type"));
                LineBuilder.Append(StrSubstNo(tdTxt, ListOfCertifications."Expiry Date"));

                LineBuilder.AppendLine('</tr>');
                BodyBuilder.AppendLine(LineBuilder.ToText());
                BodyBuilder.AppendLine('</table>');
            until ListOfCertifications.Next() < 1

        else
            BodyBuilder.AppendLine('<h2>No quality documents found for vendor items shipped</h2>');

        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        Exit(true);
    end;
}
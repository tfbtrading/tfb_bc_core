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
        If not Certificate.Inherent then
            If Certificate."Expiry Date" > 0D then begin

                DaysToExpiry := CalcDaysToExpiry(Certificate."Expiry Date");

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
                Exit('✔️');

            status::Pending:
                Exit('🕙');
            status::Inherent:
                Exit('🃏');
        end;
    end;

    procedure GatherCustomerQualityDocuments(CustomerNo: Code[20]; var ListOfCertifications: Record "TFB Vendor Certification" temporary; QualityOnly: Boolean): Boolean

    var
        VendorCertification: Record "TFB Vendor Certification";
        ListQuery: Query "TFB Items Shipped";
        ListOfItems: Dictionary of [Code[20], Integer];
        ListOfVendors: Dictionary of [Code[20], Integer];
        VendorNo: Code[20];




    begin
        CLEAR(ListOfCertifications);
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
            VendorCertification.SetAutoCalcFields(VendorCertification."Certificate Class");

            if VendorCertification.FindSet() then
                repeat
                    If QualityOnly and (VendorCertification."Certificate Class" = VendorCertification."Certificate Class"::Quality) then begin
                        ListOfCertifications := VendorCertification;
                        ListOfCertifications.Insert(false);
                    end
                until VendorCertification.Next() < 1;

        end;

        If ListOfCertifications.Count() > 0 then
            Exit(True) else
            Exit(False)

    end;

    procedure SendQualityDocumentsToCustomer(CustomerNo: Code[20]; QualityOnly: Boolean): Boolean

    var
        Contact: Record Contact;
        Customer: Record Customer;
        TempListOfCertifications: Record "TFB Vendor Certification" temporary;
        CLib: CodeUnit "TFB Common Library";
        ContactList: Page "Contact List";
        Recipients: List of [Text];
        SubTitleTxt: Label '';
        TitleTxt: Label 'Vendor Certifications Email';


    begin

        If Customer.get(CustomerNo) and GatherCustomerQualityDocuments(CustomerNo, TempListOfCertifications, QualityOnly) then begin

            Contact.SetRange("Company No.", Customer."TFB Primary Contact Company ID");
            Contact.SetFilter("E-Mail", '>%1', '');
            ContactList.SetTableView(Contact);
            ContactList.LookupMode(true);

            If ContactList.RunModal() = Action::LookupOK then begin

                Contact.SetFilter("No.", ContactList.GetSelectionFilter());

                If Contact.FindSet(false, false) then
                    repeat
                        If Contact."E-Mail" <> '' then
                            If not Recipients.Contains(Contact."E-Mail") then
                                Recipients.Add(Contact."E-Mail");

                    until Contact.Next() = 0;

                If Recipients.Count > 0 then
                    SendVendorCertificationEmail(TempListOfCertifications, Recipients, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt),Customer.SystemId);

            end;
        end;
    end;

    internal procedure SendVendorCertificationEmail(var VendorCerts: Record "TFB Vendor Certification"; Recipients: List of [Text]; HTMLTemplate: Text;CustomerSystemID: GUID)

    var
        CompanyInfo: Record "Company Information";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        PersBlobCU: CodeUnit "Persistent Blob";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        TitleTxt: Label 'Quality Documents Request';
        FileNameBuilder: TextBuilder;
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;

    begin

        CompanyInfo.Get();

        SubjectNameBuilder.Append(TitleTxt);


        HTMLBuilder.Append(HTMLTemplate);

        GenerateQualityDocumentsContent(VendorCerts, HTMLBuilder);

        EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);
        if VendorCerts.FindSet(false, false) then
            repeat
                If PersBlobCU.Exists(VendorCerts."Certificate Attach.") then begin
                    Clear(FileNameBuilder);
                    FileNameBuilder.Append(StrSubstNo('Cert %1_%2_%3.pdf', VendorCerts."Vendor Name", VendorCerts.Site, VendorCerts."Certification Type"));
                    TempBlob.CreateOutStream(Outstream);
                    PersBlobCU.CopyToOutStream(VendorCerts."Certificate Attach.", OutStream);
                    TempBlob.CreateInStream(InStream);
                    EmailMessage.AddAttachment(CopyStr(FileNameBuilder.ToText(),1,250), 'Application/PDF', InStream);
                end


            until VendorCerts.Next() < 1;
        
        Email.AddRelation(EmailMessage,Database::Customer,CustomerSystemID,Enum::"Email Relation Type"::"Related Entity");
        Email.OpenInEditorModally(EmailMessage, Enum::"Email Scenario"::Quality)

    end;




    local procedure GenerateQualityDocumentsContent(var VendorCertification: Record "TFB Vendor Certification"; var HTMLBuilder: TextBuilder): Boolean

    var
        PersBlob: CodeUnit "Persistent Blob";
        tdTxt: label '<td valign="top" class="tfbdata" style="line-height:15px;">%1</td>', Comment = '%1=Table data html content';
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

        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="40%">Vendor</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="20%">Location</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="25%">Type</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="7.5%">Expiry</th>');
        BodyBuilder.Append('<th class="tfbdata" style="text-align:left" width="7.5%">Attachment</th></thead>');

        if VendorCertification.FindSet(false, false) then begin
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
        Exit(true);
    end;
}
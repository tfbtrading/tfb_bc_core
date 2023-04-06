codeunit 50114 "TFB Sample Request Mgmt"
{
    trigger OnRun()
    begin

    end;

    var

    procedure SendSampleRequest(SampleRequest: Record "TFB Sample Request"; ReportNo: Integer): Boolean

    var

        CompanyInfo: Record "Company Information";
        SampleRequestLines: Record "TFB Sample Request Line";
        Location: Record Location;
        Contact: Record Contact;
        Customer: Record Customer;
        User: Record User;
        Item: Record Item;
        TempBlob: Codeunit "Temp Blob";
        CommonCU: CodeUnit "TFB Common Library";
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";
        DocumentRef: RecordRef;
        OutStream: OutStream;
        InStream: InStream;

        EmailScenEnum: Enum "Email Scenario";

        CCRecipients: List of [Text];
        ContactName: Text;
        CustomerName: Text;
        EmailID: Text;
        HTMLTemplate: Text;
        Recipients: List of [Text];
        Reference: Text;
        SubTitleTxt: Label 'Please find a request for sample dispatch. ';
        TitleTxt: Label 'Sample Request';
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;
        Locations: List of [Code[20]];

    begin


        HTMLTemplate := CommonCU.GetHTMLTemplateActive(TitleTxt, SubTitleTxt);


        CompanyInfo.Get();
        Contact.Get(SampleRequest."Sell-to Contact No.");

        ContactName := SampleRequest."Sell-to Contact";
        //Find first line to check for drop ship 
        SampleRequestLines.SetRange("Document No.", SampleRequest."No.");
        SampleRequestLines.SetRange("Sourced From", SampleRequestLines."Sourced From"::Warehouse);

        If SampleRequestLines.Findset(true) then
            repeat
                If not Locations.Contains(SampleRequestLines.Location) then begin
                    Locations.Add(SampleRequestLines.Location);
                    Item.Get(SampleRequestLines."No.");

                    If not Customer.Get(SampleRequest."Sell-to Customer No.") then
                        Recipients.Add(DetermineItemWarehouseLocation(Contact, Item)."E-Mail")
                    else
                        Recipients.Add(DetermineItemWarehouseLocation(Customer, Item)."E-Mail")

                end;

            until SampleRequestLines.Next() = 0;



        If Locations.Count > 0 then begin

            ContactName := Location.Name;
            Reference := SampleRequest."No.";


            //Retrieve and construct message

            SubjectNameBuilder.Append(StrSubstNo('Sample Request %1 from TFB Trading', Reference));
            Recipients.Add(EmailID);




            HTMLBuilder.Append(HTMLTemplate);
            SampleRequest.SetRecFilter();
            DocumentRef.GetTable(SampleRequest);
            TempBlob.CreateOutStream(OutStream);
            //HTMLBuilder.Replace('%1', 'Shipment Status Query');
            If REPORT.SaveAs(ReportNo, '', ReportFormat::Pdf, OutStream, DocumentRef) and GenerateSampleRequestContent(ContactName, Reference, CustomerName, HTMLBuilder) then begin

                //Check that content has been generated to send

                User.Get(UserSecurityId());
                CCRecipients.Add(User."Contact Email");

                EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);
                TempBlob.CreateInStream(InStream);
                EmailMessage.AddAttachment(StrSubstNo('Sample Request %1.pdf', SampleRequest."No."), 'application/pdf', InStream);
                Email.AddRelation(EmailMessage, Database::"TFB Sample Request", SampleRequest.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
                Email.AddRelation(EmailMessage, Database::Contact, Contact.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");
                Email.OpenInEditorModally(EmailMessage, EmailScenEnum::Logistics);


            end

        end;
    end;

    local procedure GenerateSampleRequestContent(ContactName: Text; Reference: Text; RecipientName: Text; var HTMLBuilder: TextBuilder): Boolean
    var
        BodyBuilder: TextBuilder;

    begin
        HTMLBuilder.Replace('%{ExplanationCaption}', 'Request Type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Sample Request for ' + ContactName);
        HTMLBuilder.Replace('%{DateCaption}', 'Requested on');
        HTMLBuilder.Replace('%{DateValue}', format(today()));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'Request No.');
        HTMLBuilder.Replace('%{ReferenceValue}', Reference);

        BodyBuilder.AppendLine(StrSubstNo('<h2>We have a request no. %1 for sending samples to our office.</h2>', Reference));

        BodyBuilder.AppendLine(StrSubstNo('<p>This email is intended for <b>%1</b>. If you have received this in error please let us know', RecipientName));
        BodyBuilder.AppendLine('<br><br>');

        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        Exit(true);

    end;




    procedure DetermineItemWarehouseLocation(Customer: Record Customer; Item: Record Item): Record Location

    var
        Location: Record Location;
        ItemLedger: Record "Item Ledger Entry";

    begin

        If Location.Get(Customer."Location Code") then begin
            ItemLedger.SetFilter("Remaining Quantity", '>0');
            ItemLedger.SetRange("Item No.", Item."No.");
            ItemLedger.SetRange("Location Code", Location.Code);


            If ItemLedger.IsEmpty() then begin
                ItemLedger.Reset();
                ItemLedger.SetFilter("Remaining Quantity", '>0');
                ItemLedger.SetRange("Item No.", Item."No.");
                If ItemLedger.FindFirst() then
                    Location.Get(ItemLedger."Location Code");
            end;


        end;
        Exit(Location);
    end;

    procedure DetermineItemWarehouseLocation(Contact: Record Contact; Item: Record Item): Record Location

    var
        Location: Record Location;
        ItemLedger: Record "Item Ledger Entry";
    begin

        ItemLedger.Reset();
        ItemLedger.SetFilter("Remaining Quantity", '>0');
        ItemLedger.SetRange("Item No.", Item."No.");
        If ItemLedger.FindFirst() then
            Location.Get(ItemLedger."Location Code");


        Exit(Location);
    end;
}
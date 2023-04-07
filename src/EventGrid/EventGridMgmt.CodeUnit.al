codeunit 50118 "TFB Event Grid Mgmt"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin


    end;

    var

    procedure PublishContactEnabledForOnline(Contact: Record Contact)

    var

    begin

        Message(SendMessage(CreateBody(Contact, Enum::"TFB Event Grid Event Types"::ContactEnabledForOnline)));

    end;

    procedure PublishContactDisabledForOnline(Contact: Record Contact)

    var

    begin

        Message(SendMessage(CreateBody(Contact, Enum::"TFB Event Grid Event Types"::ContactDisabledForOnline)));

    end;

    procedure PublishCheckStatus(Contact: Record Contact)

    var

    begin

        Message(SendMessage(CreateBody(Contact, Enum::"TFB Event Grid Event Types"::ContactCheckStatus)));

    end;


    local procedure CreateBody(Contact: Record Contact; EventType: Enum "TFB Event Grid Event Types") message: JsonArray
    var

        body: JsonObject;
    begin

        body.Add('id', CreateGuid());
        body.add('eventType', format(EventType));
        body.add('subject', contact.Name);
        body.Add('eventTime', CurrentDateTime());
        body.Add('data', GetRecDataForContact(Contact));
        message.Add(body);
    end;

    local procedure GetRecDataForContact(Contact: Record Contact) data: JsonObject
    var
        Customer: Record Customer;
        ContactBusinessRel: Record "Contact Business Relation";

    begin

        if not ContactBusinessRel.FindByContact(Enum::"Contact Business Relation Link To Table"::Customer, Contact."Company No.") then exit;
        if not Customer.Get(ContactBusinessRel."No.") then exit;

        data.Add('contactid', Text.DelChr(Contact.SystemId, '<>', '{}'));
        data.Add('customerid', Text.DelChr(Customer.SystemId, '<>', '{}'));
        data.Add('customername', Customer.Name);
        data.Add('firstname', Contact."First Name");
        data.Add('lastname', Contact.Surname);
        data.Add('mobilenumber', Contact."Mobile Phone No.");
        data.Add('emailaddress', Contact."E-Mail");

    end;




    local procedure SendMessage(message: JsonArray): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        SuccessMsg: Label 'Initiated process to activate contact for mobile application';
    begin
        Client.DefaultRequestHeaders.Add(
            'aeg-sas-key',
            'Cu7ia9J2B/YEYD35z4bKjRvuQh/vjS39pX5TReneCw4=');
        Content.WriteFrom(Format(message));
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        if not Client.Post(
            'https://onlineuserenabled.australiasoutheast-1.eventgrid.azure.net/api/events',
            Content, Response)
        then
            Error(CannotConnectErr);

        if not Response.IsSuccessStatusCode then
            Error(WebServiceErr, Response.HttpStatusCode, response.ReasonPhrase);

        exit(SuccessMsg);
    end;


    var

        CannotConnectErr: Label 'Cannot Connect to Azure Event Grid';
        WebServiceErr: Label 'Error when calling web service for event grid %1 %2', Comment = '%1 - HttpStatusCode, %2 = Reason Phrase';
}
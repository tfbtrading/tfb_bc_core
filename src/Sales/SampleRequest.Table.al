table 50115 "TFB Sample Request"
{
    Caption = 'Sample Request';
    DataCaptionFields =; //TODO Add in Data caption fields
    LookupPageID = "Sales List";
    Permissions = tabledata "Assemble-to-Order Link" = rmid;

    fields
    {

        field(2; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var

                Confirmed: Boolean;
                TFBSampleRequestLine: Record "TFB Sample Request Line";
            begin

                if "No." = '' then
                    InitRecord;

                if ("Sell-to Customer No." <> xRec."Sell-to Customer No.") and (xRec."Sell-to Customer No." <> '')
                then begin
                    if ("Opportunity No." <> '') then
                        Error(
                          NoChangeOpportunityMsg,
                          FieldCaption("Sell-to Customer No."),
                          FieldCaption("Opportunity No."),
                          "Opportunity No.");
                    if GetHideValidationDialog() or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := Confirm(ConfirmChangeQst, false, SellToCustomerTxt);

                    if Confirmed then begin

                        TFBSampleRequestLine.SetRange("Document No.", "No.");
                        if "Sell-to Customer No." = '' then begin
                            if not TFBSampleRequestLine.IsEmpty() then
                                Error(
                                  NoResetMsg,
                                  FieldCaption("Sell-to Customer No."));
                            Init();

                            GetSalesSetup();
                            "No. Series" := xRec."No. Series";
                            InitRecord();
                            InitNoSeries();
                            exit;
                        end;

                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;


                GetCust("Sell-to Customer No.");
                Rec."Sell-to Customer Name" := Cust.Name;
                UpdateSellToCont("Sell-to Customer No.");

            end;
        }

        field(3; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    SalesSetup.Get();
                    NoSeriesMgt.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;
        }

        field(63; "Posting No."; Code[20])
        {
            Caption = 'Posting No.';
        }

        field(107; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            ValidateTableRelation = true;
        }

        field(5055; "Opportunity No."; Code[20])
        {
            Caption = 'Opportunity No.';
            TableRelation = Opportunity."No." WHERE("Contact No." = FIELD("Sell-to Contact No."),
                                                                                          Closed = CONST(false));

            trigger OnValidate()
            begin
                LinkSalesDocWithOpportunity(xRec."Opportunity No.");
            end;
        }

        field(5052; "Sell-to Contact No."; Code[20])
        {
            Caption = 'Sell-to Contact No.';
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
                IsHandled: Boolean;
            begin
                IsHandled := false;

                if "Sell-to Customer No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then
                        Cont.SetRange("Company No.", Cont."Company No.")
                    else
                        if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Customer, "Sell-to Customer No.") then
                            Cont.SetRange("Company No.", ContBusinessRelation."Contact No.")
                        else
                            Cont.SetRange("No.", '');

                if "Sell-to Contact No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then;
                if PAGE.RunModal(0, Cont) = ACTION::LookupOK then begin
                    xRec := Rec;
                    Validate("Sell-to Contact No.", Cont."No.");
                end;
            end;

            trigger OnValidate()
            var
                Cont: Record Contact;
                Opportunity: Record Opportunity;
                IsHandled: Boolean;
                Confirmed: Boolean;
            begin

                if "Sell-to Contact No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric;

                if ("Sell-to Contact No." <> xRec."Sell-to Contact No.") and
                   (xRec."Sell-to Contact No." <> '')
                then begin
                    if ("Sell-to Contact No." = '') and ("Opportunity No." <> '') then
                        Error(NoBlankDueToOpportunity, FieldCaption("Sell-to Contact No."));
                    IsHandled := false;


                    if GetHideValidationDialog or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Sell-to Contact No."));
                    if Confirmed then begin
                        if InitFromContact("Sell-to Contact No.", "Sell-to Customer No.", FieldCaption("Sell-to Contact No.")) then
                            exit;
                        if "Opportunity No." <> '' then begin
                            Opportunity.Get("Opportunity No.");
                            if Opportunity."Contact No." <> "Sell-to Contact No." then begin
                                Modify;
                                Opportunity.Validate("Contact No.", "Sell-to Contact No.");
                                Opportunity.Modify();
                            end
                        end;
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                if ("Sell-to Customer No." <> '') and ("Sell-to Contact No." <> '') then
                    CheckContactRelatedToCustomerCompany("Sell-to Contact No.", "Sell-to Customer No.", CurrFieldNo);

                if "Sell-to Contact No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then
                        if ("Salesperson Code" = '') and (Cont."Salesperson Code" <> '') then
                            Validate("Salesperson Code", Cont."Salesperson Code");

                UpdateSellToCust("Sell-to Contact No.");

            end;
        }


        field(43; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";


        }
        field(108; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnLookup()
            begin
                TFBSampleRequest := Rec;
                GetSalesSetup;
                TFBSampleRequest.TestNoSeries;
                if NoSeriesMgt.LookupSeries(GetPostingNoSeriesCode, TFBSampleRequest."Posting No. Series") then
                    TFBSampleRequest.Validate("Posting No. Series");
                Rec := TFBSampleRequest;
            end;

            trigger OnValidate()
            begin
                if "Posting No. Series" <> '' then begin
                    GetSalesSetup;
                    TestNoSeries;
                    NoSeriesMgt.TestSeries(GetPostingNoSeriesCode, "Posting No. Series");
                end;
                TestField("Posting No.", '');
            end;
        }

        field(79; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                LookupSellToCustomerName();
            end;

            trigger OnValidate()
            var
                Customer: Record Customer;
                EnvInfoProxy: Codeunit "Env. Info Proxy";
                IsHandled: Boolean;
            begin


                if not EnvInfoProxy.IsInvoicing() and ShouldSearchForCustomerByName("Sell-to Customer No.") then
                    Validate("Sell-to Customer No.", Customer.GetCustNo("Sell-to Customer Name"));


            end;
        }
        field(80; "Sell-to Customer Name 2"; Text[50])
        {
            Caption = 'Sell-to Customer Name 2';
        }
        field(81; "Address"; Text[100])
        {
            Caption = 'Sell-to Address';

            trigger OnValidate()
            begin
                PostCodeCheck.ValidateAddress(
                  CurrFieldNo, DATABASE::"Sales Header", GetPosition, 3,
                   "Sell-to Customer Name", "Sell-to Customer Name 2", "Sell-to Contact", "Address", "Address 2",
                   "City", "Post Code", "County", "Country/Region Code");

            end;
        }
        field(82; "Address 2"; Text[50])
        {
            Caption = 'Sell-to Address 2';

            trigger OnValidate()
            begin
                PostCodeCheck.ValidateAddress(
                  CurrFieldNo, DATABASE::"Sales Header", GetPosition, 3,
                   "Sell-to Customer Name", "Sell-to Customer Name 2", "Sell-to Contact", "Address", "Address 2",
                   "City", "Post Code", "County", "Country/Region Code");

            end;
        }
        field(83; "City"; Text[30])
        {
            Caption = 'Sell-to City';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin

                PostCode.LookupPostCode("City", "Post Code", "County", "Country/Region Code");
            end;

            trigger OnValidate()
            begin
                PostCodeCheck.ValidateCity(
                  CurrFieldNo, DATABASE::"Sales Header", GetPosition, 3,
                  "Sell-to Customer Name", Rec."Sell-to Customer Name 2", Rec."Sell-to Contact", Rec."Address", Rec."Address 2",
                  Rec."City", Rec."Post Code", Rec."County", Rec."Country/Region Code");

            end;
        }
        field(84; "Sell-to Contact"; Text[100])
        {
            Caption = 'Sell-to Contact';

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin

                Contact.FilterGroup(2);
                LookupContact("Sell-to Customer No.", "Sell-to Contact No.", Contact);
                if PAGE.RunModal(0, Contact) = ACTION::LookupOK then
                    Validate("Sell-to Contact No.", Contact."No.");
                Contact.FilterGroup(0);
            end;


        }

        field(88; "Post Code"; Code[20])
        {
            Caption = 'Sell-to Post Code';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin


                PostCode.LookupPostCode(Rec."City", Rec."Post Code", Rec."County", Rec."Country/Region Code");
            end;

            trigger OnValidate()
            begin

                PostCodeCheck.ValidatePostCode(
                  CurrFieldNo, DATABASE::"Sales Header", GetPosition, 3,
                  Rec."Sell-to Customer Name", Rec."Sell-to Customer Name 2", Rec."Sell-to Contact", Rec."Address", Rec."Address 2",
                  Rec."City", Rec."Post Code", Rec."County", Rec."Country/Region Code");


            end;
        }
        field(89; "County"; Text[30])
        {
            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'Sell-to County';


        }
        field(90; "Country/Region Code"; Code[10])
        {
            Caption = 'Sell-to Country/Region Code';
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin


            end;
        }


        field(19; "Order Date"; Date)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Requested Date';

        }

        field(5790; "Requested Delivery Date"; Date)
        {
            Caption = 'Requested Delivery Date';

            trigger OnValidate()
            begin

            end;
        }

        field(5050; "Campaign No."; Code[20])
        {
            Caption = 'Campaign No.';
            TableRelation = Campaign;

            trigger OnValidate()

            begin

            end;
        }

        field(120; Status; Enum "TFB Sample Request Status")
        {
            Caption = 'Status';
            Editable = true;
        }

        field(200; "Work Description"; BLOB)
        {
            Caption = 'Request Context';
        }

        field(105; "Shipping Agent Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()

            begin


            end;
        }
        field(106; "Package Tracking No."; Text[30])
        {
            Caption = 'Package Tracking No.';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var
        SalesSetup: Record "Sales & Receivables Setup";
        TFBSampleRequest: Record "TFB Sample Request";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PostCodeCheck: Codeunit "Post Code Check";
        SelectNoSeriesAllowed: Boolean;
        SkipSellToContact: Boolean;
        Cust: Record Customer;
        PostCode: Record "Post Code";
        ReadingDataSkippedMsg: Label 'Loading field %1 will be skipped because there was an error when reading the data.\To fix the current data, contact your administrator.\Alternatively, you can overwrite the current data by entering data in the field.', Comment = '%1=field caption';

        NoChangeOpportunityMsg: Label 'You cannot change %1 because the corresponding %2 %3 has been assigned';
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        SellToCustomerTxt: Label 'Sell-to Customer';
        ConfirmEmptyEmailQst: Label 'Contact %1 has no email address specified. The value in the Email field on the sample request, %2, will be deleted. Do you want to continue?', Comment = '%1 - Contact No., %2 - Email';
        NoRelationMsg: Label 'Contact %1 %2 is not related to customer %3.';
        NoResetMsg: Label 'You cannot reset %1 because the document still has one or more lines.';

        NoBlankDueToOpportunity: Label 'The %1 field cannot be blank because this quote is linked to an opportunity.';
        Text051: Label 'The sales %1 %2 already exists.';

    protected var
        HideValidationDialog: Boolean;

    local procedure GetSalesSetup()
    begin
        SalesSetup.Get();

    end;

    procedure AssistEdit(OldSampleRequest: Record "TFB Sample Request") Result: Boolean
    var
        SampleRequest2: Record "TFB Sample Request";

    begin

        with TFBSampleRequest do begin
            Copy(Rec);
            GetSalesSetup();
            TestNoSeries();
            if NoSeriesMgt.SelectSeries(GetNoSeriesCode, OldSampleRequest."No. Series", "No. Series") then begin
                NoSeriesMgt.SetSeries("No.");
                if SampleRequest2.Get("No.") then
                    Error(Text051, "No.");
                Rec := TFBSampleRequest;
                exit(true);
            end;
        end;
    end;

    procedure SetWorkDescription(NewWorkDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Work Description");
        "Work Description".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewWorkDescription);
        Modify;
    end;

    procedure GetWorkDescription() WorkDescription: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Work Description");
        "Work Description".CreateInStream(InStream, TEXTENCODING::UTF8);
        if not TypeHelper.TryReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator(), WorkDescription) then
            Message(ReadingDataSkippedMsg, FieldCaption("Work Description"));
    end;

    procedure GetStatusStyleText() StatusStyleText: Text
    begin
        if (Status = Status::Sent) or (Status = Status::Received) then
            StatusStyleText := 'Favorable'
        else
            StatusStyleText := 'Strong';
    end;

    procedure LinkSalesDocWithOpportunity(OldOpportunityNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        Opportunity: Record Opportunity;
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if "Opportunity No." <> OldOpportunityNo then
            if Opportunity.Get("Opportunity No.") then
                Opportunity.TestField(Status, Opportunity.Status::"In Progress");
    end;

    local procedure CheckContactRelatedToCustomerCompany(ContactNo: Code[20]; CustomerNo: Code[20]; CurrFieldNo: Integer);
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";

    begin

        Contact.Get(ContactNo);
        if ContBusRel.FindByRelation(ContBusRel."Link to Table"::Customer, CustomerNo) then
            if (ContBusRel."Contact No." <> Contact."Company No.") and (ContBusRel."Contact No." <> Contact."No.") then
                Error(NoRelationMsg, Contact."No.", Contact.Name, CustomerNo);
    end;

    local procedure GetContactAsCompany(Contact: Record Contact; var SearchContact: Record Contact): Boolean;
    var
        IsHandled: Boolean;
    begin

        if not IsHandled then
            if Contact."Company No." <> '' then
                exit(SearchContact.Get(Contact."Company No."));
    end;

    local procedure UpdateSellToCust(ContactNo: Code[20])
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Customer: Record Customer;
        Cont: Record Contact;

        CustomerTempl: Record "Customer Templ.";
        SearchContact: Record Contact;

        ContactBusinessRelationFound: Boolean;
        IsHandled: Boolean;
    begin

        if not Cont.Get(ContactNo) then begin
            "Sell-to Contact" := '';
            exit;
        end;
        "Sell-to Contact No." := Cont."No.";

        if Cont.Type = Cont.Type::Person then
            ContactBusinessRelationFound := ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Customer, Cont."No.");
        if not ContactBusinessRelationFound then begin
            IsHandled := false;
            IF not IsHandled THEN
                ContactBusinessRelationFound :=
                    ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Customer, Cont."Company No.");
        end;

        if ContactBusinessRelationFound then begin
            CheckCustomerContactRelation(Cont, "Sell-to Customer No.", ContBusinessRelation."No.");

            if "Sell-to Customer No." = '' then begin
                SkipSellToContact := true;
                Validate("Sell-to Customer No.", ContBusinessRelation."No.");
                SkipSellToContact := false;
            end;




            if not GetContactAsCompany(Cont, SearchContact) then
                SearchContact := Cont;
            "Sell-to Customer Name" := SearchContact."Company Name";
            "Sell-to Customer Name 2" := SearchContact."Name 2";


        end;

        "Sell-to Contact" := Cont.Name;


        UpdateSellToCustContact(Customer, Cont);


        if Customer.Get("Sell-to Customer No.") or Customer.Get(ContBusinessRelation."No.") then begin
            "Address" := Cont.Address;
            "Address 2" := Cont."Address 2";
            "City" := Cont.City;
            "Post Code" := Cont."Post Code";
            "County" := Cont.County;
            "Country/Region Code" := Cont."Country/Region Code";
        end;
    end;

    local procedure InitFromContact(ContactNo: Code[20]; CustomerNo: Code[20]; ContactCaption: Text): Boolean

    var
        SalesLine: Record "TFB Sample Request Line";
    begin
        SalesLine.Reset();

        SalesLine.SetRange("Document No.", "No.");
        if (ContactNo = '') and (CustomerNo = '') then begin
            if not SalesLine.IsEmpty() then
                Error(NoResetMsg, ContactCaption);
            Init;
            GetSalesSetup;
            "No. Series" := xRec."No. Series";
            InitRecord;
            InitNoSeries;
            exit(true);
        end;
    end;

    local procedure UpdateSellToCustContact(Customer: Record Customer; Cont: Record Contact)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;

        if IsHandled then
            exit;

        if (Cont.Type = Cont.Type::Company) and Customer.Get("Sell-to Customer No.") then
            "Sell-to Contact" := Customer.Contact
        else
            if Cont.Type = Cont.Type::Company then
                "Sell-to Contact" := ''
            else
                "Sell-to Contact" := Cont.Name;
    end;

    local procedure updateAddressFromContact(Contact: Record Contact)

    var

    begin
        If Contact."No." <> '' then begin
            Rec."Address" := Contact.Address;
            Rec."Address 2" := Contact."Address 2";
            Rec."City" := Contact.City;
            Rec."County" := Contact.County;
            Rec."Country/Region Code" := Contact."Country/Region Code";
            Rec."Posting No. Series" := Contact."Post Code";
            
        end;
    end;

    local procedure CheckCustomerContactRelation(Cont: Record Contact; CustomerNo: Code[20]; ContBusinessRelationNo: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;

        if IsHandled then
            exit;

        if (CustomerNo <> '') and (CustomerNo <> ContBusinessRelationNo) then
            Error(NoRelationMsg, Cont."No.", Cont.Name, CustomerNo);
    end;

    procedure ShouldSearchForCustomerByName(CustomerNo: Code[20]) Result: Boolean
    var
        Customer: Record Customer;
        IsHandled: Boolean;
    begin
        IsHandled := false;

        if IsHandled then
            exit(Result);

        if CustomerNo = '' then
            exit(true);

        if not Customer.Get(CustomerNo) then
            exit(true);

        exit(not Customer."Disable Search by Name");
    end;

    local procedure LookupContact(CustomerNo: Code[20]; ContactNo: Code[20]; var Contact: Record Contact)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        FilterByContactCompany: Boolean;
    begin
        if ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Customer, CustomerNo) then
            Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.");

        if ContactNo <> '' then
            if Contact.Get(ContactNo) then
                if FilterByContactCompany then
                    Contact.SetRange("Company No.", Contact."Company No.");
    end;


    procedure LookupSellToCustomerName(): Boolean
    var
        Customer: Record Customer;
        StandardCodesMgt: Codeunit "Standard Codes Mgt.";
    begin
        if "Sell-to Customer No." <> '' then
            Customer.Get("Sell-to Customer No.");

        if Customer.SelectCustomer(Customer) then begin
            "Sell-to Customer Name" := Customer.Name;
            Validate("Sell-to Customer No.", Customer."No.");


            exit(true);
        end;
    end;

    local procedure UpdateSellToCont(CustomerNo: Code[20])
    var
        ContBusRel: Record "Contact Business Relation";
        Customer: Record Customer;
        OfficeContact: Record Contact;
        OfficeMgt: Codeunit "Office Management";
    begin
        if OfficeMgt.GetContact(OfficeContact, CustomerNo) then begin
            HideValidationDialog := true;
            UpdateSellToCust(OfficeContact."No.");
            HideValidationDialog := false;
        end else
            if Customer.Get(CustomerNo) then begin
                if Customer."Primary Contact No." <> '' then
                    "Sell-to Contact No." := Customer."Primary Contact No."
                else begin
                    ContBusRel.Reset();
                    ContBusRel.SetCurrentKey("Link to Table", "No.");
                    ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                    ContBusRel.SetRange("No.", "Sell-to Customer No.");
                    if ContBusRel.FindFirst() then
                        "Sell-to Contact No." := ContBusRel."Contact No."
                    else
                        "Sell-to Contact No." := '';
                end;
                "Sell-to Contact" := Customer.Contact;
            end;
        if "Sell-to Contact No." <> '' then
            if OfficeContact.Get("Sell-to Contact No.") then begin
                OfficeContact.CheckIfPrivacyBlockedGeneric();
                updateAddressFromContact(OfficeContact);
            end
    end;

    local procedure InitNoSeries()
    begin

        if xRec."Posting No." <> '' then begin
            "Posting No. Series" := xRec."Posting No. Series";
            "Posting No." := xRec."Posting No.";
        end;

    end;

    procedure GetHideValidationDialog(): Boolean
    var
        EnvInfoProxy: Codeunit "Env. Info Proxy";
    begin
        exit(HideValidationDialog or EnvInfoProxy.IsInvoicing);
    end;

    local procedure GetPostingNoSeriesCode() PostingNos: Code[20]
    var
        IsHandled: Boolean;
    begin
        GetSalesSetup;

        PostingNos := SalesSetup."TFB Posted Sample Request Nos.";

    end;

    procedure TestNoSeries()
    var
        IsHandled: Boolean;
    begin
        GetSalesSetup;
        IsHandled := false;
        SalesSetup.TestField("TFB Sample Request Nos.");
        SalesSetup.TestField("TFB Posted Sample Request Nos.");

    end;

    local procedure ValidateDocumentDate()
    begin

    end;

    procedure GetCust(CustNo: Code[20])
    var
        O365SalesInitialSetup: Record "O365 Sales Initial Setup";
        EnvInfoProxy: Codeunit "Env. Info Proxy";
    begin
        if not ((CustNo = '')) then begin
            if CustNo <> Cust."No." then
                Cust.Get(CustNo);
        end else
            Clear(Cust);

    end;



    procedure InitRecord()
    var
        ArchiveManagement: Codeunit ArchiveManagement;
        IsHandled: Boolean;
    begin
        GetSalesSetup;
        IsHandled := false;


        NoSeriesMgt.SetDefaultSeries("Posting No. Series", SalesSetup."Posted Invoice Nos.");


        "Order Date" := WorkDate;


        IF "Sell-to Customer No." <> '' THEN
            GetCust("Sell-to Customer No.");


    end;

    procedure GetNoSeriesCode(): Code[20]
    var
        NoSeriesCode: Code[20];
        IsHandled: Boolean;
    begin
        GetSalesSetup;
        NoSeriesCode := SalesSetup."TFB Sample Request Nos.";

        exit(NoSeriesMgt.GetNoSeriesWithCheck(NoSeriesCode, SelectNoSeriesAllowed, "No. Series"));
    end;

    trigger OnInsert()
    begin
        If "No." = '' then begin
            NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", 0D, "No.", "No. Series");
        end;

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
table 50115 "TFB Sample Request"
{
    Caption = 'Sample Request';
    DataCaptionFields = "No.", "Sell-to Contact";
    LookupPageID = "TFB Sample Request List";
    Permissions = tabledata "TFB Sample Request" = rmid;

    fields
    {

        field(2; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            Editable = false;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                Customer.SetLoadFields("No.", Name);
                if Customer.Get(Rec."Sell-to Customer No.") then
                    Rec."Sell-to Customer Name" := Customer.Name;

            end;


        }

        field(3; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    CoreSetup.Get();
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
            TableRelation = Opportunity."No." where("Contact No." = field("Sell-to Contact No."),
                                                                                          Closed = const(false));

            trigger OnValidate()
            begin
                LinkSalesDocWithOpportunity(xRec."Opportunity No.");
            end;
        }

        field(5052; "Sell-to Contact No."; Code[20])
        {
            Caption = 'Requesting Contact No.';
            TableRelation = Contact where(Type = const(Person));


            trigger OnValidate()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
                Opportunity: Record Opportunity;
                Confirmed: Boolean;
            begin
                Cont.Get("Sell-to Contact No.");


                if not GuiAllowed() or (xRec."Sell-to Contact No." = '') then
                    Confirmed := true
                else
                    Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Sell-to Contact No."));

                if Confirmed then begin
                    if InitFromContact("Sell-to Contact No.", FieldCaption("Sell-to Contact No.")) then
                        exit;

                    if Cont."Company No." <> '' then
                        if ContBusinessRelation.FindByContact(Enum::"Contact Business Relation Link To Table"::Customer, Cont."Company No.") then
                            Validate("Sell-to Customer No.", ContBusinessRelation."No.");


                    if "Opportunity No." <> '' then begin
                        Opportunity.Get("Opportunity No.");
                        if Opportunity."Contact No." <> Cont."Company No." then begin
                            Modify();
                            Opportunity.Validate("Contact No.", Cont."Company No.");
                            Opportunity.Modify();
                        end
                    end;


                end;
                "Sell-to Contact" := Cont.Name;

                if "Sell-to Contact No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then
                        if ("Salesperson Code" = '') and (Cont."Salesperson Code" <> '') then
                            Validate("Salesperson Code", Cont."Salesperson Code");

                UpdateAddressFromContact("Sell-to Contact No.");

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
                GetCoreSetup();
                TFBSampleRequest.TestNoSeries();
                if NoSeriesMgt.LookupSeries(GetPostingNoSeriesCode(), TFBSampleRequest."Posting No. Series") then
                    TFBSampleRequest.Validate("Posting No. Series");
                Rec := TFBSampleRequest;
            end;

            trigger OnValidate()
            begin
                if "Posting No. Series" <> '' then begin
                    GetCoreSetup();
                    TestNoSeries();
                    NoSeriesMgt.TestSeries(GetPostingNoSeriesCode(), "Posting No. Series");
                end;
                TestField("Posting No.", '');
            end;
        }

        field(79; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
            Editable = false;


        }
        field(80; "Sell-to Customer Name 2"; Text[90])
        {
            Caption = 'Customer Name 2';
        }
        field(81; "Address"; Text[100])
        {
            Caption = 'Ship-to Address';


        }
        field(82; "Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';


        }
        field(83; "City"; Text[50])
        {
            Caption = 'Ship-to City';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code".City
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin

                PostCode.LookupPostCode("City", "Post Code", "County", "Country/Region Code");

            end;

            trigger OnValidate()
            begin


            end;
        }
        field(84; "Sell-to Contact"; Text[100])
        {
            Caption = 'Requesting Contact';

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin

                Contact.FilterGroup(2);
                LookupContact(Contact);
                if PAGE.RunModal(0, Contact) = ACTION::LookupOK then
                    Validate("Sell-to Contact No.", Contact."No.");
                Contact.FilterGroup(0);
            end;


        }

        field(88; "Post Code"; Code[20])
        {
            Caption = 'Ship-to Post Code';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code"
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin


                PostCode.LookupPostCode(Rec."City", Rec."Post Code", Rec."County", Rec."Country/Region Code");
            end;

            trigger OnValidate()
            begin

                PostCodeCheck.VerifyPostCode(
                  CurrFieldNo, DATABASE::"Sales Header", GetPosition(), 3,
                  Rec."Sell-to Customer Name", Rec."Sell-to Customer Name 2", Rec."Sell-to Contact", Rec."Address", Rec."Address 2",
                  Rec."City", Rec."Post Code", Rec."County", Rec."Country/Region Code");


            end;
        }
        field(89; "County"; Text[50])
        {
            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'Sell-to County';


        }
        field(90; "Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
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

            trigger OnValidate()

            var
                Lines: Record "TFB Sample Request Line";

            begin
                if Status = Status::Sent then begin
                    Closed := true;
                    Lines.SetRange("Document No.", "No.");

                    if Lines.FindFirst() then
                        repeat

                            Lines."Line Status" := Lines."Line Status"::Sent;
                            Lines.Modify(false);
                        until Lines.Next() = 0;
                end
                else
                    Closed := false;
            end;
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
        field(999; Closed; Boolean)
        {
            Caption = 'Closed';
            Editable = false;
        }
        field(980; LinesExist; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("TFB Sample Request Line" where("Document No." = field("No.")));
        }

        field(50020; RequestSent; Boolean)
        {
            Caption = 'Request Sent';

        }
        field(50030; "Sample Cost"; Decimal)
        {
            Caption = 'Estimated Cost of Sample';
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
        Cust: Record Customer;
        PostCode: Record "Post Code";
        CoreSetup: Record "TFB Core Setup";
        TFBSampleRequest: Record "TFB Sample Request";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PostCodeCheck: Codeunit "Post Code Check";
        SelectNoSeriesAllowed: Boolean;
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        NoResetMsg: Label 'You cannot reset %1 because the document still has one or more lines.', Comment = '%1 -  Document No';
        ReadingDataSkippedMsg: Label 'Loading field %1 will be skipped because there was an error when reading the data.\To fix the current data, contact your administrator.\Alternatively, you can overwrite the current data by entering data in the field.', Comment = '%1=field caption';
        Text051Err: Label 'The sales %1 %2 already exists.', Comment = '%1 = No, %2 - Description';





    local procedure GetCoreSetup()
    begin
        CoreSetup.Get();

    end;

    procedure AssistEdit(OldSampleRequest: Record "TFB Sample Request") Result: Boolean
    var
        SampleRequest2: Record "TFB Sample Request";

    begin


        TFBSampleRequest.Copy(Rec);
        GetCoreSetup();
        TestNoSeries();
        if NoSeriesMgt.SelectSeries(GetNoSeriesCode(), OldSampleRequest."No. Series", "No. Series") then begin
            NoSeriesMgt.SetSeries("No.");
            if SampleRequest2.Get("No.") then
                Error(Text051Err, "No.", "Work Description");
            Rec := TFBSampleRequest;
            exit(true);
        end;
    end;


    procedure SetWorkDescription(NewWorkDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Work Description");
        "Work Description".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewWorkDescription);
        Modify();
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
        Opportunity: Record Opportunity;

    begin
        if "Opportunity No." <> OldOpportunityNo then
            if Opportunity.Get("Opportunity No.") then
                Opportunity.TestField(Status, Opportunity.Status::"In Progress");
    end;





    local procedure UpdateAddressFromContact(ContactNo: Code[20])
    var
        Cont: Record Contact;


    begin

        if not Cont.Get(ContactNo) then
            exit;

        "Sell-to Contact No." := Cont."No.";

        "Address" := Cont.Address;
        "Address 2" := Cont."Address 2";
        "City" := Cont.City;
        "Post Code" := Cont."Post Code";
        "County" := Cont.County;
        "Country/Region Code" := Cont."Country/Region Code";


    end;

    local procedure InitFromContact(ContactNo: Code[20]; ContactCaption: Text): Boolean

    var
        SampleRequestLine: Record "TFB Sample Request Line";
    begin
        SampleRequestLine.Reset();

        SampleRequestLine.SetRange("Document No.", "No.");
        if (ContactNo = '') then begin
            if not SampleRequestLine.IsEmpty() then
                Error(NoResetMsg, ContactCaption);
            Init();
            GetCoreSetup();
            "No. Series" := xRec."No. Series";
            InitRecord();
            InitNoSeries();
            exit(true);
        end;
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

    local procedure LookupContact(var Contact: Record Contact)
    var

    begin

        Contact.SetRange(Type, Contact.Type::Person);

    end;


    procedure LookupSellToCustomerName(): Boolean
    var
        Customer: Record Customer;

    begin
        if "Sell-to Customer No." <> '' then
            Customer.Get("Sell-to Customer No.");

        if Customer.SelectCustomer(Customer) then begin
            "Sell-to Customer Name" := Customer.Name;
            Validate("Sell-to Customer No.", Customer."No.");


            exit(true);
        end;
    end;



    local procedure InitNoSeries()
    begin

        if xRec."Posting No." <> '' then begin
            "Posting No. Series" := xRec."Posting No. Series";
            "Posting No." := xRec."Posting No.";
        end;

    end;


    local procedure GetPostingNoSeriesCode() PostingNos: Code[20]
    var

    begin
        GetCoreSetup();

        PostingNos := CoreSetup."Posted Sample Request Nos.";

    end;

    procedure TestNoSeries()
    var

    begin
        GetCoreSetup();

        CoreSetup.TestField("Sample Request Nos.");
        CoreSetup.TestField("Posted Sample Request Nos.");

    end;



    procedure GetCust(CustNo: Code[20])
    var

    begin
        if not ((CustNo = '')) then begin
            if CustNo <> Cust."No." then
                Cust.Get(CustNo);
        end else
            Clear(Cust);

    end;



    procedure InitRecord()
    var


    begin
        GetCoreSetup();



        NoSeriesMgt.SetDefaultSeries("Posting No. Series", CoreSetup."Sample Request Nos.");


        "Order Date" := WorkDate();


        if "Sell-to Customer No." <> '' then
            GetCust("Sell-to Customer No.");


    end;

    procedure GetNoSeriesCode(): Code[20]
    var

        NoSeriesCode: Code[20];
    begin
        GetCoreSetup();
        NoSeriesCode := CoreSetup."Sample Request Nos.";

        exit(NoSeriesMgt.GetNoSeriesWithCheck(NoSeriesCode, SelectNoSeriesAllowed, "No. Series"));
    end;

    trigger OnInsert()
    begin
        if "No." = '' then
            NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", 0D, "No.", "No. Series");


    end;



}
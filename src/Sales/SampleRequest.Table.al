table 50115 "TFB Sample Request"
{
    Caption = 'Sales Header';
    DataCaptionFields =; //TODO Add in Data caption fields
    LookupPageID = "Sales List";
    Permissions = tabledata "Assemble-to-Order Link" = rmid;

    fields
    {
        field(1; MyField; Integer)
        {
            DataClassification = ToBeClassified;

        }

        field(2; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                StandardCodesMgt: Codeunit "Standard Codes Mgt.";
                IsHandled: Boolean;
            begin

                if "No." = '' then
                    InitRecord;

                if ("Sell-to Customer No." <> xRec."Sell-to Customer No.") and
                   (xRec."Sell-to Customer No." <> '')
                then begin
                    if ("Opportunity No." <> '') then
                        Error(
                          Text062,
                          FieldCaption("Sell-to Customer No."),
                          FieldCaption("Opportunity No."),
                          "Opportunity No.",
                          "Document Type");
                    if GetHideValidationDialog or not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := Confirm(ConfirmChangeQst, false, SellToCustomerTxt);
                    if Confirmed then begin
                        SalesLine.SetRange("Document Type", "Document Type");
                        SalesLine.SetRange("Document No.", "No.");
                        if "Sell-to Customer No." = '' then begin
                            if SalesLine.FindFirst then
                                Error(
                                  Text005,
                                  FieldCaption("Sell-to Customer No."));
                            Init;
                            OnValidateSellToCustomerNoAfterInit(Rec, xRec);
                            GetSalesSetup;
                            "No. Series" := xRec."No. Series";
                            InitRecord;
                            InitNoSeries;
                            exit;
                        end;

                        CheckShipmentInfo(SalesLine, false);
                        CheckPrepmtInfo(SalesLine);
                        CheckReturnInfo(SalesLine, false);

                        SalesLine.Reset();
                    end else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                if ("Document Type" = "Document Type"::Order) and
                   (xRec."Sell-to Customer No." <> "Sell-to Customer No.")
                then begin
                    SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                    SalesLine.SetRange("Document No.", "No.");
                    SalesLine.SetFilter("Purch. Order Line No.", '<>0');
                    if not SalesLine.IsEmpty() then
                        Error(
                          Text006,
                          FieldCaption("Sell-to Customer No."));
                    SalesLine.Reset();
                end;

                GetCust("Sell-to Customer No.");
                IsHandled := false;
                OnValidateSellToCustomerNoOnBeforeCheckBlockedCustOnDocs(Rec, Cust, IsHandled);
                if not IsHandled then
                    Cust.CheckBlockedCustOnDocs(Cust, "Document Type", false, false);
                if not ApplicationAreaMgmt.IsSalesTaxEnabled then
                    Cust.TestField("Gen. Bus. Posting Group");
                OnAfterCheckSellToCust(Rec, xRec, Cust, CurrFieldNo);

                CopySellToCustomerAddressFieldsFromCustomer(Cust);

                if "Sell-to Customer No." = xRec."Sell-to Customer No." then
                    if ShippedSalesLinesExist or ReturnReceiptExist then begin
                        TestField("VAT Bus. Posting Group", xRec."VAT Bus. Posting Group");
                        TestField("WHT Business Posting Group", xRec."WHT Business Posting Group");
                        TestField("Gen. Bus. Posting Group", xRec."Gen. Bus. Posting Group");
                    end;

                "Sell-to IC Partner Code" := Cust."IC Partner Code";
                "Send IC Document" := ("Sell-to IC Partner Code" <> '') and ("IC Direction" = "IC Direction"::Outgoing);

                UpdateShipToCodeFromCust();
                SetBillToCustomerNo(Cust);

                GetShippingTime(FieldNo("Sell-to Customer No."));

                if (xRec."Sell-to Customer No." <> "Sell-to Customer No.") or
                   (xRec."Currency Code" <> "Currency Code") or
                   (xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group") or
                   (xRec."VAT Bus. Posting Group" <> "VAT Bus. Posting Group")
                then
                    RecreateSalesLines(SellToCustomerTxt);

                if not SkipSellToContact then
                    UpdateSellToCont("Sell-to Customer No.");

                OnValidateSellToCustomerNoOnBeforeRecallModifyAddressNotification(Rec);
                if (xRec."Sell-to Customer No." <> '') and (xRec."Sell-to Customer No." <> "Sell-to Customer No.") then
                    RecallModifyAddressNotification(GetModifyCustomerAddressNotificationId);

                PostCodeCheck.CopyAddressID(
                  DATABASE::Customer, Cust.GetPosition, 0, DATABASE::"Sales Header", GetPosition, 3);
            end;
        }

        field(3; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin

                    NoSeriesMgt.TestManual(GetNoSeriesCode);
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
            begin
                
                if "Sell-to Contact No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric;

                if ("Sell-to Contact No." <> xRec."Sell-to Contact No.") and
                   (xRec."Sell-to Contact No." <> '')
                then begin
                    if ("Sell-to Contact No." = '') and ("Opportunity No." <> '') then
                        Error(Text049, FieldCaption("Sell-to Contact No."));
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
                UpdateSellToCustTemplateCode;
                UpdateShipToContact;
            end;
        }



        field(108; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnLookup()
            begin
                with TFBSampleRequest do begin
                    TFBSampleRequest := Rec;
                    GetSalesSetup;
                    TestNoSeries;
                    if NoSeriesMgt.LookupSeries(GetPostingNoSeriesCode, "Posting No. Series") then
                        Validate("Posting No. Series");
                    Rec := TFBSampleRequest;
                end;
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

        field(19; "Order Date"; Date)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Order Date';

        }
    }

    keys
    {
        key(Key1; MyField)
        {
            Clustered = true;
        }
    }

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SalesSetup: Record "Sales & Receivables Setup";
        SelectNoSeriesAllowed: Boolean;
        TFBSampleRequest: Record "TFB Sample Request";
        Cust: Record Customer;

    local procedure GetSalesSetup()
    begin
        SalesSetup.Get();

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
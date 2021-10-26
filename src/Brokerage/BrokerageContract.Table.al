table 50219 "TFB Brokerage Contract"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Brokerage Contract List";
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            trigger OnValidate()

            BEGIN
                IF "No." <> xRec."No." THEN BEGIN
                    SalesSetup.GET();
                    NoSeriesMgt.TestManual(SalesSetup."TFB Brokerage Contract Nos.");
                    "No. Series" := '';
                    NoSeriesMgt.SetSeries("No.");

                END;
            end;
        }
        field(2; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ValidateTableRelation = true;

        }
        field(3; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                VendorRec: Record Vendor;
            begin
                VendorRec.Get("Vendor No.");
                "Vendor Name" := VendorRec.Name;
                SetVendorDefaults();

            end;


        }
        field(4; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = False;

            trigger OnValidate()

            var
                VendorRec: Record Vendor;
            begin

                Validate("Vendor No.", VendorRec.GetVendorNo("Vendor Name"));
                SetVendorDefaults();

            end;

        }
        field(5052; "Buy-from Contact No."; Code[20])
        {
            Caption = 'Buy-from Contact No.';
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
            begin
                if "Vendor No." <> '' then
                    if Cont.Get("Buy-from Contact No.") then
                        Cont.SetRange("Company No.", Cont."Company No.")
                    else
                        if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Vendor, "Vendor No.") then
                            Cont.SetRange("Company No.", ContBusinessRelation."Contact No.")
                        else
                            Cont.SetRange("No.", '');

                if "Buy-from Contact No." <> '' then
                    if Cont.Get("Buy-from Contact No.") then;
                if PAGE.RunModal(0, Cont) = ACTION::LookupOK then begin
                    xRec := Rec;
                    Validate("Buy-from Contact No.", Cont."No.");
                end;
            end;


            trigger OnValidate()
            var
                ContBusinessRelation: Record "Contact Business Relation";
                Cont: Record Contact;
            begin


                if "Buy-from Contact No." <> '' then
                    if Cont.Get("Buy-from Contact No.") then
                        Cont.CheckIfPrivacyBlockedGeneric();

                if ("Buy-from Contact No." <> xRec."Buy-from Contact No.") and
                   (xRec."Buy-from Contact No." <> '')
                then begin
                    if not GuiAllowed then
                        Confirmed := true
                    else
                        Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Buy-from Contact No."));
                    if not Confirmed then exit;

                end;


                if ("Vendor No." <> '') and ("Buy-from Contact No." <> '') then begin
                    Cont.Get("Buy-from Contact No.");
                    if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Vendor, "Vendor No.") then
                        if ContBusinessRelation."Contact No." <> Cont."Company No." then
                            Error(Text038Msg, Cont."No.", Cont.Name, "Vendor No.")
                        else
                            "Buy-from Contact" := Cont.Name;
                end;
            end;
        }
        field(84; "Buy-from Contact"; Text[100])
        {
            Caption = 'Buy-from Contact';

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin
                if "Vendor No." = '' then
                    exit;

                Contact.FilterGroup(2);
                LookupContact("Vendor No.", "Buy-from Contact No.", Contact);
                if PAGE.RunModal(0, Contact) = ACTION::LookupOK then
                    Validate("Buy-from Contact No.", Contact."No.");
                Contact.FilterGroup(0);
            end;


        }
        field(5; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                CustomerRec: Record Customer;
            begin
                CustomerRec.Get("Customer No.");
                "Customer Name" := CustomerRec.Name;

            end;
        }
        field(14; "Customer Name"; Text[100])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = false;

            trigger OnValidate()

            var
                CustomerRec: Record Customer;
            begin

                Validate("Customer No.", CustomerRec.GetCustNo("Customer Name"));

            end;

        }

        field(18; "Sell-to Contact"; Text[100])
        {
            Caption = 'Sell-to Contact';

            trigger OnLookup()
            var
                Contact: Record Contact;
            begin


                Contact.FilterGroup(2);
                LookupContact("Customer No.", "Sell-to Contact No.", Contact);
                if PAGE.RunModal(0, Contact) = ACTION::LookupOK then
                    Validate("Sell-to Contact No.", Contact."No.");
                Contact.FilterGroup(0);
            end;

            trigger OnValidate()
            begin
                if "Sell-to Contact" = '' then
                    Validate("Sell-to Contact No.", '');

            end;
        }

        field(19; "Sell-to Contact No."; Code[20])
        {
            Caption = 'Sell-to Contact No.';
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";

            begin


                if "Customer No." <> '' then
                    if Cont.Get("Sell-to Contact No.") then
                        Cont.SetRange("Company No.", Cont."Company No.")
                    else
                        if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Customer, "Customer No.") then
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
                if ("Sell-to Contact No." <> xRec."Sell-to Contact No.") and (xRec."Sell-to Contact No." <> '')
                then begin

                    Confirmed := Confirm(ConfirmChangeQst, false, FieldCaption("Sell-to Contact No."));
                    if Confirmed then
                        exit
                    else begin
                        Rec := xRec;
                        exit;
                    end;
                end;

                if ("Customer No." <> '') and ("Sell-to Contact No." <> '') then
                    CheckContactRelatedToCustomerCompany("Sell-to Contact No.", "Customer No.", CurrFieldNo);

                Cont.Get("Sell-to Contact No.");
                "Sell-to Contact" := Cont.Name;


            end;
        }
        field(6; "External Reference No."; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Date Signed"; Date)
        {
            DataClassification = CustomerContent;
        }

        field(8; "Crop Year"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Payment Terms Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Payment Terms";
            ValidateTableRelation = True;

            trigger OnValidate()

            var
                PaymentTerms: record "Payment Terms";

            begin

                PaymentTerms.Get("Payment Terms Code");
                "Payment Terms GUID" := PaymentTerms.SystemId;

            end;
        }
        field(15; "Payment Terms GUID"; GUID)
        {
            DataClassification = CustomerContent;

        }

        field(10; "Commission Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "% of Value","$ per MT";


        }
        field(11; "Percentage"; Decimal)
        {
            Caption = 'Percentage %';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                UpdateContractLines();
            end;
        }
        field(12; "Fixed Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()

            begin
                UpdateContractLines();
            end;

        }
        field(17; "Vendor Price Unit"; Enum "TFB Price Unit")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()

            begin
                UpdateContractLines();
            end;
        }
        field(13; "Status"; Enum "TFB Brokerage Contract Status")
        {
            DataClassification = CustomerContent;



        }
        field(16; "Currency"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Currency;
            Enabled = false;


        }
        field(30; "Total Value"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("TFB Brokerage Contract Line".Amount where("Document No." = field("No.")));

        }
        field(40; "Total Brokerage"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("TFB Brokerage Contract Line"."Brokerage Fee" where("Document No." = field("No.")));

        }
        field(50; "Container Route"; Code[20])
        {
            TableRelation = "TFB Container Route";
            ValidateTableRelation = true;

        }
        field(60; "Shipping Method Code"; Code[20])
        {
            TableRelation = "Shipment Method";
            ValidateTableRelation = true;
            Caption = 'Shipping Method';
        }
        field(70; "Est. Freight Per MT"; Decimal)
        {
            trigger OnValidate()

            begin

            end;
        }
        field(80; "No. of Shipments"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("TFB Brokerage Shipment" where("Contract No." = field("No."), Status = field("Shipment Status Filter")));
        }
        field(90; "Shipment Status Filter"; Enum "TFB Brokerage Shipment Status")
        {
            FieldClass = FlowFilter;
            Caption = 'Shipment Status Filter';
        }

        field(500; "Contract Attach."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;

        }

    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Vendor Name", "Customer Name", "Date Signed", "Crop Year", Status)
        {

            Caption = 'Select Brokerage Contract';
        }
        fieldgroup(Brick; "No.", "Vendor Name", "Customer Name", "Total Brokerage")
        {

        }
    }

    local procedure LookupContact(CustomerNo: Code[20]; ContactNo: Code[20]; var Contact: Record Contact)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        if ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Customer, CustomerNo) then
            Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.")
        else
            Contact.SetRange("Company No.", '');
        if ContactNo <> '' then
            if Contact.Get(ContactNo) then;
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Confirmed: Boolean;
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        Text038Msg: Label 'Contact %1 %2 is related to a different company than vendor %3.', Comment = '%1 = Name, %2 = Company , %3 = Vendor';


    /// <summary> 
    /// After a vendor is chosen any dependant fields will get set with values
    /// </summary>
    local procedure SetVendorDefaults()
    var
        VendorRec: Record Vendor;
    begin
        VendorRec.Get("Vendor No.");
        "Payment Terms Code" := VendorRec."Payment Terms Code";
        "Vendor Price Unit" := VendorRec."TFB Vendor Price Unit";
        Percentage := VendorRec."TFB Brokerage Percentage";
        "Fixed Rate" := VendorRec."TFB Brokerage Fixed Rate";
        "Shipping Method Code" := VendorRec."Shipment Method Code";
        Currency := VendorRec."Currency Code";
    end;

    /// <summary> 
    /// Trigger an update of the brokerage contract lines shown
    /// </summary>
    /// 
    /// 

    local procedure CheckContactRelatedToCustomerCompany(ContactNo: Code[20]; CustomerNo: Code[20]; CurrFieldNo: Integer);
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        IsHandled: Boolean;
        Text038Err: Label 'Contact %1 %2 is related to a different company than customer %3.', Comment = '%1 - Contact No., %2 - Contact Name, %3 - Customer Name';

    begin
        IsHandled := false;

        if IsHandled then
            exit;

        Contact.Get(ContactNo);
        if ContBusRel.FindByRelation(ContBusRel."Link to Table"::Customer, CustomerNo) then
            if (ContBusRel."Contact No." <> Contact."Company No.") and (ContBusRel."Contact No." <> Contact."No.") then
                Error(Text038Err, Contact."No.", Contact.Name, CustomerNo);
    end;

    local procedure UpdateContractLines()

    var
        recContractLines: Record "TFB Brokerage Contract Line";

    begin
        recContractLines.SetRange("Document No.", "No.");

        if recContractLines.FindSet(true) then
            repeat
                recContractLines.CalcLineTotals();

            Until recContractLines.Next() = 0;


    end;

    trigger OnInsert()
    begin

        If "No." = '' then begin

            SalesSetup.Get();
            SalesSetup.TestField("TFB Brokerage Contract Nos.");
            NoSeriesMgt.InitSeries(SalesSetup."TFB Brokerage Contract Nos.", xRec."No. Series", 0D, "No.", "No. Series");
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
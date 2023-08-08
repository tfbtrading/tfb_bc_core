/// <summary>
/// TableExtension TFB Contact (ID 50110) extends Record Contact.
/// </summary>
tableextension 50110 "TFB Contact" extends Contact
{
    fields
    {

        field(50100; "TFB Contact Status"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Contact Status';
            TableRelation = "TFB Contact Status".Status;


            trigger OnValidate()

            begin
                validateContactStatus();
            end;
        }

        field(50170; "TFB Contact Stage"; enum "TFB Contact Stage")
        {
            Caption = 'Contact Stage';
            DataClassification = CustomerContent;

            trigger OnValidate()

            begin
                if Rec."TFB Contact Stage" = Rec."TFB Contact Stage"::Inactive then begin
                    Rec."TFB Review Date - Planned" := 0D;
                    Rec."TFB Review Date Exp. Compl." := 0D;
                end;
            end;
        }

        field(50172; "TFB Buying Reason"; Enum "TFB Buying Reason")
        {
            DataClassification = CustomerContent;
            Caption = 'Buying Reason';
        }

        field(50174; "TFB Buying Timeframe"; Enum "TFB Buying Timeframe")
        {
            DataClassification = CustomerContent;
            Caption = 'Buying Timeframe';
        }
        field(50176; "TFB Sales Readiness"; Enum "TFB Sales Readiness")
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Readiness';
        }
        field(50178; "TFB Lead Source"; Enum "TFB Lead Source")
        {
            DataClassification = CustomerContent;
            Caption = 'Lead Source';
        }
        field(50180; "TFB Is Customer"; Boolean)
        {
            CalcFormula = exist("Contact Business Relation" where("Contact No." = field("Company No."), "Link to Table" = const(Customer)));
            Caption = 'Is A Customer';
            Editable = false;
            FieldClass = FlowField;


        }

        field(50182; "TFB Linkedin Page"; Text[255])
        {
            DataClassification = CustomerContent;
            Caption = 'LinkedIn page';
            ExtendedDatatype = URL;
        }

        field(50220; "TFB No. Of Company Tasks"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("To-do" where("Contact Company No." = field("Company No."), Closed = const(false), "System To-do Type" = const(Organizer)));
            Caption = 'No. Of Tasks';
        }
        field(50222; "TFB No. Of Contact Tasks"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("To-do" where("Contact No." = field("No."), Closed = const(false), "System To-do Type" = const(Organizer)));
            Caption = 'No. Of Tasks';
        }
        field(50230; "TFB No. Of Individuals"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Contact where("Company No." = field("Company No."), Type = const(Person)));
            Caption = 'No. Of Individuals';
        }

        field(50410; "TFB Enable Online Access"; Boolean)
        {
            Caption = 'Enable Online Access';

            trigger OnValidate()

            var

                MarketingSetup: Record "Marketing Setup";
                EventGridMgmt: CodeUnit "TFB Event Grid Mgmt";
            begin

                MarketingSetup.Get();
                case Rec."TFB Enable Online Access" of
                    true:

                        if Rec.HasBusinessRelation("Contact Business Relation"::Customer, MarketingSetup."Bus. Rel. Code for Customers") then begin
                            //check mobile is unique

                            if not IsMobilePhoneNoUnique() then FieldError("TFB Enable Online Access", 'Mobile phone number must be unique for this contact. Unfortunately other users exist');
                            CheckMandatoryFieldsForEvent();
                            EventGridMgmt.PublishContactEnabledForOnline(Rec);
                        end
                        else
                            error('To enable online access for a contact, the customer must first be enabled');



                    false:

                        if Rec.HasBusinessRelation("Contact Business Relation"::Customer, MarketingSetup."Bus. Rel. Code for Customers") then begin
                            //check mobile is unique

                            if not IsMobilePhoneNoUnique() then FieldError("TFB Enable Online Access", 'Mobile phone number must be unique for this contact. Unfortunately other users exist');


                            EventGridMgmt.PublishContactDisabledForOnline(Rec);
                        end
                        else
                            error('To enable online access for a contact, the customer must first be enabled');



                end;

            end;

        }



        field(50420; "TFB Online Identity Id"; Text[100])
        {
            Caption = 'Online Identity Id';
        }

        field(50425; "TFB In Review"; Boolean)
        {
            Caption = 'In Review';
        }
        field(50430; "TFB Review Date - Planned"; Date)
        {
            Caption = 'Revew Date - Planned';
        }
        field(50432; "TFB Review Date Exp. Compl."; Date)
        {
            Caption = 'Review Date - Expected Completion';

        }
        field(50435; "TFB Review Date Last Compl."; Date)
        {
            Caption = 'Review Date - Last Completed';
        }

        field(50440; "TFB No. Rlshp. Mgt. Comments"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'No. of Comments';
            CalcFormula = count("Rlshp. Mgt. Comment Line" where("Table Name" = const(Contact), "No." = field("No.")));
        }
        field(50450; "TFB Industry Group Filter"; Code[10])
        {
            Caption = 'Industry Group Filter';
            FieldClass = FlowFilter;
            TableRelation = "Industry Group";
        }
        field(50451; "TFB No. Of Industry Groups"; Integer)
        {
            Caption = 'No. of Industry Groups - Filtered';
            FieldClass = FlowField;
            CalcFormula = count("Contact Industry Group" where("Industry Group Code" = field("TFB Industry Group Filter"), "Contact No." = field("No.")));
        }

        field(50460; "TFB Default Review Period"; enum "TFB Periodic Review")
        {
            Caption = 'Default Review Period';

        }
        field(50470; "TFB Review Note"; Text[256])
        {
            DataClassification = CustomerContent;
            Caption = 'Review Notes';
        }
        field(50475; "TFB Last Review Note"; Text[256])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Review Notes';
        }
        field(50480; "TFB Archived"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Archived';
        }



    }
    keys
    {
        key(ContactBusinessRel; "Contact Business Relation", "No.")
        {


        }
    }
    fieldgroups
    {
        addlast(Brick; "TFB Contact Stage", "TFB Contact Status", "E-Mail") { }
        addlast(DropDown; "TFB Contact Stage", "TFB Contact Status") { }
    }



    procedure GetCustomerRelation(): Record Customer
    var
        ContBusRel: Record "Contact Business Relation";
        Customer: Record Customer;


    begin
        ContBusRel.SetRange("Link to Table", Enum::"Contact Business Relation Link To Table"::Customer);
        ContBusRel.SetRange("Contact No.", Rec."Company No.");

        if ContBusRel.IsEmpty then exit;

        ContBusRel.FindFirst();
        Customer.SetLoadFields("Primary Contact No.", "No.");
        Customer.Get(ContBusRel."No.");
        Customer.CalcFields("TFB Date of First Sale", "TFB Date of Last Open Order", "TFB Date of Last Sale", "No. of Orders", Balance, "Balance Due", "Sales (LCY)");

        exit(Customer);

    end;


    local procedure FinishAction(_ReviewComment: Text[256]; _NextReview: Date; _NextContactStatus: Code[20])
    var


    begin


        Rec."TFB In Review" := false;
        Rec."TFB Review Date - Planned" := _NextReview;
        Rec."TFB Review Date Exp. Compl." := 0D;
        Rec."TFB Review Date Last Compl." := WorkDate();
        if _NextContactStatus <> '' then
            Rec.validate("TFB Contact Status", _NextContactStatus);
        if rec."TFB Review Note" <> '' then
            Rec."TFB Last Review Note" := Rec."TFB Review Note";

        Rec."TFB Review Note" := _ReviewComment;


    end;

    procedure InitiateReview()
    var

        DialogP: Page "TFB Initiate Review Dialog";
        DefaultWeek: DateFormula;
    begin
        Evaluate(DefaultWeek, '<7D>');

        DialogP.SetDefaults(CalcDate(DefaultWeek, WorkDate()), false);
        if not (DialogP.RunModal() = ACTION::OK) then exit;

        if DialogP.getShouldCompleteNow() then begin
            Rec."TFB Review Date Exp. Compl." := Today;
            Rec."TFB In Review" := true;
            Rec.Modify(false);
            Commit();
            Rec.CompleteReview();
        end
        else begin
            If DialogP.getExpectedReviewDate() > 0D then
                Rec."TFB Review Date Exp. Compl." := DialogP.getExpectedReviewDate()
            else
                Rec."TFB Review Date Exp. Compl." := CalcDate(DefaultWeek, WorkDate());

            Rec."TFB In Review" := true;
            Rec.Modify(false);
        end;
    end;

    procedure CompleteReview(): Boolean

    var

        WizardReview: Page "TFB Contact Review Wizard";
    begin

        WizardReview.InitFromContact(Rec);
        if (WizardReview.RunModal() = Action::OK) and WizardReview.IsFinished() then begin
            FinishAction(WizardReview.GetReviewComment(), WizardReview.GetNextPlannedDate(), WizardReview.GetContactStatus());
            Rec.Modify(true);
            Commit();
            exit(true);

        end;
    end;




    local procedure IsMobilePhoneNoUnique(): Boolean

    var
        Contact: Record Contact;
    begin
        if not (Rec."Mobile Phone No." <> '') then
            FieldError("Mobile Phone No.", 'To enable online access a contact must have a mobile phone number specified');


        Contact.SetRange(Type, Contact.Type::Person);
        Contact.SetFilter("No.", '<>%1', Rec."No.");
        Contact.SetRange("Mobile Phone No.", Rec."Mobile Phone No.");

        exit(Contact.IsEmpty());
    end;

    local procedure validateContactStatus()

    var
        Status: Record "TFB Contact Status";

    begin

        if Type = Type::Person then
            Rec."TFB Contact Status" := '';

        Status.SetRange(Status, Rec."TFB Contact Status");

        if Status.FindFirst() then
            Rec.validate("TFB Contact Stage", Status.Stage);



    end;

    local procedure CheckMandatoryFieldsForEvent()
    begin
        if "First Name" = '' then FieldError("First Name", 'First Name must be entered');
        if Surname = '' then FieldError(Surname, 'Last Name must be entered');
        if "Mobile Phone No." = '' then FieldError("Mobile Phone No.", 'Mobile phone number must be entered');
    end;

}
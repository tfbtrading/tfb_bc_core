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
            CalcFormula = Exist("Contact Business Relation" WHERE("Contact No." = FIELD("Company No."), "Link to Table" = const(Customer)));
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

                        If Rec.HasBusinessRelation("Contact Business Relation"::Customer, MarketingSetup."Bus. Rel. Code for Customers") then begin
                            //check mobile is unique

                            If Not IsMobilePhoneNoUnique() then FieldError("TFB Enable Online Access", 'Mobile phone number must be unique for this contact. Unfortunately other users exist');
                            CheckMandatoryFieldsForEvent();
                            EventGridMgmt.PublishContactEnabledForOnline(Rec);
                        end
                        else
                            error('To enable online access for a contact, the customer must first be enabled');



                    false:

                        If Rec.HasBusinessRelation("Contact Business Relation"::Customer, MarketingSetup."Bus. Rel. Code for Customers") then begin
                            //check mobile is unique

                            If Not IsMobilePhoneNoUnique() then FieldError("TFB Enable Online Access", 'Mobile phone number must be unique for this contact. Unfortunately other users exist');


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
            CalcFormula = Count("Rlshp. Mgt. Comment Line" where("Table Name" = const(Contact), "No." = field("No.")));
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
            CalcFormula = Count("Contact Industry Group" where("Industry Group Code" = field("TFB Industry Group Filter"), "Contact No." = field("No.")));
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

    local procedure FilterBusinessRelations(var ContBusRel: Record "Contact Business Relation"; LinkToTable: Enum "Contact Business Relation Link To Table"; All: Boolean)
    begin
        ContBusRel.Reset();
        if ("Company No." = '') or ("Company No." = "No.") then
            ContBusRel.SetRange("Contact No.", "No.")
        else
            ContBusRel.SetFilter("Contact No.", '%1|%2', "No.", "Company No.");
        if not All then
            ContBusRel.SetFilter("No.", '<>''''');
        if LinkToTable <> LinkToTable::" " then
            ContBusRel.SetRange("Link to Table", LinkToTable);
    end;

    procedure GetCustomerRelation(): Record Customer
    var
        ContBusRel: Record "Contact Business Relation";
        Customer: Record Customer;
        RecSelected: Boolean;

    begin
        ContBusRel.SetRange("Link to Table", Enum::"Contact Business Relation Link To Table"::Customer);
        ContBusRel.SetRange("Contact No.", Rec."Company No.");

        If ContBusRel.IsEmpty then exit;

        ContBusRel.FindFirst();
        Customer.SetLoadFields("Primary Contact No.", "No.");
        Customer.Get(ContBusRel."No.");
        Customer.CalcFields("TFB Date of First Sale", "TFB Date of Last Open Order", "TFB Date of Last Sale", "No. of Orders", Balance, "Balance Due", "Sales (LCY)");

        Exit(Customer);

    end;


    local procedure FinishAction(_ReviewComment: Text[256]; _NextReview: Date)
    var
        RelComment: Record "Rlshp. Mgt. Comment Line";
        LineNo: Integer;

    begin


        Rec."TFB In Review" := false;
        Rec."TFB Review Date - Planned" := _NextReview;
        Rec."TFB Review Date Exp. Compl." := 0D;
        Rec."TFB Review Date Last Compl." := WorkDate();
        If rec."TFB Review Note" <> '' then
            Rec."TFB Last Review Note" := Rec."TFB Review Note";

        Rec."TFB Review Note" := _ReviewComment;


    end;

    procedure InitiateReview()
    var

        DialogP: Page "Date-Time Dialog";
        DefaultWeek: DateFormula;
    begin

        DialogP.UseDateOnly();
        Evaluate(DefaultWeek, '<7D>');
        DialogP.Caption('Select when review will finish');
        DialogP.SetDate(CalcDate(DefaultWeek, WorkDate()));
        If not (DialogP.RunModal() = ACTION::OK) then exit;

        if (DialogP.GetDate() > 0D) then
            Rec."TFB Review Date Exp. Compl." := DialogP.GetDate()
        else
            Rec."TFB Review Date Exp. Compl." := CalcDate(DefaultWeek, WorkDate());

        Rec."TFB In Review" := true;
        Rec.Modify(false);
    end;

    procedure CompleteReview(): Boolean

    var

        WizardReview: Page "TFB Contact Review Wizard";
    begin

        WizardReview.InitFromContact(Rec);
        If WizardReview.RunModal() = Action::OK then begin
            FinishAction(WizardReview.GetReviewComment(), WizardReview.GetNextPlannedDate());
            Rec.Modify(false);
            exit(true);

        end;
    end;




    local procedure IsMobilePhoneNoUnique(): Boolean

    var
        Contact: Record Contact;
    begin
        If not (Rec."Mobile Phone No." <> '') then
            FieldError("Mobile Phone No.", 'To enable online access a contact must have a mobile phone number specified');


        Contact.SetRange(Type, Contact.Type::Person);
        Contact.SetFilter("No.", '<>%1', Rec."No.");
        Contact.SetRange("Mobile Phone No.", Rec."Mobile Phone No.");

        Exit(Contact.IsEmpty());
    end;

    local procedure validateContactStatus()

    var
        Status: Record "TFB Contact Status";

    begin

        If Type = Type::Person then
            Rec."TFB Contact Status" := '';

        Status.SetRange(Status, Rec."TFB Contact Status");

        If Status.FindFirst() then
            Rec.validate("TFB Contact Stage", Status.Stage);



    end;

    local procedure CheckMandatoryFieldsForEvent()
    begin
        If "First Name" = '' then FieldError("First Name", 'First Name must be entered');
        If Surname = '' then FieldError(Surname, 'Last Name must be entered');
        If "Mobile Phone No." = '' then FieldError("Mobile Phone No.", 'Mobile phone number must be entered');
    end;

}
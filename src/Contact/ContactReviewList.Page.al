page 50167 "Review customer contacts"
{
    ApplicationArea = Basic, Suite, Service;
    Caption = 'Review customer contacts';
    CardPageID = "Contact Card";
    DataCaptionFields = "Company No.";
    Editable = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Contact,Navigate';
    SourceTable = Contact;
    SourceTableView = SORTING("Company Name", "Company No.", Type, Name) WHERE(Type = const(Company), "Contact Business Relation" = filter('<>Vendor'));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {


                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    Visible = false;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the name of the contact. If the contact is a person, you can click the field to see the Name Details window.';
                }
                Field(ToDoExists; GetTaskSymbol())
                {
                    Caption = '';
                    Width = 1;
                    ShowCaption = false;
                    ToolTip = 'Specifies if a task exists';
                    DrillDown = false;
                    ApplicationArea = All;

                }
                field("Name 2"; Rec."Name 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies an additional part of the name.';
                    Visible = false;
                }

                field("TFB Contact Status"; Rec."TFB Contact Status")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Tooltip = 'Specifies contact status';

                }
                field("Last Date Attempted"; Rec."Last Date Attempted")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies last date attempted to reach contact';
                    Visible = false;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the contact''s job title.';
                    Visible = false;
                }
                field("Business Relation"; Rec."Contact Business Relation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the existing business relation.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code.';
                    Visible = false;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region of the address.';
                    Visible = false;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact''s phone number.';
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact''s mobile telephone number.';
                    Visible = false;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the contact''s email.';
                }

                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code of the salesperson who normally handles this contact.';
                }


                field(County; Rec.County)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the county of the contact.';
                }
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an alternate name that you can use to search for the record in question when you cannot remember the value in the Name field.';
                    Visible = false;
                }
                field("Privacy Blocked"; Rec."Privacy Blocked")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies whether to limit access to data for the data subject during daily operations. This is useful, for example, when protecting data from changes while it is under privacy review.';
                    Visible = false;
                }

                field("Coupled to CRM"; Rec."Coupled to CRM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the contact is coupled to a contact in Dataverse.';
                    Visible = CRMIntegrationEnabled or CDSIntegrationEnabled;
                }
            }
        }
        area(factboxes)
        {
            part(Control128; "Contact Statistics FactBox")
            {
                ApplicationArea = RelationshipMgmt;
                SubPageLink = "No." = FIELD("No."),
                              "Date Filter" = FIELD("Date Filter");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }

    }


    actions
    {
        area(navigation)
        {
            group("C&ontact")
            {
                Caption = 'C&ontact';
                Image = ContactPerson;
                group("Comp&any")
                {
                    Caption = 'Comp&any';
                    Enabled = CompanyGroupEnabled;
                    Image = Company;
                    action("Business Relations")
                    {
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'Business Relations';
                        Image = BusinessRelation;
                        RunObject = Page "Contact Business Relations";
                        RunPageLink = "Contact No." = FIELD("Company No.");
                        ToolTip = 'View or edit the contact''s business relations, such as customers, vendors, banks, lawyers, consultants, competitors, and so on.';
                    }
                    action("Industry Groups")
                    {
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'Industry Groups';
                        Image = IndustryGroups;
                        RunObject = Page "Contact Industry Groups";
                        RunPageLink = "Contact No." = FIELD("Company No.");
                        ToolTip = 'View or edit the industry groups, such as Retail or Automobile, that the contact belongs to.';
                    }
                    action("Web Sources")
                    {
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'Web Sources';
                        Image = Web;
                        RunObject = Page "Contact Web Sources";
                        RunPageLink = "Contact No." = FIELD("Company No.");
                        ToolTip = 'View a list of the web sites with information about the contacts.';
                    }
                }
                group("P&erson")
                {
                    Caption = 'P&erson';
                    Enabled = PersonGroupEnabled;
                    Image = User;
                    action("Job Responsibilities")
                    {
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'Job Responsibilities';
                        Image = Job;
                        ToolTip = 'View or edit the contact''s job responsibilities.';

                        trigger OnAction()
                        var
                            ContJobResp: Record "Contact Job Responsibility";
                        begin
                            CheckContactType(Type::Person);
                            ContJobResp.SetRange("Contact No.", "No.");
                            PAGE.RunModal(PAGE::"Contact Job Responsibilities", ContJobResp);
                        end;
                    }
                }
                action("Pro&files")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Pro&files';
                    Image = Answers;
                    ToolTip = 'Open the Profile Questionnaires window.';

                    trigger OnAction()
                    var
                        ProfileManagement: Codeunit ProfileManagement;
                    begin
                        ProfileManagement.ShowContactQuestionnaireCard(Rec, '', 0);
                    end;
                }
                action("&Picture")
                {
                    ApplicationArea = Suite, RelationshipMgmt;
                    Caption = '&Picture';
                    Image = Picture;
                    RunObject = Page "Contact Picture";
                    RunPageLink = "No." = FIELD("No.");
                    ToolTip = 'View or add a picture of the contact person or, for example, the company''s logo.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Rlshp. Mgt. Comment Sheet";
                    RunPageLink = "Table Name" = CONST(Contact),
                                  "No." = FIELD("No."),
                                  "Sub No." = CONST(0);
                    ToolTip = 'View or add comments for the record.';
                }
                group("Alternati&ve Address")
                {
                    Caption = 'Alternati&ve Address';
                    Image = Addresses;
                    action(Card)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Card';
                        Image = EditLines;
                        RunObject = Page "Contact Alt. Address List";
                        RunPageLink = "Contact No." = FIELD("No.");
                        ToolTip = 'View or change detailed information about the contact.';
                    }
                    action("Date Ranges")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Date Ranges';
                        Image = DateRange;
                        RunObject = Page "Contact Alt. Addr. Date Ranges";
                        RunPageLink = "Contact No." = FIELD("No.");
                        ToolTip = 'Specify date ranges that apply to the contact''s alternate address.';
                    }
                }
#if not CLEAN19

#endif
            }


            group("Related Information")
            {
                Caption = 'Related Information';
                Image = Users;
                action("Relate&d Contacts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Relate&d Contacts';
                    Image = Users;
                    RunObject = Page "Contact List";
                    RunPageLink = "Company No." = FIELD("Company No.");
                    ToolTip = 'View a list of all contacts.';
                }
                action("Segmen&ts")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Segmen&ts';
                    Image = Segment;
                    RunObject = Page "Contact Segment List";
                    RunPageLink = "Contact Company No." = FIELD("Company No."),
                                  "Contact No." = FILTER(<> ''),
                                  "Contact No." = FIELD(FILTER("Lookup Contact No."));
                    RunPageView = SORTING("Contact No.", "Segment No.");
                    ToolTip = 'View the segments that are related to the contact.';
                }
                action("Mailing &Groups")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Mailing &Groups';
                    Image = DistributionGroup;
                    RunObject = Page "Contact Mailing Groups";
                    RunPageLink = "Contact No." = FIELD("No.");
                    ToolTip = 'View or edit the mailing groups that the contact is assigned to, for example, for sending price lists or Christmas cards.';
                }
#if not CLEAN18

#endif
                action(RelatedCustomer)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer';
                    Image = Customer;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Enabled = RelatedCustomerEnabled;
                    ToolTip = 'View the related customer that is associated with the current record.';

                    trigger OnAction()
                    var
                        LinkToTable: Enum "Contact Business Relation Link To Table";
                    begin
                        Rec.ShowBusinessRelation(LinkToTable::Customer, false);
                    end;
                }
                action(RelatedVendor)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor';
                    Image = Vendor;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Enabled = RelatedVendorEnabled;
                    ToolTip = 'View the related vendor that is associated with the current record.';

                    trigger OnAction()
                    var
                        LinkToTable: Enum "Contact Business Relation Link To Table";
                    begin
                        Rec.ShowBusinessRelation(LinkToTable::Vendor, false);
                    end;
                }
                action(RelatedBank)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Account';
                    Image = BankAccount;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Enabled = RelatedBankEnabled;
                    ToolTip = 'View the related bank account that is associated with the current record.';

                    trigger OnAction()
                    var
                        LinkToTable: Enum "Contact Business Relation Link To Table";
                    begin
                        Rec.ShowBusinessRelation(LinkToTable::"Bank Account", false);
                    end;
                }
                action(RelatedEmployee)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Employee';
                    Image = Employee;
                    Promoted = true;
                    PromotedCategory = Category5;
                    Enabled = RelatedEmployeeEnabled;
                    ToolTip = 'View the related employee that is associated with the current record.';

                    trigger OnAction()
                    var
                        LinkToTable: Enum "Contact Business Relation Link To Table";
                    begin
                        Rec.ShowBusinessRelation(LinkToTable::Employee, false);
                    end;
                }
            }

            group(Tasks)
            {
                Caption = 'Tasks';
                Image = Task;
                action("T&asks")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'T&asks';
                    Image = TaskList;
                    RunObject = Page "Task List";
                    RunPageLink = "Contact Company No." = FIELD("Company No."),
                                  "Contact No." = FIELD(FILTER("Lookup Contact No.")),
                                  "System To-do Type" = FILTER("Contact Attendee");
                    RunPageView = SORTING("Contact Company No.", "Contact No.");
                    ToolTip = 'View all marketing tasks that involve the contact person.';
                }
                action("Open Oppo&rtunities")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Open Oppo&rtunities';
                    Image = OpportunityList;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Opportunity List";
                    RunPageLink = "Contact Company No." = FIELD("Company No."),
                                  "Contact No." = FILTER(<> ''),
                                  "Contact No." = FIELD(FILTER("Lookup Contact No.")),
                                  Status = FILTER("Not Started" | "In Progress");
                    RunPageView = SORTING("Contact Company No.", "Contact No.");
                    Scope = Repeater;
                    ToolTip = 'View the open sales opportunities that are handled by salespeople for the contact. Opportunities must involve a contact and can be linked to campaigns.';
                }
                action("Postponed &Interactions")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Postponed &Interactions';
                    Image = PostponedInteractions;
                    RunObject = Page "Postponed Interactions";
                    RunPageLink = "Contact Company No." = FIELD("Company No."),
                                  "Contact No." = FILTER(<> ''),
                                  "Contact No." = FIELD(FILTER("Lookup Contact No."));
                    RunPageView = SORTING("Contact Company No.", "Contact No.");
                    ToolTip = 'View postponed interactions for the contact.';
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action(ShowSalesQuotes)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales &Quotes';
                    Image = Quote;
                    RunObject = Page "Sales Quotes";
                    RunPageLink = "Sell-to Contact No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", "Sell-to Contact No.");
                    ToolTip = 'View sales quotes that exist for the contact.';
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Closed Oppo&rtunities")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Closed Oppo&rtunities';
                    Image = OpportunityList;
                    RunObject = Page "Opportunity List";
                    RunPageLink = "Contact Company No." = FIELD("Company No."),
                                  "Contact No." = FILTER(<> ''),
                                  "Contact No." = FIELD(FILTER("Lookup Contact No.")),
                                  Status = FILTER(Won | Lost);
                    RunPageView = SORTING("Contact Company No.", "Contact No.");
                    ToolTip = 'View the closed sales opportunities that are handled by salespeople for the contact. Opportunities must involve a contact and can be linked to campaigns.';
                }
                action("Interaction Log E&ntries")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Interaction Log E&ntries';
                    Image = InteractionLog;
                    RunObject = Page "Interaction Log Entries";
                    RunPageLink = "Contact Company No." = FIELD("Company No."),
                                  "Contact No." = FILTER(<> ''),
                                  "Contact No." = FIELD(FILTER("Lookup Contact No."));
                    RunPageView = SORTING("Contact Company No.", "Contact No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View a list of the interactions that you have logged, for example, when you create an interaction, print a cover sheet, a sales order, and so on.';
                }
                action(Statistics)
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Contact Statistics";
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
                action("Sent Emails")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sent Emails';
                    Image = ShowList;
                    ToolTip = 'View a list of emails that you have sent to this contact.';

                    trigger OnAction()
                    var
                        Email: Codeunit Email;
                    begin
                        Email.OpenSentEmails(Database::Contact, Rec.SystemId);
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(MakePhoneCall)
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Make &Phone Call';
                    Image = Calls;
                    Promoted = true;
                    PromotedCategory = Process;
                    Scope = Repeater;
                    ToolTip = 'Call the selected contact.';

                    trigger OnAction()
                    var
                        TAPIManagement: Codeunit TAPIManagement;
                    begin
                        TAPIManagement.DialContCustVendBank(DATABASE::Contact, "No.", GetDefaultPhoneNo, '');
                    end;
                }
                action("Launch &Web Source")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Launch &Web Source';
                    Image = LaunchWeb;
                    ToolTip = 'Search for information about the contact online.';

                    trigger OnAction()
                    var
                        ContactWebSource: Record "Contact Web Source";
                    begin
                        ContactWebSource.SetRange("Contact No.", "Company No.");
                        if PAGE.RunModal(PAGE::"Web Source Launch", ContactWebSource) = ACTION::LookupOK then
                            ContactWebSource.Launch;
                    end;
                }
                group("Create as")
                {
                    Caption = 'Create as';
                    Image = CustomerContact;
                    action(Customer)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer';
                        Image = Customer;
                        ToolTip = 'Create the contact as a customer.';

                        trigger OnAction()
                        begin
                            CreateCustomer();
                        end;
                    }
                    action(Vendor)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Vendor';
                        Image = Vendor;
                        ToolTip = 'Create the contact as a vendor.';

                        trigger OnAction()
                        begin
                            CreateVendor;
                        end;
                    }

                }
                group("Link with existing")
                {
                    Caption = 'Link with existing';
                    Image = Links;
                    action(Action63)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer';
                        Image = Customer;
                        ToolTip = 'Link the contact to an existing customer.';

                        trigger OnAction()
                        begin
                            CreateCustomerLink;
                        end;
                    }
                    action(Action64)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Vendor';
                        Image = Vendor;
                        ToolTip = 'Link the contact to an existing vendor.';

                        trigger OnAction()
                        begin
                            CreateVendorLink;
                        end;
                    }
                    action(Action65)
                    {
                        AccessByPermission = TableData "Bank Account" = R;
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bank';
                        Image = Bank;
                        ToolTip = 'Link the contact to an existing bank.';

                        trigger OnAction()
                        begin
                            CreateBankAccountLink;
                        end;
                    }

                }
            }

            action("Create &Interaction")
            {
                AccessByPermission = TableData Attachment = R;
                ApplicationArea = RelationshipMgmt;
                Caption = 'Create &Interaction';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Create an interaction with a specified contact.';

                trigger OnAction()
                begin
                    CreateInteraction;
                end;
            }
            action("Create Opportunity")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Create Opportunity';
                Image = NewOpportunity;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Opportunity Card";
                RunPageLink = "Contact No." = FIELD("No."),
                              "Contact Company No." = FIELD("Company No.");
                RunPageMode = Create;
                ToolTip = 'Register a sales opportunity for the contact.';
            }
            action(WordTemplate)
            {
                ApplicationArea = All;
                Caption = 'Apply Word Template';
                ToolTip = 'Apply a Word template on the selected records.';
                Image = Word;

                trigger OnAction()
                var
                    Contact: Record Contact;
                    WordTemplateSelectionWizard: Page "Word Template Selection Wizard";
                begin
                    CurrPage.SetSelectionFilter(Contact);
                    WordTemplateSelectionWizard.SetData(Contact);
                    WordTemplateSelectionWizard.RunModal();
                end;
            }
            action(Email)
            {
                ApplicationArea = All;
                Caption = 'Send Email';
                Image = Email;
                ToolTip = 'Send an email to this contact.';
                Promoted = true;
                PromotedCategory = Process;
                Enabled = CanSendEmail;

                trigger OnAction()
                var
                    TempEmailItem: Record "Email Item" temporary;
                    EmailScenario: Enum "Email Scenario";
                begin
                    TempEmailItem.AddSourceDocument(Database::Contact, Rec.SystemId);
                    TempEmailitem."Send to" := Rec."E-Mail";
                    TempEmailItem.Send(false, EmailScenario::Default);
                end;
            }

        }
        area(creation)
        {
            action(NewSalesQuote)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create Sales Quote';
                Image = NewSalesQuote;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Offer items or services to a customer.';

                trigger OnAction()
                begin
                    Rec.CreateSalesQuoteFromContact;
                end;
            }
        }

    }

    views
    {
        view(ContactsInPursuit)
        {
            Caption = 'Pipeline: In pursuit';
            Filters = where("TFB Contact Stage" = filter('=Lead|Prospect'));
        }
        view(ContactsActive)
        {
            Caption = 'Pipeline: Active';
            Filters = where("TFB Contact Stage" = filter('=Converted'));
        }
        view(ContactsInactive)
        {
            Caption = 'Pipeline: Inactive';
            Filters = where("TFB Contact Stage" = filter('=Inactive'));
        }
        view(ContactWithTasks)
        {
            Caption = 'Contacts With Open Tasks';
            Filters = where("TFB No. Of Company Tasks" = filter('>0'), Type = const(Company));
            SharedLayout = true;
        }

        view(ContactsPendingInteraction)
        {
            Caption = 'Contacts Requiring Followup';
            Filters = where("Last Date Attempted" = filter('<>'''''), "Date of Last Interaction" = filter(''), Type = const(Company));
            SharedLayout = false;
            layout
            {
                modify("Last Date Attempted")
                {
                    Visible = true;
                }
                moveafter("TFB Contact Status"; "Last Date Attempted")

            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        Contact: Record Contact;
    begin
        EnableFields;

        SetEnabledRelatedActions();

        CurrPage.SetSelectionFilter(Contact);
        CanSendEmail := Contact.Count() = 1;
    end;

    trigger OnAfterGetRecord()
    begin
        StyleIsStrong := Type = Type::Company;
    end;

    trigger OnOpenPage()
    begin

        UpdateContactBusinessRelationOnContacts();
    end;

    local procedure UpdateContactBusinessRelationOnContacts()
    var
        ContactToUpdate: Record Contact;
        [SecurityFiltering(SecurityFilter::Filtered)]
        ContactRec: Record Contact;
        ContactBusinessRelation: Enum "Contact Business Relation";
    begin
        ContactRec.SetRange("Contact Business Relation", ContactBusinessRelation::" ");
        if ContactRec.IsEmpty() then
            exit;

        ContactRec.FindSet();
        repeat
            ContactToUpdate.Get(ContactRec."No.");
            if (ContactToUpdate.UpdateBusinessRelation()) then
                ContactToUpdate.Modify();
        until ContactRec.Next() = 0;
    end;

    var

        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
        [InDataSet]
        CanSendEmail: Boolean;
        [InDataSet]
        StyleIsStrong: Boolean;
        CompanyGroupEnabled: Boolean;
        PersonGroupEnabled: Boolean;
        ExtendedPriceEnabled: Boolean;
        CRMIntegrationEnabled: Boolean;
        CDSIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
        RelatedCustomerEnabled: Boolean;
        RelatedVendorEnabled: Boolean;
        RelatedBankEnabled: Boolean;
        RelatedEmployeeEnabled: Boolean;
        ExportContactEnabled: Boolean;

    local procedure EnableFields()
    begin
        CompanyGroupEnabled := Type = Type::Company;
        PersonGroupEnabled := Type = Type::Person;
        ExportContactEnabled := Rec."No." <> '';
    end;

    local procedure SetEnabledRelatedActions()
    begin
        Rec.HasBusinessRelations(RelatedCustomerEnabled, RelatedVendorEnabled, RelatedBankEnabled, RelatedEmployeeEnabled)
    end;


    procedure GetSelectionFilter(): Text
    var
        Contact: Record Contact;
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        CurrPage.SetSelectionFilter(Contact);
        exit(SelectionFilterManagement.GetSelectionFilterForContact(Contact));
    end;

    procedure SetSelection(var Contact: Record Contact)
    begin
        CurrPage.SetSelectionFilter(Contact);
    end;

    local procedure GetTaskSymbol(): Text

    var
        Contact: Record Contact;

    begin

        Contact.SetLoadFields("TFB No. Of Company Tasks", "TFB No. Of Contact Tasks", "No.");
        Contact.SetAutoCalcFields("TFB No. Of Company Tasks", "TFB No. Of Contact Tasks");
        Rec.CalcFields("TFB No. Of Company Tasks");
        If Rec.Type = Rec.Type::Company then
            If Rec."TFB No. Of Company Tasks" > 0 then
                Exit('📋')
            else
                Exit('')
        else
            If Contact."TFB No. Of Contact Tasks" > 0 then
                Exit('📋')
            else
                Exit('');
    end;


}

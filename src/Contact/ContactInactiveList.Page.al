page 50180 "TFB Contact Inactive List"
{
    ApplicationArea = Basic, Suite, Service;
    Caption = 'Contacts - Inactive';
    CardPageID = "Contact Card";
    DataCaptionFields = "Company No.";
    PageType = List;
    SourceTable = Contact;
    SourceTableView = sorting("Company Name", "Company No.", Type, Name) where(Type = const(Company), "TFB Contact Stage" = filter('=Inactive'));
    UsageCategory = Lists;
    InsertAllowed = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {


                ShowCaption = false;
                field("No."; Rec."No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the name of the contact. If the contact is a person, you can click the field to see the Name Details window.';
                }
                field(ToDoExists; GetTaskSymbol())
                {
                    Caption = '';
                    Width = 1;
                    ShowCaption = false;
                    ToolTip = 'Specifies if a task exists';
                    DrillDown = false;

                }
                field("Name 2"; Rec."Name 2")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies an additional part of the name.';
                    Visible = false;
                }

                field("TFB Contact Status"; Rec."TFB Contact Status")
                {
                    Editable = true;
                    Tooltip = 'Specifies contact status';

                }

                field("Last Date Attempted"; Rec."Last Date Attempted")
                {
                    Editable = false;
                    ToolTip = 'Specifies last date attempted to reach contact';
                    Visible = false;
                }

                field("Business Relation"; Rec."Contact Business Relation")
                {
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

            }
        }
        area(factboxes)
        {

            part(Control41; "Contact Picture")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("No.");

            }
            part(Control128; "Contact Statistics FactBox")
            {
                UpdatePropagation = both;
                ApplicationArea = RelationshipMgmt;
                SubPageLink = "No." = field("No."),
                              "Date Filter" = field("Date Filter");
            }

            part(CustomerDetails; "Customer Statistics FactBox")
            {
                UpdatePropagation = SubPart;
                ApplicationArea = RelationshipMgmt;
                SubPageLink = "TFB Primary Contact Company ID" = field("No.");
                Visible = RelatedCustomerEnabled;
            }
            systempart(Control1900383207; Links)
            {
                UpdatePropagation = both;
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                UpdatePropagation = both;
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
                        RunPageLink = "Contact No." = field("Company No.");
                        ToolTip = 'View or edit the contact''s business relations, such as customers, vendors, banks, lawyers, consultants, competitors, and so on.';
                    }
                    action("Industry Groups")
                    {
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'Industry Groups';
                        Image = IndustryGroups;
                        RunObject = Page "Contact Industry Groups";
                        RunPageLink = "Contact No." = field("Company No.");
                        ToolTip = 'View or edit the industry groups, such as Retail or Automobile, that the contact belongs to.';
                    }
                    action("Web Sources")
                    {
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'Web Sources';
                        Image = Web;
                        RunObject = Page "Contact Web Sources";
                        RunPageLink = "Contact No." = field("Company No.");
                        ToolTip = 'View a list of the web sites with information about the contacts.';
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
                    RunPageLink = "No." = field("No.");
                    ToolTip = 'View or add a picture of the contact person or, for example, the company''s logo.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;

                    RunObject = Page "Rlshp. Mgt. Comment Sheet";
                    RunPageLink = "Table Name" = const(Contact),
                                  "No." = field("No."),
                                  "Sub No." = const(0);
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
                        RunPageLink = "Contact No." = field("No.");
                        ToolTip = 'View or change detailed information about the contact.';
                    }
                    action("Date Ranges")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Date Ranges';
                        Image = DateRange;
                        RunObject = Page "Contact Alt. Addr. Date Ranges";
                        RunPageLink = "Contact No." = field("No.");
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
                    RunPageLink = "Company No." = field("Company No.");
                    ToolTip = 'View a list of all contacts.';
                }
                action("Segmen&ts")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Segmen&ts';
                    Image = Segment;
                    RunObject = Page "Contact Segment List";
                    RunPageLink = "Contact Company No." = field("Company No."),
                                  "Contact No." = filter(<> ''),
                                  "Contact No." = field(filter("Lookup Contact No."));
                    RunPageView = sorting("Contact No.", "Segment No.");
                    ToolTip = 'View the segments that are related to the contact.';
                }
                action("Mailing &Groups")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Mailing &Groups';
                    Image = DistributionGroup;
                    RunObject = Page "Contact Mailing Groups";
                    RunPageLink = "Contact No." = field("No.");
                    ToolTip = 'View or edit the mailing groups that the contact is assigned to, for example, for sending price lists or Christmas cards.';
                }
#if not CLEAN18








#endif
                action(RelatedCustomer)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer';
                    Image = Customer;

                    Enabled = RelatedCustomerEnabled;
                    ToolTip = 'View the related customer that is associated with the current record.';

                    trigger OnAction()
                    var
                        LinkToTable: Enum "Contact Business Relation Link To Table";
                    begin
                        Rec.ShowBusinessRelation(LinkToTable::Customer, false);
                    end;
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
                    RunPageLink = "Contact Company No." = field("Company No."),
                                  "Contact No." = filter(<> ''),
                                  "Contact No." = field(filter("Lookup Contact No.")),
                                  Status = filter(Won | Lost);
                    RunPageView = sorting("Contact Company No.", "Contact No.");
                    ToolTip = 'View the closed sales opportunities that are handled by salespeople for the contact. Opportunities must involve a contact and can be linked to campaigns.';
                }
                action("Interaction Log E&ntries")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Interaction Log E&ntries';
                    Image = InteractionLog;
                    RunObject = Page "Interaction Log Entries";
                    RunPageLink = "Contact Company No." = field("Company No."),
                                  "Contact No." = filter(<> ''),
                                  "Contact No." = field(filter("Lookup Contact No."));
                    RunPageView = sorting("Contact Company No.", "Contact No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View a list of the interactions that you have logged, for example, when you create an interaction, print a cover sheet, a sales order, and so on.';
                }
                action(Statistics)
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Statistics';
                    Image = Statistics;

                    RunObject = Page "Contact Statistics";
                    RunPageLink = "No." = field("No.");
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

            action(Email)
            {
                Caption = 'Send Email';
                Image = Email;
                ToolTip = 'Send an email to this contact.';

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
            action(TFBArchive)
            {
                Caption = 'Archive';
                Image = Archive;
                ToolTip = 'Archive a contact so it is not seen in reviews.';
                Enabled = not Rec."TFB Archived";


                trigger OnAction()
                var
                    Confirm: Codeunit "Confirm Management";

                begin
                    if Confirm.GetResponse('Are you sure you want to archive?', false) then
                        Rec.validate("TFB Archived", true);
                end;
            }

        }


        area(Promoted)
        {
            group(Home)
            {
                Caption = 'Home';


                actionref(PTFBArchive; TFBArchive)
                {

                }


            }
            group(Contact)
            {
                Caption = 'Contact';
                actionref(ActionRef3; RelatedCustomer)
                {

                }

                actionref(ActionRef2; "Co&mments")
                {

                }
                actionref(PStatistics; Statistics)
                {

                }

            }
        }

    }

    views
    {

        view(ContactWithTasks)
        {
            Caption = 'Contacts With Open Tasks';
            Filters = where("TFB No. Of Company Tasks" = filter('>0'), Type = const(Company));
            SharedLayout = true;
        }



    }


    trigger OnAfterGetCurrRecord()
    var
        Contact2: Record Contact;
    begin
        EnableFields();

        SetEnabledRelatedActions();

        CurrPage.SetSelectionFilter(Contact2);
        CanSendEmail := Contact2.Count() = 1;


    end;

    trigger OnAfterGetRecord()
    begin

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



        CanSendEmail: Boolean;


        CompanyGroupEnabled: Boolean;
        PersonGroupEnabled: Boolean;



        RelatedCustomerEnabled: Boolean;
        RelatedVendorEnabled: Boolean;
        RelatedBankEnabled: Boolean;
        RelatedEmployeeEnabled: Boolean;


    local procedure EnableFields()
    begin
        CompanyGroupEnabled := Rec.Type = Rec.Type::Company;


    end;

    local procedure SetEnabledRelatedActions()
    begin
        Rec.HasBusinessRelations(RelatedCustomerEnabled, RelatedVendorEnabled, RelatedBankEnabled, RelatedEmployeeEnabled)
    end;


    procedure GetSelectionFilter(): Text
    var
        Contact2: Record Contact;
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        CurrPage.SetSelectionFilter(Contact2);
        exit(SelectionFilterManagement.GetSelectionFilterForContact(Contact2));
    end;

    procedure SetSelection(var LclContact: Record Contact)
    begin
        CurrPage.SetSelectionFilter(LclContact);
    end;

    local procedure GetTaskSymbol(): Text

    var
        NewContact: Record Contact;

    begin

        NewContact.SetLoadFields("TFB No. Of Company Tasks", "TFB No. Of Contact Tasks", "No.");
        NewContact.SetAutoCalcFields("TFB No. Of Company Tasks", "TFB No. Of Contact Tasks");
        Rec.CalcFields("TFB No. Of Company Tasks");
        if Rec.Type = Rec.Type::Company then
            if Rec."TFB No. Of Company Tasks" > 0 then
                exit('📋')
            else
                exit('')
        else
            if NewContact."TFB No. Of Contact Tasks" > 0 then
                exit('📋')
            else
                exit('');
    end;



}

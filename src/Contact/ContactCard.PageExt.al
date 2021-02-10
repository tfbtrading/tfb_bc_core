pageextension 50148 "TFB Contact Card" extends "Contact Card"
{
    layout
    {

        modify("No.")
        {
            Editable = false;
            Importance = Additional;
        }
        // Add changes to page layout here
        addafter("Organizational Level Code")
        {
            field("Job Title"; Rec."Job Title")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies job title for contact';
                Visible = Rec.Type = Rec.Type::Person;
            }
        }
        modify("Parental Consent Received")
        {
            Visible = false;
        }
        modify(Minor)
        {
            Visible = false;
        }
        modify("IRD No.")
        {
            visible = false;
        }
        modify("ABN Division Part No.")
        {
            visible = false;
        }

        modify(Registration)
        {
            Visible = Rec.type = Rec.type::Company;
        }
        modify("Foreign Trade")
        {
            Visible = Rec.type = Rec.type::Company;
        }
        modify("Salutation Code")
        {
            Enabled = Rec.Type = Rec.type::Person;
        }
        addafter("Salesperson Code")
        {
            group(Status)
            {
                ShowCaption = false;
                visible = rec.type = rec.type::Company;

                field("TFB Contact Status"; Rec."TFB Contact Status")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Tooltip = 'Specifies the contact status';
                    Style = strong;
                    StyleExpr = true;

                }
            }
        }
        addbefore("Profile Questionnaire")
        {

            part(IndividualContacts; "TFB Company Contacts Subform")
            {
                Caption = 'Contacts';
                Visible = rec.type = rec.type::Company;
                ApplicationArea = All;
                SubPageLink = "Company No." = field("No.");
                SubPageView = where(Type = const(Person));
            }

            part(Tasks; "TFB Contact Task Subform")
            {
                SubPageLink = "Contact Company No." = field("Company No."), "System To-do Type" = const(Organizer), Closed = const(false);
                Caption = 'Active Tasks';
                Visible = true;
                ApplicationArea = All;
            }
        }
        addlast(General)
        {
            group(AdditionalInfo)
            {
                Caption = 'Additional Information';
                Visible = Rec.Type = Rec.Type::Company;

                field("TFB Sales Readiness"; Rec."TFB Sales Readiness")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales readiness for the contact';
                }
                field("TFB Lead Source"; Rec."TFB Lead Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies where the lead originated from';
                }

            }
        }

        addafter("Home Page")
        {
            group(LinkedIn)
            {
                ShowCaption = false;
                grid(LinkedInGrid)
                {
                    GridLayout = Columns;
                    field("TFB Linkedin Page"; Rec."TFB Linkedin Page")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specify linkedin URL';
                        ExtendedDatatype = URL;
                    }

                }
            }

        }


    }



    actions
    {
        // Add changes to page actions here
    }



    var
        Link: Label '🔗';

}
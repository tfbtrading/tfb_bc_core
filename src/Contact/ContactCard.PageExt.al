pageextension 50148 "TFB Contact Card" extends "Contact Card"
{
    layout
    {

        modify("No.")
        {
            Editable = false;
            Importance = Additional;
        }
        addbefore("Exclude from Segment")
        {
            field("TFB Enable Online Access"; Rec."TFB Enable Online Access")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if a contact has direct online access to information for their related customer';
            }
            group(OnlineIdentityDetails)
            {
                Visible = Rec."TFB Online Identity Id" <> '';
                ShowCaption = false;

                label(IdentitySetup)
                {
                    ApplicationArea = All;
                    Caption = 'Active ✔️';
                }
            }
        }
        // Add changes to page layout here

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
            group(Status)
            {
                ShowCaption = true;
                visible = rec.type = rec.type::Company;

                field("TFB Contact Status"; Rec."TFB Contact Status")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Caption = 'Pipeline Status';
                    Tooltip = 'Specifies the contact status';
                    Style = strong;
                    StyleExpr = true;
                }
                field("TFB Sales Readiness"; Rec."TFB Sales Readiness")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales readiness for the contact';
                    Importance = Standard;
                }

                field("TFB In Review"; Rec."TFB In Review")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies whether a review is currently being undertaken of contact';
                    Style = Strong;
                    StyleExpr = Rec."TFB In Review";
                    Editable = false;
                }

                field("TFB Review Date - Planned"; Rec."TFB Review Date - Planned")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies the next date in which a contact should be reviewed';
                    Editable = not Rec."TFB In Review";
                }
                field("TFB Review Date Exp. Compl."; Rec."TFB Review Date Exp. Compl.")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies when planned date for when review will be completed';
                    Editable = Rec."TFB In Review";
                }
                group(ReviewHistory)
                {
                    Visible = (Rec."TFB Review Date Last Compl." > 0D) and (not Rec."TFB In Review");
                    ShowCaption = false;

                    field("TFB Review Date Last Compl."; Rec."TFB Review Date Last Compl.")
                    {
                        ApplicationArea = All;
                        Importance = Standard;
                        ToolTip = 'Specifies date the last review was completed';
                        Editable = false;

                    }
                }


            }
            group(AdditionalInfo)
            {
                Caption = 'Additional Information';
                Visible = Rec.Type = Rec.Type::Company;


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
        addlast("F&unctions")
        {
            action(CheckOnlineStatus)
            {
                ApplicationArea = All;
                Image = UpdateDescription;
                Caption = 'Check Online Access Status';
                ToolTip = 'Checks whether the contact has been activated in the online system';
                trigger OnAction()

                var

                    EventMgmt: CodeUnit "TFB Event Grid Mgmt";
                begin

                    EventMgmt.PublishCheckStatus(Rec);
                end;
            }
        }
    }




}
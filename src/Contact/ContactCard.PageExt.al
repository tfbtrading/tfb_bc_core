pageextension 50148 "TFB Contact Card" extends "Contact Card"
{
    layout
    {

        modify("No.")
        {
            Editable = false;
            Importance = Additional;
        }
        addafter(Type)
        {
            group(PersonalJobDetails)
            {
                Visible = rec.type = rec.type::Person;
                ShowCaption = false;

                field("TFB Primary Job Resp. Code"; Rec.GetPrimaryJobResponsibilityText())
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the primary job responsibility';
                    Caption = 'Primary Job Resp.';
                    DrillDown = true;

                    trigger OnDrillDown()

                    begin
                        Rec.ShowJobResponsibilityList();
                    end;
                }

            }
        }

        movefirst(PersonalJobDetails; "Job Title")

        modify("Job Title")
        {
            Visible = true;
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
            }
            group(Review)
            {
                ShowCaption = true;
                Caption = 'Review';
                visible = (rec.type = rec.type::Company);
                group(NotInReviewDetails)
                {
                    Visible = not rec."TFB In Review" and (rec."TFB Contact Stage" <> Rec."TFB Contact Stage"::Inactive);
                    ShowCaption = false;
                    field("TFB Review Date - Planned"; Rec."TFB Review Date - Planned")
                    {
                        ApplicationArea = All;
                        Importance = Standard;
                        Caption = 'Next Date Planned';
                        ToolTip = 'Specifies the next date in which a contact should be reviewed';
                        Editable = not Rec."TFB In Review";

                    }

                    group(ReviewHistory)
                    {
                        Visible = Rec."TFB Review Note" <> '';
                        ShowCaption = false;

                        field("TFB Review Date Last Compl."; Rec."TFB Review Date Last Compl.")
                        {
                            ApplicationArea = All;
                            Importance = Standard;
                            Caption = 'Last Date Completed';
                            ToolTip = 'Specifies date the last review was completed';
                            Editable = false;

                        }
                        field("TFB Review Note"; Rec."TFB Review Note")
                        {
                            ApplicationArea = All;
                            Importance = Standard;
                            MultiLine = true;
                            Editable = false;
                            Caption = 'Notes';
                            ToolTip = 'Specifies details about the relationship captured during review';
                        }
                    }
                }

                group(InReviewDetails)
                {
                    Visible = Rec."TFB In Review";
                    ShowCaption = false;
                    field("TFB Review Date Exp. Compl."; Rec."TFB Review Date Exp. Compl.")
                    {
                        ApplicationArea = All;
                        Importance = Standard;
                        Caption = 'Finish By';
                        ToolTip = 'Specifies when planned date for when review will be completed';
                        Editable = Rec."TFB In Review";
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
                field("TFB Default Review Period"; Rec."TFB Default Review Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default review period for next date planned date';
                }
                field("TFB Primary Industry Code"; Rec.GetPrimaryIndustryText())
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the primary industry code';
                    Caption = 'Primary Industry';
                    DrillDown = true;

                    trigger OnDrillDown()

                    begin
                        Rec.ShowIndustryList();
                    end;
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

        addlast(Tasks)
        {
            action(TFBSetToInReview)
            {
                ApplicationArea = All;
                Image = ReviewWorksheet;
                ToolTip = 'Specifies that contact is now in review';
                Caption = 'Initiate Review';
                Enabled = not Rec."TFB In Review";
                Visible = Rec.Type = Rec.Type::Company;
                trigger OnAction()
                var


                begin

                    Rec.InitiateReview();
                    Rec.Modify(false);

                end;
            }

            action(TFBCompleteReview)
            {
                ApplicationArea = All;
                Image = Completed;
                Caption = 'Complete Review';
                ToolTip = 'Initiate wizard to get details for finish of review';
                Enabled = Rec."TFB In Review";
                Visible = Rec.Type = Rec.Type::Company;
                trigger OnAction()

                var

                begin
                    Rec.CompleteReview();
                    Rec.Modify(false);

                end;
            }


        }
        addlast(Category_Process)
        {
            actionref(PTFBSetToInReview; TFBSetToInReview)
            {

            }
            actionref(PTFBCompleteReview; TFBCompleteReview)
            {

            }
        }

    }




}
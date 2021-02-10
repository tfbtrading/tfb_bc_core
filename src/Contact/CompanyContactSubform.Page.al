page 50130 "TFB Company Contacts Subform"
{

    PageType = ListPart;
    SourceTable = Contact;
    Editable = true;

    ModifyAllowed = true;
    DeleteAllowed = true;
    InsertAllowed = false;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;

                    DrillDown = true;

                    trigger OnDrillDown()

                    var

                    begin
                        PAGE.Run(Page::"Contact Card", Rec);
                    end;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = All;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                }

                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }

                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = All;
                }

                field(AssignedRoles; getJobResponsibilities())
                {
                    ApplicationArea = All;
                    Caption = 'Job responsibilities';
                }
            }
        }
    }



    actions
    {
        area(Processing)
        {
            action(New)
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'New Contact';
                Image = New;
                ToolTip = 'Create a new contact for this company.';
                Enabled = rec."No." <> '';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunPageMode = Create;
                RunObject = Page "Contact Card";
                RunPageLink = "Company No." = field("Company No.");
                RunPageView = where(Type = const(Person));

            }
            action("Job Responsibilities")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Job Responsibilities';
                Image = Job;
                ToolTip = 'View or edit the contacts job responsibilities.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Enabled = rec."No." <> '';

                trigger OnAction()
                var
                    ContJobResp: Record "Contact Job Responsibility";
                begin
                    Rec.CheckContactType(Rec.Type::Person);
                    ContJobResp.SetRange("Contact No.", Rec."No.");
                    PAGE.RunModal(PAGE::"Contact Job Responsibilities", ContJobResp);
                end;
            }

            action("Pro&files")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Pro&files';
                Image = Answers;
                ToolTip = 'Open the Profile Questionnaires window.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Enabled = rec."No." <> '';

                trigger OnAction()
                var
                    ProfileManagement: Codeunit ProfileManagement;
                begin
                    ProfileManagement.ShowContactQuestionnaireCard(Rec, '', 0);
                end;
            }
            action(MakePhoneCall)
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Make &Phone Call';
                Image = Calls;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Enabled = rec."No." <> '';

                ToolTip = 'Call the selected contact.';

                trigger OnAction()
                var
                    TAPIManagement: Codeunit TAPIManagement;
                begin
                    TAPIManagement.DialContCustVendBank(DATABASE::Contact, Rec."No.", Rec.GetDefaultPhoneNo, '');
                end;
            }
            action("Create &Interaction")
            {
                AccessByPermission = TableData Attachment = R;
                ApplicationArea = RelationshipMgmt;
                Caption = 'Create &Interaction';
                Image = CreateInteraction;
                Promoted = true;
                PromotedIsBig = true;
                Enabled = rec."No." <> '';
                PromotedOnly = true;
                ToolTip = 'Create an interaction with a specified contact.';

                trigger OnAction()
                begin
                    Rec.CreateInteraction;
                end;
            }
        }
    }



    local procedure getJobResponsibilities(): Text

    var

        Resp: Record "Contact Job Responsibility";
        RespText: TextBuilder;
    begin

        Resp.SetRange("Contact No.", Rec."No.");
        Resp.SetAutoCalcFields("Job Responsibility Description");

        If Resp.FindFirst() then
            repeat begin

                RespText.AppendLine(Resp."Job Responsibility Description");

            end until Resp.Next = 0;

        Exit(RespText.ToText());
    end;
}
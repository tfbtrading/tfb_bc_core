page 50125 "TFB Contact Status List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TFB Contact Status";
    SourceTableView = sorting(SortOrder);
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;
    DelayedInsert = true;
    Caption = 'Contact Status List';


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(SortOrder; Rec.SortOrder)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order field';
                    ShowMandatory = true;

                }
                field(Stage; Rec.Stage)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stage field';
                    showmandatory = true;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Status field';
                    showmandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }

                field(Probability; Rec.Probability)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Probability field';
                }
                field(IncludeInLeads; Rec.IncludeInLeads)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include in Lead Reports field';
                }
                field(NoOfActiveContacts; Rec.NoOfActiveContacts)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many active contacts are in this stage';
                    DrillDown = true;
                    DrillDownPageId = "Contact List";
                }



            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateContacts)
            {
                ApplicationArea = All;
                Caption = 'Update status of contacts';
                Tooltip = 'Updates and corrects default status of contacts';
                Image = Process;

                trigger OnAction()

                var
                    CU: CodeUnit "TFB Contact Mgmt";
                begin

                    CU.UpdateStatusOfContacts();

                end;
            }

        }
    }
}
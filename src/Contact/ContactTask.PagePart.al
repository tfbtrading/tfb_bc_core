/// <summary>
/// Page ContactTaskPagePart (ID 50126).
/// </summary>
page 50126 "TFB Contact Task Subform"
{

    Caption = 'ContactTaskPagePart';
    PageType = ListPart;
    SourceTable = "To-do";
    Editable = false;
    CardPageId = "Task Card";
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }

                field("Opportunity Description"; Rec."Opportunity Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetInProgress)
            {
                ApplicationArea = All;
                Enabled = Rec.Closed = false;
                Caption = 'Set to In-Progress';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Start;

                trigger OnAction()
                begin

                    Rec.Validate(Status, Rec.Status::"In Progress");

                end;
            }
            action(SetComplete)
            {
                ApplicationArea = All;
                Enabled = (Rec.Closed = false) or not (Rec.Status = Rec.Status::"In Progress");
                Caption = 'Set to Completed';
                Promoted = true;
                Image = Completed;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin

                    Rec.Validate(Status, Rec.Status::Completed);
                    Rec.Modify(true);

                end;
            }


        }
    }

}

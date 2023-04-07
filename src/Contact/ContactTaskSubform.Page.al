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
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                }

                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Date; Rec.Date)
                {
                    ToolTip = 'Specifies the value of the Date field';
                }
                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field';
                }

                field("Opportunity Description"; Rec."Opportunity Description")
                {
                    ToolTip = 'Specifies the value of the Opportunity Description field';
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
                Enabled = Rec.Closed = false;
                Caption = 'Set to In-Progress';
         
                Image = Start;
                ToolTip = 'Executes the Set to In-Progress action';

                trigger OnAction()
                begin

                    Rec.Validate(Status, Rec.Status::"In Progress");

                end;
            }
            action(SetComplete)
            {
                Enabled = (Rec.Closed = false) or not (Rec.Status = Rec.Status::"In Progress");
                Caption = 'Set to Completed';
         
                Image = Completed;
     
                ToolTip = 'Executes the Set to Completed action';

                trigger OnAction()
                begin

                    Rec.Validate(Status, Rec.Status::Completed);
                    Rec.Modify(true);

                end;
            }


        }
    }

}

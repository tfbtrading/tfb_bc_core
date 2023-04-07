page 50131 "TFB Active Task List"
{
    Caption = 'Task List';
    CardPageID = "Task Card";
    DataCaptionExpression = 'Active Tasks';
    Editable = false;
    PageType = List;
    SourceTable = "To-do";
    SourceTableView = where(Closed = const(false));
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                ShowCaption = false;
                field("Contact Name"; Rec."Contact Name")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Contact Name';
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the contact to which this task has been assigned.';
                }
                field("Contact Company Name"; Rec."Contact Company Name")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the company for which the contact involved in the task works.';
                }
                field(Date; Rec.Date)
                {
                    Caption = 'Start Date';
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the date when the task should be started. There are certain rules for how dates should be entered found in How to: Enter Dates and Times.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the type of the task.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the description of the task.';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the priority of the task.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the status of the task. There are five options: Not Started, In Progress, Completed, Waiting and Postponed.';
                }

                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the date the task was is due to end or the due date.';
                    Style = Unfavorable;
                    StyleExpr = _Overdue;

                }

                field(Comment; Rec.Comment)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies that a comment has been assigned to the task.';
                }


                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the code of the salesperson assigned to the task.';
                }
                field("Team Code"; Rec."Team Code")
                {
                    Visible = false;
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the code of the team to which the task is assigned.';
                }

                field("Opportunity No."; Rec."Opportunity No.")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the number of the opportunity to which the task is linked.';
                }

            }

        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
            part(ContactStats; "Contact Statistics FactBox")
            {
                Visible = true;
                SubPageLink = "No." = field("Contact No.");
            }
            part(OpportunityStats; "Opportunity Statistics FactBox")
            {
                Visible = Rec."Opportunity No." <> '';
                SubPageLink = "No." = field("Opportunity No.");

            }
        }


    }


    actions
    {
        area(navigation)
        {
            group(Task)
            {
                Caption = 'Task';
                Image = Task;
                action("Co&mment")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mment';
                    Image = ViewComments;
                    RunObject = Page "Rlshp. Mgt. Comment Sheet";
                    RunPageLink = "Table Name" = const("To-do"),
                                  "No." = field("Organizer To-do No."),
                                  "Sub No." = const(0);
                    ToolTip = 'View or add comments.';
                }
                action("Interaction Log E&ntries")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Interaction Log E&ntries';
                    Image = InteractionLog;
                    RunObject = Page "Interaction Log Entries";
                    RunPageLink = "To-do No." = field("Organizer To-do No.");
                    RunPageView = sorting("To-do No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View interaction log entries for the task.';
                }
                action("Postponed &Interactions")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Postponed &Interactions';
                    Image = PostponedInteractions;
                    RunObject = Page "Postponed Interactions";
                    RunPageLink = "To-do No." = field("Organizer To-do No.");
                    RunPageView = sorting("To-do No.");
                    ToolTip = 'View postponed interactions for the task.';
                }
                action("A&ttendee Scheduling")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'A&ttendee Scheduling';
                    Image = ProfileCalender;
                    ToolTip = 'View the status of a scheduled meeting.';

                    trigger OnAction()
                    var
                        Task: Record "To-do";
                    begin
                        Task.Get(Rec."Organizer To-do No.");
                        PAGE.RunModal(PAGE::"Attendee Scheduling", Task);
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
                action("Assign Activities")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Assign Activities';
                    Image = Allocate;
                    ToolTip = 'View all the tasks that have been assigned to salespeople and teams. A task can be organizing meetings, making phone calls, and so on.';

                    trigger OnAction()
                    var
                        TempTask: Record "To-do" temporary;
                    begin
                        TempTask.AssignActivityFromTask(Rec);
                    end;
                }

            }
            action("&Create Task")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = '&Create Task';
                Image = NewToDo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Create a new task.';

                trigger OnAction()
                var
                    TempTask: Record "To-do" temporary;
                begin
                    TempTask.CreateTaskFromTask(Rec);
                end;
            }

        }
    }

    views
    {

        view(Overdue)
        {
            Caption = 'Overdue';
            Filters = where("Ending Date" = filter('<>'''' & <today'));
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("Contact Name", "Contact Company Name");
    end;

    trigger OnAfterGetRecord()
    begin
        ContactNoOnFormat(Format(Rec."Contact No."));
        _Overdue := Today > Rec."Ending Date";
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        RecordsFound := Rec.Find(Which);
        exit(RecordsFound);
    end;

    var
        Cont: Record Contact;
        Contact1: Record Contact;
        Salesperson: Record "Salesperson/Purchaser";
        Campaign: Record Campaign;
        Team: Record Team;
        Opp: Record Opportunity;
        SegHeader: Record "Segment Header";
        RecordsFound: Boolean;
        Text000Msg: Label '(Multiple)';
        Text001Msg: Label 'untitled';
        _Overdue: Boolean;
      
    procedure GetCaption() CaptionStr: Text
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCaption(Rec, CaptionStr, IsHandled);
        if IsHandled then
            exit;

        if Cont.Get(Rec.GetFilter("Contact Company No.")) then begin
            Contact1.Get(Rec.GetFilter("Contact Company No."));
            if Contact1."No." <> Cont."No." then
                CaptionStr := CopyStr(Cont."No." + ' ' + Cont.Name, 1, MaxStrLen(CaptionStr));
        end;
        if Cont.Get(Rec.GetFilter("Contact No.")) then
            CaptionStr := CopyStr(CaptionStr + ' ' + Cont."No." + ' ' + Cont.Name, 1, MaxStrLen(CaptionStr));
        if Salesperson.Get(Rec.GetFilter("Salesperson Code")) then
            CaptionStr := CopyStr(CaptionStr + ' ' + Salesperson.Code + ' ' + Salesperson.Name, 1, MaxStrLen(CaptionStr));
        if Team.Get(Rec.GetFilter("Team Code")) then
            CaptionStr := CopyStr(CaptionStr + ' ' + Team.Code + ' ' + Team.Name, 1, MaxStrLen(CaptionStr));
        if Campaign.Get(Rec.GetFilter("Campaign No.")) then
            CaptionStr := CopyStr(CaptionStr + ' ' + Campaign."No." + ' ' + Campaign.Description, 1, MaxStrLen(CaptionStr));
        if Opp.Get(Rec.GetFilter("Opportunity No.")) then
            CaptionStr := CopyStr(CaptionStr + ' ' + Opp."No." + ' ' + Opp.Description, 1, MaxStrLen(CaptionStr));
        if SegHeader.Get(Rec.GetFilter("Segment No.")) then
            CaptionStr := CopyStr(CaptionStr + ' ' + SegHeader."No." + ' ' + SegHeader.Description, 1, MaxStrLen(CaptionStr));
        if CaptionStr = '' then
            CaptionStr := Text001Msg;
    end;

    local procedure ContactNoOnFormat(Text: Text[1024])
    begin
        if Rec.Type = Rec.Type::Meeting then
            Text := Text000Msg;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCaption(var ToDo: Record "To-do"; var CaptionStr: Text; var Handled: Boolean)
    begin
    end;

}

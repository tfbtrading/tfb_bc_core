pageextension 50132 "TFB Sales Order" extends "Sales Order" //42
{
    layout
    {
        addlast(General)
        {
            field(Tasks; GetTaskStatus())
            {
                ShowCaption = false;
                ApplicationArea = All;
                DrillDown = true;
                ToolTip = 'Opens up a task list';

                trigger OnDrillDown()

                var
                    Todo: Record "To-do";
                    TaskList: Page "Task List";

                begin

                    ToDo.SetRange("TFB Trans. Record ID", Rec.RecordId);
                    ToDo.SetRange("System To-do Type", ToDo."System To-do Type"::Organizer);
                    ToDo.SetRange(Closed, false);

                    If not ToDo.IsEmpty() then begin
                        TaskList.SetTableView(Todo);
                        TaskList.Run();
                    end;

                end;


            }
        }

        modify("External Document No.")
        {
            trigger OnAfterValidate()

            begin
                CheckForDuplicateNotification();
            end;
        }
        addafter("Payment Terms Code")
        {
            field("Customer Price Group"; Rec."Customer Price Group")
            {
                ApplicationArea = All;
                Importance = Promoted;
                ToolTip = 'Specifies customer price group for sals order';
            }
        }
        addlast(General)
        {
            field("TFB Pre-order Exists"; Rec."TFB Pre-order Exists")
            {
                ApplicationArea = All;
                Importance = Promoted;
                ToolTip = 'Specifies that a pre-order exists for sales order';
            }
            field("No. Printed"; Rec."No. Printed")
            {
                ApplicationArea = All;
                Importance = Promoted;
                ToolTip = 'Specifies no. of times document has been printed or emailed';
                Style = Attention;
                StyleExpr = Rec."No. Printed" = 0;
            }
        }

        addafter("Late Order Shipping")
        {
            field("TFB Instructions"; Rec."TFB Instructions")
            {
                MultiLine = True;
                ApplicationArea = All;
                ToolTip = 'Specifies the specific delivery instructions for the sales order';
            }
        }

    }

    actions
    {
        addafter("Print Confirmation")
        {
            action("Send CoA's")
            {
                ApplicationArea = All;
                Image = SendAsPDF;
                Promoted = True;
                PromotedIsBig = true;
                PromotedCategory = Category7;
                ToolTip = 'Send certificates of analysis for sales order if lots are specified';


                trigger OnAction()
                var
                    CommonCU: Codeunit "TFB Common Library";
                begin

                    If Rec."No." <> '' then
                        If CommonCU.CheckAndSendCoA(Rec."No.", false, false, true) then
                            Message('Sent COA(s) to customer')
                        else
                            Message('No Line Items have Lots Specified or COA files attached');

                end;
            }
        }
        addfirst("F&unctions")
        {
            action("Create &Task")
            {
                AccessByPermission = TableData Contact = R;
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Category8;
                Caption = 'Create &Task';
                Image = NewToDo;
                ToolTip = 'Create a new marketing task for the contact.';

                trigger OnAction()
                begin
                    Rec.CreateTask;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()

    begin
        clear(DuplicateNotification);
    end;

    local procedure CheckForDuplicateNotification()

    var
        DuplicateSystemID: Guid;
    begin

        If Rec.CheckDuplicateExtDocNo(DuplicateSystemID) then begin
            DuplicateNotification.Message('There is an existing ongoing sales order with the same External Doc No');
            DuplicateNotification.Scope(NotificationScope::LocalScope);
            DuplicateNotification.SetData('SystemId', DuplicateSystemID);
            DuplicateNotification.AddAction('Open Existing', Codeunit::"TFB Sales Mgmt", 'OpenExistingSalesOrder');
            DuplicateNotification.Send();
        end
        else
            If not IsNullGuid(DuplicateNotification.Id) then
                DuplicateNotification.Recall();

    end;

    var
        DuplicateNotification: Notification;


    local procedure GetTaskStatus(): Text

    var
        ToDo: Record "To-do";

    begin

        ToDo.SetRange("TFB Trans. Record ID", Rec.RecordId);
        ToDo.SetRange("System To-do Type", ToDo."System To-do Type"::Organizer);
        ToDo.SetRange(Closed, false);

        If ToDo.Count() > 0 then
            Exit(StrSubstNo('📋 (%1)', ToDo.Count()))
        else
            Exit('');

    end;

}
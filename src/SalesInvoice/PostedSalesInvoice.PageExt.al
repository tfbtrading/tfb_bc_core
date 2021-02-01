pageextension 50191 "TFB Posted Sales Invoice" extends "Posted Sales Invoice"
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
        addbefore("External Document No.")
        {
            group(Brokerage)
            {
                ShowCaption = false;
                Visible = Rec."TFB Brokerage Shipment" <> '';

                field("TFB Brokerage Shipment"; Rec."TFB Brokerage Shipment")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies related brokerage shipment';

                    trigger OnDrillDown()

                    var
                        BrokerageRec: Record "TFB Brokerage Shipment";
                        BrokeragePage: Page "TFB Brokerage Shipment";

                    begin
                        If Rec."TFB Brokerage Shipment" <> '' then
                            If BrokerageRec.Get(Rec."TFB Brokerage Shipment") then begin

                                BrokeragePage.SetRecord(BrokerageRec);
                                BrokeragePage.Run();
                            end;

                    end;
                }
            }
        }
        addlast(factboxes)
        {
            part(PODInfo; "TFB Sales POD FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
                Caption = 'POD Info';
            }
        }
    }

    actions
    {
        addfirst("F&unctions")
        {
            action("Create &Task")
            {
                AccessByPermission = TableData Contact = R;
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Category4;
                Caption = 'Create &Task';
                Image = NewToDo;
                ToolTip = 'Create a new relationship task for the contact.';

                trigger OnAction()
                begin
                    Rec.CreateTask;
                end;
            }
        }
        addlast(Processing)
        {
            action(TFBSendPODRequest)
            {
                Caption = 'Send POD Request';
                ApplicationArea = All;
                Image = SendMail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Send a POD request to warehouse or supplier depending on how invoice was fulfilled';

                trigger OnAction()
                var
                    PurchInvCU: CodeUnit "TFB Purch. Inv. Mgmt";
                begin
                    PurchInvCU.SendPODRequestForInvoice(Rec."No.");
                end;

            }
        }
    }

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
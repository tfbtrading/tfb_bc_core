pageextension 50121 "TFB Purchase Order" extends "Purchase Order"
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
        modify("Creditor No.")
        {
            Visible = false;
        }
        modify("On Hold")
        {
            Visible = false;
        }

        modify("Requested Receipt Date") { Visible = true; Importance = Promoted; }

        modify("Currency Code")
        {
            trigger OnAfterValidate()

            begin
                CheckIfImport();
            end;
        }
        addafter(Status)
        {
            field("No. Printed"; Rec."No. Printed")
            {
                Visible = true;
                ApplicationArea = All;
                Caption = 'No. Printed or Emailed';
                ToolTip = 'Specifies no. of printed or emailed documents';
            }
        }
        addafter("Vendor Order No.")
        {
            field("TFB Manual Confirmation"; Rec."TFB Manual Confirmation")
            {
                Visible = true;
                ApplicationArea = all;
                Caption = 'Order Confirmed';
                ToolTip = 'Specifies whether the order has been confirmed';
            }
        }



        addlast("Shipping and Payment")
        {
            group("Container Details")
            {
                Visible = ImportOrder;

                field("TFB Origin Port"; Rec."TFB Origin Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies port from which order is shipped';
                }
                field("TFB Est. Sailing Date"; Rec."TFB Est. Sailing Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies est. sailing date of container';
                }
                field("TFB Destination Port"; Rec."TFB Destination Port")
                {
                    ApplicationArea = All;
                    Caption = 'Destination Port';
                    ToolTip = 'Specifies port of arrival for container';
                }
                field("TFB Container"; "ContainerNo")
                {
                    ApplicationArea = All;
                    Enabled = true;
                    Editable = false;
                    Caption = 'Container Assigned';
                    ToolTip = 'Specifies the container number if it exists';
                }
            }
        }

        addlast("Shipping and Payment")
        {

            group("Quarantine Details")
            {

                Visible = Rec."TFB Container Entry Exists";

                field("TFB X-Ray Hold"; Rec."TFB X-Ray Hold")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if purchase is subject to x-ray hold';
                }
                field("TFB Fumigation Required"; Rec."TFB Fumigation Required")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies if purchase is subject to fumigation';
                }
                field("TFB Heat Treatment Required"; Rec."TFB Heat Treatment Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if purchase is subject to heat treatment';
                }

                field("TFB Inspection Required"; Rec."TFB Inspection Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if purchase is subject to inspection';
                }
                field("TFB IFIP Required"; Rec."TFB IFIP Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if purchase is subject to IFIP inspection';
                }


            }
        }
        addafter("Vendor Exchange Rate (ACY)")
        {
            field("TFB Instructions"; Rec."TFB Instructions")
            {
                ApplicationArea = All;
                Enabled = True;
                Editable = True;
                MultiLine = True;
                ToolTip = 'Specifies any special instructions for the purchase order';
            }
            field("TFB Delivery SLA"; Rec."TFB Delivery SLA")
            {
                ApplicationArea = All;
                Enabled = True;
                Editable = True;
                MultiLine = True;
                ToolTip = 'Specifies if a delivery SLA exists for this purchase order';
            }
            group(QualityReq)
            {
                ShowCaption = true;
                Visible = Rec."Sell-to Customer No." <> '';
                Caption = 'Customer Quality Requirements';

                field("TFB Customer CoA Req"; isCoARequiredByCustomer())
                {
                    Enabled = true;
                    Editable = false;
                    Caption = 'Customer Requires CoA';
                    ToolTip = 'Specifies if a customer has elected to received a CoA';
                    Style = Strong;
                    StyleExpr = true;
                    ApplicationArea = All;
                }
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

                Caption = 'Create &Task';
                Image = NewToDo;
                ToolTip = 'Create a new marketing task for the contact.';

                trigger OnAction()
                begin
                    Rec.CreateTask();
                end;
            }
        }
        addlast(Navigation)
        {
            action("TFB&ContainerEntry")
            {
                ApplicationArea = All;
                Enabled = Rec."Buy-from Country/Region Code" <> 'AU';
                Caption = 'Inbound Shipment';
                Image = CreateMovement;
                ToolTip = 'Opens or creates a new container entry';

                trigger OnAction()
                var
                    ContainerEntry: Record "TFB Container Entry";
                    ContainerEntryPage: Page "TFB Container Entry";


                begin
                    //Check if an entry exists for this purchase order
                    ContainerEntry.SetRange("Order Reference", Rec."No.");
                    ContainerEntry.SetRange("Vendor No.", Rec."Buy-from Vendor No.");
                    ContainerEntry.SetRange(Type, ContainerEntry.Type::PurchaseOrder);

                    If ContainerEntry.FindFirst() then begin
                        ContainerEntryPage.SetRecord(ContainerEntry);
                        ContainerEntryPage.Run()
                    end
                    else begin
                        ContainerEntry.Init();
                        ContainerEntry."No." := '';
                        ContainerEntry.Insert(true);
                        ContainerEntry.Validate(Type, ContainerEntry.Type::PurchaseOrder);
                        ContainerEntry.Validate("Vendor No.", Rec."Buy-from Vendor No.");
                        ContainerEntry.Validate("Order Reference", Rec."No.");
                        ContainerEntry.Modify(true);

                        ContainerEntryPage.SetRecord(ContainerEntry);
                        ContainerEntryPage.Run();

                    end;



                end;
            }
        }

        addlast(Category_Process)
        {
            actionref(ActionRefName; "TFB&ContainerEntry")
            {

            }
        }
    }

    trigger OnAfterGetRecord()

    var
        ContainerEntry: record "TFB Container Entry";

    begin
        ContainerEntry.SetRange("Order Reference", Rec."No.");
        If ContainerEntry.FindFirst() then
            ContainerNo := ContainerEntry."Container No.";
        CheckIfImport();
        Rec.CalcFields("TFB Container Entry Exists");
    end;

    local procedure isCoARequiredByCustomer(): Boolean

    var
        Customer: Record Customer;

    begin

        If Customer.get(Rec."Sell-to Customer No.") then
            Exit(Customer."TFB CoA Required")
        else
            Exit(False);

    end;

    local procedure CheckIfImport()

    begin
        If (Rec."Currency Code" <> '') or (Rec."Buy-from Country/Region Code" <> 'AU') then
            ImportOrder := true else
            ImportOrder := false;
    end;

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





    var
        ContainerNo: text[20];
        ImportOrder: Boolean;


}
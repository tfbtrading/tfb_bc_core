pageextension 50108 "TFB Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addlast(General)
        {

            group(ItemChargeAssignGroup)
            {
                ShowCaption = false;
                Visible = _VendorCanChargeAssignment;
                field("TFB Charge Assignment"; Rec."TFB Charge Assignment")
                {
                    ToolTip = 'Specifies shortcut to be copied to lines at a header level';
                    Editable = true;
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = _AssigmentIsValid;
                    Importance = Standard;

                    trigger OnValidate()

                    begin
                        CheckIfAssignmentIsValid();
                    end;

                }
            }

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
        addafter(Status)

        {

            field(TFBDataCopiedFromIC; DataCopiedFromIC)
            {
                ShowCaption = false;
                Caption = 'Copied from IC';
                ApplicationArea = All;
                Editable = false;
                StyleExpr = true;
                Style = None;
                Width = 2;
                ToolTip = 'Specifies if data is copied from incoming document';

            }

        }

        addlast(factboxes)
        {
            part(LineSource; "TFB Purch. Inv. Line Factbox")
            {
                ApplicationArea = All;
                Provider = PurchLines;
                SubPageLink = "Document No." = field("Document No."), "Line No." = field("Line No.");
                UpdatePropagation = SubPart;
                Caption = 'Purchase Line Source';

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

        addafter(CopyDocument)
        {
            action(TFBCopyFromInboundDoc)
            {
                Caption = 'Copy From Inbound Document';
                Enabled = InboundExists;
                Image = CopyFromTask;

                ApplicationArea = All;
                ToolTip = 'Copies data that is specifies on incoming document to purchase invoice';

                trigger OnAction()


                begin

                    CopyDataFromInboundDocument();

                end;


            }

            action(TFBApplyToken)
            {
                Caption = 'Apply Header Charge Assignment';
                Enabled = _AssigmentIsValid and _VendorCanChargeAssignment;
                Image = ApplyEntries;

                ApplicationArea = All;
                ToolTip = 'Applies header level token automatically';

                trigger OnAction()

                var
                    Line: Record "Purchase Line";
                    PurchInvMgmt: CodeUnit "TFB Purch. Inv. Mgmt";

                begin

                    Line.SetRange("Document No.", Rec."No.");
                    Line.SetRange("Document Type", Rec."Document Type");

                    If Line.Findset(true) then
                        repeat
                            If not Line.AssignedItemCharge() then
                                PurchInvMgmt.CheckAndRetrieveAssignmentLines(Line, true);
                        until Rec.Next() < 1;
                end;



            }
        }
        addafter(Category_Prepare)

        {
            actionref(TFBCopyFromInboundDoc_Promoted; TFBCopyFromInboundDoc)
            {

            }
            actionref(TFBApplyToken_Promoted; TFBApplyToken)
            {

            }
        }
    }

    trigger OnAfterGetRecord()

    var
        Vendor: Record Vendor;

    begin
        If Rec."Incoming Document Entry No." > 0 then
            InboundExists := true
        else
            InboundExists := false;

        _VendorCanChargeAssignment := false;

        if Vendor.Get(Rec."Buy-from Vendor No.") then
            If Vendor."TFB Vendor Type" = Enum::"TFB Vendor Type"::SUPPLYCHAIN then
                _VendorCanChargeAssignment := true;
    end;

    local procedure CopyDataFromInboundDocument()
    var
        ICDoc: Record "Incoming Document";
        DataChanged: Boolean;

    begin
        If InboundExists then
            If ICDoc.Get(Rec."Incoming Document Entry No.") then
                If ICDOc."OCR Status" = ICDoc."OCR Status"::Success then begin

                    If ICDoc."Vendor Invoice No." <> '' then
                        Rec.Validate("Vendor Invoice No.", ICDOc."Vendor Invoice No.");

                    If ICDoc."Document Date" > 0D then begin
                        Rec.Validate("Posting Date", ICDoc."Document Date");
                        Rec.Validate("Document Date", ICDoc."Document Date");
                    end;
                    If ICDoc."Due Date" > 0D then
                        if Rec."Due Date" <> ICDoc."Due Date" then
                            If Dialog.Confirm('Do you want to override current date %1, with incoming doc date %2.', false, Rec."Due Date", ICDoc."Due Date") then
                                Rec."Due Date" := ICDOc."Due Date";

                    DataChanged := true;
                end;

        If DataChanged then
            DataCopiedFromIC := '⚡'
        else
            DataCopiedFromIC := '';
    end;

    var
        InboundExists, _VendorCanChargeAssignment, _AssigmentIsValid : Boolean;
        DataCopiedFromIC: Text;



    local procedure CheckIfAssignmentIsValid()

    var
        PurchInvCU: Codeunit "TFB Purch. Inv. Mgmt";
        TokenClass: Enum "TFB Assignment Class";
        Reference: Text[100];
        Result: Boolean;

    begin
        _AssigmentIsValid := false;
        Clear(Result);

        Reference := PurchInvCU.ExtractReference(Rec."TFB Charge Assignment", TokenClass);
        If Reference <> '' then
            case TokenClass of
                TokenClass::"Purchase Order":
                    _AssigmentIsValid := PurchInvCU.IsPOTokenValid(Reference);
                TokenClass::"Inbound Container":
                    _AssigmentIsValid := PurchInvCU.isCntTokenValid(Reference);

            end;
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
}
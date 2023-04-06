pageextension 50165 "TFB Pstd Purchase Invoice" extends "Posted Purchase Invoice"
{
    DataCaptionExpression = Rec."Vendor Invoice No.";


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
        modify("Vendor Invoice No.")
        {
            Style = Strong;
            StyleExpr = (Rec."Vendor Invoice No." <> '') or ((Rec."TFB Orig. External Doc. No." <> '') or (Rec."Vendor Invoice No." <> '')) or (Rec."TFB Orig. External Doc. No." = '');

        }
        addafter("Due Date")
        {
            field(ExpectedDateText; ExpectedDateText)
            {
                ApplicationArea = All;
                Style = Unfavorable;
                StyleExpr = IsExpectedDatePastDue;
                ToolTip = 'Add date and notes';
                Caption = 'Expected Date';
                Editable = false;
                DrillDown = true;
                trigger OnDrillDown()

                var
                    TempPurchInvHeader: Record "Purch. Inv. Header" temporary;
                    VendLedgerEntry: Record "Vendor Ledger Entry";
                    Vendor: Record Vendor;
                    CodeUnit: CodeUnit "TFB Pstd. Purch Inv. Hdr. Edit";
                    AddPaymentNote: Page "TFB Payment Note";
                begin

                    if not Rec.Closed then begin
                        Vendor.Get(Rec."Buy-from Vendor No.");
                        AddPaymentNote.SetupVendorInfo(Vendor, Rec."TFB Expected Payment Note", Rec."TFB Expected Payment Date", Rec."TFB Expected Note TimeStamp");
                        TempPurchInvHeader := Rec;
                        If AddPaymentNote.RunModal() = Action::OK then begin
                            TempPurchInvHeader."TFB Expected Payment Note" := AddPaymentNote.GetExpectedPaymentNote();
                            TempPurchInvHeader."TFB Expected Payment Date" := AddPaymentNote.GetExpectedPaymentDate();
                            TempPurchInvHeader."Due Date" := AddPaymentNote.GetExpectedPaymentDate();
                            CodeUnit.SetScenario(Enum::"TFB Pstd. SInv.-Edit Scen."::PaymentNote);
                            CodeUnit.Run(TempPurchInvHeader);

                            If AddPaymentNote.GetIsCorrection() then begin
                                VendLedgerEntry.Get(TempPurchInvHeader."Vendor Ledger Entry No.");
                                VendLedgerEntry.Validate("Due Date", AddPaymentNote.GetExpectedPaymentDate());
                                VendLedgerEntry.Modify(false);
                            end;
                        end

                    end

                end;
            }
        }

        addafter("Vendor Invoice No.")
        {
            group(CorrectedExternalDocNo)
            {
                Visible = (Rec."TFB Orig. External Doc. No." <> '') or ((Rec."Vendor Invoice No." <> '') and (Rec."TFB Orig. External Doc. No." = ''));
                ShowCaption = false;

                field("TFB Orig. External Doc. No."; Rec."TFB Orig. External Doc. No.")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = true;
                    ToolTip = 'Original external document number prior to being updated';
                    Editable = false;
                }
            }
        }

        addafter("Due Date")
        {
            field(TFBDueDate; _DueDate)
            {
                Visible = DueDateIsDifferent;
                Caption = 'Modified due date';
                Style = Strong;
                ToolTip = 'Indicates if the due date is different on the actual vendor record';
                Importance = Promoted;
                ApplicationArea = All;
            }

        }

    }

    actions
    {
        addfirst("Actions")
        {
            action("Create &Task")
            {
                AccessByPermission = TableData Contact = R;
                ApplicationArea = Basic, Suite;

                Caption = 'Create &Task';
                Image = NewToDo;
                ToolTip = 'Create a new relationship task for the contact.';

                trigger OnAction()
                begin
                    Rec.CreateTask();
                end;
            }
        }
        addlast(processing)
        {
            action(TFBCorrectExternalDocNo)
            {
                Caption = 'Update Invoice No.';
                ApplicationArea = All;
                Image = UpdateDescription;

                ToolTip = 'Handle scenario when vendor invoice number was incorrectly specified without reissuing doc';

                trigger OnAction()

                var
                    TempPurchaseInvoiceHeader: Record "Purch. Inv. Header" temporary;
                    Vendor: Record Vendor;
                    CodeUnit: CodeUnit "TFB Pstd. Purch Inv. Hdr. Edit";
                    CorrectExtDocNo: Page "TFB Correct Ext. Doc. No.";
                begin

                    if not Rec.Closed then begin
                        Vendor.Get(Rec."Buy-from Vendor No.");
                        CorrectExtDocNo.SetupVendorInfo(Vendor, Rec."Vendor Invoice No.");
                        TempPurchaseInvoiceHeader := Rec;
                        If CorrectExtDocNo.RunModal() = Action::OK then begin
                            TempPurchaseInvoiceHeader."TFB Orig. External Doc. No." := Rec."Vendor Invoice No.";
                            TempPurchaseInvoiceHeader."Vendor Invoice No." := CorrectExtDocNo.GetExternalDocNo();
                            CodeUnit.SetScenario(Enum::"TFB Pstd. SInv.-Edit Scen."::ExternalDocumentNo);
                            CodeUnit.Run(TempPurchaseInvoiceHeader);
                        end

                    end

                end;
            }


        }
        modify("Update Document")
        {
            Caption = 'Update Other Information';
        }
        addlast(Category_Process)
        {
            group(TFBUpdate)
            {
                Caption = 'Update Document';
                ShowAs = SplitButton;

                actionref(TFBCorrectExternalDocNo_Ref; TFBCorrectExternalDocNo)
                {

                }


            }
        }
        moveafter(TFBCorrectExternalDocNo_Ref; "Update Document_Promoted")

    }

    var

        DueDateIsDifferent: Boolean;
        _DueDate: Date;
        _RemainingAmt: Decimal;


    trigger OnAfterGetRecord()

    begin

        Clear(_DueDate);
        Clear(_RemainingAmt);

        If GetLedgerEntryDetail(_DueDate, _RemainingAmt) then
            If _DueDate <> Rec."Due Date" then
                DueDateIsDifferent := true else
                DueDateIsDifferent := false;

        SetExpectedDateStatus();
    end;

    local procedure SetExpectedDateStatus()

    begin
        Clear(ExpectedDateText);

        If (Rec."Due Date" < WorkDate()) and (not Rec.Closed) then
            IsPastDue := true
        else
            IsPastDue := false;

        If not Rec.Closed then begin
            If Rec."TFB Expected Payment Date" > 0D then
                ExpectedDateText := format(Rec."TFB Expected Payment Date")
            else
                if Rec."TFB Expected Payment Note" = '' then
                    ExpectedDateText := '➕'
                else
                    ExpectedDateText := '📄';
        end
        else
            ExpectedDateText := '';

        If (Rec."TFB Expected Payment Date" < WorkDate()) and (not Rec.Closed) and (Rec."TFB Expected Payment Date" > 0D) then
            IsExpectedDatePastDue := true
        else
            IsExpectedDatePastDue := false;
    end;

    local procedure GetLedgerEntryDetail(var DueDate: Date; var RemainingAmt: Decimal): Boolean

    var
        LedgerEntry: Record "Vendor Ledger Entry";

    begin

        LedgerEntry.SetRange("Document No.", Rec."No.");
        LedgerEntry.SetRange("Document Type", LedgerEntry."Document Type"::Invoice);
        LedgerEntry.SetRange(Reversed, false);
        If not LedgerEntry.FindFirst() then
            Exit(false);
        LedgerEntry.CalcFields("Remaining Amount");
        DueDate := LedgerEntry."Due Date";
        RemainingAmt := LedgerEntry."Remaining Amount";

        Exit(true);
    end;

    var
        IsExpectedDatePastDue: Boolean;
        IsPastDue: Boolean;
        ExpectedDateText: Text;

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
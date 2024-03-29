/// <summary>
/// PageExtension TFB Posted Sales Invoice (ID 50191) extends Record Posted Sales Invoice.
/// </summary>
pageextension 50191 "TFB Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {

        modify("External Document No.")
        {
            Style = Strong;
            StyleExpr = (Rec."TFB Orig. External Doc. No." <> '') or ((Rec."External Document No." <> '') and (Rec."TFB Orig. External Doc. No." = ''));

        }
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

                    if not ToDo.IsEmpty() then begin
                        TaskList.SetTableView(Todo);
                        TaskList.Run();
                    end;

                end;


            }
        }
        addbefore("External Document No.")
        {
            group(PrepaymentDetails)
            {
                Visible = Rec."Prepayment Invoice";
                field("Prepayment Order No."; Rec."Prepayment Order No.")
                {
                    ApplicationArea = All;
                    Caption = 'Prepayment for Order No.';
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the preoayment order no.';
                }
            }
        }

        addafter("External Document No.")
        {
            group(CorrectedExternalDocNo)
            {
                Visible = (Rec."TFB Orig. External Doc. No." <> '') or ((Rec."External Document No." <> '') and (Rec."TFB Orig. External Doc. No." = ''));
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

        addbefore("Payment Terms Code")
        {
            field("Customer Price Group"; Rec."Customer Price Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the customer price group that was used at the header level';

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
                        if Rec."TFB Brokerage Shipment" <> '' then
                            if BrokerageRec.Get(Rec."TFB Brokerage Shipment") then begin

                                BrokeragePage.SetRecord(BrokerageRec);
                                BrokeragePage.Run();
                            end;

                    end;
                }
            }
        }


        modify("Due Date")
        {
            Style = Unfavorable;
            StyleExpr = IsPastDue;
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
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                    Customer: Record Customer;
                    TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
                    CodeUnit: CodeUnit "TFB Pstd. Sales Inv. Hdr. Edit";
                    AddPaymentNote: Page "TFB Payment Note";
                begin

                    if not Rec.Closed then begin
                        Customer.Get(Rec."Sell-to Customer No.");
                        AddPaymentNote.SetupCustomerInfo(Customer, Rec."TFB Expected Payment Note", Rec."TFB Expected Payment Date", Rec."TFB Expected Note TimeStamp");
                        TempSalesInvoiceHeader := Rec;
                        if AddPaymentNote.RunModal() = Action::OK then begin
                            TempSalesInvoiceHeader."TFB Expected Payment Note" := AddPaymentNote.GetExpectedPaymentNote();
                            TempSalesInvoiceHeader."TFB Expected Payment Date" := AddPaymentNote.GetExpectedPaymentDate();
                            TempSalesInvoiceHeader."Due Date" := AddPaymentNote.GetExpectedPaymentDate();
                            CodeUnit.SetScenario(Enum::"TFB Pstd. SInv.-Edit Scen."::PaymentNote);
                            CodeUnit.Run(TempSalesInvoiceHeader);

                            if AddPaymentNote.GetIsCorrection() then begin
                                CustLedgerEntry.Get(TempSalesInvoiceHeader."Cust. Ledger Entry No.");
                                CustLedgerEntry.Validate("Due Date", AddPaymentNote.GetExpectedPaymentDate());
                                CustLedgerEntry.Modify(false);
                            end;
                        end

                    end

                end;
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

                Caption = 'Create &Task';
                Image = NewToDo;
                ToolTip = 'Create a new relationship task for the contact.';

                trigger OnAction()
                begin
                    Rec.CreateTask();
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

                ToolTip = 'Send a POD request to warehouse or supplier depending on how invoice was fulfilled';

                trigger OnAction()
                var
                    PurchInvCU: CodeUnit "TFB Purch. Inv. Mgmt";
                begin
                    PurchInvCU.SendPODRequestForInvoice(Rec."No.");
                end;

            }

            action(TFBCorrectExternalDocNo)
            {
                Caption = 'Update External Document No.';
                ApplicationArea = All;
                Image = UpdateDescription;

                ToolTip = 'Handle scenario when customer has changed their purchase order reference without reissuing doc';

                trigger OnAction()

                var
                    Customer: Record Customer;
                    TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
                    CodeUnit: CodeUnit "TFB Pstd. Sales Inv. Hdr. Edit";
                    CorrectExtDocNo: Page "TFB Correct Ext. Doc. No.";
                begin

                    if not Rec.Closed then begin
                        Customer.Get(Rec."Sell-to Customer No.");
                        CorrectExtDocNo.SetupCustomerInfo(Customer, Rec."External Document No.");
                        TempSalesInvoiceHeader := Rec;
                        if CorrectExtDocNo.RunModal() = Action::OK then begin
                            TempSalesInvoiceHeader."TFB Orig. External Doc. No." := Rec."External Document No.";
                            TempSalesInvoiceHeader."External Document No." := CorrectExtDocNo.GetExternalDocNo();
                            CodeUnit.SetScenario(Enum::"TFB Pstd. SInv.-Edit Scen."::ExternalDocumentNo);
                            CodeUnit.Run(TempSalesInvoiceHeader);
                        end

                    end

                end;
            }
        }

        addlast(Category_Category6)
        {


            actionref(TFBSendPODRequest_Promoted; TFBSendPODRequest)
            {

            }
        }

        addafter(Category_Category5)
        {
            group(Category_TFBUpdate)
            {
                Caption = 'Update';
                ShowAs = SplitButton;

                actionref(TFBCorrectExternalDocNo_Promoted; TFBCorrectExternalDocNo)
                {

                }
            }
        }
        moveafter(TFBCorrectExternalDocNo_Promoted; ChangePaymentService_Promoted)
    }





    trigger OnAfterGetRecord()

    begin
        SetExpectedDateStatus();
    end;

    local procedure SetExpectedDateStatus()

    begin
        Clear(ExpectedDateText);

        if (Rec."Due Date" < WorkDate()) and (not Rec.Closed) then
            IsPastDue := true
        else
            IsPastDue := false;

        if not Rec.Closed then begin
            if Rec."TFB Expected Payment Date" > 0D then
                ExpectedDateText := format(Rec."TFB Expected Payment Date")
            else
                if Rec."TFB Expected Payment Note" = '' then
                    ExpectedDateText := '➕'
                else
                    ExpectedDateText := '📄';
        end
        else
            ExpectedDateText := '';

        if (Rec."TFB Expected Payment Date" < WorkDate()) and (not Rec.Closed) and (Rec."TFB Expected Payment Date" > 0D) then
            IsExpectedDatePastDue := true
        else
            IsExpectedDatePastDue := false;
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

        if ToDo.Count() > 0 then
            exit(StrSubstNo('📋 (%1)', ToDo.Count()))
        else
            exit('');

    end;
}
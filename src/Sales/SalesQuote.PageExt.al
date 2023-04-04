pageextension 50113 "TFB Sales Quote" extends "Sales Quote" //41
{
    layout
    {
        addbefore("Location Code")
        {
            field("TFBCustomer Price Group"; Rec."Customer Price Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the customers price group';
            }
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

                    If not ToDo.IsEmpty() then begin
                        TaskList.SetTableView(Todo);
                        TaskList.Run();
                    end;

                end;


            }
            field("TFB Group Purchase"; Rec."TFB Group Purchase")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the quote is part of a group purchase';
                Importance = Promoted;
            }
            group(GroupPurchase)
            {
                ShowCaption = false;

                Visible = Rec."TFB Group Purchase";

                field("TFB Group Purchase Quote No."; Rec."TFB Group Purchase Quote No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the related purchase quote';
                    Importance = Standard;

                }
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


    }



    actions
    {
        addafter(Customer)
        {
            action(VendorQuote)
            {
                Enabled = (Rec."TFB Group Purchase Quote No." <> '');
                ApplicationArea = All;
                ToolTip = 'Opens related purchase quote';
                Image = Quote;
                RunObject = Page "Purchase Quote";
                RunPageLink = "No." = field("TFB Group Purchase Quote No."), "Document Type" = const(Quote);
                Caption = 'Vendor group quote';

            }
        }
        addafter(Statistics)
        {
            action("TFBEstimatedProfitability")
            {
                Caption = 'Profitability';
                Image = AnalysisView;
                ToolTip = 'Review line item profitability analysis';
                ApplicationArea = All;

                trigger OnAction()

                var
                    SalesLine: Record "Sales Line";

                begin
                    SalesLine.SetRange("Document Type", Rec."Document Type");
                    SalesLine.SetRange("Document No.", Rec."No.");
                    SalesLine.SetRange(Type, SalesLine.type::Item);

                    If Page.RunModal(Page::"TFB Gross Profit Sales Lines", SalesLine) = Action::OK then
                        message('Did something');

                end;

            }
        }

        addafter(Statistics_Promoted)
        {
            actionref(PTFBEstiatedProfitability; TFBEstimatedProfitability)
            {

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
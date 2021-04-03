pageextension 50187 "TFB Opportunity Stat. FactBox" extends "Opportunity Statistics FactBox"
{
    layout
    {
        addafter("No. of Interactions")
        {
            field("TFB No. Of Open Tasks"; Rec."TFB No. Of Open Tasks")
            {
                ApplicationArea = All;
                Visible = true;
                ToolTip = 'Shows the total number of open tasks';
                DrillDownPageId = "Task List";
            }
        }
        addafter("Current Sales Cycle Stage")
        {
            field(TFBActiveStage; GetActiveStageDetails())
            {
                ApplicationArea = All;
                Visible = true;
                ToolTip = 'Specifies details about the current stage';
                Caption = 'Further details';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()

    begin

    end;

    local procedure GetActiveStageDetails(): Text

    var
        OppEntry: Record "Opportunity Entry";

    begin

        OppEntry.Reset();

        OppEntry.SetRange(Active, true);
        OppEntry.SetRange("Opportunity No.", Rec."No.");

        if OppEntry.FindFirst() then
            Exit(StrSubstNo('Updated to %1 on %2', OppEntry."Sales Cycle Stage Description", OppEntry."Date of Change"));

    end;

}
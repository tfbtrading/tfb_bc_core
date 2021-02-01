pageextension 50187 "TFB Opp. Stat. FactBox" extends "Opportunity Statistics FactBox"
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
    }

    actions
    {
        // Add changes to page actions here
    }


}
pageextension 50222 "TFB Segment Subform" extends "Segment Subform"
{
    layout
    {
        modify("Contact No.")
        {
            DrillDownPageId = "Contact Card";
            trigger OnDrillDown()
            var
                Contact: record contact;
                PageOpen: CodeUnit "Page Management";
            begin
                Contact.Get(Rec."Contact No.");
                PageOpen.PageRun(Rec)
            end;
        }
    }

    actions
    {
        addlast(Line)
        {
            action(View)
            {
                ApplicationArea = All;
                Scope = Repeater;
                Image = View;
                ToolTip = 'View the current contact';
                RunObject = Page "Contact Card";
                RunPageLink = "No." = field("Contact No.");
                RunPageMode = View;

            }
        }
    }



}
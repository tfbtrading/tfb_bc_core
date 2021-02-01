pageextension 50181 "TFB Contact Statistics Factbox" extends "Contact Statistics FactBox"
{
    layout
    {
        addlast(General)
        {
            field("Date of Last Interaction"; Rec."Date of Last Interaction")
            {
                ApplicationArea = RelationshipMgmt;
                ToolTip = 'Shows the date of last interaction';
            }
            field("Last Date Attempted"; Rec."Last Date Attempted")
            {
                ApplicationArea = RelationshipMgmt;
                ToolTip = 'Specifies the date contact was last attempted unsuccessfully';
            }
            field("No. of Interactions"; Rec."No. of Interactions")
            {
                ApplicationArea = RelationshipMgmt;
                ToolTip = 'Shows the total number of interactions with the customer';
            }
            field("TFB No. Of Tasks"; Rec."TFB No. Of Tasks")
            {
                ApplicationArea = RelationshipMgmt;
                ToolTip = 'Shows the total number of tasks related to this contact';
                Visible = true;
            }

        }
        modify("Cost (LCY)")
        {
            Visible = false;
        }
        modify("Duration (Min.)")
        {
            Visible = false;
        }
        addfirst(Segmentation)
        {
            group(Individual)
            {
                ShowCaption = false;
                Visible = Rec.Type = Rec.Type::Person;
            }
        }
        movefirst(Individual; "No. of Job Responsibilities")
    }


}
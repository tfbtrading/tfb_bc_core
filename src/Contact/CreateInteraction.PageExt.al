pageextension 50179 "TFB Create Interaction" extends "Create Interaction"
{
    layout
    {
        addafter(Description)
        {
            field("TFB Further Details";Rec."TFB Further Details")
            {
                ApplicationArea=All;
                MultiLine = true;
                ToolTip = 'Specifies any further details in relation to the interaction';
            }
        }
        modify("Language Code")
        {
            Visible=false;
        }
        modify("Cost (LCY)")
        {
            Visible=false;
        }
    }
    
    actions
    {
        // Add changes to page actions here
    }
    
   
}
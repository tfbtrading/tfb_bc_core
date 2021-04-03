page 50139 "TFB Generic Item Segment Tags"
{
    Caption = 'Selected Market Segments';
    PageType = ListPart;
    SourceTable = "TFB Generic Item Market Rel.";
    InsertAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Market Segment Title"; Rec."Market Segment Title")
                {
                    ShowCaption = false;
                    ApplicationArea = All;
                    Editable = false;
                    DrillDown = false;
                    lookup = false;

                }
            }
        }


    }

}

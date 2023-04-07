page 50139 "TFB Generic Item Segment Tags"
{
    Caption = 'Selected Market Segments';

    PageType = ListPart;
    SourceTable = "TFB Generic Item Market Rel.";
    InsertAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Market Segment Title"; Rec."Market Segment Title")
                {
                    ShowCaption = false;
                    Editable = false;
                    DrillDown = false;
                    lookup = false;

                }
            }
        }


    }

}

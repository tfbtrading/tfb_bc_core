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
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()

                    var

                    begin

                    end;
                }
            }
        }


    }

    var
        MarketSegment: Text[255];

}

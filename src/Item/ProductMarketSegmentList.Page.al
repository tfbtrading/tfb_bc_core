page 50135 "TFB Product Market Seg. List"
{

    ApplicationArea = All;
    Caption = 'TFB Product Market Segment';
    PageType = List;
    SourceTable = "TFB Product Market Segment";
    UsageCategory = Administration;
    CardPageId = "TFB Product Market Segment";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Picture; Rec.Picture)
                {
                    ApplicationArea = All;
                }
                field("No. Of Generic Items"; Rec."No. Of Generic Items")
                {
                    ApplicationArea = All;
                }
                field("External ID"; Rec."External ID")
                {
                    ApplicationArea = All;
                }



            }
        }
    }

}

page 50136 "TFB Product Market Segment"
{

    Caption = 'TFB Product Market Segment';
    PageType = Card;
    SourceTable = "TFB Product Market Segment";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Detail)
                {
                    ShowCaption = false;
                    field(Title; Rec.Title)
                    {
                        ApplicationArea = All;
                    }

                    field("External ID"; Rec."External ID")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field(Description; Rec.Description)
                    {
                        ApplicationArea = All;
                    }

                    field("No. Of Generic Items"; Rec."No. Of Generic Items")
                    {
                        ApplicationArea = All;
                    }


                }
                group(Image)
                {
                    ShowCaption = false;
                    part(Picture; "TFB Market Segment Picture")
                    {
                        ApplicationArea = All;
                        SubPageLink = SystemId = field(SystemId);
                    }
                }
            }

        }
    }
}


page 50135 "TFB Product Market Seg. List"
{

    ApplicationArea = All;
    Caption = 'Product Market Segments';
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
                    ToolTip = 'Specifies the value of the Title field';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Short Description for slug field';
                }
                field(Picture; Rec.Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("No. Of Generic Items"; Rec."No. Of Generic Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Of Generic Items field';
                }
                field("External ID"; Rec."External ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the External ID field';
                }



            }
        }
    }

}

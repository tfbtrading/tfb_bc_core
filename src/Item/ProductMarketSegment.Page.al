page 50136 "TFB Product Market Segment"
{

    Caption = 'Product Market Segment';
    PageType = Card;
    SourceTable = "TFB Product Market Segment";
    DataCaptionExpression = Rec.Title;
    ApplicationArea = All;


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
                        ToolTip = 'Specifies the value of the title field';
                    }

                    field("External ID"; Rec."External ID")
                    {
                        Visible = ShowExternalIDs;
                        Importance = Standard;
                        ToolTip = 'Specifies the value of the external ID field';
                    }
                    field(Description; Rec.Description)
                    {
                        MultiLine = true;
                        ToolTip = 'Specifies the value of the short description for slug field';
                    }
                    field("Backgroud Colour"; Rec."Backgroud Colour")
                    {
                        ToolTip = 'Background colour stored in hex';
                    }

                    field("No. Of Generic Items"; Rec."No. Of Generic Items")
                    {
                        ToolTip = 'Specifies the value of the no. of generic items field';
                        DrillDown = true;
                        DrillDownPageId = "TFB Segment Generic Items";

                    }


                }

            }
            group(CriteriaGroup)
            {
                ShowCaption = false;
                part(Criteria; "TFB Seg. Match Criteria Sf")
                {

                    SubPageLink = ProductMarketSegmentID = field(SystemId);
                    Editable = true;

                }
            }

        }
        area(factboxes)
        {
            part(Picture; "TFB Market Segment Picture")
            {
                SubPageLink = SystemId = field(SystemId);
            }

            systempart(Notes; Notes)
            {
            }
        }
    }


    var
        CommonCU: CodeUnit "TFB Common Library";
        ShowExternalIDs: Boolean;

    trigger OnAfterGetRecord()

    begin

        ShowExternalIDs := CommonCU.CheckIfExternalIdsVisible();

    end;
}


page 50136 "TFB Product Market Segment"
{

    Caption = 'Product Market Segment';
    PageType = Card;
    SourceTable = "TFB Product Market Segment";
    DataCaptionExpression = Rec.Title;

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
                        Visible = ShowExternalIDs;
                        Importance = Standard;
                    }
                    field(Description; Rec.Description)
                    {
                        ApplicationArea = All;
                        MultiLine = true;
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
            group(CriteriaGroup)
            {
                ShowCaption = false;
                part(Criteria; "TFB Seg. Match Criteria Sf")
                {
                    ApplicationArea = All;

                    SubPageLink = ProductMarketSegmentID = field(SystemId);
                    Editable = true;

                }
            }

        }
    }

    var
        ShowExternalIDs: Boolean;
        CommonCU: CodeUnit "TFB Common Library";

    trigger OnAfterGetRecord()

    begin

        ShowExternalIDs := CommonCU.CheckIfExternalIdsVisible();

    end;
}


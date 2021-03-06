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
                        ToolTip = 'Specifies the value of the title field';
                    }

                    field("External ID"; Rec."External ID")
                    {
                        ApplicationArea = All;
                        Visible = ShowExternalIDs;
                        Importance = Standard;
                        ToolTip = 'Specifies the value of the external ID field';
                    }
                    field(Description; Rec.Description)
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ToolTip = 'Specifies the value of the short description for slug field';
                    }

                    field("No. Of Generic Items"; Rec."No. Of Generic Items")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the no. of generic items field';
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
        CommonCU: CodeUnit "TFB Common Library";
        ShowExternalIDs: Boolean;

    trigger OnAfterGetRecord()

    begin

        ShowExternalIDs := CommonCU.CheckIfExternalIdsVisible();

    end;
}


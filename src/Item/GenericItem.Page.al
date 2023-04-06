page 50132 "TFB Generic Item"
{

    Caption = 'Generic Item';
    PageType = Card;
    SourceTable = "TFB Generic Item";
    DataCaptionFields = Type, Description;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(DescriptionGroup)
                {
                    Caption = 'About';

                    field(Description; Rec.Description)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field(Type; Rec.Type)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Type field';
                    }
                    field("Alternative Names"; Rec."Alternative Names")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the alternative names that the generic item might be known by.';

                    }
                    field("Item Category Code"; Rec."Item Category Code")
                    {
                        Caption = 'Default item category';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Item Category Code field';
                    }
                    group(FullDescription)
                    {
                        Caption = 'Full Description';
                        field("Marketing Copy"; Rec."Rich Description")
                        {
                            ApplicationArea = All;
                            Importance = Standard;
                            MultiLine = true;
                            ShowCaption = false;
                            ToolTip = 'Specifies the marketing copy of the generic item.';
                        }

                    }
                }

            }
            group(ContentMgmt)
            {
                Caption = 'Content Management';
                field("No. Of Items"; Rec."No. Of Items")
                {
                    ApplicationArea = All;
                    Editable = false;
                    DrillDown = true;
                    DrillDownPageId = "Item List";
                    ToolTip = 'Specifies the value of the No. Of Items field';
                }
                group(ExternalID)
                {
                    Visible = ShowExternalIDs;
                    ShowCaption = false;
                    field("External ID"; Rec."External ID")
                    {
                        ApplicationArea = All;
                        Editable = true;
                        ToolTip = 'Specifies the value of the External ID field';
                    }
                }
                field("Do Not Publish"; Rec."Do Not Publish")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Indicates whether generic item should appear in catalogues or online';

                }




            }


        }



        area(FactBoxes)
        {
            part(Picture; "TFB Generic Item Picture")
            {
                ApplicationArea = All;
                SubPageLink = SystemId = field(SystemId);
            }

            part(MarketSegments; "TFB Generic Item Segment Tags")
            {

                ShowFilter = false;
                ApplicationArea = All;
                SubPageLink = GenericItemID = field(SystemId);
            }

        }
    }

    actions
    {
        area(Creation)
        {

        }

        area(Processing)
        {
            action(SwitchToParent)
            {
                Caption = 'Switch to Parent';
                ApplicationArea = All;
                Image = Hierarchy;


                Enabled = (Rec.Type = Rec.Type::ItemExtension) and (Rec.Description <> '');
                ToolTip = 'Executes the Switch to Parent action';

                trigger OnAction()
                begin

                    Rec.SwitchType(Rec.Type::ItemParent)

                end;
            }

            action(SwitchToExtension)
            {
                Caption = 'Switch to Extension';
                ApplicationArea = All;
                Image = MoveDown;

                Enabled = (Rec.Type = Rec.Type::ItemParent) and (Rec.Description <> '');
                ToolTip = 'Executes the Switch to Extension action';

                trigger OnAction()
                begin

                    Rec.SwitchType(Rec.Type::ItemExtension)

                end;
            }

            action(AddMarketSegment)
            {
                Caption = 'Add Market Segment';
                ApplicationArea = All;
                Image = CustomerGroup;

                Enabled = true;
                ToolTip = 'Add additional market segments to the generic item';

                trigger OnAction()

                var
                    MarketSegmentRec: Record "TFB Product Market Segment";
                    MarketSegmentSelRec: Record "TFB Product Market Segment";
                    MarketSegmentList: Page "TFB Product Market Seg. List";
                begin
                    MarketSegmentList.LookupMode(true);
                    MarketSegmentRec.SetFilter(SystemId, BuildExclusionFilter(Rec.SystemId));
                    If MarketSegmentRec.Count > 0 then begin
                        MarketSegmentList.SetTableView(MarketSegmentRec);
                        If MarketSegmentList.RunModal() = Action::LookupOK then begin
                            MarketSegmentList.SetSelectionFilter(MarketSegmentSelRec);
                            If MarketSegmentSelRec.Count > 1 then
                                repeat
                                    ValidateNewSegment(MarketSegmentSelRec.Title);
                                    MarketSegment := '';
                                until MarketSegmentSelRec.Next() = 0
                            else begin
                                MarketSegmentList.GetRecord(MarketSegmentRec);
                                ValidateNewSegment(MarketSegmentRec.Title);
                                MarketSegment := '';
                            end;

                        end;

                    end
                    else
                        Message('No more segments to be added');
                end;
            }
        }

        area(Promoted)
        {
            group(Category_Home)
            {
                Caption = 'Home';
                actionref(SwitchToParentRef; SwitchToParent)
                {

                }

                actionref(SwitchToExtensionRef; SwitchToExtension)
                {

                }
                actionref(AAddMarkSegmentRef; AddMarketSegment)
                {

                }
            }
        }
    }

    var
        CommonCU: CodeUnit "TFB Common Library";
        MarketSegment: Text[255];
        ShowExternalIDs: Boolean;

    trigger OnAfterGetRecord()

    begin
        //FullDescription := GetFullDescription();
        ShowExternalIDs := CommonCU.CheckIfExternalIdsVisible();

    end;

    trigger OnNewRecord(BelowxRec: Boolean)

    begin

        if Rec.Type <> Rec.Type::ItemExtension then
            Rec.Type := Rec.Type::ItemParent;

    end;


    local procedure ValidateNewSegment(Title: Text[255])


    var
        MarketSegmentRec: Record "TFB Product Market Segment";
        MarketSegmentRel: Record "TFB Generic Item Market Rel.";

    begin

        If Title = '' then exit;

        MarketSegmentRec.SetRange(Title, Title);
        If MarketSegmentRec.FindFirst() then begin
            If not MarketSegmentRel.get(Rec.SystemId, MarketSegmentRec.SystemId) then begin
                MarketSegmentRel.Init();
                MarketSegmentRel.GenericItemID := Rec.SystemId;
                MarketSegmentRel.ProductMarketSegmentID := MarketSegmentRec.SystemId;
                MarketSegmentRel.Insert(true);
                CurrPage.MarketSegments.Page.Update();
            end
        end
        else
            Error('Market segment title of %1 is invalid', MarketSegment);

    end;

    local procedure BuildExclusionFilter(SystemId: Guid): Text

    var

        MarketSegmentRel: Record "TFB Generic Item Market Rel.";
        FilterExpr: TextBuilder;
    begin

        MarketSegmentRel.SetRange(GenericItemID, SystemId);
        If MarketSegmentRel.Findset(false) then
            repeat
                If FilterExpr.Length > 0 then FilterExpr.Append('&');
                FilterExpr.Append(StrSubstNo('<>%1', MarketSegmentRel.ProductMarketSegmentID));
            until MarketSegmentRel.Next() = 0;
        Exit(FilterExpr.ToText());
    end;

}

page 50133 "TFB Generic Items"
{

    ApplicationArea = All;
    Caption = 'Generic Items';
    DataCaptionFields = Description;
    PageType = List;
    SourceTable = "TFB Generic Item";
    UsageCategory = Lists;
    CardPageId = "TFB Generic Item";
    Editable = false;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the description field';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ToolTip = 'Specifies the value of the Item Category Code field';
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Alternative Names"; Rec."Alternative Names")
                {
                    Visible = true;
                    ToolTip = 'Specifies the alternatives names by which the product is known';
                }
                field("External ID"; Rec."External ID")
                {
                    Visible = ShowExternalIDs;
                    ToolTip = 'Specifies the value of the External ID field';
                }
                field("Do Not Publish"; Rec."Do Not Publish")
                {
                    Visible = true;
                    ToolTip = 'Specifies that the generic item should not be published in the catalogue';
                }
                field("Has Active Items"; Rec."Has Active Items")
                {
                    Visible = true;
                    ToolTip = 'Specifies whether this generic item has currently active items';
                    DrillDown = false;
                }
                field("No. Of Items"; Rec."No. Of Items")
                {
                    Visible = true;
                    DrillDown = true;
                    DrillDownPageId = "Item List";
                    ToolTip = 'Specifies the value of the No. Of Items field. Offers the ability to see the number of items assigned.';
                }
            }
        }

        area(FactBoxes)
        {
            part(Picture; "TFB Generic Item Picture")
            {
                SubPageLink = SystemId = field(SystemId);
            }
            part(MarketSegments; "TFB Generic Item Segment Tags")
            {

                ShowFilter = false;
                SubPageLink = GenericItemID = field(SystemId);
            }

        }
    }
    actions
    {
        area(Processing)
        {
            action(AddMarketSegment)
            {
                Caption = 'Add Market Segment';
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
                    if MarketSegmentRec.Count > 0 then begin
                        MarketSegmentList.SetTableView(MarketSegmentRec);
                        if MarketSegmentList.RunModal() = Action::LookupOK then begin
                            MarketSegmentList.SetSelectionFilter(MarketSegmentSelRec);
                            if MarketSegmentSelRec.Count > 1 then
                                repeat
                                    ValidateNewSegment(MarketSegmentSelRec.Title);

                                until MarketSegmentSelRec.Next() = 0
                            else begin
                                MarketSegmentList.GetRecord(MarketSegmentRec);
                                ValidateNewSegment(MarketSegmentRec.Title);

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
                actionref(AddMarketSegmentRef; AddMarketSegment)
                {

                }
            }
        }


    }
    views
    {
        view(ActiveOnly)
        {
            Caption = 'With Active Items';
            Filters = where("Has Active Items" = const(true));
            SharedLayout = false;

            layout
            {
                modify("Has Active Items")
                {
                    Visible = false;
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

    local procedure ValidateNewSegment(Title: Text[255])


    var
        MarketSegmentRec: Record "TFB Product Market Segment";
        MarketSegmentRel: Record "TFB Generic Item Market Rel.";

    begin

        if Title = '' then exit;

        MarketSegmentRec.SetRange(Title, Title);
        if MarketSegmentRec.FindFirst() then begin
            if not MarketSegmentRel.get(Rec.SystemId, MarketSegmentRec.SystemId) then begin
                MarketSegmentRel.Init();
                MarketSegmentRel.GenericItemID := Rec.SystemId;
                MarketSegmentRel.ProductMarketSegmentID := MarketSegmentRec.SystemId;
                MarketSegmentRel.Insert(true);
                CurrPage.MarketSegments.Page.Update();
            end
        end
        else
            Error('Market segment title of %1 is invalid', Title);

    end;

    local procedure BuildExclusionFilter(SystemId: Guid): Text

    var

        MarketSegmentRel: Record "TFB Generic Item Market Rel.";
        FilterExpr: TextBuilder;
    begin

        MarketSegmentRel.SetRange(GenericItemID, SystemId);
        if MarketSegmentRel.Findset(false) then
            repeat
                if FilterExpr.Length > 0 then FilterExpr.Append('&');
                FilterExpr.Append(StrSubstNo('<>%1', MarketSegmentRel.ProductMarketSegmentID));
            until MarketSegmentRel.Next() = 0;
        exit(FilterExpr.ToText());
    end;
}

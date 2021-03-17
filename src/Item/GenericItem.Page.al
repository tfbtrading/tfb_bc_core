page 50132 "TFB Generic Item"
{

    Caption = 'Generic Item';
    PageType = Card;
    SourceTable = "TFB Generic Item";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Details)
                {
                    field("Item Category Code"; Rec."Item Category Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Item Category Code field';
                    }

                    field(Description; Rec.Description)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field("Alternative Names"; Rec."Alternative Names")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the alternative names that the generic item might be known by.';

                    }
                    field(Type; Rec.Type)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Type field';
                    }
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

                    group(FullDescription)
                    {
                        Caption = 'Full Description';
                        field("Full Description"; FullDescription)
                        {
                            ApplicationArea = Basic, Suite;
                            Importance = Standard;
                            MultiLine = true;
                            ShowCaption = false;
                            ToolTip = 'Specifies the full description of the generic item.';

                            trigger OnValidate()
                            begin
                                SetFullDescription(FullDescription);
                            end;
                        }
                    }
                }
                group(Image)
                {
                    ShowCaption = false;
                    part(Picture; "TFB Generic Item Picture")
                    {
                        ApplicationArea = All;
                        SubPageLink = SystemId = field(SystemId);
                    }
                }
            }

            group(MarketSegmentsGroup)
            {
                ShowCaption = false;
                group(VerticalStack)
                {
                    ShowCaption = false;
                    Caption = '';

                    field(MarketSegment; MarketSegment)

                    {
                        ApplicationArea = All;
                        Caption = 'Add Market Segment';
                        Lookup = true;
                        Editable = true;
                        LookupPageId = "TFB Product Market Seg. List";
                        ToolTip = 'Specifies the value of the Add Market Segment field';
                        trigger OnLookup(var Text: Text): Boolean

                        var
                            MarketSegmentList: Page "TFB Product Market Seg. List";
                            MarketSegmentRec: Record "TFB Product Market Segment";
                        begin
                            MarketSegmentList.LookupMode(true);
                            MarketSegmentRec.SetFilter(SystemId, BuildExclusionFilter(Rec.SystemId));
                            If MarketSegmentRec.Count > 0 then begin
                                MarketSegmentList.SetTableView(MarketSegmentRec);
                                If MarketSegmentList.RunModal() = Action::LookupOK then begin
                                    MarketSegmentList.GetRecord(MarketSegmentRec);
                                    Text := MarketSegmentRec.Title;
                                    MarketSegment := MarketSegmentRec.Title;
                                    ValidateNewSegment(MarketSegmentRec.Title);
                                    MarketSegment := '';
                                end;

                            end
                            else
                                Message('No more segments to be added');

                        end;


                    }
                    part(MarketSegments; "TFB Generic Item Segment Tags")
                    {
                        ShowFilter = false;
                        ApplicationArea = All;
                        SubPageLink = GenericItemID = field(SystemId);
                    }
                }
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
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
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
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = (Rec.Type = Rec.Type::ItemParent) and (Rec.Description <> '');
                ToolTip = 'Executes the Switch to Extension action';

                trigger OnAction()
                begin

                    Rec.SwitchType(Rec.Type::ItemExtension)

                end;
            }
        }
    }
    var


    var
        FullDescription: Text;
        MarketSegment: Text[255];
        ShowExternalIDs: Boolean;
        CommonCU: CodeUnit "TFB Common Library";

    trigger OnAfterGetRecord()

    begin
        FullDescription := GetFullDescription();
        ShowExternalIDs := CommonCU.CheckIfExternalIdsVisible();

    end;

    trigger OnNewRecord(BelowxRec: Boolean)

    begin

        if Rec.Type <> Rec.Type::ItemExtension then
            Rec.Type := Rec.Type::ItemParent;

    end;

    local procedure SetFullDescription(NewFullDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Rec."Full Description");
        Rec."Full Description".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewFullDescription);
        Rec.Modify(false);
    end;

    local procedure GetFullDescription(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields("Full Description");
        Rec."Full Description".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator));
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
        If MarketSegmentRel.FindSet(false, false) then
            repeat begin
                If FilterExpr.Length > 0 then FilterExpr.Append('&');
                FilterExpr.Append(StrSubstNo('<>%1', MarketSegmentRel.ProductMarketSegmentID));
            end until MarketSegmentRel.Next = 0;
        Exit(FilterExpr.ToText());
    end;

}

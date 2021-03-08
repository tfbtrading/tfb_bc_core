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
                    }

                    field(Description; Rec.Description)
                    {
                        ApplicationArea = All;
                    }
                    field(Type; Rec.Type)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("No. Of Items"; Rec."No. Of Items")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        DrillDown = true;
                        DrillDownPageId = "Item List";
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

                trigger OnAction()
                begin

                    Rec.SwitchType(Rec.Type::ItemExtension)

                end;
            }
        }
    }

    var
        FullDescription: Text;

    trigger OnAfterGetRecord()

    begin
        FullDescription := GetFullDescription();
      
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

}

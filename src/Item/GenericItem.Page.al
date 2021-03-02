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
            group(FurtherDetails)
            {
                ShowCaption = true;
                Visible = true;
                Caption = 'Marketing copy';


                usercontrol(MarketingCopy; Wysiwyg)
                {

                    ApplicationArea = All;
                    trigger ControlReady()
                    begin
                        CurrPage.MarketingCopy.Init();
                        CurrPage.MarketingCopy.Load(Rec."Rich Description");
                    end;

                    trigger SaveRequested(data: Text)
                    begin
                        Rec."Rich Description" := data;
                        Rec.Modify(false);
                    end;
                }


            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(SaveCopy)
            {
                Image = Save;
                Caption = 'Save marketing copy';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    CurrPage.MarketingCopy.RequestSave();
                end;

            }
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

    trigger OnNewRecord(BelowxRec: Boolean)

    begin

        if Rec.Type <> Rec.Type::ItemExtension then
            Rec.Type := Rec.Type::ItemParent;

    end;

}

page 50148 "TFB Segment Generic Items"
{
    Caption = 'Generic Items for Segment';
    PageType = List;
    SourceTable = "TFB Generic Item Market Rel.";
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    DataCaptionExpression = Rec."Market Segment Title";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Generic Item Description"; Rec."Generic Item Description")
                {
                    Caption = 'Generic Item';
                    ToolTip = 'Specifics the title of the generic item';
                    ApplicationArea = All;
                    trigger OnDrillDown()

                    var
                        GenericItem: Record "TFB Generic Item";

                    begin

                        GenericItem.GetBySystemId(Rec.GenericItemID);
                        Page.Run(PAGE::"TFB Generic Item", GenericItem);

                    end;
                }
            }
        }


    }

}

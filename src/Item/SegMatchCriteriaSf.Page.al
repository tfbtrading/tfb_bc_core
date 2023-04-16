page 50141 "TFB Seg. Match Criteria Sf"
{
    Caption = 'Attribute Match Selection';
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "TFB Segment Match Criteria";

    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;
    ModifyAllowed = true;
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Enabled = true;
                ShowCaption = false;
                field(ItemAttributeID; Rec.ItemAttributeID)
                {
                    Editable = true;
                    ToolTip = 'Specifies the item attribute ID';
                    BlankZero = true;
                    LookupPageId = "Item Attributes";



                }




                field("Attribute Name"; Rec."Attribute Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the item attribute.';

                    trigger OnValidate()
                    begin

                    end;
                }
                field(ItemAttributeValueID; Rec.ItemAttributeValueID)
                {
                    Editable = Rec.ItemAttributeID > 0;
                    ToolTip = 'Specifies the item attribute ID';
                    BlankZero = true;
                    LookupPageId = "Item Attribute Values";

                }
                field(Value; Rec."Attribute Value")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Selected Value';


                    ToolTip = 'Specifies the value of the item attribute.';

                    trigger OnValidate()
                    begin


                    end;
                }


            }
        }
    }



}
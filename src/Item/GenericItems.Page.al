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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the description field';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Category Code field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Alternative Names"; Rec."Alternative Names")
                {
                    Visible = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the alternatives names by which the product is known';
                }
                field("External ID"; Rec."External ID")
                {
                    Visible = ShowExternalIDs;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External ID field';
                }
                field("Do Not Publish"; Rec."Do Not Publish")
                {
                    Visible = true;
                    ApplicationArea = All;

                }
                field("No. Of Items"; Rec."No. Of Items")
                {
                    Visible = true;
                    ApplicationArea = All;
                    DrillDown = true;
                    DrillDownPageId = "Item List";
                    ToolTip = 'Specifies the value of the No. Of Items field. Offers the ability to see the number of items assigned.';
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

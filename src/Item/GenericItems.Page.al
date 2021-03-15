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
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("External ID"; Rec."External ID")
                {
                    Visible = ShowExternalIDs;
                    ApplicationArea = All;
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

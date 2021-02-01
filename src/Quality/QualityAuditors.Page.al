page 50106 "TFB Quality Auditors"
{
    PageType = List;
    Caption = 'Quality Auditors';
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Quality Auditor";
    Editable = true;
    ModifyAllowed = true;
    DeleteAllowed = true;
    InsertAllowed = true;
    InstructionalText = 'Please enter details around quality Auditors';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies the code for the quality auditor';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies the name for the quality auditor';
                }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {

    }
}
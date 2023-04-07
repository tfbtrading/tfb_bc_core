page 50302 "TFB Costing Scenario List"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Costing Scenario";
    CardPageId = "TFB Costing Scenario";
    Caption = 'Container Costing Scenario';
    Editable = false;
    AdditionalSearchTerms = 'Costing Template';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies unique code for costing scenario';
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ToolTip = 'Specifies initial effective date for costing scenario';
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
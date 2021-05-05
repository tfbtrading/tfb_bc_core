page 50145 "TFB Sample Request Sizes"
{

    ApplicationArea = All;
    Caption = 'Sample Request Sizes';
    PageType = List;
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;
    SourceTable = "TFB Sample Request Size";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                    Editable = true;
                }
                field(WeightKg; Rec.WeightKg)
                {
                    ToolTip = 'Specifies the value of the WeightKg field';
                    ApplicationArea = All;
                }
                field(IsUnit; Rec.IsUnit)
                {
                    ToolTip = 'Specifies the value of the IsUnit field';
                    ApplicationArea = All;
                }
            }
        }
    }

}

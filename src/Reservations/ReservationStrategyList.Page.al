page 50128 "TFB Reservation Strategy List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TFB Reservation Strategy";
    Caption = 'Reservation Strategy List';
    CardPageId = "TFB Reservation Strategy";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("No. of Customers"; Rec."No. of Customers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Customers field';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemModifiedAt field';
                }
            }
        }

    }

    actions
    {

    }
}
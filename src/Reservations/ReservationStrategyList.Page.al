page 50128 "TFB Resveration Strategy List"
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
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("No. of Customers"; Rec."No. of Customers")
                {
                    ApplicationArea = All;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}
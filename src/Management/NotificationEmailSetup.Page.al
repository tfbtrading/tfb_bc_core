page 50116 "TFB Notifications Email Setup"
{

    PageType = Card;
    SourceTable = "TFB Notification Email Setup";
    Caption = 'Notification Email Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {

                field("Email Template Active"; Rec."Email Template Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the url of the email template which is active';
                }
                field("Email Template Test"; Rec."Email Template Test")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the url of the email template which is used for testing';
                }
                field("Test Table"; Rec."Test Table")
                {
                    ToolTip = 'Specifies the table number for testing';
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExists();
    end;

}

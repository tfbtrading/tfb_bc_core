page 50120 "PDF Viewer Setup"
{
    PageType = Card;
    SourceTable = "PDF Viewer Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Web Viewer URL"; Rec."Web Viewer URL")
                {
                    Tooltip = 'Specifies web viewer URL';
                }
                field("Test Viewer URL"; Rec."Test Viewer URL")
                {
                    ToolTip = 'Specifies web viewer URL';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetRecord();
    end;
}
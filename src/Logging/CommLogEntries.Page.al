page 50182 "TFB Comm. Log Entries"
{

    PageType = List;
    SourceTable = "TFB Comm. Log Entry";
    SourceTableView = order(descending);
    Caption = 'Communication Entries';
    ApplicationArea = All;
    UsageCategory = History;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Record No."; Rec."Record No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the record no';
                }
                field("Record Table No."; Rec."Record Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the table no.';
                }
                field("Record Type"; Rec."Record Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the record type';
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source id';
                }
                field("Source Name"; Rec."Source Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source name';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source type';
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the direction';
                }

                field(ExternalURL; Rec.ExternalURL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external URL';
                }
                field(MessageContent; Rec.MessageContent)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the message content';
                }
                field(Method; Rec.Method)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the method of sending';
                }
                field(ResourceType; Rec.ResourceType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the resource type';
                }
                field(SentCount; Rec.SentCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many times message has been sent';
                }
                field(SentTimeStamp; Rec.SentTimeStamp)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the timestamp';
                }
            }
        }
    }

}

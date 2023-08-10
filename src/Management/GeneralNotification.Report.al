report 50100 "TFB General Notification"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;
    DataAccessIntent = ReadOnly;
    Extensible = true;


    dataset
    {
        dataitem(GeneralNotification; "TFB General Notification")
        {
            column(AlertText_DataItemName; AlertText)
            {
            }
            column(DateCaption_DataItemName; DateCaption)
            {
            }
            column(DateValue_DataItemName; DateValue)
            {
            }
            column(EmailContent_DataItemName; EmailContent)
            {
            }
            column(ExplanationCaption_DataItemName; ExplanationCaption)
            {
            }
            column(ExplanationValue_DataItemName; ExplanationValue)
            {
            }
            column(ReferenceCaption_DataItemName; ReferenceCaption)
            {
            }
            column(ReferenceValue_DataItemName; ReferenceValue)
            {
            }
            column(SourceRecordId_DataItemName; SourceRecordId)
            {
            }
            column(SubTitle_DataItemName; SubTitle)
            {
            }
            column(Title_DataItemName; Title)
            {
            }

        }
    }

    requestpage
    {

    }

    rendering
    {
        layout(LayoutName)
        {
            Type = Word;
            LayoutFile = 'Layouts/TFBGeneralNotification.docx';
        }
    }

    trigger OnPreReport()

    begin
        GeneralNotification.Reset();
        GeneralNotification.DeleteAll();
        GeneralNotification.Init();
        GeneralNotification.Title := 'General';
        GeneralNotification.Insert();

    end;

}
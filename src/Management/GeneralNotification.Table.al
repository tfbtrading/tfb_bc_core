table 50129 "TFB General Notification"
{
    Caption = 'General Notification';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; Title; Text[100])
        {
            Caption = 'Title';
        }
        field(2; SubTitle; Text[100])
        {
            Caption = 'SubTitle';
        }
        field(3; AlertText; Text[100])
        {
            Caption = 'AlertText';
        }
        field(4; ExplanationCaption; Text[100])
        {
            Caption = 'ExplanationCaption';
        }
        field(5; ExplanationValue; Text[100])
        {
            Caption = 'ExplanationValue';
        }
        field(6; DateCaption; Text[100])
        {
            Caption = 'DateCaption';
        }
        field(7; DateValue; Text[100])
        {
            Caption = 'DateValue';
        }
        field(8; ReferenceCaption; Text[100])
        {
            Caption = 'ReferenceCaption';
        }
        field(9; ReferenceValue; Text[100])
        {
            Caption = 'ReferenceValue';
        }
        field(10; SourceRecordId; RecordId)
        {
            Caption = 'SourceRecordId';
        }
        field(11; EmailContent; Text[2048])
        {
            Caption = 'EmailContent';
        }
    }
    keys
    {
        key(PK; Title)
        {
            Clustered = true;
        }
    }
}

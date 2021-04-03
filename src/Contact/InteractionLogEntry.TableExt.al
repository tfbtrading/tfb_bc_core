tableextension 50116 "TFB Interaction Log Entry" extends "Interaction Log Entry"
{
    fields
    {
        field(50100; "TFB Further Details"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Further details';
        }
    }
    

}
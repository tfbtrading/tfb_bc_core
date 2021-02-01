tableextension 50100 "TFB Location" extends Location
{
    fields
    {

        field(50100; "TFB Fumigation Time Delay"; Duration)
        {
            Caption = 'Fumigation Handling Time';
            DataClassification = CustomerContent;
        }
        field(50110; "TFB Inspection Time Delay"; Duration)
        {
            Caption = 'Inspection Time Delay';
            DataClassification = CustomerContent;
        }
        field(50120; "TFB X-Ray Time Delay"; Duration)
        {
            Caption = 'X-Ray Time Delay';
            DataClassification = CustomerContent;
        }

        field(50130; "TFB Heat Treat. Time Delay"; Duration)
        {
            Caption = 'Heat Treat. Time Delay';
            DataClassification = CustomerContent;
        }

        field(50140; "TFB Quarantine Location"; Boolean)
        {
            Caption = 'Quarantine Location';
            DataClassification = CustomerContent;
        }
        field(50150; "TFB AA No."; Text[35])
        {
            Caption = 'Approved Arrangement No.';
            DataClassification = CustomerContent;
        }
    }

}
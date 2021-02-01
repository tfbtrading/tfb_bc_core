table 50103 "TFB Quality Auditor"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Quality Auditors";

    fields
    {
        field(1; "Code"; Code[20])
        {

        }
        field(2; Name; Text[100])
        {

        }

    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

}
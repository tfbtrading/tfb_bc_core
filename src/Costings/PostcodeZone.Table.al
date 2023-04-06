table 50310 "TFB Postcode Zone"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Postcode Zone List";
    DrillDownPageId = "TFB Postcode Zone List";
    Caption = 'Postcode Zones';

    fields
    {

        field(2; "Code"; Code[20])
        {
            DataClassification = CustomerContent;

        }
        field(5; "Customer Price Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
            ValidateTableRelation = true;
        }
        field(4; "Filter"; Text[250])
        {
            DataClassification = CustomerContent;
            FieldClass = Normal;
        }
        field(3; "GUID"; Guid)
        {
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

}
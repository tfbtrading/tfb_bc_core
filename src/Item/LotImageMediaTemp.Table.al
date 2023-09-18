table 50132 "TFB Lot Image Media Temp"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    TableType = Temporary;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; Media; Media)
        {
            DataClassification = SystemMetadata;
        }

        field(3; MediaSet; MediaSet)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}
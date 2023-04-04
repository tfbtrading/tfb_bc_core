table 50107 "TFB Notification Email Setup"
{

    DataClassification = CustomerContent;
    ObsoleteReason = 'Consolidated into single table';
    ObsoleteState = Pending;
    ObsoleteTag = '21';
    fields
    {
        field(1; "Primary Key"; Code[10])
        {

        }
        field(10; "Email Template Active"; Text[256])
        {
            Caption = 'Email Template Active URL';
            ExtendedDatatype = url;

        }
        field(20; "Email Template Test"; Text[256])
        {
            Caption = 'Email Template Test URL';
            ExtendedDatatype = url;
        }
        field(30; "Test Table"; Integer)
        {
            Caption = 'Test Table';
            TableRelation = "Table Information";
            //You might want to add fields here

        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary> 
    /// Checks if setup table already exists
    /// </summary>
    procedure InsertIfNotExists()
    var
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;


}
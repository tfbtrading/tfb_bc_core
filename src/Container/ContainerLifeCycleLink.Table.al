table 50104 "TFB Container LifeCycle Link"
{
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Document No."; Code[20])
        {
            TableRelation = "TFB Container Entry";
            ValidateTableRelation = true;
        }
        field(20; Type; enum "TFB Container Link Type")
        {

        }
        field(30; "Source No."; Code[20])
        {

        }
        field(15; "Line No."; Integer)
        {

        }
        field(40; "Comment"; Text[200])
        {

        }


    }

    keys
    {
        key(PK; "Document No.", "Line No.", "Source No.")
        {
            Clustered = true;
        }
    }

}
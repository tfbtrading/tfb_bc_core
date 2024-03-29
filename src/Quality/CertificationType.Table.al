table 50102 "TFB Certification Type"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Certification Types";
    Access = Public;


    fields
    {
        field(10; "Code"; Code[20])
        {

        }
        field(20; Name; Text[100])
        {

        }
        field(25; "Class"; Enum "TFB Certification Class")
        {



        }
        field(30; "GFSI Accredited"; Boolean)
        {

        }
        field(40; "Logo"; Media)
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
    fieldgroups
    {
        fieldgroup(Brick; Code, Name, "GFSI Accredited", Logo) { }

        fieldgroup(Dropdown; Code, Name, Class, "GFSI Accredited") { }
    }

}
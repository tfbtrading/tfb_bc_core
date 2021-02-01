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

            trigger OnValidate()

            var
                Certification: Record "TFB Vendor Certification";

            begin

                //Ensure class is updated on all the vendor certificates
                Certification.SetRange("Certification Type", Code);

                if Certification.FindSet(true, false) then
                    repeat
                        Certification."Certification Class" := Class;
                        Certification.Modify();

                    until Certification.Next() < 1;
            end;

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

    }

}
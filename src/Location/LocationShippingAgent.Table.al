table 50117 "TFB Location Shipping Agent"

{
    DataClassification = CustomerContent;
    Caption = 'Location Shipping Agent';

    fields
    {
        field(1; Location; Code[10])
        {
            TableRelation = Location;

        }
        field(3; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin

            end;
        }
        field(4; County; Code[10])
        {

            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'County';
            TableRelation = County.Name;
        }

        field(5; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
            ValidateTableRelation = true;
        }

        field(6; "Agent Service Code"; Code[10])
        {

            Caption = 'Shipping Agent Service Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            ValidateTableRelation = true;
        }
    }

    keys
    {
        key(PK; Location, "Country/Region Code", County)
        {
            Clustered = true;
        }
    }

    var


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
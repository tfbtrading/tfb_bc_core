table 50314 "TFB Vendor Zone Rate"
{
    DataClassification = CustomerContent;
    Caption = 'Vendor PostCode Zone Rates';

    fields
    {

        field(1; "Vendor No."; code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = true;
        }
        field(5; "Sales Type"; Enum "TFB Sales Type")
        {

        }
        field(6; "Sales Code"; Code[20])
        {

            trigger OnValidate()

            var
                Customer: Record Customer;

            begin
                if "Sales Type" = "Sales Type"::Customer then
                    If Customer.get("Sales Code") then
                        "Sales Description" := Customer.Name;
            end;
        }
        field(7; "Sales Description"; Text[100])
        {
            Editable = false;
        }
        field(2; "Zone Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Postcode Zone";
            ValidateTableRelation = true;
        }
        field(10; "Rate Type"; Enum "TFB Price Unit")
        {
            DataClassification = CustomerContent;

        }
        field(20; "Shipping Agent"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
            ValidateTableRelation = true;
        }
        field(30; "Agent Service Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent"));
            ValidateTableRelation = true;
        }


        field(8; "Surcharge Rate"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(3; "ID"; Guid)
        {
            DataClassification = CustomerContent;
            Editable = False;

        }
        field(9; "Last Modified Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }

    }

    keys
    {
        key(PK; "Vendor No.", "Zone Code", "Sales Type", "Sales Code")
        {
            Clustered = true;

        }
    }

    trigger OnModify()
    begin
        "Last Modified Date Time" := CURRENTDATETIME();
    end;

    trigger OnInsert()
    begin
        "Last Modified Date Time" := CURRENTDATETIME();


    end;




}
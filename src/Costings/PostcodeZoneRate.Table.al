table 50312 "TFB Postcode Zone Rate"
{
    DataClassification = CustomerContent;
    Caption = 'PostCode Zone Rates';
    DrillDownPageId = "TFB Postcode Zone List";

    fields
    {

        field(2; "Zone Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Postcode Zone";
            ValidateTableRelation = true;
        }

        field(10; "Costing Scenario Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Costing Scenario";
        }
        field(8; "Base Rate"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                recCostingScenario: record "TFB Costing Scenario";

            begin
                if recCostingScenario.get("Costing Scenario Code") then
                    if recCostingScenario."Fuel Surcharge %" > 0 then begin
                        "Fuel Surcharge" := "Base Rate" * (recCostingScenario."Fuel Surcharge %" / 100);
                        "Total Charge" := "Fuel Surcharge" + "Base Rate";
                    end;
            end;
        }
        field(3; "ID"; Guid)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Fuel Surcharge"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Total Charge"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Last Modified Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Def. Cust. Price Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
            ValidateTableRelation = True;
        }

    }

    keys
    {
        key(PK; "Costing Scenario Code", "Zone Code")
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
table 50160 "TFB Landed Cost Template"
{
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteReason = 'Duplicate of Item Costings';



    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;

        }
        field(2; "Description"; Text[250])
        {
            DataClassification = CustomerContent;

        }


        field(3; "Total Costs"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("TFB Landed Cost Lines"."Estimated Cost" where("Template Code" = FIELD(Code)));
        }
        field(4; "Estimated Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Description = 'Total estimated weight of purchase to which landed cost is applied';
        }
        field(5; "Overseas Currency"; Code[20])
        {
            TableRelation = Currency;
            ValidateTableRelation = True;
            DataClassification = CustomerContent;
        }
        field(6; "Estimated Exch. Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 4;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }



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
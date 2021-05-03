table 50117 "TFB Sample Request Size"
{
    DataClassification = CustomerContent;

    fields
    {

        field(1; Description; Text[50])
        {

        }
        field(2; WeightKg; Decimal)
        {

        }
        field(5; IsUnit; Boolean)
        {

        }


    }

    keys
    {
        key(Key1; Description)
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
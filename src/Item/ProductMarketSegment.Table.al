table 50112 "Product Market Segment"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Generic Items";
    DrillDownPageId = "TFB Generic Items";
    Caption = 'Marketing Item';

    fields
    {

        field(10; "Title"; Text[255])
        {
            Caption = 'Title';
        }

        field(20; "Description"; Text[512])
        {
            Caption = 'Short Description for slug';

        }

        field(92; Picture; MediaSet)
        {
            Caption = 'Picture';


        }

        field(9000; "No. Of Generic Items"; Integer)
        {
            Caption = 'No. Of Generic Items';
            FieldClass = FlowField;
            CalcFormula = Count(Item where("TFB Generic Item ID" = field(SystemId)));

        }
        field(9010; "External ID"; Text[255])
        {
            Caption = 'External ID';

        }


    }

    keys
    {
        key(PK; Title)
        {
            Clustered = true;
        }

    }

}
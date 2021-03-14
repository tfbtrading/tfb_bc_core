table 50112 "TFB Product Market Segment"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Product Market Seg. List";
    DrillDownPageId = "TFB Product Market Seg. List";
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
            CalcFormula = Count("TFB Generic Item Market Rel." where(ProductMarketSegmentID = field(SystemId)));

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

    fieldgroups
    {
        fieldgroup(Bricks; Title, Picture, "No. Of Generic Items") { }
        fieldgroup(Dropdown; Title, "No. Of Generic Items") { }
    }

    trigger OnDelete()

    var
        GenericItemMarketRel: Record "TFB Generic Item Market Rel.";

    begin
        GenericItemMarketRel.SetRange(ProductMarketSegmentID, Rec.SystemId);
        If GenericItemMarketRel.Count > 0 then
            GenericItemMarketRel.DeleteAll(false);

    end;

}
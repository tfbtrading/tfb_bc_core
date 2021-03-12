table 50113 "TFB Generic Item Market Rel."
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; GenericItemID; Guid)
        {
            TableRelation = "TFB Generic Item".SystemId;
            ValidateTableRelation = true;

        }
        field(20; ProductMarketSegmentID; Guid)
        {
            TableRelation = "TFB Product Market Segment".SystemId;
            ValidateTableRelation = true;
        }
        field(2; "Generic Item Description"; Text[255])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("TFB Generic Item".Description where(SystemId = field(GenericItemID)));
        }
        field(22; "Market Segment Title"; Text[255])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("TFB Product Market Segment".Title where(SystemId = field(ProductMarketSegmentID)));
        }
        field(30; "Showcase Item ID"; Guid)
        {
            TableRelation = Item.SystemId where("TFB Generic Item ID" = field(GenericItemID));
            ValidateTableRelation = true;

        }

    }

    keys
    {
        key(PK; GenericItemID, ProductMarketSegmentID)
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
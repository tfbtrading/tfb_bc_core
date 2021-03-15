table 50114 "TFB Segment Match Criteria"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; ProductMarketSegmentID; Guid)
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Product Market Segment".SystemId;
            

        }
        field(10; ItemAttributeID; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Attribute".ID;

            trigger OnValidate()

            begin
                if xRec.ItemAttributeID <> Rec.ItemAttributeID then
                    ItemAttributeValueID := 0;
            end;

        }
        field(15; "Attribute Name"; Text[250])
        {
            CalcFormula = Lookup("Item Attribute".Name WHERE(ID = FIELD(ItemAttributeID)));
            Caption = 'Attribute Name';
            FieldClass = FlowField;
        }
        field(20; ItemAttributeValueID; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Attribute Value".ID where("Attribute ID" = field(ItemAttributeID));
        }
        field(25; "Attribute Value"; Text[100])
        {
            CalcFormula = Lookup("Item Attribute Value".Value WHERE(ID = FIELD(ItemAttributeValueID), "Attribute ID" = field(ItemAttributeID)));
            Caption = 'Attribute Value';
            FieldClass = FlowField;
        }

    }

    keys
    {
        key(PK; ProductMarketSegmentID, ItemAttributeID) { Clustered = true; }

        key(Key2; ItemAttributeValueID, ProductMarketSegmentID, ItemAttributeID) { }

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
table 50114 "TFB Segment Match Criteria"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; ProductMarketSegmentID; Guid)
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Product Market Segment".SystemId;
            Caption = 'Product Market Segment ID';

        }
        field(10; ItemAttributeID; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Attribute".ID;
            Caption = 'Item Attribute ID';

            trigger OnValidate()

            begin
                if xRec.ItemAttributeID <> Rec.ItemAttributeID then
                    ItemAttributeValueID := 0;
            end;

        }
        field(15; "Attribute Name"; Text[250])
        {
            CalcFormula = lookup("Item Attribute".Name where(ID = field(ItemAttributeID)));
            Caption = 'Attribute Name';
            FieldClass = FlowField;
        }
        field(20; ItemAttributeValueID; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Attribute Value".ID where("Attribute ID" = field(ItemAttributeID));
        }
        field(25; "Attribute Value"; Text[250])
        {
            CalcFormula = lookup("Item Attribute Value".Value where(ID = field(ItemAttributeValueID), "Attribute ID" = field(ItemAttributeID)));
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
table 50215 "TFB ContainerContents"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    Caption = 'Container Contents';

    fields
    {

        field(1; "LineType"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "PurchaseOrder","Brokerage";
        }
        field(2; "OrderReference"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "LineNo"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Item Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = true;

        }
        field(5; "Item Description"; code[100])
        {
            DataClassification = CustomerContent;
        }


        field(7; "UnitOfMeasure"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ValidateTableRelation = true;
        }
        field(6; "Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(9; "Price Unit"; Enum "TFB Price Unit")
        {
            DataClassification = CustomerContent;
        }
        field(10; "Price Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(12; "Price Unit Alloc."; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(13; "Price Unit. Incl. Alloc."; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }

        field(14; "Line Allocation"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(15; "Line Total"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(20; "Link Type"; Enum "TFB Container Link Type")
        {
            DataClassification = CustomerContent;
        }
        field(30; "Qty Sold (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
        }


    }

    keys
    {
        key(PK; OrderReference, LineNo)
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
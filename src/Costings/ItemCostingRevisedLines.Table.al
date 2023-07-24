table 50128 "TFB Item Costing Revised Lines"
{
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item Code';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = true;
            NotBlank = true;
            trigger OnValidate()
            var
                ItemRec: Record Item;
            begin
                ItemRec.Get("Item No.");
                Description := ItemRec.Description;

            end;
        }
        field(2; "Description"; Text[250])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = false;

            trigger OnValidate()

            var
                ItemRec: Record Item;
            begin

                Validate("Item No.", ItemRec.GetItemNo(Description));

            end;
        }
        field(3; "Costing Type"; Enum "TFB Costing Type")
        {

            NotBlank = true;
        }
        field(4; "Customer No."; Code[20])
        {
            NotBlank = true;
        }
        field(5; "Line Type"; Enum "TFB Costing Line Type")
        {

        }
        field(8; "Line Key"; Code[20])
        {

        }
        field(6; "Price (Base)"; Decimal)
        {

        }
        field(7; "Price Per Weight Unit"; Decimal)
        {

        }
        field(9; "Market Price (Base)"; Decimal)
        {

        }
        field(10; "Market price Per Weight Unit"; Decimal)
        {

        }


        field(12; CalcDesc; Text[2048])
        {


        }

    }

    keys
    {
        key(PK; "Item No.", "Costing Type", "Customer No.", "Line Type", "Line Key")
        {
            Clustered = true;
        }
        key(Price; "Price (Base)", "Line Type", "Line Key")
        {

        }
        key(MarketPrice; "Market Price (Base)", "Line Type", "Line Key")
        {

        }
        key("Item By Price"; "Item No.", "Price (Base)", "Line Type", "Line Key")
        {

        }
    }

}
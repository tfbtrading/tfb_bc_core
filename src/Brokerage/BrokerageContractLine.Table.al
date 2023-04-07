table 50224 "TFB Brokerage Contract Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Brokerage Contract";
            ValidateTableRelation = true;
            NotBlank = true;

        }
        field(2; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = true;
            NotBlank = true;

            trigger OnValidate()

            var
                ItemRecord: record Item;

            begin
                if ItemRecord.Get("Item No.") then
                    Description := ItemRecord.Description;
            end;
        }
        field(12; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(3; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            NotBlank = true;
            DecimalPlaces = 0;

            trigger OnValidate()

            begin
                CalcLineTotals();
            end;

        }

        field(5; "Pricing Unit Qty"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Price Unit Quantity';
            DecimalPlaces = 0 : 2;
            Enabled = true;
            Editable = false;
        }
        field(6; "Agreed Price"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2;

            trigger OnValidate()

            begin
                CalcLineTotals();
            end;


        }
        field(9; "Total MT"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 1;
            Enabled = true;
            Editable = false;
        }

        field(7; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2;
            Enabled = true;
            Editable = false;
        }

        field(8; "Brokerage Fee"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2;
            Editable = false;

        }
        field(10; "Recalculate Totals"; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'No longer required to determine if totals need to be calculated';
            Enabled = false;
            InitValue = false;
        }
        field(20; "Qty. On Shipments"; Decimal)
        {
            FieldClass = FlowField;

            CalcFormula = sum("TFB Brokerage Shipment Line".Quantity where("Contract No." = field("Document No."), "Item No." = field("Item No.")));


        }

    }

    keys
    {
        key(PK; "Document No.", "Item No.")
        {
            Clustered = true;
        }
    }

    var


    /// <summary> 
    /// Calculate line totals
    /// </summary>
    procedure CalcLineTotals()
    var
        BrokerageContract: record "TFB Brokerage Contract";
        ItemRecord: record Item;
        PriceCodeUnit: Codeunit "TFB Pricing Calculations";
        BrokerageCodeUnit: CodeUnit "TFB Brokerage Mgmt";

    begin
        if (BrokerageContract.get("Document No.")) and (ItemRecord.Get("Item No.")) and (Quantity > 0) then begin
            "Total MT" := (ItemRecord."Net Weight" * Quantity) / 1000;
            Amount := "Agreed Price" * "Pricing Unit Qty";
            "Pricing Unit Qty" := PriceCodeUnit.CalculateQtyPriceUnit("Item No.", BrokerageContract."Vendor Price Unit", Quantity);
            "Brokerage Fee" := BrokerageCodeUnit.CalculateBrokerage("Item No.", Quantity, "Agreed Price", "Document No.");
        end
        else begin
            "Brokerage Fee" := 0;
            "Total MT" := 0;
            "Pricing Unit Qty" := 0;
            Amount := 0;
        end;

    end;



}
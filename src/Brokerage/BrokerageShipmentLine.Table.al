table 50227 "TFB Brokerage Shipment Line"
{
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Brokerage Shipment";
            ValidateTableRelation = true;
            NotBlank = true;

        }
        field(2; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Brokerage Contract Line"."Item No." where("Document No." = field("Contract No."));
            ValidateTableRelation = false;
            NotBlank = true;



            trigger OnValidate()

            var
                Item: record Item;
                UoM: record "Unit of Measure";

            begin
                If Item.Get("Item No.") then begin
                    Description := Item.Description;
                    "Net Weight" := Item."Net Weight";
                    "Unit Of Measure Code" := Item."Base Unit of Measure";

                    If UoM.Get(Item."Base Unit of Measure") then
                        "Unit Of Measure" := UoM.Description;
                end;
            end;
        }
        field(12; "Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(3; "Quantity"; Decimal)
        {
            DataClassification = CustomerContent;

            NotBlank = true;
            DecimalPlaces = 1;

            trigger OnValidate()

            begin

                CalcLineTotals();
            end;

        }
        field(4; BulkerQuantity; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()

            var
                BrokerageShipment: Record "TFB Brokerage Shipment";
                Item: Record Item;

            begin

                If BrokerageShipment.Get(Rec."Document No.") and Item.Get(Rec."Item No.") then
                    If BrokerageShipment.Bulkers then
                        Rec.Validate(Quantity, (BrokerageShipment."Bulker Weight (mt)" * 1000 * Rec.BulkerQuantity) / Item."Net Weight");


            end;
        }


        field(5; "Pricing Unit Qty"; Decimal)
        {
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'No longer required';
            DecimalPlaces = 0 : 2;
            Enabled = true;
            Editable = false;
        }
        field(6; "Agreed Price"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2;
            Editable = false;

        }
        field(9; "Total MT"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 1;
            Enabled = true;
            Editable = false;
        }

        field(7; "Amount"; Decimal)
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

        field(10; "Net Weight"; Decimal)
        {
            Editable = false;

        }
        field(20; "Unit Of Measure"; Text[100])
        {
            Editable = false;
        }
        field(30; "Unit Of Measure Code"; Text[10])
        {
            Editable = false;
        }
        field(40; "Contract No."; Code[20])
        {
            Editable = false;
        }
        field(50; "Customer No."; Code[20])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("TFB Brokerage Shipment"."Customer No." where("No." = field("Document No.")));
        }
        field(60; "Buy From Vendor No"; Code[20])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("TFB Brokerage Shipment"."Buy From Vendor No." where("No." = field("Document No.")));
        }
        field(70; "Status"; Enum "TFB Brokerage Shipment Status")
        {
            FieldClass = FlowField;
            CalcFormula = lookup("TFB Brokerage Shipment".Status where("No." = field("Document No.")));
        }



    }

    keys
    {
        key(PK; "Document No.", "Item No.")
        {
            Clustered = true;
        }
    }


    trigger OnInsert()

    var
        Header: Record "TFB Brokerage Shipment";

    begin

        If Header.get("Document No.") then
            "Contract No." := Header."Contract No.";

    end;



    var

    local procedure CalcLineTotals()
    var
        BrokerageContract: record "TFB Brokerage Contract";
        BrokerageContractLine: record "TFB Brokerage Contract Line";
        BrokerageShipment: record "TFB Brokerage Shipment";
        ItemRecord: record Item;

        BrokerageCodeUnit: Codeunit "TFB Brokerage Mgmt";


    begin
        BrokerageShipment.get("Document No.");

        if (BrokerageContract.get(BrokerageShipment."Contract No.")) and (BrokerageContractLine.get(BrokerageShipment."Contract No.", "Item No.")) and (ItemRecord.Get("Item No.")) and (Quantity > 0) then begin

            "Brokerage Fee" := BrokerageCodeUnit.CalculateBrokerage("Item No.", Quantity, BrokerageContractLine."Agreed Price", BrokerageShipment."Contract No.");
            "Agreed Price" := BrokerageContractLine."Agreed Price";

            "Total MT" := (ItemRecord."Net Weight" * Quantity) / 1000;
            Amount := BrokerageContractLine."Agreed Price" * "Total MT";
        end
        else begin
            "Brokerage Fee" := 0;
            Amount := 0;
            "Total MT" := 0;
        end;
    end;


}
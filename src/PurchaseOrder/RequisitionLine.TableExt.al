tableextension 50141 "TFB Requisition Line" extends "Requisition Line" //246
{
    fields
    {
        field(50100; "TFB Price By Price Unit"; Decimal)
        {
            DataClassification = CustomerContent;

            CaptionClass = GetVendorLabel();

            DecimalPlaces = 2 :;

            trigger OnValidate()

            begin
                UpdateUnitPrice();
            end;
        }

        field(50101; "TFB Price Unit Lookup"; Enum "TFB Price Unit")
        {

            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."TFB Vendor Price Unit" where("No." = field("Vendor No.")));
            Editable = False;

            Caption = 'Pricing Unit';

        }
        field(50102; "TFB Vendor Name"; Text[100])
        {

            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = FIELD("Vendor No.")));
            Editable = false;
        }
        field(50103; "TFB Line Total Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Weight';
            DecimalPlaces = 2;
            Editable = false;
            BlankZero = true;

        }

        field(50104; "TFB Sales External No."; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Ext. Doc. No.';
            Width = 30;
            Editable = false;
        }

        field(50105; "TFB Delivery Surcharge"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Delivery Surcharge';
            Editable = False;
        }


        modify("Direct Unit Cost")
        {
            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
            end;
        }

        modify(Quantity)
        {
            trigger OnAfterValidate()

            begin
                If Type = Type::Item then
                    "TFB Line Total Weight" := TFBPricingCalculations.CalcLineTotalKg("No.", "Unit of Measure Code", Quantity)
                else
                    "TFB Line Total Weight" := 0;

            end;
        }
        modify("Unit of Measure Code")
        {
            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
            end;
        }

    }

    /// <summary> 
    /// Update unit price if price per kilogram is changed manually
    /// </summary>
    local procedure UpdateUnitPrice()

    var
        Vendor: record Vendor;

    begin
        If Type = Type::Item then begin
            Vendor.get("Vendor No.");
            PriceUnit := Vendor."TFB Vendor Price Unit";
            Rec.Validate("Direct Unit Cost", TFBPricingCalculations.CalculateUnitPriceByPriceUnit(rec."No.", rec."Unit of Measure Code", PriceUnit, rec."TFB Price By Price Unit"));

        end;
    end;


    /// <summary> 
    /// Update price unit per unit price
    /// </summary>
    local procedure UpdatePriceUnitPrice()
    var
        Vendor: record Vendor;
    begin
        If (Type = Type::Item) and (rec."Vendor No." <> '') then begin
            Vendor.get(rec."Vendor No.");
            PriceUnit := Vendor."TFB Vendor Price Unit";
            "TFB Price By Price Unit" := TFBPricingCalculations.CalculatePriceUnitByUnitPrice(rec."No.", rec."Unit of Measure Code", PriceUnit, rec."Direct Unit Cost");

        end;
    end;

    /// <summary> 
    /// Get the label to be used for the price unit
    /// </summary>
    /// <returns>Return variable "text".</returns>
    local procedure GetVendorLabel(): text

    var

    begin
        case "TFB Price Unit Lookup" of
            "TFB Price Unit Lookup"::MT:
                exit('Price Per MT');

            "TFB Price Unit Lookup"::KG:
                exit('Price Per Kg');

            "TFB Price Unit Lookup"::LB:
                exit('Price Per lb');

            else
                exit('Price Per Price Unit');

        end;


    end;

    var

        TFBPricingCalculations: Codeunit "TFB Pricing Calculations";
        PriceUnit: Enum "TFB Price Unit";

}
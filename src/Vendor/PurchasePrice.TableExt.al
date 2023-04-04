tableextension 50126 "TFB Purchase Price" extends "Purchase Price"
{

    fields
    {
        field(50140; "TFB Item Description"; Text[100])
        {
            Caption = 'Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            ObsoleteState = Pending;
            ObsoleteReason = 'Extends obselete table';
            ObsoleteTag = '21.0';

        }
        field(50127; "TFB VendorPriceUnit"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Pricing Unit';
            ObsoleteState = Pending;
            ObsoleteReason = 'Wrong field type';

        }
        field(50129; "TFB Vendor Price Unit"; Enum "TFB Price Unit")
        {
            Caption = 'Pricing Unit';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."TFB Vendor Price Unit" where("No." = field("Vendor No.")));
            ObsoleteState = Pending;
            ObsoleteReason = 'Extends obselete table';
            ObsoleteTag = '21.0';
        }

        // Add changes to table fields here
        field(50128; "TFB VendorPriceByWeight"; Decimal)
        {
            DataClassification = AccountData;
            DecimalPlaces = 4;
            Caption = 'Pricing Unit Price';
            ObsoleteState = Pending;
            ObsoleteReason = 'Extends obselete table';
            ObsoleteTag = '21.0';

            trigger OnValidate()

            begin
                UpdateUnitPrice();
            end;

        }

        modify("Direct Unit Cost")
        {
            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
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


    local procedure UpdateUnitPrice()

    var
        Vendor: record Vendor;

    begin

        Vendor.get(rec."Vendor No.");
        PriceUnit := Vendor."TFB Vendor Price Unit";
        Rec.Validate("Direct Unit Cost", TFBPricingLogic.CalculateUnitPriceByPriceUnit(rec."Item No.", rec."Unit of Measure Code", PriceUnit, rec."TFB VendorPriceByWeight"));
        Rec.CalcFields("TFB Vendor Price Unit");
    end;


    local procedure UpdatePriceUnitPrice()
    var
        Vendor: record Vendor;
    begin

        Vendor.get(rec."Vendor No.");
        PriceUnit := Vendor."TFB Vendor Price Unit";
        "TFB VendorPriceByWeight" := TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."Item No.", rec."Unit of Measure Code", PriceUnit, rec."Direct Unit Cost");
        Rec.CalcFields("TFB Vendor Price Unit");
    end;

    var

        TFBPricingLogic: Codeunit "TFB Pricing Calculations";
        PriceUnit: Enum "TFB Price Unit";

}
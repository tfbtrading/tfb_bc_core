pageextension 50203 "TFB Price List Line Review" extends "Price List Line Review"
{
    layout
    {
        addafter("Unit Price")
        {
            field(ProductWeight; _ProductWeight)
            {
                ApplicationArea = All;
                BlankZero = true;
                Caption = 'Product Weight';
                ToolTip = 'Specifies the weight of the product if applicable';
                Editable = false;
            }

            Field(PriceByWeight; _PricePerKg)
            {
                ApplicationArea = All;
                DecimalPlaces = 2 : 4;
                BlankZero = true;
                Caption = 'Price per kg';
                Tooltip = 'Specifies the price per kg';
                Editable = Rec."Asset Type" = Rec."Asset Type"::Item;
                Visible = Rec."Price Type" = Rec."Price Type"::Sale;

                trigger OnValidate()

                begin
                    rec.UpdateUnitPriceFromPerKgPrice(_PricePerKg);
                end;

            }

            Field(PriceByPriceUnit; _PricePerPriceUnit)
            {
                ApplicationArea = All;
                DecimalPlaces = 2 : 4;
                BlankZero = true;
                Caption = 'Price per Price Unit';
                Tooltip = 'Specifies the price per price unit for purchase items';
                Editable = Rec."Asset Type" = Rec."Asset Type"::Item;
                Visible = Rec."Price Type" = Rec."Price Type"::Purchase;

                trigger OnValidate()

                begin
                    rec.UpdateUnitPriceFromPerKgPrice(_PricePerKg);
                end;

            }



        }
        modify("Minimum Quantity")
        {
            Visible = false;
        }

        modify("Cost Factor")
        {
            Visible = false;
        }

        modify("Unit Price")
        {
            trigger OnAfterValidate()

            begin
                case Rec."Price Type" of
                    PriceType::Sale:
                        _PricePerKg := GetPricePerKgAndWeight();
                    PriceType::Purchase:
                        UpdatePriceUnitPrice();
                end;
            end;
        }

        modify("Asset No.")
        {

            trigger OnAfterValidate()

            begin
                _PricePerKg := GetPricePerKgAndWeight();
            end;

        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        PricingCU: CodeUnit "TFB Pricing Calculations";
        _ProductWeight: Decimal;
        _PricePerPriceUnit: Decimal;
        _PricePerKg: Decimal;
        _VendorPriceUnit: Enum "TFB Price Unit";

    trigger OnAfterGetRecord()

    begin
        case Rec."Price Type"::Purchase of
            Rec."Price Type"::Sale:
                GetPricePerKgAndWeight();
            Rec."Price Type"::Purchase:
                begin
                    GetPriceUnitForVendor();
                    UpdatePriceUnitPrice();
                end;
        end;
    end;

    local procedure GetPricePerKgAndWeight(): Decimal

    var
        Item: Record Item;

    begin
        _PricePerKg := 0;

        If not (Rec."Asset Type" = Rec."Asset Type"::Item) then exit;
        if not Item.Get(Rec."Asset No.") then exit;
        If not (Item."Net Weight" > 0) then exit;
        _PricePerKg := PricingCU.CalcPerKgFromUnit(Rec."Unit Price", Item."Net Weight");
        _ProductWeight := Item."Net Weight";
    end;



    local procedure UpdateUnitPriceFromPriceUnitPrice()


    begin
        GetPriceUnitForVendor();
        If Rec."Asset Type" = Rec."Asset Type"::Item then
            Rec.Validate("Direct Unit Cost", TFBPricingLogic.CalculateUnitPriceByPriceUnit(rec."Asset No.", rec."Unit of Measure Code", _VendorPriceUnit, _PricePerPriceUnit));

    end;

    local procedure UpdatePriceUnitPrice()

    begin
        GetPriceUnitForVendor();
        If Rec."Asset Type" = Rec."Asset Type"::Item then
            _PricePerPriceUnit := TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."Asset No.", rec."Unit of Measure Code", _VendorPriceUnit, rec."Direct Unit Cost");

    end;

    var

        TFBPricingLogic: Codeunit "TFB Pricing Calculations";

    local procedure GetPriceUnitForVendor()

    var
        Vendor: Record Vendor;
        Item: Record Item;
    begin


        If not (Rec."Source Type" = Rec."Source Type"::Vendor) then exit;

        If Vendor.Get(Rec."Source No.") then
            _VendorPriceUnit := Vendor."TFB Vendor Price Unit"
        else
            _VendorPriceUnit := _VendorPriceUnit::UNIT;

        If not (Rec."Asset Type" = Rec."Asset Type"::Item) then exit;
        if not Item.Get(Rec."Asset No.") then exit;
        If not (Item."Net Weight" > 0) then exit;

        _ProductWeight := Item."Net Weight";

    end;
}
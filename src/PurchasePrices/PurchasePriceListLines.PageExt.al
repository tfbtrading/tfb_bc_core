pageextension 50204 "TFB Purchase Price List Lines" extends "Purchase Price List Lines"
{
    layout
    {
        addafter(DirectUnitCost)
        {
            field(ProductWeight; _ProductWeight)
            {
                ApplicationArea = All;
                BlankZero = true;
                Caption = 'Product Weight';
                ToolTip = 'Specifies the weight of the product if applicable';
                Editable = false;
            }
            field("TFB VendorPriceUnit"; _VendorPriceUnit)
            {
                ApplicationArea = All;
                Caption = 'Price Unit';
                Editable = false;
                ToolTip = 'Specifies the vendors price unit';

            }

            Field(PriceByWeight; _PricePerPriceUnit)
            {
                ApplicationArea = All;
                DecimalPlaces = 2 : 4;
                BlankZero = true;
                Caption = 'Price per Price Unit';
                Tooltip = 'Specifies the price per price unit';
                Editable = Rec."Asset Type" = Rec."Asset Type"::Item;

                trigger OnValidate()

                begin
                    UpdateUnitPrice();
                end;

            }



        }
        modify("Minimum Quantity")
        {
            Visible = false;
        }



        modify(DirectUnitCost)
        {
            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
            end;
        }

        modify("Asset No.")
        {

            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
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

        _VendorPriceUnit: Enum "TFB Price Unit";




    trigger OnAfterGetRecord()

    begin
        GetPriceUnitForVendor();
        UpdatePriceUnitPrice();

    end;

    local procedure GetItemWeight()

    var
        Item: Record Item;
    begin
        _ProductWeight := 0;

        If (Rec."Asset Type" = Rec."Asset Type"::Item) and (Item.Get(Rec."Asset No.")) then begin

            _ProductWeight := Item."Net Weight";
        end;

    end;

    local procedure UpdateUnitPrice()




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

    begin

        If not (Rec."Source Type" = Rec."Source Type"::Vendor) then exit;

        If Vendor.Get(Rec."Source No.") then
            _VendorPriceUnit := Vendor."TFB Vendor Price Unit"
        else
            _VendorPriceUnit := _VendorPriceUnit::UNIT;


    end;
}
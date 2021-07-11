pageextension 50204 "TFB Purchase Price List Lines" extends "Purchase Price List Lines"
{
    layout
    {
        modify("Variant Code")
        {
            Visible = false;
        }
        modify("Work Type Code")
        {
            Visible = false;
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

        addafter(DirectUnitCost)
        {
            field(TFBPriceUnit; PriceUnit)
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Price Unit';
                ToolTip = 'Specifies the price unit of the item shown';

            }
            field(TFBWeight; _weight)
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Weight (kg)';
                ToolTip = 'Specifies the weight of the item shown';
                BlankZero = true;

            }

            field(TFBAltPrice; _altprice)
            {
                ApplicationArea = All;
                Editable = true;
                Caption = 'Weight Price';
                ToolTip = 'Specifies the price in weight unit specified';

                trigger OnValidate()

                begin

                    UpdateUnitPrice();

                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        _weight: Decimal;
        _altprice: Decimal;

        TFBPricingLogic: Codeunit "TFB Pricing Calculations";
        PriceUnit: Enum "TFB Price Unit";


    local procedure SetPriceUnit()

    var
        Vendor: record Vendor;
        PriceListHeader: Record "Price List Header";

    begin
        Vendor.SetLoadFields("TFB Vendor Price Unit");
        PriceListHeader.SetLoadFields("TFB Price Unit");

        PriceListHeader.Get(Rec."Price List Code");
        If Rec."Source Type" = Rec."Source Type"::Vendor then begin
            If Vendor.GetBySystemId(rec."Source ID") then
                PriceUnit := Vendor."TFB Vendor Price Unit"
        end
        else
            PriceUnit := PriceListHeader."TFB Price Unit";

    end;

    trigger OnAfterGetRecord()

    begin
        SetPriceUnit();
        UpdatePriceUnitPrice();
    end;

    local procedure UpdateUnitPrice()


    begin

        SetPriceUnit();
        If Rec."Asset Type" = Rec."Asset Type"::Item then
            Rec.Validate("Direct Unit Cost", TFBPricingLogic.CalculateUnitPriceByPriceUnit(rec."Asset No.", rec."Unit of Measure Code", PriceUnit, _altprice));

    end;


    local procedure UpdatePriceUnitPrice()

    begin
        SetPriceUnit();
        If Rec."Asset Type" = Rec."Asset Type"::Item then
            _altprice := TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."Asset No.", rec."Unit of Measure Code", PriceUnit, rec."Direct Unit Cost");

    end;


}
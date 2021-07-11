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
                Width = 5;

            }
            field(TFBWeight; Rec.GetItemWeight())
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Weight (kg)';
                ToolTip = 'Specifies the weight of the item shown';
                BlankZero = true;
                Width = 5;

            }

            field(TFBAltPrice; _altprice)
            {
                ApplicationArea = All;
                Editable = true;
                Caption = 'Weight Price';
                ToolTip = 'Specifies the price in weight unit specified';
                Width = 8;

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

        _altprice: Decimal;

        PriceUnit: Enum "TFB Price Unit";


    local procedure SetPriceUnit()



    begin
        PriceUnit := Rec.GetPriceUnit();

    end;

    trigger OnAfterGetRecord()

    begin
        SetPriceUnit();
        UpdatePriceUnitPrice();
    end;

    local procedure UpdateUnitPrice()


    begin

        SetPriceUnit();
        Rec.UpdateUnitPriceFromAltPrice(_altprice);

    end;


    local procedure UpdatePriceUnitPrice()

    begin
        SetPriceUnit();
        _altprice := Rec.GetPriceAltPriceFromUnitPrice()

    end;


}
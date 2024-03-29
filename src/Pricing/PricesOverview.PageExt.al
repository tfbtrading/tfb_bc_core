pageextension 50206 "TFB Prices Overview" extends "Prices Overview"
{
    layout
    {
        modify("Variant Code")
        {
            Visible = false;
        }
        modify("Currency Code")
        {
            Visible = false;
        }
        modify("Unit of Measure Code")
        {
            Visible = false;
        }
        modify("Minimum Quantity")
        {
            Visible = false;
        }
        modify("Cost Factor")
        {
            Visible = false;
        }
        addafter("Unit Price")
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
                Width = 4;

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

                    Rec.UpdateUnitPriceFromAltPrice(_altprice);

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

    trigger OnAfterGetRecord()

    begin

        PriceUnit := Rec.GetPriceUnit();
        _altprice := Rec.GetPriceAltPriceFromUnitPrice();


    end;
}
pageextension 50207 "TFB Get Price Line" extends "Get Price Line"
{
    layout
    {
        movebefore("Minimum Quantity"; "Unit Price")

        addbefore("Minimum Quantity")
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

    var

        _altprice: Decimal;

        PriceUnit: Enum "TFB Price Unit";

    trigger OnAfterGetRecord()

    begin
        PriceUnit := Rec.GetPriceUnit();
        _altprice := Rec.GetPriceAltPriceFromUnitPrice();


    end;
}
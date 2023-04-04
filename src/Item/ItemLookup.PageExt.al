pageextension 50166 "TFB Item Lookup" extends "Item Lookup"
{
    layout
    {
        addafter("Base Unit of Measure")
        {
            field("Net Weight"; Rec."Net Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies net weight of the product';
                Visible = true;
            }
        }
        addafter("Unit Price")
        {
            field(TFBSalesPrice; SalesPriceVar)
            {
                Caption = 'Local Sales Price Per Kg';
                ApplicationArea = All;
                BlankZero = true;
                ToolTip = 'Specifies the local sales price per kg';

            }
            field(TFBLastPriceChangedDate; LastChangedDateVar)
            {
                Caption = 'Last Changed';
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                ToolTip = 'Specifies the date the local sales price was changed';
            }

            field(Inventory; Rec.Inventory)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies current inventory in stock';
                Visible = true;

            }
            field("Reserved Qty. on Inventory"; Rec."Reserved Qty. on Inventory")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies currently reserved stock';
                Visible = true;
            }
        }
        modify("Unit Cost")
        {
            Visible = false;
        }
        modify("Vendor Item No.")
        {
            Visible = false;
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnOpenPage()

    begin

        CoreSetup.Get();
    end;

    trigger OnAfterGetRecord()


    begin


        Clear(SalesPriceVar);
        Clear(LastChangedDateVar);


        If CoreSetup."Def. Customer Price Group" <> '' then begin

            PriceListLine.SetRange("Asset No.", Rec."No.");
            PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
            PriceListLine.setrange("Source Type", PriceListLine."Source Type"::"Customer Price Group");
            PriceListLine.SetRange("Source No.", CoreSetup."Def. Customer Price Group");
            PriceListLine.setrange(Status, PriceListLine.Status::Active);
            PriceListLine.SetRange("Ending Date", 0D);


            If PriceListLine.FindLast() then begin
                SalesPriceVar := PricingCU.CalcPerKgFromUnit(PriceListLine."Unit Price", Rec."Net Weight");
                LastChangedDateVar := PriceListLine."Starting Date";
            end;
        end;



    end;


    var

        CoreSetup: record "TFB Core Setup";

        PriceListLine: Record "Price List Line";

        PricingCU: codeunit "TFB Pricing Calculations";


        SalesPriceVar: Decimal;

        LastChangedDateVar: Date;
}
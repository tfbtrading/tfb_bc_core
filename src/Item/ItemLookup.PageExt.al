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

                trigger OnDrillDown()

                var
                    SPLD: Page "Sales Price and Line Discounts";

                begin

                    SPLD.LoadItem(Rec);
                    SPLD.InitPage(True);
                    SPLD.RunModal();

                end;

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
        SalesSetup.Get();

    end;

    trigger OnAfterGetRecord()


    begin

        Clear(SalesPriceRec);
        Clear(SalesPriceVar);
        Clear(LastChangedDateVar);

        If SalesSetup."TFB Def. Customer Price Group" <> '' then begin

            SalesPriceRec.SetRange("Item No.", Rec."No.");
            SalesPriceRec.SetRange("Sales Code", SalesSetup."TFB Def. Customer Price Group");
            SalesPriceRec.SetRange("Sales Type", SalesPriceRec."Sales Type"::"Customer Price Group");
            SalesPriceRec.SetRange("Ending Date", 0D);

            If SalesPriceRec.FindLast() then begin
                SalesPriceVar := PricingCU.CalcPerKgFromUnit(SalesPriceRec."Unit Price", Rec."Net Weight");
                LastChangedDateVar := SalesPriceRec."Starting Date";
            end;
        end;



    end;


    var
        SalesSetup: record "Sales & Receivables Setup";
        SalesPriceRec: record "Sales Price";

        PricingCU: codeunit "TFB Pricing Calculations";
        SalesPriceVar: Decimal;

        LastChangedDateVar: Date;
}
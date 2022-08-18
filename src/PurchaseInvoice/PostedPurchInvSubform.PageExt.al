pageextension 50115 "TFB Posted Purch Inv Subform" extends "Posted Purch. Invoice Subform"
{
    layout
    {
        modify("Unit Price (LCY)")
        {
            Visible = false;
        }
        modify("Job No.")
        {
            Visible = false;
        }
        modify("Deferral Code")
        {
            Visible = false;
        }

        addbefore("Line Amount")
        {
            field("VAT %"; Rec."VAT %")
            {
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Specifies the GST% applied to the line';
            }
            field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
            {
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Specifies the GST posting group to the line';
            }
        }

        addafter("Direct Unit Cost")
        {
            field(TFBCostByVendorPriceUnit; CostByVendorPriceUnit)
            {
                ApplicationArea = All;
                Visible = True;
                Caption = 'Price By Price Unit';
                BlankZero = true;
                Editable = false;
                ToolTip = 'Specifies cost in vendors price unit';
            }
            field(TFBVendorPriceUnit; VendorPriceUnit)
            {
                ApplicationArea = All;
                Visible = true;
                Caption = 'Vendor Price Unit';
                Editable = false;
                ToolTip = 'Specifies the vendors price unit';
            }


        }

        addafter("Total Amount Incl. VAT")
        {
            field(_RemainingAmt; _RemainingAmt)
            {
                Caption = 'Total Remaining';
                ToolTip = 'Specifies the total amount remaining on invoice';
                Style = Favorable;
                StyleExpr = _RemainingAmt = 0;
                ApplicationArea = All;
                Importance = Standard;
                Visible = true;
            }

        }
    }

    actions
    {
    }

    var

        CostByVendorPriceUnit: Decimal;
        VendorPriceUnit: Enum "TFB Price Unit";
        _RemainingAmt: Decimal;

    local procedure GetLedgerEntryDetail(var RemainingAmt: Decimal): Boolean

    var
        LedgerEntry: Record "Vendor Ledger Entry";

    begin

        LedgerEntry.SetRange("Document No.", Rec."Document No.");
        LedgerEntry.SetRange("Document Type", LedgerEntry."Document Type"::Invoice);
        LedgerEntry.SetRange(Reversed, false);
        If not LedgerEntry.FindFirst() then
            Exit(false);
        LedgerEntry.CalcFields("Remaining Amount");
        RemainingAmt := LedgerEntry."Remaining Amount";
        Exit(true);
    end;





    trigger OnAfterGetRecord()

    begin

        Clear(_RemainingAmt);

        UpdatePriceUnitCalcs();

        GetLedgerEntryDetail(_RemainingAmt);

    end;

    local procedure UpdatePriceUnitCalcs(): Decimal

    var
        Vendor: Record Vendor;
        Item: Record Item;
        PricingCU: CodeUnit "TFB Pricing Calculations";

    begin

        Clear(CostByVendorPriceUnit);
        Clear(VendorPriceUnit);

        If rec.Type = rec.Type::Item then
            if Item.Get(rec."No.") then
                If item.type = item.type::Inventory then begin
                    Vendor.Get(rec."Buy-from Vendor No.");
                    VendorPriceUnit := Vendor."TFB Vendor Price Unit";
                    CostByVendorPriceUnit := PricingCU.CalculatePriceUnitByUnitPrice(Item."No.", rec."Unit of Measure Code", vendor."TFB Vendor Price Unit", rec."Direct Unit Cost");
                end;

    end;
}
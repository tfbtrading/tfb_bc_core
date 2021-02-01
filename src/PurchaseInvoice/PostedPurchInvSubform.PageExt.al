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
        addbefore("Direct Unit Cost")
        {
            field("TFB Container No"; _ContainerNo)
            {
                Caption = 'Container';
                Visible = _ContainerEntry <> '';
                DrillDown = true;
                Tooltip = 'Specifies if a container number exists';
                ApplicationArea = All;

                trigger OnDrillDown()

                begin
                    If _ContainerEntry <> '' then
                        OpenContainerDrillDown(_ContainerEntry);
                end;
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
                Visible=true;
            }

        }
    }

    actions
    {
    }

    var

        CostByVendorPriceUnit: Decimal;
        _ContainerEntry: Code[20];
        _ContainerNo: Text[100];
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

    local procedure CheckAndRetrieveContainerEntry()

    var
        CE: Record "TFB Container Entry";

    begin

        _ContainerEntry := '';
        _ContainerNo := '';

        CE.SetRange("Order Reference", Rec."Order No.");
        If CE.FindSet(false, false) then begin
            _ContainerEntry := CE."No.";
            _ContainerEntry := CE."Container No.";
        end;
    end;

    local procedure OpenContainerDrillDown(EntryNo: Code[20])

    var
        CE: Record "TFB Container Entry";
        CP: Page "TFB Container Entry";

    begin

        If CE.Get(EntryNo) then begin
            CP.SetRecord(CE);
            CP.Run();
        end;

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
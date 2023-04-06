pageextension 50230 "TFB Purch. Receipt Lines" extends "Purch. Receipt Lines" //5806
{
    layout
    {
        addbefore("Document No.")
        {
            field("Posting Date"; Rec."Posting Date")
            {
                ApplicationArea = All;
                Visible = true;
                ToolTip = 'Specifies posting date of receipt line';
            }
        }
        addafter("Buy-from Vendor No.")
        {

            field("TFB Vendor Order No. Lookup"; Rec."TFB Vendor Order No. Lookup")
            {
                ApplicationArea = All;
                Visible = true;
                Tooltip = 'Specifies vendors reference';
            }

            field("TFB Container No."; Rec."TFB Container No. LookUp")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies container number for receipt line';
                Drilldown = true;

                trigger OnDrillDown()

                var
                    ContainerEntry: Record "TFB Container Entry";
                    Container: Page "TFB Container Entry";

                begin

                    if Rec."TFB Container No. LookUp" <> '' then begin
                        ContainerEntry.Get(Rec."TFB Container Entry No.");
                        Container.SetRecord(ContainerEntry);
                        Container.Run();
                    end;
                end;
            }


            field(TFBCharges; TotalOfItemCharges)
            {
                Caption = 'Item Charges';
                ApplicationArea = All;
                Visible = true;
                ToolTip = 'Specifies total item charges currently accrued against purchase receipt';

                trigger OnDrillDown()

                begin
                    PurchRcptCU.OpenItemChargesForReceipt(Rec."Document No.", Rec."Line No.")
                end;
            }

        }


    }



    actions
    {
        addlast("&Line")
        {

        }

    }

    views
    {
        addlast
        {
            view(Warehouse)
            {
                Caption = 'Warehouse Only';
                Filters = where("Purchasing Code" = filter('<>DS'));
                OrderBy = descending("Posting Date");
                SharedLayout = true;

            }

        }

    }

    var
        PurchRcptCU: CodeUnit "TFB Purch. Rcpt. Mgmt";
        TotalOfItemCharges: Decimal;

    trigger OnAfterGetRecord()
    var
        TotalExistingItemCharges: Decimal;
        SameExistingItemCharges: Decimal;

    begin
        Rec.CalcFields("TFB Container No. LookUp");

        if PurchRcptCU.GetItemChargesForReceipt(Rec."Document No.", Rec."Line No.", '', TotalExistingItemCharges, SameExistingItemCharges) then
            TotalOfItemCharges := TotalExistingItemCharges
        else
            TotalOfItemCharges := 0;

    end;
}
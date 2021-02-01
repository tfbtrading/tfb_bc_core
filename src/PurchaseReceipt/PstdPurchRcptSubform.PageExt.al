pageextension 50160 "TFB Pstd Purch. Rcpt. Subform" extends "Posted Purchase Rcpt. Subform"
{
    layout
    {
        modify("Order Date")
        {
            Visible = false;
        }
        addafter("Quantity Invoiced")
        {
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
            field("Sales Order No."; Rec."Sales Order No.")
            {
                ApplicationArea = All;
                Visible = true;
                ToolTip = 'Specifies if a related dropship sales order exists';

                trigger OnDrillDown()

                begin
                    PurchRcptCU.OpenRelatedSalesOrder(Rec."Sales Order No.");
                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
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

        If PurchRcptCU.GetItemChargesForReceipt(Rec."Document No.", Rec."Line No.", '', TotalExistingItemCharges, SameExistingItemCharges) then
            TotalOfItemCharges := TotalExistingItemCharges
        else
            TotalOfItemCharges := 0;

    end;
}
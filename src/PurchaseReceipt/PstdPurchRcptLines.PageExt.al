pageextension 50210 "TFB Pstd. Purch. Rcpt. Lines" extends "Posted Purchase Receipt Lines" //MyTargetPageId
{

    layout
    {
        addafter("Expected Receipt Date")
        {
            field("TFBOrder No."; Rec."Order No.")
            {
                Visible = true;
                ApplicationArea = All;
                ToolTip = 'Specifies the purchase order number for the receipt';

            }
            field("TFB Container No. LookUp"; Rec."TFB Container No. LookUp")
            {
                ApplicationArea = all;
                Visible = True;
                ToolTip = 'Specifies the corresponding container number';

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
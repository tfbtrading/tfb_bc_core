pageextension 50183 "TFB Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Order Nos.")
        {
            field("TFB Container Entry Nos."; Rec."TFB Container Entry Nos.")
            {
                ApplicationArea = All;
                LookupPageId = "No. Series";
                ToolTip = 'Specifies container entry number series';
            }
        }
    }



}
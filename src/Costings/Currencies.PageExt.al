pageextension 50224 "TFB " extends Currencies
{
    layout
    {
        addafter(ExchangeRateAmt)
        {
            field("TFB Costing Basis"; Rec."TFB Costing Basis")
            {
                ToolTip = 'Specifies the rate at which item costings should default for current calculations';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
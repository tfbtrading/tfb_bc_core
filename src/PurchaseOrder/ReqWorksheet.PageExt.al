pageextension 50225 "TFB Req. Worksheet" extends "Req. Worksheet" //
{
    layout
    {
        addbefore("Direct Unit Cost")

        {

            field("TFB Price By Price Unit"; Rec."TFB Price By Price Unit")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies price in vendors price unit';
            }
            field("TFB Delivery Surcharge"; Rec."TFB Delivery Surcharge")
            {
                ApplicationArea = All;
                Caption = 'Delivery Surcharge';
                ToolTip = 'Specifies delivery surcharge';
            }
            field("TFB Price Unit Lookup"; Rec."TFB Price Unit Lookup")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies price unit lookup';
            }

            field("TFB Line Total Weight"; Rec."TFB Line Total Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies total line weight';
            }



        }
    }


    actions
    {
    }
}
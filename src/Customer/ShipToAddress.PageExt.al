pageextension 50161 "TFB Ship-to Address" extends "Ship-to Address"
{
    layout
    {
        addbefore("E-Mail")
        {
            field("TFB Notify Contact"; Rec."TFB Notify Contact")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the contact and email specified should be emailed separately';
            }
        }
        addafter("Shipping Agent Service Code")
        {
            field("TFB Override Pallet Details"; Rec."TFB Override Pallet Details")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether you want to override customer account details';
            }
            group(PalletAccountDetails)
            {
                Visible = Rec."TFB Override Pallet Details";
                Caption = 'Location specific pallet details';

                field("TFB Pallet Acct Type"; Rec."TFB Pallet Acct Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the pallet account type';
                }
                field("TFB Pallet Account No."; Rec."TFB Pallet Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the separate account number';
                }
            }


        }
    }

    actions
    {
        // Add changes to page actions here
    }


}
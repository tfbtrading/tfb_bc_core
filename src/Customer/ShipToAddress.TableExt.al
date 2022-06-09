tableextension 50109 "TFB Ship-to Address" extends "Ship-to Address"
{
    fields
    {
        field(50100; "TFB Notify Contact"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Notify separately';

            trigger OnValidate()

            begin
                if "TFB Notify Contact" then
                    if "E-Mail" = '' then
                        FieldError("E-Mail", 'Email must be filled in if notification is set to true');


            end;
        }
        field(50110; "TFB Pallet Acct Type"; enum "TFB Pallet Acct Type")
        {
            Caption = 'TFB Pallet Account Type';
        }
        field(50120; "TFB Pallet Account No."; Text[50])
        {
            Caption = 'Pallet Account No.';
        }
        field(50130; "TFB Override Pallet Details"; Boolean)
        {
            Caption = 'Override Pallet Details';
        }

        field(50104; "TFB Delivery Instructions"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Delivery Instructions';
        }


    }


}
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
    }

    var
        myInt: Integer;
}
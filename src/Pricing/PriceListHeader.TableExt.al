tableextension 50125 "TFB Price List Header" extends "Price List Header"
{
    fields
    {
        field(50100; "TFB Price Unit"; Enum "TFB Price Unit")
        {
            DataClassification = CustomerContent;
            Caption = 'Price Unit';
        }

        modify("Source No.")
        {

            trigger OnAfterValidate()

            var
                Vendor: Record Vendor;

            begin

                //If vendor get vendor details and set default unit type

                If "Source Type" = "Source Type"::Vendor then
                    If Vendor.Get("Source No.") then
                        "TFB Price Unit" := Vendor."TFB Vendor Price Unit";
            end;
        }
    }

    var
}
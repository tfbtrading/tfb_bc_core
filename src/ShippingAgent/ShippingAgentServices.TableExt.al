tableextension 50128 "TFB Shipping Agent Services" extends "Shipping Agent Services"
{
    fields
    {

        field(50100; "TFB Shipping Time Max"; DateFormula)
        {
            Caption = 'Shipping Time Max';

            trigger OnValidate()
            var
                DateTest: Date;

            begin
                DateTest := CalcDate("Shipping Time", WorkDate());
                if DateTest < WorkDate() then
                    Error(Text000Err, FieldCaption("Shipping Time"));

                TestMinVsMax();
            end;
        }

        modify("Shipping Time")
        {
            trigger OnAfterValidate()

            begin
                TestMinVsMax();
            end;
        }
        // Add changes to table fields here
    }

    local procedure TestMinVsMax(): Boolean

    var
        DateTest1: Date;
        DateTest2: Date;

    begin


        If Format("TFB Shipping Time Max") = '' then exit;

        DateTest1 := CalcDate("Shipping Time", WorkDate());
        DateTest2 := CalcDate("TFB Shipping Time Max", WorkDate());

        If DateTest2 < DateTest1 then
            FieldError("TFB Shipping Time Max", Text001Err);
    end;

    var
        Text000Err: Label 'The %1 cannot be negative.';
        Text001Err: Label 'Max shipping time cannot be less than min.';
}
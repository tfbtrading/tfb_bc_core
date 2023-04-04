pageextension 50118 "TFB Item Tracking Lines" extends "Item Tracking Lines"
{
    layout
    {
        modify("Expiration Date")
        {
            ShowMandatory = true;

            trigger OnBeforeValidate()
            var
                MFuture: DateFormula;
            begin
                Evaluate(MFuture, '6M');
                If CalcDate(MFuture, Today) > Rec."Expiration Date" then
                    If not Confirm('Check expiration date - it is only 6 months in future. Use this date?') then
                        Rec."Expiration Date" := 0D;

            end;
        }
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }


}
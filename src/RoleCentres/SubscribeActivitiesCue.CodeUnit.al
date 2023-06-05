codeunit 50131 "TFB Subscribe Activities Cue"
{
    trigger OnRun()
    begin

    end;

    local procedure GetNoLotsExpired(CalledFromWebService: Boolean; UseCachedValue: Boolean; var ActivitiesCue: Record "Activities Cue"): Integer
    var
        LotExpiryBuffer: Record "TFB Lot Expiry Buffer" temporary;
        ItemLedgersQuery: Query "TFB Item By Lot No. Ledg. Exp.";

    begin


        if UseCachedValue then
            if ActivitiesCue.Get() then
                if not IsPassedCueData(ActivitiesCue) then
                    exit(ActivitiesCue."TFB No. Lots Expired");

        ItemLedgersQuery.SetFilter(Expiration_Date, '..t');
        ItemLedgersQuery.Open();

        While ItemLedgersQuery.Read() do begin
            LotExpiryBuffer.init();
            LotExpiryBuffer."Item No." := ItemLedgersQuery.Item_No_;
            LotExpiryBuffer.Description := ItemLedgersQuery.Description;
            LotExpiryBuffer."Variant Code" := ItemLedgersQuery.Variant_Code;
            LotExpiryBuffer."Lot No." := ItemLedgersQuery.Lot_No;
            LotExpiryBuffer."Expiry Date" := ItemLedgersQuery.Expiration_Date;
            LotExpiryBuffer."Qty. (Base)" := ItemLedgersQuery.Remaining_Quantity_Sum;
            LotExpiryBuffer.Insert();
        end;

        Exit(LotExpiryBuffer.Count());

    end;


    var
        RefreshFrequencyErr: Label 'Refresh intervals of less than 10 minutes are not supported.';

    local procedure GetNoLotsExpiring(CalledFromWebService: Boolean; UseCachedValue: Boolean; var ActivitiesCue: Record "Activities Cue"): Integer

    var
        LotExpiryBuffer: Record "TFB Lot Expiry Buffer" temporary;
        ItemLedgersQuery: Query "TFB Item By Lot No. Ledg. Exp.";

    begin


        if UseCachedValue then
            if ActivitiesCue.Get() then
                if not IsPassedCueData(ActivitiesCue) then
                    exit(ActivitiesCue."TFB No. Lots Expiring");

        ItemLedgersQuery.SetFilter(Expiration_Date, 't..t+6m');
        ItemLedgersQuery.Open();

        While ItemLedgersQuery.Read() do begin
            LotExpiryBuffer.init();
            LotExpiryBuffer."Item No." := ItemLedgersQuery.Item_No_;
            LotExpiryBuffer.Description := ItemLedgersQuery.Description;
            LotExpiryBuffer."Variant Code" := ItemLedgersQuery.Variant_Code;
            LotExpiryBuffer."Lot No." := ItemLedgersQuery.Lot_No;
            LotExpiryBuffer."Expiry Date" := ItemLedgersQuery.Expiration_Date;
            LotExpiryBuffer."Qty. (Base)" := ItemLedgersQuery.Remaining_Quantity_Sum;
            LotExpiryBuffer.Insert();
        end;

        Exit(LotExpiryBuffer.Count());

    end;

    local procedure IsPassedCueData(ActivitiesCue: Record "Activities Cue"): Boolean
    begin
        if ActivitiesCue."Last Date/Time Modified" = 0DT then
            exit(true);

        exit(CurrentDateTime - ActivitiesCue."Last Date/Time Modified" >= GetActivitiesCueRefreshInterval())
    end;

    local procedure GetActivitiesCueRefreshInterval() Interval: Duration
    var
        MinInterval: Duration;
    begin
        MinInterval := 10 * 60 * 1000; // 10 minutes
        Interval := 60 * 60 * 1000; // 1 hr

        if Interval < MinInterval then
            Error(RefreshFrequencyErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Activities Mgt.", OnRefreshActivitiesCueDataOnBeforeModify, '', false, false)]
    local procedure OnRefreshActivitiesCueDataOnBeforeModify(var ActivitiesCue: Record "Activities Cue");
    begin



        if ActivitiesCue.FieldActive("TFB No. Lots Expired") then
            ActivitiesCue."TFB No. Lots Expired" := GetNoLotsExpired(false, false, ActivitiesCue);
        if ActivitiesCue.FieldActive("TFB No. Lots Expiring") then
            ActivitiesCue."TFB No. Lots Expiring" := GetNoLotsExpiring(false, false, ActivitiesCue);


    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"O365 Activities Dictionary", 'OnRunOnBeforeSetBackgroundTaskResult', '', false, false)]
    local procedure OnRunOnBeforeSetBackgroundTaskResult(var Results: Dictionary of [Text, Text]; ActivitiesCue: Record "Activities Cue");
    var


    begin

        results.Add(ActivitiesCue.FieldName("TFB No. Lots Expired"), Format(GetNoLotsExpired(false, false, ActivitiesCue)));
        results.Add(ActivitiesCue.FieldName("TFB No. Lots Expiring"), Format(GetNoLotsExpiring(false, false, ActivitiesCue)));
    end;




}
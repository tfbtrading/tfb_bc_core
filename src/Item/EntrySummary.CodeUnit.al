codeunit 50125 "TFB Entry Summary"
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Data Collection", 'OnAfterCreateEntrySummary', '', false, false)]
    local procedure OnAfterCreateEntrySummary(TrackingSpecification: Record "Tracking Specification"; var TempGlobalEntrySummary: Record "Entry Summary");

    var
        LotInfo: record "Lot No. Information";

    begin

        LotInfo.SetLoadFields(Blocked);

        LotInfo.SetRange("Item No.", TrackingSpecification."Item No.");
        LotInfo.SetRange("Variant Code", TrackingSpecification."Variant Code");
        LotInfo.SetRange("Lot No.", TrackingSpecification."Lot No.");

        If LotInfo.FindFirst() then
            TempGlobalEntrySummary."TFB Lot Blocked" := LotInfo.Blocked;

    end;

    


}
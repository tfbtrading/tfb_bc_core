codeunit 50125 "TFB Entry Summary"
{
    SingleInstance = true;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Data Collection", 'OnCreateEntrySummary2OnBeforeInsertOrModify', '', false, false)]
    local procedure OnCreateEntrySummary2OnBeforeInsertOrModify(var TempGlobalEntrySummary: Record "Entry Summary"; TempReservEntry: Record "Reservation Entry"; TrackingSpecification: Record "Tracking Specification");
    var
        LotInfo: record "Lot No. Information";

    begin
        clear(LotInfo);
        LotInfo.SetLoadFields(Blocked, "TFB Date Available");

        LotInfo.SetRange("Item No.", TempReservEntry."Item No.");
        LotInfo.SetRange("Variant Code", TempReservEntry."Variant Code");
        LotInfo.SetRange("Lot No.", TempReservEntry."Lot No.");

        if LotInfo.FindFirst() then begin
            TempGlobalEntrySummary."TFB Lot Blocked" := LotInfo.Blocked;
            TempGlobalEntrySummary."TFB Date Available" := LotInfo."TFB Date Available";
        end;
    end;





}
codeunit 50115 "TFB Location Mgmt"
{

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateLocationCodeOnAfterSetOutboundWhseHandlingTime', '', false, false)]
    local procedure OnValidateLocationCodeOnAfterSetOutboundWhseHandlingTime(var SalesLine: Record "Sales Line");
    begin


    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateLocationCodeOnBeforeSetShipmentDate', '', false, false)]
    local procedure OnValidateLocationCodeOnBeforeSetShipmentDate(var SalesLine: Record "Sales Line"; var IsHandled: Boolean);
    begin
        SalesLine."Shipment Date" := CalcShipmentDateForLocation(SalesLine);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateNoOnBeforeCalcShipmentDateForLocation', '', false, false)]
    local procedure OnValidateNoOnBeforeCalcShipmentDateForLocation(var Sender: Record "Sales Line"; var IsHandled: Boolean);


    begin

        Sender."Shipment Date" := CalcShipmentDateForLocation(Sender);
        IsHandled := true;
    end;


    local procedure CalcShipmentDateForLocation(SalesLine: Record "Sales Line") ShipmentDate2: Date
    var
        SalesHeader: record "Sales Header";
        Location: Record Location;
        CalendarMgmt: CodeUnit "Calendar Management";
        DateFormulae: DateFormula;
        NewDate: Date;
        CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
    begin
        Evaluate(DateFormulae, '1D');
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        CustomCalendarChange[1].SetSource(Enum::"Calendar Source Type"::Location, SalesLine."Location Code", '', '');
        NewDate := SalesHeader."Shipment Date";
        If Location.Get(SalesLine."Location Code") and (Location."TFB Outbound Order Deadline" > 0T) then
            If Time > Location."TFB Outbound Order Deadline" then
                NewDate := CalcDate(DateFormulae, SalesHeader."Shipment Date");

        ShipmentDate2 := CalendarMgmt.CalcDateBOC('', NewDate, CustomCalendarChange, false);
    end;

}

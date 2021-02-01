codeunit 50105 "TFB Reservations Mgmt"
{
    trigger OnRun()
    begin

    end;

    procedure GetSaleLineForItemResEntry(ResEntrySupply: Record "Reservation Entry"; var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"): Boolean

    var
        ResEntryDemand: Record "Reservation Entry";

    begin

        ResEntryDemand.SetRange("Entry No.", ResEntrySupply."Entry No.");
        ResEntryDemand.SetRange(Positive, false);

        If ResEntryDemand.FindFirst() then
            If ResEntryDemand."Source Type" = 37 then begin
                Clear(SalesLine);
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SetRange("Document No.", ResEntryDemand."Source ID");
                SalesLine.SetRange("Line No.", ResEntryDemand."Source Ref. No.");

                If SalesLine.FindFirst() then begin

                    SalesHeader.SetRange("Document Type", SalesLine."Document Type");
                    SalesHeader.SetRange("No.", SalesLine."Document No.");

                    If SalesHeader.FindFirst() then
                        Exit(true);
                end;

            end;

    end;

}
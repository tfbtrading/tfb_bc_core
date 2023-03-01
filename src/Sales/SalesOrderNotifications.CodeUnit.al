codeunit 50127 "TFB Sales Order Notifications"
{
    trigger OnRun()
    begin

    end;

    var


   
    procedure OpenExistingQuote(MyNotification: Notification)
    var
        SalesHeader: Record "Sales Header";
        PageRunner: CodeUnit "Page Management";

    begin

        If not MyNotification.HasData('SystemId') then exit;

        If not SalesHeader.GetBySystemId(MyNotification.GetData('SystemId')) then exit;

        PageRunner.PageRun(SalesHeader);


    end;
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnAfterInsertSalesOrderLine', '', false, false)]
local procedure OnAfterInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line"; SalesOrderHeader: Record "Sales Header"; SalesQuoteLine: Record "Sales Line"; SalesQuoteHeader: Record "Sales Header");
begin
end;

[EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCreateSalesLine', '', false, false)]
local procedure OnAfterCreateSalesLine(var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line");
begin
end;


}
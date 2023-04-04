codeunit 50128 "TFB Sales Order Notif. Actions"
{
    SingleInstance = true;


    procedure OpenExistingQuote(MyNotification: Notification)
    var
        SalesHeader: Record "Sales Header";
        PageRunner: CodeUnit "Page Management";

    begin

        If not MyNotification.HasData('SystemId') then exit;

        If not SalesHeader.GetBySystemId(MyNotification.GetData('SystemId')) then exit;

        PageRunner.PageRun(SalesHeader);


    end;


}
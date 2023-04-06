codeunit 50128 "TFB Sales Order Notif. Actions"
{
    SingleInstance = true;


    procedure OpenExistingQuote(MyNotification: Notification)
    var
        SalesHeader: Record "Sales Header";
        PageRunner: CodeUnit "Page Management";

    begin

        if not MyNotification.HasData('SystemId') then exit;

        if not SalesHeader.GetBySystemId(MyNotification.GetData('SystemId')) then exit;

        PageRunner.PageRun(SalesHeader);


    end;


}
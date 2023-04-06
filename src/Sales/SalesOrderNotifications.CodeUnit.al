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

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateNoOnAfterUpdateUnitPrice', '', false, false)]
    local procedure OnValidateNoOnAfterUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line");
    var
        MyNotification: Notification;
        LatestQuoteSystemId: Guid;
        LatestQuoteNo: code[20];
        NoOfQuotes: Integer;
        NotificationTxt: Label 'There are %1 quote lines for this %3. The latest one is %2', Comment = '%1 = count of quotes, %2 = quote number, %3 = item description';
    begin

        If SalesLine.GetSalesHeader()."Quote No." <> '' then exit; // If order Head is a quote we should not check this line
        If not CheckIfItemOnQuote(SalesLine, LatestQuoteSystemId, LatestQuoteNo, NoOfQuotes) then exit;

        MyNotification.Message(StrSubstNo(NotificationTxt, NoOfQuotes, LatestQuoteNo, SalesLine.Description));
        MyNotification.Scope(NotificationScope::LocalScope);
        MyNotification.SetData('SystemID', LatestQuoteSystemId);
        MyNotification.AddAction('Open Latest Quote', 50128, 'OpenExistingQuote');
        MyNotification.Send();

    end;

    local procedure CheckIfItemOnQuote(SalesLine: Record "Sales Line"; var LatestQuoteSystemId: Guid; var LatestQuoteNo: code[20]; var NoOfQuotes: Integer): Boolean

    var
        SalesQuote: Record "Sales Header";
        SalesQuoteLine: Record "Sales line";
    begin

        SalesQuoteLine.setRange("Document Type", SalesQuoteLine."Document Type"::Quote);
        SalesQuoteLine.setRange("No.", SalesLine."No.");
        SalesQuoteLine.SetRange("Sell-to Customer No.", SalesLine."Sell-to Customer No.");

        if SalesQuoteLine.IsEmpty() then exit(false);

        NoOfQuotes := SalesQuoteLine.count();

        SalesQuoteLine.FindLast();

        SalesQuote.SetLoadFields(SystemId);
        SalesQuote.Get(SalesQuote."Document Type"::Quote, SalesQuoteLine."Document No.");
        LatestQuoteSystemId := SalesQuote.Systemid;
        LatestQuoteNo := SalesQuote."No.";
        exit(true);

    end;


}


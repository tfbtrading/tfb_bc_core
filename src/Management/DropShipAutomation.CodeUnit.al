codeunit 50109 "TFB DropShip Automation"
{
    trigger OnRun()
    begin

        If not ReqWorkName.FindFirst() then
            exit;

        ReqWorkLine.Init();
        ReqWorkLine."Worksheet Template Name" := ReqWorkName."Worksheet Template Name";

        GetSalesRpt.InitializeRequest(0);
        GetSalesRpt.SetReqWkshLine(ReqWorkLine, 0);
        GetSalesRpt.Run();

        CarryOutRpt.SetReqWkshName(ReqWorkName);
        CarryOutRpt.Run();

    end;

    var
        ReqWorkLine: Record "Requisition Line";
        ReqWorkName: Record "Requisition Wksh. Name";
        GetSalesRpt: Report "Get Sales Orders";

        CarryOutRpt: Report "Carry Out Action Msg. - Req.";

}
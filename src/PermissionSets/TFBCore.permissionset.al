permissionset 50100 "TFB Core"
{
    Assignable = true;
    Caption = 'TFB Core - Super';
    IncludedPermissionSets = "TFB Core Log - Edit", "TFB CORE QUAL - EDIT", "TFB Core Cost - Edit", "TFB Core CRM";

    Permissions = tabledata "PDF Viewer Setup" = RIMD,

        page "PDF Viewer" = X,
        page "PDF Viewer Part" = X,
        page "PDF Viewer Setup" = X,
        tabledata "TFB Core Setup" = RIMD,
        page "TFB Core Setup" = X,

        page "TFB Rep. Sel - Sample Req." = X,
        page "TFB Report Sel - Brokerage" = X,
        page "TFB Report Sel - Containers" = X,
        page "TFB Report Sel. - Notif." = X,

        query "TFB Contact PowerBI" = X,
        query "TFB Container Payment Sched." = X,
        query "TFB Customer Item Sales" = X,
        query "TFB Interaction PowerBI" = X,
        query "TFB Item Generic Info" = X,
        query "TFB Item Ledger Entries" = X,
        query "TFB Item Metadata" = X,
        query "TFB Items Shipped" = X,
        query "TFB Purchase Lines Outstanding" = X,
        query "TFB Sales Lines Outstanding" = X,
        query "TFB Transfer Lines Outstanding" = X;
}
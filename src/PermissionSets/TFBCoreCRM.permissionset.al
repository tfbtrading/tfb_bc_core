permissionset 50107 "TFB Core CRM"
{
    Assignable = true;
    Caption = 'TFB Core CRM';
    Permissions = tabledata "PDF Viewer Setup" = RIMD,
    tabledata "TFB Lot Expiry Buffer" = RIMD,
        tabledata "TFB Contact Status" = RIMD,
        tabledata "TFB Cust. Fav. Item" = RIMD,
        tabledata "TFB Customer Sales Line Buffer" = RIMD,
        tabledata "TFB Comm. Log Entry" = Rimd,
        tabledata "TFB Ops Mgr Activities Cue" = RIMD,
        tabledata "TFB Picture Entity" = RIMD,
        tabledata "TFB Product Market Segment" = RIMD,
        tabledata "TFB Lot Image" = R,
        tabledata "TFB Core Setup" = r,
        tabledata "TFB Sales Admin Activities Cue" = RIMD,
        tabledata "TFB Sales WinLoss" = RIMD,
        codeunit "PDF Viewer Install" = x,
        codeunit "TFB Action Handlers" = x,
        codeunit "TFB Common Library" = x,
        codeunit "TFB Contact Mgmt" = x,
        codeunit "TFB Cust. Collections Mgmt" = x,
        codeunit "TFB Cust. Fav. Items" = X,
        codeunit "TFB Customer Mgmt" = X,
        codeunit "TFB DropShip Automation" = X,
        codeunit "TFB Item Mgmt" = x,
        codeunit "TFB Location Mgmt" = x,
        codeunit "TFB Lot Info Mgmt" = x,
        codeunit "TFB Lot Intelligence" = x,
        codeunit "TFB Reservations Mgmt" = x,
        codeunit "TFB Role Centres Mgmt" = x,
        codeunit "TFB Sales Credit Mgmt" = x,
        codeunit "TFB Sales Mgmt" = x,
        codeunit "TFB Sales Order Notif. Actions" = x,
        codeunit "TFB Sales Order Notifications" = x,
        codeunit "TFB Sales Shipment Mgmt" = x,
        page "PDF Viewer" = X,
        page "PDF Viewer Part" = X,
        page "PDF Viewer Setup" = X,
        page "TFB Active Task List" = X,
        page "TFB APIV2 - Contact DIL" = X,
        page "TFB APIV2 - Contact Review" = X,
        page "TFB APIV2 - Custom Pictures" = X,
        page "TFB Contact Review List" = X,
        page "TFB Contact Review Wizard" = X,
        page "TFB Contact Status List" = X,
        page "TFB Contact Task Subform" = X,
        page "TFB Cust. Cont. Stats. FactBox" = X,
        page "TFB Cust. Fav. Items" = X,
        page "TFB Generic Item Picture" = X,
        page "TFB Gross Profit Sales Lines" = x,
        page "TFB Lot Images" = X,
        page "TFB Market Segment Picture" = X,
        page "TFB Ops Mgr Activities" = X,
        page "TFB Ops Mgr Role Center" = X,
        page "TFB Payment Note" = X,
        page "TFB Product Market Seg. List" = X,
        page "TFB Product Market Segment" = X,
        page "TFB Sales Admin Activities" = X,
        page "TFB Sales Admin Role Center" = X,
        page "TFB Sales Line FactBox" = X,
        page "TFB Sales POD FactBox" = X,
        query "TFB Customer Item Sales" = X,
        query "TFB Interaction PowerBI" = X,
        query "TFB Item Generic Info" = X,
        query "TFB Item Ledger Entries" = x,
        query "TFB Item Metadata" = x,
        query "TFB Items Shipped" = x,
        query "TFB Purchase Lines Outstanding" = x,
        query "TFB Sales Lines Outstanding" = x,
        query "TFB Transfer Lines Outstanding" = x;
}
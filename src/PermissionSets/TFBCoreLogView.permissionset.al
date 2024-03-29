permissionset 50104 "TFB Core Log - View"
{
    Assignable = true;
    Caption = 'TFB Core Logistics - View';
    Permissions =
    tabledata "TFB Lot Expiry Buffer" = R,
        tabledata "TFB Brokerage Contract" = R,
        tabledata "TFB Brokerage Contract Line" = R,
        tabledata "TFB Location Shipping Agent" = R,
        tabledata "TFB Brokerage Shipment" = R,
        tabledata "TFB Brokerage Shipment Line" = R,
        tabledata "TFB Container Entry" = R,
        tabledata "TFB Container LifeCycle Link" = R,
        tabledata "TFB Container Route" = R,
        tabledata "TFB ContainerContents" = R,
        tabledata "TFB ContainerType" = R,
        tabledata "TFB Core Setup" = r,
        tabledata "TFB Cust. Fav. Item" = R,
        tabledata "TFB Generic Item" = R,
        tabledata "TFB Generic Item Market Rel." = R,
        tabledata "TFB Landed Cost Profile" = R,
        tabledata "TFB Reservation Strategy" = R,
        tabledata "TFB Segment Match Criteria" = R,


        codeunit "TFB Action Handlers" = x,
        codeunit "TFB Brokerage Mgmt" = x,
        codeunit "TFB Common Library" = x,
        codeunit "TFB Container Mgmt" = x,

        codeunit "TFB Cust. Collections Mgmt" = x,
        codeunit "TFB Cust. Fav. Items" = x,
        codeunit "TFB Customer Mgmt" = x,
        codeunit "TFB DropShip Automation" = x,
        codeunit "TFB Entry Summary" = x,
        codeunit "TFB Event Grid Mgmt" = x,
        codeunit "TFB Item Mgmt" = x,
        codeunit "TFB Location Mgmt" = x,
        codeunit "TFB Lot Info Mgmt" = x,
        codeunit "TFB Lot Intelligence" = x,
        codeunit "TFB Price List Management" = x,
        codeunit "TFB Pricing Calculations" = x,
        codeunit "TFB Pstd. Purch Inv. Hdr. Edit" = x,
        codeunit "TFB Pstd. Sales Inv. Hdr. Edit" = x,
        codeunit "TFB Pstd. Shipment. Hdr. Edit" = x,
        codeunit "TFB Purch. Inv. Mgmt" = x,
        codeunit "TFB Purch. Rcpt. Mgmt" = x,
        codeunit "TFB Purchase Order Mgmt" = x,
        codeunit "TFB Reservations Mgmt" = x,
        codeunit "TFB Role Centres Mgmt" = x,
        codeunit "TFB Sales Credit Mgmt" = x,
        codeunit "TFB Sales Mgmt" = x,
        codeunit "TFB Sales Order Notif. Actions" = x,
        codeunit "TFB Sales Order Notifications" = x,
        codeunit "TFB Sales Shipment Mgmt" = x,
        codeunit "TFB Transfer Order Mgmt" = x,
        codeunit "TFB Transfer Rcpt. Mgmt" = x,
        codeunit "TFB Vendor Mgmt" = x,
        codeunit "TFB Word Template Mgmt" = x,
        page "PDF Viewer" = X,
        page "PDF Viewer Part" = X,
        page "PDF Viewer Setup" = X,
        page "TFB Brokerage Contract" = X,
        page "TFB Brokerage Contract List" = X,
        page "TFB Brokerage Contract Subform" = X,
        page "TFB Brokerage Shipment" = X,
        page "TFB Brokerage Shipment Archive" = X,
        page "TFB Brokerage Shipment List" = X,
        page "TFB Brokerage Shipment Subform" = X,
        page "TFB Confirm Purchase Orders" = X,
        page "TFB Container Entry" = X,
        page "TFB Container Entry List" = X,
        page "TFB Container Entry SubForm" = X,
        page "TFB Container Routes" = X,
        page "TFB Container Types" = X,
        page "TFB Correct Ext. Doc. No." = X,
        page "TFB Cust. Cont. Stats. FactBox" = X,
        page "TFB Cust. Fav. Items" = X,
        page "TFB Generic Item" = X,
        page "TFB Generic Item Picture" = X,
        page "TFB Generic Item Segment Tags" = X,
        page "TFB Generic Items" = X,
        page "TFB Lot Add Image Wizard" = X,
        page "TFB Lot Get Image Wizard" = X,
        page "TFB Lot Images" = X,
        page "TFB Market Segment Picture" = X,
        page "TFB Pending Purch. Order Lines" = X,
        page "TFB Pending Sales Lines" = X,
        page "TFB Post Dropship from Sale" = X,
        page "TFB Postcode Zone List" = X,
        page "TFB Product Market Seg. List" = X,
        page "TFB Product Market Segment" = X,
        page "TFB Pstd. Purch. Inv. Lines" = X,
        page "TFB Pstd. Sales Inv. Lines" = X,
        page "TFB Purch. Inv. Line Factbox" = X,
        page "TFB Reservation Strategy" = X,
        page "TFB Reservation Strategy List" = X,
        page "TFB Sales Admin Activities" = X,
        page "TFB Sales Admin Role Center" = X,
        page "TFB Sales Line FactBox" = X,
        page "TFB Sales POD FactBox" = X,
        page "TFB Segment Generic Items" = X,
        query "TFB Customer Item Sales" = x,
        query "TFB Item Generic Info" = x,
        query "TFB Item Ledger Entries" = x,
        query "TFB Item Metadata" = x,
        query "TFB Items Shipped" = x,
        query "TFB Purchase Lines Outstanding" = x,
        query "TFB Sales Lines Outstanding" = x,
        query "TFB Transfer Lines Outstanding" = x;
}
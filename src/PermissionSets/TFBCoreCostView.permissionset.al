permissionset 50106 "TFB Core Cost - View"
{
    Assignable = true;
    Caption = 'TFB Core Cost - View';
    Permissions =
        tabledata "TFB Item Costing Revised" = R,
        tabledata "TFB Item Costing Revised Lines" = R,
        tabledata "TFB Location Shipping Agent" = R,

        tabledata "TFB Container Route" = R,
        tabledata "TFB ContainerType" = R,
        tabledata "TFB Core Setup" = r,
        tabledata "TFB Costing Scenario" = R,
        tabledata "TFB Forex Mgmt Entry" = r,
        tabledata "TFB Item Costing Filters" = R,
        tabledata "TFB Landed Cost Profile" = R,
        tabledata "TFB Postcode Zone" = R,
        tabledata "TFB Postcode Zone Rate" = R,
        tabledata "TFB Vendor Zone Rate" = R,

        codeunit "TFB Banking" = x,
        codeunit "TFB Common Library" = x,
        codeunit "TFB Container Mgmt" = x,
        codeunit "TFB Costing Mgmt" = x,
        codeunit "TFB DropShip Automation" = x,
        codeunit "TFB Item Mgmt" = x,
        codeunit "TFB Location Mgmt" = x,
        codeunit "TFB Price List Management" = x,
        codeunit "TFB Pricing Calculations" = x,
        codeunit "TFB Update Forex Entry Status" = x,
        codeunit "TFB Vendor Mgmt" = x,
        codeunit "TFB Word Template Mgmt" = x,


        page "TFB Gross Profit Sales Lines" = X,
        page "TFB Item Costing" = X,
        page "TFB Item Costing Factbox" = X,
        page "TFB Item Costing List" = X,
        page "TFB Item Costing Subform" = X,
        page "TFB Vend. Applied Entries FB" = X,
        page "TFB Vend. Ledg. Appl. FactBox" = X,
        page "TFB Vendor Zone Rate SubForm" = X,
        query "TFB Container Payment Sched." = x,
        query "TFB Customer Item Sales" = x,
        query "TFB Item Ledger Entries" = x,
        query "TFB Item Metadata" = x,
        query "TFB Items Shipped" = x,
        query "TFB Purchase Lines Outstanding" = x,
        query "TFB Sales Lines Outstanding" = x,
        query "TFB Transfer Lines Outstanding" = x;
}
permissionset 50101 "TFB Core Qual - Edit"
{
    Assignable = true;
    Caption = 'TFB Core Quality - Edit';
    Permissions =
    tabledata "TFB Lot Expiry Buffer" = RIMD,

        tabledata "TFB Certification Type" = RIMD,
        tabledata "TFB Company Certification" = RIMD,

        tabledata "TFB Core Setup" = r,

        tabledata "TFB Lot Image" = RIMD,

        tabledata "TFB Quality Auditor" = RIMD,
        tabledata "TFB Reservation Strategy" = RIMD,

        tabledata "TFB Sample Request" = RIMD,
        tabledata "TFB Sample Request Line" = RIMD,
        tabledata "TFB Vendor Certification" = RIMD,


        table "TFB Certification Type" = X,
        table "TFB Company Certification" = X,
        table "TFB Core Setup" = X,

         table "TFB Lot Expiry Buffer" = X,

        table "TFB Lot Image" = X,
        table "TFB Quality Auditor" = X,
        table "TFB Sample Request" = X,
        table "TFB Sample Request Line" = X,
        table "TFB Vendor Certification" = X,
        report "TFB Sample Request" = X,
        codeunit "TFB Banking" = X,
        codeunit "TFB Brokerage Mgmt" = X,
        codeunit "TFB Common Library" = X,

        codeunit "TFB Lot Info Mgmt" = X,
        codeunit "TFB Lot Intelligence" = X,
        codeunit "TFB Quality Mgmt" = X,
        codeunit "TFB Role Centres Mgmt" = X,
        codeunit "TFB Sales Mgmt" = X,
        codeunit "TFB Sample Request Mgmt" = X,
        codeunit "TFB Vendor Mgmt" = X,
        page "TFB Certification Types" = X,
        page "TFB Company Certification List" = X,
        page "TFB Lot Add Image Wizard" = X,
        page "TFB Lot Get Image Wizard" = X,
        page "TFB Lot Images" = X,
        page "TFB Quality Auditors" = X,
        page "TFB Sales Admin Activities" = X,
        page "TFB Sales Admin Role Center" = X,
        page "TFB Sales Line FactBox" = X,
        page "TFB Sales POD FactBox" = X,
        page "TFB Sample Picture" = X,
        page "TFB Sample Request" = X,
        page "TFB Sample Request List" = X,
        page "TFB Sample Request Subform" = X,
        page "TFB Segment Generic Items" = X,
        page "TFB Vendor Certification List" = X;
}
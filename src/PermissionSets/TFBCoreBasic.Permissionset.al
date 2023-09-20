permissionset 50108 "TFB Core - Basic"
{
    Assignable = true;
    Caption = 'TFB Core - Basic';
    IncludedPermissionSets = "TFB Core Cost - View", "TFB Core CRM", "TFB Core Log - View", "TFB Core Qual - View";

    Permissions = tabledata "PDF Viewer Setup" = RIMD,

        page "PDF Viewer" = X,
        page "PDF Viewer Part" = X,
        page "PDF Viewer Setup" = X,
        tabledata "TFB Core Setup" = r;

}
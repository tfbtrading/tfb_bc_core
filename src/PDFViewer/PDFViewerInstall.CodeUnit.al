codeunit 50108 "PDF Viewer Install"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if AppInfo.DataVersion() = Version.Create(0, 0, 0, 0) then
            DoFreshInstall();
    end;

    local procedure DoFreshInstall()
    var
        PDFViewerSetup: Record "PDF Viewer Setup";
        PDFViewerUrlTxt: Label 'https://bcpdfviewer.z6.web.core.windows.net/web/viewer.html?file=', Locked = true;
    begin
        PDFViewerSetup.GetRecord();
        PDFViewerSetup."Web Viewer URL" := PDFViewerUrlTxt;
        PDFViewerSetup.Modify();
    end;
}
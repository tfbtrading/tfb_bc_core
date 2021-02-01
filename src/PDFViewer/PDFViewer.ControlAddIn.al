controladdin PDFViewer
{
    StartupScript = 'js/startup.js';
    Scripts = 'js/script.js';

    HorizontalStretch = true;
    HorizontalShrink = true;
    MinimumWidth = 250;
    MinimumHeight = 400;

    event OnControlAddInReady();
    event OnPdfViewerReady();
    procedure InitializeControl(url: Text);
    procedure LoadDocument(data: JsonObject);
}
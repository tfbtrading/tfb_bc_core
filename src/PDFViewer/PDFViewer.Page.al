page 50119 "PDF Viewer"
{
    PageType = List;
    ApplicationArea = All;


    layout
    {
        area(Content)
        {
            usercontrol(PDFViewer; PDFViewer)
            {
                trigger OnControlAddInReady()
                begin
                    InitializePDFViewer();
                end;

                trigger OnPdfViewerReady()
                begin
                    ControlIsReady := true;
                    ShowData();
                end;
            }
        }
    }

    var
        ControlIsReady: Boolean;
        Data: JsonObject;
        ContentType: Option URL,BASE64;
        Content: Text;

    local procedure InitializePDFViewer()
    var
        PDFViewerSetup: Record "PDF Viewer Setup";
    begin
        PDFViewerSetup.GetRecord();
        CurrPage.PDFViewer.InitializeControl(PDFViewerSetup."Web Viewer URL");
    end;

    local procedure ShowData()
    begin
        if not ControlIsReady then
            exit;

        if not Data.Contains('content') then
            exit;

        Clear(Data);
        Data.Add('type', Format(ContentType));
        Data.Add('content', Content);
        CurrPage.PDFViewer.LoadDocument(Data);
        Clear(Data);
    end;

    procedure LoadPdfViaUrl(Url: Text)
    begin
        ContentType := ContentType::URL;
        Content := Url;
    end;

    procedure LoadPdfFromBlob(Base64Data: Text)
    begin
        ContentType := ContentType::BASE64;
        Content := Base64Data;
    end;

}
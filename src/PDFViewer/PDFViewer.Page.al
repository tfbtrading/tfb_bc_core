page 50119 "PDF Viewer"
{
    PageType = List;

    layout
    {
        area(Content)
        {
            usercontrol(PDFViewer; PDFViewer)
            {
                ApplicationArea = All;
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
        DataCache: Text;
        Dirty: Boolean;

    local procedure InitializePDFViewer()
    var
        PDFViewerSetup: Record "PDF Viewer Setup";
    begin
        PDFViewerSetup.GetRecord();
        CurrPage.PDFViewer.InitializeControl(PDFViewerSetup."Web Viewer URL");
    end;

    local procedure ShowData()
    begin
        
        CurrPage.PDFViewer.LoadDocument(Data);
        Clear(Data);
    end;

    procedure LoadPdfViaUrl(Url: Text)
    begin
        Clear(Data);
        Data.Add('type', 'url');
        Data.Add('content', Url);
    end;

    procedure LoadPdfFromBlob(Base64Data: Text)
    begin
        Clear(Data);
        Data.Add('type', 'base64');
        Data.Add('content', Base64Data);

    end;

}
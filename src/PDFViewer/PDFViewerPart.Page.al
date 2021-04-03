page 50118 "PDF Viewer Part"
{
    PageType = CardPart;
    Caption = 'PDF Viewer';

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

        CurrPage.PDFViewer.LoadDocument(Data);
  
        Clear(Data);
    end;

    procedure LoadPdfViaUrl(Url: Text)
    begin
        Clear(Data);
        Data.Add('type', 'url');
        Data.Add('content', Url);
        ShowData();
    end;

    procedure LoadPdfFromBase64(Base64Data: Text)

   
    begin
       
        Clear(Data);
        Data.Add('type', 'base64');
        Data.Add('content', Base64Data);
        ShowData();

    end;
}
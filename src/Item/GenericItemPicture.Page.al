page 50134 "TFB Generic Item Picture"
{

    Caption = 'Default Lot Image';
    PageType = CardPart;
    SourceTable = "TFB Generic Item";
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            group(General)
            {
                ShowCaption = false;
                usercontrol(WebViewer; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
                {
                    ApplicationArea = All;

                    trigger ControlAddInReady(callbackUrl: Text)
                    var

                        url: text;

                    begin

                        webviewerready := true;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ExportPicture)
            {
                Caption = 'Export';
                Image = Export;
                ToolTip = 'Export a picture file.';
                Visible = HideActions = false;

                trigger OnAction()
                begin
                    ExportItemPicture();
                end;
            }
            action(OpenLotImage)
            {
                Caption = 'Open Lot Image Record';
                Image = Find;
                ToolTip = 'Opens the underlying lot image record';
                Visible = HideActions = false;

                trigger OnAction()
                begin
                    OpenLotImageRecord();
                end;
            }

        }


    }

    trigger OnAfterGetRecord()
    var
        url: text;
        htmlTxt: label '<html><head><style> img { display:block; max-width: 100%; height: auto; margin: 0 auto;}</style><body><img src="%1" alt="generated lot image"></body></html>';
    begin
        CurrPage.WebViewer.SetContent('<html><body>');
        LotImage.SetRange("Generic Item ID", Rec.SystemId);
        LotImage.SetRange("Default for Generic Item", true);


        if LotImage.FindFirst() then begin
            if LotImage."Lot No." <> '' then
                url := CommonCU.GetLotImagesURL('gridbowl', LotImage."Isol. Image Blob Name", LotImage."Lot No.", LotImage."Item No.")
            else
                url := CommonCU.GetLotImagesURL('gridbowl', LotImage."Isol. Image Blob Name", LotImage."Item No.");
        end
        else
            url := 'https://tfbdata001.blob.core.windows.net/pubresources/images/imageplaceholder.webp';
        CurrPage.WebViewer.SetContent(StrSubstNo(htmlTxt, url));

    end;

    trigger OnOpenPage()
    begin

    end;

    var
        LotImageMediaTemp: Record "TFB Lot Image Media Temp";
        LotImage: Record "TFB Lot Image";
        LotImageMgmt: CodeUnit "TFB Lot Image Mgmt";
        CommonCU: CodeUnit "TFB Common Library";
        webviewerready: boolean;
        HideActions: Boolean;
    //MustSpecifyDescriptionErr: Label 'You must add a description to the item before you can import a picture.';










    local procedure ExportItemPicture()

    var

        ImgFileName: Text;
        TempBlob: CodeUnit "Temp Blob";
        FileName: Text;
        inStream: InStream;

    begin


        if LotImage.FindFirst() then begin
            if LotImage."Lot No." <> '' then
                TempBlob := CommonCU.GetLotImagesTempBlob('gridbowl', LotImage."Isol. Image Blob Name", LotImage."Lot No.", LotImage."Item No.")
            else
                TempBlob := CommonCU.GetLotImagesTempBlob('gridbowl', LotImage."Isol. Image Blob Name", LotImage."Item No.");
            TempBlob.CreateInStream(inStream);
            FileName := StrSubstNo('GBI - %1 %2.jpg', LotImage."Lot No.", LotImage.Description);
            DownloadFromStream(Instream, '', '', '', FileName);
        end;



    end;



    local procedure OpenLotImageRecord()
    var

    begin
        If LotImage.Count > 0 then
            Page.Run(Page::"TFB Lot Images", LotImage);
    end;




    procedure SetHideActions()
    begin
        HideActions := true;
    end;


}

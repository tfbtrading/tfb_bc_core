page 50183 "TFB Lot Image Picture"
{

    Caption = 'Lot Image';
    PageType = CardPart;
    SourceTable = "TFB Lot Image";
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

        }


    }

    trigger OnAfterGetRecord()
    var
        url: text;
        htmlTxt: label '<html><head><style> img { display:block; max-width: 100%; height: auto; margin: 0 auto;}</style><body><img src="%1" alt="generated lot image"></body></html>';
    begin
        CurrPage.WebViewer.SetContent('<html><body></body></html>');


        if Rec."Lot No." <> '' then
            url := CommonCU.GetLotImagesURL('gridbowl', Rec."Isol. Image Blob Name", Rec."Lot No.", Rec."Item No.")
        else
            url := CommonCU.GetLotImagesURL('gridbowl', Rec."Isol. Image Blob Name", Rec."Item No.");
        CurrPage.WebViewer.SetContent(StrSubstNo(htmlTxt, url));
    end;

    trigger OnOpenPage()
    begin

    end;

    var

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



        if Rec."Lot No." <> '' then
            TempBlob := CommonCU.GetLotImagesTempBlob('gridbowl', Rec."Isol. Image Blob Name", Rec."Lot No.", Rec."Item No.")
        else
            TempBlob := CommonCU.GetLotImagesTempBlob('gridbowl', Rec."Isol. Image Blob Name", Rec."Item No.");
        TempBlob.CreateInStream(inStream);
        FileName := StrSubstNo('GBI - %1 %2.jpg', Rec."Lot No.", Rec.Description);
        DownloadFromStream(Instream, '', '', '', FileName);




    end;






    procedure SetHideActions()
    begin
        HideActions := true;
    end;


}

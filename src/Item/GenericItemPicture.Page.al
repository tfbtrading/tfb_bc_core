page 50134 "TFB Generic Item Picture"
{

    Caption = 'Image';
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
                field(Picture; Rec.Picture)
                {
                    ShowCaption = false;
                    ToolTip = 'Specifies the picture that has been inserted for the item.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(TakePicture)
            {
                Caption = 'Take';
                Image = Camera;

                ToolTip = 'Activate the camera on the device.';
                Visible = CameraAvailable and (HideActions = false);

                trigger OnAction()
                begin
                    TakeNewPicture();
                end;
            }
            action(ImportPicture)
            {
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a picture file.';
                Visible = HideActions = false;

                trigger OnAction()
                begin
                    ImportItemPicture();
                end;
            }
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

            action(DeletePicture)
            {
                Caption = 'Delete';
                Enabled = DeleteExportEnabled;
                Image = Delete;
                ToolTip = 'Delete the record.';
                Visible = HideActions = false;

                trigger OnAction()
                begin
                    DeleteItemPicture();
                end;
            }
        }


    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEditableOnPictureActions();
    end;

    trigger OnOpenPage()
    begin
        CameraAvailable := Camera.IsAvailable();
    end;

    var
        Camera: Codeunit Camera;

        CameraAvailable: Boolean;
        //OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        //SelectPictureTxt: Label 'Select a picture to upload';
        DeleteImageQst: Label 'Are you sure you want to delete the picture?';
        DeleteExportEnabled: Boolean;
        HideActions: Boolean;
    //MustSpecifyDescriptionErr: Label 'You must add a description to the item before you can import a picture.';

    procedure TakeNewPicture()
    var
        TempBlob: CodeUnit "Temp Blob";
        InStream: InStream;
        PictureName: Text;
    begin
        Rec.Find();
        Rec.TestField(Description);
        TempBlob.CreateInStream();

        Camera.GetPicture(InStream, PictureName);
        Rec.Picture.ImportStream(InStream, PictureName);
    end;



    local procedure SetEditableOnPictureActions()
    begin
        DeleteExportEnabled := Rec.Picture.Count <> 0;
    end;

    local procedure ImportItemPicture()
    var
        FileManagement: CodeUnit "File Management";
        TempBlob: CodeUnit "Temp Blob";
        Instream: Instream;
        ImgFileName: Text;
        FileFilterTxt: Label 'Image file(*.png, *.jpg)|*.png;*.jpg';
        ExtFilterTxt: Label 'jpg,jpeg,png';
        ConfMsg: Label 'The existing picture will be overwritten, do you want to continue?';


    begin
        if Rec.Picture.count > 0 then
            if not confirm(ConfMsg) then
                exit;

        ImgFileName := FileManagement.BLOBImportWithFilter(TempBlob, 'Import Image', ImgFileName, FileFilterTxt, ExtFilterTxt);

        if TempBlob.HasValue() then begin

            TempBlob.CreateInStream(Instream);
            Clear(Rec.Picture);
            Rec.Picture.ImportStream(Instream, ImgFileName);
            Rec.Modify(true);

        end;
    end;


    local procedure ExportItemPicture()

    var
        TenantMedia: Record "Tenant Media";
        Instream: Instream;
        ConfMsg: Label 'No picture stored';
        Index: Integer;
        ImgFileName: Text;


    begin
        if Rec.Picture.Count = 0 then
            Error(ConfMsg);

        for Index := 1 to Rec.Picture.count do
            if TenantMedia.Get(Rec.Picture.Item(Index)) then begin
                TenantMedia.CalcFields(content);
                if TenantMedia.Content.HasValue then begin
                    ImgFileName := ConvertStr(Rec.TableCaption + '_' + format(Rec.Description) + GetImgFileExt(TenantMedia), ' ', '_');
                    TenantMedia.Content.CreateInStream(Instream);
                    DownloadFromStream(Instream, '', '', '', ImgFileName);

                end;
            end;

    end;

    local procedure GetImgFileExt(var TenantMedia: Record "Tenant Media"): Text
    begin
        case TenantMedia."Mime Type" of
            'image/jpeg':
                exit('.jpeg');
            'image/png':
                exit('.png');
            'image/bmp':
                exit('.bmp');
            'image/gif':
                exit('.gif');
            'image/tiff':
                exit('.tiff');

        end
    end;

    procedure IsCameraAvailable(): Boolean
    begin
        exit(Camera.IsAvailable());
    end;

    procedure SetHideActions()
    begin
        HideActions := true;
    end;

    procedure DeleteItemPicture()
    begin
        Rec.TestField(Description);

        if not Confirm(DeleteImageQst) then
            exit;

        Clear(Rec.Picture);
        Rec.modify(true);
    end;
}

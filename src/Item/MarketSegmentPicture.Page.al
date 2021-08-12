page 50137 "TFB Market Segment Picture"
{

    Caption = 'Image';
    PageType = CardPart;
    SourceTable = "TFB Product Market Segment";
    InsertAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                ShowCaption = false;
                field(Picture; Rec.Picture)
                {
                    ApplicationArea = All;
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
                ApplicationArea = All;
                Caption = 'Take';
                Image = Camera;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Activate the camera on the device.';
                Visible = CameraAvailable AND (HideActions = FALSE);

                trigger OnAction()
                begin
                    TakeNewPicture();
                end;
            }
            action(ImportPicture)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a picture file.';
                Visible = HideActions = FALSE;

                trigger OnAction()
                begin
                    ImportItemPicture();
                end;
            }
            action(ExportPicture)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Image = Export;
                ToolTip = 'Export a picture file.';
                Visible = HideActions = FALSE;

                trigger OnAction()
                begin
                    ExportItemPicture();
                end;
            }

            action(DeletePicture)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                Enabled = DeleteExportEnabled;
                Image = Delete;
                ToolTip = 'Delete the record.';
                Visible = HideActions = FALSE;

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
        [InDataSet]
        CameraAvailable: Boolean;

        DeleteImageQst: Label 'Are you sure you want to delete the picture?';
        //SelectPictureTxt: Label 'Select a picture to upload';
        //MustSpecifyDescriptionErr: Label 'You must add a description to the item before you can import a picture.';
        //OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        DeleteExportEnabled: Boolean;
        HideActions: Boolean;

    procedure TakeNewPicture()
    begin
        Rec.Find();
        Rec.TestField(Description);


        Camera.AddPicture(Rec, Rec.FieldNo(Picture));
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
        FileFilterTxt: Label 'All files (*.*)|*.*';
        FileDialogTxt: Label 'Choose an image to upload';
        ConfMsg: Label 'The existing picture will be overwritten, do you want to continue?';


    begin
        If Rec.Picture.count > 0 then
            If not confirm(ConfMsg) then
                exit;

        ImgFileName := FileManagement.BLOBImportWithFilter(TempBlob, 'Import Image', ImgFileName, '', 'All files (*.*)|*.*');

        If TempBlob.HasValue() then begin

            Clear(Rec.Picture);
            Rec.Picture.ImportStream(Instream, ImgFileName);
            Rec.Modify(true);
        end;
    end;

    local procedure ExportItemPicture()

    var
        TenantMedia: Record "Tenant Media";
        Instream: Instream;
        Index: Integer;
        ImgFileName: Text;
        ConfMsg: Label 'No picture stored';


    begin
        If Rec.Picture.Count = 0 then
            Error(ConfMsg);

        for Index := 1 to Rec.Picture.count do
            If TenantMedia.Get(Rec.Picture.Item(Index)) then begin
                TenantMedia.CalcFields(content);
                If TenantMedia.Content.HasValue then begin
                    ImgFileName := Rec.TableCaption + '_Image' + format(Index) + GetImgFileExt(TenantMedia);
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

page 50155 "TFB Sample Picture"
{
    Caption = 'Sample Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = "Lot No. Information";

    layout
    {
        area(content)
        {
            field(Picture; Rec."TFB Sample Picture")
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the picture that has been inserted for the sample of the lot.';
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
                    ImportFromDevice();
                end;
            }
            action(ExportFile)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Enabled = DeleteExportEnabled;
                Image = Export;
                ToolTip = 'Export the sample picture to a file.';
                Visible = HideActions = FALSE;

                trigger OnAction()

                begin
                    ExportSamplePicture(Rec);
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
        SetEditableOnPictureActions;
    end;

    trigger OnOpenPage()
    begin
        CameraAvailable := Camera.IsAvailable();
    end;


    var
        Camera: Codeunit Camera;
        [InDataSet]
        CameraAvailable: Boolean;
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        DeleteImageQst: Label 'Are you sure you want to delete the picture?';
        SelectPictureTxt: Label 'Select a picture to upload';
        DeleteExportEnabled: Boolean;
        HideActions: Boolean;
        MustSpecifyDescriptionErr: Label 'You must add a description to the item before you can import a picture.';


    local procedure ExportSamplePicture(LotInfo: Record "Lot No. Information")

    var
        TenantMedia: Record "Tenant Media";
        InStream: InStream;
        Index: Integer;
        ImgFileName: Text;
        NoImgMsg: Label 'No picture stored.';

    begin
        If LotInfo."TFB Sample Picture".count = 0 then
            Error(NoImgMsg);

        for index := 1 to LotInfo."TFB Sample Picture".count do
            If TenantMedia.Get(LotInfo."TFB Sample Picture".Item(Index)) then begin
                TenantMedia.CalcFields(Content);
                If TenantMedia.Content.HasValue() then begin
                    ImgFileName := StrSubstNo('Item %1 Lot %2 Sample.%3', LotInfo."Item No.", LotInfo."Lot No.", GetImgFileExt(TenantMedia));
                    TenantMedia.Content.CreateInStream(InStream);
                    DownloadFromStream(InStream, '', '', '', ImgFileName);
                end;

            end;

    end;

    local procedure GetImgFileExt(var TenantMedia: record "Tenant Media"): Text

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
        end;

    end;

    procedure TakeNewPicture()
    begin
        Rec.Find();
        Rec.TestField("Lot No.");
        Rec.TestField("Item No.");

        OnAfterTakeNewPicture(
            Rec,
            Camera.AddPicture(Rec, Rec.FieldNo("TFB Sample Picture")));
    end;


    procedure ImportFromDevice()
    var

        FileName: Text;
        ClientFileName: Text;
        FromFilter: Text;
        InStream: InStream;
        OutStream: OutStream;
    begin
        Rec.Find();
        Rec.TestField("Lot No.");
        Rec.TestField("Item No.");
        FromFilter := 'Image Files|*.jpg;*.jpeg*;*.png;*.bmp';


        if Rec."TFB Sample Picture".Count > 0 then
            if not Confirm(OverrideImageQst) then
                Error('');

        ClientFileName := '';
        If not UploadIntoStream('Select an image for lot sample', '', FromFilter, ClientFileName, InStream) then exit;


        Clear(Rec."TFB Sample Picture");
        Rec."TFB Sample Picture".ImportStream(InStream, 'LotImage');
        Rec.Modify(true);
        OnImportFromDeviceOnAfterModify(Rec);
    end;

    local procedure SetEditableOnPictureActions()
    begin
        DeleteExportEnabled := Rec."TFB Sample Picture".Count <> 0;
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
        Rec.TestField("Lot No.");
        Rec.TestField("Item No.");

        if not Confirm(DeleteImageQst) then
            exit;

        Clear(Rec."TFB Sample Picture");
        Rec.Modify(true);

        OnAfterDeleteSamplePicture(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteSamplePicture(var LotInfo: Record "Lot No. Information")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTakeNewPicture(var LotInfo: Record "Lot No. Information"; IsPictureAdded: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnImportFromDeviceOnAfterModify(var LotInfo: Record "Lot No. Information")
    begin
    end;
}


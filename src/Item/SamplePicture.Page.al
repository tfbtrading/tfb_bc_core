page 50155 "TFB Sample Picture"
{
    Caption = 'Sample Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = "Lot No. Information";
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            field(Picture; Rec."TFB Sample Picture")
            {
                ShowCaption = false;
                ToolTip = 'Specifies the picture that has been inserted for the sample of the lot.';
            }
        }
    }

    actions
    {
        area(processing)
        {

            action(ExportFile)
            {
                Caption = 'Export';
                Enabled = DeleteExportEnabled;
                Image = Export;
                ToolTip = 'Export the sample picture to a file.';
                Visible = HideActions = false;

                trigger OnAction()

                begin
                    ExportSamplePicture(Rec);
                end;
            }

        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEditableOnPictureActions();
    end;

  


    var
        Camera: Codeunit Camera;
    
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        DeleteImageQst: Label 'Are you sure you want to delete the picture?';
    
        DeleteExportEnabled: Boolean;
        HideActions: Boolean;
     


    local procedure ExportSamplePicture(LotInfo: Record "Lot No. Information")

    var
        TenantMedia: Record "Tenant Media";
        InStream: InStream;
        Index: Integer;
        ImgFileName: Text;
        NoImgMsg: Label 'No picture stored.';

    begin
        if LotInfo."TFB Sample Picture".count = 0 then
            Error(NoImgMsg);

        for index := 1 to LotInfo."TFB Sample Picture".count do
            if TenantMedia.Get(LotInfo."TFB Sample Picture".Item(Index)) then begin
                TenantMedia.CalcFields(Content);
                if TenantMedia.Content.HasValue() then begin
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




    procedure ImportFromDevice()
    var

    
        ClientFileName: Text;
        FromFilter: Text;
        InStream: InStream;
    
    begin
        Rec.Find();
        Rec.TestField("Lot No.");
        Rec.TestField("Item No.");
        FromFilter := 'Image Files|*.jpg;*.jpeg*;*.png;*.bmp';


        if Rec."TFB Sample Picture".Count > 0 then
            if not Confirm(OverrideImageQst) then
                Error('');

        ClientFileName := '';
        if not UploadIntoStream('Select an image for lot sample', '', FromFilter, ClientFileName, InStream) then exit;


        Clear(Rec."TFB Sample Picture");
        Rec."TFB Sample Picture".ImportStream(InStream, 'LotImage');
        if Rec."TFB Sample Picture".Count <> 0 then Rec."TFB Sample Picture Exists" := true;
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
        Rec."TFB Sample Picture Exists" := false;
        Rec.Modify(true);

        OnAfterDeleteSamplePicture(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteSamplePicture(var LotInfo: Record "Lot No. Information")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnImportFromDeviceOnAfterModify(var LotInfo: Record "Lot No. Information")
    begin
    end;
}


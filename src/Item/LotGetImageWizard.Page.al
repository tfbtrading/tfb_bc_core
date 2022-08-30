page 50171 "TFB Lot Get Image Wizard"
{
    Caption = 'Welcome to the Lot Image Wizard';
    PageType = NavigatePage;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to PageName")
                {
                    Caption = 'First lets get the blob details';
                    Visible = Step1Visible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'For a start we are going to collect the blob id';

                        field(BlobName; _BlobName)
                        {
                            ApplicationArea = All;
                            Caption = 'Blob name';
                        }
                    }
                }

            }

            group(Step2)
            {
                Caption = '';
                InstructionalText = 'Next choose types of images to download.';
                Visible = Step2Visible;
                //You might want to add fields here

                field(GridActive; _GridActive)
                {
                    Caption = 'Grid Image';
                    ApplicationArea = All;
                }
                field(CropActive; _CropActive)
                {
                    Caption = 'Cropped Image';
                    ApplicationArea = All;
                }
                field(IsolatedActive; _IsolatedActive)
                {
                    Caption = 'Isolated Image';
                    ApplicationArea = All;
                }
            }


            group(Step3)
            {
                Visible = Step3Visible;
                group(Group23)
                {
                    Caption = '';
                    InstructionalText = 'Secton whether to download or email images';

                    field(Email; _EmailImages)
                    {
                        Caption = 'Email Images';
                        ApplicationArea = All;

                    }
                }
                group("That's it!")
                {
                    Caption = 'That''s it!';
                    group(Group25)
                    {
                        Caption = '';
                        InstructionalText = 'To take action, choose Finish.';
                    }
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    var
        StorageServiceAuth: CodeUnit "Storage Service Authorization";
        SharedKey: Text;
        ContainerName: Text;
        StorageAccount: Text;
    //RecordVar: Record "TableName";
    begin
        /*         Rec.Init();
                if RecordVar.Get() then
                    Rec.TransferFields(RecordVar);

                Rec.Insert(); */

        Step := Step::Start;
        EnableControls();
        ContainerName := 'images';
        StorageAccount := 'tfbmanipulator';
        SharedKey := 'ZcRda2sapxTDjYc3nfGFN0UpDK5XQiq3lDgQ8iP2WEkdnleReEo+pbKVzMbPOpOKj8ZatNM7PugEQrp+MeVkjA==';
        Authorization := StorageServiceAuth.CreateSharedKey(SharedKey);
        ABSClient.Initialize(StorageAccount, ContainerName, Authorization);
        ABSClient.SetBaseUrl('https://tfbmanipulator.blob.core.windows.net');
    end;




    var
        _BlobName: Text[100];
        _CropActive: Boolean;
        _GridActive: Boolean;
        _IsolatedActive: Boolean;
        _EmailImages: Boolean;
        ABSClient: CodeUnit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        Step: Option Start,Step2,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        TopBannerVisible: Boolean;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep1();
            Step::Step2:
                ShowStep2();
            Step::Finish:
                ShowStep3();
        end;
    end;

    local procedure StoreRecordVar();
    var
    //RecordVar: Record "TableName";
    begin
        /*     if not RecordVar.Get() then begin
                RecordVar.Init();
                RecordVar.Insert();
            end;

            RecordVar.TransferFields(Rec, false);
            RecordVar.Modify(true); */
    end;


    local procedure FinishAction();
    begin
        StoreRecordVar();

        If (_BlobName <> '') and _IsolatedActive then begin
            Message('Now downloading isolated image');
            DownloadIsolatedImage();
        end;

        If _GridActive then begin
            Message('Now downloading grid image');
            DownloadGridImage();
        end;
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowStep1();
    begin
        Step1Visible := true;

        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowStep2();
    begin
        Step2Visible := true;
    end;

    local procedure ShowStep3();
    begin
        Step3Visible := true;

        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        Step1Visible := false;
        Step2Visible := false;
        Step3Visible := false;
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
            MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
                MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
        then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure DownloadIsolatedImage()

    var
        TempBlob: CodeUnit "Temp Blob";
        ABSOperationResponse: CodeUnit "ABS Operation Response";
        inStream: InStream;
        outStream: OutStream;
        fileName: Text;
    begin

        ABSOperationResponse := ABSClient.GetBlobAsStream('isolated/' + _BlobName, inStream);
        IF ABSOperationResponse.IsSuccessful() then begin
            filename := _BlobName + '.jpeg';
            DownloadFromStream(inStream, 'Downloaded File', '', '', fileName);
        end
        else
            Message('Error from Azure Storage: %1', ABSOperationResponse.GetError());

    end;


    procedure DownloadGridImage()


    var
        CommonCU: CodeUnit "TFB Common Library";
        TempBlobCU: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;

    begin

        TempBlobCU := CommonCU.GetLotImagesTempBlob('grid', _BlobName);
        TempBlobCu.CreateInStream(InStream);
        FileName := StrSubstNo('LotImage %1.png', _BlobName);
        If not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
            Error('File %1 not downloaded', FileName);

    end;
}
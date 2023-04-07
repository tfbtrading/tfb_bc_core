page 50171 "TFB Lot Get Image Wizard"
{
    Caption = 'Welcome to the Lot Image Wizard';
    PageType = NavigatePage;
    UsageCategory = None;
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = 'Get a lot image for item ledger ';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = 'Nearly finished';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to PageName")
                {
                    Caption = 'First check when you last got an image';
                    Visible = Step1Visible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'First we will just confirm a few details';

                        field(CountOfImages; _Count)
                        {
                            Editable = false;
                            Caption = 'No. of lot images';
                            ToolTip = 'Specifies how many lot images have been uploaded for this item ledger entry';
                        }
                        field(LastCreated; _LastCreated)
                        {
                            Editable = false;
                            Caption = 'Last created on';
                            ToolTip = 'Specifies the date the last image was uploaded';
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
                    ToolTip = 'Specifies whether to download a image with only product and overlaid grid';
                }
                field(GridBowlActive; _GridBowlActive)
                {
                    Caption = 'Grid over Bowl Image';
                    ToolTip = 'Specifies whether to download a image within bowl and with overlaid grid and information.';
                }
                field(CropActive; _CropActive)
                {
                    Caption = 'Cropped Image';
                    ToolTip = 'Specifies whether to download just a cropped, zoomed image of product without bowl.';
                }
                field(IsolatedActive; _IsolatedActive)
                {
                    Caption = 'Isolated Image';
                    ToolTip = 'Specifies whether to download original isolated image.';
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
                        ToolTip = 'Specifies the value of the Email Images field.';

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
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Back action.';
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Next action.';
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Executes the Finish action.';
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

    begin

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

        LotImage: Record "TFB Lot Image";
        LedgerEntry: Record "Item Ledger Entry";
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        ABSClient: CodeUnit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        Step: Option Start,Step2,Finish;
        _BlobName: Text[100];
        _CropActive: Boolean;
        _GridActive: Boolean;
        _IsolatedActive: Boolean;
        _GridBowlActive: Boolean;
        _EmailImages: Boolean;
        _Count: Integer;
        _LastCreated: DateTime;
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


    procedure InitFromItemLedger(LedgerEntry2: Record "Item Ledger Entry")

    begin
        LedgerEntry := LedgerEntry2;
        LotImage.SetFiltersFromItemLedgerEntry(LedgerEntry2);
        _Count := LotImage.Count();
        case _Count of
            1:
                begin

                    LotImage.FindFirst();
                    _BlobName := LotImage."Isol. Image Blob Name";
                    _LastCreated := LotImage.SystemCreatedAt;
                end;

            2 .. 100:
                begin

                    if not Confirm('There are %1 lot images stored for this ledger entry. Choose latest?', true, _Count) then exit;

                    LotImage.FindLast();
                    _BlobName := LotImage."Isol. Image Blob Name";
                    _LastCreated := LotImage.SystemCreatedAt;
                end;

            0:
                error('No lot image available');

        end;


    end;


    local procedure FinishAction();
    begin


        if (_BlobName <> '') and _IsolatedActive then begin
            Message('Now downloading isolated image');
            DownloadIsolatedImage();
        end;

        if (_BlobName <> '') and _GridActive then begin
            Message('Now downloading grid image');
            DownloadGridImage();
        end;

        if (_BlobName <> '') and _GridBowlActive then begin
            Message('Now downloading grid bowl image');
            DownloadGridBowlImage();
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
   
        ABSOperationResponse: CodeUnit "ABS Operation Response";
        inStream: InStream;
     
        fileName: Text;
    begin

        ABSOperationResponse := ABSClient.GetBlobAsStream('isolated/' + _BlobName, inStream);
        FileName := StrSubstNo('LII %1 - lot %2.png', LedgerEntry.Description, LedgerEntry."Lot No.");
        if ABSOperationResponse.IsSuccessful() then
            DownloadFromStream(inStream, 'Downloaded File', '', '', fileName)
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
        FileName := StrSubstNo('LGI %1 - lot %2.jpg', LedgerEntry.Description, LedgerEntry."Lot No.");
        if not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
            Error('File %1 not downloaded', FileName);

    end;

    procedure DownloadGridBowlImage()


    var
        CommonCU: CodeUnit "TFB Common Library";
        TempBlobCU: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;

    begin

        TempBlobCU := CommonCU.GetLotImagesTempBlob('gridbowl', _BlobName, LedgerEntry."Lot No.", LedgerEntry."Item No.");
        TempBlobCu.CreateInStream(InStream);
        FileName := StrSubstNo('LGI %1 - lot %2.jpg', LedgerEntry.Description, LedgerEntry."Lot No.");
        if not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
            Error('File %1 not downloaded', FileName);

    end;
}
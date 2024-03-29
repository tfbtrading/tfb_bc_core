page 50172 "TFB Lot Add Image Wizard"
{
    Caption = 'Welcome to the add Lot Image Wizard';
    PageType = NavigatePage;

    UsageCategory = None;
    ApplicationArea = All;


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
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to PageName")
                {
                    Caption = 'First lets confirm some details';
                    Visible = Step1Visible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'For a start we are going to check lot details and get bowl size for the image';

                        field("Item No."; TempLotImage."Item No.")
                        {
                            Editable = false;
                            ToolTip = 'Specifies the value of the Item No. field.';

                        }
                        field("Lot No."; TempLotImage."Lot No.")
                        {
                            Editable = false;
                            ToolTip = 'Specifies the value of the Lot No field.';

                        }
                        field(BowlDiameter; _BowlDiameter)
                        {
                            Caption = 'Bow Diameter (cm)';
                            NotBlank = true;
                            Editable = true;
                            MinValue = 1;
                            MaxValue = 300;
                            ToolTip = 'Specifies the value of the _BowlDiameter field.';
                        }
                    }
                }

            }

            group(Step2)
            {
                Caption = '';
                InstructionalText = 'Confirm image was processed okay';
                Visible = Step2Visible;
                //You might want to add fields here


                usercontrol(WebViewer; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
                {

                    trigger ControlAddInReady(callbackUrl: Text)
                    var
                        //TypeHelper: Codeunit "Type Helper";
                        CommonLibrary: CodeUnit "TFB Common Library";
                        HTMLTemplate: Text;
                        UrlLbl: Label 'https://tfbmanipulator.blob.core.windows.net/images/%1', Comment = '%1 = message content';
                    begin


                        CurrPage.WebViewer.InitializeIFrame('4:3');
                        HTMLTemplate := CommonLibrary.GetHTMLScaledImageTemplate(StrSubstNo(UrlLbl, TempLotImage."Orig. Image Blob Name"), TempLotImage.Description);
                        CurrPage.WebViewer.SetContent(HTMLTemplate);
                    end;
                }
            }


            group(Step3)
            {
                Visible = Step3Visible;

                group("That's it!")
                {
                    Caption = 'That''s it!';
                    group(Group25)
                    {
                        Caption = '';
                        InstructionalText = 'To take action, choose Finish. Processing of the image make take 3-10 seconds.';
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

        TempLotImage: Record "TFB Lot Image" temporary;
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        ABSClient: CodeUnit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";

        OriginalBlobGUID: Guid;
        _BowlDiameter: Integer;


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

    procedure InitFromItemLedgerID(itemLedgerID: Guid)

    begin
        TempLotImage.Init();
        TempLotImage.InitFromItemLedgerEntryID(itemLedgerID);
        _BowlDiameter := 110;
    end;

    local procedure StoreRecordVar();
    var
        RecordVar: Record "TFB Lot Image";
    begin

        RecordVar.Init();
        RecordVar.TransferFields(TempLotImage, true);
        RecordVar."Import Sequence No." := RecordVar.GetNextSequence();
        RecordVar.Insert(true);

    end;


    local procedure FinishAction();

    var
        CommonCU: CodeUnit "TFB Common Library";
        TempBlobCU: Codeunit "Temp Blob";

    begin

        TempBlobCU := CommonCU.GetIsolatedImagesTempBlob(TempLotImage."Orig. Image Blob Name", _BowlDiameter);

        if UploadIsolatedFile(TempBlobCU) then
            StoreRecordVar();

        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;
        if Step = Step::Step2 then
            UploadOriginalFile();
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



    local procedure UploadOriginalFile(): Boolean
    var

        ABSOperationResponse: CodeUnit "ABS Operation Response";

        inStream: InStream;

        fileName: Text[100];
        fileExtension: text;
        FromFilter: Text;
        ClientFileName: Text;
        OverrideImageQst: Label 'Image already exists - do you want to override?';

    begin



        FromFilter := 'Image Files|*.jpg;*.jpeg*;*.png;*.bmp';


        if TempLotImage."Original Image".Count > 0 then
            if not Confirm(OverrideImageQst) then
                Error('');

        ClientFileName := '';
        if not UploadIntoStream('Select an image for lot sample', '', FromFilter, ClientFileName, InStream) then exit;
        FileExtension := Text.CopyStr(ClientFileName, Text.StrPos(ClientFileName, '.'));
        OriginalBlobGUID := CreateGuid();
        fileName := Text.DelChr(format(OriginalBlobGUID), '=', '{}') + fileExtension;
        ABSOperationResponse := ABSClient.PutBlobBlockBlobStream(fileName, inStream);
        if ABSOperationResponse.IsSuccessful() then begin
            TempLotImage."Orig. Image Blob Name" := fileName;
            exit(true)
        end
        else
            Message('Error from Azure Storage: %1', ABSOperationResponse.GetError());

    end;

    local procedure UploadIsolatedFile(var TempBlob: Codeunit "Temp Blob"): Boolean
    var

        ABSOperationResponse: CodeUnit "ABS Operation Response";
        instream: instream;

        fileName: Text[100];

        fileExtension: text;


    begin

        if TempBlob.Length() < 2000 then Error('Error: file returned via API appears to be too small');
        fileExtension := '.png';
        fileName := Text.DelChr(format(CreateGuid()), '=', '{}') + fileExtension;
        TempLotImage."Isol. Image Blob Name" := fileName;



        TempBlob.CreateInStream(instream);
        ABSOperationResponse := ABSClient.PutBlobBlockBlobStream('isolated/' + fileName, inStream);
        if ABSOperationResponse.IsSuccessful() then
            exit(true)
        else
            Error('Error from Azure Storage: %1', ABSOperationResponse.GetError());

    end;



}
page 50172 "TFB Lot Add Image Wizard"
{
    Caption = 'Welcome to the add Lot Image Wizard';
    PageType = NavigatePage;
    SourceTable = "TFB Lot Image";
    SourceTableTemporary = true;
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
                    Caption = 'First lets confirm some details';
                    Visible = Step1Visible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'For a start we are going to check lot details and get bowl size for the image';

                        field("Item No."; Rec."Item No.")
                        {
                            ApplicationArea = All;
                            Editable = false;

                        }
                        field("Lot No."; Rec."Lot No.")
                        {
                            ApplicationArea = All;
                            Editable = false;

                        }
                        field(BowlDiameter; _BowlDiameter)
                        {
                            NotBlank = true;
                            Editable = true;
                            MinValue = 1;
                            MaxValue = 300;
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

                field("Original Image"; Rec."Original Image")
                {
                    ApplicationArea = All;
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
        OriginalBlobGUID: Guid;
        _BowlDiameter: Integer;
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

    var
        CommonCU: CodeUnit "TFB Common Library";
        TempBlobCU: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;
    begin
        StoreRecordVar();



        TempBlobCU := CommonCU.GetIsolatedImagesTempBlob(OriginalBlobGUID);

        UploadIsolatedFile(TempBlobCU);

        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;
        If Step = Step::Step2 then
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

    local procedure UploadOriginalFile(): Boolean
    var
        TempBlob: CodeUnit "Temp Blob";
        ABSOperationResponse: CodeUnit "ABS Operation Response";
        inStream: InStream;
        outStream: OutStream;
        fileName: Text;
        FromFilter: Text;
        ClientFileName: Text;
        OverrideImageQst: Label 'Image already exists - do you want to override?';

    begin


        Rec.Find();
        Rec.TestField("Lot No.");
        Rec.TestField("Item No.");
        FromFilter := 'Image Files|*.jpg;*.jpeg*;*.png;*.bmp';


        if Rec."Original Image".Count > 0 then
            if not Confirm(OverrideImageQst) then
                Error('');

        ClientFileName := '';
        If not UploadIntoStream('Select an image for lot sample', '', FromFilter, ClientFileName, InStream) then exit;

        OriginalBlobGUID := CreateGuid();
        ABSOperationResponse := ABSClient.PutBlobBlockBlobStream(OriginalBlobGUID, inStream);
        IF ABSOperationResponse.IsSuccessful() then begin
            Clear(Rec."Original Image");
            Rec."Original Image".ImportStream(InStream, 'LotImage');
            exit(true)
        end
        else
            Message('Error from Azure Storage: %1', ABSOperationResponse.GetError());

    end;

    local procedure UploadIsolatedFile(var TempBlob: Codeunit "Temp Blob"): Boolean
    var

        ABSOperationResponse: CodeUnit "ABS Operation Response";
        instream: instream;
        outStream: OutStream;
        fileName: Text;
        FromFilter: Text;
        ClientFileName: Text;
        OverrideImageQst: Label 'Image already exists - do you want to override?';

    begin



        Rec."Isol. Image Blob Name" := CreateGuid();
        ABSOperationResponse := ABSClient.PutBlobBlockBlobStream('isolated/' + OriginalBlobGUID, inStream);
        IF ABSOperationResponse.IsSuccessful() then begin
            Clear(Rec."Isolated Image");
            Rec."Isolated Image".ImportStream(InStream, 'LotImage');
            exit(true)
        end
        else
            Message('Error from Azure Storage: %1', ABSOperationResponse.GetError());

    end;



}
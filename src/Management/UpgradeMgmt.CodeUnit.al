codeunit 50103 "TFB Upgrade Mgmt"
{

    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerCompany()

    var


    begin


    end;

    trigger OnUpgradePerCompany()

    begin
        if CheckIfUpgradeCodeRequired() then
            PerformUpgrades();

    end;

    local procedure PerformUpgrades()

    begin
        UpdateLotImagesWithDefaults();
    end;

    procedure GetInstallingVersionNo(): Text
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(FORMAT(AppInfo.AppVersion()));
    end;

    procedure GetCurrentlyInstalledVersionNo(): Text
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(FORMAT(AppInfo.DataVersion()));
    end;

    local procedure CheckIfUpgradeCodeRequired(): Boolean

    var
    begin
        exit((GetInstallingVersionNo() = '22.0.2.46'))
    end;












    procedure CopyQualityAttachToPersBlob()

    var
        VendorCert: Record "TFB Vendor Certification";
        PersBlob: CodeUnit "Persistent Blob";
        PersKey: BigInteger;
        InStream: InStream;

    begin

        if VendorCert.Findset(true) then
            repeat
                Clear(PersBlob);
                VendorCert.CalcFields(Certificate);
                if VendorCert.Certificate.HasValue then begin
                    PersKey := PersBlob.Create();
                    VendorCert.Certificate.CreateInStream(InStream);
                    if PersBlob.CopyFromInStream(PersKey, InStream) then begin
                        VendorCert."Certificate Attach." := PersKey;
                        Clear(VendorCert.Certificate);
                        VendorCert.Modify(false);
                    end;
                end;

            until VendorCert.Next() < 1;


    end;

    procedure UpdateLotImagesWithDefaults()
    var
        LotImage: record "TFB Lot Image";
        LotImage2: record "TFB Lot Image";
        LotImage3: record "TFB Lot Image";
    begin

        LotImage.SetCurrentKey("Item No.", SystemCreatedAt);
        LotImage.SetAscending(SystemCreatedAt, false);

        if not LotImage.FindSet(true) then exit;
        repeat

            if LotImage."Item No." <> '' then begin
                LotImage3.SetFilter("Item No.", '%1', LotImage."Item No.");
                LotImage3.SetRange("Default for Item", true);
                if LotImage3.IsEmpty then
                    LotImage."Default for Item" := true;
            end;
            LotImage.CalcFields("Generic Item ID");

            if not IsNullGuid(LotImage."Generic Item ID") then begin
                LotImage2.SetFilter("Generic Item ID", '%1', LotImage."Generic Item ID");
                LotImage2.SetRange("Default for Generic Item", true);
                if LotImage2.IsEmpty then
                    LotImage."Default for Generic Item" := true;
            end;

            LotImage.Modify(false);
        until LotImage.Next() = 0;



    end;

    procedure CopyCoAAttachToPersBlob()

    var
        LotInfo: Record "Lot No. Information";
        PersBlob: CodeUnit "Persistent Blob";
        PersKey: BigInteger;
        InStream: InStream;

    begin

        if LotInfo.Findset(true) then
            repeat
                Clear(PersBlob);
                LotInfo.CalcFields("TFB CoA Attachment");
                if LotInfo."TFB CoA Attachment".HasValue then begin
                    PersKey := PersBlob.Create();
                    LotInfo."TFB CoA Attachment".CreateInStream(InStream);
                    if PersBlob.CopyFromInStream(PersKey, InStream) then begin
                        LotInfo."TFB CoA Attach." := PersKey;
                        LotInfo.Modify(false);
                    end;
                end;

            until LotInfo.Next() < 1;


    end;






}
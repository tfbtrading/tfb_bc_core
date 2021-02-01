codeunit 50103 "TFB Upgrade Mgmt"
{

    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerCompany()

    var


    begin


    end;

    trigger OnUpgradePerCompany()

    begin
        If CheckIfUpgradeCodeRequired() then
            SetDefaultCustomerPreference();


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
        Exit((GetInstallingVersionNo() = '17.0.7.6'))
    end;



    local procedure SetDefaultCustomerPreference();

    var
        Customer: Record Customer;

    begin
        Customer.ModifyAll("TFB Order Update Preference", Enum::"TFB Order Update Preference"::Always);
    end;

    local procedure CopyToDefaultPurchaseCodes()

    var
        Item: record Item;

    begin

        Item.FindSet(true, false);

        repeat
            Item."Purchasing Code" := Text.CopyStr(Item."TFB Default Purch. Code", 1, 10);
            Item.Modify(false);

        until Item.Next() < 1;


    end;

    procedure CopyQualityAttachToPersBlob()

    var
        VendorCert: Record "TFB Vendor Certification";
        PersBlob: CodeUnit "Persistent Blob";
        PersKey: BigInteger;
        InStream: InStream;

    begin

        If VendorCert.FindSet(true, false) then
            repeat
                Clear(PersBlob);
                VendorCert.CalcFields(Certificate);
                If VendorCert.Certificate.HasValue then begin
                    PersKey := PersBlob.Create();
                    VendorCert.Certificate.CreateInStream(InStream);
                    If PersBlob.CopyFromInStream(PersKey, InStream) then begin
                        VendorCert."Certificate Attach." := PersKey;
                        Clear(VendorCert.Certificate);
                        VendorCert.Modify(false);
                    end;
                end;

            until VendorCert.Next() < 1;


    end;


    procedure CopyCoAAttachToPersBlob()

    var
        LotInfo: Record "Lot No. Information";
        PersBlob: CodeUnit "Persistent Blob";
        PersKey: BigInteger;
        InStream: InStream;

    begin

        If LotInfo.FindSet(true, false) then
            repeat
                Clear(PersBlob);
                LotInfo.CalcFields("TFB CoA Attachment");
                If LotInfo."TFB CoA Attachment".HasValue then begin
                    PersKey := PersBlob.Create();
                    LotInfo."TFB CoA Attachment".CreateInStream(InStream);
                    If PersBlob.CopyFromInStream(PersKey, InStream) then begin
                        LotInfo."TFB CoA Attach." := PersKey;
                        LotInfo.Modify(false);
                    end;
                end;

            until LotInfo.Next() < 1;


    end;

    local procedure CheckForEmptyLineContracts()

    var
        Line: Record "TFB Brokerage Shipment Line";
        Header: Record "TFB Brokerage Shipment";

    begin

        Line.SetFilter("Contract No.", '%1', '');
        If Line.Count() > 0 then
            if Line.FindSet() then
                repeat

                    If Header.Get(Line."Document No.") then begin
                        Line."Contract No." := Header."Contract No.";
                        Line.Modify();
                    end;
                until Line.Next() < 1;
    end;



}
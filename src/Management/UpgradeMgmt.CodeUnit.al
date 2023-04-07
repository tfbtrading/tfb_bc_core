codeunit 50103 "TFB Upgrade Mgmt"
{

    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerCompany()

    var


    begin


    end;

    trigger OnUpgradePerCompany()

    begin
      //  If CheckIfUpgradeCodeRequired() then
          


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
        exit((GetInstallingVersionNo() = '21.0.0.42'))
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





    local procedure UpdateSystemIDForForexMgmg()
    var
        ForexMgmtEntry: Record "TFB Forex Mgmt Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";

    begin
        if ForexMgmtEntry.Findset(true) then
            repeat
                if IsNullGuid(ForexMgmtEntry."Applies-to id") and (ForexMgmtEntry."Applies-to Doc No." <> '') then
                    if ForexMgmtEntry."Applies-to Doc. Type" = ForexMgmtEntry."Applies-to Doc. Type"::VendorLedgerEntry then begin
                        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
                        VendorLedgerEntry.SetRange("Document No.", ForexMgmtEntry."Applies-to Doc No.");
                        if VendorLedgerEntry.FindFirst() then begin
                            ForexMgmtEntry."Applies-to id" := VendorLedgerEntry.SystemId;
                            ForexMgmtEntry."Applies-to Entry Doc. No." := VendorLedgerEntry."Document No.";
                            ForexMgmtEntry."Applies-to Posting Date" := VendorLedgerEntry."Posting Date";
                            ForexMgmtEntry.Modify();
                        end;
                    end

            until ForexMgmtEntry.Next() = 0;

    end;


}
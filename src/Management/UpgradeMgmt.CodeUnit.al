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
            FixStatus();


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
        Exit((GetInstallingVersionNo() = '21.0.0.42'))
    end;

    local procedure FixStatus(): Boolean

    var
        Customer: Record Customer;
        Contact: Record Contact;

    begin

        If Customer.Findset(true) then
            repeat begin

                Customer.validate("TFB Contact Status", Customer."TFB Contact Status");
                Customer.modify(false);

            end until Customer.Next() = 0;

        Contact.SetRange(Type, Contact.Type::Company);

        If Contact.Findset(true) then
            repeat begin

                Contact.Validate("TFB Contact Status", Contact."TFB Contact Status");
                Contact.Modify(false);

            end until Contact.Next() = 0;

    end;



    local procedure FixLotSampleStatusRecord(): Boolean

    var
        LotNoInformation: Record "Lot No. Information";

    begin

        If LotNoInformation.Findset(true) then
            repeat
                If LotNoInformation."TFB Sample Picture".Count <> 0 then begin
                    LotNoInformation."TFB Sample Picture Exists" := true;
                    LotNoInformation.Modify(false);
                end;
            until LotNoInformation.Next() = 0;

    end;



    procedure CopyQualityAttachToPersBlob()

    var
        VendorCert: Record "TFB Vendor Certification";
        PersBlob: CodeUnit "Persistent Blob";
        PersKey: BigInteger;
        InStream: InStream;

    begin

        If VendorCert.Findset(true) then
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

        If LotInfo.Findset(true) then
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





    local procedure UpdateSystemIDForForexMgmg()
    var
        ForexMgmtEntry: Record "TFB Forex Mgmt Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";

    begin
        If ForexMgmtEntry.Findset(true) then
            repeat
                if IsNullGuid(ForexMgmtEntry."Applies-to id") and (ForexMgmtEntry."Applies-to Doc No." <> '') then
                    If ForexMgmtEntry."Applies-to Doc. Type" = ForexMgmtEntry."Applies-to Doc. Type"::VendorLedgerEntry then begin
                        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
                        VendorLedgerEntry.SetRange("Document No.", ForexMgmtEntry."Applies-to Doc No.");
                        If VendorLedgerEntry.FindFirst() then begin
                            ForexMgmtEntry."Applies-to id" := VendorLedgerEntry.SystemId;
                            ForexMgmtEntry."Applies-to Entry Doc. No." := VendorLedgerEntry."Document No.";
                            ForexMgmtEntry."Applies-to Posting Date" := VendorLedgerEntry."Posting Date";
                            ForexMgmtEntry.Modify();
                        end;
                    end

            until ForexMgmtEntry.Next() = 0;

    end;


}
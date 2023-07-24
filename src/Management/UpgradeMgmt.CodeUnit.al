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
            PerformUpgrades();

    end;

    local procedure PerformUpgrades()

    begin
        UpgradeCostingTables();
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
        exit((GetInstallingVersionNo() = '22.0.2.0'))
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


    procedure UpgradeCostingTables()
    var
        fromRec: Record "TFB Item Costing";
        toRec: record "TFB Item Costing Revised";
        fromLRec: Record "TFB Item Costing Lines";
        toLRec: Record "TFB Item Costing Revised Lines";
        dt: DataTransfer;
        dt2: DataTransfer;


    begin

        dt.SetTables(Database::"TFB Item Costing", Database::"TFB Item Costing Revised");
        dt.AddFieldValue(fromRec.FieldNo("Item No."), toRec.FieldNo("Item No."));
        dt.addfieldValue(fromRec.FieldNo("Vendor No."), toRec.FieldNo("Vendor No."));
        dt.AddFieldValue(fromrec.fieldno(Description), toRec.FieldNo(Description));
        dt.AddFieldValue(fromrec.Fieldno("Costing Type"), torec.FieldNo("Costing Type"));
        dt.AddFieldValue(fromrec.fieldno("Landed Cost Profile"), torec.FieldNo("Landed Cost Profile"));
        dt.AddFieldValue(fromrec.fieldno("Scenario Override"), torec.fieldno("Scenario Override"));
        dt.AddFieldValue(fromrec.FieldNo("Vendor Name"), torec.FieldNo("Vendor Name"));
        dt.addfieldvalue(fromRec.fieldno("Fix Exch. Rate"), torec.fieldno("Fix Exch. Rate"));
        dt.AddFieldValue(fromRec.fieldno("Purchase Price Unit"), torec.fieldno("Purchase Price Unit"));
        dt.AddFieldValue(fromrec.FieldNo("Average Cost"), torec.FieldNo("Average Cost"));
        dt.AddFieldValue(fromrec.FieldNo("Market Price"), torec.FieldNo("Market Price"));
        dt.AddFieldValue(fromrec.fieldNo("Pricing Margin %"), torec.FieldNo("Pricing Margin %"));
        dt.AddFieldValue(fromrec.fieldno("Market Price Margin %"), torec.FieldNo("Market Price Margin %"));
        dt.addfieldvalue(fromrec.fieldno("Full Load Margin %"), torec.FieldNo("Full Load Margin %"));
        dt.AddFieldValue(fromrec.FieldNo("Pallet Qty"), torec.FieldNo("Pallet Qty"));
        dt.AddFieldValue(fromrec.FieldNo("Vendor Currency"), torec.fieldno("Vendor Currency"));
        dt.addfieldvalue(fromRec.FieldNo("Days Financed"), torec.FieldNo("Days Financed"));
        dt.AddFieldValue(fromRec.FieldNo(Dropship), torec.FieldNo(Dropship));
        dt.AddFieldValue(fromRec.FieldNo("Est. Storage Duration"), toRec.FieldNo("Est. Storage Duration"));
        dt.AddFieldValue(fromRec.FieldNo("Automatically Updated"), torec.FieldNo("Automatically Updated"));
        dt.CopyRows();

        dt2.setTables(Database::"TFB Item Costing Lines", Database::"TFB Item Costing Revised Lines");
        dt2.AddFieldValue(fromLRec.FieldNo("Item No."), toLRec.FieldNo("Item No."));
        dt2.AddFieldValue(fromLRec.FieldNo("Costing Type"), toLRec.FieldNo("Costing Type"));
        dt2.AddFieldValue(fromLRec.FieldNo("Line Type"), toLRec.FieldNo("Line Type"));
        dt2.AddFieldValue(fromLRec.FieldNo("Line Key"), toLRec.FieldNo("Line Key"));
        dt2.AddFieldValue(fromLRec.FieldNo(Description), toLRec.FieldNo(Description));
        dt2.AddFieldValue(fromLRec.FieldNo(CalcDesc), toLRec.FieldNo(CalcDesc));
        dt2.AddFieldValue(fromLRec.FieldNo("Market Price (Base)"), toLRec.fieldno("Market Price (Base)"));
        dt2.AddFieldValue(fromLRec.FieldNo("Market price Per Weight Unit"), toLRec.fieldno("Market price Per Weight Unit"));
        dt2.AddFieldValue(fromLRec.fieldno("Price (Base)"), toLRec.FieldNo("Price (Base)"));
        dt2.AddFieldValue(fromLRec.fieldno("Price Per Weight Unit"), toLRec.FieldNo("Price Per Weight Unit"));
        dt2.CopyRows();

    end;




}
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
        updateContactStatus();
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
        exit((GetInstallingVersionNo() = '22.0.2.12'))
    end;



    local procedure updateContactStatus()

    var
        Status: Record "TFB Contact Status";
        Contact: Record Contact;
    begin

        if Contact.Findset(true) then
            repeat
                if Contact.Type = Contact.Type::Person then
                    Contact."TFB Contact Status" := '';

                Status.SetRange(Status, Contact."TFB Contact Status");

                if Status.FindFirst() then
                    Contact.validate("TFB Contact Stage", Status.Stage);

                Contact.modify(true);
            until Contact.Next() = 0;



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
        CodeUnitCosting: Codeunit "TFB Costing Mgmt";
        dt: DataTransfer;
        dt2: DataTransfer;
        UpdateExchRate: Boolean;
        UpdateMargins: Boolean;
        UpdatePrices: Boolean;

    begin

        dt.SetTables(Database::"TFB Item Costing", Database::"TFB Item Costing Revised");
        dt.AddFieldValue(fromRec.FieldNo("Item No."), toRec.FieldNo("Item No."));
        dt.addfieldValue(fromRec.FieldNo("Vendor No."), toRec.FieldNo("Vendor No."));
        dt.AddFieldValue(fromrec.fieldno(Description), toRec.FieldNo(Description));
        dt.AddFieldValue(fromrec.Fieldno("Costing Type"), torec.FieldNo("Costing Type"));
        dt.AddFieldValue(fromrec.fieldno("Landed Cost Profile"), torec.FieldNo("Landed Cost Profile"));
        dt.AddFieldValue(fromrec.fieldno("Scenario Override"), torec.fieldno("Scenario Override"));
        dt.AddFieldValue(fromrec.FieldNo("Vendor Name"), torec.FieldNo("Vendor Name"));
        dt.AddFieldValue(fromrec.fieldno("Exch. Rate"), torec.fieldno("Exch. Rate"));
        dt.addfieldvalue(fromRec.fieldno("Fix Exch. Rate"), torec.fieldno("Fix Exch. Rate"));
        dt.AddFieldValue(fromRec.fieldno("Purchase Price Unit"), torec.fieldno("Purchase Price Unit"));
        dt.AddFieldValue(fromrec.FieldNo("Average Cost"), torec.FieldNo("Average Cost"));
        dt.AddFieldValue(fromrec.FieldNo("Market Price"), torec.FieldNo("Market Price"));
        dt.AddFieldValue(fromrec.fieldNo("Pricing Margin %"), torec.FieldNo("Pricing Margin %"));
        dt.AddFieldValue(fromrec.fieldno("Market Price Margin %"), torec.FieldNo("Market Price Margin %"));
        dt.addfieldvalue(fromrec.fieldno("Full Load Margin %"), torec.FieldNo("Full Load Margin %"));
        dt.AddFieldValue(fromrec.FieldNo("Pallet Qty"), torec.FieldNo("Pallet Qty"));
        dt.addfieldvalue(fromRec.FieldNo("Days Financed"), torec.FieldNo("Days Financed"));
        dt.AddFieldValue(fromRec.FieldNo(Dropship), torec.FieldNo(Dropship));
        dt.AddFieldValue(fromRec.FieldNo("Est. Storage Duration"), toRec.FieldNo("Est. Storage Duration"));
        dt.AddFieldValue(fromRec.FieldNo("Automatically Updated"), torec.FieldNo("Automatically Updated"));
        dt.AddSourceFilter(fromRec.FieldNo(Current), '%1', true);
        dt.CopyRows();





        UpdateExchRate := false;
        UpdateMargins := false;
        UpdatePrices := false;
        CodeUnitCosting.UpdateCurrentCostingsDetails(UpdateExchRate, UpdateMargins, UpdatePrices);


    end;




}
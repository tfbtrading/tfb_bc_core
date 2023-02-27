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
        Exit((GetInstallingVersionNo() = '21.0.0.40'))
    end;

    local procedure FixStatus(): Boolean

    var
        Customer: Record Customer;
        Contact: Record Contact;

    begin

        Customer.Findset(true, true);

        repeat begin

            Customer.validate("TFB Contact Status", Customer."TFB Contact Status");
            Customer.modify(false);

        end until Customer.Next() = 0;

        Contact.SetRange(Type, Contact.Type::Company);

        Contact.FindSet(true, true);

        repeat begin

            Contact.Validate("TFB Contact Status", Contact."TFB Contact Status");
            Contact.Modify(false);

        end until Contact.Next() = 0;

    end;

    local procedure TransferSetupFields(): Boolean


    var
        CoreSetup: Record "TFB Core Setup";
        CostingSetup: Record "TFB Costings Setup";
        NotifySetup: Record "TFB Notification Email Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        ItemSetup: Record "Inventory Setup";
        InteractionSetup: Record "Interaction Template Setup";
        UserSetup: Record "User Setup";

    begin

        CoreSetup.InsertIfNotExists();




        If CostingSetup.Get() then begin
            CoreSetup."Cust. Decl. Item Charge" := CostingSetup."Cust. Decl. Item Charge";
            CoreSetup."Default Postal Zone" := CostingSetup."Default Postal Zone";
            CoreSetup.ExWarehouseEnabled := CostingSetup.ExWarehouseEnabled;
            CoreSetup.ExWarehousePricingGroup := CostingSetup.ExWarehousePricingGroup;
            CoreSetup."Fumigation Fees Item Charge" := CostingSetup."Fumigation Fees Item Charge";
            CoreSetup."Import Duty Rate" := CostingSetup."Import Duty Rate";
            CoreSetup."Ocean Freight Item Charge" := CostingSetup."Ocean Freight Item Charge";
            CoreSetup."Port Cartage Item Charge" := CostingSetup."Port Cartage Item Charge";
            CoreSetup."Port Documents" := CostingSetup."Port Documents";
            CoreSetup."Quarantine Fees Item Charge" := CostingSetup."Quarantine Fees Item Charge";
            CoreSetup."Unpack Item Charge" := CostingSetup."Unpack Item Charge";
        end;

        if ItemSetup.Get() then begin

            CoreSetup.ABSLotSampleAccessKey := ItemSetup."TFB ABS Lot Sample Access Key";
            CoreSetup."ABS Lot Sample Account" := ItemSetup."TFB ABS Lot Sample Account";
            CoreSetup."ABS Lot Sample Container" := ItemSetup."TFB ABS Lot Sample Container";
            CoreSetup."MSDS Word Template" := ItemSetup."TFB MSDS Word Template";
        end;

        if PurchSetup.Get() then
            CoreSetup."Container Entry Nos." := PurchSetup."TFB Container Entry Nos.";

        if SalesSetup.Get() then begin
            CoreSetup."ABS POD Access Key" := SalesSetup."TFB ABS POD Access Key";
            CoreSetup."ABS POD Account" := SalesSetup."TFB ABS POD Account";
            CoreSetup."ABS POD Container" := SalesSetup."TFB ABS POD Container";
            CoreSetup."ASN Def. Job Resp. Rec." := SalesSetup."TFB ASN Def. Job Resp. Rec.";
            CoreSetup."Auto Shipment Notification" := SalesSetup."TFB Auto Shipment Notification";
            CoreSetup."Brokerage Contract Nos." := SalesSetup."TFB Brokerage Contract Nos.";
            CoreSetup."Brokerage Default %" := SalesSetup."Brokerage Default %";
            CoreSetup."Brokerage Service Item" := SalesSetup."TFB Brokerage Service Item";
            CoreSetup."Brokerage Shipment Nos." := SalesSetup."TFB Brokerage Shipment Nos.";
            CoreSetup."Converted Status" := SalesSetup."TFB Converted Status";
            CoreSetup."Credit Tolerance" := SalesSetup."TFB Credit Tolerance";
            CoreSetup."Def. Customer Price Group" := SalesSetup."TFB Def. Customer Price Group";
            CoreSetup."Image URL Pattern" := SalesSetup."TFB Image URL Pattern";
            CoreSetup."Item Price Group" := SalesSetup."TFB Item Price Group";
            CoreSetup."Lead Status" := SalesSetup."TFB Lead Status";
            CoreSetup."PL Def. Job Resp. Rec." := SalesSetup."TFB PL Def. Job Resp. Rec.";
            CoreSetup."Posted Sample Request Nos." := SalesSetup."TFB Posted Sample Request Nos.";
            CoreSetup."Price List Def. Job Resp." := SalesSetup."TFB Price List Def. Job Resp.";
            CoreSetup."Prospect Status - New" := SalesSetup."TFB Prospect Status - New";
            CoreSetup."Prospect Status - Opp" := SalesSetup."TFB Prospect Status - Opp";
            CoreSetup."Prospect Status - Quote" := SalesSetup."TFB Prospect Status - Quote";
            CoreSetup."QDS Def. Job Resp." := SalesSetup."TFB QDS Def. Job Resp.";
            CoreSetup."Sample Request Nos." := SalesSetup."TFB Sample Request Nos.";
            CoreSetup."Specification URL Pattern" := SalesSetup."TFB Specification URL Pattern";
        end;

        If NotifySetup.Get() then begin
            CoreSetup."Test Table" := NotifySetup."Test Table";
            CoreSetup."Email Template Active" := NotifySetup."Email Template Active";
            CoreSetup."Email Template Test" := NotifySetup."Email Template Test";
        end;



        CoreSetup.Modify(true);



    end;

    local procedure FixLotSampleStatusRecord(): Boolean

    var
        LotNoInformation: Record "Lot No. Information";

    begin

        If LotNoInformation.FindSet(true, false) then
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





    local procedure UpdateSystemIDForForexMgmg()
    var
        ForexMgmtEntry: Record "TFB Forex Mgmt Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";

    begin
        If ForexMgmtEntry.FindSet(true, false) then
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
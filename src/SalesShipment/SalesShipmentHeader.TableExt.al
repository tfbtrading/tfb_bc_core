tableextension 50183 "TFB Sales Shipment Header" extends "Sales Shipment Header" //MyTargetTableId
{
    fields
    {
        field(50180; "TFB 3PL Booking No."; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = '3PL Booking No.';

        }
        field(50331; "TFB POD Received"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'POD Received';
        }
        field(50332; "TFB POD Filename"; Text[256])
        {
            DataClassification = CustomerContent;
            Caption = 'POD Filename';
        }
        field(50334; "TFB Marked Rec. By Cust."; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Marked as Received';
        }
        field(50336; "TFB DeliveredAt"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Confirmed Delivered At';
        }



    }

    var
        InventorySetup: Record "Inventory Setup";
        CoreSetup: Record "TFB Core Setup";
        ABSResponse: CodeUnit "ABS Operation Response";
        AzureBlob: CodeUnit "ABS Blob Client";
        StorageServiceAuthorization: CodeUnit "Storage Service Authorization";
        TempBlob: CodeUnit "Temp Blob";
        Authorization: Interface "Storage Service Authorization";


    procedure GetProofOfDelivery(var Instream: Instream): Boolean

    var
        WarehouseShipment: Record "Posted Whse. Shipment Line";

    begin

        CoreSetup.SetLoadFields("ABS POD Container", "ABS POD Access Key", "ABS POD Account");
        CoreSetup.Get();
        Authorization := StorageServiceAuthorization.CreateSharedKey(CoreSetup."ABS POD Access Key");
        AzureBlob.Initialize(CoreSetup."ABS POD Account", CoreSetup."ABS POD Container", Authorization);

        ABSResponse := AzureBlob.GetBlobAsStream(Rec."TFB POD Filename", Instream);
        exit(ABSResponse.IsSuccessful());


    end;

    procedure AddProofOfDelivery(FileName: Text; Instream: InStream; HideDialog: Boolean): Boolean

    var
        TempSalesShipmentHeader: Record "Sales Shipment Header" temporary;
        PstdShipmentHdrEdit: CodeUnit "TFB Pstd. Shipment. Hdr. Edit";
        ConfirmOverwriteMsg: Label 'Overwright existing blob assigned with filename %1', comment = '%1 = filename of blob being overwritten';
    begin

        if not HideDialog then
            if "TFB POD Received" then
                if not Confirm(ConfirmOverwriteMsg, true, "TFB POD Filename") then exit;

        CoreSetup.SetLoadFields("ABS POD Container", "ABS POD Access Key", "ABS POD Account");
        CoreSetup.Get();
        Authorization := StorageServiceAuthorization.CreateSharedKey(CoreSetup."ABS POD Access Key");
        AzureBlob.Initialize(CoreSetup."ABS POD Account", CoreSetup."ABS POD Container", Authorization);

        ABSResponse := AzureBlob.PutBlobBlockBlobStream(Rec."TFB POD Filename", Instream);
        if ABSResponse.IsSuccessful() then begin
            TempSalesShipmentHeader := Rec;
            TempSalesShipmentHeader."TFB POD Filename" := FileName;
            TempSalesShipmentHeader."TFB POD Received" := true;
            PstdShipmentHdrEdit.Run(TempSalesShipmentHeader);
        end;
        exit(ABSResponse.IsSuccessful());

    end;



}
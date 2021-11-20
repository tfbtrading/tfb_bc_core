tableextension 50183 "TFB Sales Shipment Header" extends "Sales Shipment Header" //MyTargetTableId
{
    fields
    {
        field(50180; "TFB 3PL Booking No."; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = '3PL Booking No.';

        }
        field(50190; "TFB POD Received"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'POD Received';
        }
        field(50200; "TFB POD Filename"; Text[256])
        {
            DataClassification = CustomerContent;
            Caption = 'POD Filename';
        }
        field(50210; "TFB Marked Rec. By Cust."; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Marked as Received';
        }
        field(50220; "TFB DeliveredAt"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Confirmed Delivered At';
        }

        

    }

    var
        AzureBlob: CodeUnit "ABS Blob Client";
        StorageServiceAuthorization: CodeUnit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
        ABSResponse: CodeUnit "ABS Operation Response";

        InventorySetup: Record "Inventory Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        TempBlob: CodeUnit "Temp Blob";
        Instream: Instream;
        FileName: Text;

    procedure GetProofOfDelivery(var Instream: Instream): Boolean

    var
        WarehouseShipment: Record "Posted Whse. Shipment Line";

    begin

        SalesSetup.SetLoadFields("TFB ABS POD Container", "TFB ABS POD Access Key", "TFB ABS POD Account");
        SalesSetup.Get();
        Authorization := StorageServiceAuthorization.CreateSharedKey(SalesSetup."TFB ABS POD Access Key");
        AzureBlob.Initialize(SalesSetup."TFB ABS POD Account", SalesSetup."TFB ABS POD Container", Authorization);

        ABSResponse := AzureBlob.GetBlobAsStream(Rec."TFB POD Filename", Instream);
        Exit(ABSResponse.IsSuccessful());


    end;

    procedure AddProofOfDelivery(FileName: Text; Instream: InStream; HideDialog: Boolean): Boolean

    var
        TempSalesShipmentHeader: Record "Sales Shipment Header" temporary;
        PstdShipmentHdrEdit: CodeUnit "TFB Pstd. Shipment. Hdr. Edit";
        ConfirmOverwriteMsg: Label 'Overwright existing blob assigned with filename %1', comment = '%1 = filename of blob being overwritten';
    begin
        
        If not HideDialog then
            If "TFB POD Received" then
                If not Confirm(ConfirmOverwriteMsg, true, "TFB POD Filename") then exit;

        SalesSetup.SetLoadFields("TFB ABS POD Container", "TFB ABS POD Access Key", "TFB ABS POD Account");
        SalesSetup.Get();
        Authorization := StorageServiceAuthorization.CreateSharedKey(SalesSetup."TFB ABS POD Access Key");
        AzureBlob.Initialize(SalesSetup."TFB ABS POD Account", SalesSetup."TFB ABS POD Container", Authorization);

        ABSResponse := AzureBlob.PutBlobBlockBlobStream(Rec."TFB POD Filename", Instream);
        If ABSResponse.IsSuccessful() then begin
            TempSalesShipmentHeader := Rec;
            TempSalesShipmentHeader."TFB POD Filename" := FileName;
            TempSalesShipmentHeader."TFB POD Received" := True;
            PstdShipmentHdrEdit.Run(TempSalesShipmentHeader);
        end;
        Exit(ABSResponse.IsSuccessful());

    end;

    procedure AddProofOfDelivery(FileName: Text; HideDialog: Boolean): Boolean

    var
        TempSalesShipmentHeader: Record "Sales Shipment Header" temporary;
        PstdShipmentHdrEdit: CodeUnit "TFB Pstd. Shipment. Hdr. Edit";
        ConfirmOverwriteMsg: Label 'Overwright existing blob assigned with filename %1', comment = '%1 = filename of blob being overwritten';

    begin
        If not HideDialog then
            If "TFB POD Received" then
                If not Confirm(ConfirmOverwriteMsg, true, "TFB POD Filename") then exit;

        SalesSetup.SetLoadFields("TFB ABS POD Container", "TFB ABS POD Access Key", "TFB ABS POD Account");
        SalesSetup.Get();
        Authorization := StorageServiceAuthorization.CreateSharedKey(SalesSetup."TFB ABS POD Access Key");
        AzureBlob.Initialize(SalesSetup."TFB ABS POD Account", SalesSetup."TFB ABS POD Container", Authorization);
        ABSResponse := AzureBlob.GetBlobAsStream(FileName, InStream);
        If ABSResponse.IsSuccessful() then begin
            TempSalesShipmentHeader := Rec;
            TempSalesShipmentHeader."TFB POD Filename" := FileName;
            TempSalesShipmentHeader."TFB POD Received" := True;
            PstdShipmentHdrEdit.Run(TempSalesShipmentHeader);
        end;
        Exit(ABSResponse.IsSuccessful());

    end;

}
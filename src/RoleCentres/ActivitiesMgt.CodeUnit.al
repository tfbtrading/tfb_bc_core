codeunit 50132 "TFB Activities Mgt."
{

    trigger OnRun()
    begin
        ActivitiesMgt.Run();
    end;

    internal procedure DrillDownOnExpiringLotNos()
    var

        LotExpiryList: Page "TFB Lot Expiry List";


    begin




        LotExpiryList.InitExpiringData();
        LotExpiryList.Run();

    end;

    internal procedure DrillDownOnExpiredLotNos()
    var

        LotExpiryList: Page "TFB Lot Expiry List";


    begin

        LotExpiryList.InitExpiredData();
        LotExpiryList.Run();

    end;

    internal procedure PopulateExpiringData(var TempLotExpiryBuffer: Record "TFB Lot Expiry Buffer")

    var
        ItemLedgersQuery: Query "TFB Item By Lot No. Ledg. Exp.";
    begin
        ItemLedgersQuery.SetFilter(Expiration_Date, 't..t+6m');
        ItemLedgersQuery.Open();

        while ItemLedgersQuery.Read() do begin
            TempLotExpiryBuffer.init();
            TempLotExpiryBuffer."Item No." := ItemLedgersQuery.Item_No_;
            TempLotExpiryBuffer.Description := ItemLedgersQuery.Description;
            TempLotExpiryBuffer."Variant Code" := ItemLedgersQuery.Variant_Code;
            TempLotExpiryBuffer."Lot No." := ItemLedgersQuery.Lot_No;
            TempLotExpiryBuffer."Expiry Date" := ItemLedgersQuery.Expiration_Date;
            TempLotExpiryBuffer."Qty. (Base)" := ItemLedgersQuery.Remaining_Quantity_Sum;
            TempLotExpiryBuffer.Insert();
        end;
    end;

    internal procedure PopulateExpiredData(var TempLotExpiryBuffer: Record "TFB Lot Expiry Buffer")

    var
        ItemLedgersQuery: Query "TFB Item By Lot No. Ledg. Exp.";
    begin
        ItemLedgersQuery.SetFilter(Expiration_Date, '..t');
        ItemLedgersQuery.Open();

        while ItemLedgersQuery.Read() do begin
            TempLotExpiryBuffer.init();
            TempLotExpiryBuffer."Item No." := ItemLedgersQuery.Item_No_;
            TempLotExpiryBuffer.Description := ItemLedgersQuery.Description;
            TempLotExpiryBuffer."Variant Code" := ItemLedgersQuery.Variant_Code;
            TempLotExpiryBuffer."Lot No." := ItemLedgersQuery.Lot_No;
            TempLotExpiryBuffer."Expiry Date" := ItemLedgersQuery.Expiration_Date;
            TempLotExpiryBuffer."Qty. (Base)" := ItemLedgersQuery.Remaining_Quantity_Sum;
            TempLotExpiryBuffer.Insert();
        end;
    end;

    var
        ActivitiesMgt: Codeunit "Activities Mgt.";


}
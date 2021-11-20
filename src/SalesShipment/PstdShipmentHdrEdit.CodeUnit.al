codeunit 50119 "TFB Pstd. Shipment. Hdr. Edit"
{
    Permissions = TableData "Sales Shipment Header" = m;
    TableNo = "Sales Shipment Header";

    trigger OnRun()
    var
        ShipmentHeader: Record "Sales Shipment Header";
    begin
        ShipmentHeader := Rec;
        ShipmentHeader.LockTable();
        ShipmentHeader.Find();

        ShipmentHeader."TFB POD Filename" := Rec."TFB POD Filename";
        ShipmentHeader."TFB POD Received" := Rec."TFB POD Received";
        ShipmentHeader."TFB Marked Rec. By Cust." := Rec."TFB Marked Rec. By Cust.";
        ShipmentHeader."TFB 3PL Booking No." := Rec."TFB 3PL Booking No.";

        ShipmentHeader.TestField("No.", Rec."No.");
        ShipmentHeader.Modify();
        Rec := ShipmentHeader;
    end;

    var
        


}
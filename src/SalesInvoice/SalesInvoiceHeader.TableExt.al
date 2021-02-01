tableextension 50192 "TFB Sales Invoice Header" extends "Sales Invoice Header" //MyTargetTableId
{
    fields
    {
        field(50190; "TFB Brokerage Shipment"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Brokerage Shipment";
            ValidateTableRelation = true;
            Caption = 'Brokerage Shipment';
        }

    }


    procedure CreateTask()
    var
        TempTask: Record "To-do" temporary;
        RecRef: RecordRef;
    begin
        TestField("Sell-to Contact No.");
        RecRef.GetTable(Rec);
        TempTask.CreateTaskFromPstdDocument(RecRef);
    end;

}
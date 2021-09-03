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

        field(50200; "TFB Expected Payment Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Payment Date';
        }
        field(50210; "TFB Expected Payment Note"; Text[512])
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Payment Note';
        }
        field(50220; "TFB Expected Note TimeStamp"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Payment Note Last Added';
        }
        field(50230; "TFB Orig. External Doc. No."; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Original External Document No.';
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
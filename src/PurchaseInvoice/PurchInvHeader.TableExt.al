tableextension 50113 "TFB Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(50401; "TFB Expected Payment Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Payment Date';
        }
        field(50402; "TFB Expected Payment Note"; Text[512])
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Payment Note';
        }
        field(50403; "TFB Expected Note TimeStamp"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Payment Note Last Added';
        }
        field(50405; "TFB Orig. External Doc. No."; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Original External Document No.';
        }
    }

    fieldgroups
    {
        addlast(Brick; "Vendor Invoice No.", "Document Date")
        {

        }
    }
    procedure CreateTask()
    var
        TempTask: Record "To-do" temporary;
        RecRef: RecordRef;
    begin
        TestField("Buy-from Contact No.");
        RecRef.GetTable(Rec);
        TempTask.CreateTaskFromPstdDocument(RecRef);
    end;

}
tableextension 50113 "TFB Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        // Add changes to table fields here
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
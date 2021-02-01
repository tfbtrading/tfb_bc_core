codeunit 50141 "TFB Action Handlers"
{
    trigger OnRun()
    begin

    end;

    procedure OpenItem(ItemDataNotification: Notification)

    var
        ItemRec: Record Item;
        ItemPage: Page "Item Card";
        ItemNo: Text;

    begin

        ItemNo := ItemDataNotification.GetData(ItemNo);
        If ItemRec.get(ItemNo) then begin
            ItemPage.SetRecord(ItemRec);
            ItemPage.Run();
        end else
            ERROR('Could not find item %1', ItemNo);
    end;




}
codeunit 50175 "TFB Transfer Order Mgmt"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeInsertTransShptLine', '', false, false)]
    local procedure HandleTransferOrderPostShipment(CommitIsSuppressed: Boolean; TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")

    //Get container number details
    var

        Container: Record "TFB Container Entry";

    begin

        TransShptLine."TFB Container Entry No." := TransLine."TFB Container Entry No.";


        if Container.Get(TransLine."TFB Container Entry No.") then
            TransShptLine."TFB Container No." := Container."Container No.";



    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeInsertTransRcptLine', '', false, false)]
    local procedure HandleTransferOrderPostReceipt(CommitIsSuppressed: Boolean; TransLine: Record "Transfer Line"; var TransRcptLine: Record "Transfer Receipt Line")

    //Get container number details
    var

        Container: Record "TFB Container Entry";
        TransferOrder: record "Transfer Header";

    begin

        TransferOrder.SetLoadFields("TFB Transfer Type", "TFB Order Reference", "TFB Container Entry No.");
        if not TransferOrder.Get(TransLine."Document No.") then exit;
        if not (TransferOrder."TFB Transfer Type" = Enum::"TFB Transfer Order Type"::Container) then exit;




        if Container.Get(TransferOrder."TFB Container Entry No.") then begin
            TransRcptLine."TFB Container No." := Container."Container No.";
            TransRcptLine."TFB Container Entry No." := TransferOrder."TFB Container Entry No.";
        end;

    end;

}






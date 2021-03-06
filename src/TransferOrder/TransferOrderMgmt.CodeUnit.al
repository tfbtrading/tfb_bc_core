codeunit 50175 "TFB Transfer Order Mgmt"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeInsertTransShptLine', '', false, false)]
    local procedure HandleTransferOrderPostShipment(CommitIsSuppressed: Boolean; TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")

    //Get container number details
    var

        Container: Record "TFB Container Entry";

    begin

        TransShptLine."TFB Container Entry No." := TransLine."TFB Container Entry No.";


        If Container.Get(TransLine."TFB Container Entry No.") then
            TransShptLine."TFB Container No." := Container."Container No.";



    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeInsertTransRcptLine', '', false, false)]
    local procedure HandleTransferOrderPostReceipt(CommitIsSuppressed: Boolean; TransLine: Record "Transfer Line"; var TransRcptLine: Record "Transfer Receipt Line")

    //Get container number details
    var

        Container: Record "TFB Container Entry";

    begin

        TransRcptLine."TFB Container Entry No." := TransLine."TFB Container Entry No.";

        If Container.Get(TransLine."TFB Container Entry No.") then
            TransRcptLine."TFB Container No." := Container."Container No.";




    end;

}






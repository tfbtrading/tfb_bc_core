codeunit 50129 "TFB Word Template Mgmt"
{
    trigger OnRun()
    begin
        
    end;[EventSubscriber(ObjectType::Codeunit, Codeunit::"Word Template Interactions", 'OnBeforeSendMergedDocument', '', false, false)]
    local procedure OnBeforeSendMergedDocument(MergedDocumentInStream: InStream; TempDeliverySorter: Record "Delivery Sorter"; ToAddress: Text; InteractionLogEntry: Record "Interaction Log Entry"; var IsHandled: Boolean);
    begin
    end;
    
    
  
}
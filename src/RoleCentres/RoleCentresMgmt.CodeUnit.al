codeunit 50113 "TFB Role Centres Mgmt"
{
    trigger OnRun()
    begin
        
    end;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Conf./Personalization Mgt.", 'OnRoleCenterOpen', '', false, false)]
    local procedure OnRoleCenterOpen();
    begin
    end;
    
}
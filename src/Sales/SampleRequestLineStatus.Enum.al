enum 50125 "TFB Sample Request Line Status"
{
    Extensible = true;
    AssignmentCompatibility = true;
    Caption = 'Sample Request Line Status';

    value(0; " ") { Caption = ' '; }
    value(1; "AwaitingStock") { Caption = 'Awaiting New Stock'; }
    value(2; Requested) { Caption = 'Requested'; }
    value(3; ReadyToPackage) { Caption = 'Ready to Package'; }
    value(4; ReadyToSend) { Caption = 'Ready to Send'; }

    value(5; Sent) { Caption = 'Sent'; }

}
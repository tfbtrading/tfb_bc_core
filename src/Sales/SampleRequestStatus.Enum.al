enum 50122 "TFB Sample Request Status"
{
    Extensible = true;
    AssignmentCompatibility = true;
    Caption = 'Sample Request Status';

    value(0;" ") { Caption = ' ';}
    value(1; "Documented") { Caption = 'Documented Initial Requirement'; }
    value(2; Confirmed) { Caption = 'Confirmed Sample Manifest'; }
    value(3; Sourcing) { Caption = 'Sourcing Required Samples'; }
    value(4; Preparing) { Caption = 'Preparing Sample Package'; }
    value(5; Sent) { Caption = 'Samples Sent to Customer'; }
    value(6; Received) { Caption = 'Received by Customer'; }
}
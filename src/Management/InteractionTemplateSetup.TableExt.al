tableextension 50122 "TFB Interaction Template Setup" extends "Interaction Template Setup"
{

    fields
    {
        field(50100; "TFB Brokerage Cust. Update"; Code[10])
        {
            Caption = 'Brokerage Cust. Updates';
            TableRelation = "Interaction Template" where("Attachment No." = const(0));
            ObsoleteReason = 'Consolidated into single table';
            ObsoleteState = Pending;
            ObsoleteTag = '21';
        }
        field(50110; "TFB Certificate of Analysis"; Code[10])
        {
            Caption = 'Certificate of Analysis';
            TableRelation = "Interaction Template" where("Attachment No." = const(0));
            ObsoleteReason = 'Consolidated into single table';
            ObsoleteState = Pending;
            ObsoleteTag = '21';
        }
        field(50130; "TFB Shipment Status Enquiry"; Code[10])
        {
            Caption = 'Shipment Status Enquiries';
            TableRelation = "Interaction Template" where("Attachment No." = const(0));
            ObsoleteReason = 'Consolidated into single table';
            ObsoleteState = Pending;
            ObsoleteTag = '21';
        }
    }


}
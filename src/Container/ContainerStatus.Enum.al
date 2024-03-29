enum 50200 "TFB Container Status"
{
    Extensible = true;

    value(0; Planned)
    {
    }
    value(1; Booked)
    {

    }
    value(2; Dispatched)
    {
        Caption = 'Dispatched from Facility';
    }
    value(3; ShippedFromPort)
    {
        Caption = 'Shipped from Port';
    }
    value(4; PendingTreatment)
    {
        Caption = 'Pending Treatment';

    }
    value(5; PendingClearance)
    {
        Caption = 'Pending AQIS Clearance';
    }

    value(9; PendingUnpack)
    {
        Caption = 'Pending Unpack Report';

    }
    value(6; Closed)
    {
        Caption = 'Received and Closed';

    }
    value(7; Cancelled)
    {

    }
    value(8; ReExport)
    {
        Caption = 'Requires re-export';
    }


}
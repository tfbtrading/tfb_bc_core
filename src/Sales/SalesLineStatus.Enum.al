enum 50108 "TFB Sales Line Status"
{
    Extensible = true;

    value(0; None)
    {
    }
    value(10; ReservedFromStock)
    {
        Caption = 'Reserved From Stock';
    }
    value(20; ReservedFromStockPendingRelease)
    {
        Caption = 'Reserved From Stock Pending Release';
    }
    value(30; ReservedFromLocalPO)
    {
        Caption = 'Reserved From Local Purchase Order';

    }
    value(40; ReservedFromPlannedContainer)
    {
        Caption = 'Reserved From Planned Future Container';
    }
    value(50; ReservedFromInboundContainer)
    {
        Caption = 'Reserved from Inbound Container';
    }
    value(60; ReservedFromArrivedContainer)
    {
        Caption = 'Reserved from Arrived Container Pending Clearance';
    }
    value(70; SentToWarehouse)
    {
        Caption = 'Sent to warehouse for processing';
    }
    value(75; NotConfirmedByDropShipSupplier)
    {
        Caption = 'Awaiting Confirmation by Drop Ship Supplier';
    }
    value(80; ConfirmedByDropShipSupplier)
    {
        Caption = 'Confirmed by drop ship supplier';
    }
    value(90; ShippedPendingInvoice)
    {
        Caption = 'Shipped Not Invoiced';
    }
    value(100; ShippedAndInvoiced)
    {
        Caption = 'Shipped and Invoiced';
    }

}
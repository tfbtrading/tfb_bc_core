enum 50131 "TFB Forex Mgmt Entry Type"
{
    Extensible = true;

    value(0; ForexContract)
    {
          Caption = 'Forex Contract';
    }
    value(1; VendorLedgerEntry)
    {
        Caption = 'Vendor Ledger Entry';

    }
    value(2; PurchaseOrder)
    {
     Caption = 'Purchase Order';
    }
    value(3; Assignment)
    {

    }
}
enum 50119 "TFB Reservation Type"
{
    Extensible = true;

    Caption = 'Reservation Type';
    value(0; Reserved)
    {
        Caption = 'Reserved allocation';
    }
    value(1; Firm)
    {
        Caption = 'Firm allocation';
    }
}
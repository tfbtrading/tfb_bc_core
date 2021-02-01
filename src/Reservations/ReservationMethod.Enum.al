enum 50117 "TFB Reservation Method"
{
    Extensible = true;
    Caption = 'Reservation Method';
    value(0; Asap)
    {
        Caption = 'Allocate as soon as available before supply required by date';
    }
    value(1; Acap)
    {
        Caption = 'Allocate as close as possible to supply required by date';
    }
}
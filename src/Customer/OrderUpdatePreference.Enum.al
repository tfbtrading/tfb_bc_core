enum 50110 "TFB Order Update Preference"
{
    Extensible = true;

    value(0; OptOut)
    {
        Caption = 'Opt Out';

    }
    value(1; "DataOnly")
    {
        Caption = 'When Data Exists';

    }
    value(2; "Always")
    {
        Caption = 'Always Receive';

    }
}
enum 50107 "TFB Lot Status"
{
    Extensible = true;


    value(10; DoesNotExist)
    {
        Caption = 'Lot Detail Required';

    }
    value(20; ExistsWithIssue)
    {
        Caption = 'Issue To Be Resolved';

    }
    value(30; ExistsNoIssue)
    {
        Caption = 'Lot Info Correct';

    }
    value(40; NotRequired)
    {
        Caption = 'Not Required';

    }
}
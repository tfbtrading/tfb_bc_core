/// <summary>
/// Enum TFB Customer Stage (ID 50112).
/// </summary>
enum 50112 "TFB Contact Stage"
{
    Extensible = true;

    value(0; Lead)
    {
        Caption = 'Lead';
    }
    value(1; Prospect)
    {
        Caption = 'Prospect';
    }
    value(2; Converted)
    {
        Caption = 'Converted';
    }
}
codeunit 50123 "TFB Update Forex Entry Status"
{
    trigger OnRun()
    begin
        ForexMgmtEntry.SetRange(EntryType, Enum::"TFB Forex Mgmt Entry Type"::Assignment, Enum::"TFB Forex Mgmt Entry Type"::ForexContract);
        If ForexMgmtEntry.FindSet(true, false) then
            repeat
                ForexMgmtEntry.UpdateOpenStatus();
                ForexMgmtEntry.Modify(false);
            until ForexMgmtEntry.Next() = 0;

    end;

    var
        ForexMgmtEntry: Record "TFB Forex Mgmt Entry";
}
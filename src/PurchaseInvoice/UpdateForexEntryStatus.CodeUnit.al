codeunit 50123 "TFB Update Forex Entry Status"
{
    trigger OnRun()

    var
        Progress: Dialog;
        ProgressMsg: Label 'Updating contracts - ##1####', Comment = '%1 - outlines what contract is currently being processed';
    begin

        ForexMgmtEntry.SetRange(EntryType, Enum::"TFB Forex Mgmt Entry Type"::Assignment, Enum::"TFB Forex Mgmt Entry Type"::ForexContract);
        If ForexMgmtEntry.Findset(true) then begin

            Progress.Open(ProgressMsg, ForexMgmtEntry."External Document No.");
            repeat
                ForexMgmtEntry.UpdateOpenStatus();
                ForexMgmtEntry.Modify(false);
                Progress.Update(1, ForexMgmtEntry."External Document No.");
            until ForexMgmtEntry.Next() = 0;
            Progress.Close();
        end;

    end;

    var
        ForexMgmtEntry: Record "TFB Forex Mgmt Entry";
}
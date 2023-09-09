codeunit 50134 "TFB File Naming Mgmt"
{
    trigger OnRun()
    begin

    end;

    local procedure GenerateInvoiceFileName(DataRecRef: RecordRef; Extension: Text): Text
    var
        PstdInvoice: Record "Sales Invoice Header";
        PreFileNameLbl: Label 'Invoice %1 for %2.%3', Comment = '%1 = Number, %2=Customer Name %3=Extension';

    begin

        PstdInvoice.Get(DataRecRef.RecordId);
        exit(StrSubstNo(PreFileNameLbl, PstdInvoice."No.", PstdInvoice."Sell-to Customer Name", Extension))

    end;

    var

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Layout Reporting", OnGenerateFileNameOnAfterAssignFileName, '', false, false)]
    local procedure OnGenerateFileNameOnAfterAssignFileName(var FileName: Text; ReportID: Integer; Extension: Text; DataRecRef: RecordRef);
    var
        TestReportID: Integer;
    begin

        TestReportID := ReportID;

        case ReportID of
            6188472:
                FileName := GenerateInvoiceFileName(DataRecRef, Extension);

        end;
    end;

}
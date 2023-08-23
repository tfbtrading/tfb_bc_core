tableextension 50126 "TFB Contact Job Responsibility" extends "Contact Job Responsibility"
{
    fields
    {
        field(50001; "TFB Primary"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Primary';

            trigger OnValidate()
            var
                ContactJobResponsibility: record "Contact Job Responsibility";
                ConfirmMgmt: codeunit "Confirm Management";
            begin
                ContactJobResponsibility.SetFilter("Contact No.", '%1', Rec."Contact No.");
                ContactJobResponsibility.SetFilter("Job Responsibility Code", '<>%1', Rec."Job Responsibility Code");
                ContactJobResponsibility.SetRange("TFB Primary", true);
                if Rec."TFB Primary" then begin
                    if ContactJobResponsibility.FindFirst() then
                        if ConfirmMgmt.GetResponseOrDefault('Switch this industry to primary?', true) then begin
                            ContactJobResponsibility."TFB Primary" := false;
                            ContactJobResponsibility.modify(false);
                        end
                        else
                            Rec."TFB Primary" := false;
                end
                else
                    if ContactJobResponsibility.IsEmpty() then
                        FieldError("TFB Primary", 'Cannot be non-primary, no other primary exists');
            end;
        }
    }


    trigger OnInsert()
    var
        ContactJobResponsibility: record "Contact Job Responsibility";
    begin
        ContactJobResponsibility.SetFilter("Contact No.", '%1', Rec."Contact No.");
        ContactJobResponsibility.SetFilter("Job Responsibility Code", '<>%1', Rec."Job Responsibility Code");
        if ContactJobResponsibility.IsEmpty then
            Rec."TFB Primary" := true;

    end;
}
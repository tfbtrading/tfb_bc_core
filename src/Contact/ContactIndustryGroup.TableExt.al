tableextension 50112 "TFB Contact Industry Group" extends "Contact Industry Group"
{


    fields
    {
        field(50001; "TFB Primary"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Primary';

            trigger OnValidate()
            var
                ContactIndustryGroup2: record "Contact Industry Group";
                ConfirmMgmt: codeunit "Confirm Management";
            begin
                ContactIndustryGroup2.SetFilter("Contact No.", '%1', Rec."Contact No.");
                ContactIndustryGroup2.SetFilter("Industry Group Code", '<>%1', Rec."Industry Group Code");
                ContactIndustryGroup2.SetRange("TFB Primary", true);
                if Rec."TFB Primary" then begin
                    if ContactIndustryGroup2.FindFirst() then
                        if ConfirmMgmt.GetResponseOrDefault('Switch this industry to primary?', true) then begin
                            ContactIndustryGroup2."TFB Primary" := false;
                            ContactIndustryGroup2.modify(false);
                        end
                        else
                            Rec."TFB Primary" := false;
                end
                else
                    if ContactIndustryGroup2.IsEmpty() then
                        FieldError("TFB Primary", 'Cannot be non-primary, no other primary exists');
            end;
        }
    }

    keys
    {

    }

    var


    trigger OnInsert()
    var
        ContactIndustryGroup2: record "Contact Industry Group";
    begin
        ContactIndustryGroup2.SetFilter("Contact No.", '%1', Rec."Contact No.");
        ContactIndustryGroup2.SetFilter("Industry Group Code", '<>%1', Rec."Industry Group Code");
        if ContactIndustryGroup2.IsEmpty then
            Rec."TFB Primary" := true;

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
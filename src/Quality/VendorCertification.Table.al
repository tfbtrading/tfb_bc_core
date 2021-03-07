table 50101 "TFB Vendor Certification"
{
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Vendor No."; Code[20])
        {
            NotBlank = true;
            TableRelation = Vendor;
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                VendorRec: Record Vendor;
            begin
                VendorRec.Get("Vendor No.");
                "Vendor Name" := VendorRec.Name;
            end;
        }
        field(12; "Vendor Name"; Text[100])
        {
            NotBlank = true;
            TableRelation = Vendor;
            ValidateTableRelation = false;

            trigger OnValidate()

            var
                VendorRec: Record Vendor;
            begin

                Validate("Vendor No.", VendorRec.GetVendorNo("Vendor Name"));

            end;
        }
        field(20; "Certification Type"; code[20])
        {
            TableRelation = "TFB Certification Type";
            ValidateTableRelation = true;
            NotBlank = true;

            trigger OnValidate()

            var
                CertificationType: Record "TFB Certification Type";

            begin
                If CertificationType.Get(Rec."Certification Type") then
                    If CertificationType.Class <> CertificationType.Class::Religous then
                        Inherent := false;
            end;


        }
        field(25; "Certification Class"; enum "TFB Certification Class")
        {
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by lookup';

        }
        field(30; "Site"; Text[20])
        {
            NotBlank = true;
        }
        field(40; "Auditor"; Code[20])
        {
            TableRelation = "TFB Quality Auditor";
            ValidateTableRelation = true;
            NotBlank = true;
        }
        field(44; "Last Audit Date"; Date)
        {
            NotBlank = true;

        }
        field(46; "Expiry Date"; Date)
        {
            NotBlank = true;
        }
        field(53; "Last Modified Date Time"; DateTime)
        {
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteReason = 'Provided by system';
        }
        field(54; "Last Date Modified"; Date)
        {
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteReason = 'Provided by system';

        }
        field(56; "Certificate"; Blob)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by permanent blob';


        }
        field(57; "Certificate Attach."; BigInteger)
        {
            Editable = false;
        }
        field(60; "CertificationLogo"; Media)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("TFB Certification Type".Logo where(Code = field("Certification Type")));
        }

        field(65; "Certificate Class"; Enum "TFB Certification Class")
        {
            FieldClass = FlowField;
            CalcFormula = lookup("TFB Certification Type".Class where(Code = field("Certification Type")));
            Editable = false;
        }
        field(70; Inherent; Boolean)
        {
            Editable = true;

            trigger OnValidate()

            begin
                If Rec.Inherent then begin
                    Rec.CalcFields("Certificate Class");
                    If Rec."Certificate Class" = Rec."Certificate Class"::Religous then begin
                        "Last Audit Date" := 0D;
                        "Expiry Date" := 0D;
                        Auditor := '';
                    end
                    else
                        FieldError(Rec.Inherent, 'Only religious certifications can be inherent');
                end;
            end;
        }
        field(1; ID; Guid)
        {
            Editable = false;
            ObsoleteReason = 'Provided by system';
            ObsoleteState = Removed;
        }


    }



    keys
    {
        key(PK; "Vendor No.", "Certification Type", Site)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Vendor No.", "Vendor Name", "Certification Type", "Expiry Date", CertificationLogo) { }
    }

    trigger OnInsert()

    begin

        MarkAsModified();

    end;

    trigger OnModify()

    begin
        MarkAsModified();
    end;

    local procedure MarkAsModified()

    begin
        "Last Date Modified" := today();
        "Last Modified Date Time" := CurrentDateTime();
    end;

}
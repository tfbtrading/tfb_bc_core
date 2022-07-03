table 50118 "TFB Company Certification"
{
    DataClassification = CustomerContent;

    fields
    {

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

        field(26; "Location Specific"; Boolean)
        {
            Editable = true;

            trigger OnValidate()

            begin
                If not ("Location Code" <> '') then
                    FieldError("Location Code", 'The location code must be entered if company certification is location speciifc');
            end;
        }
        field(28; "Location Code"; Code[20])
        {
            Editable = true;
            TableRelation = Location;
            ValidateTableRelation = true;

        }
        field(29; "Location"; Text[255])
        {
            NotBlank = true;
            FieldClass = FlowField;
            CalcFormula = lookup(Location.Name where(code = field("Location Code")));
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
        field(85; "Certification No."; Code[20])
        {
            Editable = true;
        }
        field(80; Archived; Boolean)
        {
            Editable = false;

        }



    }



    keys
    {
        key(PK; "Certification Type", "Location Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Certification Type", Location, "Expiry Date", CertificationLogo) { }
    }




}
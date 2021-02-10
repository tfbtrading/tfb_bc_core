/// <summary>
/// TableExtension TFB Contact (ID 50110) extends Record Contact.
/// </summary>
tableextension 50110 "TFB Contact" extends Contact
{
    fields
    {

        field(50100; "TFB Contact Status"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Contact Status';
            TableRelation = "TFB Contact Status".Status;


            trigger OnValidate()

            begin
                validateContactStatus();
            end;
        }

        field(50170; "TFB Contact Stage"; enum "TFB Contact Stage")
        {
            Caption = 'Contact Stage';
            DataClassification = CustomerContent;
        }

        field(50172; "TFB Buying Reason"; Enum "TFB Buying Reason")
        {
            DataClassification = CustomerContent;
            Caption = 'Buying Reason';
        }

        field(50174; "TFB Buying Timeframe"; Enum "TFB Buying Timeframe")
        {
            DataClassification = CustomerContent;
            Caption = 'Buying Timeframe';
        }
        field(50176; "TFB Sales Readiness"; Enum "TFB Sales Readiness")
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Readiness';
        }
        field(50178; "TFB Lead Source"; Enum "TFB Lead Source")
        {
            DataClassification = CustomerContent;
            Caption = 'Lead Source';
        }
        field(50180; "TFB Is Customer"; Boolean)
        {
            CalcFormula = Exist("Contact Business Relation" WHERE("Contact No." = FIELD("Company No."), "Link to Table" = const(Customer)));
            Caption = 'Is A Customer';
            Editable = false;
            FieldClass = FlowField;


        }

        field(50182; "TFB Linkedin Page"; Text[255])
        {
            DataClassification = CustomerContent;
            Caption = 'LinkedIn page';
            ExtendedDatatype = URL;
        }

        field(50220; "TFB No. Of Company Tasks"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("To-do" where("Contact Company No." = field("Company No."), Closed = const(false), "System To-do Type" = const(Organizer)));
            Caption = 'No. Of Tasks';
        }
        field(50222; "TFB No. Of Contact Tasks"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("To-do" where("Contact No." = field("No."), Closed = const(false), "System To-do Type" = const(Organizer)));
            Caption = 'No. Of Tasks';
        }
        field(50230; "TFB No. Of Individuals"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Contact where("Company No." = field("Company No."), Type = const(Person)));
            Caption = 'No. Of Individuals';
        }
    }
    fieldgroups
    {
        addlast(Brick; "TFB Contact Stage", "TFB Contact Status", "E-Mail") { }
        addlast(DropDown; "TFB Contact Stage", "TFB Contact Status") { }
    }


    local procedure validateContactStatus()

    var
        Status: Record "TFB Contact Status";

    begin

        If Type = Type::Person then
            Rec."TFB Contact Status" := '';

        Status.SetRange(Status, Rec."TFB Contact Status");

        If Status.FindFirst() then
            Rec.validate("TFB Contact Stage", Status.Stage);



    end;

}
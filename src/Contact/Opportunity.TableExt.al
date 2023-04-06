tableextension 50114 "TFB Opportunity" extends Opportunity
{
    fields
    {
        field(50100; "TFB Buying Reason"; Enum "TFB Buying Reason")
        {
            DataClassification = CustomerContent;
            Caption = 'Buying reason';
        }

        field(50110; "TFB Buying Timeframe"; Enum "TFB Buying Timeframe")
        {
            DataClassification = CustomerContent;
            Caption = 'Buying timeframe';
        }

        field(50120; "TFB Details"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Details';

        }
        field(50210; "TFB No. Of Open Tasks"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("To-do" where(Closed = const(false), "Opportunity No." = field("No."), "System To-do Type" = const(Organizer)));
            Caption = 'No. Of Open Tasks';
        }
    }

    fieldgroups
    {
        addlast(DropDown; "Contact Company Name", "TFB Buying Timeframe") { }

    }


}
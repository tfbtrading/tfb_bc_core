tableextension 50119 "TFB Rel. Mgmt. Cue" extends "Relationship Mgmt. Cue"
{
    fields
    {
        field(50100; "TFB Recent Interactions"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Interaction Log Entry" where(Date = filter('>today-7D')));
        }
        field(50110; "TFB Open Tasks"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("To-do" where(Closed = const(false), "System To-do Type" = const(Organizer)));

        }
        field(50120; "TFB SalesPerson Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            Caption = 'SalesPerson Filter';
        }
        field(50130; "TFB My Prospects"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'My Prospects - Companies';
            CalcFormula = count(Contact where(Type = const(Company), "Salesperson Code" = field("TFB SalesPerson Filter"), "TFB Contact Stage" = const(Prospect)));
        }

        field(50140; "TFB My Leads"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'My Leads - Companies';
            CalcFormula = count(Contact where(Type = const(Company), "Salesperson Code" = field("TFB SalesPerson Filter"), "TFB Contact Stage" = const(Lead)));
        }

    }


}
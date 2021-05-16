tableextension 50119 "TFB Rel. Mgmt. Cue" extends "Relationship Mgmt. Cue"
{
    fields
    {
        field(50100; "TFB Recent Interactions"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Interaction Log Entry" where(Date = filter('>today-3D')));
        }
        field(50105; "TFB My Interactions"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'My Recent Interactions';
            CalcFormula = count("Interaction Log Entry" where(Date = filter('>today-3D'), "Salesperson Code" = field("TFB SalesPerson Filter")));
        }
        field(50110; "TFB Open Tasks"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'All Pending Tasks';
            CalcFormula = count("To-do" where(Closed = const(false), "System To-do Type" = const(Organizer)));

        }

        field(50115; "TFB My Tasks"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'My Pending Tasks';
            CalcFormula = count("To-do" where(Closed = const(false), "System To-do Type" = const(Organizer), "Salesperson Code" = field("TFB SalesPerson Filter")));

        }

        field(50120; "TFB SalesPerson Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            Caption = 'SalesPerson Filter';
        }
        field(50130; "TFB My Prospects"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'My Prospects';
            CalcFormula = count(Contact where(Type = const(Company), "Salesperson Code" = field("TFB SalesPerson Filter"), "TFB Contact Stage" = const(Prospect)));
        }

        field(50140; "TFB My Leads"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'My Leads';
            CalcFormula = count(Contact where(Type = const(Company), "Salesperson Code" = field("TFB SalesPerson Filter"), "TFB Contact Stage" = const(Lead)));
        }
        field(50150; "TFB My Opportunities"; Integer)
        {
            CalcFormula = Count(Opportunity WHERE(Closed = FILTER(false), "Salesperson Code" = field("TFB SalesPerson Filter")));
            Caption = 'My Open Opportunities';
            FieldClass = FlowField;
        }
        field(50135; "TFB No. Open Sample Requests"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'No. Open Sample Requests';
            CalcFormula = count("TFB Sample Request" where(Closed = const(false)));
        }

        field(50535; "Recent Filter"; DateTime)
        {
            Caption = 'Recent Filter';
            FieldClass = FlowFilter;
        }

    }


}
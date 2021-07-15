tableextension 50475 "TFB Activities Cue" extends "Activities Cue" //MyTargetTableId
{
    fields
    {
        field(50476; "TFB Ongoing Sales Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("Sales Line" where("Document Type" = filter(Order), "Completely Shipped" = filter(false), Type = filter(Item), "Document Type" = filter(Order)));
            Caption = 'Sales Lines';
        }

        field(50477; "TFB Ongoing Whse. Shipments"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("Warehouse Shipment Header");
            Caption = 'Whse. Shipments';
        }
        field(50478; "TFB Containers In Progress"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("TFB Container Entry" where(Status = filter(ShippedFromPort | PendingClearance | PendingTreatment)));
            Caption = 'Inbound Shipments';
        }
        field(50500; "TFB Open Opportunities"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count(Opportunity where(Closed = const(false)));
            Caption = 'Opportunities';
        }

        field(50505; "TFB My Opportunities"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count(Opportunity where(Closed = const(false), "Salesperson Code" = field("TFB Salesperson Code Filter")));
            Caption = 'Opportunities';
        }
        field(50130; "TFB No. Open Sample Requests"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'No. Open Sample Requests';
            CalcFormula = count("TFB Sample Request" where(Closed = const(false)));
        }

        field(50510; "TFB New Contacts"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count(Contact where(type = const(Company), SystemCreatedAt = field("Recent Filter"), "TFB Contact Stage" = filter('Lead|Prospect')));
            Caption = 'New Contacts - last 7 days';
        }
        field(50520; "TFB Tasks"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("To-do" where("System To-do Type" = const(Organizer), Closed = const(false)));
            Caption = 'Tasks - open';
        }
        field(50530; "TFB My Tasks"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("To-do" where("System To-do Type" = const(Organizer), Closed = const(false), "Salesperson Code" = field("TFB Salesperson Code Filter")));
            Caption = 'Tasks - mine';
        }

        field(50535; "Recent Filter"; DateTime)
        {
            Caption = 'Recent Filter';
            FieldClass = FlowFilter;
        }

        field(50525; "TFB Salesperson Code Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            Caption = 'Salesperson Code Filter';
        }




    }

}
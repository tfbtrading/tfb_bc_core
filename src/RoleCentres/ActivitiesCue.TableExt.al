tableextension 50475 "TFB Activities Cue" extends "Activities Cue" //MyTargetTableId
{
    fields
    {
        field(50476; "TFB Ongoing Sales Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Sales Line" where("Document Type" = filter(Order), "Completely Shipped" = filter(false), Type = filter(Item), "Document Type" = filter(Order)));
            Caption = 'Sales Lines';
        }

        field(50477; "TFB Ongoing Whse. Shipments"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Warehouse Shipment Header");
            Caption = 'Whse. Shipments';
        }
        field(50478; "TFB Containers In Progress"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("TFB Container Entry" where(Status = filter(ShippedFromPort | PendingClearance | PendingTreatment)));
            Caption = 'Inbound Shipments';
        }
        field(50500; "TFB Open Opportunities"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Opportunity where(Closed = const(false)));
            Caption = 'Opportunities';
        }

        field(50505; "TFB My Opportunities"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Opportunity where(Closed = const(false), "Salesperson Code" = field("TFB Salesperson Code Filter")));
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
            CalcFormula = count(Contact where(type = const(Company), SystemCreatedAt = field("Recent Filter"), "TFB Contact Stage" = filter('Lead|Prospect')));
            Caption = 'New Contacts - last 7 days';
        }
        field(50520; "TFB Tasks"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("To-do" where("System To-do Type" = const(Organizer), Closed = const(false)));
            Caption = 'Tasks - open';
        }
        field(50530; "TFB My Tasks"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("To-do" where("System To-do Type" = const(Organizer), Closed = const(false), "Salesperson Code" = field("TFB Salesperson Code Filter")));
            Caption = 'Tasks - mine';
        }

        field(50535; "Recent Filter"; DateTime)
        {
            Caption = 'Recent Filter';
            FieldClass = FlowFilter;
        }
        field(50536; "Next Six Months Filter"; DateTime)
        {
            Caption = 'Next Six Months Filter';
            FieldClass = FlowFilter;
        }

        field(50525; "TFB Salesperson Code Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            Caption = 'Salesperson Code Filter';
        }

        field(50526; "TFB Purchase Pending Confirm."; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = const(Order), "Completely Received" = const(false), "TFB Manual Confirmation" = const(false)));
            Caption = 'Purchases Pending Confirmation';
        }

        field(50527; "TFB No. Sales Lines Prepay."; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Sales Line" where("Document Type" = const(Order), "Prepayment Amount" = filter('>0')));
            Caption = 'Sales with Prepayment';
        }
        field(50100; "TFB No. Lots Expired"; Integer)
        {
            AutoFormatExpression = GetAmountFormat();
            Caption = 'No. Lots Expired';

        }
        field(50101; "TFB No. Lots Expiring"; Integer)
        {
            AutoFormatExpression = GetAmountFormat();
            Caption = 'No. Lots Expiring';

        }


    }

}
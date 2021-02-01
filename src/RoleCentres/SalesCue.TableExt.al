tableextension 50476 "TFB Sales Cue" extends "Sales Cue" //9053
{
    
    fields
    {
        field(50476; "TFB Ongoing Sales Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count ("Sales Line" where("Document Type" = filter(Order), "Completely Shipped" = filter(false), Type = filter(Item), "Document Type" = filter(Order)));
            Caption = 'Sales Lines - Ongoing';
        }

        field(50477; "TFB Ongoing Whse. Shipments"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count ("Warehouse Shipment Header");
            Caption = 'Whse. Shipments - Ongoing';
        }
        field(50478; "TFB Containers In Progress"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count ("TFB Container Entry" where(Status = filter(PendingFumigation | Dispatched | PendingClearance | ShippedFromPort)));
            Caption = 'Containers';
        }
        field(50100; "TFB Purchase Orders"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count ("Purchase Header" where("Document Type" = const(Order)));
            Caption = 'Purchases - Ongoing';
        }

    }

}
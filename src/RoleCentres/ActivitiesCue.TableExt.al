tableextension 50475 "TFB Activities Cue" extends "Activities Cue" //MyTargetTableId
{
    fields
    {
        field(50476; "TFB Ongoing Sales Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count ("Sales Line" where("Document Type" = filter(Order), "Completely Shipped" = filter(false), Type = filter(Item), "Document Type" = filter(Order)));
            Caption = 'Sales Lines';
        }

        field(50477; "TFB Ongoing Whse. Shipments"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count ("Warehouse Shipment Header");
            Caption = 'Whse. Shipments';
        }
        field(50478; "TFB Containers In Progress"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count ("TFB Container Entry" where(Status = filter(ShippedFromPort | PendingClearance | PendingFumigation)));
            Caption = 'Inbound Shipments';
        }




    }

}
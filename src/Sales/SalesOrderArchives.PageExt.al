pageextension 50119 "TFB Sales Order Archives" extends "Sales Order Archives"
{
    layout
    {
        // Add changes to page layout here

    }

    actions
    {
        addlast(Processing)
        {
            action(TFBSendPODRequest)
            {
                Caption = 'Send POD request';
                ApplicationArea = All;
                Image = SendMail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Sends a proof of delivery request to the relevant party who managed delivery';

                trigger OnAction()
                var
                    SalesShipment: Record "Sales Shipment Header";
                    ShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";

                begin

                    Clear(SalesShipment);
                    SalesShipment.SetRange("Order No.", Rec."No.");


                    if SalesShipment.FindSet() then
                        repeat
                            ShipmentCU.SendShipmentStatusQuery(SalesShipment, Rec."No.");

                        until SalesShipment.Next() < 1
                    else
                        Message('No Sales Shipments found');


                end;


            }
        }
    }


}
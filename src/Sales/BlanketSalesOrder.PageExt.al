pageextension 50138 "TFB Blanket Sales Order" extends "Blanket Sales Order" //507
{
    layout
    {
        addlast("Shipping and Billing")
        {
            field("TFB Instructions"; Rec."TFB Instructions")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies any specific instructions related to the blanket contract';
                Importance = Standard;
                MultiLine = true;
                Caption = 'Instructions';
            }
        }

        addafter("Order Date")
        {
            field("Requested Delivery Date"; Rec."Requested Delivery Date")
            {
                ApplicationArea = All;
                Importance = Standard;
                ToolTip = 'Specifies when the customer wants the order delivered';
            }
        }


        addbefore("Document Date")

        {
            group("TFBContract Details")
            {
                Caption = 'Contract Details';
                field("TFB Start Date"; Rec."TFB Start Date")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies start date for shipments to occur';

                }
                field("TFB End Date"; Rec."TFB End Date")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies the date by which shipments should be completed';
                }
                field("TFB Blanket DropShip"; Rec."TFB Blanket DropShip")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    tooltip = 'Specifies if the blanket agreement is for a dropshipment';

                    trigger OnValidate()

                    begin
                        if Rec."TFB Blanket DropShip" then
                            Rec."TFB Direct to Customer" := true
                        else
                            Rec."TFB Direct to Customer" := false;
                    end;
                }
                group(DropShip)
                {
                    Visible = Rec."TFB Blanket DropShip";
                    ShowCaption = false;

                    field("TFB Blanket PO"; BlanketPOLookUp)
                    {
                        ApplicationArea = All;
                        Caption = 'Blanket Purchase Order No.';
                        Editable = false;
                        ToolTip = 'Specifies the related blanket purchase order number';

                    }

                }



            }

        }

        addfirst("Shipment Method")
        {
            field("TFB Direct to Customer"; Rec."TFB Direct to Customer")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if all the items will be drop shipped directly to the customer. Usually reserved for trailor loads of items';
            }
        }


    }

    actions
    {
        addlast(Navigation)
        {
            action("TFBPBlanketPO")
            {
                Enabled = Rec."TFB Blanket DropShip";
                Caption = 'Blanket Purchase Order';
                Image = BlanketOrder;
                ApplicationArea = All;
                ToolTip = 'Opens related blanket order';

                trigger OnAction()

                var
                    BlanketPORec: record "Purchase Header";
                    BlanketPO: page "Blanket Purchase Order";

                begin

                    BlanketPORec.setrange("Document Type", BlanketPORec."Document Type"::"Blanket Order");
                    BlanketPORec.setrange("TFB Blanket DropShip", true);
                    BlanketPORec.setrange("TFB Sales Blanket Order No.", Rec."No.");

                    if BlanketPORec.FindFirst() then begin
                        BlanketPO.SetRecord(BlanketPORec);
                        BlanketPO.Run();
                    end else
                        Message('No Sales Blanket Order Created Yet');


                end;
            }
        }

        addlast(Category_Category8)
        {
            actionref(TFBBlanketPO_Promoted; TFBPBlanketPO)
            {

            }
        }

    }
    trigger OnAfterGetRecord()
    var
        BlanketPORec: Record "Purchase Header";


    begin
        BlanketPORec.setrange("Document Type", BlanketPORec."Document Type"::"Blanket Order");
        BlanketPORec.setrange("TFB Blanket DropShip", true);
        BlanketPORec.setrange("TFB Sales Blanket Order No.", Rec."No.");

        if BlanketPORec.FindFirst() then
            BlanketPOLookUp := BlanketPORec."No.";

    end;

    var
        BlanketPOLookUp: Code[20];
}
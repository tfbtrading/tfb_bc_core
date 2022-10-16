pageextension 50122 "TFB Blanket Purchase Order" extends "Blanket Purchase Order" //509
{
    layout
    {
        addbefore("Document Date")

        {
            group("TFBContract Details")
            {
                Caption = 'Contract Details';

                field("TFB Start Date"; Rec."TFB Start Date")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies start date from which goods can be shipped';

                }
                field("TFB End Date"; Rec."TFB End Date")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    Tooltip = 'Specifies end date before which goods need to be shipped';
                }
                field("TFB Blanket DropShip"; Rec."TFB Blanket DropShip")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies if this blanket order is for a drop shipment';
                }
                group(TFBDropShipDetails)
                {
                    ShowCaption = false;
                    Visible = Rec."TFB Blanket DropShip";
                    field("TFB Sales Blanket Order No."; Rec."TFB Sales Blanket Order No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the related sales blanket order number';

                        trigger OnLookup(var Text: Text): Boolean

                        var
                            BlanketSO: Record "Sales Header";

                        begin
                            BlanketSO.SetRange("Document Type", Rec."Document Type"::"Blanket Order");

                            If Page.RunModal(9303, BlanketSO) = ACTION::LookupOK then
                                Rec."TFB Sales Blanket Order No." := BlanketSO."No.";

                        end;
                    }
                }

            }
        }
    }

    actions
    {
        addlast(Navigation)
        {
            action("TFBBlanketSalesOrder")
            {
                Enabled = Rec."TFB Sales Blanket Order No." <> '';
                Image = BlanketOrder;
                ApplicationArea = All;
                Caption = 'Blanket Sales Order';
                ToolTip = 'Opens blanket sales order if drop shipment';

                trigger OnAction()

                var
                    BlanketRec: Record "Sales Header";
                    BlanketSO: Page "Blanket Sales Order";

                begin

                    BlanketRec.SetRange("Document Type", BlanketRec."Document Type"::"Blanket Order");
                    BlanketRec.SetRange("No.", Rec."TFB Sales Blanket Order No.");

                    If BlanketRec.FindFirst() then begin
                        BlanketSO.SetRecord(BlanketRec);
                        BlanketSO.Run();
                    end;
                end;
            }
        }
        addlast(Category_Category8)
        {
            actionref(ActionRefName; "TFBBlanketSalesOrder")
            {

            }
        }
    }
}
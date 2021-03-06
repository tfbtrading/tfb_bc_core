pageextension 50270 "TFB Item Card" extends "Item Card"
{


    layout
    {
        addafter(Inventory)
        {
            field("Qty. in Transit"; Rec."Qty. in Transit")
            {
                Importance = Standard;
                ApplicationArea = All;
                ToolTip = 'Specifies current qty in transit';

            }
            field("Qty. Assigned to ship"; Rec."Qty. Assigned to ship")
            {
                Importance = Additional;
                ApplicationArea = All;
                ToolTip = 'Specifies qty assigned to warehouse shipments';
            }

        }
        addafter(Blocked)
        {
            field("TFB Publish POA Only"; Rec."TFB Publish POA Only")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if only price on application should be shown in price list';
            }
            field("TFB Publishing Block"; Rec."TFB Publishing Block")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if item should be blocked from being shown on price list';
            }

        }
        addlast(Replenishment)
        {
            group("TFB Quarantine")
            {
                Caption = 'AQIS Requirements';
                field("TFB Requires Permit"; Rec."TFB Permit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if item requires a permit';
                }
                field("TFB Mandatory Fumigation"; Rec."TFB Fumigation")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies if item required mandatory fumigation';

                }
                field("TFB Heat Treatment"; Rec."TFB Heat Treatment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if item requires mandatory heat treatment';
                }
                field("TFB Mandatory Inspection"; Rec."TFB Inspection")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if item required a mandatory inspection';
                }

            }
        }

        addafter("Indirect Cost %")
        {
            field("TFB Est. Storage Duration"; Rec."TFB Est. Storage Duration")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies standard estimation duration for storage';
            }

        }
        addafter("Purchasing Blocked")
        {
            group(DropshipDetails)
            {
                ShowCaption = false;
                Visible = DropShipDefault;
                field("TFB DropShip Avail."; Rec."TFB DropShip Avail.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies drop ship item availability';
                }
                field("TFB DropShip ETA"; Rec."TFB DropShip ETA")
                {

                    ApplicationArea = All;
                    ToolTip = 'Specifies estimated availability if drop ship item is not available';
                }
            }

        }
        addafter("Country/Region of Origin Code")
        {

            field("Country/Region Purchased Code"; Rec."Country/Region Purchased Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies country from which item is purchased';
            }
        }
        addafter("No.")
        {
            field("TFB Act As Generic"; Rec."TFB Act As Generic")
            {
                ApplicationArea = All;
                Importance = Standard;
                ToolTip = 'Specifies if product should act as generic item. ';
            }
        }
        addafter(Description)
        {
            Group(GenericParent)
            {
                ShowCaption = false;
                Visible = not Rec."TFB Act As Generic";
                field("TFB Parent Generic Item Name"; Rec."TFB Parent Generic Item Name")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies parent item if item is not acting as a generic';

                }

            }
            Group(GenericSelf)
            {
                ShowCaption = false;
                Visible = Rec."TFB Act As Generic";
                field(TFBGenericExtensionName; GetGenericExtensionName())
                {
                    Caption = 'Generic Description';
                    ApplicationArea = All;
                    Editable = Rec."TFB Generic Link Exists";
                    Importance = Standard;
                    ToolTip = 'Specifies the generic item name drawn from the generic item table';

                }

            }
            field("TFB Alt. Names"; Rec."TFB Alt. Names")
            {
                ApplicationArea = All;
                Importance = Standard;
                ToolTip = 'Specifies alternative names for item';
            }




        }
        addafter("Common Item No.")
        {
            field("TFB Long Desc."; Rec."TFB Long Desc.")
            {
                ApplicationArea = All;
                Importance = Additional;
                MultiLine = true;
                ToolTip = 'Specifies long description for item';
            }
        }

        modify("Unit Price")
        {
            trigger OnAfterValidate()

            begin
                Rec."TFB Unit Price Source" := ''; // Clear as manual override
            end;
        }
        addafter("Unit Price")
        {
            field("TFB Unit Price Per Kg"; GetPricePerKg())
            {
                Editable = false;
                ApplicationArea = All;
                Caption = 'Unit Price Per Kg';
                ToolTip = 'Specifies the per kilogram unit price based on item weight';
                Importance = Standard;
            }
            field("TFB Unit Price Source"; Rec."TFB Unit Price Source")
            {
                Editable = false;
                ApplicationArea = all;
                ToolTip = 'Specifies if the unit price source is linked with a customer price group';
                Importance = Standard;
            }

        }
        addafter("Unit Cost")
        {
            field("TFB Unit Cost per Kg"; GetUnitCostPerKg())
            {
                ApplicationArea = All;
                Caption = 'Unit Cost Per Kg';
                Editable = false;
                ToolTip = 'Specifies the unit cost per kilogram';
            }
        }
    }
    actions
    {
        addlast(ItemActionGroup)
        {
            action(TFBItemCostings)
            {
                ApplicationArea = All;
                Caption = 'Item Costings';
                Image = CostEntries;
                RunObject = page "TFB Item Costing List";
                RunPageLink = "Item No." = field("No.");
                RunPageMode = View;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ToolTip = 'Open item costings list for item';


            }


        }

        addafter("Item Re&ferences")
        {
            action("TFBGenericItem")
            {
                ApplicationArea = All;
                Image = Navigate;
                Caption = 'Generic Item';
                ToolTip = 'Open related generic item';
                RunObject = Page "TFB Generic Item";
                RunPageLink = SystemId = field("TFB Generic Item ID");
                RunPageMode = View;
                Enabled = Rec."TFB Generic Link Exists";
            }
        }
    }

    local procedure GetPricePerKg(): Decimal

    begin
        If Rec."Net Weight" > 0 then
            exit(Rec."Unit Price" / Rec."Net Weight")
        else
            exit(0);
    end;

    local procedure GetUnitCostPerKg(): Decimal

    begin
        If Rec."Net Weight" > 0 then
            exit(Rec."Unit Cost" / Rec."Net Weight")
        else
            Exit(0);
    end;

    trigger OnAfterGetRecord()
    begin
        CheckAndUpdateDropShipDetails();
        Rec.CalcFields(Rec."TFB Generic Link Exists");

    end;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields(Rec."TFB Generic Link Exists");
    end;

    var
        DropShipDefault: Boolean;


    local procedure CheckAndUpdateDropShipDetails()

    var
        PurchasingCode: Record Purchasing;

    begin


        If PurchasingCode.Get(rec."Purchasing Code") then
            DropShipDefault := PurchasingCode."Drop Shipment"
        else
            DropShipDefault := false;


    end;

    local procedure GetGenericExtensionName(): Text[255]

    var
        GenericItem: Record "TFB Generic Item";
    begin
        If Rec."TFB Act As Generic" = true then
            If not IsNullGuid(Rec."TFB Generic Item ID") then
                If GenericItem.GetBySystemId(Rec."TFB Generic Item ID") then
                    Exit(GenericItem.Description)
                else
                    Exit('Error-not found')
            else
                Exit('Pending save')
        else
            Exit('Not Extension');

    end;

}
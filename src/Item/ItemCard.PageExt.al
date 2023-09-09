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

        addbefore("Net Weight")
        {
            field("TFB Multi-item Pallet Option"; Rec."TFB Multi-item Pallet Option")
            {
                Importance = Additional;
                ApplicationArea = All;
                ToolTip = 'Specifics the most flexible options available when wanting to mix this item on a pallet';

            }
            group(MultiItem)
            {
                ShowCaption = false;
                Visible = Rec."TFB Multi-item Pallet Option" = Rec."TFB Multi-item Pallet Option"::Layer;

                field("TFB No. Of Bags Per Layer"; Rec."TFB No. Of Bags Per Layer")
                {
                    Importance = Additional;
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many bags or carton in a layer on the pallet';
                }
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
            group(GenericParent)
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
            group(GenericSelf)
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

        modify("Vendor No.")
        {
            trigger OnAfterValidate()

            var
            begin
                ShowOrderAddressOption := CheckIfOrderAddressExists();

                if (Rec."Vendor No." <> xRec."Vendor No.") or (Rec."Vendor No." = '') then
                    Rec."TFB Vendor Order Address" := '';
            end;
        }

        addafter("Vendor No.")
        {
            group(VendorOrderDetails)
            {
                Visible = ShowOrderAddressOption;
                ShowCaption = false;

                field("TFB Vendor Order Address"; Rec."TFB Vendor Order Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which site this item originates at if the supplier has alternative sites';
                    Enabled = ShowOrderAddressOption;
                    Importance = Promoted;

                }
            }
        }

        addafter("Vendor Item No.")
        {
            field("TFB Vendor is Agent"; Rec."TFB Vendor is Agent")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the vendor is only purchased on behalf of our company and the manufacturer is a different entity. Useful for quality and branding';

            }
            group(TFBVendorAgent)
            {
                ShowCaption = false;
                Visible = Rec."TFB Vendor is Agent";

                field("TFB Item Manufacturer/Brand"; Rec."TFB Item Manufacturer/Brand")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actual manufacturer or company brand of goods being purchased.';
                }
            }
        }
        modify(Inventory)
        {
            Style = Ambiguous;


            trigger OnDrillDown()

            var
                ItemLedgerEntry: Record "Item Ledger Entry";


            begin
                ItemLedgerEntry.FilterGroup(10);
                ItemLedgerEntry.SetRange("Item No.", Rec."No.");
                ItemLedgerEntry.SetFilter("Location Code", Rec."Location Filter");
                ItemLedgerEntry.SetFilter("Variant Code", Rec."Variant Filter");
                ItemLedgerEntry.SetFilter("Lot No.", Rec."Lot No. Filter");
                ItemLedgerEntry.SetFilter("Remaining Quantity", '>0');
                ItemLedgerEntry.FilterGroup(0);
                PAGE.Run(PAGE::"Item Ledger Entries", ItemLedgerEntry);
            end;
        }
    }
    actions
    {
        addlast(Navigation_Item)
        {
            action(TFBItemCostings)
            {
                ApplicationArea = All;
                Caption = 'Item Costings';
                Image = CostEntries;
                RunObject = page "TFB Item Costing List";
                RunPageLink = "Item No." = field("No.");
                RunPageMode = View;

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

            action("TFBDownloadSpec")
            {
                ApplicationArea = All;
                Image = ExportFile;
                Caption = 'Download Specification';
                ToolTip = 'Find and download specification file';


                Enabled = true;

                trigger OnAction()

                var
                    ItemCU: CodeUnit "TFB Item Mgmt";

                begin

                    ItemCU.DownloadItemSpecification(Rec);

                end;

            }

            action("TFBDownloadMSDS")
            {
                ApplicationArea = All;
                Image = ExportFile;
                Caption = 'Download MSDS';
                ToolTip = 'Find and download Material Safety Data Sheet';


                Enabled = true;

                trigger OnAction()

                var
                    Item: Record Item;
                    ItemCU: CodeUnit "TFB Item Mgmt";

                begin
                    CurrPage.SetSelectionFilter(Item);
                    ItemCU.DownloadItemMSDS(Item);

                end;

            }
        }




    }



    local procedure GetPricePerKg(): Decimal

    begin
        if Rec."Net Weight" > 0 then
            exit(Rec."Unit Price" / Rec."Net Weight")
        else
            exit(0);
    end;

    local procedure CheckIfOrderAddressExists(): Boolean

    var
        OrderAddress: Record "Order Address";
    begin

        OrderAddress.SetRange("Vendor No.", Rec."Vendor No.");

        exit(not OrderAddress.IsEmpty())

    end;

    local procedure GetUnitCostPerKg(): Decimal

    begin
        if Rec."Net Weight" > 0 then
            exit(Rec."Unit Cost" / Rec."Net Weight")
        else
            exit(0);
    end;

    trigger OnAfterGetRecord()
    begin
        CheckAndUpdateDropShipDetails();
        ShowOrderAddressOption := CheckIfOrderAddressExists();
        Rec.CalcFields(Rec."TFB Generic Link Exists");

    end;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields(Rec."TFB Generic Link Exists");
        ShowOrderAddressOption := CheckIfOrderAddressExists();
    end;

    var
        DropShipDefault: Boolean;
        ShowOrderAddressOption: Boolean;

    local procedure CheckAndUpdateDropShipDetails()

    var
        PurchasingCode: Record Purchasing;

    begin


        if PurchasingCode.Get(rec."Purchasing Code") then
            DropShipDefault := PurchasingCode."Drop Shipment"
        else
            DropShipDefault := false;


    end;

    local procedure GetGenericExtensionName(): Text[255]

    var
        GenericItem: Record "TFB Generic Item";
    begin
        if Rec."TFB Act As Generic" = true then
            if not IsNullGuid(Rec."TFB Generic Item ID") then
                if GenericItem.GetBySystemId(Rec."TFB Generic Item ID") then
                    exit(GenericItem.Description)
                else
                    exit('Error-not found')
            else
                exit('Pending save')
        else
            exit('Not Extension');

    end;

}
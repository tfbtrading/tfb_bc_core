/// <summary>
/// PageExtension TFB Item List (ID 50117) extends Record Item List.
/// </summary>
pageextension 50117 "TFB Item List" extends "Item List"
{

    layout
    {

        modify(Description)
        {
            Style = Unfavorable;
            StyleExpr = IsBlockedFromSale;
        }
        modify("Unit Cost")
        {
            Visible = false;
        }
        modify("Unit Price")
        {
            Visible = false;
        }
        modify("Base Unit of Measure")
        {
            Visible = false;
        }

        addafter(Type)
        {
            field(TFBDropShip; IsDropShipByDefault)
            {
                Caption = 'Usually dropship.';
                ApplicationArea = All;

                ToolTip = 'Specifies if an item is usually sent directly from the supplier to the customer and not held in inventory';
            }

            field(TFBSalesPrice; SalesPriceVar)
            {
                Caption = 'Local Sales Price Per Kg';
                ApplicationArea = All;
                BlankZero = true;
                ToolTip = 'Specifies the local sales price per kg';

                trigger OnDrillDown()

                var
                    PriceListLine: Record "Price List Line";
                    PriceListLineReview: Page "Price List Line Review";

                begin
                    PriceListLine.SetRange("Asset No.", Rec."No.");
                    PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
                    PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
                    PriceListLine.Setrange(Status, PriceListLine.Status::Active);
                    PriceListLine.SetFilter("Ending Date", '=%1|>=%2', 0D, WorkDate());
                    PriceListLineReview.SetTableView(PriceListLine);
                    PriceListLineReview.LookupMode(false);
                    PriceListLineReview.RunModal();

                end;

            }
            field(TFBLastPriceChangedDate; LastChangedDateVar)
            {
                Caption = 'Last Changed';
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                ToolTip = 'Specifies the date the local sales price was changed';
            }

            field("TFB Out. Qty. On Sales Order"; Rec."TFB Out. Qty. On Sales Order")
            {
                ApplicationArea = All;
                BlankZero = true;
                DrillDownPageId = "TFB Pending Sales Lines";
                ToolTip = 'Specifies qty currently listed on sales orders';
            }


        }
        addafter(InventoryField)
        {
            field("TFB Inventory - Excl. Transit"; Rec."TFB Inventory - Excl. Transit")
            {
                ApplicationArea = All;
                BlankZero = true;
                ToolTip = 'Specifies remaining inv. excl. transit';
            }
            field("Qty. in Transit"; Rec."Qty. in Transit")
            {
                ApplicationArea = All;
                BlankZero = true;
                ToolTip = 'Specific qty currently in transit';
            }

            field("Reserved Qty. on Inventory"; Rec."Reserved Qty. on Inventory")
            {
                ApplicationArea = All;
                BlankZero = true;
                ToolTip = 'Specifies qty reserved against inventory';
            }
            field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
            {
                ApplicationArea = All;
                BlankZero = true;
                ToolTip = 'Specifies qty currently on purchase orders';
            }

        }

        modify(InventoryField)
        {
            Style = Ambiguous;
            StyleExpr = IsDropShipByDefault;

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


        addlast(processing)
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
        addafter("Item Refe&rences")
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
            action("TFBEmailSpec")
            {
                ApplicationArea = All;
                Image = SendEmailPDF;
                Caption = 'Email Specification';
                ToolTip = 'Find and email specifications to selected contact';

                Enabled = true;

                trigger OnAction()

                var
                    Item: Record Item;
                    ItemCU: CodeUnit "TFB Item Mgmt";
                begin
                    CurrPage.SetSelectionFilter(Item);
                    ItemCU.SendSelectedItemSpecifications(Item);

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

                    ItemCU: CodeUnit "TFB Item Mgmt";

                begin

                    ItemCU.DownloadItemMSDS(Rec);

                end;

            }
            action(TFBLotImages)
            {
                ApplicationArea = All;
                Image = Picture;
                Caption = 'Lot Images';
                ToolTip = 'Show lot images stored against this item';
                Enabled = true;

                trigger OnAction()

                var
                    LotImage: Record "TFB Lot Image";


                begin

                    LotImage.FilterGroup(0);
                    LotImage.SetFilter("Item No.", Rec."No.");
                    LotImage.FilterGroup(4);
                    LotImage.SetAscending(SystemCreatedAt, false);

                    Page.Run(Page::"TFB Lot Images", LotImage);

                end;
            }
        }
        addfirst(Inventory)
        {


            action(TFBAvailabilityByEvent)
            {
                ApplicationArea = All;

                Image = ItemAvailabilitybyPeriod;
                Caption = 'Item Availability By Event';
                ToolTip = 'Open up item availability by event view';

                trigger OnAction()
                var
                    InventoryCU: CodeUnit "Item Availability Forms Mgt";

                begin

                    InventoryCU.ShowItemAvailFromItem(rec, InventoryCU.ByEvent());

                end;
            }
        }
        addlast(Category_Category4)
        {
            actionref(TFBItemCostingsRef; TFBItemCostings)
            {

            }
            group(Specification)
            {
                ShowAs = SplitButton;

                actionref(TFBPEmailSpecification; TFBEmailSpec)
                {

                }
                actionref(TFBDownloadSpecRef; TFBDownloadSpec)
                {

                }
                actionref(TFBDownloadMSDSRef; TFBDownloadMSDS)
                {

                }
            }

        }
        addfirst(Category_Category5)
        {
            actionref(LedgerEntryRef; "Ledger E&ntries")
            {

            }
            actionref(InventoryAvailRef; "Inventory Availability")
            {

            }
        }

    }

    var

        ItemMgmtCU: CodeUnit "TFB Item Mgmt";
        LastChangedDateVar: Date;
        IsDropShipByDefault: Boolean;

        IsBlockedFromSale: Boolean;

        SalesPriceVar: Decimal;





    trigger OnAfterGetRecord()


    begin


        Clear(SalesPriceVar);
        Clear(LastChangedDateVar);
        Rec.SetAutoCalcFields("TFB Generic Link Exists");
        IsDropShipByDefault := GetIfUsuallyDropship();
        IsBlockedFromSale := GetIfBlockedFromSale();
        ItemMgmtCU.GetItemDynamicDetails(Rec."No.", SalesPriceVar, LastChangedDateVar);


    end;

    local procedure GetIfBlockedFromSale(): Boolean

    begin
        exit(Rec.Blocked or Rec."Sales Blocked");
    end;

    local procedure GetIfUsuallyDropship(): Boolean

    var

        PurchCode: Record Purchasing;

    begin

        if PurchCode.Get(Rec."Purchasing Code") then
            exit(PurchCode."Drop Shipment");
    end;

}
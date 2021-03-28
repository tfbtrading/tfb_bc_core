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
                Visible = not ExtendedPriceEnabled;

                trigger OnDrillDown()

                var
                    SPLD: Page "Sales Price and Line Discounts";

                begin

                    SPLD.LoadItem(Rec);
                    SPLD.InitPage(True);
                    SPLD.RunModal();

                end;

            }

            field(TFBSalesPriceNew; _salesPriceVar)
            {
                AccessByPermission = TableData "Sales Price Access" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Local Sales Price';

                Visible = ExtendedPriceEnabled;
                ToolTip = 'Set up sales prices for the item. An item price is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                trigger OnDrillDown()
                var
                    AmountType: Enum "Price Amount Type";
                    PriceType: Enum "Price Type";
                begin
                    Rec.ShowPriceListLines(PriceType::Sale, AmountType::Price);
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
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
        }
        addfirst(Inventory)
        {


            action(TFBAvailabilityByEvent)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
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
    }

    var

        IsDropShipByDefault: Boolean;

        IsBlockedFromSale: Boolean;

        SalesPriceVar: Decimal;

        ItemMgmtCU: CodeUnit "TFB Item Mgmt";

        LastChangedDateVar: Date;

        _salesPriceVar: Decimal;


    trigger OnAfterGetRecord()


    begin


        Clear(SalesPriceVar);
        Clear(LastChangedDateVar);
        Rec.SetAutoCalcFields("TFB Generic Link Exists");
        IsDropShipByDefault := GetIfUsuallyDropship();
        IsBlockedFromSale := GetIfBlockedFromSale();
        If not ExtendedPriceEnabled then
            ItemMgmtCU.GetItemDynamicDetails(Rec."No.", SalesPriceVar, LastChangedDateVar)
        else
            ItemMgmtCU.GetPriceListDynamicDetails(Rec."No.", _salesPriceVar, LastChangedDateVar);


    end;

    local procedure GetIfBlockedFromSale(): Boolean

    begin
        Exit(Rec.Blocked or Rec."Sales Blocked");
    end;

    local procedure GetIfUsuallyDropship(): Boolean

    var

        PurchCode: Record Purchasing;

    begin

        If PurchCode.Get(Rec."Purchasing Code") then
            Exit(PurchCode."Drop Shipment");
    end;

}
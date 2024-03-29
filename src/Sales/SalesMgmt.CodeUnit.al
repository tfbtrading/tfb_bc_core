/// <summary>
/// Codeunit TFB Sales Mgmt (ID 50122).
/// </summary>
codeunit 50122 "TFB Sales Mgmt"
{




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure OnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; WhseShip: Boolean; WhseReceive: Boolean; var EverythingInvoiced: Boolean);

    var




    begin
        /* 
        GLAccNo := '5330';
        GLAmount := 100;
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := SalesInvoiceHeader."Posting Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Document No." := SalesInvoiceHeader."No.";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := GLAccNo;
        GenJnlLine.Description := 'Estimated freight provisional charge';
        GenJnlLine.Amount := GLAmount;

        SalesInvoiceHeader.CalcFields(Amount);
        If not ((SalesInvoiceHeader."No." <> '') and (SalesInvoiceHeader.Amount > 0)) then exit;
        Message('About to post %1 for %2', SalesInvoiceHeader."No.", SalesInvoiceHeader.Amount);

        GenJnlPostLine.InitGLEntry(GenJnlLine, GLEntry, GLAccNo, GLAmount, 0, false, false);
        GenJnlPostLine.CreateGLEntry(GenJnlLine, GLAccNo, GLAmount, 0, false);
        GenJnlPostLine.ContinuePosting();
 */


    end;



    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInitInsert', '', false, false)]
    local procedure MyProcedure(var IsHandled: Boolean; var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")
    begin

        SalesHeader."Compress Prepayment" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document-Mailing", 'OnBeforeGetAttachmentFileName', '', false, false)]
    local procedure OnBeforeGetAttachmentFileName(var AttachmentFileName: Text[250]; PostedDocNo: Code[20]; EmailDocumentName: Text[250]; ReportUsage: Integer);
    var
        SalesOrder: record "Sales Header";
        SalesInvoice: record "Sales Invoice Header";
    begin

        case ReportUsage of
            Enum::"Report Selection Usage"::"S.Order".AsInteger():
                begin
                    SalesOrder.SetLoadFields("Prepayment %");
                    if SalesOrder.Get(Enum::"Sales Document Type"::Order.AsInteger(), PostedDocNo) and (SalesOrder."Prepayment %" = 100) then
                        AttachmentFileName := StrSubstNo('Sales Contract (Proforma) %1.pdf', PostedDocNo)
                    else
                        AttachmentFileName := StrSubstNo('Sales Contract %1.pdf', PostedDocNo);
                end;
            Enum::"Report Selection Usage"::"S.Invoice".AsInteger():
                begin
                    SalesInvoice.SetLoadFields("Prepayment Invoice");
                    if SalesInvoice.Get(PostedDocNo) and (SalesInvoice."Prepayment Invoice") then
                        AttachmentFileName := StrSubstNo('Prepayment Invoice %1.pdf', PostedDocNo)
                    else
                        AttachmentFileName := StrSubstNo('Sales Invoice %1.pdf', PostedDocNo);
                end;
        end;

    end;

    /// <summary>
    /// OpenExistingSalesOrder.
    /// </summary>
    /// <param name="DuplicateNotification">Notification.</param>
    /// <returns>Return value of type Text.</returns>
    procedure OpenExistingSalesOrder(MyNotification: Notification)
    var
        SalesHeader: Record "Sales Header";
        PageRunner: CodeUnit "Page Management";

    begin

        if not MyNotification.HasData('SystemId') then exit;

        if not SalesHeader.GetBySystemId(MyNotification.GetData('SystemId')) then exit;

        PageRunner.PageRun(SalesHeader);


    end;


    procedure OpenOpenOrArchivedOrder(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20])

    var
        SalesHeader: Record "Sales Header";
        SalesOrder: Page "Sales Order";

    begin

        case SalesHeader.Get(DocumentType, DocumentNo) of
            true:
                begin
                    SalesOrder.SetRecord(SalesHeader);
                    SalesOrder.Run();
                end;
            false:
                OpenArchivedOrder(DocumentType, DocumentNo);

        end;
    end;

    local procedure OpenArchivedOrder(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20])
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesOrderArchives: Page "Sales Order Archives";

    begin
        SalesHeaderArchive.FilterGroup(10);
        SalesHeaderArchive.SetRange("Document Type", DocumentType);
        SalesHeaderArchive.SetRange("No.", DocumentNo);
        SalesHeaderArchive.FilterGroup(0);

        if SalesHeaderArchive.IsEmpty() then exit;

        SalesOrderArchives.SetTableView(SalesHeaderArchive);
        SalesOrderArchives.Run();
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeSalesShptHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesShptHeaderInsert(var SalesShptHeader: Record "Sales Shipment Header"; SalesOrderHeader: Record "Sales Header"; CommitIsSupressed: Boolean; var PurchaseHeader: Record "Purchase Header");

    var
        Customer: Record Customer;
        Vendor: record Vendor;
        ShippingAgentServices: Record "Shipping Agent Services";
        SalesMgmt: CodeUnit "TFB Sales Mgmt";

    begin
        SalesShptHeader."Package Tracking No." := CopyStr(PurchaseHeader."Vendor Shipment No.", 1, 30);

        Customer.get(SalesShptHeader."Sell-to Customer No.");
        Vendor.get(PurchaseHeader."Buy-from Vendor No.");
        ShippingAgentServices := SalesMgmt.GetShippingAgentDetailsForDropShipItem(Vendor, Customer);
        SalesShptHeader."Shipping Agent Code" := ShippingAgentServices."Shipping Agent Code";
        SalesShptHeader."Shipping Agent Service Code" := ShippingAgentServices.Code;

    end;



    //TODO Explore how to reactive this functionality
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeCheckAssocPurchOrder', '', false, false)]
    local procedure HandleOnBeforeCheckAssocPurchOrder(TheFieldCaption: Text[250]; var IsHandled: Boolean; var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    var
    //PurchaseLine: Record "Purchase Line";
    //ContinueChangeQtyMsg: Label 'Do you want to change qty in associated PO?';
    begin


        /* 

                If (SalesLine."Quantity (Base)" <> xSalesLine."Quantity (Base)") and (xSalesLine."Quantity (Base)" = xSalesLine."Outstanding Qty. (Base)") then begin
                    PurchaseLine.SetRange("Document No.", SalesLine."Purchase Order No.");
                    PurchaseLine.SetRange("Line No.", SalesLine."Purch. Order Line No.");
                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);

                    If PurchaseLine.FindFirst() and (PurchaseLine."Quantity (Base)" <> SalesLine."Quantity (Base)") then
                        If Dialog.Confirm(ContinueChangeQtyMsg) then begin
                            PurchaseLine.validate(Quantity, SalesLine.Quantity);
                            PurchaseLine.Modify();
                            IsHandled := true;
                        end; */

        //TODO Determine if we actually need to recreate additional checks and code to duplicate other checks performed by this function
        //  end;

    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterUpdateSalesLineBeforePost', '', false, false)]
    local procedure HandleUpdateSalesLineBeforePost(CommitIsSuppressed: Boolean; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; WhseReceive: Boolean; WhseShip: Boolean)


    var
        ExchangeRate: Record "Currency Exchange Rate";
        NewUnitPrice: Decimal;
        Rate: Decimal;
        RateDiff: Decimal;
        RateDiffPerc: Decimal;
        UnitPriceDiff: Decimal;

    begin

        if (SalesLine."TFB Pre-Order") and (SalesLine."Qty. to Invoice" > 0) then begin

            //Transfer across fields

            Rate := ExchangeRate.ExchangeRate(SalesHeader."Posting Date", CopyStr(SalesLine."TFB Pre-Order Currency", 1, 10));
            RateDiff := Rate - SalesLine."TFB Pre-Order Exch. Rate";
            RateDiffPerc := RateDiff / SalesLine."TFB Pre-Order Exch. Rate";
            NewUnitPrice := Round(SalesLine."Unit Price" * (1 - RateDiffPerc), 0.01);
            UnitPriceDiff := Round(NewUnitPrice - SalesLine."Unit Price", 0.01);


            SalesLine.SuspendStatusCheck(true);
            SalesLine."TFB Pre-Order Adj. Exch. Rate" := Rate;
            SalesLine."TFB Pre-Order Unit Price Adj." := UnitPriceDiff;
            SalesLine.Validate("Unit Price", SalesLine."Unit Price" + UnitPriceDiff);
            SalesLine."TFB Pre-Order Adj. Date" := SalesHeader."Posting Date";
            SalesHeader.SuspendStatusCheck(false);
            Message('Updated unit price by %1 with exch rate perc diff of %2', UnitPriceDiff, RateDiffPerc);

        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateLocationCodeOnAfterSetOutboundWhseHandlingTime', '', false, false)]
    local procedure OnValidateLocationCodeOnAfterSetOutboundWhseHandlingTime(var SalesLine: Record "Sales Line");
    var
        SalesHeader: record "Sales Header";


    begin

        SalesHeader.SetLoadFields("Ship-to Country/Region Code", "Ship-to County");

        if not SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then exit;

        GetShippingAgentDetailsForSalesLine(SalesLine, SalesHeader);


    end;

    local procedure GetShippingAgentDetailsForSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")

    var
        ShippingAgentServices: Record "Shipping Agent Services";

    begin

        ShippingAgentServices := GetShippingAgentDetailsForLocation(SalesLine."Location Code", SalesHeader."Ship-to County", SalesHeader."Shipment Method Code", OverrideAgentDetails(SalesHeader));

        if ShippingAgentServices.Code = '' then exit;

        SalesLine."Shipping Agent Code" := ShippingAgentServices."Shipping Agent Code";
        SalesLine."Shipping Agent Service Code" := ShippingAgentServices.Code;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterUpdateLineDiscPct', '', false, false)]
    local procedure OnAfterUpdateLineDiscPct(var SalesLine: Record "Sales Line");
    begin
        if (SalesLine."Document Type" = Enum::"Sales Document Type"::Order) or (SalesLine."Document Type" = Enum::"Sales Document Type"::Quote) then
            if (SalesLine."Unit Price" > 0) and (SalesLine."Line Discount %" > 0) then
                SalesLine."TFB Price Unit Discount" := Round(((SalesLine."Line Discount %" / 100) * SalesLine."Unit Price") / SalesLine."Net Weight", 0.01, '=')
            else
                SalesLine."TFB Price Unit Discount" := 0;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateLineDiscountPercentOnBeforeUpdateAmounts', '', false, false)]
    local procedure OnValidateLineDiscountPercentOnBeforeUpdateAmounts(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer);

    var

        ItemUoM: Record "Item Unit of Measure";

    begin

        if (SalesLine."Document Type" = Enum::"Sales Document Type"::Order) or (SalesLine."Document Type" = Enum::"Sales Document Type"::Quote) then
            if (SalesLine."Unit Price" > 0) and (SalesLine."Line Discount %" > 0) then begin
                if SalesLine."Net Weight" > 0 then
                    SalesLine."TFB Price Unit Discount" := Round(((SalesLine."Line Discount %" / 100) * SalesLine."Unit Price") / SalesLine."Net Weight", 0.01, '=')
                else
                    if ItemUoM.Get(SalesLine."No.", SalesLine."Unit of Measure Code") then
                        SalesLine."TFB Price Unit Discount" := Round(((SalesLine."Line Discount %" / 100) * SalesLine."Unit Price") / ItemUoM.Weight, 0.01, '=')
            end
            else
                SalesLine."TFB Price Unit Discount" := 0;
    end;



    /// <summary>
    /// GetShippingAgentDetailsForDropShipItem.
    /// </summary>
    /// <param name="Item">Record Item.</param>
    /// <param name="Customer">Record Customer.</param>
    /// <returns>Return variable ShippingAgentServices of type Record "Shipping Agent Services".</returns>
    procedure GetShippingAgentDetailsForDropShipItem(Item: Record Item; Customer: Record Customer) ShippingAgentServices: Record "Shipping Agent Services"

    var
        Vendor: Record Vendor;
        PostCodeZone: Record "TFB Postcode Zone";
        ShippingAgent: Record "Shipping Agent";
        ItemCU: Codeunit "TFB Item Mgmt";


    begin

        PostcodeZone.SetRange("Customer Price Group", Customer."Customer Price Group");

        //Check if there is an override shipping agent and service

        if Vendor.Get(Item."Vendor No.") then
            if PostcodeZone.FindFirst() and (not ItemCU.GetVendorShippingAgentOverride(Vendor."No.", PostcodeZone.Code, ShippingAgentServices)) then
                if ShippingAgent.Get(Vendor."Shipping Agent Code") then
                    ShippingAgentServices.Get(ShippingAgent.Code, ShippingAgent."TFB Service Default");

    end;

    /// <summary>
    /// GetShippingAgentDetailsForDropShipItem.
    /// </summary>
    /// <param name="Vendor">Record Vendor.</param>
    /// <param name="Customer">Record Customer.</param>
    /// <returns>Return variable ShippingAgentServices of type Record "Shipping Agent Services".</returns>
    procedure GetShippingAgentDetailsForDropShipItem(Vendor: Record Vendor; Customer: Record Customer) ShippingAgentServices: Record "Shipping Agent Services"

    var

        ShippingAgent: Record "Shipping Agent";
        PostCodeZone: Record "TFB Postcode Zone";
        ItemCU: Codeunit "TFB Item Mgmt";


    begin

        PostcodeZone.SetRange("Customer Price Group", Customer."Customer Price Group");

        //Check if there is an override shipping agent and service


        if PostcodeZone.FindFirst() and (not ItemCU.GetVendorShippingAgentOverride(Vendor."No.", PostcodeZone.Code, ShippingAgentServices)) then
            if ShippingAgent.Get(Vendor."Shipping Agent Code") then
                ShippingAgentServices.Get(ShippingAgent.Code, ShippingAgent."TFB Service Default");

    end;



    /// <summary>
    /// GetShippingAgentDetailsForLocation.
    /// </summary>
    /// <param name="LocationCode">Code[10].</param>
    /// <param name="ShipToCounty">text[30].</param>
    /// <param name="ShipmentMethodCode">Code[10].</param>
    /// <returns>Return variable ShippingAgentServices of type Record "Shipping Agent Services".</returns>
    procedure GetShippingAgentDetailsForLocation(LocationCode: Code[10]; ShipToCounty: text[30]; ShipmentMethodCode: Code[10]; OverrideLocationShipping: Boolean) ShippingAgentServices: Record "Shipping Agent Services"

    var
        Location: Record Location;
        LocationShippingAgent: Record "TFB Location Shipping Agent";
        ShipmentMethod: Record "Shipment Method";

    begin
        if OverrideLocationShipping then exit;
        if not Location.Get(LocationCode) then exit;
        if ShipmentMethod.Get(ShipmentMethodCode) then
            if ShipmentMethod."TFB Pickup at Location" then exit;
        //Check if location is in same state or not
        if not LocationShippingAgentEnabled(Location) then exit;

        if (ShipToCounty <> Location.County) then
            //Interstate location
            if LocationShippingAgent.Get(LocationCode, Location."Country/Region Code", ShipToCounty) then
                ShippingAgentServices.Get(LocationShippingAgent."Shipping Agent Code", LocationShippingAgent."Agent Service Code")
            else
                ShippingAgentServices.Get(Location."TFB Insta Shipping Agent Code", Location."TFB Insta Agent Service Code")
        else
            //Locale state
            ShippingAgentServices.Get(Location."TFB Lcl Shipping Agent Code", Location."TFB Lcl Agent Service Code");

    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterCopyFromItem', '', false, false)]
    local procedure OnAfterCopyFromItem(var SalesLine: Record "Sales Line"; Item: Record Item; CurrentFieldNo: Integer);
    var
        SalesHeader: Record "Sales Header";
        PurchasingDropShip: Record Purchasing;
        PurchasingSpecialOrder: Record "Purchasing";
        Customer: Record Customer;
        ItemPurchasingDefault: Record Purchasing;

    begin
        //Check for if sales order overrides the default behaviour on dropshipping
        PurchasingDropShip.SetRange("Drop Shipment", true);

        SalesHeader.get(SalesLine."Document Type", SalesLine."Document No.");

        if SalesHeader."TFB Direct to Customer" = true then
            if PurchasingDropShip.FindFirst() then
                SalesLine.validate("Purchasing Code", PurchasingDropShip.Code);

        //Check if the customer overrides default drop ship behaviour and special orders instead
        if not ItemPurchasingDefault.Get(Item."Purchasing Code") then exit;
        if not ItemPurchasingDefault."Drop Shipment" then exit;
        Customer.SetLoadFields("TFB Special Order Dropships");
        Customer.Get(SalesLine."Sell-to Customer No.");
        if not Customer."TFB Special Order Dropships" then exit;

        PurchasingSpecialOrder.SetRange("Special Order", true);
        if not PurchasingSpecialOrder.FindFirst() then exit;


        SalesLine.validate("Purchasing Code", PurchasingSpecialOrder.Code);

    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnSetShipToCustomerAddressFieldsFromShipToAddrOnBeforeValidateShippingAgentFields, '', false, false)]
    local procedure OnSetShipToCustomerAddressFieldsFromShipToAddrOnBeforeValidateShippingAgentFields(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; ShipToAddr: Record "Ship-to Address"; var IsHandled: Boolean);
    var
        ShippingAgentServices: Record "Shipping Agent Services";

    begin
        ShippingAgentServices := GetShippingAgentDetailsForLocation(ShipToAddr."Location Code", ShipToAddr.County, ShipToAddr."Shipment Method Code", ShipToAddr."TFB Override Location Shipping");

        if ShippingAgentServices.Code = '' then exit;

        SalesHeader."Shipping Agent Code" := ShippingAgentServices."Shipping Agent Code";
        SalesHeader."Shipping Agent Service Code" := ShippingAgentServices.Code;
        IsHandled := true;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterInitHeaderDefaults', '', false, false)]
    local procedure OnAfterInitHeaderDefaults(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; xSalesLine: Record "Sales Line");

    begin

        GetShippingAgentDetailsForSalesLine(SalesLine, SalesHeader);
    end;

    local procedure LocationShippingAgentEnabled(Location: Record Location): Boolean

    var
        failedtest: Boolean;

    begin

        if Location."TFB Lcl Agent Service Code" = '' then failedtest := true;
        if Location."TFB Insta Agent Service Code" = '' then failedtest := true;
        if Location."TFB Lcl Shipping Agent Code" = '' then failedtest := true;
        if Location."TFB Insta Shipping Agent Code" = '' then failedtest := true;

        exit(not failedtest)
    end;

    /// <summary>
    /// GetBaseQtyForSalesLine.
    /// </summary>
    /// <param name="SalesLine">Record "Sales Line".</param>
    /// <returns>Return value of type Decimal.</returns>
    procedure GetBaseQtyForSalesLine(SalesLine: Record "Sales Line"): Decimal

    var
        Item: Record Item;
        ItemUoM: Record "Item Unit of Measure";

    begin
        if item.Get(SalesLine."No.") then
            if ItemUoM.Get(Item."No.", Item."Sales Unit of Measure") then
                exit(ItemUoM."Qty. per Unit of Measure" * 1);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeInitHeaderLocactionCode, '', false, false)]
    local procedure OnBeforeInitHeaderLocationCode(var IsHandled: Boolean; var SalesLine: Record "Sales Line")

    var
        SalesHeader: Record "Sales Header";
        IntelligentLocationCode: Code[10];

    begin
        if SalesLine.Type <> SalesLine.Type::Item then exit;

        SalesHeader.SetLoadFields("Ship-to Code", "Location Code");
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        IntelligentLocationCode := SalesHeader."Location Code";

        //If not intelligent location then exit unhandled
        GetIntelligentLocation(SalesLine."Sell-to Customer No.", SalesHeader."Ship-to Code", SalesLine."No.", GetBaseQtyForSalesLine(SalesLine), IntelligentLocationCode);

        if IntelligentLocationCode = '' then exit;
        // Intelligent location return so show that it has been handled
        IsHandled := true;
        SalesLine."Location Code" := IntelligentLocationCode;

    end;



    local procedure GetSalesUoMForItem(Item: Record Item) ItemUoM: Record "Item Unit of Measure";

    var

    begin

        ItemUoM.Get(Item."No.", Item."Sales Unit of Measure");

    end;

    local procedure HasLinePrepaymentBeenPaid(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"): Boolean
    var
        PrepaymentInvoice: Record "Sales Invoice Header";
        PrepaymentInvoiceLine: Record "Sales Invoice Line";

    begin

        if PrepaymentInvoice.Get(SalesHeader."Last Prepayment No.") and PrepaymentInvoiceLine.Get(PrepaymentInvoice."No.", SalesLine."Line No.") then
            if PrepaymentInvoiceLine."Prepayment Line" and (PrepaymentInvoiceLine."Prepayment %" = 100) then begin
                PrepaymentInvoice.CalcFields("Remaining Amount");
                if PrepaymentInvoice."Remaining Amount" = 0 then
                    exit(true);
            end;


    end;

    local procedure OverrideAgentDetails(SalesHeader: Record "Sales Header"): Boolean

    var

        ShipToAddress: Record "Ship-to Address";
        Customer: Record Customer;
    begin

        if not Customer.Get(SalesHeader."Sell-to Customer No.") then exit(false);
        if SalesHeader."Ship-to Code" <> '' then
            if ShipToAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code") then
                exit(ShipToAddress."TFB Override Location Shipping");

        exit(Customer."TFB Override Location Shipping");

    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeUpdateUnitPrice', '', false, false)]
    local procedure OnBeforeUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer; var Handled: Boolean);
    var
        ExistingLines: Record "Sales Line";
        BlanketSalesLine: Record "Sales Line";

    begin

        if SalesLine."Blanket Order No." <> '' then exit;
        if not (SalesLine.Type = SalesLine.Type::Item) then exit;

        BlanketSalesLine.SetRange("Document Type", BlanketSalesLine."Document Type"::"Blanket Order");
        BlanketSalesLine.SetRange("No.", SalesLine."No.");
        BlanketSalesLine.SetFilter("Outstanding Qty. (Base)", '>0');

        BlanketSalesLine.SetLoadFields("Outstanding Qty. (Base)", "Document No.", "Line No.");

        if not (BlanketSalesLine.FindFirst()) then exit;

        if not BlanketSalesLine."TFB Consume Blanket Order" then exit;

        ExistingLines.SetLoadFields("Outstanding Qty. (Base)");
        ExistingLines.SetRange("Blanket Order No.", BlanketSalesLine."Document No.");
        ExistingLines.SetRange("Blanket Order Line No.", BlanketSalesLine."Line No.");
        ExistingLines.SetRange("Document Type", ExistingLines."Document Type"::Order);

        ExistingLines.CalcSums(ExistingLines."Outstanding Qty. (Base)");

        if (BlanketSalesLine."Outstanding Qty. (Base)" - ExistingLines."Outstanding Qty. (Base)" - SalesLine."Quantity (Base)") < 0 then exit;

        SalesLine."Blanket Order No." := BlanketSalesLine."Document No.";
        SalesLine."Blanket Order Line No." := BlanketSalesLine."Line No.";


    end;


    /// <summary>
    /// GetIntelligentLocation.
    /// </summary>
    /// <param name="CustomerNo">Code[20].</param>
    /// <param name="ItemNo">Code[20].</param>
    /// <param name="MinQty">Decimal.</param>
    /// <returns>Return value of type Code[10].</returns>
    procedure GetIntelligentLocation(CustomerNo: Code[20]; "Ship-to Code": Code[10]; ItemNo: Code[20]; MinQty: Decimal; var LocationCode: Code[10]): Boolean

    var
        AddressBuffer: Record "Address Buffer";

    begin

        exit(GetIntelligentLocation(CustomerNo, "Ship-to Code", ItemNo, MinQty, LocationCode, AddressBuffer));

    end;

    procedure GetIntelligentLocation(CustomerNo: Code[20]; ItemNo: Code[20]; MinQty: Decimal; var LocationCode: Code[10]): boolean

    var
        AddressBuffer: Record "Address Buffer";

    begin

        exit(GetIntelligentLocation(CustomerNo, '', ItemNo, MinQty, LocationCode, AddressBuffer));

    end;

    /// <summary>
    /// GetIntelligentLocation.
    /// </summary>
    /// <param name="CustomerNo">Code[20].</param>
    /// <param name="ItemNo">Code[20].</param>
    /// <param name="MinQty">Decimal.</param>
    /// <param name="Address">Temporary Record "Address Buffer".</param>
    /// <returns>Return value of type Code[10].</returns>
    procedure GetIntelligentLocation(CustomerNo: Code[20]; "Ship-to Code": Code[10]; ItemNo: Code[20]; MinQty: Decimal; var LocationCode: Code[10]; Address: Record "Address Buffer" temporary): Boolean

    var
        Location: Record Location;
        CustomerShipTo: Record "Ship-to Address";
        Customer: Record Customer;
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        QtyRemainingAtLocation: Decimal;
        LocationCode1: Code[10];
        InitLocationCode: Code[10];
        ValidLocationFound: Boolean;
    begin

        //test if we are handling
        if not (Customer.Get(CustomerNo) and Item.Get(ItemNo) and Item.IsInventoriableType()) then exit(false);

        //Get minimum test quantity if none provided
        if MinQty = 0 then MinQty := GetSalesUoMForItem(Item)."Qty. per Unit of Measure";

        InitLocationCode := LocationCode;

        //Determine if ship-to location rather than default customer location is used
        if ("Ship-to Code" <> '') and (CustomerShipTo.Get(CustomerNo, "Ship-to Code")) then
            LocationCode1 := CustomerShipTo."Location Code"
        else
            LocationCode1 := Customer."Location Code";

        //Check if inventory is available at the default location code
        ItemLedgerEntry.SetRange("Location Code", LocationCode1);
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>0');
        ItemLedgerEntry.CalcSums("Remaining Quantity");
        QtyRemainingAtLocation := ItemLedgerEntry."Remaining Quantity";

        //If enough stock exists at location then use it and check whether it is the same as provided initially
        if QtyRemainingAtLocation >= MinQty then begin
            LocationCode := LocationCode1;
            exit(LocationCode <> InitLocationCode);
        end;

        //Check if inventory is in stock at other locations currently

        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', QtyRemainingAtLocation);
        ItemLedgerEntry.SetCurrentKey("Remaining Quantity");
        ItemLedgerEntry.SetAscending("Remaining Quantity", false);

        //Iterate thourgh ledger entried for each location 
        if ItemLedgerEntry.Findset(false) then
            repeat
                Location.SetLoadFields("TFB Use for ILA", "TFB Enabled", Code);
                Location.Get(ItemLedgerEntry."Location Code");
                if not (Location.IsInTransit(ItemLedgerEntry."Location Code")) and (Location."TFB Enabled") and (Location."TFB Use for ILA") and not (ItemLedgerEntry."Remaining Quantity" < MinQty) then begin
                    LocationCode := ItemLedgerEntry."Location Code";
                    ValidLocationFound := true;
                end;
            until (ItemLedgerEntry.Next() = 0) or (ValidLocationFound = true);

        //If enough stock exists at and alternative location then use it and check whether it is the same as provided initially
        if ValidLocationFound then exit(LocationCode <> InitLocationCode);

        //Check if stock is on a purch line incoming

        //Check if for the first incoming purchase order for this item
        PurchaseLine.SetRange("No.", Item."No.");
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetFilter("Outstanding Qty. (Base)", '>0');
        PurchaseLine.SetRange("Drop Shipment", false);
        PurchaseLine.SetCurrentKey("Planned Receipt Date");
        PurchaseLine.SetAscending("Planned Receipt Date", true);


        if PurchaseLine.FindSet(false) then
            repeat
                Location.SetLoadFields("TFB Use for ILA", "TFB Enabled", Code, "Use As In-Transit");
                Location.Get(PurchaseLine."Location Code");
                if not (Location."Use As In-Transit") and (Location."TFB Enabled") and (Location."TFB Use for ILA") and (PurchaseLine."Outstanding Qty. (Base)" >= MinQty) and not (PurchaseLine."Drop Shipment") then begin

                    LocationCode := PurchaseLine."Location Code";
                    ValidLocationFound := true;
                end;
            until (PurchaseLine.Next() = 0) or (ValidLocationFound = true);

        //If valid purchase line found exit with the location code
        if ValidLocationFound then exit(LocationCode <> InitLocationCode);

        //Check if for the first incoming transfer for this item
        TransferLine.SetRange("Item No.", Item."No.");
        TransferLine.SetFilter("Outstanding Qty. (Base)", '>0');
        TransferLine.SetCurrentKey("Receipt Date");
        TransferLine.SetAscending("Receipt Date", true);

        if TransferLine.FindSet(false) then
            repeat
                Location.SetLoadFields("TFB Use for ILA", "TFB Enabled", Code, "Use As In-Transit");
                Location.Get(TransferLine."Transfer-to Code");
                if not (Location."Use As In-Transit") and (Location."TFB Enabled") and (Location."TFB Use for ILA") and (TransferLine."Outstanding Qty. (Base)" >= MinQty) then begin
                    LocationCode := TransferLine."Transfer-to Code";
                    ValidLocationFound := true;
                end;
            until (TransferLine.Next() = 0) or (ValidLocationFound = true);

        //If valid transfer line found
        if ValidLocationFound then exit(LocationCode <> InitLocationCode);

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    local procedure HandleOnBeforeReleaseSalesDoc(PreviewMode: Boolean; var SalesHeader: Record "Sales Header")

    var
        Customer: Record Customer;


    begin

        Customer.Get(SalesHeader."Sell-to Customer No.");

        if (Customer."TFB External No. Req.") and (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then
            if SalesHeader."External Document No." = '' then
                Error('Cannot release. External Reference No. is required for customers orders');


    end;

    /// <summary>
    /// GetShipmentNoForInvoiceLine.
    /// </summary>
    /// <param name="DocumentNo">Code[20].</param>
    /// <param name="LineNo">Integer.</param>
    /// <returns>Return value of type Code[20].</returns>
    procedure GetShipmentNoForInvoiceLine(DocumentNo: Code[20]; LineNo: Integer): Code[20]

    var
        ItemLedger: Record "Item Ledger Entry";
        SalesShipment: Record "Sales Shipment Header";
        ValueEntry: Record "Value Entry";

    begin
        ValueEntry.SetRange("Document No.", DocumentNo);
        ValueEntry.SetRange("Document Line No.", LineNo);
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetRange(Adjustment, false);

        if ValueEntry.FindFirst() then
            //Locate shipment
            if ItemLedger.Get(ValueEntry."Item Ledger Entry No.") then
                if ItemLedger."Document Type" = ItemLedger."Document Type"::"Sales Shipment" then
                    if SalesShipment.Get(ItemLedger."Document No.") then
                        //Return the shipment document number
                        exit(SalesShipment."No.");
    end;

    /// <summary>
    /// SendPODRequest.
    /// </summary>
    /// <param name="DocumentNo">Code[20].</param>
    /// <param name="LineNo">Integer.</param>
    procedure SendPODRequest(DocumentNo: Code[20]; LineNo: Integer)

    var
        ItemLedger: Record "Item Ledger Entry";
        SalesShipment: Record "Sales Shipment Header";
        ValueEntry: Record "Value Entry";
        ShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";

    begin
        ValueEntry.SetRange("Document No.", DocumentNo);
        if LineNo > 0 then
            ValueEntry.SetRange("Document Line No.", LineNo);
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetRange(Adjustment, false);

        if ValueEntry.Findset(false) then
            repeat

                //Locate shipments
                if ItemLedger.Get(ValueEntry."Item Ledger Entry No.") then begin

                    //Retrieve sales shipment
                    Clear(SalesShipment);
                    if ItemLedger."Document Type" = ItemLedger."Document Type"::"Sales Shipment" then
                        if SalesShipment.Get(ItemLedger."Document No.") then
                            //Call Sales Shipment CU
                            ShipmentCU.SendShipmentStatusQuery(SalesShipment, DocumentNo);
                end;


            until ValueEntry.Next() < 1;

    end;

    /// <summary>
    /// AdjustSalesLinePlannedDateByItemRes.
    /// </summary>
    /// <param name="ItemLedgerEntry">Record "Item Ledger Entry".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure AdjustSalesLinePlannedDateByItemRes(ItemLedgerEntry: Record "Item Ledger Entry"): Boolean

    var
        LotInfo: Record "Lot No. Information";
        ResEntry: Record "Reservation Entry";
        ResEntryDemand: Record "Reservation Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        DateFormula: DateFormula;
        BlockDate: Date;


    begin



        LotInfo.SetRange("Item No.", ItemLedgerEntry."Item No.");
        LotInfo.SetRange("Lot No.", ItemLedgerEntry."Lot No.");
        LotInfo.SetRange("Variant Code", ItemLedgerEntry."Variant Code");

        if LotInfo.FindFirst() then
            if (LotInfo.Blocked) and (LotInfo."TFB Date Available" > 0D) then
                BlockDate := LotInfo."TFB Date Available" else
                BlockDate := today();

        if Dialog.Confirm('Defer shipments by 1 day from %1 for %2?', false, BlockDate, ItemLedgerEntry.Description) then
            Evaluate(DateFormula, '+1D')
        else
            Evaluate(DateFormula, '0D');

        ResEntry.SetRange("Item No.", ItemLedgerEntry."Item No.");
        ResEntry.SetRange("Source Ref. No.", ItemLedgerEntry."Entry No.");
        ResEntry.SetRange("Source Type", 32);
        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Reservation);

        if Dialog.Confirm('Found %1 Reservations to Adjust. Continue?', true, ResEntry.Count()) then
            if ResEntry.Findset(false) then
                repeat
                    Clear(ResEntryDemand);
                    Clear(SalesLine);
                    ResEntryDemand.SetRange("Entry No.", ResEntry."Entry No.");
                    ResEntryDemand.SetRange(Positive, false);
                    ResEntryDemand.SetRange("Source Type", 37);



                    if ResEntryDemand.FindFirst() then begin
                        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                        SalesLine.SetRange("Document No.", ResEntryDemand."Source ID");
                        SalesLine.SetRange("Line No.", ResEntryDemand."Source Ref. No.");
                        SalesLine.SetRange("Whse. Outstanding Qty. (Base)", 0);

                        if SalesLine.FindFirst() then begin

                            SalesHeader.SetRange("Document Type", SalesLine."Document Type");
                            SalesHeader.SetRange("No.", SalesLine."Document No.");
                            SalesHeader.FindFirst();

                            if Dialog.Confirm('Change date from %1 to %2 for order %3 to %4 originally requested on %5', true, SalesLine."Shipment Date", CalcDate(DateFormula, BlockDate), SalesLine."Document No.", SalesHeader."Sell-to Customer Name", SalesHeader."Requested Delivery Date") then begin

                                SalesHeader.SetRange("Document Type", SalesLine."Document Type");
                                SalesHeader.SetRange("No.", SalesLine."Document No.");

                                SalesHeader.FindFirst();


                                ReleaseSalesDoc.PerformManualReopen(SalesHeader);





                                SalesLine.Validate("Shipment Date", CalcDate(DateFormula, BlockDate));
                                SalesLine.Modify();

                                if not (SalesLine."Prepayment %" > 0) then
                                    ReleaseSalesDoc.PerformManualRelease(SalesHeader)
                                else
                                    if (Salesline."Prepayment Amount" = SalesLine.Amount) then
                                        if HasLinePrepaymentBeenPaid(SalesHeader, SalesLine) then
                                            ReleaseSalesDoc.PerformManualRelease(SalesHeader);

                            end;
                        end;

                    end;
                until ResEntry.Next() < 1;

    end;

    /// <summary>
    /// GetSalesLineStatusEmoji.
    /// </summary>
    /// <param name="SalesLine">Record "Sales Line".</param>
    /// <returns>Return value of type Text.</returns>
    procedure GetSalesLineStatusEmoji(SalesLine: Record "Sales Line"): Text

    var
        Item: Record Item;
        _availability: Text;
        emojiAvailableTxt: Label '🟢';
        emojiDropShipPendingTxt: Label '🛒';
        emojiDropShipTxt: Label '📦';
        emojiNotApplicableTxt: Label '';
        emojiNotAvailableTxt: Label '🟠';
        emojiReservedTxt: Label '👌';
        emojiReservedWaitingStockTxt: Label '🪂';
        emojiShippedTxt: Label '😀';
        emojiSpecialTxt: Label '🔐';

    begin
        _availability := '';

        SalesLine.CalcFields(SalesLine."Reserved Qty. (Base)");


        if SalesLine.Type = SalesLine.Type::Item then
            if Item.Get(SalesLine."No.") then begin
                Item.SetRange("Location Filter", SalesLine."Location Code");
                Item.CalcFields(Inventory);
                if not ((SalesLine."Drop Shipment") or (SalesLine."Special Order")) then
                    if SalesLine."Outstanding Qty. (Base)" = 0 then
                        _availability := emojiShippedTxt
                    else
                        if SalesLine."Reserved Qty. (Base)" = SalesLine."Outstanding Qty. (Base)" then
                            if Item.Inventory > SalesLine."Outstanding Qty. (Base)" then
                                _availability := emojiReservedTxt
                            else
                                _availability := emojiReservedWaitingStockTxt
                        else
                            if Item.Inventory > SalesLine."Outstanding Qty. (Base)" then
                                _availability := emojiAvailableTxt
                            else
                                _availability := emojiNotAvailableTxt
                else
                    if SalesLine."Outstanding Qty. (Base)" = 0 then
                        _availability := emojiShippedTxt
                    else begin

                        if SalesLine."Drop Shipment" then
                            if SalesLine."Purchase Order No." <> '' then
                                _availability := emojiDropShipTxt else
                                _availability := emojiDropShipPendingTxt;

                        if SalesLine."Special Order" then
                            if SalesLine."Special Order Purchase No." <> '' then
                                _availability := emojiSpecialTxt else
                                _availability := emojiDropShipPendingTxt;
                    end;
            end
            else
                _availability := emojiNotApplicableTxt
        else
            _availability := emojiNotApplicableTxt;
        exit(_availability);
    end;



    /// <summary>
    /// OpenRelatedAvailabilityInfo.
    /// </summary>
    /// <param name="SalesLineStatus">Enum "TFB Sales Line Status".</param>
    /// <param name="RelatedRecRef">RecordRef.</param>
    procedure OpenRelatedAvailabilityInfo(SalesLineStatus: Enum "TFB Sales Line Status"; RelatedRecRef: RecordRef)

    var
        Container: Record "TFB Container Entry";
        LedgerEntry: Record "Item Ledger Entry";
        LotNoInfo: Record "Lot No. Information";
        Purchase: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        WhseShip: Record "Warehouse Shipment Header";
        WhseShipLine: Record "Warehouse Shipment Line";
        ContainerPage: Page "TFB Container Entry";
        LedgerEntryPage: Page "Item Ledger Entries";
        LotNoInfoPage: Page "Lot No. Information Card";
        PurchasePage: Page "Purchase Order";
        WhseShipPage: Page "Warehouse Shipment";


    begin

        case RelatedRecRef.Number() of
            Database::"Purchase Line":
                begin
                    RelatedRecRef.SetTable(PurchaseLine);
                    Purchase.SetRange("No.", PurchaseLine."Document No.");
                    Purchase.SetRange("Document Type", PurchaseLine."Document Type");
                    if Purchase.FindFirst() then begin
                        PurchasePage.SetRecord(Purchase);
                        PurchasePage.Run();
                    end;

                end;
            Database::"TFB Container Entry":
                begin
                    RelatedRecRef.SetTable(Container);
                    if not Container.IsEmpty() then begin
                        ContainerPage.SetRecord(Container);
                        ContainerPage.Run();
                    end;

                end;
            Database::"Item Ledger Entry":
                begin
                    RelatedRecRef.SetTable(LedgerEntry);
                    if not LedgerEntry.IsEmpty() then begin
                        LedgerEntryPage.SetTableView(LedgerEntry);
                        LedgerEntryPage.Run();
                    end;

                end;
            Database::"Purchase Header":
                begin
                    RelatedRecRef.SetTable(Purchase);
                    if not Purchase.IsEmpty() then begin
                        PurchasePage.SetRecord(Purchase);
                        PurchasePage.Run();
                    end;
                end;
            Database::"Lot No. Information":
                begin
                    RelatedRecRef.SetTable(LotNoInfo);
                    if not LotNoInfo.IsEmpty() then begin
                        LotNoInfoPage.SetRecord(LotNoInfo);
                        LotNoInfoPage.Run();
                    end;
                end;
            Database::"Warehouse Shipment Line":
                begin
                    RelatedRecRef.SetTable(WhseShipLine);
                    WhseShip.SetRange("No.", WhseShipLine."No.");
                    if WhseShip.FindFirst() then begin

                        WhseShipPage.SetRecord(WhseShip);
                        WhseShipPage.Run();
                    end;


                end;
        end;
    end;

    /// <summary>
    /// GetItemSalesLineAvailability.
    /// </summary>
    /// <param name="SalesLine">Record "Sales Line".</param>
    /// <param name="AvailInfo">VAR Text[512].</param>
    /// <param name="ShipDatePlanned">VAR Date.</param>
    /// <param name="LineStatus">VAR Enum "TFB Sales Line Status".</param>
    /// <param name="RelatedRecRef">VAR RecordRef.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure GetItemSalesLineAvailability(SalesLine: Record "Sales Line"; var AvailInfo: Text[512]; var ShipDatePlanned: Date; var LineStatus: Enum "TFB Sales Line Status"; var RelatedRecRef: RecordRef): Boolean

    var
        Container: Record "TFB Container Entry";
        DemandResEntry: Record "Reservation Entry";
        LedgerEntry: Record "Item Ledger Entry";
        LotNoInfo: Record "Lot No. Information";
        Purchase: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SupplyResEntry: Record "Reservation Entry";
        Vendor: Record Vendor;
        WhseShptLine: Record "Warehouse Shipment Line";
        DeliverySLA: TExt;
        Status: Text[512];



    begin

        SalesLine.CalcFields("Whse. Outstanding Qty.");

        if SalesLine."Qty. Shipped (Base)" = 0 then

            //Check if drop ship

            if not SalesLine."Drop Shipment" then

                //Check if anything is scheduled on warehouse shipment

                if SalesLine."Whse. Outstanding Qty." = 0 then begin

                    //Provide details of warehouse shipment
                    Status := 'Planned for dispatch';
                    SalesLine.CalcFields("Reserved Qty. (Base)");
                    if SalesLine."Reserved Qty. (Base)" = SalesLine."Outstanding Qty. (Base)" then begin

                        DemandResEntry.SetRange("Source ID", SalesLine."Document No.");
                        DemandResEntry.SetRange("Source Ref. No.", SalesLine."Line No.");
                        DemandResEntry.SetRange("Item No.", SalesLine."No.");
                        DemandResEntry.SetRange(Positive, false);

                        if DemandResEntry.FindFirst() then begin

                            SupplyResEntry.SetRange(Positive, true);
                            SupplyResEntry.SetRange("Entry No.", DemandResEntry."Entry No.");

                            if SupplyResEntry.FindFirst() then
                                case SupplyResEntry."Source Type" of
                                    32: //Item Ledger Entry

                                        if LedgerEntry.Get(SupplyResEntry."Source Ref. No.") then begin

                                            Status += StrSubstNo(' from stock already in inventory');
                                            LineStatus := LineStatus::ReservedFromStock;
                                            RelatedRecRef.GetTable(LedgerEntry);

                                            LotNoInfo.SetRange("Item No.", LedgerEntry."Item No.");
                                            LotNoInfo.SetRange("Lot No.", LedgerEntry."Lot No.");
                                            LotNoInfo.SetRange("Variant Code", LedgerEntry."Variant Code");


                                            if LotNoInfo.FindFirst() then
                                                if (LotNoInfo.Blocked = true) and (LotNoInfo."TFB Date Available" > 0D) then begin
                                                    Status += StrSubstNo(' and pending release on %1', LotNoInfo."TFB Date Available");
                                                    LineStatus := LineStatus::ReservedFromStockPendingRelease;
                                                    RelatedRecRef.GetTable(LotNoInfo);

                                                end;

                                        end;

                                    39: //Purchase Order Entry
                                        begin
                                            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                                            PurchaseLine.SetRange("Line No.", SupplyResEntry."Source Ref. No.");
                                            PurchaseLine.SetRange("Document No.", SupplyResEntry."Source ID");

                                            if PurchaseLine.FindFirst() then
                                                case PurchaseLine."TFB Container Entry No." of
                                                    '':
                                                        begin
                                                            Status += StrSubstNo(' based on arrival from local purchase order due into warehouse on %1', purchaseline."Expected Receipt Date");
                                                            LineStatus := LineStatus::ReservedFromLocalPO;
                                                            RelatedRecRef.GetTable(PurchaseLine);
                                                        end;
                                                    else
                                                        if Container.Get(PurchaseLine."TFB Container Entry No.") then begin
                                                            RelatedRecRef.GetTable(Container);
                                                            case Container.Status of

                                                                Container.Status::Planned:
                                                                    begin

                                                                        Status += StrSubstNo(' based on planned overseas container due for arrival on %1 and estimated to be available on %2', Container."Est. Arrival Date", Container."Est. Warehouse");
                                                                        LineStatus := LineStatus::ReservedFromPlannedContainer;

                                                                    end;
                                                                Container.Status::ShippedFromPort:
                                                                    begin
                                                                        Status += StrSubstNo(' based on shipped container %1, due for arrival on %2 and estimated to be available on %3', Container."Container No.", Container."Est. Arrival Date", Container."Est. Warehouse");
                                                                        LineStatus := LineStatus::ReservedFromInboundContainer;
                                                                    end;
                                                                Container.Status::PendingTreatment:
                                                                    begin
                                                                        Status += StrSubstNo(' based on container that arrived on %1.', Container."Arrival Date");
                                                                        if Container."Fumigation Req." then
                                                                            Status += ' Fumigation Currently In Progress.';
                                                                        if Container."Inspection Req." or Container."IFIP Req." then
                                                                            Status += ' Inspection Req.';

                                                                        LineStatus := LineStatus::ReservedFromArrivedContainer;
                                                                    end;
                                                                Container.Status::PendingClearance:
                                                                    begin
                                                                        Status += StrSubstNo(' based on container that arrived on %1.', Container."Arrival Date");
                                                                        if Container."Fumigation Req." then
                                                                            Status += ' Fumigation Complete.';
                                                                        if Container."Inspection Req." or Container."IFIP Req." then
                                                                            if Container."Inspection Date" > 0D then
                                                                                Status += StrSubstNo(' Inspection Booked On %1.', Container."Inspection Date")
                                                                            else
                                                                                Status += ' Still Waiting for Inspection Date to Be Booked';

                                                                        LineStatus := LineStatus::ReservedFromArrivedContainer;
                                                                    end;
                                                            end;
                                                        end;
                                                end;
                                        end;
                                end;
                        end;

                    end;
                    //Get reservation entries for this line
                end
                //Get Location of reservation

                else begin

                    WhseShptLine.SetRange("Source Document", WhseShptLine."Source Document"::"Sales Order");
                    WhseShptLine.SetRange("Source No.", SalesLine."Document No.");
                    WhseShptLine.SetRange("Source Line No.", SalesLine."Line No.");

                    if WhseShptLine.FindFirst() then begin
                        ShipDatePlanned := WhseShptLine."Shipment Date";
                        LineStatus := LineStatus::SentToWarehouse;
                        Status := StrSubstNo('Being prepared by warehouse for dispatch on %1', WhseShptLine."Shipment Date");
                        RelatedRecRef.GetTable(WhseShptLine);

                    end;
                end
            else begin
                //Get Vendor Details
                Clear(PurchaseLine);
                Purchase.SetRange("Document Type", Purchase."Document Type"::Order);
                Purchase.SetRange("No.", SalesLine."Purchase Order No.");
                PurchaseLine.SetRange("Document No.", SalesLine."Purchase Order No.");
                PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SetRange("Line No.", SalesLine."Purch. Order Line No.");

                if Purchase.FindFirst() and PurchaseLine.FindFirst() then begin
                    if Purchase."TFB Delivery SLA" = '' then begin
                        Vendor.Get(Purchase."Buy-from Vendor No.");
                        DeliverySLA := Vendor."TFB Delivery SLA"
                    end
                    else
                        DeliverySLA := Purchase."TFB Delivery SLA";

                    Status := StrSubstNo('Confirmed by %1 for drop-ship on %2 with SLA of %3', Purchase."Buy-from Vendor Name", PurchaseLine."Planned Receipt Date", DeliverySLA);
                    LineStatus := LineStatus::ConfirmedByDropShipSupplier;
                    RelatedRecRef.GetTable(Purchase);
                end else begin
                    Status := 'Pending confirmation for drop-ship';
                    LineStatus := LineStatus::NotConfirmedByDropShipSupplier;
                    RelatedRecRef.gettable(SalesLine);
                end;
            end
        else

            if SalesLine."Qty. Shipped (Base)" < SalesLine."Quantity (Base)" then begin

                //Partially Shipped

                Status := format(SalesLine."Qty. Shipped (Base)") + ' already shipped. Remainder planned for dispatch.';
                LineStatus := LineStatus::ShippedPendingInvoice;
            end

            else

                //Fully Shipped
                if SalesLine."Qty. Invoiced (Base)" = SalesLine."Qty. Shipped (Base)" then begin
                    Status := 'Shipped and invoiced';
                    LineStatus := LineStatus::ShippedPendingInvoice;

                end
                else begin
                    Status := 'Shipped, but pending invoicing';
                    LineStatus := LineStatus::ShippedPendingInvoice;
                end;

        AvailInfo := Status;
        if LineStatus.AsInteger() > 0 then exit(true) else exit(false);


    end;

    internal procedure GetPaymentStatusEmoji(Rec: Record "Sales Line"): Text
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: record "Sales Invoice Line";



        emojiNotApplicableTxt: Label '▫️';
        emojiWaitingForPrepaymentInvoiceTxt: Label '🟠';
        emojiWaitingForPrepaymentInvoiceToBePaidTxt: Label '💰';
        emojiPrepaymentInvoicePaidTxt: Label '😀';
        InvoicePaid: Boolean;

    begin

        if (Rec."Prepayment %" = 0) or (Rec."Prepmt. Line Amount" = 0) then
            exit(emojiNotApplicableTxt);

        if (Rec."Prepmt. Amt. Inv." >= 0) and (Rec."Prepmt. Amt. Inv." < Rec."Prepmt. Line Amount") then
            exit(emojiWaitingForPrepaymentInvoiceTxt);

        if (Rec."Prepmt. Amt. Inv." = Rec."Prepmt. Line Amount") then begin

            //Check for related invoice

            SalesInvoiceHeader.SetRange("Prepayment Invoice", true);
            SalesInvoiceHeader.SetRange("Prepayment Order No.", Rec."Document No.");
            SalesInvoiceHeader.SetLoadFields("No.", "Prepayment Order No.");

            if SalesInvoiceHeader.FindSet(false) then
                repeat
                    SalesInvoiceHeader.CalcFields("Remaining Amount");
                    if SalesInvoiceLine.Get(SalesInvoiceHeader."No.", Rec."Line No.") then
                        if SalesInvoiceLine."Prepayment Line" then
                            if SalesInvoiceHeader."Remaining Amount" = 0 then
                                InvoicePaid := true
                            else
                                InvoicePaid := false;

                until SalesInvoiceHeader.Next() = 0;

            if InvoicePaid then
                exit(emojiPrepaymentInvoicePaidTxt)
            else
                exit(emojiWaitingForPrepaymentInvoiceToBePaidTxt);
        end;


    end;

}